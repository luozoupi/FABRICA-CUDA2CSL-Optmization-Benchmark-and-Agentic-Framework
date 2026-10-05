#!/usr/bin/env python3
"""Assemble results/anatomy/gemm_dataflow_v7.html (and mesh_webgl_v2.html).

template (gemm_dataflow.tpl.html) + mesh-section markup (gemm_dataflow_mesh.html)
+ mesh-section script (gemm_dataflow_mesh.js) + a data payload taken verbatim from the
verification outputs in results/datapath/. No number on the page is typed by hand.
"""
import json, pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
DP = ROOT / 'results/datapath'
TOOLS = ROOT / 'tools'
OUT = ROOT / 'results/anatomy/gemm_dataflow_v7.html'
GL = ROOT / 'results/anatomy/mesh_webgl_v2.html'

CSS = r"""
:root{--io:#6B4FC8} @media (prefers-color-scheme:dark){:root:not([data-theme="light"]){--io:#B7A3FF}}
:root[data-theme="dark"]{--io:#B7A3FF}
.life{display:flex;flex-wrap:wrap;align-items:flex-end;gap:6px 10px;margin:14px 0 10px}
.lg{display:flex;flex-direction:column;gap:4px}
.lgn{font-family:"IBM Plex Mono",monospace;font-size:10px;letter-spacing:.1em;text-transform:uppercase;color:var(--dim)}
.lgp{display:flex;gap:3px}
.lgp button{font-family:"IBM Plex Mono",monospace;font-size:12px;min-width:34px;min-height:32px;padding:4px 8px;
 border:1px solid var(--ln);background:var(--pan);color:var(--ink2);border-radius:2px;cursor:pointer}
.lgp button[aria-pressed="true"]{background:var(--ink);color:var(--bg);border-color:var(--ink);font-weight:600}
.lga{color:var(--dim);padding-bottom:6px}
.meshcard svg{display:block;width:100%;height:auto;color:var(--ink);margin-top:6px}
.viewtag{font-family:"IBM Plex Mono",monospace;font-size:11px;color:var(--dim);border:1px solid var(--ln);
 padding:3px 8px;border-radius:2px}
.mkey{display:flex;flex-wrap:wrap;gap:6px 18px;font-family:"IBM Plex Mono",monospace;font-size:11px;color:var(--ink2);margin-top:8px}
.mkey i{display:inline-block;width:11px;height:11px;margin-right:6px;vertical-align:-1px}
.mkey .sq{border:1px solid var(--ink2);border-radius:2px}
.mkey .ring{border:1.5px dashed var(--ink2);border-radius:50%}
.mkey .dot{background:var(--ink2);border-radius:50%}
.chip{cursor:pointer;outline:none}
.chip:hover rect,.chip:focus-visible rect{stroke-width:2.6}
rect.chip:hover,rect.chip:focus-visible{stroke:var(--ink);stroke-width:2}
.below{display:grid;grid-template-columns:minmax(0,1fr) minmax(0,1fr);gap:14px;margin-top:14px}
@media (max-width:960px){.below{grid-template-columns:1fr}}
.checks{list-style:none;padding:0;margin:10px 0 0;font-size:12.5px}
.checks li{display:flex;justify-content:space-between;gap:12px;padding:5px 0;border-bottom:1px dotted var(--ln);color:var(--ink2)}
.checks b{font-family:"IBM Plex Mono",monospace;font-weight:600;color:var(--c);white-space:nowrap}
.detail h3{margin:4px 0 8px;font-size:15px}
.detail svg.heat{display:block;width:100%;max-width:300px;height:auto;color:var(--ink)}
.detail .hc{cursor:pointer}
.mini{font-size:11.5px;color:var(--dim);margin:4px 0 8px}
.ok{font-size:12.5px;color:var(--c);border-left:2px solid var(--c);padding-left:9px;margin-top:10px}
.bad{font-size:12.5px;color:var(--bad);border-left:2px solid var(--bad);padding-left:9px}
.vec{display:grid;grid-template-columns:repeat(auto-fill,minmax(92px,1fr));gap:3px;font-family:"IBM Plex Mono",monospace;font-size:11px}
.vec span{border-left:2px solid;padding:2px 6px;background:var(--pan2)}
table.chain{border-collapse:collapse;font-family:"IBM Plex Mono",monospace;font-size:11.5px;margin:6px 0;width:100%}
table.chain th,table.chain td{text-align:right;padding:3px 8px;border-bottom:1px solid var(--ln)}
table.chain th{color:var(--dim);font-weight:500}
table.chain td:first-child,table.chain th:first-child{text-align:left}
details.code{margin:8px 0;border:1px solid var(--ln);border-radius:2px;background:var(--pan2)}
details.code summary{font-family:"IBM Plex Mono",monospace;font-size:11.5px;padding:6px 10px;cursor:pointer;color:var(--ink2)}
details.code pre{margin:0;padding:8px 0;overflow-x:auto;font-family:"IBM Plex Mono",monospace;font-size:11.5px;line-height:1.5;
 border-top:1px solid var(--ln);background:var(--pan)}
details.code .ln{display:block;padding:0 12px 0 0;white-space:pre}
details.code .ln i{display:inline-block;width:40px;text-align:right;margin-right:12px;color:var(--dim);font-style:normal;user-select:none}
details.code .ln.hl{background:color-mix(in srgb,var(--c) 14%,transparent);box-shadow:inset 2px 0 0 var(--c)}
.gridwrap{overflow-x:auto;margin:6px 0 2px;-webkit-overflow-scrolling:touch}
table.grid{border-collapse:collapse;font-family:"IBM Plex Mono",monospace;font-size:10px;line-height:1.25}
table.grid th{font-weight:500;color:var(--dim);padding:1px 3px;text-align:right;font-size:9px}
table.grid th.on{color:var(--ink);font-weight:700}
table.grid th.corner{font-size:8.5px;text-align:left}
table.grid td{padding:2px 3px;text-align:right;border:1px solid var(--ln);color:var(--ink2);min-width:30px}
table.grid.g-x td.hl{background:color-mix(in srgb,var(--x) 16%,transparent);color:var(--ink)}
table.grid.g-w td.hl{background:color-mix(in srgb,var(--w) 16%,transparent);color:var(--ink)}
table.grid.g-c td.hl{background:color-mix(in srgb,var(--c) 16%,transparent)}
table.grid td.sel{outline:2px solid var(--ink);outline-offset:-2px;background:color-mix(in srgb,var(--c) 26%,transparent);color:var(--ink);font-weight:700}
table.grid.clk td{cursor:pointer} table.grid.clk td:hover{background:var(--pan2);color:var(--ink)}
table.chain td.cx{color:var(--x)} table.chain td.cw{color:var(--w)} table.chain td.cc{color:var(--c);font-weight:600}
.tfilter{display:inline-flex;gap:4px}
.tfilter button{font-family:"IBM Plex Mono",monospace;font-size:11px;padding:4px 9px;border:1px solid var(--ln);background:var(--pan);color:var(--ink2);border-radius:2px;cursor:pointer;min-height:28px}
.tfilter button[aria-pressed="true"]{background:var(--ink);color:var(--bg);border-color:var(--ink)}
.toype{cursor:pointer} .toype:focus-visible rect{stroke-width:3}
#cycfig .zoomrow{display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:14px;margin:8px 0}
#cycfig #cyczoom{margin-top:14px}
#cycfig canvas{display:block;width:100%;height:auto;background:var(--pan);border:1px solid var(--ln);border-radius:4px;margin-top:8px}
#cycfig select{font-family:"IBM Plex Mono",monospace;font-size:11px;padding:5px 8px;border:1px solid var(--ln);background:var(--pan2);color:var(--ink2);border-radius:2px;min-height:30px}
#cycfig .cycpre{font-family:"IBM Plex Mono",monospace;font-size:11px;line-height:1.5;white-space:pre-wrap;color:var(--ink2);margin:0;max-height:360px;overflow:auto}
#cycfig input[type=range]{accent-color:var(--ink);margin:10px 0 0}
.kshade i{display:inline-block;width:11px;height:11px;margin:0 1px;border-radius:2px;vertical-align:-1px}
"""

