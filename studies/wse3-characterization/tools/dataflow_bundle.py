#!/usr/bin/env python3
"""Join checked numeric observations, packet identities and ELF storage for WebGL.

Host API order has no measured simulator timestamp in the retained runs. Never
assign synthetic cycles to upload/readback, or treat an S6 value as a SRAM write.
"""
import argparse
import hashlib
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]

def walkthrough(s):
    """A checked algorithmic ordering, never a synthetic cycle-by-cycle trace."""
    n,t,p=s['n'],s['t'],s['p'];gemm=s['kind']=='gemm'
    inputs={x['name']:x['values'] for x in s['host']['inputs']}
    tiles=[dict(tile, id=f"{tile['tensor']}@{pe['id']}", pe=pe['id'], fabric=pe['fabric'])
           for name in inputs for pe in s['pes'] for tile in pe['input_tiles'] if tile['tensor']==name]
    outputs=[]
    for pe in s['pes']:
        if not gemm and pe['y']!=p-1:continue
        rows=list(range(pe['y']*t,(pe['y']+1)*t)) if gemm else [0]
        cols=list(range(pe['x']*t,(pe['x']+1)*t))
        outputs.append(dict(pe=pe['id'],tensor=s['host']['output_name'],rows=rows,cols=cols,
                            values=[s['host']['output'][i][j] for i in rows for j in cols]))
    state={pe['id']:dict(partial=None,result=None) for pe in s['pes']}
    resident=[];gathered=[];steps=[]
    def step(phase,title,description,chapter=0,**kw):
        steps.append(dict(id=f'{phase}-{len(steps)}',phase=phase,title=title,description=description,
                          chapter=chapter,resident=list(resident),gathered=list(gathered),
                          state=json.loads(json.dumps(state)),**kw))
    step('overview','Host → edge I/O → support PEs → kernel',
         'The SDK connects edge I/O to the kernel rectangle through three west support columns and two east support columns. These captures use copy mode, one SDK channel, and no inserted buffers. The drawing is a schematic, not a captured physical I/O route.')
    step('partition',f'Partition the {n} × {n} workload',
         f'Each matrix tile is {t} × {t}. Logical PE (x,y) owns matrix rows y·{t}…(y+1)·{t}−1 and columns x·{t}…(x+1)·{t}−1. '+
         ('C stays on its owner throughout all panel rounds.' if gemm else 'This workload is Y = X × W. X slices follow W rows and are copied to every PE in that row; this is host replication, not a captured X broadcast.'))
    for tile in tiles:
        resident.append(tile['id'])
        step('place',f"Place {tile['tensor']} tile → PE ({tile['pe']})",
             'The highlighted global tile is copied to its exported local SRAM array. Tile steps split a host memcpy for explanation; they do not assert a measured order of individual PE deliveries.',
             1,tile=tile['id'],pe=tile['pe'],tensor=tile['tensor'])
    for pe in s['pes']:state[pe['id']]['partial']=[0]*s['slots']
    step('launch','Inputs resident → launch the kernel',
         'All input arrays now have SRAM backing. The zero accumulators shown here follow kernel initialization; teaching states below are checked reconstructions, not simultaneous memory snapshots.',2)
    def flows(kind,round_=None):
        groups={}
        for q in s['packets']:
            if q['kind']!=kind or (round_ is not None and q.get('round')!=round_):continue
            key=(q['source'],q['destination'])
            groups.setdefault(key,[]).append(q)
        return [dict(source=a,destination=b,tensor=kind,values=[q['value'] for q in sorted(qs,key=lambda q:q['slot'])],
                     packet_ids=[q['id'] for q in qs]) for (a,b),qs in groups.items()]
    events={(e['kind'],e['pe'],e.get('i'),e.get('j'),e.get('k')):e
            for e in s['events'] if e['kind'] in ('multiply','accumulate')}
    rounds=range(p) if gemm else range(1)
    for r in rounds:
        if gemm:
            for name,axis in [('A','row'),('B','column')]:
                step('panel',f'Round {r+1}/{p} · {name} panels along each {axis}',
                     f"{name} panels for k = {r*t}…{(r+1)*t-1}. Owned panels are read locally; remote panels arrive in {'abuf' if name=='A' else 'bbuf'}. Only this operand's transfers are highlighted.",
                     4 if p>1 else 3,tensor=name,round=r,flows=flows(name,r))
        for offset in range(t):
            calcs=[]
            for pe in s['pes']:
                k=r*t+offset if gemm else pe['y']*t+offset
                rows=range(pe['y']*t,(pe['y']+1)*t) if gemm else [None]
                cols=range(pe['x']*t,(pe['x']+1)*t)
                before=list(state[pe['id']]['partial']);a=[];b=[];products=[];after=[];mul_ids=[];add_ids=[]
                for z,(i,j) in enumerate((i,j) for i in rows for j in cols):
                    av=inputs['A'][i][k] if gemm else inputs['X'][0][k]
                    bv=inputs['B' if gemm else 'W'][k][j]
                    mul=events[('multiply',pe['id'],i,j,k)];add=events[('accumulate',pe['id'],i,j,k)]
                    assert (mul['a'],mul['b'],mul['value'])==(av,bv,av*bv)
                    assert (add['old'],add['addend'],add['value'])==(before[z],av*bv,before[z]+av*bv)
                    a.append(av);b.append(bv);products.append(av*bv);after.append(add['value'])
                    mul_ids.append(mul['id']);add_ids.append(add['id'])
                state[pe['id']]['partial']=after
                calcs.append(dict(pe=pe['id'],k=k,before=before,a=a,b=b,products=products,after=after,mul_ids=mul_ids,add_ids=add_ids))
            step('compute',f"{'Round '+str(r+1)+' · k = '+str(r*t+offset) if gemm else 'Local term '+str(offset+1)+'/'+str(t)} · multiply and accumulate",
                 'Each displayed cell performs old + left × right = new. All operands, products and sums are checked against captured instructions. This teaching step groups operations from different cycles; select a scalar operation to open its actual time slice.',
                 3,round=r,offset=offset,calculations=calcs)
    if not gemm and p>1:
        assert p==2,'The retained GEMV reduction is the two-row algorithm.'
        for x in range(p):
            source=f'{x},0';destination=f'{x},1'
            before=state[destination]['partial'];incoming=state[source]['partial'];after=[a+b for a,b in zip(before,incoming)]
            reduced=sorted((e for e in s['events'] if e['kind']=='reduce' and e['pe']==destination),key=lambda e:e['index'])
            assert [e['value'] for e in reduced]==after
            state[destination]['result']=after
            step('reduce',f'Column {x} · combine partials on PE ({destination})',
                 'The upper PE sends its partial vector to the lower PE. The receiver adds its own local contribution. Purple arrows identify matched partial packets.',
                 4,pe=destination,flows=[f for f in flows('partial') if f['destination']==destination],
                 reduction=dict(before=before,incoming=incoming,after=after,event_ids=[e['id'] for e in reduced]))
        for x in range(p):
            source=f'{x},1';destination=f'{x},0';state[destination]['result']=state[source]['result']
            step('replicate',f'Column {x} · return the completed Y slice',
                 'The lower PE sends the final result back up. Both PE rows retain a checked replica. Host assembly below uses the lower row and omits duplicate replicas.',
                 4,pe=destination,flows=[f for f in flows('replica') if f['destination']==destination])
    else:
        for v in state.values():v['result']=v['partial']
    for pe in s['pes']:assert state[pe['id']]['result']==pe['final_readback']
    step('results','Final values on the PEs',
         'All output tiles agree with independently computed reference results and the retained host readbacks.',5)
    for tile in outputs:
        gathered.append(tile['pe'])
        step('gather',f"Assemble {tile['tensor']} from PE ({tile['pe']})",
             'The highlighted tile is placed back at its global output indices. D2H timing and its physical path were not captured; the mint dashed route is explanatory.',
             6,pe=tile['pe'])
    step('complete','Host output · exact numerical verification',
         'The assembled output agrees with every checked PE result. Use Observed journey or Time layers to inspect the instrumented simulator timeline.',6)
    return dict(schema='wse-teaching/1',tiles=tiles,output_tiles=outputs,steps=steps,
                time_basis='algorithmic teaching order, not global cycle order',
                checked_operations=sum(len(c['after']) for st in steps for c in st.get('calculations',[])))

