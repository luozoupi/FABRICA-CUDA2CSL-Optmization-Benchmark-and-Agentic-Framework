"""Verified scalar MeshGEMV readbacks, instruction bindings, and checkpoints."""
from collections import Counter
import gzip
import json
from pathlib import Path
import struct

from .gemm_viz import checked_manifest, f32bits, from_bits, sha256, tick
from .inventory import _Elf64

CASES={'v0':(4,1),'v1':(4,2),'v2':(8,2)}
PHASES=['inputs','local','peer','reduced','final']

def reference(case):
    n,p=CASES[case];t=n//p
    x=[1,2,-1,3] if n==4 else [1,2,-1,3,0,-2,1,2]
    w=[[n*k+j+1 for j in range(n)] for k in range(n)]
    outputs=[];pes=[]
    for py in range(p):
        for px in range(p):
            pes.append({'id':f'{px},{py}','x':px,'y':py,'fabric':[px+4,py+1],
                        'w':[row[px*t:(px+1)*t] for row in w[py*t:(py+1)*t]],
                        'x_values':x[py*t:(py+1)*t],'partials':[], 'observed':None,'phases':{}})
    for j in range(n):
        parts=[];terms=[]
        for py in range(p):
            acc=0;px=j//t
            for k in range(py*t,(py+1)*t):
                old=acc;product=x[k]*w[k][j];acc+=product
                terms.append({'id':f'{j}:{k}','j':j,'k':k,'pe':f'{px},{py}',
                              'x':x[k],'w':w[k][j],'old':old,'product':product,'acc':acc,
                              'w_offset':4*((k%t)*t+j%t),'x_offset':4*(k%t),'partial_offset':4*(j%t),
                              'observed':None,'instruction_ids':[]})
            parts.append(acc);pes[py*p+px]['partials'].append(acc)
        outputs.append({'j':j,'expected':sum(parts),'parts':parts,'terms':terms,
                        'root':f'{j//t},{p-1}','replicas':[f'{j//t},{y}' for y in range(p)],
                        'observed':[],'reduction':{'old':parts[-1],'peer':parts[0] if p>1 else 0,
                        'acc':sum(parts),'observed':None,'instruction_ids':[]}})
    return {'id':case,'kind':'gemv','n':n,'p':p,'t':t,'x':x,'w':w,'pes':pes,'outputs':outputs,
            'status':'reference only','verification':None,'programs':{},'dynamic':{},'wavelets':[],
            'trace':None,'control':None,'provenance':None}

