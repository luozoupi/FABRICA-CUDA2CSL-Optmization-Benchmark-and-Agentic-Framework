"""Rule 4 of the contract check: the device-internal timing window is structural."""
import unittest

import contract_check as cc
import timing_protocol as tp

REF = """
const timestamp = @import_module("<time>");
var tsc_window_open: bool = false;
fn f_tic_dev() void {
  if (!tsc_window_open) { tsc_window_open = true; timestamp.get_timestamp(&tscStartBuffer); }
}
fn f_toc_dev() void { timestamp.get_timestamp(&tscEndBuffer); }
fn main() void {
  f_tic_dev();
  do_work();
}
task f_exit() void {
  f_toc_dev();  // end of the measured window
  sys_mod.unblock_cmd_stream();
}
fn f_tic() void { timestamp.get_timestamp(&tscStartBuffer); sys_mod.unblock_cmd_stream(); }
comptime {
  @export_symbol(main);
  @export_symbol(f_tic);
}
"""

LEGACY = """
const timestamp = @import_module("<time>");
var tscStartBuffer = @zeros([3]u16); var tscEndBuffer = @zeros([3]u16);
fn main() void {
  do_work();
}
task recv_done() void {
  if (remaining == 0) {
    sys_mod.unblock_cmd_stream();
  }
}
fn f_enable_timer() void { timestamp.enable_tsc(); sys_mod.unblock_cmd_stream(); }
fn f_tic() void { timestamp.get_timestamp(&tscStartBuffer); sys_mod.unblock_cmd_stream(); }
fn f_toc() void { timestamp.get_timestamp(&tscEndBuffer); sys_mod.unblock_cmd_stream(); }
comptime { @export_symbol(main); @export_symbol(f_tic); @export_symbol(f_toc); @export_symbol(f_enable_timer); }
"""


class CallsiteRuleTest(unittest.TestCase):
    def test_identical_passes(self):
        self.assertIsNone(cc.validate_frozen_callsites(REF, REF))
        self.assertIsNone(cc.validate_against_reference(REF, REF))

    def test_dropping_the_end_stamp_is_a_violation(self):
        variant = REF.replace("  f_toc_dev();  // end of the measured window\n", "")
        msg = cc.validate_frozen_callsites(variant, REF)
        self.assertIsNotNone(msg); self.assertIn("f_toc_dev", msg)
        self.assertIn("f_toc_dev", cc.validate_against_reference(variant, REF))

    def test_moving_the_start_stamp_is_a_violation(self):
        variant = REF.replace("  f_tic_dev();\n  do_work();\n", "  do_work();\n  f_tic_dev();\n")
        msg = cc.validate_frozen_callsites(variant, REF)
        self.assertIsNotNone(msg); self.assertIn("must start with f_tic_dev", msg)

    def test_early_end_stamp_is_a_violation(self):
        variant = REF.replace("  f_toc_dev();  // end of the measured window\n  sys_mod.unblock_cmd_stream();",
                              "  f_toc_dev();\n  more_work();\n  sys_mod.unblock_cmd_stream();")
        self.assertIsNotNone(cc.validate_frozen_callsites(variant, REF))

    def test_different_task_structure_passes(self):
        variant = REF.replace("task f_exit() void {\n  f_toc_dev();  // end of the measured window\n  sys_mod.unblock_cmd_stream();\n}",
                              "task done_a() void {\n  f_toc_dev();\n  sys_mod.unblock_cmd_stream();\n}\n"
                              "task done_b() void {\n  if (x) {\n    f_toc_dev();\n    sys_mod.unblock_cmd_stream();\n  }\n}")
        self.assertIsNone(cc.validate_frozen_callsites(variant, REF))

    def test_legacy_reference_is_unaffected(self):
        self.assertIsNone(cc.validate_frozen_callsites(LEGACY, LEGACY))
        self.assertIn("f_tic_dev", cc.DEFAULT_FROZEN_FUNCTIONS)


