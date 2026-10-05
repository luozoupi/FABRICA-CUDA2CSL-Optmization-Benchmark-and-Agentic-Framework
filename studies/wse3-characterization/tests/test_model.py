from __future__ import annotations

import random
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from wse3study.model import fit_latency_model, predict_latency  # noqa: E402


class LatencyModelTests(unittest.TestCase):
    def _samples(self):
        rng = random.Random(19)
        samples = []
        directions = ("east_hops", "west_hops", "north_hops", "south_hops")
        hop_choices = (1, 2, 4, 8, 16, 32, 64, 128, 256)
        costs = {"east_hops": 2.0, "west_hops": 2.2, "north_hops": 2.4, "south_hops": 2.6}
        for index in range(240):
            row = {direction: 0 for direction in directions}
            direction = rng.choice(directions)
            row[direction] = rng.choice(hop_choices)
            row["turns"] = rng.randrange(0, 3)
            row["payload_wavelets"] = rng.choice((1, 8, 64, 512))
            row["contention_sources"] = rng.choice((1, 2, 4))
            row["receiver_delay_cycles"] = rng.choice((0, 4, 16, 64))
            row["case_index"] = index
            row["evidence"] = "silicon"
            row["correctness"] = "pass"
            row["elapsed_cycles"] = (
                40
                + sum(row[name] * costs[name] for name in directions)
                + row["turns"] * 3
                + row["payload_wavelets"] * 0.25
                + row["contention_sources"] * 5
                + row["receiver_delay_cycles"]
            )
            samples.append(row)
        return samples

    def test_recovers_directional_costs_and_validates(self) -> None:
        model = fit_latency_model(self._samples(), bootstrap_iterations=10)
        self.assertTrue(model["validation_target_met"])
        self.assertGreater(model["sample_counts"]["uncontended_validation"], 0)
        self.assertEqual(
            model["sample_counts"]["validation"],
            len(model["validation_residuals"]),
        )
        self.assertAlmostEqual(2.0, model["coefficients"]["east_hops"], places=5)
        self.assertAlmostEqual(2.6, model["coefficients"]["south_hops"], places=5)
        probe = self._samples()[0]
        self.assertAlmostEqual(probe["elapsed_cycles"], predict_latency(model, probe), places=4)

    def test_missing_holdout_is_not_reported_as_validation_success(self) -> None:
        rows = []
        directions = ("east_hops", "west_hops", "north_hops", "south_hops")
        for index in range(40):
            row = {
                **{name: 0 for name in directions},
                "turns": index % 3,
                "payload_wavelets": 1 + index,
                "contention_sources": 1 + index % 2,
                "receiver_delay_cycles": index % 5,
                "evidence": "silicon",
                "correctness": True,
            }
            row[directions[index % len(directions)]] = 1 + (index // 4) % 4
            row["elapsed_cycles"] = 20 + sum(
                float(row[name])
                for name in (
                    "east_hops",
                    "west_hops",
                    "north_hops",
                    "south_hops",
                    "turns",
                    "payload_wavelets",
                    "contention_sources",
                    "receiver_delay_cycles",
                )
            )
            rows.append(row)
        model = fit_latency_model(rows, bootstrap_iterations=0)
        self.assertEqual(0, model["sample_counts"]["validation"])
        self.assertIsNone(model["validation_target_met"])


if __name__ == "__main__":
    unittest.main()
