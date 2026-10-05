#!/usr/bin/env python3
"""Convert a decoded WSE trace into a Perfetto-openable Chrome JSON trace.

Perfetto's importer does NOT read CTF/barectf/LTTng, so `simfab_traces/` cannot be
opened directly.  It does read the Chrome (Catapult) JSON Trace Event Format, which
is what this emits.  Load the output at https://ui.perfetto.dev (processing is
client-side; nothing is uploaded to a server).

TIME UNITS.  Chrome JSON `ts`/`dur` are microseconds, and Perfetto labels them as
such.  This tool maps **one cycle to one microsecond**, so every duration the UI
shows as "N us" is really N cycles.  There is no scaling factor to undo.

WHAT YOU GET
  * one Perfetto "process" per PE, named `PE (x,y)`, laid out by fabric coordinate
  * a `tasks` track per PE: consecutive dispatches sharing a task_color, merged
  * an `instructions` track per PE (--detail only): one slice per dispatch
  * a `dispatches` counter per PE: issue rate, binned
  * flow arrows between PEs for wavelet hops (--flows)

EVIDENCE.  Dispatch slices and cycle values are `simulator`.  Flow arrows are
`inferred`: path membership comes from `build_wavelet_groups`, which pairs
observations by ident plus cardinal adjacency and does not decode a router field.
Every flow arrow carries that tag in its args, and ambiguous predecessors are
marked, because a wavelet with several equally-recent candidates is a multicast
that this pairing cannot disambiguate.

SCALE.  A per-instruction trace of a large kernel is enormous (MeshGEMM is 8.3M
events).  Aggregated mode is the default; use --detail with --window/--pes to zoom.
Emission stops at --max-slices and reports what was dropped rather than silently
truncating.
"""

from __future__ import annotations

import argparse
import collections
import gzip
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

DISPATCH = "hwm_dispatch_trace_entry"
WAVELET = "wavelet_trace_entry"


def _coord(event):
    sim = (event.get("coordinates") or {}).get("simulator") or {}
    x, y = sim.get("x"), sim.get("y")
    return (x, y) if x is not None and y is not None else None


class PeTracks:
    """Assign a Perfetto pid per PE and emit the naming metadata."""

    def __init__(self):
        self._pid = {}
        self.meta = []

    def pid(self, tile, coord):
        if tile in self._pid:
            return self._pid[tile]
        pid = len(self._pid) + 1
        self._pid[tile] = pid
        label = f"PE ({coord[0]},{coord[1]})" if coord else f"tile {tile}"
        # Sort key keeps the UI's track order equal to fabric row-major order, so
        # the process list reads as the physical layout rather than arrival order.
        self.meta.append({"name": "process_name", "ph": "M", "pid": pid, "tid": 0,
                          "args": {"name": label}})
        self.meta.append({"name": "process_sort_index", "ph": "M", "pid": pid, "tid": 0,
                          "args": {"sort_index": tile}})
        return pid

    def __len__(self):
        return len(self._pid)


def iter_events(path, window, pes):
    lo, hi = window if window else (None, None)
    with gzip.open(path, "rt") as fh:
        for line in fh:
            e = json.loads(line)
            c = e.get("cycle")
            if c is None:
                continue
            if lo is not None and not (lo <= c <= hi):
                continue
            if pes and e.get("tile_index") not in pes:
                continue
            yield e


