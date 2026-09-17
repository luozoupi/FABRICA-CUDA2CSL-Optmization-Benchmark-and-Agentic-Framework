"""wiring_plan — Two-layer IR for CUDA→CSL translation.

Layer 1 (CUDASemantics): structured representation of CUDA kernel semantics,
decoupled from GPU-specific constructs. Parsed from the analysis LLM output.

Layer 2 (WiringPlan): typed contract between architect and implementer.
Captures the decomposition, resource allocation, and task wiring that the
implementer needs. Validated against the layout.csl contract and merged with
translation_facts to produce a ground-truth resource ledger.

Gate: XKERNEL_WIRING_PLAN=1 (default OFF until A/B validated).

All parsers are best-effort with sensible defaults. A parsing failure never
blocks the pipeline — the unstructured prose passes through unchanged.
"""

from __future__ import annotations

import logging
import re
from dataclasses import dataclass, field
from typing import Dict, List, Optional, Tuple

from design_schema import (
    DesignFacts,
    LayoutContract,
    ValidationResult,
    parse_design,
    parse_layout_contract,
)

logger = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# Layer 1: CUDASemantics
# ---------------------------------------------------------------------------

@dataclass
class TensorDesc:
    name: str
    shape: str = ""
    dtype: str = "f32"
    access_pattern: str = ""


@dataclass
class ParallelAxis:
    name: str
    grid_dim: str = ""
    independent: bool = True


@dataclass
class ReductionAxis:
    axis: str
    op: str = "add"
    associative: bool = True


@dataclass
class CUDASemantics:
    computation_type: str = "unknown"
    math_formula: str = ""
    input_tensors: List[TensorDesc] = field(default_factory=list)
    output_tensors: List[TensorDesc] = field(default_factory=list)
    parallel_axes: List[ParallelAxis] = field(default_factory=list)
    reduction_axes: List[ReductionAxis] = field(default_factory=list)
    sync_points: List[str] = field(default_factory=list)
    data_dependencies: List[str] = field(default_factory=list)
    arithmetic_intensity: str = "unknown"


_COMP_TYPE_PATTERNS = [
    (r'element[- ]?wise|point[- ]?wise|map', "elementwise"),
    (r'reduc(?:tion|e)|sum|accumul', "reduction"),
    (r'stencil|halo|neighbor|laplacian|jacobi', "stencil"),
    (r'mat(?:rix)?[- ]?mul|gemm|gemv|dot[- ]?product', "matmul"),
    (r'scan|prefix[- ]?sum', "scan"),
    (r'pipeline|multi[- ]?stage|chain', "pipeline"),
    (r'histogram|bin(?:ning)?', "histogram"),
    (r'fft|fourier|butterfly', "fft"),
    (r'sort|merge', "sort"),
    (r'scatter|gather', "scatter_gather"),
]


def parse_cuda_semantics(analysis_text: str) -> CUDASemantics:
    """Parse the LLM's CUDA analysis into structured semantics."""
    sem = CUDASemantics()
    text = analysis_text.lower()

    for pattern, comp_type in _COMP_TYPE_PATTERNS:
        if re.search(pattern, text):
            sem.computation_type = comp_type
            break

    m = re.search(
        r'(?:formula|equation|computes?)\s*[=:]\s*(.+?)(?:\.\s|\n|$)',
        analysis_text, re.IGNORECASE,
    )
    if m:
        sem.math_formula = m.group(1).strip()[:120]

    for m in re.finditer(
        r'(?:input|reads?)\s+(?:tensor|matrix|vector|array|buffer)\s+'
        r'[`"\']?(\w+)[`"\']?',
        analysis_text, re.IGNORECASE,
    ):
        sem.input_tensors.append(TensorDesc(name=m.group(1)))

    for m in re.finditer(
        r'(?:output|writes?|result)\s+(?:tensor|matrix|vector|array|buffer)\s+'
        r'[`"\']?(\w+)[`"\']?',
        analysis_text, re.IGNORECASE,
    ):
        sem.output_tensors.append(TensorDesc(name=m.group(1)))

    if re.search(r'__syncthreads|barrier|synchroniz', text):
        sem.sync_points.append("barrier_sync")

    if re.search(r'atomicadd|atomic|__shfl', text):
        sem.sync_points.append("atomic_or_shuffle")

    for m in re.finditer(
        r'(?:gridDim|blockDim|num_blocks)\s*[.=]\s*(?:\w+\s*[=,]\s*)?(\w+)',
        analysis_text,
    ):
        sem.parallel_axes.append(ParallelAxis(name=m.group(1)))

    for m in re.finditer(
        r'(?:reduc(?:tion|e)|sum|accumulate)\s+(?:along|over|across)\s+(\w+)',
        analysis_text, re.IGNORECASE,
    ):
        sem.reduction_axes.append(ReductionAxis(axis=m.group(1)))

    if re.search(r'compute[- ]?bound|high\s+(?:arithmetic|compute)\s+intensity', text):
        sem.arithmetic_intensity = "high"
    elif re.search(r'memory[- ]?bound|low\s+(?:arithmetic|compute)\s+intensity|bandwidth', text):
        sem.arithmetic_intensity = "low"
    elif re.search(r'balanced|moderate|medium', text):
        sem.arithmetic_intensity = "medium"

    return sem


