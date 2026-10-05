#!/usr/bin/env python3
"""Build verified instruction-sized teaching steps and simulator comparisons."""
import argparse,copy,gzip,hashlib,json,statistics,struct
from pathlib import Path
from weight_streaming import build_weight_streaming
ROOT=Path(__file__).resolve().parents[1]

def reference_review():
    result=dict(local='/home/USER/matmul-7ways.html',public='https://claude.ai/artifact/A7Zvd8JtB62NfzebTENCGr',status='See MATMUL_REFERENCE_REVIEW.md for local reference review and scope.')
    path=ROOT/'external/matmul-reference/local-review.json'
    if path.is_file():
        review=json.loads(path.read_text());source=Path(review['source'])
        if source.is_file() and hashlib.sha256(source.read_bytes()).hexdigest()==review['sha256']:
            result.update(sha256=review['sha256'],status='Updated local seven-view reference reviewed. All 14 coarse/fine configurations pass after repairing duplicate saved-DOM initialization in a separate copy. Views: inner/outer product, row/column AXPY, two GEMV-level groupings, and tiling. These are not seven independent loop orders.')
    return result

def mesh_evidence():
    path=ROOT/'viewer/public/dataflow-bundle.json'
    data=json.loads(path.read_text())
    scenes=[next(s for s in data['scenes'] if s['id']==name) for name in ('g1','g2','v1')]
    assert len(scenes)==3 and all(s['verification']['passed'] for s in scenes)
    return dict(hardware_dataflow=build_weight_streaming(scenes[0]),mesh_scenes=scenes,mesh_source=dict(path=str(path.relative_to(ROOT)),sha256=hashlib.sha256(path.read_bytes()).hexdigest()))
LABELS={'ikj':'Row update · ikj','kij':'Outer product by rows · kij','jki':'Column update · jki','kji':'Outer product by columns · kji','ijk_reduce':'Dot product · ijk (corrected)','jik_reduce':'Dot product · jik (corrected)','ikj_map':'Row update · @map','ijk_bt_reduce':'Dot product · transposed B','ikj_map_blk':'Blocked row · descriptor reload','ikj_packed_blk':'Blocked row · packed B + @map','ijk_scalar':'Scalar dot product','ijk_bad':'Diagnostic · last-product overwrite'}

def function_source(source,name):
    start=source.index('fn '+name+'(');brace=source.index('{',start);depth=1;end=brace+1
    while depth:
        depth+=(source[end]=='{')-(source[end]=='}');end+=1
    return source[start:end]

def steps_for(c,name):
    n=c['n'];tile=c['tile'];A=c['inputs']['A'];B=c['inputs']['B'];C=[[0]*n for _ in range(n)];steps=[]
    def emit(op,indices,bad=False):
        before=copy.deepcopy(C);updates=[];acc=0
        for i,j,k in indices:
            av,bv=A[i][k],B[k][j];product=av*bv;old=C[i][j]
            if op=='FMULH':value=product
            elif op=='FADDH':
                old=0 if bad else acc;value=old+product;acc=value;C[i][j]=value
            else:value=old+product;C[i][j]=value
            updates.append(dict(i=i,j=j,k=k,a=av,b=bv,product=product,old=old,value=value))
        steps.append(dict(op=op,before=before,after=copy.deepcopy(C),updates=updates))
    if name in ('ikj','kij','ikj_map'):
        order=((i,k) for i in range(n) for k in range(n)) if name!='kij' else ((i,k) for k in range(n) for i in range(n))
        for i,k in order:emit('FMACH',[(i,j,k) for j in range(n)])
    elif name in ('jki','kji'):
        order=((j,k) for j in range(n) for k in range(n)) if name=='jki' else ((j,k) for k in range(n) for j in range(n))
        for j,k in order:emit('FMACH',[(i,j,k) for i in range(n)])
    elif name in ('ikj_map_blk','ikj_packed_blk'):
        for i in range(n):
            for jb in range(0,n,tile):
                for k in range(n):emit('FMACH',[(i,j,k) for j in range(jb,jb+tile)])
    elif name=='ijk_scalar':
        # This schedule is source order. Optimizing compilers may reorder scalar
        # multiplies, so it is deliberately not bound by dispatch position.
        for i in range(n):
            for j in range(n):
                for k in range(n):
                    emit('FMULH',[(i,j,k)])
                    before=copy.deepcopy(C);old=C[i][j];value=old+A[i][k]*B[k][j];C[i][j]=value
                    steps.append(dict(op='FADDH',before=before,after=copy.deepcopy(C),updates=[dict(i=i,j=j,k=k,a=A[i][k],b=B[k][j],product=A[i][k]*B[k][j],old=old,value=value)]))
    else:
        order=((i,j) for j in range(n) for i in range(n)) if name=='jik_reduce' else ((i,j) for i in range(n) for j in range(n))
        for i,j in order:
            indices=[(i,j,k) for k in range(n)];emit('FMULH',indices);emit('FADDH',indices,name=='ijk_bad')
    expected=next(v['output'] for v in c['runs'][0]['variants'] if v['name']==name)
    assert C==expected,(n,name,'teaching state disagrees with capture')
    return steps

