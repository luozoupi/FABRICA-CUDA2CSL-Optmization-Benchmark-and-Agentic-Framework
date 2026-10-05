#!/usr/bin/env python3
"""Cross-reference an agentic sweep with a one-shot sweep and emit a comparison report.

Usage:
  aggregate_compare.py <agentic-sweep-root> <oneshot-sweep-root>

Writes <oneshot-sweep-root>/agentic_vs_oneshot.md and .csv.
"""
from __future__ import annotations

import argparse
import csv
import glob
import json
import os
import sys
from pathlib import Path
from typing import Dict, List, Optional, Set


SKIP_DIRS = {"preflight", "preflight_v2", "_reports", "smoke"}


def latest_batch_dir(model_dir: Path) -> Optional[Path]:
    cands = sorted(
        [p for p in model_dir.iterdir() if p.is_dir() and p.name.startswith("batch_")],
        reverse=True,
    )
    return cands[0] if cands else None


def load_results(batch_dir: Path) -> List[Dict]:
    rj = batch_dir / "results.json"
    if rj.exists():
        try:
            payload = json.loads(rj.read_text())
            if isinstance(payload, dict) and isinstance(payload.get("results"), list):
                return payload["results"]
            if isinstance(payload, list):
                return payload
        except json.JSONDecodeError:
            pass
    return []


def model_label(slug: str) -> str:
    """Turn slug back into a readable model name. Slugs replace '/' and '.' with '_'."""
    # The slug rule was tr '/.' '__', so any '_' could be from either; restore '/' first.
    if slug.startswith("argo__"):
        return f"{slug[len('argo__'):].replace('__','/')} (Argo)"
    return slug.replace("__", "/")


def collect(sweep_root: Path) -> Dict[str, List[Dict]]:
    models: Dict[str, List[Dict]] = {}
    for d in sorted(sweep_root.iterdir()):
        if not d.is_dir() or d.name in SKIP_DIRS or d.name.endswith(".bak") or d.name.endswith("_bak"):
            continue
        if any(d.name.endswith(suf) for suf in (".ctx_overflow_bak", ".503_bak")):
            continue
        batch = latest_batch_dir(d)
        if not batch:
            continue
        results = load_results(batch)
        if not results:
            continue
        models[d.name] = results
    return models


def fmt_cell(rec: Optional[Dict]) -> str:
    if not rec:
        return "—"
    st = rec.get("status", "?")
    if st == "pass":
        rt = rec.get("run_time_ms")
        return f"**pass** {int(rt) if rt is not None else '?'} ms"
    if st == "fail":
        return "fail"
    if st == "error":
        return "err"
    if st == "timeout":
        return "timeout"
    return st


def status_only(rec: Optional[Dict]) -> str:
    if not rec:
        return "missing"
    return rec.get("status", "?")


def run_ms(rec: Optional[Dict]) -> Optional[float]:
    if not rec:
        return None
    return rec.get("run_time_ms")


def transition_arrow(one: Optional[Dict], agent: Optional[Dict]) -> str:
    """Categorise how a model's outcome changed from one-shot to agentic."""
    s1 = status_only(one)
    s2 = status_only(agent)
    if s1 == "pass" and s2 == "pass":
        return "✓→✓ both"
    if s1 == "pass" and s2 != "pass":
        return f"✓→{s2[0]} regression"  # rare: one-shot won, agentic lost
    if s1 != "pass" and s2 == "pass":
        return f"{s1[0]}→✓ repair-helped"
    if s1 == "missing" or s2 == "missing":
        return f"({s1}/{s2})"
    return f"{s1[0]}→{s2[0]} both-failed"