def build():
    paths=['viewer/public/time-bundle.json','viewer/public/bundle.json',
           'viewer/public/gemv-bundle.json','results/pe-hops/hops.json','results/input-storage.json']
    loaded={p:json.loads((ROOT/p).read_text()) for p in paths}
    sources=[dict(path=p,sha256=hashlib.sha256((ROOT/p).read_bytes()).hexdigest()) for p in paths]
    original={s['id']:s for p in paths[1:3] for s in loaded[p]['scenes']}
    hops={s['id']:s for s in loaded[paths[3]]['scenes']}
    storage={s['scene']:s for s in loaded[paths[4]]['scenes']}
    scenes=[]
    for source in loaded[paths[0]]['scenes']:
        s=dict(source); raw=original[s['id']];n=s['n']
        assert s['verification']['passed'],s['id']
        if s['kind']=='gemm':
            inputs=[dict(name='A',rows=n,cols=n,values=raw['a']),dict(name='B',rows=n,cols=n,values=raw['b'])]
            output=[[None]*n for _ in range(n)]
            for c in raw['cells']:
                assert c['expected']==c['observed']
                output[c['i']][c['j']]=c['observed']
        else:
            inputs=[dict(name='X',rows=1,cols=n,values=[raw['x']]),dict(name='W',rows=n,cols=n,values=raw['w'])]
            output=[[] for _ in range(1)]
            # Every vertical PE replica must agree with its independently checked result.
            output[0]=[next(p for p in s['pes'] if p['x']==j//s['t'] and p['y']==s['p']-1)['final_readback'][j%s['t']] for j in range(n)]
            for pe in s['pes']:
                assert pe['final_readback']==pe['final_expected']
        s['host']=dict(inputs=inputs,output=output,output_name='C' if s['kind']=='gemm' else 'Y',
                       mode='copy',upload_cycle=None,readback_cycle=None,
                       note='Host calls and payloads are recorded; ingress/egress cycles and physical off-chip links are not bound in this capture.')
        s['storage']=storage[s['id']]['pes']
        s['packets']=[]
        for message in hops.get(s['id'],{}).get('messages',[]):
            for term in message['terms']:
                packet=term.get('packet')
                if not packet:continue
                s['packets'].append(dict(id=packet['ident'],source=message['source'],destination=message['destination'],
                    kind=message['kind'],label=message['label'],round=message.get('round'),slot=term['slot'],value=term['value'],
                    word=packet['word'],color=message['color'],observations=packet['observations'],
                    send=term.get('send'),receive=term.get('receive'),consumer=term.get('consumer'),
                    send_instruction=message.get('send_instruction',{}).get('assembly'),
                    receive_instruction=message.get('receive_instruction',{}).get('assembly')))
        s['cycles']=sorted(set(s['cycles']+[o['cycle'] for p in s['packets'] for o in p['observations']]))
        s['sources']=sources
        s['limits']=[s['limitations'],s['host']['note'],
            'Stored inputs show initialized SRAM backing; operand/result observations do not establish SRAM write-commit cycles.',
            'The mesh is the logical application placement; edge I/O and support PE geometry is schematic.',
            'Time layers repeat the same PEs at later times. They are not different physical chips.',
            'GPR/DSR snapshots and pipeline latch states are unavailable in these retained captures.']
        s['io_layout']=dict(offset=[4,1],support_west_columns=3,support_east_columns=2,buffer_columns=0,
            channels=1,
            evidence='SDK memcpy documentation + retained compiler flags',
            source='https://cerebras-sdk-docs-140.netlify.app/tensor-streaming')
        s['teaching']=walkthrough(s)
        scenes.append(s)
    snapshot_path=ROOT/'results/snapshots/summary.json'
    snapshots=json.loads(snapshot_path.read_text()) if snapshot_path.exists() else None
    return dict(schema='wse-dataflow/1',scenes=scenes,sources=sources,snapshots=snapshots)

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--out',type=Path,default=ROOT/'viewer/public/dataflow-bundle.json')
    a=ap.parse_args();data=build();a.out.parent.mkdir(parents=True,exist_ok=True)
    a.out.write_text(json.dumps(data,separators=(',',':'))+'\n')
    print(a.out,len(data['scenes']),'scenes',sum(len(s['packets']) for s in data['scenes']),'packets')

if __name__=='__main__':main()
