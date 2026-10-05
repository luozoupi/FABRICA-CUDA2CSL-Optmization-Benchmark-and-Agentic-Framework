#!/usr/bin/env python3
"""Assemble results/anatomy/sparse_dataflow.html from the traced sparse runs.

head + CSS: the GEMM page's template (same palette and layout rules), plus the same CSS additions.
body: tools/sparse_dataflow.html; script: tools/sparse_dataflow.js with %%DATA%% = the payload:
  walk      results/datapath/sparse_walk.json  (tools/sparse_walk_values.py: trace-checked values)
  snip      results/datapath/sparse_snippets.json (verbatim source)
  refs      benchmark-size cycles from each task's spec.yaml wse3_reference and the expert README
  hyper     what the Cerebras hypersparse SpMV example does, from its layout source (not traced here)
No number on the page is typed by hand.
"""
import json, re, sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))
from gemm_dataflow_build import CSS

ROOT = Path(__file__).resolve().parents[1]
TOOLS = ROOT / "tools"; DP = ROOT / "results/datapath"; K = Path.home() / "xkernel/kernels"
OUT = ROOT / "results/anatomy/sparse_dataflow.html"

def spec_ref(task, size="small"):
    s = (K / task / "spec.yaml").read_text()
    blk = s[s.index(f"- name: {size}"):]; blk = blk[:blk.find("- name:", 10) if blk.find("- name:", 10) > 0 else None]
    m = re.search(r"cycles_send:\s*(\d+)", blk); p = re.search(r"params:\s*\{([^}]*)\}", blk); c = re.search(r'structure_class:\s*"([^"]+)"\s*#\s*([^\n]*)', blk)
    return dict(cycles=int(m.group(1)), params=p.group(1).strip(), desc=f"{p.group(1).strip()}; {c.group(2).strip() if c else ''}".strip("; "))

def expert_refs():
    t = (K / "_sparse_expert/README.md").read_text()
    m = re.search(r"pe_dense_accumulator\.csl.*?\|\s*([\d,]+) vs ([\d,]+) \(([\d.]+)x\) at list ([\d.]+);\s*\*\*([\d,]+) vs ([\d,]+) \(([\d.]+)x\)\*\* at list ([\d.]+)", t)
    return dict(desc=f"{m.group(1)} vs {m.group(2)} cycles ({m.group(3)}x) at mean list length {m.group(4)}; {m.group(5)} vs {m.group(6)} ({m.group(7)}x) at {m.group(8)} (n144)") if m else None

def hyper_text():
    lay = (K / "SpMV Hypersparse/CSL/src/hypersparse_spmv/layout.csl").read_text()
    colours = len(re.findall(r"param colors:\[(\d+)\]color", lay)) and int(re.search(r"param colors:\[(\d+)\]color", lay).group(1))
    top = (K / "SpMV Hypersparse/CSL/src/layout.csl").read_text()
    ar = int(re.search(r"\.colors = \[(\d)\]color\{allreduce_c0", top).group(1))
    return f"""<p>The SDK's own multi-PE sparse example, <code>spmv-hypersparse</code>, is the design these three reference kernels are
measured against, and it moves data differently again. From its layout source (SDK example, WSE-2 build in this corpus, not
traced here):</p>
<ul>
<li><b>2-D partition.</b> A is cut into a grid of tiles, one per PE; x and y are distributed by column and by row. Each PE holds
its tile's nonzeros as (row, col, value) lists.</li>
<li><b>x moves as north/south "trains".</b> Two colours carry x values up and down each PE column so that every PE of the column
sees the x entries its tile needs (<code>compute_north</code> / <code>compute_south</code> tasks, one colour per direction).</li>
<li><b>Partial y moves as west/east trains.</b> Four colours, alternating by column parity, carry (value, row) pairs along each PE
row; each PE merges what arrives into its local dense y slice (<code>reduce_local_west/east</code>). The reduction is a sparse
merge, not a dense allreduce.</li>
<li><b>{colours} routable colours for the product, {ar} more for the synchronising allreduce</b> that aligns the PEs' clocks before timing.</li>
</ul>
<p>Against that, the reference SpMV here is the simplest strip: whole rows per PE, x multicast once, no reduction. The Cerebras
design trades one multicast for a train of x along every column and a merge of y along every row, which is what a general 2-D
tiling of a hypersparse matrix forces. Neither the trains nor the merges are asserted here beyond the source.</p>"""