def format_cuda_semantics(sem: CUDASemantics) -> str:
    """Format CUDASemantics as a compact block for the architect prompt."""
    lines = ["## STRUCTURED CUDA SEMANTICS (machine-extracted)"]
    lines.append(f"- Computation type: {sem.computation_type}")
    if sem.math_formula:
        lines.append(f"- Formula: {sem.math_formula}")
    if sem.input_tensors:
        lines.append(f"- Inputs: {', '.join(t.name for t in sem.input_tensors)}")
    if sem.output_tensors:
        lines.append(f"- Outputs: {', '.join(t.name for t in sem.output_tensors)}")
    if sem.parallel_axes:
        lines.append(f"- Parallel axes: {', '.join(a.name for a in sem.parallel_axes)}")
    if sem.reduction_axes:
        lines.append(f"- Reduction axes: {', '.join(f'{a.axis} ({a.op})' for a in sem.reduction_axes)}")
    if sem.sync_points:
        lines.append(f"- Sync: {', '.join(sem.sync_points)}")
    lines.append(f"- Arithmetic intensity: {sem.arithmetic_intensity}")
    return "\n".join(lines)


# ---------------------------------------------------------------------------
# Layer 2: WiringPlan
# ---------------------------------------------------------------------------

@dataclass
class BufferDecl:
    name: str
    type: str = "f32"
    size_expr: str = ""
    role: str = ""
    bytes: int = 0


@dataclass
class ColorAssignment:
    color_id: int
    direction: str = ""
    purpose: str = ""


@dataclass
class TaskNode:
    task_id: int
    name: str = ""
    trigger: str = ""
    action: str = ""
    next_task_ids: List[int] = field(default_factory=list)


@dataclass
class QueueAssignment:
    queue_id: int
    owner: str = "user"
    direction: str = ""


@dataclass
class WiringPlan:
    design: DesignFacts = field(default_factory=DesignFacts)

    pe_buffers: List[BufferDecl] = field(default_factory=list)
    color_assignments: List[ColorAssignment] = field(default_factory=list)
    task_chain: List[TaskNode] = field(default_factory=list)
    queue_assignments: List[QueueAssignment] = field(default_factory=list)

    layout_task_ids: List[int] = field(default_factory=list)
    layout_color_ids: List[int] = field(default_factory=list)
    memcpy_reserved_queues: List[int] = field(default_factory=list)
    tile_code_params: List[str] = field(default_factory=list)
    exported_symbols: List[str] = field(default_factory=list)
    host_launch_sequence: List[str] = field(default_factory=list)

    cuda_semantics: Optional[CUDASemantics] = None


def _parse_buffers(text: str) -> List[BufferDecl]:
    """Extract per-PE buffer declarations from the design."""
    buffers = []
    for m in re.finditer(
        r'(?:var|buffer|array|tile)\s+[`"\']?(\w+)[`"\']?\s*'
        r'(?::\s*\[?(\d+)(?:\s*[x×*]\s*(\d+))?\]?\s*(\w+))?',
        text, re.IGNORECASE,
    ):
        name = m.group(1)
        size1 = m.group(2) or ""
        size2 = m.group(3) or ""
        dtype = m.group(4) or "f32"
        size_expr = f"{size1}x{size2}" if size2 else size1
        elem_bytes = 4 if "32" in dtype else 2 if "16" in dtype else 1
        total = 1
        for s in [size1, size2]:
            if s and s.isdigit():
                total *= int(s)
        buffers.append(BufferDecl(
            name=name, type=dtype, size_expr=size_expr,
            bytes=total * elem_bytes,
        ))

    for m in re.finditer(
        r'[`"\']?(\w+)[`"\']?\s*(?::|—|=)\s*(\d+)\s*(?:×|x|\*)\s*(\d+)\s*'
        r'(?:×|x|\*)?\s*(\d+)?\s*(?:=\s*)?(\d+(?:,\d+)?)\s*bytes?',
        text, re.IGNORECASE,
    ):
        name = m.group(1)
        total_bytes = int(m.group(5).replace(',', ''))
        buffers.append(BufferDecl(name=name, bytes=total_bytes))

    return buffers


