#!/usr/bin/env python3
"""Reverse-engineer the `fields` value of wavelet_trace_entry.

Ground truth: the compiler's own routing tables, read from the ELF via
fabric_probe.py.  For each PE we know exactly which colours are configured and
which directions each colour receives from and transmits to.  A candidate
decoding of `fields` is accepted only if it reproduces that.
"""
import sys, json, collections, os, argparse

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("traces")
    ap.add_argument("fabric_json")
    ap.add_argument("--study", default=os.path.expanduser("~/xkernel/studies/wse3-characterization"))
    a = ap.parse_args()
    sys.path.insert(0, a.study)
    from wse3study.trace import CtfTraceReader

    G = json.load(open(os.path.join(a.traces, "global_simdata.json")))
    X = G["xsize"]
    fab = json.load(open(a.fabric_json))["pes"]
    truth = {}
    for p, v in fab.items():
        x, y = (int(c) for c in p.split(","))
        truth[(x, y)] = {int(c): (tuple(r["rx"]), tuple(r["tx"])) for c, r in v["routes"].items()}

    per = collections.defaultdict(collections.Counter)
    for e in CtfTraceReader(a.traces).iter_events():
        if e.get("event_type") != "wavelet_trace_entry":
            continue
        t = e.get("tile_index")
        if t is None:
            continue
        per[(t % X, t // X)][e.get("fields")] += 1

    print("PE      top `fields` values            | colours configured in the ELF")
    for k in sorted(per)[:12]:
        fv = sorted(per[k], key=lambda z: -per[k][z])[:4]
        fs = " ".join("0x%04x" % v for v in fv)
        tr = truth.get(k, {})
        parts = []
        for c, (rx, tx) in sorted(tr.items()):
            if c >= 21:
                continue
            parts.append("c%d:%s>%s" % (c, "|".join(rx) or "-", "|".join(tx) or "-"))
        print("%-7s %-32s | %s" % ("%d,%d" % k, fs, " ".join(parts)[:58]))

    # Does the SET of fields values at a PE correlate with its colour count?
    print()
    print("correlation test: distinct `fields` values vs configured user colours")
    rows = []
    for k in sorted(per):
        ncols = len([c for c in truth.get(k, {}) if c < 21])
        rows.append((k, len(per[k]), ncols))
    for k, nf, nc in rows[:12]:
        print("  PE %-7s distinct_fields=%-3d user_colours=%d" % ("%d,%d" % k, nf, nc))
    same = sum(1 for _, nf, nc in rows if nf == nc)
    print("  PEs where distinct_fields == user_colours: %d/%d" % (same, len(rows)))

    # bit-level view of the observed values
    allv = sorted({v for c in per.values() for v in c})
    print()
    print("all %d distinct `fields` values:" % len(allv))
    for v in allv[:20]:
        print("   0x%08x  %s" % (v, format(v, "032b")))
    if len(allv) > 20:
        print("   ... %d more" % (len(allv) - 20))
    fixed_ones = allv[0]; fixed_zero = ~allv[0] & 0xFFFFFFFF
    for v in allv[1:]:
        fixed_ones &= v; fixed_zero &= ~v & 0xFFFFFFFF
    varying = 32 - bin(fixed_ones | fixed_zero).count("1")
    print("   always-1 bits: 0x%08x   always-0 mask: 0x%08x   varying bits: %d"
          % (fixed_ones, ~fixed_zero & 0xFFFFFFFF, varying))

if __name__ == "__main__":
    sys.exit(main())

def verify_colour_hypothesis(per, truth, nbits=5):
    """Hypothesis: fields[nbits-1:0] encodes the colour id."""
    mask = (1 << nbits) - 1
    ok = bad = 0; misses = []
    for pe, counter in per.items():
        cols = set(truth.get(pe, {}))
        if not cols:
            continue
        obs = {v & mask for v in counter}
        exp = {c & mask for c in cols}
        if obs <= exp:
            ok += 1
        else:
            bad += 1
            misses.append((pe, sorted(obs - exp), sorted(cols)))
    return ok, bad, misses
