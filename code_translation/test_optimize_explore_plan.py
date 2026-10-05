"""Tests for the OptimizationOrchestrator's Piece-3a additions:
   * ``_load_plan`` — round-0 planner call + fallback paths.
   * ``benchmark_with_files`` — multi-file dict staging contract
     (empty / primary-missing rejected; single-file delegates).

Live LLM and live `cslc` paths stay out of scope here (covered by the
end-to-end Piece-3d tests). This file is for behaviour we can verify
with stubbed dependencies.
"""

from __future__ import annotations

import os
import shutil
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch, MagicMock

THIS_DIR = Path(__file__).resolve().parent
if str(THIS_DIR) not in sys.path:
    sys.path.insert(0, str(THIS_DIR))

import bench_structure
import optimize_explore
import optimization_planner


def _write(path: Path, body: str) -> Path:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(body, encoding="utf-8")
    return path


def _make_self_contained_bundle(root: Path) -> Path:
    """Bench dir with pe.csl + layout.csl + commands script + run.py.
    Self-contained — no editable imports — so the planner trivially
    returns root-only."""
    bundle = root / "bundle"
    _write(bundle / "pe.csl",
           "// trivial PE\n"
           "param N: u16;\n"
           "fn compute() void {}\n")
    _write(bundle / "layout.csl",
           "@import_module(\"<layout>\");\nlayout { 1, 1 }\n")
    _write(bundle / "commands_wse3.sh",
           "#!/bin/bash\ncslc layout.csl --arch=wse3\n")
    _write(bundle / "run.py", "print('hello')\n")
    return bundle


def _make_dispatcher_bundle(root: Path) -> Path:
    """Bench whose root pe.csl @import_module's a sibling blas.csl that
    holds the real compute. Forces the planner into multi-file land."""
    bundle = root / "dispatcher"
    _write(bundle / "pe.csl",
           "const blas = @import_module(\"blas.csl\");\n"
           "fn run() void { blas.gemv(); }\n")
    _write(bundle / "blas.csl",
           "fn gemv() void {\n"
           "    var acc: f32 = 0.0;\n"
           "    for (@range(i16, 16)) |i| {\n"
           "        acc += 1.0;\n"
           "    }\n"
           "}\n")
    _write(bundle / "layout.csl", "@import_module(\"<layout>\");\n")
    _write(bundle / "commands_wse3.sh", "#!/bin/bash\ncslc layout.csl\n")
    _write(bundle / "run.py", "print('hi')\n")
    return bundle


def _make_orchestrator() -> optimize_explore.OptimizationOrchestrator:
    """Build an orchestrator with everything stubbed — no provider, no
    SDK, no work_root that touches disk on the wrong process."""
    provider = MagicMock()
    provider.kind = "stub"
    provider.model = "stub-model"
    provider.client = MagicMock()
    store = MagicMock()
    work_root = tempfile.mkdtemp(prefix="opt_explore_test_")
    orch = optimize_explore.OptimizationOrchestrator(
        provider=provider,
        store=store,
        sdk_root="/tmp/nonexistent-sdk",
        work_root=work_root,
        shell_setup=None,
    )
    # Round-0 baseline is set by run() in production; tests have to
    # populate it manually since they call _load_plan() in isolation.
    orch._first_round_baseline = 1234
    return orch


