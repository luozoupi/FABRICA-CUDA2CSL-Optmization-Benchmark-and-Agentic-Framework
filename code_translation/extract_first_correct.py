#!/usr/bin/env python3
"""Extract the first genuinely passing translation ("first correct", FC) per kernel
from saved sweep runs, so optimizer arms can start from an identical frozen program.

A run's final_result.json lists every benchmarked attempt in order. The FC attempt
is the first with status == "pass", success_marker == True and a cycles_send
reading (a compile-only dry check also records status "pass" but carries neither).
Optimization attempts only start after such a pass, so the first match is always a
translation-phase candidate. The code is copied from the attempt's
`translated_path` (the sandbox file usually still exists); otherwise it is
recovered from translation_log.json as the assistant ```csl fence whose line
count equals the attempt's `code_lines`.

Sweep layouts. Flat sweeps are <sweep>/<kernel>/run_*/<kernel>/. Multi-seed
sweeps nest one level, <sweep>/<kernel>/seed_<n>/run_*/<kernel>/; there the seed
is chosen by a BLIND rule -- the lowest-sorted intermediate directory that
yields an extraction -- so the choice cannot depend on the cycle counts and
cannot favour an optimizer arm. Every candidate seed's first-correct cycles are
recorded in meta.json under `sibling_fc_cycles` for transparency.

Output layout:  <out>/<kernel>/<target_relpath>  and  <out>/<kernel>/meta.json

Usage:
  python extract_first_correct.py --sweep code_translation/results/full_template_sweep_20260722_192305 \
      --out code_translation/results/first_correct/template_20260722 [--kernels A,B] [--overwrite]
"""
from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import sys
from pathlib import Path
from typing import Any, Dict, List, Tuple, Optional

FENCE_RE = re.compile(r"```csl[^\n]*\n(.*?)```", re.DOTALL)


def _load(path: Path) -> Any:
    with open(path, "r", encoding="utf-8") as fh:
        return json.load(fh)


def first_correct_attempt(attempts: List[Dict[str, Any]]) -> Optional[int]:
    for idx, att in enumerate(attempts):
        if (att.get("status") == "pass" and bool(att.get("success_marker"))
                and att.get("cycles_send") is not None):
            return idx
    return None


def code_from_log(log_path: Path, code_lines: Optional[int]) -> Optional[str]:
    if not log_path.exists():
        return None
    data = _load(log_path)
    messages = data.get("messages", data) if isinstance(data, dict) else data
    candidates: List[str] = []
    for msg in messages:
        if not isinstance(msg, dict) or msg.get("role") != "assistant":
            continue
        content = msg.get("content")
        if isinstance(content, list):  # anthropic-style blocks
            content = "\n".join(str(b.get("text", "")) for b in content if isinstance(b, dict))
        for m in FENCE_RE.finditer(str(content or "")):
            candidates.append(m.group(1))
    if not candidates:
        return None
    if code_lines:
        for c in candidates:
            if len(c.splitlines()) == code_lines:
                return c
    return None


def extract_run(run_dir: Path, kernel: str, out_dir: Path, overwrite: bool) -> Dict[str, Any]:
    kdir = run_dir / kernel
    final_result = kdir / "final_result.json"
    meta_path = kdir / "bundle_metadata.json"
    rec: Dict[str, Any] = {"kernel": kernel, "run_dir": str(run_dir), "status": "missing_final_result"}
    if not final_result.exists():
        return rec
    attempts = _load(final_result).get("attempts", [])
    bundle_meta = _load(meta_path) if meta_path.exists() else {}
    idx = first_correct_attempt(attempts)
    rec.update({
        "n_attempts": len(attempts),
        "model": bundle_meta.get("model"),
        "target_relpath": bundle_meta.get("target_relpath") or (attempts[0].get("target_relpath") if attempts else None),
        "reference_dir": bundle_meta.get("reference_dir") or (attempts[0].get("reference_dir") if attempts else None),
    })
    if idx is None:
        rec["status"] = "no_passing_attempt"
        return rec
    att = attempts[idx]
    rec.update({
        "fc_attempt_index": idx + 1,
        "fc_cycles_send": att.get("cycles_send"),
        "fc_cycles_send_runs": att.get("cycles_send_runs"),
        "fc_code_lines": att.get("code_lines"),
        "fc_heldout_eval": att.get("heldout_eval"),
        "translated_path": att.get("translated_path"),
    })
    target_relpath = rec["target_relpath"] or "pe.csl"
    dest = out_dir / kernel / target_relpath
    if dest.exists() and not overwrite:
        rec["status"] = "exists"
        rec["dest"] = str(dest)
        return rec
    code: Optional[str] = None
    src = att.get("translated_path")
    if src and os.path.isfile(src):
        code = Path(src).read_text(encoding="utf-8")
        rec["source"] = "sandbox"
    else:
        code = code_from_log(kdir / "translation_log.json", att.get("code_lines"))
        rec["source"] = "translation_log" if code is not None else "missing"
    if code is None:
        rec["status"] = "code_unrecoverable"
        return rec
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_text(code, encoding="utf-8")
    rec["dest"] = str(dest)
    rec["status"] = "extracted"
    (out_dir / kernel / "meta.json").write_text(json.dumps(rec, indent=2), encoding="utf-8")
    return rec


