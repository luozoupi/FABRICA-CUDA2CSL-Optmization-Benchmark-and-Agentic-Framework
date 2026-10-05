#!/usr/bin/env python3
"""WS4.2 — mine "why faster" rules from naive-CUDA-port vs optimized-reference-CSL.

The reviewer's insight: the CUDA source is the NAIVE intent (the straightforward
algorithm); the human reference CSL is the OPTIMIZED form. The diff between them
is exactly the "what did the expert do to make it fast on the wafer" signal.
This tool runs that contrast across the TRAIN split only and distills
generalizable "faster because X" rules into a catalog-feeding JSONL.

Firewall / leakage discipline (docs/SPLIT_AND_LEAKAGE.md):
  - TRAIN split only. Test kernels' references are never read here.
  - The distilled rules must be GENERALIZABLE and contain NO bench-specific
    identifiers — enforced by knowledge_persistence.tutorial_leak_check before a
    rule is written. (The reference CSL is read to PRODUCE the rule, exactly like
    explore_promote tutorialization; the rule that ships is leak-checked prose.)

Output: knowledge/explored/ingest/why_faster_rules.jsonl (one rule set per
kernel). These can later be promoted into CSL_OPTIMIZATION_STEPS_CATALOG by hand
or fed to for_implementer like the explored tutorials.

Usage:
    python why_faster_miner.py --train GEMM GEMV Power-Method [...]
    python why_faster_miner.py --train-all          # all split=train kernels
    python why_faster_miner.py --dry-run --train GEMM   # no LLM; show the prompt
"""

from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path
from typing import List, Optional

THIS_DIR = Path(__file__).resolve().parent
if str(THIS_DIR) not in sys.path:
    sys.path.insert(0, str(THIS_DIR))

REPO_ROOT = THIS_DIR.parent
OUT_JSONL = REPO_ROOT / "knowledge" / "explored" / "ingest" / "why_faster_rules.jsonl"


_PROMPT = """You are distilling GENERALIZABLE wafer-scale optimization rules by
contrasting a NAIVE GPU algorithm against an EXPERT-OPTIMIZED CSL kernel for the
Cerebras WSE.

## Naive intent (CUDA — the straightforward algorithm)
```cuda
{cuda}
```

## Expert-optimized form (CSL reference — how the expert made it fast on the wafer)
```csl
{csl}
```

## Your task
List 3-6 "faster because X" rules: each is a TRANSFERABLE technique the expert
applied that a naive translator would miss. Focus on wafer-scale levers:
decomposition/tiling choices, fabric communication (collectives, halo, async
DSDs), DSD/SIMD bulk ops replacing scalar loops, comptime hoisting, task/queue
structure, memory layout.

HARD CONSTRAINTS (this ships into the knowledge base):
- NO bench-specific identifiers: no verbatim function names, struct field names,
  numeric tile sizes, color/queue ids, or kernel-specific symbol names.
- Each rule must generalize to OTHER kernels of this class, not just this one.
- Phrase as an imperative pattern + the WHY, e.g.:
  "Replace per-row scalar accumulation with a strided mem1d_dsd + @fmacs — the
   DSD streams the whole row in one issue, removing per-element loop overhead."

Output STRICT JSON: {{"group": "<gemm|gemv|stencil|linalg|...>", "rules":
[{{"pattern": "<short name>", "rule": "<imperative + why, generalizable>"}}]}}.
No prose outside the JSON.
"""


def _read(p: Path) -> str:
    try:
        return p.read_text(encoding="utf-8", errors="ignore")
    except OSError:
        return ""


def _train_kernels() -> List[str]:
    """All registry kernels whose spec.yaml has split: train."""
    import cuda2csl as c  # type: ignore
    import yaml  # type: ignore
    out = []
    for name, entry in c.KERNEL_REGISTRY.items():
        spec_path = Path(entry["reference_csl_dir"]).parent / "spec.yaml"
        if not spec_path.is_file():
            continue
        try:
            spec = yaml.safe_load(spec_path.read_text(encoding="utf-8"))
        except Exception:
            continue
        if isinstance(spec, dict) and spec.get("split") == "train":
            out.append(name)
    return out


def mine_one(kernel: str, llm_caller, dry_run: bool = False) -> Optional[dict]:
    import cuda2csl as c  # type: ignore
    from knowledge_persistence import tutorial_leak_check  # type: ignore
    entry = c.KERNEL_REGISTRY.get(kernel)
    if not entry:
        print(f"[skip] {kernel}: not in registry")
        return None
    cuda = _read(Path(entry["cuda_path"]))
    csl = _read(Path(entry["reference_csl_dir"]) / entry["target_relpath"])
    if not cuda or not csl:
        print(f"[skip] {kernel}: missing CUDA or reference CSL")
        return None
    prompt = _PROMPT.format(cuda=cuda[:6000], csl=csl[:8000])
    if dry_run:
        print(f"--- {kernel}: prompt ({len(prompt)} chars) ---\n{prompt[:800]}...")
        return None
    if llm_caller is None:
        print(f"[skip] {kernel}: no LLM provider")
        return None
    reply = llm_caller(prompt) or ""
    # extract JSON
    import re
    m = re.search(r"\{.*\}", reply, re.DOTALL)
    if not m:
        print(f"[warn] {kernel}: no JSON in reply")
        return None
    try:
        data = json.loads(m.group(0))
    except json.JSONDecodeError:
        print(f"[warn] {kernel}: bad JSON")
        return None
    # leak-check each rule against the reference bundle text
    bundle = cuda + "\n" + csl
    kept = []
    for r in data.get("rules", []):
        text = f"{r.get('pattern','')} {r.get('rule','')}"
        if tutorial_leak_check(text, bundle, threshold=3) is None:
            kept.append(r)
        else:
            print(f"[leak] {kernel}: dropped rule '{r.get('pattern','')}' (bench tokens)")
    if not kept:
        return None
    return {"kernel_train_source": kernel, "group": data.get("group", ""),
            "rules": kept, "split": "train"}


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--train", nargs="*", default=None, help="train kernels to mine")
    ap.add_argument("--train-all", action="store_true")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    kernels = args.train or []
    if args.train_all:
        kernels = _train_kernels()
    if not kernels:
        print("specify --train K [K ...] or --train-all")
        return 2

    llm_caller = None
    if not args.dry_run:
        try:
            from workflow_common import resolve_provider, llm_complete  # type: ignore
            h = resolve_provider(provider="auto")
            llm_caller = lambda p: llm_complete(h.client, h.model,
                                                [{"role": "user", "content": p}], 2048)
        except Exception as exc:
            print(f"[main] provider unavailable: {str(exc)[:160]}")

    rows = []
    for k in kernels:
        row = mine_one(k, llm_caller, dry_run=args.dry_run)
        if row:
            rows.append(row)
            print(f"[ok] {k}: {len(row['rules'])} rules")
    if rows and not args.dry_run:
        OUT_JSONL.parent.mkdir(parents=True, exist_ok=True)
        with open(OUT_JSONL, "a", encoding="utf-8") as fh:
            for r in rows:
                fh.write(json.dumps(r) + "\n")
        print(f"[main] wrote {len(rows)} rule sets -> {OUT_JSONL}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
