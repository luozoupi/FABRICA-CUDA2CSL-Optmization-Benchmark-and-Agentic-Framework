#!/usr/bin/env python3
"""Extract a step-wise, debug-mode view of each matmul traversal.

Phases are located from the trace itself: each variant's floating-point
instruction sits at its own PC, so the cycle range of that PC is the variant's
phase. That is cross-checked against the on-device TSC deltas in
matmulorder_results.json, which agree to about 0.1%.

For each variant this keeps:
  * the phase cycle range and the PCs belonging to it
  * a full dispatch list for the first few inner iterations, with cycles
  * the lane structure of one FP instance, with operand values

Index labels (which i, k, j an iteration is on) are *source-derived*: they follow
from the generated loop order, not from anything in the trace. They are marked as
such on the page, per ARCHITECTURE_MODEL_PLAN.md.
"""
from __future__ import annotations
import collections, gzip, json
from pathlib import Path

STUDY = Path(__file__).resolve().parent.parent
MB = STUDY / "microbench/matmulorder"
APP = (4, 1)

# PC of the FP op -> variant, established by matching phase spans to TSC deltas
VAR_PC = {int(k, 16): v for k, v in json.loads(Path(
    "/tmp/scratch/pcmap15.json"
).read_text()).items()}

meta = json.loads((MB / "meta.json").read_text())
res = {v["order"]: v for v in json.loads((MB / "matmulorder_results.json").read_text())["variants"]}
M, N, K = meta["M"], meta["N"], meta["K"]

# ---- pass 1: phase bounds from the FP PCs -------------------------------
ph = collections.defaultdict(lambda: [1 << 62, 0, 0])
with gzip.open(MB / "events.jsonl.gz", "rt") as f:
    for line in f:
        if '"hwm_dispatch_trace_entry"' not in line:
            continue
        e = json.loads(line)
        sim = (e.get("coordinates") or {}).get("simulator")
        if not sim or (sim["x"], sim["y"]) != APP:
            continue
        v = VAR_PC.get(e["inst_ptr"])
        if v is None:
            continue
        r = ph[v]
        r[0] = min(r[0], e["cycle"]); r[1] = max(r[1], e["cycle"]); r[2] += 1
print("phases located:")
for v, (lo, hi, n) in sorted(ph.items(), key=lambda kv: kv[1][0]):
    tsc = res[v]["cycles"]
    print(f"  {v:11s} cycles {lo:8d}..{hi:8d} span {hi-lo:8d}  TSC {tsc:8d}  "
          f"delta {100*abs((hi-lo)-tsc)/tsc:.2f}%  fp dispatches {n}")

# ---- pass 2: detailed windows -------------------------------------------
NSTEP = 90                       # dispatches kept per variant
steps = {v: [] for v in ph}
lanes = {v: None for v in ph}
open_fp = {}
with gzip.open(MB / "events.jsonl.gz", "rt") as f:
    for line in f:
        if '"hwm_' not in line:
            continue
        e = json.loads(line)
        sim = (e.get("coordinates") or {}).get("simulator")
        if not sim or (sim["x"], sim["y"]) != APP:
            continue
        c = e["cycle"]
        cur = None
        for v, (lo, hi, _) in ph.items():
            if lo <= c <= hi:
                cur = v; break
        if cur is None:
            continue
        if e["_type"] == "hwm_dispatch_trace_entry":
            if len(steps[cur]) < NSTEP:
                steps[cur].append({"cyc": c - ph[cur][0], "pc": e["inst_ptr"],
                                   "op": e["name"], "nd": e.get("num_data"),
                                   "uid": e["uid"]})
            if lanes[cur] is None and VAR_PC.get(e["inst_ptr"]) == cur \
               and (e["name"].startswith("FMAC") or e["name"].startswith("FMUL")):
                open_fp[(cur, e["uid"])] = {"op": e["name"], "nd": e.get("num_data"),
                                            "recs": []}
        elif e["_type"] == "hwm_pipe_trace_entry" and e.get("simdi") not in (None, 255):
            k = (cur, e["uid"])
            if k in open_fp:
                open_fp[k]["recs"].append({"cyc": c, "lane": e["simdi"], "elem": e["data"],
                                           "dest": e["dest"], "src0": e["src0"],
                                           "src1": e["src1"], "src2": e.get("src2")})
                if len(open_fp[k]["recs"]) >= (open_fp[k]["nd"] or 1):
                    d = open_fp.pop(k)
                    r0 = min(x["cyc"] for x in d["recs"])
                    for x in d["recs"]:
                        x["cyc"] -= r0
                    d["lanes"] = sorted({x["lane"] for x in d["recs"]})
                    d["cycles"] = len(sorted({x["cyc"] for x in d["recs"]}))
                    lanes[cur] = d
        if all(len(steps[v]) >= NSTEP for v in ph) and all(lanes[v] for v in ph):
            break

out = {"M": M, "N": N, "K": K, "macs": meta["macs"],
       "variants": {}}
for v in ph:
    lo, hi, nfp = ph[v]
    out["variants"][v] = {
        "phase": [lo, hi], "span": hi - lo, "tsc_cycles": res[v]["cycles"],
        "fp_dispatches": nfp, "macs_per_cycle": res[v]["macs_per_cycle"],
        "passed": res[v]["passed"], "max_abs_err": res[v]["max_abs_err"],
        "failure_hypothesis": res[v].get("failure_hypothesis"),
        "vs_best": res[v].get("vs_best"),
        "steps": steps[v], "fp_instance": lanes[v],
    }
o = STUDY / "results/datapath/matmul_steps.json"
o.write_text(json.dumps(out, indent=1))
print(f"\n  -> {o}  ({o.stat().st_size/1024:.0f} KB)")
