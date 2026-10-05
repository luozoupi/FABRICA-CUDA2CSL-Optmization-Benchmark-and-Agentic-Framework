#!/usr/bin/env python3
"""Check the SRAM backing of the six teaching scenes against their retained ELFs."""
import hashlib
import json
from pathlib import Path
import re
import sys

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT))
from wse3study.inventory import _Elf64


def check(condition,message):
    if not condition:
        raise ValueError(message)


def audit():
    scenes=[]
    for bundle_name in ('gemv-bundle.json','bundle.json'):
        for scene in json.loads((ROOT/'viewer/public'/bundle_name).read_text())['scenes']:
            work=ROOT/scene['provenance']['run']
            placement=json.loads((work/'placement.json').read_text())
            manifest=json.loads((work/'manifest.json').read_text())
            gemv=scene['id'].startswith('v');t=scene['t']
            sizes={'X':4*t,'W':4*t*t} if gemv else {'A':4*t*t,'B':4*t*t}
            if not gemv and scene['p']>1:sizes.update(abuf=4*t*t,bbuf=4*t*t)
            pes=[]
            for pe,p in placement.items():
                names=[p['elf'],'pe.csl','run.py',p['ir']+'/program.ll']
                patched=list((work/p['ir']).glob('cslc_ir_*/program.ll'))
                check(len(patched)==1,'Ambiguous executed IR')
                names.append(str(patched[0].relative_to(work)))
                hashes={}
                for name in names:
                    digest=hashlib.sha256((work/name).read_bytes()).hexdigest()
                    check(manifest['sha256'].get(name)==digest,f'Capture binding mismatch: {work/name}')
                    hashes[name]=digest
                elf=_Elf64(work/p['elf']);objects={s['name']:s for s in elf.object_symbols(limit=10000)}
                check(elf.program_tile_ids()==[p['tile']],'ELF PE placement mismatch')
                ir=patched[0].read_text();arrays=[]
                for name,size in sizes.items():
                    obj=objects[name];section=elf.sections[obj['section_index']]
                    check(obj['bytes']==size,f'{pe} {name}: unexpected allocation size')
                    check(section.name=='.bss' and section.flags&3==3,'Expected allocated writable .bss')
                    check(section.address<=obj['address'] and obj['address']+size<=section.address+section.size,'Symbol outside section')
                    check(0<=obj['address'] and obj['address']+size<=48*1024,'Symbol outside PE local memory range')
                    segments=[h for h in elf.program_headers if h.segment_type==1 and h.flags&2
                              and h.physical_address>>40==p['tile']
                              and h.virtual_address<=obj['address']
                              and obj['address']+size<=h.virtual_address+h.memory_size]
                    check(bool(segments),'No matching writable PE load segment')
                    definition=re.search(r'^@'+name+r' = internal global \['+str(size//4)+r' x float\].*$',ir,re.M)
                    check(definition is not None,f'IR allocation missing: {name}')
                    arrays.append(dict(name=name,elf_address=obj['address'],elf_address_hex=hex(obj['address']),
                        bytes=size,elements=size//4,section=section.name,section_flags=section.flags,
                        ir_definition=definition[0],storage='PE-local SRAM',
                        role='received panel buffer' if name in ('abuf','bbuf') else 'host-loaded input array'))
                for i,a in enumerate(arrays):
                    for b in arrays[i+1:]:
                        check(a['elf_address']+a['bytes']<=b['elf_address'] or b['elf_address']+b['bytes']<=a['elf_address'], 'Overlapping input allocations')
                pes.append(dict(pe=pe,fabric=p['fabric'],elf=p['elf'],executed_ir=str(patched[0].relative_to(work)),arrays=arrays,hashes=hashes))
            scenes.append(dict(scene=scene['id'],run=str(work.relative_to(ROOT)),pes=pes,
                value_evidence='Exact final X/W readbacks and multiply operands' if gemv else 'Host input bits, captured panel histories and multiply operands; no separate final A/B readback'))
    report=dict(schema='input-storage/1',scenes=scenes,
        arrays=sum(len(p['arrays']) for s in scenes for p in s['pes']),
        scope='Compiled PE-local SRAM allocations for retained simulator builds, not physical bank measurements or cycle-by-cycle SRAM contents. Scalar arithmetic uses transient operand copies; fabric buffering is distinct from these allocated arrays.',
        architecture_sources=['https://sdk.cerebras.ai/computing-with-cerebras','https://sdk.cerebras.ai/csl/language/appendix'])
    out=ROOT/'results/input-storage.json';out.write_text(json.dumps(report,indent=2)+'\n')
    print(f'{len(scenes)} scenes, {sum(len(s["pes"]) for s in scenes)} PEs, {report["arrays"]} verified SRAM-backed arrays: {out}')
    return report


if __name__=='__main__':audit()
