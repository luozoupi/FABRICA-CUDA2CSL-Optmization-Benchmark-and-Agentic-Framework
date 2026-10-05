"""Mode handlers for explore_csl.py.

Each mode (variation / idea / cuda-nl) exposes ``propose_candidates`` that
turns a seed (an existing kernel path / an idea string / a catalog entry)
plus retrieved knowledge into a list of :class:`Candidate` dataclasses.

The candidate is what the orchestrator hands to the implementer to expand
into a full bundle. After the bundle is benchmarked the orchestrator
delegates failure handling and persistence — modes are stateless.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Dict, List, Optional


@dataclass
class Candidate:
    """One exploration candidate.

    Modes produce these; the orchestrator iterates over them, asks the
    implementer to expand each into a full bundle (via ``implementer_prompt``
    on top of the system prompt), benchmarks the result, and persists.
    """
    id: str
    mode: str                                  # variation | idea | cuda-nl
    idea: str                                  # short slug + title (idea_hash key)
    title: str
    summary: str
    acceptance_numerics: str
    suggested_mesh: str
    features: List[str] = field(default_factory=list)
    difficulty: str = "medium"

    # The architect / implementer prompts to send. ``architect_prompt`` is
    # optional — Mode A (variation) skips it because the design is implicit
    # in the baseline + axis.
    architect_prompt: Optional[str] = None
    implementer_prompt: str = ""

    # For Mode A: paths to the baseline bundle (used by the implementer).
    baseline_dir: Optional[str] = None
    baseline_kind: Optional[str] = None        # "kernels" or "csl-examples"

    # For Mode C: the catalog entry id (for promotion + provenance).
    catalog_id: Optional[str] = None

    # Two-axis difficulty + hard floor on the layout's PE count. The
    # orchestrator's mesh gate enforces ``min_pe_count`` before
    # benchmark to prevent the LLM from collapsing a hard-tier seed
    # onto a single PE.
    layout_complexity: int = 0     # 1=easy, 2=medium, 3=hard, 0=unknown
    compute_complexity: int = 0
    min_pe_count: int = 1

    # Free-form metadata (mode-specific extras).
    meta: Dict[str, Any] = field(default_factory=dict)


__all__ = ["Candidate"]
