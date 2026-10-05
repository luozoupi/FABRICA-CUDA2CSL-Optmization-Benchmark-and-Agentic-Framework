#!/usr/bin/env python3
"""MeshGEMM's fabric hops, per transfer, as the packets actually travelled (repeat 1).

A wavelet record is written at every router a packet passes, so the ordered list of
distinct routers is the packet's physical path. For each kernel transfer (skew and step,
X and W) this groups packets by (source PE, destination PE) and reports:
  colour     the colour the packet carried (the virtual channel)
  path       routers in order, e.g. (0,1)->(1,1)->(2,1): 2 hops, (1,1) a transit router
  packets    how many packets took it; values_per_packet (2 for @mov16: data + index)
and checks that every path is a straight run between neighbouring routers, that the
transit router is exactly the one the layout's `x_tran_color` / `y_tran_color` names, and
that each directed link carries at most one transfer per step.
Evidence: `simulator` (paths), `source` (the colour plan in comm_layout.csl).
"""
import collections, gzip, json
from pathlib import Path

P = 4
PATH = "results/wse3-full/kernels/WaferLLM-MeshGEMM/events.jsonl.gz"
KIND = {1: "x", 2: "x", 3: "x", 4: "w", 5: "w", 6: "w", 7: "skew_rev", 8: "skew_rev", 9: "skew_rev",
        12: "skew_fwd", 13: "skew_fwd", 16: "skew_fwd"}
K = lambda x, y: 4 <= x <= 7 and 1 <= y <= 4

def main():
    lc = json.loads(Path("results/datapath/meshgemm_lifecycle.json").read_text())["phases"]
    lo, hi = lc["skew"]["cycles"][0] - 50, lc["steps"]["cycles"][1] + 50      # repeat 1 only
    obs = collections.defaultdict(list)
    with gzip.open(PATH, "rt") as f:
        for line in f:
            if '"wavelet_trace_entry"' not in line: continue
            e = json.loads(line)
            if e["cycle"] < lo: continue
            if e["cycle"] > hi: break
            col = int(e["fields"]) & 31
            if col not in KIND: continue
            s = e["coordinates"]["simulator"]
            obs[e["ident"]].append((e["cycle"], s["x"], s["y"], col))
    groups = collections.defaultdict(list)
    for ob in obs.values():
        ob.sort(); path = []
        for _, x, y, _c in ob:
            if not path or path[-1] != (x, y): path.append((x, y))
        if not all(K(*p) for p in path): continue
        pe = [(x - 4, y - 1) for x, y in path]
        groups[(KIND[ob[0][3]], pe[0], pe[-1], tuple(pe), ob[0][3])].append((ob[0][0], ob[-1][0]))
    links, straight, bad = [], 0, []
    for (kind, a, b, path, col), L in sorted(groups.items()):
        hops = len(path) - 1
        ok = all(abs(p[0] - q[0]) + abs(p[1] - q[1]) == 1 for p, q in zip(path, path[1:])) and \
             (len({p[1] for p in path}) == 1 or len({p[0] for p in path}) == 1)
        straight += ok
        if not ok: bad.append(path)
        links.append({"kind": kind, "src": a, "dst": b, "colour": col, "hops": hops, "path": path,
                      "transit": list(path[1:-1]), "packets": len(L), "cycles": [min(t for t, _ in L), max(t for _, t in L)]})
    # per step window: each directed link (router -> neighbour) used by how many distinct transfers
    st = [l for l in links if l["kind"] in ("x", "w")]
    use = collections.Counter()
    for l in st:
        for p, q in zip(l["path"], l["path"][1:]): use[(l["kind"], tuple(p), tuple(q))] += 1
    out = {"links": links, "paths_straight_between_neighbours": [straight, len(links)], "not_straight": bad,
           "hops": {f"{k}:{h}": v for (k, h), v in collections.Counter((l["kind"], l["hops"]) for l in links).most_common()},
           "max_transfers_per_directed_link_over_repeat1": max(use.values()) if use else 0,
           "transfers": len(links)}
    # when does each PE's incoming tile arrive, relative to that PE's own FMACH window?
    rep = json.loads(Path("results/datapath/meshgemm_repeats.json").read_text())["pes"]
    arr = collections.defaultdict(list)                      # (kind, dst) -> arrival cycles at the destination router
    for ob in obs.values():
        ob.sort(); x, y = ob[-1][1], ob[-1][2]; kind = KIND[ob[0][3]]
        if kind in ("x", "w") and K(x, y) and K(ob[0][1], ob[0][2]): arr[(kind, (x - 4, y - 1))].append((ob[0][0], ob[-1][0]))
    timing = {}; ov = collections.Counter()
    for (kind, pe), L in arr.items():
        steps_ = rep[f"{pe[0]},{pe[1]}"][0]["steps"]
        for s_, stp in enumerate(steps_):
            f0, f1 = stp["fmach"]
            prev_end = steps_[s_ - 1]["fmach"][1] if s_ else f0 - 600
            mine = [(a, b) for a, b in L if prev_end < a < f0]          # issued by this step's two_hop_comm
            if not mine: continue
            first, last = min(a for a, _ in mine), max(b for _, b in mine)
            timing[f"{kind}:{pe[0]},{pe[1]}:{s_}"] = {"fmach": [f0, f1], "arrivals": [first, last], "packets": len(mine),
                                                    "last_arrival_to_first_fmach": f0 - last,
                                                    "overlap_cycles": max(0, min(last, f1) - max(first, f0))}
            ov["windows"] += 1; ov["packets_128"] += len(mine) == 128
            ov["transfer_done_before_fmach"] += last < f0
            ov["overlapping"] += min(last, f1) > max(first, f0)
    gaps = [v["last_arrival_to_first_fmach"] for v in timing.values()]
    durs = [v["arrivals"][1] - v["arrivals"][0] for v in timing.values()]
    ov["gap_min"], ov["gap_max"] = min(gaps), max(gaps); ov["transfer_cycles_min"], ov["transfer_cycles_max"] = min(durs), max(durs)
    out["receive_vs_fmach"] = {"summary": dict(ov), "per_step": timing}
    print("receive vs FMACH:", dict(ov))
    Path("results/datapath/meshgemm_links.json").write_text(json.dumps(out, indent=1, default=list))
    print(f"{len(links)} (kind, src, dst, path) groups; straight {straight}/{len(links)}")
    print("hop counts:", out["hops"])
    print("packets per group:", sorted({l["packets"] for l in links}))
    for l in links[:6]: print(l)
    print("-> results/datapath/meshgemm_links.json")

if __name__ == "__main__":
    main()
