"""cost_report: exact vs modelled tiers, prices, simulator and wall-clock columns on a synthetic run."""
import json
import os
import tempfile
import time
import unittest
from pathlib import Path

import cost_report as cr


def _mk_run(root: Path, sweep: str, arm: str, seed: int, kernel: str, with_usage: bool) -> Path:
    rd = root / sweep / kernel / arm / f"seed_{seed}" / "run_20260908_070000" / kernel
    rd.mkdir(parents=True)
    (rd / "bundle_metadata.json").write_text(json.dumps({"kernel": kernel, "model": "claude-opus-4-8", "backend": "anthropic"}))
    (rd / "benchmark.json").write_text(json.dumps({"status": "pass", "success_marker": True, "cycles_send": 142}))
    (rd / "final_result.json").write_text(json.dumps({"attempts": [
        {"status": "fail", "script_elapsed_ms": 1500.0}, {"status": "pass", "script_elapsed_ms": 9000.0}]}))
    (rd / "optimization_summary.json").write_text(json.dumps({"steps": [
        {"step": "dsd_width_flatten_l0", "selected": True}, {"step": "f16_precision", "selected": False}]}))
    (rd / "translation_log.json").write_text(json.dumps({"messages": [
        {"role": "system", "content": "a" * 400}, {"role": "user", "content": "b" * 800},
        {"role": "assistant", "content": "c" * 1200}, {"role": "user", "content": "d" * 2000},
        {"role": "assistant", "content": "e" * 400}]}))
    (rd / "version_trace.json").write_text(json.dumps({"versions": [
        {"phase": "translate", "run_time_ms": 100}, {"phase": "optimize", "run_time_ms": 2500}, {"phase": "optimize", "run_time_ms": 3500}]}))
    if with_usage:
        (rd / "usage_log.json").write_text(json.dumps({
            "schema": "usage_log/1",
            "totals": {"calls": 9, "input_tokens": 120000, "output_tokens": 15000, "cache_read_input_tokens": 30000},
            "by_phase": {"translate": {"calls": 3, "input_tokens": 40000, "output_tokens": 5000, "missing_usage": 0},
                         "_select_optimization_angle": {"calls": 3, "input_tokens": 30000, "output_tokens": 2000, "missing_usage": 0},
                         "optimize": {"calls": 3, "input_tokens": 50000, "output_tokens": 8000, "missing_usage": 1}}}))
    return rd


class CostReportTests(unittest.TestCase):
    def test_exact_tier_and_prices(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            rd = _mk_run(root, "mg_sweep", "O1", 1, "ReLU-1PE", with_usage=True)
            prices = cr.parse_prices(["claude-opus-4-8=15,75,1.5"])
            row = cr.run_row(rd, root, prices, 4.0, None)
            self.assertEqual(row["tier"], "exact")
            self.assertEqual((row["sweep"], row["arm"], row["seed"], row["kernel"]), ("mg_sweep", "O1", "1", "ReLU-1PE"))
            self.assertEqual(row["input_tokens"], 120000)
            self.assertEqual(row["opt_input_tokens"], 80000)
            self.assertEqual(row["opt_calls"], 6)
            self.assertEqual(row["missing_usage_calls"], 1)
            # 120000*15 + 15000*75 + 30000*1.5 = 1.8M + 1.125M + 45k = 2.97 USD
            self.assertAlmostEqual(row["usd"], 2.97, places=3)
            self.assertAlmostEqual(row["sim_s_translate"], 10.5)
            self.assertAlmostEqual(row["sim_s_optimize_partial"], 6.0)
            self.assertEqual(row["n_accepted"], 1)
            self.assertIsNotNone(row["wall_min"])

    def test_modelled_tier_lower_bound(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            rd = _mk_run(root, "legacy", "", 0, "GELU-1PE", with_usage=False)
            row = cr.run_row(rd, root, {}, 4.0, None)
            self.assertEqual(row["tier"], "modelled")
            # assistant turn 1 sees 1200 chars of context, turn 2 sees 4400 -> 5600 chars -> 1400 tokens
            self.assertEqual(row["input_tokens"], 1400)
            self.assertEqual(row["output_tokens"], 400)
            self.assertEqual(row["llm_calls"], 2)
            self.assertIsNone(row["usd"])           # no price given
            self.assertIsNone(row["opt_input_tokens"])  # no per-step constants given
            row2 = cr.run_row(rd, root, {}, 4.0, (20000, 3000))
            self.assertEqual(row2["opt_input_tokens"], 40000)
            self.assertEqual(row2["input_tokens"], 1400 + 40000)

    def test_price_prefix_match_and_default_cache(self):
        prices = cr.parse_prices(["claude-opus=10,50"])
        self.assertEqual(cr.price_for("claude-opus-4-8", prices), (10.0, 50.0, 1.0))
        self.assertIsNone(cr.price_for("gpt-5", prices))
        with self.assertRaises(SystemExit):
            cr.parse_prices(["bad=1"])

    def test_summary_groups_by_sweep_arm_tier(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            rows = [cr.run_row(_mk_run(root, "s", arm, seed, "K", True), root, {}, 4.0, None)
                    for arm in ("O0", "O1") for seed in (1, 2)]
            summ = cr.summarise(rows)
            self.assertEqual([(s["arm"], s["runs"]) for s in summ], [("O0", 2), ("O1", 2)])
            self.assertEqual(summ[0]["median_input_tokens"], 120000)


if __name__ == "__main__":
    unittest.main()
