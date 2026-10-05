#!/usr/bin/env python3
"""Anatomy of an add, at the instruction level, from a real trace.

Reads microbench/atomic_add (each add form executed exactly once), joins the
dispatch trace (cycle, PC), the pipe trace (decode = stage 3, execute = stage 6,
via uid) and the elf2am disassembly (PC -> text), cuts the straight-line body into
its five add forms by instruction pattern, and renders one page:

  * the CSL line, the assembly it became, and the role of every instruction
  * a MIPS-style pipeline chart -- rows are instructions, columns are cycles,
    D = dispatch/decode, X = execute, and for a DSD op the cycles until its
    hardware loop has completed (measured by a timestamp read that waits for it)
  * the component dataflow: which SRAM words, DSRs, registers and lanes each
    instruction touches, in the order the machine touches them
  * the verified inputs and outputs

Evidence: `simulator`, joined by uid and PC exactly; fetch and writeback are not
traced and are drawn as unobserved.
"""
from __future__ import annotations
import gzip, json, re, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent / "microbench" / "atomic_add"
APP_TILE = 12
sys.path.insert(0, str(Path(__file__).resolve().parent))
from anatomy_common import load_pipe, typed, ladder  # operand values, typed rendering, C ladder

def load():
    rows = json.loads((ROOT / "disasm.json").read_text()); rows = rows["records"] if isinstance(rows, dict) else rows
    pe = sorted((r for r in rows if "atomic_add" in (r.get("source_file") or "")), key=lambda r: r["pc"])
    disp, s3, s6 = {}, {}, {}   # s6[uid] = set of every execute cycle (a DSD op has many)
    with gzip.open(ROOT / "events.jsonl.gz", "rt") as fh:
        for line in fh:
            e = json.loads(line)
            if e.get("tile_index") != APP_TILE: continue
            t = e.get("event_type")
            if t == "hwm_dispatch_trace_entry":
                disp.setdefault(e.get("inst_ptr"), []).append((e["cycle"], e["uid"], e.get("num_data")))
            elif t == "hwm_pipe_trace_entry":
                if e.get("stage") == 3:
                    s3[e["uid"]] = min(s3.get(e["uid"], e["cycle"]), e["cycle"])
                elif e.get("stage") == 6:
                    s6.setdefault(e["uid"], set()).add(e["cycle"])
    seq = []
    for r in pe:
        ds = disp.get(r["pc"], [])
        if len(ds) != 1: continue
        c, uid, nd = ds[0]
        if c < 5000: continue
        nd = nd if isinstance(nd, int) and nd < 65535 else 1
        xs = sorted(s6.get(uid, ()))
        seq.append({"pc": r["pc"], "text": r["instruction"], "dispatch": c, "uid": uid,
                    "decode": s3.get(uid), "execute": xs[0] if xs else None,
                    "x_last": xs[-1] if xs else None, "x_cycles": xs, "nd": nd})
    pv = load_pipe(ROOT / "events.jsonl.gz", {APP_TILE})
    for ins in seq:
        ins["elems_raw"] = pv.get((APP_TILE, ins["uid"]), {}).get("elems", [])
    return seq

def cut(seq):
    """Find the five cores by pattern; attach the next dispatch cycle (a scheduling fact, not a latency)."""
    forms = []
    n = len(seq)
    for i, ins in enumerate(seq):
        t = ins["text"]
        if t.startswith(("add16", "faddh r")) and i >= 2 and seq[i-1]["text"].startswith("ld16") and seq[i-2]["text"].startswith("ld16") and i + 1 < n and seq[i+1]["text"].startswith("st16"):
            core = seq[i-2:i+2]
            forms.append({"name": "scalar_i16" if t.startswith("add16") else "scalar_f16", "core": core,
                          "csl": "ci[0] = ai[0] + bi[0];" if t.startswith("add16") else "cf[0] = af[0] + bf[0];",
                          "kind": "scalar", "next": seq[i+2]["dispatch"] if i + 2 < n else None})
        if t.startswith("faddh [dds") and i >= 3:
            core = seq[i-3:i+1]
            nd = ins["nd"]
            forms.append({"name": f"dsd{nd}", "core": core, "csl": f"@faddh(c{nd}, a{nd}, b{nd});",
                          "kind": "dsd", "next": seq[i+1]["dispatch"] if i + 1 < n else None})
    return forms

