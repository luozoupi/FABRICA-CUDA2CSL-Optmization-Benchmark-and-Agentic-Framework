"""The optimizer reads the profile of the candidate it edits, gates angles, and
shows the silicon-model readout to the angle selector (no SDK, no LLM)."""
import os
import unittest
from unittest import mock

import cuda2csl
import prompt_cuda2csl as pc


def _orchestrator():
    o = cuda2csl.CUDA2CSLOrchestrator.__new__(cuda2csl.CUDA2CSLOrchestrator)
    o.max_tokens = 2048
    return o


class ProfilingContextTest(unittest.TestCase):
    def test_context_carries_heuristic_and_model_fields(self):
        profile = {"artifacts": {
            "sim_log_parsed": {"bottleneck_label": "stall-bound", "stall_ratio": 0.4, "wavelet_density": 0.1},
            "memory_profile": {"utilization": 0.9},
            "model_readout": {"bottleneck": "overhead_bound", "ipc": 0.43, "elements_per_dispatch": 1.15,
                              "f16_arith_pct": 0.0, "roofline_fraction_f16": 0.0064,
                              "model_keys": ["model_overhead_bound", "model_narrow_dsd"]},
        }}
        ctx = cuda2csl._profiling_context_from_profile(profile)
        self.assertEqual(ctx["sim_log_bottleneck"], "stall-bound")
        self.assertEqual(ctx["sram_utilization"], 0.9)
        self.assertEqual(ctx["model_bottleneck"], "overhead_bound")
        self.assertEqual(ctx["model_keys"], ["model_overhead_bound", "model_narrow_dsd"])

    def test_empty_profile(self):
        self.assertEqual(cuda2csl._profiling_context_from_profile({}), {})


class FilterAnglesTest(unittest.TestCase):
    ANGLES = ["fmac_bulk", "f16_precision", "bank_class_offset", "turn_free_routing", "dsd_width_flatten_l0"]

    def _run(self, env, spec=None):
        with mock.patch.dict(os.environ, env, clear=False):
            for k in ("XKERNEL_ANGLE_DENYLIST", "XKERNEL_HW_ANGLES", "XKERNEL_CODESIGN_LAYOUT"):
                if k not in env:
                    os.environ.pop(k, None)
            return _orchestrator()._filter_angles(list(self.ANGLES), spec)

    def test_defaults_deny_precision_hardware_and_codesign(self):
        kept, denied = self._run({})
        self.assertEqual(kept, ["fmac_bulk", "dsd_width_flatten_l0"])
        self.assertEqual(denied, {"f16_precision": "precision_contract", "bank_class_offset": "hardware_only",
                                  "turn_free_routing": "codesign_only"})

    def test_precision_contract_admits_f16(self):
        kept, _ = self._run({}, {"precision": {"allow_f16_internal": True}})
        self.assertIn("f16_precision", kept)
        kept, _ = self._run({}, {"precision": {"io_dtype": "f16"}})
        self.assertIn("f16_precision", kept)

    def test_env_gates(self):
        kept, _ = self._run({"XKERNEL_HW_ANGLES": "1", "XKERNEL_CODESIGN_LAYOUT": "1"})
        self.assertIn("bank_class_offset", kept)
        self.assertIn("turn_free_routing", kept)
        kept, denied = self._run({"XKERNEL_ANGLE_DENYLIST": "fmac_bulk, dsd_width_flatten_l0"})
        self.assertNotIn("fmac_bulk", kept)
        self.assertEqual(denied["fmac_bulk"], "denylist")


class SelectorSeesReadoutTest(unittest.TestCase):
    def test_selector_prompt_contains_model_readout(self):
        o = _orchestrator()
        captured = {}

        def fake_llm(messages, max_tokens=None, **kw):
            captured["prompt"] = messages[-1]["content"] if isinstance(messages, list) else str(messages)
            return "ANGLE: dsd_width_flatten_l0\nREASON: narrow dispatches"

        o._llm_call = fake_llm
        sig = {"bottlenecks": {"model_narrow_dsd": 1, "model_overhead_bound": 1},
               "model_readout_text": "Silicon-model readout: class=overhead bound; 1.15 elements/dispatch",
               "n_for_loops": 2, "code_chars": 1000}
        angle, reason = o._select_optimization_angle(
            whitelist=["fmac_bulk", "dsd_width_flatten_l0"], round_robin_idx=0, current_code="fn x() {}",
            current_cycles=1000, reference_cycles=900, kernel_group="stencil", bottleneck_signature=sig)
        self.assertEqual(angle, "dsd_width_flatten_l0")
        self.assertIn("Silicon-model readout", captured["prompt"])
        self.assertIn("BOTTLENECK MATCH", captured["prompt"])  # model keys scored through applicable_bottlenecks


