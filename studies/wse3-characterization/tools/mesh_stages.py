#!/usr/bin/env python3
"""Pipeline stages on the 2-D mesh: every PE's decode / in-flight / execute slots, the
instruction in each, its source and target, and the wavelets on the links -- one cycle at a time.

Built from the same joins as add_anatomy.py / ops_anatomy.py (dispatch trace = cycle + PC,
pipe trace stage 3 = decode and stage 6 = execute by uid, elf2am disassembly = operands by
PC) plus wavelet_trace_entry paired by `ident` across neighbouring tiles (a wavelet keeps
its ident from router to router, so consecutive observations of one ident are one hop).

Two scenes are embedded: the one-message relay (N=1, B=8: send and receive) and the
atomic-ISA body (22 basic operations on one PE).  Evidence: `simulator` for every cycle;
the fetch and writeback stages are not traced and are drawn as unobserved; what a DSR
stream points at (SRAM vs a fabric queue) is `inferred` from the wavelets that follow or
precede the op and is labelled so.
"""
from __future__ import annotations
import gzip, json, re, sys
from pathlib import Path

HERE = Path(__file__).resolve().parent.parent
MEMCPY_COLOURS = {0, 1, 2, 3, 4, 5, 21, 22, 23}
sys.path.insert(0, str(Path(__file__).resolve().parent))
from anatomy_common import load_pipe, typed_for, wavelet_fields, parse_routes, load_disasm, SCENE_LADDER

def disasm(fn, tag=None):
    """Every instruction in the ELF, labelled application / runtime / unclassified.

    `tag` is ignored (kept for call compatibility).  Filtering by source used to drop the
    <memcpy> runtime instructions that run ON an application PE; they were then reported as
    undecoded "harness" code and hidden, which removed real cycles from the picture.
    """
    return load_disasm(fn)

def load(events):
    disp, s3, s6, wav, coord = {}, {}, {}, {}, {}
    with gzip.open(events, "rt") as fh:
        for line in fh:
            e = json.loads(line); t = e.get("tile_index")
            if t is None: continue
            if t not in coord:
                sim = (e.get("coordinates") or {}).get("simulator") or {}
                if sim.get("x") is not None: coord[t] = (sim["x"], sim["y"])
            k = e.get("event_type")
            if k == "hwm_dispatch_trace_entry":
                disp.setdefault(t, []).append((e["cycle"], e.get("inst_ptr"), e["uid"], e.get("num_data"), e.get("task_color"), e.get("name")))
            elif k == "hwm_pipe_trace_entry":
                key = (t, e["uid"])
                if e.get("stage") == 3: s3[key] = min(s3.get(key, e["cycle"]), e["cycle"])
                elif e.get("stage") == 6: s6.setdefault(key, set()).add(e["cycle"])
            elif k == "wavelet_trace_entry":
                wav.setdefault(e.get("ident"), []).append((e["cycle"], t, (e.get("fields") or 0) & 0x1F, e.get("fields") or 0, e.get("data")))
    return disp, s3, s6, wav, coord

def role(t):
    if "?" in t and "jmp" in t: return "ctrl"
    if "?" in t: return "pred"
    if "[dds" in t or "[s1ds" in t or "[s0ds" in t: return "simd"
    if t.startswith(("ld16", "ld32", "ld16rp")): return "load"
    if t.startswith(("st16", "st32")): return "store"
    if t.startswith(("lddwds", "lds0wds", "lds1wds")): return "dsr"
    if t.startswith(("jmp", "actvt", "ublk", "blk")): return "ctrl"
    if t.startswith(("lt16", "ltu16", "eq16", "eq32", "lt32")): return "cmp"
    if t.startswith(("fh2s", "fs2h")): return "cvt"
    if t.startswith("nop"): return "nop"
    return "alu"

def classify(op, dsr_ctx):
    op = op.strip()
    if not op: return None
    m = re.fullmatch(r"\[(0x[0-9a-f]+)\]", op)
    if m: return {"kind": "sram", "label": f"SRAM {m.group(1)}"}
    m = re.fullmatch(r"\[(dds\d|s0ds\d|s1ds\d)\]", op)
    if m:
        d = m.group(1); c = dsr_ctx.get(d)
        return c or {"kind": "stream", "label": f"SRAM stream via {d}", "inferred": True}
    m = re.fullmatch(r"\[(r\d+)\]", op)
    if m: return {"kind": "sram", "label": f"SRAM at {m.group(1)}"}
    if re.fullmatch(r"(dds|s0ds|s1ds)\d", op): return {"kind": "dsr", "label": f"DSR {op}"}
    if re.fullmatch(r"r\d+", op): return {"kind": "gpr", "label": f"GPR {op}"}
    if re.fullmatch(r"d\d+", op): return {"kind": "gpr", "label": f"GPR pair {op}"}
    if op.startswith("cflag"): return {"kind": "flag", "label": op}
    if re.fullmatch(r"-?0x[0-9a-f]+|-?\d+", op): return {"kind": "imm", "label": f"imm {op}"}
    return {"kind": "other", "label": op}

def operands(text, dsr_ctx):
    m = re.match(r"(?:(!?cflag\d) \? )?(\S+)(?: (.*))?$", text)
    if not m: return [], None, None
    pred, mnem, rest = m.group(1), m.group(2), m.group(3) or ""
    dst = None; srcs = []
    if "=" in rest:
        d, s = rest.split("=", 1); dst = classify(d, dsr_ctx); srcs = [classify(x, dsr_ctx) for x in s.split(",")]
    elif mnem.startswith("jmp"): dst = {"kind": "pc", "label": f"PC <- {rest.strip()}"}
    elif mnem.startswith("actvt"): dst = {"kind": "task", "label": f"activate task {rest.strip()}"}
    elif rest: srcs = [classify(x, dsr_ctx) for x in rest.split(",")]
    if pred: srcs.append({"kind": "flag", "label": f"if {pred}"})
    return [s for s in srcs if s], dst, mnem

