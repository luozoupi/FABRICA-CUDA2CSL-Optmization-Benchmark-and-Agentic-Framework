#!/usr/bin/env python3
"""Render the matmul formulation study, organised by classification.

Five classes: inner product, outer product, row-wise axpy, column-wise axpy,
tiled. For each, what it is mathematically, what it becomes on a WSE-3 PE
(which instruction, which operand port, what stride, how many lanes), and what
it measured. Every number comes from results/datapath/matmul_steps.json and
microbench/matmulorder/matmulorder_results.json.
"""
from __future__ import annotations
import datetime as dt, json
from pathlib import Path

S = Path(__file__).resolve().parent.parent
D = json.loads((S / "results/datapath/matmul_steps.json").read_text())
SRC = json.loads((S / "results/datapath/matmul_src.json").read_text())
M, N, K, MACS = D["M"], D["N"], D["K"], D["macs"]
V = D["variants"]
esc = lambda s: str(s).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
fm = lambda n: f"{n:,}"
best = min(V[v]["tsc_cycles"] for v in V if V[v]["passed"])

# ---------------------------------------------------------------- classes
CLASSES = [
 {"id": "row", "name": "Row-wise axpy", "nest": "k in the middle, j innermost",
  "math": "C[i,:] += A[i,k] &middot; B[k,:]",
  "members": ["ikj_map", "ikj"],
  "maps": "Exactly one FMACH. This is the instruction's native shape.",
  "ports": [("dest / src0", "C[i,:] &mdash; the output row", "unit", "8"),
            ("src1", "B[k,:] &mdash; the streamed row", "unit", "8"),
            ("src2", "A[i,k] &mdash; one scalar, broadcast", "&mdash;", "all")],
  "verdict": "Best in this 32×32 row-major probe: contiguous vectors and a scalar FMA operand. This is not a universal matmul ranking."},
 {"id": "outer", "name": "Outer product", "nest": "k outermost",
  "math": "C += A[:,k] &otimes; B[k,:]  (rank-1 update)",
  "members": ["kij_map", "kij", "kji"],
  "maps": "Not one instruction either: the FMA takes a vector and a scalar, not two vectors. "
          "A rank-1 update decomposes into M row-axpys (kij) or N column-axpys (kji). With the "
          "descriptors hoisted this is the fastest form measured here.",
  "ports": [("dest / src0", "C[i,:] or C[:,j]", "unit for kij, 32 for kji", "8 or 1"),
            ("src1", "B[k,:] or A[:,k]", "unit for kij, 32 for kji", "8 or 1"),
            ("src2", "A[i,k] or B[k,j], broadcast", "&mdash;", "all")],
  "verdict": "Measured similarly to the corresponding axpy in this probe. These two source orders have nearly equal timings in this particular probe."},
 {"id": "col", "name": "Column-wise axpy", "nest": "k in the middle, i innermost",
  "math": "C[:,j] += A[:,k] &middot; B[k,j]",
  "members": ["kji", "jki"],
  "maps": "Same FMACH as the row form. Only the memory stride differs.",
  "ports": [("dest / src0", "C[:,j] &mdash; an output column", "32", "1"),
            ("src1", "A[:,k] &mdash; a column", "32", "1"),
            ("src2", "B[k,j] &mdash; one scalar, broadcast", "&mdash;", "all")],
  "verdict": "About 2.3x slower here. The stride-32 vectors use one observed lane; addressing and loop overhead also contribute."},
 {"id": "inner", "name": "Inner product", "nest": "k innermost",
  "math": "C[i,j] = &Sigma;<sub>k</sub> A[i,k] &middot; B[k,j]",
  "members": ["ijk_tree", "ijk_bt", "ijk", "jik", "ijk_scalar"],
  "maps": "These tested dot-product kernels use a vector "
          "multiply followed by an accumulation reduction.",
  "ports": [("dest", "one scalar accumulator", "&mdash;", "1"),
            ("src0 / src1", "A[i,:] and B[:,j]", "unit and 32 (unit if B is transposed)", "1, or 8 with B&#7488;"),
            ("src2", "unused &mdash; there is no scalar to broadcast", "&mdash;", "&mdash;")],
  "verdict": "The worst fit, and the only class whose natural spelling is also wrong. Done correctly with a tree reduction it is 7.5x off the winner; done correctly and scalar, 86x. The three variants using the horizontal-reduction builtin return the last product instead of the sum and are excluded from the ranking."},
 {"id": "tiled", "name": "Tiled / blocked", "nest": "j split into tiles",
  "math": "C[i, t] += A[i,k] &middot; B[k, t]  over tiles t",
  "members": ["outer_tile4c", "outer_tile4b", "outer_tile4", "ikj_map_blk"],
  "maps": "The same FMACH on shorter vectors. Descriptor traffic multiplies by the tile count, "
          "and this implementation reloads the B descriptor for each k. Packing B by tile enables @map again.",
  "ports": [("dest / src0", "C[i, tile] &mdash; 8 of 32 elements", "unit", "8"),
            ("src1", "B[k, tile]", "unit", "8"),
            ("src2", "A[i,k], broadcast", "&mdash;", "all")],
  "verdict": "Tiling the output rows beats the correct inner product by 4.0x but loses to the untiled outer product by 1.9x. Tiling the output row instead is 15.8x off. Measured on one PE with everything already in SRAM; it says nothing about tiling across a mesh, where the operands are not local to begin with."},
]
CLS_OF = {}
for c in CLASSES:
    for m in c["members"]:
        CLS_OF.setdefault(m, c["id"])

LABEL = {"ikj_map": "ikj + @map", "ikj": "ikj", "kij": "kij", "kji": "kji", "jki": "jki",
         "ijk": "ijk", "jik": "jik", "ijk_scalar": "ijk scalar", "ijk_bt": "ijk with B\u1d40",
         "ikj_map_blk": "ikj tiled 8", "ijk_tree": "ijk tree reduction",
         "kij_map": "kij + @map", "outer_tile4": "outer tile 4, naive",
         "outer_tile4b": "outer tile 4, no index math",
         "outer_tile4c": "outer tile 4, DSR-pinned"}