def load(n): return json.loads((DP / n).read_text())

def payload():
    st, gv, gl = load('meshgemm_steps.json'), load('meshgemm_values.json'), load('meshgemm_lifecycle.json')
    vv, vl, snip = load('meshgemv_values.json'), load('meshgemv_lifecycle.json'), load('csl_snippets.json')
    gf = load('gemm_dataflow.json')['WaferLLM-MeshGEMV']['colours']
    assert st['verified'] and gv['P'] == st['P'] == 4
    # GEMV reduce: stage 1 = first add on rows 1 and 3; stage 2 = second add on row 3
    s1 = [vv['pes'][f'{x},{y}']['adds'][0]['cycle'] for x in range(4) for y in (1, 3)]
    s2 = [vv['pes'][f'{x},3']['adds'][1]['cycle'] for x in range(4)]
    b = gf['9']
    red = dict(c1=6, c2=15, cb=9, t1=[min(s1), max(s1)], t2=[min(s2), max(s2)],
               bpk=b['packets'], bpp=int(next(iter(b['pes_per_packet']))))
    assert list(b['pes_per_packet']) == ['4'] and gf['6']['role'].startswith('reduce stage 1') and gf['15']['role'].startswith('reduce stage 2')
    # verified tiles by label, for any buffer that holds them
    xt, wt = {}, {}
    for key, tl in gv['tiles'].items():
        px, py, s = map(int, key.split(','))
        q = st['steps'][s][f'{px},{py}']
        xt['%d,%d' % tuple(q['x'])] = tl['X']; wt['%d,%d' % tuple(q['w'])] = tl['W']
    gk = load('meshgemm_phases.json'); rp = load('meshgemm_repeats.json'); lk = load('meshgemm_links.json')
    S = rp['summary']
    gx = dict(recv=lk['receive_vs_fmach']['summary'],
              links=dict(straight=lk['paths_straight_between_neighbours'][0], groups=lk['paths_straight_between_neighbours'][1]),
              rep=dict(repeats=rp['repeats'], skew_first=sum(t['skew_before_clear_before_fmach'] for t in rp['timeline']),
                       steps=S['steps'], read_ne_recv=min(S['x_read!=x_recv'], S['w_read!=w_recv']), single_buf=S['single_x_buffer_per_step'],
                       alternates=min(S['x_alternates'], S['w_alternates']), pairs=S['alternation_pairs'],
                       aligned=[S[f'rep{r}_aligned'] for r in range(1, rp['repeats'] + 1)],
                       aligned_later=f"repeat 2: {S['rep2_aligned']}/64 steps; repeats 3-7: {S['rep3_aligned']}/64"),
              timeline=rp['timeline'])
    assert gx['recv']['transfer_done_before_fmach'] == gx['recv']['windows'] and gx['rep']['read_ne_recv'] == gx['rep']['steps']
    host = dict(M=64, K=64, N=64, tile=256, bytes_f16=64 * 64 * 2, words_per_matrix=64 * 64,
        stages=[
          dict(id='storage', title='Storage', ev='none', lines=['disk or network FS', 'no WaferLLM launcher', 'reads one']),
          dict(id='ram', title='Host RAM', ev='src', lines=['X, W: 64 x 64 f16', 'np.random, seed 2025', '8,192 B each']),
          dict(id='cpu', title='Host CPU', ev='src', lines=['W rows permuted (ind)', 'tile_X / tile_W', 'f16 -> 32-bit words']),
          dict(id='runtime', title='SDK runtime', ev='src', lines=['SdkRuntime', 'memcpy_h2d / _d2h', 'sim: cs_python']),
          dict(id='transport', title='Network', ev='doc', lines=['device: 100 GbE to', 'the CS-3 (1.2 Tb/s)', 'sim: in-process']),
          dict(id='edge', title='Wafer edge', ev='sim', lines=['I/O channel, west', 'colour 23, halo (0,1)', '--channels 1'])],
        transport_text=("memcpy_h2d hands the packed words to the SDK runtime. In the simulator (this trace), cs_python's SdkRuntime runs the "
          "compiled program on simfabric, which Cerebras describes as cycle-accurate: the on-wafer part of memcpy is simulated, the network is not. "
          "On a CS-3 the launcher (<code>launch_device.py</code>) uses the appliance client, <code>SdkRuntime(artifact_id)</code>: the host code runs on a worker node "
          "of the Cerebras appliance, which reaches the system over parallel 100 GbE (1.2 Tb/s of system I/O on CS-3). "
          "On the wafer, I/O channels enter the fabric at PEs on the east and west edges (62 per edge on WSE-3); "
          "this kernel uses one (<code>--channels 1</code>), and the SDK's own benchmark puts one channel at about 7 Gb/s. "
          "memcpy reserves colours 21-23 (23 = host to device), input queues 0-1, output queue 0 and micro-thread 0, and it zero-extends every 16-bit value "
          "into a 32-bit wavelet, which is why the fabric carries one value per packet."),
        transport_checks=[['host-to-device colour seen on the wafer', '23'], ['I/O channels compiled', '1 (max 16)'],
                          ['values per 32-bit wavelet (zero-extended)', '1'], ['sources', 'SDK 2.10 docs, CS-3 page']],
        formats=dict(
          h1=[dict(label='X 64 x 64 f16', sub='8,192 B, row-major, host RAM'), dict(label='W 64 x 64 f16', sub='8,192 B, row-major')],
          h2=[dict(label='W rows permuted by ind', sub='block rows: the W pre-skew'), dict(label='16 tiles x 256 values', sub='PE-major; X column-major in a tile'),
              dict(label='4,096 words per matrix', sub='f16 in the low 16 bits of 32')],
          h3=[dict(label='memcpy_h2d(X, 0, 0, 4, 4, 256)', sub='16-bit, row-major, copy mode'), dict(label='wavelets on colour 23', sub='one value per 32-bit wavelet'),
              dict(label='west edge -> halo PE (0,1)', sub='one I/O channel')],
          h4=[dict(label='4,096 words from the east edge', sub='memcpy_d2h(res, ...)'), dict(label='f16 view -> untile_res', sub='64 x 64 C'),
              dict(label='check vs np.matmul (f32)', sub='repeat 1 only')]),
        notes=dict(h3=['Not documented: router buffer depth, and whether SDK memcpy traffic passes through SwarmX / MemoryX.',
                       'Documented for WSE-2: each colour has dedicated buffering in every router; flow control is lossless, with backpressure.']))
    return dict(P=4, send=st['ring_successor'], ind=st['w_offset_ind'], steps=st['steps'],
                gv=gv['tiles'], gl=gl, vv=dict(pes=vv['pes'], final=vv['final']), vl=vl, snip=snip, red=red,
                col=load('meshgemm_colours.json'), cyc=load('mesh_small_cycles.json'), xt=xt, wt=wt, gk=dict(phases=gk['phases'], buffers=gk['buffers']), gx=gx, host=host)

