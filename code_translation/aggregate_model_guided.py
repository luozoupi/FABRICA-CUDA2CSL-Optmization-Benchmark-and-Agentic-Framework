#!/usr/bin/env python3
"""Aggregate a run_model_guided_ab.sh sweep: <root>/<kernel>/<arm>/seed_<n>/<kernel>/.

Retained pass = benchmark status "pass" AND success_marker AND (when the
held-out gate ran) a passing held-out evaluation. The per-task cycle estimator
is the median over passing seeds, reported only when both arms have >= 2
passing seeds (else NoData); best-of-k and last-accepted are sensitivity
columns. Suite-level: geometric mean of per-task O1/O0 ratios with a paired
bootstrap CI over tasks (10,000 resamples, fixed seed); pass rates with 95%
Wilson intervals. Better/worse counts are printed but are NOT a headline
statistic (they flip with the estimator).

Outputs: <root>/model_guided_runs.csv (one row per run), <root>/model_guided_tasks.csv
(one row per kernel), and a text summary on stdout.
"""
from __future__ import annotations

import argparse
import csv
import json
import math
import random
import statistics
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional


def _load(p: Path) -> Optional[Dict[str, Any]]:
    try:
        return json.loads(p.read_text())
    except (OSError, ValueError):
        return None


def wilson(k: int, n: int, z: float = 1.96):
    if n == 0:
        return (float("nan"), float("nan"))
    p = k / n
    denom = 1 + z * z / n
    centre = (p + z * z / (2 * n)) / denom
    half = z * math.sqrt(p * (1 - p) / n + z * z / (4 * n * n)) / denom
    return (max(0.0, centre - half), min(1.0, centre + half))


def geomean(xs: List[float]) -> float:
    xs = [x for x in xs if x and x > 0]
    return math.exp(sum(math.log(x) for x in xs) / len(xs)) if xs else float("nan")


def bootstrap_geomean_ci(xs: List[float], n_boot: int = 10000, seed: int = 20260908):
    xs = [x for x in xs if x and x > 0]
    if len(xs) < 2:
        return (float("nan"), float("nan"))
    rng = random.Random(seed)
    stats = []
    for _ in range(n_boot):
        sample = [xs[rng.randrange(len(xs))] for _ in xs]
        stats.append(geomean(sample))
    stats.sort()
    return (stats[int(0.025 * n_boot)], stats[int(0.975 * n_boot) - 1])


def retained_pass(bench: Optional[Dict[str, Any]]) -> bool:
    if not bench:
        return False
    if bench.get("status") != "pass" or not bench.get("success_marker"):
        return False
    # Second line of defence. benchmark_csl demotes status to "fail" when the
    # held-out gate fails, so the check above normally catches it; this also
    # rejects a record whose gate result says failed while status says pass.
    # evaluate_heldout's schema is {"passed", "failing_seed", "per_seed", "reason"}.
    he = bench.get("heldout_eval")
    if isinstance(he, dict) and he.get("passed") is False:
        return False
    return True


def collect(root: Path, fc_root: Optional[Path]) -> List[Dict[str, Any]]:
    rows: List[Dict[str, Any]] = []
    for kdir in sorted(p for p in root.iterdir() if p.is_dir()):
        kernel = kdir.name
        fc_cycles = None
        if fc_root:
            meta = _load(fc_root / kernel / "meta.json")
            # prefer the cycles re-verified under the current timing protocol
            fc_cycles = (meta or {}).get("fc_cycles_send_v2") or (meta or {}).get("fc_cycles_send")
        for adir in sorted(p for p in kdir.iterdir() if p.is_dir()):
            arm = adir.name
            for sdir in sorted(p for p in adir.glob("seed_*") if p.is_dir()):
                seed = int(sdir.name.split("_")[-1])
                # cuda2csl writes <output>/run_<UTC>/<kernel>/...; take the newest run.
                runs = sorted(sdir.glob("run_*"))
                kout = (runs[-1] / kernel) if runs else (sdir / kernel)
                summary = _load(kout / "optimization_summary.json")
                bench = _load(kout / "benchmark.json")
                steps = (summary or {}).get("steps") or []
                accepted = [s for s in steps if s.get("selected")]
                row = {
                    "kernel": kernel, "arm": arm, "seed": seed,
                    "fc_cycles": fc_cycles,
                    "model_class": ((summary or {}).get("baseline") or {}).get("model_class"),
                    "baseline_cycles": ((summary or {}).get("baseline") or {}).get("cycles_send"),
                    "final_status": (summary or {}).get("final_status") or (bench or {}).get("status"),
                    "success_marker": (bench or {}).get("success_marker"),
                    "retained_pass": retained_pass(bench),
                    "final_cycles": (summary or {}).get("final_cycles_send") if summary else (bench or {}).get("cycles_send"),
                    "attempts_used": (summary or {}).get("attempts_used"),
                    "n_accepted": len(accepted),
                    "accepted_angles": ";".join(str(s.get("angle")) for s in accepted),
                    "angles_denied": ";".join(sorted(((summary or {}).get("angles_denied") or {}).keys())),
                    "angle_source": (summary or {}).get("angle_source"),
                    # v2 sparse study: structure class of the start program, its compiled-code keys, hazards
                    "structure_keys": ";".join(((summary or {}).get("baseline") or {}).get("structure_keys") or []),
                    "ir_keys_baseline": ";".join(((summary or {}).get("baseline") or {}).get("ir_keys") or []),
                    "n_hazards_baseline": len(((summary or {}).get("baseline") or {}).get("ir_hazards") or []),
                    "n_hazard_flags": sum(1 for s in steps if s.get("hazard_flag")),
                    "n_candidates": sum(len(s.get("candidates") or []) for s in steps),
                    "n_contract_violations": sum(1 for s in steps for c in (s.get("candidates") or []) if c.get("contract_violation")),
                    "n_command_failed": sum(1 for s in steps for c in (s.get("candidates") or []) if c.get("failure_reason") == "command_failed"),
                    "complete": summary is not None,
                }
                rows.append(row)
    return rows