# The template-completion route's scaffold: f_tic()/f_toc() called on device around the
# kernel call, the completion task only unblocks the host. This is the shape of every
# first-correct program of the sparse suite's multi-PE tasks (SpMV-RowBlock, SpMM-CSR-Dense).
TEMPLATE = """
const timestamp = @import_module("<time>");
var tsc_start_buf = @zeros([3]u16); var tsc_end_buf = @zeros([3]u16);
fn spmv() void { do_work(); }
fn compute() void { spmv(); }
fn f_enable_timer() void { timestamp.enable_tsc(); sys_mod.unblock_cmd_stream(); }
fn f_tic() void { timestamp.get_timestamp(&tsc_start_buf); }
fn f_toc() void { timestamp.get_timestamp(&tsc_end_buf); timestamp.disable_tsc(); }
fn f_memcpy_timestamps() void { time_buf_u16[0] = tsc_start_buf[0]; sys_mod.unblock_cmd_stream(); }
fn main() void {
  f_tic();
  var it: u16 = 0;
  while (it < iters) : (it += 1) {
    compute();
  }
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
SPEC_FROZEN = ("f_tic_dev", "f_toc_dev", "f_enable_timer", "f_memcpy_timestamps", "f_tic", "f_toc")


class TemplateWindowTest(unittest.TestCase):
    """Rule 4 for a start program that uses the template protocol (2026-09-21: every
    optimizer candidate of the multi-PE sparse tasks had been rejected because the rule
    compared them with the reference's device_internal_v2 helpers instead)."""

    def test_protocol_detection(self):
        self.assertTrue(tp.uses_template_protocol(TEMPLATE))
        self.assertFalse(tp.uses_template_protocol(LEGACY))     # exported for the host, never called on device
        self.assertFalse(tp.uses_template_protocol(REF))        # v2 takes precedence
        self.assertFalse(tp.uses_protocol(TEMPLATE))

    def test_identical_passes(self):
        self.assertIsNone(cc.validate_frozen_callsites(TEMPLATE, TEMPLATE))
        self.assertIsNone(cc.validate_against_reference(TEMPLATE, TEMPLATE, SPEC_FROZEN, ("P", "iters")))

    def test_work_before_the_start_stamp_is_a_violation(self):
        # observed: a luna candidate moved an index-narrowing pass ahead of f_tic() in main()
        variant = TEMPLATE.replace("fn main() void {\n  f_tic();\n", "fn main() void {\n  narrow_indices();\n  f_tic();\n")
        msg = cc.validate_frozen_callsites(variant, TEMPLATE)
        self.assertIsNotNone(msg); self.assertIn("must start with f_tic", msg)

    def test_work_after_the_end_stamp_is_a_violation(self):
        variant = TEMPLATE.replace("  f_toc();\n  @activate(EXIT);", "  f_toc();\n  flush_y();\n  @activate(EXIT);")
        msg = cc.validate_frozen_callsites(variant, TEMPLATE)
        self.assertIsNotNone(msg); self.assertIn("work after f_toc", msg)

    def test_completion_signal_elsewhere_is_a_violation(self):
        variant = TEMPLATE.replace("fn compute() void { spmv(); }", "fn compute() void { spmv(); @activate(EXIT); }")
        msg = cc.validate_frozen_callsites(variant, TEMPLATE)
        self.assertIsNotNone(msg); self.assertIn("@activate(EXIT)", msg)

    def test_completion_task_doing_work_is_a_violation(self):
        variant = TEMPLATE.replace("task f_exit() void {\n  sys_mod.unblock_cmd_stream();",
                                   "task f_exit() void {\n  finalize_y();\n  sys_mod.unblock_cmd_stream();")
        msg = cc.validate_frozen_callsites(variant, TEMPLATE)
        self.assertIsNotNone(msg); self.assertIn("only unblock", msg)

    def test_restarting_the_window_is_a_violation(self):
        variant = TEMPLATE.replace("    compute();\n", "    f_tic();\n    compute();\n")
        msg = cc.validate_frozen_callsites(variant, TEMPLATE)
        self.assertIsNotNone(msg); self.assertIn("other than as an entry point's first statement", msg)

    def test_dropping_the_end_stamp_is_a_violation(self):
        variant = TEMPLATE.replace("  f_toc();\n  @activate(EXIT);", "  @activate(EXIT);")
        self.assertIn("never called", cc.validate_frozen_callsites(variant, TEMPLATE))

    def test_unblock_without_a_stamp_is_a_violation(self):
        variant = TEMPLATE.replace("fn compute() void { spmv(); }", "fn compute() void { spmv(); sys_mod.unblock_cmd_stream(); }")
        self.assertIn("unblock_cmd_stream() in 'compute'", cc.validate_frozen_callsites(variant, TEMPLATE))

    def test_different_completion_structure_passes(self):
        # the end stamp moves into a receive task that signals EXIT; main no longer stamps the end
        variant = TEMPLATE.replace("  f_toc();\n  @activate(EXIT);\n}", "}").replace(
            "task f_exit() void {", "task all_received() void {\n  if (pending == 0) {\n    f_toc();\n    @activate(EXIT);\n  }\n}\ntask f_exit() void {")
        self.assertIsNone(cc.validate_frozen_callsites(variant, TEMPLATE), cc.validate_frozen_callsites(variant, TEMPLATE))

    def test_end_stamp_inside_a_branch_passes(self):
        """Observed (luna, prefetch_fabric_async): the head PE stamps and exits inside one branch of
        main, the others finish in a task that an async DSD op activates. The sibling `else`
        branches are other paths, and COMPUTE is not a completion signal."""
        variant = TEMPLATE.replace(
            "fn main() void {\n  f_tic();\n  var it: u16 = 0;\n  while (it < iters) : (it += 1) {\n    compute();\n  }\n  f_toc();\n  @activate(EXIT);\n}",
            "fn main() void {\n  f_tic();\n  if (P > 1) {\n    if (px == 0) {\n      @fmovs(x_out, x_mem, .{ .async = true });\n      compute();\n      f_toc();\n      @activate(EXIT);\n    } else {\n      @fmovs(x_mem, x_in, .{ .async = true, .activate = COMPUTE });\n    }\n  } else {\n    @activate(COMPUTE);\n  }\n}\n"
            "task compute_after_x() void {\n  compute();\n  f_toc();\n  @activate(EXIT);\n}").replace(
            "  @bind_local_task(f_exit, EXIT);", "  @bind_local_task(compute_after_x, COMPUTE);\n  @bind_local_task(f_exit, EXIT);")
        self.assertIsNone(cc.validate_frozen_callsites(variant, TEMPLATE), cc.validate_frozen_callsites(variant, TEMPLATE))
        # but work after the branch's stamp, on the same path, is still caught
        bad = variant.replace("      f_toc();\n      @activate(EXIT);\n    } else {", "      f_toc();\n      @activate(EXIT);\n    } else {\n    }\n    finish();\n    if (false) {")
        self.assertIn("work after f_toc", cc.validate_frozen_callsites(bad, TEMPLATE))

    def test_the_defect_the_rule_replaces(self):
        """A template program checked against a v2 reference fails on helpers it never had,
        and the splice against that reference imports the reference's buffer names."""
        msg = cc.validate_against_reference(TEMPLATE, REF, SPEC_FROZEN, ())
        self.assertIn("f_tic_dev' is missing", msg); self.assertIn("helpers missing", msg)
        spliced, replaced = cc.splice_frozen_functions(TEMPLATE, REF, SPEC_FROZEN)
        self.assertEqual(replaced, ["f_tic"]); self.assertIn("tscStartBuffer", spliced)   # not declared in TEMPLATE
        # against the start program itself the identity edit is clean and the splice is a no-op
        self.assertIsNone(cc.validate_against_reference(TEMPLATE, TEMPLATE, SPEC_FROZEN, ()))
        self.assertEqual(cc.splice_frozen_functions(TEMPLATE, TEMPLATE, SPEC_FROZEN)[1], [])

    def test_splice_restores_the_start_programs_timing_bodies(self):
        variant = TEMPLATE.replace("fn f_toc() void { timestamp.get_timestamp(&tsc_end_buf); timestamp.disable_tsc(); }",
                                   "fn f_toc() void { timestamp.get_timestamp(&tsc_end_buf); }")
        spliced, replaced = cc.splice_frozen_functions(variant, TEMPLATE, SPEC_FROZEN)
        self.assertEqual(replaced, ["f_toc"]); self.assertIn("timestamp.disable_tsc()", spliced)
        self.assertIsNone(cc.validate_against_reference(spliced, TEMPLATE, SPEC_FROZEN, ()))


class InstrumenterTest(unittest.TestCase):
    def test_instrument_legacy_program(self):
        out = tp.instrument_device_window(LEGACY)
        self.assertIsNone(tp.check_device_window_contract(out), tp.check_device_window_contract(out))
        self.assertEqual(out.count("f_tic_dev();"), 1)          # main() only
        self.assertEqual(out.count("f_toc_dev();"), 1)          # recv_done only; helpers untouched
        self.assertIn("timestamp.get_timestamp(&tscStartBuffer)", out)
        self.assertEqual(tp.instrument_device_window(out), out)  # idempotent


if __name__ == "__main__":
    unittest.main()
