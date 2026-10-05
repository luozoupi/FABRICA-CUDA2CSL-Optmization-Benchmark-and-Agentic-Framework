"""Mode B: idea-driven exploration.

Picks N high-gap ideas via :class:`IdeaSampler` and builds one
:class:`Candidate` per idea. The architect/implementer split inside one
prompt: the LLM emits a DESIGN.md AND the full bundle in one shot
(``q_explore_idea`` template, fenced blocks). Splitting design and
implementation into two round-trips would double LLM cost without much
benefit for net-new kernels — the implementer needs the design in front of
it either way, and we're rate-limited by cslc + simulator, not by prompts.
"""

from __future__ import annotations

import os
import sys
from pathlib import Path
from typing import List, Optional

# Make parent dir importable for sibling modules + prompt templates.
_THIS = Path(__file__).resolve()
_CODE_TRANSLATION = _THIS.parents[1]
if str(_CODE_TRANSLATION) not in sys.path:
    sys.path.insert(0, str(_CODE_TRANSLATION))

from explore_modes import Candidate  # type: ignore  # noqa: E402
from explore_modes.idea_sampler import IdeaSampler, IdeaSeed  # type: ignore  # noqa: E402
from prompt_cuda2csl import (  # type: ignore  # noqa: E402
    CYCLES_SEND_RECIPE,
    builtin_whitelist_block,
    q_explore_idea,
)
import csl_knowledge_base  # type: ignore  # noqa: E402


def _prior_lessons_block(explored_root: Optional[str]) -> str:
    """Render at most the last 5 lessons rows so the architect avoids
    repeating recent failure modes. Returns "(none on record)" when the
    explored corpus is empty."""
    if not explored_root:
        return "(none on record)"
    p = Path(explored_root) / "experiences.jsonl"
    if not p.is_file():
        return "(none on record)"
    import json
    rows = []
    try:
        with open(p, "r", encoding="utf-8") as fh:
            for line in fh:
                line = line.strip()
                if not line:
                    continue
                try:
                    rows.append(json.loads(line))
                except json.JSONDecodeError:
                    pass
    except OSError:
        return "(none on record)"
    if not rows:
        return "(none on record)"
    rows = rows[-5:]
    parts = []
    for r in rows:
        lessons = r.get("lessons") or []
        if not lessons:
            continue
        parts.append(f"- {r.get('kernel_id', '?')} ({r.get('outcome', '?')}): "
                     + "; ".join(lessons[:3]))
    return "\n".join(parts) or "(no distilled lessons yet)"


def _layout_requirements_block(seed) -> str:
    """Render an explicit layout-floor section for the LLM.

    This is the prompt-side companion to the parse-time mesh gate. The
    gate rejects single-PE collapses; this block tells the LLM up-front
    why, so it doesn't waste a round emitting one. For easy-tier seeds
    (min_pe_count=1), this section is short and permissive.
    """
    tier = seed.tier
    if seed.min_pe_count <= 1:
        return (
            f"This is an EASY-tier seed (layout={seed.layout_complexity}, "
            f"compute={seed.compute_complexity}). A single-PE layout is "
            f"acceptable. Use @set_rectangle(1, 1) if that is the simplest "
            f"correct decomposition."
        )
    axis_names = {1: "single-PE", 2: "1D mesh", 3: "2D mesh / collectives / halo"}
    layout_desc = axis_names.get(seed.layout_complexity, "multi-PE")
    return (
        f"This is a {tier.upper()}-tier seed "
        f"(layout_complexity={seed.layout_complexity} = {layout_desc}, "
        f"compute_complexity={seed.compute_complexity}).\n\n"
        f"HARD LAYOUT FLOOR: @set_rectangle(W, H) MUST satisfy W*H >= "
        f"{seed.min_pe_count}. A parse-time mesh gate will REJECT any "
        f"bundle with fewer PEs BEFORE invoking cslc, marking the "
        f"candidate as `mesh_too_small`.\n\n"
        f"Single-PE collapses are FORBIDDEN for this tier — the point of "
        f"the seed is to exercise wafer-scale decomposition. If your "
        f"first instinct is `@set_rectangle(1, 1)`, you are solving a "
        f"different (easier) problem than what the seed describes.\n\n"
        f"The mesh hint below is a starting suggestion; you may pick any "
        f"shape whose product is at least {seed.min_pe_count}."
    )


def propose_candidates(*,
                       sampler: IdeaSampler,
                       n_candidates: int,
                       explored_root: Optional[str] = None) -> List[Candidate]:
    """Pick n ideas from the sampler and build a Candidate for each."""
    seeds = sampler.sample(n_candidates)
    prior = _prior_lessons_block(explored_root)
    whitelist = builtin_whitelist_block()
    out: List[Candidate] = []
    for seed in seeds:
        kb = csl_knowledge_base.for_explorer(
            f"{seed.title}\n{seed.summary}\nmesh:{seed.suggested_mesh}\n"
            + " ".join(seed.features or [])
        )
        impl_prompt = q_explore_idea.format(
            idea_title=seed.title,
            idea_summary=seed.summary,
            acceptance_numerics=seed.acceptance_numerics,
            layout_requirements=_layout_requirements_block(seed),
            suggested_mesh=seed.suggested_mesh,
            knowledge_base=kb,
            prior_lessons=prior,
            builtin_whitelist=whitelist,
            cycles_send_recipe=CYCLES_SEND_RECIPE,
        )
        out.append(Candidate(
            id=seed.id,
            mode="idea",
            idea=f"{seed.id}: {seed.title}",
            title=seed.title,
            summary=seed.summary,
            acceptance_numerics=seed.acceptance_numerics,
            suggested_mesh=seed.suggested_mesh,
            features=list(seed.features),
            difficulty=seed.difficulty,
            layout_complexity=seed.layout_complexity,
            compute_complexity=seed.compute_complexity,
            min_pe_count=seed.min_pe_count,
            architect_prompt=None,
            implementer_prompt=impl_prompt,
            meta={"seed_hash": seed.hash,
                  "tier": seed.tier},
        ))
    return out


__all__ = ["propose_candidates"]
