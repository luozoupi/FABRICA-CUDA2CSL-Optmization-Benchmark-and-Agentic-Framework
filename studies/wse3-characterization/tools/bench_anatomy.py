#!/usr/bin/env python3
"""Render a single-PE microbench suite as an instruction-anatomy page.

The mesh replay (mesh_view.py) shows WHERE data moves; a 1-PE microbench has no
interesting where, so this shows WHAT the compiler emitted and WHEN each
instruction dispatched: every dispatch is a block on a per-class lane, wide DSD
ops carry their element count, and the decode->execute depth from the pipe trace
rides along per instruction.  This is the page for dissecting what a CSL builtin
actually costs -- the setup preamble, the one giant hardware-loop dispatch, the
reps back edge, or a scalar loop's dependent chain.

Variant windows come from the device TSC captured around each bench in the same
run as the trace, so window edges and trace cycles share a clock (simulator:
raw timestamps are cycle-domain; this tool verifies coverage and says so).

Evidence: `simulator` throughout.
"""

from __future__ import annotations

import argparse
import collections
import gzip
import json
from pathlib import Path

MAX_INSTR_PER_VARIANT = 1500

# Where each operator's data flows on the PE.  This is read off gen.py -- we
# wrote these kernels, so the operand arrays are known at the source level
# (`compiled` evidence); the RATES drawn against them are measured.
#   srcs / dst are SRAM arrays or the register file ("reg"); "const" is an
#   immediate; passes = number of full DSD sweeps per rep.
FLOW = {
    "read":    {"srcs": ["A"],            "dst": "reg",   "op": "FMOVH (scalar dest)", "passes": 1},
    "write":   {"srcs": ["const"],        "dst": "A",     "op": "FMOVH fill",          "passes": 1},
    "copy":    {"srcs": ["A"],            "dst": "Bb",    "op": "FMOVH",               "passes": 1},
    "rstride": {"srcs": ["A (stride s)"], "dst": "Bb",    "op": "FMOVH",               "passes": 1},
    "axpy":    {"srcs": ["x", "y"],       "dst": "y",     "op": "FMACH  y += a*x",     "passes": 1},
    "dotloop": {"srcs": ["x[i]", "y[i]"], "dst": "reg acc", "op": "scalar FMUL+FADD chain", "passes": 1},
    "vdot":    {"srcs": ["x", "y", "t"],  "dst": "reg acc", "op": "FMULH -> t ; FADDH reduce t", "passes": 2},
    "reduce":  {"srcs": ["x"],            "dst": "reg acc", "op": "FADDH (scalar dest)", "passes": 1},
    "ewadd":   {"srcs": ["a3", "b3"],     "dst": "c3",    "op": "FADDH",               "passes": 1},
    "ewmul":   {"srcs": ["a3", "b3"],     "dst": "c3",    "op": "FMULH",               "passes": 1},
    "gemv":    {"srcs": ["Amat col k", "X[k]"], "dst": "Y", "op": "FMACH  Y += A[:,k]*X[k]", "passes": "K"},
    "stencil": {"srcs": ["Amat (5 offsets)"], "dst": "Bout", "op": "FADDH x4",         "passes": 4},
    "iadd16":  {"srcs": ["ia", "ib"],     "dst": "ic",    "op": "ADD16",               "passes": 1},
    "idot16":  {"srcs": ["ia[i]", "ib[i]"], "dst": "reg iacc", "op": "scalar i16 mul+add", "passes": 1},
    "i8":      {"srcs": ["q8[i]"],        "dst": "reg qacc", "op": "scalar i8 add",     "passes": 1},
}
ELEM_BYTES = {"i8": 1}

FP_ARITH = ("FMAC", "FMUL", "FADD", "FSUB", "FDIV", "FABS", "FNEG", "FSCALE",
            "FNORM", "FMAX", "FMIN", "FLT", "FEQ")


def classify(name: str) -> str:
    n = (name or "").upper()
    base = n.split(".")[0]
    if any(base.startswith(p) for p in FP_ARITH):
        return "fp"
    if base.startswith(("FMOV", "IMOV", "MOV", "XP16", "FS2", "FH2")):
        return "move"
    if base.startswith(("LD", "ST")):
        return "mem"
    return "ctl"


