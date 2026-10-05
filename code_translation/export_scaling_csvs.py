#!/usr/bin/env python3
"""Export the wafer-level results of 30 Sep - 1 Oct 2026 into the manuscript's figure CSVs.

  python export_scaling_csvs.py --out <paper>/figures

Writes ipdps_sparse_wafer.csv (per run: size, configuration, seed, start/final cycles, whether the final
program carries a row_order.py), ipdps_sparse_mapping.csv (equal blocks vs the expert and the agent's
row mapping, reference and first-correct programs, per matrix), ipdps_sparse_iter.csv (the ten-product
SpMV task) and, when present, ipdps_sparse_halo.csv and ipdps_sparse_curve.csv. Matrix ids are public
SuiteSparse names; no paths or hosts are written."""
import argparse
import csv
import glob
import json
import os
from pathlib import Path

R = Path(__file__).resolve().parent / "results"


def _runs(root, size, impl):
    rows = []
    for f in sorted(glob.glob(str(R / root / "SpMV-RowBlock/*/seed_*/run_*/SpMV-RowBlock/optimization_summary.json"))):
        parts = f.split(os.sep)
        arm, seed = parts[-5], int(parts[-4].split("_")[1])
        d = json.load(open(f))
        rows.append({"size": size, "arm": arm, "implementation": impl, "seed": seed,
                     "start_cycles": (d.get("baseline") or {}).get("cycles_send"),
                     "final_cycles": d.get("final_cycles_send"),
                     "final_status": d.get("final_status"),
                     "row_order_in_final": int("row_order.py" in (d.get("extra_files") or {}))})
    return rows


def _write(path, rows, fields):
    with open(path, "w", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=fields)
        w.writeheader()
        for r in rows:
            w.writerow({k: r.get(k) for k in fields})
    print(f"wrote {path}: {len(rows)} rows")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", required=True)
    a = ap.parse_args()
    out = Path(a.out)

    wafer = []
    wafer += [r for r in _runs("mg_sparse_luna_wafer_p64_20260930_171825", 64, "first") ]
    for r in wafer:
        if r["arm"] != "O1W":
            r["implementation"] = "-"
    wafer += _runs(sorted(p.name for p in R.glob("mg_sparse_luna_waferfix_p64_2*"))[-1], 64, "corrected")
    p256 = _runs(sorted(p.name for p in R.glob("mg_sparse_luna_wafer_p256_2*"))[-1], 256, "corrected")
    for r in p256:
        if r["arm"] != "O1W":
            r["implementation"] = "-"
    wafer += p256
    _write(out / "ipdps_sparse_wafer.csv", wafer,
           ["size", "arm", "implementation", "seed", "start_cycles", "final_cycles", "final_status", "row_order_in_final"])

    mapping = []
    for program, f, key in (("reference", "scaling/row_order_headroom_20260930/headroom.json", "mapping"),
                            ("reference", "scaling/row_order_headroom_heldout_20260930/headroom.json", "mapping"),
                            ("first_correct", "scaling/fc_mapping_20261001/fc_mapping.json", "mapping")):
        p = R / f
        if not p.exists():
            continue
        for r in json.load(open(p)):
            if program == "reference" and "heldout" not in f and r["seed"] != 7:
                continue    # the first headroom run echoed seed 7 for every seed (relay); keep the train row only
            mapping.append({"program": program, "pes": int(r["size"][1:]), "seed": r["seed"], "matrix": r.get("matrix"),
                            "mapping": r[key].replace("nnz_balanced", "expert"), "status": r["status"], "cycles": r["cycles"]})
    _write(out / "ipdps_sparse_mapping.csv", mapping, ["program", "pes", "seed", "matrix", "mapping", "status", "cycles"])

    iroot = sorted(R.glob("mg_sparse_luna_iter_win_2*"))[-1]
    it = []
    for row in csv.DictReader(open(iroot / "model_guided_runs.csv")):
        it.append({"arm": row["arm"], "seed": row["seed"], "fc_cycles": row["fc_cycles"],
                   "final_cycles": row["final_cycles"], "retained_pass": row["retained_pass"]})
    _write(out / "ipdps_sparse_iter.csv", it, ["arm", "seed", "fc_cycles", "final_cycles", "retained_pass"])

    halo = R / "scaling/halo_headroom_20261001/halo_headroom.json"
    if halo.exists():
        rows = [{"pes": int(r["size"][1:]), "seed": r["seed"], "matrix": r.get("matrix"), "config": r["config"],
                 "status": r["status"], "cycles": r["cycles"]} for r in json.load(open(halo))]
        _write(out / "ipdps_sparse_halo.csv", rows, ["pes", "seed", "matrix", "config", "status", "cycles"])

    curve = sorted(R.glob("scaling/spmv_curve*/curve.json"))
    if curve:
        rows = json.load(open(curve[-1]))
        fields = sorted({k for r in rows for k in r if not isinstance(r[k], (list, dict))})
        _write(out / "ipdps_sparse_curve.csv", rows, fields)


if __name__ == "__main__":
    main()
