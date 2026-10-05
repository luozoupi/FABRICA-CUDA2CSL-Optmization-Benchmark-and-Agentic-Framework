"""Verified sparse building blocks (sparse_blocks/, gate XKERNEL_SPARSE_BLOCKS)."""
import glob
import json
import os
import re
import unittest

import importlib

import sparse_blocks as sb

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
S_TASKS = ["SpMV-RowBlock", "SpMM-CSR-Dense", "SpGEMM-Masked-Dot", "RowScale-CSR", "ColScale-CSR",
           "RowReduce-CSR", "SpMV-CSR", "SpMV-RowBlock-Iter", "SpMV-CSR-Block"]


def _norm_lines(text):
    out = set()
    for ln in text.splitlines():
        code = re.sub(r"//.*", "", ln)
        code = re.sub(r"\s+", "", code)
        if len(code) >= 30:          # long enough to identify copied code, not a generic one-liner
            out.add(code)
    return out


class TestSparseBlocks(unittest.TestCase):
    def test_blocks_for_three_strategies(self):
        for angle in sb.BLOCKS:
            t = sb.block_text(angle)
            self.assertIn("```csl", t, angle)
            self.assertIn("VERIFIED BUILDING BLOCK", t)
            self.assertTrue(sb.selector_note(angle).startswith("verified block, measured"), angle)
        for other in ("dsd_setup_hoist", "comptime_hoist", "nnz_balanced_row_partition", "nope"):
            self.assertEqual(sb.block_text(other), "")
            self.assertEqual(sb.selector_note(other), "")

    def test_regions_are_in_the_verified_toy(self):
        toy = open(os.path.join(os.path.dirname(sb.__file__), "toy", "pe.csl")).read()
        for regions, _ in sb.BLOCKS.values():
            for r in regions:
                self.assertIn(sb.region(r).strip(), toy)

    def test_every_served_method_verified(self):
        v = json.load(open(os.path.join(os.path.dirname(sb.__file__), "verified.json")))["configs"]
        self.assertEqual(set(v), {"banded_5diag_n128", "banded_25diag_n64"})
        for cfg in v.values():
            self.assertTrue(cfg["blocks_ok"])
            self.assertEqual(cfg["status"], "pass")
            self.assertTrue(all(m["correct"] for m in cfg["methods"]))

    def test_gate_default_off(self):
        old = os.environ.pop("XKERNEL_SPARSE_BLOCKS", None)
        try:
            self.assertFalse(sb.enabled())
        finally:
            if old is not None:
                os.environ["XKERNEL_SPARSE_BLOCKS"] = old

    def test_no_reference_or_expert_line(self):
        blocks = set()
        for angle in sb.BLOCKS:
            blocks |= _norm_lines(sb.block_text(angle))
        files = [p for t in S_TASKS for p in glob.glob(os.path.join(ROOT, "kernels", t, "CSL", "*.csl"))]
        files += glob.glob(os.path.join(ROOT, "kernels", "_sparse_expert", "**", "*.csl"), recursive=True)
        self.assertGreater(len(files), 8)
        for f in files:
            common = blocks & _norm_lines(open(f, encoding="utf-8").read())
            self.assertEqual(common, set(), f"{f} shares lines with a building block: {sorted(common)[:3]}")

    def test_cuda2csl_uses_blocks_only_behind_the_gate(self):
        src = open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "cuda2csl.py")).read()
        for call in ("sparse_blocks.block_text(", "sparse_blocks.selector_note("):
            for m in re.finditer(re.escape(call), src):
                window = src[max(0, m.start() - 200):m.start()]
                self.assertIn("if getattr(self, \"sparse_blocks\", False):", window, call)


class TestSparseBlocksV2(TestSparseBlocks):
    """Version 2 (sparse_blocks_v2/): same contract, plus the window rule and the row-range clamp."""

    def setUp(self):
        global sb
        self._v1 = sb
        sb = importlib.import_module("sparse_blocks_v2")

    def tearDown(self):
        global sb
        sb = self._v1

    def test_gate_default_off(self):
        old = os.environ.pop("XKERNEL_SPARSE_BLOCKS", None)
        try:
            self.assertFalse(sb.enabled())
            os.environ["XKERNEL_SPARSE_BLOCKS"] = "1"
            self.assertFalse(sb.enabled())
            os.environ["XKERNEL_SPARSE_BLOCKS"] = "2"
            self.assertTrue(sb.enabled())
        finally:
            os.environ.pop("XKERNEL_SPARSE_BLOCKS", None)
            if old is not None:
                os.environ["XKERNEL_SPARSE_BLOCKS"] = old

    def test_window_rule_and_clamp(self):
        t = sb.block_text("vectorise_along_structure")
        self.assertIn("never before the timing window opens", t)
        self.assertIn("if (hi < lo) { hi = lo; }", t)


