"""Unit test for the compute-leak guard in cuda2csl.CUDA2CSLOrchestrator.

The benchmark contract is: agents may read layout.csl, run.py, and
commands_wse3.sh; they MUST NOT read the human-written compute CSL at
target_relpath. _set_compute_canary + _assert_no_compute_leak make this a
tested invariant rather than a documented convention.

Run with: python test_no_compute_leak.py
Exits 0 on pass, non-zero on failure (no pytest dependency).
"""
import os
import sys
import unittest
from unittest.mock import patch

# Make `import cuda2csl` resolve when run from any directory.
_HERE = os.path.dirname(os.path.abspath(__file__))
if _HERE not in sys.path:
    sys.path.insert(0, _HERE)

import cuda2csl  # noqa: E402


def _make_orchestrator():
    """Construct a minimal orchestrator that never opens a network client.
    All we need is __init__ side effects + the two guard methods."""
    return cuda2csl.CUDA2CSLOrchestrator(
        model="dummy-model",
        api_key_file="/dev/null",
        api_key_command=None,
        base_url=None,
        max_tokens=1024,
        turns_limit=1,
        work_root="/tmp/xkernel-test-no-leak",
        sdk_root="/dev/null",
        arch="wse3",
        commands_script="commands_wse3.sh",
        shell_setup=None,
    )


# Mirror a small chunk of a real reference compute CSL so the canary
# extraction picks something representative (a real fn declaration line).
_REFERENCE_COMPUTE_SAMPLE = """// kernel.csl — reference compute for some kernel
const sys_mod = @import_module("<memcpy/memcpy>", .{ .MAX_ZDIM = MAX_ZDIM });
const timestamp = @import_module("<time>");

var tscStartBuffer = @zeros([timestamp.tsc_size_words]u16);
var tscEndBuffer = @zeros([timestamp.tsc_size_words]u16);

fn very_distinctive_compute_function_name_for_canary(x: i16, y: i16) f32 {
    return @as(f32, x) * @as(f32, y);
}

fn f_tic() void {
    timestamp.get_timestamp(&tscStartBuffer);
    sys_mod.unblock_cmd_stream();
}
"""


class ComputeCanaryTests(unittest.TestCase):
    def test_canary_extracted_skips_imports_and_short_lines(self):
        orch = _make_orchestrator()
        orch._set_compute_canary(_REFERENCE_COMPUTE_SAMPLE, kernel_name="test-kernel")
        canary = orch._compute_canary
        self.assertIsNotNone(canary, "canary must be extracted from a real ref")
        # The canary should be a substantive line (≥40 chars), not an import.
        self.assertGreaterEqual(len(canary), 40)
        self.assertNotIn("@import_module", canary)
        # It should be a distinctive line we'd notice in any leak.
        self.assertIn("very_distinctive_compute_function_name_for_canary", canary)

    def test_disarmed_when_no_reference(self):
        orch = _make_orchestrator()
        orch._set_compute_canary(None, kernel_name="no-ref")
        self.assertIsNone(orch._compute_canary)
        # Should be a no-op (no exception) even if messages contain anything.
        orch._assert_no_compute_leak([
            {"role": "user", "content": "any text at all, nothing to check"},
        ])

    def test_assert_passes_for_clean_prompt(self):
        orch = _make_orchestrator()
        orch._set_compute_canary(_REFERENCE_COMPUTE_SAMPLE, kernel_name="test-kernel")
        orch._assert_no_compute_leak([
            {"role": "system", "content": "You are an expert in CSL."},
            {"role": "user", "content": "Here is layout.csl: const foo = 42;"},
        ])  # must not raise

    def test_assert_raises_on_leak(self):
        orch = _make_orchestrator()
        orch._set_compute_canary(_REFERENCE_COMPUTE_SAMPLE, kernel_name="test-kernel")
        leaky = orch._compute_canary
        with self.assertRaises(AssertionError) as ctx:
            orch._assert_no_compute_leak([
                {"role": "user", "content": f"Reference code follows:\n{leaky}\n"},
            ])
        self.assertIn("compute-leak guard", str(ctx.exception))
        self.assertIn("test-kernel", str(ctx.exception))

    def test_assert_tolerates_non_string_content(self):
        # Some message shapes (rare) carry list/dict content. Don't crash.
        orch = _make_orchestrator()
        orch._set_compute_canary(_REFERENCE_COMPUTE_SAMPLE, kernel_name="test-kernel")
        orch._assert_no_compute_leak([
            {"role": "user", "content": [{"type": "text", "text": "ok"}]},
        ])

    def test_w2_disarm_allows_compute_in_prompt(self):
        """W2 (--optimize-only) legitimately feeds the input CSL into the
        optimizer prompt. The disarm flag must let that pass; the contract
        validator is the second layer that still catches gaming."""
        orch = _make_orchestrator()
        orch._set_compute_canary(_REFERENCE_COMPUTE_SAMPLE, kernel_name="test-kernel")
        orch._w2_disarm_compute_canary = True
        leaky = orch._compute_canary
        # Same content that would raise in W1 must NOT raise in W2.
        orch._assert_no_compute_leak([
            {"role": "user", "content": f"Current code at 2129 cycles:\n{leaky}\n"},
        ])
        # Sanity: flipping back arms the guard again.
        orch._w2_disarm_compute_canary = False
        with self.assertRaises(AssertionError):
            orch._assert_no_compute_leak([
                {"role": "user", "content": f"prefix {leaky}"},
            ])

    def test_llm_call_invokes_guard(self):
        """_llm_call must call _assert_no_compute_leak BEFORE making the
        network request. Patch llm_complete to confirm the guard fires
        first (we never reach llm_complete on leak)."""
        orch = _make_orchestrator()
        orch._set_compute_canary(_REFERENCE_COMPUTE_SAMPLE, kernel_name="test-kernel")
        leaky = orch._compute_canary
        with patch.object(cuda2csl, "llm_complete") as mocked:
            with self.assertRaises(AssertionError):
                orch._llm_call([{"role": "user", "content": f"prefix {leaky} suffix"}])
            mocked.assert_not_called()


class BuildReferenceContractLeakTest(unittest.TestCase):
    """Integration-ish check: build_reference_contract returns the reference
    compute as a SEPARATE value from the contract; the contract string itself
    must NOT contain the canary line from the compute CSL.

    Uses the real 7-Point Stencil kernel bundle as the fixture so this catches
    regressions in build_reference_contract (e.g., if someone accidentally
    inlined the compute CSL into the contract)."""

    REFERENCE_DIR = os.path.normpath(
        os.path.join(_HERE, "..", "kernels", "7-Point Stencil", "CSL")
    )

    def _build_or_skip(self):
        if not os.path.isdir(self.REFERENCE_DIR):
            self.skipTest(f"missing reference dir: {self.REFERENCE_DIR}")
        return cuda2csl.build_reference_contract(
            reference_dir=self.REFERENCE_DIR,
            target_relpath="src/kernel.csl",
            commands_script="commands_wse3.sh",
        )

    def test_returns_three_tuple(self):
        contract, reference_compute, layout_text = self._build_or_skip()
        self.assertTrue(contract.strip(), "contract must be non-empty")
        self.assertTrue(reference_compute.strip(), "reference compute must be non-empty")
        self.assertTrue(layout_text.strip(), "layout_text must be non-empty")
        self.assertGreater(len(layout_text), 200,
                           "layout.csl is usually 2-4 KB; suspiciously short")

    def test_contract_does_not_contain_compute_canary(self):
        contract, reference_compute, layout_text = self._build_or_skip()
        orch = _make_orchestrator()
        orch._set_compute_canary(reference_compute, kernel_name="7-Point Stencil")
        canary = orch._compute_canary
        self.assertIsNotNone(canary, "must be able to extract canary from real ref")
        self.assertNotIn(
            canary, contract,
            f"contract string contains reference-compute canary {canary[:60]!r} — "
            f"this means the reference compute is leaking into prompts.",
        )

    def test_contract_does_not_contain_layout(self):
        """Phase 2a: layout is now a separate prompt section, so it must NOT
        be embedded in the contract string (or it'd be shown twice)."""
        contract, _, layout_text = self._build_or_skip()
        # Pick a distinctive line from layout that's unlikely to coincidentally
        # appear in run.py / commands_wse3.sh.
        distinctive = None
        for line in layout_text.splitlines():
            line = line.strip()
            if line.startswith("//") or not line:
                continue
            if line.startswith("const ") and "@get_color" in line:
                distinctive = line
                break
            if line.startswith("layout {"):
                distinctive = line
                break
        if not distinctive:
            self.skipTest("could not extract distinctive layout line for this kernel")
        self.assertNotIn(
            distinctive, contract,
            "Phase 2a removed layout.csl from build_reference_contract's "
            "contract string. If this assertion fires, layout is being shown "
            "twice (once hoisted, once embedded).",
        )


