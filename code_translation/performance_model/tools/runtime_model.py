#!/usr/bin/env python3
"""Whole-program runtime synthesis, testing the HPDC'24 model form on our traces.

Luczynski et al. (arXiv:2404.15888) predict a collective's cycles on WSE-2 as

    T = max(C, E/N + L) + (2*T_R + 1) * D

with C contention, E energy (element-hops), N links used, L distance, D depth
(store-and-forward stages), T_R ~ 2.  They hand-derive the terms per algorithm.
This tool measures every term FROM THE TRACE of an arbitrary kernel, adds the
compute roof W their model lacks (they charge 1 cyc/element; we have measured
per-instruction rates), and emits the components so a fitter can score

    T_pred = max(C, E/N + CYC_HOP*L, W) + k*D + c

against the measured span, with k fitted across the corpus and compared to
their k = 2*T_R + 1 = 5.

Term definitions (all per kernel, from one pass plus the wavelet grouping):
  C  max wavelets over one directed link (a link delivers 1 wavelet/cycle,
     so this is a hard floor -- their per-PE contention, at link resolution)
  E  total wavelet-hops        N  distinct directed links used
  L  longest per-ident path length (hops), CYC_HOP = 2 (silicon)
  D  longest relay chain: group g arrives at PE p, group g' is later injected
     at p -> edge g->g' (latest arrival before injection, the same conservative
     rule build_wavelet_groups uses).  This is causality INFERRED from timing
     and placement, and is labelled as such.
  W  busiest-PE compute cycles: per dispatch max(1, num_data * rate), rates
     from the measured single-PE model (f16 arith 0.25 cyc/elem, 16-bit moves
     0.125, 32-bit moves 0.25, everything else 1 -- issue width is 1/cycle).

Evidence: measured spans `simulator`; C/E/N/W `simulator`; L/D `inferred`.
"""

from __future__ import annotations

import argparse
import collections
import gzip
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

CYC_HOP = 2.0  # silicon-fitted; their model uses 1


def dispatch_cost(name: str, nd, ut_id=None) -> float:
    # An async DSD op (ut_id != 255) is issued once and runs on a microthread,
    # overlapping the main stream -- its data movement is the fabric terms' job.
    # Charging it elements*rate serialized the overlap and overpredicted W by
    # 17x on MeshGEMM; issue cost is one cycle.
    if ut_id is not None and ut_id != 255:
        return 1.0
    n = (name or "").upper()
    base = n.split(".")[0]
    nd = nd if isinstance(nd, int) and nd < 65535 else 1
    if base.startswith(("FMOV16", "IMOV16")):
        rate = 0.125
    elif base.startswith(("FMOV", "IMOV", "MOV")):
        rate = 0.25
    elif base[0] == "F" and base.endswith("H"):
        rate = 0.25          # f16 arithmetic, 4 elem/cyc measured
    elif base[0] == "F":
        rate = 1.0           # f32 arithmetic in this corpus is scalar-dispatched
    elif base.startswith(("ADD16", "AND16", "OR16", "XOR16", "SLL16", "SLR16")):
        rate = 0.25          # i16 DSD ops measured at ~4 elem/cyc
    else:
        rate = 1.0
    return max(1.0, nd * rate)


