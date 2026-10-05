"""Wafer-level mapping hook and per-PE readout (2026-09-30)."""
import importlib.util
import unittest
from pathlib import Path

from cuda2csl import ROW_ORDER_ANGLE_NOTE, ROW_ORDER_HOOK_NOTE, ROW_ORDER_OUTPUT_NOTE, fabric_readout
from workflow_common import extract_multi_file_blocks

XK = Path(__file__).resolve().parent.parent

STDOUT = """SpMV-RowBlock: P=4, nrows_pe=2, ncols=8, max_nnz_pe=8, iters=1, structure_id=0
row blocks: nnz per PE [6, 2, 2, 0]
cycles_send = 900 cycles
per-PE windows (cycles): [900, 500, 480, 300]
SUCCESS
"""


def _result(stdout):
    return {"status": "pass", "transcript": [{"step": "compile", "stdout": ""}, {"step": "run", "stdout": stdout}]}


class FabricReadoutTest(unittest.TestCase):
    def test_readout_reports_slowest_pe_floor_and_imbalance(self):
        fr = fabric_readout(_result(STDOUT))
        self.assertEqual(fr["slowest_pe"], 0)
        self.assertEqual(fr["slowest_cycles"], 900)
        self.assertEqual(fr["broadcast_floor"], 300)
        self.assertAlmostEqual(fr["imbalance"], 6 / (10 / 3), places=3)
        self.assertIn("struct_pe_imbalance", fr["keys"])
        self.assertIn("1 PEs hold no rows", fr["text"])

    def test_no_per_pe_windows_means_no_readout(self):
        self.assertIsNone(fabric_readout(_result("cycles_send = 5 cycles\nSUCCESS\n")))
        self.assertIsNone(fabric_readout(None))

    def test_row_order_block_is_extracted_from_a_reply(self):
        reply = ("```csl\nfn main() void {}\n```\n\n```python:row_order.py\n"
                 "def row_order(row_nnz, P, nrows_pe):\n    return list(range(len(row_nnz)))\n```\n")
        blocks = extract_multi_file_blocks(reply, "python")
        self.assertIn("row_order.py", blocks)
        self.assertIn("def row_order", blocks["row_order.py"])
        self.assertIn("python:row_order.py", ROW_ORDER_HOOK_NOTE)

    def test_output_rules_allow_the_hook_block(self):
        # correction #4: the template's closing rules must not forbid the second fence
        self.assertIn("python:row_order.py", ROW_ORDER_OUTPUT_NOTE)
        self.assertIn("Exception to the output rules", ROW_ORDER_OUTPUT_NOTE)
        self.assertIn("unchanged", ROW_ORDER_ANGLE_NOTE)


class ExpertRowOrderTest(unittest.TestCase):
    def setUp(self):
        path = XK / "kernels/_sparse_expert/SpMV-RowBlock/row_order.py"
        spec = importlib.util.spec_from_file_location("expert_row_order", path)
        self.mod = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(self.mod)

    def test_permutation_balances_blocks(self):
        row_nnz = [5, 5, 1, 1, 1, 1]           # equal blocks: [5,5] [1,1] [1,1] -> max 10
        P, nr = 3, 2
        perm = self.mod.row_order(row_nnz, P, nr)
        self.assertEqual(sorted(perm), list(range(len(row_nnz))))
        blocks = [sum(row_nnz[r] for r in perm[i:i + nr]) for i in range(0, len(perm), nr)]
        equal = [sum(row_nnz[i:i + nr]) for i in range(0, len(row_nnz), nr)]
        self.assertLess(max(blocks), max(equal))
        self.assertEqual(max(blocks), 6)

    def test_partial_last_block(self):
        perm = self.mod.row_order([3, 1, 4, 1, 5], 4, 2)
        self.assertEqual(sorted(perm), [0, 1, 2, 3, 4])


if __name__ == "__main__":
    unittest.main()
