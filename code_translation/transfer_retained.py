#!/usr/bin/env python3
"""Run retained programs on the HELD-OUT matrices of their class (RQ3 transfer).

The acceptance gate already proves a retained program is *correct* on the held-out
matrices (`benchmark_csl.evaluate_heldout`), but it records no cycle count for them and
never measures the frozen first-correct program there. The transfer estimator of the
pre-registration needs both: per task, the fraction of held-out matrices on which the
retained program passes AND beats the first-correct program.

So for every (kernel, arm, seed) final program of a model-guided sweep, plus the kernel's
frozen first-correct program as the baseline series `FC`, this script

  * benchmarks the program once (compile + train-matrix run, staged bundle kept), then
  * re-runs ONLY the `cs_python run.py` step once per held-out seed on that same compiled
    bundle -- exactly what the held-out gate does -- and parses `cycles_send`, the matrix
    id and its nnz from the runner's own stdout (`matrix = <id> n=.. m=.. nnz=..`).

The held-out seed values come from the kernel's `spec.yaml` `eval:` block and are injected
through the environment and the bundle's `.xkernel_eval_env.json`; they never enter a
prompt. A run whose `eval_seed = N` echo disagrees with the requested seed is recorded as
`env_not_propagated` (infrastructure), never as a kernel property -- see
docs/SPARSE_SUITE.md and the 2026-09-16 pre-registration entry.

Serial SDK (one cslc/cs_python at a time). Resumable: (kernel, series, seed, eval_seed)
rows already in the output JSON are skipped. Writes the JSON plus, with --csv, the
figure schema `kernel,arm,seed,train_matrix,eval_matrix,status,cycles,fc_cycles,nnz`.

Usage:
  python transfer_retained.py --sweep code_translation/results/<mg sweep> \
      --kernels "$(python task_sets.py --kernels S)" --arms O0,O1,O1I --seeds median \
      --fc code_translation/results/first_correct/sparse_20260924 \
      --out code_translation/results/transfer/transfer_<tag>.json --csv <paper>/figures/ipdps_sparse_transfer.csv
"""
from __future__ import annotations

import argparse
import csv
import json
import re
import statistics
import sys
import time
from pathlib import Path
from typing import Any, Dict, List, Optional

sys.path.insert(0, str(Path(__file__).resolve().parent))

from benchmark_csl import (  # noqa: E402
    _heldout_eval_for_reference,
    _run_step_command,
    benchmark_translated_compute_file,
    classify_command_step,
    parse_command_script,
)
from rebaseline_references import _load_yaml, kernel_dir  # noqa: E402
from scale_retained import retained_programs  # noqa: E402
from workflow_common import default_sdk_root, expand_path  # noqa: E402

REPO_ROOT = Path(__file__).resolve().parents[1]

_CYCLES_RE = re.compile(r"cycles_send\s*=\s*(\d+)")
_SEED_ECHO_RE = re.compile(r"eval_seed\s*=\s*(\d+)")
_MATRIX_RE = re.compile(r"matrix\s*=\s*(\S+).*?nnz=(\d+)")


def parse_run_stdout(text: str) -> Dict[str, Any]:
    """cycles, matrix id, nnz and the seed echo, from the runner's own prints."""
    out: Dict[str, Any] = {"cycles": None, "matrix": None, "nnz": None, "seed_echo": None,
                           "success_marker": "SUCCESS" in (text or "")}
    m = _CYCLES_RE.search(text or "")
    if m:
        out["cycles"] = int(m.group(1))
    m = _MATRIX_RE.search(text or "")
    if m:
        out["matrix"], out["nnz"] = m.group(1), int(m.group(2))
    m = _SEED_ECHO_RE.search(text or "")
    if m:
        out["seed_echo"] = int(m.group(1))
    return out


def fc_program(fc_root: Optional[Path], kernel: str, target_relpath: str) -> Optional[Dict[str, Any]]:
    """The frozen first-correct program of a kernel, as a series named FC."""
    if not fc_root:
        return None
    kdir = fc_root / kernel
    if not kdir.is_dir():
        return None
    for cand in (kdir / target_relpath, kdir / Path(target_relpath).name, *sorted(kdir.glob("*.csl"))):
        if cand.is_file():
            return {"arm": "FC", "seed": 0, "program": cand, "target_relpath": target_relpath,
                    "cycles_small": None}
    return None


