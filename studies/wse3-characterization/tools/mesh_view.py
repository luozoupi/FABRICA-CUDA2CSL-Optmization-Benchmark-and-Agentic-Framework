#!/usr/bin/env python3
"""Render a CSL program's 2-D mesh dataflow as an animated, self-contained page.

The study already had space without time, and time without space:

  * `wafer.svg` / `layout.svg`  -- the true 2-D layout, but summed over the whole run
  * `trace_to_perfetto.py`      -- exact cycle timing, but PEs flattened to a track list

Neither shows a wavelet crossing the fabric.  This joins them: PEs drawn at their
real fabric coordinates, wavelet hops replayed on the links they actually took, at
the cycle they actually happened.

Hop direction and path membership come from `build_wavelet_groups`, which pairs
observations by ident plus cardinal adjacency -- `inferred`, and labelled as such
on the page.  Cycles and dispatch counts are `simulator`.

Output is one HTML file with the data inlined; it needs no server and no network.
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


def _is_fp_arith(name):
    """True for floating-point *arithmetic* only.

    FMOV16/FMOV32 move data and FS2XP16/FH2S convert it; neither is computation,
    and counting them would make every data-movement PE look like a compute PE.
    What remains -- FMACH, FMULS, FADDS, FDIVSS ... -- is real math.
    """
    if not name or not name.startswith("F"):
        return False
    base = name.split(".")[0]
    return not base.startswith("FMOV") and "2" not in base


def _dispatch_class(name):
    """fp / move / mem / ctl -- the four lanes the anatomy pages use."""
    n = (name or "").upper()
    base = n.split(".")[0]
    if _is_fp_arith(n):
        return "fp"
    if base.startswith(("FMOV", "IMOV", "MOV", "XP16", "FS2", "FH2")):
        return "move"
    if base.startswith(("LD", "ST")):
        return "mem"
    return "ctl"


def _coord(ev):
    sim = (ev.get("coordinates") or {}).get("simulator") or {}
    x, y = sim.get("x"), sim.get("y")
    return (x, y) if x is not None and y is not None else None


def load(events_path, window, max_wavelets):
    """One streaming pass: dispatch activity, wavelet records, coordinates."""
    lo, hi = window if window else (None, None)
    wavelets, coords = [], {}
    disp = []
    fp_arith = collections.Counter()
    truncated = 0
    with gzip.open(events_path, "rt") as fh:
        for line in fh:
            e = json.loads(line)
            c = e.get("cycle")
            if c is None or (lo is not None and not (lo <= c <= hi)):
                continue
            tile = e.get("tile_index")
            if tile is not None and tile not in coords:
                xy = _coord(e)
                if xy:
                    coords[tile] = xy
            t = e.get("event_type")
            if t == DISPATCH:
                nm = e.get("name")
                cls = _dispatch_class(nm)
                nd = e.get("num_data")
                nd = nd if isinstance(nd, int) and nd < 65535 else 1
                disp.append((c, tile, cls, nd if cls == "fp" else 0))
                if cls == "fp":
                    fp_arith[tile] += 1
            elif t == WAVELET:
                if len(wavelets) < max_wavelets:
                    wavelets.append(e)
                else:
                    truncated += 1
    return disp, wavelets, coords, fp_arith, truncated


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("events", help="decoded events.jsonl.gz")
    ap.add_argument("fabric", help="fabric_probe.py --json output")
    ap.add_argument("-o", "--out", required=True, help="destination .html")
    ap.add_argument("--title", default=None, help="kernel name shown on the page")
    ap.add_argument("--frames", type=int, default=240, help="animation frames (default 240)")
    ap.add_argument("--window", type=int, nargs=2, metavar=("LO", "HI"))
    ap.add_argument("--max-wavelets", type=int, default=120_000,
                    help="cap on wavelet records considered (default 120k)")
    a = ap.parse_args()

    events = Path(a.events)
    title = a.title or events.parent.name
    disp, wavelets, coords, fp_arith, truncated = load(events, a.window, a.max_wavelets)
    if not wavelets:
        raise SystemExit("no wavelet records in range")

    # The fabric profile was previously accepted and ignored.  It carries the
    # compiled routing, which is where the host boundary actually is: a RAMP on
    # the rx side means the compute engine injects into the fabric, a RAMP on tx
    # means the fabric delivers into the engine.  Those are the I/O ports.
    fab = json.loads(Path(a.fabric).read_text())
    MEMCPY_COLOURS = {21, 22, 23}
    ports = {}
    for xy, rec in (fab.get("pes") or {}).items():
        fx, fy = (int(v) for v in xy.split(","))
        inject = eject = memcpy = False
        for col, r in (rec.get("routes") or {}).items():
            rx, tx = r.get("rx") or [], r.get("tx") or []
            if "RAMP" in rx:
                inject = True
            if "RAMP" in tx:
                eject = True
            if int(col) in MEMCPY_COLOURS:
                memcpy = True
        if inject or eject or memcpy:
            ports[(fx, fy)] = {"inject": inject, "eject": eject, "memcpy": memcpy,
                               "sram": rec.get("sram_bytes")}

    from wse3study.trace import build_wavelet_groups
    groups = build_wavelet_groups(wavelets)

    nodes = {}
    for g in groups:
        for n in g.get("nodes", []):
            nodes[n["node_id"]] = n

    # Colour comes from fields[4:0] -- the decoding verified against the compiler's
    # routing tables on 38/38 PEs.  Colours 22/23 carry host-to-device traffic,
    # 21 carries device-to-host, and everything else is the kernel's own dataflow,
    # so this is what separates I/O from compute on the map.
    hops = []
    ambiguous = 0
    for g in groups:
        for e in g.get("edges", []):
            if e.get("direction") == "LOCAL":
                continue
            s, d = nodes.get(e["source"]), nodes.get(e["destination"])
            if not s or not d:
                continue
            sx, dx = _coord(s), _coord(d)
            if not sx or not dx:
                continue
            idx = d.get("source_event_index")
            fields = wavelets[idx].get("fields") if isinstance(idx, int) and idx < len(wavelets) else None
            colour = (fields & 0x1F) if isinstance(fields, int) else None
            ambiguous += bool(e.get("ambiguous_predecessor"))
            hops.append((int(d["cycle"]), sx, dx, e["direction"],
                         int(e["delay_cycles"]), colour))
    if not hops:
        raise SystemExit("no cross-PE hops recovered")

    cyc = [h[0] for h in hops] + [c for c, *_ in disp]
    c0, c1 = min(cyc), max(cyc)
    span = max(c1 - c0, 1)
    F = max(1, a.frames)

    def frame_of(c):
        return min(F - 1, int((c - c0) * F / span))

    # Sparse per-frame link traffic and per-PE dispatch activity.
    # The host path is identifiable from the SHAPE of the memcpy routes, and the
    # H2D and D2H colours have to be read separately because an application PE
    # both receives host data and injects results:
    #
    #   x=3  c22/c23: RAMP -> EAST         entry port -- engine injects H2D
    #   x=4  c22/c23: WEST -> EAST, RAMP   application -- forwards H2D and taps it
    #        c21:     RAMP -> EAST                     -- and injects its D2H result
    #   x=7  c22/c23: WEST -> RAMP         application -- last column, taps only
    #   x=8  c21:     WEST -> RAMP         exit port -- collects D2H, forwards nothing
    #
    # So: RAMP on the rx side of an H2D colour is the entry; RAMP on the tx side of
    # an H2D colour is an application PE; RAMP as the sole tx of the D2H colour is
    # the exit.  An SRAM-size heuristic gets x=7 and x=8 wrong; this does not.
    CARD = {"NORTH", "SOUTH", "EAST", "WEST"}
    H2D_C, D2H_C = {22, 23}, {21}
    role_x = collections.defaultdict(set)
    for xy, rec in (fab.get("pes") or {}).items():
        fx, _fy = (int(v) for v in xy.split(","))
        for col, r in (rec.get("routes") or {}).items():
            c = int(col)
            rx, tx = set(r.get("rx") or []), set(r.get("tx") or [])
            if c in H2D_C:
                if "RAMP" in rx:
                    role_x["entry"].add(fx)
                if "RAMP" in tx:
                    role_x["app"].add(fx)
            elif c in D2H_C and "RAMP" in tx and not (tx & CARD):
                role_x["exit"].add(fx)
    app_x = sorted(role_x["app"] - role_x["entry"])
    ax0, ax1 = (min(app_x), max(app_x)) if app_x else (None, None)
    entry_x = min(role_x["entry"]) if role_x["entry"] else None
    exit_x = max(role_x["exit"] - role_x["app"]) if (role_x["exit"] - role_x["app"]) else None

    def region_of(x):
        if entry_x is not None and x == entry_x:
            return "in-port"
        if exit_x is not None and x == exit_x:
            return "out-port"
        if ax0 is not None and ax0 <= x <= ax1:
            return "compute"
        if ax0 is None:
            return "compute"
        return "host-west" if x < ax0 else "host-east"

    H2D, D2H = {22, 23}, {21}
    def klass(col, sxy, dxy):
        # 22/23 carry host->device, 21 device->host.  Anything else is kernel
        # compute ONLY if both endpoints are application PEs; between plumbing PEs
        # the remaining colours (0,1,2,3,5 in every harness seen) are the memcpy
        # library's control/credit ring -- including the wavelets that travel
        # WEST from the east gateway back into the collector column.
        if col in H2D:
            return "in"
        if col in D2H:
            return "out"
        if region_of(sxy[0]) == "compute" and region_of(dxy[0]) == "compute":
            return "compute"
        return "control"

    link_index, link_list = {}, []
    link_frames = collections.defaultdict(collections.Counter)
    link_total = collections.Counter()
    delays = collections.defaultdict(list)
    link_delay = collections.defaultdict(collections.Counter)
    class_total = collections.Counter()
    for c, s, d, direction, delay, colour in hops:
        k = klass(colour, s, d)
        class_total[k] += 1
        key = (s, d, k)
        if key not in link_index:
            link_index[key] = len(link_list)
            link_list.append({"sx": s[0], "sy": s[1], "dx": d[0], "dy": d[1],
                              "dir": direction, "cls": k})
        i = link_index[key]
        f = frame_of(c)
        link_frames[f][i] += 1
        link_delay[f][i] += delay
        link_total[i] += 1
        delays[i].append(delay)

    pe_index, pe_list = {}, []
    for tile, xy in sorted(coords.items()):
        pe_index[tile] = len(pe_list)
        pe_list.append({"x": xy[0], "y": xy[1], "tile": tile})
    # Per PE per frame: [total, fp, move, mem, ctl, fp_elements].  This is what
    # lets a node show not just THAT it was busy but WHAT it was doing -- arithmetic
    # or data movement -- and how close its arithmetic ran to the measured peak.
    CLS_IX = {"fp": 1, "move": 2, "mem": 3, "ctl": 4}
    pe_frames = collections.defaultdict(dict)
    pe_total = collections.Counter()
    pe_cls = collections.defaultdict(collections.Counter)
    pe_fp_elems = collections.Counter()
    for c, tile, cls, fpe in disp:
        if tile in pe_index:
            i = pe_index[tile]
            row = pe_frames[frame_of(c)].setdefault(i, [0, 0, 0, 0, 0, 0])
            row[0] += 1
            row[CLS_IX[cls]] += 1
            row[5] += fpe
            pe_total[i] += 1
            pe_cls[i][cls] += 1
            pe_fp_elems[i] += fpe

    for i, ln in enumerate(link_list):
        ds = delays[i]
        ln["total"] = link_total[i]
        ln["median_delay"] = sorted(ds)[len(ds) // 2] if ds else None
    for i, pe in enumerate(pe_list):
        pe["total"] = pe_total[i]
        pr = ports.get((pe["x"], pe["y"]))
        if pr:
            pe["inject"] = pr["inject"]
            pe["eject"] = pr["eject"]
            pe["memcpy"] = pr["memcpy"]
        pe["region"] = region_of(pe["x"])
        pe["fp"] = fp_arith.get(pe["tile"], 0)
        pe["cls"] = {k: pe_cls[i].get(k, 0) for k in ("fp", "move", "mem", "ctl")}
        pe["fp_elems"] = pe_fp_elems.get(i, 0)
        # Three roles, each with its own evidence:
        #   compute      executes floating-point arithmetic
        #   data-move    executes instructions, but never any arithmetic
        #   router       carries wavelets with the core never dispatching at all
        pe["role"] = ("compute" if pe["fp"] > 0
                      else "data-move" if pe["total"] > 0 else "router")


    region_frames = collections.defaultdict(collections.Counter)
    for c, sxy, _d, _dir, _dl, _col in hops:
        region_frames[frame_of(c)][region_of(sxy[0])] += 1

    dirs = collections.Counter(h[3] for h in hops)
    colours = collections.Counter(h[5] for h in hops if h[5] is not None)
    data = {
        "title": title,
        "cycle0": c0, "cycle1": c1, "frames": F,
        "cycles_per_frame": span / F,
        "pes": pe_list,
        "regions": {"app_x0": ax0, "app_x1": ax1,
                    "entry_x": entry_x, "exit_x": exit_x},
        "region_frames": {str(k): dict(v) for k, v in region_frames.items()},
        "links": link_list,
        "pe_frames": {str(k): {str(i): row for i, row in v.items()} for k, v in pe_frames.items()},
        # f16 FMA peak measured in this study (simulator 4.00 elem/cyc, silicon 2.92)
        "peak_fp_elem_per_cyc": 4.0,
        "link_frames": {str(k): dict(v) for k, v in link_frames.items()},
        "link_delay": {str(k): dict(v) for k, v in link_delay.items()},
        # A link accepts one wavelet every 2 cycles (silicon-fitted CYC_HOP), so
        # this is the denominator for utilisation: anything approaching 1.0 is a
        # saturated link, and the free-flowing hop delay is 2 cycles.
        "link_capacity_per_cycle": 0.5,
        "free_delay_cycles": 2,
        "stats": {
            "hops": len(hops), "links": len(link_list), "pes": len(pe_list),
            "directions": dict(dirs), "ambiguous": ambiguous,
            "truncated_wavelets": truncated,
            "busiest_link": max(link_total.values()) if link_total else 0,
            "busiest_pe": max(pe_total.values()) if pe_total else 0,
            "classes": dict(class_total),
            "roles": dict(collections.Counter(p["role"] for p in pe_list)),
            "fp_total": sum(fp_arith.values()),
            "colours": {str(k): v for k, v in sorted(colours.items())},
        },
    }

    out = Path(a.out).expanduser()
    out.parent.mkdir(parents=True, exist_ok=True)
    # The <title> is the page's name in a gallery, so it must name the kernel
    # rather than the tool -- two renders otherwise arrive indistinguishable.
    page = HTML.replace("<title>Mesh Dataflow Replay</title>",
                        f"<title>{title} Dataflow</title>")
    out.write_text(page.replace("__DATA__", json.dumps(data, separators=(",", ":"))))

    print(f"kernel        {title}")
    print(f"cycles        {c0}..{c1}  ({span} spanned, {F} frames, "
          f"{span/F:.1f} cyc/frame)")
    print(f"PEs           {len(pe_list)}")
    if ax0 is not None:
        print(f"host path     entry x={entry_x}  application x={ax0}..{ax1}  exit x={exit_x}")
    roles = collections.Counter(p["role"] for p in pe_list)
    print(f"PE roles      {roles['compute']} compute (FP arithmetic), "
          f"{roles['data-move']} data-movement (no arithmetic), "
          f"{roles['router']} pure router (zero dispatches)")
    print(f"links         {len(link_list)}   busiest {data['stats']['busiest_link']} hops")
    print(f"hops          {len(hops)}   directions {dict(dirs)}")
    print(f"  host->device  {class_total['in']:>8}  (colours 22,23)")
    print(f"  device->host  {class_total['out']:>8}  (colour 21)")
    print(f"  kernel compute{class_total['compute']:>8}  (app<->app, non-memcpy colours)")
    print(f"  memcpy control{class_total['control']:>8}  (plumbing<->plumbing ring/credit traffic)")
    if ambiguous:
        print(f"ambiguous     {ambiguous} hops had several equally-recent predecessors")
    if truncated:
        print(f"TRUNCATED     {truncated} wavelet records beyond --max-wavelets were skipped")
    print(f"wrote         {out}  ({out.stat().st_size/1e6:.2f} MB)")
    return 0


HTML = r"""<title>Mesh Dataflow Replay</title>
<style>
:root{
  --ground:#F4F6F8; --surface:#FFFFFF; --surface-2:#EDF0F3;
  --ink:#12171C; --ink-2:#3D4750; --muted:#68747F; --line:#D9DFE5;
  --oxide:#0C6E77; --amber:#A8660F; --violet:#5A4B94;
  --app:#0C6E77; --infra:#8A96A2; --idle:#DDE3E9;
  --hot:#A8660F; --cool:#0C6E77;
  --compute:#0C6E77; --move:#5A4B94; --route:#8A96A2;
}
@media (prefers-color-scheme:dark){:root:not([data-theme="light"]){
  --ground:#0C1014; --surface:#141A20; --surface-2:#1B232B;
  --ink:#E7ECF1; --ink-2:#B6C1CB; --muted:#8797A3; --line:#26313A;
  --oxide:#4FC3CC; --amber:#E8A33F; --violet:#A99BE0;
  --app:#4FC3CC; --infra:#5A6874; --idle:#222C35;
  --hot:#E8A33F; --cool:#4FC3CC;
  --compute:#4FC3CC; --move:#A99BE0; --route:#6B7885;
}}
:root[data-theme="dark"]{
  --ground:#0C1014; --surface:#141A20; --surface-2:#1B232B;
  --ink:#E7ECF1; --ink-2:#B6C1CB; --muted:#8797A3; --line:#26313A;
  --oxide:#4FC3CC; --amber:#E8A33F; --violet:#A99BE0;
  --app:#4FC3CC; --infra:#5A6874; --idle:#222C35;
  --hot:#E8A33F; --cool:#4FC3CC;
  --compute:#4FC3CC; --move:#A99BE0; --route:#6B7885;
}
*{box-sizing:border-box}
body{margin:0;background:var(--ground);color:var(--ink);
  font-family:ui-sans-serif,system-ui,-apple-system,"Segoe UI",Roboto,sans-serif;
  font-size:15px;line-height:1.55}
