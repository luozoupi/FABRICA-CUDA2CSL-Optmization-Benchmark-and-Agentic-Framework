#!/usr/bin/env python3
"""End-to-end lifecycle of the WaferLLM kernels: host -> I/O port -> support PEs ->
kernel PEs -> compute -> kernel PEs -> support PEs -> I/O port -> host.

For every packet on a non-kernel (memcpy runtime) colour: where it was first and last
observed, which way it travelled, and when. Binned over the whole run so the input
phase, the compute phase and the output phase separate by time.
Evidence: `simulator`. Kernel colour sets come from the kernel layout sources.
"""
import collections, gzip, json, sys
from pathlib import Path

KERNEL = {"WaferLLM-MeshGEMM": {1,2,3,4,5,6,7,8,9,12,13,16},
          "WaferLLM-MeshGEMV": {5,6,7,8,9,12,13,14,15,16}}
APP = lambda x, y: 4 <= x <= 7 and 1 <= y <= 4

def probe(kernel):
    obs = collections.defaultdict(list)
    fmach = collections.Counter(); disp_app = collections.Counter(); disp_sup = collections.Counter()
    B = 2000
    with gzip.open(f"results/wse3-full/kernels/{kernel}/events.jsonl.gz", "rt") as f:
        for line in f:
            if '"wavelet_trace_entry"' in line:
                e = json.loads(line); s = e["coordinates"]["simulator"]
                obs[int(e["ident"])].append((e["cycle"], s["x"], s["y"], int(e["fields"]) & 0x1F))
            elif '"hwm_dispatch_trace_entry"' in line:
                e = json.loads(line); s = (e.get("coordinates") or {}).get("simulator")
                if not s: continue
                b = e["cycle"] // B
                if APP(s["x"], s["y"]): disp_app[b] += 1
                else: disp_sup[b] += 1
                if e["name"] == "FMACH": fmach[b] += 1
    kc = KERNEL[kernel]
    rt = collections.defaultdict(lambda: collections.Counter())      # bin -> kind -> packets
    ends = collections.Counter(); samples = {}
    for ident, ob in obs.items():
        ob.sort(); col = ob[0][3]
        if col in kc: continue
        c0, x0, y0, _ = ob[0]; c1, x1, y1, _ = ob[-1]
        a0, a1 = APP(x0, y0), APP(x1, y1)
        kind = ("into kernel" if (not a0 and a1) else "out of kernel" if (a0 and not a1)
                else "within support" if (not a0 and not a1) else "within kernel")
        rt[c0 // B][kind] += 1
        key = (kind, (x0, y0), (x1, y1), col)
        ends[key] += 1
        samples.setdefault(key, (c0, c1))
    bins = sorted(set(rt) | set(fmach) | set(disp_app))
    print(f"\n== {kernel}: timeline in {B}-cycle bins (runtime-colour packets by direction)")
    print(f"   {'cycles':>15} {'FMACH':>6} {'app disp':>8} {'sup disp':>8}  runtime packets")
    for b in bins:
        r = rt.get(b, {})
        if not (fmach[b] or r or disp_app[b] > 200): continue
        print(f"   {b*B:>7}-{b*B+B-1:<7} {fmach[b]:>6} {disp_app[b]:>8} {disp_sup[b]:>8}  {dict(r)}")
    print("   top packet routes (kind, first PE, last PE, colour): count")
    for (kind, a, b, col), n in ends.most_common(14):
        print(f"     {kind:15} {a} -> {b} colour {col:2d}: {n}  first seen at cycle {samples[(kind,a,b,col)][0]}")
    return {"bins": {b*B: {"fmach": fmach[b], "app_dispatch": disp_app[b], "support_dispatch": disp_sup[b],
                           "runtime_packets": dict(rt.get(b, {}))} for b in bins},
            "routes": [{"kind": k, "from": list(a), "to": list(b), "colour": c, "packets": n,
                        "first_cycle": samples[(k, a, b, c)][0]}
                       for (k, a, b, c), n in ends.most_common(60)]}

out = {k: probe(k) for k in ("WaferLLM-MeshGEMV", "WaferLLM-MeshGEMM")}
Path("results/datapath/io_lifecycle.json").write_text(json.dumps(out, indent=1))
print("\n  -> results/datapath/io_lifecycle.json")