def analyze(events_path: Path) -> dict:
    wavelets = []
    work = collections.Counter()
    fp16 = collections.Counter()   # per-tile f16 arithmetic elements
    fp32 = collections.Counter()   # per-tile f32 arithmetic elements
    disp_count = collections.Counter()
    lo = hi = None
    with gzip.open(events_path, "rt") as fh:
        for line in fh:
            e = json.loads(line)
            t = e.get("event_type")
            if t == "hwm_dispatch_trace_entry":
                c = e["cycle"]
                lo = c if lo is None else min(lo, c)
                hi = c if hi is None else max(hi, c)
                tile = e.get("tile_index")
                nm = e.get("name") or ""
                nd = e.get("num_data")
                nd = nd if isinstance(nd, int) and nd < 65535 else 1
                work[tile] += dispatch_cost(nm, nd, e.get("ut_id"))
                disp_count[tile] += 1
                base = nm.upper().split(".")[0]
                if base.startswith("F") and not base.startswith("FMOV") and "2" not in base:
                    (fp16 if base.endswith("H") else fp32)[tile] += nd
            elif t == "wavelet_trace_entry":
                wavelets.append(e)

    measured = (hi - lo) if lo is not None else 0
    W = max(work.values()) if work else 0.0
    # Optimistic compute floor per PE: f16 arithmetic at the 4 elem/cyc peak, f32
    # at 1 elem/cyc (independent scalar issue).  The busiest PE's floor bounds T.
    lb_compute = max((fp16[t] / 4.0 + fp32[t] / 1.0 for t in set(fp16) | set(fp32)), default=0.0)
    hot = max(set(fp16) | set(fp32), key=lambda t: fp16[t] / 4.0 + fp32[t], default=None)

    H2D, D2H = {22, 23}, {21}
    def klass(col):
        return "in" if col in H2D else "out" if col in D2H else "comp"

    C = E = N = L = D = D_app = 0
    per = {k: {"C": 0, "E": 0, "N": 0, "L": 0} for k in ("in", "out", "comp")}
    groups = []
    if wavelets:
        from wse3study.trace import build_wavelet_groups
        import bisect
        groups = build_wavelet_groups(wavelets)

        link = collections.Counter()
        link_cls = {k: collections.Counter() for k in per}
        chain_len, chain_cls = {}, {}
        arrivals = collections.defaultdict(list)
        injections = []
        gclass = {}
        for gid, g in enumerate(groups):
            nodes = {n["node_id"]: n for n in g.get("nodes", [])}
            ns = sorted(g.get("nodes", []), key=lambda n: n["cycle"])
            if not ns:
                continue
            idx = ns[0].get("source_event_index")
            fld = wavelets[idx].get("fields") if isinstance(idx, int) and idx < len(wavelets) else None
            kc = klass((fld & 0x1F) if isinstance(fld, int) else -1)
            gclass[gid] = kc
            depth_in = collections.defaultdict(int)
            for e_ in g.get("edges", []):
                s_, d_ = e_["source"], e_["destination"]
                if e_.get("direction") != "LOCAL":
                    key = (nodes[s_].get("tile_id"), nodes[d_].get("tile_id"))
                    link[key] += 1
                    link_cls[kc][key] += 1
                depth_in[d_] = max(depth_in[d_], depth_in[s_] + (e_.get("direction") != "LOCAL"))
            chain_len[gid] = max(depth_in.values(), default=0)
            root = ns[0]
            injections.append((root["cycle"], root.get("tile_id"), gid))
            for n in ns:
                arrivals[n.get("tile_id")].append((n["cycle"], gid))

        C = max(link.values()) if link else 0
        E = sum(link.values()); N = len(link)
        L = max(chain_len.values(), default=0)
        for k in per:
            lc = link_cls[k]
            per[k]["C"] = max(lc.values()) if lc else 0
            per[k]["E"] = sum(lc.values()); per[k]["N"] = len(lc)
            per[k]["L"] = max((chain_len[g] for g in chain_len if gclass.get(g) == k), default=0)

        for pe in arrivals:
            arrivals[pe].sort()
        relay = collections.defaultdict(int)
        relay_app = collections.defaultdict(int)
        for cyc, pe, gid in sorted(injections):
            arr = arrivals.get(pe) or []
            i = bisect.bisect_left(arr, (cyc, -1)) - 1
            if i >= 0 and arr[i][1] != gid:
                prev = arr[i][1]
                relay[gid] = max(relay[gid], relay[prev] + 1)
                if gclass.get(gid) == "comp" and gclass.get(prev) == "comp":
                    relay_app[gid] = max(relay_app[gid], relay_app[prev] + 1)
        D = max(relay.values(), default=0)
        D_app = max(relay_app.values(), default=0)

    def fab(k):
        q = per[k]
        return round(q["E"] / q["N"] + CYC_HOP * q["L"], 1) if q["N"] else 0.0

    fabric_term = round(E / N + CYC_HOP * L, 1) if N else 0.0
    roof = max(C, fabric_term, W)
    lower_bound = max(C, fabric_term, lb_compute)
    return {"kernel": events_path.parent.name, "measured": measured,
            "C": C, "E": E, "N": N, "L": L, "D": D, "D_app": D_app, "W": round(W, 1),
            "wavelet_groups": len(groups),
            "hot_pe_dispatches": max(disp_count.values()) if disp_count else 0,
            "fabric_term": fabric_term, "roof": round(roof, 1),
            "C_in": per["in"]["C"], "fab_in": fab("in"),
            "C_out": per["out"]["C"], "fab_out": fab("out"),
            "C_comp": per["comp"]["C"], "fab_comp": fab("comp"),
            "fp16_elems_hot": fp16.get(hot, 0), "fp32_elems_hot": fp32.get(hot, 0),
            "lb_compute": round(lb_compute, 1),
            "lower_bound": round(lower_bound, 1),
            "pct_of_bound": round(100.0 * lower_bound / measured, 1) if measured else None}


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("events", help="decoded events.jsonl.gz")
    ap.add_argument("--json", help="write the component record here")
    a = ap.parse_args()
    r = analyze(Path(a.events))
    for k, v in r.items():
        print(f"  {k:<20} {v}")
    if a.json:
        Path(a.json).parent.mkdir(parents=True, exist_ok=True)
        Path(a.json).write_text(json.dumps(r, indent=1))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