class LoadPlanTests(unittest.TestCase):

    def setUp(self) -> None:
        self.tmp = Path(tempfile.mkdtemp(prefix="optload_"))
        # Use a fresh explored_root each test so plan caches don't
        # carry across tests.
        self.explored_root = self.tmp / "explored"
        self.explored_root.mkdir()

    def tearDown(self) -> None:
        shutil.rmtree(self.tmp, ignore_errors=True)

    def test_self_contained_kernel_loads_trivial_plan(self) -> None:
        """A bench with no editable imports should get a root-only plan
        WITHOUT the LLM ever being called (the planner's
        _trivial_plan_if_obvious short-circuit). The plan is cached in
        a throwaway dir via XKERNEL_OPTIMIZATION_PLANS_ROOT so the shared
        prod plans cache is untouched."""
        bundle = _make_self_contained_bundle(self.tmp)
        target = optimize_explore.OptimizationTarget(
            bundle_dir=bundle, target_relpath="pe.csl",
            kernel_id="TrivK", kernel_group="all",
        )
        orch = _make_orchestrator()
        env = dict(os.environ)
        env["XKERNEL_OPTIMIZATION_PLANS_ROOT"] = str(self.explored_root)
        with patch.dict(os.environ, env, clear=True):
            llm_mock = MagicMock(side_effect=AssertionError(
                "trivial plan path must NOT call LLM"))
            orch.llm = llm_mock  # type: ignore[assignment]
            plan = orch._load_plan(target)
        self.assertEqual(plan.focus_files, ["pe.csl"])
        self.assertEqual(plan.expose_in_prompt, ["pe.csl"])
        self.assertEqual(plan.kernel_id, "TrivK")
        self.assertIs(orch.plan, plan)  # stashed on instance
        # And: the plan landed in the throwaway dir, not the prod one.
        prod_path = Path(os.path.expanduser(
            optimization_planner.DEFAULT_EXPLORED_ROOT
        )) / "optimization/plans" / "trivk.json"
        self.assertFalse(
            prod_path.exists(),
            f"test polluted prod plans dir at {prod_path}",
        )

    def test_scan_failure_falls_back_to_root_only(self) -> None:
        """If bench_structure.scan_bench raises, _load_plan must NOT
        propagate — it should swap in a root-only fallback so the
        orchestrator can keep going."""
        bundle = _make_self_contained_bundle(self.tmp)
        target = optimize_explore.OptimizationTarget(
            bundle_dir=bundle, target_relpath="pe.csl",
            kernel_id="ScanFail", kernel_group="all",
        )
        orch = _make_orchestrator()
        with patch.object(bench_structure, "scan_bench",
                          side_effect=RuntimeError("disk fell off")):
            plan = orch._load_plan(target)
        self.assertEqual(plan.focus_files, ["pe.csl"])
        self.assertEqual(plan.expose_in_prompt, ["pe.csl"])
        self.assertEqual(plan.confidence, "low")
        self.assertIn("FALLBACK", plan.rationale)

    def test_planner_exception_falls_back_to_root_only(self) -> None:
        """If get_or_make_plan raises, _load_plan must still return a
        usable plan rather than letting the orchestrator crash."""
        bundle = _make_dispatcher_bundle(self.tmp)
        target = optimize_explore.OptimizationTarget(
            bundle_dir=bundle, target_relpath="pe.csl",
            kernel_id="PlannerFail", kernel_group="linalg",
        )
        orch = _make_orchestrator()
        with patch.object(optimization_planner, "get_or_make_plan",
                          side_effect=RuntimeError("LLM 500")):
            plan = orch._load_plan(target)
        self.assertEqual(plan.focus_files, ["pe.csl"])
        self.assertEqual(plan.confidence, "low")
        self.assertIn("FALLBACK", plan.rationale)