ROLE = {
    "ld16": ("load", "SRAM word -> GPR", "read one 16-bit word from SRAM into a general register"),
    "add16": ("alu", "GPR + GPR -> GPR", "integer add in the scalar ALU"),
    "faddh r": ("alu", "GPR + GPR -> GPR", "f16 add in the scalar FP unit"),
    "st16": ("store", "GPR -> SRAM word", "write one 16-bit word from a register to SRAM"),
    "lddwds": ("dsr", "descriptor mem -> DDS", "load the DESTINATION data-structure register (base, length, stride)"),
    "lds0wds": ("dsr", "descriptor mem -> S0DS", "load the SOURCE-0 data-structure register"),
    "lds1wds": ("dsr", "descriptor mem -> S1DS", "load the SOURCE-1 data-structure register"),
    "faddh [": ("simd", "S0DS,S1DS streams -> 8 lanes -> DDS stream", "the hardware loop: address generators walk both source DSRs, 8 f16 lanes add, results stream to the destination DSR; completes 6 + 2*groups cycles after dispatch (independent scalar instructions keep issuing meanwhile)"),
}
def role(text):
    for k, v in ROLE.items():
        if text.startswith(k): return v
    return ("other", "", "")

def main():
    seq = load(); forms = cut(seq)
    res = json.loads((ROOT / "results.json").read_text())
    timing = {r["variant"]: r for r in res["rows"]}
    for f in forms:
        c0 = f["core"][0]["dispatch"]
        kind = "i16" if f["name"] == "scalar_i16" else "f16"   # every value in an f16 form is an f16 bit pattern
        for ins in f["core"]:
            ins["role"], ins["flow"], ins["what"] = role(ins["text"])
            k = "dsr" if ins["role"] == "dsr" else kind
            ins["elems"] = [{"cycle": x["cycle"], "idx": x["idx"], "lane": x["lane"], "dest": typed(k, x["dest"]),
                             "src0": typed(k, x["src0"], "src0"), "src1": typed(k, x["src1"], "src1")} for x in ins["elems_raw"]]
            ins.pop("elems_raw", None)
            ins["d_rel"] = ins["dispatch"] - c0
            ins["x_rel"] = (ins["execute"] - c0) if ins["execute"] is not None else None
            ins["xl_rel"] = (ins["x_last"] - c0) if ins["x_last"] is not None else None
            ins["x_rels"] = [x - c0 for x in ins["x_cycles"]]
            ins["completion"] = (ins["x_last"] - ins["dispatch"]) if ins["x_last"] is not None else None
        last = f["core"][-1]
        # the interval to the NEXT instruction's dispatch: a scheduling fact, not a latency
        f["next_dispatch_interval"] = (f["next"] - last["dispatch"]) if f["next"] else None
        # the verified completion boundary: the op's last execute record
        f["completion"] = last["completion"]
        f["timed_cycles"] = timing[f["name"]]["cycles"]; f["verified"] = timing[f["name"]]["verified"]
        f["ladder"] = ladder(f["name"])
        f["span"] = max((ins["xl_rel"] or ins["x_rel"] or 0) for ins in f["core"]) + 1
    data = {"forms": forms, "inputs": res["inputs"], "outputs": res["outputs"]}
    out = ROOT.parent.parent / "results" / "anatomy" / "add_anatomy.html"
    out.write_text(HTML.replace("__DATA__", json.dumps(data)))
    for f in forms:
        print(f"{f['name']:<11} core={len(f['core'])} instr  span {f['span']:>3} cyc  "
              f"completion {str(f['completion']):>4}  next dispatch +{str(f['next_dispatch_interval']):>3}  "
              f"timed {f['timed_cycles']}  verified {f['verified']}")
    print("wrote", out)