.wrap{max-width:1180px;margin:0 auto;padding:28px 20px 56px}
header{display:flex;flex-wrap:wrap;gap:14px;align-items:baseline;
  border-bottom:1px solid var(--line);padding-bottom:14px;margin-bottom:20px}
h1{font-size:22px;margin:0;letter-spacing:-.02em;text-wrap:balance}
.eyebrow{font-size:11px;letter-spacing:.14em;text-transform:uppercase;color:var(--muted)}
.chip{font-size:10.5px;letter-spacing:.08em;text-transform:uppercase;padding:2px 7px;
  border-radius:3px;border:1px solid var(--line);color:var(--muted);white-space:nowrap}
.stage{background:var(--surface);border:1px solid var(--line);border-radius:8px;
  padding:14px;overflow-x:auto}
canvas{display:block;width:100%;height:auto;touch-action:none}
.ctl{display:flex;flex-wrap:wrap;gap:12px;align-items:center;margin:14px 0 6px}
button{font:inherit;font-size:13px;padding:6px 13px;border-radius:5px;cursor:pointer;
  background:var(--surface-2);color:var(--ink);border:1px solid var(--line)}
button:hover{border-color:var(--oxide)}
button:focus-visible{outline:2px solid var(--oxide);outline-offset:2px}
button[aria-pressed="true"]{background:var(--oxide);border-color:var(--oxide);color:var(--surface)}
input[type=range]{flex:1;min-width:170px;accent-color:var(--oxide)}
select{font:inherit;font-size:13px;padding:6px 9px;border-radius:5px;background:var(--surface-2);
  color:var(--ink);border:1px solid var(--line);cursor:pointer}