def load_trace(path):
    inst=[];byuid={};discarded=0
    with gzip.open(path,'rt') as f:
        for row,line in enumerate(f,1):
            if 'hwm_dispatch_trace_entry' not in line and 'hwm_pipe_trace_entry' not in line:continue
            e=json.loads(line);discarded=max(discarded,e.get('packet_context',{}).get('events_discarded',0))
            if e.get('tile_index')!=12:continue # bound by width=8, offset=(4,1)
            if e['_type']=='hwm_dispatch_trace_entry' and e['name'] in ('FMACH','FMULH','FADDH'):
                q=dict(op=e['name'],uid=e['uid'],pc=e['inst_ptr'],cycle=e['cycle'],row=row,length=e['num_data'],records=[]);inst.append(q);byuid[e['uid']]=q
            elif e['_type']=='hwm_pipe_trace_entry' and e['stage']==6 and e['simdi']!=255 and e['uid'] in byuid:
                byuid[e['uid']]['records'].append(dict(cycle=e['cycle'],row=row,lane=e['simdi'],element=e['data'],**{k:e[k] for k in ('src0','src1','src2','dest')}))
    assert discarded==0,'Trace reports discarded events'
    return inst

def halfbits(x):return int.from_bytes(struct.pack('<e',x),'little')
def verify_capture(work):
    manifest=json.loads((work/'manifest.json').read_text())
    names=['capture.json','meta.json','pe.csl','layout.csl','out/bin/out_0_0.elf']
    if (work/'events.jsonl.gz').exists():names.append('events.jsonl.gz')
    for name in names:
        h=hashlib.sha256()
        with (work/name).open('rb') as f:
            for chunk in iter(lambda:f.read(1024*1024),b''):h.update(chunk)
        assert h.hexdigest()==manifest['sha256'][name],f'Changed capture artifact: {work/name}'
    return {name:manifest['sha256'][name] for name in names}

def bind_trace(c,variants,path):
    inst=load_trace(path);cursor=0;bindings=0
    for rep in c['runs']:
        for v in variants:
            steps=v['steps'];observations=inst[cursor:cursor+len(steps)];cursor+=len(steps)
            assert len(observations)==len(steps),(c['n'],v['name'],'dispatch count')
            if v['name']=='ijk_scalar':continue
            for st,obs in zip(steps,observations):
                assert st['op']==obs['op'],(v['name'],st['op'],obs['op'])
                recs=sorted(obs['records'],key=lambda r:r['element'])
                assert len(recs)==len(st['updates'])==obs['length'],(v['name'],obs['pc'],'length')
                for u,r in zip(st['updates'],recs):
                    if st['op']=='FMACH':src=(u['old'],u['a'] if v['name'] in ('jki','kji') else u['b'],u['b'] if v['name'] in ('jki','kji') else u['a'])
                    elif st['op']=='FMULH':src=(u['a'],u['b'])
                    else:src=(u['old'],u['product'])
                    expected=[halfbits(x) for x in (*src,u['value'])]
                    got=[r['src'+str(i)]&65535 for i in range(len(src))]+[r['dest']&65535]
                    # +0/-0 may differ after multiply; compare decoded numerical
                    # values, retaining all raw bits in the presentation.
                    decode=lambda arr:[struct.unpack('<e',int(x).to_bytes(2,'little'))[0] for x in arr]
                    assert decode(got)==decode(expected),(c['n'],v['name'],obs['pc'],u,decode(got),decode(expected))
                if 'trace' not in st:st['trace']=obs;bindings+=len(recs)
    assert cursor==len(inst),(cursor,len(inst),'unaccounted arithmetic dispatches')
    return bindings

def build(root):
    cases=[]
    for path in sorted(root.glob('n*/capture.json'),key=lambda p:int(p.parent.name[1:])):
        verified=verify_capture(path.parent)
        c=json.loads(path.read_text());n=c['n'];variants=[]
        source=(path.parent/'pe.csl').read_text()
        for name in c['variants']:
            measurements=[next(v for v in r['variants'] if v['name']==name) for r in c['runs'] if not r['warmup']]
            cycles=[v['cycles'] for v in measurements];passed=all(v['passed'] for v in measurements)
            v=dict(name=name,label=LABELS[name],passed=passed,cycles=cycles,median=statistics.median(cycles),minimum=min(cycles),maximum=max(cycles),output=measurements[0]['output'],max_abs_err=max(v['max_abs_err'] for v in measurements))
            v['csl']=function_source(source,'bench_'+name)
            if name in ('ikj_map','ikj_packed_blk'):v['csl']+='\n\n'+function_source(source,'step_map')
            if n<=8:v['steps']=steps_for(c,name)
            variants.append(v)
        bound=bind_trace(c,variants,path.parent/'events.jsonl.gz') if (path.parent/'events.jsonl.gz').exists() and n<=8 else 0
        cases.append(dict(n=n,tile=c['tile'],dtype=c['dtype'],inputs=c['inputs'],reference=c['reference'],variants=variants,bound_values=bound,trace_trial='first invocation (warmup)',trace_enabled=c.get('trace_enabled',True),timing_scope=c['timing_scope'],source=str(path.relative_to(ROOT)),sha256=hashlib.sha256(path.read_bytes()).hexdigest(),verified_artifacts=verified))
    return dict(schema='matmul-debug/1',**mesh_evidence(),cases=cases,reference_review=reference_review(),limits=['Single application PE, f16, integer inputs chosen for exact arithmetic.','Fixed variant order; three timed repetitions after one warmup, not a statistical silicon benchmark.','Packing and H2D/D2H excluded from kernel cycles. Packed B occupies one additional n²-element buffer.','Trace stepping is replay of captured instructions, not interactive hardware pause or SRAM snapshots.','Scalar-loop teaching steps are source order and have no claimed cycle binding.'])
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--root',type=Path,default=ROOT/'results/matmul-compare/try-20260922a');p.add_argument('--out',type=Path,default=ROOT/'viewer/public/matmul-bundle.json');a=p.parse_args();b=build(a.root);a.out.write_text(json.dumps(b,separators=(',',':'))+'\n');print([(c['n'],c['bound_values']) for c in b['cases']])
