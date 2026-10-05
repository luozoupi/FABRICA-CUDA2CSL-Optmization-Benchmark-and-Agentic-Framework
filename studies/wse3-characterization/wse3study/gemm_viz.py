"""Tiny GEMM: independent numerical model, checked capture binding, viewer export.

Mathematical values are always labelled reference. Only SDK readbacks become
observations. Dynamic instruction associations require sequence AND operand-value
agreement; a missing match does not get a fabricated cycle or register name.
"""
from __future__ import annotations
import argparse
from collections import defaultdict
import gzip
import hashlib
import json
from pathlib import Path
import struct

STUDY = Path(__file__).resolve().parents[1]
CASES = {'g0':(4,1), 'g1':(4,2), 'g2':(8,2)}


def f32bits(value):
    return struct.unpack('<I',struct.pack('<f',value))[0]


def from_bits(value):
    return struct.unpack('<f',struct.pack('<I',value))[0]


def inputs(n):
    a=[[n*i+k+1 for k in range(n)] for i in range(n)]
    b=[[1,2,3,4],[0,1,2,3],[2,0,1,2],[1,2,0,1]] if n==4 else [[(3*k+2*j)%5-2 for j in range(n)] for k in range(n)]
    return a,b


def reference(case, a=None, b=None):
    n,p=CASES[case];t=n//p
    if a is None and b is None:a,b=inputs(n)
    if a is None or b is None or len(a)!=n or len(b)!=n or any(len(r)!=n for r in a+b):
        raise ValueError('GEMM inputs must match the selected square shape')
    cells=[];pes=[]
    for y in range(p):
        for x in range(p):
            pes.append({'id':f'{x},{y}','x':x,'y':y,'fabric':[x+4,y+1],
                        'rows':[y*t,(y+1)*t],'cols':[x*t,(x+1)*t],
                        'role':'application','placement_evidence':'requested; not yet compiler-bound'})
    for i in range(n):
        for j in range(n):
            x,y=j//t,i//t;terms=[];acc=0
            for k in range(n):
                old=acc;product=a[i][k]*b[k][j];acc+=product
                terms.append({'id':f'{i}:{j}:{k}','i':i,'j':j,'k':k,'round':k//t,
                              'a':a[i][k],'b':b[k][j],'old':old,'product':product,'acc':acc,
                              'a_origin':[k//t,i//t],'b_origin':[j//t,k//t],
                              'a_offset_bytes':4*(i*n+k if p==1 else (k%t)*t+i%t),
                              'b_offset_bytes':4*(k*n+j if p==1 else (j%t)*t+k%t),
                              'observed':None,'instruction_ids':[], 'binding':None})
            cells.append({'i':i,'j':j,'pe':f'{x},{y}','local':[i%t,j%t],
                          'c_offset_bytes':4*(i*n+j if p==1 else (j%t)*t+i%t),
                          'expected':acc,'observed':None,'terms':terms})
    panels=[]
    for y in range(p):
        for x in range(p):
            for s in range(p):
                for tensor,src,values in [
                    ('A',[s,y],[[a[y*t+ii][s*t+kk] for kk in range(t)] for ii in range(t)]),
                    ('B',[x,s],[[b[s*t+kk][x*t+jj] for jj in range(t)] for kk in range(t)])]:
                    packed=[values[i][j] for i in range(t) for j in range(t)] if p==1 else [values[i][j] for j in range(t) for i in range(t)]
                    panels.append({'tensor':tensor,'source':src,'destination':[x,y],'round':s,
                                   'values':values,'packed':packed,'observed':None,
                                   'transfer':src!=[x,y],'evidence':'algorithm'})
    return {'id':case,'n':n,'p':p,'t':t,'a':a,'b':b,'cells':cells,'pes':pes,'panels':panels,
            'storage':'row-major' if p==1 else 'column-major within each tile',
            'status':'reference only','verification':None,'programs':{},'dynamic':{},'wavelets':[],
            'trace':None,'control':None,'provenance':None}


def sha256(path):
    h=hashlib.sha256()
    with path.open('rb') as f:
        for block in iter(lambda:f.read(1024*1024),b''):h.update(block)
    return h.hexdigest()


def checked_manifest(work, schema='gemm-run/1'):
    m=json.loads((work/'manifest.json').read_text())
    if m.get('schema')!=schema:raise ValueError('Unsupported walkthrough run manifest')
    required={'capture.json','placement.json','pe.csl','layout.csl','events.jsonl.gz','simfab_traces/global_simdata.json'}
    if not required.issubset(m.get('sha256',{})):raise ValueError('Incomplete artifact manifest')
    for rel,expected in m['sha256'].items():
        path=(work/rel).resolve()
        if not path.is_relative_to(work.resolve()):raise ValueError('Artifact escapes run directory')
        if not path.is_file() or sha256(path)!=expected:raise ValueError(f'Artifact hash mismatch: {rel}')
    return m


def tick(words):
    return int(words[0]) | (int(words[1])<<16) | (int(words[2])<<32)


def bind_readback(scene, capture):
    n,p,t=scene['n'],scene['p'],scene['t']
    if (capture.get('case'),capture.get('n'),capture.get('p'),capture.get('history'),capture.get('evidence'))!=(scene['id'],n,p,True,'simulator'):
        raise ValueError('Capture identity does not match this teaching scene')
    for key,mat in [('a_bits',scene['a']),('b_bits',scene['b'])]:
        if capture[key]!=[f32bits(v) for row in mat for v in row]:raise ValueError('Capture input identity mismatch')
    rows={(r['x'],r['y']):r for r in capture['pes']}
    if len(rows)!=p*p or len(capture['pes'])!=p*p:raise ValueError('Incomplete or duplicate PE readbacks')
    mismatches=[];checks=0
    def compare(kind,where,got,expected):
        nonlocal checks
        checks+=1
        if got!=expected:mismatches.append({'kind':kind,**where,'observed':got,'expected':expected})
    for cell in scene['cells']:
        i,j=cell['i'],cell['j'];row=rows[j//t,i//t]
        slot=i*n+j if p==1 else (j%t)*t+i%t
        cell['observed']=from_bits(row['c_bits'][slot])
        compare('final',{'i':i,'j':j},cell['observed'],cell['expected'])
        for term in cell['terms']:
            k=term['k'];h=slot*n+k
            obs={name:from_bits(row[field][h]) for name,field in [('a','h_a'),('b','h_b'),('old','h_old'),('acc','h_new')]}
            obs['sample_tick']=tick(row['h_clock'][h*3:h*3+3]);obs['slot']=h
            obs['evidence']='simulator readback';term['observed']=obs
            for key in ['a','b','old','acc']:compare(key,{'i':i,'j':j,'k':k},obs[key],term[key])
    for panel in scene['panels']:
        row=rows[tuple(panel['destination'])];s=panel['round'];key='a_seen' if panel['tensor']=='A' else 'b_seen'
        panel['observed']=[from_bits(v) for v in row[key][s*t*t:(s+1)*t*t]]
        compare('panel',{'pe':panel['destination'],'round':s,'tensor':panel['tensor']},panel['observed'],panel['packed'])
    for pe in scene['pes']:
        row=rows[pe['x'],pe['y']];start,end=tick(row['time_words'][:3]),tick(row['time_words'][3:])
        pe['timer_ticks']=[start,end];pe['cycles']=(end-start)%(1<<48)
    scene['verification']={'passed':not mismatches,'checks':checks,'contributions':n**3,'outputs':n*n,'mismatches':mismatches}
    scene['status']='verified simulator' if not mismatches else 'verification failed'


def bind_trace(scene, work):
    n,p,t=scene['n'],scene['p'],scene['t']
    meta=json.loads((work/'simfab_traces/global_simdata.json').read_text());width=int(meta['xsize'])
    from .inventory import _Elf64
    placement=json.loads((work/'placement.json').read_text())
    tiles={}
    for pe in scene['pes']:
        loc=placement[pe['id']]
        if loc['tile'] not in _Elf64(work/loc['elf']).program_tile_ids():raise ValueError('ELF placement mismatch')
        if [loc['tile']%width,loc['tile']//width]!=pe['fabric']:raise ValueError('Unexpected PE coordinates')
        tiles[loc['tile']]=pe['id']
    programs={}
    for pe in scene['pes']:
        path=work/f'disasm_{pe["x"]}_{pe["y"]}.json'
        rows=json.loads(path.read_text());rows=rows.get('records',[]) if isinstance(rows,dict) else rows
        programs[pe['id']]={'assembly':{str(r['pc']):{'text':r['instruction'],'source':r['source'],'file':Path(r['source_file']).name} for r in rows if r.get('instruction')},
                            'csl':(work/'pe.csl').read_text(),'ir':''}
        cap=work/placement[pe['id']]['ir']
        if cap.exists():
            patched=list(cap.glob('cslc_ir_*/program.ll'))
            if len(patched)==1:programs[pe['id']]['ir']=patched[0].read_text()
        pe['placement_evidence']='ELF load-segment tile ID + simulator fabric width'
    dyn={};waves=[];counts=defaultdict(int);discarded=0
    with gzip.open(work/'events.jsonl.gz','rt') as f:
        for ordinal,line in enumerate(f):
            e=json.loads(line);kind=e['event_type'];counts[kind]+=1
            discarded=max(discarded,e.get('packet_context',{}).get('events_discarded',0))
            tile=e.get('tile_index');pe=tiles.get(tile);c=e.get('cycle')
            if kind=='wavelet_trace_entry' and c is not None and pe is not None:
                if e['fields']&31 in (0,1,4,5):
                    waves.append({'cycle':c,'xy':[tile%width,tile//width],'ident':str(e['ident']),
                                  'fields':e['fields'],'color':e['fields']&31,'data':e['data'],'row':ordinal})
            # TSC is reset independently on each PE. It is not a trace-cycle origin.
            # Match the complete run, then retain only the selected instruction context.
            if pe is None or c is None:continue
            if kind not in ('hwm_dispatch_trace_entry','hwm_pipe_trace_entry'):continue
            uid=f'{pe}:{e["uid"]}'
            d=dyn.setdefault(uid,{'id':uid,'uid':e['uid'],'pe':pe,'dispatch':[],'decode':[],'execute':[],'pc':None,'name':'unknown','raw_rows':[]})
            d['raw_rows'].append(ordinal)
            if kind=='hwm_dispatch_trace_entry':
                d['dispatch'].append(c);d['pc']=e.get('inst_ptr');d['name']=e.get('name','unknown')
                d['task']=e.get('task_color');d['ut']=e.get('ut_id')
            elif e['stage']==3:d['decode'].append(c)
            elif e['stage']==6:
                d['execute'].append({'cycle':c,'element':e.get('data'),'lane':e.get('simdi'),
                                     **{k:e.get(k) for k in ['dest','src0','src1','src2']}})
    scene['programs']=programs;scene['wavelets']=waves
    scene['trace']={'counts':dict(counts),'discarded':discarded,'width':width,
                    'wavelet_scope':'whole run, application PEs and colors 0,1,4,5 only; no sampling',
                    'clock_domains':'trace cycles and local TSC ticks have distinct origins',
                    'binding':'unresolved','matched_terms':0}
    if discarded or not scene['verification']['passed']:return
    for pe in scene['pes']:
        seq=sorted([v for v in dyn.values() if v['pe']==pe['id'] and v['dispatch']],key=lambda d:d['dispatch'][0])
        mul=[d for d in seq if d['name'].split('.')[0]=='FMULS']
        add=[d for d in seq if d['name'].split('.')[0]=='FADDS']
        terms=[term for cell in scene['cells'] if cell['pe']==pe['id'] for term in cell['terms']]
        terms.sort(key=(lambda q:(q['i'],q['j'],q['k'])) if p==1 else (lambda q:(q['round'],q['k'],q['j'],q['i'])))
        if len(mul)!=len(terms) or len(add)!=len(terms):continue
        positions={v['id']:i for i,v in enumerate(seq)}
        for term,m,a in zip(terms,mul,add):
            def last(d):return next((e for e in reversed(d['execute']) if e['dest'] not in (None,0xffffffff)),None)
            mv,av=last(m),last(a)
            if not mv or not av:continue
            if sorted([mv['src0'],mv['src1']])!=sorted([f32bits(term['a']),f32bits(term['b'])]):continue
            if mv['dest']!=f32bits(term['product']) or av['dest']!=f32bits(term['acc']):continue
            if sorted([av['src0'],av['src1']])!=sorted([f32bits(term['old']),f32bits(term['product'])]):continue
            start=max(0,positions[m['id']]-8);end=min(len(seq),positions[a['id']]+9)
            term['instruction_ids']=[d['id'] for d in seq[start:end]]
            term['arithmetic_ids']=[m['id'],a['id']]
            term['binding']='ordered scalar operations + exact execute operand/result bits + checked history'
            term['observed']['multiply_cycle']=mv['cycle'];term['observed']['add_cycle']=av['cycle']
            scene['trace']['matched_terms']+=1
    scene['trace']['binding']='complete' if scene['trace']['matched_terms']==n**3 else 'partial / unresolved'
    keep={uid for cell in scene['cells'] for q in cell['terms'] for uid in q['instruction_ids']}
    scene['dynamic']={uid:dyn[uid] for uid in keep}


def build_scene(case,captures=None):
    scene=reference(case)
    if captures is None:return scene
    work=Path(captures)/f'{case}-history'
    if not (work/'manifest.json').exists():return scene
    manifest=checked_manifest(work)
    bind_readback(scene,json.loads((work/'capture.json').read_text()))
    scene['provenance']={'run':str(work),'manifest_sha256':sha256(work/'manifest.json'),
                         'mode':manifest['mode'],'sif':manifest['sif'],'sha256':manifest['sha256']}
    bind_trace(scene,work)
    control=Path(captures)/f'{case}-control'
    if (control/'manifest.json').exists():
        cm=checked_manifest(control);c=json.loads((control/'capture.json').read_text())
        if (c.get('case'),c.get('n'),c.get('p'),c.get('history'),c.get('evidence'))!=(case,scene['n'],scene['p'],False,'simulator'):raise ValueError('Control identity mismatch')
        if c['a_bits']!=[f32bits(v) for r in scene['a'] for v in r] or c['b_bits']!=[f32bits(v) for r in scene['b'] for v in r]:raise ValueError('Control input mismatch')
        rows={(r['x'],r['y']):r for r in c['pes']}
        if len(rows)!=scene['p']**2 or len(c['pes'])!=len(rows):raise ValueError('Incomplete control PE readbacks')
        correct=True
        for cell in scene['cells']:
            i,j=cell['i'],cell['j'];t=scene['t'];n=scene['n']
            slot=i*n+j if scene['p']==1 else (j%t)*t+i%t
            correct &= rows[j//t,i//t]['c_bits'][slot]==f32bits(cell['expected'])
        scene['control']={'run':str(control),'correct':correct,'pes':[],'manifest_sha256':sha256(control/'manifest.json')}
        for row in c['pes']:
            start,end=tick(row['time_words'][:3]),tick(row['time_words'][3:])
            scene['control']['pes'].append({'id':f'{row["x"]},{row["y"]}','cycles':(end-start)%(1<<48)})
    return scene


def export(out, captures=None, case='all'):
    out=Path(out);out.mkdir(parents=True,exist_ok=True)
    scenes=[build_scene(k,captures) for k in (CASES if case=='all' else [case])]
    bundle={'schema':'gemm-viz/1','scenes':scenes}
    dest=out/'bundle.json';dest.write_text(json.dumps(bundle,separators=(',',':'),allow_nan=False))
    print(f'Wrote {dest} ({dest.stat().st_size:,} bytes)')
    for s in scenes:print(s['id'],s['status'],'instruction matches',s['trace']['matched_terms'] if s['trace'] else 0)
    return bundle


def command(args):
    export(args.out,args.captures,args.scene);return 0


if __name__=='__main__':
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--out',type=Path,required=True)
    ap.add_argument('--captures',type=Path);ap.add_argument('--scene',choices=['all',*CASES],default='all')
    command(ap.parse_args())
