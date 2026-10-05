"""Optimization planner — round-0 LLM call that decides which files to optimize.

The bench-structure scanner (`bench_structure.py`) discovers WHAT files
exist + their densities. This module takes that snapshot, asks the LLM
"given this structure, which file(s) should the optimizer focus on?",
and caches the answer at ``optimization/plans/<kernel>.json``.

The planner is invoked ONCE per kernel at round 0. Caching is keyed on
the bench's structural fingerprint (root path + editable-import paths +
their LOC counts) so re-running on the same bench is free, but
re-running after a kernel edit (the planner's input changed) triggers a
fresh plan.

For self-contained kernels (Cholesky, GoL, GEMM Collectives 2D,
Laplacian2D-Halo) the planner trivially says "focus on root, expose
root" — same as today's behavior. For thin-dispatcher kernels
(BiCGSTAB, CG, PCG, Power Method) it surfaces the editable libraries
and says "focus on blas.csl, expose root + blas".

The planner does NOT pick the angle for every round (that stays the
angle scheduler's job). It picks the FIRST angle as a hint; everything
else is unchanged.
"""

from __future__ import annotations

import hashlib
import json
import logging
import os
import re
import sys
from dataclasses import asdict, dataclass, field
from pathlib import Path
from typing import Any, Callable, Dict, List, Optional, Tuple

THIS_DIR = Path(__file__).resolve().parent
if str(THIS_DIR) not in sys.path:
    sys.path.insert(0, str(THIS_DIR))

import bench_structure  # type: ignore

logger = logging.getLogger("optimization_planner")

DEFAULT_EXPLORED_ROOT = os.path.expanduser("~/xkernel/knowledge/explored")
PLANS_DIRNAME = "optimization/plans"

# How many lines of each file to include in the planner prompt. The
# planner doesn't need to see every byte — top of file (imports,
# state, key fns) is enough to judge where compute lives.
PROMPT_EXCERPT_LINES_ROOT = 80
PROMPT_EXCERPT_LINES_LIBRARY = 60


@dataclass
class OptimizationPlan:
    """Round-0 decision about which files to optimize.

    ``focus_files`` is the list of relpaths (relative to bench_csl_dir)
    the optimizer will REWRITE each round.

    ``expose_in_prompt`` is the read-only context the LLM sees alongside
    the focus files in each prompt. MUST be a superset of focus_files.

    ``suggested_first_angle`` is a hint for round 1 only; the scheduler
    takes over after that.

    ``fingerprint`` is the cache key — re-planning is skipped when the
    fingerprint of the current bench matches the cached plan's.
    """
    kernel_id: str
    focus_files: List[str]
    expose_in_prompt: List[str]
    rationale: str
    suggested_first_angle: str
    confidence: str
    fingerprint: str
    # Provenance kept for audit / debugging.
    planner_model: Optional[str] = None
    planner_ts: Optional[str] = None

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)

    @classmethod
    def from_dict(cls, d: Dict[str, Any]) -> "OptimizationPlan":
        return cls(
            kernel_id=str(d.get("kernel_id", "")),
            focus_files=list(d.get("focus_files", [])),
            expose_in_prompt=list(d.get("expose_in_prompt", [])),
            rationale=str(d.get("rationale", "")),
            suggested_first_angle=str(d.get("suggested_first_angle", "")),
            confidence=str(d.get("confidence", "unknown")),
            fingerprint=str(d.get("fingerprint", "")),
            planner_model=d.get("planner_model"),
            planner_ts=d.get("planner_ts"),
        )


# ---------------------------------------------------------------------------
# Fingerprint / cache
# ---------------------------------------------------------------------------

