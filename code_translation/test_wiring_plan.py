"""Tests for wiring_plan — two-layer IR for CUDA→CSL translation."""

import unittest

from wiring_plan import (
    BufferDecl,
    CUDASemantics,
    ColorAssignment,
    QueueAssignment,
    TaskNode,
    WiringPlan,
    format_cuda_semantics,
    format_wiring_plan_block,
    merge_with_translation_facts,
    parse_cuda_semantics,
    parse_wiring_plan,
    validate_wiring_plan,
)
from design_schema import LayoutContract


class TestParseCUDASemantics(unittest.TestCase):

    def test_elementwise(self):
        text = "This kernel performs an elementwise ReLU. Output = max(0, x[i])."
        sem = parse_cuda_semantics(text)
        self.assertEqual(sem.computation_type, "elementwise")

    def test_reduction(self):
        text = "The kernel computes a sum reduction along rows."
        sem = parse_cuda_semantics(text)
        self.assertEqual(sem.computation_type, "reduction")

    def test_stencil(self):
        text = "A 5-point Laplacian stencil with halo exchange."
        sem = parse_cuda_semantics(text)
        self.assertEqual(sem.computation_type, "stencil")

    def test_matmul(self):
        text = "Standard matrix multiplication (GEMM) C = A * B."
        sem = parse_cuda_semantics(text)
        self.assertEqual(sem.computation_type, "matmul")

    def test_input_output_tensors(self):
        text = "Reads input tensor x and input tensor y. Writes output tensor z."
        sem = parse_cuda_semantics(text)
        self.assertEqual(len(sem.input_tensors), 2)
        self.assertEqual(sem.input_tensors[0].name, "x")
        self.assertEqual(sem.output_tensors[0].name, "z")

    def test_sync_points(self):
        text = "Uses __syncthreads() after loading shared memory."
        sem = parse_cuda_semantics(text)
        self.assertIn("barrier_sync", sem.sync_points)

    def test_intensity_high(self):
        text = "The kernel is compute-bound with high arithmetic intensity."
        sem = parse_cuda_semantics(text)
        self.assertEqual(sem.arithmetic_intensity, "high")

    def test_intensity_low(self):
        text = "Memory-bound kernel, limited by bandwidth."
        sem = parse_cuda_semantics(text)
        self.assertEqual(sem.arithmetic_intensity, "low")

    def test_format_roundtrip(self):
        sem = CUDASemantics(computation_type="stencil", arithmetic_intensity="medium")
        out = format_cuda_semantics(sem)
        self.assertIn("stencil", out)
        self.assertIn("medium", out)


class TestParseWiringPlan(unittest.TestCase):

    SAMPLE_DESIGN = """### 1. Mesh
5×5 mesh of PEs.
### 2. Algorithm
Step 1: broadcast x. Step 2: local GEMV. Step 3: reduce.
### 3. Memory
Total: 2 KB per PE.
### 5. Collective
Using <collectives_2d>.
### 7. Edge cases
- Uneven partition: last PE gets fewer rows.
### 9. Resource allocation
task 8: compute entry
task 9: receive callback
color 8: north halo send
color 9: south halo send
queue 2: user output north
### 10. Buffers
var A_tile: [128]f32
var x_buf: [32]f32
"""

    SAMPLE_LAYOUT = """
const kernel_rows = 5;
const kernel_cols = 5;
@export_symbol("compute")
@export_symbol("f_tic")
@import_module("<collectives_2d/pe>", c2d_params)
@import_module("<memcpy/memcpy>", mp)
@get_local_task_id(10)
@get_local_task_id(11)
@get_color(12)
"""

    def test_parse_basic(self):
        plan = parse_wiring_plan(self.SAMPLE_DESIGN, self.SAMPLE_LAYOUT)
        self.assertEqual(plan.design.mesh_shape, (5, 5))
        self.assertFalse(plan.design.is_single_pe)
        self.assertEqual(plan.design.collective_choice, "collectives_2d")

    def test_parse_buffers(self):
        plan = parse_wiring_plan(self.SAMPLE_DESIGN, self.SAMPLE_LAYOUT)
        names = [b.name for b in plan.pe_buffers]
        self.assertIn("A_tile", names)
        self.assertIn("x_buf", names)

    def test_parse_task_chain(self):
        plan = parse_wiring_plan(self.SAMPLE_DESIGN, self.SAMPLE_LAYOUT)
        ids = [t.task_id for t in plan.task_chain]
        self.assertIn(8, ids)
        self.assertIn(9, ids)

    def test_parse_colors(self):
        plan = parse_wiring_plan(self.SAMPLE_DESIGN, self.SAMPLE_LAYOUT)
        ids = [c.color_id for c in plan.color_assignments]
        self.assertIn(8, ids)
        self.assertIn(9, ids)

    def test_parse_queues(self):
        plan = parse_wiring_plan(self.SAMPLE_DESIGN, self.SAMPLE_LAYOUT)
        ids = [q.queue_id for q in plan.queue_assignments]
        self.assertIn(2, ids)

    def test_layout_task_ids(self):
        plan = parse_wiring_plan(self.SAMPLE_DESIGN, self.SAMPLE_LAYOUT)
        self.assertIn(10, plan.layout_task_ids)
        self.assertIn(11, plan.layout_task_ids)

    def test_layout_colors(self):
        plan = parse_wiring_plan(self.SAMPLE_DESIGN, self.SAMPLE_LAYOUT)
        self.assertIn(12, plan.layout_color_ids)

    def test_memcpy_queues(self):
        plan = parse_wiring_plan(self.SAMPLE_DESIGN, self.SAMPLE_LAYOUT)
        self.assertEqual(plan.memcpy_reserved_queues, [0, 1])

    def test_exported_symbols(self):
        plan = parse_wiring_plan(self.SAMPLE_DESIGN, self.SAMPLE_LAYOUT)
        self.assertIn("compute", plan.exported_symbols)
        self.assertIn("f_tic", plan.exported_symbols)

    def test_single_pe(self):
        design = "### 1. Mesh\nSingle-PE kernel (1×1)."
        layout = "const width = 1;\nconst height = 1;\n"
        plan = parse_wiring_plan(design, layout)
        self.assertTrue(plan.design.is_single_pe)