select:focus-visible{outline:2px solid var(--oxide);outline-offset:2px}
.readout{font-family:ui-monospace,SFMono-Regular,Menlo,Consolas,monospace;font-size:12.5px;
  color:var(--ink-2);font-variant-numeric:tabular-nums}
.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:10px;margin-top:18px}
.card{background:var(--surface);border:1px solid var(--line);border-radius:7px;padding:11px 13px}
.card .k{font-size:10.5px;letter-spacing:.09em;text-transform:uppercase;color:var(--muted)}
.card .v{font-size:19px;font-variant-numeric:tabular-nums;margin-top:3px;
  font-family:ui-monospace,SFMono-Regular,Menlo,Consolas,monospace}
.note{margin-top:20px;padding:12px 14px;border-left:3px solid var(--violet);
  background:var(--surface);border-radius:0 6px 6px 0;font-size:13.5px;color:var(--ink-2)}
.legend{display:flex;flex-wrap:wrap;gap:16px;margin-top:12px;font-size:12.5px;color:var(--muted)}
.legend i{display:inline-block;width:11px;height:11px;border-radius:2px;margin-right:5px;
  vertical-align:-1px}
code{font-family:ui-monospace,SFMono-Regular,Menlo,Consolas,monospace;font-size:.92em}
</style>
<div class="wrap">
<header>
  <div>
    <div class="eyebrow">Cerebras WSE-3 · 2-D mesh dataflow</div>
    <h1 id="ttl">Mesh Dataflow Replay</h1>
  </div>
  <span class="chip">cycles · simulator</span>
  <span class="chip">hop direction · inferred</span>