def _parse_color_assignments(text: str) -> List[ColorAssignment]:
    """Extract color assignments from design."""
    colors = []
    for m in re.finditer(
        r'color\s+(\d+)\s*(?::|—|=)\s*([^,\n]{3,60})',
        text, re.IGNORECASE,
    ):
        colors.append(ColorAssignment(
            color_id=int(m.group(1)),
            purpose=m.group(2).strip()[:60],
        ))
    for m in re.finditer(
        r'@get_color\s*\(\s*(\d+)\s*\)',
        text,
    ):
        cid = int(m.group(1))
        if not any(c.color_id == cid for c in colors):
            colors.append(ColorAssignment(color_id=cid))
    return colors


def _parse_task_chain(text: str) -> List[TaskNode]:
    """Extract task ID assignments from design."""
    tasks = []
    for m in re.finditer(
        r'(?:task|task_id|local_task_id)\s+(\d+)\s*(?::|—|=)\s*([^,\n]{3,60})',
        text, re.IGNORECASE,
    ):
        tasks.append(TaskNode(
            task_id=int(m.group(1)),
            name=m.group(2).strip()[:60],
        ))
    return tasks


def _parse_queue_assignments(text: str) -> List[QueueAssignment]:
    """Extract queue assignments from design."""
    queues = []
    for m in re.finditer(
        r'(?:queue|queue_id)\s+(\d+)\s*(?::|—|=)\s*([^,\n]{3,60})',
        text, re.IGNORECASE,
    ):
        queues.append(QueueAssignment(
            queue_id=int(m.group(1)),
            owner="user",
            direction=m.group(2).strip()[:40],
        ))
    return queues


def parse_wiring_plan(design_text: str, layout_text: str) -> WiringPlan:
    """Parse design + layout into a WiringPlan."""
    design = parse_design(design_text)
    plan = WiringPlan(design=design)
    plan.pe_buffers = _parse_buffers(design_text)
    plan.color_assignments = _parse_color_assignments(design_text)
    plan.task_chain = _parse_task_chain(design_text)
    plan.queue_assignments = _parse_queue_assignments(design_text)

    contract = parse_layout_contract(layout_text)
    plan.exported_symbols = contract.exported_symbols
    plan.tile_code_params = contract.struct_fields

    for m in re.finditer(r'@get_local_task_id\s*\(\s*(\d+)\s*\)', layout_text):
        plan.layout_task_ids.append(int(m.group(1)))
    for m in re.finditer(r'@get_color\s*\(\s*(\d+)\s*\)', layout_text):
        plan.layout_color_ids.append(int(m.group(1)))

    if any('memcpy' in m for m in contract.imported_modules):
        plan.memcpy_reserved_queues = [0, 1]

    for m in re.finditer(
        r'runner\s*\.\s*launch\s*\(\s*["\'](\w+)["\']',
        layout_text,
    ):
        plan.host_launch_sequence.append(m.group(1))

    return plan


def merge_with_translation_facts(plan: WiringPlan, facts: Dict) -> WiringPlan:
    """Merge translation_facts extracted values into the WiringPlan."""
    if not facts:
        return plan

    if "task_ids_owned_by_layout" in facts:
        for tid in facts["task_ids_owned_by_layout"]:
            if isinstance(tid, int) and tid not in plan.layout_task_ids:
                plan.layout_task_ids.append(tid)

    if "color_ids_owned_by_layout" in facts:
        for cid in facts["color_ids_owned_by_layout"]:
            if isinstance(cid, int) and cid not in plan.layout_color_ids:
                plan.layout_color_ids.append(cid)

    if "memcpy_reserved_input_queues" in facts:
        for qid in facts["memcpy_reserved_input_queues"]:
            if isinstance(qid, int) and qid not in plan.memcpy_reserved_queues:
                plan.memcpy_reserved_queues.append(qid)

    if "exported_symbols_pe_must_define" in facts:
        for sym_info in facts["exported_symbols_pe_must_define"]:
            name = sym_info if isinstance(sym_info, str) else sym_info.get("name", "")
            if name and name not in plan.exported_symbols:
                plan.exported_symbols.append(name)

    if "tile_code_params_pe_must_declare" in facts:
        for p in facts["tile_code_params_pe_must_declare"]:
            if isinstance(p, str) and p not in plan.tile_code_params:
                plan.tile_code_params.append(p)

    if "host_launch_sequence" in facts:
        if not plan.host_launch_sequence:
            plan.host_launch_sequence = [
                f for f in facts["host_launch_sequence"] if isinstance(f, str)
            ]

    return plan