def summarise(rows: List[Dict[str, Any]], arms: List[str]) -> List[Dict[str, Any]]:
    kernels = sorted({r["kernel"] for r in rows})
    out: List[Dict[str, Any]] = []
    for k in kernels:
        rec: Dict[str, Any] = {"kernel": k}
        per_arm: Dict[str, List[Dict[str, Any]]] = {a: [r for r in rows if r["kernel"] == k and r["arm"] == a] for a in arms}
        for a in arms:
            runs = per_arm[a]
            passing = [r for r in runs if r["retained_pass"] and isinstance(r["final_cycles"], int)]
            cyc = [r["final_cycles"] for r in passing]
            rec[f"{a}_runs"] = len(runs)
            rec[f"{a}_pass"] = len(passing)
            rec[f"{a}_median"] = statistics.median(cyc) if len(cyc) >= 2 else (cyc[0] if len(cyc) == 1 else None)
            rec[f"{a}_best"] = min(cyc) if cyc else None
            rec[f"{a}_n_for_median"] = len(cyc)
        # The first-correct comparator is the start program measured by the runs
        # themselves (optimization_summary.baseline: same size, same num_runs, same
        # SDK), so a `--size` root compares against the start program AT THAT SIZE;
        # the extraction's meta.json cycles are the fallback for old roots.
        base = next((r.get("baseline_cycles") for r in rows if r["kernel"] == k and r.get("baseline_cycles")), None)
        fc = base or next((r["fc_cycles"] for r in rows if r["kernel"] == k and r["fc_cycles"]), None)
        rec["fc_cycles"] = fc
        rec["fc_source"] = "run_baseline" if base else ("meta" if fc else None)
        # Candidate-level accounting: a kernel whose every candidate was rejected by
        # the contract check reports a harness condition, not a model result.
        rec["n_candidates"] = sum(r.get("n_candidates") or 0 for r in rows if r["kernel"] == k)
        rec["n_contract_violations"] = sum(r.get("n_contract_violations") or 0 for r in rows if r["kernel"] == k)
        if len(arms) >= 2:
            a0, a1 = arms[0], arms[1]
            m0, m1 = rec.get(f"{a0}_median"), rec.get(f"{a1}_median")
            if rec[f"{a0}_n_for_median"] >= 2 and rec[f"{a1}_n_for_median"] >= 2 and m0 and m1:
                rec["ratio_median"] = m0 / m1          # > 1 means O1 (arms[1]) is faster
                rec["comparable"] = True
            else:
                rec["ratio_median"] = None
                rec["comparable"] = False
            b0, b1 = rec.get(f"{a0}_best"), rec.get(f"{a1}_best")
            rec["ratio_best"] = (b0 / b1) if (b0 and b1) else None
        if fc:
            for a in arms:
                m = rec.get(f"{a}_median")
                rec[f"{a}_speedup_vs_fc"] = (fc / m) if m else None
        out.append(rec)
    return out


def kernel_classes(rows: List[Dict[str, Any]]) -> Dict[str, str]:
    """Bottleneck class of each task's start program: the model readout of the
    frozen first-correct program, recorded by every model-guided (O1*) run in
    optimization_summary.baseline.model_class. The same program starts every
    arm, so one class per kernel; 'unclassified' when no run recorded it."""
    out: Dict[str, str] = {}
    for r in rows:
        c = r.get("model_class")
        if c and r["kernel"] not in out:
            out[r["kernel"]] = str(c)
    return out


