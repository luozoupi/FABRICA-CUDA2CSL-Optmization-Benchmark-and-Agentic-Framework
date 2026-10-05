import unittest
from pathlib import Path
from csl_templates import select_template


class SparseTemplateInterfaceTests(unittest.TestCase):
    def test_symbolic_sparse_mesh_is_not_single_pe(self):
        root = Path(__file__).resolve().parents[1]
        for name in ("SpMV-RowBlock", "SpMM-CSR-Dense"):
            self.assertIsNone(select_template((root / "kernels" / name / "CSL/layout.csl").read_text()))

    def test_literal_single_pe_keeps_template(self):
        self.assertEqual(select_template('@set_rectangle(1, 1); @export_name("compute", fn()void);'), 'single_pe')

    def test_unknown_rectangle_does_not_invent_one_pe(self):
        self.assertIsNone(select_template('@set_rectangle(W, H);'))


if __name__ == '__main__': unittest.main()
