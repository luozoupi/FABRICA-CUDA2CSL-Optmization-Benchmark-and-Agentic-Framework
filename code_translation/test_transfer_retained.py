"""transfer_retained.py: stdout parsing, the FC series, and the per-seed loop with the
SDK mocked out. CPU-only; no container, no compile."""
import json
import os
import tempfile
import unittest
from pathlib import Path
from unittest import mock

import transfer_retained as tr


class ParseTests(unittest.TestCase):
    def test_parse_run_stdout(self):
        txt = ("SpMV-RowBlock: nrows_pe=256 ncols=1024 max_nnz_pe=2560\n"
               "eval_seed = 202\n"
               "matrix = HB/jagmesh1 n=1009 m=1009 nnz=6865 (index 2, data/manifest.json)\n"
               "cycles_send = 41234 cycles\n"
               "time_send = 48.5 us\n"
               "[verify] max abs err = 1.2e-07\n"
               "cycles_per_nnz = 6.01\n"
               "SUCCESS\n")
        got = tr.parse_run_stdout(txt)
        self.assertEqual(got["cycles"], 41234)
        self.assertEqual(got["matrix"], "HB/jagmesh1")
        self.assertEqual(got["nnz"], 6865)
        self.assertEqual(got["seed_echo"], 202)
        self.assertTrue(got["success_marker"])

    def test_parse_run_stdout_empty_and_partial(self):
        self.assertEqual(tr.parse_run_stdout("")["cycles"], None)
        self.assertFalse(tr.parse_run_stdout("")["success_marker"])
        # a legacy runner that echoes no seed must not look like a mismatch
        self.assertIsNone(tr.parse_run_stdout("cycles_send = 7 cycles\nSUCCESS")["seed_echo"])


class FCTests(unittest.TestCase):
    def test_fc_program_found_by_target_then_basename(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            (root / "SpMV-CSR").mkdir()
            (root / "SpMV-CSR" / "pe.csl").write_text("// fc\n")
            got = tr.fc_program(root, "SpMV-CSR", "pe.csl")
            self.assertEqual(got["arm"], "FC")
            self.assertEqual(got["seed"], 0)
            self.assertEqual(Path(got["program"]).name, "pe.csl")
            self.assertIsNone(tr.fc_program(root, "Missing-Kernel", "pe.csl"))
            self.assertIsNone(tr.fc_program(None, "SpMV-CSR", "pe.csl"))

    def test_fc_program_nested_target(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            (root / "K" / "src").mkdir(parents=True)
            (root / "K" / "src" / "kernel.csl").write_text("// fc\n")
            got = tr.fc_program(root, "K", "src/kernel.csl")
            self.assertTrue(str(got["program"]).endswith("src/kernel.csl"))


class SeedLoopTests(unittest.TestCase):
    def setUp(self):
        self.td = tempfile.TemporaryDirectory()
        self.bundle = Path(self.td.name)
        (self.bundle / "commands_wse3.sh").write_text(
            "#!/usr/bin/env bash\n"
            "cslc ./layout.csl --arch=wse3 --params=nrows:512 -o out --memcpy --channels=1\n"
            "cs_python run.py --name out\n")

    def tearDown(self):
        self.td.cleanup()

    def _run(self, per_seed_stdout, seeds=(101, 202)):
        calls = []

        def fake_step(bundle, command, sdk_root, extra_env=None, shell_setup=None, timeout=0):
            calls.append((command, dict(extra_env or {})))
            seed = int((extra_env or {}).get("XKERNEL_EVAL_SEED", "0"))
            return {"ok": True, "returncode": 0, "stdout": per_seed_stdout[seed], "stderr": ""}

        with mock.patch.object(tr, "_run_step_command", side_effect=fake_step):
            rows = tr.run_on_seeds(str(self.bundle), "commands_wse3.sh", list(seeds),
                                   "/sdk", "XKERNEL_EVAL_SEED", 60)
        return rows, calls

    def test_only_the_run_step_is_re_run_with_all_three_env_forms(self):
        out = {101: "eval_seed = 101\nmatrix = HB/a n=1 m=1 nnz=10 (index 3)\ncycles_send = 100 cycles\nSUCCESS",
               202: "eval_seed = 202\nmatrix = HB/b n=1 m=1 nnz=20 (index 2)\ncycles_send = 200 cycles\nSUCCESS"}
        rows, calls = self._run(out)
        self.assertEqual([c[0] for c in calls], ["cs_python run.py --name out"] * 2)  # never cslc
        for _, env in calls:
            self.assertEqual(set(env), {"XKERNEL_EVAL_SEED", "SINGULARITYENV_XKERNEL_EVAL_SEED",
                                        "APPTAINERENV_XKERNEL_EVAL_SEED"})
        self.assertEqual([r["status"] for r in rows], ["pass", "pass"])
        self.assertEqual([r["cycles"] for r in rows], [100, 200])
        self.assertEqual([r["matrix"] for r in rows], ["HB/a", "HB/b"])
        self.assertEqual([r["nnz"] for r in rows], [10, 20])

    def test_seed_echo_mismatch_is_infrastructure_not_a_kernel_property(self):
        out = {101: "eval_seed = 7\nmatrix = HB/train n=1 m=1 nnz=10 (index 0)\ncycles_send = 100 cycles\nSUCCESS",
               202: "eval_seed = 202\ncycles_send = 200 cycles\nSUCCESS"}
        rows, _ = self._run(out)
        self.assertEqual(rows[0]["status"], "env_not_propagated")
        self.assertIn("eval_seed=7", rows[0]["reason"])
        self.assertNotEqual(rows[0]["status"], "fail")

    def test_pass_without_cycles_is_flagged(self):
        out = {101: "eval_seed = 101\nmatrix = HB/a n=1 m=1 nnz=10 (index 3)\nSUCCESS",
               202: "eval_seed = 202\nmatrix = HB/b n=1 m=1 nnz=20 (index 2)\ncycles_send = 200 cycles\nSUCCESS"}
        rows, _ = self._run(out)
        self.assertEqual(rows[0]["status"], "no_cycles")
        self.assertEqual(rows[1]["status"], "pass")

    def test_failed_run_records_the_stderr_tail(self):
        def fake_step(bundle, command, sdk_root, extra_env=None, shell_setup=None, timeout=0):
            return {"ok": False, "returncode": 1, "stdout": "eval_seed = 101\n",
                    "stderr": "AssertionError: Not equal to tolerance"}

        with mock.patch.object(tr, "_run_step_command", side_effect=fake_step):
            rows = tr.run_on_seeds(str(self.bundle), "commands_wse3.sh", [101], "/sdk",
                                   "XKERNEL_EVAL_SEED", 60)
        self.assertEqual(rows[0]["status"], "fail")
        self.assertIn("Not equal to tolerance", rows[0]["reason"])


class SpecTests(unittest.TestCase):
    def test_every_sparse_task_declares_heldout_seeds(self):
        import task_sets as ts
        from benchmark_csl import _heldout_eval_for_reference
        repo = Path(__file__).resolve().parents[1]
        for k in ts.S:
            csl = repo / "kernels" / k / "CSL"
            if not csl.is_dir():
                continue
            ev = _heldout_eval_for_reference(str(csl))
            self.assertTrue(ev and ev.get("heldout_seeds"), f"{k}: transfer needs held-out seeds")


if __name__ == "__main__":
    unittest.main()
