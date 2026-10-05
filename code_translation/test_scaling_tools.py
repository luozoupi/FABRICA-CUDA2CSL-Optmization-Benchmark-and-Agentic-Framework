"""scale_retained / aggregate_scaling: PE-count rules, size discovery, CSV assembly (CPU only)."""
import json
import os
import tempfile
import unittest
from pathlib import Path

import aggregate_scaling as ag
import scale_retained as sr

REPO = Path(__file__).resolve().parents[1]


class PeCountTests(unittest.TestCase):
    def test_rules(self):
        self.assertEqual(sr.pe_count({"P": 4, "Mt": 14}), 16)
        self.assertEqual(sr.pe_count({"kernel_rows": 8, "kernel_cols": 8}), 64)
        self.assertEqual(sr.pe_count({"width": 2, "height": 2, "Mt": 16}), 4)
        self.assertIsNone(sr.pe_count({"n": 256}))
        self.assertEqual(sr.mesh_side({"P": 8}), 8)
        self.assertEqual(sr.mesh_side({"kernel_rows": 2, "kernel_cols": 2}), 2)

    def test_sizes_of_real_specs(self):
        gemm = sr.sizes_of(REPO / "kernels" / "GEMM")
        names = {s["name"]: s for s in gemm}
        self.assertEqual(set(names), {"small", "large", "p2", "p8_t14"})
        self.assertEqual(names["p8_t14"]["pes"], 64)
        self.assertEqual(names["p2"]["ref_cycles"], 25712)
        qp = {s["name"]: s for s in sr.sizes_of(REPO / "kernels" / "Attention-QP")}
        self.assertEqual([qp[n]["pes"] for n in ("p2", "small", "p8")], [4, 16, 64])


class AggregateTests(unittest.TestCase):
    def test_csv_assembly(self):
        with tempfile.TemporaryDirectory() as d:
            sc = Path(d) / "scaling.json"
            sc.write_text(json.dumps({"rows": [
                {"kernel": "GEMM", "series": "O1", "seed": 1, "size": "small", "P": 4, "pes": 16, "status": "pass", "cycles": 40000},
                {"kernel": "GEMM", "series": "O1", "seed": 2, "size": "small", "P": 4, "pes": 16, "status": "pass", "cycles": 42000},
                {"kernel": "GEMM", "series": "O1", "seed": 1, "size": "p8_t14", "P": 8, "pes": 64, "status": "compile_fail", "cycles": None},
                {"kernel": "GEMM", "series": "O0", "seed": 1, "size": "small", "P": 4, "pes": 16, "status": "verify_fail", "cycles": None},
            ]}))
            ex = Path(d) / "expert.json"
            ex.write_text(json.dumps([{"kernel": "GEMM", "P": 4, "pes": 16, "size": "small", "cycles": 122770, "platform": "sim"}]))
            hw = Path(d) / "hw.json"
            hw.write_text(json.dumps([
                {"kernel": "GEMM", "label": "O1__small/seed_1", "arms": {"hw": {"status": "pass", "cycles_send": 43000}}},
                {"kernel": "GEMM", "label": "O1__p8_t14/seed_1", "arms": {"hw": {"status": "compile_fail"}}},
                {"kernel": "GEMM", "label": "O1__small/seed_1", "pass_kind": "reference",
                 "arms": {"hw": {"status": "pass", "cycles_send": 52000}}},
            ]))
            out = Path(d) / "ipdps_scaling.csv"
            import sys
            argv = sys.argv
            sys.argv = ["aggregate_scaling.py", "--scaling", str(sc), "--expert", str(ex), "--hw", str(hw), "--out", str(out)]
            try:
                self.assertEqual(ag.main(), 0)
            finally:
                sys.argv = argv
            import csv
            rows = list(csv.DictReader(open(out)))
        ref = [r for r in rows if r["series"] == "reference"]
        self.assertEqual({r["size"] for r in ref}, {"small", "large", "p2", "p8_t14"})
        o1_small = next(r for r in rows if r["series"] == "O1" and r["size"] == "small" and r["platform"] == "sim")
        self.assertEqual(o1_small["cycles"], "41000")      # median of two seeds
        o1_p8 = next(r for r in rows if r["series"] == "O1" and r["size"] == "p8_t14" and r["platform"] == "sim")
        self.assertEqual((o1_p8["status"], o1_p8["cycles"]), ("compile_fail", ""))
        o0 = next(r for r in rows if r["series"] == "O0")
        self.assertEqual(o0["status"], "verify_fail")
        self.assertTrue(any(r["series"] == "expert" and r["cycles"] == "122770" for r in rows))
        hw_rows = [r for r in rows if r["platform"] == "hw"]
        self.assertEqual({(r["series"], r["size"], r["status"], r["cycles"]) for r in hw_rows},
                         {("O1", "small", "pass", "43000"), ("O1", "p8_t14", "compile_fail", ""),
                          ("reference", "small", "pass", "52000")})

    def test_pseudo_run_tree_is_harvestable(self):
        import hw_replay
        with tempfile.TemporaryDirectory() as d:
            prog = Path(d) / "prog.csl"; prog.write_text("// program")
            kdir = REPO / "kernels" / "GEMM"
            size = {"name": "p2", "params": {"P": 2}, "commands_script": "commands_wse3_p2.sh"}
            root = Path(d) / "scaling_x"
            sr.write_pseudo_run(root, "GEMM", {"arm": "O1", "seed": 3, "program": str(prog), "target_relpath": "pe.csl"},
                                size, kdir, {"status": "pass", "cycles": 24000, "cycles_runs": [24000]})
            sr.write_pseudo_run(root, "GEMM", {"arm": "O0", "seed": 1, "program": str(prog), "target_relpath": "pe.csl"},
                                size, kdir, {"status": "compile_fail", "cycles": None})
            found = hw_replay.harvest(root)
        self.assertEqual(len(found), 1)                       # only the passing scaled program
        self.assertEqual(found[0]["label"], "O1__p2/seed_3")
        self.assertEqual(found[0]["commands_script"], "commands_wse3_p2.sh")
        self.assertEqual(found[0]["sweep_sim_cycles"], 24000)


if __name__ == "__main__":
    unittest.main()
