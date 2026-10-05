#!/usr/bin/env python3
"""Re-parameterise retained programs along a kernel's size axis (RQ3 scaling).

For every (kernel, arm, seed) run of a model-guided sweep the FINAL program
(<run>/<kernel>/<target>) is benchmarked, unchanged, at every size listed in the
kernel's spec.yaml `sizes[]` (each size = its own commands_wse3_<size>.sh, so
the layout parameters change while the compute file stays the agent's). A size
where the program stops compiling or verifying is recorded as a non-scaling
failure (status compile_fail / verify_fail), never dropped.

Serial SDK (one cslc/cs_python at a time). Resumable: rows already present in
the output JSON are skipped. Next to the JSON a pseudo-run tree
<out stem>/<kernel>/<arm>__<size>/seed_<n>/run_scaled/<kernel>/ mirrors every
measurement (benchmark.json + program), so `hw_replay.py --sweep <out stem>`
replays the passing scaled programs on WSE-3 with each size's own build script;
aggregate_scaling.py merges both legs into the paper's figures/ipdps_scaling.csv.

Usage:
  python scale_retained.py --sweep code_translation/results/<mg sweep> \
      --kernels GEMM,GEMV-Collectives-2D,Attention-QP,Laplacian2D-Halo \
      --arms O0,O1 --seeds median --out code_translation/results/scaling/scaling_<tag>.json
"""
from __future__ import annotations

import argparse
import json
import os
import statistics
import sys
import time
from pathlib import Path
from typing import Any, Dict, List, Optional

sys.path.insert(0, str(Path(__file__).resolve().parent))

from benchmark_csl import benchmark_translated_compute_file  # noqa: E402
from rebaseline_references import kernel_dir, _load_yaml  # noqa: E402
from workflow_common import default_sdk_root, expand_path  # noqa: E402

REPO_ROOT = Path(__file__).resolve().parents[1]


def pe_count(params: Dict[str, Any]) -> Optional[int]:
    """PEs of a size from its layout params: P x P meshes, kernel_rows x kernel_cols,
    width x height. None when no rule applies."""
    if not isinstance(params, dict):
        return None
    if "P" in params:
        return int(params["P"]) ** 2
    if "kernel_rows" in params and "kernel_cols" in params:
        return int(params["kernel_rows"]) * int(params["kernel_cols"])
    if "width" in params and "height" in params:
        return int(params["width"]) * int(params["height"])
    return None


def mesh_side(params: Dict[str, Any]) -> Optional[int]:
    if not isinstance(params, dict):
        return None
    if "P" in params:
        return int(params["P"])
    if "kernel_rows" in params:
        return int(params["kernel_rows"])
    if "width" in params:
        return int(params["width"])
    return None


def sizes_of(kdir: Path) -> List[Dict[str, Any]]:
    spec = _load_yaml(kdir / "spec.yaml")
    out = []
    for s in spec.get("sizes") or []:
        if not isinstance(s, dict):
            continue
        script = s.get("commands_script") or "commands_wse3.sh"
        if not (kdir / "CSL" / script).is_file():
            continue
        out.append({"name": s.get("name"), "params": s.get("params") or {}, "commands_script": script,
                    "ref_cycles": ((s.get("wse3_reference") or {}).get("cycles_send")),
                    "P": mesh_side(s.get("params") or {}), "pes": pe_count(s.get("params") or {})})
    return out