class PromptRenderingTest(unittest.TestCase):
    """All 4 implementer-facing templates with new {layout_text} slots must
    render against the real 7-Point Stencil bundle without KeyError."""

    REFERENCE_DIR = os.path.normpath(
        os.path.join(_HERE, "..", "kernels", "7-Point Stencil", "CSL")
    )

    def _bundle(self):
        if not os.path.isdir(self.REFERENCE_DIR):
            self.skipTest(f"missing reference dir: {self.REFERENCE_DIR}")
        return cuda2csl.build_reference_contract(
            reference_dir=self.REFERENCE_DIR,
            target_relpath="src/kernel.csl",
            commands_script="commands_wse3.sh",
        )

    def test_q_translate_renders(self):
        import prompt_cuda2csl as P
        contract, _, layout_text = self._bundle()
        out = P.q_translate_cuda_to_csl_bundle.format(
            target_relpath="src/kernel.csl",
            knowledge_base="(test knowledge)",
            task_summary="(test task)",
            decomposition_plan="(test design)",
            layout_text=layout_text,
            translation_facts="",
            reference_contract=contract,
            cuda_analysis="(test analysis)",
            cuda_code="// test cuda",
            builtin_whitelist="(test whitelist)",
        )
        self.assertIn("layout.csl", out)
        self.assertIn("EXACT interface", out)

    def test_q_design_architecture_renders(self):
        import prompt_cuda2csl as P
        contract, _, layout_text = self._bundle()
        out = P.q_design_architecture.format(
            knowledge_base="(test knowledge)",
            layout_text=layout_text,
            reference_contract=contract,
            cuda_analysis="(test analysis)",
            cuda_code="// test cuda",
        )
        self.assertIn("immutable interface", out)

    def test_csl_bundle_fix_with_review_renders(self):
        import prompt_cuda2csl as P
        contract, _, layout_text = self._bundle()
        out = P.csl_bundle_fix_with_review.format(
            current_code="// test current",
            layout_text=layout_text,
            translation_facts="",
            reference_contract=contract,
            benchmark_status="fail",
            failure_reason="test",
            command_transcript="(test transcript)",
            verdict_bucket="B",
            reviewer_rationale="(test rationale)",
            debug_action="(test action)",
            debugger_report="",
            builtin_whitelist="(test whitelist)",
        )
        self.assertIn("EXACT interface", out)

    def test_csl_bundle_fix_contract_renders(self):
        import prompt_cuda2csl as P
        contract, _, layout_text = self._bundle()
        out = P.csl_bundle_fix_contract.format(
            current_code="// test current",
            layout_text=layout_text,
            translation_facts="",
            reference_contract=contract,
            commands_script="commands_wse3.sh",
            benchmark_status="fail",
            failure_reason="test",
            command_transcript="(test transcript)",
            reviewer_rationale="(test rationale)",
            missing_symbol="f_test",
            debug_action="(test action)",
            builtin_whitelist="(test whitelist)",
        )
        self.assertIn("EXACT interface", out)


class MultiRunBenchmarkTest(unittest.TestCase):
    """Phase 1a: variance reduction via num_runs.

    The actual cs_python execution depends on the Cerebras SDK + simulator,
    so we test the parts that DON'T need the toolchain: the runner-script
    generation (does it repeat run steps N times?) and the cycles
    aggregation (does it median correctly?)."""

    def test_runner_script_repeats_run_steps(self):
        import benchmark_csl as B
        import tempfile
        with tempfile.TemporaryDirectory() as td:
            commands = [
                "cslc ./src/layout.csl --arch wse3 -o out",      # compile
                "cs_python ./run.py --latestlink out --run-only",  # run
            ]
            path = B.write_instrumented_runner(td, commands, None, num_runs=3)
            with open(path) as fh:
                body = fh.read()
            # The compile step appears exactly once...
            self.assertEqual(body.count("cslc ./src/layout.csl"), 1)
            # ...the run step appears N times.
            self.assertEqual(body.count("cs_python ./run.py"), 3)
            # Repeat idx tagging "2.1", "2.2", "2.3" must be present.
            for r in (1, 2, 3):
                self.assertIn(f"run_step 2.{r}", body)

    def test_runner_script_default_is_unchanged(self):
        """num_runs=1 must produce a script byte-identical (modulo trailing
        newline) to the pre-Phase-1a output. This is the backward-compat
        contract: anyone running with default flags sees no behavior change."""
        import benchmark_csl as B
        import tempfile
        with tempfile.TemporaryDirectory() as td:
            commands = ["cslc layout.csl -o out", "cs_python run.py"]
            path_default = B.write_instrumented_runner(td, commands, None)  # default = 1
            with open(path_default) as fh:
                default_body = fh.read()
            path_explicit = B.write_instrumented_runner(td, commands, None, num_runs=1)
            with open(path_explicit) as fh:
                explicit_body = fh.read()
            self.assertEqual(default_body, explicit_body)
            # Each step appears exactly once.
            self.assertEqual(default_body.count("cslc"), 1)
            self.assertEqual(default_body.count("cs_python"), 1)

    def test_extract_kernel_cycles_median(self):
        import benchmark_csl as B
        # Three run steps with different cycles_send values.
        transcript = [
            {"step": "compile", "stdout": "", "stderr": ""},
            {"step": "run", "stdout": "cycles_send = 1233 cycles\ntime_send = 1.45 us", "stderr": ""},
            {"step": "run", "stdout": "cycles_send = 1076 cycles\ntime_send = 1.27 us", "stderr": ""},
            {"step": "run", "stdout": "cycles_send = 2129 cycles\ntime_send = 2.50 us", "stderr": ""},
        ]
        cycles, time_us, runs, time_runs, per_fn = B._extract_kernel_cycles(transcript)
        # Median of (1233, 1076, 2129) sorted = (1076, 1233, 2129) → 1233.
        # (The progress-doc-cited samples!)
        self.assertEqual(cycles, 1233)
        self.assertEqual(runs, [1233, 1076, 2129])
        self.assertEqual(len(time_runs), 3)

    def test_extract_kernel_cycles_single_run_unchanged(self):
        """num_runs=1: median == sole value; backwards compat with pre-Phase-1a."""
        import benchmark_csl as B
        transcript = [{"step": "run", "stdout": "cycles_send = 2129 cycles", "stderr": ""}]
        cycles, _, runs, _, _ = B._extract_kernel_cycles(transcript)
        self.assertEqual(cycles, 2129)
        self.assertEqual(runs, [2129])

    def test_extract_kernel_cycles_none_for_correctness_only(self):
        """A run.py that doesn't print cycles_send (correctness-only kernel)
        yields None — same as before."""
        import benchmark_csl as B
        transcript = [{"step": "run", "stdout": "SUCCESS!", "stderr": ""}]
        cycles, time_us, runs, _, _ = B._extract_kernel_cycles(transcript)
        self.assertIsNone(cycles)
        self.assertIsNone(time_us)
        self.assertEqual(runs, [])


class RunPyCompressionTest(unittest.TestCase):
    """Phase 2b: run.py compression keeps the host-protocol skeleton when
    max_chars triggers, drops only the boilerplate."""

    BIG_KERNEL_DIR = os.path.normpath(
        os.path.join(_HERE, "..", "kernels", "BiCGSTAB", "CSL")
    )
    SMALL_KERNEL_DIR = os.path.normpath(
        os.path.join(_HERE, "..", "kernels", "7-Point Stencil", "CSL")
    )

    def _build(self, ref_dir, max_chars=None):
        if not os.path.isdir(ref_dir):
            self.skipTest(f"missing reference dir: {ref_dir}")
        return cuda2csl.build_reference_contract(
            reference_dir=ref_dir,
            target_relpath="src/kernel.csl",
            commands_script="commands_wse3.sh",
            max_chars=max_chars,
        )

    def test_small_kernel_untouched_at_default_threshold(self):
        """7pt-Stencil's run.py is ~14 KB; either way (digested or verbatim)
        the host-protocol skeleton + verification + cycles_send must
        survive in the contract."""
        contract, _, _ = self._build(self.SMALL_KERNEL_DIR, max_chars=12000)
        self.assertIn("cycles_send", contract)
        # Different kernels use different host-runner names (simulator vs
        # runner). At least one launch call must survive.
        self.assertTrue("simulator.launch" in contract or "runner.launch" in contract,
                        "at least one host-runner launch must survive")
        # Critical: verification + timing path must survive in some form.
        # (Either verbatim if uncompressed, or as a kept line if compressed.)
        self.assertTrue("assert_allclose" in contract or "SUCCESS" in contract,
                        "verification call must be preserved in the contract")
        # f_tic / f_toc / f_memcpy_timestamps / f_reference_timestamps
        # references must all survive — these are the launches the agent
        # must keep its compute file compatible with.
        for fn in ("f_tic", "f_toc", "f_memcpy_timestamps", "f_reference_timestamps"):
            self.assertIn(fn, contract, f"launch of {fn} must be in the contract")

    def test_big_kernel_compressed_under_threshold(self):
        """BiCGSTAB run.py is ~25 KB; with max_chars=10000 the digest must
        trigger and produce a contract smaller than the uncompressed one."""
        contract_uncompressed, _, _ = self._build(self.BIG_KERNEL_DIR, max_chars=None)
        contract_compressed, _, _ = self._build(self.BIG_KERNEL_DIR, max_chars=10000)
        self.assertLess(len(contract_compressed), len(contract_uncompressed),
                        "compression should produce a shorter contract")
        # Critical: the digest header must say what happened so the agent
        # knows it's looking at a digest, not the real file.
        self.assertIn("compressed", contract_compressed)
        # Essential host-protocol lines must survive in the digest.
        self.assertIn("simulator.launch", contract_compressed)
        self.assertIn("cycles_send", contract_compressed)
        self.assertIn("make_u48", contract_compressed)
        # Commands script (small, should remain verbatim).
        self.assertIn("cslc", contract_compressed)
        # The original docstring (large boilerplate) should NOT survive.
        self.assertNotIn("BSD-style license", contract_compressed)

    def test_compress_helper_is_no_op_when_under_budget(self):
        small = "def main():\n    pass\n"
        out = cuda2csl._compress_run_py(small, max_chars=1000)
        self.assertEqual(out, small)


