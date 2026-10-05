"""Audit sparse replay traces inside timer windows; count events, not inferred stalls."""
import argparse
from collections import Counter
import hashlib
import json
import math
from pathlib import Path
import re
import statistics
import struct
import sys


def require(condition, message):
    if not condition: raise ValueError(message)


def sha(path):
    h=hashlib.sha256()
    with path.open('rb') as f:
        for block in iter(lambda:f.read(1024*1024),b''): h.update(block)
    return h.hexdigest()


def f32(word): return struct.unpack('<f',struct.pack('<I',word))[0]
def round32(value): return struct.unpack('<f',struct.pack('<f',value))[0]


def elf_text(path):
    b=path.read_bytes(); require(b[:6]==b'\x7fELF\x02\x01','Unsupported ELF')
    h=struct.unpack_from('<HHIQQQIHHHHHH',b,16)
    ss=[struct.unpack_from('<IIQQQQIIQQ',b,h[5]+i*h[10]) for i in range(h[11])]
    s=ss[h[12]]; names=b[s[4]:s[4]+s[5]]
    for s in ss:
        if names[s[0]:].split(b'\0')[0]==b'.text': return s[3],b[s[4]:s[4]+s[5]]
    raise ValueError('No .text section')


def stats(values):
    return dict(min=min(values),median=statistics.median(values),max=max(values)) if values else None


