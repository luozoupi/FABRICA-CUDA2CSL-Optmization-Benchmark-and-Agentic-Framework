#!/usr/bin/env python3
"""Render an original, standalone teaching figure from the architecture audit."""
from html import escape
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'results/architecture-review'


def main():
    model = json.loads((OUT / 'estimates.json').read_text())
    ins = model['gemm_timeline']['instructions']
    height = 930 + len(ins)*42
    svg = [f'''<svg xmlns="http://www.w3.org/2000/svg" width="1680" height="{height}" viewBox="0 0 1680 {height}" role="img" aria-labelledby="title desc">
    <title id="title">WSE-3: a functional PE datapath and an observed instruction timeline</title>
    <desc id="desc">Documented components, inferred functional connections, and exact simulator S3 and S6 observations. Physical intermediate pipeline stages and cache policy remain unknown.</desc>
    <defs><marker id="arrow" markerWidth="9" markerHeight="9" refX="8" refY="3" orient="auto"><path d="M0 0 L8 3 L0 6" fill="none" stroke="#596b7c"/></marker></defs>
    <style>text{{font-family:Arial,sans-serif;fill:#203649}} .title{{font-size:34px;font-weight:bold}} .head{{font-size:22px;font-weight:bold}} .body{{font-size:18px}} .small{{font-size:16px;fill:#536879}} .mono{{font-family:monospace;font-size:17px}} .wire{{fill:none;stroke:#596b7c;stroke-width:2;marker-end:url(#arrow)}} .control{{stroke-dasharray:6 5}} .box{{fill:white;stroke:#94a9b7;stroke-width:1.5}} .d{{fill:#dcedfa;stroke:#4a8bad}} .x{{fill:#d7eee6;stroke:#23856d}}</style>
    <rect width="1680" height="{height}" fill="#f5f5ef"/>
    <text x="45" y="58" class="title">WSE-3 · Follow operands, then account for time</text>
    <text x="45" y="92" class="body">Functional connections are a model. Boxes do not imply separate physical units, ports, muxes, or pipeline registers.</text>''']

    def text(x,y,s,cls='body'):
        svg.append(f'<text x="{x}" y="{y}" class="{cls}">{escape(str(s))}</text>')

    def box(x,y,w,h,title,lines):
        svg.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="8" class="box"/>')
        text(x+15,y+30,title,'head')
        for j,line in enumerate(lines):text(x+15,y+59+23*j,line,'small')

    def wire(d,control=False):
        svg.append(f'<path d="{d}" class="wire'+(' control' if control else '')+'"/>')

    box(45,145,260,110,'Task / PC selection',['Activated + unblocked task','Instruction decode: trace S3'])
    box(350,145,280,110,'DSRs / addresses',['48 DSRs; dest / src0 / src1','Base, extent, stride; XDSR/SR'])
    box(680,130,445,145,'Local memory',['48 KB SRAM: code, arrays, stack','X/W and A/B have SRAM allocations','512-byte cache: role here unverified'])
    box(1320,145,310,110,'Input queues',['8 queue IDs, separate from colors','Incoming wavelet buffering'])
    box(45,350,260,100,'Scalar registers',['16 GPRs; f32 register pairs','Loads / arithmetic / stores'])
    box(350,350,280,100,'Operand selection',['Registers / immediates','Memory / fabric streams'])
    box(705,340,350,130,'Arithmetic / moves',['Scalar and vector instruction forms','8-way 16-bit / 16-way 8-bit SIMD','Execution values: trace S6'])
    box(1110,350,205,100,'Destination',['SRAM / register','or output queue'])
    box(1360,350,270,110,'Router / RAMP',['24 colors; routed wavelets','N/E/S/W links to neighbors'])
    wire('M305 190 H350',True)
    wire('M490 255 V350',True)
    wire('M305 402 H350')
    wire('M630 402 H705')
    wire('M1055 402 H1110')
    wire('M1315 402 H1360')
    wire('M1475 350 V255')
    wire('M1320 230 H1210 V320 H580 V350')
    wire('M730 275 V295 H175 V350')
    wire('M1215 350 V285 H1030 V275')
    wire('M880 470 V515 H175 V450')
    text(65,296,'Local load','small')
    text(650,317,'Fabric operand / received data','small')
    text(1140,278,'Store','small')
    text(505,505,'Scalar result dependency','small')
    text(45,550,'Documented capacities: Cerebras Hot Chips 2024, PDF p.29; SDK DSR, task, and queue references.','small')
    text(45,574,'Observed bindings: executed ELF/IR, instruction operands and exact packet identities. Cache access and SRAM commit time are not recorded.','small')

    text(45,623,'One GEMV value across two PEs: 11 joins local 30 to produce 41','head')
    term=model['gemv_path']['term']
    stages=[('Send S6',term['send']['cycle']),
            ('Source router',term['packet']['observations'][0]['cycle']),
            ('Destination router',term['packet']['observations'][1]['cycle']),
            ('Receive S6',term['receive']['cycle']),
            ('Add: '+term['consumer']['equation'],term['consumer']['cycle'])]
    for j,(label,cycle) in enumerate(stages):
        x=45+j*330
        svg.append(f'<rect x="{x}" y="645" width="280" height="72" rx="6" class="x"/>')
        text(x+12,671,label,'body');text(x+12,700,f'cycle {cycle:,}','mono')
        if j<4:wire(f'M{x+280} 682 H{x+323}')
    text(45,745,'V1 PE (0,0) → (0,1), packet 14310831030273, word 0x41300000. Spacing above is schematic; times are recorded.','small')

    text(45,791,'A MIPS-style timeline, using only the timing anchors we have','head')
    text(45,819,'G0 history: scalar spill / reload / Add window. D = S3 decode; X = operand-bearing S6. Connecting lines have no assigned stage function.','small')
    lo=min(i['s3'] for i in ins);hi=max(i['v_last'] or i['s3'] for i in ins)
    dx=min(65,970/max(1,hi-lo+1));base=650
    for c in range(lo,hi+1):text(base+(c-lo)*dx+2,857,c,'small')
    for row,i in enumerate(ins):
        y=872+row*42
        text(45,y+22,f"UID {i['uid']}: {i['text']}",'mono')
        x0=base+(i['s3']-lo)*dx
        x1=base+((i['v_last'] or i['s3'])-lo)*dx
        svg.append(f'<path d="M{x0+16} {y+15} H{x1+16}" stroke="#bbc6ca" stroke-width="2" stroke-dasharray="3 3"/>')
        points=[(i['s3'],'D','d')]+[(c,'X','x') for c in sorted({v['cycle'] for v in i['execute'] if v['has_payload']})]
        for cycle,label,cls in points:
            x=base+(cycle-lo)*dx
            svg.append(f'<rect x="{x}" y="{y}" width="32" height="30" rx="4" class="{cls}"/>')
            text(x+9,y+21,label,'body')
    text(45,height-26,f"{model['raw_anchors_rechecked']} S3/S6 anchors + {model['gemv_path']['raw_records_rechecked']} GEMV path records rechecked. Simulator timing; fetch, forwarding and writeback timing remain unspecified.",'small')
    svg.append('</svg>')
    (OUT/'datapath.svg').write_text('\n'.join(svg)+'\n')
    print(OUT/'datapath.svg')


if __name__=='__main__':
    main()
