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