</header>

<div class="stage"><canvas id="c"></canvas></div>
<div class="stage" style="margin-top:10px;padding:10px 14px">
  <div class="eyebrow" style="margin-bottom:6px">Phases &mdash; wavelets per region over the run</div>
  <canvas id="ph"></canvas>
</div>

<div class="ctl">
  <button id="play">Play</button>
  <button id="mode" aria-pressed="false">Cumulative heat</button>
  <select id="metric" aria-label="Colour metric">
    <option value="traffic">Colour: traffic volume</option>
    <option value="util">Colour: link utilisation</option>
    <option value="delay">Colour: hop delay (congestion)</option>
    <option value="cls">Colour: input / output / compute</option>
  </select>
  <select id="nodemode" aria-label="PE node metric">
    <option value="activity">PEs: activity (dispatches)</option>
    <option value="arith">PEs: arithmetic utilisation</option>
    <option value="mix">PEs: instruction mix (stacked)</option>
  </select>
  <input type="range" id="scrub" min="0" value="0" step="1">
  <span class="readout" id="ro"></span>
</div>

<div class="legend" id="legend"></div>

<div class="card" style="margin-top:14px;background:var(--surface);border:1px solid var(--line);border-radius:8px;padding:12px 14px">
  <div class="eyebrow" style="margin-bottom:4px">PE inspector &mdash; <span id="peName">click a PE on the mesh</span></div>
  <div class="readout" id="peRo"></div>
  <canvas id="pec" style="margin-top:8px"></canvas>
  <div style="font-size:11.5px;color:var(--muted);margin-top:6px">
    Stacked bars: this PE's dispatches per frame by class (teal FP arithmetic, violet moves,
    amber loads/stores, grey control). Line: FP elements retired per cycle as a fraction of the
    4 elem/cyc f16 peak. This is the compute-vs-movement story of one PE across the whole run.
  </div>
</div>

<div class="grid" id="stats"></div>

<div class="note">
  <strong>Every PE drawn is on the wafer.</strong> The MEMCPY STAGING and MEMCPY GATEWAY bands
  are the <code>&lt;memcpy&gt;</code> library's own PEs: the compiler places them on both sides of
  your application rectangle to shuttle data between the application and the fabric edge, where
  the host I/O attaches. The staging side holds the H2D stream and the control ring; the gateway
  side collects D2H and returns credits. Control-ring wavelets (colours 0/1/2/3/5) are the ones you
  see travelling WEST from the gateway back into the collector column, and the ring itself leaves
  the east fabric edge and re-enters at the west edge through the host side. PEs sit at their true
  fabric coordinates, with <code>y</code> increasing downward per the CSL convention &mdash; so a
  NORTH hop points up the page. Each arrow is one wavelet crossing one link,
  replayed at the cycle it occurred. Hop <em>direction</em> and path membership are
  <strong>inferred</strong>: they come from pairing observations by <code>ident</code> and cardinal
  adjacency, not from a decoded router field. Cycle values and dispatch counts are direct
  <strong>simulator</strong> observations.