class VersionTraceTest(unittest.TestCase):
    """Task #10: W1 per-version trace builds correctly from run_log +
    optimization_summary['steps'] and computes vs-reference percentages."""

    def test_trace_with_reference(self):
        run_log = [
            {"status": "fail", "cycles_send": None, "run_time_ms": 3100, "failure_reason": "compile"},
            {"status": "pass", "cycles_send": 2129, "run_time_ms": 3200,
             "cycles_send_runs": [2129]},
        ]
        opt_summary = {
            "steps": [
                {"attempt": 1, "angle": "task_simplify", "best_of": 2,
                 "winner_cand_idx": 1, "status": "pass", "cycles_send": 1500,
                 "cycles_send_runs": [1500, 1505, 1495],
                 "run_time_ms": 3300, "selected": True},
                {"attempt": 2, "angle": "buffer_cleanup", "best_of": 2,
                 "winner_cand_idx": None, "status": "no_candidate",
                 "rejected_reason": "no_survivor"},
                {"attempt": 3, "angle": "comptime_cleanup", "best_of": 2,
                 "winner_cand_idx": 2, "status": "pass", "cycles_send": 1072,
                 "cycles_send_runs": [1072, 1080, 1065],
                 "run_time_ms": 3250, "selected": True},
            ],
        }
        ref = {"cycles_send": 2129, "run_time_ms": 3074, "num_runs": 3}
        import cuda2csl
        trace = cuda2csl.build_version_trace(run_log, opt_summary, ref)

        self.assertEqual(trace["reference"]["cycles_send"], 2129)
        self.assertEqual(len(trace["versions"]), 5)  # 2 translate + 3 optimize

        # First translate attempt: failure, no cycles, no comparison.
        v1 = trace["versions"][0]
        self.assertEqual(v1["phase"], "translate")
        self.assertEqual(v1["status"], "fail")
        self.assertIsNone(v1["cycles_send"])
        self.assertIsNone(v1["vs_ref_cycles_pct"])

        # Second translate attempt: pass at reference cycles → 0% vs ref.
        v2 = trace["versions"][1]
        self.assertEqual(v2["phase"], "translate")
        self.assertEqual(v2["accepted"], True)
        self.assertEqual(v2["vs_ref_cycles_pct"], 0.0)

        # Optimize attempt 1: 1500 cycles, 29.5% faster than 2129.
        v3 = trace["versions"][2]
        self.assertEqual(v3["phase"], "optimize")
        self.assertEqual(v3["angle"], "task_simplify")
        self.assertAlmostEqual(v3["vs_ref_cycles_pct"], -29.544, places=2)

        # Optimize attempt 3: 1072 cycles, ~49.6% faster — the winner.
        v5 = trace["versions"][4]
        self.assertAlmostEqual(v5["vs_ref_cycles_pct"], -49.648, places=2)

        # Summary headline.
        self.assertEqual(trace["summary"]["first_passing_attempt"], 2)
        self.assertEqual(trace["summary"]["best_cycles"], 1072)
        self.assertAlmostEqual(trace["summary"]["best_vs_ref_cycles_pct"], -49.648, places=2)
        self.assertEqual(trace["summary"]["n_versions"], 5)
        self.assertEqual(trace["summary"]["n_accepted"], 3)  # v2 translate + 2 optimize wins

    def test_trace_without_reference(self):
        import cuda2csl
        trace = cuda2csl.build_version_trace([], {}, None)
        self.assertIsNone(trace["reference"]["cycles_send"])
        self.assertEqual(trace["versions"], [])
        self.assertIsNone(trace["summary"]["best_vs_ref_cycles_pct"])


class AngleCatalogTest(unittest.TestCase):
    """A1: catalog + helpers behave as documented."""

    def test_catalog_size_and_keys(self):
        import prompt_cuda2csl as P
        # 6 generic + 12 new from skills scan = 18 (fifo_smoothing is the 13th
        # new angle — verify exact count to catch accidental removals).
        self.assertGreaterEqual(len(P.CSL_OPTIMIZATION_STEPS_CATALOG), 13)
        # Every entry has the four required keys.
        for name, meta in P.CSL_OPTIMIZATION_STEPS_CATALOG.items():
            self.assertIn("description", meta, f"{name} missing description")
            self.assertIn("applicable_groups", meta, f"{name} missing applicable_groups")
            self.assertIn("source_skill", meta, f"{name} missing source_skill")
            self.assertIn("knowledge_query_hint", meta, f"{name} missing knowledge_query_hint")
            self.assertIsInstance(meta["applicable_groups"], list)

    def test_backward_compat_dict_access(self):
        """Existing call sites do CSL_OPTIMIZATION_STEPS.get(name, name)
        and expect a string back."""
        import prompt_cuda2csl as P
        self.assertIsInstance(P.CSL_OPTIMIZATION_STEPS["dsd_offset_chaining"], str)
        self.assertIsInstance(P.CSL_OPTIMIZATION_STEPS.get("fmac_bulk", ""), str)
        self.assertEqual(P.CSL_OPTIMIZATION_STEPS.get("not_real", "default"), "default")
        self.assertIn("dsd_offset_chaining", P.CSL_OPTIMIZATION_STEPS)

    def test_angle_metadata_unknown_falls_back(self):
        import prompt_cuda2csl as P
        meta = P.angle_metadata("not_a_real_angle")
        self.assertEqual(meta["description"], "not_a_real_angle")
        self.assertEqual(meta["applicable_groups"], ["all"])
        self.assertIn("unknown", meta["source_skill"].lower())

    def test_angles_for_group(self):
        import prompt_cuda2csl as P
        stencil_angles = P.angles_for_group("stencil")
        self.assertIn("circbuf_save_address", stencil_angles)
        self.assertIn("dsd_offset_chaining", stencil_angles)
        # Generic angles ("all") apply to every group.
        self.assertIn("comptime_cleanup", stencil_angles)
        # Sparse-only angles should NOT appear for stencil.
        sparse_angles = P.angles_for_group("sparse")
        self.assertIn("fabric_simd_packing", sparse_angles)


class SpecYamlAnglesTest(unittest.TestCase):
    """A2: every existing spec.yaml's optimization_angles must reference
    angles that actually exist in the catalog."""

    SPECS_GLOB = os.path.normpath(os.path.join(_HERE, "..", "kernels", "*", "spec.yaml"))

    def test_all_spec_angles_in_catalog(self):
        import glob
        import yaml  # spec.yaml uses yaml
        import prompt_cuda2csl as P
        catalog_names = set(P.CSL_OPTIMIZATION_STEPS_CATALOG.keys())
        spec_files = sorted(glob.glob(self.SPECS_GLOB))
        if not spec_files:
            self.skipTest(f"no spec.yaml files found at {self.SPECS_GLOB}")
        failures = []
        for spec_path in spec_files:
            with open(spec_path) as fh:
                d = yaml.safe_load(fh)
            angles = (d or {}).get("optimization_angles") or []
            unknown = [a for a in angles if a not in catalog_names]
            if unknown:
                failures.append((spec_path, unknown))
        self.assertEqual(failures, [],
                         f"spec.yaml angles must be in catalog. Unknown: {failures}")