class TestSparseBlocksV3(TestSparseBlocksV2):
    """Version 3 (sparse_blocks_v3/): storage formats; verdicts computed from the toy's measurements."""

    def setUp(self):
        global sb
        self._v1 = sb
        sb = importlib.import_module("sparse_blocks_v3")

    def test_regions_are_in_the_verified_toy(self):
        toy = open(os.path.join(os.path.dirname(sb.__file__), "toy", "pe.csl")).read()
        for region, _method, _config, _matrix in sb.BLOCKS.values():
            self.assertIn(sb.region(region).strip(), toy)

    def test_every_served_method_verified(self):
        v = json.load(open(os.path.join(os.path.dirname(sb.__file__), "verified.json")))["configs"]
        for _region, method, config, _matrix in sb.BLOCKS.values():
            rows = v[config]["rows"]
            for m in (method, "csr"):
                self.assertEqual({r["products"] for r in rows if r["method"] == m}, {1, 10}, (config, m))
            self.assertTrue(all(r["correct"] for r in rows), config)

    def test_gate_default_off(self):
        old = os.environ.pop("XKERNEL_SPARSE_BLOCKS", None)
        try:
            self.assertFalse(sb.enabled())
            for val, on in (("1", False), ("2", False), ("3", True)):
                os.environ["XKERNEL_SPARSE_BLOCKS"] = val
                self.assertEqual(sb.enabled(), on, val)
        finally:
            os.environ.pop("XKERNEL_SPARSE_BLOCKS", None)
            if old is not None:
                os.environ["XKERNEL_SPARSE_BLOCKS"] = old

    def test_window_rule_and_clamp(self):
        t = sb.block_text("vectorise_along_structure")
        self.assertIn("never before the timing window opens", t)
        self.assertIn("if (hi < lo) { hi = lo; }", t)
        self.assertIn("ci[w] = ci[j]; va[w] = va[j]; w += 1;", t)       # compacted in place, no copy
        for angle in sb.BLOCKS:                                           # keep the wrapper's callee
            self.assertIn("keep this kernel's existing kernel function", sb.block_text(angle))

    def test_verdicts_quote_the_measurement(self):
        for angle in ("dense_tile_format", "block_sparse_format"):
            note = sb.selector_note(angle)
            self.assertRegex(note, r"\d+\.\d\dx faster than the scalar CSR loop per product", angle)
            self.assertIn("breaks even after", note)
        self.assertEqual(sb.block_text("row_dsd_runtime_repoint"),
                         importlib.import_module("sparse_blocks_v2").block_text("row_dsd_runtime_repoint"))

    def test_economics_from_rows(self):
        # cycles(k) = conversion + k * sweep: CSR 1000/product; method 300/product + 1400 conversion
        rows = [{"method": "csr", "products": 1, "cycles": 1000, "correct": True},
                {"method": "csr", "products": 10, "cycles": 10000, "correct": True},
                {"method": "m", "products": 1, "cycles": 1700, "correct": True},
                {"method": "m", "products": 10, "cycles": 4400, "correct": True}]
        import tempfile
        with tempfile.NamedTemporaryFile("w", suffix=".json", delete=False) as fh:
            json.dump({"configs": {"c": {"rows": rows}}}, fh)
        old = sb._VERIFIED
        try:
            sb._VERIFIED = fh.name
            gain, conv, be, g10 = sb._economics("m", "c")
            self.assertAlmostEqual(gain, 1000 / 300)
            self.assertAlmostEqual(conv, 1.4)
            self.assertAlmostEqual(be, 2.0)
            self.assertAlmostEqual(g10, 10000 / 4400)
            rows[2]["correct"] = False
            json.dump({"configs": {"c": {"rows": rows}}}, open(fh.name, "w"))
            self.assertIsNone(sb._economics("m", "c"))     # a wrong result serves no block
        finally:
            sb._VERIFIED = old
            os.unlink(fh.name)


if __name__ == "__main__":
    unittest.main()
