#!/usr/bin/env python3
"""Measure register data hazards by joining static operands to dynamic cycles.

Neither trace stream is sufficient alone, and the reason is structural:

  * `hwm_dispatch_trace_entry` has `cycle`, `inst_ptr` and `uid`, but no operands.
  * `hwm_pipe_trace_entry` has `stage`, `xcptn` and operand fields -- but those
    fields carry operand *values*, not register indices, so they cannot tell you
    which instruction produced an input.
  * The `elf2am` disassembly has exact register operands but no timing.

`uid` is unique per instruction instance within a PE, and `inst_ptr` equals the
`elf2am` PC exactly, so the three join cleanly: uid ties dispatch to pipe, and PC
ties both to the disassembly's registers.

WHAT IS MEASURED
  pipeline depth   stage 3 (decode) -> stage 6 (execute), per mnemonic
  issue gap        cycles between consecutive dispatches on one PE
  RAW distance     instructions back to the producer of this instruction's source
  hazard class     RAW / WAR / WAW against the preceding window

Evidence: `simulator`.  Stage 3 and 6 are Cerebras-documented as decode and
execute; everything else here is measured, and any stall model is reported with
its hit rate rather than asserted.
"""

from __future__ import annotations

import argparse
import collections
import gzip
import json
import re
from pathlib import Path

# Register tokens in the Cerebras assembly syntax: general (r0-15), data/FP
# (d0-15), predicate (cflag0-2), stack pointer, and the DSR files.
REG = re.compile(r"\b(sp|r\d+|d\d+|cflag\d+|accum\d+|dds\d+|s0ds\d+|s1ds\d+|xds\d+|lfsr\d+)\b")


def parse_operands(text: str) -> tuple[list[str], list[str]]:
    """Split one disassembled instruction into (destinations, sources).

    Handles the three shapes that appear: `op dst = src, src`, a predicated
    `cflagN ? op ...` (the predicate is a source), and store forms where the
    left side is a memory reference and any register in it is an address source.
    """
    text = text.strip()
    pred: list[str] = []
    if "?" in text:
        head, text = text.split("?", 1)
        pred = REG.findall(head)
    if "=" not in text:
        # No destination (jumps, barriers): every register mentioned is a source.
        return [], pred + REG.findall(text)
    lhs, rhs = text.split("=", 1)
    lhs_regs = REG.findall(lhs)
    if "[" in lhs:
        # `st32 sp[0x6] = d4` -- the left side is an address, not a written reg.
        return [], pred + lhs_regs + REG.findall(rhs)
    # Drop the mnemonic itself, which never matches REG, so lhs_regs is the dest.
    return lhs_regs, pred + REG.findall(rhs)


def load_disasm(path: Path) -> dict[int, dict]:
    rows = json.loads(path.read_text())
    rows = rows["records"] if isinstance(rows, dict) else rows
    out = {}
    for r in rows:
        text = r.get("instruction") or ""
        dst, src = parse_operands(text)
        out[r["pc"]] = {"text": text, "dest": dst, "srcs": src}
    return out


def load_trace(path: Path, tile: int | None):
    disp: dict[int, tuple] = {}
    stage3: dict[int, int] = {}
    stage6: dict[int, int] = {}
    xcptn: dict[int, int] = {}
    with gzip.open(path, "rt") as fh:
        for line in fh:
            e = json.loads(line)
            if tile is not None and e.get("tile_index") != tile:
                continue
            t = e.get("event_type")
            if t == "hwm_dispatch_trace_entry":
                disp[e["uid"]] = (e["cycle"], e.get("inst_ptr"), e.get("name"))
            elif t == "hwm_pipe_trace_entry":
                uid, c, st = e["uid"], e["cycle"], e.get("stage")
                if st == 3:
                    stage3[uid] = min(stage3.get(uid, c), c)
                elif st == 6:
                    stage6[uid] = min(stage6.get(uid, c), c)
                    x = e.get("xcptn")
                    if x not in (None, 255):
                        xcptn[uid] = x
    return disp, stage3, stage6, xcptn


