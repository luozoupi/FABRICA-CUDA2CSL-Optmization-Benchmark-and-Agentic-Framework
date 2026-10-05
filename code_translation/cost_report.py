#!/usr/bin/env python3
"""Cost report over preserved runs: LLM tokens, dollars, simulator seconds, wall-clock.

One row per kernel output directory (the directory holding bundle_metadata.json).

Token accounting has two tiers and every row says which one it used:
  exact    usage_log.json is present (written by cuda2csl.write_final_artifacts
           from the provider's own usage blocks; runs after 2026-09-08). Input,
           output and cache-read tokens per phase are summed as recorded.
  modelled no usage_log.json (legacy runs). Translation tokens are estimated
           from translation_log.json with a cumulative-context model (each
           assistant turn re-reads every earlier message; chars / --chars-per-token)
           and are a LOWER BOUND, because the preserved history keeps only the
           final conversation state (review rounds are folded). Optimizer calls
           are not in translation_log.json at all; they are counted from
           optimization_summary.json steps and priced with --opt-step-tokens
           IN,OUT (calibrate from exact rows: see --calibrate).

Simulator seconds: sum of attempts[].script_elapsed_ms (translation, exact) plus
version_trace optimize versions' run_time_ms (partial: compile time of optimizer
candidates is not preserved) -- reported separately.

Wall-clock: run_<UTC> directory timestamp -> mtime of benchmark.json.

Dollars: --price MODEL=IN,OUT[,CACHE_READ] in USD per million tokens (repeatable;
a prefix match on the model name). No default prices are built in; without a
--price the dollar columns are blank.

Usage:
  python cost_report.py --roots code_translation/results --out docs/data/cost_report.csv \
      --price claude-opus-4-8=15,75,1.5 --price claude-sonnet-4-6=3,15,0.3
  python cost_report.py --roots <sweep> --calibrate      # exact vs modelled on rows that have both
"""
from __future__ import annotations

import argparse
import csv
import json
import re
import statistics
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

RUN_TS = re.compile(r"run_(\d{8})_(\d{6})")
ARM_DIR = re.compile(r"^(O0|O1|O1A|O1S|O2|A|B|C|D|on|off|ref|W2)$")
SEED_DIR = re.compile(r"^seed_(\d+)$")


def _load(p: Path) -> Optional[Any]:
    try:
        return json.loads(p.read_text())
    except (OSError, ValueError):
        return None


def parse_prices(specs: List[str]) -> Dict[str, Tuple[float, float, float]]:
    out: Dict[str, Tuple[float, float, float]] = {}
    for s in specs or []:
        name, _, vals = s.partition("=")
        parts = [float(x) for x in vals.split(",") if x.strip()]
        if len(parts) < 2:
            raise SystemExit(f"--price expects MODEL=IN,OUT[,CACHE_READ]: {s}")
        cache = parts[2] if len(parts) > 2 else parts[0] * 0.1
        out[name.strip()] = (parts[0], parts[1], cache)
    return out


def price_for(model: str, prices: Dict[str, Tuple[float, float, float]]) -> Optional[Tuple[float, float, float]]:
    if not model:
        return None
    for k, v in sorted(prices.items(), key=lambda kv: -len(kv[0])):
        if model.startswith(k):
            return v
    return None


def modelled_translation_tokens(messages: List[Dict[str, Any]], chars_per_token: float) -> Tuple[int, int, int]:
    """Cumulative-context model over the preserved history: (input, output, assistant_turns)."""
    ctx = 0
    inp = out = turns = 0
    for m in messages:
        c = m.get("content")
        n = len(c) if isinstance(c, str) else len(json.dumps(c)) if c is not None else 0
        if m.get("role") == "assistant":
            inp += ctx
            out += n
            turns += 1
        ctx += n
    return int(inp / chars_per_token), int(out / chars_per_token), turns


