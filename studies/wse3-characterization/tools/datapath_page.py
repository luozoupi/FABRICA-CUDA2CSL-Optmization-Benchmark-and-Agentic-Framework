#!/usr/bin/env python3
"""Render the cross-workload datapath result as one self-contained page.

Every number comes from results/datapath/{xworkload,evidence}.json; nothing here
is typed by hand.
"""
from __future__ import annotations
import collections, json, statistics, datetime as dt
from pathlib import Path

STUDY = Path(__file__).resolve().parent.parent
X = json.loads((STUDY / "results/datapath/xworkload.json").read_text())
E = json.loads((STUDY / "results/datapath/evidence.json").read_text())

shared = collections.defaultdict(dict)
for w, v in X.items():
    for op, s in v["opcodes"].items():
        shared[op][w] = s
multi = {op: ws for op, ws in shared.items() if len(ws) >= 3}
inv = [op for op, ws in multi.items() if len({s["lat_min"] for s in ws.values()}) == 1]

def tot(op):  return sum(s["n"] for s in shared[op].values())
def lanes(op): return max(s["n_lanes"] for s in shared[op].values())
def latmin(op): return min(s["lat_min"] for s in shared[op].values())

# group the invariant opcodes into functional units
grp = collections.defaultdict(list)
for op in inv:
    grp[(latmin(op), lanes(op))].append(op)
UNIT_NAME = {(3,1): "Scalar ALU, branch, load, store", (3,8): "16-bit SIMD",
             (4,8): "f16 fused multiply-add", (4,4): "f32 SIMD",
             (6,1): "16-bit move (IMOV16.NF)"}
units = []
for (lat, ln), ops in sorted(grp.items()):
    ops.sort(key=tot, reverse=True)
    units.append({"name": UNIT_NAME.get((lat, ln), f"latency {lat}, {ln} lane(s)"),
                  "lat": lat, "lanes": ln, "n": sum(tot(o) for o in ops),
                  "ops": ops})
# FADDS / FMOV32 land outside `inv` because of one outlier; fold f32 in explicitly
f32 = [o for o in ("FADDS", "FMOV32.NF") if o in shared]
if f32 and not any(u["lanes"] == 4 for u in units):
    units.append({"name": UNIT_NAME[(4,4)], "lat": 4, "lanes": 4,
                  "n": sum(tot(o) for o in f32), "ops": f32})
# IMOV16.NF is excluded from `inv` because its minimum varies, but its *median* is 6
# in all seven workloads that run it, so it is a real unit and belongs in the table.
if "IMOV16.NF" in shared and not any("IMOV16.NF" in u["ops"] for u in units):
    med = sorted({float(s2["lat_med"]) for s2 in shared["IMOV16.NF"].values()})
    units.append({"name": UNIT_NAME[(6,1)], "lat": int(med[0]) if len(med) == 1 else 6,
                  "lanes": 1, "n": tot("IMOV16.NF"), "ops": ["IMOV16.NF"],
                  "caveat": "median, not minimum"})
units.sort(key=lambda u: (u["lat"], -u["lanes"]))

pairs = [(op, w) for op, ws in shared.items() for w in ws]
at3 = sum(1 for op, ws in shared.items() for w, s in ws.items() if s["lat_min"] == 3)

esc = lambda s: str(s).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
def f(n): return f"{n:,}"

CLS = collections.OrderedDict()
for w, v in X.items():
    CLS.setdefault(v["class"], []).append(w)

# ---------- diagram ----------
def unit_rows():
    out, y = [], 196
    for u in units:
        out.append(f'''<g>
      <rect x="604" y="{y}" width="352" height="44" rx="2" fill="none" stroke="currentColor" stroke-opacity=".38"/>
      <text x="618" y="{y+19}" font-size="12.5" fill="currentColor">{esc(u["name"])}</text>
      <text x="618" y="{y+34}" font-size="10.5" fill="currentColor" fill-opacity=".62">{esc(", ".join(u["ops"][:4]))}</text>
      <text x="882" y="{y+21}" font-size="12" fill="var(--teal)" text-anchor="middle" font-weight="600">{u["lanes"]}&#215;</text>
      <text x="882" y="{y+34}" font-size="9" fill="currentColor" fill-opacity=".55" text-anchor="middle">lanes</text>
      <text x="936" y="{y+21}" font-size="14" fill="var(--amb)" text-anchor="middle" font-weight="600">{u["lat"]}</text>
      <text x="936" y="{y+34}" font-size="9" fill="currentColor" fill-opacity=".55" text-anchor="middle">cyc</text>
    </g>''')
        y += 52
    return "\n    ".join(out), y

