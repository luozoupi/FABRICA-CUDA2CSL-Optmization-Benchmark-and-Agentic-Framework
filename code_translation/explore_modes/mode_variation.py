"""Mode A: variation of an existing passing kernel.

Asks the LLM to propose N small variants along permitted axes (tiling,
precision, mesh shape, communication pattern, microthread usage, FIFO
depth, comptime hoisting). Each variant becomes one Candidate; the
implementer then expands it into a full bundle via q_explore_idea.

The baseline bundle is kept as the "starting point" the implementer can
copy from and modify. Unlike Mode B/C, the run.py is REUSED VERBATIM by
default (only changed when the variant explicitly requires it, e.g. a
mesh-shape change that needs different fabric_dims). This both speeds up
exploration and gives us a stable correctness reference per variant.
"""

from __future__ import annotations

import json
import logging
import os
import re
import sys
from pathlib import Path
from typing import Any, Callable, Dict, List, Optional

_THIS = Path(__file__).resolve()
_CODE_TRANSLATION = _THIS.parents[1]
if str(_CODE_TRANSLATION) not in sys.path:
    sys.path.insert(0, str(_CODE_TRANSLATION))

from explore_modes import Candidate  # type: ignore  # noqa: E402
from prompt_cuda2csl import (  # type: ignore  # noqa: E402
    CYCLES_SEND_RECIPE,
    builtin_whitelist_block,
    q_explore_idea,
    q_explore_variation,
)
import csl_knowledge_base  # type: ignore  # noqa: E402


DEFAULT_AXES = [
    "tiling_factor",          # change Mt/Nt/BLOCK_SIZE
    "precision",              # f32 -> f16 where safe
    "mesh_shape",             # try a different fabric_dims (require run.py edits)
    "comm_pattern",           # broadcast vs reduce vs ring
    "microthread_use",        # WSE-3 microthreads for hot loops
    "fifo_depth",             # change @allocate_fifo depth
    "comptime_hoist",         # move runtime constants to comptime
    "dsd_chaining",           # rebuild DSDs vs @increment_dsd_offset
]

AXES_DESCRIPTION = """The permitted axes (pick ONE per variant):
  - tiling_factor:   change Mt / Nt / BLOCK_SIZE comptime params
  - precision:       reduce f32->f16 where numerics tolerate it
  - mesh_shape:      change fabric_dims; run.py must be amended to match
  - comm_pattern:    swap broadcast/reduce/ring patterns for collectives
  - microthread_use: enable WSE-3 microthreads for hot loops
  - fifo_depth:      change @allocate_fifo depth (smaller = fewer cycles
                     but risks back-pressure)
  - comptime_hoist:  move runtime constants/casts to comptime
  - dsd_chaining:    rebuild DSDs vs @increment_dsd_offset
"""


def _read_baseline(baseline_dir: str | Path) -> Dict[str, str]:
    """Locate layout.csl / pe*.csl / run.py inside a kernel's CSL subdir
    or a csl-examples benchmark dir.
    """
    p = Path(baseline_dir)
    # Accept "kernels/X" (use its CSL/ subdir) OR "kernels/X/CSL/" directly.
    if (p / "CSL").is_dir():
        p = p / "CSL"
    out = {"layout": "", "pe": "", "run_py": "", "pe_name": ""}
    layout = p / "layout.csl"
    if layout.is_file():
        out["layout"] = layout.read_text(encoding="utf-8", errors="ignore")
    # Pick the largest-looking pe*.csl as the compute file.
    candidates = sorted(p.glob("pe*.csl"),
                        key=lambda x: x.stat().st_size if x.is_file() else 0,
                        reverse=True)
    if candidates:
        out["pe"] = candidates[0].read_text(encoding="utf-8", errors="ignore")
        out["pe_name"] = candidates[0].name
    run_py = p / "run.py"
    if run_py.is_file():
        out["run_py"] = run_py.read_text(encoding="utf-8", errors="ignore")
    return out


_VARIANT_JSON_RE = re.compile(r"```json\s*(.*?)```", re.DOTALL)


def _parse_variants(reply_text: str) -> List[Dict[str, str]]:
    if not reply_text:
        return []
    m = _VARIANT_JSON_RE.search(reply_text)
    payload = m.group(1).strip() if m else reply_text.strip()
    try:
        data = json.loads(payload)
    except json.JSONDecodeError as exc:
        logging.warning("[mode_variation] variant JSON parse failed: %s", exc)
        return []
    if not isinstance(data, dict):
        return []
    variants = data.get("variants")
    if not isinstance(variants, list):
        return []
    out = []
    for v in variants:
        if isinstance(v, dict) and "id" in v:
            out.append({k: str(v.get(k, "")) for k in
                        ("id", "axis", "hypothesis", "design_choice", "expected_risk")})
    return out


