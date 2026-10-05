"""The optimizer checks the frozen-function contract against the program it STARTS from.

2026-09-21: every candidate of the multi-PE sparse tasks (75 across five sweeps) was
rejected because the contract compared template-route start programs (f_tic/f_toc
called on device) with the reference's device_internal_v2 helpers, and the splice
imported the reference's f_tic body -- with its buffer names -- so even the identity
edit failed to compile. No SDK, no LLM: the benchmark and the model are faked."""
import os
import tempfile
import unittest
from unittest import mock

import cuda2csl

START = """
const timestamp = @import_module("<time>");
param P: u16;
var tsc_start_buf = @zeros([3]u16); var tsc_end_buf = @zeros([3]u16);
var y = @zeros([64]f32);
fn spmv() void { do_work(); }
fn compute() void { spmv(); }
fn f_enable_timer() void { timestamp.enable_tsc(); sys_mod.unblock_cmd_stream(); }
fn f_tic() void { timestamp.get_timestamp(&tsc_start_buf); }
fn f_toc() void { timestamp.get_timestamp(&tsc_end_buf); timestamp.disable_tsc(); }
fn f_memcpy_timestamps() void { time_buf_u16[0] = tsc_start_buf[0]; sys_mod.unblock_cmd_stream(); }
fn main() void {
  f_tic();
  compute();
  f_toc();
  @activate(EXIT);
}
task f_exit() void {
  sys_mod.unblock_cmd_stream();
}
comptime {
  @bind_local_task(f_exit, EXIT);
  @export_symbol(main); @export_symbol(f_enable_timer); @export_symbol(f_memcpy_timestamps);
  @export_symbol(f_tic); @export_symbol(f_toc);
}
"""

REFERENCE = """
const timestamp = @import_module("<time>");
param P: u16;
var tscStartBuffer = @zeros([3]u16); var tscEndBuffer = @zeros([3]u16);
var tsc_window_open: bool = false;
fn f_tic_dev() void {
  if (!tsc_window_open) { tsc_window_open = true; timestamp.get_timestamp(&tscStartBuffer); }
}
fn f_toc_dev() void { timestamp.get_timestamp(&tscEndBuffer); }
fn main() void {
  f_tic_dev();
  reference_work();
}
task f_exit() void {
  f_toc_dev();
  sys_mod.unblock_cmd_stream();
}
fn f_tic() void { timestamp.get_timestamp(&tscStartBuffer); sys_mod.unblock_cmd_stream(); }
fn f_toc() void { timestamp.get_timestamp(&tscEndBuffer); sys_mod.unblock_cmd_stream(); }
fn f_memcpy_timestamps() void { time_buf_u16[0] = tscStartBuffer[0]; sys_mod.unblock_cmd_stream(); }
comptime { @export_symbol(main); @export_symbol(f_tic); @export_symbol(f_toc); }
"""

SPEC = {"frozen_functions": ["f_tic_dev", "f_toc_dev", "f_enable_timer", "f_memcpy_timestamps", "f_tic", "f_toc"],
        "frozen_params": ["P"], "optimization_angles": ["comptime_hoist"]}


def _orchestrator(start_code):
    o = cuda2csl.CUDA2CSLOrchestrator.__new__(cuda2csl.CUDA2CSLOrchestrator)
    o.max_tokens = 2048
    o.current_code = start_code
    o.optimize_num_runs = 1
    o.profile_feedback_enabled = False
    o.keep_candidates = False
    o.retained_candidates = []
    o.profile_log = None
    o.model_guided = False
    o.model_angles = False
    o.sparse_angles = False
    o.best_of = 1
    o.latest_profiler_feedback = None
    o._compute_canary = None
    o._compute_canary_kernel = None
    o._w2_disarm_compute_canary = True
    o.codesign_layout = False
    return o


class OptimizerContractReferenceTest(unittest.TestCase):
    def _run(self, candidate, bench_cycles=900):
        o = _orchestrator(START)
        benched = []

        def fake_bench(**kw):
            benched.append(kw["current_code"])
            return {"status": "pass", "cycles_send": bench_cycles, "cycles_send_runs": [bench_cycles],
                    "success_marker": True, "heldout_eval": {"passed": True}}

        o._benchmark_current_code = fake_bench
        o._llm_call = lambda messages, **kw: "```csl\n" + candidate + "\n```"
        o._select_optimization_angle = lambda *a, **kw: ("comptime_hoist", "test")
        baseline = {"status": "pass", "cycles_send": 1000, "cycles_send_runs": [1000], "success_marker": True}
        with tempfile.TemporaryDirectory() as d, mock.patch.dict(os.environ, {"XKERNEL_SPLICE_FROZEN": "1"}):
            with open(os.path.join(d, "pe.csl"), "w") as fh:
                fh.write(REFERENCE)
            code, result, summary = o.optimize(
                kernel_name="SpMV-RowBlock", reference_dir=d, target_relpath="pe.csl", reference_contract="",
                reference_compute_file=REFERENCE, baseline_result=baseline, requested_steps=["comptime_hoist"],
                min_attempts=1, max_attempts=1, kernel_spec=SPEC)
        return code, summary, benched

    def test_valid_candidate_is_benchmarked_and_accepted(self):
        candidate = START.replace("fn spmv() void { do_work(); }", "fn spmv() void { do_work_faster(); }")
        code, summary, benched = self._run(candidate)
        self.assertEqual(summary["contract"]["reference"], "start_program")
        cand = summary["steps"][0]["candidates"][0]
        self.assertIsNone(cand["contract_violation"], cand["contract_violation"])
        self.assertGreaterEqual(len(benched), 1)                # the candidate reached the benchmark
        self.assertNotIn("tscStartBuffer", benched[0])          # the splice did not import the reference's names
        self.assertIn("do_work_faster", benched[0])
        self.assertEqual(summary["final_cycles_send"], 900)
        self.assertIn("do_work_faster", code)

    def test_window_gaming_is_still_rejected(self):
        candidate = START.replace("fn main() void {\n  f_tic();\n  compute();", "fn main() void {\n  compute();\n  f_tic();")
        code, summary, benched = self._run(candidate)
        cand = summary["steps"][0]["candidates"][0]
        self.assertIn("must start with f_tic", cand["contract_violation"])
        self.assertEqual(summary["final_cycles_send"], 1000)   # not accepted
        self.assertNotIn("compute();\n  f_tic();", code)