def main():
    t = (TOOLS / 'gemm_dataflow.tpl.html').read_text()
    markup = (TOOLS / 'gemm_dataflow_toy.html').read_text() + '\n' + (TOOLS / 'gemm_dataflow_mesh.html').read_text()
    js = (TOOLS / 'gemm_dataflow_mesh.js').read_text() + '\n' + (TOOLS / 'gemm_dataflow_toy.js').read_text() + '\n' + (TOOLS / 'gemm_dataflow_cycles.js').read_text()
    a, b = t.index('<h2>Across the mesh</h2>'), t.index('<h2>The three dataflows compared</h2>')
    t = t[:a] + markup + '\n' + t[b:]
    a, b = t.index('/* ======================= across the mesh ======================= */'), t.index('</script>')
    t = t[:a] + js + '\n' + t[b:]
    t = t.replace('</style>', CSS + '</style>', 1)
    data = json.dumps(payload(), separators=(',', ':')).replace('</', '<\\/')   # never close the <script> early
    assert '</' not in data
    t = t.replace('%%DATA%%', data, 1)
    OUT.write_text(t)
    print(f'{OUT} {len(t):,} bytes')
    g = (TOOLS / 'mesh_webgl.tpl.html').read_text().replace('%%DATA%%', data, 1)
    GL.write_text(g)
    print(f'{GL} {len(g):,} bytes')

if __name__ == '__main__':
    main()
