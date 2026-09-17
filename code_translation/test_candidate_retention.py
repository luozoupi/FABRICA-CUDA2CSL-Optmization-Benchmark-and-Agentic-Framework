"""Retained optimizer candidates are written under candidates/ and harvested by hw_replay."""
import json
import tempfile
import unittest
from pathlib import Path

import cuda2csl
import hw_replay


class RetentionTest(unittest.TestCase):
    def test_write_and_harvest(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp) / "sweep"
            kout = root / "ReLU-1PE" / "O1" / "seed_1" / "run_20260908_000000" / "ReLU-1PE"
            kout.mkdir(parents=True)
            ref_dir = Path(tmp) / "ref" / "CSL"; ref_dir.mkdir(parents=True)
            (ref_dir / "pe.csl").write_text("// ref\n")
            retained = [
                {"attempt": 0, "cand_idx": 0, "angle": "baseline", "accepted": True, "status": "pass",
                 "success_marker": True, "cycles_send": 272, "cycles_send_runs": [272, 272, 272],
                 "contract_violation": None, "base_label": "input", "base_cycles": None, "code": "// v0\n"},
                {"attempt": 1, "cand_idx": 1, "angle": "dsd_width_flatten_l0", "accepted": True, "status": "pass",
                 "success_marker": True, "cycles_send": 143, "cycles_send_runs": [143, 143, 143],
                 "contract_violation": None, "base_label": "best", "base_cycles": 272, "code": "// v1\n"},
                {"attempt": 2, "cand_idx": 1, "angle": "comptime_hoist", "accepted": False, "status": "fail",
                 "success_marker": False, "cycles_send": None, "cycles_send_runs": [],
                 "contract_violation": None, "base_label": "best", "base_cycles": 143, "code": "// v2\n"},
            ]
            cuda2csl.write_final_artifacts(
                kernel_output_dir=str(kout), target_relpath="pe.csl", translated_code="// final\n",
                metadata={"kernel": "ReLU-1PE", "reference_dir": str(ref_dir), "commands_script": "commands_wse3.sh"},
                env_report={}, benchmark_result={"status": "pass", "success_marker": True, "cycles_send": 142,
                                                 "target_relpath": "pe.csl", "reference_dir": str(ref_dir)},
                optimization_summary={}, history=[], run_log=[], retained_candidates=retained)
            idx = json.loads((kout / "candidates" / "index.json").read_text())["candidates"]
            self.assertEqual([c["label"] for c in idx],
                             ["attempt_00_baseline", "attempt_01_cand1_dsd_width_flatten_l0", "attempt_02_cand1_comptime_hoist"])
            self.assertTrue((kout / "candidates" / "attempt_01_cand1_dsd_width_flatten_l0" / "pe.csl").is_file())
            self.assertNotIn("code", idx[0])
            # harvest: final + passing candidates by default; nested arm/seed layout understood
            entries = hw_replay.harvest(root, versions=True)
            versions = sorted(e["version"] for e in entries)
            self.assertEqual(versions, ["attempt_00_baseline", "attempt_01_cand1_dsd_width_flatten_l0", "final"])
            self.assertTrue(all(e["kernel"] == "ReLU-1PE" and e["label"] == "O1/seed_1" for e in entries))
            all_entries = hw_replay.harvest(root, versions=True, include_failed=True)
            self.assertEqual(len(all_entries), 4)
            self.assertEqual(len(hw_replay.harvest(root)), 1)


if __name__ == "__main__":
    unittest.main()
