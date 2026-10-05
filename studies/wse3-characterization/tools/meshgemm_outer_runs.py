#!/usr/bin/env python3
"""Is MeshGEMM's per-PE multiply an outer product? Measured, not read from source.

An outer-product (rank-1) update C += X[:,k] (x) W[k,:] issued as axpys shows up as a run
of consecutive FMACHs that share ONE vector operand (the X column) while the broadcast
scalar changes (one W[k,n] per FMACH). An inner-product order would instead hold the
accumulator fixed and change the vector every instruction. This counts the runs.
Evidence: `simulator`.
"""
import collections, gzip, json
from pathlib import Path

def runs_for(pe, lo, hi):
    disp, first = {}, {}
    with gzip.open("results/wse3-full/kernels/WaferLLM-MeshGEMM/events.jsonl.gz", "rt") as f:
        for line in f:
            if '"hwm_' not in line:
                continue
            e = json.loads(line); c = e["cycle"]
            if c < lo or c > hi:
                continue
            sim = (e.get("coordinates") or {}).get("simulator")
            if not sim or (sim["x"], sim["y"]) != pe:
                continue
            if e["_type"] == "hwm_dispatch_trace_entry":
                if e["name"] == "FMACH" and e.get("ut_id") == 255:
                    disp[e["uid"]] = c
            elif e["_type"] == "hwm_pipe_trace_entry" and e.get("simdi") == 0 and e.get("data") == 0:
                if e["uid"] in disp and e["uid"] not in first:
                    first[e["uid"]] = (disp[e["uid"]], e["src1"], e["src2"])
    runs = []
    for c, s1, s2 in sorted(first.values()):
        if runs and runs[-1][0] == s1:
            runs[-1][1].append(s2)
        else:
            runs.append([s1, [s2]])
    return len(first), runs

out = {"window": [70000, 72000], "pes": {}}
for pe in [(4, 1), (5, 2), (6, 3), (7, 4)]:
    n, runs = runs_for(pe, 70000, 72000)
    full = [r for r in runs[1:-1]]                  # edge runs may be cut by the window
    out["pes"][f"{pe[0]-4},{pe[1]-1}"] = {
        "fmach": n, "runs": len(runs),
        "interior_run_lengths": dict(collections.Counter(len(r[1]) for r in full)),
        "interior_distinct_scalars": dict(collections.Counter(len(set(r[1])) for r in full)),
    }
    print(f"  kernel PE {pe[0]-4},{pe[1]-1}: {n} FMACHs, interior runs sharing one vector operand: "
          f"{out['pes'][f'{pe[0]-4},{pe[1]-1}']['interior_run_lengths']}, distinct scalars per run: "
          f"{out['pes'][f'{pe[0]-4},{pe[1]-1}']['interior_distinct_scalars']}")
Path("results/datapath/meshgemm_outer_runs.json").write_text(json.dumps(out, indent=1))
print("  -> results/datapath/meshgemm_outer_runs.json")
