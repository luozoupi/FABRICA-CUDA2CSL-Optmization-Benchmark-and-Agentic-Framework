"""Per-kernel optimization-accept tree.

Each kernel that has been optimized produces a chain (or DAG) of accepted
variants. Today the orchestrator tracks them only as a flat list in
``experiences.jsonl``, so a Cholesky session that branches off the
original baseline (rather than chaining off a previous accept) gets lost
in the timeline — the next round picks the latest-by-timestamp accept as
baseline even when an earlier sibling branch reached lower cycles.

This module gives us:
  * one ``optimization/trees/<kernel>.json`` per kernel with nodes,
    edges (parent), branches, leaves, and the running ``current_best``
  * one ``optimization/trees/pattern_index.json`` mapping pattern_id →
    list of (kernel, node_id, bundle) where that pattern fired
  * helpers the orchestrator can call to:
      - resolve "what pe.csl should I baseline against for kernel X"
        (= current_best.bundle's pe.csl, falling back to the original
        kernels/<X>/CSL/pe.csl when no accepts exist yet)
      - record a new accept (append node, recompute leaves +
        current_best, scan diff for known patterns, update index)
      - report cross-kernel pattern coverage for the angle scheduler
        to bias toward patterns that won on ≥2 other kernels but
        haven't been tried on this one

Tree schema (per file):
{
  "kernel": "Cholesky",
  "baseline_cycles": 12479,
  "current_best": {"cycles": 11549, "node_id": "n6"},
  "nodes": {
    "root": {"cycles": 12479, "bundle": null,  "parent": null,
             "angle": null, "ts": null, "patterns": []},
    "n1":   {"cycles": 11702, "bundle": "...070553Z",
             "parent": "root", "angle": "buffer_cleanup",
             "ts": "20260604T070553Z", "patterns": ["promote_var_dsd_to_const"]},
    ...
  },
  "branches": [["n1"], ["n2"], ["n4","n5","n6"]],
  "leaves":   ["n1","n2","n6"]
}

Branches are reconstructed: every node whose parent isn't another
accepted node's parent ID is a branch head; nodes form a chain when
they explicitly cite a prior accept as their fork point.
"""

from __future__ import annotations

import json
import logging
import os
import re
import tempfile
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

logger = logging.getLogger("optimization_tree")

DEFAULT_EXPLORED_ROOT = os.path.expanduser("~/xkernel/knowledge/explored")
TREES_DIRNAME = "optimization/trees"
PATTERN_INDEX_NAME = "pattern_index.json"
PROMOTE_CANDIDATES_DIRNAME = "optimization/patterns/_candidates"

# How many distinct kernels a pattern must span before we emit a
# promotion-candidate file. Matches what was used by hand for
# column_gather_via_strided_dsd (5 kernels) and is the threshold the
# 2nd-promotion analysis used for inline_for_comptime_N_dsd_unroll (3).
PROMOTE_KERNEL_THRESHOLD = 3


# ---------------------------------------------------------------------------
# Pattern detectors
# ---------------------------------------------------------------------------
#
# Each detector is a regex over diff_summary.md text. The string returned
# is the pattern_id; multiple patterns can fire per diff. Detectors are
# intentionally permissive (catch the pattern even when phrased slightly
# differently in different diffs) — false positives are cheaper than
# false negatives for cross-kernel deduplication.

_PATTERN_DETECTORS = [
    # Strided DSD that walks a tile's column/row by stride-Nt — the
    # already-promoted angle from Laplacian2D-Halo. Detected here too
    # so the index stays consistent.
    ("column_gather_via_strided_dsd",
     re.compile(r"(stride[-_ ]?Nt|strided\s+mem1d_dsd|@fmovs.*tile_col|extract_columns)",
                re.IGNORECASE)),

    # The inline-for + @increment_dsd_offset pattern. NOTE: this is the
    # same idiom as the catalog's per_row_dsd_unroll (added 2026-06-04
    # from Laplacian2D-Halo wins). Keeping a single canonical id
    # `per_row_dsd_unroll` for both detector + catalog so the cross-kernel
    # promotion counter and the named-angle scheduler agree on identity.
    ("per_row_dsd_unroll",
     re.compile(r"(inline\s+for.*@(?:range|increment_dsd_offset)|@increment_dsd_offset.*inline\s+for|per_row_dsd_unroll)",
                re.IGNORECASE)),

    # Async-completion task chaining that eliminates intermediate hops.
    ("task_hop_elimination_via_async_chaining",
     re.compile(r"(\.activate\s*=|\.unblock|completion\s+task|chain.*completion|async.*activate)",
                re.IGNORECASE)),

    # Promote var → const for DSDs that are never reassigned.
    ("promote_var_dsd_to_const",
     re.compile(r"(promoted?\s+from\s+`?var`?\s+to\s+`?const`?|var.*never\s+reassigned)",
                re.IGNORECASE)),

    # Hoist comptime constants like MN, MN_MINUS_NT, NT_MINUS_1.
    ("hoist_comptime_constants",
     re.compile(r"(hoist(ed)?\s+`?[A-Z_][A-Z0-9_]*`?|comptime\s+constant.*hoist|fold.*MN|MN_MINUS_NT|NT_MINUS_1)",
                re.IGNORECASE)),

    # Pingpong / swap-buffer trick (skip terminal copy-back).
    ("skip_terminal_copyback_pingpong",
     re.compile(r"(skip.*copy[-_ ]?back|swap\s+buffer|ping[-_ ]?pong|remaining_iters\s*==\s*1)",
                re.IGNORECASE)),
]