def analyze(d,reader_type):
    cfg=json.loads((d/'case.json').read_text())
    binding=json.loads((d/'elf-binding.json').read_text()); old=Path(binding['original'])
    require(sha(old/'observations.json')==binding['original_observations_sha256'],'Original observations changed')
    for rel,h in binding['elf_sha256'].items():
        require(sha(d/'out'/rel)==h==sha(old/'out'/rel),'ELF mismatch: '+rel)
    for rel,h in cfg['source_hashes'].items(): require(sha(d/rel)==h,'Source changed: '+rel)
    require(sha(d/'disassembly.json')==sha(old/'disassembly.json'),'Disassembly changed')
    rows=[r for a in json.loads((d/'disassembly.json').read_text()).values() for r in a]
    source_map={r['pc']:r for r in rows}; require(len(source_map)==len(rows),'Ambiguous PC map')
    timer_pcs=sorted(r['pc'] for r in rows if re.match(r'ld16 .*\[0x7b30\]',r['instruction']))
    require(len(timer_pcs)==2,'This pilot expects exactly two static timer anchors')
    text_sections=[elf_text(p) for p in (d/'out/bin').glob('*.elf')]
    require(len(text_sections)==1,'This pilot supports a single application ELF')
    geometry=json.loads((d/'simfab_traces/global_simdata.json').read_text())
    require((geometry['xsize'],geometry['ysize'])==(8,3),'Unexpected fabric shape')
    reader=reader_type(d/'simfab_traces'); dispatch={}; arithmetic={}; anchors=[]
    for event in reader.iter_events():
        if event.get('tile_index')!=12: continue
        uid=event.get('uid')
        if event['event_type']=='hwm_dispatch_trace_entry':
            require(uid not in dispatch,'Repeated instruction UID')
            dispatch[uid]={k:event[k] for k in ('uid','cycle','inst_ptr','inst_bin','name')}
            if event['inst_ptr'] in timer_pcs: anchors.append(dispatch[uid])
        elif event['event_type']=='hwm_pipe_trace_entry' and event['stage']==6 and event['dest']!=0xffffffff:
            inst=dispatch.get(uid)
            if not inst or inst['name'].split()[0].upper() not in ('FMACS','FMULS','FADDS'): continue
            # Restrict arithmetic checks to the compiled kernel, excluding memcpy library code.
            if not timer_pcs[0] < inst['inst_ptr'] < timer_pcs[1]: continue
            opcode=inst['name'].split()[0].upper()
            vals={k:f32(event[k]) for k in ('dest','src0','src1','src2') if event[k]!=0xffffffff}
            require(all(math.isfinite(v) for v in vals.values()),'Nonfinite arithmetic event')
            if opcode=='FMACS': expected=round32(vals['src0']+vals['src1']*vals['src2'])
            elif opcode=='FMULS': expected=round32(vals['src0']*vals['src1'])
            else: expected=round32(vals['src0']+vals['src1'])
            require(vals['dest']==expected,'Arithmetic operand/result mismatch')
            inst_result=arithmetic.setdefault(uid,dict(cycles=[],lanes=Counter(),operand_examples=[]))
            inst_result['cycles'].append(event['cycle']); inst_result['lanes'][str(event['simdi'])]+=1
            if len(inst_result['operand_examples'])<4:
                inst_result['operand_examples'].append(dict(cycle=event['cycle'],lane=event['simdi'],values=vals))
    require(not reader.warnings and reader.discarded_events_total==0,'Incomplete CTF trace')
    anchors.sort(key=lambda e:e['cycle'])
    obs=json.loads((d/'observations.json').read_text())
    records=obs['records']; samples=[(r,s) for r in records for s in r['samples']]
    require(len(samples)==24 and len(anchors)==48,'Unexpected number of launches/timer anchors')
    windows=[]; seen_arithmetic=set()
    for i,(record,sample) in enumerate(samples):
        a,b=anchors[2*i:2*i+2]
        require([a['inst_ptr'],b['inst_ptr']]==timer_pcs,'Unexpected timer control flow')
        require(b['cycle']-a['cycle']==sample['cycles']==sample['end']-sample['start'],'Timer mismatch')
        require(sample['correct'] and sample['matches_original_timing_and_output'],'Replay failed recorded checks')
        entry=next(x for x in cfg['inputs'] if x['id']==record['input_id'])
        for name,h in entry['input_hashes'].items():require(sha(d/'inputs'/entry['id']/name)==h,'Input hash mismatch')
        nnz=(d/'inputs'/entry['id']/'col_idx.bin').stat().st_size//4
        active={uid:e for uid,e in dispatch.items() if a['cycle']<=e['cycle']<b['cycle']}
        opcodes=Counter(); pc_counts=Counter(); fp_dispatch=Counter(); fp_elements=Counter()
        result_cycles=set(); spans=[]; delay=[]; lanes=Counter(); config_stores=Counter(); pc_sequence=[]
        for uid,e in active.items():
            pc=e['inst_ptr']; require(pc in source_map,'Unknown PC')
            addr=2*pc
            require(any(base<=addr<=base+len(data)-4 and struct.unpack_from('<I',data,addr-base)[0]==e['inst_bin'] for base,data in text_sections),'Instruction encoding mismatch')
            op=e['name'].split()[0].upper(); opcodes[op]+=1; pc_counts[pc]+=1; pc_sequence.append(pc)
            # Preserve actual addresses. Interpretation as DSD setup is checked against assembly/source.
            match=re.match(r'st16 \[(0x7e[0-9a-f]{2})\]',source_map[pc]['instruction'])
            if match: config_stores[match[1]]+=1
            if uid in arithmetic:
                seen_arithmetic.add(uid); f=arithmetic[uid]
                require(all(a['cycle']<=c<b['cycle'] for c in f['cycles']),'Arithmetic crosses timer window')
                fp_dispatch[op]+=1; fp_elements[op]+=len(f['cycles']); result_cycles.update(f['cycles']); lanes.update(f['lanes'])
                if op=='FMACS':
                    spans.append(max(f['cycles'])-min(f['cycles'])+1); delay.append(min(f['cycles'])-e['cycle'])
        require(fp_elements['FMACS']+fp_elements['FMULS']==nnz*cfg['N'],'Wrong multiplication count')
        require(fp_elements['FMULS']==fp_elements['FADDS'],'Unpaired scalar multiply/add')
        examples=[]
        for uid,e in active.items():
            if uid in arithmetic and len(examples)<3:
                examples.append(dict(uid=uid,pc=e['inst_ptr'],dispatch_cycle=e['cycle'],assembly=source_map[e['inst_ptr']]['instruction'],source=source_map[e['inst_ptr']].get('source'),result_elements=len(arithmetic[uid]['cycles']),first_operand_events=arithmetic[uid]['operand_examples']))
        encoded=struct.pack('<'+'I'*len(pc_sequence),*pc_sequence)
        windows.append(dict(input_id=record['input_id'],family=record['family'],session=record['session'],changed=record['changed'],
            repetition=sample['rep'],warmup=sample['warmup'],nnz=nnz,output_width=cfg['N'],cycles=sample['cycles'],
            trace_start=a['cycle'],trace_end=b['cycle'],tsc_start=sample['start'],tsc_end=sample['end'],
            dispatches=len(active),opcode_dispatches=dict(sorted(opcodes.items())),pc_counts=dict(sorted(pc_counts.items())),
            executed_pc_sequence_sha256=hashlib.sha256(encoded).hexdigest(),arithmetic_examples=examples,
            floating_dispatches=dict(fp_dispatch),floating_result_elements=dict(fp_elements),floating_result_event_cycles=len(result_cycles),
            arithmetic_lanes=dict(lanes),fmac_result_span=stats(spans),fmac_dispatch_to_first_result=stats(delay),
            stores_to_0x7e_registers=dict(sorted(config_stores.items())),
            conventional_flops=2*nnz*cfg['N'],conventional_flops_per_cycle=2*nnz*cfg['N']/sample['cycles'],
            cycles_per_dispatch=sample['cycles']/len(active)))
    require(seen_arithmetic==set(arithmetic),'Kernel arithmetic outside all timed windows')
    files=['case.json','pe.csl','layout.csl','host.py','trace_host.py','elf-binding.json','disassembly.json','observations.json','baseline.json','replay-result.json']
    hashes={name:sha(d/name) for name in files}
    hashes.update({str(p.relative_to(d)):sha(p) for p in (d/'simfab_traces').iterdir() if p.is_file()})
    return dict(id=d.name,passed=True,case=cfg,windows=windows,hashes=hashes,elf_sha256=binding['elf_sha256'],
                timer_pcs=timer_pcs,discarded_events=reader.discarded_events_total,
                scope='One application PE at (4,1); timestamp-read dispatch anchors; output zeroing included; host copies excluded. '
                      'FP32 exact-integer operands/results verified; counts and result-event cycles do not assign hardware stalls or utilization.')