if __name__ == "__main__":
    unittest.main()


class CompiledNoopAndWhitelistTests(unittest.TestCase):
    """2026-09-28: a candidate the compiler folded to the same code is reported as such to the next
    selector prompt (arm O1N), and an env whitelist replaces the angle list (arm O2)."""

    IR = {"disasm": {"records_target": 60, "mnemonics": {"add16": 10, "fmuls": 2, "jmp": 5}}}

    def _run(self, env, candidate_cycles, candidate_ir):
        o = _orchestrator(START)
        prompts = []

        def fake_bench(**kw):
            code = kw["current_code"]
            if "do_work_faster" in code:
                return {"status": "pass", "cycles_send": candidate_cycles, "cycles_send_runs": [candidate_cycles],
                        "success_marker": True, "ir_readout": candidate_ir}
            return {"status": "pass", "cycles_send": 1000, "cycles_send_runs": [1000], "success_marker": True, "ir_readout": self.IR}

        def fake_llm(messages, **kw):
            prompts.append(messages[-1]["content"] if isinstance(messages, list) else str(messages))
            return "```csl\n" + START.replace("fn spmv() void { do_work(); }", "fn spmv() void { do_work_faster(); }") + "\n```"

        o._benchmark_current_code = fake_bench
        o._llm_call = fake_llm
        o._select_optimization_angle = lambda *a, **kw: ("comptime_hoist", "test")
        baseline = {"status": "pass", "cycles_send": 1000, "cycles_send_runs": [1000], "success_marker": True, "ir_readout": self.IR}
        with tempfile.TemporaryDirectory() as d, mock.patch.dict(os.environ, {"XKERNEL_SPLICE_FROZEN": "1", **env}):
            with open(os.path.join(d, "pe.csl"), "w") as fh:
                fh.write(REFERENCE)
            code, result, summary = o.optimize(
                kernel_name="SpMV-RowBlock", reference_dir=d, target_relpath="pe.csl", reference_contract="",
                reference_compute_file=REFERENCE, baseline_result=baseline, requested_steps=["comptime_hoist"],
                min_attempts=2, max_attempts=2, kernel_spec=SPEC)
        return summary, prompts

    def test_noop_is_detected_and_reported_in_full_when_the_gate_is_on(self):
        summary, prompts = self._run({"XKERNEL_NOOP_FEEDBACK": "1"}, 1000, self.IR)
        step = summary["steps"][0]
        self.assertTrue(step["candidates"][0]["compiled_noop"])
        self.assertTrue(step.get("compiled_noop"))
        self.assertTrue(step["rejected_reason"].startswith("compiled_noop"))
        self.assertTrue(any("SAME instruction stream" in p for p in prompts[1:]), "the second attempt's prompt must carry the full reason")

    def test_noop_recorded_but_not_worded_when_the_gate_is_off(self):
        summary, prompts = self._run({}, 1000, self.IR)
        step = summary["steps"][0]
        self.assertTrue(step["candidates"][0]["compiled_noop"])
        self.assertTrue(step["rejected_reason"].startswith("cycles 1000 >= best 1000"))
        self.assertFalse(any("SAME instruction stream" in p for p in prompts))

    def test_different_code_with_same_cycles_is_not_a_noop(self):
        other = {"disasm": {"records_target": 61, "mnemonics": {"add16": 11, "fmuls": 2, "jmp": 5}}}
        summary, _ = self._run({"XKERNEL_NOOP_FEEDBACK": "1"}, 1000, other)
        self.assertFalse(summary["steps"][0]["candidates"][0]["compiled_noop"])

    def test_env_whitelist_replaces_the_angle_list(self):
        summary, _ = self._run({"XKERNEL_ANGLE_WHITELIST": "cursor_path_split,dsd_setup_hoist,no_such_angle"}, 900, self.IR)
        self.assertEqual(summary["angle_whitelist"], ["cursor_path_split", "dsd_setup_hoist"])
        self.assertIn("env whitelist", summary["angle_source"])