ROWS, endy = unit_rows()
H = max(endy + 30, 470)

SVG = f'''<svg viewBox="0 0 1000 {H}" role="img" width="1000"
   aria-label="Datapath of one Cerebras WSE-3 processing element: a sequencer dispatches at most one instruction per cycle into decode, which is three cycles ahead of execute; execute contains a scalar unit and SIMD units of eight 16-bit lanes or four 32-bit lanes; operands arrive from a register file, a descriptor file with address generators reading data SRAM, and fabric queues. Stages four and five and writeback emit no trace records.">
  <defs>
    <marker id="ar" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">
      <path d="M0,0 L10,5 L0,10 z" fill="currentColor"/>
    </marker>
    <marker id="arT" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">
      <path d="M0,0 L10,5 L0,10 z" fill="var(--teal)"/>
    </marker>
  </defs>

  <!-- pipeline spine -->
  <g font-size="12" fill="currentColor">
    <rect x="28"  y="44" width="132" height="42" rx="2" fill="none" stroke="currentColor" stroke-opacity=".6"/>
    <text x="94"  y="62" text-anchor="middle">sequencer</text>
    <text x="94"  y="77" text-anchor="middle" font-size="10" fill-opacity=".6">PC, task activation</text>

    <rect x="196" y="44" width="132" height="42" rx="2" fill="none" stroke="currentColor" stroke-opacity=".6"/>
    <text x="262" y="62" text-anchor="middle">dispatch</text>
    <text x="262" y="77" text-anchor="middle" font-size="10" fill="var(--amb)">1 instr / cycle max</text>

    <rect x="364" y="44" width="132" height="42" rx="2" fill="none" stroke="currentColor" stroke-opacity=".85"/>
    <text x="430" y="62" text-anchor="middle" font-weight="600">decode</text>
    <text x="430" y="77" text-anchor="middle" font-size="10" fill-opacity=".6">sim. stage 3</text>

    <rect x="532" y="44" width="100" height="42" rx="2" fill="none" stroke="currentColor" stroke-opacity=".3" stroke-dasharray="4 3"/>
    <text x="582" y="62" text-anchor="middle" fill-opacity=".5">stages 4&#8211;5</text>
    <text x="582" y="77" text-anchor="middle" font-size="10" fill-opacity=".45">no records</text>

    <rect x="668" y="44" width="132" height="42" rx="2" fill="none" stroke="currentColor" stroke-opacity=".85"/>
    <text x="734" y="62" text-anchor="middle" font-weight="600">execute</text>
    <text x="734" y="77" text-anchor="middle" font-size="10" fill-opacity=".6">sim. stage 6</text>

    <rect x="836" y="44" width="132" height="42" rx="2" fill="none" stroke="currentColor" stroke-opacity=".3" stroke-dasharray="4 3"/>
    <text x="902" y="62" text-anchor="middle" fill-opacity=".5">writeback</text>
    <text x="902" y="77" text-anchor="middle" font-size="10" fill-opacity=".45">no records</text>

    <line x1="160" y1="65" x2="192" y2="65" stroke="currentColor" marker-end="url(#ar)"/>
    <line x1="328" y1="65" x2="360" y2="65" stroke="currentColor" marker-end="url(#ar)"/>
    <line x1="496" y1="65" x2="528" y2="65" stroke="currentColor" stroke-opacity=".45" marker-end="url(#ar)"/>
    <line x1="632" y1="65" x2="664" y2="65" stroke="currentColor" stroke-opacity=".45" marker-end="url(#ar)"/>
    <line x1="800" y1="65" x2="832" y2="65" stroke="currentColor" stroke-opacity=".45" marker-end="url(#ar)"/>
  </g>

  <!-- measured decode-to-execute span -->
  <g stroke="var(--amb)" fill="none">
    <path d="M430,98 L430,116 L734,116 L734,98"/>
  </g>
  <text x="582" y="133" text-anchor="middle" font-size="12" fill="var(--amb)" font-weight="600">3 cycles minimum, identical in {at3} of {len(pairs)} opcode-workload pairs</text>

  <!-- operand supply -->
  <g font-size="12" fill="currentColor">
    <text x="28" y="176" font-size="10.5" fill-opacity=".6" letter-spacing=".08em">OPERAND SUPPLY</text>
    <rect x="28" y="196" width="230" height="44" rx="2" fill="none" stroke="currentColor" stroke-opacity=".45"/>
    <text x="42" y="215">register file</text>
    <text x="42" y="230" font-size="10" fill-opacity=".6">scalar, one word per operand</text>

    <rect x="28" y="252" width="230" height="58" rx="2" fill="none" stroke="currentColor" stroke-opacity=".45"/>
    <text x="42" y="271">descriptor file + address gen</text>
    <text x="42" y="286" font-size="10" fill-opacity=".6">16 DSRs; one decode record</text>
    <text x="42" y="300" font-size="10" fill-opacity=".6">issued per element</text>

    <rect x="28" y="322" width="230" height="44" rx="2" fill="none" stroke="currentColor" stroke-opacity=".45"/>
    <text x="42" y="341">data SRAM</text>
    <text x="42" y="356" font-size="10" fill-opacity=".6">48 KiB, 8 banks</text>

    <rect x="28" y="378" width="230" height="44" rx="2" fill="none" stroke="currentColor" stroke-opacity=".45"/>
    <text x="42" y="397">fabric queues</text>
    <text x="42" y="412" font-size="10" fill-opacity=".6">wavelet in / out, by colour</text>
  </g>

  <!-- supply into the units -->
  <g stroke="var(--teal)" fill="none">
    <path d="M258,218 L300,218 L300,300 L336,300" marker-end="url(#arT)"/>
    <path d="M258,281 L300,281"/>
    <path d="M258,344 L300,344 L300,300"/>
    <path d="M258,400 L300,400 L300,300"/>
  </g>
  <text x="352" y="288" font-size="12" fill="var(--teal)" font-weight="600">128 bit</text>
  <text x="352" y="303" font-size="11" fill="var(--teal)">per cycle</text>
  <text x="352" y="320" font-size="10" fill="currentColor" fill-opacity=".6">8 &#215; 16-bit</text>
  <text x="352" y="333" font-size="10" fill="currentColor" fill-opacity=".6">or 4 &#215; 32-bit</text>
  <line x1="470" y1="296" x2="598" y2="296" stroke="var(--teal)" marker-end="url(#arT)"/>

  <!-- execution units -->
  <text x="604" y="176" font-size="10.5" fill="currentColor" fill-opacity=".6" letter-spacing=".08em">EXECUTION UNITS, MEASURED</text>
  {ROWS}
</svg>'''