def retained_programs(sweep: Path, kernel: str, arms: List[str], seeds: str) -> List[Dict[str, Any]]:
    """Final programs of a run_model_guided_ab.sh sweep: <sweep>/<kernel>/<arm>/seed_<n>/run_*/<kernel>/."""
    out = []
    for arm in arms:
        cands = []
        for sdir in sorted((sweep / kernel / arm).glob("seed_*")):
            runs = sorted(sdir.glob("run_*"))
            kout = (runs[-1] / kernel) if runs else None
            if not kout or not (kout / "benchmark.json").is_file():
                continue
            bench = json.loads((kout / "benchmark.json").read_text())
            if bench.get("status") != "pass" or not bench.get("success_marker"):
                continue
            target = bench.get("target_relpath") or "pe.csl"
            prog = kout / target
            if not prog.is_file():
                prog = kout / Path(target).name
            if not prog.is_file():
                continue
            cands.append({"arm": arm, "seed": int(sdir.name.split("_")[-1]), "program": prog,
                          "target_relpath": target, "cycles_small": bench.get("cycles_send")})
        if not cands:
            continue
        if seeds == "all":
            out.extend(cands)
        elif seeds == "best":
            out.append(min(cands, key=lambda c: c["cycles_small"] or float("inf")))
        else:  # median seed by small-size cycles
            cands.sort(key=lambda c: c["cycles_small"] or float("inf"))
            out.append(cands[len(cands) // 2])
    return out


def bench_at_size(prog: Path, kdir: Path, target_relpath: str, size: Dict[str, Any], sdk_root: str,
                  work_root: Path, num_runs: int, keep: bool) -> Dict[str, Any]:
    csl_dir = kdir / "CSL"
    # <kernel>__<size>__<arm>__seed_<n>: prog = <sweep>/<kernel>/<arm>/seed_<n>/run_*/<kernel>/<target>
    arm = prog.parents[3].name
    seed = prog.parents[2].name
    work = work_root / f"{kdir.name.replace(' ', '_').lower()}__{size['name']}__{arm}__{seed}"
    work.mkdir(parents=True, exist_ok=True)
    t0 = time.time()
    r = benchmark_translated_compute_file(
        translated_path=str(prog), reference_dir=str(csl_dir), target_relpath=target_relpath,
        work_dir=str(work), sdk_root=sdk_root, commands_script=size["commands_script"],
        num_runs=num_runs, keep_staged_bundle=keep)
    status = r.get("status")
    if status == "pass" and r.get("success_marker") and r.get("cycles_send"):
        st = "pass"
    else:
        steps = [t.get("step") for t in (r.get("transcript") or []) if t.get("status") != "pass"]
        st = "compile_fail" if "compile" in steps else "verify_fail"
    runs = r.get("cycles_send_runs") or ([r["cycles_send"]] if r.get("cycles_send") else [])
    return {"status": st, "cycles": int(statistics.median(runs)) if runs else None, "cycles_runs": runs,
            "failure_reason": r.get("failure_reason"), "elapsed_s": round(time.time() - t0, 1),
            "staged_bundle": r.get("staged_bundle") if keep else None}


def write_pseudo_run(root: Path, kernel: str, prog: Dict[str, Any], size: Dict[str, Any], kdir: Path,
                     measured: Dict[str, Any]) -> Path:
    """Mirror one scaled measurement as <root>/<kernel>/<arm>__<size>/seed_<n>/run_scaled/<kernel>/
    with benchmark.json + the program, so `hw_replay.py --sweep <root>` harvests the passing
    scaled programs (label '<arm>__<size>/seed_<n>', the size's own commands script) for the
    hardware leg of the scaling study."""
    kout = root / kernel / f"{prog['arm']}__{size['name']}" / f"seed_{prog['seed']}" / "run_scaled" / kernel
    kout.mkdir(parents=True, exist_ok=True)
    target = prog["target_relpath"]
    dest = kout / target
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_text(Path(prog["program"]).read_text())
    (kout / "benchmark.json").write_text(json.dumps({
        "status": "pass" if measured["status"] == "pass" else "fail",
        "success_marker": measured["status"] == "pass",
        "cycles_send": measured["cycles"], "cycles_send_runs": measured.get("cycles_runs"),
        "failure_reason": measured.get("failure_reason"),
        "target_relpath": target, "reference_dir": str(kdir / "CSL"),
        "commands_script": size["commands_script"], "size_name": size["name"], "params": size["params"],
        "scaled_from": str(prog["program"]),
    }, indent=2))
    (kout / "bundle_metadata.json").write_text(json.dumps({"kernel": kernel, "commands_script": size["commands_script"],
                                                            "reference_dir": str(kdir / "CSL"), "target_relpath": target}))
    return kout


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--sweep", required=True, help="run_model_guided_ab.sh sweep root")
    ap.add_argument("--kernels", required=True)
    ap.add_argument("--arms", default="O0,O1")
    ap.add_argument("--seeds", default="median", choices=["median", "best", "all"])
    ap.add_argument("--sizes", default=None, help="comma-separated size names (default: all in spec)")
    ap.add_argument("--num-runs", type=int, default=3)
    ap.add_argument("--sdk-root", default=default_sdk_root())
    ap.add_argument("--out", required=True)
    ap.add_argument("--work-root", default=str(REPO_ROOT / "code_translation" / "sandbox" / "scaling"))
    ap.add_argument("--keep-bundles", action="store_true", help="keep staged bundles for hw_replay")
    a = ap.parse_args()
    sweep = Path(expand_path(a.sweep))
    out = Path(expand_path(a.out)); out.parent.mkdir(parents=True, exist_ok=True)
    work_root = Path(expand_path(a.work_root)); work_root.mkdir(parents=True, exist_ok=True)
    arms = [x for x in a.arms.split(",") if x]
    wanted = [s.strip() for s in a.sizes.split(",")] if a.sizes else None
    rows: List[Dict[str, Any]] = json.loads(out.read_text())["rows"] if out.is_file() else []
    done = {(r["kernel"], r["series"], r["seed"], r["size"]) for r in rows}
    for kname in [k.strip() for k in a.kernels.split(",") if k.strip()]:
        kdir = kernel_dir(kname)
        reg = _load_yaml(kdir / "spec.yaml").get("kernel_id") or kdir.name.replace(" ", "-")
        sizes = [s for s in sizes_of(kdir) if not wanted or s["name"] in wanted]
        progs = retained_programs(sweep, reg, arms, a.seeds)
        print(f"== {reg}: {len(sizes)} sizes x {len(progs)} retained programs", flush=True)
        for p in progs:
            for s in sizes:
                key = (reg, p["arm"], p["seed"], s["name"])
                if key in done:
                    continue
                print(f"   {p['arm']} seed {p['seed']} @ {s['name']} (P={s['P']}, {s['pes']} PEs) ...", end=" ", flush=True)
                m = bench_at_size(p["program"], kdir, p["target_relpath"], s, a.sdk_root, work_root, a.num_runs, a.keep_bundles)
                print(f"{m['status']} cycles={m['cycles']} ({m['elapsed_s']}s)", flush=True)
                rows.append({"kernel": reg, "series": p["arm"], "seed": p["seed"], "size": s["name"], "P": s["P"],
                             "pes": s["pes"], "params": s["params"], "platform": "sim", **m,
                             "program": str(p["program"]), "ref_cycles": s["ref_cycles"]})
                write_pseudo_run(out.parent / out.stem, reg, p, s, kdir, m)
                out.write_text(json.dumps({"schema": "scaling/1", "sweep": str(sweep), "rows": rows}, indent=2))
    out.write_text(json.dumps({"schema": "scaling/1", "sweep": str(sweep), "rows": rows}, indent=2))
    print(f"\nwrote {out}: {len(rows)} rows")
    return 0


if __name__ == "__main__":
    sys.exit(main())
