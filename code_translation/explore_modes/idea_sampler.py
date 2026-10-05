"""Idea sampler for explore_csl Mode B.

Takes a curated YAML of seed ideas (``code_translation/seeds/idea_seeds.yaml``)
plus existing-kernel coverage info, and emits a ranked list of ideas to try
next. The ranking is:

  weight = base_weight
           + alpha * (# features in the idea that are uncovered by kernels/)
           - beta  * (# prior attempts on this idea, decayed)
           - gamma * (# prior infeasible verdicts on this idea)

Then we sample without replacement, weighted by weight. Ties broken by
features-uncovered. Ideas in the ``infeasible_idea_hashes`` set are HARD-
skipped.

This file is pure-Python; no LLM calls. The orchestrator builds the heavy
prompt around each chosen idea later via ``mode_idea.propose_candidates``.
"""

from __future__ import annotations

import hashlib
import logging
import os
import random
import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Sequence, Set


REPO_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_SEEDS = REPO_ROOT / "code_translation" / "seeds" / "idea_seeds.yaml"


@dataclass
class IdeaSeed:
    """One seed kernel idea.

    Two-axis difficulty (each 1-easy / 2-medium / 3-hard) per the
    2026-06-03 user direction: layout_complexity and compute_complexity
    are independent failure modes in CSL. The overall ``tier`` derives
    from ``max(layout, compute)`` and drives the --difficulty filter.

    ``min_pe_count`` is a HARD floor on @set_rectangle(W,H): the explore
    pipeline's parse-time mesh gate rejects any candidate with W*H below
    this. Default derives from layout_complexity (1->1, 2->4, 3->4) so
    older seeds without an explicit override still work.
    """
    id: str
    title: str
    summary: str
    acceptance_numerics: str
    suggested_mesh: str
    features: List[str] = field(default_factory=list)
    # Legacy single-axis label (kept for back-compat with the CLI's
    # --difficulty filter that pre-dated the two-axis model). When the
    # YAML omits it we derive from max(layout, compute).
    difficulty: str = ""
    notes: str = ""
    # New two-axis fields. 0 means "unspecified" — code derives a
    # conservative default when reading them.
    layout_complexity: int = 0
    compute_complexity: int = 0
    min_pe_count: int = 0

    def __post_init__(self) -> None:
        # Backfill complexities + min_pe_count from sensible defaults so
        # an older YAML (without these fields) still loads.
        if self.layout_complexity not in (1, 2, 3):
            self.layout_complexity = _infer_layout_from_mesh(self.suggested_mesh)
        if self.compute_complexity not in (1, 2, 3):
            self.compute_complexity = 2  # neutral default
        if self.min_pe_count <= 0:
            self.min_pe_count = _default_min_pe_count(self.layout_complexity,
                                                      self.suggested_mesh)
        if not self.difficulty:
            self.difficulty = self.tier

    @property
    def tier(self) -> str:
        """Derived overall difficulty: max of the two axes."""
        m = max(self.layout_complexity, self.compute_complexity)
        return {1: "easy", 2: "medium", 3: "hard"}.get(m, "medium")

    @property
    def hash(self) -> str:
        return hashlib.sha1((self.title or self.id).encode("utf-8")).hexdigest()[:12]


def _infer_layout_from_mesh(mesh_hint: str) -> int:
    h = (mesh_hint or "").lower()
    if "single" in h or h in ("1x1", "1_pe", ""):
        return 1
    if "1d" in h or h in ("1d_row", "1d_col"):
        return 2
    if "2d" in h or "block" in h or "torus" in h:
        return 3
    return 2


def _default_min_pe_count(layout_complexity: int, mesh_hint: str) -> int:
    # Layout 1 → 1 PE; Layout 2/3 → 4 PE minimum (2×2 or 1×4).
    if layout_complexity <= 1:
        return 1
    return 4


# ---------------------------------------------------------------------------
# Loading
# ---------------------------------------------------------------------------

