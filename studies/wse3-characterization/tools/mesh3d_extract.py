#!/usr/bin/env python3
"""Condense a decoded WSE-3 trace into a compact 3-D mesh scene.

The animation needs three things the raw trace has, but not in a shape a browser
can hold: where each PE is, what it was doing at cycle C, and which wavelets were
in flight on which link at cycle C.

Size is solved by a route-template dedup.  MeshGEMM emits 543,122 wavelet
observations under 197,909 idents -- but only **170 distinct
(path, relative-hop-timing) pairs**.  Each wavelet is therefore stored as
(template_id, launch_cycle, colour): three small integers, and the page
reconstructs exact per-hop positions from the template.

Evidence, carried through to the page:
  * PE coordinates, cycles, dispatch counts, wavelet observations -- `simulator`
  * a wavelet's *path membership* (which observations belong to one packet)
    -- `inferred`, from ident equality plus cardinal adjacency, the rule
    `build_wavelet_groups` uses.  Hop direction is then read off the observed
    coordinates, never from the router fields.
  * wavelet colour, bits 0-4 of `fields` -- `compiled` (verified against the ELF
    routing tables; 3,021 wavelets, 0 mismatches)
"""

from __future__ import annotations

import collections
import gzip
import json

DISPATCH = "hwm_dispatch_trace_entry"
WAVELET = "wavelet_trace_entry"
PIPE = "hwm_pipe_trace_entry"

# Same rule as tools/mesh_view.py: moves and converts are not arithmetic.
def is_fp_arith(name):
    if not name or not name.startswith("F"):
        return False
    base = name.split(".")[0]
    return not base.startswith("FMOV") and "2" not in base


def _coord(ev, width):
    sim = (ev.get("coordinates") or {}).get("simulator")
    if sim:
        return int(sim["x"]), int(sim["y"])
    t = ev.get("tile_index")
    if t is None or not width:
        return None
    return int(t) % width, int(t) // width


def _scan_span(path, window):
    """First pass: cycle span only, so bins can be laid out in the second."""
    lo, hi = 1 << 62, -1
    wlo, whi = window if window else (None, None)
    op = gzip.open if str(path).endswith(".gz") else open
    with op(path, "rt") as f:
        for line in f:
            i = line.find('"cycle":')
            if i < 0:
                continue
            j = line.find(",", i)
            try:
                c = int(line[i + 8:j])
            except ValueError:
                continue
            if wlo is not None and (c < wlo or c > whi):
                continue
            if c < lo:
                lo = c
            if c > hi:
                hi = c
    return lo, hi


def extract(path, width=None, window=None, nbins=200, max_waves=90000,
            fine_target=8000):
    cyc_lo, cyc_hi = _scan_span(path, window)
    if cyc_hi < 0:
        raise SystemExit("no cycled records in %s" % path)
    span = cyc_hi - cyc_lo + 1
    stride = max(1, -(-span // nbins))
    nb = -(-span // stride)
    # A second, much finer binning drives the trellis: inside one stack of cycle
    # layers the coarse bins never change, so every layer would share a colour.
    fstride = max(1, -(-span // fine_target))
    fnb = -(-span // fstride)

    wlo, whi = window if window else (None, None)
    idents = collections.defaultdict(list)
    disp = collections.Counter()
    fp = collections.Counter()
    elems = collections.Counter()
    mix = collections.defaultdict(collections.Counter)
    wav_at = collections.Counter()
    binned = collections.defaultdict(lambda: [0] * nb)      # (x,y) -> per-bin dispatches
    fpbin = collections.defaultdict(lambda: [0] * nb)
    fine = collections.defaultdict(lambda: [0] * fnb)       # (x,y) -> per-fine-bin
    stall_sum = collections.Counter()
    stall_n = collections.Counter()
    dec = {}
    n_disp = n_wav = n_pipe = 0

    op = gzip.open if str(path).endswith(".gz") else open
    with op(path, "rt") as f:
        for line in f:
            if '"cycle"' not in line:
                continue
            ev = json.loads(line)
            c = ev.get("cycle")
            if c is None:
                continue
            c = int(c)
            if wlo is not None and (c < wlo or c > whi):
                continue
            xy = _coord(ev, width)
            if xy is None:
                continue
            t = ev.get("_type") or ev.get("event_type")
            b = (c - cyc_lo) // stride
            if b >= nb:
                b = nb - 1
            if t == DISPATCH:
                n_disp += 1
                disp[xy] += 1
                binned[xy][b] += 1
                fb = (c - cyc_lo) // fstride
                fine[xy][fnb - 1 if fb >= fnb else fb] += 1
                nm = ev.get("name") or (ev.get("raw") or {}).get("name")
                mix[xy][nm] += 1
                if is_fp_arith(nm):
                    fp[xy] += 1
                    fpbin[xy][b] += 1
                nd = ev.get("num_data")
                if isinstance(nd, int) and 0 <= nd < 0xFFFF:
                    elems[xy] += nd
            elif t == WAVELET:
                n_wav += 1
                wav_at[xy] += 1
                idents[int(ev["ident"])].append(
                    (c, xy[0], xy[1], int(ev.get("fields") or 0)))
            elif t == PIPE:
                n_pipe += 1
                st, uid = ev.get("stage"), ev.get("uid")
                if st == 3:
                    dec[(xy, uid)] = c
                elif st == 6:
                    d0 = dec.pop((xy, uid), None)
                    if d0 is not None and c >= d0:
                        stall_sum[xy] += c - d0
                        stall_n[xy] += 1

    # ---- route templates -------------------------------------------------
    tmpl_id, templates, waves = {}, [], []
    links = collections.Counter()
    solo = 0
    for obs in idents.values():
        obs.sort()
        pts, dts, prev = [], [], None
        for c, x, y, _ in obs:
            if prev == (x, y):          # repeat observation at one PE
                continue
            pts.append((x, y))
            dts.append(c - obs[0][0])
            prev = (x, y)
        if len(pts) < 2:
            solo += 1
            continue
        if any(abs(a[0] - b[0]) + abs(a[1] - b[1]) != 1 for a, b in zip(pts, pts[1:])):
            solo += 1                   # not a cardinal chain: not a routed path
            continue
        key = (tuple(pts), tuple(dts))
        tid = tmpl_id.get(key)
        if tid is None:
            tid = len(templates)
            tmpl_id[key] = tid
            templates.append({"p": [list(p) for p in pts], "d": list(dts)})
        waves.append([tid, obs[0][0] - cyc_lo, obs[0][3] & 0x1F])
        for a, b in zip(pts, pts[1:]):
            links[(a, b)] += 1

    waves.sort(key=lambda w: w[1])
    keep = 1
    if len(waves) > max_waves:
        keep = -(-len(waves) // max_waves)
        waves = waves[::keep]

    pes = sorted(set(disp) | set(wav_at))
    return {
        "pes": pes, "disp": disp, "fp": fp, "elems": elems, "mix": mix,
        "wav_at": wav_at, "stall_sum": stall_sum, "stall_n": stall_n,
        "binned": binned, "fpbin": fpbin, "fine": fine,
        "fstride": fstride, "fnb": fnb,
        "templates": templates, "waves": waves, "links": links,
        "cycles": [cyc_lo, cyc_hi], "stride": stride, "nb": nb,
        "counts": {"dispatch": n_disp, "wavelet": n_wav, "pipe": n_pipe,
                   "idents": len(idents), "unpaired_idents": solo,
                   "templates": len(templates), "wave_decimation": keep,
                   "waves_kept": len(waves)},
    }