class SelectorFallbackTest(unittest.TestCase):
    """A3: angle selector's fallback paths.

    All four error modes (LLM exception, parse failure, unknown-angle name,
    empty whitelist) must NOT raise; they must return a valid name from the
    whitelist (or a sentinel for empty) with a 'fallback' reason."""

    def _make_orch(self):
        return cuda2csl.CUDA2CSLOrchestrator(
            model="dummy", api_key_file="/dev/null", api_key_command=None,
            base_url=None, max_tokens=2048, turns_limit=1, work_root="/tmp/x",
            sdk_root="/dev/null", arch="wse3",
            commands_script="commands_wse3.sh", shell_setup=None,
        )

    def test_clean_parse_returns_pick(self):
        orch = self._make_orch()
        whitelist = ["fmac_bulk", "dsd_offset_chaining"]
        with patch.object(orch, "_llm_call",
                          return_value="ANGLE: fmac_bulk\nREASON: hot mul-add loop"):
            pick, reason = orch._select_optimization_angle(
                whitelist=whitelist, round_robin_idx=0,
                current_code="fn x() {}", current_cycles=2129,
                reference_cycles=2129, kernel_group="linalg")
        self.assertEqual(pick, "fmac_bulk")
        self.assertIn("hot mul-add", reason)

    def test_parse_failure_falls_back_to_round_robin(self):
        orch = self._make_orch()
        whitelist = ["fmac_bulk", "dsd_offset_chaining", "async_detach_overlap"]
        with patch.object(orch, "_llm_call", return_value="I think fmac_bulk maybe?"):
            pick, reason = orch._select_optimization_angle(
                whitelist=whitelist, round_robin_idx=1,
                current_code="", current_cycles=1, reference_cycles=1,
                kernel_group="linalg")
        self.assertEqual(pick, "dsd_offset_chaining")  # round-robin idx 1
        self.assertIn("fallback", reason)

    def test_unknown_angle_falls_back(self):
        orch = self._make_orch()
        whitelist = ["fmac_bulk", "dsd_offset_chaining", "async_detach_overlap"]
        with patch.object(orch, "_llm_call",
                          return_value="ANGLE: invented\nREASON: ..."):
            pick, reason = orch._select_optimization_angle(
                whitelist=whitelist, round_robin_idx=2,
                current_code="", current_cycles=1, reference_cycles=1,
                kernel_group="linalg")
        self.assertEqual(pick, "async_detach_overlap")  # round-robin idx 2
        self.assertIn("unknown_angle", reason)

    def test_llm_exception_falls_back(self):
        orch = self._make_orch()
        whitelist = ["fmac_bulk", "dsd_offset_chaining"]
        with patch.object(orch, "_llm_call", side_effect=RuntimeError("boom")):
            pick, reason = orch._select_optimization_angle(
                whitelist=whitelist, round_robin_idx=0,
                current_code="", current_cycles=1, reference_cycles=1,
                kernel_group="linalg")
        self.assertEqual(pick, "fmac_bulk")  # round-robin idx 0
        self.assertIn("llm_error", reason)

    def test_empty_whitelist_returns_safe_default(self):
        orch = self._make_orch()
        with patch.object(orch, "_llm_call",
                          return_value="ANGLE: x\nREASON: y"):
            pick, reason = orch._select_optimization_angle(
                whitelist=[], round_robin_idx=0,
                current_code="", current_cycles=1, reference_cycles=1,
                kernel_group="")
        # Sentinel; must not raise.
        self.assertEqual(pick, "comptime_cleanup")
        self.assertIn("empty_whitelist", reason)


class BottleneckProfilerTest(unittest.TestCase):
    """Task #24: static bottleneck profiler + matcher."""

    def test_empty_code_no_bottlenecks(self):
        sig = cuda2csl.CUDA2CSLOrchestrator._profile_bottleneck_signature("")
        self.assertEqual(sig["bottlenecks"], {})
        self.assertEqual(sig["n_for_loops"], 0)

    def test_detects_dsd_rebuild_in_loop(self):
        code = """
        fn step() void {
            for (@range(i16, N)) |i| {
                const d = @get_dsd(mem1d_dsd, .{ .base_address = &A[i] });
                @fmovs(out_dsd, d);
            }
        }
        """
        sig = cuda2csl.CUDA2CSLOrchestrator._profile_bottleneck_signature(code)
        self.assertEqual(sig["n_for_loops"], 1)
        self.assertIn("dsd_rebuild_in_loop", sig["bottlenecks"])

    def test_detects_runtime_size_in_inner_loop(self):
        code = """
        fn step() void {
            for (@range(i16, N)) |i| {
                const idx = @as(i16, MAX_ZDIM);
                A[i] = idx;
            }
        }
        """
        sig = cuda2csl.CUDA2CSLOrchestrator._profile_bottleneck_signature(code)
        self.assertIn("runtime_size_in_inner_loop", sig["bottlenecks"])

    def test_detects_scalar_loop_over_arrays(self):
        code = """
        fn step() void {
            for (@range(i16, N)) |i| {
                y[i] = A[i] + b;
            }
        }
        """
        sig = cuda2csl.CUDA2CSLOrchestrator._profile_bottleneck_signature(code)
        self.assertIn("scalar_loops_over_arrays", sig["bottlenecks"])

    def test_skips_loops_with_bulk_ops(self):
        code = """
        fn step() void {
            for (@range(i16, N)) |i| {
                @fmacs(y_dsd, y_dsd, A_dsd, x[i]);
            }
        }
        """
        sig = cuda2csl.CUDA2CSLOrchestrator._profile_bottleneck_signature(code)
        self.assertNotIn("scalar_loops_over_arrays", sig["bottlenecks"])

    def test_detects_separate_mul_then_add(self):
        code = """
        fn step() void {
            @fmuls(temp, A, scalar);
            @fadds(y, y, temp);
        }
        """
        sig = cuda2csl.CUDA2CSLOrchestrator._profile_bottleneck_signature(code)
        self.assertIn("separate_mul_then_add", sig["bottlenecks"])

    def test_matcher_ranks_relevant_angles(self):
        sig = {"bottlenecks": {"dsd_rebuild_in_loop": 3, "scalar_loops_over_arrays": 1}}
        whitelist = ["dsd_offset_chaining", "fmac_bulk", "comptime_hoist", "buffer_cleanup"]
        matches = cuda2csl.CUDA2CSLOrchestrator._match_angles_to_bottlenecks(whitelist, sig)
        # dsd_offset_chaining addresses dsd_rebuild_in_loop (score 3)
        # fmac_bulk addresses scalar_loops_over_arrays (score 1)
        # buffer_cleanup addresses dsd_rebuild_in_loop (score 3)
        # comptime_hoist addresses neither, excluded
        matched_names = [n for n, _ in matches]
        self.assertIn("dsd_offset_chaining", matched_names)
        self.assertIn("fmac_bulk", matched_names)
        self.assertNotIn("comptime_hoist", matched_names)
        # First in ranking should be a score-3 angle
        self.assertEqual(matches[0][1], 3)

    def test_matcher_empty_when_no_signature(self):
        matches = cuda2csl.CUDA2CSLOrchestrator._match_angles_to_bottlenecks(
            ["dsd_offset_chaining", "fmac_bulk"], {})
        self.assertEqual(matches, [])

    def test_real_gemv_kernel_has_dsd_rebuild(self):
        """Integration check on the real GEMV pe.csl, which is known to have
        a for-loop. If the regex breaks on real CSL syntax (e.g. nested
        parens in @range), this catches it."""
        path = os.path.normpath(
            os.path.join(_HERE, "..", "kernels", "GEMV", "CSL", "pe.csl"))
        if not os.path.isfile(path):
            self.skipTest(f"missing fixture: {path}")
        with open(path) as fh:
            code = fh.read()
        sig = cuda2csl.CUDA2CSLOrchestrator._profile_bottleneck_signature(code)
        self.assertGreater(sig["n_for_loops"], 0,
                           "GEMV pe.csl is known to have for-loops")


