"""Build time-slice presentations from verified observations, never synthetic cycles."""
import argparse
import json
from pathlib import Path

from .gemm_viz import f32bits, sha256

def instruction(scene,ids,which):
    d=scene['dynamic'][ids[which]]
    text=scene['programs'][d['pe']]['assembly'].get(str(d['pc']),d['name'])
    if isinstance(text,dict):text=text['text']
    return {'uid':d['uid'],'pc':d['pc'],'assembly':text,'raw_rows':d['raw_rows']}

def finish(scene,source):
    scene['events'].sort(key=lambda e:(e['cycle'],e['pe'],e['kind'],e['id']))
    scene['cycles']=sorted({e['cycle'] for e in scene['events']})
    scene['start']=scene['cycles'][0]-1;scene['end']=scene['cycles'][-1]
    scene['provenance']={'source_bundle':str(source),'source_sha256':sha256(source)}
    return scene

def gemv(scene,source):
    if not scene['verification']['passed'] or scene['trace']['binding']!='complete':raise ValueError('Time slices require fully verified MeshGEMV bindings')
    n,p,t=scene['n'],scene['p'],scene['t'];events=[]
    for out in scene['outputs']:
        for q in out['terms']:
            base={'pe':q['pe'],'index':out['j']%t,'label':f'partial[{out["j"]}]','j':out['j'],'k':q['k']}
            events.append({**base,'id':'mul:'+q['id'],'kind':'multiply','cycle':q['observed']['multiply_cycle'],
                           'a':q['x'],'b':q['w'],'value':q['product'],'instruction':instruction(scene,q['arithmetic_ids'],0)})
            events.append({**base,'id':'add:'+q['id'],'kind':'accumulate','cycle':q['observed']['add_cycle'],
                           'old':q['old'],'addend':q['product'],'value':q['acc'],'instruction':instruction(scene,q['arithmetic_ids'],1)})
        if p>1:
            r=out['reduction'];events.append({'id':f'reduce:{out["j"]}','kind':'reduce','cycle':r['observed']['cycle'],
                'pe':out['root'],'index':out['j']%t,'label':f'Y[{out["j"]}]','old':r['old'],'addend':r['peer'],'value':r['acc'],
                'instruction':instruction(scene,r['arithmetic_ids'],0)})
    pes=[]
    for pe in scene['pes']:
        pes.append({'id':pe['id'],'x':pe['x'],'y':pe['y'],'fabric':pe['fabric'],'input_labels':['X','W'],
                    'inputs':[pe['x_values'],[v for row in pe['w'] for v in row]],'input_columns':[t,t],
                    'partial_labels':[f'P[{pe["y"]},{j}]' for j in range(pe['x']*t,(pe['x']+1)*t)],
                    'final_expected':pe['observed']['result'],'final_readback':pe['observed']['result']})
        for name,phase in pe['phases'].items():
            values={}
            if name=='inputs':values={'partial':[0]*t}
            if name=='local':values={'partial':pe['observed']['partial']}
            if name=='peer':values={'peer':pe['observed']['peer']}
            if name in ('reduced','final'):values={'result':pe['observed']['result']}
            events.append({'id':f'phase:{pe["id"]}:{name}','kind':'checkpoint','cycle':phase['cycle'],'pe':pe['id'],
                           'phase':name,'values':values,'local_tick':phase['tick'],'instruction_ids':phase['instruction_ids'],
                           'evidence':'checked buffer/history + compiled phase semantics + trace-bound checkpoint'})
    return finish({'id':scene['id'],'kind':'gemv','title':f'{n}×{n} MeshGEMV · {p*p} PE(s)',
                   'n':n,'p':p,'t':t,'slots':t,'slot_columns':t,'pes':pes,'events':events,
                   'wavelets':scene['wavelets'],'has_checkpoints':True,'verification':scene['verification'],
                   'limitations':'Accumulator values come from matched execute results. Checkpoint buffers are tied to explicit program phases; they are not cycle-by-cycle SRAM dumps. Raw fabric observations are not assigned tensor elements.'},source)

