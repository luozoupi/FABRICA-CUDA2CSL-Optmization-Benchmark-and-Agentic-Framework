#!/usr/bin/env python3
"""Build cached 3-D mesh scenes from the study's decoded traces."""
from __future__ import annotations

import argparse
import base64
import json
import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from mesh3d_extract import extract

STUDY = Path(__file__).resolve().parent.parent

# name, title, events path, mesh width, window, blurb
SCENES = [
    ("relay", "One message crosses one link",
     "microbench/relay/events_n1b8.jsonl.gz", 16, None,
     "N=1, B=8. The smallest possible dataflow: PE (4,1) sends eight 32-bit words "
     "to PE (5,1). Everything else on the fabric is the memcpy runtime."),
    ("relay_compute", "Send, then compute on what arrived",
     "microbench/relay_compute/events.jsonl.gz", 16, None,
     "The receiver does arithmetic on the delivered block, so the fabric hop and "
     "the pipeline that consumes it appear in the same timeline."),
    ("single_pe", "One PE running the basic ISA",
     "microbench/atomic_ops/events.jsonl.gz", 8, None,
     "The 22 atomic instruction forms on a single application PE. The surrounding "
     "traffic is entirely memcpy plumbing: this is the 23:1 PE overhead, drawn."),
    ("meshgemv", "MeshGEMV on a 4x4 application tile",
     "results/wse3-full/kernels/WaferLLM-MeshGEMV/events.jsonl.gz", 11, None,
     "WaferLLM's matrix-vector kernel. Thousands of independent point-to-point "
     "packets share the same compiled routes into the tile, the FMACH column "
     "reduces, and results walk back west. Whole run."),
    ("meshgemm", "MeshGEMM, one steady-state window",
     "results/wse3-full/kernels/WaferLLM-MeshGEMM/events.jsonl.gz", 11, (70000, 82000),
     "WaferLLM's matrix-matrix kernel, 12,000 cycles of the steady state. Three "
     "FMACH phases, two bursts of fabric traffic, and one stretch of pure compute with no "
     "fabric traffic at all -- the contrast the whole-run view averages away."),
    ("meshgemm_full", "MeshGEMM, the whole run",
     "results/wse3-full/kernels/WaferLLM-MeshGEMM/events.jsonl.gz", 11, None,
     "All 122,741 cycles. Setup and teardown use a wider PE footprint than the "
     "4x4 compute tile, and the long quiet stretch near cycle 36,000-60,000 is "
     "five PEs of the memcpy runtime, not the kernel."),
]


FABRIC_DIMS = {"relay": (16, 3), "relay_compute": (16, 3), "single_pe": (8, 3),
               "meshgemv": (11, 6), "meshgemm": (11, 6), "meshgemm_full": (11, 6)}


def role_map(kernel):
    p = STUDY / "results" / "fabric-profiles" / f"{kernel}.json"
    if not p.exists():
        return {}
    d = json.loads(p.read_text())
    out = {}
    for pe, v in d["pes"].items():
        x, y = (int(c) for c in pe.split(","))
        out[(x, y)] = v.get("role")
    return out


def build(name, title, rel, width, window, blurb, nbins, max_waves):
    src = STUDY / rel
    if not src.exists():
        print(f"  skip {name}: {rel} missing")
        return None
    print(f"  {name}: reading {rel} ...", flush=True)
    e = extract(src, width=width, window=window, nbins=nbins, max_waves=max_waves)
    roles = {}
    if "WaferLLM-" in rel:
        roles = role_map(rel.split("/")[-2])

    pes = e["pes"]
    xs = [p[0] for p in pes] or [0]
    ys = [p[1] for p in pes] or [0]
    pel = []
    for p in pes:
        d = e["disp"][p]
        n = e["stall_n"][p]
        pel.append({
            "x": p[0], "y": p[1],
            "disp": d, "fp": e["fp"][p], "wav": e["wav_at"][p],
            "elem": e["elems"][p],
            "stall": round(e["stall_sum"][p] / n, 2) if n else None,
            "role": roles.get(p) or ("application" if e["fp"][p] else "support"),
            "top": [[k, v] for k, v in e["mix"][p].most_common(8)],
            "bin": e["binned"][p] if d else [],
            "fpbin": e["fpbin"][p] if e["fp"][p] else [],
        })
    # Fine bins ship as one base64 Uint8 block, PE-major. Counts are per
    # fstride cycles and an issue rate of 1/cycle caps them well under 255.
    fnb = e["fnb"]
    flat = bytearray()
    for p in pes:
        row = e["fine"].get(p)
        if row is None:
            flat.extend(b"\x00" * fnb)
        else:
            flat.extend(bytes(255 if v > 255 else v for v in row))
    fine_b64 = base64.b64encode(bytes(flat)).decode("ascii")

    links = [[a[0], a[1], b[0], b[1], n] for (a, b), n in
             sorted(e["links"].items(), key=lambda kv: -kv[1])]
    return {
        "name": name, "title": title, "blurb": blurb, "source": rel,
        "dims": list(FABRIC_DIMS.get(name, (max(xs) + 1, max(ys) + 1))),
        "cycles": e["cycles"], "stride": e["stride"], "nb": e["nb"],
        "fstride": e["fstride"], "fnb": fnb, "fine": fine_b64,
        "window": list(window) if window else None,
        "pes": pel, "links": links,
        "templates": e["templates"], "waves": e["waves"],
        "counts": e["counts"],
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("-o", "--out", default=str(STUDY / "results/mesh3d/scenes"))
    ap.add_argument("--only", nargs="*")
    ap.add_argument("--nbins", type=int, default=200)
    ap.add_argument("--max-waves", type=int, default=90000)
    a = ap.parse_args()
    out = Path(a.out)
    out.mkdir(parents=True, exist_ok=True)
    for spec in SCENES:
        if a.only and spec[0] not in a.only:
            continue
        s = build(*spec, nbins=a.nbins, max_waves=a.max_waves)
        if s is None:
            continue
        f = out / f"{spec[0]}.json"
        f.write_text(json.dumps(s, separators=(",", ":")))
        c = s["counts"]
        print(f"    -> {f.name}  {f.stat().st_size/1e6:.2f} MB  "
              f"PEs={len(s['pes'])} cycles={s['cycles'][0]}..{s['cycles'][1]} "
              f"templates={c['templates']} waves={c['waves_kept']} "
              f"(1 in {c['wave_decimation']})  fine: {s['fnb']} bins "
              f"@ {s['fstride']} cyc")


if __name__ == "__main__":
    main()
