"""Smoke tests for the explore_csl workflow.

Covers (no LLM calls, no cslc):
  * numeric_check: missing assert_allclose, self-compare, valid call
  * tutorial_leak_check: clean tutorial passes, leaky tutorial fails
  * knowledge_persistence: round-trip record_success + record_failure
  * idea_sampler: gap-weighted draw + infeasible-hash hard-skip
  * provider_resolver: env-driven fallback walk
  * explore_csl CLI: --dry-run end-to-end produces a recorded success

Run with:  python /home/USER/xkernel/code_translation/test_explore_csl.py
Exits 0 on success, non-zero on failure. No pytest dependency.
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
from unittest.mock import patch

_HERE = Path(__file__).resolve().parent
if str(_HERE) not in sys.path:
    sys.path.insert(0, str(_HERE))


# =============================================================================
# numeric_check
# =============================================================================

import numeric_check  # noqa: E402


class NumericCheckTests(unittest.TestCase):
    def test_missing_assert_allclose_fails(self) -> None:
        src = "import numpy as np\nx = np.zeros(1)\n"
        self.assertIsNotNone(numeric_check.validate_run_py(src))

    def test_missing_numpy_import_fails(self) -> None:
        src = "x = 1\nassert_allclose(x, x)\n"
        self.assertIsNotNone(numeric_check.validate_run_py(src))

    def test_self_compare_fails(self) -> None:
        src = ("import numpy as np\n"
               "out = np.zeros(1)\n"
               "np.testing.assert_allclose(out, out)\n")
        msg = numeric_check.validate_run_py(src)
        self.assertIsNotNone(msg)
        self.assertIn("self", msg.lower())

    def test_valid_call_passes(self) -> None:
        src = ("import numpy as np\n"
               "expected = np.array([1.0])\n"
               "device = np.array([1.0])\n"
               "np.testing.assert_allclose(device, expected, rtol=1e-5)\n")
        self.assertIsNone(numeric_check.validate_run_py(src))

    def test_comment_does_not_count(self) -> None:
        src = ("import numpy as np\n"
               "# np.testing.assert_allclose(out, out)\n")
        self.assertIsNotNone(numeric_check.validate_run_py(src))


# =============================================================================
# tutorial_leak_check
# =============================================================================

from knowledge_persistence import bundle_identifier_set, tutorial_leak_check  # noqa: E402


class TutorialLeakCheckTests(unittest.TestCase):
    def test_clean_tutorial_passes(self) -> None:
        bundle = textwrap.dedent("""
            param BLOCK_SIZE: u16;
            const fabric_color_zone7: color = @get_color(7);
            fn compute_special_softmax_inner() void { ... }
        """)
        tutorial = textwrap.dedent("""
            # Row-softmax on a single PE
            The idiom uses an online single-pass reduction that maintains a
            running max and denominator. Keep the inner loop free of DSD
            rebuilds.
        """)
        self.assertIsNone(tutorial_leak_check(tutorial, bundle, threshold=3))

    def test_leaky_tutorial_fails(self) -> None:
        bundle = textwrap.dedent("""
            param BLOCK_SIZE: u16;
            const fabric_color_zone7: color = @get_color(7);
            fn compute_special_softmax_inner() void { ... }
            const HIDDEN_TOLERANCE = 12345;
            const HIDDEN_DENOM = 67890;
        """)
        tutorial = textwrap.dedent("""
            Use BLOCK_SIZE and fabric_color_zone7 and compute_special_softmax_inner
            and 12345 with 67890 to reproduce the exact bundle.
        """)
        msg = tutorial_leak_check(tutorial, bundle, threshold=3)
        self.assertIsNotNone(msg)
        self.assertIn("bundle-specific", msg)

    def test_identifier_set_excludes_common(self) -> None:
        bundle = "import numpy as np\nfrom cerebras.sdk import SdkRuntime\n"
        s = bundle_identifier_set(bundle)
        # numpy and SdkRuntime are in the common-set, so should be filtered out.
        self.assertNotIn("numpy", s)
        self.assertNotIn("SdkRuntime", s)


# =============================================================================
# knowledge_persistence round-trip
# =============================================================================

from knowledge_persistence import (  # noqa: E402
    CandidateArtifacts,
    ExplorationStore,
)


class PersistenceTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.mkdtemp(prefix="explore_test_")
        self.store = ExplorationStore(root=self.tmp)

    def tearDown(self) -> None:
        shutil.rmtree(self.tmp, ignore_errors=True)

    def test_record_success_writes_bundle_and_jsonl(self) -> None:
        art = CandidateArtifacts(
            pe_csl="// pe placeholder",
            layout_csl="// layout placeholder",
            run_py=("import numpy as np\n"
                    "np.testing.assert_allclose([1], [1])\n"),
            design_md="# DESIGN",
        )
        rec = self.store.record_success(
            mode="idea",
            idea="row_softmax: row-wise softmax",
            kernel_id="row_softmax",
            artifacts=art,
            benchmark_result={"status": "pass", "cycles_send": 1234,
                              "compile_time_ms": 50, "run_time_ms": 20},
            baseline_ref=None,
            baseline_cycles=None,
            lessons=["online softmax avoids 2-pass reduction"],
        )
        self.assertEqual(rec.outcome, "success")
        # Bundle dir exists
        bundle_dir = Path(self.tmp) / rec.artifacts_dir
        self.assertTrue(bundle_dir.is_dir())
        self.assertTrue((bundle_dir / "pe.csl").is_file())
        self.assertTrue((bundle_dir / "metrics.json").is_file())
        # JSONL contains row
        rows = self.store.list_records()
        self.assertEqual(len(rows), 1)
        self.assertEqual(rows[0]["kernel_id"], "row_softmax")
        # Index.md got a row
        idx = (Path(self.tmp) / "index.md").read_text(encoding="utf-8")
        self.assertIn("row_softmax", idx)
        # Ingest JSONL got a chunk
        chunks = (Path(self.tmp) / "ingest" / "explored_experiences.jsonl"
                  ).read_text(encoding="utf-8")
        self.assertIn("row_softmax", chunks)

    def test_record_failure_writes_diagnosis(self) -> None:
        rec = self.store.record_failure(
            mode="cuda-nl",
            idea="spmm_csr_dense: SpMM",
            kernel_id="spmm_csr_dense",
            last_pe_csl="// failed pe",
            failure_reason="command_failed",
            stderr_tail="error: undeclared identifier 'foo'",
            diagnosis="probably missing import",
            lessons=["always import the helper before using its types"],
        )
        self.assertEqual(rec.outcome, "failure")
        bundle_dir = Path(self.tmp) / rec.artifacts_dir
        self.assertTrue((bundle_dir / "error_log.txt").is_file())
        self.assertTrue((bundle_dir / "diagnosis.md").is_file())
        self.assertEqual(len(self.store.list_records()), 1)

    def test_dedup_helpers(self) -> None:
        self.store.record_failure(
            mode="idea", idea="x", kernel_id="x",
            last_pe_csl="", failure_reason="r", stderr_tail="",
        )
        self.store.mark_infeasible("x", "idea", "too big for fabric")
        seen = self.store.seen_idea_hashes()
        self.assertGreaterEqual(len(seen), 1)
        infeasible = self.store.infeasible_idea_hashes()
        self.assertEqual(len(infeasible), 1)


# =============================================================================
# idea_sampler
# =============================================================================

from explore_modes.idea_sampler import (  # noqa: E402
    IdeaSampler,
    IdeaSeed,
)


class IdeaSamplerTests(unittest.TestCase):
    def _seeds(self) -> list:
        return [
            IdeaSeed(id="a", title="A", summary="", acceptance_numerics="",
                     suggested_mesh="single_pe",
                     features=["very_rare_feature_xyz1"],
                     difficulty="easy"),
            IdeaSeed(id="b", title="B", summary="", acceptance_numerics="",
                     suggested_mesh="single_pe",
                     features=["another_rare_feature_xyz2"],
                     difficulty="medium"),
            IdeaSeed(id="c", title="C", summary="", acceptance_numerics="",
                     suggested_mesh="single_pe",
                     features=["fmacs"],   # this IS in the covered set
                     difficulty="hard"),
        ]

    def test_infeasible_hard_skips(self) -> None:
        seeds = self._seeds()
        sampler = IdeaSampler(seeds=seeds, kernels_root="/nonexistent",
                              infeasible_hashes={seeds[0].hash})
        picks = sampler.sample(3)
        self.assertNotIn("a", [p.id for p in picks])

    def test_gap_scoring_prefers_uncovered(self) -> None:
        seeds = self._seeds()
        sampler = IdeaSampler(seeds=seeds, kernels_root="/nonexistent",
                              rng_seed=42)
        # Manually inject covered set as if fmacs were covered.
        sampler.covered = {"fmacs"}
        # Score: a and b each get +1.2 for one uncovered feature; c gets 0.
        self.assertGreater(sampler.weight(seeds[0]), sampler.weight(seeds[2]))
        self.assertGreater(sampler.weight(seeds[1]), sampler.weight(seeds[2]))

    def test_sample_returns_distinct(self) -> None:
        sampler = IdeaSampler(seeds=self._seeds(), kernels_root="/nonexistent",
                              rng_seed=7)
        picks = sampler.sample(2)
        self.assertEqual(len(picks), 2)
        self.assertEqual(len({p.id for p in picks}), 2)


# =============================================================================
# provider resolver
# =============================================================================

import workflow_common  # noqa: E402
import mesh_gate  # noqa: E402


class ProviderResolverTests(unittest.TestCase):
    def test_auto_falls_through_to_openai(self) -> None:
        # Force every higher rung to fail.
        with patch.object(workflow_common, "_try_argo",
                          side_effect=RuntimeError("no settings")), \
             patch.object(workflow_common, "_try_alcf",
                          side_effect=RuntimeError("no globus")), \
             patch.object(workflow_common, "_try_openai",
                          return_value=workflow_common.ProviderHandle(
                              kind="openai", client=object(), model="gpt-4.1"
                          )):
            h = workflow_common.resolve_provider(provider="auto")
            self.assertEqual(h.kind, "openai")
            # Notes include both failures plus the final success.
            self.assertTrue(any("argo" in n for n in h.notes))
            self.assertTrue(any("alcf" in n for n in h.notes))

    def test_auto_prefers_argo_first(self) -> None:
        # When argo is available it MUST be chosen even though alcf/openai
        # would also succeed. Codifies the 2026-06-03 default ordering.
        with patch.object(workflow_common, "_try_argo",
                          return_value=workflow_common.ProviderHandle(
                              kind="argo", client=object(),
                              model="claude-opus-4-7"
                          )), \
             patch.object(workflow_common, "_try_alcf",
                          return_value=workflow_common.ProviderHandle(
                              kind="alcf", client=object(),
                              model="gpt-oss-120b"
                          )), \
             patch.object(workflow_common, "_try_openai",
                          return_value=workflow_common.ProviderHandle(
                              kind="openai", client=object(), model="gpt-4.1"
                          )):
            h = workflow_common.resolve_provider(provider="auto")
            self.assertEqual(h.kind, "argo")
            self.assertEqual(h.model, "claude-opus-4-7")

    def test_require_provider_no_fallback(self) -> None:
        with patch.object(workflow_common, "_try_argo",
                          side_effect=RuntimeError("no settings")):
            with self.assertRaises(RuntimeError):
                workflow_common.resolve_provider(
                    provider="argo", require=True)


# =============================================================================
# explore_csl CLI --dry-run end-to-end
# =============================================================================

import explore_csl  # noqa: E402


class ExploreCLIDryRunTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.mkdtemp(prefix="explore_cli_test_")

    def tearDown(self) -> None:
        shutil.rmtree(self.tmp, ignore_errors=True)

    def test_dry_run_idea_mode(self) -> None:
        argv = [
            "explore_csl",
            "--mode", "idea",
            "--candidates-per-round", "2",
            "--n-rounds", "1",
            "--export-dir", self.tmp,
            "--work-root", os.path.join(self.tmp, "work"),
            "--dry-run",
        ]
        with patch.object(sys, "argv", argv), \
             patch.object(workflow_common, "_try_argo",
                          side_effect=RuntimeError("ci: no provider")), \
             patch.object(workflow_common, "_try_alcf",
                          side_effect=RuntimeError("ci: no provider")), \
             patch.object(workflow_common, "_try_openai",
                          side_effect=RuntimeError("ci: no provider")):
            rc = explore_csl.main()
        self.assertEqual(rc, 0)
        # We should have at least one success row.
        store = explore_csl.ExplorationStore(self.tmp)
        rows = store.list_records()
        self.assertGreaterEqual(len(rows), 1)
        self.assertEqual(rows[0]["outcome"], "success")


# =============================================================================
# mesh_gate
# =============================================================================

class MeshGateTests(unittest.TestCase):

    def test_parse_literal_dims(self) -> None:
        layout = "layout { @set_rectangle(4, 6); }"
        m = mesh_gate.parse_set_rectangle(layout)
        self.assertEqual(m.width, 4)
        self.assertEqual(m.height, 6)
        self.assertEqual(m.confidence, "exact")
        self.assertEqual(m.pe_count, 24)

    def test_parse_const_dims(self) -> None:
        layout = textwrap.dedent("""
            const Pw: i16 = 8;
            const Ph: i16 = 3;
            layout { @set_rectangle(Pw, Ph); }
        """)
        m = mesh_gate.parse_set_rectangle(layout)
        self.assertEqual(m.pe_count, 24)
        self.assertEqual(m.confidence, "exact")

    def test_parse_params_resolved_via_commands(self) -> None:
        layout = "param P: u16;\nlayout { @set_rectangle(P, P); }"
        commands = ("cslc --arch=wse3 ./layout.csl --fabric-dims=11,11 "
                    "--params=P:5,Mt:14 --memcpy --channels=1 -o out\n")
        m = mesh_gate.parse_set_rectangle(layout, commands)
        self.assertEqual(m.pe_count, 25)
        self.assertEqual(m.confidence, "params-resolved")

    def test_parse_unresolvable_returns_unknown(self) -> None:
        layout = ("param P: u16;\n"
                  "layout { @set_rectangle(P * complex_expr() + 1, P); }")
        m = mesh_gate.parse_set_rectangle(layout, "")
        self.assertEqual(m.confidence, "unknown")
        self.assertIsNone(m.pe_count)

    def test_gate_passes_single_pe_when_floor_is_one(self) -> None:
        layout = "layout { @set_rectangle(1, 1); }"
        g = mesh_gate.check_mesh_gate(layout, "", min_pe_count=1)
        self.assertTrue(g.passed)

    def test_gate_rejects_collapse_below_floor(self) -> None:
        layout = "layout { @set_rectangle(1, 1); }"
        g = mesh_gate.check_mesh_gate(layout, "", min_pe_count=4)
        self.assertFalse(g.passed)
        self.assertIn("mesh_too_small", g.reason)

    def test_gate_accepts_meeting_floor(self) -> None:
        layout = "layout { @set_rectangle(4, 4); }"
        g = mesh_gate.check_mesh_gate(layout, "", min_pe_count=4)
        self.assertTrue(g.passed)
        self.assertEqual(g.mesh.pe_count, 16)

    def test_gate_unknown_fail_open_by_default(self) -> None:
        layout = "layout { @set_rectangle(P * f(), P); }"
        g = mesh_gate.check_mesh_gate(layout, "", min_pe_count=4)
        self.assertTrue(g.passed)  # fail-open

    def test_gate_unknown_fail_closed_when_required(self) -> None:
        layout = "layout { @set_rectangle(P * f(), P); }"
        g = mesh_gate.check_mesh_gate(layout, "", min_pe_count=4,
                                       fail_on_unknown=True)
        self.assertFalse(g.passed)


# =============================================================================
# IdeaSeed tier + filter
# =============================================================================

from explore_modes.idea_sampler import load_seeds  # noqa: E402


class TwoAxisDifficultyTests(unittest.TestCase):

    def test_seed_tier_derives_from_max_axis(self) -> None:
        from explore_modes.idea_sampler import IdeaSeed
        s_easy = IdeaSeed(id="x", title="x", summary="", acceptance_numerics="",
                          suggested_mesh="single_pe",
                          layout_complexity=1, compute_complexity=1)
        s_med = IdeaSeed(id="y", title="y", summary="", acceptance_numerics="",
                         suggested_mesh="1d_row",
                         layout_complexity=2, compute_complexity=1)
        s_hard = IdeaSeed(id="z", title="z", summary="", acceptance_numerics="",
                          suggested_mesh="single_pe",
                          layout_complexity=1, compute_complexity=3)
        self.assertEqual(s_easy.tier, "easy")
        self.assertEqual(s_med.tier, "medium")
        self.assertEqual(s_hard.tier, "hard")

    def test_min_pe_count_default_from_layout(self) -> None:
        from explore_modes.idea_sampler import IdeaSeed
        s1 = IdeaSeed(id="a", title="a", summary="", acceptance_numerics="",
                      suggested_mesh="single_pe", layout_complexity=1,
                      compute_complexity=1)
        s2 = IdeaSeed(id="b", title="b", summary="", acceptance_numerics="",
                      suggested_mesh="2d_block", layout_complexity=3,
                      compute_complexity=3)
        self.assertEqual(s1.min_pe_count, 1)
        self.assertEqual(s2.min_pe_count, 4)

    def test_explicit_min_pe_overrides_default(self) -> None:
        from explore_modes.idea_sampler import IdeaSeed
        s = IdeaSeed(id="c", title="c", summary="", acceptance_numerics="",
                     suggested_mesh="2d_block", layout_complexity=3,
                     compute_complexity=3, min_pe_count=16)
        self.assertEqual(s.min_pe_count, 16)

    def test_sampler_difficulty_filter(self) -> None:
        seeds = load_seeds()
        if not seeds:
            self.skipTest("YAML seeds not available in this env")
        from explore_modes.idea_sampler import IdeaSampler
        hard_only = IdeaSampler(seeds=seeds, kernels_root="/nonexistent",
                                difficulty_filter="hard", rng_seed=1)
        for s in hard_only.seeds:
            self.assertEqual(s.tier, "hard")
        easy_only = IdeaSampler(seeds=seeds, kernels_root="/nonexistent",
                                difficulty_filter="easy", rng_seed=1)
        for s in easy_only.seeds:
            self.assertEqual(s.tier, "easy")
        # Each tier should produce some seeds with the new YAML.
        self.assertGreater(len(hard_only.seeds), 0)
        self.assertGreater(len(easy_only.seeds), 0)

    def test_sampler_axis_filter(self) -> None:
        seeds = load_seeds()
        if not seeds:
            self.skipTest("YAML seeds not available in this env")
        from explore_modes.idea_sampler import IdeaSampler
        layout3 = IdeaSampler(seeds=seeds, kernels_root="/nonexistent",
                              layout_complexity_filter=3, rng_seed=1)
        for s in layout3.seeds:
            self.assertEqual(s.layout_complexity, 3)


# =============================================================================
# optimize_explore: profiler + persistence round-trip
# =============================================================================

import optimize_explore  # noqa: E402


class OptimizeBottleneckProfileTests(unittest.TestCase):

    def test_scalar_loop_detected(self) -> None:
        # A scalar for-loop that writes per element AND has no bulk @fmacs.
        src = textwrap.dedent("""
            fn step() void {
                for (@range(i16, 16)) |i| {
                    y[i] = y[i] + a;
                }
            }
        """)
        sig = optimize_explore.profile_bottlenecks(src)
        self.assertIn("scalar_loops_over_arrays", sig)

    def test_dsd_rebuild_in_loop_detected(self) -> None:
        src = textwrap.dedent("""
            fn step() void {
                for (@range(i16, 16)) |i| {
                    const tmp = @get_dsd(mem1d_dsd, .{ .tensor_access = |j|{N} -> A[j] });
                    @fmacs(out, out, tmp, x[i]);
                }
            }
        """)
        sig = optimize_explore.profile_bottlenecks(src)
        self.assertIn("dsd_rebuild_in_loop", sig)

    def test_no_bottlenecks_returns_empty(self) -> None:
        # Trivial elementwise via @fmacs — none of the bottleneck patterns
        # should fire.
        src = ("const dsd = @get_dsd(mem1d_dsd, .{ .tensor_access = |i|{16} -> y[i] });\n"
               "fn step() void { @fmovs(dsd, 0.0); }\n")
        sig = optimize_explore.profile_bottlenecks(src)
        # We're not insisting on exactly empty (other heuristics might match
        # incidentally); just ensure scalar_loops_over_arrays is NOT here.
        self.assertNotIn("scalar_loops_over_arrays", sig)


class OptimizeStoreRoundTripTests(unittest.TestCase):

    def setUp(self) -> None:
        self.tmp = tempfile.mkdtemp(prefix="opt_store_test_")
        from knowledge_persistence import ExplorationStore
        self.store = ExplorationStore(root=self.tmp)

    def tearDown(self) -> None:
        shutil.rmtree(self.tmp, ignore_errors=True)

    def _accept(self, kernel, group, angle, base, cand) -> None:
        self.store.record_optimization(
            kernel=kernel, kernel_group=group, angle=angle,
            baseline_cycles=base, candidate_cycles=cand,
            accepted=True, reject_reason=None,
            optimized_pe_csl="// dummy\nfn step() void {}",
            diff_summary=f"used {angle} to reduce loop overhead",
            benchmark_result={
                "status": "pass", "compile_time_ms": 100,
                "run_time_ms": 50, "cycles_send": cand,
            },
            bottlenecks=["scalar_loops_over_arrays"],
        )

    def _reject(self, kernel, group, angle, base, cand, why) -> None:
        self.store.record_optimization(
            kernel=kernel, kernel_group=group, angle=angle,
            baseline_cycles=base, candidate_cycles=cand,
            accepted=False, reject_reason=why,
            optimized_pe_csl="",
            diff_summary=None,
            benchmark_result={"status": "rejected"},
            bottlenecks=[],
        )

    def test_accept_writes_bundle_and_jsonl(self) -> None:
        self._accept("GEMV", "gemv", "fmac_bulk", 1000, 700)
        rows = self.store.load_optimization_records()
        self.assertEqual(len(rows), 1)
        r = rows[0]
        self.assertTrue(r["accepted"])
        self.assertAlmostEqual(r["speedup"], 1000 / 700, places=4)
        # Bundle dir written with pe.csl + diff + metrics.
        bundle_dir = Path(self.tmp) / r["artifacts_dir"]
        self.assertTrue((bundle_dir / "pe.csl").is_file())
        self.assertTrue((bundle_dir / "diff_summary.md").is_file())
        self.assertTrue((bundle_dir / "metrics.json").is_file())
        # KB-ready chunk emitted.
        chunks = (Path(self.tmp) / "optimization" / "ingest"
                  / "optimization_experiences.jsonl"
                  ).read_text(encoding="utf-8")
        self.assertIn("fmac_bulk", chunks)
        self.assertIn("gemv", chunks)

    def test_reject_writes_jsonl_only(self) -> None:
        self._reject("GEMV", "gemv", "comptime_hoist", 1000, 1100,
                     "no-improvement")
        rows = self.store.load_optimization_records()
        self.assertEqual(len(rows), 1)
        self.assertFalse(rows[0]["accepted"])
        # No accepted bundle dir.
        bundles = list((Path(self.tmp) / "optimization" / "accepted").glob("*"))
        self.assertEqual(len(bundles), 0)

    def test_aggregate_angle_rewards(self) -> None:
        # Build a deterministic dataset.
        self._accept("GEMV", "gemv", "fmac_bulk", 1000, 700)
        self._accept("GEMV2", "gemv", "fmac_bulk", 800, 600)
        self._reject("GEMV3", "gemv", "fmac_bulk", 500, 500, "no-improvement")
        self._reject("STEN", "stencil", "fmac_bulk", 2000, 2000, "no-improvement")
        agg = self.store.aggregate_angle_rewards()
        gemv_fmac = agg["gemv::fmac_bulk"]
        self.assertEqual(gemv_fmac["attempts"], 3)
        self.assertEqual(gemv_fmac["accepts"], 2)
        self.assertAlmostEqual(gemv_fmac["accept_rate"], 2 / 3, places=4)
        # mean speedup over the two accepted only
        self.assertAlmostEqual(gemv_fmac["mean_speedup"],
                                (1000/700 + 800/600) / 2, places=4)
        self.assertAlmostEqual(gemv_fmac["best_speedup"],
                                max(1000/700, 800/600), places=4)
        stencil_fmac = agg["stencil::fmac_bulk"]
        self.assertEqual(stencil_fmac["attempts"], 1)
        self.assertEqual(stencil_fmac["accepts"], 0)
        self.assertEqual(stencil_fmac["accept_rate"], 0.0)
        self.assertIsNone(stencil_fmac["mean_speedup"])


class OptimizeKnowledgeBaseSurfacingTests(unittest.TestCase):

    def test_for_optimizer_explored_empty_when_no_data(self) -> None:
        # Point the optimization-records path at a nonexistent file.
        from unittest.mock import patch
        with patch("csl_knowledge_base._OPTIMIZATION_RECORDS_PATH",
                    Path("/nonexistent/opt.jsonl")), \
             patch("csl_knowledge_base._OPTIMIZATION_KB_PATH",
                    Path("/nonexistent/chunks.jsonl")):
            import csl_knowledge_base
            self.assertEqual(csl_knowledge_base.for_optimizer_explored(""),
                              "")

    def test_for_optimization_includes_explored_when_present(self) -> None:
        # Write a small optimization-records file in a tmpdir, point the KB
        # accessor at it, confirm for_optimization() ingests the table.
        from unittest.mock import patch
        tmp = tempfile.mkdtemp(prefix="opt_kb_test_")
        try:
            opt_jsonl = Path(tmp) / "opt.jsonl"
            opt_jsonl.write_text(
                json.dumps({
                    "ts": "20260605T000000Z",
                    "kernel": "GEMV", "kernel_group": "gemv",
                    "angle": "fmac_bulk", "baseline_cycles": 1000,
                    "candidate_cycles": 700, "speedup": 1000/700,
                    "accepted": True, "reject_reason": None,
                    "diff_summary": "loop -> @fmacs",
                }) + "\n",
                encoding="utf-8",
            )
            with patch("csl_knowledge_base._OPTIMIZATION_RECORDS_PATH",
                        opt_jsonl), \
                 patch("csl_knowledge_base._OPTIMIZATION_KB_PATH",
                        Path("/nonexistent/chunks.jsonl")):
                import csl_knowledge_base
                ctx = csl_knowledge_base.for_optimization(
                    "gemv test", kernel_group="gemv",
                )
                self.assertIn("Prior optimization experience", ctx)
                self.assertIn("fmac_bulk", ctx)
                self.assertIn("1.43x", ctx)  # 1000/700 rounded
        finally:
            shutil.rmtree(tmp, ignore_errors=True)


# =============================================================================
# optimize_explore: repair classifier + failure persistence
# =============================================================================


class OptimizeResolveTargetTests(unittest.TestCase):
    """Pin the compute-file resolution behaviour that the 7-Point Stencil
    failure (src/kernel.csl) exposed. Future changes to resolve_target
    must keep all six representative layouts working."""

    def setUp(self) -> None:
        self.tmp = Path(tempfile.mkdtemp(prefix="opt_resolve_test_"))
        # Three layouts side-by-side: pe.csl / src/kernel.csl / *.csl
        # at root.
        for d in ("GEMV-like", "Stencil-like", "Residual-like"):
            (self.tmp / d / "CSL").mkdir(parents=True)
        (self.tmp / "GEMV-like" / "CSL" / "pe.csl").write_text("// pe", "utf-8")
        (self.tmp / "GEMV-like" / "CSL" / "layout.csl").write_text("// l", "utf-8")
        (self.tmp / "GEMV-like" / "CSL" / "commands_wse3.sh").write_text(
            "#!/bin/bash\necho ok\n", "utf-8")
        (self.tmp / "Stencil-like" / "CSL" / "src").mkdir()
        (self.tmp / "Stencil-like" / "CSL" / "src" / "kernel.csl").write_text(
            "// k", "utf-8")
        (self.tmp / "Stencil-like" / "CSL" / "layout.csl").write_text("// l", "utf-8")
        # Stencil-like ships only commands_wse2.sh — exercises the fallback.
        (self.tmp / "Stencil-like" / "CSL" / "commands_wse2.sh").write_text(
            "#!/bin/bash\necho ok\n", "utf-8")
        (self.tmp / "Residual-like" / "CSL" / "residual.csl").write_text(
            "// r", "utf-8")
        (self.tmp / "Residual-like" / "CSL" / "layout.csl").write_text("// l", "utf-8")
        (self.tmp / "Residual-like" / "CSL" / "commands_wse3.sh").write_text(
            "#!/bin/bash\necho ok\n", "utf-8")

    def tearDown(self) -> None:
        shutil.rmtree(self.tmp, ignore_errors=True)

    def test_pe_csl_at_root(self) -> None:
        from optimize_explore import resolve_target
        t = resolve_target(str(self.tmp / "GEMV-like"))
        self.assertEqual(t.target_relpath, "pe.csl")

    def test_src_kernel_csl(self) -> None:
        from optimize_explore import resolve_target
        t = resolve_target(str(self.tmp / "Stencil-like"))
        self.assertEqual(t.target_relpath, "src/kernel.csl")

    def test_other_csl_at_root(self) -> None:
        from optimize_explore import resolve_target
        t = resolve_target(str(self.tmp / "Residual-like"))
        self.assertEqual(t.target_relpath, "residual.csl")

    def test_target_relpath_override(self) -> None:
        # Even when pe.csl exists, the override wins.
        from optimize_explore import resolve_target
        (self.tmp / "GEMV-like" / "CSL" / "alt.csl").write_text("// a", "utf-8")
        t = resolve_target(str(self.tmp / "GEMV-like"),
                            target_relpath_override="alt.csl")
        self.assertEqual(t.target_relpath, "alt.csl")

    def test_kernel_id_replaces_whitespace(self) -> None:
        # Names like "7-Point Stencil" must become "7-Point_Stencil" so
        # the persistence slug doesn't carry a space.
        (self.tmp / "7-Point Stencil" / "CSL").mkdir(parents=True)
        (self.tmp / "7-Point Stencil" / "CSL" / "pe.csl").write_text("// p", "utf-8")
        (self.tmp / "7-Point Stencil" / "CSL" / "layout.csl").write_text("// l", "utf-8")
        (self.tmp / "7-Point Stencil" / "CSL" / "commands_wse3.sh"
         ).write_text("#!/bin/bash\necho ok\n", "utf-8")
        from optimize_explore import resolve_target
        t = resolve_target(str(self.tmp / "7-Point Stencil"))
        self.assertEqual(t.kernel_id, "7-Point_Stencil")

    def test_no_compute_file_raises(self) -> None:
        (self.tmp / "Empty" / "CSL").mkdir(parents=True)
        (self.tmp / "Empty" / "CSL" / "layout.csl").write_text("// l", "utf-8")
        (self.tmp / "Empty" / "CSL" / "commands_wse3.sh").write_text(
            "#!/bin/bash\necho ok\n", "utf-8")
        from optimize_explore import resolve_target
        with self.assertRaises(FileNotFoundError) as ctx:
            resolve_target(str(self.tmp / "Empty"))
        self.assertIn("compute file", str(ctx.exception))

    def test_arch_falls_back_to_wse2(self) -> None:
        # Stencil-like ships only commands_wse2.sh — exercises the fallback
        # that fixes the SpMV-Hypersparse / 25-Point Stencil failures.
        from optimize_explore import resolve_target
        t = resolve_target(str(self.tmp / "Stencil-like"))
        self.assertEqual(t.arch, "wse2")
        self.assertEqual(t.commands_script, "commands_wse2.sh")

    def test_arch_prefers_wse3(self) -> None:
        # When both scripts exist, wse3 wins.
        (self.tmp / "GEMV-like" / "CSL" / "commands_wse2.sh").write_text(
            "#!/bin/bash\necho old\n", "utf-8")
        from optimize_explore import resolve_target
        t = resolve_target(str(self.tmp / "GEMV-like"))
        self.assertEqual(t.arch, "wse3")
        self.assertEqual(t.commands_script, "commands_wse3.sh")

    def test_arch_override(self) -> None:
        # --arch=wse2 explicitly wins even when wse3 also exists.
        (self.tmp / "GEMV-like" / "CSL" / "commands_wse2.sh").write_text(
            "#!/bin/bash\necho old\n", "utf-8")
        from optimize_explore import resolve_target
        t = resolve_target(str(self.tmp / "GEMV-like"), arch_override="wse2")
        self.assertEqual(t.arch, "wse2")
        self.assertEqual(t.commands_script, "commands_wse2.sh")

    def test_no_commands_script_raises(self) -> None:
        # An otherwise-valid bundle without any commands_*.sh should fail
        # at resolve time, not 30s into a benchmark run.
        (self.tmp / "Scriptless" / "CSL").mkdir(parents=True)
        (self.tmp / "Scriptless" / "CSL" / "pe.csl").write_text("// p", "utf-8")
        (self.tmp / "Scriptless" / "CSL" / "layout.csl").write_text("// l", "utf-8")
        from optimize_explore import resolve_target
        with self.assertRaises(FileNotFoundError) as ctx:
            resolve_target(str(self.tmp / "Scriptless"))
        self.assertIn("commands_", str(ctx.exception))


class OptimizeRepairClassifierTests(unittest.TestCase):

    def setUp(self) -> None:
        from optimize_explore import OptimizationOrchestrator
        from workflow_common import ProviderHandle
        from knowledge_persistence import ExplorationStore
        self.tmp = tempfile.mkdtemp(prefix="opt_repair_test_")
        self.orch = OptimizationOrchestrator(
            provider=ProviderHandle(kind="stub", client=None, model="stub"),
            store=ExplorationStore(root=self.tmp),
            sdk_root="~/cs_sdk-1.4.0",
            work_root=os.path.join(self.tmp, "work"),
            shell_setup=None,
        )

    def tearDown(self) -> None:
        shutil.rmtree(self.tmp, ignore_errors=True)

    def test_compile_fail_is_repairable(self) -> None:
        # bench fail: command_failed is the dominant GEMV failure mode.
        self.assertTrue(self.orch._is_repairable(
            "bench fail: fail: command_failed"))

    def test_contract_violation_is_repairable(self) -> None:
        self.assertTrue(self.orch._is_repairable(
            "contract: FROZEN function 'f_tic' is missing from the variant"))

    def test_no_cycles_is_repairable(self) -> None:
        self.assertTrue(self.orch._is_repairable(
            "cycles_send not reported by run.py"))

    def test_no_improvement_is_not_repairable(self) -> None:
        # The LLM produced a correct kernel; repairing won't help.
        # Future rounds with a different angle will.
        self.assertFalse(self.orch._is_repairable(
            "no-improvement (cycles 4003 >= threshold 3962)"))

    def test_none_reason_is_not_repairable(self) -> None:
        self.assertFalse(self.orch._is_repairable(None))


class OptimizeFailurePersistenceTests(unittest.TestCase):

    def setUp(self) -> None:
        self.tmp = tempfile.mkdtemp(prefix="opt_fail_persist_test_")
        from knowledge_persistence import ExplorationStore
        self.store = ExplorationStore(root=self.tmp)

    def tearDown(self) -> None:
        shutil.rmtree(self.tmp, ignore_errors=True)

    def test_failure_bundle_written_when_artefacts_present(self) -> None:
        self.store.record_optimization(
            kernel="GEMV", kernel_group="gemv",
            angle="memory_simd_alignment",
            baseline_cycles=4003, candidate_cycles=None,
            accepted=False,
            reject_reason="bench fail: fail: command_failed",
            optimized_pe_csl="",
            diff_summary=None,
            benchmark_result={"status": "fail"},
            failure_pe_csl="// broken pe.csl\nfn step() void { ... }",
            failure_layout_csl="// layout placeholder",
            failure_stderr_tail="pe.csl:12:5: error: type mismatch",
            failure_diagnosis="Likely missing @as cast.",
        )
        # Bundle written under failures/
        failure_dirs = list((Path(self.tmp) / "optimization" / "failures"
                             ).glob("gemv_memory_simd_alignment__*"))
        self.assertEqual(len(failure_dirs), 1)
        d = failure_dirs[0]
        self.assertTrue((d / "last_pe.csl").is_file())
        self.assertTrue((d / "last_layout.csl").is_file())
        self.assertTrue((d / "error_log.txt").is_file())
        self.assertTrue((d / "diagnosis.md").is_file())
        # JSONL row records artifacts_dir pointing at the failure bundle
        rows = self.store.load_optimization_records()
        self.assertEqual(len(rows), 1)
        self.assertTrue(rows[0]["artifacts_dir"].startswith("optimization/failures/"))

    def test_no_failure_bundle_when_artefacts_empty(self) -> None:
        # If the orchestrator has nothing to persist (e.g. LLM error before
        # any candidate emitted), we should NOT create an empty bundle dir.
        self.store.record_optimization(
            kernel="GEMV", kernel_group="gemv",
            angle="comptime_hoist",
            baseline_cycles=4003, candidate_cycles=None,
            accepted=False,
            reject_reason="implementer LLM error: 503",
            optimized_pe_csl="",
            diff_summary=None,
            benchmark_result={"status": "fail"},
        )
        failure_dirs = list((Path(self.tmp) / "optimization" / "failures"
                             ).glob("gemv_comptime_hoist__*"))
        self.assertEqual(len(failure_dirs), 0)
        # JSONL row still appended.
        rows = self.store.load_optimization_records()
        self.assertEqual(len(rows), 1)


if __name__ == "__main__":
    # Run with high verbosity and short tracebacks.
    unittest.main(verbosity=2)