class BenchmarkWithFilesContractTests(unittest.TestCase):
    """The actual benchmark/cslc path needs a working SDK + bundle; these
    tests cover only the input-validation contract that's reachable
    without invoking the simulator."""

    def setUp(self) -> None:
        self.tmp = Path(tempfile.mkdtemp(prefix="benchfiles_"))

    def tearDown(self) -> None:
        shutil.rmtree(self.tmp, ignore_errors=True)

    def _target(self) -> optimize_explore.OptimizationTarget:
        bundle = _make_self_contained_bundle(self.tmp)
        return optimize_explore.OptimizationTarget(
            bundle_dir=bundle, target_relpath="pe.csl",
            kernel_id="BenchTest", kernel_group="all",
        )

    def test_empty_files_dict_rejected(self) -> None:
        orch = _make_orchestrator()
        with self.assertRaisesRegex(ValueError, "empty files dict"):
            orch.benchmark_with_files(self._target(), {})

    def test_primary_missing_rejected(self) -> None:
        orch = _make_orchestrator()
        with self.assertRaisesRegex(ValueError, "not in files dict"):
            orch.benchmark_with_files(
                self._target(),
                {"blas.csl": "fn x() void {}\n"},  # missing pe.csl
            )

    def test_single_file_delegates_to_translate_path(self) -> None:
        """Single-file dict should call the wrapped
        benchmark_translated_compute_file exactly once — the legacy
        single-file path, no overlay logic engaged."""
        target = self._target()
        orch = _make_orchestrator()
        # Patch the helper imported into optimize_explore's namespace,
        # not the original benchmark_csl symbol — Python's `from ... import`
        # binds a local name and patching the source has no effect here.
        with patch.object(optimize_explore,
                           "benchmark_translated_compute_file") as mock_bench:
            mock_bench.return_value = {"status": "pass", "cycles_send": 999,
                                        "commands_script": "commands_wse3.sh",
                                        "staged_bundle": str(self.tmp / "fake")}
            result = orch.benchmark_with_files(
                target, {"pe.csl": "// new\n"},
            )
        self.assertEqual(mock_bench.call_count, 1)
        self.assertEqual(result["status"], "pass")
        self.assertEqual(result["cycles_send"], 999)