def _run_groups(kdir: Path) -> List[Tuple[str, List[Path]]]:
    """[(label, run dirs)] for a kernel directory, flat layout first, then the
    one-level-nested (seed_<n>/arm) layout, both in sorted -- hence blind -- order."""
    flat = sorted(p for p in kdir.glob("run_*") if p.is_dir())
    if flat:
        return [("", flat)]
    groups: List[Tuple[str, List[Path]]] = []
    for sub in sorted(p for p in kdir.iterdir() if p.is_dir()):
        runs = sorted(p for p in sub.glob("run_*") if p.is_dir())
        if runs:
            groups.append((sub.name, runs))
    return groups


def _sibling_cycles(run_groups: List[Tuple[str, List[Path]]], kernel: str) -> Dict[str, Any]:
    """Final cycles_send of every candidate group, for the record (not used to choose)."""
    out: Dict[str, Any] = {}
    for label, runs in run_groups:
        bj = runs[-1] / kernel / "benchmark.json"
        try:
            d = json.loads(bj.read_text(encoding="utf-8"))
            out[label] = d.get("cycles_send")
        except (OSError, ValueError):
            out[label] = None
    return out


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--sweep", required=True, help="sweep directory: <sweep>/<kernel>/run_*/<kernel>/")
    ap.add_argument("--out", required=True, help="output root for the frozen first-correct programs")
    ap.add_argument("--kernels", default=None, help="comma-separated subset")
    ap.add_argument("--overwrite", action="store_true")
    args = ap.parse_args()

    sweep = Path(os.path.expanduser(args.sweep))
    out = Path(os.path.expanduser(args.out))
    only = set(k.strip() for k in args.kernels.split(",")) if args.kernels else None
    records: List[Dict[str, Any]] = []
    for kdir in sorted(p for p in sweep.iterdir() if p.is_dir()):
        kernel = kdir.name
        if only and kernel not in only:
            continue
        run_groups = _run_groups(kdir)
        if not run_groups:
            records.append({"kernel": kernel, "status": "no_run_dir"})
            continue
        rec = None
        for label, runs in run_groups:                 # blind order: sorted by directory name
            cand = extract_run(runs[-1], kernel, out, args.overwrite)
            if cand.get("status") in ("extracted", "exists"):
                cand["source_group"] = label
                rec = cand
                break
            rec = rec or cand
        if rec is not None and len(run_groups) > 1:
            rec["sibling_fc_cycles"] = _sibling_cycles(run_groups, kernel)
        # meta.json is the tracked provenance file the sweep scripts read: keep the
        # seed choice and its blind alternatives there, not only in index.json.
        meta_path = out / kernel / "meta.json"
        if rec is not None and meta_path.is_file():
            try:
                meta = json.loads(meta_path.read_text(encoding="utf-8"))
                for key in ("source_group", "sibling_fc_cycles"):
                    if key in rec:
                        meta[key] = rec[key]
                meta["seed_choice_rule"] = ("lowest-sorted run group that yielded an extraction "
                                            "(blind to cycle counts)")
                meta_path.write_text(json.dumps(meta, indent=2), encoding="utf-8")
            except (OSError, ValueError):
                pass
        records.append(rec)
    out.mkdir(parents=True, exist_ok=True)
    # index.json is the ledger of every frozen program in this root, not just the
    # kernels of this invocation: extractions are done sweep by sweep, so merge by
    # kernel name (this run wins for a kernel it re-extracted) instead of replacing.
    index_path = out / "index.json"
    merged: Dict[str, Dict[str, Any]] = {}
    if index_path.is_file():
        try:
            prior = json.loads(index_path.read_text(encoding="utf-8"))
            for rec in prior if isinstance(prior, list) else []:
                if isinstance(rec, dict) and rec.get("kernel"):
                    merged[rec["kernel"]] = rec
        except (OSError, ValueError):
            pass
    for rec in records:
        if rec.get("kernel"):
            merged[rec["kernel"]] = rec
    index_path.write_text(json.dumps([merged[k] for k in sorted(merged)], indent=2), encoding="utf-8")
    counts: Dict[str, int] = {}
    for r in records:
        counts[r["status"]] = counts.get(r["status"], 0) + 1
    print(json.dumps({"sweep": str(sweep), "out": str(out), "kernels": len(records), "by_status": counts}, indent=2))
    for r in records:
        if r["status"] in ("extracted", "exists"):
            print(f"  {r['kernel']:28s} attempt {r['fc_attempt_index']:>2}  cycles {str(r['fc_cycles_send']):>8}  source={r.get('source','-')}")
        else:
            print(f"  {r['kernel']:28s} {r['status']}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
