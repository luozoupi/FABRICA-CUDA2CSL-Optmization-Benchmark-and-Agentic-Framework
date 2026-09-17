"""Unit tests for the silicon-model adapter (CPU only; no SDK, no LLM)."""
import gzip
import json
import os
import tempfile
import unittest
from pathlib import Path

import wse3_model as wm


def _write_events(path: Path, events):
    path.parent.mkdir(parents=True, exist_ok=True)
    with gzip.open(path, "wt") as fh:
        for e in events:
            fh.write(json.dumps(e) + "\n")


def _fmach_stream(n_dispatch=1000, num_data=16, span=8000, tile=5):
    events = []
    for i in range(n_dispatch):
        events.append({"event_type": "hwm_dispatch_trace_entry", "cycle": int(i * span / n_dispatch),
                       "tile_index": tile, "name": "FMACH", "num_data": num_data, "ut_id": 255})
    # a few scalar control instructions on another (memcpy) tile
    for i in range(50):
        events.append({"event_type": "hwm_dispatch_trace_entry", "cycle": i * 10, "tile_index": 0,
                       "name": "MOVRI", "num_data": 1, "ut_id": 255})
    return events


class FpSummaryTest(unittest.TestCase):
    def test_flop_per_cycle_and_roofline_fraction(self):
        events = _fmach_stream()
        fp = wm.fp_summary(events)
        self.assertEqual(fp["hot_tile"], 5)
        self.assertEqual(fp["hot_f16_elems"], 16000)
        self.assertEqual(fp["hot_flop"], 32000)  # FMA = 2 FLOP/element
        self.assertEqual(fp["dispatch_span"], 7992)

    def test_num_data_sentinel_counts_as_one(self):
        events = [{"event_type": "hwm_dispatch_trace_entry", "cycle": 0, "tile_index": 1,
                   "name": "FMACS", "num_data": 0xFFFFFFFF, "ut_id": 255}]
        fp = wm.fp_summary(events)
        self.assertEqual(fp["hot_f32_elems"], 1)


@unittest.skipUnless(wm.study_available(), "characterization study not present")
class ClassifyTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.events = Path(self.tmp.name) / "events.jsonl.gz"
        _write_events(self.events, _fmach_stream())

    def tearDown(self):
        self.tmp.cleanup()

    def test_roofline_fraction_from_synthetic_trace(self):
        mods = wm._import_study()
        isa_doc = mods["isa_probe"].profile(self.events)
        fp = wm.fp_summary(wm.iter_events(self.events))
        r = wm.classify(isa_doc, fp, cycles_send=8000, kernel="synthetic")
        self.assertIsNotNone(r)
        # 1,000 FMACH x 16 elements x 2 FLOP / 8,000 cycles = 4.0 FLOP/cycle = 0.685 of 5.84
        self.assertAlmostEqual(r["flop_per_cycle"], 4.0, places=3)
        self.assertAlmostEqual(r["roofline_fraction_f16"], 4.0 / 5.84, places=3)
        self.assertEqual(r["cycles_denominator"], "cycles_send")
        self.assertGreaterEqual(r["f16_arith_pct"], 99.0)
        self.assertNotIn("model_f32_arith_only", r["model_keys"])
        self.assertNotIn("model_narrow_dsd", r["model_keys"])  # 16 elements/dispatch is wide
        self.assertTrue(r["readout_text"] if "readout_text" in r else wm.format_readout(r))

    def test_denominator_falls_back_to_dispatch_span(self):
        mods = wm._import_study()
        isa_doc = mods["isa_probe"].profile(self.events)
        fp = wm.fp_summary(wm.iter_events(self.events))
        r = wm.classify(isa_doc, fp, cycles_send=None)
        self.assertEqual(r["cycles_denominator"], "dispatch_span")

    def test_analyse_docs_matches_path_wrapper_on_study_profile(self):
        mods = wm._import_study()
        bn = mods["bottleneck"]
        prof = wm.study_root() / "results" / "isa-profiles" / "ReLU-1PE.json"
        if not prof.is_file():
            self.skipTest("study isa profile missing")
        via_path = bn.analyse(prof, wm.study_root() / "results" / "fabric-profiles" / "ReLU-1PE.json")
        via_doc = bn.analyse_docs(json.loads(prof.read_text()), app_pes=via_path.get("application_pes"),
                                  pct_bound=via_path.get("pct_of_lower_bound"), kernel="ReLU-1PE")
        self.assertEqual(via_path, via_doc)


class ModelKeysTest(unittest.TestCase):
    def test_key_mapping(self):
        r = {"bottleneck": "arithmetic_bound", "f16_arith_pct": 0.0, "float_pct": 12.0,
             "elements_per_dispatch": 1.1, "ipc": 0.5, "distinct_ut_ids": 1, "turns": 9,
             "pct_of_bound": 4.2}
        keys = wm.model_keys(r)
        for k in ("model_arithmetic_bound", "model_f32_arith_only", "model_narrow_dsd",
                  "model_low_ut_occupancy", "model_turns_present", "model_far_from_bound"):
            self.assertIn(k, keys)
        self.assertTrue(set(keys) <= set(wm.MODEL_KEYS))

    def test_spent_levers_are_not_flagged(self):
        r = {"bottleneck": "overhead_bound", "f16_arith_pct": 100.0, "float_pct": 3.0,
             "elements_per_dispatch": 13.5, "ipc": 0.9, "distinct_ut_ids": 6}
        keys = wm.model_keys(r)
        self.assertEqual(keys, ["model_overhead_bound"])

    def test_format_readout_respects_cap(self):
        r = {"bottleneck": "io_dominated", "ipc": 0.2, "float_pct": 1.0, "elements_per_dispatch": 2.0,
             "f16_arith_pct": 0.0, "roofline_fraction_f16": 0.01, "roofline_fraction_f32": 0.05,
             "distinct_ut_ids": 1, "recommended_fix": "x" * 2000}
        text = wm.format_readout(r, max_chars=300)
        self.assertLessEqual(len(text), 300)
        self.assertTrue(text.startswith("Silicon-model readout"))


class StudyAbsentTest(unittest.TestCase):
    def test_graceful_none_without_study(self):
        saved = os.environ.get("XKERNEL_WSE3_STUDY_ROOT")
        os.environ["XKERNEL_WSE3_STUDY_ROOT"] = "/nonexistent/study/root"
        wm._reset_for_tests()
        try:
            self.assertFalse(wm.study_available())
            self.assertIsNone(wm.build_readout("/nonexistent/bundle"))
        finally:
            if saved is None:
                os.environ.pop("XKERNEL_WSE3_STUDY_ROOT", None)
            else:
                os.environ["XKERNEL_WSE3_STUDY_ROOT"] = saved
            wm._reset_for_tests()


if __name__ == "__main__":
    unittest.main()