</div>
</div>

<script>
const D = __DATA__;
const cv = document.getElementById('c'), ctx = cv.getContext('2d');
const scrub = document.getElementById('scrub'), ro = document.getElementById('ro');
const playBtn = document.getElementById('play'), modeBtn = document.getElementById('mode');
document.getElementById('ttl').textContent = D.title;
document.title = D.title + ' · Mesh Dataflow';
scrub.max = D.frames - 1;

const xs = D.pes.map(p => p.x), ys = D.pes.map(p => p.y);
const minX = Math.min(...xs), maxX = Math.max(...xs);
const minY = Math.min(...ys), maxY = Math.max(...ys);
const cols = maxX - minX + 1, rows = maxY - minY + 1;

let frame = 0, playing = false, heat = false, metric = 'traffic', nodemode = 'activity', selPE = -1;
const Z6 = [0,0,0,0,0,0];
let dpr = 1, cell = 40, pad = 34;

function layout(){
  const avail = cv.parentElement.clientWidth - 28;
  cell = Math.max(26, Math.min(72, Math.floor(avail / (cols + 1.6))));
  pad = Math.round(cell * 0.85);
  const w = cols * cell + pad * 2, h = rows * cell + pad * 2;
  dpr = window.devicePixelRatio || 1;
  cv.width = w * dpr; cv.height = h * dpr;
  cv.style.width = w + 'px'; cv.style.height = h + 'px';
  ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
}
const px = x => pad + (x - minX) * cell + cell / 2;
const py = y => pad + (y - minY) * cell + cell / 2;

function css(v){ return getComputedStyle(document.documentElement).getPropertyValue(v).trim(); }

function mix(a, b, t){
  const p = s => [1,3,5].map(i => parseInt(s.slice(i, i+2), 16));
  const A = p(a), B = p(b);
  return `rgb(${A.map((v,i)=>Math.round(v+(B[i]-v)*t)).join(',')})`;
}

