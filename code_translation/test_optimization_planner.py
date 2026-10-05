"""Tests for the optimization planner.

No live LLM calls; the planner is exercised with a mocked
``llm_call`` callable. Live LLM plumbing is covered by piece 3 (the
orchestrator integration), so this file only proves:
  * parsing + validation: malformed/hallucinated focus_files get
    filtered, JSON fence is required, confidence is normalised
  * cache: re-planning with the same fingerprint hits cache (no LLM)
  * cache invalidation: a structural change forces a fresh plan
  * trivial-plan path: self-contained kernels never call the LLM
  * fingerprint stability: same struct → same fp
  * fallback: LLM errors / unparseable replies fall back to root-only
"""

from __future__ import annotations

import json
import os
import shutil
import sys
import tempfile
import textwrap
import unittest
from pathlib import Path

_HERE = Path(__file__).resolve().parent
if str(_HERE) not in sys.path:
    sys.path.insert(0, str(_HERE))

import bench_structure as bs  # noqa: E402
import optimization_planner as op  # noqa: E402


def _make_self_contained_bench(tmp: Path) -> bs.BenchStructure:
    (tmp / "pe.csl").write_text(textwrap.dedent("""
        const memcpy = @import_module("<memcpy/memcpy>", p);
        fn run() void {
            @fmacs(d, d, s, 1.0);
        }
    """), encoding="utf-8")
    (tmp / "layout.csl").write_text("// l\n", encoding="utf-8")
    return bs.scan_bench(tmp, "pe.csl")


def _make_dispatcher_bench(tmp: Path) -> bs.BenchStructure:
    """Synthetic shell kernel with a high-density blas import."""
    (tmp / "src").mkdir()
    (tmp / "src" / "kernel.csl").write_text(textwrap.dedent("""
        const t = @import_module("<time>");
        const blas = @import_module("blas.csl");
        fn dispatch() void { blas.dot(1, x, y); }
        fn step() void { @fmacs(d, d, s, 1.0); }
    """), encoding="utf-8")
    (tmp / "src" / "blas.csl").write_text(textwrap.dedent("""
        fn reduce_dot(xval: f32, yval: f32, sum: *f32) f32 {
            return sum.* + xval * yval;
        }
        fn dot(n: i16, x: [*]f32, y: [*]f32) f32 {
            var sum: f32 = 0.0;
            @map(reduce_dot, mem_x_dsd, mem_y_dsd, &sum, &sum);
            return sum;
        }
    """), encoding="utf-8")
    return bs.scan_bench(tmp, "src/kernel.csl")


def _make_thin_dispatcher_with_hot_helper(tmp: Path) -> bs.BenchStructure:
    """Realistic immune-kernel shape: thin dispatcher (<5% density) +
    hot helper (>=7% density). Mirrors the BiCGSTAB/CG/PCG/Power_Method
    layout where kernel_*.csl orchestrates and blas.csl owns the
    arithmetic. Used by the auto-promote tests."""
    (tmp / "src").mkdir()
    # Thin dispatcher: lots of scaffolding (imports, state, comments)
    # with one @fmacs hidden inside. Density should land < 5%.
    scaffolding = "\n".join(
        f"const param_{i}: i16 = {i};" for i in range(60)
    )
    dispatcher_body = textwrap.dedent(f"""
        const t = @import_module("<time>");
        const blas = @import_module("blas.csl");
        {scaffolding}
        fn dispatch() void {{ blas.dot(1, x, y); }}
        fn step() void {{ @fmacs(d, d, s, 1.0); }}
    """).lstrip()
    (tmp / "src" / "kernel.csl").write_text(dispatcher_body, encoding="utf-8")
    # Hot helper: bulk arithmetic, multiple @fmacs / @fadds / @map.
    (tmp / "src" / "blas.csl").write_text(textwrap.dedent("""
        fn reduce_dot(xval: f32, yval: f32, sum: *f32) f32 {
            return sum.* + xval * yval;
        }
        fn dot(n: i16, x: [*]f32, y: [*]f32) f32 {
            var sum: f32 = 0.0;
            @map(reduce_dot, mem_x_dsd, mem_y_dsd, &sum, &sum);
            return sum;
        }
        fn axpy(n: i16, a: f32, x: [*]f32, y: [*]f32) void {
            @fmacs(mem_y_dsd, mem_y_dsd, mem_x_dsd, a);
        }
        fn add_to(n: i16, x: [*]f32, y: [*]f32) void {
            @fadds(mem_y_dsd, mem_y_dsd, mem_x_dsd);
        }
    """), encoding="utf-8")
    return bs.scan_bench(tmp, "src/kernel.csl")