def detect_patterns(diff_text: str) -> List[str]:
    """Return the pattern_ids whose detectors match `diff_text`."""
    if not diff_text:
        return []
    hits = []
    for pid, regex in _PATTERN_DETECTORS:
        if regex.search(diff_text):
            hits.append(pid)
    return hits


# ---------------------------------------------------------------------------
# Persistence layer
# ---------------------------------------------------------------------------

def _trees_dir(explored_root: str | Path) -> Path:
    p = Path(os.path.expanduser(str(explored_root))) / TREES_DIRNAME
    p.mkdir(parents=True, exist_ok=True)
    return p


def _slug(s: str) -> str:
    """Normalise kernel id to a filesystem-safe slug. Mirrors
    knowledge_persistence._slug for cross-consistency."""
    out = []
    for ch in (s or "").lower():
        if ch.isalnum():
            out.append(ch)
        elif out and out[-1] != "_":
            out.append("_")
    return "".join(out).strip("_") or "untitled"


def _atomic_write(path: Path, data: Dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(json.dumps(data, indent=2, sort_keys=False), encoding="utf-8")
    os.replace(tmp, path)


def _read_json(path: Path) -> Optional[Dict[str, Any]]:
    if not path.is_file():
        return None
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception as exc:
        logger.warning("[tree] could not parse %s: %s", path, exc)
        return None


def tree_path(kernel: str, explored_root: str | Path = DEFAULT_EXPLORED_ROOT) -> Path:
    return _trees_dir(explored_root) / f"{_slug(kernel)}.json"


def pattern_index_path(explored_root: str | Path = DEFAULT_EXPLORED_ROOT) -> Path:
    return _trees_dir(explored_root) / PATTERN_INDEX_NAME


def _empty_tree(kernel: str, baseline_cycles: Optional[int]) -> Dict[str, Any]:
    return {
        "kernel": kernel,
        "baseline_cycles": baseline_cycles,
        "current_best": {"cycles": baseline_cycles, "node_id": "root"},
        "nodes": {
            "root": {
                "cycles": baseline_cycles,
                "bundle": None,
                "parent": None,
                "angle": None,
                "ts": None,
                "patterns": [],
            },
        },
        "branches": [],
        "leaves": [],
    }


# ---------------------------------------------------------------------------
# Tree manipulation
# ---------------------------------------------------------------------------

def load_tree(kernel: str,
              explored_root: str | Path = DEFAULT_EXPLORED_ROOT
              ) -> Optional[Dict[str, Any]]:
    """Return the tree for ``kernel`` or None when it doesn't exist yet."""
    return _read_json(tree_path(kernel, explored_root))


def save_tree(tree: Dict[str, Any],
              explored_root: str | Path = DEFAULT_EXPLORED_ROOT) -> Path:
    p = tree_path(tree["kernel"], explored_root)
    _atomic_write(p, tree)
    return p


def _next_node_id(tree: Dict[str, Any]) -> str:
    nums = []
    for nid in tree["nodes"]:
        m = re.match(r"^n(\d+)$", nid)
        if m:
            nums.append(int(m.group(1)))
    n = (max(nums) + 1) if nums else 1
    return f"n{n}"


def _recompute_branches_leaves(tree: Dict[str, Any]) -> None:
    """Reconstruct ``branches`` and ``leaves`` from the parent graph.

    A leaf is any node whose ID is no other node's ``parent`` AND that
    isn't the synthetic ``root``.

    A branch is a chain from a child-of-root down to a leaf (or the
    deepest accepted node in that lineage). One branch per root child.
    """
    nodes = tree["nodes"]
    parent_of: Dict[str, Optional[str]] = {nid: n.get("parent") for nid, n in nodes.items()}
    children_of: Dict[str, List[str]] = {}
    for nid, par in parent_of.items():
        if par is not None:
            children_of.setdefault(par, []).append(nid)
    # Leaves: nodes with no children, excluding root if there are any
    # accepted nodes (root is never a "leaf" in the accept sense).
    leaves = [
        nid for nid in nodes
        if nid != "root" and not children_of.get(nid)
    ]
    leaves.sort(key=lambda nid: nodes[nid].get("ts") or "")
    # Branches: walk down from each root-child.
    branches: List[List[str]] = []
    root_children = children_of.get("root", [])
    root_children.sort(key=lambda nid: nodes[nid].get("ts") or "")
    for rc in root_children:
        chain = [rc]
        cur = rc
        while children_of.get(cur):
            # If there's branching, the longest-chain wins for "the
            # canonical branch from this root-child"; multi-child
            # subtrees produce additional branch entries below.
            nexts = sorted(
                children_of[cur],
                key=lambda nid: nodes[nid].get("ts") or "",
            )
            # Continue the chain with the EARLIEST child; siblings get
            # their own branch entries on subsequent root-child passes.
            cur = nexts[0]
            chain.append(cur)
            if len(nexts) > 1:
                # Each additional child becomes its own branch starting
                # at that node (a sub-branch).
                for sibling in nexts[1:]:
                    sib_chain = [sibling]
                    walk = sibling
                    while children_of.get(walk):
                        walk = sorted(
                            children_of[walk],
                            key=lambda nid: nodes[nid].get("ts") or "",
                        )[0]
                        sib_chain.append(walk)
                    branches.append(sib_chain)
        branches.append(chain)
    tree["branches"] = branches
    tree["leaves"] = leaves


def _recompute_current_best(tree: Dict[str, Any]) -> None:
    nodes = tree["nodes"]
    best_id, best_cycles = "root", nodes["root"].get("cycles")
    for nid, n in nodes.items():
        c = n.get("cycles")
        if c is None:
            continue
        if best_cycles is None or c < best_cycles:
            best_id, best_cycles = nid, c
    tree["current_best"] = {"cycles": best_cycles, "node_id": best_id}


def add_accept(tree: Dict[str, Any],
               *,
               cycles: int,
               bundle: str,
               angle: str,
               ts: str,
               parent_cycles: Optional[int] = None,
               patterns: Optional[List[str]] = None) -> str:
    """Append an accepted variant to ``tree``. Returns the new node_id.

    ``parent_cycles`` resolves which node this variant forked from. If
    None, defaults to the node matching ``cycles_in == tree.current_best``
    (the most common case — a new accept in the current chain). If
    ``parent_cycles`` is given, we look for any existing node with that
    cycle count; if multiple match, we pick the most-recent by ts (the
    parent the orchestrator was actually optimising against).
    """
    parent_id = "root"
    if parent_cycles is None:
        parent_id = tree["current_best"]["node_id"]
    else:
        matches = [
            (nid, n) for nid, n in tree["nodes"].items()
            if n.get("cycles") == parent_cycles
        ]
        if matches:
            matches.sort(key=lambda kv: kv[1].get("ts") or "")
            parent_id = matches[-1][0]
        else:
            # No node matches parent_cycles; this is a fork off root.
            parent_id = "root"
    nid = _next_node_id(tree)
    tree["nodes"][nid] = {
        "cycles": int(cycles),
        "bundle": bundle,
        "parent": parent_id,
        "angle": angle,
        "ts": ts,
        "patterns": list(patterns or []),
    }
    _recompute_branches_leaves(tree)
    _recompute_current_best(tree)
    return nid


# ---------------------------------------------------------------------------
# Pattern index
# ---------------------------------------------------------------------------

def load_pattern_index(explored_root: str | Path = DEFAULT_EXPLORED_ROOT
                       ) -> Dict[str, List[Dict[str, str]]]:
    p = pattern_index_path(explored_root)
    data = _read_json(p)
    return data or {}


def save_pattern_index(index: Dict[str, List[Dict[str, str]]],
                       explored_root: str | Path = DEFAULT_EXPLORED_ROOT) -> Path:
    p = pattern_index_path(explored_root)
    _atomic_write(p, index)
    return p


def update_pattern_index(*,
                         patterns: List[str],
                         kernel: str,
                         node_id: str,
                         bundle: str,
                         explored_root: str | Path = DEFAULT_EXPLORED_ROOT
                         ) -> Dict[str, List[Dict[str, str]]]:
    if not patterns:
        return load_pattern_index(explored_root)
    index = load_pattern_index(explored_root)
    for pid in patterns:
        slot = index.setdefault(pid, [])
        # Dedup: skip if (kernel, bundle) already recorded.
        key = (kernel, bundle)
        if any((e.get("kernel"), e.get("bundle")) == key for e in slot):
            continue
        slot.append({"kernel": kernel, "node_id": node_id, "bundle": bundle})
    save_pattern_index(index, explored_root)
    return index


def kernels_for_pattern(pattern_id: str,
                        explored_root: str | Path = DEFAULT_EXPLORED_ROOT
                        ) -> List[str]:
    index = load_pattern_index(explored_root)
    return sorted({e["kernel"] for e in index.get(pattern_id, [])})


def promotion_candidates(threshold: int = PROMOTE_KERNEL_THRESHOLD,
                         explored_root: str | Path = DEFAULT_EXPLORED_ROOT
                         ) -> List[Tuple[str, List[str]]]:
    """Return [(pattern_id, [kernels])] for patterns that span ≥ threshold
    kernels and aren't yet in the named-angle catalog."""
    index = load_pattern_index(explored_root)
    # Best-effort: import the catalog to see what's already promoted.
    try:
        import sys as _sys
        _sys.path.insert(0, str(Path(__file__).parent))
        from prompt_cuda2csl import CSL_OPTIMIZATION_STEPS_CATALOG  # type: ignore
        promoted = set(CSL_OPTIMIZATION_STEPS_CATALOG.keys())
    except Exception:
        promoted = set()
    out = []
    for pid, entries in index.items():
        kernels = sorted({e["kernel"] for e in entries})
        if len(kernels) >= threshold and pid not in promoted:
            out.append((pid, kernels))
    return sorted(out, key=lambda t: -len(t[1]))


# ---------------------------------------------------------------------------
# Orchestrator integration
# ---------------------------------------------------------------------------

def current_best_pe_path(kernel: str,
                         explored_root: str | Path = DEFAULT_EXPLORED_ROOT
                         ) -> Optional[Path]:
    """Return the absolute path to the current-best ``pe.csl`` for
    ``kernel``, or None when the tree is empty (no accepts yet, use the
    kernel's original pe.csl).
    """
    tree = load_tree(kernel, explored_root)
    if not tree:
        return None
    best = tree.get("current_best") or {}
    nid = best.get("node_id")
    if not nid or nid == "root":
        return None
    node = tree["nodes"].get(nid) or {}
    bundle = node.get("bundle")
    if not bundle:
        return None
    # Bundle name is the dir under optimization/accepted/.
    accepted_dir = (Path(os.path.expanduser(str(explored_root)))
                    / "optimization" / "accepted" / bundle)
    pe = accepted_dir / "pe.csl"
    return pe if pe.is_file() else None


def record_accept_in_tree(*,
                          kernel: str,
                          baseline_cycles: int,
                          candidate_cycles: int,
                          parent_cycles: Optional[int],
                          bundle: str,
                          angle: str,
                          ts: str,
                          diff_summary_text: str,
                          explored_root: str | Path = DEFAULT_EXPLORED_ROOT
                          ) -> Tuple[Dict[str, Any], List[str]]:
    """Single-call wrapper the orchestrator uses on every accept.

    Loads (or creates) the tree, detects patterns in the diff, appends
    the node, updates the pattern index. Returns (updated tree, pattern
    ids that fired).
    """
    tree = load_tree(kernel, explored_root) or _empty_tree(kernel, baseline_cycles)
    if tree.get("baseline_cycles") is None:
        tree["baseline_cycles"] = baseline_cycles
        tree["nodes"]["root"]["cycles"] = baseline_cycles
        _recompute_current_best(tree)
    patterns = detect_patterns(diff_summary_text)
    nid = add_accept(
        tree,
        cycles=candidate_cycles,
        bundle=bundle,
        angle=angle,
        ts=ts,
        parent_cycles=parent_cycles,
        patterns=patterns,
    )
    save_tree(tree, explored_root)
    if patterns:
        update_pattern_index(
            patterns=patterns,
            kernel=kernel,
            node_id=nid,
            bundle=bundle,
            explored_root=explored_root,
        )
    return tree, patterns


__all__ = [
    "DEFAULT_EXPLORED_ROOT",
    "PROMOTE_KERNEL_THRESHOLD",
    "detect_patterns",
    "load_tree", "save_tree", "tree_path",
    "load_pattern_index", "save_pattern_index", "pattern_index_path",
    "update_pattern_index", "kernels_for_pattern", "promotion_candidates",
    "add_accept",
    "current_best_pe_path", "record_accept_in_tree",
]