function draw(){
  layout();
  const lf = heat ? null : (D.link_frames[frame] || {});
  const pf = heat ? null : (D.pe_frames[frame] || {});
  const pfv = i => heat
    ? [D.pes[i].total, D.pes[i].cls.fp, D.pes[i].cls.move, D.pes[i].cls.mem, D.pes[i].cls.ctl, D.pes[i].fp_elems]
    : ((pf && pf[i]) || Z6);
  const maxLink = heat ? D.stats.busiest_link
    : Math.max(1, ...Object.values(lf));
  const maxPe = heat ? D.stats.busiest_pe
    : Math.max(1, ...Object.values(pf).map(a => a[0]));
  const winCycles = heat ? (D.cycle1 - D.cycle0) : D.cycles_per_frame;
  const ink = css('--ink'), line = css('--line'), idle = css('--idle');
  const app = css('--app'), infra = css('--infra');
  const cool = css('--cool'), hot = css('--hot');

  ctx.clearRect(0, 0, cv.width, cv.height);

  // region bands: the host path is a property of the compiled routing, so it is
  // drawn as fixed geography rather than derived from whatever is moving now
  const R = D.regions, bands = [];
  if (R.app_x0 !== null){
    if (R.entry_x !== null) bands.push([R.entry_x, R.entry_x, 'IN PORT', css('--violet')]);
    bands.push([R.app_x0, R.app_x1, 'APPLICATION', css('--app')]);
    if (R.exit_x !== null) bands.push([R.exit_x, R.exit_x, 'OUT PORT', css('--amber')]);
    if (minX < Math.min(R.app_x0, R.entry_x ?? 99))
      bands.push([minX, Math.min(R.app_x0, R.entry_x ?? 99) - 1, 'MEMCPY STAGING', css('--infra')]);
    const eastStart = Math.max(R.app_x1, R.exit_x ?? -1) + 1;
    if (eastStart <= maxX) bands.push([eastStart, maxX, 'MEMCPY GATEWAY', css('--infra')]);
  }
  ctx.textAlign = 'center';
  ctx.font = `${Math.max(8, Math.round(cell*0.22))}px ui-sans-serif,system-ui,sans-serif`;
  for (const [bx0, bx1, label, colr] of bands){
    const x = px(bx0) - cell/2, w = (bx1 - bx0 + 1) * cell;
    ctx.globalAlpha = 0.07; ctx.fillStyle = colr;
    ctx.fillRect(x, pad - cell*0.42, w, rows * cell + cell*0.1);
    ctx.globalAlpha = 1;
    ctx.strokeStyle = colr; ctx.globalAlpha = 0.35; ctx.lineWidth = 1;
    ctx.strokeRect(x, pad - cell*0.42, w, rows * cell + cell*0.1);
    ctx.globalAlpha = 1;
    ctx.fillStyle = colr;
    ctx.fillText(label, x + w/2, pad - cell*0.55);
  }

  // grid of quiet link stubs, so the mesh reads even when nothing is moving
  ctx.strokeStyle = line; ctx.lineWidth = 1;
  for (const p of D.pes){
    for (const [dx,dy] of [[1,0],[0,1]]){
      if (D.pes.some(q => q.x === p.x+dx && q.y === p.y+dy)){
        ctx.beginPath();
        ctx.moveTo(px(p.x), py(p.y));
        ctx.lineTo(px(p.x+dx), py(p.y+dy));
        ctx.stroke();
      }
    }
  }

  // links carrying traffic
  const df = heat ? null : (D.link_delay[frame] || {});
  const cyclesThisFrame = D.cycles_per_frame;
  D.links.forEach((L, i) => {
    const v = heat ? L.total : (lf[i] || 0);
    if (!v) return;
    let t, col;
    if (metric === 'cls'){
      col = L.cls === 'in' ? css('--violet') : L.cls === 'out' ? css('--amber')
          : L.cls === 'control' ? css('--route') : css('--oxide');
      t = Math.min(1, v / maxLink);
    } else if (metric === 'util'){
      // fraction of the link's 1-wavelet-per-2-cycles capacity actually used
      const cap = (heat ? (D.cycle1 - D.cycle0) : cyclesThisFrame) * D.link_capacity_per_cycle;
      t = Math.max(0, Math.min(1, v / Math.max(cap, 1e-9)));
      col = mix(cool, hot, t);
    } else if (metric === 'delay'){
      // mean observed hop delay; D.free_delay_cycles is free-flowing, more is queueing
      const mean = heat ? (L.median_delay ?? D.free_delay_cycles)
                        : ((df[i] || 0) / v);
      t = Math.max(0, Math.min(1, (mean - D.free_delay_cycles) / (3 * D.free_delay_cycles)));
      col = mix(cool, hot, t);
    } else {
      t = Math.min(1, v / maxLink);
      col = mix(cool, hot, t);
    }
    const x1 = px(L.sx), y1 = py(L.sy), x2 = px(L.dx), y2 = py(L.dy);
    // offset perpendicular so opposite directions do not overlap
    const ang = Math.atan2(y2 - y1, x2 - x1);
    const ox = Math.cos(ang + Math.PI/2) * cell * 0.11;
    const oy = Math.sin(ang + Math.PI/2) * cell * 0.11;
    const sh = cell * 0.30;
    const ax = x1 + Math.cos(ang) * sh + ox, ay = y1 + Math.sin(ang) * sh + oy;
    const bx = x2 - Math.cos(ang) * sh + ox, by = y2 - Math.sin(ang) * sh + oy;
    ctx.strokeStyle = col;
    // width always tracks volume, so a low-utilisation heavy link stays visible
    ctx.lineWidth = 1 + Math.min(1, v / maxLink) * (cell * 0.13);
    ctx.globalAlpha = 0.35 + 0.65 * Math.max(t, 0.25);
    ctx.beginPath(); ctx.moveTo(ax, ay); ctx.lineTo(bx, by); ctx.stroke();
    // arrowhead
    const hd = cell * 0.17;
    ctx.fillStyle = col;
    ctx.beginPath();
    ctx.moveTo(bx, by);
    ctx.lineTo(bx - Math.cos(ang - 0.42) * hd, by - Math.sin(ang - 0.42) * hd);
    ctx.lineTo(bx - Math.cos(ang + 0.42) * hd, by - Math.sin(ang + 0.42) * hd);
    ctx.closePath(); ctx.fill();
    ctx.globalAlpha = 1;
  });

  // PEs, coloured by measured role rather than by position
  const roleCol = { compute: css('--compute'), 'data-move': css('--move'), router: css('--route') };
  const r = cell * 0.27;
  D.pes.forEach((p, i) => {
    const a = pfv(i);
    const v = a[0];
    const t = maxPe ? Math.min(1, v / maxPe) : 0;
    const base = roleCol[p.role] || infra;
    const x0 = px(p.x) - r, y0 = py(p.y) - r, side = r * 2;
    // A router never dispatches, so it has no activity to brighten: draw it
    // hollow to say "traffic passes through, the core is not involved".
    if (p.role === 'router'){
      ctx.fillStyle = idle;
      ctx.strokeStyle = base; ctx.lineWidth = 1.6; ctx.setLineDash([2.5, 2.5]);
      ctx.beginPath(); ctx.roundRect(x0, y0, side, side, Math.max(2, r * 0.28));
      ctx.fill(); ctx.stroke(); ctx.setLineDash([]);
    } else if (nodemode === 'arith'){
      // fraction of the measured f16 FMA peak this PE's arithmetic reached
      const util = Math.min(1, a[5] / Math.max(1e-9, winCycles * D.peak_fp_elem_per_cyc));
      ctx.fillStyle = util > 0 ? mix(idle, css('--compute'), 0.15 + 0.85 * util) : idle;
      ctx.strokeStyle = line; ctx.lineWidth = 1;
      ctx.beginPath(); ctx.roundRect(x0, y0, side, side, Math.max(2, r * 0.28));
      ctx.fill(); ctx.stroke();
    } else if (nodemode === 'mix'){
      // stacked fill: what the core was doing this frame, bottom-up fp/move/mem/ctl
      ctx.fillStyle = idle; ctx.strokeStyle = line; ctx.lineWidth = 1;
      ctx.beginPath(); ctx.roundRect(x0, y0, side, side, Math.max(2, r * 0.28));
      ctx.fill();
      if (v > 0){
        const parts = [[a[1], css('--compute')], [a[2], css('--move')],
                       [a[3], css('--amber')], [a[4], css('--route')]];
        let yb = y0 + side;
        for (const [n, colr] of parts){
          const hh = side * n / v;
          if (hh <= 0) continue;
          ctx.fillStyle = colr; ctx.fillRect(x0 + 1, yb - hh, side - 2, hh);
          yb -= hh;
        }
      }
      ctx.beginPath(); ctx.roundRect(x0, y0, side, side, Math.max(2, r * 0.28)); ctx.stroke();
    } else {
      ctx.fillStyle = t > 0 ? mix(idle, base, 0.28 + 0.72 * t) : mix(idle, base, 0.12);
      ctx.strokeStyle = line; ctx.lineWidth = 1; ctx.setLineDash([]);
      ctx.beginPath(); ctx.roundRect(x0, y0, side, side, Math.max(2, r * 0.28));
      ctx.fill(); ctx.stroke();
    }
    if (i === selPE){
      ctx.strokeStyle = css('--ink'); ctx.lineWidth = 2;
      ctx.beginPath(); ctx.roundRect(x0 - 3, y0 - 3, side + 6, side + 6, Math.max(3, r * 0.3)); ctx.stroke();
    }
    // Port glyphs read straight off the compiled routes: a RAMP on the rx side
    // means this engine injects into the fabric, on the tx side that the fabric
    // delivers into it.  Both together is an ordinary compute PE and is not marked.
    if (p.memcpy && (p.inject !== p.eject)){
      ctx.fillStyle = p.inject ? css('--violet') : css('--amber');
      const g = r * 0.52, cx2 = px(p.x), cy2 = py(p.y);
      ctx.beginPath();
      if (p.inject){ ctx.moveTo(cx2, cy2 - g); ctx.lineTo(cx2 + g, cy2 + g); ctx.lineTo(cx2 - g, cy2 + g); }
      else { ctx.moveTo(cx2, cy2 + g); ctx.lineTo(cx2 + g, cy2 - g); ctx.lineTo(cx2 - g, cy2 - g); }
      ctx.closePath(); ctx.fill();
    }
  });

  // axis ticks
  ctx.fillStyle = css('--muted');
  ctx.font = `${Math.max(9, Math.round(cell*0.26))}px ui-monospace,Menlo,monospace`;
  ctx.textAlign = 'center';
  for (let x = minX; x <= maxX; x++) ctx.fillText(x, px(x), pad * 0.55);
  ctx.textAlign = 'right';
  for (let y = minY; y <= maxY; y++) ctx.fillText(y, pad * 0.72, py(y) + 4);

  const c = Math.round(D.cycle0 + frame * D.cycles_per_frame);
  ro.textContent = heat
    ? `whole run · ${D.stats.hops.toLocaleString()} hops`
    : `cycle ${c.toLocaleString()}  ·  frame ${frame + 1}/${D.frames}`;
  drawPhases();
  drawInspector();
}