HTML = r"""<title>Anatomy of an Add</title>
<style>
:root{--ground:#F4F6F8;--surface:#FFFFFF;--surface-2:#EDF0F3;--ink:#12171C;--ink-2:#3D4750;--muted:#68747F;--line:#D9DFE5;
  --oxide:#0C6E77;--amber:#A8660F;--violet:#5A4B94;--load:#A8660F;--alu:#0C6E77;--store:#A8660F;--dsr:#5A4B94;--simd:#0C6E77;--idle:#DDE3E9}
@media (prefers-color-scheme:dark){:root:not([data-theme="light"]){--ground:#0C1014;--surface:#141A20;--surface-2:#1B232B;--ink:#E7ECF1;--ink-2:#B6C1CB;--muted:#8797A3;--line:#26313A;
  --oxide:#4FC3CC;--amber:#E8A33F;--violet:#A99BE0;--load:#E8A33F;--alu:#4FC3CC;--store:#E8A33F;--dsr:#A99BE0;--simd:#4FC3CC;--idle:#222C35}}
:root[data-theme="dark"]{--ground:#0C1014;--surface:#141A20;--surface-2:#1B232B;--ink:#E7ECF1;--ink-2:#B6C1CB;--muted:#8797A3;--line:#26313A;
  --oxide:#4FC3CC;--amber:#E8A33F;--violet:#A99BE0;--load:#E8A33F;--alu:#4FC3CC;--store:#E8A33F;--dsr:#A99BE0;--simd:#4FC3CC;--idle:#222C35}
*{box-sizing:border-box}body{margin:0;background:var(--ground);color:var(--ink);font-family:ui-sans-serif,system-ui,-apple-system,"Segoe UI",Roboto,sans-serif;font-size:15px;line-height:1.55}
.wrap{max-width:1100px;margin:0 auto;padding:26px 20px 60px}
header{border-bottom:1px solid var(--line);padding-bottom:13px;margin-bottom:20px;display:flex;gap:14px;flex-wrap:wrap;align-items:baseline}
h1{font-size:22px;margin:0;letter-spacing:-.02em}h2{font-size:17px;margin:34px 0 8px;letter-spacing:-.01em}
.eyebrow{font-size:11px;letter-spacing:.14em;text-transform:uppercase;color:var(--muted)}
.chip{font-size:10.5px;letter-spacing:.08em;text-transform:uppercase;padding:2px 7px;border-radius:3px;border:1px solid var(--line);color:var(--muted)}
.card{background:var(--surface);border:1px solid var(--line);border-radius:8px;padding:14px 16px;margin-top:10px}
code,.mono{font-family:ui-monospace,SFMono-Regular,Menlo,Consolas,monospace;font-size:.92em}
table{border-collapse:collapse;width:100%;font-size:13px}th{font-size:10.5px;letter-spacing:.09em;text-transform:uppercase;color:var(--muted);text-align:left;padding:6px 8px;border-bottom:1px solid var(--line)}
td{padding:6px 8px;border-bottom:1px solid var(--line);vertical-align:top}
.scroll{overflow-x:auto}
.pipe{border-collapse:separate;border-spacing:2px;font-family:ui-monospace,Menlo,monospace;font-size:11.5px}
.pipe td{padding:0;border:0;width:22px;height:22px;text-align:center;border-radius:3px;background:var(--idle);color:var(--ink)}
.pipe td.lbl{width:auto;text-align:left;padding:0 10px 0 2px;background:transparent;white-space:nowrap}
.pipe td.D{background:var(--violet);color:#fff}.pipe td.X{background:var(--oxide);color:#fff}.pipe td.W{background:var(--oxide);opacity:.55;color:#fff}.pipe td.s{background:var(--surface-2)}
.pipe th{padding:0;text-align:center;font-size:10px;border:0}
.lede{color:var(--ink-2)}.note{margin-top:12px;padding:11px 14px;border-left:3px solid var(--violet);background:var(--surface);border-radius:0 6px 6px 0;font-size:13.5px;color:var(--ink-2)}
.role-load,.role-store{color:var(--load)}.role-alu,.role-simd{color:var(--alu)}.role-dsr{color:var(--dsr)}
.lad{display:grid;grid-template-columns:1fr 1.15fr 1fr;gap:0;border:1px solid var(--line);border-radius:8px;overflow:hidden;background:var(--surface)}
@media(max-width:820px){.lad{grid-template-columns:1fr}}
.lad>div{padding:11px 14px;border-right:1px solid var(--line)}
.lad>div:last-child{border-right:0}
@media(max-width:820px){.lad>div{border-right:0;border-bottom:1px solid var(--line)}}
.lad pre{margin:5px 0 0;font-family:ui-monospace,Menlo,monospace;font-size:11.5px;line-height:1.5;white-space:pre-wrap;color:var(--ink)}
.lad p{margin:5px 0 0;font-size:12.5px;color:var(--ink-2)}
.diverge{margin-top:8px;padding:9px 13px;border-left:3px solid var(--amber);background:var(--surface);border-radius:0 6px 6px 0;font-size:12.5px;color:var(--ink-2)}
.ev{display:inline-block;font-size:9.5px;letter-spacing:.08em;text-transform:uppercase;padding:1px 6px;border-radius:2px;border:1px solid;margin-left:4px;vertical-align:1px;white-space:nowrap}.ev-dep{color:var(--violet);border-color:var(--violet)}.ev-delay{color:var(--amber);border-color:var(--amber)}.ev-stall{color:var(--oxide);border-color:var(--oxide)}
.flow{display:grid;grid-template-columns:1fr auto 1fr auto 1fr;gap:8px;align-items:center;margin-top:10px;font-size:12.5px}
.box{background:var(--surface-2);border:1px solid var(--line);border-radius:6px;padding:8px 10px;text-align:center}.arrow{color:var(--muted);text-align:center;font-size:18px}
</style>
<div class="wrap">
<header><div><div class="eyebrow">Cerebras WSE-3 · one PE · one add</div><h1>Anatomy of an Add</h1></div><span class="chip">cycles · simulator</span><span class="chip">joined by uid + PC</span></header>
<p class="lede">Five forms of <code>c = a + b</code>, each shown three ways — what it does, the C you would write for it, and the CSL that was actually compiled — then dissected instruction by instruction. Each was executed exactly once, read straight from the dispatch trace, the pipe trace (stage 3 = decode, stage 6 = execute) and the ELF disassembly. The execute-stage records also carry the operand values the datapath used — one record per element for a DSD op, with its SIMD lane — so every table below shows the actual numbers that moved. Every D and X cell is a cycle the simulator recorded and every result was checked against the host; the only drawn-but-unobserved cells are the two between D and X, explained in the pipeline card below.</p>
<div class="card"><div class="eyebrow" style="margin-bottom:6px">The pipeline these charts are drawn on</div>
<div class="scroll"><table class="pipe" style="width:auto"><tr><td class="lbl">stage</td><td class="s" style="width:70px">fetch</td><td class="D" style="width:110px">dispatch / decode</td><td class="s" style="width:60px">stage 4</td><td class="s" style="width:60px">stage 5</td><td class="X" style="width:70px">execute</td><td class="s" style="width:90px">writeback</td></tr>
<tr><td class="lbl">observed?</td><td class="lbl">no</td><td class="lbl">yes — trace stage 3</td><td class="lbl">—</td><td class="lbl">—</td><td class="lbl">yes — trace stage 6</td><td class="lbl">no</td></tr></table></div>
<p style="font-size:13px;color:var(--ink-2);margin:8px 0 0">Cerebras numbers the stages: decode is 3, execute is 6, so an instruction is <strong>3 cycles</strong> from decode to execute and a new instruction enters every cycle. Read the charts like a MIPS diagram: D = the cycle the instruction dispatched and decoded (the stage-3 record), X = the cycle it executed (the stage-6 record). <strong>The two cells between them are not decode</strong> — decode is the single D cycle. They are stages 4 and 5, which the trace does not record at all; they are drawn because the stage numbering implies them, and nothing observed says what happens there. Fetch and writeback exist but are not in any trace field either, so they are drawn as unobserved.</p></div>
<div class="card" style="font-size:12.5px;color:var(--ink-2)"><div class="eyebrow" style="margin-bottom:6px">how timing statements are labelled</div><span class="ev ev-dep">dependency identified</span> a producer–consumer relation exists in the code (register, DSR, flag or memory); it may or may not cost anything. &nbsp; <span class="ev ev-delay">delay observed</span> the trace shows a gap; its cause has not been isolated. &nbsp; <span class="ev ev-stall">stall cause supported</span> a controlled experiment varied the suspected cause and the delay followed it.</div>
<div id="forms"></div>
<div class="note"><strong>Where the values come from.</strong> Each stage-6 (execute) record of the pipe trace carries <code>dest</code>, <code>src0</code>, <code>src1</code> as the datapath saw them; a DSD instruction emits one such record per element, tagged with the element index and the SIMD lane. The element tables above are those records, rendered in the form's type (i16 or f16). Cerebras's own decoder (<code>SimfabInstructionTraceCtf</code>) reports the same numbers.</div>
<div class="note" id="dsdnote"></div>
</div>
<script>
const D = __DATA__;
const el = document.getElementById('forms');
const roleCls = r => ({load:'role-load',store:'role-store',alu:'role-alu',simd:'role-simd',dsr:'role-dsr'}[r] || '');
for (const f of D.forms){
  const span = f.span;
  let pipe = '<div class="scroll"><table class="pipe"><tr><th></th>' + Array.from({length: span}, (_, i) => `<th>${i}</th>`).join('') + '</tr>';
  f.core.forEach((ins, k) => {
    let cells = '';
    for (let c = 0; c < span; c++){
      let cls = '', txt = '';
      const xr = ins.x_rels || [];
      if (c === ins.d_rel){ cls = 'D'; txt = 'D'; }
      else if (xr.includes(c)){ cls = 'X'; txt = (c === ins.xl_rel && xr.length > 1) ? '\u25a0' : 'X'; }
      else if (ins.x_rel !== null && c > ins.d_rel && c < ins.x_rel){ cls = 's'; txt = '·'; }
      else if (ins.xl_rel !== null && c > ins.x_rel && c < ins.xl_rel){ cls = 'W'; txt = '\u2248'; }
      cells += `<td class="${cls}">${txt}</td>`;
    }
    pipe += `<tr><td class="lbl ${roleCls(ins.role)}">${ins.text.replace(/</g,'&lt;')}</td>${cells}</tr>`;
  });
  pipe += '</table></div>';
  const vals = ins => { const e = ins.elems || []; if (!e.length) return '<span style="color:var(--muted)">—</span>';
    if (e.length === 1 || ins.role === 'dsr') { const x = e[0]; const s = [x.src0, x.src1].filter(Boolean).join(', '); return `${x.dest || ''}${s ? ' ← ' + s : ''}`; }
    const lanes = e.map(x => x.lane).filter(l => l !== null && l !== undefined); const cyc = new Set(e.map(x => x.cycle));
    return `${e.length} elements · lanes ${Math.min(...lanes)}–${Math.max(...lanes)} · ${cyc.size} cycle${cyc.size>1?'s':''} (table below)`; };
  const rows = f.core.map(ins => `<tr><td class="mono">0x${ins.pc.toString(16)}</td><td class="mono ${roleCls(ins.role)}">${ins.text.replace(/</g,'&lt;')}</td><td class="mono">${ins.d_rel}</td><td class="mono">${ins.x_rel}</td><td class="mono">${ins.nd}</td><td class="mono">${ins.flow}</td><td>${ins.what}</td><td class="mono" style="font-size:12px">${vals(ins)}</td></tr>`).join('');
  const dsdOp = f.core.find(ins => ins.role === 'simd');   // the vector op's records; never the descriptor loads' two words
  const elemTable = dsdOp ? `<div class="eyebrow" style="margin:12px 0 6px">every element the hardware loop produced (stage-6 records of <span class="mono">${dsdOp.text.replace(/</g,'&lt;')}</span>; cycle relative to the form's first dispatch)</div><div class="scroll" style="max-height:300px;overflow-y:auto"><table><tr><th>element</th><th>lane</th><th>cycle</th><th>src0 (a)</th><th>src1 (b)</th><th>dest (c)</th></tr>${dsdOp.elems.map(x => `<tr><td class="mono">${x.idx}</td><td class="mono">${x.lane}</td><td class="mono">${x.cycle - f.core[0].dispatch}</td><td class="mono">${x.src0}</td><td class="mono">${x.src1}</td><td class="mono">${x.dest}</td></tr>`).join('')}</table></div>` : '';
  const isS = f.kind === 'scalar';
  const flow = isS ? `
    <div class="flow"><div class="box">SRAM<br><span class="mono">a</span> at ${f.core[0].text.match(/\[(0x[0-9a-f]+)\]/)[1]}<br><span class="mono">b</span> at ${f.core[1].text.match(/\[(0x[0-9a-f]+)\]/)[1]}</div><div class="arrow">→ ld16 ×2 →</div>
    <div class="box">GPR file<br><span class="mono">${f.core[0].text.split(' ')[1]}, ${f.core[1].text.split(' ')[1]}</span></div><div class="arrow">→ ${f.core[2].text.split(' ')[0]} →</div>
    <div class="box">SRAM<br><span class="mono">c</span> at ${f.core[3].text.match(/\[(0x[0-9a-f]+)\]/)[1]}<br>via st16</div></div>`
  : `<div class="flow"><div class="box">descriptor memory<br><span class="mono">[${f.core[0].text.match(/\[(0x[0-9a-f]+)\]/)[1]}] [${f.core[1].text.match(/\[(0x[0-9a-f]+)\]/)[1]}] [${f.core[2].text.match(/\[(0x[0-9a-f]+)\]/)[1]}]</span></div><div class="arrow">→ ld*wds ×3 →</div>
    <div class="box">DSR file<br><span class="mono">dds1 · s0ds1 · s1ds1</span><br>base / length / stride</div><div class="arrow">→ faddh →</div>
    <div class="box">address gens → SRAM banks (word&amp;7)<br>→ 8 f16 lanes → SRAM<br><span class="mono">${f.core[3].nd} elements · ${f.core[3].nd/8} group(s)</span></div></div>`;
  const L = f.ladder;
  const lad = !L ? '' : `<div class="lad">
      <div><span class="eyebrow">what it does</span><p>${L.intent}</p></div>
      <div><span class="eyebrow">the same thing in C</span><pre>${L.c.replace(/</g,'&lt;')}</pre></div>
      <div><span class="eyebrow">as written in CSL</span><pre>${f.csl.replace(/</g,'&lt;')}</pre></div>
    </div>${L.differs ? `<div class="diverge"><strong>Where C and the WSE part company.</strong> ${L.differs}</div>` : '<div class="diverge" style="border-left-color:var(--oxide)">In isolation the lowering is one-to-one with the C: two loads, one arithmetic instruction, one store. In straight-line code the optimiser shares the loads between statements, so an add embedded among others costs less than this — see the ISA page.</div>'}`;
  el.insertAdjacentHTML('beforeend', `
    <h2>${f.name.replace('_',' ')} &nbsp;<span class="chip">${f.verified ? 'verified' : 'NOT VERIFIED'}</span></h2>
    ${lad}
    <div class="card"><div class="mono" style="margin-bottom:8px">${f.csl}</div>${pipe}
      <p style="font-size:13px;color:var(--ink-2);margin:10px 0 0">first dispatch → last execute: <strong>${f.span}</strong> cycles &nbsp;·&nbsp; ${f.kind==='dsd' ? `<strong>decode → last execute</strong> (the completion boundary): <strong>${f.completion}</strong> cycles &nbsp;·&nbsp; <strong>next dispatch after the op</strong>: ${f.next_dispatch_interval} cycles — two different quantities: the second is when the pipeline moved on, not when the result existed <span class="ev ev-delay">delay observed</span>` : `each instruction is exactly 3 cycles from decode to execute; the add's own completion latency is ${f.core[2].completion} cycles`} &nbsp;·&nbsp; TSC-timed region incl. timestamp overhead: ${f.timed_cycles} cycles</p></div>
    <div class="card"><div class="eyebrow" style="margin-bottom:6px">what each instruction touches</div><div class="scroll"><table><tr><th>pc</th><th>instruction</th><th>D</th><th>X</th><th>elems</th><th>data path</th><th>action</th><th>values at X (dest ← src0, src1)</th></tr>${rows}</table></div>${flow}${elemTable}</div>`);
}
const dsd = D.forms.filter(f => f.kind === 'dsd');
const jn = k => dsd.map(f => f[k]).join(' / ');
document.getElementById('dsdnote').innerHTML = `<strong>How to read a DSD form.</strong> Three <code>ld*wds</code> instructions load the three data-structure registers from descriptors in memory (destination, source-0, source-1: base address, length, stride) <span class="ev ev-dep">dependency identified</span>. That is descriptor <em>control</em> state: <code>lds1wds</code> moves no operand into the ALU. The single <code>faddh [dds1] = [s0ds1], [s1ds1]</code> then <em>is</em> the loop, reading its data through those descriptors: address generators walk both sources, eight f16 lanes add, results stream to the destination. Two intervals are measured for it and must not be conflated: <strong>decode → last execute</strong> is <strong>${jn('completion')}</strong> cycles for ${dsd.map(f => f.core[f.core.length-1].nd).join(' / ')} elements, and the <strong>next instruction's dispatch</strong> follows the op's dispatch by <strong>${jn('next_dispatch_interval')}</strong> cycles, which is 6 + 2·(elements/8) <span class="ev ev-delay">delay observed</span>. The first is when the last element executed; the second is when the pipeline moved on; the 4-cycle difference between them is not explained by any record in the trace. Every <strong>X</strong> cell is a cycle in which the trace recorded execute records for this op (8 lanes each), <strong>■</strong> is the last one, and the <strong>≈</strong> cells between them are cycles with no record for this op inside its execute window — whether the loop is running or idle there is not observed. <code>microbench/overlap</code> shows that the PE issues nothing else while such an op runs <span class="ev ev-stall">stall cause supported</span>, for the configuration tested: a memory-to-memory i16 <code>@add16</code> on one PE with no microthread. Fabric-bound DSD copies run as microthreads (the relay's carry microthread id 6 in the trace) and were not tested; the result does not extend to them.`;
const I = D.inputs, O = D.outputs;
el.insertAdjacentHTML('beforeend', `<div class="card"><div class="eyebrow" style="margin-bottom:6px">verified values</div>
<div class="mono">ai=${I.ai}  bi=${I.bi}  → ci=${O.ci}  (expected ${I.ai + I.bi})<br>af=${I.af}  bf=${I.bf}  → cf=${O.cf}<br>a[0]=${I.a0}  b[0]=${I.b0}  → c[0]=${O.c0}  (and all 64 elements of c = a + b match, checked in f16)</div></div>`);
</script>
"""
if __name__ == "__main__":
    main()
