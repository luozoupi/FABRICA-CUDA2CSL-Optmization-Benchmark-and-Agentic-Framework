import unittest

import check_timing_integrity as cti

GOOD = """
fn f_tic_dev() void { if (!o) { o = true; timestamp.get_timestamp(&s); } }
fn f_toc_dev() void { timestamp.get_timestamp(&e); }
fn main() void {
  f_tic_dev();
  work();
}
task f_exit() void {
  f_toc_dev();
  sys_mod.unblock_cmd_stream();
}
comptime { @export_symbol(main); }
"""


class DeviceWindowTest(unittest.TestCase):
    def test_good(self):
        ok, _ = cti.check_device_window(GOOD)
        self.assertTrue(ok)

    def test_legacy_passes(self):
        ok, reason = cti.check_device_window("fn f_tic() void {}\nfn main() void {}")
        self.assertTrue(ok); self.assertIn("legacy", reason)

    def test_missing_toc_call(self):
        bad = GOOD.replace("  f_toc_dev();\n", "")
        ok, reason = cti.check_device_window(bad)
        self.assertFalse(ok); self.assertIn("f_toc_dev", reason)

    def test_toc_outside_completion_path(self):
        bad = GOOD.replace("  f_toc_dev();\n  sys_mod.unblock_cmd_stream();", "  sys_mod.unblock_cmd_stream();").replace(
            "  work();\n", "  work();\n  f_toc_dev();\n")
        ok, reason = cti.check_device_window(bad)
        self.assertFalse(ok); self.assertIn("f_toc_dev", reason)

    def test_commented_call_does_not_count(self):
        bad = GOOD.replace("  f_tic_dev();\n", "  // f_tic_dev();\n")
        ok, reason = cti.check_device_window(bad)
        self.assertFalse(ok); self.assertIn("f_tic_dev", reason)


if __name__ == "__main__":
    unittest.main()
