#!/usr/bin/env python3
"""Aggregate a multi-model batch_cuda2csl.py sweep into a comparison report.

Layout expected:
  <sweep_root>/
    <model_slug>/batch_<utc-stamp>/results.json   (written by batch_cuda2csl.py)
    <model_slug>/batch_<utc-stamp>/<kernel>/...   (per-kernel artifacts)

Writes <sweep_root>/comparison.csv and <sweep_root>/comparison_report.md.
"""
from __future__ import annotations

import argparse
import csv
import json
import os
import sys
from pathlib import Path
from typing import Dict, List, Optional


def latest_batch_dir(model_dir: Path) -> Optional[Path]:
    candidates = sorted(
        [p for p in model_dir.iterdir() if p.is_dir() and p.name.startswith("batch_")],
        reverse=True,
    )
    return candidates[0] if candidates else None


def load_results(batch_dir: Path) -> List[Dict]:
    rj = batch_dir / "results.json"
    if rj.exists():
        try:
            payload = json.loads(rj.read_text())
            # batch_cuda2csl writes {"model": ..., "results": [...]}; older
            # runs may have written the bare list. Handle both.
            if isinstance(payload, dict) and isinstance(payload.get("results"), list):
                return payload["results"]
            if isinstance(payload, list):
                return payload
        except json.JSONDecodeError:
            pass
    # Fallback: reconstruct from per-kernel benchmark.json
    out: List[Dict] = []
    for kdir in sorted(batch_dir.iterdir()):
        if not kdir.is_dir():
            continue
        b = kdir / "benchmark.json"
        if not b.exists():
            continue
        try:
            data = json.loads(b.read_text())
        except json.JSONDecodeError:
            continue
        out.append({
            "kernel":      kdir.name,
            "status":      data.get("status", "unknown"),
            "run_time_ms": data.get("run_time_ms"),
            "output_dir":  str(kdir),
            "wall_s":      None,
        })
    return out


def collect(sweep_root: Path) -> Dict[str, List[Dict]]:
    models: Dict[str, List[Dict]] = {}
    for d in sorted(sweep_root.iterdir()):
        if not d.is_dir() or d.name in {"preflight", "_reports"}:
            continue
        batch = latest_batch_dir(d)
        if not batch:
            continue
        models[d.name] = load_results(batch)
    return models


def write_csv(out_path: Path, kernels: List[str], models: Dict[str, List[Dict]]) -> None:
    cols = ["kernel"] + [f"{m}__status" for m in models] + [f"{m}__run_ms" for m in models] + [f"{m}__wall_s" for m in models]
    with out_path.open("w", newline="") as fh:
        w = csv.writer(fh)
        w.writerow(cols)
        for k in kernels:
            row = [k]
            for m in models:
                rec = next((r for r in models[m] if r.get("kernel") == k), None)
                row.append(rec.get("status") if rec else "missing")
            for m in models:
                rec = next((r for r in models[m] if r.get("kernel") == k), None)
                row.append(rec.get("run_time_ms") if rec else "")
            for m in models:
                rec = next((r for r in models[m] if r.get("kernel") == k), None)
                row.append(rec.get("wall_s") if rec else "")
            w.writerow(row)


def fmt_cell(rec: Optional[Dict]) -> str:
    if not rec:
        return "—"
    st = rec.get("status", "?")
    rt = rec.get("run_time_ms")
    ws = rec.get("wall_s")
    parts = [st]
    if st == "pass" and rt is not None:
        parts.append(f"{rt} ms")
    if ws is not None:
        parts.append(f"{ws}s wall")
    return " · ".join(parts)


def model_short(slug: str) -> str:
    # slug uses '_' for '/' and '.'. Re-derive a readable label.
    return slug.replace("__", "/")


def write_markdown(out_path: Path, kernels: List[str], models: Dict[str, List[Dict]]) -> None:
    headers = ["Kernel"] + [model_short(m) for m in models]
    lines: List[str] = []
    lines.append(f"# ALCF inference-endpoint sweep — comparison report")
    lines.append("")
    lines.append(f"Source: `{out_path.parent}`")
    lines.append("")
    lines.append("## Summary")
    lines.append("")
    lines.append("| Model | Passed | Failed | Errored | Timeout | Total |")
    lines.append("| --- | ---: | ---: | ---: | ---: | ---: |")
    for m, results in models.items():
        passed  = sum(1 for r in results if r.get("status") == "pass")
        failed  = sum(1 for r in results if r.get("status") == "fail")
        errored = sum(1 for r in results if r.get("status") == "error")
        timeout = sum(1 for r in results if r.get("status") == "timeout")
        total   = len(results)
        lines.append(f"| `{model_short(m)}` | {passed} | {failed} | {errored} | {timeout} | {total} |")
    lines.append("")
    lines.append("## Per-kernel results")
    lines.append("")
    lines.append("| " + " | ".join(headers) + " |")
    lines.append("| " + " | ".join(["---"] * len(headers)) + " |")
    for k in kernels:
        row = [k]
        for m in models:
            rec = next((r for r in models[m] if r.get("kernel") == k), None)
            row.append(fmt_cell(rec))
        lines.append("| " + " | ".join(row) + " |")
    lines.append("")
    lines.append("## Notes")
    lines.append("- `pass` = generated CSL compiled with `cslc` AND ran on the WSE returning the expected result.")
    lines.append("- `run ms` = on-device execution time reported by `benchmark.json`. Lower is faster, but a model can only be compared on a kernel both passed.")
    lines.append("- `wall s` = end-to-end batch driver wall clock for that kernel (LLM turns + compile + run).")
    out_path.write_text("\n".join(lines))


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("sweep_root", type=Path)
    args = ap.parse_args()

    root: Path = args.sweep_root.expanduser().resolve()
    if not root.is_dir():
        print(f"not a directory: {root}", file=sys.stderr)
        return 2

    models = collect(root)
    if not models:
        print(f"no per-model batch dirs under {root}", file=sys.stderr)
        return 1

    # Union of kernels in the deterministic batch_cuda2csl tier order, then anything extra.
    tier_order = [
        "GEMM", "GEMV", "GEMM-Collectives-2D",
        "GEMV-Checkerboard", "GEMV-Collectives-2D",
        "Wide-Multiplication", "Single-Tile-Matvec", "Game-of-Life",
        "Cholesky", "Residual", "7pt-Stencil",
        "BiCGSTAB", "CG", "Power-Method", "Preconditioned-CG",
        "Mandelbrot", "FFT-1D-2D",
    ]
    seen = {r.get("kernel") for lst in models.values() for r in lst}
    kernels = [k for k in tier_order if k in seen] + sorted(seen - set(tier_order))

    write_csv(root / "comparison.csv", kernels, models)
    write_markdown(root / "comparison_report.md", kernels, models)
    print(f"wrote {root/'comparison.csv'}")
    print(f"wrote {root/'comparison_report.md'}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