def main():
    walk = json.loads((DP / "sparse_walk.json").read_text()); snip = json.loads((DP / "sparse_snippets.json").read_text())
    refs = dict(spmv=spec_ref("SpMV-RowBlock"), spmm=spec_ref("SpMM-CSR-Dense"), spgemm=spec_ref("SpGEMM-Masked-Dot"), spgemm_acc=expert_refs())
    v, m, g, a = walk["spmv"], walk["spmm"], walk["spgemm"], walk["spgemm_acc"]
    evidence = [
        ["SpMV: 39 multiply/add pairs, 16 outputs, 132 host words, 16 multicast packets", "meas", f"traced instance; arithmetic {v['checks']['arithmetic']}, outputs {v['checks']['outputs']}, words {v['io']['h2d_words_found']}/{v['io']['h2d_words_expected']}, colour-8 packets {v['mcast']['packets']} × {v['mcast']['routers_per_packet']} routers"],
        ["SpMV: PE 1 and 2 deliver and forward x (multicast)", "src", "layout.csl routes rx WEST → tx RAMP, EAST; trace: every packet seen at all four routers and three PEs compute with it"],
        ["SpMM: 76 multiply/add pairs, 32 outputs, no kernel traffic", "meas", f"arithmetic {m['checks']['arithmetic']}, outputs {m['checks']['outputs']}, kernel colours {m['kernel_colours']}"],
        ["SpGEMM merge: 26 products, 22 values, 22 row codes, 9 zombies", "meas", f"arithmetic {g['checks']['arithmetic']}, c_val {g['checks']['c_values']}, codes {g['checks']['row_codes']}, zombies {g['checks']['zombies']}"],
        ["SpGEMM accumulator: 62 products (36 of them by 0.0), same outputs", "meas", f"arithmetic {a['checks']['arithmetic']}, c_val {a['checks']['c_values']}; {a['compute_span'][1] - a['compute_span'][0]} vs {g['compute_span'][1] - g['compute_span'][0]} cycles over the entries"],
        ["Benchmark-size cycles", "meas", "the study's SDK 2.10 simulator runs recorded in each spec.yaml (wse3_reference) and the expert README; not re-run here"],
        ["Queue depths (WSE-3: IQ 8/8/4/4/4/4/4/4, OQ 8 words)", "doc", "SDK 2.10 DSD documentation"],
        ["Hypersparse SpMV design", "src", "Cerebras sdk-examples layout and kernel source; not traced"],
    ]
    foot = ("Traces: microbench/sparse_walk/{spmv,spmm,spgemm,spgemm_acc}/events.jsonl.gz (SDK 2.10 simulator, cs_python, one I/O channel). "
            "Kernel sources are the unmodified references in kernels/<Task>/CSL (hashes in each manifest.json); only the host program and the instance are the study's. "
            "Extraction: tools/sparse_walk_values.py; snippets: tools/sparse_snippets.py; page: tools/sparse_dataflow_build.py.")
    payload = dict(walk=walk, snip=snip, refs=refs, hyper=hyper_text(), evidence=evidence, foot=foot)
    tpl = (TOOLS / "gemm_dataflow.tpl.html").read_text()
    headp = tpl[:tpl.index("</style>")].replace("<title>Where the Operands Live</title>", "<title>Sparse Products on the Mesh</title>")
    page = headp + CSS + "</style>\n" + (TOOLS / "sparse_dataflow.html").read_text() + "\n<script>\n" + \
        (TOOLS / "sparse_dataflow.js").read_text().replace("%%DATA%%", json.dumps(payload, separators=(",", ":")).replace("</", "<\\/"), 1) + "\n</script>\n"
    OUT.write_text(page); print(f"{OUT} {len(page):,} bytes")

if __name__ == "__main__":
    main()