# ---------------------------------------------------------------------------
# Trivial path
# ---------------------------------------------------------------------------

class TrivialPlanTests(unittest.TestCase):

    def setUp(self) -> None:
        self.tmp = Path(tempfile.mkdtemp(prefix="planner_trivial_"))

    def tearDown(self) -> None:
        shutil.rmtree(self.tmp, ignore_errors=True)

    def test_self_contained_kernel_skips_llm(self) -> None:
        struct = _make_self_contained_bench(self.tmp)
        calls = []
        def llm(p): calls.append(p); raise AssertionError("should not be called")
        plan = op.make_plan(
            kernel_id="K1", kernel_group="all", baseline_cycles=100,
            struct=struct, llm_call=llm,
        )
        self.assertEqual(plan.focus_files, ["pe.csl"])
        self.assertEqual(plan.expose_in_prompt, ["pe.csl"])
        self.assertEqual(plan.confidence, "high")
        self.assertEqual(calls, [])

    def test_trivial_plan_has_stable_fingerprint(self) -> None:
        struct = _make_self_contained_bench(self.tmp)
        plan1 = op.make_plan(
            kernel_id="K1", kernel_group="all", baseline_cycles=100,
            struct=struct, llm_call=lambda p: "should not run",
        )
        plan2 = op.make_plan(
            kernel_id="K1", kernel_group="all", baseline_cycles=100,
            struct=struct, llm_call=lambda p: "should not run",
        )
        self.assertEqual(plan1.fingerprint, plan2.fingerprint)


# ---------------------------------------------------------------------------
# LLM-driven path
# ---------------------------------------------------------------------------