const phc = document.getElementById('ph'), pctx = phc.getContext('2d');
const REGION_ORDER = ['host-west', 'in-port', 'compute', 'out-port', 'host-east'];
function regionColour(k){
  return k === 'in-port' ? css('--violet') : k === 'out-port' ? css('--amber')
       : k === 'compute' ? css('--app') : css('--infra');
}
function drawPhases(){
  const w = phc.parentElement.clientWidth - 28, h = 74;
  phc.width = w * dpr; phc.height = h * dpr;
  phc.style.width = w + 'px'; phc.style.height = h + 'px';
  pctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  pctx.clearRect(0, 0, w, h);
  let peak = 1;
  for (let f = 0; f < D.frames; f++){
    const r = D.region_frames[f] || {};
    peak = Math.max(peak, REGION_ORDER.reduce((a, k) => a + (r[k] || 0), 0));
  }
  const bw = w / D.frames;
  for (let f = 0; f < D.frames; f++){
    const r = D.region_frames[f] || {};
    let yb = h - 14;
    for (const k of REGION_ORDER){
      const v = r[k] || 0;
      if (!v) continue;
      const hh = (v / peak) * (h - 20);
      pctx.fillStyle = regionColour(k);
      pctx.globalAlpha = 0.85;
      pctx.fillRect(f * bw, yb - hh, Math.max(bw, 1), hh);
      yb -= hh;
    }
  }
  pctx.globalAlpha = 1;
  // playhead
  pctx.strokeStyle = css('--ink'); pctx.lineWidth = 1.5;
  pctx.beginPath(); pctx.moveTo(frame * bw + bw/2, 0);
  pctx.lineTo(frame * bw + bw/2, h - 12); pctx.stroke();
  pctx.fillStyle = css('--muted');
  pctx.font = '10px ui-monospace,Menlo,monospace';
  pctx.textAlign = 'left';  pctx.fillText(D.cycle0.toLocaleString(), 0, h - 2);
  pctx.textAlign = 'right'; pctx.fillText(D.cycle1.toLocaleString(), w, h - 2);
}
phc.addEventListener('click', ev => {
  const rect = phc.getBoundingClientRect();
  frame = Math.max(0, Math.min(D.frames - 1,
    Math.floor((ev.clientX - rect.left) / rect.width * D.frames)));
  scrub.value = frame; heat = false;
  modeBtn.setAttribute('aria-pressed', 'false');
  draw();
});

function step(){
  if (!playing) return;
  frame = (frame + 1) % D.frames;
  scrub.value = frame;
  draw();
  setTimeout(() => requestAnimationFrame(step), 55);
}
playBtn.onclick = () => {
  playing = !playing;
  playBtn.textContent = playing ? 'Pause' : 'Play';
  if (playing){ heat = false; modeBtn.setAttribute('aria-pressed','false'); step(); }
};
modeBtn.onclick = () => {
  heat = !heat;
  modeBtn.setAttribute('aria-pressed', heat ? 'true' : 'false');
  if (heat){ playing = false; playBtn.textContent = 'Play'; }
  draw();
};
scrub.oninput = () => { heat = false; modeBtn.setAttribute('aria-pressed','false');
  frame = +scrub.value; draw(); };
const metricSel = document.getElementById('metric');
metricSel.onchange = () => { metric = metricSel.value; legend(); draw(); };
const nodeSel = document.getElementById('nodemode');
nodeSel.onchange = () => { nodemode = nodeSel.value; legend(); draw(); };

// click a PE to inspect its compute-vs-movement profile over the whole run
cv.addEventListener('click', ev => {
  const rect = cv.getBoundingClientRect();
  const mx = (ev.clientX - rect.left), my = (ev.clientY - rect.top);
  let best = -1, bd = 1e9;
  D.pes.forEach((p, i) => {
    const d = Math.hypot(px(p.x) - mx, py(p.y) - my);
    if (d < bd){ bd = d; best = i; }
  });
  if (bd <= cell * 0.5){ selPE = best; draw(); }
});

