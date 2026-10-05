"""Translation timing-window gate (harness correction #3, 30 Sep 2026).

A translated program of a device_internal_v2 task must open its timer at the first statement
of the launched entry point, so communication (e.g., the broadcast of x) is inside the measured
window as in the reference. SpMV-RowBlock-Iter's first correct programs started the timer in
the compute task instead; the optimizer's contract check then rejected every candidate.
"""
import os
import tempfile
import textwrap
import unittest
from pathlib import Path

from cuda2csl import translation_window_problem

GOOD_TEMPLATE = textwrap.dedent("""
    fn f_tic() void { timestamp.get_timestamp(&t0); }
    fn f_toc() void { timestamp.get_timestamp(&t1); }
    task compute_fn() void {
      spmv();
      f_toc();
      sys_mod.unblock_cmd_stream();
    }
    fn main() void {
      f_tic();
      @activate(compute_task);
    }
    comptime {
      @export_symbol(main);
      @export_symbol(f_tic);
      @export_symbol(f_toc);
    }
""")

TIMER_IN_TASK = textwrap.dedent("""
    fn f_tic() void { timestamp.get_timestamp(&t0); }
    fn f_toc() void { timestamp.get_timestamp(&t1); }
    task compute_fn() void {
      f_tic();
      spmv();
      f_toc();
      sys_mod.unblock_cmd_stream();
    }
    fn main() void {
      broadcast_x();
      @activate(compute_task);
    }
    comptime {
      @export_symbol(main);
      @export_symbol(f_tic);
      @export_symbol(f_toc);
    }
""")

NO_WINDOW = textwrap.dedent("""
    task compute() void {
      timestamp.get_timestamp(&tscStartBuffer);
      spmv();
      sys_mod.unblock_cmd_stream();
    }
    fn main() void { @activate(compute_task); }
    comptime { @export_symbol(main); }
""")


def _task_dir(root: Path, protocol: str) -> str:
    csl = root / "CSL"
    csl.mkdir(parents=True)
    (root / "spec.yaml").write_text(f"name: t\ntiming_protocol: {protocol}\n" if protocol else "name: t\n")
    return str(csl)


class TranslateWindowGateTest(unittest.TestCase):
    def setUp(self):
        self._tmp = tempfile.TemporaryDirectory()
        self.root = Path(self._tmp.name)

    def tearDown(self):
        self._tmp.cleanup()

    def test_well_formed_template_window_passes(self):
        ref = _task_dir(self.root / "a", "device_internal_v2")
        self.assertIsNone(translation_window_problem(GOOD_TEMPLATE, ref))

    def test_timer_started_in_a_task_is_rejected(self):
        ref = _task_dir(self.root / "b", "device_internal_v2")
        msg = translation_window_problem(TIMER_IN_TASK, ref)
        self.assertIsNotNone(msg)
        self.assertIn("main", msg)

    def test_program_without_a_window_is_rejected(self):
        ref = _task_dir(self.root / "c", "device_internal_v2")
        self.assertIn("no device-side timing window", translation_window_problem(NO_WINDOW, ref))

    def test_other_protocols_are_not_checked(self):
        ref = _task_dir(self.root / "d", "")
        self.assertIsNone(translation_window_problem(TIMER_IN_TASK, ref))

    def test_real_iter_start_program_fails_and_references_pass(self):
        xk = Path(__file__).resolve().parent.parent
        kern = xk / "kernels"
        for task in ("SpMV-RowBlock", "SpMM-CSR-Dense", "SpMV-RowBlock-Iter"):
            ref = kern / task / "CSL"
            if ref.is_dir():
                self.assertIsNone(translation_window_problem((ref / "pe.csl").read_text(), str(ref)), task)

    def test_gate_is_off_by_default(self):
        old = os.environ.pop("XKERNEL_TRANSLATE_WINDOW_CHECK", None)
        try:
            self.assertNotEqual(os.environ.get("XKERNEL_TRANSLATE_WINDOW_CHECK", "0"), "1")
        finally:
            if old is not None:
                os.environ["XKERNEL_TRANSLATE_WINDOW_CHECK"] = old


if __name__ == "__main__":
    unittest.main()
