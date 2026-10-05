#!/usr/bin/env python3
"""Audit the wavelet pairing that drives the mesh viewers.

ARCHITECTURE_MODEL_PLAN.md is explicit on three risks the viewers must not paper
over:

  * "Multicast needs branching paths, including transit PEs."
  * "Packet identities apply within their capture; active relays create new
     identities that require an explicit dataflow binding."
  * "Equal numbers alone cannot establish lineage."

tools/mesh3d_extract.py builds ONE LINEAR CHAIN per ident: observations sorted by
cycle, repeats at a PE collapsed, and the whole ident discarded if any consecutive
pair is not cardinally adjacent. That is a modelling choice, not a measurement.
This tool measures what it costs, per capture, without changing anything:

  linear      the cycle-ordered observations form a simple cardinal path
  branching   some PE has two or more cardinal successors -> a multicast tree the
              linear model would render as one arbitrary strand
  ambiguous   a step has more than one equally-recent cardinal predecessor
  broken      a consecutive pair is not cardinally adjacent at all
  solo        one observation, no path

Evidence: `simulator`. The classification itself is `inferred` -- it rests on the
same ident-plus-adjacency rule it is auditing, so it bounds that rule's damage
rather than validating it independently.
"""
from __future__ import annotations
import argparse, collections, gzip, json
from pathlib import Path

def load(path, width=None):
    obs = collections.defaultdict(list)
    with gzip.open(path, "rt") as f:
        for line in f:
            if '"wavelet_trace_entry"' not in line:
                continue
            e = json.loads(line)
            sim = (e.get("coordinates") or {}).get("simulator")
            if sim:
                xy = (int(sim["x"]), int(sim["y"]))
            elif width:
                t = e["tile_index"]; xy = (t % width, t // width)
            else:
                continue
            obs[int(e["ident"])].append((int(e["cycle"]), xy, int(e.get("fields") or 0)))
    return obs

def card(a, b):
    return abs(a[0]-b[0]) + abs(a[1]-b[1]) == 1

def classify(ob):
    ob = sorted(ob)
    pts, prev = [], None
    for c, xy, _ in ob:
        if xy == prev:
            continue
        pts.append((c, xy)); prev = xy
    if len(pts) < 2:
        return "solo", 0, 0
    # successors per PE under the linear reading
    succ = collections.defaultdict(set)
    broken = 0
    for (c0, a), (c1, b) in zip(pts, pts[1:]):
        if card(a, b):
            succ[a].add(b)
        else:
            broken += 1
    if broken:
        return "broken", broken, 0
    # branching: a PE with 2+ distinct cardinal successors
    fan = sum(1 for a, s in succ.items() if len(s) > 1)
    if fan:
        return "branching", 0, fan
    # ambiguity: for each step, how many earlier-or-equal observations are cardinal
    amb = 0
    for i in range(1, len(pts)):
        ci, b = pts[i]
        cands = [j for j in range(i) if card(pts[j][1], b) and pts[j][0] <= ci]
        if len(cands) > 1:
            best = max(pts[j][0] for j in cands)
            if sum(1 for j in cands if pts[j][0] == best) > 1:
                amb += 1
    return ("ambiguous" if amb else "linear"), 0, amb

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("-o", "--out", default="results/datapath/lineage_audit.json")
    a = ap.parse_args()
    CAPS = [
        ("relay",         "microbench/relay/events_n1b8.jsonl.gz", 16),
        ("relay_compute", "microbench/relay_compute/events.jsonl.gz", 16),
        ("single_pe",     "microbench/atomic_ops/events.jsonl.gz", 8),
        ("meshgemv",      "results/wse3-full/kernels/WaferLLM-MeshGEMV/events.jsonl.gz", 11),
        ("meshgemm_full", "results/wse3-full/kernels/WaferLLM-MeshGEMM/events.jsonl.gz", 11),
    ]
    out = {}
    for name, rel, w in CAPS:
        p = Path(rel)
        if not p.exists():
            print(f"  skip {name}"); continue
        obs = load(p, w)
        kinds = collections.Counter(); fanout = collections.Counter(); reuse = collections.Counter()
        origins = collections.Counter()
        for ident, ob in obs.items():
            k, br, fan = classify(ob)
            kinds[k] += 1
            if k == "branching":
                fanout[fan] += 1
            # an ident seen at the same PE more than once with a cycle gap:
            per = collections.Counter(xy for _, xy, _ in ob)
            if any(v > 1 for v in per.values()):
                reuse["repeat_at_a_PE"] += 1
            o0 = sorted(ob)[0]
            origins[(o0[0], o0[1])] += 1
        n = sum(kinds.values())
        shared_origin = sum(1 for v in origins.values() if v > 1)
        out[name] = {"source": rel, "idents": n, "classes": dict(kinds),
                     "branch_fanout_pes": dict(fanout),
                     "idents_with_repeat_observation": reuse.get("repeat_at_a_PE", 0),
                     "distinct_origins": len(origins),
                     "origins_shared_by_multiple_idents": shared_origin}
        pct = lambda k: 100.0 * kinds[k] / n if n else 0
        print(f"  {name:14s} idents={n:7d}  linear={pct('linear'):5.1f}%  "
              f"branching={pct('branching'):5.1f}%  ambiguous={pct('ambiguous'):5.1f}%  "
              f"broken={pct('broken'):5.1f}%  solo={pct('solo'):4.1f}%  "
              f"shared-origin idents={shared_origin}")
    o = Path(a.out); o.parent.mkdir(parents=True, exist_ok=True)
    o.write_text(json.dumps(out, indent=1))
    print(f"\n  -> {o}")

if __name__ == "__main__":
    main()