class MultiFileRoundTests(unittest.TestCase):
    """End-to-end test of the multi-file round handler with stubbed LLM
    and benchmark. Confirms:
      * the LLM is asked the multi-file prompt when plan.focus_files > 1
      * a reply with all focus fences accepts (when cycles drop)
      * a reply missing a focus fence rejects with "missing focus files"
      * a reply that touches a read-only file rejects with
        "touched read-only files"
    """

    def setUp(self) -> None:
        self.tmp = Path(tempfile.mkdtemp(prefix="multif_round_"))

    def tearDown(self) -> None:
        shutil.rmtree(self.tmp, ignore_errors=True)

    def _setup_orch_with_plan(self, plan_focus, plan_expose):
        bundle = _make_dispatcher_bundle(self.tmp)
        target = optimize_explore.OptimizationTarget(
            bundle_dir=bundle, target_relpath="pe.csl",
            kernel_id="MFTest", kernel_group="linalg",
            angles=["buffer_cleanup"],  # simplest catalog entry
        )
        orch = _make_orchestrator()
        orch._first_round_baseline = 10000
        orch.plan = optimization_planner.OptimizationPlan(
            kernel_id="MFTest",
            focus_files=plan_focus,
            expose_in_prompt=plan_expose,
            rationale="test",
            suggested_first_angle="buffer_cleanup",
            confidence="high",
            fingerprint="test",
        )
        # Stub the persistence layer.
        orch.store.record_optimization = MagicMock(return_value={
            "ts": "20260605T000000",
            "speedup": 1.5,
            "artifacts_dir": "optimization/accepted/test__20260605",
        })
        orch.store.root = self.tmp / "explored"
        return orch, target

    def test_multifile_accept_path(self) -> None:
        orch, target = self._setup_orch_with_plan(
            plan_focus=["pe.csl", "blas.csl"],
            plan_expose=["pe.csl", "blas.csl"],
        )
        # Stub the LLM: angle selector picks buffer_cleanup, then
        # implementer returns a multi-file reply with both focus files.
        # The benchmark stub reports a cycle drop so the round accepts.
        def fake_llm(prompt, max_tokens=None, system=None):
            if "BUCKET:" in prompt or "Pick the angle" in prompt:
                return "ANGLE: buffer_cleanup\nREASON: stub"
            if "MULTI-FILE EDIT" in prompt:
                return (
                    "```csl:pe.csl\n"
                    "const blas = @import_module(\"blas.csl\");\n"
                    "fn run() void { blas.gemv(); }\n"
                    "```\n\n"
                    "```csl:blas.csl\n"
                    "fn gemv() void { /* bulk fmacs - optimised */ }\n"
                    "```\n"
                )
            # diff distiller call.
            return "Test diff: bulk fmacs in blas.csl."
        orch.llm = fake_llm  # type: ignore[assignment]
        # Stub benchmark to report a cycle drop.
        orch.benchmark_with_files = MagicMock(return_value={
            "status": "pass", "cycles_send": 8000,
            "cycles_send_runs": [8000, 7990, 8010],
            "commands_script": "commands_wse3.sh",
        })
        outcome = orch._attempt_round_multifile(
            target, round_idx=1, current_cycles=10000,
            bottlenecks={}, prior=[],
        )
        self.assertTrue(outcome.accepted, msg=f"reason={outcome.reject_reason}")
        self.assertEqual(outcome.candidate_cycles, 8000)
        # Confirm benchmark was given BOTH focus files.
        called_files = orch.benchmark_with_files.call_args[0][1]
        self.assertEqual(set(called_files.keys()), {"pe.csl", "blas.csl"})

    def test_multifile_omitted_focus_file_treated_as_unchanged(self) -> None:
        """When the LLM emits only one of two focus files, the omitted
        file is preserved (treated as unchanged) rather than rejecting.
        The acceptance gate (cycles must drop) is what defends against
        phantom wins. Behavior change landed after the piece-3d live
        run showed Opus reliably omits unchanged focus files.
        """
        orch, target = self._setup_orch_with_plan(
            plan_focus=["pe.csl", "blas.csl"],
            plan_expose=["pe.csl", "blas.csl"],
        )
        def fake_llm(prompt, max_tokens=None, system=None):
            if "Pick the angle" in prompt:
                return "ANGLE: buffer_cleanup\nREASON: stub"
            if "MULTI-FILE EDIT" in prompt:
                # LLM only emits one fence — drops the dispatcher,
                # only edits blas.csl. Should be treated as "dispatcher
                # unchanged, blas.csl rewritten".
                return ("```csl:blas.csl\n"
                        "fn gemv() void { /* better bulk fmacs */ }\n"
                        "```\n")
            return "diff"
        orch.llm = fake_llm  # type: ignore[assignment]
        orch.benchmark_with_files = MagicMock(return_value={
            "status": "pass", "cycles_send": 7500,  # wins
            "cycles_send_runs": [7500, 7495, 7505],
            "commands_script": "commands_wse3.sh",
        })
        outcome = orch._attempt_round_multifile(
            target, round_idx=1, current_cycles=10000,
            bottlenecks={}, prior=[],
        )
        self.assertTrue(outcome.accepted, msg=f"reason={outcome.reject_reason}")
        # Confirm benchmark got BOTH files — blas.csl with the new
        # content, pe.csl with the on-disk (unchanged) content.
        called_files = orch.benchmark_with_files.call_args[0][1]
        self.assertEqual(set(called_files.keys()), {"pe.csl", "blas.csl"})
        self.assertIn("better bulk fmacs", called_files["blas.csl"])
        # The preserved pe.csl should match the on-disk dispatcher
        # bundle text (which contains "blas.gemv()").
        self.assertIn("blas.gemv()", called_files["pe.csl"])

    def test_multifile_all_focus_omitted_rejected(self) -> None:
        """A reply with ZERO csl fences for any focus file is still a
        reject (nothing to benchmark). Defends against the case where
        the LLM emits only English prose and no code at all."""
        orch, target = self._setup_orch_with_plan(
            plan_focus=["pe.csl", "blas.csl"],
            plan_expose=["pe.csl", "blas.csl"],
        )
        def fake_llm(prompt, max_tokens=None, system=None):
            if "Pick the angle" in prompt:
                return "ANGLE: buffer_cleanup\nREASON: stub"
            if "MULTI-FILE EDIT" in prompt:
                return "I considered this but cannot find any improvement."
            return ""
        orch.llm = fake_llm  # type: ignore[assignment]
        orch.benchmark_with_files = MagicMock(side_effect=AssertionError(
            "should NOT benchmark when all focus files were omitted"))
        outcome = orch._attempt_round_multifile(
            target, round_idx=1, current_cycles=10000,
            bottlenecks={}, prior=[],
        )
        self.assertFalse(outcome.accepted)
        self.assertIn("omitted ALL focus files",
                       outcome.reject_reason or "")

    def test_multifile_state_propagates_across_rounds(self) -> None:
        """The bug: round 2's prompt previously saw the original
        on-disk text, so round 1's accept was discarded. Fix: the run
        loop tracks an accepted_files dict and passes it to the round
        handler as current_files_override.

        This test stubs round 1 to accept a particular blas.csl edit,
        then confirms round 2's prompt shows THAT edited blas.csl in
        the exposed_files_block (not the original on-disk text).
        """
        orch, target = self._setup_orch_with_plan(
            plan_focus=["pe.csl", "blas.csl"],
            plan_expose=["pe.csl", "blas.csl"],
        )
        # Pre-set the override as if round 1 had already accepted.
        round1_accepted = {
            "pe.csl": "// round-1 accepted pe.csl with foo_marker\n",
            "blas.csl": "// round-1 accepted blas.csl with bar_marker\n",
        }
        # Capture the prompt the LLM is fed in round 2.
        captured = {}
        def fake_llm(prompt, max_tokens=None, system=None):
            if "Pick the angle" in prompt:
                return "ANGLE: buffer_cleanup\nREASON: stub"
            if "MULTI-FILE EDIT" in prompt:
                captured["prompt"] = prompt
                # Return both focus files so the round proceeds (we
                # only care about the prompt content here, not whether
                # the round accepts).
                return (
                    "```csl:pe.csl\n// round-2 attempt\n```\n\n"
                    "```csl:blas.csl\n// round-2 attempt\n```\n"
                )
            return "stub"
        orch.llm = fake_llm  # type: ignore[assignment]
        # Stub benchmark to fail (we only care about prompt content).
        orch.benchmark_with_files = MagicMock(return_value={
            "status": "fail", "failure_reason": "stub",
            "cycles_send": None,
        })
        # Run round 2 with the override active.
        outcome = orch._attempt_round_multifile(
            target, round_idx=2, current_cycles=8000,
            bottlenecks={}, prior=[],
            current_files_override=round1_accepted,
        )
        # Prompt MUST show round-1 markers, not the original on-disk text.
        self.assertIn("foo_marker", captured.get("prompt", ""),
                       "round 2 prompt did not show round-1's accepted pe.csl")
        self.assertIn("bar_marker", captured.get("prompt", ""),
                       "round 2 prompt did not show round-1's accepted blas.csl")

    def test_multifile_reject_when_touches_readonly(self) -> None:
        # Expose includes layout.csl as read-only; LLM tries to edit it.
        orch, target = self._setup_orch_with_plan(
            plan_focus=["pe.csl"],          # only pe.csl is editable
            plan_expose=["pe.csl", "blas.csl"],  # blas is read-only
        )
        # Force multifile path even with one focus file by patching the
        # detection (in production this branch only runs when focus > 1,
        # but the read-only-touch check applies any time the parser sees
        # an unexpected relpath).
        orch._is_multifile = lambda: True  # type: ignore[assignment]
        def fake_llm(prompt, max_tokens=None, system=None):
            if "Pick the angle" in prompt:
                return "ANGLE: buffer_cleanup\nREASON: stub"
            if "MULTI-FILE EDIT" in prompt:
                return (
                    "```csl:pe.csl\nfn run() void {}\n```\n\n"
                    "```csl:blas.csl\nfn gemv() void {}\n```\n"
                )
            return ""
        orch.llm = fake_llm  # type: ignore[assignment]
        orch.benchmark_with_files = MagicMock(side_effect=AssertionError(
            "should not benchmark on read-only touch"))
        outcome = orch._attempt_round_multifile(
            target, round_idx=1, current_cycles=10000,
            bottlenecks={}, prior=[],
        )
        self.assertFalse(outcome.accepted)
        self.assertIn("read-only", outcome.reject_reason or "")
        self.assertIn("blas.csl", outcome.reject_reason or "")