def write_paired_csv(rows: List[Dict[str, Any]], path: Path) -> None:
    """figures/ipdps_paired.csv: one row per run with a first-correct reference."""
    classes = kernel_classes(rows)
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "w", newline="") as fh:
        w = csv.writer(fh)
        w.writerow(["kernel", "class", "arm", "seed", "cycles", "fc_cycles", "retained_pass", "structure"])
        for r in rows:
            fc = r.get("baseline_cycles") or r.get("fc_cycles")
            if not fc or not isinstance(r.get("final_cycles"), int):
                continue
            arm = {"O1A": "O1A", "O1S": "O1S"}.get(r["arm"], r["arm"])
            w.writerow([r["kernel"], classes.get(r["kernel"], "unclassified"), arm, r["seed"],
                        r["final_cycles"], fc, bool(r["retained_pass"]), r.get("structure_keys") or ""])


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("root")
    ap.add_argument("--fc", default=None, help="first_correct root (for fc_cycles)")
    ap.add_argument("--arms", default="O0,O1")
    ap.add_argument("--paired-csv", default=None,
                    help="also write the paper's figures/ipdps_paired.csv schema "
                         "(kernel,class,arm,seed,cycles,fc_cycles,retained_pass) to this path")
    a = ap.parse_args()
    root = Path(a.root)
    arms = [x.strip() for x in a.arms.split(",") if x.strip()]
    rows = collect(root, Path(a.fc) if a.fc else None)
    if not rows:
        print("no runs found under", root)
        return 1
    with open(root / "model_guided_runs.csv", "w", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=list(rows[0].keys()))
        w.writeheader(); w.writerows(rows)
    tasks = summarise(rows, arms)
    keys = sorted({k for t in tasks for k in t.keys()}, key=lambda s: (s != "kernel", s))
    with open(root / "model_guided_tasks.csv", "w", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=keys)
        w.writeheader(); w.writerows(tasks)

    print(f"\n=== MODEL-GUIDED A/B: {len(tasks)} kernels, arms {arms} ===")
    for arm in arms:
        n = sum(1 for r in rows if r["arm"] == arm and r["complete"])
        k = sum(1 for r in rows if r["arm"] == arm and r["retained_pass"])
        lo, hi = wilson(k, n)
        print(f"  {arm}: retained pass {k}/{n}  (Wilson 95% {100*lo:.0f}-{100*hi:.0f}%)")
    if len(arms) >= 2:
        ratios = [t["ratio_median"] for t in tasks if t.get("comparable")]
        if ratios:
            g = geomean(ratios); lo, hi = bootstrap_geomean_ci(ratios)
            print(f"  geomean {arms[0]}/{arms[1]} cycle ratio over {len(ratios)} comparable tasks: "
                  f"{g:.3f}x  (paired bootstrap 95% {lo:.3f}-{hi:.3f}); >1 favours {arms[1]}")
            better = sum(1 for r in ratios if r > 1.03); worse = sum(1 for r in ratios if r < 0.97)
            print(f"  (sensitivity only, not a headline) tasks with {arms[1]} faster by >3%: {better}, slower: {worse}, "
                  f"within 3%: {len(ratios) - better - worse}")
        fc_ratios = {arm: [t[f"{arm}_speedup_vs_fc"] for t in tasks if t.get(f"{arm}_speedup_vs_fc")] for arm in arms}
        for arm in arms:
            if fc_ratios[arm]:
                print(f"  {arm} geomean speedup over first-correct: {geomean(fc_ratios[arm]):.3f}x over {len(fc_ratios[arm])} tasks")
    print("\n  kernel                    " + "  ".join(f"{arm:>14s}" for arm in arms) + "   ratio(med)")
    for t in tasks:
        cells = []
        for arm in arms:
            m = t.get(f"{arm}_median")
            cells.append(f"{(str(int(m)) if m else '-'):>8s}({t[f'{arm}_pass']}/{t[f'{arm}_runs']})")
        r = t.get("ratio_median")
        print(f"  {t['kernel']:26s}" + "  ".join(f"{c:>14s}" for c in cells) + f"   {r:.2f}" if r else
              f"  {t['kernel']:26s}" + "  ".join(f"{c:>14s}" for c in cells) + "   NoData")
    for t in tasks:
        if t.get("n_candidates") and t["n_contract_violations"] == t["n_candidates"]:
            print(f"  !! {t['kernel']}: all {t['n_candidates']} candidates were rejected by the contract check "
                  f"-- a harness condition, not a model result; no candidate was benchmarked")
    print(f"\n  wrote {root/'model_guided_runs.csv'} and {root/'model_guided_tasks.csv'}")
    if a.paired_csv:
        write_paired_csv(rows, Path(a.paired_csv))
        print(f"  wrote {a.paired_csv}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
