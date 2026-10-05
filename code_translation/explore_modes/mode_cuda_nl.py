"""Mode C: CUDA-via-natural-language.

Each entry in ``seeds/cuda_nl_catalog.jsonl`` becomes a candidate. The flow
inside one round (per candidate):

  1. (architect-LLM, optional) ``q_cuda_nl_to_spec`` reduces the CUDA
     snippet (or the nl_target alone, if cuda_snippet is empty) to a SPEC.
  2. ``q_cuda_nl_design_from_spec`` plus the SPEC builds the architect
     prompt the implementer pipeline consumes.
  3. The implementer then runs the standard exploration bundle template
     (q_explore_idea) with the SPEC injected as the "summary" and the
     architect's DESIGN as ``prior_lessons``. This lets the same downstream
     parser handle both modes.

The full architect-LLM call happens inside the orchestrator (it needs the
provider handle). This module just builds the prompts.
"""

from __future__ import annotations

import json
import logging
import os
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
    q_cuda_nl_to_spec,
    q_cuda_nl_design_from_spec,
    q_explore_idea,
)
import csl_knowledge_base  # type: ignore  # noqa: E402


REPO_ROOT = _CODE_TRANSLATION.parent
DEFAULT_CATALOG = _CODE_TRANSLATION / "seeds" / "cuda_nl_catalog.jsonl"


def load_catalog(path: str | Path = DEFAULT_CATALOG) -> List[Dict[str, Any]]:
    p = Path(path)
    if not p.is_file():
        logging.warning("[mode_cuda_nl] catalog not found: %s", p)
        return []
    out: List[Dict[str, Any]] = []
    with open(p, "r", encoding="utf-8") as fh:
        for line in fh:
            line = line.strip()
            if not line:
                continue
            try:
                out.append(json.loads(line))
            except json.JSONDecodeError as exc:
                logging.warning("[mode_cuda_nl] malformed catalog line: %s", exc)
    return out


def _filter_entries(catalog: List[Dict[str, Any]],
                    ids: Optional[List[str]] = None,
                    seen_hashes: Optional[set] = None) -> List[Dict[str, Any]]:
    out = list(catalog)
    if ids:
        wanted = set(ids)
        out = [e for e in out if e.get("id") in wanted]
    # Dedup against seen hashes if provided (we hash by id+title for stable keys).
    if seen_hashes:
        import hashlib
        out = [e for e in out
               if hashlib.sha1(f"cuda-nl:{e.get('id','')}:{e.get('title','')}"
                               .encode("utf-8")).hexdigest()[:12] not in seen_hashes]
    return out


def propose_candidates(*,
                       n_candidates: int,
                       catalog_path: Optional[str] = None,
                       only_ids: Optional[List[str]] = None,
                       seen_hashes: Optional[set] = None,
                       spec_caller: Optional[Callable[[str], str]] = None
                       ) -> List[Candidate]:
    """Build candidates from the catalog.

    ``spec_caller``: optional ``(prompt: str) -> str`` LLM call. When provided,
    we materialise the SPEC up-front (step 1) so the implementer prompt is
    fully self-contained. When None (e.g. dry-run / test mode), we splice
    the raw nl_target as the SPEC so a downstream agent could still try.
    """
    entries = _filter_entries(load_catalog(catalog_path or DEFAULT_CATALOG),
                              only_ids, seen_hashes)
    if not entries:
        return []
    entries = entries[:n_candidates]
    whitelist = builtin_whitelist_block()

    out: List[Candidate] = []
    for entry in entries:
        title = str(entry.get("title") or entry.get("id"))
        nl_target = str(entry.get("nl_target") or "")
        cuda_snippet = str(entry.get("cuda_snippet") or "").strip()
        acceptance_notes = str(entry.get("acceptance_notes") or "")
        suggested_mesh = str(entry.get("suggested_mesh") or "single_pe")

        if spec_caller is not None:
            try:
                spec = spec_caller(q_cuda_nl_to_spec.format(
                    cuda_snippet=cuda_snippet or "(no CUDA snippet — write SPEC from the task hint only)",
                    nl_target=nl_target,
                    acceptance_notes=acceptance_notes,
                ))
                if not spec or not spec.strip():
                    spec = f"# Auto-fallback SPEC\n{nl_target}"
            except Exception as exc:
                logging.warning("[mode_cuda_nl] spec LLM call failed for %s: %s",
                                entry.get("id"), str(exc)[:160])
                spec = f"# Auto-fallback SPEC (LLM failed)\n{nl_target}"
        else:
            spec = f"# Auto-fallback SPEC (no spec_caller)\n{nl_target}"

        kb_arch = csl_knowledge_base.for_explorer(
            f"{title}\n{spec[:1200]}\nmesh:{suggested_mesh}"
        )
        architect_prompt = q_cuda_nl_design_from_spec.format(
            spec=spec.strip()[:4000],
            suggested_mesh=suggested_mesh,
            knowledge_base=kb_arch,
        )
        # Implementer prompt: reuse q_explore_idea with the SPEC as the
        # idea summary. The architect-side DESIGN will be appended later in
        # the orchestrator via ``prior_lessons``.
        impl_prompt = q_explore_idea.format(
            idea_title=title,
            idea_summary=spec.strip()[:3000],
            acceptance_numerics=acceptance_notes,
            layout_requirements=(
                "Mode C (CUDA-via-NL): pick a wafer-native decomposition "
                "from the SPEC. There is no enforced PE floor for this "
                "mode yet — the LLM is free to choose the mesh."
            ),
            suggested_mesh=suggested_mesh,
            knowledge_base=kb_arch,
            prior_lessons="(filled in by orchestrator with the DESIGN.md)",
            builtin_whitelist=whitelist,
            cycles_send_recipe=CYCLES_SEND_RECIPE,
        )

        out.append(Candidate(
            id=str(entry.get("id")),
            mode="cuda-nl",
            idea=f"{entry.get('id')}: {title}",
            title=title,
            summary=nl_target,
            acceptance_numerics=acceptance_notes,
            suggested_mesh=suggested_mesh,
            features=list(entry.get("features") or []),
            difficulty=str(entry.get("difficulty") or "medium"),
            architect_prompt=architect_prompt,
            implementer_prompt=impl_prompt,
            catalog_id=str(entry.get("id")),
            meta={"cuda_snippet": cuda_snippet, "spec": spec},
        ))
    return out


__all__ = ["load_catalog", "propose_candidates", "DEFAULT_CATALOG"]
