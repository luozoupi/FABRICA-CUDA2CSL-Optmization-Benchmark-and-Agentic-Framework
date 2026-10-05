from __future__ import annotations

import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from wse3study.single_pe import analyze_single_pe, enrich_trial  # noqa: E402


class SinglePeTests(unittest.TestCase):
    def test_enriches_fma_throughput(self) -> None:
        row = enrich_trial(
            {
                "operation": "fma",
                "dtype": "fp32",
                "vector_length": 100,
                "elapsed_cycles": 50,
                "evidence": "silicon",
            }
        )
        self.assertEqual(4.0, row["operations_per_cycle"])
        self.assertEqual(32.0, row["bytes_per_cycle"])

    def test_effective_elements_count_independent_work_lanes(self) -> None:
        row = enrich_trial(
            {
                "operation": "add",
                "dtype": "fp32",
                "vector_length": 8,
                "effective_elements": 32,
                "elapsed_cycles": 16,
            }
        )
        self.assertEqual(2.0, row["operations_per_cycle"])
        self.assertEqual(24.0, row["bytes_per_cycle"])
        self.assertEqual(0.5, row["cycles_per_element"])

    def test_classifies_mimd_and_sram_ceiling(self) -> None:
        result = analyze_single_pe(
            [
                {
                    "family": "single-pe-throughput",
                    "operation": "add",
                    "dtype": "fp32",
                    "mode": "scalar",
                    "vector_length": 8,
                    "elapsed_cycles": 16,
                    "correctness": True,
                },
                {
                    "family": "single-pe-sram",
                    "allocation_bytes": 45056,
                    "status": "compiled",
                },
                {
                    "family": "single-pe-sram",
                    "allocation_bytes": 46080,
                    "status": "compile_fail",
                },
            ],
            instruction_events=[
                {"opcode": "FADD", "simd_width": 8},
                {"opcode": "FMUL", "simdi": 7},
            ],
        )
        self.assertFalse(result["execution_model"]["is_cuda_simt"])
        self.assertEqual(45056, result["sram_ceiling"]["largest_compiling_allocation_bytes"])
        self.assertEqual([8], result["observed_simd_widths"]["FADD"])
        self.assertNotIn("FMUL", result["observed_simd_widths"])


if __name__ == "__main__":
    unittest.main()