def run_row(run_dir: Path, root: Path, prices: Dict[str, Tuple[float, float, float]],
            chars_per_token: float, opt_step_tokens: Optional[Tuple[int, int]]) -> Dict[str, Any]:
    meta = _load(run_dir / "bundle_metadata.json") or {}
    bench = _load(run_dir / "benchmark.json") or {}
    final = _load(run_dir / "final_result.json") or {}
    opt = _load(run_dir / "optimization_summary.json") or {}
    usage = _load(run_dir / "usage_log.json")
    tlog = _load(run_dir / "translation_log.json") or {}
    vtrace = _load(run_dir / "version_trace.json") or {}
    try:
        rel = run_dir.relative_to(root).parts
    except ValueError:
        rel = run_dir.parts[-3:]
    arm = next((p for p in rel if ARM_DIR.match(p)), "")
    seed = next((SEED_DIR.match(p).group(1) for p in rel if SEED_DIR.match(p)), "")
    sweep = rel[0] if rel else root.name
    attempts = final.get("attempts") or []
    steps = opt.get("steps") or []
    row: Dict[str, Any] = {
        "sweep": sweep, "arm": arm, "seed": seed, "kernel": meta.get("kernel") or run_dir.name,
        "model": meta.get("model") or "", "backend": meta.get("backend") or "",
        "run_dir": str(run_dir.relative_to(root)) if rel else str(run_dir),
        "final_status": bench.get("status"), "success_marker": bench.get("success_marker"),
        "cycles_send": bench.get("cycles_send"),
        "n_translate_attempts": len(attempts), "n_optimize_steps": len(steps),
        "n_accepted": sum(1 for s in steps if s.get("selected")),
    }
    # --- tokens
    if usage and isinstance(usage.get("totals"), dict):
        t = usage["totals"]
        row.update(tier="exact", llm_calls=t.get("calls"), input_tokens=t.get("input_tokens"),
                   output_tokens=t.get("output_tokens"), cache_read_tokens=t.get("cache_read_input_tokens"))
        by_phase = usage.get("by_phase") or {}
        opt_phases = {k: v for k, v in by_phase.items() if k in ("optimize", "_select_optimization_angle")}
        row["opt_input_tokens"] = sum(int(v.get("input_tokens") or 0) for v in opt_phases.values())
        row["opt_output_tokens"] = sum(int(v.get("output_tokens") or 0) for v in opt_phases.values())
        row["opt_calls"] = sum(int(v.get("calls") or 0) for v in opt_phases.values())
        row["missing_usage_calls"] = sum(int(v.get("missing_usage") or 0) for v in by_phase.values())
    else:
        inp, out, turns = modelled_translation_tokens(tlog.get("messages") or [], chars_per_token)
        row.update(tier="modelled", llm_calls=turns, input_tokens=inp, output_tokens=out, cache_read_tokens=0,
                   opt_calls=len(steps) * 2 if steps else 0, missing_usage_calls=None)
        if opt_step_tokens and steps:
            row["opt_input_tokens"] = len(steps) * opt_step_tokens[0]
            row["opt_output_tokens"] = len(steps) * opt_step_tokens[1]
            row["input_tokens"] += row["opt_input_tokens"]
            row["output_tokens"] += row["opt_output_tokens"]
        else:
            row["opt_input_tokens"] = row["opt_output_tokens"] = None
    # --- dollars
    pr = price_for(row["model"], prices)
    if pr and row.get("input_tokens") is not None:
        usd = (row["input_tokens"] * pr[0] + (row["output_tokens"] or 0) * pr[1]
               + (row.get("cache_read_tokens") or 0) * pr[2]) / 1e6
        row["usd"] = round(usd, 4)
    else:
        row["usd"] = None
    # --- simulator and wall time
    row["sim_s_translate"] = round(sum(float(a.get("script_elapsed_ms") or 0) for a in attempts) / 1000.0, 1)
    opt_versions = [v for v in (vtrace.get("versions") or []) if str(v.get("phase", "")).startswith("optim")]
    row["sim_s_optimize_partial"] = round(sum(float(v.get("run_time_ms") or 0) for v in opt_versions) / 1000.0, 1)
    m = RUN_TS.search(str(run_dir))
    wall = None
    if m:
        import datetime as _dt
        try:
            start = _dt.datetime.strptime(m.group(1) + m.group(2), "%Y%m%d%H%M%S").replace(tzinfo=_dt.timezone.utc)
            end = _dt.datetime.fromtimestamp((run_dir / "benchmark.json").stat().st_mtime, tz=_dt.timezone.utc)
            wall = round((end - start).total_seconds() / 60.0, 1)
        except (OSError, ValueError):
            wall = None
    row["wall_min"] = wall
    return row


