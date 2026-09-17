#!/usr/bin/env python3
"""Per-link NoC occupancy model.

Joins three sources:
  * ELF routing tables (fabric_probe.py)  -- per PE, per colour: rx -> tx directions
  * CTF wavelet trace                     -- per event: tile_index and `fields`
  * measured silicon coefficients         -- hop / wavelet / turn costs

The join is `fields[4:0] == colour id`, verified against the compiler's routing
tables on 38/38 PEs with zero inconsistencies (6 bits fails on 30/38, which
bounds the field at 5).  Colour is what turns a per-PE wavelet count into a
per-LINK one: PE + colour -> the ELF's tx directions -> the specific link.

Why it matters: charging every wavelet in a kernel to one serial total predicted
161% of ParDot-Product's runtime -- parallel links billed as if sequential.
"""
from __future__ import annotations
import argparse, collections, gzip, json, os, sys

COLOUR_BITS = 5
COLOUR_MASK = (1 << COLOUR_BITS) - 1
FIXED, CYC_HOP, CYC_WAVE, CYC_TURN = 33.0, 2.000, 1.125, 20.0   # silicon
AXIS = {"EAST": "x", "WEST": "x", "NORTH": "y", "SOUTH": "y"}


def load_routes(fabric_json):
    """PE -> colour -> (rx, tx), plus the set of application PEs, from the compiler."""
    out, app = {}, set()
    for p, v in json.load(open(fabric_json))["pes"].items():
        x, y = (int(c) for c in p.split(","))
        out[(x, y)] = {int(c): (tuple(r["rx"]), tuple(r["tx"])) for c, r in v["routes"].items()}
        if v.get("role") == "application":
            app.add((x, y))
    return out, app


def iter_wavelets(trace, study):
    """Yield (tile_index, fields) from either a decoded .jsonl.gz or a raw CTF dir."""
    if os.path.isdir(trace):
        sys.path.insert(0, study)
        from wse3study.trace import CtfTraceReader
        for e in CtfTraceReader(trace).iter_events():
            if e.get("event_type") == "wavelet_trace_entry":
                yield e.get("tile_index"), e.get("fields")
    else:
        with gzip.open(trace, "rt") as fh:
            for line in fh:
                e = json.loads(line)
                if e.get("event_type") == "wavelet_trace_entry":
                    yield e.get("tile_index"), e.get("fields")


def analyse(trace, fabric_json, xsize, study, measured=None):
    routes, app_pes = load_routes(fabric_json)
    link = collections.Counter()      # (PE, tx direction) -> wavelets
    per_pe = collections.Counter()
    total = unattributed = 0
    for tile, fields in iter_wavelets(trace, study):
        if tile is None or not isinstance(fields, int):
            continue
        total += 1
        pe = (tile % xsize, tile // xsize)
        per_pe[pe] += 1
        colour = fields & COLOUR_MASK
        entry = routes.get(pe, {}).get(colour)
        if not entry:
            unattributed += 1
            continue
        _rx, tx = entry
        outs = [d for d in tx if d in AXIS]
        if not outs:                       # RAMP only: consumed locally, no link
            continue
        for d in outs:                     # a multicast occupies each link it drives
            link[(pe, d)] += 1

    # extent must span APPLICATION PEs only -- including memcpy support PEs
    # inflates the hop term with plumbing that carries no user traffic.
    xs = [p[0] for p in app_pes] or [0]; ys = [p[1] for p in app_pes] or [0]
    hops = (max(xs) - min(xs)) + (max(ys) - min(ys))
    turns = 0
    for pe, cs in routes.items():
        for c, (rx, tx) in cs.items():
            if c >= 21:
                continue
            a = [AXIS[d] for d in rx if d in AXIS]; b = [AXIS[d] for d in tx if d in AXIS]
            if a and b and any(i != j for i in a for j in b):
                turns += 1

    base = FIXED + CYC_HOP * hops + CYC_TURN * turns
    busiest_link = max(link.values()) if link else 0
    busiest_pe = max(per_pe.values()) if per_pe else 0
    return {
        "wavelets_total": total, "unattributed": unattributed,
        "distinct_links": len(link), "busiest_link": busiest_link,
        "busiest_pe": busiest_pe, "hops": hops, "turns": turns,
        "predict_sum": base + CYC_WAVE * total,
        "predict_pe": base + CYC_WAVE * busiest_pe,
        "predict_link": base + CYC_WAVE * busiest_link,
        "measured": measured,
        "top_links": [("%d,%d %s" % (p[0], p[1], d), n) for (p, d), n in link.most_common(5)],
    }


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("trace"); ap.add_argument("fabric_json")
    ap.add_argument("--xsize", type=int,
                    help="fabric width; defaults to fabric_dims[0] from the profile. "
                         "Getting this wrong silently mis-maps tile_index to PE "
                         "coordinates and most wavelets fail to attribute.")
    ap.add_argument("--measured", type=float)
    ap.add_argument("--study", default=os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    a = ap.parse_args()
    xsize = a.xsize or json.load(open(a.fabric_json))["fabric_dims"][0]
    r = analyse(a.trace, a.fabric_json, xsize, a.study, a.measured)
    print("fabric width %d (%s)" % (xsize, "given" if a.xsize else "from profile"))
    print("wavelets %d   unattributed %d (%.1f%%)   distinct links %d"
          % (r["wavelets_total"], r["unattributed"],
             100.0 * r["unattributed"] / max(r["wavelets_total"], 1), r["distinct_links"]))
    print("hops %d   turns %d   busiest PE %d   busiest LINK %d"
          % (r["hops"], r["turns"], r["busiest_pe"], r["busiest_link"]))
    print()
    m = r["measured"]
    for label, key in (("sum of all wavelets", "predict_sum"),
                       ("bottleneck PE", "predict_pe"),
                       ("bottleneck LINK", "predict_link")):
        share = ("%6.1f%% of measured" % (100.0 * r[key] / m)) if m else ""
        print("  %-22s %9.0f   %s" % (label, r[key], share))
    if m:
        print("  %-22s %9.0f" % ("measured", m))
    print()
    print("busiest links:", r["top_links"])


if __name__ == "__main__":
    sys.exit(main())