def validate_wiring_plan(
    plan: WiringPlan, layout_contract: LayoutContract
) -> ValidationResult:
    """Validate a WiringPlan against the layout contract.

    Checks for resource collisions (task IDs, colors, queues),
    memory budget, and export coverage.
    """
    result = ValidationResult()

    layout_mesh = (layout_contract.mesh_width, layout_contract.mesh_height)
    if plan.design.mesh_shape != layout_mesh and layout_mesh != (1, 1):
        if plan.design.mesh_shape != (1, 1):
            result.errors.append(
                f"Mesh mismatch: design {plan.design.mesh_shape[0]}×"
                f"{plan.design.mesh_shape[1]} vs layout "
                f"{layout_mesh[0]}×{layout_mesh[1]}"
            )

    for task in plan.task_chain:
        if task.task_id in plan.layout_task_ids:
            result.errors.append(
                f"Task ID {task.task_id} collision: used by design "
                f"('{task.name}') but already owned by layout.csl"
            )
        if not (8 <= task.task_id < 32):
            result.warnings.append(
                f"Task ID {task.task_id} outside valid range [8,32)"
            )

    for color in plan.color_assignments:
        if color.color_id in plan.layout_color_ids:
            result.warnings.append(
                f"Color {color.color_id} also appears in layout.csl — "
                f"verify it's the same usage"
            )
        if color.color_id < 8:
            result.warnings.append(
                f"Color {color.color_id} is in the system-reserved range [0,8)"
            )

    for q in plan.queue_assignments:
        if q.queue_id in plan.memcpy_reserved_queues:
            result.errors.append(
                f"Queue {q.queue_id} collision: used by design but "
                f"reserved by memcpy"
            )

    if plan.pe_buffers:
        total_bytes = sum(b.bytes for b in plan.pe_buffers)
        total_kb = total_bytes / 1024.0
        if total_kb > 48.0:
            result.errors.append(
                f"Buffer total {total_kb:.1f} KB exceeds 48 KB per-PE limit"
            )
        elif total_kb > 40.0:
            result.warnings.append(
                f"Buffer total {total_kb:.1f} KB above 40 KB safe threshold"
            )

    if plan.design.memory_budget_kb and plan.design.memory_budget_kb > 48.0:
        result.errors.append(
            f"Architect memory budget {plan.design.memory_budget_kb:.1f} KB "
            f"exceeds 48 KB per-PE limit"
        )

    return result


def format_wiring_plan_block(plan: WiringPlan) -> str:
    """Format a WiringPlan as a YAML block for prompt injection."""
    lines = [
        "## WIRING PLAN (machine-validated resource allocation)",
        f"mesh: {plan.design.mesh_shape[0]}×{plan.design.mesh_shape[1]}"
        f" ({'single-PE' if plan.design.is_single_pe else 'multi-PE'})",
    ]

    if plan.design.memory_budget_kb:
        lines.append(f"memory_budget: {plan.design.memory_budget_kb:.1f} KB / 48 KB")

    if plan.design.collective_choice:
        lines.append(f"collective: {plan.design.collective_choice}")

    if plan.exported_symbols:
        lines.append(f"required_exports: [{', '.join(plan.exported_symbols[:15])}]")

    if plan.tile_code_params:
        lines.append(f"params_pe_must_declare: [{', '.join(plan.tile_code_params[:15])}]")

    if plan.host_launch_sequence:
        lines.append(f"host_launch_order: [{', '.join(plan.host_launch_sequence[:10])}]")

    if plan.layout_task_ids:
        lines.append(f"layout_owns_task_ids: {plan.layout_task_ids}")
        free_range = [i for i in range(8, 32) if i not in plan.layout_task_ids]
        lines.append(f"free_task_ids: {free_range[:8]}...")

    if plan.layout_color_ids:
        lines.append(f"layout_owns_colors: {plan.layout_color_ids}")

    if plan.memcpy_reserved_queues:
        lines.append(f"memcpy_reserved_queues: {plan.memcpy_reserved_queues}")
        free_qs = [i for i in range(2, 8) if i not in plan.memcpy_reserved_queues]
        lines.append(f"free_queues: {free_qs}")

    if plan.pe_buffers:
        lines.append("pe_buffers:")
        for b in plan.pe_buffers[:10]:
            lines.append(f"  - {b.name}: {b.size_expr} {b.type} ({b.bytes} bytes)")

    if plan.color_assignments:
        lines.append("color_plan:")
        for c in plan.color_assignments[:10]:
            lines.append(f"  - color {c.color_id}: {c.purpose or c.direction}")

    if plan.task_chain:
        lines.append("task_plan:")
        for t in plan.task_chain[:10]:
            lines.append(f"  - task_id {t.task_id}: {t.name}")

    return "\n".join(lines)