if __name__ == "__main__":
    unittest.main()


class PairedCsvTests(unittest.TestCase):
    """aggregate_model_guided --paired-csv: the paper's figures/ipdps_paired.csv schema."""

    def test_paired_rows_and_classes(self):
        import csv
        import tempfile
        from pathlib import Path
        import aggregate_model_guided as amg
        rows = [
            {"kernel": "K", "arm": "O0", "seed": 1, "fc_cycles": 1000, "final_cycles": 500, "retained_pass": True, "model_class": None},
            {"kernel": "K", "arm": "O1", "seed": 1, "fc_cycles": 1000, "final_cycles": 400, "retained_pass": True, "model_class": "overhead_bound"},
            {"kernel": "K", "arm": "O1", "seed": 2, "fc_cycles": 1000, "final_cycles": None, "retained_pass": False, "model_class": "overhead_bound"},
            {"kernel": "J", "arm": "O0", "seed": 1, "fc_cycles": None, "final_cycles": 300, "retained_pass": True, "model_class": None},
        ]
        self.assertEqual(amg.kernel_classes(rows), {"K": "overhead_bound"})
        with tempfile.TemporaryDirectory() as d:
            out = Path(d) / "ipdps_paired.csv"
            amg.write_paired_csv(rows, out)
            got = list(csv.DictReader(open(out)))
        self.assertEqual([r["arm"] for r in got], ["O0", "O1"])       # no cycles -> dropped; no fc -> dropped
        self.assertEqual(got[0]["class"], "overhead_bound")            # class shared across arms
        self.assertEqual(got[1]["cycles"], "400")
        self.assertEqual(got[0]["retained_pass"], "True")


class AggregatorRootTests(unittest.TestCase):
    """aggregate_model_guided.main on a root as run_model_guided_ab.sh lays it out."""

    SUMMARY = {"baseline": {"cycles_send": 380296, "structure_keys": ["struct_banded"]},
               "final_cycles_send": 380296, "final_status": "pass", "attempts_used": 1,
               "steps": [{"angle": "comptime_hoist", "status": "fail", "candidates": [
                   {"cand_idx": 1, "status": "fail", "failure_reason": "command_failed",
                    "contract_violation": "FROZEN function 'f_tic_dev' is missing from the variant"}]}]}

    def _root(self, d, summary=SUMMARY):
        import json
        from pathlib import Path
        k = Path(d) / "SpMV-RowBlock" / "O0" / "seed_1" / "run_20260921_000000" / "SpMV-RowBlock"
        k.mkdir(parents=True)
        (k / "optimization_summary.json").write_text(json.dumps(summary))
        (k / "benchmark.json").write_text(json.dumps({"status": "pass", "success_marker": True, "cycles_send": 380296}))
        return Path(d)

    def test_paired_csv_and_harness_warning(self):
        """Regression: the table loop shadowed the argparse namespace and --paired-csv crashed
        (2026-09-21, it10 root); and a root whose every candidate failed the contract check
        must say so instead of printing a null result."""
        import contextlib, csv, io, sys, tempfile
        import aggregate_model_guided as amg
        with tempfile.TemporaryDirectory() as d:
            root = self._root(d)
            out = io.StringIO()
            with mock.patch.object(sys, "argv", ["amg", str(root), "--arms", "O0", "--paired-csv", str(root / "paired.csv")]), \
                 contextlib.redirect_stdout(out):
                rc = amg.main()
            self.assertEqual(rc, 0)
            text = out.getvalue()
            self.assertIn("all 1 candidates were rejected by the contract check", text)
            self.assertTrue((root / "paired.csv").is_file())
            tasks = list(csv.DictReader(open(root / "model_guided_tasks.csv")))
        self.assertEqual(tasks[0]["fc_source"], "run_baseline")            # the run's own baseline, not meta.json
        self.assertEqual(tasks[0]["n_contract_violations"], "1")
        self.assertAlmostEqual(float(tasks[0]["O0_speedup_vs_fc"]), 1.0)

    def test_comparator_is_the_runs_baseline_at_its_size(self):
        """A --size root (it10: start program 380,296) must not be compared with the
        extraction's small-size cycles (37,012), which reported 0.097x."""
        import aggregate_model_guided as amg
        rows = [{"kernel": "K", "arm": "O0", "seed": 1, "fc_cycles": 37012, "baseline_cycles": 380296,
                 "final_cycles": 190148, "retained_pass": True, "model_class": None,
                 "n_candidates": 5, "n_contract_violations": 0}]
        rec = amg.summarise(rows, ["O0"])[0]
        self.assertEqual(rec["fc_cycles"], 380296); self.assertEqual(rec["fc_source"], "run_baseline")
        self.assertAlmostEqual(rec["O0_speedup_vs_fc"], 2.0)
        rows[0]["baseline_cycles"] = None
        rec = amg.summarise(rows, ["O0"])[0]
        self.assertEqual(rec["fc_source"], "meta")


