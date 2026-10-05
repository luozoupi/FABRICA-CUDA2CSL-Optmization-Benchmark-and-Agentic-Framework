#!/usr/bin/env python3
"""Stage the retained 4x4 / four-PE GEMM ELF for independent stopped-phase runs."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import struct

ROOT=Path(__file__).resolve().parents[2]
def main():
    ap=argparse.ArgumentParser();ap.add_argument('--out',type=Path,required=True);a=ap.parse_args()
    root=a.out.resolve();root.mkdir(parents=True,exist_ok=True)
    scene=next(s for s in json.loads((ROOT/'viewer/public/bundle.json').read_text())['scenes'] if s['id']=='g1')
    src=ROOT/scene['provenance']['run']
    for file,digest in scene['provenance']['sha256'].items():
        if file.endswith('.elf') and file.startswith('out/'):
            assert hashlib.sha256((src/file).read_bytes()).hexdigest()==digest
    shutil.copytree(src/'out',root/'out')
    shutil.copy2(Path(__file__).with_name('stopped_phases.py'),root/'stopped_phases.py')
    A=scene['a'];B=scene['b'];C=[[sum(A[i][k]*B[k][j] for k in range(4)) for j in range(4)] for i in range(4)]
    bits=lambda a:[struct.unpack('<I',struct.pack('<f',v))[0] for v in a]
    uploads=[];expected={}
    for y in range(2):
        for x in range(2):
            for name,m in [('A',A),('B',B),('C',C)]:
                values=bits([m[y*2+i][x*2+j] for j in range(2) for i in range(2)])
                expected[f'{name}@{x},{y}']=values
                if name!='C':uploads.append(dict(symbol=name,pe=[x,y],bits=values))
    report=dict(case={'kind':'gemm','n':4,'pes':4},uploads=uploads,expected=expected,
                source_run=str(src.relative_to(ROOT)),source_elf_sha256={p:h for p,h in scene['provenance']['sha256'].items() if p.endswith('.elf') and p.startswith('out/')},
                note='Reuses the instrumented/optnone g1 ELF; snapshot runs have their own simulator timelines.')
    (root/'report.json').write_text(json.dumps(report,indent=2)+'\n');print(root)

if __name__=='__main__':main()
