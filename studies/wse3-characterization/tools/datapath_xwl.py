#!/usr/bin/env python3
"""Cross-workload datapath probe: is an instruction's latency a property of the
hardware, or of the program around it?

The study already measured decode-to-execute depth on single workloads (§8, §10l).
That cannot separate a functional unit's intrinsic latency from the stalls the
surrounding code happens to impose. This does, by measuring the *same opcodes* in
deliberately different company:

  GEMM        FMACH-dominated, DSD operands, fabric-fed     (MeshGEMV / MeshGEMM)
  add         scalar arithmetic, register operands          (atomic_add / atomic_ops)
  readwrite   load/store dominated                          (pcsweep mem / singlepe)
  elementwise a third context for the same scalar opcodes   (GELU-1PE, Dot-Product)

For an in-order pipeline the *minimum* decode-to-execute over many instances of an
opcode is the unstalled latency: some instance somewhere had its operands ready.
If that minimum is the same number in every workload, it is structural. If it moves
with the workload, it is not a unit property and the model is wrong.

Joins, per PE: dispatch gives the mnemonic and uid; pipe stage 3 gives decode;
pipe stage 6 gives execute, one record per element, the value in the last (§10l).
Evidence: `simulator`.
"""

from __future__ import annotations

import argparse
import collections
import gzip
import json
import statistics
from pathlib import Path

DISPATCH = "hwm_dispatch_trace_entry"
PIPE = "hwm_pipe_trace_entry"
SENTINEL = 0xFFFF


def busiest_tile(path, window=None):
    c = collections.Counter()
    lo, hi = window if window else (None, None)
    with gzip.open(path, "rt") as f:
        for line in f:
            if '"hwm_dispatch_trace_entry"' not in line:
                continue
            e = json.loads(line)
            cy = e.get("cycle")
            if lo is not None and (cy < lo or cy > hi):
                continue
            sim = (e.get("coordinates") or {}).get("simulator")
            if sim:
                c[(int(sim["x"]), int(sim["y"]))] += 1
    return c.most_common(1)[0][0] if c else None


def collect(path, tile, window=None):
    """Per-instruction structure on one PE.

    A vector op emits one stage-3 record per element as the front end feeds it,
    and one stage-6 record per element per lane. Records with ``simdi`` 255 are
    the instruction-level placeholders; the lane records carry the operands and
    ``data`` is the element index. Timing therefore comes from the lane records.
    """
    lo, hi = window if window else (None, None)
    open_ = {}
    rows = []

    def close(uid):
        r = open_.pop(uid, None)
        if not r or not r["s3"]:
            return
        lane = sorted(r["lane"])                 # (cycle, simdi, elem)
        s3 = sorted(r["s3"])
        rec = {
            "name": r["name"], "ndata": r["ndata"], "ut": r["ut"],
            "disp": r["disp"], "s3_first": s3[0], "n_s3": len(s3),
            "n_lane": len(lane), "n_ph": r["ph"],
            "lanes": sorted(r["simdi"]),
            "elems": len({e for _, _, e in lane}),
        }
        if lane:
            rec["x_first"] = lane[0][0]
            rec["x_last"] = lane[-1][0]
            cyc = sorted({c for c, _, _ in lane})
            rec["ii"] = [b - a for a, b in zip(cyc, cyc[1:])]
            per = collections.Counter(c for c, _, _ in lane)
            rec["max_per_cycle"] = max(per.values())
        rows.append(rec)

    with gzip.open(path, "rt") as f:
        for line in f:
            if '"cycle"' not in line:
                continue
            e = json.loads(line)
            t = e.get("_type") or e.get("event_type")
            if t not in (DISPATCH, PIPE):
                continue
            cy = e.get("cycle")
            if cy is None or (lo is not None and (cy < lo or cy > hi)):
                continue
            sim = (e.get("coordinates") or {}).get("simulator")
            if not sim or (int(sim["x"]), int(sim["y"])) != tile:
                continue
            uid = e.get("uid")
            if uid is None:
                continue
            if t == DISPATCH:
                close(uid)
                nd = e.get("num_data")
                open_[uid] = {
                    "name": e.get("name") or (e.get("raw") or {}).get("name"),
                    "ndata": nd if isinstance(nd, int) and nd < SENTINEL else None,
                    "ut": e.get("ut_id"),
                    "disp": cy, "s3": set(), "lane": set(), "simdi": set(), "ph": 0,
                }
            else:
                r = open_.get(uid)
                if r is None:
                    continue
                st, sd = e.get("stage"), e.get("simdi")
                if st == 3:
                    r["s3"].add(cy)
                elif st == 6:
                    if sd is None or sd == 255:
                        r["ph"] += 1
                    else:
                        r["simdi"].add(sd)
                        r["lane"].add((cy, sd, e.get("data")))
    for uid in list(open_):
        close(uid)
    return rows