def busiest_tile(path: Path) -> int:
    counts = collections.Counter()
    with gzip.open(path, "rt") as fh:
        for line in fh:
            e = json.loads(line)
            if e.get("event_type") == "hwm_dispatch_trace_entry":
                counts[e.get("tile_index")] += 1
    return counts.most_common(1)[0][0]


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("events", help="decoded events.jsonl.gz")
    ap.add_argument("disasm", help="csdisasm.py --json output for the PE's ELF")
    ap.add_argument("--tile", type=int, help="tile_index (default: busiest)")
    ap.add_argument("--window", type=int, nargs=2, metavar=("LO", "HI"),
                    help="restrict to this cycle range")
    ap.add_argument("--depth", type=int, default=8,
                    help="how many prior instructions to scan for hazards (default 8)")
    ap.add_argument("--json", help="write the full per-instruction table here")
    a = ap.parse_args()

    events = Path(a.events)
    tile = a.tile if a.tile is not None else busiest_tile(events)
    disasm = load_disasm(Path(a.disasm))
    disp, s3, s6, xcp = load_trace(events, tile)

    order = sorted(disp)
    if a.window:
        lo, hi = a.window
        order = [u for u in order if lo <= disp[u][0] <= hi]

    print(f"tile {tile}   instruction instances {len(order)}   "
          f"disassembled PCs {len(disasm)}")

    # ---- pipeline depth per mnemonic ---------------------------------------
    depth = collections.defaultdict(list)
    for uid in order:
        if uid in s3 and uid in s6:
            depth[disp[uid][2]].append(s6[uid] - s3[uid])
    print(f"\npipeline depth, stage 3 (decode) -> stage 6 (execute):")
    print(f"  {'mnemonic':<14}{'n':>8}{'mean':>8}{'min':>6}{'max':>6}")
    for name, v in sorted(depth.items(), key=lambda kv: -len(kv[1]))[:12]:
        print(f"  {name:<14}{len(v):>8}{sum(v)/len(v):>8.2f}{min(v):>6}{max(v):>6}")

    # ---- hazards ------------------------------------------------------------
    rows = []
    recent: collections.deque = collections.deque(maxlen=a.depth)
    prev_cycle = None
    for uid in order:
        cyc, pc, name = disp[uid]
        info = disasm.get(pc, {"dest": [], "srcs": [], "text": ""})
        raw_dist = None
        war = waw = False
        for back, (pdest, psrcs) in enumerate(reversed(recent), start=1):
            if raw_dist is None and any(s in pdest for s in info["srcs"]):
                raw_dist = back
            if any(d in psrcs for d in info["dest"]):
                war = True
            if any(d in pdest for d in info["dest"]):
                waw = True
        gap = None if prev_cycle is None else cyc - prev_cycle
        rows.append({"uid": uid, "cycle": cyc, "pc": pc, "mnemonic": name,
                     "text": info["text"], "gap": gap, "raw_distance": raw_dist,
                     "war": war, "waw": waw,
                     "decode": s3.get(uid), "execute": s6.get(uid),
                     "pipeline_depth": (s6[uid] - s3[uid]) if uid in s3 and uid in s6 else None,
                     "xcptn": xcp.get(uid)})
        recent.append((info["dest"], info["srcs"]))
        prev_cycle = cyc

    def gap_table(label, key):
        """Gap-vs-RAW-distance, scored.  `key` selects dispatch or execute time."""
        seq = sorted((r for r in rows if r[key] is not None), key=lambda r: r[key])
        table = collections.defaultdict(collections.Counter)
        prev = None
        for r in seq:
            if prev is not None:
                table[r["raw_distance"]][r[key] - prev] += 1
            prev = r[key]
        print(f"\n{label} vs RAW distance (distance = instructions back to the producer):")
        print(f"  {'RAW dist':<10}{'n':>8}  gap histogram")
        for d in sorted(table, key=lambda x: (x is None, x)):
            c = table[d]
            top = ", ".join(f"{g}cyc:{v}" for g, v in sorted(c.items(), key=lambda kv: -kv[1])[:5])
            print(f"  {str(d):<10}{sum(c.values()):>8}  {top}")
        modal = {d: table[d].most_common(1)[0][0] for d in table}
        hit = tot = 0
        prev = None
        for r in seq:
            if prev is not None:
                tot += 1
                hit += modal.get(r["raw_distance"]) == r[key] - prev
            prev = r[key]
        if tot:
            print(f"  modal-gap-per-RAW-distance model: {hit}/{tot} = {100*hit/tot:.1f}% exact")
            if hit / tot < 0.9:
                print("  -> below 90%: RAW distance alone does not determine this gap")
        return table

    # Dispatch runs ahead of execution and buffers, so the dispatch gap is a noisy
    # proxy.  Execute-to-execute is the cadence the dependency actually sets.
    gap_table("dispatch gap", "cycle")
    gap_table("EXECUTE gap", "execute")

    # The stall itself: an instruction waiting on an operand sits in the pipe, so
    # decode->execute grows with the hazard rather than staying at its baseline.
    fp_depth = collections.defaultdict(collections.Counter)
    for r in rows:
        if r["pipeline_depth"] is not None:
            fp_depth[r["raw_distance"]][r["pipeline_depth"]] += 1
    print("\npipeline depth (decode->execute) vs RAW distance -- this is the stall:")
    print(f"  {'RAW dist':<10}{'n':>8}{'mean':>7}  depth histogram")
    for d in sorted(fp_depth, key=lambda x: (x is None, x)):
        c = fp_depth[d]
        n = sum(c.values())
        mean = sum(k * v for k, v in c.items()) / n
        print(f"  {str(d):<10}{n:>8}{mean:>7.2f}  {dict(sorted(c.items()))}")

    fp = [r for r in rows if r["xcptn"] is not None]
    if fp:
        xn = collections.defaultdict(collections.Counter)
        for r in fp:
            xn[r["mnemonic"]][r["xcptn"]] += 1
        print("\nxcptn by mnemonic (stage 6):")
        for name, c in sorted(xn.items(), key=lambda kv: -sum(kv[1].values()))[:8]:
            print(f"  {name:<14}{dict(c)}")

    if a.json:
        Path(a.json).parent.mkdir(parents=True, exist_ok=True)
        Path(a.json).write_text(json.dumps(
            {"tile": tile, "instances": len(rows),
             "pipeline_depth_by_mnemonic": {k: {"n": len(v), "mean": sum(v)/len(v),
                                                "min": min(v), "max": max(v)}
                                            for k, v in depth.items()},
             "rows": rows}, indent=1))
        print(f"\nwrote {a.json}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