def scene(name, title, notes, events, dis_by_tile, lo, hi, focus, routes=None, offsets=(0, 0)):
    disp, s3, s6, wav, coord = load(events)
    R = parse_routes(routes, offsets) if routes else {}
    W = max(x for x, y in coord.values()) + 1
    # hops: consecutive observations of one ident on different tiles
    hops = []
    for ident, obs in wav.items():
        obs = sorted(obs)
        for (c0, t0, col, f0, d0), (c1, t1, _c, f1, _d) in zip(obs, obs[1:]):
            if t0 != t1 and lo <= c1 and c0 <= hi:
                hops.append({"src": t0, "dst": t1, "leave": c0, "arrive": c1, "colour": col, "app": col not in MEMCPY_COLOURS,
                             "link_src": wavelet_fields(f0)["link"], "link_dst": wavelet_fields(f1)["link"], "data": d0})
    hops.sort(key=lambda h: h["leave"])
    for k, h in enumerate([h for h in hops if h["app"]]): h["k"] = k + 1
    pes = {}
    for t, rows in disp.items():
        if t not in coord: continue
        dis = dis_by_tile.get(t, {})
        merged = {}
        for c, pc, uid, nd, task, nm in sorted(rows):
            if not (lo - 30 <= c <= hi): continue
            if uid in merged: merged[uid]["red"] = c; continue
            nd = nd if isinstance(nd, int) and nd < 65535 else 1
            rec = dis.get(pc); xs = sorted(s6.get((t, uid), ()))
            # "no ELF supplied for this PE" is a different statement from "this PC is not in the ELF"
            unk = "unknown" if dis else "no-disasm"
            merged[uid] = {"uid": uid, "pc": pc, "text": (rec or {}).get("text", (nm or "?").lower()),
                           "known": rec is not None, "origin": (rec or {}).get("origin", unk),
                           "source_file": (rec or {}).get("source_file", ""), "dec": s3.get((t, uid), c),
                           "disp": c, "exe": xs[0] if xs else None, "x_last": xs[-1] if xs else None,
                           "x_cycles": xs, "red": None, "nd": nd, "task": task}
        instrs = sorted(merged.values(), key=lambda i: i["disp"])
        instrs = [i for i in instrs if i["exe"] is None and lo <= i["dec"] <= hi or (i["exe"] is not None and (i["x_last"] or i["exe"]) >= lo and i["dec"] <= hi)]
        if not instrs: continue
        # DSR context per DSD op from the wavelets around it (inferred)
        for i in instrs:
            i["role"] = role(i["text"]) if i["known"] else "unknown"
            ctx = {}
            if i["nd"] > 1:
                out = [h for h in hops if h["src"] == t and h["app"] and i["disp"] <= h["leave"] <= (i["exe"] or i["disp"]) + 16]
                inn = [h for h in hops if h["dst"] == t and h["app"] and i["disp"] <= h["arrive"] <= (i["exe"] or i["disp"] + 40)]
                if out:
                    dx, dy = coord[out[0]["dst"]]; rt = R.get(coord[t], {}).get(out[0]["colour"])
                    ctx["dds1"] = {"kind": "fabout", "label": f"fabric out · colour {out[0]['colour']} → PE ({dx},{dy})" + (f" (route {rt['rx']}→{','.join(rt['tx'])}, compiled)" if rt else ""), "inferred": not rt}
                if inn:
                    sx, sy = coord[inn[0]["src"]]; rt = R.get(coord[t], {}).get(inn[0]["colour"])
                    ctx["s1ds1"] = {"kind": "fabin", "label": f"fabric in · colour {inn[0]['colour']} ← PE ({sx},{sy})" + (f" (route {rt['rx']}→{','.join(rt['tx'])}, compiled)" if rt else ""), "inferred": not rt}
            srcs, dst, mnem = operands(i["text"], ctx) if i["known"] else ([], None, i["text"])
            i["srcs"] = srcs; i["dst"] = dst; i["mnem"] = mnem
        x, y = coord[t]
        pes[t] = {"x": x, "y": y, "app": any(i["origin"] == "application" for i in instrs), "instrs": instrs}
    app_tiles = {t for t, p in pes.items() if p["app"]}
    pv = load_pipe(events, app_tiles)
    for t in app_tiles:
        for i in pes[t]["instrs"]:
            mn = i["text"].split(" ")[0]; raw = pv.get((t, i["uid"]), {}).get("elems", [])
            i["vals"] = [{"cycle": x["cycle"], "idx": x["idx"], "lane": x["lane"], "dest": typed_for(mn, x["dest"]), "src0": typed_for(mn, x["src0"], "src0"),
                          "src1": typed_for(mn, x["src1"], "src1"), "src2": typed_for(mn, x["src2"], "src2")} for x in raw][:64]
    # the box spans every PE that dispatched at any time (the harness ring gives the mesh its context)
    ever = [coord[t] for t in disp if t in coord and len(disp[t]) > 4]
    xs = [x for x, y in ever]; ys = [y for x, y in ever]
    return {"name": name, "title": title, "notes": notes, "ladder": SCENE_LADDER.get(name), "lo": lo, "hi": hi, "W": W, "focus": focus,
            "box": [min(xs), min(ys), max(xs), max(ys)], "pes": pes, "hops": hops,
            "ever": sorted(t for t in disp if t in coord and len(disp[t]) > 4),
            "routes": {f"{x},{y}": {str(c): {"rx": v["rx"], "tx": v["tx"]} for c, v in d.items()} for (x, y), d in R.items()},
            "coord": {str(t): list(c) for t, c in coord.items()}}

