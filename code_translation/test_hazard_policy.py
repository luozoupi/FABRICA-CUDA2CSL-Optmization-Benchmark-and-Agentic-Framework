"""The f32 DSD-reduction hazard policy on a passing candidate (heldout | reject | warn)."""
import os
import tempfile
import unittest
from unittest import mock

import cuda2csl


class _Dummy:
    sdk_root = "/software/cerebras/cs_sdk-2.10"
    shell_setup = None


def result_with_hazard(severity="error", heldout=None):
    r = {"status": "pass", "commands_script": "commands_wse3.sh", "staged_bundle": tempfile.mkdtemp(),
         "ir_readout": {"hazards": [{"severity": severity, "pc": 678, "instruction": "fadds d12 = d0, [s1ds1]"}]}}
    if heldout is not None:
        r["heldout_eval"] = heldout
    return r


class HazardPolicyTests(unittest.TestCase):
    def setUp(self):
        self._saved = os.environ.pop("XKERNEL_IR_HAZARD_POLICY", None)

    def tearDown(self):
        os.environ.pop("XKERNEL_IR_HAZARD_POLICY", None)
        if self._saved is not None:
            os.environ["XKERNEL_IR_HAZARD_POLICY"] = self._saved

    def apply(self, result, ho_return=None, spec_ho=None):
        with mock.patch("benchmark_csl.evaluate_heldout", return_value=ho_return) as ev, \
             mock.patch("benchmark_csl._heldout_eval_for_reference", return_value=spec_ho):
            cuda2csl.CUDA2CSLOrchestrator._apply_hazard_policy(_Dummy(), result, "/ref")
            return ev

    def test_warning_severity_is_ignored(self):
        r = result_with_hazard("warning")
        self.apply(r)
        self.assertEqual(r["status"], "pass"); self.assertNotIn("hazard_flag", r)

    def test_reject_policy_demotes(self):
        os.environ["XKERNEL_IR_HAZARD_POLICY"] = "reject"
        r = result_with_hazard()
        self.apply(r)
        self.assertEqual((r["status"], r["failure_reason"]), ("fail", "ir_f32_reduction_hazard"))
        self.assertEqual(r["hazard_flag"]["n"], 1)

    def test_warn_policy_annotates_only(self):
        os.environ["XKERNEL_IR_HAZARD_POLICY"] = "warn"
        r = result_with_hazard()
        self.apply(r)
        self.assertEqual(r["status"], "pass"); self.assertEqual(r["hazard_flag"]["policy"], "warn")

    def test_default_heldout_policy_reruns_and_demotes_on_failure(self):
        r = result_with_hazard()
        ev = self.apply(r, ho_return={"passed": False, "reason": "heldout_seed_mismatch seed=101"},
                        spec_ho={"train_seed": 7, "heldout_seeds": [101, 202, 303], "seed_env": "XKERNEL_EVAL_SEED"})
        self.assertTrue(ev.called)
        self.assertEqual((r["status"], r["failure_reason"]), ("fail", "ir_f32_reduction_hazard_heldout_fail"))
        self.assertTrue(r["hazard_forced_heldout"])

    def test_heldout_policy_keeps_a_candidate_the_held_out_inputs_vouch_for(self):
        r = result_with_hazard()
        ev = self.apply(r, ho_return={"passed": True}, spec_ho={"train_seed": 7, "heldout_seeds": [101], "seed_env": "XKERNEL_EVAL_SEED"})
        self.assertTrue(ev.called); self.assertEqual(r["status"], "pass"); self.assertIn("hazard_flag", r)
        r2 = result_with_hazard(heldout={"passed": True})
        ev2 = self.apply(r2)
        self.assertFalse(ev2.called); self.assertEqual(r2["status"], "pass")     # already vouched for

    def test_no_heldout_contract_records_without_demoting(self):
        r = result_with_hazard()
        self.apply(r, spec_ho=None)
        self.assertEqual(r["status"], "pass"); self.assertIs(r["hazard_forced_heldout"], False)


if __name__ == "__main__":
    unittest.main()
