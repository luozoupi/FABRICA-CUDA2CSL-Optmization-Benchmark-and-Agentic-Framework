#!/usr/bin/env python3
"""Bind retained f32 messages to wavelet observations and consuming arithmetic.

This exporter never treats wavelet.data alone as a 32-bit payload. SDK 2.10's
format_wavelet_bits('f32') combines index (high 16) with data (low 16). Identity,
route endpoints, complete ordered message words, and instruction chronology
must all agree. Unmatched/ambiguous observations remain in the exported data.
"""
from __future__ import annotations
import gzip
import hashlib
import json
import re
import struct
from collections import Counter, defaultdict
from pathlib import Path
from anatomy_common import wavelet_fields

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT/'results/pe-hops'


def bits(value):
    return struct.unpack('<I', struct.pack('<f', value))[0]


def word32(index, data):
    if not all(isinstance(x, int) and 0 <= x <= 65535 for x in (index, data)):
        raise ValueError('Wavelet word requires both unsigned 16-bit halves')
    return index << 16 | data


def f32(word):
    return struct.unpack('<f', struct.pack('<I', word))[0]


def read_capture(base, placement, colors, trace_name='events.jsonl.gz'):
    """Retain all scoped wavelets, and move/arithmetic records on application PEs."""
    tiles = {p['tile']: pe for pe,p in placement.items()}
    asm = {}
    for pe,p in placement.items():
        doc=json.loads((base/p['disasm']).read_text())
        rows=doc['records'] if isinstance(doc,dict) else doc
        asm[pe]={r['pc']:r for r in rows}
    waves, instructions = [], {}
    discarded=0
    with gzip.open(base/trace_name, 'rt') as fh:
        for row,line in enumerate(fh,1):
            e=json.loads(line)
            discarded=max(discarded,e.get('packet_context',{}).get('events_discarded',0))
            pe=tiles.get(e.get('tile_index'))
            if pe is None: continue
            if e['event_type']=='wavelet_trace_entry' and e['fields']&31 in colors:
                wf=wavelet_fields(e['fields'])
                waves.append(dict(row=row,pe=pe,xy=placement[pe]['fabric'],cycle=e['cycle'],ident=str(e['ident']),
                    index=e['index'],data=e['data'],word=word32(e['index'],e['data']),fields=e['fields'],
                    color=wf['colour'],control=wf['ctrl'],link=wf['link'],ramp=wf['link']=='R'))
            elif e['event_type']=='hwm_dispatch_trace_entry':
                if e['name'] not in ('IMOV32.NF','FMOV32.NF','FMULS','FADDS'):continue
                key=(pe,e['uid'])
                ins=instructions.setdefault(key,dict(pe=pe,uid=e['uid'],pc=e['inst_ptr'],name=e['name'],
                    count=e['num_data'],ut=e['ut_id'],dispatch=[],decode=[],execute=[]))
                if ins['pc']!=e['inst_ptr']:raise ValueError('UID reused for a different instruction')
                ins['dispatch'].append(dict(cycle=e['cycle'],row=row))
                r=asm[pe].get(e['inst_ptr'],{})
                ins.update(assembly=r.get('instruction',e['name']),source_file=r.get('source_file'),source_line=r.get('source'))
            elif e['event_type']=='hwm_pipe_trace_entry':
                ins=instructions.get((pe,e['uid']))
                if ins is None:continue
                if e['stage']==3:ins['decode'].append(dict(cycle=e['cycle'],row=row))
                if e['stage']==6 and e.get('simdi',255)!=255:
                    ins['execute'].append(dict(cycle=e['cycle'],row=row,index=e['data'],lane=e['simdi'],
                        **{k:e.get(k) for k in ('dest','src0','src1','src2')}))
    assert discarded==0, 'Discarded records prevent a complete message binding'
    return waves,list(instructions.values())


def packets_for(waves):
    groups=defaultdict(list)
    for w in waves:groups[w['ident']].append(w)
    packets,unresolved=[],[]
    for ident,obs in groups.items():
        obs.sort(key=lambda w:(w['cycle'],w['row']))
        # Deliberately bounded to the adjacent-PE cases in this review.
        if len(obs)!=2 or not obs[0]['ramp'] or obs[1]['ramp']:
            unresolved.extend(w['row'] for w in obs);continue
        a,b=obs
        if (sum(abs(x-y) for x,y in zip(a['xy'],b['xy']))!=1 or
            any(a[k]!=b[k] for k in ('word','color','control')) or b['cycle']<a['cycle']):
            unresolved.extend(w['row'] for w in obs);continue
        packets.append(dict(ident=ident,source=a['pe'],destination=b['pe'],color=a['color'],control=a['control'],
            word=a['word'],observations=obs,interval=b['cycle']-a['cycle']))
    return packets,unresolved