def _fingerprint(struct: bench_structure.BenchStructure,
                 preflight_skipped_angles: Optional[List[str]] = None) -> str:
    """Cheap structural hash. Captures: root path, editable import paths,
    their code_loc + compute_loc, AND the pre-flight skip set when
    available. Doesn't capture density (derived) or transitive (planner
    doesn't see those directly). Stable across formatting changes that
    don't touch import structure or compute counts.

    Including the skip set means a plan generated under one skip
    configuration is invalidated when the baseline changes enough that
    pre-flight skips a different set (e.g. someone manually edits the
    baseline to drop a bulk @fmacs, freeing fmac_bulk to re-enter). The
    plan should then regenerate with blas.csl back in scope.
    """
    parts = [
        struct.root_compute.relpath or struct.root_compute.path,
        f"r:{struct.root_compute.code_loc}:{struct.root_compute.compute_loc}",
    ]
    for m in sorted(struct.editable_modules,
                    key=lambda x: x.relpath or x.path):
        parts.append(f"e:{m.relpath or m.path}:{m.code_loc}:{m.compute_loc}")
    if preflight_skipped_angles:
        parts.append("skip:" + ",".join(sorted(preflight_skipped_angles)))
    blob = "\n".join(parts).encode("utf-8")
    return hashlib.sha1(blob).hexdigest()[:16]


def _slug(s: str) -> str:
    out = []
    for ch in (s or "").lower():
        if ch.isalnum():
            out.append(ch)
        elif out and out[-1] != "_":
            out.append("_")
    return "".join(out).strip("_") or "untitled"


def plan_path(kernel_id: str,
              explored_root: str | Path = DEFAULT_EXPLORED_ROOT) -> Path:
    return (Path(os.path.expanduser(str(explored_root)))
            / PLANS_DIRNAME / f"{_slug(kernel_id)}.json")


def load_cached_plan(kernel_id: str,
                     explored_root: str | Path = DEFAULT_EXPLORED_ROOT
                     ) -> Optional[OptimizationPlan]:
    p = plan_path(kernel_id, explored_root)
    if not p.is_file():
        return None
    try:
        d = json.loads(p.read_text(encoding="utf-8"))
        return OptimizationPlan.from_dict(d)
    except Exception as exc:
        logger.warning("[planner] could not parse cached plan %s: %s",
                       p, exc)
        return None


def save_plan(plan: OptimizationPlan,
              explored_root: str | Path = DEFAULT_EXPLORED_ROOT) -> Path:
    p = plan_path(plan.kernel_id, explored_root)
    p.parent.mkdir(parents=True, exist_ok=True)
    tmp = p.with_suffix(p.suffix + ".tmp")
    tmp.write_text(json.dumps(plan.to_dict(), indent=2), encoding="utf-8")
    os.replace(tmp, p)
    return p


# ---------------------------------------------------------------------------
# Trivial-case shortcut (no LLM needed)
# ---------------------------------------------------------------------------

def _trivial_plan_if_obvious(kernel_id: str,
                              struct: bench_structure.BenchStructure,
                              fingerprint: str
                              ) -> Optional[OptimizationPlan]:
    """For kernels with NO editable imports, the planner's answer is
    deterministic: focus on the root, expose only the root. Skip the
    LLM call entirely — same answer, $0 cost.
    """
    if struct.editable_modules:
        return None
    return OptimizationPlan(
        kernel_id=kernel_id,
        focus_files=[struct.root_compute.relpath],
        expose_in_prompt=[struct.root_compute.relpath],
        rationale=(
            f"Self-contained kernel ({len(struct.editable_modules)} "
            f"editable imports). Root density "
            f"{struct.root_compute.density:.1%} over "
            f"{struct.root_compute.code_loc} code lines. No library "
            f"file to consider — focus on root. (Deterministic; no "
            "LLM consulted.)"
        ),
        suggested_first_angle="",  # let the scheduler pick
        confidence="high",
        fingerprint=fingerprint,
    )


# ---------------------------------------------------------------------------
# Prompt assembly
# ---------------------------------------------------------------------------

