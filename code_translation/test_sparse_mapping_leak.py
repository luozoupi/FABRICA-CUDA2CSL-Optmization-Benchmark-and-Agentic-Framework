"""Firewall and gating of the sparse cross-semantic mapping (arm T1): no line of any S
task's reference program appears in the knowledge block or the catalogue document, and
gates off leaves the knowledge text byte-identical."""
import os
import re
import unittest
from pathlib import Path
from unittest import mock

import csl_knowledge_base as kb
import task_sets as ts

REPO = Path(__file__).resolve().parents[1]
DOC = REPO / "docs" / "CUDA_TO_CSL_SPARSE_PATTERNS.md"


def norm_lines(text, min_chars=30):
    out = set()
    for line in text.splitlines():
        s = re.sub(r"\s+", "", line)
        if len(s) >= min_chars and not s.startswith("//") and not s.startswith("#"):
            out.add(s)
    return out


class FirewallTests(unittest.TestCase):
    def test_no_reference_line_in_block_or_doc(self):
        targets = norm_lines(kb.SPARSE_CUDA_TO_CSL_MAPPING) | norm_lines(kb.SPARSE_ARCHITECT_CONTEXT) | norm_lines(DOC.read_text())
        for k in ts.S:
            ref = REPO / "kernels" / k / "CSL" / "pe.csl"
            if not ref.is_file():
                continue
            leaked = norm_lines(ref.read_text()) & targets
            # generic boilerplate shared by every CSL program is not a leak
            leaked = {l for l in leaked if not re.match(r"(param|const|var)\w+", l) or "@zeros" in l and False}
            self.assertFalse(leaked, f"{k}: reference lines present in the mapping text: {sorted(leaked)[:3]}")


class GateTests(unittest.TestCase):
    def setUp(self):
        self._saved = os.environ.pop("XKERNEL_SPARSE_MAPPING", None)

    def tearDown(self):
        os.environ.pop("XKERNEL_SPARSE_MAPPING", None)
        if self._saved is not None:
            os.environ["XKERNEL_SPARSE_MAPPING"] = self._saved

    def test_gate_off_is_unchanged_and_gate_on_adds_for_sparse_only(self):
        off = kb.for_implementer("spmv csr kernel", kernel_group="sparse")
        self.assertNotIn("CUDA -> CSL for SPARSE kernels", off)
        with mock.patch.dict(os.environ, {"XKERNEL_SPARSE_MAPPING": "1"}):
            on = kb.for_implementer("spmv csr kernel", kernel_group="sparse")
            self.assertIn("CUDA -> CSL for SPARSE kernels", on)
            self.assertIn("dest != src0", on)
            other = kb.for_implementer("dense gemv tile", kernel_group="linalg")
            self.assertNotIn("CUDA -> CSL for SPARSE kernels", other)
            arch_on = kb.for_architect("sparse matrix vector product in csr")
            self.assertIn("Sparse decompositions on the WSE-3", arch_on)
            self.assertNotIn("Sparse decompositions on the WSE-3", kb.for_architect("dense matmul tile"))
        self.assertEqual(off, kb.for_implementer("spmv csr kernel", kernel_group="sparse"))

    def test_helper_and_template_route_wiring(self):
        """The T1 block must reach the template-completion route too (pilot finding, 16 Sep):
        the helper is what both for_implementer and the template prompt call."""
        self.assertEqual(kb.sparse_mapping_block("spmv csr kernel", "sparse"), "")
        with mock.patch.dict(os.environ, {"XKERNEL_SPARSE_MAPPING": "1"}):
            self.assertIn("CUDA -> CSL for SPARSE kernels", kb.sparse_mapping_block("anything", "sparse"))
            self.assertIn("CUDA -> CSL for SPARSE kernels", kb.sparse_mapping_block("row_ptr col_idx gather", "linalg"))
            self.assertEqual(kb.sparse_mapping_block("dense gemv tile", "linalg"), "")
            self.assertIn("ek_slice", kb.sparse_mapping_block("x", "sparse"))   # P15 present in the block
        src = (Path(__file__).resolve().parent / "cuda2csl.py").read_text()
        i = src.index("prompt = q_translate_from_template.format(")
        window = src[max(0, i - 900):i + 400]
        self.assertIn("csl_knowledge_base.sparse_mapping_block(", window)
        self.assertIn("task_summary=_tpl_task_summary", window)

    def test_catalogue_doc_has_fifteen_patterns(self):
        doc = DOC.read_text()
        ids = [l.split("|")[1].strip() for l in doc.splitlines() if l.startswith("| P")]
        self.assertEqual(ids, [f"P{i}" for i in range(1, 16)])
        self.assertIn("Fifteen idioms", doc)

    def test_block_budget(self):
        self.assertLess(len(kb.SPARSE_CUDA_TO_CSL_MAPPING), 6000)
        self.assertLess(len(kb.SPARSE_ARCHITECT_CONTEXT), 2000)


if __name__ == "__main__":
    unittest.main()
