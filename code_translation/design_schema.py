"""design_schema — structured DESIGN.md validator for the architect→implementer hand-off.

Implements Option (A) from docs/TRANSLATION_QUALITY_DESIGN.md: parse the architect's
free-form markdown DESIGN.md into typed fields and validate against the layout.csl
contract. Catches architect mistakes BEFORE the implementer sees them (wrong tile dims,
busted memory budget, missing edge cases).

Gate: XKERNEL_DESIGN_SCHEMA=1 (default OFF until A/B validated).

The validator does NOT change the DESIGN.md format the architect emits — it parses
whatever the architect writes, extracts structured facts, validates them, and appends
a compact "VALIDATED DESIGN FACTS" block that the implementer can trust as ground truth.
If validation fails, the architect is re-spun with the specific errors.
"""

from __future__ import annotations

import logging
import re
from dataclasses import dataclass, field
from typing import Dict, List, Optional, Tuple

logger = logging.getLogger(__name__)


@dataclass
class TensorShard:
    name: str
    decomposition: str = ""
    tile_dims: str = ""

@dataclass
class DesignFacts:
    mesh_shape: Tuple[int, int] = (1, 1)
    is_single_pe: bool = True
    tensor_shards: List[TensorShard] = field(default_factory=list)
    memory_budget_kb: Optional[float] = None
    collective_choice: str = ""
    algorithm_steps: List[str] = field(default_factory=list)
    edge_cases: List[str] = field(default_factory=list)
    reduction_axis: str = ""
    communication_pattern: str = ""


def _parse_mesh_shape(text: str) -> Tuple[int, int]:
    """Extract mesh shape from design text."""
    patterns = [
        r'(\d+)\s*[x×]\s*(\d+)\s*(?:mesh|grid|PE|rectangle)',
        r'(?:mesh|grid|rectangle)\s*(?:is|=|:)\s*(\d+)\s*[x×]\s*(\d+)',
        r'width\s*=\s*(\d+).*?height\s*=\s*(\d+)',
        r'kernel_(?:rows|width)\s*=\s*(\d+).*?kernel_(?:cols|height)\s*=\s*(\d+)',
        r'(\d+)\s*[x×]\s*(\d+)\s*(?:PEs|tiles|processors)',
        r'Px\s*=\s*(\d+).*?Py\s*=\s*(\d+)',
    ]
    for pat in patterns:
        m = re.search(pat, text, re.IGNORECASE | re.DOTALL)
        if m:
            return (int(m.group(1)), int(m.group(2)))
    if re.search(r'single[- ]PE|1\s*[x×]\s*1|one PE', text, re.IGNORECASE):
        return (1, 1)
    return (1, 1)


def _parse_memory_budget(text: str) -> Optional[float]:
    """Extract estimated per-PE memory in KB. Prefer 'total' lines."""
    patterns = [
        r'[Tt]otal\s*[=:]\s*~?(\d+(?:\.\d+)?)\s*KB',
        r'(\d+(?:\.\d+)?)\s*KB\s*(?:total|per[- ]PE|budget)',
        r'(?:total|per[- ]PE|budget|memory)[^.\n]{0,40}?(\d+(?:\.\d+)?)\s*KB',
        r'(\d+(?:\.\d+)?)\s*KB',
    ]
    for pat in patterns:
        m = re.search(pat, text, re.IGNORECASE)
        if m:
            val = float(m.group(1))
            if 0.1 < val < 200:
                return val
    byte_pats = [
        r'(\d+(?:,\d+)?)\s*bytes?\s*(?:total|per[- ]PE|budget)',
        r'(?:total|budget)[^.]{0,40}?(\d+(?:,\d+)?)\s*bytes?',
    ]
    for pat in byte_pats:
        m = re.search(pat, text, re.IGNORECASE)
        if m:
            val = int(m.group(1).replace(',', ''))
            if 100 < val < 200_000:
                return val / 1024.0
    return None


def _parse_tensor_shards(text: str) -> List[TensorShard]:
    """Extract tensor decomposition descriptions."""
    shards = []
    decomp_keywords = (
        'replicated', 'row-tiled', 'col-tiled', 'block-tiled',
        '1d-along', '2d-block', 'broadcast', 'sharded', 'partitioned',
        'distributed', 'halo',
    )
    for m in re.finditer(
        r'(?:tensor|matrix|vector|array|buffer|input|output)\s+'
        r'[`"\']?(\w+)[`"\']?\s+(?:is|uses?|has)\s+'
        r'([\w-]+(?:\s+[\w-]+){0,3})',
        text, re.IGNORECASE,
    ):
        name, desc = m.group(1), m.group(2).lower()
        if any(k in desc for k in decomp_keywords):
            shards.append(TensorShard(name=name, decomposition=desc))

    for m in re.finditer(
        r'[`"\']?(\w+)[`"\']?\s*(?::|—|–|-)\s*'
        r'((?:' + '|'.join(decomp_keywords) + r')[\w\s,.-]{0,80})',
        text, re.IGNORECASE,
    ):
        name, desc = m.group(1), m.group(2).strip()
        if name.lower() not in ('step', 'section', 'rule', 'note', 'trade'):
            if not any(s.name == name for s in shards):
                shards.append(TensorShard(name=name, decomposition=desc))
    return shards