def messages_for(packets):
    flows=defaultdict(list)
    for p in packets:flows[(p['source'],p['destination'],p['color'])].append(p)
    messages=[]
    for flow,ps in flows.items():
        ps.sort(key=lambda p:p['observations'][0]['cycle'])
        pending=[]
        for p in ps:
            if p['control']:
                if pending:messages.append(dict(source=flow[0],destination=flow[1],color=flow[2],packets=pending,control=p))
                pending=[]
            else:pending.append(p)
        # The relay has a fixed extent and no end-of-message control wavelet.
        if pending:messages.append(dict(source=flow[0],destination=flow[1],color=flow[2],packets=pending,control=None))
    return messages


def copy_candidates(instructions, message, side, dsr=None):
    """Whole-vector equality and elementwise temporal bounds, not scalar equality."""
    pe=message['source' if side=='send' else 'destination'];ps=message['packets']
    result=[]
    for ins in instructions:
        if ins['pe']!=pe or ins['name']!='IMOV32.NF' or ins['count']!=len(ps) or ins['ut']==255:continue
        if dsr is not None and ins['assembly'] != f'imov32.nf [dds{dsr}] = [s1ds{dsr}]':continue
        vals=sorted(ins['execute'],key=lambda e:e['index'])
        if len(vals)!=len(ps) or [e['index'] for e in vals]!=list(range(len(ps))):continue
        if any(e['dest']!=p['word'] or e['src1']!=p['word'] for e,p in zip(vals,ps)):continue
        if side=='send' and any(e['cycle']>p['observations'][0]['cycle'] for e,p in zip(vals,ps)):continue
        if side=='receive' and any(e['cycle']<p['observations'][1]['cycle'] for e,p in zip(vals,ps)):continue
        result.append(ins)
    return result


def collective_dsr(source, module):
    block=re.search(r'const '+re.escape(module)+r' = @import_module\("<collectives_2d/pe>", \.\{(.*?)\}\);',source,re.S)
    if block is None:raise ValueError(f'Missing collective configuration: {module}')
    ids=[int(re.search(r'\.'+name+r'_dsr_ids = \[1\]u16\{(\d+)\}',block[1])[1]) for name in ('dest','src1')]
    if ids[0]!=ids[1]:raise ValueError('This binder requires matching source/destination DSR IDs')
    return ids[0]


def bind_message(messages, source, destination, values, color):
    expected=[bits(v) for v in values]
    candidates=[m for m in messages if (m['source'],m['destination'],m['color'])==(source,destination,color)
                and [p['word'] for p in m['packets']]==expected]
    if len(candidates)!=1:raise ValueError(f'Message ambiguity/mismatch: {source} → {destination}, {expected}: {len(candidates)} candidates')
    return candidates[0]


def compact_instruction(ins):
    return {k:ins[k] for k in ('pe','uid','pc','name','assembly','source_file','source_line','dispatch','decode','execute')}


