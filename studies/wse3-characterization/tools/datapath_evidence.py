#!/usr/bin/env python3
"""Capture the specific instruction instances the datapath argument rests on."""
from __future__ import annotations
import collections, gzip, json
from pathlib import Path

def s16(u):                      # 16-bit two's complement
    u &= 0xFFFF
    return u - 0x10000 if u & 0x8000 else u

def grab(path, tile, want, need_lanes=None, need_elems=None):
    disp, pipe = {}, collections.defaultdict(list)
    with gzip.open(path, "rt") as f:
        for line in f:
            if '"hwm_' not in line:
                continue
            e = json.loads(line)
            sim = (e.get("coordinates") or {}).get("simulator")
            if not sim or (sim["x"], sim["y"]) != tile:
                continue
            if e["_type"] == "hwm_dispatch_trace_entry":
                if e["name"] == want and e.get("ut_id") == 255:
                    disp[e["uid"]] = (e.get("num_data"), e["cycle"])
            elif e["_type"] == "hwm_pipe_trace_entry" and e.get("simdi") not in (None, 255):
                pipe[e["uid"]].append(e)
    for uid, (nd, dc) in disp.items():
        lr = pipe.get(uid)
        if not lr:
            continue
        lanes = {p["simdi"] for p in lr}
        if need_lanes and len(lanes) != need_lanes:
            continue
        if need_elems and nd != need_elems:
            continue
        return uid, nd, dc, sorted(lr, key=lambda p: (p["cycle"], p["simdi"]))
    return None

out = {}

g = grab("microbench/atomic_ops/events.jsonl.gz", (4, 1), "ADD16.NF", need_lanes=8)
uid, nd, dc, lr = g
out["simd_int16"] = {
    "opcode": "ADD16.NF", "source": "microbench/atomic_ops", "pe": [4, 1],
    "uid": uid, "num_data": nd, "dispatch_cycle": dc,
    "cycles": sorted({p["cycle"] for p in lr}),
    "lanes": [{"lane": p["simdi"], "elem": p["data"], "cycle": p["cycle"],
               "dest": s16(p["dest"]), "src0": s16(p["src0"]), "src1": s16(p["src1"]),
               "checks": s16(p["src0"]) + s16(p["src1"]) == s16(p["dest"])}
              for p in lr],
}
out["simd_int16"]["all_lanes_check"] = all(l["checks"] for l in out["simd_int16"]["lanes"])

g = grab("microbench/atomic_ops/events.jsonl.gz", (4, 1), "FADDH", need_elems=8)
if g:
    uid, nd, dc, lr = g
    out["recurrence_f16"] = {
        "opcode": "FADDH", "source": "microbench/atomic_ops", "pe": [4, 1],
        "uid": uid, "num_data": nd, "dispatch_cycle": dc,
        "steps": [{"elem": p["data"], "cycle": p["cycle"], "lane": p["simdi"],
                   "dest": p["dest"], "src0": p["src0"], "src1": p["src1"]} for p in lr],
    }
    cy = sorted({p["cycle"] for p in lr})
    out["recurrence_f16"]["cycles_per_element"] = (
        round((cy[-1] - cy[0]) / max(1, len(cy) - 1), 2) if len(cy) > 1 else None)
    st = out["recurrence_f16"]["steps"]
    out["recurrence_f16"]["src0_equals_prev_dest"] = all(
        st[i]["src0"] == st[i-1]["dest"] for i in range(1, len(st)))

g = grab("results/wse3-full/kernels/WaferLLM-MeshGEMV/events.jsonl.gz", (6, 3), "FMACH")
if g:
    uid, nd, dc, lr = g
    per = collections.Counter(p["cycle"] for p in lr)
    out["fma_f16"] = {"opcode": "FMACH", "source": "WaferLLM-MeshGEMV", "pe": [6, 3],
                      "uid": uid, "num_data": nd, "dispatch_cycle": dc,
                      "cycles": sorted(per), "lanes_per_cycle": sorted(per.values()),
                      "distinct_lanes": sorted({p["simdi"] for p in lr})}

p = Path("results/datapath/evidence.json")
p.write_text(json.dumps(out, indent=1))
print("wrote", p)
print("  int16 SIMD: all 8 lanes arithmetic checks ->", out["simd_int16"]["all_lanes_check"])
if "recurrence_f16" in out:
    r = out["recurrence_f16"]
    print(f"  f16 accumulate: {r['cycles_per_element']} cyc/element, "
          f"src0==prev dest -> {r['src0_equals_prev_dest']}")
if "fma_f16" in out:
    print(f"  FMACH: num_data={out['fma_f16']['num_data']} "
          f"lanes/cycle={out['fma_f16']['lanes_per_cycle']} "
          f"over {len(out['fma_f16']['cycles'])} cycles")