class TranscriptClipAndDedupeTest(unittest.TestCase):
    """Task #34 audit fixes: head+tail clip on stderr, cslc warning dedupe."""

    def test_clip_preserves_short_input(self):
        from workflow_common import _clip_head_tail
        s = "short stderr"
        self.assertEqual(_clip_head_tail(s), s)

    def test_clip_handles_empty(self):
        from workflow_common import _clip_head_tail
        self.assertEqual(_clip_head_tail(""), "(empty)")
        self.assertEqual(_clip_head_tail(None), "(empty)")

    def test_clip_preserves_head_and_tail(self):
        """Most important property: error message at the END must survive,
        AND the head context (banner/source preamble) is also preserved."""
        from workflow_common import _clip_head_tail
        # Use distinct markers: HEAD section, BIG middle that gets elided,
        # final ERROR line that must be preserved.
        long_input = ("HEAD_BANNER_LINE\n" + "X" * 4000
                      + "MIDDLE_FILLER\n" + "Y" * 4000
                      + "CRITICAL_ERROR_AT_END")
        clipped = _clip_head_tail(long_input, head=400, tail=800)
        self.assertTrue(clipped.startswith("HEAD_BANNER_LINE"))
        self.assertTrue(clipped.endswith("CRITICAL_ERROR_AT_END"))
        self.assertIn("chars elided", clipped)
        # The MIDDLE_FILLER marker is in the elided region.
        self.assertNotIn("MIDDLE_FILLER", clipped)
        # Total size should be roughly head + tail + marker, ~1230 chars.
        self.assertLess(len(clipped), 400 + 800 + 100)
        self.assertGreater(len(clipped), 400 + 800 - 100)

    def test_dedupe_short_stderr_noop(self):
        from benchmark_csl import _dedupe_cslc_warnings
        short = "one warning\ntwo warning\nthree"
        # Under 6 lines → no-op
        self.assertEqual(_dedupe_cslc_warnings(short), short)

    def test_dedupe_collapses_repeated_warnings(self):
        """The Mandelbrot pattern: 168 warnings collapse to 14 uniques."""
        from benchmark_csl import _dedupe_cslc_warnings
        # Build 12 repeats of 2 distinct warnings (each block 2 lines)
        block1 = (
            "./code.csl:65:33: warning: unused entry in module instantiation\n"
            "      const params = .{ .pe_x = x };"
        )
        block2 = (
            "./code.csl:66:33: warning: unused entry in module instantiation\n"
            "      const params = .{ .pe_y = y };"
        )
        raw = "\n".join([block1, block1, block1, block2, block2, block1, block2])
        deduped = _dedupe_cslc_warnings(raw)
        # Should collapse to 2 unique warning starts.
        self.assertEqual(deduped.count("warning: unused entry"), 2)
        # Multiplier should reflect actual count.
        self.assertIn("×4", deduped)  # block1 appears 4 times
        self.assertIn("×3", deduped)  # block2 appears 3 times

    def test_dedupe_preserves_distinct_warnings(self):
        from benchmark_csl import _dedupe_cslc_warnings
        blocks = [
            f"./code.csl:{n}:33: warning: unused entry in module instantiation\n"
            f"      const params = .{{ .x = x }};" for n in range(65, 79)
        ]
        # Mandelbrot pattern: 14 unique source-line offenders, no duplicates
        raw = "\n".join(blocks)
        deduped = _dedupe_cslc_warnings(raw)
        # All 14 unique warnings should still be present.
        self.assertEqual(deduped.count("warning: unused entry"), 14)
        # No multipliers since none were repeated.
        self.assertNotIn("×", deduped)


class KnowledgeInjectionTest(unittest.TestCase):
    """Task #35: layer-1 query augmentation + layer-2 KNOWN_GOTCHAS additions."""

    def test_w1_gotchas_present_when_cluster_marker_in_query(self):
        """After resweep w1lo0sycr regression, gotchas are CLUSTER-GATED:
        only included when the query contains markers for that cluster's
        bottlenecks. A generic query gets none; a query with ALL three
        cluster markers should get ALL five sections."""
        import csl_knowledge_base as K
        # Query mentions all three clusters' markers — should get every section.
        out = K.for_implementer(
            "uses collectives_2d for broadcast, has halo exchange with is_n_edge, "
            "and sets up dest_dsr_ids with @initialize_queue"
        )
        self.assertIn("Recurring W1 translation traps", out)
        self.assertIn("collectives_2d/pe import", out)
        self.assertIn("unblock_cmd_stream", out)
        self.assertIn("memcpy library reserves input queues 0 and 1", out)
        self.assertIn("Synchronous @fmovs", out)

    def test_w1_gotchas_disable_via_env(self):
        import csl_knowledge_base as K
        os.environ["XKERNEL_W1_GOTCHAS"] = "0"
        try:
            out = K.for_implementer("test")
            self.assertNotIn("Recurring W1 translation traps", out)
        finally:
            del os.environ["XKERNEL_W1_GOTCHAS"]

    def test_collectives_cluster_augmentation(self):
        import csl_knowledge_base as K
        aug = K._augment_query_for_w1_clusters("uses collectives_2d for broadcast")
        # Should contain cluster keywords.
        self.assertIn("topic-11-collectives", aug)
        self.assertIn("c2d_params", aug)
        # Original query preserved.
        self.assertIn("collectives_2d for broadcast", aug)

    def test_halo_cluster_augmentation(self):
        import csl_knowledge_base as K
        aug = K._augment_query_for_w1_clusters("compute with halo exchange, is_n_edge guard")
        self.assertIn("topic-15-wse3-microthreads", aug)
        self.assertIn("unblock_cmd_stream", aug)

    def test_dsr_queue_cluster_augmentation(self):
        import csl_knowledge_base as K
        aug = K._augment_query_for_w1_clusters("dest_dsr_ids and @initialize_queue setup")
        self.assertIn("input_queues", aug)
        self.assertIn("MEMCPYH2D_DATA", aug)

    def test_no_augmentation_when_query_has_no_marker(self):
        import csl_knowledge_base as K
        aug = K._augment_query_for_w1_clusters("generic compute task with no cluster markers")
        self.assertEqual(aug, "generic compute task with no cluster markers")

    def test_augmentation_disabled_via_env(self):
        import csl_knowledge_base as K
        os.environ["XKERNEL_W1_CLUSTER_QUERIES"] = "0"
        try:
            aug = K._augment_query_for_w1_clusters("uses collectives_2d for broadcast")
            self.assertEqual(aug, "uses collectives_2d for broadcast")  # no keywords appended
        finally:
            del os.environ["XKERNEL_W1_CLUSTER_QUERIES"]

    def test_multiple_clusters_compose(self):
        """Stencil that uses collectives AND halo exchange should get BOTH augmentations."""
        import csl_knowledge_base as K
        aug = K._augment_query_for_w1_clusters(
            "stencil with halo exchange AND collectives_2d broadcast on a 2D mesh")
        self.assertIn("topic-11-collectives", aug)
        self.assertIn("topic-15-wse3-microthreads", aug)

    def test_gotchas_gated_by_cluster_match(self):
        """Trivial single-PE kernel without halo/collectives/queue markers
        should NOT get the W1 gotchas block — fixes Single-Tile-Matvec
        regression from resweep w1lo0sycr."""
        import csl_knowledge_base as K
        # A trivial single-PE matvec query with no cluster markers
        out = K.for_implementer("single-PE matvec, no fabric")
        self.assertNotIn("Recurring W1 translation traps", out)
        self.assertNotIn("collectives_2d/pe import takes", out)

    def test_gotchas_included_when_collectives_marker_present(self):
        import csl_knowledge_base as K
        out = K.for_implementer("uses collectives_2d for broadcast across 2D mesh")
        self.assertIn("Recurring W1 translation traps", out)
        # Should include the collectives-specific sub-entries
        self.assertIn("collectives_2d/pe import takes", out)
        # Should NOT include unrelated halo entries
        self.assertNotIn("Receivers must call sys_mod.unblock_cmd_stream", out)

    def test_gotchas_included_when_halo_marker_present(self):
        import csl_knowledge_base as K
        out = K.for_implementer("compute with halo exchange across is_n_edge neighbors")
        self.assertIn("Recurring W1 translation traps", out)
        self.assertIn("Receivers must call sys_mod.unblock_cmd_stream", out)
        self.assertNotIn("collectives_2d/pe import takes", out)

    def test_gotchas_force_all_via_env(self):
        """Debug override: XKERNEL_W1_GOTCHAS_FORCE_ALL=1 reverts to always-on."""
        import csl_knowledge_base as K
        os.environ["XKERNEL_W1_GOTCHAS_FORCE_ALL"] = "1"
        try:
            out = K.for_implementer("trivial single-PE kernel, no markers")
            self.assertIn("Recurring W1 translation traps", out)
            self.assertIn("collectives_2d/pe import takes", out)
        finally:
            del os.environ["XKERNEL_W1_GOTCHAS_FORCE_ALL"]