def load_seeds(path: str | Path = DEFAULT_SEEDS) -> List[IdeaSeed]:
    p = Path(path)
    if not p.is_file():
        logging.warning("[idea_sampler] seed file not found: %s", p)
        return []
    try:
        import yaml  # type: ignore
    except ImportError:
        logging.warning("[idea_sampler] PyYAML not installed; cannot load seeds")
        return []
    try:
        data = yaml.safe_load(p.read_text(encoding="utf-8")) or {}
    except yaml.YAMLError as exc:
        logging.warning("[idea_sampler] seed YAML parse error: %s", exc)
        return []
    out: List[IdeaSeed] = []
    for entry in (data.get("seeds") or []):
        if not isinstance(entry, dict):
            continue
        try:
            out.append(IdeaSeed(
                id=str(entry["id"]),
                title=str(entry.get("title") or entry["id"]),
                summary=str(entry.get("summary") or ""),
                acceptance_numerics=str(entry.get("acceptance_numerics") or ""),
                suggested_mesh=str(entry.get("suggested_mesh") or "single_pe"),
                features=list(entry.get("features") or []),
                # difficulty: still accepted from old YAML; new YAML omits.
                difficulty=str(entry.get("difficulty") or ""),
                notes=str(entry.get("notes") or ""),
                # Two-axis fields. Ints; 0 means "use derived default".
                layout_complexity=int(entry.get("layout_complexity") or 0),
                compute_complexity=int(entry.get("compute_complexity") or 0),
                min_pe_count=int(entry.get("min_pe_count") or 0),
            ))
        except (KeyError, TypeError, ValueError) as exc:
            logging.warning("[idea_sampler] skipping malformed seed: %s", exc)
    return out


# ---------------------------------------------------------------------------
# Coverage
# ---------------------------------------------------------------------------

_FEATURE_KEYWORDS_FOR_KERNEL_TOKENS = {
    # Map CSL token presence to high-level feature tags. Conservative — when
    # we see @fmacs or @fadds we say the kernel covers "fmacs"/"reduction".
    # Used only to compute coverage gaps for sampler weighting, NOT for
    # correctness anywhere.
    "fmacs":                   r"@fmacs",
    "fadds":                   r"@fadds",
    "fmovs":                   r"@fmovs",
    "mem1d_dsd":               r"@get_dsd\s*\(\s*mem1d_dsd",
    "fabric":                  r"fab(?:in|out)_dsd",
    "broadcast":               r"\b(?:row|col)_(?:bcast|broadcast)|memcpy_h2d_(?:row|col)bcast",
    "reduction":               r"reduce|allreduce|fadds.*scan|@fadds",
    "collectives":             r"@import_module\s*\(\s*\"<collectives_2d>",
    "halo_exchange":           r"\bhalo|\bping[_ ]?pong\b|@mov16.*fabric",
    "stencil":                 r"\bstencil\b|7pt|stencil_3d",
    "routing":                 r"@get_color|RoutingPosition|@set_routes",
    "microthreads":            r"@get_microthread|microthread_id|wse-3 microthread",
    "memcpy":                  r"@import_module\s*\(\s*\"<memcpy/",
    "scan":                    r"\bscan\b|cumsum|prefix[_ ]?sum",
    "exp":                     r"@exp\b|math\.exp",
    "sqrt":                    r"@sqrt\b|math\.sqrt|rsqrt",
    "normalization":           r"\b(?:layernorm|rmsnorm|softmax|normalize)\b",
    "gemv":                    r"\bgemv\b|@fmacs.*for\s*\(",
    "gemm":                    r"\bgemm\b|matmul",
    "batched":                 r"\bbatched?\b|batch_size",
    "fft":                     r"\bfft\b|butterfly",
    "scalar_loops_over_arrays": r"for\s*\(\s*@range\s*\(\s*i16",
    "scatter_gather":          r"\bgather\b|\bscatter\b|indirect",
    "two_phase_tree":          r"two[_ ]?phase|up[_ ]?sweep|down[_ ]?sweep",
}


def _read_text_safely(p: Path) -> str:
    try:
        return p.read_text(encoding="utf-8", errors="ignore")
    except OSError:
        return ""


def covered_features_in_kernels(kernels_root: str | Path) -> Set[str]:
    """Walk kernels/<X>/CSL/pe*.csl and return the union of feature tags
    that are detectable from CSL source.

    Best-effort: regex-based and conservative. The point is to give the
    sampler a "what does the bench tree already cover" signal so it can
    bias toward gaps.
    """
    root = Path(kernels_root)
    if not root.is_dir():
        return set()
    covered: Set[str] = set()
    for csl in root.glob("*/CSL/*.csl"):
        text = _read_text_safely(csl)
        if not text:
            continue
        for feat, pattern in _FEATURE_KEYWORDS_FOR_KERNEL_TOKENS.items():
            if re.search(pattern, text, re.IGNORECASE):
                covered.add(feat)
    return covered