class LLMPlanTests(unittest.TestCase):

    def setUp(self) -> None:
        self.tmp = Path(tempfile.mkdtemp(prefix="planner_llm_"))
        self.struct = _make_dispatcher_bench(self.tmp)

    def tearDown(self) -> None:
        shutil.rmtree(self.tmp, ignore_errors=True)

    def test_good_reply_parses(self) -> None:
        """A helper-only focus_files is now auto-promoted to include
        the dispatcher (see AutoPromoteThinDispatcherTests). This test
        used to assert focus_files == ['src/blas.csl']; after the
        piece-3d immune-kernels live runs surfaced that helper-only
        plans cannot be executed (the legacy single-file path edits
        target_relpath regardless of plan), the validator now adds the
        root so the multi-file path engages.
        """
        def llm(prompt):
            return textwrap.dedent("""
                Here's the plan.
                ```json
                {
                  "focus_files": ["src/blas.csl"],
                  "expose_in_prompt": ["src/kernel.csl", "src/blas.csl"],
                  "rationale": "Root is a thin dispatcher; the dot reduction lives in src/blas.csl.",
                  "suggested_first_angle": "fmac_bulk",
                  "confidence": "high"
                }
                ```
            """)
        plan = op.make_plan(
            kernel_id="K_disp", kernel_group="linalg",
            baseline_cycles=12345,
            struct=self.struct, llm_call=llm,
        )
        self.assertEqual(set(plan.focus_files),
                         {"src/kernel.csl", "src/blas.csl"})
        self.assertEqual(set(plan.expose_in_prompt),
                          {"src/kernel.csl", "src/blas.csl"})
        self.assertEqual(plan.suggested_first_angle, "fmac_bulk")
        self.assertEqual(plan.confidence, "high")
        self.assertIn("AUTO-PROMOTE", plan.rationale)

    def test_hallucinated_focus_files_filtered(self) -> None:
        # LLM names a file that doesn't exist in the bench. Validator
        # should drop it; if nothing valid remains, fall back.
        def llm(prompt):
            return '```json\n{"focus_files": ["nonexistent.csl"], "expose_in_prompt": [], "rationale": "x", "suggested_first_angle": "", "confidence": "low"}\n```'
        plan = op.make_plan(
            kernel_id="K_hallu", kernel_group="linalg",
            baseline_cycles=100,
            struct=self.struct, llm_call=llm,
        )
        # Fallback path → root-only.
        self.assertEqual(plan.focus_files, [self.struct.root_compute.relpath])
        self.assertEqual(plan.confidence, "low")
        self.assertIn("FALLBACK", plan.rationale)

    def test_expose_is_superset_of_focus(self) -> None:
        # LLM forgets to list focus file in expose_in_prompt; validator
        # auto-adds it.
        def llm(prompt):
            return '```json\n{"focus_files": ["src/blas.csl"], "expose_in_prompt": ["src/kernel.csl"], "rationale": "ok", "suggested_first_angle": "", "confidence": "medium"}\n```'
        plan = op.make_plan(
            kernel_id="K_supset", kernel_group="linalg",
            baseline_cycles=100,
            struct=self.struct, llm_call=llm,
        )
        self.assertIn("src/blas.csl", plan.expose_in_prompt)

    def test_bad_confidence_normalised(self) -> None:
        def llm(prompt):
            return '```json\n{"focus_files": ["src/blas.csl"], "expose_in_prompt": ["src/blas.csl"], "rationale": "ok", "suggested_first_angle": "", "confidence": "MAYBE"}\n```'
        plan = op.make_plan(
            kernel_id="K_conf", kernel_group="linalg",
            baseline_cycles=100,
            struct=self.struct, llm_call=llm,
        )
        self.assertEqual(plan.confidence, "medium")

    def test_unparseable_reply_falls_back(self) -> None:
        def llm(prompt):
            return "Sorry, I can't help with that."
        plan = op.make_plan(
            kernel_id="K_garbage", kernel_group="linalg",
            baseline_cycles=100,
            struct=self.struct, llm_call=llm,
        )
        self.assertEqual(plan.focus_files, [self.struct.root_compute.relpath])
        self.assertEqual(plan.confidence, "low")

    def test_llm_exception_falls_back(self) -> None:
        def llm(prompt):
            raise RuntimeError("503 service unavailable")
        plan = op.make_plan(
            kernel_id="K_err", kernel_group="linalg",
            baseline_cycles=100,
            struct=self.struct, llm_call=llm,
        )
        self.assertEqual(plan.focus_files, [self.struct.root_compute.relpath])
        self.assertEqual(plan.confidence, "low")


# ---------------------------------------------------------------------------
# Cache behaviour
# ---------------------------------------------------------------------------

