"""IR/disassembly readout on real captured artifacts (fixtures/ir): the SDK 2.10 SpMV-CSR
program, the iremit study program with the f32 DSD-reduction hazard, and its disassembly."""
import json
import os
import shutil
import tempfile
import unittest
from pathlib import Path

import ir_readout as ir

F = Path(__file__).resolve().parent / "fixtures" / "ir"


class ParseIrTests(unittest.TestCase):
    def setUp(self):
        self.spmv = ir.parse_ir((F / "spmv_csr_sdk210.ll").read_text(), ("pe.csl",))
        self.iremit = ir.parse_ir((F / "iremit_excerpt.ll").read_text(), ("pe.csl",))

    def fn(self, parsed, name):
        return next(f for f in parsed["functions"] if f["name"] == name)

    def test_scalar_csr_spmv_shape(self):
        f = self.fn(self.spmv, "spmv_csr")
        self.assertEqual(f["file"], "pe.csl")
        self.assertEqual((f["loops"], f["max_loop_depth"]), (2, 2))
        self.assertEqual(f["dsd_compute_ops"], 0)
        self.assertGreaterEqual(f["indexed_gathers_in_loop"], 1)          # x[col_idx[j]]
        self.assertGreater(f["scalar_fp_ops_in_loop"], 0)
        self.assertEqual(f["reductions"], [])

    def test_compiler_internals_and_library_functions_excluded(self):
        names = [f["name"] for f in self.spmv["functions"]]
        self.assertNotIn(".teardown", names)
        self.assertFalse(any("memcpy" in n for n in names))
        self.assertIn("compute", names)

    def test_hazard_case_has_in_loop_f32_register_reduction_with_accumulator(self):
        f = self.fn(self.iremit, "spmv_blk_dsdred")
        reds = f["reductions"]
        self.assertEqual(len(reds), 1)
        self.assertEqual(reds[0]["intrinsic"], "llvm.sdr.fadds.rrs1")
        self.assertTrue(reds[0]["in_loop"]); self.assertTrue(reds[0]["f32"]); self.assertTrue(reds[0]["accumulator_pattern"])
        self.assertGreaterEqual(f["dsd_setup_in_loop"], 4)

    def test_vectorised_forms_have_dsd_ops(self):
        dia = self.fn(self.iremit, "spmv_dia")
        self.assertGreater(dia["dsd_compute_ops"], 0)
        scalar = self.fn(self.iremit, "spmv_scalar")
        self.assertEqual(scalar["dsd_compute_ops"], 0)
        self.assertEqual(scalar["max_loop_depth"], 2)


class DisasmTests(unittest.TestCase):
    def test_hazard_and_histogram(self):
        recs = json.load(open(F / "disasm_hazard.json"))["records"]
        d = ir.parse_disasm(recs, "pe.csl")
        self.assertEqual([hex(h["pc"]) for h in d["hazards"]], ["0x2a6"])
        self.assertTrue(d["hazards"][0]["f32"])
        self.assertGreater(d["dsd_ops"], 0)
        self.assertIsNotNone(d["shift_per_fp_mul"])
        self.assertIn("fadds", d["mnemonics"])

    def test_no_false_positive_on_accumulating_form(self):
        recs = [{"pc": 1, "instruction": "fadds d0 = d0, [s1ds1]", "source": "", "source_file": "pe.csl"},
                {"pc": 2, "instruction": "fadds d10 = d10, d0", "source": "", "source_file": "pe.csl"}]
        self.assertEqual(ir.parse_disasm(recs)["hazards"], [])