def _parse_edge_cases(text: str) -> List[str]:
    """Extract edge cases mentioned in the design."""
    cases = []
    sec7 = re.search(
        r'(?:###?\s*7|edge case|determinism|hazard)(.*?)(?=###?\s*\d|$)',
        text, re.IGNORECASE | re.DOTALL,
    )
    if sec7:
        block = sec7.group(1)
        for line in block.split('\n'):
            line = line.strip().lstrip('-*•').strip()
            if len(line) > 10 and not line.startswith('#'):
                cases.append(line[:200])
    return cases[:10]


def _parse_algorithm_steps(text: str) -> List[str]:
    """Extract algorithm steps from section 2."""
    steps = []
    sec2 = re.search(
        r'(?:###?\s*2|algorithm|data flow)(.*?)(?=###?\s*3|$)',
        text, re.IGNORECASE | re.DOTALL,
    )
    if sec2:
        block = sec2.group(1)
        for m in re.finditer(r'(?:step|phase)\s*(\d+)\s*[:.]\s*(.+)', block, re.IGNORECASE):
            steps.append(f"Step {m.group(1)}: {m.group(2).strip()[:150]}")
        if not steps:
            for line in block.split('\n'):
                line = line.strip().lstrip('-*•0123456789.').strip()
                if len(line) > 15 and not line.startswith('#'):
                    steps.append(line[:150])
    return steps[:20]


def _parse_collective_choice(text: str) -> str:
    """Extract collective library choice."""
    if re.search(r'collectives_2d|<collectives_2d', text, re.IGNORECASE):
        return "collectives_2d"
    if re.search(r'custom\s+(?:fabric|color|routing)', text, re.IGNORECASE):
        return "custom_fabric"
    if re.search(r'no\s+collective|single[- ]PE|1\s*[x×]\s*1', text, re.IGNORECASE):
        return "none"
    return ""


def parse_design(design_text: str) -> DesignFacts:
    """Parse a free-form DESIGN.md into structured facts."""
    mesh = _parse_mesh_shape(design_text)
    return DesignFacts(
        mesh_shape=mesh,
        is_single_pe=(mesh == (1, 1)),
        tensor_shards=_parse_tensor_shards(design_text),
        memory_budget_kb=_parse_memory_budget(design_text),
        collective_choice=_parse_collective_choice(design_text),
        algorithm_steps=_parse_algorithm_steps(design_text),
        edge_cases=_parse_edge_cases(design_text),
    )


@dataclass
class LayoutContract:
    """Facts extracted from layout.csl that the design must respect."""
    mesh_width: int = 1
    mesh_height: int = 1
    exported_symbols: List[str] = field(default_factory=list)
    struct_fields: List[str] = field(default_factory=list)
    imported_modules: List[str] = field(default_factory=list)
    pe_memory_kb: float = 48.0


def parse_layout_contract(layout_text: str) -> LayoutContract:
    """Extract contract facts from layout.csl text."""
    contract = LayoutContract()

    for pat in [
        r'kernel_rows\s*=\s*(\d+)',
        r'width\s*[=:]\s*(\d+)',
        r'Px\s*=\s*(\d+)',
    ]:
        m = re.search(pat, layout_text)
        if m:
            contract.mesh_width = int(m.group(1))
            break

    for pat in [
        r'kernel_cols\s*=\s*(\d+)',
        r'height\s*[=:]\s*(\d+)',
        r'Py\s*=\s*(\d+)',
    ]:
        m = re.search(pat, layout_text)
        if m:
            contract.mesh_height = int(m.group(1))
            break

    for m in re.finditer(r'@export_(?:symbol|name)\s*\(\s*"?(\w+)"?\s*\)', layout_text):
        contract.exported_symbols.append(m.group(1))

    for m in re.finditer(r'@import_module\s*\(\s*"([^"]+)"', layout_text):
        contract.imported_modules.append(m.group(1))

    for m in re.finditer(r'\.(\w+)\s*=', layout_text):
        fname = m.group(1)
        if fname not in ('color', 'filter', 'pop_mode', 'task_id', 'local_task_id',
                         'LAUNCH', 'async', 'activate', 'block_mode'):
            contract.struct_fields.append(fname)

    return contract