def main():
    relay = HERE / "microbench" / "relay"; ops = HERE / "microbench" / "atomic_ops"
    scenes = []
    scenes.append(scene("relay", "One message: PE (4,1) sends 8 words to PE (5,1)",
        "microbench/relay at N=1, B=8. The sender's fmov32.nf streams 8 SRAM words into an output queue; the receiver's fmov32.nf was dispatched before any data existed and waits in the pipe until the first wavelet reaches its router. The other PEs in the row run the <memcpy> runtime; their instructions are decoded from their own ELFs and can be shown with the toggle.",
        relay / "events_n1b8.jsonl.gz", {20: disasm(relay / "disasm_pe0.json", "relay"), 21: disasm(relay / "disasm_pe1.json", "relay")}, 356, 398, {"tile": 20, "cycle": 384},
        routes=relay / "routes_N1_B8.txt", offsets=(4, 1)))
    dis = disasm(ops / "disasm.json", "atomic_ops")
    d_ops, *_ = load(ops / "events.jsonl.gz")
    app_pc = lambda d, pc: (d.get(pc) or {}).get("origin") == "application"
    first = min(c for c, pc, *_r in d_ops[12] if c >= 5000 and app_pc(dis, pc))
    scenes.append(scene("ops", "The atomic ISA body on PE (2,1)",
        "microbench/atomic_ops: 22 basic operations written once each, as the compiler scheduled them. One application PE. Runtime instructions that execute on it between the markers are shown and badged; the surrounding PEs run the <memcpy> runtime and are quiet during the body.",
        ops / "events.jsonl.gz", {12: dis}, first - 2, first + 182, {"tile": 12, "cycle": first + 4}, routes=ops / "routes.txt", offsets=(4, 1)))
    opt = ops / "ir_cap" / "optnone_sim"
    if (opt / "events_optnone.jsonl.gz").exists():
        dis_o = disasm(opt / "disasm_optnone.json", "atomic_ops")
        d_o, *_ = load(opt / "events_optnone.jsonl.gz")
        first_o = min(c for c, pc, *_r in d_o[12] if c >= 5000 and app_pc(dis_o, pc))
        scenes.append(scene("ops_optnone", "The atomic ISA body, optnone build: every form isolated",
            "The same 22 operations rebuilt from cslc's own LLVM IR with `noinline optnone` on compute() (tools/cslc_ir.py), then run on the simulator: all forms verified, all 23 markers dispatch in program order, and each form is exactly its own loads, op and store. Loads are no longer shared, the if/else forms become real jumps, and the loop keeps its counter on the stack — the price of isolation is 267 cycles from the first marker's dispatch to the END marker's dispatch, against 171 for the optimised build (the same measure the ISA page reports).",
            opt / "events_optnone.jsonl.gz", {12: dis_o}, first_o - 2, first_o + 276, {"tile": 12, "cycle": first_o + 4}, routes=ops / "routes.txt", offsets=(4, 1)))
    out = HERE / "results" / "anatomy" / "mesh_stages.html"
    out.write_text(HTML.replace("__DATA__", json.dumps(scenes)))
    for s in scenes:
        n_app = sum(1 for p in s["pes"].values() if p["app"]); n_ins = sum(len(p["instrs"]) for p in s["pes"].values())
        print(f"{s['name']:<6} cycles {s['lo']}..{s['hi']}  PEs shown {len(s['pes'])} (app {n_app})  instructions {n_ins}  hops {len(s['hops'])} (app {sum(h['app'] for h in s['hops'])})  box {s['box']}")
    print("wrote", out)