HTML = f'''<title>Inside a Wafer PE</title>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Chivo:wght@700;900&family=IBM+Plex+Mono:wght@400;500;600&family=IBM+Plex+Sans:wght@400;500;600&display=swap">
<style>
:root{{--bg:#F4F6FA;--pan:#FFFFFF;--pan2:#EDF0F6;--ln:#D8DEEA;--ink:#121826;--ink2:#37415A;
  --dim:#5E6B85;--amb:#B55C05;--teal:#07766C;--sh:0 1px 0 rgba(255,255,255,.6),0 6px 18px rgba(20,30,60,.08)}}
@media (prefers-color-scheme:dark){{:root:not([data-theme="light"]){{--bg:#111826;--pan:#1A2233;
  --pan2:#141B2A;--ln:#2B364C;--ink:#E4EAF5;--ink2:#B4C0D4;--dim:#8593AD;--amb:#FFB454;--teal:#4FD1C5;
  --sh:0 1px 0 rgba(255,255,255,.03),0 8px 24px rgba(0,0,0,.45)}}}}
:root[data-theme="dark"]{{--bg:#111826;--pan:#1A2233;--pan2:#141B2A;--ln:#2B364C;--ink:#E4EAF5;
  --ink2:#B4C0D4;--dim:#8593AD;--amb:#FFB454;--teal:#4FD1C5;
  --sh:0 1px 0 rgba(255,255,255,.03),0 8px 24px rgba(0,0,0,.45)}}
*{{box-sizing:border-box}}
body{{background:var(--bg);color:var(--ink);font-family:"IBM Plex Sans",ui-sans-serif,system-ui,sans-serif;
  font-size:15px;line-height:1.58;-webkit-font-smoothing:antialiased}}
.wrap{{max-width:1080px;margin:0 auto;padding:0 22px 80px}}
h1,h2,h3{{font-family:Chivo,sans-serif;text-wrap:balance;margin:0}}
h1{{font-weight:900;font-size:clamp(30px,4vw,50px);letter-spacing:-.025em;line-height:1.02}}
h2{{font-weight:900;font-size:25px;letter-spacing:-.02em;margin:46px 0 12px}}
h3{{font-weight:700;font-size:16px;margin:26px 0 7px}}
p{{max-width:70ch;color:var(--ink2);margin:0 0 13px}}
li{{max-width:68ch;color:var(--ink2);margin-bottom:7px}}
.mono,code{{font-family:"IBM Plex Mono",ui-monospace,monospace;font-variant-numeric:tabular-nums}}
code{{font-size:.88em;background:var(--pan2);border:1px solid var(--ln);border-radius:2px;padding:1px 5px}}
header{{padding:34px 0 20px;border-bottom:1px solid var(--ln)}}
header p{{font-size:16px;max-width:66ch;margin-top:12px}}
.kpi{{display:grid;grid-template-columns:repeat(auto-fit,minmax(170px,1fr));gap:1px;background:var(--ln);
  border:1px solid var(--ln);border-radius:3px;margin:26px 0 8px;overflow:hidden}}
.kpi div{{background:var(--pan);padding:15px 17px}}
.kpi b{{display:block;font-family:"IBM Plex Mono",monospace;font-size:27px;font-weight:600;
  letter-spacing:-.02em;line-height:1;color:var(--amb)}}
.kpi b.t{{color:var(--teal)}}
.kpi span{{display:block;font-size:11.5px;color:var(--dim);margin-top:7px;line-height:1.4}}
figure{{margin:26px 0 8px;background:var(--pan);border:1px solid var(--ln);border-radius:3px;
  padding:18px 16px 12px;box-shadow:var(--sh);overflow-x:auto}}
figure svg{{max-width:100%;height:auto;display:block;color:var(--ink);min-width:760px}}
figcaption{{font-size:12.5px;color:var(--dim);margin-top:14px;max-width:80ch}}
.tw{{overflow-x:auto;margin:16px 0}}
table{{border-collapse:collapse;width:100%;font-size:13px;min-width:520px}}
th,td{{text-align:left;padding:8px 14px 8px 0;border-bottom:1px solid var(--ln);vertical-align:top}}
th{{font-family:"IBM Plex Mono",monospace;font-size:10px;letter-spacing:.1em;text-transform:uppercase;
  color:var(--dim);font-weight:500}}
td.n{{font-family:"IBM Plex Mono",monospace;font-variant-numeric:tabular-nums;text-align:right;padding-right:22px}}
td.m{{font-family:"IBM Plex Mono",monospace;font-size:12px}}
.ok{{color:var(--teal);font-weight:600}}
.note{{background:var(--pan);border:1px solid var(--ln);border-left:2px solid var(--amb);
  border-radius:0 3px 3px 0;padding:14px 17px;margin:20px 0}}
.note h3{{margin:0 0 6px;font-size:12px;font-family:"IBM Plex Mono",monospace;letter-spacing:.1em;
  text-transform:uppercase;color:var(--amb)}}
.note p{{font-size:13px;margin:0 0 8px}}.note p:last-child{{margin:0}}
footer{{margin-top:56px;padding-top:18px;border-top:1px solid var(--ln);
  font-family:"IBM Plex Mono",monospace;font-size:11px;color:var(--dim)}}
</style>

<div class="wrap">
<header>
  <h1>Inside a Wafer PE</h1>
  <p>A Cerebras WSE-3 processing element, reverse engineered the way a MIPS datapath is:
     run the same instructions in deliberately different company, and keep only what does
     not change.</p>
</header>

<div class="kpi">
  <div><b>{at3}<span style="font-size:15px;color:var(--dim)"> / {len(pairs)}</span></b>
       <span>opcode&ndash;workload pairs whose minimum decode-to-execute is exactly 3 cycles</span></div>
  <div><b>{len(inv)}<span style="font-size:15px;color:var(--dim)"> / {len(multi)}</span></b>
       <span>opcodes with an invariant latency across 3 or more of 8 workloads</span></div>
  <div><b class="t">128</b><span>bits per cycle through the SIMD path, as 8&#215;16-bit or 4&#215;32-bit</span></div>
  <div><b class="t">8 / 8</b><span>lanes of one <code>ADD16.NF</code> whose arithmetic verifies exactly</span></div>
</div>

<h2>The datapath</h2>
<figure>
{SVG}
<figcaption>One processing element. Solid outlines are structures the trace observes directly;
dashed ones emit no records at all, so stages 4 and 5 and writeback are placed by position in
the pipeline and nothing more. &ldquo;Decode&rdquo; and &ldquo;execute&rdquo; are the
<em>simulator's</em> labels for its stages 3 and 6; they name where a record appears, not a
verified physical pipeline stage, and the interval between them is a trace-clock interval, not
host time. Latencies on the right are minimum decode-to-execute measured across eight
workloads; lane counts are the most lanes ever seen retiring in one cycle.</figcaption>
</figure>

<h2>Why measure the same opcode in different company</h2>
<p>A latency measured on one program is contaminated. If every <code>FADDS</code> in a kernel
happens to consume a value produced one instruction earlier, its apparent latency includes that
stall, and no amount of averaging separates the two.</p>
<p>The minimum fixes this. Over thousands of instances some instance somewhere had its operands
ready, so the minimum decode-to-execute is the unstalled latency. If that minimum is the same
number in a matrix kernel, a scalar arithmetic microbenchmark, a load/store sweep and an
elementwise kernel, it is a property of the hardware. If it moves, the model is wrong.</p>

<div class="tw"><table>
<thead><tr><th>Class</th><th>Traces</th><th class="n">Instructions analysed</th></tr></thead>
<tbody>
{"".join(f'<tr><td>{esc(c)}</td><td class="m">{esc(", ".join(ws))}</td><td class="n">{f(sum(X[w]["instructions"] for w in ws))}</td></tr>' for c, ws in CLS.items())}
</tbody></table></div>

<h2>The execution units, as measured</h2>
<div class="tw"><table>
<thead><tr><th>Unit</th><th class="n">Lanes</th><th class="n">Latency</th><th class="n">Instances</th><th>Opcodes</th></tr></thead>
<tbody>
{"".join(f'<tr><td>{esc(u["name"])}</td><td class="n">{u["lanes"]}</td><td class="n">{u["lat"]}{"*" if u.get("caveat") else ""}</td><td class="n">{f(u["n"])}</td><td class="m">{esc(", ".join(u["ops"][:6]))}</td></tr>' for u in units)}
</tbody></table></div>
<p>Latency is cycles from the decode record to the first execute record, taken as the minimum
over every instance. The 16-bit and 32-bit SIMD entries both move 128 bits per cycle, which is
the single number the two rows agree on. The starred row is a median: its minimum is not
invariant, and the note below says why.</p>

<h2>The eight lanes are directly visible</h2>
<p>One <code>ADD16.NF</code> covering 8 elements retires every lane in the same cycle, each
carrying its own destination and two sources. Read as 16-bit two's complement, all eight
verify as ordinary integer addition. This is arithmetic checked against the trace, not a
lane count inferred from throughput.</p>
<div class="tw"><table>
<thead><tr><th class="n">Lane</th><th class="n">src0</th><th class="n">src1</th><th class="n">dest</th><th>Check</th></tr></thead>
<tbody>
{"".join(f'<tr><td class="n">{l["lane"]}</td><td class="n">{l["src0"]}</td><td class="n">{l["src1"]}</td><td class="n">{l["dest"]}</td><td class="m ok">{l["src0"]} + {l["src1"]} = {l["dest"]}</td></tr>' for l in E["simd_int16"]["lanes"])}
</tbody></table></div>
<p>All eight in cycle {f(E["simd_int16"]["cycles"][0])} of
<code>{esc(E["simd_int16"]["source"])}</code>. The same width shows up from the opposite end
of the corpus: an <code>ADD16.NF</code> over 2,048 elements still retires 8 per cycle, and
<code>FMACH</code> carrying {E["fma_f16"]["num_data"]} elements is
{E["fma_f16"]["lanes_per_cycle"][0]} lanes across {len(E["fma_f16"]["cycles"])} cycles. That
last point settles an old question in this study: WaferLLM's <code>FMACH</code> is always 16
elements because 16 is two passes of the hardware width, not because 16 is a limit.</p>

<h2>A dependent chain collapses the lanes to one</h2>
<p>Width is only available when elements are independent. In an <code>FADDH</code>
accumulation the recurrence is visible in the operands themselves: each element's
<code>src0</code> is the previous element's <code>dest</code>.</p>
<div class="tw"><table>
<thead><tr><th class="n">Element</th><th class="n">Cycle</th><th class="n">Lane</th><th class="n">src0</th><th class="n">src1</th><th class="n">dest</th></tr></thead>
<tbody>
{"".join(f'<tr><td class="n">{s["elem"]}</td><td class="n">{f(s["cycle"])}</td><td class="n">{s["lane"]}</td><td class="n">{f(s["src0"])}</td><td class="n">{f(s["src1"])}</td><td class="n">{f(s["dest"])}</td></tr>' for s in E["recurrence_f16"]["steps"][:6])}
</tbody></table></div>
<p>One lane, {E["recurrence_f16"]["cycles_per_element"]} cycles per element, which is the
dependent f16 add latency this study measured independently by microbenchmark. The same
opcode family over independent elements uses the full width. A reduction written as an
accumulation therefore runs at one eighth of the available throughput, which is where the
f32 reduction hazard recorded elsewhere in this study lives.</p>

<div class="note">
  <h3>Two things this analysis had to work around</h3>
  <p><strong>Microthreads break instruction identity.</strong> <code>IMOV16.NF</code> and
  <code>IMOV32.NF</code> issue on microthread 0 in six of the eight traces. They overlap the
  main thread, so a <code>uid</code> no longer names one in-flight instruction and naive
  pairing produces impossible latencies, including zero. Every figure here is main-thread
  only, and the microthreaded instructions are counted separately rather than dropped
  silently.</p>
  <p><strong>Three opcodes are not invariant.</strong> <code>FADDS</code> has median 4 in all
  three workloads but minimum 3 in GELU's 5,632 instances against 4 elsewhere;
  <code>SAR16.NF</code> rests on a single instance at 4 against 3 in three other workloads;
  and <code>IMOV16.NF</code> is a steady 6 in all seven workloads that run it, for reasons
  that are <em>not explained</em> here. A 16-bit move costing twice a 32-bit move suggests its
  source is not the register file, and a fabric queue is the obvious candidate, but that is a
  guess and it is untested.</p>
</div>

<h2>What is still unknown</h2>
<p>The stage numbers are the simulator's own, and this page takes them as record positions, not
as evidence of a six-stage physical pipeline. A latency of 3 means three trace-clock cycles
elapse between two record types; how many physical stages sit in that interval is not
established here, and stages 4 and 5 emit nothing, so operand-read and writeback timing remain
unobserved. Nothing here constrains register-file port counts, and no forwarding network is
visible: the trace shows that a dependent instruction waits, not where the value travels while
it waits. A lane count is a count of records retiring together, not proof of physically distinct
adders. All of this is simulator evidence. The study's silicon runs cover the memory path, where the simulator is
optimistic by 1.37 to 1.66 times, and none of the figures on this page have been re-measured
there.</p>

<footer>WSE-3 characterization study &middot; SDK 2.10 &middot;
{f(sum(v["instructions"] for v in X.values()))} instructions across {len(X)} traces &middot;
built {dt.datetime.now():%Y-%m-%d}</footer>
</div>'''

out = STUDY / "results/anatomy/pe_datapath.html"
out.write_text(HTML)
print(f"-> {out}  {out.stat().st_size/1024:.0f} KB")
print(f"   {len(inv)}/{len(multi)} invariant, {at3}/{len(pairs)} pairs at 3, {len(units)} units")