class SelectAngleHonorsPlannerHintTests(unittest.TestCase):
    """When self.plan.suggested_first_angle is in the active angles
    list, round 1 of select_angle should use it instead of catalog
    order. Live runs (Piece 3f) showed the planner picking
    dsd_offset_chaining as the first-angle hint but auto-mode running
    comptime_value_tuning first because the catalog order placed it
    earlier — wasting the planner's most informed pick.
    """

    def setUp(self) -> None:
        self.tmp = Path(tempfile.mkdtemp(prefix="select_angle_"))

    def tearDown(self) -> None:
        shutil.rmtree(self.tmp, ignore_errors=True)

    def _orch_with_plan_and_target(self, first_angle: str,
                                    angles=None):
        bundle = _make_self_contained_bundle(self.tmp)
        target = optimize_explore.OptimizationTarget(
            bundle_dir=bundle, target_relpath="pe.csl",
            kernel_id="SelK", kernel_group="linalg",
            angles=angles or ["comptime_value_tuning",
                              "iterative_phase_fusion",
                              "dsd_offset_chaining",
                              "buffer_cleanup"],
        )
        orch = _make_orchestrator()
        orch.plan = optimization_planner.OptimizationPlan(
            kernel_id="SelK",
            focus_files=["pe.csl"],
            expose_in_prompt=["pe.csl"],
            rationale="t",
            suggested_first_angle=first_angle,
            confidence="medium",
            fingerprint="t",
        )
        return orch, target

    def test_round1_uses_planner_first_angle(self) -> None:
        """The planner suggested dsd_offset_chaining; round 1 should
        pick it even though comptime_value_tuning is earlier in the
        catalog order."""
        orch, target = self._orch_with_plan_and_target(
            first_angle="dsd_offset_chaining",
        )
        angle, reason = orch.select_angle(
            target,
            current_pe="// pe.csl\n",
            current_cycles=10000,
            bottlenecks={},
            prior_outcomes=[],  # round 1
        )
        self.assertEqual(angle, "dsd_offset_chaining")
        self.assertIn("planner", reason.lower())

    def test_round2_ignores_planner_first_angle(self) -> None:
        """After round 1, the fewest-attempts scheduler takes over.
        The planner hint should NOT keep biasing rounds 2+."""
        orch, target = self._orch_with_plan_and_target(
            first_angle="dsd_offset_chaining",
        )
        # Simulate round 1 attempted dsd_offset_chaining and rejected.
        prior = [optimize_explore.RoundOutcome(
            round_idx=1, angle="dsd_offset_chaining",
            accepted=False, candidate_cycles=10000,
            baseline_cycles=10000, speedup=1.0,
            reject_reason="no-improvement",
            diff_summary=None, raw_reply="",
        )]
        angle, _ = orch.select_angle(
            target,
            current_pe="// pe.csl\n",
            current_cycles=10000,
            bottlenecks={},
            prior_outcomes=prior,
        )
        # Should NOT pick dsd_offset_chaining again — it now has the
        # most attempts (1 vs 0 for others).
        self.assertNotEqual(angle, "dsd_offset_chaining")

    def test_planner_first_angle_outside_active_ignored(self) -> None:
        """If the planner's suggested angle isn't in the active list
        (e.g. it was pre-flight skipped), fall through to the
        catalog-order scheduler — don't pick a satisfied angle."""
        orch, target = self._orch_with_plan_and_target(
            first_angle="fmac_bulk",  # NOT in angles list
        )
        angle, _ = orch.select_angle(
            target,
            current_pe="// pe.csl\n",
            current_cycles=10000,
            bottlenecks={},
            prior_outcomes=[],
        )
        # Should fall through to the first catalog entry.
        self.assertEqual(angle, "comptime_value_tuning")

    def test_no_plan_no_hint(self) -> None:
        """Backward-compat: when self.plan is None (legacy path),
        select_angle continues using the catalog scheduler."""
        bundle = _make_self_contained_bundle(self.tmp)
        target = optimize_explore.OptimizationTarget(
            bundle_dir=bundle, target_relpath="pe.csl",
            kernel_id="NoPlan", kernel_group="linalg",
            angles=["comptime_value_tuning", "dsd_offset_chaining"],
        )
        orch = _make_orchestrator()
        # orch.plan is None by default — confirm that branch is taken.
        self.assertIsNone(orch.plan)
        angle, _ = orch.select_angle(
            target,
            current_pe="// pe.csl\n",
            current_cycles=10000,
            bottlenecks={},
            prior_outcomes=[],
        )
        self.assertEqual(angle, "comptime_value_tuning")