def readback(scene,capture,history=True):
    n,p,t=scene['n'],scene['p'],scene['t']
    if (capture.get('case'),capture.get('n'),capture.get('p'),capture.get('history'),capture.get('evidence'))!=(scene['id'],n,p,history,'simulator'):
        raise ValueError('MeshGEMV capture identity mismatch')
    if capture['x_bits']!=[f32bits(v) for v in scene['x']] or capture['w_bits']!=[f32bits(v) for row in scene['w'] for v in row]:
        raise ValueError('MeshGEMV input identity mismatch')
    rows={(r['x'],r['y']):r for r in capture['pes']}
    if set(rows)!={(x,y) for x in range(p) for y in range(p)} or len(capture['pes'])!=p*p:raise ValueError('Incomplete or duplicate PE readback')
    errors=[];checks=0
    def check(kind,got,expected,**where):
        nonlocal checks
        checks+=1
        if got!=expected:errors.append({'kind':kind,'observed':got,'expected':expected,**where})
    def values(row,key):return [from_bits(v) for v in row[key]]
    for pe in scene['pes']:
        px,py=pe['x'],pe['y'];row=rows[px,py]
        for key,expected in [('W',[v for r in pe['w'] for v in r]),('X',pe['x_values']),('partial',pe['partials']),
                             ('result',[o['expected'] for o in scene['outputs'][px*t:(px+1)*t]])]:
            for ix,(got,want) in enumerate(zip(values(row,key),expected,strict=True)):check(key,got,want,pe=pe['id'],index=ix)
        if p>1:
            for ix,(got,want) in enumerate(zip(values(row,'peer'),scene['pes'][px]['partials'],strict=True)):check('peer',got,want,pe=pe['id'],index=ix)
        if history:
            pe['observed']={key:values(row,key) for key in ['W','X','partial','peer','result']}
            pe['timer_ticks']=[tick(row['time_words'][:3]),tick(row['time_words'][3:])]
            pe['cycles']=(pe['timer_ticks'][1]-pe['timer_ticks'][0])%(1<<48)
            for index,name in enumerate(PHASES):
                expected=(index+1) if name in (['inputs','local','final'] if p==1 else ['inputs','local','peer','final']+(['reduced'] if py==p-1 else [])) else 0
                check('phase_flag',row['phase_flags'][index],expected,pe=pe['id'],phase=name)
                if expected:pe['phases'][name]={'tick':tick(row['phase_clock'][3*index:3*index+3]),'cycle':None}
    for out in scene['outputs']:
        j=out['j'];px=j//t
        if history:out['observed']=[values(rows[px,py],'result')[j%t] for py in range(p)]
        if not history:continue
        for q in out['terms']:
            row=rows[px,q['k']//t];slot=(j%t)*t+q['k']%t
            obs={key:from_bits(row[field][slot]) for key,field in [('x','h_x'),('w','h_w'),('old','h_old'),('acc','h_new')]}
            obs['sample_tick']=tick(row['h_clock'][slot*3:slot*3+3]);q['observed']=obs
            for key in ['x','w','old','acc']:check(key,obs[key],q[key],j=j,k=q['k'])
        if p>1:
            row=rows[px,p-1];r=out['reduction'];r['observed']={key:from_bits(row[field][j%t]) for key,field in [('old','r_old'),('peer','r_peer'),('acc','r_new')]}
            for key in ['old','peer','acc']:check('reduction_'+key,r['observed'][key],r[key],j=j)
    result={'passed':not errors,'checks':checks,'contributions':n*n,'outputs':n,'replicas':n*p,'mismatches':errors}
    if history:scene['verification']=result;scene['status']='verified simulator' if not errors else 'verification failed'
    return result

def function_ranges(path):
    elf=_Elf64(path);sym=elf.section('.symtab');strings_sec=elf.sections[sym.link]
    strings=elf.data[strings_sec.offset:strings_sec.offset+strings_sec.size];ranges={}
    for off in range(sym.offset,sym.offset+sym.size,sym.entry_size):
        name,info,_,_,value,size=struct.unpack_from('<IBBHQQ',elf.data,off)
        if info&15==2 and size:
            name=strings[name:].split(b'\0',1)[0].decode()
            # ELF addresses/sizes are bytes; simulator PCs are 16-bit words.
            ranges[name]=[value//2,(value+size)//2]
    return ranges

def load_trace(work,scene):
    meta=json.loads((work/'simfab_traces/global_simdata.json').read_text());width=int(meta['xsize'])
    placement=json.loads((work/'placement.json').read_text());tiles={};programs={}
    for pe in scene['pes']:
        loc=placement[pe['id']];elf=work/loc['elf']
        if loc['tile'] not in _Elf64(elf).program_tile_ids() or [loc['tile']%width,loc['tile']//width]!=pe['fabric']:raise ValueError('ELF placement mismatch')
        tiles[loc['tile']]=pe['id']
        doc=json.loads((work/f'disasm_{pe["x"]}_{pe["y"]}.json').read_text());records=doc['records']
        patched=list((work/loc['ir']).glob('cslc_ir_*/program.ll'))
        if len(patched)!=1:raise ValueError('Ambiguous executed IR')
        programs[pe['id']]={'assembly':{str(r['pc']):r['instruction'] for r in records},
                            'functions':function_ranges(elf),'csl':(work/'pe.csl').read_text(),'ir':patched[0].read_text()}
    dyn={};waves=[];counts=Counter();discarded=0
    for ordinal,line in enumerate(gzip.open(work/'events.jsonl.gz','rt')):
        e=json.loads(line);kind=e['event_type'];counts[kind]+=1
        discarded=max(discarded,e.get('packet_context',{}).get('events_discarded',0))
        pe=tiles.get(e.get('tile_index'));c=e.get('cycle')
        if pe is None or c is None:continue
        if kind=='wavelet_trace_entry' and e['fields']&31 in (4,5):
            waves.append({'cycle':c,'pe':pe,'ident':str(e['ident']),'color':e['fields']&31,'fields':e['fields'],'data':e['data'],'row':ordinal})
        if kind not in ('hwm_dispatch_trace_entry','hwm_pipe_trace_entry'):continue
        uid=f'{pe}:{e["uid"]}'
        d=dyn.setdefault(uid,{'id':uid,'uid':e['uid'],'pe':pe,'dispatch':[],'decode':[],'execute':[],'pc':None,'name':'unknown','raw_rows':[]})
        d['raw_rows'].append(ordinal)
        if kind=='hwm_dispatch_trace_entry':
            d['dispatch'].append(c);d['pc']=e['inst_ptr'];d['name']=e.get('name','unknown');d['task']=e.get('task_color');d['ut']=e.get('ut_id')
        elif e['stage']==3:d['decode'].append(c)
        elif e['stage']==6:d['execute'].append({'cycle':c,'lane':e.get('simdi'),'element':e.get('data'),**{k:e.get(k) for k in ['dest','src0','src1','src2']}})
    return programs,dyn,waves,{'counts':dict(counts),'discarded':discarded,'matched_terms':0,'matched_reductions':0,'matched_checkpoints':0}

def bind_trace(scene,work):
    programs,dyn,waves,trace=load_trace(work,scene);scene.update(programs=programs,wavelets=waves,trace=trace)
    if trace['discarded'] or not scene['verification']['passed']:return
    keep=set()
    def last(d):return next((e for e in reversed(d['execute']) if e['lane']==0 and e['dest'] is not None),None)
    for pe in scene['pes']:
        seq=sorted([d for d in dyn.values() if d['pe']==pe['id'] and d['dispatch']],key=lambda d:d['dispatch'][0]);positions={d['id']:i for i,d in enumerate(seq)}
        ranges=programs[pe['id']]['functions']
        def inside(d,name):
            lo,hi=ranges.get(name,[-1,-1]);return d['pc'] is not None and lo<=d['pc']<hi
        def context(q,*ops):
            lo=max(0,min(positions[d['id']] for d in ops)-5);hi=min(len(seq),max(positions[d['id']] for d in ops)+6)
            q['instruction_ids']=[d['id'] for d in seq[lo:hi]];keep.update(q['instruction_ids'])
        terms=sorted([q for out in scene['outputs'] for q in out['terms'] if q['pe']==pe['id']],key=lambda q:(q['k'],q['j']))
        mul=[d for d in seq if inside(d,'gemv') and d['name']=='FMULS'];add=[d for d in seq if inside(d,'gemv') and d['name']=='FADDS']
        if len(mul)==len(add)==len(terms):
            for q,m,a in zip(terms,mul,add):
                mv,av=last(m),last(a)
                if not mv or not av:continue
                if sorted([mv['src0'],mv['src1']])!=sorted([f32bits(q['x']),f32bits(q['w'])]):continue
                if mv['dest']!=f32bits(q['product']) or av['dest']!=f32bits(q['acc']):continue
                if sorted([av['src0'],av['src1']])!=sorted([f32bits(q['old']),f32bits(q['product'])]):continue
                q['observed'].update(multiply_cycle=mv['cycle'],add_cycle=av['cycle'])
                q['arithmetic_ids']=[m['id'],a['id']];context(q,m,a);trace['matched_terms']+=1
        reductions=[o for o in scene['outputs'] if o['root']==pe['id']] if scene['p']>1 else []
        add=[d for d in seq if inside(d,'combine') and d['name']=='FADDS']
        if len(add)==len(reductions):
            for out,d in zip(reductions,add):
                r=out['reduction'];v=last(d)
                if v and v['dest']==f32bits(r['acc']) and sorted([v['src0'],v['src1']])==sorted([f32bits(r['old']),f32bits(r['peer'])]):
                    r['observed']['cycle']=v['cycle'];r['arithmetic_ids']=[d['id']];context(r,d);trace['matched_reductions']+=1
        for name,phase in pe['phases'].items():
            ops=[d for d in seq if inside(d,'phase_'+name)]
            cycles=[v['cycle'] for d in ops for v in d['execute']]
            if cycles:
                phase['cycle']=max(cycles);phase['instruction_ids']=[d['id'] for d in ops];keep.update(phase['instruction_ids']);trace['matched_checkpoints']+=1
    scene['dynamic']={key:dyn[key] for key in sorted(keep)}
    trace['binding']='complete' if trace['matched_terms']==scene['n']**2 and trace['matched_reductions']==(scene['n'] if scene['p']>1 else 0) and trace['matched_checkpoints']==sum(len(pe['phases']) for pe in scene['pes']) else 'partial / unresolved'

def build_scene(case,root):
    s=reference(case);work=Path(root)/f'{case}-history';m=checked_manifest(work,'gemv-run/1')
    readback(s,json.loads((work/'capture.json').read_text()));bind_trace(s,work)
    s['provenance']={'run':str(work),'mode':m['mode'],'manifest_sha256':sha256(work/'manifest.json'),'sha256':m['sha256'],'sif':m['sif']}
    control=Path(root)/f'{case}-control';checked_manifest(control,'gemv-run/1');c=json.loads((control/'capture.json').read_text())
    v=readback(reference(case),c,False)
    s['control']={'correct':v['passed'],'verification':v,'manifest_sha256':sha256(control/'manifest.json'),
                  'pes':[{'id':f'{r["x"]},{r["y"]}','cycles':(tick(r['time_words'][3:])-tick(r['time_words'][:3]))%(1<<48)} for r in c['pes']]}
    return s

def export(root,out):
    bundle={'schema':'gemv-viz/1','scenes':[build_scene(case,root) for case in CASES]}
    Path(out).parent.mkdir(parents=True,exist_ok=True);Path(out).write_text(json.dumps(bundle,separators=(',',':'),allow_nan=False))
    for s in bundle['scenes']:print(s['id'],s['status'],s['trace'])
    return bundle

if __name__=='__main__':
    import argparse
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--captures',required=True,type=Path);ap.add_argument('--out',required=True,type=Path)
    a=ap.parse_args();export(a.captures,a.out)
