#!/usr/bin/env python3
"""Export the x-supply headroom variants (trimmed broadcast, compute while x arrives, both, 2D partition) with the
reference cycles of the same matrix and PE count, to the paper's figures/ipdps_sparse_xsupply.csv."""
import csv, os
R = "/home/USER/xkernel/code_translation/results/phase2_stream"
PAPER = "/home/USER/6a64e2c9def474810517b3d0/figures"
COLS = {"HB/bcspwr06": 1454, "HB/bcspwr07": 1612, "HB/bcspwr08": 1624, "HB/bcspwr09": 1723}
ref = {(int(r["pes"]), r["matrix"]): int(r["cycles"]) for r in csv.DictReader(open(f"{PAPER}/ipdps_sparse_halo.csv"))
       if r["config"] == "ref" and r["status"] == "pass"}
rows = []
def add(variant, pes, matrix, seed, status, cycles):
    rows.append({"variant": variant, "pes": pes, "seed": seed, "matrix": matrix, "matrix_cols": COLS[matrix],
                 "status": status, "cycles": cycles, "reference_cycles": ref[(pes, matrix)]})
for f in ("stream_results_p64.csv", "stream_results_p256.csv"):
    for r in csv.DictReader(open(os.path.join(R, f))):
        add("stream" if r["rcm"] == "0" else "stream_rcm", int(r["pes"]), r["matrix"], r["seed"], r["status"], r["cycles"])
for f, name in (("trim_results.csv", "trim"), ("streamtrim_p64.csv", "stream_trim"), ("streamtrim_p256.csv", "stream_trim"),
                ("twod_results.csv", "2d"), ("twod_results_p256.csv", "2d")):
    for r in csv.DictReader(open(os.path.join(R, f))):
        pes = 64 if "p64" in r["commands"] else 256
        add(name, pes, r["matrix"], r["seed"], r["status"], r["cycles"])
with open(f"{PAPER}/ipdps_sparse_xsupply.csv", "w", newline="") as fh:
    w = csv.DictWriter(fh, fieldnames=list(rows[0]), lineterminator="\n"); w.writeheader(); w.writerows(rows)
for v in ("trim", "stream", "stream_rcm", "stream_trim", "2d"):
    for pes in (64, 256):
        g = [ref[(pes, r["matrix"])] / int(r["cycles"]) for r in rows if r["variant"] == v and r["pes"] == pes and r["status"] == "pass"]
        print(f"{v:12s} {pes:3d} n={len(g)} gain {min(g):.2f}-{max(g):.2f}")
print(len(rows), "rows")