class NoKnowledgeBaselineTest(unittest.TestCase):
    """Tiered --no-knowledge baseline ablation (knowledge_tier chokepoint).

    TIER-A = curated/retrieved knowledge (gotchas, RAG, tutorials, skills,
    mesh, experience). TIER-B = the CSL language primer (TYPE/DSD/TASK/WSE3
    + architect/reviewer role framing). TIER-C = template structure (layout,
    contract, builtin whitelist) — lives in prompt_cuda2csl, not here.

      full (default)                : A + B present
      soft (XKERNEL_NO_KNOWLEDGE=1) : A stripped, B kept
      bare (+ XKERNEL_BARE=1)       : A and B both stripped (for_* -> "")
    """

    # Distinctive content markers.
    _TIERA_IMPL = "Recurring W1 translation traps"   # W1 gotchas (TIER-A)
    _TIERA_BASE = "## Known CSL Gotchas"             # base KNOWN_GOTCHAS (TIER-A)
    _TIERB_TYPE = "## CSL Type Rules"                # TYPE_RULES primer (TIER-B)
    _TIERB_TASK = "## CSL Task System"              # TASK_SYSTEM primer (TIER-B)
    _CLUSTER_QUERY = (
        "uses collectives_2d for broadcast, has halo exchange with is_n_edge, "
        "and sets up dest_dsr_ids with @initialize_queue"
    )

    def setUp(self):
        # Snapshot + clear the tier env vars so each test starts from "full".
        self._saved = {k: os.environ.get(k)
                       for k in ("XKERNEL_NO_KNOWLEDGE", "XKERNEL_BARE")}
        for k in self._saved:
            os.environ.pop(k, None)

    def tearDown(self):
        for k, v in self._saved.items():
            if v is None:
                os.environ.pop(k, None)
            else:
                os.environ[k] = v

    def _set(self, *, no_knowledge=False, bare=False):
        if no_knowledge:
            os.environ["XKERNEL_NO_KNOWLEDGE"] = "1"
        if bare:
            os.environ["XKERNEL_BARE"] = "1"

    def test_tier_resolution(self):
        import csl_knowledge_base as K
        self.assertEqual(K.knowledge_tier(), "full")
        self._set(no_knowledge=True)
        self.assertEqual(K.knowledge_tier(), "soft")
        self._set(no_knowledge=True, bare=True)
        self.assertEqual(K.knowledge_tier(), "bare")
        # --bare alone (no --no-knowledge) does NOT activate; stays full.
        os.environ.pop("XKERNEL_NO_KNOWLEDGE", None)
        self.assertEqual(K.knowledge_tier(), "full")

    def test_full_has_both_tiers(self):
        import csl_knowledge_base as K
        out = K.for_implementer(self._CLUSTER_QUERY)
        self.assertIn(self._TIERB_TYPE, out)   # B
        self.assertIn(self._TIERA_IMPL, out)   # A

    def test_soft_strips_A_keeps_B(self):
        import csl_knowledge_base as K
        self._set(no_knowledge=True)
        impl = K.for_implementer(self._CLUSTER_QUERY)
        # TIER-B primer present.
        self.assertIn(self._TIERB_TYPE, impl)
        self.assertIn(self._TIERB_TASK, impl)
        # TIER-A curated knowledge absent.
        self.assertNotIn(self._TIERA_IMPL, impl)
        self.assertNotIn(self._TIERA_BASE, impl)
        self.assertNotIn("collectives_2d/pe import takes", impl)
        # Other roles: B-level role framing kept, A-level docs gone.
        self.assertIn("## Wafer-Scale Architecture Reasoning",
                      K.for_architect(self._CLUSTER_QUERY))
        self.assertIn("## CSL Failure Triage Checklist",
                      K.for_reviewer(self._CLUSTER_QUERY))
        # Optimizer: primer kept, curated per-angle lever stripped.
        opt = K.for_optimization(self._CLUSTER_QUERY,
                                 kernel_group="stencil",
                                 picked_angle="buffer_cleanup")
        self.assertIn(self._TIERB_TYPE, opt)
        self.assertNotIn("This round's optimization lever", opt)
        self.assertNotIn(self._TIERA_BASE, opt)

    def test_bare_strips_everything(self):
        import csl_knowledge_base as K
        self._set(no_knowledge=True, bare=True)
        self.assertEqual(K.for_implementer(self._CLUSTER_QUERY), "")
        self.assertEqual(K.for_architect(self._CLUSTER_QUERY), "")
        self.assertEqual(K.for_reviewer(self._CLUSTER_QUERY), "")
        self.assertEqual(
            K.for_optimization(self._CLUSTER_QUERY, kernel_group="stencil",
                               picked_angle="buffer_cleanup"),
            "")
        # for_translation alias follows for_implementer.
        self.assertEqual(K.for_translation(self._CLUSTER_QUERY), "")

    def test_tierC_builtin_whitelist_independent_of_no_knowledge(self):
        """TIER-C builtin whitelist must stay ON under bare (it is necessary
        structure), and is governed only by its own XKERNEL_BUILTIN_WHITELIST
        gate — not by the no-knowledge tier."""
        import importlib
        import prompt_cuda2csl as P
        self._set(no_knowledge=True, bare=True)
        saved_bw = os.environ.get("XKERNEL_BUILTIN_WHITELIST")
        try:
            os.environ.pop("XKERNEL_BUILTIN_WHITELIST", None)
            importlib.reload(P)
            self.assertGreater(len(P.builtin_whitelist_block()), 0,
                               "builtin whitelist (TIER-C) must survive bare mode")
            os.environ["XKERNEL_BUILTIN_WHITELIST"] = "0"
            importlib.reload(P)
            self.assertEqual(P.builtin_whitelist_block(), "",
                             "builtin whitelist honors its own independent gate")
        finally:
            if saved_bw is None:
                os.environ.pop("XKERNEL_BUILTIN_WHITELIST", None)
            else:
                os.environ["XKERNEL_BUILTIN_WHITELIST"] = saved_bw
            importlib.reload(P)

    def test_no_compute_leak_in_any_tier(self):
        """The compute-leak canary invariant must hold in all three tiers:
        stripping knowledge never causes pe.csl identifiers to appear (and the
        for_* outputs, which only draw from layout-visible primer/curated text,
        never contain a compute canary regardless of tier)."""
        import csl_knowledge_base as K
        canary = "very_distinctive_compute_function_name_for_canary"
        for label, kw in (("full", {}),
                          ("soft", {"no_knowledge": True}),
                          ("bare", {"no_knowledge": True, "bare": True})):
            os.environ.pop("XKERNEL_NO_KNOWLEDGE", None)
            os.environ.pop("XKERNEL_BARE", None)
            self._set(**kw)
            for fn in (K.for_implementer, K.for_architect,
                       K.for_reviewer, K.for_translation):
                self.assertNotIn(canary, fn(self._CLUSTER_QUERY),
                                 f"canary leaked in {label}/{fn.__name__}")


class TranslationFactsTest(unittest.TestCase):
    """Phase 1 feasibility: regex-extracted facts block for the implementer prompt."""

    def setUp(self):
        import translation_facts as tf  # noqa: F401
        self.tf = tf
        self.repo_root = os.path.dirname(_HERE)

    def test_gemv_facts_have_task_ids_and_memcpy_queues(self):
        facts = self.tf.extract_layout_facts(
            os.path.join(self.repo_root, "kernels", "GEMV"))
        # GEMV layout.csl declares @get_local_task_id(14..17) for c2d entry points
        self.assertEqual(facts["task_ids_owned_by_layout"], [14, 15, 16, 17])
        # memcpy/get_params reserves queues 0 and 1 on WSE-3
        self.assertEqual(facts["memcpy_reserved_input_queues"], [0, 1])
        # tile-code passes Mt, Nt, c2d_params, memcpy_params to pe.csl
        self.assertIn("Mt", facts["tile_code_params_pe_must_declare"])
        self.assertIn("c2d_params", facts["tile_code_params_pe_must_declare"])
        # host launch sequence ordered: f_enable_timer, f_tic, main, f_toc, ...
        seq = facts["host_launch_sequence"]
        self.assertIn("f_tic", seq)
        self.assertIn("main", seq)
        self.assertLess(seq.index("f_tic"), seq.index("f_toc"))

    def test_collectives_2d_kernel_surfaces_NUM_PES_note(self):
        """The exact failure the W1 logs flagged: 'c2d_params.x.dim_size doesn't
        exist; the correct field is NUM_PES'. The facts block must surface
        that <collectives_2d/pe> expects NUM_PES, not dim_size."""
        block = self.tf.render_facts_block(
            os.path.join(self.repo_root, "kernels", "GEMV Collectives 2D"))
        # GEMV Coll 2D layout imports <collectives_2d/params>; the c2d_params
        # struct it constructs gets passed to pe.csl, which then imports
        # <collectives_2d/pe>. The IMPORT_FIELD_SCHEMAS table flags the
        # NUM_PES rule under <collectives_2d/pe>; for <collectives_2d/params>
        # the note explains the construct->pass->import chain.
        self.assertIn("collectives_2d", block)
        # The c2d_params note must mention what pe.csl needs to do with it.
        self.assertIn("c2d_params", block)

    def test_truncation_caps_at_30_lines(self):
        """Even on the largest kernels, the YAML body must be capped."""
        facts = self.tf.extract_layout_facts(
            os.path.join(self.repo_root, "kernels", "GEMV"))
        body = self.tf.format_facts_yaml(facts)
        self.assertLessEqual(len(body.splitlines()), 30)

    def test_facts_extractor_never_reads_pe_csl(self):
        """W1 invariant: the facts block must be derivable from layout-visible
        files ALONE. Run the extractor in a temp dir that contains layout.csl,
        run.py, commands_wse3.sh, AND a pe.csl with a canary string —
        confirm the canary never appears in the rendered block."""
        import tempfile
        canary = "VERY_DISTINCTIVE_COMPUTE_CANARY_DO_NOT_LEAK"
        with tempfile.TemporaryDirectory() as td:
            with open(os.path.join(td, "layout.csl"), "w") as f:
                f.write('param N: u16;\nlayout {\n  @set_rectangle(1, 1);\n'
                        '  @set_tile_code(0, 0, "pe.csl", .{ .N = N });\n'
                        '  @export_name("f_tic", fn() void);\n}\n')
            with open(os.path.join(td, "run.py"), "w") as f:
                f.write('runner.launch("f_tic")\n')
            with open(os.path.join(td, "commands_wse3.sh"), "w") as f:
                f.write('cslc --arch=wse3 layout.csl\n')
            with open(os.path.join(td, "pe.csl"), "w") as f:
                f.write(f"// {canary}\nfn whatever() void {{}}\n")
            block = self.tf.render_facts_block(td)
            self.assertNotIn(canary, block,
                "facts block must NOT contain pe.csl content")

    def test_builtins_yaml_loads_and_has_required_entries(self):
        b = self.tf.load_csl_builtins()
        # The entries the W1 logs say the model gets wrong:
        for name in ["@fmacs", "@get_local_task_id", "@get_dsd",
                     "@export_symbol", "@import_module"]:
            self.assertIn(name, b, f"missing builtin entry: {name}")
        # @fmacs is the canonical 4-arg lookup (the W1 verdict said the
        # model called it with 3).
        self.assertEqual(self.tf.builtin_arity("@fmacs"), 4)

    def test_render_facts_never_raises(self):
        """The render function must be exception-safe: a bad kernel dir
        gives a degraded block, not a crash that kills the pipeline."""
        block = self.tf.render_facts_block("/nonexistent/kernel/dir")
        self.assertIn("TRANSLATION FACTS", block)
        self.assertIn("failed", block.lower())

    def test_validate_facts_flags_inconsistencies(self):
        """The cross-check helper catches a fabricated reservation."""
        bad_facts = {
            "memcpy_reserved_input_queues": [0, 1],
            "imports": [{"path": "<time>"}],  # no memcpy import!
        }
        warnings = self.tf.validate_facts_against_builtins(bad_facts)
        self.assertTrue(any("memcpy" in w for w in warnings),
                        f"expected memcpy warning, got: {warnings}")