class CacheTests(unittest.TestCase):

    def setUp(self) -> None:
        self.tmp = Path(tempfile.mkdtemp(prefix="planner_cache_"))
        self.explored = self.tmp / "explored"
        self.bench_dir = self.tmp / "bench"
        self.bench_dir.mkdir()
        self.struct = _make_dispatcher_bench(self.bench_dir)

    def tearDown(self) -> None:
        shutil.rmtree(self.tmp, ignore_errors=True)

    def _good_llm(self):
        def llm(prompt):
            return '```json\n{"focus_files": ["src/blas.csl"], "expose_in_prompt": ["src/kernel.csl", "src/blas.csl"], "rationale": "ok", "suggested_first_angle": "fmac_bulk", "confidence": "high"}\n```'
        return llm

    def test_get_or_make_caches(self) -> None:
        calls = []
        llm = self._good_llm()
        def counting_llm(p): calls.append(p); return llm(p)
        # First call: LLM hit.
        p1 = op.get_or_make_plan(
            kernel_id="K_cache", kernel_group="linalg",
            baseline_cycles=100, struct=self.struct,
            llm_call=counting_llm, explored_root=str(self.explored),
        )
        # Second call: cache hit, no LLM.
        p2 = op.get_or_make_plan(
            kernel_id="K_cache", kernel_group="linalg",
            baseline_cycles=100, struct=self.struct,
            llm_call=counting_llm, explored_root=str(self.explored),
        )
        self.assertEqual(len(calls), 1)
        self.assertEqual(p1.focus_files, p2.focus_files)
        self.assertEqual(p1.fingerprint, p2.fingerprint)

    def test_force_replan_skips_cache(self) -> None:
        calls = []
        llm = self._good_llm()
        def counting_llm(p): calls.append(p); return llm(p)
        op.get_or_make_plan(
            kernel_id="K_force", kernel_group="linalg",
            baseline_cycles=100, struct=self.struct,
            llm_call=counting_llm, explored_root=str(self.explored),
        )
        op.get_or_make_plan(
            kernel_id="K_force", kernel_group="linalg",
            baseline_cycles=100, struct=self.struct,
            llm_call=counting_llm, explored_root=str(self.explored),
            force_replan=True,
        )
        self.assertEqual(len(calls), 2)

    def test_fingerprint_change_invalidates_cache(self) -> None:
        calls = []
        llm = self._good_llm()
        def counting_llm(p): calls.append(p); return llm(p)
        op.get_or_make_plan(
            kernel_id="K_inv", kernel_group="linalg",
            baseline_cycles=100, struct=self.struct,
            llm_call=counting_llm, explored_root=str(self.explored),
        )
        # Mutate the bench: add @fmacs lines to blas.csl, which changes
        # compute_loc → fingerprint flips → cache miss.
        blas = self.bench_dir / "src" / "blas.csl"
        blas.write_text(blas.read_text(encoding="utf-8")
                        + "\nfn extra() void { @fmacs(d, d, s, 1.0); }\n",
                        encoding="utf-8")
        new_struct = bs.scan_bench(self.bench_dir, "src/kernel.csl")
        op.get_or_make_plan(
            kernel_id="K_inv", kernel_group="linalg",
            baseline_cycles=100, struct=new_struct,
            llm_call=counting_llm, explored_root=str(self.explored),
        )
        self.assertEqual(len(calls), 2)

    def test_cached_plan_round_trips(self) -> None:
        plan = op.make_plan(
            kernel_id="K_rt", kernel_group="linalg",
            baseline_cycles=100,
            struct=self.struct, llm_call=self._good_llm(),
        )
        op.save_plan(plan, explored_root=str(self.explored))
        loaded = op.load_cached_plan("K_rt", explored_root=str(self.explored))
        self.assertIsNotNone(loaded)
        self.assertEqual(loaded.focus_files, plan.focus_files)
        self.assertEqual(loaded.expose_in_prompt, plan.expose_in_prompt)
        self.assertEqual(loaded.fingerprint, plan.fingerprint)


# ---------------------------------------------------------------------------
# Live snapshot — pin behaviour on the real immune + winning kernels
# ---------------------------------------------------------------------------

REPO_ROOT = _HERE.parent
KERNELS = REPO_ROOT / "kernels"


@unittest.skipUnless(KERNELS.is_dir(), "kernels/ not present in this env")
class LiveSnapshotTests(unittest.TestCase):
    """Pin: BiCGSTAB / CG / PCG / Power Method must NOT take the trivial
    path (their structure has editable imports, so the planner SHOULD
    consult the LLM). Cholesky / Laplacian / GoL / GEMM-2D MUST take the
    trivial path (zero editable imports, deterministic plan)."""

    def _scan(self, name: str) -> bs.BenchStructure:
        from optimize_explore import _find_compute_file  # type: ignore
        bench = KERNELS / name / "CSL"
        relpath = _find_compute_file(bench)
        return bs.scan_bench(bench, relpath)

    def test_immune_kernels_need_llm(self) -> None:
        for name in ("BiCGSTAB", "Conjugate Gradient",
                     "Preconditioned CG", "Power Method"):
            with self.subTest(kernel=name):
                struct = self._scan(name)
                # If the trivial-path shortcut would fire, the planner
                # would be cheap but wrong (it'd never see the blas.csl).
                # Pin that the shortcut returns None for these kernels.
                fp = op._fingerprint(struct)
                trivial = op._trivial_plan_if_obvious(name, struct, fp)
                self.assertIsNone(
                    trivial,
                    f"{name}: trivial shortcut fired despite having "
                    f"{len(struct.editable_modules)} editable imports"
                )

    def test_self_contained_kernels_take_trivial_path(self) -> None:
        for name in ("Cholesky", "Laplacian2D-Halo", "Game of Life",
                     "GEMM Collectives 2D"):
            with self.subTest(kernel=name):
                struct = self._scan(name)
                fp = op._fingerprint(struct)
                trivial = op._trivial_plan_if_obvious(name, struct, fp)
                self.assertIsNotNone(
                    trivial,
                    f"{name}: trivial shortcut did not fire despite zero "
                    f"editable imports"
                )
                self.assertEqual(trivial.focus_files,
                                  [struct.root_compute.relpath])