def main():
    ap=argparse.ArgumentParser(description=__doc__); ap.add_argument('--root',type=Path,required=True)
    ap.add_argument('--trace-library',type=Path,required=True); ap.add_argument('--case'); args=ap.parse_args()
    sys.path.insert(0,str(args.trace_library)); from wse3study.trace import CtfTraceReader
    results=[]
    for d in sorted((args.root/'cases').iterdir()):
        if args.case and d.name!=args.case:continue
        if not (d/'replay-result.json').exists():continue
        if json.loads((d/'replay-result.json').read_text())['status']!='pass':continue
        result=analyze(d,CtfTraceReader); results.append(result)
        (d/'trace-analysis.json').write_text(json.dumps(result,indent=2)+'\n')
        print(d.name,'PASS',len(result['windows']),'windows',[(w['family'],w['cycles'],w['dispatches']) for w in result['windows'] if w['session']==0 and w['repetition']==1],flush=True)
    payload=dict(analyzer_sha256=sha(Path(__file__)),parser_sha256=sha(args.trace_library/'wse3study/trace.py'),results=results)
    destination=args.root/(('trace-analysis-'+args.case+'.json') if args.case else 'trace-analysis.json')
    destination.write_text(json.dumps(payload,indent=2)+'\n')

if __name__=='__main__':main()
