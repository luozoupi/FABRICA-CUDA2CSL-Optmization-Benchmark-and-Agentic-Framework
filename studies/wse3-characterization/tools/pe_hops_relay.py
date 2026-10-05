#!/usr/bin/env python3
"""Audit the two retained adjacent-PE relay captures without rerunning them."""
import gzip
import hashlib
import json
from pe_hops import ROOT, OUT, word32, f32, bits, packets_for, read_capture
from anatomy_common import wavelet_fields


def build():
    placement={f'{i},0':dict(tile=20+i,fabric=[4+i,1],disasm=f'disasm_pe{i}.json') for i in range(2)}
    rows=[];sources={}
    for name,filename in [('relay','events_n1b8.jsonl.gz'),('relay_compute','events.jsonl.gz')]:
        base=ROOT/'microbench'/name
        if name=='relay_compute':waves,ins=read_capture(base,placement,[6],filename)
        else:
            waves=[];ins=[]
            with gzip.open(base/filename,'rt') as fh:
                for row,line in enumerate(fh,1):
                    e=json.loads(line)
                    if e['event_type']!='wavelet_trace_entry' or e['tile_index'] not in (20,21) or e['fields']&31!=6:continue
                    w=wavelet_fields(e['fields']);pe=f'{e["tile_index"]-20},0'
                    waves.append(dict(row=row,cycle=e['cycle'],ident=str(e['ident']),pe=pe,xy=placement[pe]['fabric'],
                        index=e['index'],data=e['data'],word=word32(e['index'],e['data']),color=w['colour'],
                        control=w['ctrl'],link=w['link'],ramp=w['link']=='R',fields=e['fields']))
        packets,unresolved=packets_for(waves)
        packets.sort(key=lambda p:p['observations'][0]['cycle'])
        assert len(packets)==8 and not unresolved
        consumers=[]
        if name=='relay_compute':
            result=json.loads((base/'result.json').read_text())
            assert result['received_ok'] and result['res_ok']
            assert [p['word'] for p in packets]==[bits(v) for v in result['buf0']]
            arithmetic=[i for i in ins if i['pe']=='1,0' and i['name']=='FADDS' and i['count']==8]
            assert len(arithmetic)==1
            for slot,e in enumerate(sorted(arithmetic[0]['execute'],key=lambda e:e['index'])):
                assert sorted([e['src0'],e['src1']])==sorted([bits(result['buf0'][slot]),bits(result['loc1'][slot])])
                assert e['dest']==bits(result['res'][slot])
                consumers.append(dict(slot=slot,cycle=e['cycle'],row=e['row'],uid=arithmetic[0]['uid'],pc=arithmetic[0]['pc'],
                    incoming=result['buf0'][slot],local=result['loc1'][slot],result=result['res'][slot]))
            assert len(consumers)==8
        rows.append(dict(id=name,source=str((base/filename).relative_to(ROOT)),trace_dir=str((base/'simfab_traces').relative_to(ROOT)),
            wavelets=waves,packets=packets,consumers=consumers,values=[f32(p['word']) for p in packets],
            intervals=[p['interval'] for p in packets],host_numeric_readback_verified=name=='relay_compute'))
        for path in [base/filename,base/'pe.csl',base/'layout.csl',base/('result.json' if name=='relay_compute' else 'result_N1_B8.json')]:
            sources[str(path.relative_to(ROOT))]=hashlib.sha256(path.read_bytes()).hexdigest()
    OUT.mkdir(parents=True,exist_ok=True)
    (OUT/'relay_comparison.json').write_text(json.dumps(dict(captures=rows,sources=sources,
        limits='Different programs, not a controlled readiness experiment. Router arrival does not identify input-queue occupancy. FMOV32 S6 zeros are not used as numeric payload evidence.'),indent=2)+'\n')
    for row in rows:print(row['id'],row['intervals'],len(row['consumers']),'arithmetic lanes checked')


if __name__=='__main__':build()