class BundleReadoutTests(unittest.TestCase):
    def make_bundle(self, with_ir=True, with_disasm=True):
        d = Path(tempfile.mkdtemp()); ird = d / ".xkernel_ir"
        if with_ir:
            (ird / "cap" / "out_out_0_0").mkdir(parents=True)
            shutil.copy(F / "iremit_excerpt.ll", ird / "cap" / "out_out_0_0" / "program.ll")
            (ird / "cap" / "out_east_out_0_0").mkdir(parents=True)
            (ird / "cap" / "out_east_out_0_0" / "program.ll").write_text("define void @plumbing() {\n  ret void\n}\n")
        if with_disasm:
            (ird / "disasm").mkdir(parents=True, exist_ok=True)
            shutil.copy(F / "disasm_hazard.json", ird / "disasm" / "out_0_0.json")
        return d

    def test_readout_keys_and_text(self):
        r = ir.build_ir_readout(self.make_bundle(), "pe.csl")
        self.assertEqual(r["schema"], "ir_readout/1")
        self.assertEqual(r["programs"], ["out_out_0_0"])                     # plumbing programs are skipped
        self.assertIn("ir_f32_reduction_candidate", r["ir_keys"])
        self.assertIn("ir_f32_reduction_hazard", r["ir_keys"])               # dest != src0 and an accumulator pattern
        self.assertEqual(r["hazards"][0]["severity"], "error")
        self.assertLessEqual(len(r["readout_text"]), 600)
        self.assertIn("hazards: f32_reduction_dest_ne_src0", r["readout_text"])

    def test_scalar_spmv_keys(self):
        d = Path(tempfile.mkdtemp()); (d / ".xkernel_ir" / "cap" / "out_out_0_0").mkdir(parents=True)
        shutil.copy(F / "spmv_csr_sdk210.ll", d / ".xkernel_ir" / "cap" / "out_out_0_0" / "program.ll")
        r = ir.build_ir_readout(d, "pe.csl")
        for k in ("ir_scalar_inner_loop", "ir_indexed_gather", "ir_no_dsd_ops"):
            self.assertIn(k, r["ir_keys"])
        self.assertNotIn("ir_f32_reduction_hazard", r["ir_keys"])

    def test_disasm_only_bundle(self):
        r = ir.build_ir_readout(self.make_bundle(with_ir=False), "pe.csl")
        self.assertEqual(r["functions"], [])
        self.assertEqual(r["hazards"][0]["severity"], "warning")          # no IR accumulator evidence -> warning only
        self.assertNotIn("ir_f32_reduction_hazard", r["ir_keys"])

    def test_no_artifacts(self):
        self.assertIsNone(ir.build_ir_readout(tempfile.mkdtemp(), "pe.csl"))
        self.assertIsNone(ir.build_ir_readout(self.make_bundle(with_ir=False, with_disasm=False), "pe.csl"))

    def test_keys_are_known(self):
        r = ir.build_ir_readout(self.make_bundle(), "pe.csl")
        self.assertTrue(set(r["ir_keys"]) <= set(ir.IR_KEYS))



class BranchHeavyTests(unittest.TestCase):
    """A two-pointer merge is branch-bound, not arithmetic-bound: a branch costs 9-10 cycles
    against ~1 for the rest (FINDINGS 10h). Calibrated on the suite's own disassembly,
    2026-09-20: masked SpGEMM 10-11 branches per fp multiply, scalar CSR SpMV 6-7, and the
    SpMM reference's arithmetic inner loop 1.0."""

    @staticmethod
    def _recs(branches, fpmuls, filler=0):
        r = [{"pc": i, "instruction": "jmp 0x10", "source_file": "pe.csl"} for i in range(branches)]
        r += [{"pc": 100 + i, "instruction": "fmuls d1 = d2, d3", "source_file": "pe.csl"} for i in range(fpmuls)]
        r += [{"pc": 200 + i, "instruction": "add16.nf d1 = d2, d3", "source_file": "pe.csl"} for i in range(filler)]
        return r

    def test_merge_shaped_body_is_flagged(self):
        dis = ir.parse_disasm(self._recs(11, 1, 130), "pe.csl")
        self.assertEqual(dis["branch_per_fp_mul"], 11.0)
        self.assertIn("ir_branch_heavy", ir.ir_keys({"functions": [], "disasm": dis, "hazards": []}))

    def test_arithmetic_inner_loop_is_not_flagged(self):
        dis = ir.parse_disasm(self._recs(16, 16, 340), "pe.csl")
        self.assertEqual(dis["branch_per_fp_mul"], 1.0)
        self.assertNotIn("ir_branch_heavy", ir.ir_keys({"functions": [], "disasm": dis, "hazards": []}))

    def test_no_floating_point_at_all_does_not_divide_by_zero(self):
        dis = ir.parse_disasm(self._recs(5, 0, 20), "pe.csl")
        self.assertIsNone(dis["branch_per_fp_mul"])
        self.assertNotIn("ir_branch_heavy", ir.ir_keys({"functions": [], "disasm": dis, "hazards": []}))

    def test_branch_counts_are_reported_beside_the_share(self):
        dis = ir.parse_disasm(self._recs(4, 2, 44), "pe.csl")
        self.assertEqual(dis["branches"], 4)
        self.assertAlmostEqual(dis["branch_share"], 4 / 50, places=3)

    def test_the_key_is_declared(self):
        self.assertIn("ir_branch_heavy", ir.IR_KEYS)


if __name__ == "__main__":
    unittest.main()