TIER_ORDER = [
    "GEMM", "GEMV", "GEMM-Collectives-2D",
    "GEMV-Checkerboard", "GEMV-Collectives-2D",
    "Wide-Multiplication", "Single-Tile-Matvec", "Game-of-Life",
    "Cholesky", "Residual", "7pt-Stencil",
    "BiCGSTAB", "CG", "Power-Method", "Preconditioned-CG",
    "Mandelbrot", "FFT-1D-2D",
]


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("agentic_root", type=Path)
    ap.add_argument("oneshot_root", type=Path)
    args = ap.parse_args()

    ag = collect(args.agentic_root.expanduser().resolve())
    os_ = collect(args.oneshot_root.expanduser().resolve())

    common_slugs = sorted(set(ag) & set(os_))
    only_ag = sorted(set(ag) - set(os_))
    only_os = sorted(set(os_) - set(ag))

    # Per-model index for fast lookup
    def index(rows: List[Dict]) -> Dict[str, Dict]:
        return {r.get("kernel"): r for r in rows}
    ag_ix = {m: index(ag[m]) for m in ag}
    os_ix = {m: index(os_[m]) for m in os_}

    seen_kernels: Set[str] = set()
    for m in list(ag) + list(os_):
        seen_kernels.update((ag_ix.get(m, {}) or {}).keys())
        seen_kernels.update((os_ix.get(m, {}) or {}).keys())
    kernels = [k for k in TIER_ORDER if k in seen_kernels] + sorted(seen_kernels - set(TIER_ORDER))

    # ----- write markdown -----
    out_md = args.oneshot_root / "agentic_vs_oneshot.md"
    out_csv = args.oneshot_root / "agentic_vs_oneshot.csv"

    lines: List[str] = []
    lines.append("# Agentic vs one-shot translation — comparison")
    lines.append("")
    lines.append(f"- **Agentic sweep:** `{args.agentic_root}` (`--turns 4`, full repair loop, `analyse_cuda` enabled)")
    lines.append(f"- **One-shot sweep:** `{args.oneshot_root}` (`--turns 1 --skip-analyse`, single LLM call)")
    lines.append("")

    # Headline per-model counts
    lines.append("## Pass-rate summary")
    lines.append("")
    lines.append("| Model | One-shot pass | Agentic pass | Δ | One-shot wall | Agentic wall |")
    lines.append("| --- | ---: | ---: | ---: | ---: | ---: |")
    for slug in sorted(set(list(ag)) | set(list(os_))):
        ag_rows = ag.get(slug, [])
        os_rows = os_.get(slug, [])
        ag_pass = sum(1 for r in ag_rows if r.get("status") == "pass")
        os_pass = sum(1 for r in os_rows if r.get("status") == "pass")
        ag_total = len(ag_rows) or 17
        os_total = len(os_rows) or 17
        ag_wall = sum((r.get("wall_s") or 0) for r in ag_rows)
        os_wall = sum((r.get("wall_s") or 0) for r in os_rows)
        delta = ag_pass - os_pass
        delta_str = f"+{delta}" if delta > 0 else ("0" if delta == 0 else str(delta))
        os_str = f"{os_pass}/{os_total}" if os_rows else "—"
        ag_str = f"{ag_pass}/{ag_total}" if ag_rows else "—"
        os_wall_str = f"{os_wall/60:.1f} min" if os_rows else "—"
        ag_wall_str = f"{ag_wall/60:.1f} min" if ag_rows else "—"
        lines.append(f"| `{model_label(slug)}` | {os_str} | {ag_str} | {delta_str} | {os_wall_str} | {ag_wall_str} |")
    lines.append("")
    lines.append("- **Δ > 0** = the agentic 4-turn loop recovered kernels the one-shot missed.")
    lines.append("- **Δ < 0** = regressions (one-shot won; agentic's loop wandered into a worse state).")
    lines.append("- **Δ = 0 with different kernels passing** is possible — see the per-kernel matrix.")
    lines.append("")

    # Per-kernel side-by-side for the common models
    lines.append("## Per-kernel: one-shot → agentic transition")
    lines.append("")
    lines.append("Cell shows `one-shot status → agentic status`. **✓** = pass, **F** = fail (wrong output), **e** = error (crash/overflow), **t** = timeout, **—** = missing.")
    lines.append("")
    headers = ["Kernel"] + [model_label(s) for s in common_slugs]
    lines.append("| " + " | ".join(headers) + " |")
    lines.append("| " + " | ".join(["---"] * len(headers)) + " |")
    def shorten(s: str) -> str:
        return {"pass": "✓", "fail": "F", "error": "e", "timeout": "t", "missing": "—"}.get(s, s[:1])
    for k in kernels:
        row = [k]
        for slug in common_slugs:
            o = os_ix.get(slug, {}).get(k)
            a = ag_ix.get(slug, {}).get(k)
            row.append(f"{shorten(status_only(o))} → {shorten(status_only(a))}")
        lines.append("| " + " | ".join(row) + " |")
    lines.append("")

    # Movement breakdown per common model
    lines.append("## Transition breakdown per model")
    lines.append("")
    lines.append("| Model | ✓→✓ both pass | repair-helped (one→agentic) | regression (one>agentic) | both failed |")
    lines.append("| --- | ---: | ---: | ---: | ---: |")
    for slug in common_slugs:
        both = helped = regr = both_fail = 0
        helped_k, regr_k = [], []
        for k in kernels:
            o = os_ix.get(slug, {}).get(k)
            a = ag_ix.get(slug, {}).get(k)
            so, sa = status_only(o), status_only(a)
            if so == "pass" and sa == "pass":
                both += 1
            elif sa == "pass" and so != "pass":
                helped += 1; helped_k.append(k)
            elif so == "pass" and sa != "pass":
                regr += 1; regr_k.append(k)
            else:
                both_fail += 1
        lines.append(f"| `{model_label(slug)}` | {both} | {helped} ({', '.join(helped_k) or '—'}) | {regr} ({', '.join(regr_k) or '—'}) | {both_fail} |")
    lines.append("")

    # On-device timing: when both modes pass, did the agentic loop produce faster code?
    lines.append("## On-device runtime: one-shot vs agentic (kernels where BOTH passed)")
    lines.append("")
    lines.append("Shows whether the agentic 4-turn refinement loop produced faster CSL than the one-shot attempt.")
    lines.append("")
    for slug in common_slugs:
        rows: List[str] = []
        for k in kernels:
            o = os_ix.get(slug, {}).get(k)
            a = ag_ix.get(slug, {}).get(k)
            if status_only(o) == "pass" and status_only(a) == "pass":
                rt_o = run_ms(o)
                rt_a = run_ms(a)
                if rt_o is not None and rt_a is not None:
                    delta_ms = rt_a - rt_o
                    delta_pct = (delta_ms / rt_o * 100) if rt_o else 0
                    arrow = "↓" if delta_ms < 0 else ("↑" if delta_ms > 0 else "=")
                    rows.append(f"| {k} | {int(rt_o)} | {int(rt_a)} | {delta_ms:+.0f} | {arrow} {delta_pct:+.1f}% |")
        if rows:
            lines.append(f"### `{model_label(slug)}`")
            lines.append("")
            lines.append("| Kernel | one-shot ms | agentic ms | Δ ms | Δ % (negative = agentic faster) |")
            lines.append("| --- | ---: | ---: | ---: | ---: |")
            lines.extend(rows)
            lines.append("")

    # Missing-model notes
    if only_ag or only_os:
        lines.append("## Coverage notes")
        lines.append("")
        if only_ag:
            lines.append("- Models present only in the agentic sweep: " + ", ".join(f"`{model_label(s)}`" for s in only_ag))
        if only_os:
            lines.append("- Models present only in the one-shot sweep: " + ", ".join(f"`{model_label(s)}`" for s in only_os))
        lines.append("")

    out_md.write_text("\n".join(lines))

    # ----- write CSV (flat, machine-readable) -----
    cols = ["kernel"]
    for slug in common_slugs:
        cols += [f"{slug}__oneshot_status", f"{slug}__oneshot_ms",
                 f"{slug}__agentic_status", f"{slug}__agentic_ms"]
    with out_csv.open("w", newline="") as fh:
        w = csv.writer(fh)
        w.writerow(cols)
        for k in kernels:
            row = [k]
            for slug in common_slugs:
                o = os_ix.get(slug, {}).get(k)
                a = ag_ix.get(slug, {}).get(k)
                row += [status_only(o), run_ms(o) or "", status_only(a), run_ms(a) or ""]
            w.writerow(row)

    print(f"wrote {out_md}")
    print(f"wrote {out_csv}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