const pec = document.getElementById('pec'), pcx = pec.getContext('2d');
function drawInspector(){
  const nameEl = document.getElementById('peName'), roEl = document.getElementById('peRo');
  const w = pec.parentElement.clientWidth - 28, h = 96;
  pec.width = w * dpr; pec.height = h * dpr;
  pec.style.width = w + 'px'; pec.style.height = h + 'px';
  pcx.setTransform(dpr, 0, 0, dpr, 0, 0);
  pcx.clearRect(0, 0, w, h);
  if (selPE < 0){ nameEl.textContent = 'click a PE on the mesh'; roEl.textContent = ''; return; }
  const p = D.pes[selPE];
  nameEl.textContent = `PE (${p.x},${p.y}) · ${p.role} · region ${p.region}`;
  const peakUtil = (() => { let m = 0;
    for (let f = 0; f < D.frames; f++){ const a = (D.pe_frames[f] || {})[selPE];
      if (a) m = Math.max(m, a[5] / (D.cycles_per_frame * D.peak_fp_elem_per_cyc)); }
    return m; })();
  roEl.textContent =
    `dispatches ${p.total.toLocaleString()}  ·  FP arith ${p.cls.fp.toLocaleString()}  ·  ` +
    `moves ${p.cls.move.toLocaleString()}  ·  ld/st ${p.cls.mem.toLocaleString()}  ·  ` +
    `ctl ${p.cls.ctl.toLocaleString()}  ·  FP elements ${p.fp_elems.toLocaleString()}  ·  ` +
    `peak arith util ${(100 * Math.min(1, peakUtil)).toFixed(0)}%`;
  let maxT = 1;
  for (let f = 0; f < D.frames; f++){ const a = (D.pe_frames[f] || {})[selPE]; if (a) maxT = Math.max(maxT, a[0]); }
  const bw = w / D.frames;
  const cols = [css('--compute'), css('--move'), css('--amber'), css('--route')];
  for (let f = 0; f < D.frames; f++){
    const a = (D.pe_frames[f] || {})[selPE];
    if (!a) continue;
    let yb = h - 14;
    for (let k = 1; k <= 4; k++){
      const hh = (a[k] / maxT) * (h - 22);
      if (!hh) continue;
      pcx.fillStyle = cols[k - 1]; pcx.globalAlpha = 0.85;
      pcx.fillRect(f * bw, yb - hh, Math.max(bw, 1), hh);
      yb -= hh;
    }
  }
  pcx.globalAlpha = 1;
  // arithmetic utilisation line
  pcx.strokeStyle = css('--compute'); pcx.lineWidth = 1.5; pcx.beginPath();
  let started = false;
  for (let f = 0; f < D.frames; f++){
    const a = (D.pe_frames[f] || {})[selPE];
    const u = a ? Math.min(1, a[5] / (D.cycles_per_frame * D.peak_fp_elem_per_cyc)) : 0;
    const x = f * bw + bw / 2, y = (h - 14) - u * (h - 22);
    if (!started){ pcx.moveTo(x, y); started = true; } else pcx.lineTo(x, y);
  }
  pcx.stroke();
  pcx.strokeStyle = css('--ink'); pcx.lineWidth = 1.5;
  pcx.beginPath(); pcx.moveTo(frame * bw + bw/2, 0); pcx.lineTo(frame * bw + bw/2, h - 12); pcx.stroke();
  pcx.fillStyle = css('--muted'); pcx.font = '10px ui-monospace,Menlo,monospace';
  pcx.textAlign = 'left'; pcx.fillText('run start', 0, h - 2);
  pcx.textAlign = 'right'; pcx.fillText('run end', w, h - 2);
}

function legend(){
  const swatch = (c, label) => `<span><i style="background:${c}"></i>${label}</span>`;
  const rows = [
    swatch('var(--compute)', `compute PE &mdash; runs FP arithmetic (${D.stats.roles.compute || 0})`),
    swatch('var(--move)', `data-movement PE &mdash; instructions, no arithmetic (${D.stats['roles']['data-move'] || 0})`),
    '<span><i style="background:transparent;border:1.5px dashed var(--route)"></i>' +
      `pure router &mdash; forwards wavelets, core never dispatches (${D.stats.roles.router || 0})</span>`];
  if (metric === 'cls'){
    rows.push(swatch('var(--violet)', 'host &rarr; device (colours 22, 23)'),
              swatch('var(--amber)', 'device &rarr; host (colour 21)'),
              swatch('var(--oxide)', 'kernel compute (application PE to application PE)'),
              swatch('var(--route)', 'memcpy control / credit ring (plumbing to plumbing, colours 0-5)'));
  } else if (metric === 'util'){
    rows.push(swatch('var(--cool)', 'idle link'),
              swatch('var(--hot)', 'saturated (1 wavelet / 2 cycles)'));
  } else if (metric === 'delay'){
    rows.push(swatch('var(--cool)', `free-flowing (${D.free_delay_cycles} cyc/hop)`),
              swatch('var(--hot)', 'queued (&ge;4&times; free delay)'));
  } else {
    rows.push(swatch('var(--cool)', 'light traffic'), swatch('var(--hot)', 'heavy traffic'));
  }
  if (nodemode === 'arith'){
    rows.push(swatch('var(--idle)', 'PE: no arithmetic this frame'),
              swatch('var(--compute)', 'PE: at the 4 elem/cyc f16 FMA peak'));
  } else if (nodemode === 'mix'){
    rows.push(swatch('var(--compute)', 'PE fill: FP arithmetic share'),
              swatch('var(--move)', 'moves &amp; converts'),
              swatch('var(--amber)', 'loads &amp; stores'),
              swatch('var(--route)', 'control'));
  }
  rows.push('<span><i style="background:var(--violet)"></i>&#9650; injects into fabric (H2D entry)</span>',
            '<span><i style="background:var(--amber)"></i>&#9660; collects from fabric (D2H exit)</span>',
            '<span>line width = wavelet volume · node brightness = dispatches</span>');
  document.getElementById('legend').innerHTML = rows.join('');
}
legend();
window.addEventListener('resize', draw);
matchMedia('(prefers-color-scheme:dark)').addEventListener('change', draw);

const S = D.stats;
document.getElementById('stats').innerHTML = [
  ['PEs drawn', S.pes], ['active links', S.links],
  ['wavelet hops', S.hops.toLocaleString()],
  ['busiest link', S.busiest_link.toLocaleString() + ' hops'],
  ['cycles spanned', (D.cycle1 - D.cycle0).toLocaleString()],
  ['direction split', Object.entries(S.directions)
      .sort((a,b) => b[1]-a[1]).map(([k,v]) => k[0] + ':' + v).join('  ')],
  ['host &rarr; device', (S.classes.in || 0).toLocaleString() + ' hops'],
  ['device &rarr; host', (S.classes.out || 0).toLocaleString() + ' hops'],
  ['kernel compute', (S.classes.compute || 0).toLocaleString() + ' hops'],
  ['memcpy control', (S.classes.control || 0).toLocaleString() + ' hops'],
  ['compute PEs', (S.roles.compute || 0) + ' of ' + S.pes],
  ['FP arithmetic', S.fp_total.toLocaleString() + ' dispatches'],
  ['FP elements', D.pes.reduce((a, p) => a + (p.fp_elems || 0), 0).toLocaleString()],
].map(([k,v]) => `<div class="card"><div class="k">${k}</div><div class="v">${v}</div></div>`).join('');

draw();
</script>
"""

if __name__ == "__main__":
    raise SystemExit(main())