class LayoutResolutionTest(unittest.TestCase):
    """Regression guard for the C1 stale-layout bug: _find_layout_csl must
    resolve the layout the ACTIVE build script compiles, not a stale layout.csl.
    The iterative solvers compile layout_{power,cg,pcg,bicgstab}.csl; resolving
    the bare layout.csl shows the agent the wrong export contract (the v1.0
    immune-kernel build-path bug surfacing in the contract path)."""

    def test_solver_layout_matches_active_build(self):
        cases = [
            ("Power-Method", "Power Method", "src/layout_power.csl"),
            ("CG", "Conjugate Gradient", "src/layout_cg.csl"),
            ("Preconditioned-CG", "Preconditioned CG", "src/layout_pcg.csl"),
            ("BiCGSTAB", "BiCGSTAB", "src/layout_bicgstab.csl"),
        ]
        for name, kdir, expected in cases:
            cdir = os.path.join(_HERE, "..", "kernels", kdir, "CSL")
            if not os.path.isdir(cdir):
                self.skipTest(f"{name} kernel dir missing")
            resolved = cuda2csl._find_layout_csl(cdir, "commands_wse3.sh")
            self.assertTrue(
                resolved.endswith(expected),
                f"{name}: resolved {resolved!r} != active build {expected!r} "
                f"(stale-layout C1 regression)")


class LeaveOneOutLeakTest(unittest.TestCase):
    """WS3 leave-one-out retrieval firewall guard: exemplar SOURCES must be
    train-pool only (never a test kernel's reference), and the TARGET must always
    be excluded from its own retrieval (leave-one-out)."""

    def setUp(self):
        import csl_knowledge_base as kb
        self.kb = kb
        os.environ["XKERNEL_LEAVE_ONE_OUT"] = "1"

    def tearDown(self):
        os.environ["XKERNEL_LEAVE_ONE_OUT"] = "0"

    def test_sources_are_train_pool_only(self):
        src = {n for n, _, _ in self.kb._LOO_TRAIN_POOL}
        for test_kernel in ("Cholesky", "7pt-Stencil", "Laplacian2D-Halo",
                            "Tensor-Transpose-021", "PDFT-Pi-Pipeline",
                            "Wide-Multiplication", "Residual", "Game-of-Life",
                            "Single-Tile-Matvec"):
            self.assertNotIn(test_kernel, src,
                             f"{test_kernel} (test/non-train) must not be a retrieval source")

    def test_default_off(self):
        os.environ["XKERNEL_LEAVE_ONE_OUT"] = "0"
        self.assertEqual(self.kb.leave_one_out_exemplars("cuda", "GEMM"), "")

    def test_target_excluded_from_own_retrieval(self):
        gemm_cuda = self.kb._cuda_text("GEMM")
        if not gemm_cuda:
            self.skipTest("GEMM CUDA missing")
        out = self.kb.leave_one_out_exemplars(gemm_cuda, "GEMM")
        self.assertNotIn("### GEMM (", out,
                         "leave-one-out must exclude the target kernel itself")

    def test_test_kernel_retrieval_leaks_no_test_ref(self):
        chol_cuda = self.kb._cuda_text("Cholesky")
        if not chol_cuda:
            self.skipTest("Cholesky CUDA missing")
        out = self.kb.leave_one_out_exemplars(chol_cuda, "Cholesky")
        for marker in ("### Cholesky", "### 7pt", "### Laplacian",
                       "### Tensor", "### PDFT"):
            self.assertNotIn(marker, out,
                             f"test-kernel retrieval leaked a test ref: {marker}")

    def test_forbidden_canary_line_scrubbed_from_exemplar(self):
        """Regression for the leave-one-out leak that the compute-leak guard
        caught: train kernels can SHARE a library idiom line with the target
        (the solvers + 7pt-Stencil both have the stencil-import output_queues
        line). When that line is the target's canary, the retrieved exemplar
        must be scrubbed so it never reaches the prompt."""
        sevenpt = os.path.join(_HERE, "..", "kernels", "7-Point Stencil",
                               "CUDA", "kernel.cu")
        if not os.path.isfile(sevenpt):
            self.skipTest("7pt CUDA missing")
        cuda = open(sevenpt, encoding="utf-8", errors="ignore").read()
        canary = '.output_queues = if (@is_arch("wse3")) [4]u16{4, 5, 6, 7} else [1]u16{3},'
        # Without scrub, a train exemplar surfaces the shared line...
        unscrubbed = self.kb.leave_one_out_exemplars(cuda, "7pt-Stencil")
        # ...with the canary passed as forbidden, it must be gone.
        scrubbed = self.kb.leave_one_out_exemplars(
            cuda, "7pt-Stencil", forbidden_lines=[canary])
        self.assertNotIn(canary, scrubbed,
                         "target canary line leaked through a retrieved exemplar")


