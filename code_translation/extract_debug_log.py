#!/usr/bin/env python3
"""Extract a human-readable per-attempt debug log from a cuda2csl run.

The reviewer agent records its verdict on each failed attempt as
`attempts[i].reviewer_verdict` inside `final_result.json`. This script walks
one or more such files (single kernel dir, batch dir, or sweep root) and
produces:
  - a JSONL stream of `{kernel, attempt, status, bucket, rationale, ...}`
    suitable for ingestion into a downstream dashboard / fine-tuning corpus
  - a markdown "tape" formatted for human reading

The reviewer's value is in WHY each attempt failed. The repair loop's pass-rate
is one number; this script surfaces the substantive notes underneath.

Usage:
    extract_debug_log.py <path>             # auto-detect dir type
    extract_debug_log.py <path> --jsonl     # emit only JSONL on stdout
    extract_debug_log.py <path> --markdown  # emit only markdown on stdout
    extract_debug_log.py <path> --out FILE  # write to FILE instead of stdout

Default output: markdown to stdout.

Schema of each JSONL record:
    {
        "kernel":         str,   # kernel name
        "model":          str,   # model name (best-effort from batch results.json)
        "run_dir":        str,   # source dir
        "attempt":        int,   # 1-indexed
        "status":         str,   # pass | fail | error | blocked
        "failure_reason": str | None,
        "compile_time_ms": int | None,
        "run_time_ms":    int | None,
        "verdict": {
            "bucket":         str,    # A | B | C | None on pass
            "rationale":      str,
            "missing_symbol": str | None,
            "design_amendment": str | None
        } | None
    }
"""
from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path
from typing import Iterator, List, Dict, Any, Optional


# ---------------------------------------------------------------------------
# Discovery: walk a path and yield (kernel_run_dir, kernel_name) tuples
# ---------------------------------------------------------------------------

def discover_kernel_runs(root: Path) -> Iterator[Path]:
    """Yield each kernel run dir (containing final_result.json) under root.

    Accepts:
      - a single kernel run dir         (results/cuda2csl/run_*/Kernel/)
      - a batch dir                     (results/cuda2csl/run_*/)
      - a sweep dir                     (results/<sweep_root>/<model_slug>/batch_*/)
      - a sweep root                    (results/<sweep_root>/)
    """
    root = root.resolve()
    if (root / "final_result.json").exists():
        yield root
        return
    # Walk one level deeper.
    for child in sorted(root.iterdir()):
        if not child.is_dir():
            continue
        if (child / "final_result.json").exists():
            yield child
            continue
        # batch dir contains kernel-named subdirs OR a results.json + per-kernel
        # results pointed to via output_dir. Prefer following output_dir when present.
        rjson = child / "results.json"
        if rjson.exists():
            try:
                payload = json.loads(rjson.read_text())
                rows = payload.get("results", payload) if isinstance(payload, dict) else payload
                for r in rows or []:
                    od = r.get("output_dir")
                    if od and Path(od).is_dir() and (Path(od) / "final_result.json").exists():
                        yield Path(od)
                continue
            except (json.JSONDecodeError, KeyError, TypeError):
                pass
        # Recurse one more level.
        for grand in sorted(child.iterdir()):
            if grand.is_dir() and (grand / "final_result.json").exists():
                yield grand


# ---------------------------------------------------------------------------
# Extraction
# ---------------------------------------------------------------------------

def kernel_name_from(run_dir: Path) -> str:
    """The kernel name is the leaf directory name in cuda2csl's layout."""
    return run_dir.name


def model_from_batch(run_dir: Path) -> Optional[str]:
    """Best-effort: walk up to find results.json (the batch driver writes one
    with {"model": ..., "results": [...]} so we can attribute records."""
    cur = run_dir.parent
    for _ in range(4):
        rj = cur / "results.json"
        if rj.exists():
            try:
                payload = json.loads(rj.read_text())
                if isinstance(payload, dict) and "model" in payload:
                    return payload["model"]
            except (json.JSONDecodeError, KeyError):
                pass
        if cur == cur.parent:
            break
        cur = cur.parent
    return None