def _read_excerpt(path: Path, n_lines: int) -> str:
    try:
        text = path.read_text(encoding="utf-8", errors="ignore")
    except OSError as exc:
        return f"(could not read {path}: {exc})"
    lines = text.splitlines()
    if len(lines) <= n_lines:
        return text
    return "\n".join(lines[:n_lines]) + f"\n// ... (truncated; full file is {len(lines)} lines)"


def _format_editable_summary(struct: bench_structure.BenchStructure) -> str:
    if not struct.editable_modules:
        return "  (none — kernel is self-contained)"
    lines = []
    for m in struct.editable_modules:
        flag = " [HIGH-DENSITY library]" if m.density > 0.05 else ""
        lines.append(
            f"  {m.relpath:<50}  "
            f"loc={m.loc:>4}  code={m.code_loc:>4}  "
            f"compute={m.compute_loc:>3}  density={m.density:.1%}{flag}"
        )
    return "\n".join(lines)


def _format_editable_excerpts(struct: bench_structure.BenchStructure,
                              max_files: int = 3) -> str:
    """Show the first N high-density-or-flagged editable files. Cap to
    avoid blowing the prompt budget on big shared libs the planner
    doesn't need to read in full."""
    if not struct.editable_modules:
        return ""
    # Rank by compute_loc (more compute → more likely to be the
    # planner's target).
    ranked = sorted(struct.editable_modules,
                    key=lambda m: -m.compute_loc)[:max_files]
    parts = []
    for m in ranked:
        excerpt = _read_excerpt(Path(m.path), PROMPT_EXCERPT_LINES_LIBRARY)
        parts.append(
            f"### Editable: `{m.relpath}` "
            f"(first ~{PROMPT_EXCERPT_LINES_LIBRARY} lines; "
            f"code={m.code_loc}, compute={m.compute_loc})\n"
            f"```csl\n{excerpt}\n```\n"
        )
    return "\n".join(parts)


def _format_angle_catalog(kernel_group: str, max_angles: int = 14) -> str:
    """Render the angles applicable to this group as `name: short-desc`."""
    try:
        from prompt_cuda2csl import (  # type: ignore
            angles_for_group, angle_metadata,
        )
    except Exception:
        return "  (catalog unavailable)"
    names = angles_for_group(kernel_group)
    if not names:
        return "  (no angles for group)"
    names = names[:max_angles]
    out = []
    for n in names:
        meta = angle_metadata(n) or {}
        desc = (meta.get("description") or "").strip().split("\n")[0][:120]
        out.append(f"  - {n}: {desc}")
    return "\n".join(out)


# ---------------------------------------------------------------------------
# LLM-driven plan
# ---------------------------------------------------------------------------

_JSON_FENCE_RE = re.compile(r"```json\s*\n(.*?)```", re.DOTALL)
_VALID_CONFIDENCE = {"high", "medium", "low"}


def _parse_plan_reply(reply: str) -> Optional[Dict[str, Any]]:
    if not reply:
        return None
    m = _JSON_FENCE_RE.search(reply)
    payload = m.group(1) if m else reply
    payload = payload.strip()
    try:
        d = json.loads(payload)
    except json.JSONDecodeError:
        return None
    if not isinstance(d, dict):
        return None
    return d


