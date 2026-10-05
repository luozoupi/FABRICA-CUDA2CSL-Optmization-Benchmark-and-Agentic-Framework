#!/usr/bin/env python3
"""Measure FP dependent-op latency and issue width from the ILP microbench trace.

Every variant issues the same 8 scalar FP multiply-adds per iteration; only the
dependency-chain depth differs.  Cycles per FP op then separates the two things
a single timing cannot:

  * chain-limited variants cost  depth * latency  per iteration
  * independent variants cost    instructions / issue_width

Only the application PE is counted.  The 23 `<memcpy>` infrastructure PEs run
their own programs at overlapping instruction addresses, so an unfiltered trace
mixes their dispatches into the loop's PC window and corrupts both the
instruction count and the cycle span.
"""

import argparse
import collections
import gzip
import json

# (first PC in loop body, back-edge PC) per variant, from tools/csdisasm.py.
LOOPS = [("k1", 8, 0x160, 0x184), ("k2", 4, 0x1cc, 0x1f0),
         ("k4", 2, 0x244, 0x268), ("k8", 1, 0x2dc, 0x31e)]
FP = {"FMULS", "FADDS"}
SPILL = {"ST32", "LD16RP"}


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("events", help="decoded events.jsonl.gz")
    ap.add_argument("--iters", type=int, default=512)
    ap.add_argument("--tile", type=int,
                    help="application tile_index (default: the tile issuing FMULS)")
    ap.add_argument("--json", help="write results here")
    a = ap.parse_args()

    rows = []
    fp_tiles = collections.Counter()
    for line in gzip.open(a.events, "rt"):
        e = json.loads(line)
        if e.get("event_type") != "hwm_dispatch_trace_entry":
            continue
        if e.get("name") in FP:
            fp_tiles[e["tile_index"]] += 1
        rows.append((e["cycle"], e["tile_index"], e.get("inst_ptr"), e.get("name")))

    tile = a.tile if a.tile is not None else fp_tiles.most_common(1)[0][0]
    rows = sorted(r for r in rows if r[1] == tile)
    print(f"application PE tile_index={tile}  "
          f"({fp_tiles[tile]} FP dispatches, {len(fp_tiles)} tile(s) issue FP)\n")

    print(f"{'variant':<9}{'depth':>6}{'inst/it':>9}{'cyc/it':>9}"
          f"{'cyc/inst':>10}{'cyc/FP-op':>11}{'spill/it':>10}{'1-cyc gaps':>12}")
    out = []
    for name, depth, lo, hi in LOOPS:
        body = [r for r in rows if lo <= r[2] <= hi]
        if not body:
            print(f"{name:<9} no dispatches in {hex(lo)}..{hex(hi)}")
            continue
        span = body[-1][0] - body[0][0]
        n = len(body)
        fp = sum(1 for r in body if r[3] in FP)
        sp = sum(1 for r in body if r[3] in SPILL)
        one = sum(1 for x, b in zip(body, body[1:]) if b[0] - x[0] == 1)
        one_pct = 100.0 * one / max(1, len(body) - 1)
        rec = {"variant": name, "chain_depth": depth, "dispatches": n,
               "inst_per_iter": round(n / a.iters, 2),
               "cycles_per_iter": round(span / a.iters, 2),
               "cycles_per_inst": round(span / n, 3),
               "cycles_per_fp_op": round(span / fp, 3),
               "pct_gaps_1_cycle": round(one_pct, 1),
               "spills_per_iter": round(sp / a.iters, 2)}
        out.append(rec)
        print(f"{name:<9}{depth:>6}{n / a.iters:>9.1f}{span / a.iters:>9.2f}"
              f"{span / n:>10.3f}{span / fp:>11.3f}{sp / a.iters:>10.1f}"
              f"{one_pct:>11.0f}%")

    # NOTE: do not divide cycles/iter by the *intended* chain depth.  The
    # scheduler reorders freely -- the k2 body ships as two long runs rather than
    # an interleave -- so the achieved depth is not the requested one, and a
    # per-dependent-step latency computed from `depth` is meaningless.
    #
    # A per-edge rule ("dependent pair costs 2 cycles, independent costs 1") was
    # tested against the register dependencies in the disassembly and REFUTED:
    # it predicts only 15 of 30 observed gaps.  Independent pairs are seen at 2
    # cycles and dependent pairs at 1.  What the data does support is aggregate:
    # issue never exceeds 1 instruction/cycle, and cycles/instruction falls
    # monotonically as ILP rises.  Explaining individual gaps needs the `stage`
    # field of hwm_pipe_trace_entry, which this probe does not yet read.

    print("\nissue-interval histogram (gap in cycles between consecutive dispatches):")
    for name, depth, lo, hi in LOOPS:
        body = [r for r in rows if lo <= r[2] <= hi]
        if len(body) < 3:
            continue
        d = collections.Counter(b[0] - x[0] for x, b in zip(body, body[1:]))
        tot = sum(d.values())
        top = "  ".join(f"{k}cyc:{100 * v / tot:.0f}%" for k, v in sorted(d.items())[:4])
        print(f"  {name:<4} {top}")

    if a.json:
        with open(a.json, "w", encoding="utf-8") as fh:
            json.dump({"tile_index": tile, "iters": a.iters, "variants": out}, fh, indent=1)
        print(f"\nwrote {a.json}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