def gemm(scene,source):
    if not scene['verification']['passed'] or scene['trace']['binding']!='complete':raise ValueError('Time slices require fully verified GEMM bindings')
    n,p,t=scene['n'],scene['p'],scene['t'];events=[];pes=[]
    for cell in scene['cells']:
        for q in cell['terms']:
            base={'pe':cell['pe'],'index':cell['local'][0]*t+cell['local'][1],'label':f'C[{cell["i"]},{cell["j"]}]','i':cell['i'],'j':cell['j'],'k':q['k']}
            events.append({**base,'id':'mul:'+q['id'],'kind':'multiply','cycle':q['observed']['multiply_cycle'],
                           'a':q['a'],'b':q['b'],'value':q['product'],'instruction':instruction(scene,q['arithmetic_ids'],0)})
            events.append({**base,'id':'add:'+q['id'],'kind':'accumulate','cycle':q['observed']['add_cycle'],
                           'old':q['old'],'addend':q['product'],'value':q['acc'],'instruction':instruction(scene,q['arithmetic_ids'],1)})
    for pe in scene['pes']:
        px,py=pe['x'],pe['y'];cells=[c for c in scene['cells'] if c['pe']==pe['id']]
        pes.append({'id':pe['id'],'x':px,'y':py,'fabric':pe['fabric'],'input_labels':['initial A tile','initial B tile'],
                    'inputs':[[m[i][j] for i in range(py*t,(py+1)*t) for j in range(px*t,(px+1)*t)] for m in [scene['a'],scene['b']]],
                    'input_columns':[t,t],'partial_labels':[f'C[{c["i"]},{c["j"]}]' for c in cells],
                    'final_expected':[c['expected'] for c in cells],'final_readback':[c['observed'] for c in cells]})
    waves=[{**w,'pe':f'{w["xy"][0]-4},{w["xy"][1]-1}'} for w in scene['wavelets']]
    return finish({'id':scene['id'],'kind':'gemm','title':f'{n}×{n} GEMM · {p*p} PE(s)',
                   'n':n,'p':p,'t':t,'slots':t*t,'slot_columns':t,'pes':pes,'events':events,
                   'wavelets':waves,'has_checkpoints':False,'verification':scene['verification'],
                   'limitations':'Displayed C values are last observed multiply/add results, not SRAM snapshots. The input panel separately shows fixed host tiles, checked round-panel history, and receive S6 observations when the hop evidence is supplied. Final host readback is an untimed comparison.'},source)

def state_at(scene,cycle):
    """Reference reducer used by verification tests and exported snapshot checks."""
    states={pe['id']:{'partial':[None]*scene['slots'],'peer':[None]*scene['slots'],
                          'result':[None]*scene['slots'],'phase':'not yet observed','product':None} for pe in scene['pes']}
    for e in scene['events']:
        if e['cycle']>cycle:break
        s=states[e['pe']]
        if e['kind']=='multiply':s['product']=e['value'];s['phase']='local compute'
        elif e['kind']=='accumulate':s['partial'][e['index']]=e['value'];s['phase']='local compute'
        elif e['kind']=='reduce':s['result'][e['index']]=e['value'];s['phase']='reduction'
        elif e['kind']=='checkpoint':
            s['phase']=e['phase']
            for key,values in e['values'].items():s[key]=list(values)
    return states

