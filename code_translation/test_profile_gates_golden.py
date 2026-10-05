"""Gates off == today's prompt, byte for byte; gates on add exactly the readout lines."""
import json
import os
import unittest
from unittest import mock

import profile_csl as pc


def base_profile(extra_artifacts=None):
    arts = {"available": True, "elf_count": 1, "sim_log_count": 1, "simfab_trace_dir_count": 1,
            "sim_log_parsed": {"bottleneck_label": "compute-bound"}, "model_readout": None}
    arts.update(extra_artifacts or {})
    return {"profile_status": "pass", "target_sdk": "1.4.0", "arch": "wse3",
            "benchmark": {"status": "pass", "cycles_send": 1234, "time_send_us": 1.45, "compile_time_ms": 10,
                          "run_time_ms": 20, "success_marker": True},
            "artifacts": arts, "insights": []}


IR_ART = {"schema": "ir_readout/1", "readout_text": "IR/disasm readout (compiled; pe.csl); x: 2 loop(s)",
          "ir_keys": ["ir_scalar_inner_loop"], "hazards": []}
ST_ART = {"schema": "structure_readout/1", "readout_text": "Structure readout (train input)\n  matrix HB/x: 10 x 10",
          "keys": ["struct_short_rows"], "features": {}}


class GoldenTests(unittest.TestCase):
    def setUp(self):
        self._env = {k: os.environ.pop(k, None) for k in ("XKERNEL_IR_READOUT", "XKERNEL_STRUCTURE_READOUT", "XKERNEL_MODEL_GUIDED")}

    def tearDown(self):
        for k, v in self._env.items():
            os.environ.pop(k, None)
            if v is not None:
                os.environ[k] = v

    def test_gates_off_prompt_is_unchanged_by_new_artifacts(self):
        plain = pc.format_profile_for_prompt(base_profile())
        with_new = pc.format_profile_for_prompt(base_profile({"ir_readout": IR_ART, "structure_readout": ST_ART}))
        self.assertEqual(plain, with_new)
        self.assertNotIn("- ir:", plain); self.assertNotIn("- structure:", plain)
        self.assertEqual(pc._classify_bottlenecks(base_profile()["benchmark"], base_profile({"ir_readout": IR_ART, "structure_readout": ST_ART})["artifacts"], "1.4.0", "wse3"),
                         pc._classify_bottlenecks(base_profile()["benchmark"], base_profile()["artifacts"], "1.4.0", "wse3"))

    def test_gates_on_add_the_lines_and_insights(self):
        with mock.patch.dict(os.environ, {"XKERNEL_IR_READOUT": "1", "XKERNEL_STRUCTURE_READOUT": "1"}):
            txt = pc.format_profile_for_prompt(base_profile({"ir_readout": IR_ART, "structure_readout": ST_ART}))
            self.assertIn("- ir: IR/disasm readout", txt)
            self.assertIn("- structure: Structure readout (train input)   matrix HB/x", txt)
            ins = pc._classify_bottlenecks(base_profile()["benchmark"], base_profile({"ir_readout": IR_ART, "structure_readout": ST_ART})["artifacts"], "1.4.0", "wse3")
            cats = [i["category"] for i in ins]
            self.assertIn("ir_readout", cats); self.assertIn("input_structure", cats)
            hz = dict(IR_ART, hazards=[{"severity": "error", "kind": "f32_reduction_dest_ne_src0", "pc": 678, "instruction": "fadds d12 = d0, [s1ds1]"}])
            ins2 = pc._classify_bottlenecks(base_profile()["benchmark"], base_profile({"ir_readout": hz})["artifacts"], "1.4.0", "wse3")
            self.assertEqual(next(i for i in ins2 if i["category"] == "ir_readout")["severity"], "error")

    def test_structure_from_transcript(self):
        feats = {"n": 4, "m": 4, "nnz": 7, "density": 0.4375, "row_len_mean": 1.75, "row_len_max": 3, "row_len_min": 1,
                 "row_len_cv": 0.5, "empty_rows_frac": 0.0, "bandwidth": 2, "band95": 2, "frac_within_band1": 0.5,
                 "n_diagonals": 4, "n_diagonals_for_90pct": 3, "contiguous_run_rows_frac": 0.75, "symmetric_pattern": False,
                 "block_density_4x4": 0.4, "accumulator_fits": True, "keys": ["struct_short_rows"]}
        tr = [{"step": "run", "stdout": "hello\nxkernel_structure = " + json.dumps(feats) + "\ncycles_send = 5 cycles\n"}]
        st = pc._structure_from_transcript(tr)
        self.assertEqual(st["keys"], ["struct_short_rows"])
        self.assertIn("4 x 4, nnz 7", st["readout_text"])
        self.assertIsNone(pc._structure_from_transcript([{"stdout": "nothing here"}]))


if __name__ == "__main__":
    unittest.main()