class RetainedPassTests(unittest.TestCase):
    """The pre-registered retained-pass rule: status pass AND success marker AND held-out."""

    def test_rule(self):
        import aggregate_model_guided as amg
        ok = {"status": "pass", "success_marker": True}
        self.assertTrue(amg.retained_pass(ok))
        self.assertFalse(amg.retained_pass(None))
        self.assertFalse(amg.retained_pass({"status": "fail", "success_marker": True}))
        self.assertFalse(amg.retained_pass({"status": "pass", "success_marker": False}))
        # cycles alone are not a pass
        self.assertFalse(amg.retained_pass({"status": "fail", "success_marker": False, "cycles_send": 1234}))

    def test_heldout_failure_rejected_on_the_real_schema(self):
        """evaluate_heldout reports {"passed": bool, ...} and has no "status" key: a
        record whose gate says failed must be rejected even if status still says pass."""
        import aggregate_model_guided as amg
        he_fail = {"passed": False, "failing_seed": 101, "reason": "seed 101 mismatch"}
        he_pass = {"passed": True, "failing_seed": None, "reason": "passed all 3 held-out seeds"}
        self.assertFalse(amg.retained_pass({"status": "pass", "success_marker": True, "heldout_eval": he_fail}))
        self.assertTrue(amg.retained_pass({"status": "pass", "success_marker": True, "heldout_eval": he_pass}))
        # the gate not having run at all is not a failure
        self.assertTrue(amg.retained_pass({"status": "pass", "success_marker": True, "heldout_eval": {}}))


class ExtraAnglesTests(unittest.TestCase):
    """XKERNEL_SPARSE_ANGLES_EXTRA admits catalogue angles by name (arm O1X) without touching
    the default sparse list, so the O1 treatment of earlier cells is unchanged."""

    def test_catalogue_entry_is_not_in_the_default_sparse_list(self):
        self.assertIn("cursor_path_split", pc.CSL_OPTIMIZATION_STEPS)
        self.assertNotIn("cursor_path_split", pc.SPARSE_CSL_OPT_STEPS)

    def test_env_adds_known_angles_and_ignores_unknown(self):
        o = _orchestrator()
        with mock.patch.dict(os.environ, {"XKERNEL_SPARSE_ANGLES_EXTRA": "cursor_path_split, no_such_angle"}):
            extra = [a.strip() for a in os.environ.get("XKERNEL_SPARSE_ANGLES_EXTRA", "").split(",") if a.strip()]
        known = [a for a in extra if a in pc.CSL_OPTIMIZATION_STEPS]
        self.assertEqual(known, ["cursor_path_split"])
        kept, _ = o._filter_angles(["fmac_bulk"] + known, {"group": "sparse"})
        self.assertIn("cursor_path_split", kept)