def build(args):
    tracks = PeTracks()
    out = []
    dropped = collections.Counter()

    # ---- pass 1: dispatches, grouped per PE ---------------------------------
    per_pe = collections.defaultdict(list)
    wavelets = []
    coords = {}
    # Single pass: these traces reach 8.3M lines, so coordinates are collected
    # alongside the dispatches rather than by re-reading the file.
    for e in iter_events(args.events, args.window, args.pes):
        tile = e.get("tile_index")
        if tile is not None and tile not in coords:
            c = _coord(e)
            if c:
                coords[tile] = c
        t = e.get("event_type")
        if t == DISPATCH:
            per_pe[tile].append(
                (e["cycle"], e.get("name"), e.get("task_color"), e.get("inst_ptr"),
                 e.get("num_data"), e.get("ut_id")))
        elif t == WAVELET and args.flows:
            wavelets.append(e)

    slices = 0
    for tile in sorted(per_pe):
        rows = sorted(per_pe[tile])
        pid = tracks.pid(tile, coords.get(tile))
        out.append({"name": "thread_name", "ph": "M", "pid": pid, "tid": 1,
                    "args": {"name": "tasks"}})

        # --- merged task_color runs -----------------------------------------
        run_start, run_color, run_n = None, None, 0
        for i, (cyc, name, color, *_rest) in enumerate(rows):
            if color != run_color:
                if run_start is not None:
                    if slices >= args.max_slices:
                        dropped["task_slices"] += 1
                    else:
                        out.append({"name": f"color {run_color}", "ph": "X", "cat": "task",
                                    "ts": run_start, "dur": max(cyc - run_start, 1),
                                    "pid": pid, "tid": 1,
                                    "args": {"task_color": run_color,
                                             "dispatches": run_n,
                                             "cycles": cyc - run_start,
                                             "evidence": "simulator"}})
                        slices += 1
                run_start, run_color, run_n = cyc, color, 0
            run_n += 1
        if run_start is not None and slices < args.max_slices:
            end = rows[-1][0]
            out.append({"name": f"color {run_color}", "ph": "X", "cat": "task",
                        "ts": run_start, "dur": max(end - run_start, 1),
                        "pid": pid, "tid": 1,
                        "args": {"task_color": run_color, "dispatches": run_n,
                                 "cycles": end - run_start, "evidence": "simulator"}})
            slices += 1

        # --- per-instruction slices -----------------------------------------
        if args.detail:
            out.append({"name": "thread_name", "ph": "M", "pid": pid, "tid": 2,
                        "args": {"name": "instructions"}})
            for i, (cyc, name, color, ptr, nd, ut) in enumerate(rows):
                if slices >= args.max_slices:
                    dropped["instruction_slices"] += 1
                    continue
                nxt = rows[i + 1][0] if i + 1 < len(rows) else cyc + 1
                out.append({"name": name or "?", "ph": "X", "cat": "instruction",
                            "ts": cyc, "dur": max(nxt - cyc, 1), "pid": pid, "tid": 2,
                            "args": {"pc": hex(ptr) if ptr is not None else None,
                                     "elements": nd, "ut_id": ut, "task_color": color,
                                     "evidence": "simulator"}})
                slices += 1

        # --- issue-rate counter ---------------------------------------------
        if args.bin:
            bins = collections.Counter(c // args.bin for c, *_ in rows)
            for b in sorted(bins):
                out.append({"name": "dispatches", "ph": "C", "ts": b * args.bin,
                            "pid": pid, "tid": 0,
                            "args": {"per_%d_cyc" % args.bin: bins[b]}})

    # ---- flows -------------------------------------------------------------
    flows = 0
    if args.flows and wavelets:
        from wse3study.trace import build_wavelet_groups
        groups = build_wavelet_groups(wavelets)
        node_by_id = {}
        for g in groups:
            for n in g.get("nodes", []):
                node_by_id[n["node_id"]] = n
        fid = 0
        for g in groups:
            for edge in g.get("edges", []):
                if edge.get("direction") == "LOCAL":
                    continue  # same PE: no arrow to draw
                src = node_by_id.get(edge["source"])
                dst = node_by_id.get(edge["destination"])
                if not src or not dst or src.get("tile_id") is None or dst.get("tile_id") is None:
                    continue
                if flows >= args.max_flows:
                    dropped["flows"] += 1
                    continue
                spid = tracks.pid(src["tile_id"], _coord(src))
                dpid = tracks.pid(dst["tile_id"], _coord(dst))
                fid += 1
                common = {"cat": "wavelet", "name": f"{edge['direction']}",
                          "id": fid,
                          "args": {"direction": edge["direction"],
                                   "delay_cycles": edge["delay_cycles"],
                                   "ambiguous_predecessor": edge.get("ambiguous_predecessor"),
                                   "direction_evidence": edge.get("direction_evidence"),
                                   "evidence": edge.get("evidence", "inferred")}}
                out.append({**common, "ph": "s", "ts": src["cycle"], "pid": spid, "tid": 1})
                out.append({**common, "ph": "f", "bp": "e", "ts": dst["cycle"],
                            "pid": dpid, "tid": 1})
                flows += 1

    return tracks, out, slices, flows, dropped


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("events", help="decoded events.jsonl.gz")
    ap.add_argument("-o", "--out", required=True, help="destination .json")
    ap.add_argument("--detail", action="store_true",
                    help="one slice per dispatched instruction (large; pair with --window)")
    ap.add_argument("--window", nargs=2, type=int, metavar=("LO", "HI"),
                    help="restrict to this cycle range")
    ap.add_argument("--pes", type=int, nargs="+", help="restrict to these tile_index values")
    ap.add_argument("--flows", action="store_true",
                    help="emit wavelet hop arrows between PEs (inferred; needs memory)")
    ap.add_argument("--bin", type=int, default=100,
                    help="counter bin width in cycles; 0 disables (default 100)")
    ap.add_argument("--max-slices", type=int, default=400_000)
    ap.add_argument("--max-flows", type=int, default=50_000)
    a = ap.parse_args()

    tracks, events, slices, flows, dropped = build(a)
    doc = {"traceEvents": tracks.meta + events,
           "displayTimeUnit": "ns",
           "otherData": {
               "source": str(a.events),
               "time_unit_note": "ts/dur are CYCLES emitted as microseconds; 1 cycle = 1 us",
               "flow_evidence": "inferred (ident + cardinal adjacency)",
               "slice_evidence": "simulator"}}

    out = Path(a.out).expanduser()
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(doc))

    print(f"PEs        {len(tracks)}")
    print(f"slices     {slices}")
    print(f"flows      {flows}")
    if dropped:
        print("DROPPED    " + ", ".join(f"{v} {k}" for k, v in dropped.items())
              + "  -- raise --max-slices/--max-flows or narrow --window")
    print(f"wrote      {out}  ({out.stat().st_size / 1e6:.1f} MB)")
    print("open at https://ui.perfetto.dev  (durations shown as 'us' are CYCLES)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