HTML = r"""<title>Pipeline Stages on the Mesh</title>
<style>
:root{--ground:#F4F6F8;--surface:#FFFFFF;--surface-2:#EDF0F3;--ink:#12171C;--ink-2:#3D4750;--muted:#68747F;--line:#D9DFE5;
  --oxide:#0C6E77;--amber:#A8660F;--violet:#5A4B94;--rose:#A33A5B;--moss:#3F7A3A;--slate:#4A6070;--idle:#E3E8ED;--wait:#F1D7A8;--wave:#0C6E77;--hz:#B9C3CC}
@media (prefers-color-scheme:dark){:root:not([data-theme="light"]){--ground:#0C1014;--surface:#141A20;--surface-2:#1B232B;--ink:#E7ECF1;--ink-2:#B6C1CB;--muted:#8797A3;--line:#26313A;
  --oxide:#4FC3CC;--amber:#E8A33F;--violet:#A99BE0;--rose:#E48AA6;--moss:#8CC985;--slate:#93AABB;--idle:#222C35;--wait:#4A3A1C;--wave:#4FC3CC;--hz:#3A4854}}
:root[data-theme="dark"]{--ground:#0C1014;--surface:#141A20;--surface-2:#1B232B;--ink:#E7ECF1;--ink-2:#B6C1CB;--muted:#8797A3;--line:#26313A;
  --oxide:#4FC3CC;--amber:#E8A33F;--violet:#A99BE0;--rose:#E48AA6;--moss:#8CC985;--slate:#93AABB;--idle:#222C35;--wait:#4A3A1C;--wave:#4FC3CC;--hz:#3A4854}
*{box-sizing:border-box}body{margin:0;background:var(--ground);color:var(--ink);font-family:ui-sans-serif,system-ui,-apple-system,"Segoe UI",Roboto,sans-serif;font-size:14.5px;line-height:1.5}
.wrap{max-width:1240px;margin:0 auto;padding:22px 20px 60px}
header{border-bottom:1px solid var(--line);padding-bottom:12px;margin-bottom:14px;display:flex;gap:14px;flex-wrap:wrap;align-items:baseline}
h1{font-size:21px;margin:0;letter-spacing:-.02em}h2{font-size:15px;margin:22px 0 6px}
.eyebrow{font-size:11px;letter-spacing:.14em;text-transform:uppercase;color:var(--muted)}
.chip{font-size:10.5px;letter-spacing:.08em;text-transform:uppercase;padding:2px 7px;border-radius:3px;border:1px solid var(--line);color:var(--muted)}
.card{background:var(--surface);border:1px solid var(--line);border-radius:8px;padding:12px 14px;margin-top:10px}
.mono{font-family:ui-monospace,SFMono-Regular,Menlo,Consolas,monospace;font-size:.92em;font-variant-numeric:tabular-nums}
.tabs{display:flex;gap:6px;margin:10px 0 0}.tab{padding:6px 12px;border:1px solid var(--line);border-radius:6px;background:var(--surface);cursor:pointer;font-size:13px;color:var(--ink-2)}.tab[aria-selected="true"]{border-color:var(--oxide);color:var(--oxide);font-weight:600}
.ctl{display:flex;gap:10px;align-items:center;flex-wrap:wrap;margin-top:10px}
.ctl button{padding:5px 10px;border:1px solid var(--line);border-radius:6px;background:var(--surface);color:var(--ink);cursor:pointer;font-size:13px}
.ctl button:focus-visible,.tab:focus-visible{outline:2px solid var(--oxide);outline-offset:2px}
.ctl input[type=range]{flex:1;min-width:220px;accent-color:var(--oxide)}
.cyc{font-size:22px;font-weight:600;letter-spacing:-.02em;min-width:110px}
.lad{display:grid;grid-template-columns:1fr 1.4fr;gap:0;border:1px solid var(--line);border-radius:8px;overflow:hidden;background:var(--surface);margin-top:10px}
@media(max-width:820px){.lad{grid-template-columns:1fr}}
.lad>div{padding:11px 14px;border-right:1px solid var(--line)}
.lad>div:last-child{border-right:0}
@media(max-width:820px){.lad>div{border-right:0;border-bottom:1px solid var(--line)}}
.lad pre{margin:5px 0 0;font-family:ui-monospace,Menlo,monospace;font-size:11.5px;line-height:1.55;white-space:pre-wrap;color:var(--ink)}
.lad p{margin:5px 0 0;font-size:12.5px;color:var(--ink-2)}
.diverge{margin-top:8px;padding:9px 13px;border-left:3px solid var(--amber);background:var(--surface);border-radius:0 6px 6px 0;font-size:12.5px;color:var(--ink-2)}
.ev{display:inline-block;font-size:9.5px;letter-spacing:.08em;text-transform:uppercase;padding:1px 6px;border-radius:2px;border:1px solid;margin-left:4px;vertical-align:1px;white-space:nowrap}.ev-dep{color:var(--violet);border-color:var(--violet)}.ev-delay{color:var(--amber);border-color:var(--amber)}.ev-stall{color:var(--oxide);border-color:var(--oxide)}
.scroll{overflow-x:auto}
svg text{font-family:ui-monospace,Menlo,monospace}
.legend{display:flex;gap:14px;flex-wrap:wrap;font-size:12px;color:var(--ink-2);margin-top:8px}.legend span::before{content:"";display:inline-block;width:11px;height:11px;border-radius:2px;margin-right:5px;vertical-align:-1px}
.l-D::before{background:var(--violet)}.l-f::before{background:var(--hz)}.l-X::before{background:var(--oxide)}.l-w::before{background:var(--wait)}.l-wv::before{background:var(--wave);border-radius:50%!important}
table{border-collapse:collapse;width:100%;font-size:12.5px}th{font-size:10.5px;letter-spacing:.09em;text-transform:uppercase;color:var(--muted);text-align:left;padding:5px 8px;border-bottom:1px solid var(--line)}
td{padding:4px 8px;border-bottom:1px solid var(--line);vertical-align:top}tr.now td{background:var(--surface-2)}
.log li{margin:3px 0;font-size:13px}.log .pe{font-weight:600}.log .inf{color:var(--muted);font-size:11px;letter-spacing:.06em;text-transform:uppercase}
.pipe{border-collapse:separate;border-spacing:2px;font-family:ui-monospace,Menlo,monospace;font-size:10.5px}
.pipe td{padding:0;border:0;width:18px;min-width:18px;height:18px;text-align:center;border-radius:3px;background:var(--idle);color:var(--ink)}
.pipe td.lbl{width:auto;min-width:0;text-align:left;padding:0 8px 0 2px;background:transparent;white-space:nowrap}
.pipe td.D{background:var(--violet);color:#fff}.pipe td.X{background:var(--oxide);color:#fff}.pipe td.f{background:var(--hz)}.pipe td.w{background:var(--wait)}.pipe td.now{outline:2px solid var(--amber);outline-offset:-2px}
.pipe td.Xm{background:var(--oxide);color:#fff;opacity:.75}.pipe td.Xl{background:var(--oxide);color:#fff}.pipe td.run{background:var(--oxide);opacity:.32}
.orig{font-size:9px;letter-spacing:.06em;text-transform:uppercase;color:var(--muted);border:1px solid var(--line);border-radius:3px;padding:0 3px;margin-right:4px}
.pipe th{padding:0;text-align:center;font-size:9px;border:0;color:var(--muted)}
.grid2{display:grid;grid-template-columns:minmax(0,1fr) minmax(0,1fr);gap:12px}@media(max-width:900px){.grid2{grid-template-columns:1fr}}
.note{margin-top:10px;padding:10px 14px;border-left:3px solid var(--violet);background:var(--surface);border-radius:0 6px 6px 0;font-size:13px;color:var(--ink-2)}
</style>
<div class="wrap">
<header><div><div class="eyebrow">Cerebras WSE-3 · 2-D mesh · one cycle at a time</div><h1>Pipeline Stages on the Mesh</h1></div><span class="chip">cycles · simulator</span><span class="chip">stages 3 and 6 traced</span><span class="chip">wavelets paired by ident</span></header>
<p style="color:var(--ink-2);margin:0">Each tile is a PE. Inside it, four slots are the traced pipeline: <strong>D</strong> (stage 3, dispatch/decode), two in-flight stages, <strong>X</strong> (stage 6, execute). The line under the slots names the source and target of the instruction executing this cycle. Wavelets travel the links between tiles at the cycles the routers recorded them. Click a tile for its full instruction table and pipeline chart.</p>
<div class="tabs" role="tablist" id="tabs"></div>
<p id="notes" style="color:var(--ink-2);font-size:13.5px;margin:8px 0 0"></p>
<div id="scenecode"></div>
<div class="ctl"><button id="b0" title="first">|◀</button><button id="bm">◀ 1</button><button id="play">▶ play</button><button id="bp">1 ▶</button><button id="b9" title="last">▶|</button><input type="range" id="rng"><div class="cyc mono" id="cyc"></div><label style="font-size:13px;color:var(--ink-2)"><input type="checkbox" id="harness"> also show &lt;memcpy&gt; runtime instructions on the surrounding PEs</label></div>
<div class="card scroll" id="mesh"></div>
<div class="legend"><span class="l-D">D — dispatched &amp; decoded (stage 3)</span><span class="l-f">the two cycles between the decode and execute records — stages 4–5, untraced, inferred from the stage numbering; not decode</span><span class="l-X">X — an execute record (stage 6); ■ the last one</span><span class="l-w">waiting — dispatched, data not yet arrived</span><span class="l-wv">wavelet on a link</span></div>
<p style="font-size:12.5px;color:var(--ink-2);margin:6px 0 0">A DSD instruction produces one execute record per element, so it holds the X slot across every cycle in which the trace recorded one; ≈ marks the cycles in between, where the hardware loop is still running. Those are not idle cycles, and the instruction is not removed after its first record.</p>
<div class="grid2">
  <div class="card"><div class="eyebrow">this cycle, across the mesh</div><ul class="log" id="log" style="padding-left:16px;margin:6px 0"></ul></div>
  <div class="card"><div class="eyebrow" id="seltitle">selected PE</div><div id="sel"></div></div>
</div>
<h2>Selected PE, whole window</h2>
<div class="card scroll" id="chart"></div>
<div class="note"><strong>What is measured and what is drawn.</strong> Timing statements on this page carry one of three labels: <span class="ev ev-dep">dependency identified</span> (a producer–consumer relation exists in the code), <span class="ev ev-delay">delay observed</span> (the trace shows a gap; cause not isolated), <span class="ev ev-stall">stall cause supported</span> (a controlled experiment varied the cause and the delay followed). D and X cells are trace records (stage 3 and stage 6, joined by uid). The two in-flight cells between them are drawn because the stage numbers imply them; when an instruction takes longer than 3 cycles from decode to execute, the extra cycles are drawn in the last in-flight slot as a layout choice only: the trace does not say where within stages 4–5 the delay sits, or whether it is a stall at all <span class="ev ev-delay">delay observed</span>. Fetch and writeback are not traced and are not drawn. Values shown after "=" are the operands the execute stage recorded (one record per element and lane for a DSD op), and the annotation says which record of how many is landing this cycle. Instructions are labelled application or <code>&lt;memcpy&gt;</code> runtime by the source file their code came from, not by whether a mnemonic decoded; a PC absent from a supplied ELF is labelled <em>unknown</em>, and a PE whose ELF this page was not given is labelled <em>no-disasm</em> (its mnemonic still comes from the trace). Both stay visible, because hiding them would turn their cycles into apparent bubbles. Wavelet labels give the link each record was taken on (R = the PE's own ramp, E/N/S/W = a link), decoded from the trace's field bits exactly as csdb renders them, and each tile shows the compiled route (<code>cslc --out-routes</code>: receive side → transmit side) for the colours crossing it. A DSR stream's target is confirmed by that route where one exists and marked <em>inferred</em> otherwise; SRAM addresses, registers and immediates are read from the disassembly.</div>
</div>
<script>
const SCENES = __DATA__;
const esc = s => String(s).replace(/</g,'&lt;');
const roleColor = {load:'var(--amber)', store:'var(--amber)', alu:'var(--oxide)', cmp:'var(--rose)', ctrl:'var(--rose)', pred:'var(--rose)', dsr:'var(--violet)', simd:'var(--oxide)', cvt:'var(--rose)', nop:'var(--muted)', unknown:'var(--muted)', 'no-disasm':'var(--muted)'};
let S, cyc, sel, timer = null, showRuntime = false;
const $ = id => document.getElementById(id);

// pipeline state of one instruction at cycle c: {stage: 'D'|4|5|'X'|'wait'|'stall'|null}
// Every execute record the trace holds for this instruction, in order.  A DSD op has one
// per element, so it stays live from its first record to its last; the cycles in between are
// the loop running, never idle time, and the instruction is not removed after its first X.
function stateAt(i, c){
  if (c < i.dec) return null;
  if (i.red !== null && c < i.red) return c === i.dec ? 'D' : 'wait';
  const base = i.red !== null ? i.red : i.dec;
  if (c === base) return 'D';
  const xs = (i.x_cycles && i.x_cycles.length) ? i.x_cycles : (i.exe !== null ? [i.exe] : []);
  if (!xs.length) return null;                       // no execute record (jumps): where it resolves is not observed
  const last = xs[xs.length - 1];
  if (c > last) return null;
  if (xs.indexOf(c) >= 0) return c === xs[0] ? 'X' : (c === last ? 'Xl' : 'Xm');
  if (c < xs[0]){ const k = c - base; return k === 1 ? 4 : k === 2 ? 5 : 'stall'; }
  return 'run';
}
const nExec = i => (i.x_cycles && i.x_cycles.length) ? i.x_cycles.length : (i.exe !== null ? 1 : 0);
const execIdx = (i, c) => (i.x_cycles || []).indexOf(c) + 1;
// An instruction is application or runtime by where its code came from.  Application and
// unclassified instructions are always shown; runtime (<memcpy>) instructions are shown on an
// application PE because they interleave with the body and consume its cycles.
const visible = (i, p) => i.origin !== 'runtime' || p.app || showRuntime;
const opLabel = o => o ? o.label : '?';
const srcDst = i => {
  if (!i.known) return i.origin === 'no-disasm'
    ? 'no ELF was supplied for this PE, so the mnemonic comes from the trace and the operands are undecoded'
    : 'unknown: this PC is not in this PE\'s ELF disassembly, so its operands are undecoded';
  const s = i.srcs.map(opLabel).join(', ');
  return (s ? s : '—') + ' → ' + (i.dst ? opLabel(i.dst) : (i.mnem && i.mnem.startsWith('st') ? '' : '—'));
};
const inferred = i => (i.srcs||[]).some(o => o.inferred) || (i.dst && i.dst.inferred);
// values the datapath used, from the stage-6 records: scalar = one record; DSD = one per element (shown for the cycle c, or all)
const valsAt = (i, c) => { const e = i.vals || []; if (!e.length) return '';
  if (e.length === 1) { const x = e[0]; const s = [x.src0, x.src1, x.src2].filter(Boolean).join(', '); return `${x.dest || '(flag)'}${s ? ' ← ' + s : ''}`; }
  const now = c === undefined ? e : e.filter(x => x.cycle === c); const pick = now.length ? now : e;
  const lanes = pick.map(x => x.lane).filter(l => l !== null && l !== undefined);
  return `${pick.length} lane${pick.length>1?'s':''} (${Math.min(...lanes)}–${Math.max(...lanes)}): ` + pick.slice(0, 2).map(x => `e${x.idx}: ${[x.src0, x.src1, x.src2].filter(Boolean).map(v => v.split(' ')[0]).join(', ')} → ${(x.dest||'').split(' ')[0]}`).join('; ') + (pick.length > 2 ? ' …' : ''); };
const routesFor = t => { const p = S.pes[t] || {}; const r = S.routes[`${p.x},${p.y}`] || {}; const cols = [...new Set(S.hops.filter(h => h.app && (h.src === t || h.dst === t)).map(h => h.colour))];
  return cols.map(c => r[String(c)] ? `c${c}: ${r[String(c)].rx}→${r[String(c)].tx.join(',')}` : '').filter(Boolean).join('  '); };

function buildTabs(){
  $('tabs').innerHTML = SCENES.map((s, k) => `<button class="tab" role="tab" aria-selected="${k===0}" data-k="${k}">${esc(s.title)}</button>`).join('');
  $('tabs').querySelectorAll('.tab').forEach(b => b.onclick = () => setScene(+b.dataset.k));
}
function setScene(k){
  S = SCENES[k]; cyc = S.focus.cycle; sel = S.focus.tile;
  $('tabs').querySelectorAll('.tab').forEach((b, j) => b.setAttribute('aria-selected', j === k));
  $('notes').textContent = S.notes;
  const L = S.ladder;
  $('scenecode').innerHTML = !L ? '' : `<div class="lad">
      <div><span class="eyebrow">what is running</span><p>${esc(L.intent)}</p></div>
      <div><span class="eyebrow">the same thing in C</span><pre>${esc(L.c)}</pre></div>
    </div>${L.differs ? `<div class="diverge"><strong>Where C and the WSE part company.</strong> ${esc(L.differs)}</div>` : ''}`;
  const r = $('rng'); r.min = S.lo; r.max = S.hi; r.value = cyc;
  render();
}
function pesShown(){
  const [x0,y0,x1,y1] = S.box; const out = [];
  for (let y = y0; y <= y1; y++) for (let x = x0; x <= x1; x++){
    const t = y * S.W + x; const p = S.pes[t];
    out.push({t, x, y, p: p || null, ever: S.ever.includes(t)});
  }
  return out;
}
function render(){
  $('cyc').textContent = 'cycle ' + cyc; $('rng').value = cyc;
  renderMesh(); renderLog(); renderSel(); renderChart();
}
function renderMesh(){
  const [x0,y0,x1,y1] = S.box; const TW = 196, TH = 122, GX = 34, GY = 30, PAD = 16;
  const cols = x1 - x0 + 1, rows = y1 - y0 + 1;
  const w = PAD*2 + cols*TW + (cols-1)*GX, h = PAD*2 + rows*TH + (rows-1)*GY;
  const px = x => PAD + (x - x0) * (TW + GX), py = y => PAD + (y - y0) * (TH + GY);
  let g = `<svg viewBox="0 0 ${w} ${h}" width="${w}" height="${h}" style="display:block;max-width:none">`;
  // links between horizontally / vertically adjacent shown tiles
  for (const {x, y} of pesShown()){
    if (x < x1) g += `<line x1="${px(x)+TW}" y1="${py(y)+TH/2}" x2="${px(x+1)}" y2="${py(y)+TH/2}" stroke="var(--line)" stroke-width="2"/>`;
    if (y < y1) g += `<line x1="${px(x)+TW/2}" y1="${py(y)+TH}" x2="${px(x)+TW/2}" y2="${py(y+1)}" stroke="var(--line)" stroke-width="2"/>`;
  }
  for (const {t, x, y, p, ever} of pesShown()){
    const X = px(x), Y = py(y); const isSel = t === sel; const app = p && p.app;
    g += `<g style="cursor:pointer" onclick="selectPE(${t})"><rect x="${X}" y="${Y}" width="${TW}" height="${TH}" rx="7" fill="var(--surface)" stroke="${isSel ? 'var(--amber)' : (app ? 'var(--oxide)' : 'var(--line)')}" stroke-width="${isSel ? 2.5 : 1.2}"/>`;
    g += `<text x="${X+9}" y="${Y+15}" font-size="11" fill="var(--ink)" font-weight="600">PE (${x},${y})</text>`;
    g += `<text x="${X+TW-9}" y="${Y+15}" font-size="9.5" fill="var(--muted)" text-anchor="end" letter-spacing=".08em">${app ? 'APPLICATION' : (p ? 'MEMCPY RUNTIME' : (ever ? 'RUNTIME · QUIET' : 'IDLE'))}</text>`;
    // slots
    const slots = {D:null, 4:null, 5:null, X:null}; let waiting = null, stall = null, running = null, xst = null;
    if (p) for (const i of p.instrs){
      if (!visible(i, p)) continue;
      const st = stateAt(i, cyc); if (!st) continue;
      if (st === 'wait') waiting = i;
      else if (st === 'stall') stall = i;
      else if (st === 'run') running = i;
      else if (st === 'X' || st === 'Xm' || st === 'Xl'){ slots.X = i; xst = st; }
      else slots[st] = i;
    }
    const names = ['D','4','5','X'], keys = ['D',4,5,'X'], SW = 40, SX = X + 9, SY = Y + 24;
    keys.forEach((k, j) => {
      let i = slots[k]; const isRun = (k === 'X' && !i && running); if (isRun) i = running;
      const fill = i ? (k === 'D' ? 'var(--violet)' : k === 'X' ? (isRun ? 'rgba(12,110,119,.35)' : 'var(--oxide)') : 'var(--hz)') : 'var(--idle)';
      const stalled = (k === 5 && stall);
      g += `<rect x="${SX + j*(SW+3)}" y="${SY}" width="${SW}" height="30" rx="4" fill="${stalled ? 'var(--wait)' : fill}"/>`;
      const glyph = (k === 'X' && i) ? (isRun ? '\u2248' : (xst === 'Xl' && nExec(i) > 1 ? '\u25a0' : 'X')) : names[j];
      g += `<text x="${SX + j*(SW+3) + SW/2}" y="${SY+10}" font-size="8" text-anchor="middle" fill="${i && !stalled && k !== 4 && k !== 5 ? '#fff' : 'var(--muted)'}">${glyph}</text>`;
      const lab = i ? i.mnem || i.text.split(' ')[0] : (stalled ? stall.mnem : '');
      if (lab) g += `<text x="${SX + j*(SW+3) + SW/2}" y="${SY+23}" font-size="9" text-anchor="middle" fill="${i && (k==='D'||k==='X') ? '#fff' : 'var(--ink)'}">${esc(lab.slice(0,8))}${(i && i.nd > 1) ? '×'+i.nd : ''}</text>`;
    });
    // annotation: executing instruction's src -> dst, else waiting
    const ex = slots['X'];
    let ann = '', annColor = 'var(--ink-2)';
    if (ex) { const v = valsAt(ex, cyc); const n = nExec(ex); const k = execIdx(ex, cyc);
              ann = srcDst(ex) + (v ? ' = ' + v : '') + (n > 1 ? ` [execute record ${k} of ${n}]` : ''); }
    else if (running) { ann = `${running.mnem || running.text} still running: ${execIdx(running, running.x_cycles[0])} of ${nExec(running)} execute records done`; annColor = 'var(--muted)'; }
    else if (waiting) { ann = `waiting ${cyc - waiting.dec} cyc for ${waiting.srcs.map(opLabel).join(', ') || 'data'}`; annColor = 'var(--amber)'; }
    else if (stall) { ann = `delayed past the 3-cycle depth: ${srcDst(stall)}`; annColor = 'var(--amber)'; }
    else if (slots['D']) { ann = 'decoding ' + esc(slots['D'].text); annColor = 'var(--muted)'; }
    else if (p && !app && !showRuntime) { ann = '<memcpy> runtime — toggle to show'; annColor = 'var(--muted)'; }
    if (ann){
      const lines = wrap(ann, 36);
      lines.slice(0,3).forEach((l, j) => g += `<text x="${X+9}" y="${Y+70+j*12}" font-size="9.5" fill="${annColor}">${esc(l)}</text>`);
    }
    const rt = p ? routesFor(t) : '';
    if (rt) g += `<text x="${X+TW-9}" y="${Y+TH-6}" font-size="8.5" text-anchor="end" fill="var(--muted)">route ${esc(rt)}</text>`;
    if (waiting && ex) g += `<rect x="${X+TW-14}" y="${Y+22}" width="7" height="7" fill="var(--wait)" rx="1"/>`;
    g += `</g>`;
  }
  // wavelets in flight or about to be: position along the link
  for (const hz of S.hops){
    if (!(hz.leave <= cyc && cyc <= hz.arrive)) continue;
    const a = S.coord[hz.src], b = S.coord[hz.dst]; if (!a || !b) continue;
    if (a[0] < x0 || a[0] > x1 || b[0] < x0 || b[0] > x1 || a[1] < y0 || a[1] > y1 || b[1] < y0 || b[1] > y1) continue;
    const f = hz.arrive === hz.leave ? 1 : (cyc - hz.leave) / (hz.arrive - hz.leave);
    const ax = px(a[0]) + TW/2, ay = py(a[1]) + TH/2, bx = px(b[0]) + TW/2, by = py(b[1]) + TH/2;
    // start at the edge of the source tile, end at the edge of the destination tile
    const sx = ax + Math.sign(bx-ax) * TW/2, ex = bx - Math.sign(bx-ax) * TW/2, sy = ay + Math.sign(by-ay) * TH/2, ey = by - Math.sign(by-ay) * TH/2;
    const X = sx + (ex - sx) * f, Y = sy + (ey - sy) * f;
    const col = hz.app ? 'var(--wave)' : 'var(--muted)';
    g += `<circle cx="${X}" cy="${Y}" r="${hz.app ? 6 : 3.5}" fill="${col}" opacity="${hz.app ? 1 : .6}"/>`;
    if (hz.app) g += `<text x="${X}" y="${Y - 9}" font-size="9" text-anchor="middle" fill="var(--ink-2)">w${hz.k} · c${hz.colour} · ${hz.link_src}→${hz.link_dst}${hz.data !== null && hz.data !== undefined ? ' · ' + hz.data : ''}</text>`;
  }
  g += '</svg>';
  $('mesh').innerHTML = g;
}
function wrap(s, n){ const out = []; let cur = ''; for (const w of s.split(' ')){ if ((cur + ' ' + w).trim().length > n && cur){ out.push(cur); cur = w; } else cur = (cur + ' ' + w).trim(); } if (cur) out.push(cur); return out; }
function renderLog(){
  const items = [];
  for (const [t, p] of Object.entries(S.pes)){
    for (const i of p.instrs){
      if (!visible(i, p)) continue;
      const st = stateAt(i, cyc); if (!st || st === 4 || st === 5 || st === 'run') continue;
      const pe = `<span class="pe">PE (${p.x},${p.y})</span>`;
      if (st === 'D') items.push(`${pe} dispatches <span class="mono">${esc(i.text)}</span>${i.nd>1?` ×${i.nd}`:''}${i.red!==null && cyc===i.red ? ' <span class="inf">re-dispatch: data arrived</span>' : ''}`);
      else if (st === 'X' || st === 'Xm' || st === 'Xl') { const v = valsAt(i, cyc); const n = nExec(i);
        const lead = st === 'X' ? (n > 1 ? `begins executing (record 1 of ${n})` : 'executes') : (st === 'Xl' ? `completes (record ${n} of ${n})` : `executes (record ${execIdx(i, cyc)} of ${n})`);
        items.push(`${pe} ${lead} <span class="mono">${esc(i.mnem||i.text)}</span>: ${esc(srcDst(i))}${v ? ` <span class="mono">= ${esc(v)}</span>` : ''}${i.origin !== 'application' ? ` <span class="inf">${i.origin}</span>` : ''}${inferred(i) ? ' <span class="inf">target inferred</span>' : ''}`); }
      else if (st === 'wait' && cyc === i.dec + 1) items.push(`${pe} holds <span class="mono">${esc(i.mnem)}</span> — its source is ${esc(i.srcs.map(opLabel).join(', '))}, nothing has arrived`);
      else if (st === 'stall' && cyc === (i.red ?? i.dec) + 3) items.push(`${pe} <span class="mono">${esc(i.mnem)}</span> is delayed beyond the 3-cycle decode→execute depth (delay observed; its location within stages 4–5 is not recorded)`);
    }
  }
  for (const hz of S.hops){
    if (!hz.app) continue; const a = S.coord[hz.src], b = S.coord[hz.dst];
    if (hz.leave === cyc) items.push(`<span class="pe">link (${a[0]},${a[1]}) → (${b[0]},${b[1]})</span> wavelet ${hz.k} (colour ${hz.colour}, payload ${hz.data}) recorded at the sender's router on its ${hz.link_src === 'R' ? 'ramp (R)' : hz.link_src + ' link'}`);
    if (hz.arrive === cyc) items.push(`<span class="pe">link (${a[0]},${a[1]}) → (${b[0]},${b[1]})</span> wavelet ${hz.k} recorded at the receiver's router on the ${hz.link_dst} link, ${hz.arrive - hz.leave} cycles later`);
  }
  $('log').innerHTML = items.length ? items.map(x => `<li>${x}</li>`).join('') : '<li style="color:var(--muted)">nothing dispatched, executed or on an application link this cycle</li>';
}
function renderSel(){
  const p = S.pes[sel]; $('seltitle').textContent = p ? `PE (${p.x},${p.y}) — instructions in this window` : 'selected PE';
  if (!p){ $('sel').innerHTML = '<p style="color:var(--muted)">no dispatches in this window</p>'; return; }
  let h = '<div class="scroll" style="max-height:340px;overflow-y:auto"><table><tr><th>D</th><th>X first</th><th>X last</th><th>origin</th><th>instruction</th><th>source(s) → target</th><th>values at X</th></tr>';
  for (const i of p.instrs.filter(x => visible(x, p))){
    const now = stateAt(i, cyc);
    h += `<tr class="${now ? 'now' : ''}"><td class="mono">${i.dec}${i.red!==null?`<br><span style="color:var(--muted)">re ${i.red}</span>`:''}</td><td class="mono">${i.exe ?? '—'}</td><td class="mono">${nExec(i)>1 ? i.x_last : ''}</td><td style="font-size:11px;color:var(--muted)">${i.origin}</td><td class="mono" style="color:${roleColor[i.role]||'inherit'}">${esc(i.text)}${i.nd>1?` <span style="color:var(--muted)">×${i.nd}</span>`:''}</td><td style="font-size:12px">${esc(srcDst(i))}${inferred(i)?' <span class="inf" style="color:var(--muted);font-size:10px;letter-spacing:.06em">INFERRED</span>':''}</td><td class="mono" style="font-size:11px">${esc(valsAt(i))}</td></tr>`;
  }
  $('sel').innerHTML = h + '</table></div>';
}
function renderChart(){
  const p = S.pes[sel]; if (!p){ $('chart').innerHTML = ''; return; }
  const showable = p.instrs.filter(i => visible(i, p));
  const lo = S.lo, hi = S.hi, span = hi - lo + 1;
  let t = `<table class="pipe"><tr><th></th>${Array.from({length: span}, (_, i) => `<th>${(lo+i)%5===0? lo+i : ''}</th>`).join('')}</tr>`;
  for (const i of showable){
    let cells = '';
    for (let c = lo; c <= hi; c++){
      const st = stateAt(i, c); let cls = '', txt = '';
      if (st === 'D'){ cls = 'D'; txt = 'D'; }
      else if (st === 'X'){ cls = 'X'; txt = 'X'; }
      else if (st === 'Xm'){ cls = 'Xm'; txt = 'X'; }
      else if (st === 'Xl'){ cls = 'Xl'; txt = '\u25a0'; }
      else if (st === 'run'){ cls = 'run'; txt = '\u2248'; }
      else if (st === 4 || st === 5){ cls = 'f'; txt = '·'; }
      else if (st === 'wait'){ cls = 'w'; txt = '…'; }
      else if (st === 'stall'){ cls = 'w'; txt = '·'; }
      cells += `<td class="${cls}${c===cyc?' now':''}">${txt}</td>`;
    }
    const bad = i.origin !== 'application' ? `<span class="orig">${i.origin === 'runtime' ? 'runtime' : esc(i.origin)}</span>` : '';
    t += `<tr><td class="lbl" style="color:${roleColor[i.role]||'inherit'}">${bad}${esc(i.text)}${i.nd>1?` ×${i.nd}`:''}${nExec(i)>1?` <span style="color:var(--muted)">${nExec(i)} exec recs</span>`:''}</td>${cells}</tr>`;
  }
  $('chart').innerHTML = t + '</table>';
}
window.selectPE = t => { sel = t; render(); };
function step(d){ cyc = Math.max(S.lo, Math.min(S.hi, cyc + d)); render(); }
$('bm').onclick = () => step(-1); $('bp').onclick = () => step(1); $('b0').onclick = () => { cyc = S.lo; render(); }; $('b9').onclick = () => { cyc = S.hi; render(); };
$('rng').oninput = e => { cyc = +e.target.value; render(); };
$('harness').onchange = e => { showRuntime = e.target.checked; render(); };
$('play').onclick = () => { if (timer){ clearInterval(timer); timer = null; $('play').textContent = '▶ play'; return; } $('play').textContent = '❚❚ pause'; timer = setInterval(() => { if (cyc >= S.hi){ clearInterval(timer); timer = null; $('play').textContent = '▶ play'; return; } step(1); }, 420); };
document.addEventListener('keydown', e => { if (e.key === 'ArrowLeft') step(-1); if (e.key === 'ArrowRight') step(1); });
buildTabs(); setScene(0);
</script>
"""
if __name__ == "__main__":
    main()
