#!/usr/bin/env python3
"""Tests for check_timing_integrity.py — the static run.py / compute.csl linters.

Covers all three guards:
  - check_run_py        : host-loop-inside-timed-window (immune-kernel bug)
  - check_compute_csl   : get_timestamp without enable_tsc (dead-timer bug)
  - check_success_gated : SUCCESS marker reachable without an enforced check
                          (the SpMV ungated-verifier bug; added 2026-06-24)
"""

import unittest

from check_timing_integrity import (
    check_run_py,
    check_compute_csl,
    check_success_gated,
)


class HostLoopTimingTest(unittest.TestCase):
    def test_host_loop_inside_window_flagged(self):
        bad = (
            'runner.launch("f_tic")\n'
            'for i in range(max_ite):\n'
            '    runner.launch("f_spmv")\n'
            'runner.launch("f_toc")\n'
        )
        ok, reason = check_run_py(bad)
        self.assertFalse(ok, reason)
        self.assertIn("INSIDE the f_tic..f_toc", reason)

    def test_single_device_launch_clean(self):
        good = (
            'runner.launch("f_tic")\n'
            'runner.launch("generate", np.uint16(iters))\n'
            'runner.launch("f_toc")\n'
        )
        ok, reason = check_run_py(good)
        self.assertTrue(ok, reason)

    def test_no_timing_window_is_skipped(self):
        ok, reason = check_run_py('runner.launch("f_run")\n')
        self.assertTrue(ok)
        self.assertIn("no f_tic/f_toc", reason)


class DeadTimerCslTest(unittest.TestCase):
    def test_get_timestamp_without_enable_tsc_flagged(self):
        bad = "timestamp.get_timestamp(&buf);\n"
        ok, reason = check_compute_csl(bad)
        self.assertFalse(ok, reason)
        self.assertIn("never enable_tsc()", reason)

    def test_get_timestamp_with_enable_tsc_clean(self):
        good = (
            "task startup() void { timestamp.enable_tsc(); }\n"
            "timestamp.get_timestamp(&buf);\n"
        )
        ok, reason = check_compute_csl(good)
        self.assertTrue(ok, reason)

    def test_no_timing_csl_skipped(self):
        ok, _ = check_compute_csl("const x = 1;\n")
        self.assertTrue(ok)


class SuccessGatedBackstopTest(unittest.TestCase):
    """The SpMV bug: a verifier printed PASS/FAIL but never raised, so any
    output reached the SUCCESS marker the harness scrapes as a pass."""

    def test_ungated_success_flagged(self):
        bad = (
            "import numpy as np\n"
            "def verify_result(ref, res):\n"
            "    print('PASS' if np.allclose(ref, res) else 'FAIL')\n"
            "print('SUCCESS')\n"
        )
        ok, reason = check_success_gated(bad)
        self.assertFalse(ok, reason)
        self.assertIn("NO enforcement primitive", reason)

    def test_assert_gates_success(self):
        good = "import numpy as np\nassert np.allclose(ref, res)\nprint('SUCCESS')\n"
        ok, reason = check_success_gated(good)
        self.assertTrue(ok, reason)

    def test_np_testing_assert_gates_success(self):
        good = (
            "import numpy as np\n"
            "np.testing.assert_allclose(res, ref, rtol=1e-3)\n"
            "print('SUCCESS')\n"
        )
        ok, reason = check_success_gated(good)
        self.assertTrue(ok, reason)

    def test_nonzero_exit_on_fail_path_gates_success(self):
        good = (
            "if err < tol:\n"
            "    print('SUCCESS!')\n"
            "else:\n"
            "    print('FAIL'); raise SystemExit(1)\n"
        )
        ok, reason = check_success_gated(good)
        self.assertTrue(ok, reason)

    def test_no_success_marker_is_not_applicable(self):
        ok, reason = check_success_gated("print('hello world')\n")
        self.assertTrue(ok)
        self.assertIn("no SUCCESS marker", reason)

    def test_raise_systemexit_zero_is_not_a_gate(self):
        bad = "print('SUCCESS')\nraise SystemExit(0)\n"
        ok, reason = check_success_gated(bad)
        self.assertFalse(ok, reason)


class LiveKernelGatesTest(unittest.TestCase):
    """The hardened verifiers (2026-06-24) must all pass the backstop."""

    HARDENED = [
        "../kernels/Cholesky/CSL/run.py",
        "../kernels/SpMV/CSL/run.py",
        "../kernels/SpMV Hypersparse/CSL/run.py",
        "../kernels/FFT 1D-2D/CSL/run.py",
        "../kernels/3D FFT/CSL/run.py",
        "../kernels/Jacobi-2D-5pt/CSL/run.py",
    ]

    def test_hardened_verifiers_are_gated(self):
        import os
        here = os.path.dirname(os.path.abspath(__file__))
        for rel in self.HARDENED:
            path = os.path.join(here, rel)
            if not os.path.isfile(path):
                continue  # WSE-2-only kernels may move; skip if absent
            with open(path, encoding="utf-8", errors="ignore") as fh:
                ok, reason = check_success_gated(fh.read())
            self.assertTrue(ok, f"{rel}: {reason}")


if __name__ == "__main__":
    unittest.main()