class FrozenCalloutBlockTests(unittest.TestCase):
    """Piece 3h: the prompt now surfaces frozen symbols as an explicit
    DO-NOT-EDIT list with specific names, fixing the 3-of-32 contract
    violations observed in Piece 3f (LLM tripped f_reference_timestamps
    despite the prior static "function bodies must match verbatim"
    prose).
    """

    def test_default_callout_lists_known_frozen_functions(self) -> None:
        from prompt_cuda2csl import default_frozen_callout_block
        block = default_frozen_callout_block()
        # The four frozen functions the live runs kept tripping.
        for fn in ("f_tic", "f_toc", "f_memcpy_timestamps",
                    "f_reference_timestamps"):
            self.assertIn(f"`{fn}`", block,
                           f"frozen fn {fn!r} missing from callout")
        # The common frozen params.
        for p in ("BLOCK_SIZE", "MAX_ZDIM", "width", "height"):
            self.assertIn(f"`{p}`", block,
                           f"frozen param {p!r} missing from callout")
        # The DO-NOT-EDIT banner.
        self.assertIn("FROZEN SYMBOLS", block)
        self.assertIn("DO NOT EDIT", block)

    def test_callout_honors_spec_override(self) -> None:
        """When spec.yaml provides explicit lists, the callout uses
        them instead of the catalog defaults."""
        from prompt_cuda2csl import default_frozen_callout_block
        spec = {
            "frozen_functions": ["my_custom_fn", "another_fn"],
            "frozen_params": ["MY_PARAM"],
        }
        block = default_frozen_callout_block(spec)
        self.assertIn("`my_custom_fn`", block)
        self.assertIn("`another_fn`", block)
        self.assertIn("`MY_PARAM`", block)
        # Defaults should NOT appear when an override is provided.
        self.assertNotIn("`f_tic`", block)
        self.assertNotIn("`BLOCK_SIZE`", block)

    def test_orchestrator_helper_delegates_to_module_fn(self) -> None:
        """OptimizationOrchestrator._build_frozen_callout_block should
        produce the same string as the shared module function."""
        from prompt_cuda2csl import default_frozen_callout_block
        bundle = _make_self_contained_bundle(Path(tempfile.mkdtemp()))
        target = optimize_explore.OptimizationTarget(
            bundle_dir=bundle, target_relpath="pe.csl",
            kernel_id="K", kernel_group="all",
            spec={"frozen_functions": ["f_tic"], "frozen_params": ["N"]},
        )
        orch = _make_orchestrator()
        self.assertEqual(
            orch._build_frozen_callout_block(target),
            default_frozen_callout_block(target.spec),
        )


if __name__ == "__main__":
    unittest.main(verbosity=2)