@dataclass
class ValidationResult:
    """Result of validating design facts against the layout contract."""
    errors: List[str] = field(default_factory=list)
    warnings: List[str] = field(default_factory=list)
    facts_block: str = ""

    @property
    def ok(self) -> bool:
        return len(self.errors) == 0


def validate_design(facts: DesignFacts, contract: LayoutContract) -> ValidationResult:
    """Validate parsed design facts against the layout contract."""
    result = ValidationResult()

    layout_mesh = (contract.mesh_width, contract.mesh_height)
    if facts.mesh_shape != layout_mesh and layout_mesh != (1, 1):
        if facts.mesh_shape != (1, 1):
            result.errors.append(
                f"Mesh shape mismatch: design says {facts.mesh_shape[0]}x{facts.mesh_shape[1]} "
                f"but layout.csl declares {layout_mesh[0]}x{layout_mesh[1]}."
            )

    if facts.memory_budget_kb and facts.memory_budget_kb > contract.pe_memory_kb:
        result.errors.append(
            f"Memory budget {facts.memory_budget_kb:.1f} KB exceeds per-PE limit "
            f"of {contract.pe_memory_kb:.0f} KB."
        )

    if facts.memory_budget_kb and facts.memory_budget_kb > 40.0:
        result.warnings.append(
            f"Memory budget {facts.memory_budget_kb:.1f} KB is above the 40 KB "
            f"safe threshold (48 KB total minus stack/instruction overhead)."
        )

    if not facts.is_single_pe and not facts.collective_choice:
        result.warnings.append(
            "Multi-PE design does not specify a collective library choice "
            "(collectives_2d vs custom fabric)."
        )

    if not facts.algorithm_steps:
        result.warnings.append(
            "No algorithm steps detected in section 2. The implementer needs "
            "a step-by-step compute and communication plan."
        )

    if not facts.edge_cases:
        result.warnings.append(
            "No edge cases detected in section 7. At least one edge case "
            "(uneven shard, boundary condition, K=1) should be addressed."
        )

    uses_collectives_2d = any('collectives_2d' in m for m in contract.imported_modules)
    if uses_collectives_2d and facts.collective_choice != "collectives_2d":
        result.warnings.append(
            "layout.csl imports collectives_2d but the design doesn't mention it. "
            "The implementer will need to use the collectives_2d API."
        )

    lines = []
    lines.append("## VALIDATED DESIGN FACTS")
    lines.append(f"- Mesh: {facts.mesh_shape[0]}x{facts.mesh_shape[1]}"
                 f" ({'single-PE' if facts.is_single_pe else 'multi-PE'})")
    if facts.memory_budget_kb:
        lines.append(f"- Memory budget: {facts.memory_budget_kb:.1f} KB / 48 KB per PE")
    if facts.collective_choice:
        lines.append(f"- Collective: {facts.collective_choice}")
    if facts.tensor_shards:
        lines.append("- Tensor decompositions:")
        for s in facts.tensor_shards[:8]:
            lines.append(f"  - {s.name}: {s.decomposition}")
    if facts.algorithm_steps:
        lines.append(f"- Algorithm: {len(facts.algorithm_steps)} steps identified")
    if facts.edge_cases:
        lines.append(f"- Edge cases: {len(facts.edge_cases)} addressed")
    if contract.exported_symbols:
        lines.append(f"- Required exports: {', '.join(contract.exported_symbols[:10])}")

    if result.warnings:
        lines.append("- WARNINGS:")
        for w in result.warnings:
            lines.append(f"  ⚠ {w}")

    result.facts_block = "\n".join(lines)
    return result


def validate_and_augment(design_text: str, layout_text: str) -> Tuple[str, ValidationResult]:
    """Parse, validate, and augment a design with validated facts.

    Returns (augmented_design, validation_result).
    If validation has errors, the augmented_design includes the error block
    so the architect can see what to fix on respin.
    """
    facts = parse_design(design_text)
    contract = parse_layout_contract(layout_text)
    result = validate_design(facts, contract)

    if result.errors:
        error_block = "\n\n## DESIGN VALIDATION ERRORS\n"
        for e in result.errors:
            error_block += f"❌ {e}\n"
        error_block += ("\nThe architect must fix these errors before the implementer "
                        "can proceed. Re-spin the design.\n")
        return design_text + error_block, result

    return design_text + "\n\n" + result.facts_block + "\n", result