def stats(rows, main_only=True):
    """Latency is only meaningful where uid identifies one in-flight instruction.
    Microthreaded instructions (ut_id != 255) overlap the main thread and break
    that, so they are excluded here and counted separately."""
    by = collections.defaultdict(list)
    for r in rows:
        if not r.get("name") or "x_first" not in r:
            continue
        if main_only and r.get("ut") not in (255, None):
            continue
        by[r["name"]].append(r)
    out = {}
    for name, v in by.items():
        lat = [r["x_first"] - r["s3_first"] for r in v]
        ii = [d for r in v for d in r["ii"]]
        el = [r["elems"] for r in v]
        lanes = sorted({l for r in v for l in r["lanes"]})
        out[name] = {
            "n": len(v),
            "lat_min": min(lat), "lat_med": statistics.median(lat), "lat_max": max(lat),
            "ii_min": min(ii) if ii else None,
            "ii_med": statistics.median(ii) if ii else None,
            "elems_med": statistics.median(el), "elems_max": max(el),
            "lanes": lanes[:8], "n_lanes": len(lanes),
            "max_per_cycle": max(r.get("max_per_cycle", 1) for r in v),
        }
    return out


WORKLOADS = [
    ("gemv",        "GEMM", "results/wse3-full/kernels/WaferLLM-MeshGEMV/events.jsonl.gz", None),
    ("gemm",        "GEMM", "results/wse3-full/kernels/WaferLLM-MeshGEMM/events.jsonl.gz", (70000, 82000)),
    ("atomic_add",  "add",  "microbench/atomic_add/events.jsonl.gz", None),
    ("atomic_ops",  "add",  "microbench/atomic_ops/events.jsonl.gz", None),
    ("pcsweep_mem", "readwrite", "microbench/pcsweep/cases/mem/events.jsonl.gz", None),
    ("pcsweep_gpr", "readwrite", "microbench/pcsweep/cases/gpr/events.jsonl.gz", None),
    ("gelu",        "elementwise", "results/wse3-full/kernels/GELU-1PE/events.jsonl.gz", None),
    ("dotprod",     "elementwise", "results/wse3-full/kernels/Dot-Product-1PE/events.jsonl.gz", None),
]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("-o", "--out", default="results/datapath/xworkload.json")
    ap.add_argument("--only", nargs="*")
    a = ap.parse_args()

    result = {}
    for name, cls, rel, win in WORKLOADS:
        if a.only and name not in a.only:
            continue
        p = Path(rel)
        if not p.exists():
            print(f"  skip {name}: {rel} missing")
            continue
        tile = busiest_tile(p, win)
        print(f"  {name:12s} ({cls}) busiest PE {tile} ...", flush=True)
        rows = collect(p, tile, win)
        sc = stats(rows, main_only=True)
        mt = collections.Counter(r["name"] for r in rows
                                 if r.get("ut") not in (255, None))
        result[name] = {"class": cls, "source": rel, "tile": list(tile),
                        "window": list(win) if win else None,
                        "instructions": len(rows), "opcodes": sc,
                        "microthreaded": dict(mt.most_common()),
                        "elem_hist": dict(collections.Counter(
                            r.get("elems", 0) for r in rows).most_common(8))}
        print(f"      {len(rows)} instructions, {len(sc)} opcodes with lane records")

    out = Path(a.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(result, indent=1))
    print(f"\n  -> {out}")


if __name__ == "__main__":
    main()