def run_on_seeds(staged_bundle: str, commands_script: str, seeds: List[int], sdk_root: str,
                 seed_env: str, timeout: int) -> List[Dict[str, Any]]:
    """Re-run the compiled bundle's run step once per seed (no recompile)."""
    script_path = Path(staged_bundle) / commands_script
    run_cmds = [c for c in parse_command_script(str(script_path))
                if classify_command_step(c) == "run"]
    rows: List[Dict[str, Any]] = []
    for seed in seeds:
        env = {seed_env: str(seed), f"SINGULARITYENV_{seed_env}": str(seed),
               f"APPTAINERENV_{seed_env}": str(seed)}
        row: Dict[str, Any] = {"eval_seed": seed, "status": "pass", "cycles": None,
                               "matrix": None, "nnz": None, "seed_echo": None, "reason": ""}
        for cmd in run_cmds:
            step = _run_step_command(staged_bundle, cmd, sdk_root, extra_env=env, timeout=timeout)
            info = parse_run_stdout(str(step.get("stdout") or ""))
            row.update({k: info[k] for k in ("cycles", "matrix", "nnz", "seed_echo") if info[k] is not None})
            if info["seed_echo"] is not None and info["seed_echo"] != seed:
                row.update({"status": "env_not_propagated",
                            "reason": f"run.py reports eval_seed={info['seed_echo']} for requested {seed}"})
                break
            if not step.get("ok") or not info["success_marker"]:
                row.update({"status": "fail",
                            "reason": (str(step.get("stderr") or "")[-400:] or "no SUCCESS marker")})
                break
        if row["status"] == "pass" and not row["cycles"]:
            row.update({"status": "no_cycles", "reason": "run passed but printed no cycles_send"})
        rows.append(row)
    return rows


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--sweep", required=True, help="run_model_guided_ab.sh sweep root")
    ap.add_argument("--kernels", required=True)
    ap.add_argument("--arms", default="O0,O1,O1I")
    ap.add_argument("--seeds", default="median", choices=["median", "best", "all"])
    ap.add_argument("--fc", default=None, help="first_correct root, added as series FC")
    ap.add_argument("--num-runs", type=int, default=3, help="train-matrix repeats (held-out seeds run once)")
    ap.add_argument("--timeout", type=int, default=1800)
    ap.add_argument("--sdk-root", default=default_sdk_root())
    ap.add_argument("--out", required=True)
    ap.add_argument("--csv", default=None, help="also write the figure CSV")
    ap.add_argument("--work-root", default=str(REPO_ROOT / "code_translation" / "sandbox" / "transfer"))
    a = ap.parse_args()

    sweep = Path(expand_path(a.sweep))
    out = Path(expand_path(a.out)); out.parent.mkdir(parents=True, exist_ok=True)
    work_root = Path(expand_path(a.work_root)); work_root.mkdir(parents=True, exist_ok=True)
    fc_root = Path(expand_path(a.fc)) if a.fc else None
    arms = [x for x in a.arms.split(",") if x]
    rows: List[Dict[str, Any]] = json.loads(out.read_text())["rows"] if out.is_file() else []
    done = {(r["kernel"], r["series"], r["seed"], r["eval_seed"]) for r in rows}

    for kname in [k.strip() for k in a.kernels.split(",") if k.strip()]:
        kdir = kernel_dir(kname)
        spec = _load_yaml(kdir / "spec.yaml")
        reg = spec.get("kernel_id") or kdir.name.replace(" ", "-")
        csl_dir = kdir / "CSL"
        ev = _heldout_eval_for_reference(str(csl_dir)) or {}
        heldout = list(ev.get("heldout_seeds") or [])
        if not heldout:
            print(f"== {reg}: no held-out seeds in spec.yaml -- skipped", flush=True)
            continue
        target = spec.get("compute_file") or "pe.csl"
        script = "commands_wse3.sh"
        for s in (spec.get("sizes") or []):
            if isinstance(s, dict) and s.get("commands_script"):
                script = s["commands_script"]
                break
        progs = retained_programs(sweep, reg, arms, a.seeds)
        fc = fc_program(fc_root, reg, target)
        if fc:
            progs = [fc] + progs
        print(f"== {reg}: {len(progs)} programs x {len(heldout)} held-out matrices "
              f"(train seed {ev.get('train_seed')})", flush=True)
        for p in progs:
            if all((reg, p["arm"], p["seed"], s) in done for s in heldout):
                continue
            work = work_root / f"{reg.lower()}__{p['arm']}__seed_{p['seed']}"
            work.mkdir(parents=True, exist_ok=True)
            t0 = time.time()
            r = benchmark_translated_compute_file(
                translated_path=str(p["program"]), reference_dir=str(csl_dir),
                target_relpath=p["target_relpath"], work_dir=str(work), sdk_root=a.sdk_root,
                commands_script=script, num_runs=a.num_runs, keep_staged_bundle=True,
                heldout_eval=False, timeout=a.timeout)
            train = parse_run_stdout("\n".join(str(t.get("stdout") or "")
                                               for t in (r.get("transcript") or [])))
            staged = r.get("staged_bundle")
            base_runs = r.get("cycles_send_runs") or ([r["cycles_send"]] if r.get("cycles_send") else [])
            train_cycles = int(statistics.median(base_runs)) if base_runs else None
            if r.get("status") != "pass" or not staged:
                steps = [t.get("step") for t in (r.get("transcript") or []) if t.get("status") != "pass"]
                st = "compile_fail" if "compile" in steps else "train_fail"
                print(f"   {p['arm']} seed {p['seed']}: {st} on the TRAIN matrix -- "
                      f"held-out runs skipped ({r.get('failure_reason')})", flush=True)
                for s in heldout:
                    rows.append({"kernel": reg, "series": p["arm"], "seed": p["seed"], "eval_seed": s,
                                 "status": st, "cycles": None, "train_cycles": train_cycles,
                                 "train_matrix": train.get("matrix"), "matrix": None, "nnz": None,
                                 "reason": str(r.get("failure_reason") or "")[:200],
                                 "program": str(p["program"])})
                continue
            measured = run_on_seeds(staged, script, [s for s in heldout
                                                     if (reg, p["arm"], p["seed"], s) not in done],
                                    a.sdk_root, str(ev.get("seed_env") or "XKERNEL_EVAL_SEED"), a.timeout)
            for m in measured:
                rows.append({"kernel": reg, "series": p["arm"], "seed": p["seed"],
                             "eval_seed": m["eval_seed"], "status": m["status"], "cycles": m["cycles"],
                             "train_cycles": train_cycles, "train_matrix": train.get("matrix"),
                             "matrix": m["matrix"], "nnz": m["nnz"], "reason": m["reason"][:200],
                             "program": str(p["program"])})
                print(f"   {p['arm']} seed {p['seed']} @ {m['matrix']} (seed {m['eval_seed']}): "
                      f"{m['status']} {m['cycles']} cycles (train {train_cycles})", flush=True)
            out.write_text(json.dumps({"sweep": str(sweep), "fc": str(fc_root or ""),
                                       "sdk_root": a.sdk_root, "rows": rows}, indent=2))
            print(f"   ({round(time.time() - t0, 1)}s)", flush=True)

    out.write_text(json.dumps({"sweep": str(sweep), "fc": str(fc_root or ""), "sdk_root": a.sdk_root,
                               "rows": rows}, indent=2))
    print(f"\nreport: {out}  ({len(rows)} rows)")

    if a.csv:
        # figure schema: one row per (kernel, arm, seed, eval matrix), with the FC series'
        # cycles on the SAME matrix as the comparison column.
        fc_by = {(r["kernel"], r["eval_seed"]): r["cycles"] for r in rows
                 if r["series"] == "FC" and r["status"] == "pass"}
        path = Path(expand_path(a.csv)); path.parent.mkdir(parents=True, exist_ok=True)
        with open(path, "w", newline="") as fh:
            w = csv.writer(fh)
            w.writerow(["kernel", "arm", "seed", "train_matrix", "eval_matrix", "status", "cycles",
                        "fc_cycles", "nnz"])
            for r in rows:
                if r["series"] == "FC":
                    continue
                w.writerow([r["kernel"], r["series"], r["seed"], r["train_matrix"] or "",
                            r["matrix"] or "", r["status"], r["cycles"] or "",
                            fc_by.get((r["kernel"], r["eval_seed"])) or "", r["nnz"] or ""])
        print(f"csv: {path}")

    # summary: the pre-registration's transfer estimator
    per = {}
    for r in rows:
        if r["series"] == "FC":
            continue
        key = (r["kernel"], r["series"])
        fc = next((x["cycles"] for x in rows if x["series"] == "FC" and x["kernel"] == r["kernel"]
                   and x["eval_seed"] == r["eval_seed"] and x["status"] == "pass"), None)
        ok = r["status"] == "pass"
        beats = bool(ok and fc and r["cycles"] and r["cycles"] < fc)
        d = per.setdefault(key, {"n": 0, "pass": 0, "beats": 0})
        d["n"] += 1
        d["pass"] += int(ok)
        d["beats"] += int(beats)
    if per:
        print("\ntransfer (held-out matrices): kernel arm  passed/n  passed-and-beats-FC/n")
        for (k, arm), d in sorted(per.items()):
            print(f"  {k:22s} {arm:5s} {d['pass']}/{d['n']}   {d['beats']}/{d['n']}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