class AutoPromoteThinDispatcherTests(unittest.TestCase):
    """The piece-3d live runs showed Opus reliably picks
    len(focus_files)==1 on thin-dispatcher+hot-helper kernels, defeating
    the multi-file path. The validator auto-promotes those cases so
    the optimizer always edits both files in coordination. These tests
    lock in that behaviour.
    """

    def setUp(self) -> None:
        self.tmp = Path(tempfile.mkdtemp(prefix="planner_promote_"))

    def tearDown(self) -> None:
        shutil.rmtree(self.tmp, ignore_errors=True)

    def _reply(self, focus, expose=None, rationale="rational") -> str:
        """Build a planner reply with the given focus_files."""
        expose = expose or list(focus)
        return (
            "```json\n"
            "{\n"
            f"  \"focus_files\": {json.dumps(focus)},\n"
            f"  \"expose_in_prompt\": {json.dumps(expose)},\n"
            f"  \"rationale\": \"{rationale}\",\n"
            "  \"suggested_first_angle\": \"fmac_bulk\",\n"
            "  \"confidence\": \"high\"\n"
            "}\n"
            "```"
        )

    def test_root_only_pick_gets_helper_added(self) -> None:
        """Case (1): planner picked just the dispatcher; validator
        appends the hot helper so the multi-file path fires."""
        struct = _make_thin_dispatcher_with_hot_helper(self.tmp)
        reply = self._reply(["src/kernel.csl"])
        plan = op.make_plan(
            kernel_id="ThinK", kernel_group="linalg",
            baseline_cycles=10000, struct=struct,
            llm_call=lambda _p: reply,
        )
        self.assertEqual(set(plan.focus_files),
                         {"src/kernel.csl", "src/blas.csl"})
        self.assertIn("src/blas.csl", plan.expose_in_prompt)
        self.assertIn("AUTO-PROMOTE", plan.rationale)

    def test_helper_only_pick_gets_root_added(self) -> None:
        """Case (2): planner picked just the helper; validator
        prepends the dispatcher so the multi-file path can execute
        (helper-alone plans can't run — the runner needs the root)."""
        struct = _make_thin_dispatcher_with_hot_helper(self.tmp)
        reply = self._reply(["src/blas.csl"])
        plan = op.make_plan(
            kernel_id="ThinK", kernel_group="linalg",
            baseline_cycles=10000, struct=struct,
            llm_call=lambda _p: reply,
        )
        self.assertEqual(set(plan.focus_files),
                         {"src/kernel.csl", "src/blas.csl"})
        self.assertIn("AUTO-PROMOTE", plan.rationale)
        self.assertIn("helper-only", plan.rationale)

    def test_already_multifile_pick_is_unchanged(self) -> None:
        """When the planner already returned both files, the validator
        does NOT add a promotion note (no-op)."""
        struct = _make_thin_dispatcher_with_hot_helper(self.tmp)
        reply = self._reply(["src/kernel.csl", "src/blas.csl"])
        plan = op.make_plan(
            kernel_id="ThinK", kernel_group="linalg",
            baseline_cycles=10000, struct=struct,
            llm_call=lambda _p: reply,
        )
        self.assertEqual(set(plan.focus_files),
                         {"src/kernel.csl", "src/blas.csl"})
        self.assertNotIn("AUTO-PROMOTE", plan.rationale)

    def test_dense_root_no_promotion(self) -> None:
        """The non-immune-kernel shape: a dense root with no need for
        helper coverage. Validator does NOT promote when root density
        is >= 5%."""
        # Build a bench with dense root + dense helper. Should NOT
        # promote because the root is over the 5% threshold.
        (self.tmp / "src").mkdir()
        (self.tmp / "src" / "kernel.csl").write_text(textwrap.dedent("""
            const t = @import_module("<time>");
            const blas = @import_module("blas.csl");
            fn step() void {
                @fmacs(d, d, s, 1.0);
                @fmacs(d, d, s, 1.0);
                @fmacs(d, d, s, 1.0);
                @fmacs(d, d, s, 1.0);
            }
        """), encoding="utf-8")
        (self.tmp / "src" / "blas.csl").write_text(textwrap.dedent("""
            fn dot(n: i16, x: [*]f32, y: [*]f32) f32 {
                @fmacs(d, d, s, 1.0);
                return 0.0;
            }
        """), encoding="utf-8")
        struct = bs.scan_bench(self.tmp, "src/kernel.csl")
        self.assertGreaterEqual(struct.root_compute.density, 0.05)
        reply = self._reply(["src/kernel.csl"])
        plan = op.make_plan(
            kernel_id="DenseK", kernel_group="linalg",
            baseline_cycles=10000, struct=struct,
            llm_call=lambda _p: reply,
        )
        self.assertEqual(plan.focus_files, ["src/kernel.csl"])
        self.assertNotIn("AUTO-PROMOTE", plan.rationale)