def add_input_evidence(scene,original,hops=None):
    """Fixed host tiles, checked round panels and optional timed receive operands.

    These are separate from the accumulator reducer: adding provenance must not
    change existing event cycles, phase sampling or output histories.
    """
    t,p=scene['t'],scene['p'];scene['input_panels']=[];scene['input_receipts']=[]
    def tile(tensor,rows,cols,values,storage,source,packing,evidence):
        packed=list(values) if packing=='row-major' else [values[i*len(cols)+j] for j in range(len(cols)) for i in range(len(rows))]
        return dict(tensor=tensor,rows=list(rows),cols=list(cols),values=values,packed=packed,storage=storage,
                    source=source,packing=packing,evidence=evidence)
    for pe in scene['pes']:
        x,y=pe['x'],pe['y'];rr=list(range(y*t,(y+1)*t));cc=list(range(x*t,(x+1)*t))
        if scene['kind']=='gemv':
            source=next(q for q in original['pes'] if q['id']==pe['id'])
            for name,vals in zip(('X','W'),pe['inputs']):
                if [f32bits(v) for v in vals]!=[f32bits(v) for v in source['observed'][name]]:raise ValueError('Input readback mismatch')
            pe['input_tiles']=[tile('X',[0],rr,pe['inputs'][0],'X',pe['id'],'row-major','Host upload + exact final X readback + matched multiply operands'),
                               tile('W',rr,cc,pe['inputs'][1],'W',pe['id'],'row-major','Host upload + exact final W readback + matched multiply operands')]
            pe['input_checkpoint']=source['phases']['inputs']['cycle']
        else:
            packing='row-major' if p==1 else 'column-major'
            pe['input_tiles']=[tile(name,rr,cc,vals,name,pe['id'],packing,'Host upload + exact owned-panel history + matched multiply operands; no separate final A/B readback') for name,vals in zip(('A','B'),pe['inputs'])]
            for inp in pe['input_tiles']:
                owned=next(q for q in original['panels'] if q['tensor']==inp['tensor'] and q['source']==[x,y] and q['destination']==[x,y])
                if [f32bits(v) for v in inp['packed']]!=[f32bits(v) for v in owned['observed']]:raise ValueError('Owned input tile disagrees with panel history')
    if scene['kind']=='gemm':
        for q in original['panels']:
            x,y=q['destination'];r=q['round'];name=q['tensor'];remote=q['transfer']
            rows=range(y*t,(y+1)*t) if name=='A' else range(r*t,(r+1)*t)
            cols=range(r*t,(r+1)*t) if name=='A' else range(x*t,(x+1)*t)
            panel=tile(name,rows,cols,[v for row in q['values'] for v in row],('abuf' if name=='A' else 'bbuf') if remote else name,
                ','.join(map(str,q['source'])),'row-major' if p==1 else 'column-major','Full panel checked against a_seen/b_seen; round follows the matched multiply k index')
            if [f32bits(v) for v in panel['packed']]!=[f32bits(v) for v in q['observed']]:raise ValueError('Panel readback mismatch')
            panel.update(pe=f'{x},{y}',round=r,remote=remote)
            scene['input_panels'].append(panel)
    if hops is not None:
        for message in hops['messages']:
            if scene['kind']!='gemm':continue
            candidates=[q for q in scene['input_panels'] if q['pe']==message['destination'] and q['tensor']==message['kind'] and q['round']==message['round'] and q['source']==message['source']]
            if len(candidates)!=1:raise ValueError('Hop panel identity mismatch')
            panel=candidates[0]
            if [f32bits(v) for v in panel['packed']]!=[term['packet']['word'] for term in message['terms']]:raise ValueError('Hop input values mismatch')
            for term in message['terms']:
                slot=term['slot'];index=(slot%t)*t+slot//t
                scene['input_receipts'].append(dict(pe=panel['pe'],tensor=panel['tensor'],storage=panel['storage'],round=panel['round'],source=panel['source'],
                    index=index,slot=slot,value=term['value'],cycle=term['receive']['cycle'],row=term['receive']['row'],ident=term['packet']['ident']))
    scene['input_receipts'].sort(key=lambda e:(e['cycle'],e['row']))
    return scene


def export(gemv_path,gemm_path,out,hops_path=None):
    hops=json.loads(Path(hops_path).read_text()) if hops_path else None
    scenes=[]
    for path,convert in [(gemv_path,gemv),(gemm_path,gemm)]:
        if not path:continue
        for original in json.loads(Path(path).read_text())['scenes']:
            hop=next((h for h in hops['scenes'] if h['id']==original['id']),None) if hops else None
            if hop:
                raw=original['provenance']['run']+'/events.jsonl.gz'
                if hop['source']!=raw or hops['sources'].get(raw)!=original['provenance']['sha256']['events.jsonl.gz']:
                    raise ValueError('Input hop capture identity mismatch')
            scene=add_input_evidence(convert(original,path),original,hop)
            if hop:scene['provenance']['input_hops']={'path':str(hops_path),'sha256':sha256(hops_path)}
            scenes.append(scene)
    for s in scenes:
        final=state_at(s,s['end'])
        for pe in s['pes']:
            key='result' if s['kind']=='gemv' else 'partial'
            if [f32bits(v) for v in final[pe['id']][key]]!=[f32bits(v) for v in pe['final_readback']]:raise ValueError('Final time-slice state disagrees with readback')
    bundle={'schema':'time-slices/1','scenes':scenes}
    Path(out).parent.mkdir(parents=True,exist_ok=True);Path(out).write_text(json.dumps(bundle,separators=(',',':'),allow_nan=False))
    print('Time slices:',[(s['id'],len(s['events']),s['start'],s['end']) for s in scenes])
    return bundle

if __name__=='__main__':
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--gemv',type=Path,required=True)
    ap.add_argument('--gemm',type=Path);ap.add_argument('--out',type=Path,required=True);ap.add_argument('--hops',type=Path)
    a=ap.parse_args();export(a.gemv,a.gemm,a.out,a.hops)