def build():
    OUT.mkdir(parents=True,exist_ok=True)
    scenes=[];sources={}
    def identity(path):
        h=hashlib.sha256()
        with path.open('rb') as fh:
            for block in iter(lambda:fh.read(1024*1024),b''):h.update(block)
        sources[str(path.relative_to(ROOT))]=h.hexdigest()
    for family,file in [('gemv','viewer/public/gemv-bundle.json'),('gemm','viewer/public/bundle.json')]:
        identity(ROOT/file)
        for s in json.loads((ROOT/file).read_text())['scenes']:
            if s['p']==1:continue
            base=ROOT/s['provenance']['run']
            program_source=(base/'pe.csl').read_text()
            placement=json.loads((base/'placement.json').read_text())
            for pe,p in placement.items():p['disasm']=f'disasm_{pe.replace(",","_")}.json'
            colors=[4,5] if family=='gemv' else [0,1,4,5]
            waves,ins=read_capture(base,placement,colors)
            packets,unresolved=packets_for(waves);messages=messages_for(packets)
            wanted=[]
            if family=='gemv':
                pes={p['id']:p for p in s['pes']}
                for x in range(s['p']):
                    top,root=f'{x},0',f'{x},1'
                    for kind,src,dst,values in [('partial',top,root,pes[top]['observed']['partial']),('replica',root,top,pes[root]['observed']['result'])]:
                        wanted.append(dict(label=f'{kind} column {x}',source=src,destination=dst,values=values,color=4,kind=kind,x=x))
            else:
                for panel in s['panels']:
                    if panel['transfer']:
                        wanted.append(dict(label=f'{panel["tensor"]} panel · round {panel["round"]}',
                            source=','.join(map(str,panel['source'])),destination=','.join(map(str,panel['destination'])),values=panel['packed'],
                            color=0 if panel['tensor']=='A' else 4,kind=panel['tensor'],round=panel['round']))
            bound=[];used=set()
            for w in wanted:
                m=bind_message(messages,w['source'],w['destination'],w['values'],w['color'])
                dsr=collective_dsr(program_source, ('mpi_x' if w['kind']=='A' else 'mpi_y')) if family=='gemm' else None
                send,receive=copy_candidates(ins,m,'send',dsr),copy_candidates(ins,m,'receive',dsr)
                if len(send)!=1 or len(receive)!=1:raise ValueError(f'{s["id"]} copy binding ambiguity {w["label"]}: send {len(send)}, receive {len(receive)}')
                for instruction in (send[0],receive[0]):instruction['execute'].sort(key=lambda e:e['index'])
                terms=[]
                for slot,(p,value) in enumerate(zip(m['packets'],w['values'])):
                    if p['ident'] in used:raise ValueError('Packet assigned more than once')
                    used.add(p['ident'])
                    event=None;semantic=None
                    if family=='gemv' and w['kind']=='partial':
                        out=s['outputs'][w['x']*s['t']+slot];r=out['reduction']
                        uid=s['dynamic'][r['arithmetic_ids'][0]]['uid']
                        arithmetic=next(i for i in ins if i['pe']==w['destination'] and i['uid']==uid)
                        e=arithmetic['execute'][0]
                        assert (e['src0'],e['src1'],e['dest'])==(bits(r['old']),bits(value),bits(r['acc']))
                        event=dict(cycle=e['cycle'],row=e['row'],uid=uid,pc=arithmetic['pc'],assembly=arithmetic['assembly'],
                                   equation=f'{r["old"]} + {value:g} = {r["acc"]}')
                        semantic=f'Y[{out["j"]}] received partial'
                    elif family=='gemv':semantic=f'Y[{w["x"]*s["t"]+slot}] replica'
                    else:
                        t=s['t'];dx,dy=map(int,w['destination'].split(','));r=w['round']
                        if w['kind']=='A':i,k=dy*t+slot%t,r*t+slot//t;semantic=f'A[{i},{k}]';matches=[q for c in s['cells'] if c['pe']==w['destination'] and c['i']==i for q in c['terms'] if q['k']==k]
                        else:k,j=r*t+slot%t,dx*t+slot//t;semantic=f'B[{k},{j}]';matches=[q for c in s['cells'] if c['pe']==w['destination'] and c['j']==j for q in c['terms'] if q['k']==k]
                        q=min(matches,key=lambda q:q['observed']['multiply_cycle'])
                        uid=s['dynamic'][q['arithmetic_ids'][0]]['uid'];arithmetic=next(i for i in ins if i['pe']==w['destination'] and i['uid']==uid);e=arithmetic['execute'][0]
                        assert e['src0' if w['kind']=='A' else 'src1']==p['word']
                        assert e['cycle']>=receive[0]['execute'][slot]['cycle']
                        event=dict(cycle=e['cycle'],row=e['row'],uid=uid,pc=arithmetic['pc'],assembly=arithmetic['assembly'],equation=f'{q["a"]} × {q["b"]} = {q["product"]}')
                    terms.append(dict(slot=slot,value=value,semantic=semantic,packet=p,send=send[0]['execute'][slot],
                                      receive=receive[0]['execute'][slot],consumer=event))
                bound.append(dict(**w,dsr=dsr,terms=terms,control=m['control'],send_instruction=compact_instruction(send[0]),receive_instruction=compact_instruction(receive[0])))
            scenes.append(dict(id=s['id'],title=f'{s["n"]}×{s["n"]} {family.upper()}',source=str((base/'events.jsonl.gz').relative_to(ROOT)),
                trace_dir=str((base/'simfab_traces').relative_to(ROOT)),placement=placement,colors=colors,wavelets=waves,
                unresolved_rows=unresolved,messages=bound,counts=dict(raw_observations=len(waves),data_packets_bound=len(used),
                    control_packets_bound=sum(m['control'] is not None for m in bound),unresolved_observations=len(unresolved))))
            for path in [base/'events.jsonl.gz',base/'pe.csl',base/'layout.csl',base/'placement.json',base/'manifest.json',base/'simfab_traces/metadata',base/'capture.log']+[base/p[key] for p in placement.values() for key in ('disasm','elf')]:
                identity(path)
            print(s['id'],scenes[-1]['counts'],flush=True)
    data=dict(schema='pe-hop-review/1',scenes=scenes,sources=sources,
        encoding='SDK f32 format: (index << 16) | data; data alone is only the low half',
        evidence='Packet edges require matching capture-local ident, full word, color/control, ordered observations and adjacent coordinates. Message binding additionally requires ordered full-vector equality, endpoints, and unique copy instructions with temporal bounds.',
        limits='Router observation interval includes unobserved transport/readiness delays; it is not pure wire latency. No queue-occupancy or SRAM-write timestamp is reconstructed. Control words are not numerical tensor values.')
    (OUT/'hops.json').write_text(json.dumps(data,indent=2)+'\n')
    template=(ROOT/'tools/pe_hops.html.tpl').read_text()
    (OUT/'hops.html').write_text(template.replace('__DATA__',json.dumps(data).replace('<','\\u003c')))
    print('Wrote',OUT/'hops.html')


if __name__=='__main__':build()