def extract_records(run_dir: Path) -> List[Dict[str, Any]]:
    fr = run_dir / "final_result.json"
    if not fr.exists():
        return []
    try:
        d = json.loads(fr.read_text())
    except json.JSONDecodeError:
        return []
    attempts = d.get("attempts") or []
    kernel = kernel_name_from(run_dir)
    model = model_from_batch(run_dir) or "<unknown>"
    records: List[Dict[str, Any]] = []
    for i, a in enumerate(attempts, start=1):
        v = a.get("reviewer_verdict") or None
        if v is not None:
            v_out = {
                "bucket":          v.get("bucket"),
                "rationale":       v.get("rationale"),
                "missing_symbol":  v.get("missing_symbol"),
                "design_amendment": v.get("design_amendment"),
            }
        else:
            v_out = None
        records.append({
            "kernel":         kernel,
            "model":          model,
            "run_dir":        str(run_dir),
            "attempt":        i,
            "status":         a.get("status"),
            "failure_reason": a.get("failure_reason"),
            "compile_time_ms": a.get("compile_time_ms"),
            "run_time_ms":    a.get("run_time_ms"),
            "verdict":        v_out,
        })
    return records


# ---------------------------------------------------------------------------
# Rendering
# ---------------------------------------------------------------------------

def render_jsonl(records: List[Dict[str, Any]]) -> str:
    return "\n".join(json.dumps(r, ensure_ascii=False) for r in records) + ("\n" if records else "")


def render_markdown(records: List[Dict[str, Any]]) -> str:
    if not records:
        return "_(no attempts found)_\n"
    by_kernel: Dict[str, List[Dict[str, Any]]] = {}
    for r in records:
        by_kernel.setdefault(r["kernel"], []).append(r)
    out: List[str] = ["# Reviewer debug log\n"]
    for kernel, rows in by_kernel.items():
        last = rows[-1]
        final_status = last["status"]
        passes = sum(1 for r in rows if r["status"] == "pass")
        out.append(f"## {kernel}  ({rows[0]['model']})")
        out.append(f"final status: **{final_status}** · attempts: {len(rows)} · passes: {passes}")
        out.append(f"source: `{rows[0]['run_dir']}`")
        out.append("")
        out.append("| # | status | bucket | rationale |")
        out.append("| --- | --- | --- | --- |")
        for r in rows:
            v = r.get("verdict") or {}
            bucket = v.get("bucket") or "—"
            rationale = (v.get("rationale") or "").replace("|", "\\|").replace("\n", " ")[:200]
            if r["status"] == "pass":
                rationale = "_(pass — no reviewer)_"
            out.append(f"| {r['attempt']} | {r['status']} | {bucket} | {rationale} |")
        # Spotlight A-bucket design amendments + C-bucket missing symbols
        spotlights = []
        for r in rows:
            v = r.get("verdict") or {}
            if v.get("design_amendment"):
                spotlights.append(f"**attempt {r['attempt']} (A amendment):** {v['design_amendment']}")
            if v.get("missing_symbol"):
                spotlights.append(f"**attempt {r['attempt']} (C missing symbol):** `{v['missing_symbol']}`")
        if spotlights:
            out.append("")
            out.append("**Spotlights:**")
            for s in spotlights:
                out.append(f"- {s}")
        out.append("")
    return "\n".join(out)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.strip().splitlines()[0])
    ap.add_argument("path", type=Path, help="Run dir, batch dir, or sweep root")
    fmt = ap.add_mutually_exclusive_group()
    fmt.add_argument("--jsonl", action="store_true", help="Emit only JSONL")
    fmt.add_argument("--markdown", action="store_true", help="Emit only markdown (default)")
    ap.add_argument("--out", type=Path, default=None, help="Write to file instead of stdout")
    args = ap.parse_args()

    if not args.path.exists():
        print(f"path does not exist: {args.path}", file=sys.stderr)
        return 2

    records: List[Dict[str, Any]] = []
    for run_dir in discover_kernel_runs(args.path):
        records.extend(extract_records(run_dir))

    if args.jsonl:
        text = render_jsonl(records)
    else:
        text = render_markdown(records)

    if args.out:
        args.out.write_text(text)
        print(f"wrote {args.out}  ({len(records)} records)", file=sys.stderr)
    else:
        sys.stdout.write(text)
    return 0


if __name__ == "__main__":
    sys.exit(main())