def _build_prompt(kernel_id: str,
                  kernel_group: str,
                  baseline_cycles: Optional[int],
                  struct: bench_structure.BenchStructure,
                  preflight_skipped_angles: Optional[List[str]] = None) -> str:
    from prompt_cuda2csl import q_optimization_planner  # type: ignore
    root_excerpt = _read_excerpt(Path(struct.root_compute.path),
                                  PROMPT_EXCERPT_LINES_ROOT)
    if preflight_skipped_angles:
        skipped_block = (
            "Angles ALREADY SATISFIED by the baseline (pre-flight will "
            "skip these — do NOT propose focus_files justified by them):\n"
            + "\n".join(f"  - {a}" for a in preflight_skipped_angles)
            + "\n\n"
            "If a helper file's only justification is an angle in this "
            "list (e.g. blas.csl whose only relevance is fmac_bulk, but "
            "fmac_bulk was skipped), DROP that helper from focus_files. "
            "It will not be edited and only consumes prompt budget."
        )
    else:
        skipped_block = "(no angles already satisfied — full catalog applies)"
    return q_optimization_planner.format(
        kernel_id=kernel_id,
        kernel_group=kernel_group,
        baseline_cycles=baseline_cycles or "(unknown)",
        root_relpath=struct.root_compute.relpath,
        root_loc=struct.root_compute.loc,
        root_code_loc=struct.root_compute.code_loc,
        root_compute_loc=struct.root_compute.compute_loc,
        root_density=f"{struct.root_compute.density:.1%}",
        root_is_thin=str(struct.root_is_thin_dispatcher),
        editable_summary=_format_editable_summary(struct),
        stdlib_imports=", ".join(struct.stdlib_imports) or "(none)",
        angle_catalog=_format_angle_catalog(kernel_group),
        preflight_skipped_block=skipped_block,
        root_excerpt=root_excerpt,
        editable_excerpts=_format_editable_excerpts(struct),
    )


# Thin-dispatcher + hot-helper auto-promotion thresholds.
# Reasoning lives in the planner prompt's "case B" section and the
# _maybe_promote_thin_dispatcher docstring; keep these constants in sync
# with that prose.
_THIN_DISPATCHER_DENSITY_MAX = 0.05   # root must be < 5% density
_HOT_HELPER_DENSITY_MIN      = 0.07   # helper must be >= 7% density


def _maybe_promote_thin_dispatcher(
        focus: List[str],
        expose: List[str],
        struct: bench_structure.BenchStructure,
        rationale: str,
) -> Tuple[List[str], List[str], Optional[str]]:
    """Deterministic post-validation that fixes the most common planner
    failure mode: the LLM correctly identifies a hot helper in its
    rationale but emits focus_files of length 1.

    Two shapes get auto-promoted to multi-file:

      (1) The LLM picked ONLY the root, but the bench is the
          thin-dispatcher + hot-helper shape (root density < 5%, some
          editable helper >= 7% density). Add the hottest helper to
          focus_files. Without this, ``_is_multifile()`` never trips
          and the LLM never gets to edit the helper — the immune-kernels
          regression we observed in live runs.

      (2) The LLM picked ONLY a helper (e.g. ['src/blas.csl']) — that
          plan can't actually be executed because the single-file path
          edits ``target.target_relpath`` (the dispatcher) ignoring the
          plan, and the multi-file path requires len(focus) > 1. Add
          the root to focus_files so the multi-file path engages and
          the LLM can coordinate edits across the call boundary.

    Returns (new_focus, new_expose, promotion_note). promotion_note is
    None if nothing changed; otherwise a short prose line we'll prepend
    to the rationale so the audit trail shows the auto-fix.
    """
    root_rel = struct.root_compute.relpath
    root_density = struct.root_compute.density
    # Combine first-level editable + transitive; the transitive walk
    # picks up benchmark-libs/<lib>/pe.csl which can also be the hot
    # helper for some kernels.
    helpers = list(struct.editable_modules) + list(struct.transitive_modules)
    hot_helpers = sorted(
        (m for m in helpers if m.density >= _HOT_HELPER_DENSITY_MIN
         and m.relpath != root_rel),
        key=lambda m: m.density,
        reverse=True,
    )
    if not hot_helpers:
        return focus, expose, None
    hottest = hot_helpers[0].relpath
    is_thin_root = root_density < _THIN_DISPATCHER_DENSITY_MAX

    # Case (1): root-only, but it's a thin dispatcher with a hot helper.
    if (focus == [root_rel] and is_thin_root):
        new_focus = [root_rel, hottest]
        new_expose = list(expose)
        for f in new_focus:
            if f not in new_expose:
                new_expose.append(f)
        note = (
            f"[AUTO-PROMOTE] root density {root_density:.1%} < "
            f"{_THIN_DISPATCHER_DENSITY_MAX:.0%} and helper {hottest!r} "
            f"density {hot_helpers[0].density:.1%} >= "
            f"{_HOT_HELPER_DENSITY_MIN:.0%}; planner's root-only "
            "focus_files extended to multi-file."
        )
        return new_focus, new_expose, note

    # Case (2): a single helper, no root.
    if (len(focus) == 1 and focus[0] != root_rel
            and focus[0] in {m.relpath for m in helpers}):
        new_focus = [root_rel, focus[0]]
        new_expose = list(expose)
        for f in new_focus:
            if f not in new_expose:
                new_expose.append(f)
        note = (
            f"[AUTO-PROMOTE] planner picked helper-only {focus[0]!r}; "
            "added root to focus_files so the multi-file dispatch "
            "engages (helper-alone plans cannot be executed)."
        )
        return new_focus, new_expose, note

    return focus, expose, None