def propose_candidates(*,
                       baseline_dir: str,
                       n_variants: int,
                       proposer_caller: Callable[[str], str],
                       axes: Optional[List[str]] = None,
                       baseline_kind: str = "kernels") -> List[Candidate]:
    """Generate N variant candidates from a baseline bundle.

    ``proposer_caller`` is a ``(prompt) -> str`` LLM call used to ask for the
    variant JSON. Then for each accepted variant we build a Candidate whose
    implementer_prompt is the full bundle-emit template (q_explore_idea
    reused), seeded with the baseline bundle as the "starting point" plus
    the variant brief as the idea.
    """
    baseline = _read_baseline(baseline_dir)
    if not baseline["pe"] or not baseline["layout"]:
        raise FileNotFoundError(
            f"baseline at {baseline_dir} missing layout.csl or pe*.csl"
        )
    axes = axes or DEFAULT_AXES
    axes_block = AXES_DESCRIPTION + "\nSelected axes for this round: " + ", ".join(axes)

    kb_query = (f"baseline {Path(baseline_dir).name} variation tuning "
                + " ".join(axes))
    knowledge = csl_knowledge_base.for_explorer(kb_query)

    proposer_prompt = q_explore_variation.format(
        n_variants=n_variants,
        baseline_layout=baseline["layout"][:3500],
        baseline_pe=baseline["pe"][:6000],
        baseline_run_py=baseline["run_py"][:3500],
        axes_block=axes_block,
        knowledge_base=knowledge,
    )

    try:
        reply = proposer_caller(proposer_prompt)
    except Exception as exc:
        logging.warning("[mode_variation] proposer LLM failed: %s", str(exc)[:200])
        reply = ""

    variants = _parse_variants(reply)
    if not variants:
        # Fall back to one trivial variant: "tweak nothing, just re-run".
        # Useful as a smoke test that the rest of the pipeline works.
        variants = [{
            "id": "noop_resubmit",
            "axis": "noop",
            "hypothesis": "re-run baseline to confirm pipeline works end-to-end",
            "design_choice": "no changes",
            "expected_risk": "should pass and produce baseline cycles",
        }]

    whitelist = builtin_whitelist_block()
    out: List[Candidate] = []
    for v in variants[:n_variants]:
        brief = (
            f"Variant axis: {v.get('axis')}\n"
            f"Hypothesis: {v.get('hypothesis')}\n"
            f"Design choice: {v.get('design_choice')}\n"
            f"Risk: {v.get('expected_risk')}\n\n"
            "Baseline bundle is below; produce a MODIFIED bundle that "
            "applies the variant. Keep run.py compatible (you may amend "
            "fabric_dims / params if the variant requires it)."
        )
        impl_prompt = q_explore_idea.format(
            idea_title=f"{Path(baseline_dir).name}__{v.get('id')}",
            idea_summary=brief
                + "\n\n## Baseline layout.csl\n```csl\n"
                + baseline["layout"][:3500] + "\n```"
                + "\n\n## Baseline compute file\n```csl\n"
                + baseline["pe"][:6000] + "\n```"
                + "\n\n## Baseline run.py\n```python\n"
                + baseline["run_py"][:3500] + "\n```",
            acceptance_numerics=(
                "Keep the existing run.py numpy.testing.assert_allclose "
                "call(s); a variant is correct only if the same checks pass."
            ),
            suggested_mesh="(inherit from baseline unless the axis is mesh_shape)",
            knowledge_base=knowledge,
            prior_lessons="(none specific to this variant)",
            builtin_whitelist=whitelist,
            cycles_send_recipe=CYCLES_SEND_RECIPE,
            layout_requirements=(
                "Mode A (variation): preserve the baseline's mesh shape "
                "UNLESS the variant axis is mesh_shape, in which case "
                "justify the new shape in the design block."
            ),
        )
        out.append(Candidate(
            id=f"{Path(baseline_dir).name}__{v.get('id')}",
            mode="variation",
            idea=f"variation:{Path(baseline_dir).name}:{v.get('axis')}:{v.get('id')}",
            title=f"{Path(baseline_dir).name} variant: {v.get('id')}",
            summary=v.get("hypothesis", ""),
            acceptance_numerics="reuse baseline assert_allclose",
            suggested_mesh="(baseline)",
            features=[v.get("axis", "noop")],
            difficulty="medium",
            architect_prompt=None,
            implementer_prompt=impl_prompt,
            baseline_dir=str(Path(baseline_dir).resolve()),
            baseline_kind=baseline_kind,
            meta={"variant": v, "baseline_pe_name": baseline["pe_name"]},
        ))
    return out


__all__ = ["propose_candidates", "DEFAULT_AXES", "AXES_DESCRIPTION"]
