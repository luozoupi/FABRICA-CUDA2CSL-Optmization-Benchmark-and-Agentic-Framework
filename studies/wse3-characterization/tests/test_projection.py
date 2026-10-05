from __future__ import annotations

import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from wse3study.projection import (  # noqa: E402
    latency_samples,
    project_measurements,
    single_pe_samples,
)
from wse3study.telemetry import load_measurements  # noqa: E402


class ProjectionTests(unittest.TestCase):
    def _record(self):
        return {
            "accepted": True,
            "warmup": False,
            "trial": 2,
            "campaign_id": "c",
            "subject": "straight-east-h4-p8",
            "variant": "straight",
            "arm": "hardware",
            "evidence": "silicon",
            "telemetry_level": "endpoint",
            "request_key": "r",
            "event_key": "e",
            "source_hash": "s",
            "result": {
                "elapsed_cycles": 77,
                "correctness": True,
                "timing_method": "device_internal_synchronized",
            },
            "request": {
                "kind": "calibration",
                "configuration": {
                    "calibration_family": "straight",
                    "calibration_case": "straight-east-h4-p8",
                    "direction": "east",
                    "hops": 4,
                    "payload_wavelets": 8,
                    "split": "fit",
                },
            },
        }

    def test_projects_directional_features(self) -> None:
        rows = latency_samples([self._record()])
        self.assertEqual(4, rows[0]["east_hops"])
        self.assertEqual(0, rows[0]["west_hops"])
        self.assertEqual(77, rows[0]["elapsed_cycles"])

    def test_measurement_projection_is_rebuilt(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "measurements.csv"
            self.assertEqual(1, project_measurements([self._record()], path))
            self.assertEqual("77", load_measurements(path)[0]["elapsed_cycles"])

    def test_projection_uses_latest_attempt_and_expands_spatial_telemetry(self) -> None:
        older = self._record()
        newer = self._record()
        newer["result"] = {
            **newer["result"],
            "elapsed_cycles": 90,
            "telemetry_rows": [
                {
                    "fabric_x": 4,
                    "fabric_y": 1,
                    "phase": "compute_start",
                    "timestamp_cycles": 1000,
                    "elapsed_cycles": "",
                },
                {
                    "fabric_x": 4,
                    "fabric_y": 1,
                    "phase": "compute_end",
                    "timestamp_cycles": 1090,
                    "elapsed_cycles": 90,
                },
            ],
        }
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "measurements.csv"
            self.assertEqual(2, project_measurements([older, newer], path))
            rows = load_measurements(path)
        self.assertEqual(["compute_end", "compute_start"], sorted(row["phase"] for row in rows))
        self.assertTrue(all(row["fabric_x"] == "4" for row in rows))
        self.assertNotIn("77", {row["elapsed_cycles"] for row in rows})

    def test_compile_capacity_probe_preserves_compiled_observation(self) -> None:
        record = self._record()
        record.update(
            {
                "subject": "single-pe-sram-b50176",
                "variant": "single-pe-sram",
                "arm": "simulator",
                "evidence": "compiled",
                "result": {
                    "status": "compile_capacity_fail",
                    "compile_success": False,
                    "capacity_failure": True,
                    "compile_probe_valid": True,
                },
            }
        )
        record["request"]["configuration"] = {
            "calibration_family": "single-pe-sram",
            "calibration_case": "single-pe-sram-b50176",
            "compile_only": True,
            "allocation_bytes": 50176,
        }
        rows = single_pe_samples([record])
        self.assertEqual(1, len(rows))
        self.assertEqual("compile_capacity_fail", rows[0]["status"])
        self.assertTrue(rows[0]["capacity_failure"])


if __name__ == "__main__":
    unittest.main()