def _drop_blas_when_fmac_bulk_skipped(
        focus: List[str],
        expose: List[str],
        struct: bench_structure.BenchStructure,
        preflight_skipped_angles: Optional[List[str]],
) -> Tuple[List[str], List[str], Optional[str]]:
    """Deterministic guard: when pre-flight skips fmac_bulk (i.e. the
    baseline already uses bulk @fmacs on a DSD), drop a blas-like
    helper from focus_files and keep it read-only in expose. The
    BiCGSTAB-family kernels surfaced this case: blas.csl is purely
    bulk-DSD BLAS, fmac_bulk is its only catalog-targetable optimization,
    pre-flight skips fmac_bulk → blas.csl in focus_files is wasted
    prompt budget that distracts the LLM from the dispatcher angles
    (iterative_phase_fusion, dsd_offset_chaining, async_detach_overlap,
    etc.) that ARE in play.

    Heuristic for "blas-like": helper relpath ends with /blas.csl or
    is exactly blas.csl. This avoids accidentally demoting helpers
    that happen to have other names but admit non-fmac_bulk angles.
    """
    if not preflight_skipped_angles or "fmac_bulk" not in preflight_skipped_angles:
        return focus, expose, None
    root_rel = struct.root_compute.relpath
    def _is_blas_like(rel: str) -> bool:
        base = os.path.basename(rel or "").lower()
        return base == "blas.csl"
    demoted = [f for f in focus if _is_blas_like(f) and f != root_rel]
    if not demoted:
        return focus, expose, None
    new_focus = [f for f in focus if f not in demoted]
    # If demotion leaves focus empty, abort the demotion — better to
    # waste a round than have an empty plan.
    if not new_focus:
        return focus, expose, None
    # Keep demoted helpers in expose (read-only) so the LLM can still
    # see their call signatures when reasoning about the dispatcher.
    new_expose = list(expose)
    for d in demoted:
        if d not in new_expose:
            new_expose.append(d)
    note = (
        f"[DROP-HELPER] pre-flight skipped fmac_bulk (baseline already "
        f"uses bulk @fmacs on a DSD), so blas-like helper(s) "
        f"{demoted} were demoted from focus_files to read-only context. "
        "No remaining catalog angle targets bulk-BLAS helpers."
    )
    return new_focus, new_expose, note


