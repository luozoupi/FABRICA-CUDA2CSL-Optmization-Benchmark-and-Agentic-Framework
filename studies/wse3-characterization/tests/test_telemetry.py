from __future__ import annotations

import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from wse3study.telemetry import (  # noqa: E402
    U48_MODULUS,
    append_measurements,
    elapsed_u48,
    load_measurements,
    telemetry_overhead_pct,
    u48_to_words,
    validate_timed_trial,
    words_to_u48,
)


class TelemetryTests(unittest.TestCase):
    def test_u48_round_trip_and_wrap(self) -> None:
        value = 0x1234_5678_9ABC
        self.assertEqual(value, words_to_u48(u48_to_words(value)))
        self.assertEqual(9, elapsed_u48(U48_MODULUS - 4, 5))

    def test_rejects_dead_and_host_bracketed_timer(self) -> None:
        errors = validate_timed_trial(
            {
                "elapsed_cycles": 12,
                "timing_method": "host_launched_tic_toc",
                "arm": "hardware",
                "evidence": "silicon",
                "correctness": True,
            }
        )
        self.assertTrue(any("dead-timer" in error for error in errors))
        self.assertTrue(any("device-internal" in error for error in errors))

        live_short = validate_timed_trial(
            {
                "elapsed_cycles": 37,
                "timer_validated": True,
                "timing_method": "device_internal_synchronized",
                "correctness": True,
            }
        )
        self.assertEqual([], live_short)

    def test_csv_contract_and_overhead(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "measurements.csv"
            count = append_measurements(
                path,
                [{"kernel": "k", "arm": "hardware", "evidence": "silicon"}],
            )
            self.assertEqual(1, count)
            self.assertEqual("k", load_measurements(path)[0]["kernel"])
        self.assertAlmostEqual(5.0, telemetry_overhead_pct([100, 100, 100], [105, 105, 105]))


if __name__ == "__main__":
    unittest.main()
