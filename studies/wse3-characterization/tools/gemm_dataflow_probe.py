#!/usr/bin/env python3
"""Measure what each fabric colour carries in the WaferLLM GEMM/GEMV traces.

Colour roles come from the kernel sources (~/waferllm/Mesh*/src/layout.csl) and
the compiled route tables; this checks them against the simulator trace:
per colour, how many wavelet observations, how many distinct packets, which
direction they travel, how far, and -- for the multicast colours -- whether one
packet identity is observed at several PEs along its line.

Colour = bits 0-4 of `fields` (verified against the ELF routing tables earlier).
Evidence: observations `simulator`; colour roles `compiled` + source.
"""
from __future__ import annotations
import collections, gzip, json, sys
from pathlib import Path

ROLE = {
 "WaferLLM-MeshGEMM": {1: "X shift (row ring)", 2: "X shift (row ring)", 3: "X shift (row ring)",
                       4: "W shift (column ring)", 5: "W shift (column ring)", 6: "W shift (column ring)",
                       7: "X initial skew, reverse", 8: "X initial skew, reverse", 9: "X initial skew, reverse",
                       12: "X initial skew", 13: "X initial skew", 16: "X initial skew"},
 "WaferLLM-MeshGEMV": {5: "reduce stage 1, down", 6: "reduce stage 1, down",
                       7: "reduce stage 1, up", 8: "reduce stage 1, up",
                       9: "result broadcast up (multicast)", 12: "result broadcast down (multicast)",
                       13: "reduce stage 2, up", 14: "reduce stage 2, up",
                       15: "reduce stage 2, down", 16: "reduce stage 2, down"},
}
APP = {(x, y) for x in range(4, 8) for y in range(1, 5)}

def run(kernel, window=None):
    path = Path(f"results/wse3-full/kernels/{kernel}/events.jsonl.gz")
    lo, hi = window or (None, None)
    obs = collections.defaultdict(list)          # ident -> [(cycle, xy, colour)]
    with gzip.open(path, "rt") as f:
        for line in f:
            if '"wavelet_trace_entry"' not in line:
                continue
            e = json.loads(line)
            c = e["cycle"]
            if lo is not None and not (lo <= c <= hi):
                continue
            sim = (e.get("coordinates") or {}).get("simulator")
            if not sim:
                continue
            obs[int(e["ident"])].append((c, (sim["x"], sim["y"]), int(e["fields"]) & 0x1F))
    per = collections.defaultdict(lambda: {"obs": 0, "pkts": 0, "app_pkts": 0,
                                           "dir": collections.Counter(), "span": collections.Counter(),
                                           "pes_per_pkt": collections.Counter()})
    for ident, ob in obs.items():
        ob.sort()
        col = collections.Counter(o[2] for o in ob).most_common(1)[0][0]
        s = per[col]
        s["obs"] += len(ob); s["pkts"] += 1
        pes = []
        for _, xy, _ in ob:
            if not pes or pes[-1] != xy:
                pes.append(xy)
        if all(p in APP for p in pes):
            s["app_pkts"] += 1
        s["pes_per_pkt"][len(pes)] += 1
        if len(pes) >= 2:
            dx = pes[-1][0] - pes[0][0]; dy = pes[-1][1] - pes[0][1]
            d = ("E" if dx > 0 else "W" if dx < 0 else "") + ("S" if dy > 0 else "N" if dy < 0 else "")
            s["dir"][d or "-"] += 1
            s["span"][abs(dx) + abs(dy)] += 1
    return per

def main():
    out = {}
    for kernel, win in (("WaferLLM-MeshGEMM", (70000, 82000)), ("WaferLLM-MeshGEMV", None)):
        per = run(kernel, win)
        roles = ROLE[kernel]
        print(f"\n== {kernel}" + (f"  (cycles {win[0]}-{win[1]})" if win else "  (whole run)"))
        print(f"   {'col':>3} {'role':34} {'pkts':>7} {'in tile':>7} {'dir':12} {'hops':14} {'PEs seen per pkt'}")
        rows = {}
        for col in sorted(per):
            s = per[col]
            role = roles.get(col, "runtime / memcpy")
            print(f"   {col:>3} {role:34} {s['pkts']:>7} {s['app_pkts']:>7} "
                  f"{str(dict(s['dir'].most_common(2))):12} {str(dict(s['span'].most_common(2))):14} "
                  f"{dict(sorted(s['pes_per_pkt'].items()))}")
            rows[col] = {"role": role, "packets": s["pkts"], "in_tile": s["app_pkts"],
                         "observations": s["obs"], "direction": dict(s["dir"]),
                         "hops": dict(s["span"]), "pes_per_packet": dict(s["pes_per_pkt"])}
        out[kernel] = {"window": win, "colours": rows}
    Path("results/datapath/gemm_dataflow.json").write_text(json.dumps(out, indent=1))
    print("\n  -> results/datapath/gemm_dataflow.json")

if __name__ == "__main__":
    main()