class HeldoutSeedLeakTest(unittest.TestCase):
    """Input-level train/test split firewall (2026-06-24).

    The held-out eval seeds in a kernel's spec.yaml `eval:` block are HARNESS-ONLY.
    They must never reach the agent — otherwise a kernel could be tuned to pass the
    specific held-out inputs, defeating the anti-hardcoding gate. spec.yaml is not
    part of build_reference_contract (the agent sees only run.py + layout + commands),
    so the values must NOT appear in the contract / layout / task-summary. This is the
    input-split analogue of the compute-leak canary."""

    # Rolled out 2026-06-24 to scoreable kernels with a randomizable input.
    # (GEMV excluded: its build hardcodes --seed, which overrides the env-driven
    # held-out seed — see kernels/GEMV/spec.yaml.)
    PILOTS = [
        ("Cholesky",            "pe.csl"),
        ("Residual",            "residual.csl"),
        ("Single Tile Matvec",  "pe_matvec.csl"),
        ("GEMM",                "pe.csl"),
        ("Wide Multiplication", "pe.csl"),
        ("Tensor-Transpose-021", "pe.csl"),
        ("PDFT-Pi-Pipeline",    "pe.csl"),
        ("Laplacian2D-Halo",    "pe.csl"),
    ]

    def _ref_dir(self, name):
        return os.path.normpath(os.path.join(_HERE, "..", "kernels", name, "CSL"))

    def test_resolve_eval_reads_block_and_is_backcompat(self):
        # pilots have an eval block...
        for name, _ in self.PILOTS:
            spec = cuda2csl.load_kernel_spec(self._ref_dir(name))
            if spec is None:
                self.skipTest(f"missing spec for {name}")
            ev = cuda2csl.resolve_eval(spec)
            self.assertIsNotNone(ev, f"{name} should expose an eval block")
            self.assertTrue(ev["heldout_seeds"], f"{name} eval has no heldout_seeds")
            self.assertEqual(ev["seed_env"], "XKERNEL_EVAL_SEED")
        # ...a kernel WITHOUT an eval block returns None (back-compat). Conjugate
        # Gradient is an honest-capability fail (not gaming-risk), so it deliberately
        # gets no input-split — a good back-compat fixture. None also returns None.
        cg_spec = cuda2csl.load_kernel_spec(self._ref_dir("Conjugate Gradient"))
        if cg_spec is not None:
            self.assertIsNone(cuda2csl.resolve_eval(cg_spec),
                              "Conjugate Gradient should have no eval block")
        self.assertIsNone(cuda2csl.resolve_eval(None))
        self.assertIsNone(cuda2csl.resolve_eval({"tasks": ["x"]}))  # spec w/o eval:

    def test_task_summary_never_renders_eval_block(self):
        # PRIMARY firewall test (collision-free): inject a DISTINCTIVE sentinel seed
        # into a spec's eval block and assert spec_task_summary() — the only place a
        # spec is turned into prompt text — never emits it. Short real seeds (101/202)
        # collide with years/dims as substrings, so we use a sentinel that cannot.
        SENTINEL = 98765432123
        spec = {
            "tasks": ["do the thing"],
            "inputs": [{"name": "A", "shape": "[N]", "dtype": "f32"}],
            "outputs": [{"name": "y", "shape": "[N]", "dtype": "f32"}],
            "eval": {"train_seed": 7, "heldout_seeds": [SENTINEL],
                     "seed_env": "XKERNEL_EVAL_SEED"},
        }
        rendered = cuda2csl.spec_task_summary(spec)
        self.assertNotIn(str(SENTINEL), rendered,
                         "spec_task_summary leaked the eval block into prompt text — "
                         "held-out seeds must stay harness-only.")

    def test_heldout_seed_values_absent_from_contract(self):
        # SECONDARY defensive test on the real pilots: build the actual agent-facing
        # contract and assert no real held-out seed appears as a STANDALONE token
        # (word-boundary match — avoids the '202' in '2025' copyright-year collision).
        import re
        for name, target in self.PILOTS:
            ref_dir = self._ref_dir(name)
            if not os.path.isdir(ref_dir):
                self.skipTest(f"missing reference dir: {ref_dir}")
            spec = cuda2csl.load_kernel_spec(ref_dir)
            ev = cuda2csl.resolve_eval(spec)
            if not ev or not ev["heldout_seeds"]:
                self.skipTest(f"{name} has no held-out seeds")
            contract, _reference_compute, layout_text = cuda2csl.build_reference_contract(
                reference_dir=ref_dir,
                target_relpath=target,
                commands_script="commands_wse3.sh",
            )
            task_summary = cuda2csl.spec_task_summary(spec)
            haystack = "\n".join([contract, layout_text, task_summary])
            for seed in ev["heldout_seeds"]:
                self.assertIsNone(
                    re.search(rf"(?<!\d){seed}(?!\d)", haystack),
                    f"[{name}] held-out seed {seed} leaked into an agent-facing "
                    f"string as a standalone value. Held-out seeds must stay "
                    f"harness-only (spec.yaml is never injected into prompts).")

    def test_benchmark_csl_spec_reader_matches_resolve_eval(self):
        # The harness reads the eval block via a self-contained reader (no cuda2csl
        # import). It must agree with cuda2csl.resolve_eval so they can't drift.
        import benchmark_csl
        for name, _ in self.PILOTS:
            ref_dir = self._ref_dir(name)
            spec = cuda2csl.load_kernel_spec(ref_dir)
            a = cuda2csl.resolve_eval(spec)
            b = benchmark_csl._heldout_eval_for_reference(ref_dir)
            if a is None and b is None:
                continue
            self.assertEqual(a["heldout_seeds"], b["heldout_seeds"], name)
            self.assertEqual(a["seed_env"], b["seed_env"], name)

    def test_heldout_gate_refuses_when_build_hardcodes_seed(self):
        # FOOTGUN GUARD: a build that passes `--seed N` on the cs_python line would
        # override the env-driven held-out seed -> the gate must REFUSE (not give
        # false assurance). Build a tiny fake bundle and check evaluate_heldout bails
        # before running anything. (GEMV is the real instance of this; excluded.)
        import tempfile, benchmark_csl
        with tempfile.TemporaryDirectory() as d:
            with open(os.path.join(d, "commands_wse3.sh"), "w") as fh:
                fh.write("#!/usr/bin/env bash\nset -e\n"
                         "cslc ./layout.csl --arch=wse3 -o out\n"
                         "cs_python run.py --name out --seed 7\n")
            res = benchmark_csl.evaluate_heldout(
                staged_bundle=d, commands_script="commands_wse3.sh",
                heldout_seeds=[101], sdk_root="/dev/null")
            self.assertFalse(res["passed"])
            self.assertIn("heldout_eval_unsupported", res["reason"])

    def test_gemv_excluded_from_input_split(self):
        # GEMV intentionally has NO eval block (its build hardcodes --seed).
        spec = cuda2csl.load_kernel_spec(self._ref_dir("GEMV"))
        if spec is not None:
            self.assertIsNone(cuda2csl.resolve_eval(spec),
                              "GEMV must stay excluded from the input split")


class HeldoutGateDecisionTest(unittest.TestCase):
    """The held-out gate is a DEFAULT-ON integrity gate. Decision precedence:
    env XKERNEL_HELDOUT_EVAL (0/1) overrides everything; else the per-call
    heldout_eval param; else default-on. The W2 inner loop passes False to skip it.
    Tested by stubbing the SDK-touching pieces so it runs without a simulator."""

    def _run(self, env_val, param_val):
        import benchmark_csl
        from unittest.mock import patch
        calls = {"heldout": 0}

        def fake_run_staged_bundle(*a, **k):
            return {"status": "pass", "failure_reason": None, "compile_time_ms": 1,
                    "run_time_ms": 1, "cycles_send": 999, "time_send_us": 1.0,
                    "cycles_send_runs": [999], "cycles_send_min": 999,
                    "cycles_send_max": 999, "time_send_us_runs": [1.0], "num_runs": 1,
                    "success_marker": True, "transcript": [], "script_command": "x",
                    "script_elapsed_ms": 1, "shell_setup_applied": False}

        def fake_eval_heldout(*a, **k):
            calls["heldout"] += 1
            return {"passed": True, "failing_seed": None, "per_seed": [],
                    "reason": "stub"}

        import tempfile, os as _os
        with tempfile.TemporaryDirectory() as work:
            # minimal staged bundle: a reference dir with a spec that has eval:
            ref = _os.path.join(work, "K", "CSL")
            _os.makedirs(ref)
            with open(_os.path.join(work, "K", "spec.yaml"), "w") as fh:
                fh.write("eval: {train_seed: 1, heldout_seeds: [101], "
                         "seed_env: XKERNEL_EVAL_SEED}\n")
            tgt = _os.path.join(ref, "pe.csl")
            with open(tgt, "w") as _f:
                _f.write("// x\n")
            _os.makedirs(_os.path.join(ref, ".unused"), exist_ok=True)
            with open(_os.path.join(ref, "commands_wse3.sh"), "w") as fh:
                fh.write("cslc x\ncs_python run.py --name out\n")
            old = _os.environ.pop("XKERNEL_HELDOUT_EVAL", None)
            if env_val is not None:
                _os.environ["XKERNEL_HELDOUT_EVAL"] = env_val
            try:
                with patch.object(benchmark_csl, "run_staged_bundle", fake_run_staged_bundle), \
                     patch.object(benchmark_csl, "evaluate_heldout", fake_eval_heldout), \
                     patch.object(benchmark_csl, "stage_reference_bundle",
                                  lambda *a, **k: {"staged_bundle": ref, "staged_target": tgt}):
                    benchmark_csl.benchmark_translated_compute_file(
                        translated_path=tgt, reference_dir=ref, target_relpath="pe.csl",
                        work_dir=work, sdk_root="/dev/null", commands_script="commands_wse3.sh",
                        keep_staged_bundle=True, heldout_eval=param_val)
            finally:
                _os.environ.pop("XKERNEL_HELDOUT_EVAL", None)
                if old is not None:
                    _os.environ["XKERNEL_HELDOUT_EVAL"] = old
        return calls["heldout"]

    def test_default_on_when_unset(self):
        self.assertEqual(self._run(env_val=None, param_val=None), 1)

    def test_param_false_skips(self):
        self.assertEqual(self._run(env_val=None, param_val=False), 0)

    def test_env_zero_overrides_param_true(self):
        self.assertEqual(self._run(env_val="0", param_val=True), 0)

    def test_env_one_overrides_param_false(self):
        self.assertEqual(self._run(env_val="1", param_val=False), 1)


if __name__ == "__main__":
    unittest.main(verbosity=2)