def summarise(rows: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    groups: Dict[Tuple[str, str, str], List[Dict[str, Any]]] = {}
    for r in rows:
        groups.setdefault((r["sweep"], r["arm"], r["tier"]), []).append(r)
    out = []
    for (sw, arm, tier), rs in sorted(groups.items()):
        def med(key):
            xs = [r[key] for r in rs if isinstance(r.get(key), (int, float))]
            return round(statistics.median(xs), 1) if xs else None
        out.append({"sweep": sw, "arm": arm, "tier": tier, "runs": len(rs),
                    "median_input_tokens": med("input_tokens"), "median_output_tokens": med("output_tokens"),
                    "median_usd": med("usd"), "total_usd": round(sum(r["usd"] for r in rs if r.get("usd")), 2) if any(r.get("usd") for r in rs) else None,
                    "median_sim_s_translate": med("sim_s_translate"), "median_wall_min": med("wall_min"),
                    "models": ";".join(sorted({r["model"] for r in rs if r["model"]}))})
    return out


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--roots", nargs="+", required=True, help="results roots (recursive)")
    ap.add_argument("--out", help="per-run CSV path")
    ap.add_argument("--summary-out", help="per-(sweep, arm, tier) CSV path")
    ap.add_argument("--price", action="append", default=[], help="MODEL=IN,OUT[,CACHE_READ] USD per Mtok")
    ap.add_argument("--chars-per-token", type=float, default=4.0)
    ap.add_argument("--opt-step-tokens", default=None, help="IN,OUT tokens per optimizer step for modelled rows")
    ap.add_argument("--calibrate", action="store_true",
                    help="on exact rows, compare the modelled estimate with the recorded usage")
    a = ap.parse_args()
    prices = parse_prices(a.price)
    ost = tuple(int(x) for x in a.opt_step_tokens.split(",")) if a.opt_step_tokens else None
    rows: List[Dict[str, Any]] = []
    for root_s in a.roots:
        root = Path(root_s)
        for meta in sorted(root.rglob("bundle_metadata.json")):
            rows.append(run_row(meta.parent, root, prices, a.chars_per_token, ost))  # type: ignore[arg-type]
    if not rows:
        print("no runs found"); return 1
    if a.out:
        out = Path(a.out); out.parent.mkdir(parents=True, exist_ok=True)
        keys = sorted({k for r in rows for k in r}, key=lambda s: (s not in ("sweep", "arm", "seed", "kernel", "model", "tier"), s))
        with open(out, "w", newline="") as fh:
            w = csv.DictWriter(fh, fieldnames=keys); w.writeheader(); w.writerows(rows)
        print(f"wrote {out} ({len(rows)} runs)")
    summ = summarise(rows)
    if a.summary_out:
        p = Path(a.summary_out); p.parent.mkdir(parents=True, exist_ok=True)
        with open(p, "w", newline="") as fh:
            w = csv.DictWriter(fh, fieldnames=list(summ[0].keys())); w.writeheader(); w.writerows(summ)
        print(f"wrote {p}")
    exact = sum(1 for r in rows if r["tier"] == "exact")
    print(f"runs {len(rows)}: exact usage {exact}, modelled {len(rows) - exact}")
    for s in summ:
        print(f"  {s['sweep'][:40]:40s} {s['arm']:4s} {s['tier']:8s} n={s['runs']:4d} "
              f"in~{s['median_input_tokens']} out~{s['median_output_tokens']} usd~{s['median_usd']} "
              f"sim_s~{s['median_sim_s_translate']} wall~{s['median_wall_min']}min")
    if a.calibrate:
        pairs = []
        for r in rows:
            if r["tier"] != "exact":
                continue
            tl = _load(Path(a.roots[0]) / r["run_dir"] / "translation_log.json") or {}
            inp, out, _ = modelled_translation_tokens(tl.get("messages") or [], a.chars_per_token)
            if r["input_tokens"]:
                pairs.append((inp / r["input_tokens"], (out or 0) / max(1, r["output_tokens"] or 1)))
        if pairs:
            print(f"\ncalibration over {len(pairs)} exact rows: modelled/exact input median "
                  f"{statistics.median(p[0] for p in pairs):.2f}, output median {statistics.median(p[1] for p in pairs):.2f}")
        else:
            print("\ncalibration: no exact rows with a translation log")
    return 0


if __name__ == "__main__":
    sys.exit(main())