class TestValidateWiringPlan(unittest.TestCase):

    def test_task_id_collision(self):
        plan = WiringPlan(
            task_chain=[TaskNode(task_id=10, name="user_task")],
            layout_task_ids=[10, 11],
        )
        contract = LayoutContract(mesh_width=1, mesh_height=1)
        result = validate_wiring_plan(plan, contract)
        self.assertTrue(any("collision" in e.lower() for e in result.errors))

    def test_queue_collision(self):
        plan = WiringPlan(
            queue_assignments=[QueueAssignment(queue_id=0, owner="user")],
            memcpy_reserved_queues=[0, 1],
        )
        contract = LayoutContract()
        result = validate_wiring_plan(plan, contract)
        self.assertTrue(any("Queue 0" in e for e in result.errors))

    def test_task_id_range_warning(self):
        plan = WiringPlan(
            task_chain=[TaskNode(task_id=5, name="bad_id")],
        )
        contract = LayoutContract()
        result = validate_wiring_plan(plan, contract)
        self.assertTrue(any("range" in w.lower() for w in result.warnings))

    def test_memory_overflow(self):
        plan = WiringPlan(
            pe_buffers=[BufferDecl(name="big", bytes=50 * 1024)],
        )
        contract = LayoutContract()
        result = validate_wiring_plan(plan, contract)
        self.assertTrue(any("exceeds" in e.lower() for e in result.errors))

    def test_valid_plan(self):
        plan = WiringPlan(
            task_chain=[TaskNode(task_id=8, name="compute")],
            queue_assignments=[QueueAssignment(queue_id=2)],
            pe_buffers=[BufferDecl(name="buf", bytes=4096)],
            layout_task_ids=[10, 11],
            memcpy_reserved_queues=[0, 1],
        )
        contract = LayoutContract(mesh_width=1, mesh_height=1)
        result = validate_wiring_plan(plan, contract)
        self.assertEqual(len(result.errors), 0)


class TestMergeWithFacts(unittest.TestCase):

    def test_merge_task_ids(self):
        plan = WiringPlan(layout_task_ids=[10])
        facts = {"task_ids_owned_by_layout": [10, 11, 12]}
        merged = merge_with_translation_facts(plan, facts)
        self.assertIn(11, merged.layout_task_ids)
        self.assertIn(12, merged.layout_task_ids)
        self.assertEqual(merged.layout_task_ids.count(10), 1)

    def test_merge_exports(self):
        plan = WiringPlan(exported_symbols=["main"])
        facts = {
            "exported_symbols_pe_must_define": [
                {"name": "main"}, {"name": "f_tic"},
            ]
        }
        merged = merge_with_translation_facts(plan, facts)
        self.assertIn("f_tic", merged.exported_symbols)
        self.assertEqual(merged.exported_symbols.count("main"), 1)

    def test_merge_empty_facts(self):
        plan = WiringPlan(layout_task_ids=[8])
        merged = merge_with_translation_facts(plan, {})
        self.assertEqual(merged.layout_task_ids, [8])

    def test_merge_none_facts(self):
        plan = WiringPlan()
        merged = merge_with_translation_facts(plan, None)
        self.assertIsNotNone(merged)


class TestFormatWiringPlan(unittest.TestCase):

    def test_format_basic(self):
        plan = WiringPlan(
            exported_symbols=["main", "f_tic"],
            memcpy_reserved_queues=[0, 1],
            layout_task_ids=[10, 11],
            pe_buffers=[BufferDecl(name="buf", type="f32", size_expr="1024", bytes=4096)],
        )
        out = format_wiring_plan_block(plan)
        self.assertIn("WIRING PLAN", out)
        self.assertIn("main", out)
        self.assertIn("free_queues", out)
        self.assertIn("free_task_ids", out)

    def test_format_empty(self):
        plan = WiringPlan()
        out = format_wiring_plan_block(plan)
        self.assertIn("WIRING PLAN", out)


if __name__ == "__main__":
    unittest.main()