class PreflightAwarePlannerTests(unittest.TestCase):
    """Piece 3e: planner sees the pre-flight skip set and uses it to
    drop helpers whose only relevance is already-satisfied (e.g. drop
    blas.csl when fmac_bulk is skipped — Sonnet+Opus pre-flight already
    confirmed bulk-DSD).
    """

    def setUp(self) -> None:
        self.tmp = Path(tempfile.mkdtemp(prefix="planner_preflight_"))

    def tearDown(self) -> None:
        shutil.rmtree(self.tmp, ignore_errors=True)

    def _reply(self, focus, expose=None) -> str:
        expose = expose or list(focus)
        return (
            "```json\n"
            "{\n"
            f"  \"focus_files\": {json.dumps(focus)},\n"
            f"  \"expose_in_prompt\": {json.dumps(expose)},\n"
            "  \"rationale\": \"blas helper holds the bulk-DSD ops\",\n"
            "  \"suggested_first_angle\": \"fmac_bulk\",\n"
            "  \"confidence\": \"medium\"\n"
            "}\n"
            "```"
        )

    def test_blas_dropped_when_fmac_bulk_skipped(self) -> None:
        """The immune-kernels case: LLM picks [root, blas.csl] but
        pre-flight already skipped fmac_bulk → blas.csl becomes
        read-only context, focus_files shrinks to [root]."""
        struct = _make_thin_dispatcher_with_hot_helper(self.tmp)
        reply = self._reply(["src/kernel.csl", "src/blas.csl"])
        plan = op.make_plan(
            kernel_id="BlasK", kernel_group="linalg",
            baseline_cycles=10000, struct=struct,
            llm_call=lambda _p: reply,
            preflight_skipped_angles=["fmac_bulk"],
        )
        self.assertEqual(plan.focus_files, ["src/kernel.csl"])
        self.assertIn("src/blas.csl", plan.expose_in_prompt)
        self.assertIn("DROP-HELPER", plan.rationale)
        self.assertIn("fmac_bulk", plan.rationale)

    def test_blas_kept_when_fmac_bulk_active(self) -> None:
        """When pre-flight does NOT skip fmac_bulk, the demotion
        guard stays silent and blas.csl remains in focus."""
        struct = _make_thin_dispatcher_with_hot_helper(self.tmp)
        reply = self._reply(["src/kernel.csl", "src/blas.csl"])
        plan = op.make_plan(
            kernel_id="BlasK", kernel_group="linalg",
            baseline_cycles=10000, struct=struct,
            llm_call=lambda _p: reply,
            preflight_skipped_angles=["comptime_hoist"],  # something else
        )
        self.assertEqual(set(plan.focus_files),
                         {"src/kernel.csl", "src/blas.csl"})
        self.assertNotIn("DROP-HELPER", plan.rationale)

    def test_other_helper_not_demoted(self) -> None:
        """The demotion is BLAS-specific (relpath basename == blas.csl).
        A helper called something else (e.g. 'reductions.csl') is NOT
        demoted even when fmac_bulk is skipped — it might admit other
        angles the catalog can target."""
        (self.tmp / "src").mkdir()
        (self.tmp / "src" / "kernel.csl").write_text(
            "const r = @import_module(\"reductions.csl\");\n"
            + "\n".join(f"const p_{i}: i16 = {i};" for i in range(60))
            + "\nfn dispatch() void { r.reduce(); }\n"
            + "fn step() void { @fmacs(d, d, s, 1.0); }\n",
            encoding="utf-8",
        )
        (self.tmp / "src" / "reductions.csl").write_text(
            "fn reduce_one(a: f32, b: f32, s: *f32) f32 {\n"
            "    return s.* + a + b;\n}\n"
            "fn reduce() void {\n"
            "    @map(reduce_one, mem_x_dsd, mem_y_dsd, &sum, &sum);\n"
            "    @fadds(mem_y_dsd, mem_y_dsd, mem_x_dsd);\n"
            "}\n",
            encoding="utf-8",
        )
        struct = bs.scan_bench(self.tmp, "src/kernel.csl")
        reply = self._reply(["src/kernel.csl", "src/reductions.csl"])
        plan = op.make_plan(
            kernel_id="ReduceK", kernel_group="linalg",
            baseline_cycles=10000, struct=struct,
            llm_call=lambda _p: reply,
            preflight_skipped_angles=["fmac_bulk"],
        )
        # Both files stay in focus because reductions.csl is not "blas.csl".
        self.assertEqual(set(plan.focus_files),
                         {"src/kernel.csl", "src/reductions.csl"})
        self.assertNotIn("DROP-HELPER", plan.rationale)

    def test_fingerprint_changes_with_skip_set(self) -> None:
        """Cache invalidation: same bench, different skip set ->
        different fingerprint -> plan regenerates."""
        struct = _make_thin_dispatcher_with_hot_helper(self.tmp)
        fp_a = op._fingerprint(struct, ["fmac_bulk"])
        fp_b = op._fingerprint(struct, ["fmac_bulk", "comptime_hoist"])
        fp_none = op._fingerprint(struct, None)
        self.assertNotEqual(fp_a, fp_b)
        self.assertNotEqual(fp_a, fp_none)
        # Same skip set (different order) -> same fingerprint.
        fp_b_reordered = op._fingerprint(struct,
                                          ["comptime_hoist", "fmac_bulk"])
        self.assertEqual(fp_b, fp_b_reordered)

    def test_planner_prompt_includes_skip_block(self) -> None:
        """The skip set is rendered into the planner prompt under the
        'Pre-flight: already-satisfied angles' section so the LLM has
        the same information as the deterministic guard."""
        struct = _make_thin_dispatcher_with_hot_helper(self.tmp)
        prompt = op._build_prompt(
            kernel_id="BlasK", kernel_group="linalg",
            baseline_cycles=10000, struct=struct,
            preflight_skipped_angles=["fmac_bulk", "comptime_hoist"],
        )
        self.assertIn("already-satisfied angles", prompt.lower())
        self.assertIn("fmac_bulk", prompt)
        self.assertIn("comptime_hoist", prompt)
        # When no skipped set is given, the block clearly says so.
        prompt2 = op._build_prompt(
            kernel_id="BlasK", kernel_group="linalg",
            baseline_cycles=10000, struct=struct,
        )
        self.assertIn("full catalog applies", prompt2)


if __name__ == "__main__":
    unittest.main(verbosity=2)
