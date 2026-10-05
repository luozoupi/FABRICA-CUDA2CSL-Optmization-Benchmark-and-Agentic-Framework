#!/usr/bin/env python3
"""One-shot script: backfill optimization-tree JSONs from the existing
accepts in ``optimization/experiences.jsonl`` + ``optimization/accepted/``.

Run after the tree machinery (optimization_tree.py) lands. Idempotent —
safe to re-run; an existing tree gets blown away and rebuilt from scratch
so backfill picks up any new pattern detectors added since the last run.

Effect:
  - one ``optimization/trees/<kernel>.json`` per kernel that has at
    least one accept
  - one ``optimization/trees/pattern_index.json`` mapping pattern_id
    to (kernel, node_id, bundle) entries
  - prints a promotion-candidate report at the end

Usage:
    python3 code_translation/backfill_trees.py
    python3 code_translation/backfill_trees.py --explored-root /tmp/test_explored
"""

from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path
from typing import Any, Dict, List

THIS_DIR = Path(__file__).resolve().parent
if str(THIS_DIR) not in sys.path:
    sys.path.insert(0, str(THIS_DIR))

from knowledge_persistence import DEFAULT_EXPLORED_ROOT  # type: ignore
import optimization_tree  # type: ignore


def _read_jsonl(p: Path) -> List[Dict[str, Any]]:
    if not p.is_file():
        return []
    out = []
    with open(p, "r", encoding="utf-8") as fh:
        for line in fh:
            line = line.strip()
            if not line:
                continue
            try:
                out.append(json.loads(line))
            except json.JSONDecodeError:
                pass
    return out


def _read_diff_summary(explored_root: Path, artifacts_dir: str) -> str:
    if not artifacts_dir:
        return ""
    p = explored_root / artifacts_dir / "diff_summary.md"
    if not p.is_file():
        return ""
    try:
        return p.read_text(encoding="utf-8")
    except OSError:
        return ""


def backfill(explored_root: str | Path = DEFAULT_EXPLORED_ROOT,
             wipe_existing: bool = True) -> Dict[str, Any]:
    """Rebuild all trees + pattern index from experiences.jsonl. Returns
    a summary dict with counts."""
    root = Path(os.path.expanduser(str(explored_root)))
    exp_path = root / "optimization" / "experiences.jsonl"
    rows = _read_jsonl(exp_path)
    if not rows:
        print(f"no rows in {exp_path}; nothing to backfill")
        return {"rows": 0, "kernels": 0, "accepts": 0, "patterns": 0}

    # Optionally clear the trees dir so stale nodes don't linger from
    # previous backfills with weaker pattern detectors.
    trees_dir = root / "optimization" / "trees"
    if wipe_existing and trees_dir.is_dir():
        for f in trees_dir.glob("*.json"):
            f.unlink()
        print(f"wiped {trees_dir}/*.json")

    # Walk accepts in chronological order so parent_cycles resolution
    # finds prior nodes correctly.
    accepts = [r for r in rows if r.get("accepted")]
    accepts.sort(key=lambda r: r.get("ts") or "")

    per_kernel: Dict[str, int] = {}
    pattern_hits: Dict[str, int] = {}
    for r in accepts:
        kernel = r.get("kernel")
        if not kernel:
            continue
        bundle = os.path.basename((r.get("artifacts_dir") or "").rstrip("/"))
        diff = _read_diff_summary(root, r.get("artifacts_dir") or "")
        baseline = r.get("baseline_cycles")
        candidate = r.get("candidate_cycles")
        if baseline is None or candidate is None:
            continue
        tree, pats = optimization_tree.record_accept_in_tree(
            kernel=kernel,
            baseline_cycles=int(baseline),
            candidate_cycles=int(candidate),
            parent_cycles=int(baseline),  # row's baseline_cycles IS the parent
            bundle=bundle,
            angle=r.get("angle") or "?",
            ts=r.get("ts") or "",
            diff_summary_text=diff,
            explored_root=str(root),
        )
        per_kernel[kernel] = per_kernel.get(kernel, 0) + 1
        for pid in pats:
            pattern_hits[pid] = pattern_hits.get(pid, 0) + 1

    return {
        "rows": len(rows),
        "kernels": len(per_kernel),
        "accepts": len(accepts),
        "patterns": len(pattern_hits),
        "per_kernel": per_kernel,
        "pattern_hits": pattern_hits,
    }


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--explored-root", default=DEFAULT_EXPLORED_ROOT)
    ap.add_argument("--keep", action="store_true",
                    help="Don't wipe existing trees/*.json before rebuilding "
                         "(useful for additive runs; default is wipe).")
    args = ap.parse_args()

    summary = backfill(
        explored_root=args.explored_root,
        wipe_existing=not args.keep,
    )
    root = Path(os.path.expanduser(args.explored_root))
    trees_dir = root / "optimization" / "trees"

    print()
    print("=" * 64)
    print(f"  experiences.jsonl rows  {summary['rows']}")
    print(f"  accepted rows           {summary['accepts']}")
    print(f"  kernels with trees      {summary['kernels']}")
    print(f"  distinct patterns hit   {summary['patterns']}")
    print("=" * 64)

    if summary.get("per_kernel"):
        print("\nPer-kernel accepts (now persisted as trees):")
        for k in sorted(summary["per_kernel"]):
            tree = optimization_tree.load_tree(k, explored_root=str(root))
            if tree:
                best = tree.get("current_best", {}).get("cycles")
                root_c = tree.get("baseline_cycles")
                ratio = (root_c / best) if (root_c and best) else None
                print(f"  {k:<28}  {summary['per_kernel'][k]} accepts  "
                      f"baseline={root_c}  best={best}  "
                      f"speedup={ratio:.3f}x" if ratio else
                      f"  {k:<28}  {summary['per_kernel'][k]} accepts")

    if summary.get("pattern_hits"):
        print("\nPattern detector hits (across all kernels):")
        for pid, n in sorted(summary["pattern_hits"].items(),
                              key=lambda kv: -kv[1]):
            kernels = optimization_tree.kernels_for_pattern(pid, root)
            print(f"  {n:>3}× {pid:<46}  kernels={kernels}")

    promo = optimization_tree.promotion_candidates(
        threshold=optimization_tree.PROMOTE_KERNEL_THRESHOLD,
        explored_root=str(root),
    )
    print()
    print("Promotion candidates (≥ "
          f"{optimization_tree.PROMOTE_KERNEL_THRESHOLD} kernels, not yet "
          "in the named-angle catalog):")
    if promo:
        for pid, kernels in promo:
            print(f"  - {pid}  →  kernels: {kernels}")
    else:
        print("  (none — every cross-kernel pattern is already in the catalog)")

    print()
    print(f"Tree files: {trees_dir}/<kernel>.json")
    print(f"Pattern index: {trees_dir}/pattern_index.json")
    return 0


if __name__ == "__main__":
    sys.exit(main())