# ---------------------------------------------------------------------------
# Sampler
# ---------------------------------------------------------------------------

class IdeaSampler:
    """Stateful sampler.

    Construct once per exploration run; call ``sample(n)`` for each round.
    Uses the ExplorationStore to dedup against prior attempts; the
    ``kernels_root`` argument is used for coverage scoring only.
    """

    def __init__(self,
                 *,
                 seeds: Optional[List[IdeaSeed]] = None,
                 kernels_root: str | Path = REPO_ROOT / "kernels",
                 seen_hashes: Optional[Set[str]] = None,
                 infeasible_hashes: Optional[Set[str]] = None,
                 prior_attempt_counts: Optional[Dict[str, int]] = None,
                 rng_seed: Optional[int] = None,
                 difficulty_filter: Optional[str] = None,
                 layout_complexity_filter: Optional[int] = None,
                 compute_complexity_filter: Optional[int] = None) -> None:
        all_seeds = seeds if seeds is not None else load_seeds()
        # Filters: drop seeds that don't match. None means "no constraint".
        # difficulty_filter is the union (easy/medium/hard tier); axis filters
        # pin each axis exactly. They compose (AND) if multiple are set.
        self.seeds = [
            s for s in all_seeds
            if (difficulty_filter is None or s.tier == difficulty_filter)
            and (layout_complexity_filter is None
                 or s.layout_complexity == layout_complexity_filter)
            and (compute_complexity_filter is None
                 or s.compute_complexity == compute_complexity_filter)
        ]
        self.covered = covered_features_in_kernels(kernels_root)
        self.seen = set(seen_hashes or [])
        self.infeasible = set(infeasible_hashes or [])
        self.attempt_counts = dict(prior_attempt_counts or {})
        self._rng = random.Random(rng_seed) if rng_seed is not None else random.Random()

    def gap_score(self, seed: IdeaSeed) -> int:
        """Number of seed features NOT covered by existing kernels/. Higher
        means more underrepresented."""
        return sum(1 for f in (seed.features or []) if f not in self.covered)

    def weight(self, seed: IdeaSeed,
               *,
               base: float = 1.0,
               alpha: float = 1.2,
               beta: float = 0.5,
               gamma: float = 5.0) -> float:
        if seed.hash in self.infeasible:
            return 0.0
        attempts = self.attempt_counts.get(seed.hash, 0)
        gap = self.gap_score(seed)
        w = base + alpha * gap - beta * attempts
        if seed.hash in self.seen and attempts >= 2:
            w -= gamma * 0.2  # mild discount for already-tried, allow re-try
        # Difficulty bias: prefer easy first, then medium, hard last.
        diff_bias = {"easy": 0.6, "medium": 0.2, "hard": -0.2}
        w += diff_bias.get(seed.difficulty.lower(), 0.0)
        return max(0.0, w)

    def sample(self, n: int) -> List[IdeaSeed]:
        """Return up to n distinct seeds, weighted by ``weight``.

        Falls back to uniform sampling among non-infeasible seeds when all
        weights are zero (e.g. tiny seed pool fully exhausted).
        """
        pool = [s for s in self.seeds if s.hash not in self.infeasible]
        if not pool:
            return []
        weights = [self.weight(s) for s in pool]
        if all(w <= 0 for w in weights):
            # Fall back to uniform — the user explicitly asked for n ideas.
            return self._rng.sample(pool, k=min(n, len(pool)))
        picks: List[IdeaSeed] = []
        local_pool = list(pool)
        local_weights = list(weights)
        for _ in range(min(n, len(local_pool))):
            i = self._weighted_choice(local_weights)
            picks.append(local_pool[i])
            del local_pool[i]
            del local_weights[i]
            if not local_pool or all(w <= 0 for w in local_weights):
                break
        return picks

    def _weighted_choice(self, weights: Sequence[float]) -> int:
        total = sum(w for w in weights if w > 0)
        if total <= 0:
            return self._rng.randrange(len(weights))
        r = self._rng.random() * total
        acc = 0.0
        for i, w in enumerate(weights):
            if w <= 0:
                continue
            acc += w
            if r <= acc:
                return i
        return len(weights) - 1


__all__ = ["IdeaSeed", "load_seeds", "covered_features_in_kernels",
           "IdeaSampler", "DEFAULT_SEEDS"]
