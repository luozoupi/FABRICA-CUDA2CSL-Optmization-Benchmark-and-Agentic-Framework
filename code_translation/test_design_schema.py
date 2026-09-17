"""Tests for design_schema — structured DESIGN.md validator."""

import unittest

from design_schema import (
    DesignFacts,
    LayoutContract,
    TensorShard,
    parse_design,
    parse_layout_contract,
    validate_and_augment,
    validate_design,
)


class TestParseDesign(unittest.TestCase):

    def test_single_pe_design(self):
        text = """### 1. Mesh and tensor layout
This is a single-PE kernel (1×1 mesh). No decomposition needed.

### 2. Algorithm and data flow
Step 1: Load input array from host via memcpy.
Step 2: Apply ReLU element-wise (compare with zero, select max).
Step 3: Store result back via memcpy.

### 3. Memory budget
Input: 1024 floats × 4 bytes = 4 KB
Output: 1024 floats × 4 bytes = 4 KB
Total: 8 KB per PE (well within 48 KB limit)

### 7. Edge cases
- All-zero input: should produce all zeros (no sign issues with IEEE floats).
- Negative infinity: max(0, -inf) = 0, correct by IEEE rules.
"""
        facts = parse_design(text)
        self.assertEqual(facts.mesh_shape, (1, 1))
        self.assertTrue(facts.is_single_pe)
        self.assertIsNotNone(facts.memory_budget_kb)
        self.assertAlmostEqual(facts.memory_budget_kb, 8.0)
        self.assertGreater(len(facts.algorithm_steps), 0)
        self.assertGreater(len(facts.edge_cases), 0)

    def test_multi_pe_design(self):
        text = """### 1. Mesh and tensor layout
5×5 mesh of PEs. Matrix A is row-tiled; each PE owns Mt = 32/5 ≈ 6 rows.
Vector x is broadcast along Y axis.

### 2. Algorithm
Step 1: broadcast x along Y.
Step 2: local GEMV on each PE's tile.
Step 3: reduce partial sums along X using collectives_2d.

### 3. Memory budget
A_tile: 6 × 16 × 4 = 384 bytes
x: 16 × 4 = 64 bytes
Total: ~0.5 KB per PE

### 5. Collective library choice
Using <collectives_2d> for row/column reduction (simpler, acceptable overhead).

### 7. Edge cases
- Matrix rows not divisible by kernel_rows: last PE gets fewer rows, pad with zeros.
"""
        facts = parse_design(text)
        self.assertEqual(facts.mesh_shape, (5, 5))
        self.assertFalse(facts.is_single_pe)
        self.assertEqual(facts.collective_choice, "collectives_2d")
        self.assertGreater(len(facts.algorithm_steps), 0)
        self.assertGreater(len(facts.edge_cases), 0)

    def test_mesh_from_px_py(self):
        text = "The layout declares Px = 3, Py = 4 PEs."
        facts = parse_design(text)
        self.assertEqual(facts.mesh_shape, (3, 4))

    def test_memory_from_bytes(self):
        text = "Total per-PE memory budget: 24576 bytes total."
        facts = parse_design(text)
        self.assertAlmostEqual(facts.memory_budget_kb, 24.0)


class TestParseLayoutContract(unittest.TestCase):

    def test_basic_layout(self):
        layout = """
const kernel_rows = 5;
const kernel_cols = 5;
@export_symbol("compute")
@export_symbol("main")
@import_module("<collectives_2d/pe>", c2d_params)
.width = 5,
.height = 5,
.Mt = Mt,
.Nt = Nt,
"""
        contract = parse_layout_contract(layout)
        self.assertEqual(contract.mesh_width, 5)
        self.assertEqual(contract.mesh_height, 5)
        self.assertIn("compute", contract.exported_symbols)
        self.assertIn("main", contract.exported_symbols)
        self.assertIn("<collectives_2d/pe>", contract.imported_modules)

    def test_single_pe_layout(self):
        layout = """
const width = 1;
const height = 1;
@export_symbol("main")
"""
        contract = parse_layout_contract(layout)
        self.assertEqual(contract.mesh_width, 1)
        self.assertEqual(contract.mesh_height, 1)


class TestValidation(unittest.TestCase):

    def test_mesh_mismatch_error(self):
        facts = DesignFacts(mesh_shape=(3, 3), is_single_pe=False)
        contract = LayoutContract(mesh_width=5, mesh_height=5)
        result = validate_design(facts, contract)
        self.assertFalse(result.ok)
        self.assertTrue(any("Mesh shape mismatch" in e for e in result.errors))

    def test_mesh_match_ok(self):
        facts = DesignFacts(mesh_shape=(5, 5), is_single_pe=False,
                            collective_choice="collectives_2d",
                            algorithm_steps=["step1"], edge_cases=["edge1"])
        contract = LayoutContract(mesh_width=5, mesh_height=5)
        result = validate_design(facts, contract)
        self.assertTrue(result.ok)

    def test_memory_over_budget_error(self):
        facts = DesignFacts(memory_budget_kb=55.0,
                            algorithm_steps=["s1"], edge_cases=["e1"])
        contract = LayoutContract(pe_memory_kb=48.0)
        result = validate_design(facts, contract)
        self.assertFalse(result.ok)
        self.assertTrue(any("Memory budget" in e for e in result.errors))

    def test_memory_warning_above_40(self):
        facts = DesignFacts(memory_budget_kb=42.0,
                            algorithm_steps=["s1"], edge_cases=["e1"])
        contract = LayoutContract(pe_memory_kb=48.0)
        result = validate_design(facts, contract)
        self.assertTrue(result.ok)
        self.assertTrue(any("40 KB" in w for w in result.warnings))

    def test_missing_edge_cases_warning(self):
        facts = DesignFacts(algorithm_steps=["step1"])
        contract = LayoutContract()
        result = validate_design(facts, contract)
        self.assertTrue(result.ok)
        self.assertTrue(any("edge case" in w.lower() for w in result.warnings))

    def test_collectives_warning(self):
        facts = DesignFacts(mesh_shape=(5, 5), is_single_pe=False,
                            algorithm_steps=["s1"], edge_cases=["e1"])
        contract = LayoutContract(
            mesh_width=5, mesh_height=5,
            imported_modules=["<collectives_2d/pe>"],
        )
        result = validate_design(facts, contract)
        self.assertTrue(any("collectives_2d" in w for w in result.warnings))


class TestValidateAndAugment(unittest.TestCase):

    def test_augments_valid_design(self):
        design = """### 1. Mesh
Single-PE kernel (1×1).
### 2. Algorithm
Step 1: load. Step 2: compute. Step 3: store.
### 3. Memory
Total: 8 KB per PE.
### 7. Edge cases
- All zeros handled correctly.
"""
        layout = "const width = 1;\nconst height = 1;\n"
        augmented, vr = validate_and_augment(design, layout)
        self.assertTrue(vr.ok)
        self.assertIn("VALIDATED DESIGN FACTS", augmented)

    def test_error_block_on_mesh_mismatch(self):
        design = "### 1. Mesh\n3×3 mesh of PEs.\n"
        layout = "const kernel_rows = 5;\nconst kernel_cols = 5;\n"
        augmented, vr = validate_and_augment(design, layout)
        self.assertFalse(vr.ok)
        self.assertIn("DESIGN VALIDATION ERRORS", augmented)


if __name__ == "__main__":
    unittest.main()