def _validate_and_normalise_plan(
        parsed: Dict[str, Any],
        struct: bench_structure.BenchStructure,
        preflight_skipped_angles: Optional[List[str]] = None,
) -> Optional[Dict[str, Any]]:
    """Sanity-check the LLM's JSON. Returns the cleaned dict or None on
    irrecoverable garbage. Filters focus_files / expose_in_prompt to
    relpaths that ACTUALLY exist in the bench (root + editable
    modules); silently drops anything the LLM hallucinated.

    Two deterministic post-validations are applied in order:
      1. ``_maybe_promote_thin_dispatcher`` — adds the helper when the
         LLM picked root-only on the thin-dispatcher+hot-helper shape,
         or adds the root when the LLM picked helper-only.
      2. ``_drop_blas_when_fmac_bulk_skipped`` — removes a blas-like
         helper from focus_files when pre-flight skipped fmac_bulk.

    Both can fire on the same plan: e.g. LLM picks root-only, promotion
    adds blas.csl, then the fmac_bulk-skip guard removes blas.csl back
    to read-only. End state is correct: root-only focus with blas.csl
    visible for context.
    """
    valid_relpaths = {struct.root_compute.relpath}
    valid_relpaths.update(m.relpath for m in struct.editable_modules)
    valid_relpaths.update(m.relpath for m in struct.transitive_modules)
    focus = [f for f in (parsed.get("focus_files") or [])
             if isinstance(f, str) and f in valid_relpaths]
    expose = [f for f in (parsed.get("expose_in_prompt") or [])
              if isinstance(f, str) and f in valid_relpaths]
    if not focus:
        # No valid focus file — bail to the trivial plan.
        return None
    # expose_in_prompt MUST be a superset of focus_files.
    for f in focus:
        if f not in expose:
            expose.append(f)
    rationale_raw = str(parsed.get("rationale", ""))[:1500]
    focus, expose, promo_note = _maybe_promote_thin_dispatcher(
        focus, expose, struct, rationale_raw,
    )
    focus, expose, drop_note = _drop_blas_when_fmac_bulk_skipped(
        focus, expose, struct, preflight_skipped_angles,
    )
    notes = "\n\n".join(n for n in (promo_note, drop_note) if n)
    rationale = f"{notes}\n\n{rationale_raw}" if notes else rationale_raw
    confidence = str(parsed.get("confidence", "medium")).lower().strip()
    if confidence not in _VALID_CONFIDENCE:
        confidence = "medium"
    return {
        "focus_files": focus,
        "expose_in_prompt": expose,
        "rationale": rationale[:1700],
        "suggested_first_angle": str(
            parsed.get("suggested_first_angle", "")).strip(),
        "confidence": confidence,
    }


def make_plan(kernel_id: str,
              kernel_group: str,
              baseline_cycles: Optional[int],
              struct: bench_structure.BenchStructure,
              llm_call: Callable[[str], str],
              planner_model: Optional[str] = None,
              ts: Optional[str] = None,
              preflight_skipped_angles: Optional[List[str]] = None
              ) -> OptimizationPlan:
    """Build the plan (no caching here — caller manages cache).

    ``llm_call`` is a one-shot prompt→reply callable. Errors and parse
    failures fall back to the trivial "focus on root, expose root" plan
    rather than blocking the optimization run.

    ``preflight_skipped_angles`` (when provided) is the list of catalog
    angles already implemented by the baseline (e.g. ``fmac_bulk`` for
    the BiCGSTAB family whose blas.csl is already bulk-DSD). The
    planner uses this to avoid proposing a helper file whose ONLY
    relevance to the kernel is an already-skipped angle — those helpers
    pure noise that distracts the LLM from the dispatcher angles that
    ARE in play. See _drop_helpers_with_only_skipped_applicability.
    """
    fp = _fingerprint(struct, preflight_skipped_angles)
    trivial = _trivial_plan_if_obvious(kernel_id, struct, fp)
    if trivial is not None:
        return trivial
    prompt = _build_prompt(kernel_id, kernel_group, baseline_cycles, struct,
                            preflight_skipped_angles=preflight_skipped_angles)
    try:
        reply = llm_call(prompt)
    except Exception as exc:
        logger.warning("[planner] LLM call failed for %s: %s",
                       kernel_id, str(exc)[:200])
        return _fallback_plan(kernel_id, struct, fp, planner_model, ts,
                              "LLM call errored")
    parsed = _parse_plan_reply(reply)
    if parsed is None:
        logger.warning("[planner] %s: unparseable plan reply; "
                       "falling back to root-only", kernel_id)
        return _fallback_plan(kernel_id, struct, fp, planner_model, ts,
                              "reply not valid JSON")
    validated = _validate_and_normalise_plan(
        parsed, struct,
        preflight_skipped_angles=preflight_skipped_angles,
    )
    if validated is None:
        return _fallback_plan(kernel_id, struct, fp, planner_model, ts,
                              "focus_files invalid or empty")
    return OptimizationPlan(
        kernel_id=kernel_id,
        focus_files=validated["focus_files"],
        expose_in_prompt=validated["expose_in_prompt"],
        rationale=validated["rationale"],
        suggested_first_angle=validated["suggested_first_angle"],
        confidence=validated["confidence"],
        fingerprint=fp,
        planner_model=planner_model,
        planner_ts=ts,
    )