STRIDE = {"ikj_map": "all unit", "ikj": "all unit", "kij": "all unit",
          "ikj_map_blk": "all unit, length 8", "ijk_bt": "all unit (B transposed)",
          "kji": "stride 32", "jki": "stride 32", "ijk": "B column, stride 32",
          "jik": "B column, stride 32", "ijk_scalar": "scalar registers",
          "ijk_tree": "all unit (B transposed)", "kij_map": "all unit",
          "outer_tile4": "all unit", "outer_tile4b": "all unit", "outer_tile4c": "all unit"}
NOTE = {
 "kij_map": "The winner. An outer product with its descriptors hoisted. Consecutive FMACHs write different rows of C, but the issue cadence is 9 cycles either way, so the margin is fewer bookkeeping instructions, not independence.",
 "ikj_map": "Second, by 1.6%. Same hoisting, applied to the row form: descriptors loaded once per output row and @map feeding the scalars, so the inner loop is two instructions.",
 "outer_tile4c": "The tiled outer product done properly, with the four C descriptors pinned in DSRs. Nothing spills and one B descriptor load feeds four FMACHs. 4.0x faster than the correct inner product, still 1.9x behind the untiled outer product.",
 "outer_tile4b": "The same tile with running offsets instead of index arithmetic. It barely helps, which is how descriptor spilling was identified as the real cost rather than the address math.",
 "outer_tile4": "The same tile spelled naively: 26.6 instructions per FMA, because the four C descriptors spill to memory every iteration. The disassembly shows 56 stores around 4 FMACHs.",
 "kij": "An outer product realised as row axpys, written without hoisting. Within 0.09% of ikj, which is an axpy. The family label predicts nothing.",
 "ikj": "Same traversal as ikj_map without hoisting: two DSD offsets recomputed every iteration, so roughly 40 of 44 cycles per iteration are addressing rather than arithmetic.",
 "ijk_tree": "The repaired inner product. The miscompiling horizontal reduction is replaced by a five-level tree of elementwise vector adds, every one lane-parallel. Correct, and faster than the broken variant it replaces.",
 "ijk_bt": "The stride control. Only B's layout changed, from a strided column to a transposed row. The multiply goes from 1 lane to 8. The reduction is still wrong.",
 "kji": "An outer product realised as column axpys. Every operand is stride 32, so the FMACH collapses to 1 lane.",
 "jki": "A column axpy. The same instruction as ikj with strided operands, and the same 1 lane.",
 "ijk": "The textbook dot product. Wrong answer: the reduction compiled with dest != src0 and returns only the last product. Kept as a checked regression case.",
 "jik": "The same failure as ijk, with the outer loops swapped.",
 "ikj_map_blk": "Tiling the output row rather than the output rows. Correct, keeps 8 lanes per tile, and is the worst tiled form here because the streaming operand cannot be used once the tile width stops matching B's row pitch.",
 "ijk_scalar": "The dot product with no descriptor at all, so it is correct. It is also 86x slower than the winner, issuing 65,536 floating-point instructions where the vector forms issue 1,024.",
}
SHAPE = {
 "ikj": {"outer": "i", "mid": "k", "no": M, "ni": K, "kind": "row"},
 "kij": {"outer": "k", "mid": "i", "no": K, "ni": M, "kind": "row"},
 "ikj_map": {"outer": "i", "mid": "k", "no": M, "ni": K, "kind": "row"},
 "jki": {"outer": "j", "mid": "k", "no": N, "ni": K, "kind": "col"},
 "kji": {"outer": "k", "mid": "j", "no": K, "ni": N, "kind": "col"},
 "ijk": {"outer": "i", "mid": "j", "no": M, "ni": N, "kind": "dot"},
 "jik": {"outer": "j", "mid": "i", "no": N, "ni": M, "kind": "dot"},
 "ijk_scalar": {"outer": "i", "mid": "j", "no": M, "ni": N, "kind": "dot"},
 "ijk_bt": {"outer": "i", "mid": "j", "no": M, "ni": N, "kind": "dotT"},
 "ikj_map_blk": {"outer": "i", "mid": "jb", "no": M, "ni": 4, "kind": "rowblk"},
 "ijk_tree": {"outer": "i", "mid": "j", "no": M, "ni": N, "kind": "dotT"},
 "kij_map": {"outer": "k", "mid": "i", "no": K, "ni": M, "kind": "row"},
 "outer_tile4": {"outer": "ib", "mid": "k", "no": M // 4, "ni": K, "kind": "otile"},
 "outer_tile4b": {"outer": "ib", "mid": "k", "no": M // 4, "ni": K, "kind": "otile"},
 "outer_tile4c": {"outer": "ib", "mid": "k", "no": M // 4, "ni": K, "kind": "otile"},
}
ORDER = ["kij_map", "ikj_map", "outer_tile4c", "outer_tile4b", "outer_tile4",
         "kij", "ikj", "ijk_tree", "ijk_bt", "kji", "jki", "ijk", "jik",
         "ikj_map_blk", "ijk_scalar"]

def vrow(v):
    x = V[v]
    ok = x["passed"]
    return (f'<tr class="{"" if ok else "bad"}"><td class="m">{esc(LABEL[v])}</td>'
            f'<td><span class="cl cl-{CLS_OF[v]}">{esc(next(c["name"] for c in CLASSES if c["id"]==CLS_OF[v]))}</span></td>'
            f'<td class="m">{STRIDE[v]}</td>'
            f'<td class="n">{x.get("lanes","?")}</td>'
            f'<td class="n">{fm(x["tsc_cycles"])}</td>'
            f'<td class="n">{fm(x["fp_dispatches"])}</td>'
            f'<td class="n">{(str(round(x["tsc_cycles"]/best,2))+"x") if ok else "&mdash;"}</td>'
            f'<td>{"ok" if ok else "<b>wrong</b>"}</td></tr>')

def card(c):
    ms = "".join(
        f'<tr><td class="m">{esc(LABEL[m])}</td><td class="n">{fm(V[m]["tsc_cycles"])}</td>'
        f'<td class="n">{V[m].get("lanes","?")}</td>'
        f'<td class="n">{(str(round(V[m]["tsc_cycles"]/best,2))+"x") if V[m]["passed"] else "&mdash;"}</td>'
        f'<td>{"ok" if V[m]["passed"] else "<b class=w>wrong</b>"}</td></tr>' for m in c["members"])
    ports = "".join(
        f'<tr><td class="m">{p[0]}</td><td>{p[1]}</td><td class="m">{p[2]}</td>'
        f'<td class="n">{p[3]}</td></tr>' for p in c["ports"])
    return f'''<section class="cls" id="c-{c['id']}">
  <div class="ch"><span class="dot cl-{c['id']}"></span><h3>{esc(c['name'])}</h3>
    <span class="nest">{esc(c['nest'])}</span></div>
  <div class="cb">
    <div>
      <p class="math">{c['math']}</p>
      <p class="maps"><strong>On the PE:</strong> {c['maps']}</p>
      <table class="mini"><thead><tr><th>FMA port</th><th>carries</th><th>stride</th><th>lanes</th></tr></thead>
      <tbody>{ports}</tbody></table>
    </div>
    <div>
      <table class="mini"><thead><tr><th>Variant</th><th class="n">Cycles</th><th class="n">Lanes</th>
      <th class="n">vs best</th><th>Check</th></tr></thead><tbody>{ms}</tbody></table>
      <p class="verd">{esc(c['verdict'])}</p>
    </div>
  </div>
</section>'''

PAY = {v: {"tsc": V[v]["tsc_cycles"], "fp": V[v]["fp_dispatches"],
           "ok": V[v]["passed"], "steps": V[v]["steps"], "src": SRC.get(v, ""),
           "shape": SHAPE[v], "note": NOTE[v], "cls": CLS_OF[v],
           "lanes": V[v].get("lanes", 1), "fpop": V[v].get("fp_op", "FP"),
           "fpel": V[v].get("fp_elems", 1), "fpcy": V[v].get("fp_cycles", 1),
           "stride": STRIDE[v], "label": LABEL[v],
           "vs": round(V[v]["tsc_cycles"] / best, 2) if V[v]["passed"] else None} for v in ORDER}

HTML = f"""<title>Which Way to Multiply</title>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Chivo:wght@700;900&family=IBM+Plex+Mono:wght@400;500;600&family=IBM+Plex+Sans:wght@400;500;600&display=swap">
<style>
:root{{--bg:#F4F6FA;--pan:#FFF;--pan2:#EDF0F6;--ln:#D8DEEA;--ink:#121826;--ink2:#37415A;
 --dim:#5E6B85;--amb:#B55C05;--teal:#07766C;--bad:#B3282C;
 --row:#07766C;--outer:#2D5FA8;--col:#8A5A12;--inner:#B3282C;--tiled:#6B4A9E;
 --sh:0 1px 0 rgba(255,255,255,.6),0 6px 18px rgba(20,30,60,.08)}}
@media (prefers-color-scheme:dark){{:root:not([data-theme="light"]){{--bg:#111826;--pan:#1A2233;
 --pan2:#141B2A;--ln:#2B364C;--ink:#E4EAF5;--ink2:#B4C0D4;--dim:#8593AD;--amb:#FFB454;
 --teal:#4FD1C5;--bad:#F2686B;--row:#4FD1C5;--outer:#7FB0FF;--col:#FFC069;--inner:#F2686B;
 --tiled:#C9A7F0;--sh:0 1px 0 rgba(255,255,255,.03),0 8px 24px rgba(0,0,0,.45)}}}}
:root[data-theme="dark"]{{--bg:#111826;--pan:#1A2233;--pan2:#141B2A;--ln:#2B364C;--ink:#E4EAF5;
 --ink2:#B4C0D4;--dim:#8593AD;--amb:#FFB454;--teal:#4FD1C5;--bad:#F2686B;--row:#4FD1C5;
 --outer:#7FB0FF;--col:#FFC069;--inner:#F2686B;--tiled:#C9A7F0;
 --sh:0 1px 0 rgba(255,255,255,.03),0 8px 24px rgba(0,0,0,.45)}}
*{{box-sizing:border-box}}
body{{background:var(--bg);color:var(--ink);font-family:"IBM Plex Sans",system-ui,sans-serif;
 font-size:15px;line-height:1.56;-webkit-font-smoothing:antialiased}}
.wrap{{max-width:1240px;margin:0 auto;padding:0 20px 72px}}
h1,h2,h3{{font-family:Chivo,sans-serif;margin:0;text-wrap:balance}}
h1{{font-weight:900;font-size:clamp(29px,3.8vw,48px);letter-spacing:-.025em;line-height:1.03}}
h2{{font-weight:900;font-size:24px;letter-spacing:-.02em;margin:46px 0 11px}}
p{{max-width:72ch;color:var(--ink2);margin:0 0 12px}}
.mono,code{{font-family:"IBM Plex Mono",ui-monospace,monospace;font-variant-numeric:tabular-nums}}
code{{font-size:.88em;background:var(--pan2);border:1px solid var(--ln);border-radius:2px;padding:1px 5px}}
header{{padding:32px 0 18px;border-bottom:1px solid var(--ln)}}
header p{{font-size:16px;max-width:68ch;margin-top:11px}}
.kpi{{display:grid;grid-template-columns:repeat(auto-fit,minmax(168px,1fr));gap:1px;
 background:var(--ln);border:1px solid var(--ln);border-radius:3px;margin:24px 0 6px;overflow:hidden}}
.kpi div{{background:var(--pan);padding:14px 16px}}
.kpi b{{display:block;font-family:"IBM Plex Mono",monospace;font-size:25px;font-weight:600;
 line-height:1;letter-spacing:-.02em;color:var(--amb)}}
.kpi b.t{{color:var(--teal)}}
.kpi span{{display:block;font-size:11.5px;color:var(--dim);margin-top:6px;line-height:1.4}}
/* class colour chips */
.cl,.dot{{font-family:"IBM Plex Mono",monospace;font-size:10px;letter-spacing:.06em;
 text-transform:uppercase;padding:2px 7px;border-radius:9px;border:1px solid currentColor;
 white-space:nowrap}}
.cl-row{{color:var(--row)}} .cl-outer{{color:var(--outer)}} .cl-col{{color:var(--col)}}
.cl-inner{{color:var(--inner)}} .cl-tiled{{color:var(--tiled)}}
.dot{{display:inline-block;width:11px;height:11px;padding:0;border-radius:50%;
 background:currentColor;border:0;flex:0 0 auto}}
/* class cards */
.cls{{background:var(--pan);border:1px solid var(--ln);border-radius:3px;margin:14px 0;
 box-shadow:var(--sh);overflow:hidden}}
.ch{{display:flex;align-items:center;gap:10px;padding:12px 16px;border-bottom:1px solid var(--ln);
 background:var(--pan2);flex-wrap:wrap}}
.ch h3{{font-size:17px;font-weight:700}}
.ch .nest{{font-family:"IBM Plex Mono",monospace;font-size:11px;color:var(--dim);margin-left:auto}}
.cb{{display:grid;grid-template-columns:minmax(0,1.15fr) minmax(0,.85fr);gap:22px;padding:15px 16px}}
@media (max-width:880px){{.cb{{grid-template-columns:1fr;gap:14px}}}}
.math{{font-family:"IBM Plex Mono",monospace;font-size:14px;color:var(--ink);margin:0 0 10px}}
.maps{{font-size:13.5px;margin:0 0 11px}}
.verd{{font-size:13px;margin:11px 0 0;color:var(--ink2)}}
table.mini{{border-collapse:collapse;width:100%;font-size:12px}}
table.mini th,table.mini td{{text-align:left;padding:5px 10px 5px 0;border-bottom:1px solid var(--ln)}}
table.mini th{{font-family:"IBM Plex Mono",monospace;font-size:9.5px;letter-spacing:.1em;
 text-transform:uppercase;color:var(--dim);font-weight:500}}
table.mini td.n{{font-family:"IBM Plex Mono",monospace;text-align:right;padding-right:14px;
 font-variant-numeric:tabular-nums}}
table.mini td.m{{font-family:"IBM Plex Mono",monospace}}
b.w{{color:var(--bad)}}
figure{{margin:20px 0 8px;background:var(--pan);border:1px solid var(--ln);border-radius:3px;
 padding:16px;box-shadow:var(--sh);overflow-x:auto}}
figure svg{{max-width:100%;height:auto;display:block;color:var(--ink);min-width:660px}}
figcaption{{font-size:12.5px;color:var(--dim);margin-top:13px;max-width:82ch}}
/* debug console */
.tabs{{display:flex;flex-wrap:wrap;gap:5px;margin:20px 0 0}}
.tabs button{{font-family:"IBM Plex Mono",monospace;font-size:11.5px;padding:6px 10px;
 border:1px solid var(--ln);background:var(--pan);color:var(--ink2);border-radius:2px;cursor:pointer;
 display:flex;align-items:center;gap:6px}}
.tabs button:hover{{border-color:var(--amb)}}
.tabs button[aria-pressed="true"]{{background:var(--amb);border-color:var(--amb);color:#14181F;font-weight:600}}
.tabs button i{{width:8px;height:8px;border-radius:50%;background:currentColor;display:inline-block}}
.console{{display:grid;grid-template-columns:minmax(0,1.05fr) minmax(0,.95fr);gap:12px;margin-top:12px}}
@media (max-width:940px){{.console{{grid-template-columns:1fr}}}}
.card{{background:var(--pan);border:1px solid var(--ln);border-radius:3px;padding:13px 15px;
 box-shadow:var(--sh);min-width:0}}
.eyebrow{{font-family:"IBM Plex Mono",monospace;font-size:10px;letter-spacing:.13em;
 text-transform:uppercase;color:var(--dim);margin:0 0 9px}}
pre{{margin:0;font-family:"IBM Plex Mono",monospace;font-size:11.5px;line-height:1.62;
 overflow-x:auto;color:var(--ink2)}}
pre .hl{{background:color-mix(in srgb,var(--amb) 22%,transparent);border-radius:2px;
 display:inline-block;width:100%;color:var(--ink);font-weight:600}}
pre .cm{{color:var(--dim)}}
.grids{{display:grid;grid-template-columns:repeat(3,1fr);gap:10px}}
.gw{{text-align:center}}
.gw canvas{{width:100%;height:auto;display:block;border:1px solid var(--ln);border-radius:2px;
 image-rendering:pixelated;background:var(--pan2)}}
.gw span{{display:block;font-family:"IBM Plex Mono",monospace;font-size:10.5px;color:var(--dim);margin-top:5px}}
.stream{{max-height:210px;overflow-y:auto;font-family:"IBM Plex Mono",monospace;font-size:11px}}
.stream table{{width:100%;border-collapse:collapse}}
.stream td{{padding:2px 8px 2px 0;border-bottom:1px solid var(--ln);white-space:nowrap}}
.stream tr.fp td{{color:var(--teal);font-weight:600}}
.ctl{{display:flex;align-items:center;gap:9px;flex-wrap:wrap;margin-top:11px}}
.ctl button{{font-family:"IBM Plex Mono",monospace;font-size:11px;letter-spacing:.08em;
 text-transform:uppercase;padding:6px 12px;border:1px solid var(--ln);background:var(--pan2);
 color:var(--ink2);border-radius:2px;cursor:pointer}}
.ctl button.p{{background:var(--amb);border-color:var(--amb);color:#14181F;font-weight:600;min-width:74px}}
.ctl input[type=range]{{flex:1;min-width:120px;accent-color:var(--amb)}}
.rd{{font-family:"IBM Plex Mono",monospace;font-size:11.5px;color:var(--dim);margin-top:8px}}
.rd b{{color:var(--ink)}}
.note{{background:var(--pan2);border-left:2px solid var(--amb);border-radius:0 2px 2px 0;
 padding:10px 13px;margin-top:11px;font-size:12.5px;color:var(--ink2)}}
.note.bad{{border-left-color:var(--bad)}}
.tw{{overflow-x:auto;margin:16px 0}}
table.res{{border-collapse:collapse;width:100%;font-size:13px;min-width:720px}}
table.res th,table.res td{{text-align:left;padding:8px 14px 8px 0;border-bottom:1px solid var(--ln)}}
table.res th{{font-family:"IBM Plex Mono",monospace;font-size:10px;letter-spacing:.1em;
 text-transform:uppercase;color:var(--dim);font-weight:500}}
table.res td.n{{font-family:"IBM Plex Mono",monospace;text-align:right;padding-right:20px;
 font-variant-numeric:tabular-nums}}
table.res td.m{{font-family:"IBM Plex Mono",monospace}}
table.res tr.bad td{{color:var(--bad)}}
footer{{margin-top:52px;padding-top:17px;border-top:1px solid var(--ln);
 font-family:"IBM Plex Mono",monospace;font-size:11px;color:var(--dim)}}
:focus-visible{{outline:2px solid var(--amb);outline-offset:2px}}
@media (prefers-reduced-motion:reduce){{*{{animation:none!important;transition:none!important}}}}
</style>

<div class="wrap">
<header>
  <h1>Which Way to Multiply</h1>
  <p>Five ways to formulate C = A&middot;B &mdash; inner product, outer product, row-wise,
     column-wise and tiled &mdash; each mapped onto what a Cerebras WSE-3 processing element
     actually executes, and each measured. Ten variants, {fm(MACS)} multiply-accumulates
     apiece, {M}&times;{N}&times;{K} in f16, every result checked against a host reference.</p>
</header>

<div class="kpi">
  <div><b>86&times;</b><span>between the best formulation and the worst correct one</span></div>
  <div><b class="t">1 port</b><span>the FMA broadcasts one scalar; that is why row-wise wins</span></div>
  <div><b class="t">1 &rarr; 8</b><span>lanes recovered by transposing B and changing nothing else</span></div>
  <div><b class="t">4.0&times;</b><span>the tiled outer product over the correct inner product</span></div>
</div>

<h2>How the PE multiplies</h2>
<p>Every classification below is really a question about one instruction. FMACH computes
<code>dest = src0 + src1 &times; src2</code> in one rounding, where <strong>src2 is a single scalar
broadcast to all eight lanes</strong> and the other two ports carry vectors out of memory through
descriptors. So a formulation is fast on this machine exactly when it can put a vector on the
vector ports, a scalar on the scalar port, and read both vectors at unit stride.</p>
<figure>
<svg viewBox="0 0 900 280" role="img" aria-label="The FMACH instruction has three operand ports: a destination and source-0 port carrying the accumulator vector, a source-1 port carrying a streamed vector, and a source-2 port carrying one scalar broadcast to all eight lanes. Both vector ports read memory through descriptors and deliver eight elements per cycle in the contiguous case; the stride-32 operands in this probe use one SIMD lane.">
 <defs><marker id="a" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path d="M0,0 L10,5 L0,10 z" fill="currentColor"/></marker></defs>
 <g font-size="12" fill="currentColor">
  <rect x="20" y="24" width="150" height="128" rx="3" fill="none" stroke="currentColor" stroke-opacity=".45"/>
  <text x="34" y="46" font-weight="600">data SRAM</text>
  <text x="34" y="64" font-size="10.5" fill-opacity=".62">48 KiB, flat, no cache</text>
  <text x="34" y="92" font-size="11">A, B, C all resident</text>
  <text x="34" y="112" font-size="10.5" fill-opacity=".62">stride is a property of</text>
  <text x="34" y="126" font-size="10.5" fill-opacity=".62">the descriptor, not the data</text>

  <rect x="214" y="24" width="140" height="56" rx="3" fill="none" stroke="var(--teal)"/>
  <text x="228" y="46" fill="var(--teal)" font-weight="600">descriptor</text>
  <text x="228" y="63" font-size="10.5" fill="var(--teal)">base, length, stride</text>
  <rect x="214" y="96" width="140" height="56" rx="3" fill="none" stroke="var(--teal)"/>
  <text x="228" y="118" fill="var(--teal)" font-weight="600">descriptor</text>
  <text x="228" y="135" font-size="10.5" fill="var(--teal)">base, length, stride</text>
  <rect x="214" y="168" width="140" height="44" rx="3" fill="none" stroke="var(--amb)"/>
  <text x="228" y="195" fill="var(--amb)" font-weight="600">scalar register</text>

  <line x1="170" y1="52" x2="210" y2="52" stroke="currentColor" marker-end="url(#a)"/>
  <line x1="170" y1="124" x2="210" y2="124" stroke="currentColor" marker-end="url(#a)"/>
  <line x1="170" y1="190" x2="210" y2="190" stroke="currentColor" marker-end="url(#a)"/>

  <rect x="470" y="24" width="210" height="188" rx="3" fill="none" stroke="currentColor" stroke-opacity=".8"/>
  <text x="484" y="46" font-weight="600">FMACH</text>
  <text x="484" y="64" font-size="10.5" fill-opacity=".62">fused, one rounding</text>
  <text x="484" y="88" font-size="11.5" font-family="IBM Plex Mono,monospace">dest = src0 + src1 &#215; src2</text>
  <g font-size="10.5">
   <rect x="484" y="104" width="182" height="26" rx="2" fill="none" stroke="var(--teal)" stroke-opacity=".7"/>
   <text x="494" y="121" fill="var(--teal)">src0 / dest &mdash; vector port</text>
   <rect x="484" y="136" width="182" height="26" rx="2" fill="none" stroke="var(--teal)" stroke-opacity=".7"/>
   <text x="494" y="153" fill="var(--teal)">src1 &mdash; vector port</text>
   <rect x="484" y="168" width="182" height="26" rx="2" fill="none" stroke="var(--amb)" stroke-opacity=".8"/>
   <text x="494" y="185" fill="var(--amb)">src2 &mdash; ONE scalar, broadcast</text>
  </g>
  <line x1="354" y1="52" x2="466" y2="115" stroke="var(--teal)" marker-end="url(#a)"/>
  <line x1="354" y1="124" x2="466" y2="147" stroke="var(--teal)" marker-end="url(#a)"/>
  <line x1="354" y1="190" x2="466" y2="181" stroke="var(--amb)" marker-end="url(#a)"/>

  <rect x="720" y="52" width="158" height="60" rx="3" fill="none" stroke="var(--teal)"/>
  <text x="734" y="74" fill="var(--teal)" font-weight="600">8 lanes</text>
  <text x="734" y="92" font-size="10.5" fill="var(--teal)">f16, 128 bit/cycle</text>
  <rect x="720" y="128" width="158" height="60" rx="3" fill="none" stroke="currentColor" stroke-opacity=".4"/>
  <text x="734" y="150" fill-opacity=".72" font-weight="600">1 lane</text>
  <text x="734" y="168" font-size="10.5" fill-opacity=".6">any non-unit stride</text>
  <line x1="680" y1="100" x2="716" y2="82" stroke="var(--teal)" marker-end="url(#a)"/>
  <line x1="680" y1="136" x2="716" y2="158" stroke="currentColor" stroke-opacity=".5" marker-end="url(#a)"/>
  <text x="690" y="232" font-size="10.5" fill-opacity=".6">measured: unit stride on every operand &rarr; 8 elements/cycle.</text>
  <text x="690" y="248" font-size="10.5" fill-opacity=".6">One strided operand &rarr; 1 element/cycle.</text>
 </g>
</svg>
<figcaption>The instruction's shape is the whole argument. One scalar port means a formulation
that needs two vectors per step (an outer product) cannot be one instruction, and a formulation
that needs a reduction (an inner product) has no instruction at all. Lane counts here are
measured across ten variants, not assumed.</figcaption>
</figure>

<h2>The five formulations, mapped</h2>
{''.join(card(c) for c in CLASSES)}

<h2>All ten variants</h2>
<div class="tw"><table class="res">
<thead><tr><th>Variant</th><th>Class</th><th>Operand stride</th><th class="n">Lanes</th>
<th class="n">Cycles</th><th class="n">FP instructions</th><th class="n">vs best</th><th>Value check</th></tr></thead>
<tbody>{''.join(vrow(v) for v in ORDER)}</tbody></table></div>
<p>Cycles are the on-device cycle counter; the trace's own phase spans agree with it to between
0.01% and 0.69%. Lanes is the most lanes ever seen retiring together in that variant's
floating-point instruction.</p>

<h2>Step through any of them</h2>
<p>Pick a variant and step the inner loop. The grids show which element of A is broadcast as the
scalar, which vector streams, and the order C fills &mdash; which is the real visual difference
between the classes. The instruction stream beside it is traced, with measured cycle offsets.</p>
<div class="tabs" id="tabs"></div>
<div class="console">
  <div class="card">
    <p class="eyebrow">Generated CSL &middot; floating-point statement highlighted</p>
    <pre id="src"></pre>
    <div class="note" id="note"></div>
  </div>
  <div class="card">
    <p class="eyebrow">Dataflow at this step</p>
    <div class="grids">
      <div class="gw"><canvas id="gA" width="{K}" height="{M}"></canvas><span id="lA">A</span></div>
      <div class="gw"><canvas id="gB" width="{N}" height="{K}"></canvas><span id="lB">B</span></div>
      <div class="gw"><canvas id="gC" width="{N}" height="{M}"></canvas><span id="lC">C</span></div>
    </div>
    <div class="ctl">
      <button class="p" id="play">Play</button>
      <button id="back">&larr;</button><button id="fwd">&rarr;</button>
      <input type="range" id="scrub" min="0" value="0">
    </div>
    <div class="rd" id="rd"></div>
    <p class="eyebrow" style="margin-top:13px">Traced instruction stream, first iterations</p>
    <div class="stream"><table id="strm"></table></div>
  </div>
</div>

<h2>Why the classification does not predict the cost</h2>
<p>The classical grouping puts K's position first: K innermost is the inner product form, K
outermost is the outer product, K in the middle is the axpy. Measured, that grouping is
internally inconsistent &mdash; and grouping by what the <em>innermost</em> loop walks is almost
perfect.</p>
<div class="tw"><table class="res">
<thead><tr><th>Grouping</th><th>Group</th><th>Members</th><th class="n">Spread within group</th></tr></thead>
<tbody>
<tr><td rowspan="3">By K's position (classical)</td><td>inner product</td><td class="m">ijk, jik</td><td class="n">1.03x</td></tr>
<tr><td>axpy / gaxpy</td><td class="m">ikj, jki</td><td class="n">2.31x</td></tr>
<tr><td>outer product</td><td class="m">kij, kji</td><td class="n">2.29x</td></tr>
<tr><td rowspan="3">By innermost loop</td><td>j</td><td class="m">ikj, kij</td><td class="n">1.00x</td></tr>
<tr><td>i</td><td class="m">jki, kji</td><td class="n">1.01x</td></tr>
<tr><td>k</td><td class="m">ijk, jik</td><td class="n">1.03x</td></tr>
</tbody></table></div>
<p><code>ikj</code> is an axpy and <code>kij</code> is an outer product and they differ by 0.06%.
<code>ikj</code> and <code>jki</code> are both axpy forms and differ by 2.31x. The reason is in the
diagram above: the innermost loop is what sets the stride on the two vector ports, and stride is
what decides whether you get eight lanes or one.</p>

<h2>Mapping the seven-view reference to the PE</h2>
<p>The updated local reference has been reviewed: inner product, outer product,
row and column AXPY, two GEMV-level views, and tiling. The GEMV views group AXPY
steps; they are not separate loop permutations. Its persistent A/B/C values,
Delta-C panel and coarse/fine navigation are useful teaching patterns.</p>
<p>The compiled row FMACH kernels here use memory descriptors for C. Their
accumulation remains local to one PE, while C is read and updated through SRAM
operands. This differs from the reference's illustrative GPU register tile.
A match between consecutive arithmetic values confirms dependence; descriptors
and disassembly establish the storage path. These observations do not prove a
universal restriction on all WSE instruction sequences or output tile shapes.</p>
<p>The corrected comparison demonstrates two controls missing from the original
capture: zero-stride DSD dot reductions pass, and packing B in tile order makes
blocked @map correct (17,550 cycles versus 158,988 for descriptor-reloading
blocking at 32x32). Full-row @map remains fastest in that sweep at 10,239 cycles.
Packing is outside the kernel interval. The original failed reductions used a
fixed scalar source instead of accumulator feedback; they do not establish a
compiler defect.</p>
<p>Our blocked kernels split j into row segments. The reference's 2x2 output tiles
and explicit K-tile traversal require a separate I/J/K tiled control. See
<a href="../../MATMUL_REFERENCE_REVIEW.md">the detailed reference review</a> and
<a href="../matmul-compare/matmul.html">the corrected WebGL comparison</a>.
Performance depends on the implementation and on the memory boundary being
measured; GPU traffic formulas cannot be compared directly with PE-local SRAM
traffic.</p>

<h2>The stride rule, tested directly</h2>
<p><code>ijk with B&#7488;</code> is identical to <code>ijk</code> in every respect except that B is
read from a pre-transposed copy, making both vector operands unit stride. Same opcode, same 32
elements, same loop nest.</p>
<div class="tw"><table class="res">
<thead><tr><th>Variant</th><th>Operand stride</th><th class="n">Lanes</th><th class="n">Cycles for 32 elements</th><th class="n">Elements / cycle</th></tr></thead>
<tbody>
<tr><td class="m">ijk</td><td>B column, stride 32</td><td class="n">1</td><td class="n">32</td><td class="n">1.0</td></tr>
<tr><td class="m">ijk with B&#7488;</td><td>all unit</td><td class="n">8</td><td class="n">4</td><td class="n">8.0</td></tr>
</tbody></table></div>
<p>The prediction came from earlier lane measurements and held. Across all ten variants the rule
separates perfectly. Layout fixes the lanes; it does not fix the reduction, and
<code>ijk with B&#7488;</code> still returns the wrong numbers.</p>

<h2>The textbook answer is wrong, not just slow</h2>
<p>The three inner-product variants written with the DSD reduction builtin return wrong values.
The reduction compiled with a different register in the destination and source-0 fields:</p>
<pre style="color:var(--bad)">faddh r15 = r5, [s1ds1]     // dest != src0, so nothing accumulates</pre>
<p>They return <code>A[i,K-1]&times;B[K-1,j]</code> &mdash; only the last product &mdash; and the
test of that hypothesis gives a maximum error of exactly 0.000000. This study had the same defect
on file for f32 with a runtime-length descriptor implicated; both are now refuted, since this is
f16 with a compile-time length. The broken form is also <em>faster</em> than the correct one, so
only a value check catches it.</p>

<p class="note"><strong>Follow-up, 2026-09-22:</strong> Corrected reductions and packed-B tiling were tested at 4×4, 8×8 and 32×32. See <a href="../matmul-compare/matmul.html">the WebGL trace-replay comparison</a>. These retained timings describe the original implementations.</p>
<footer>WSE-3 characterization study &middot; SDK 2.10 &middot; microbench/matmulorder &middot;
{fm(sum(V[v]["fp_dispatches"] for v in V))} floating-point dispatches traced &middot;
built {dt.datetime.now():%Y-%m-%d}</footer>
</div>

<script>
const D = {json.dumps(PAY)};
const M = {M}, N = {N}, K = {K};
const ORDER = {json.dumps(ORDER)};
const $ = i => document.getElementById(i);
const esc = s => String(s).replace(/[&<>]/g, c => ({{'&':'&amp;','<':'&lt;','>':'&gt;'}}[c]));
let cur = ORDER[0], step = 0, playing = false, timer = null;

function nsteps(v){{ const s = D[v].shape; return s.no * s.ni; }}
function idx(v, n){{
  const s = D[v].shape, o = Math.floor(n / s.ni), m = n % s.ni;
  const r = {{}}; r[s.outer] = o; r[s.mid] = m; return r;
}}
const css = x => getComputedStyle(document.documentElement).getPropertyValue(x).trim();

function paint(v, n){{
  const s = D[v].shape, id = idx(v, n);
  const base = css('--pan2'), amb = css('--amb'), teal = css('--teal'), done = css('--dim');
  const g = (c, w, h) => {{ const x = c.getContext('2d'); x.clearRect(0,0,w,h);
    x.fillStyle = base; x.fillRect(0,0,w,h); return x; }};
  const xa = g($('gA'), K, M), xb = g($('gB'), N, K), xc = g($('gC'), N, M);
  xc.fillStyle = done;
  if (s.kind === 'row'){{
    const seen = new Set();
    for (let t = 0; t <= n; t++) seen.add(idx(v, t).i);
    for (const i of seen) xc.fillRect(0, i, N, 1);
  }} else if (s.kind === 'col'){{
    const seen = new Set();
    for (let t = 0; t <= n; t++) seen.add(idx(v, t).j);
    for (const j of seen) xc.fillRect(j, 0, 1, M);
  }} else if (s.kind === 'otile'){{
    for (let t = 0; t <= n; t++){{ const q = idx(v, t); xc.fillRect(0, q.ib*4, N, 4); }}
  }} else if (s.kind === 'rowblk'){{
    for (let t = 0; t < n; t++){{ const q = idx(v, t); xc.fillRect(q.jb*(N/4), q.i, N/4, 1); }}
  }} else {{
    for (let t = 0; t < n; t++){{ const q = idx(v, t); xc.fillRect(q.j, q.i, 1, 1); }}
  }}
  if (s.kind === 'row'){{
    xa.fillStyle = amb; xa.fillRect(id.k, id.i, 1, 1);
    xb.fillStyle = teal; xb.fillRect(0, id.k, N, 1);
    xc.fillStyle = amb; xc.fillRect(0, id.i, N, 1);
  }} else if (s.kind === 'col'){{
    xb.fillStyle = amb; xb.fillRect(id.j, id.k, 1, 1);
    xa.fillStyle = teal; xa.fillRect(id.k, 0, 1, M);
    xc.fillStyle = amb; xc.fillRect(id.j, 0, 1, M);
  }} else if (s.kind === 'otile'){{
    xa.fillStyle = amb; xa.fillRect(id.k, id.ib*4, 1, 4);     // 4 scalars, one per row
    xb.fillStyle = teal; xb.fillRect(0, id.k, N, 1);          // ONE B row, reused 4x
    xc.fillStyle = amb; xc.fillRect(0, id.ib*4, N, 4);        // 4 rows of C accumulate
  }} else if (s.kind === 'rowblk'){{
    const w = N / 4;
    xa.fillStyle = teal; xa.fillRect(0, id.i, K, 1);
    xb.fillStyle = teal; xb.fillRect(id.jb*w, 0, w, K);
    xc.fillStyle = amb; xc.fillRect(id.jb*w, id.i, w, 1);
  }} else {{
    xa.fillStyle = teal; xa.fillRect(0, id.i, K, 1);
    xb.fillStyle = teal; xb.fillRect(id.j, 0, 1, K);
    xc.fillStyle = amb; xc.fillRect(id.j, id.i, 1, 1);
  }}
  const L = s.kind === 'row'
    ? [`A[i,k] &rarr; scalar port &nbsp;i=${{id.i}} k=${{id.k}}`, `B[k,:] &rarr; vector port, unit`, `C[i,:] accumulates`]
    : s.kind === 'col'
    ? [`A[:,k] &rarr; vector port, stride ${{N}}`, `B[k,j] &rarr; scalar port`, `C[:,j] accumulates`]
    : s.kind === 'dotT'
    ? [`A[i,:] unit &nbsp;i=${{id.i}}`, `B&#7488;[j,:] unit &nbsp;j=${{id.j}}`, `C[i,j] one cell, needs a reduction`]
    : s.kind === 'otile'
    ? [`A[${{id.ib*4}}..${{id.ib*4+3}}, k] &rarr; 4 scalars &nbsp;k=${{id.k}}`,
       `B[k,:] &rarr; vector port, read once, used 4&times;`,
       `C[${{id.ib*4}}..${{id.ib*4+3}}, :] &mdash; a 4-row tile accumulates`]
    : s.kind === 'rowblk'
    ? [`A[i,:] scalars &nbsp;i=${{id.i}}`, `B[:, tile ${{id.jb}}] &nbsp;${{N/4}} wide`, `C[i, tile ${{id.jb}}] over all k`]
    : [`A[i,:] unit &nbsp;i=${{id.i}}`, `B[:,j] stride ${{N}} &nbsp;j=${{id.j}}`, `C[i,j] one cell, needs a reduction`];
  $('lA').innerHTML = L[0]; $('lB').innerHTML = L[1]; $('lC').innerHTML = L[2];
}}

function srcHTML(v){{
  return (D[v].src || '').split('\\n').map(L => {{
    if (/@fmach|@fmulh|@faddh|acc \\+=/.test(L)) return `<span class="hl">${{esc(L)}}</span>`;
    if (L.trim().startsWith('//')) return `<span class="cm">${{esc(L)}}</span>`;
    return esc(L);
  }}).join('\\n');
}}
function streamHTML(v){{
  return (D[v].steps || []).map(s =>
    `<tr class="${{/^F(MAC|MUL|ADD)/.test(s.op) ? 'fp' : ''}}"><td>+${{s.cyc}}</td>`
    + `<td>0x${{s.pc.toString(16)}}</td><td>${{esc(s.op)}}</td>`
    + `<td>${{s.nd != null && s.nd < 65535 ? s.nd + ' el' : ''}}</td></tr>`).join('');
}}

function render(){{
  const v = cur, x = D[v], ns = nsteps(v);
  $('tabs').querySelectorAll('button').forEach(b =>
    b.setAttribute('aria-pressed', String(b.dataset.v === v)));
  $('src').innerHTML = srcHTML(v);
  $('note').innerHTML = esc(x.note);
  $('note').className = 'note' + (x.ok ? '' : ' bad');
  $('scrub').max = ns - 1;
  if (+$('scrub').value !== step) $('scrub').value = step;
  paint(v, step);
  $('rd').innerHTML =
    `inner step <b>${{step + 1}}</b> of ${{ns}} &nbsp;&middot;&nbsp; `
    + `<b>${{x.tsc.toLocaleString()}}</b> cycles total, <b>${{(x.tsc/ns).toFixed(1)}}</b> per step`
    + ` &nbsp;&middot;&nbsp; ${{x.fpop}} covers <b>${{x.fpel}}</b> elements on <b>${{x.lanes}}</b>`
    + ` lane${{x.lanes > 1 ? 's' : ''}} in <b>${{x.fpcy}}</b> cycles &nbsp;&middot;&nbsp; ${{esc(x.stride)}}`
    + (x.ok ? '' : ' &nbsp;&middot;&nbsp; <b style="color:var(--bad)">wrong result</b>');
  $('strm').innerHTML = streamHTML(v);
}}

$('tabs').innerHTML = ORDER.map(v =>
  `<button data-v="${{v}}" aria-pressed="false"><i class="cl-${{D[v].cls}}"></i>`
  + `${{esc(D[v].label)}} &nbsp;${{D[v].ok ? D[v].vs+'x' : 'not ranked'}}</button>`).join('');
$('tabs').querySelectorAll('button').forEach(b => b.onclick = () => {{
  cur = b.dataset.v; step = 0; render(); }});
$('fwd').onclick = () => {{ step = Math.min(nsteps(cur) - 1, step + 1); render(); }};
$('back').onclick = () => {{ step = Math.max(0, step - 1); render(); }};
$('scrub').oninput = e => {{ step = +e.target.value; render(); }};
$('play').onclick = () => {{
  playing = !playing; $('play').textContent = playing ? 'Pause' : 'Play';
  if (timer) clearInterval(timer);
  if (playing) timer = setInterval(() => {{ step = (step + 1) % nsteps(cur); render(); }}, 90);
}};
addEventListener('keydown', e => {{
  if (e.key === 'ArrowRight'){{ e.preventDefault(); $('fwd').click(); }}
  if (e.key === 'ArrowLeft'){{ e.preventDefault(); $('back').click(); }}
}});
render();
</script>
"""
out = S / "results/anatomy/matmul_order_v2.html"
out.write_text(HTML)
print(f"-> {out}  {out.stat().st_size/1024:.0f} KB")
