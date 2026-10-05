"""The static bottleneck signature's sparse keys: only under XKERNEL_SPARSE_ANGLES=1, and only
for the CSR `while`-loop gather idiom."""
import os
import unittest
from pathlib import Path
from unittest import mock

import cuda2csl

REPO = Path(__file__).resolve().parents[1]
SPMV = (REPO / "kernels" / "SpMV-CSR" / "CSL" / "pe.csl").read_text()
ROWSCALE = (REPO / "kernels" / "RowScale-CSR" / "CSL" / "pe.csl").read_text()   # no gather: d[r] indexes the loop var


class StaticSparseSignatureTests(unittest.TestCase):
    def test_gate_off_adds_nothing(self):
        with mock.patch.dict(os.environ, {"XKERNEL_SPARSE_ANGLES": "0"}):
            sig = cuda2csl.CUDA2CSLOrchestrator._profile_bottleneck_signature(SPMV)
        self.assertNotIn("scalar_gather_loop", sig["bottlenecks"]); self.assertNotIn("u32_index_arith", sig["bottlenecks"])

    def test_csr_gather_detected_under_gate(self):
        with mock.patch.dict(os.environ, {"XKERNEL_SPARSE_ANGLES": "1"}):
            sig = cuda2csl.CUDA2CSLOrchestrator._profile_bottleneck_signature(SPMV)
            self.assertGreaterEqual(sig["bottlenecks"].get("scalar_gather_loop", 0), 1)
            self.assertGreaterEqual(sig["bottlenecks"].get("u32_index_arith", 0), 2)
            sig2 = cuda2csl.CUDA2CSLOrchestrator._profile_bottleneck_signature(ROWSCALE)
            self.assertNotIn("scalar_gather_loop", sig2["bottlenecks"])


if __name__ == "__main__":
    unittest.main()