def _fallback_plan(kernel_id: str,
                   struct: bench_structure.BenchStructure,
                   fp: str,
                   planner_model: Optional[str],
                   ts: Optional[str],
                   reason: str) -> OptimizationPlan:
    return OptimizationPlan(
        kernel_id=kernel_id,
        focus_files=[struct.root_compute.relpath],
        expose_in_prompt=[struct.root_compute.relpath],
        rationale=(
            f"FALLBACK: planner skipped ({reason}). Defaulting to "
            "root-only focus to preserve original behavior."
        ),
        suggested_first_angle="",
        confidence="low",
        fingerprint=fp,
        planner_model=planner_model,
        planner_ts=ts,
    )


def get_or_make_plan(*,
                     kernel_id: str,
                     kernel_group: str,
                     baseline_cycles: Optional[int],
                     struct: bench_structure.BenchStructure,
                     llm_call: Callable[[str], str],
                     planner_model: Optional[str] = None,
                     ts: Optional[str] = None,
                     explored_root: str | Path = DEFAULT_EXPLORED_ROOT,
                     force_replan: bool = False,
                     preflight_skipped_angles: Optional[List[str]] = None
                     ) -> OptimizationPlan:
    """The single entry point optimize_explore should call at round 0.

    Loads cached plan if present and fingerprint matches; otherwise
    builds a fresh plan (LLM or trivial) and caches it.

    ``preflight_skipped_angles`` (when provided) is folded into the
    fingerprint so a cached plan is invalidated when the baseline's
    pre-flight skip set changes (e.g. someone manually drops a bulk
    @fmacs and fmac_bulk re-enters the catalog).
    """
    fp = _fingerprint(struct, preflight_skipped_angles)
    if not force_replan:
        cached = load_cached_plan(kernel_id, explored_root)
        if cached and cached.fingerprint == fp:
            logger.info("[planner] %s: using cached plan (focus=%s)",
                        kernel_id, cached.focus_files)
            return cached
    plan = make_plan(
        kernel_id=kernel_id,
        kernel_group=kernel_group,
        baseline_cycles=baseline_cycles,
        struct=struct,
        llm_call=llm_call,
        planner_model=planner_model,
        ts=ts,
        preflight_skipped_angles=preflight_skipped_angles,
    )
    try:
        save_plan(plan, explored_root)
    except Exception as exc:
        logger.warning("[planner] could not persist plan for %s: %s",
                       kernel_id, str(exc)[:200])
    logger.info("[planner] %s: focus=%s expose=%s first_angle=%s confidence=%s",
                kernel_id, plan.focus_files, plan.expose_in_prompt,
                plan.suggested_first_angle or "(scheduler picks)",
                plan.confidence)
    return plan


__all__ = [
    "OptimizationPlan",
    "DEFAULT_EXPLORED_ROOT",
    "plan_path",
    "load_cached_plan",
    "save_plan",
    "make_plan",
    "get_or_make_plan",
]
