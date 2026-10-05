#!/usr/bin/env python3
"""Decode a barectf CTF simulator trace into ``events.jsonl.gz``.

This is the bridge between the SDK simulator and every analysis tool in this
directory.  The simulator writes ``<out_dir>/simfab_traces/{metadata,stream0}``;
this reads the field layout out of ``metadata`` (no SDK import, no hard-coded
bit offsets) and emits one JSON object per event.

Each event carrying a ``tile_index`` also gets ``coordinates``, resolved through
the fabric width in ``global_simdata.json`` -- the tools downstream need (x, y),
and deriving the width here is what keeps a width-9 kernel from being read on a
width-11 grid.
"""

from __future__ import annotations

import argparse
import gzip
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from wse3study.trace import CtfTraceReader  # noqa: E402


def resolve_traces(target: Path) -> Path:
    """Accept either a compiled out_ dir or the simfab_traces dir itself."""
    if (target / "stream0").is_file():
        return target
    nested = target / "simfab_traces"
    if (nested / "stream0").is_file():
        return nested
    raise SystemExit(f"no CTF stream0 under {target} (looked in ./ and ./simfab_traces)")


def fabric_width(traces: Path) -> int | None:
    simdata = traces / "global_simdata.json"
    if not simdata.is_file():
        return None
    try:
        return int(json.loads(simdata.read_text())["xsize"])
    except (ValueError, KeyError, TypeError):
        return None


def main() -> int:
    ap = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("target", help="compiled out_ dir, or a simfab_traces dir")
    ap.add_argument("-o", "--out", required=True, help="destination events.jsonl.gz")
    ap.add_argument("--limit", type=int, help="stop after this many events")
    ap.add_argument("--quiet", action="store_true")
    a = ap.parse_args()

    traces = resolve_traces(Path(a.target).expanduser())
    width = fabric_width(traces)
    out = Path(a.out).expanduser()
    out.parent.mkdir(parents=True, exist_ok=True)

    reader = CtfTraceReader(traces)
    written = 0
    with gzip.open(out, "wt") as fh:
        for event in reader.iter_events():
            tile = event.get("tile_index")
            if tile is not None and width:
                event["coordinates"] = {"simulator": {
                    "x": tile % width, "y": tile // width, "evidence": "simulator"}}
            fh.write(json.dumps(event) + "\n")
            written += 1
            if a.limit and written >= a.limit:
                break

    if not a.quiet:
        print(f"source   {traces}")
        print(f"width    {width if width else 'UNKNOWN -- no coordinates attached'}")
        print(f"events   {written}")
        if reader.discarded_events_total:
            print(f"WARNING  CTF reports {reader.discarded_events_total} discarded events; "
                  f"this trace is incomplete")
        print(f"wrote    {out}  ({out.stat().st_size / 1e6:.1f} MB)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