def load(events_path: Path):
    disp = []
    s3, s6 = {}, {}
    tiles = collections.Counter()
    fp_tiles = collections.Counter()
    wav_tiles = collections.Counter()
    wav_events = []          # (cycle, tile): fabric activity, to count per variant window
    coords = {}
    with gzip.open(events_path, "rt") as fh:
        for line in fh:
            e = json.loads(line)
            t = e.get("event_type")
            tile = e.get("tile_index")
            if tile is not None and tile not in coords:
                sim = (e.get("coordinates") or {}).get("simulator") or {}
                if "x" in sim:
                    coords[tile] = (sim["x"], sim["y"])
            if t == "hwm_dispatch_trace_entry":
                tiles[tile] += 1
                nm = e.get("name")
                if classify(nm) == "fp" and not (nm or "").upper().startswith("FMOV"):
                    fp_tiles[tile] += 1
                disp.append((e["cycle"], tile, nm, e.get("num_data"),
                             e.get("uid"), e.get("task_color")))
            elif t == "hwm_pipe_trace_entry":
                uid, st, c = e.get("uid"), e.get("stage"), e["cycle"]
                key = (tile, uid)
                if st == 3:
                    s3[key] = min(s3.get(key, c), c)
                elif st == 6:
                    s6[key] = min(s6.get(key, c), c)
            elif t == "wavelet_trace_entry":
                wav_tiles[tile] += 1
                wav_events.append((e["cycle"], tile))
    return disp, s3, s6, tiles, fp_tiles, wav_tiles, wav_events, coords


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("suite_dir", help="suite directory holding events.jsonl.gz and results.json")
    ap.add_argument("-o", "--out", required=True)
    ap.add_argument("--title", required=True)
    a = ap.parse_args()

    sd = Path(a.suite_dir)
    res = json.loads((sd / "results.json").read_text())
    rows = res["rows"]
    disp, s3, s6, tiles, fp_tiles, wav_tiles, wav_events, coords = load(sd / "events.jsonl.gz")
    wav_events.sort()
    disp_full = sorted(disp)

    app = tiles.most_common(1)[0][0]
    mine = sorted((d for d in disp if d[1] == app), key=lambda d: d[0])

    lo = min(r["t_start"] for r in rows)
    hi = max(r["t_end"] for r in rows)
    # The TSC and the trace clock need not share an origin: with a long H2D before
    # compute() they were 60k-260k cycles apart and every window landed on memcpy
    # traffic.  Maximum-coverage alignment picks the memcpy region (it is denser
    # than the benchmark), so anchor semantically instead: the first dispatch on the
    # compute PE of a benchmark DSD op -- an FP or i16 op carrying num_data >= the
    # first variant's element count, which the memcpy library never issues.
    first = rows[0]
    def is_bench_op(name, nd):
        n = (name or "").upper().split(".")[0]
        return (n.startswith("F") and not n.startswith("FMOV16")) or n.startswith(("ADD16", "FMOV16")) \
            and isinstance(nd, int) and nd >= max(2, min(first["elems"], 8))
    anchor = None
    for c, _t, nm, nd, *_ in disp_full:
        if _t == app and is_bench_op(nm, nd) and isinstance(nd, int) and nd >= max(2, min(first["elems"], 8)):
            anchor = c; break
    if anchor is not None:
        offset = anchor - first["t_start"] - 24     # DSD setup precedes the op by ~16-24 cycles
        print(f"TSC->trace offset {offset:+d} cycles (anchor {first['name']} first DSD op at {anchor})")
        for r in rows:
            r["t_start"] += offset; r["t_end"] += offset
        lo += offset; hi += offset
    inside = sum(1 for c, *_ in mine if lo <= c <= hi)
    coverage = inside / max(len(mine), 1)
    # The compute PE also executes the memcpy library's tap-and-forward code for
    # every H2D/D2H wavelet, all of it outside the variant windows, so the global
    # fraction is not a clock-alignment test.  Alignment is: every window must
    # contain dispatches.  (With real inputs this fraction dropped to ~3%.)
    empty = [r["name"] for r in rows if not any(r["t_start"] <= c <= r["t_end"] for c, *_ in mine)]
    print(f"app PE tile {app} {coords.get(app)}   dispatches {len(mine)}   "
          f"inside variant windows {coverage:.1%}   empty windows {len(empty)}")
    if len(empty) > len(rows) // 2:
        raise SystemExit(f"TSC windows do not overlap trace cycles; clock domains differ: {empty[:5]}")

    variants = []
    for r in rows:
        t0, t1 = r["t_start"], r["t_end"]
        win = [d for d in mine if t0 <= d[0] <= t1]
        instr = []
        mix = collections.Counter()
        for i, (cyc, _t, nm, nd, uid, _col) in enumerate(win):
            mix[nm] += 1
            if len(instr) >= MAX_INSTR_PER_VARIANT:
                continue
            nxt = win[i + 1][0] if i + 1 < len(win) else t1
            depth = None
            k = (app, uid)
            if k in s3 and k in s6:
                depth = s6[k] - s3[k]
            nd_val = nd if isinstance(nd, int) and nd < 65535 else 1
            instr.append([cyc - t0, max(nxt - cyc, 1), classify(nm), nm, nd_val, depth])
        import bisect, re as _re
        fab_in_window = (bisect.bisect_right(wav_events, (t1, 1 << 30))
                         - bisect.bisect_left(wav_events, (t0, -1)))
        fab_app = sum(1 for c_, tl in wav_events[bisect.bisect_left(wav_events, (t0, -1)):
                                                 bisect.bisect_right(wav_events, (t1, 1 << 30))]
                      if tl == app)
        wide = max(instr, key=lambda b: b[4]) if instr else None
        if wide is not None and wide[4] <= 1:
            wide = None          # scalar loop: no hardware-loop instruction to name
        stride = int(_re.search(r"rstride_(\d+)", r["name"]).group(1)) if r["family"] == "rstride" else 1
        flow = dict(FLOW.get(r["family"], {"srcs": ["?"], "dst": "?", "op": "?", "passes": 1}))
        flow.update({"stride": stride, "elem_bytes": ELEM_BYTES.get(r["family"], 2),
                     "wide_op": wide[3] if wide else None, "wide_nd": wide[4] if wide else None,
                     "elem_per_cyc": round(1 / r["cyc_per_elem"], 3) if r["cyc_per_elem"] else None,
                     "fabric_wavelets_in_window": fab_in_window,
                     "fabric_wavelets_at_pe": fab_app})
        variants.append({
            "flow": flow,
            "name": r["name"], "family": r["family"], "elems": r["elems"],
            "reps": r["reps"], "cycles": r["cycles"],
            "cyc_per_elem": r["cyc_per_elem"],
            "dispatches": len(win), "shown": len(instr),
            "mix": mix.most_common(5), "instr": instr})
        print(f"  {r['name']:<16} {len(win):>7} dispatches  "
              f"{'(capped at %d)' % MAX_INSTR_PER_VARIANT if len(win) > MAX_INSTR_PER_VARIANT else ''}")

    pes = []
    for t in sorted(set(tiles) | set(wav_tiles)):
        x, y = coords.get(t, (None, None))
        if x is None:
            continue
        role = ("compute" if fp_tiles.get(t) else
                "data-move" if tiles.get(t) else "router")
        pes.append({"x": x, "y": y, "role": role, "disp": tiles.get(t, 0)})

    data = {"title": a.title, "suite": res["suite"], "app": list(coords.get(app, ())),
            "coverage": round(coverage, 4), "variants": variants, "pes": pes,
            "total_pes": len(pes)}

    out = Path(a.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    page = HTML.replace("<title>Microbench Anatomy</title>",
                        f"<title>{a.title}</title>")
    out.write_text(page.replace("__DATA__", json.dumps(data, separators=(",", ":"))))
    print(f"wrote {out}  ({out.stat().st_size / 1e6:.2f} MB)")
    return 0


HTML = r"""<title>Microbench Anatomy</title>
<style>
:root{
  --ground:#F4F6F8; --surface:#FFFFFF; --surface-2:#EDF0F3;
  --ink:#12171C; --ink-2:#3D4750; --muted:#68747F; --line:#D9DFE5;
  --oxide:#0C6E77; --amber:#A8660F; --violet:#5A4B94;
  --fp:#0C6E77; --move:#5A4B94; --mem:#A8660F; --ctl:#8A96A2; --idle:#DDE3E9;
}
@media (prefers-color-scheme:dark){:root:not([data-theme="light"]){
  --ground:#0C1014; --surface:#141A20; --surface-2:#1B232B;
  --ink:#E7ECF1; --ink-2:#B6C1CB; --muted:#8797A3; --line:#26313A;
  --oxide:#4FC3CC; --amber:#E8A33F; --violet:#A99BE0;
  --fp:#4FC3CC; --move:#A99BE0; --mem:#E8A33F; --ctl:#6B7885; --idle:#222C35;
}}
:root[data-theme="dark"]{
  --ground:#0C1014; --surface:#141A20; --surface-2:#1B232B;
  --ink:#E7ECF1; --ink-2:#B6C1CB; --muted:#8797A3; --line:#26313A;
  --oxide:#4FC3CC; --amber:#E8A33F; --violet:#A99BE0;
  --fp:#4FC3CC; --move:#A99BE0; --mem:#E8A33F; --ctl:#6B7885; --idle:#222C35;
}
*{box-sizing:border-box}
body{margin:0;background:var(--ground);color:var(--ink);
  font-family:ui-sans-serif,system-ui,-apple-system,"Segoe UI",Roboto,sans-serif;
  font-size:15px;line-height:1.55}
.wrap{max-width:1180px;margin:0 auto;padding:26px 20px 56px}
header{display:flex;flex-wrap:wrap;gap:14px;align-items:baseline;
  border-bottom:1px solid var(--line);padding-bottom:13px;margin-bottom:18px}
h1{font-size:22px;margin:0;letter-spacing:-.02em;text-wrap:balance}
.eyebrow{font-size:11px;letter-spacing:.14em;text-transform:uppercase;color:var(--muted)}
.chip{font-size:10.5px;letter-spacing:.08em;text-transform:uppercase;padding:2px 7px;
  border-radius:3px;border:1px solid var(--line);color:var(--muted);white-space:nowrap}
.card{background:var(--surface);border:1px solid var(--line);border-radius:8px;padding:12px 14px}
.grid{display:grid;grid-template-columns:220px 1fr;gap:12px;align-items:start}
.vlist{display:flex;flex-direction:column;gap:2px;max-height:520px;overflow-y:auto}
.vbtn{font:inherit;font-size:12.5px;text-align:left;padding:5px 9px;border-radius:5px;
  cursor:pointer;background:transparent;color:var(--ink-2);border:1px solid transparent;
  font-family:ui-monospace,SFMono-Regular,Menlo,Consolas,monospace}
.vbtn:hover{border-color:var(--oxide)}
.vbtn[aria-pressed="true"]{background:var(--surface-2);border-color:var(--oxide);color:var(--ink)}
.vbtn small{color:var(--muted);float:right}
canvas{display:block;width:100%;height:auto}
.readout{font-family:ui-monospace,SFMono-Regular,Menlo,Consolas,monospace;font-size:12.5px;
  color:var(--ink-2);min-height:20px;margin-top:8px;font-variant-numeric:tabular-nums}
.legend{display:flex;flex-wrap:wrap;gap:14px;margin-top:10px;font-size:12.5px;color:var(--muted)}
.legend i{display:inline-block;width:11px;height:11px;border-radius:2px;margin-right:5px;vertical-align:-1px}
.stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(140px,1fr));gap:10px;margin-top:12px}
.stats .k{font-size:10.5px;letter-spacing:.09em;text-transform:uppercase;color:var(--muted)}
.stats .v{font-size:17px;margin-top:2px;font-variant-numeric:tabular-nums;
  font-family:ui-monospace,SFMono-Regular,Menlo,Consolas,monospace}
.note{margin-top:18px;padding:11px 14px;border-left:3px solid var(--violet);
  background:var(--surface);border-radius:0 6px 6px 0;font-size:13.5px;color:var(--ink-2)}
code{font-family:ui-monospace,SFMono-Regular,Menlo,Consolas,monospace;font-size:.92em}
.mini{margin-top:10px}
</style>
<div class="wrap">
<header>
  <div>
    <div class="eyebrow">Cerebras WSE-3 · single-PE microbench anatomy</div>
    <h1 id="ttl"></h1>
  </div>
  <span class="chip">cycles · simulator</span>
  <span class="chip" id="cov"></span>
</header>

<div class="grid">
  <div>
    <div class="card">
      <div class="eyebrow" style="margin-bottom:6px">Variants</div>
      <div class="vlist" id="vlist"></div>
    </div>
    <div class="card mini">
      <div class="eyebrow" style="margin-bottom:6px">Fabric context</div>
      <canvas id="mm"></canvas>
      <div style="font-size:11.5px;color:var(--muted);margin-top:6px" id="mmnote"></div>
    </div>
  </div>
  <div>
    <div class="card">
      <div class="eyebrow" style="margin-bottom:6px">Instruction timeline · <span id="vname"></span></div>
      <canvas id="tl"></canvas>
      <div class="readout" id="ro">hover an instruction</div>
      <div class="legend">
        <span><i style="background:var(--fp)"></i>FP arithmetic</span>
        <span><i style="background:var(--move)"></i>moves &amp; converts</span>
        <span><i style="background:var(--mem)"></i>loads &amp; stores</span>
        <span><i style="background:var(--ctl)"></i>control</span>
        <span>block width = cycles until next dispatch · bar under block = decode&rarr;execute depth</span>
      </div>
      <div class="stats" id="stats"></div>
    </div>
    <div class="card" style="margin-top:12px">
      <div class="eyebrow" style="margin-bottom:6px">PE dataflow &middot; <span id="dfname"></span></div>
      <canvas id="df"></canvas>
      <div class="readout" id="dfro"></div>
      <div style="font-size:11.5px;color:var(--muted);margin-top:6px">
        Left: source SRAM arrays. Middle: the compute engine and the single hardware-loop instruction
        that does the work (its element count per dispatch from the trace). Right: destination.
        <strong>Arrows are element streams, not wavelets</strong>: the DSD walks the array one element
        per step (f16 / i16 = one 16-bit word each), and the label is the measured element rate with its
        byte equivalent. Fabric wavelets (32-bit) never appear here &mdash; nothing crosses the fabric
        during a compute variant. The 8-cell strip is the SRAM bank
        interleave (bank = address bits[3:1], documented): filled cells are the banks this access
        pattern touches within any 8 consecutive words &mdash; the strided-read law (8 &rarr; 4 &rarr; 2
        &rarr; 1 elem/cyc for stride 1/2/4/8) equals the number of banks touched. Fabric traffic during
        the variant's window is counted from the wavelet trace: for compute variants it is zero &mdash;
        every byte moved is SRAM &harr; CE.
      </div>
    </div>
  </div>
</div>

<div class="note" id="capnote"></div>
<div class="note">
  Each block is one <code>hwm_dispatch_trace_entry</code> on the application PE, placed at its cycle
  within the variant's TSC window. A wide DSD op is <em>one</em> block whose element count is printed
  on it — the hardware loop. The bar under a block is that instruction's decode&rarr;execute depth
  from the pipe trace (baseline 3; the excess is stall). Evidence: <strong>simulator</strong>.
</div>
</div>

<script>
const D = __DATA__;
document.getElementById('ttl').textContent = D.title;
document.title = D.title;
document.getElementById('cov').textContent = `window coverage ${(D.coverage*100).toFixed(1)}%`;

const css = v => getComputedStyle(document.documentElement).getPropertyValue(v).trim();
const CLS = {fp:'--fp', move:'--move', mem:'--mem', ctl:'--ctl'};
let sel = 0, dpr = window.devicePixelRatio || 1;

const vlist = document.getElementById('vlist');
D.variants.forEach((v, i) => {
  const b = document.createElement('button');
  b.className = 'vbtn';
  b.innerHTML = `${v.name}<small>${v.cyc_per_elem.toFixed(3)} c/e</small>`;
  b.onclick = () => { sel = i; refresh(); };
  vlist.appendChild(b);
});

const tl = document.getElementById('tl'), ctx = tl.getContext('2d');
const ro = document.getElementById('ro');
let blocks = [];

function drawTimeline(){
  const v = D.variants[sel];
  const w = tl.parentElement.clientWidth - 30, h = 300;
  tl.width = w * dpr; tl.height = h * dpr;
  tl.style.width = w + 'px'; tl.style.height = h + 'px';
  ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  ctx.clearRect(0, 0, w, h);
  const span = Math.max(...v.instr.map(b => b[0] + b[1]), 1);
  const sx = (w - 60) / span;
  const lanes = {fp: 40, move: 100, mem: 160, ctl: 220};
  ctx.font = '10px ui-monospace,Menlo,monospace';
  ctx.fillStyle = css('--muted');
  for (const [k, y] of Object.entries(lanes)){
    ctx.fillText(k.toUpperCase(), 4, y - 16);
    ctx.strokeStyle = css('--line'); ctx.lineWidth = 1;
    ctx.beginPath(); ctx.moveTo(50, y + 14); ctx.lineTo(w - 8, y + 14); ctx.stroke();
  }
  blocks = [];
  for (const [rel, dur, cls, name, nd, depth] of v.instr){
    const x = 52 + rel * sx, bw = Math.max(dur * sx, 1.5), y = lanes[cls];
    ctx.fillStyle = css(CLS[cls]);
    ctx.fillRect(x, y - 12, bw, 24);
    if (depth !== null && depth !== undefined){
      ctx.fillStyle = css('--ink');
      ctx.globalAlpha = 0.55;
      ctx.fillRect(x, y + 15, bw, Math.min(depth - 2, 6));
      ctx.globalAlpha = 1;
    }
    if (nd > 1 && bw > 34){
      ctx.fillStyle = css('--surface');
      ctx.fillText(`${name} ×${nd.toLocaleString()}`, x + 3, y + 3);
    }
    blocks.push({x, w: bw, y: y - 12, h: 34, rel, dur, cls, name, nd, depth});
  }
  ctx.fillStyle = css('--muted');
  ctx.textAlign = 'left';  ctx.fillText('cycle 0', 52, h - 8);
  ctx.textAlign = 'right'; ctx.fillText(`+${span.toLocaleString()}`, w - 8, h - 8);
  ctx.textAlign = 'left';
}

tl.addEventListener('mousemove', ev => {
  const r = tl.getBoundingClientRect();
  const mx = ev.clientX - r.left, my = ev.clientY - r.top;
  const b = blocks.find(b => mx >= b.x && mx <= b.x + b.w && my >= b.y && my <= b.y + b.h);
  ro.textContent = b
    ? `${b.name}  @ +${b.rel.toLocaleString()} cyc   ${b.dur} cyc to next   ` +
      `elements ${b.nd.toLocaleString()}   decode→execute ${b.depth ?? '–'}`
    : 'hover an instruction';
});

const df = document.getElementById('df'), dctx = df.getContext('2d');
function drawFlow(){
  const v = D.variants[sel], F = v.flow;
  document.getElementById('dfname').textContent = v.name;
  const w = df.parentElement.clientWidth - 30, h = 236;
  df.width = w * dpr; df.height = h * dpr;
  df.style.width = w + 'px'; df.style.height = h + 'px';
  dctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  dctx.clearRect(0, 0, w, h);
  const ink = css('--ink'), muted = css('--muted'), line = css('--line');
  const fp = css('--fp'), mv = css('--move'), mem = css('--mem'), ctl = css('--ctl');
  const mono = '11px ui-monospace,Menlo,monospace';
  const box = (x, y, bw, bh, label, sub, col) => {
    dctx.fillStyle = css('--surface-2'); dctx.strokeStyle = col; dctx.lineWidth = 1.5;
    dctx.beginPath(); dctx.roundRect(x, y, bw, bh, 6); dctx.fill(); dctx.stroke();
    dctx.fillStyle = ink; dctx.font = '12.5px ui-sans-serif,system-ui,sans-serif';
    dctx.textAlign = 'center'; dctx.fillText(label, x + bw/2, y + 20);
    dctx.fillStyle = muted; dctx.font = mono;
    (sub || []).forEach((t, i) => dctx.fillText(t, x + bw/2, y + 36 + i * 13));
  };
  const arrow = (x1, y1, x2, y2, label, col) => {
    dctx.strokeStyle = col; dctx.fillStyle = col; dctx.lineWidth = 2;
    dctx.beginPath(); dctx.moveTo(x1, y1); dctx.lineTo(x2, y2); dctx.stroke();
    const a = Math.atan2(y2 - y1, x2 - x1);
    dctx.beginPath(); dctx.moveTo(x2, y2);
    dctx.lineTo(x2 - 8*Math.cos(a - .4), y2 - 8*Math.sin(a - .4));
    dctx.lineTo(x2 - 8*Math.cos(a + .4), y2 - 8*Math.sin(a + .4)); dctx.closePath(); dctx.fill();
    dctx.fillStyle = muted; dctx.font = mono; dctx.textAlign = 'center';
    dctx.fillText(label, (x1 + x2)/2, (y1 + y2)/2 - 6);
  };
  const epc = F.elem_per_cyc || 0, eb = F.elem_bytes;
  const bw = Math.min(170, (w - 120) / 3), bh = 64;
  const xs = 10, xc = w/2 - bw/2, xd = w - bw - 10;
  const n = F.srcs.length;
  F.srcs.forEach((sname, i) => {
    const y = 14 + i * (bh + 8) * (n > 1 ? 0.75 : 1);
    const isReg = /^(const|reg)/.test(sname) || /\[i\]|\[k\]/.test(sname);
    box(xs, y, bw, bh - 10, sname, [isReg ? (sname === 'const' ? 'immediate' : 'scalar / indexed') : `${v.elems.toLocaleString()} elems · ${(v.elems*eb).toLocaleString()} B`], isReg ? ctl : mem);
    arrow(xs + bw, y + (bh-10)/2, xc, 14 + (bh-10)/2 + 6, sname === 'const' ? '' : `read ${epc.toFixed(2)} elem/cyc · ${(epc*eb).toFixed(2)} B/cyc`, mem);
  });
  const ceY = 14;
  box(xc, ceY, bw, bh + 6, F.op.split('  ')[0], [
    F.wide_op ? `${F.wide_op} ×${(F.wide_nd||1).toLocaleString()} / dispatch` : 'scalar loop, 1 elem / dispatch',
    `${epc.toFixed(2)} elem/cyc measured`,
    F.passes === 1 ? '1 pass' : `${F.passes} passes`], fp);
  const dstReg = /^reg/.test(F.dst);
  box(xd, ceY + 8, bw, bh - 10, F.dst, [dstReg ? 'register file' : `${v.elems.toLocaleString()} elems · ${(v.elems*eb).toLocaleString()} B`], dstReg ? ctl : mem);
  arrow(xc + bw, ceY + (bh+6)/2, xd, ceY + 8 + (bh-10)/2, dstReg ? 'to register' : `write ${epc.toFixed(2)} elem/cyc · ${(epc*eb).toFixed(2)} B/cyc`, dstReg ? ctl : mem);

  // bank interleave strip: bank = byte address bits[3:1]
  const sy = h - 62, cw = Math.min(26, (w - 260) / 8);
  dctx.fillStyle = muted; dctx.font = mono; dctx.textAlign = 'left';
  dctx.fillText(`SRAM banks touched (stride ${F.stride}, ${eb}-byte elements):`, 10, sy - 6);
  const touched = new Set();
  for (let i = 0; i < 8; i++) touched.add(((F.stride * i * eb) >> 1) & 7);
  for (let b = 0; b < 8; b++){
    dctx.fillStyle = touched.has(b) ? mem : css('--idle');
    dctx.fillRect(10 + b * (cw + 3), sy, cw, 16);
    dctx.fillStyle = touched.has(b) ? css('--surface') : muted;
    dctx.textAlign = 'center'; dctx.fillText(String(b), 10 + b * (cw + 3) + cw/2, sy + 12);
  }
  dctx.fillStyle = muted; dctx.textAlign = 'left';
  dctx.fillText(`${touched.size} of 8 banks → ≤ ${touched.size} elem/cyc per stream on the read path`, 10 + 8*(cw+3) + 12, sy + 12);
  dctx.fillText(`fabric traffic during this variant: ${F.fabric_wavelets_in_window.toLocaleString()} wavelets on the harness, ${F.fabric_wavelets_at_pe.toLocaleString()} at this PE` +
    (F.fabric_wavelets_at_pe === 0 ? '  →  all data movement is SRAM ↔ CE' : ''), 10, h - 22);
  document.getElementById('dfro').textContent =
    `${F.op}  ·  reads ${F.srcs.filter(s => s !== 'const').length} stream(s) at ${(epc*eb).toFixed(2)} B/cyc each` +
    (dstReg ? '' : `, writes 1 stream at ${(epc*eb).toFixed(2)} B/cyc`) +
    `  ·  ${(epc*eb*(F.srcs.filter(s => s !== 'const').length + (dstReg ? 0 : 1))).toFixed(1)} B/cyc total SRAM traffic`;
}

function refresh(){
  document.querySelectorAll('.vbtn').forEach((b, i) =>
    b.setAttribute('aria-pressed', i === sel ? 'true' : 'false'));
  const v = D.variants[sel];
  document.getElementById('vname').textContent = v.name;
  const mixTxt = v.mix.map(([n, c]) => `${n}:${c}`).join('  ');
  document.getElementById('stats').innerHTML = [
    ['cycles', v.cycles.toLocaleString()],
    ['cyc / element', v.cyc_per_elem.toFixed(4)],
    ['dispatches', v.dispatches.toLocaleString()],
    ['elements × reps', `${v.elems.toLocaleString()} × ${v.reps}`],
    ['instruction mix', mixTxt],
  ].map(([k, x]) => `<div><div class="k">${k}</div><div class="v">${x}</div></div>`).join('');
  document.getElementById('capnote').textContent =
    v.dispatches > v.shown
      ? `${v.name}: showing the first ${v.shown.toLocaleString()} of ` +
        `${v.dispatches.toLocaleString()} dispatches — the preamble and steady state; ` +
        `the tail repeats the loop body.`
      : `${v.name}: all ${v.dispatches.toLocaleString()} dispatches shown.`;
  drawTimeline();
  drawFlow();
}

function drawMini(){
  const mm = document.getElementById('mm'), c2 = mm.getContext('2d');
  const xs = D.pes.map(p => p.x), ys = D.pes.map(p => p.y);
  const x0 = Math.min(...xs), x1 = Math.max(...xs);
  const y0 = Math.min(...ys), y1 = Math.max(...ys);
  const cols = x1 - x0 + 1, rows = y1 - y0 + 1;
  const w = mm.parentElement.clientWidth - 30;
  const cell = Math.max(10, Math.min(22, Math.floor(w / cols)));
  const h = rows * cell + 8;
  mm.width = w * dpr; mm.height = h * dpr;
  mm.style.width = w + 'px'; mm.style.height = h + 'px';
  c2.setTransform(dpr, 0, 0, dpr, 0, 0);
  const roleCol = {compute: css('--fp'), 'data-move': css('--move'), router: css('--ctl')};
  for (const p of D.pes){
    const x = (p.x - x0) * cell + 4, y = (p.y - y0) * cell + 4, r = cell - 4;
    if (p.role === 'router'){
      c2.strokeStyle = roleCol.router; c2.setLineDash([2, 2]);
      c2.strokeRect(x, y, r, r); c2.setLineDash([]);
    } else {
      c2.fillStyle = roleCol[p.role]; c2.globalAlpha = p.role === 'compute' ? 1 : 0.55;
      c2.fillRect(x, y, r, r); c2.globalAlpha = 1;
    }
  }
  document.getElementById('mmnote').textContent =
    `${D.total_pes} PEs active in the trace for this 1-PE benchmark — teal computes ` +
    `at (${D.app[0]},${D.app[1]}); the rest are <memcpy> harness (the compiled ` +
    `layout occupies 24 PEs; route-only ones emit no events).`;
}

window.addEventListener('resize', () => { drawMini(); drawTimeline(); drawFlow(); });
matchMedia('(prefers-color-scheme:dark)').addEventListener('change', () => { drawMini(); refresh(); });
drawMini();
refresh();
</script>
"""

if __name__ == "__main__":
    raise SystemExit(main())
