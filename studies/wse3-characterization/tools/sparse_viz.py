#!/usr/bin/env python3
"""Offline sparse walkthrough: retained SpMV lanes, source-reconstructed SpMM/SpGEMM.

Never launches a device job. Reconstructed steps have no instruction cycles.
"""
from __future__ import annotations
import gzip
import hashlib
import importlib.util
import json
import re
import struct
from pathlib import Path
import numpy as np

ROOT=Path(__file__).resolve().parents[1]
REPO=ROOT.parents[1]
OUT=ROOT/'results/sparse-walkthrough'


def f32(x):return float(np.float32(x))
def bits(x):return struct.unpack('<I',struct.pack('<f',x))[0]
def mac(old,a,b):
    product=f32(a*b)
    return product,f32(old+product)


def merge_dot(ptr,idx,val,i,j):
    """Mirror the captured source's two-pointer algorithm, including structural existence."""
    pa,pb=int(ptr[i]),int(ptr[j]);ea,eb=int(ptr[i+1]),int(ptr[j+1])
    old=0.0;steps=[];exists=False
    while pa<ea and pb<eb:
        ia,ib=int(idx[pa]),int(idx[pb]);match=ia==ib
        a,b=float(val[pa]),float(val[pb]);product,acc=mac(old,a,b) if match else (None,old)
        steps.append(dict(pa=pa,pb=pb,ia=ia,ib=ib,k=ia if match else None,a=a,b=b,match=match,
            action='match' if match else ('advance left' if ia<ib else 'advance right'),old=old,product=product,acc=acc))
        exists |= match;old=acc
        if ia<=ib:pa+=1
        if ib<=ia:pb+=1
    return steps,old,exists


def trace_spmv(base):
    asm={r['pc']:r for r in json.loads((base/'disasm.json').read_text())['records']}
    instructions={};markers={};discarded=0
    with gzip.open(base/'events.jsonl.gz','rt') as fh:
        for row,line in enumerate(fh,1):
            e=json.loads(line);discarded=max(discarded,e.get('packet_context',{}).get('events_discarded',0))
            if e.get('tile_index')!=12:continue
            if e['event_type']=='hwm_dispatch_trace_entry':
                dis=asm.get(e['inst_ptr'],{})
                marker=re.fullmatch(r'movri \S+ = 0x(700[0-9a-d])',dis.get('instruction',''))
                if marker:
                    key=int(marker[1],16)-0x7000
                    if key in markers:raise ValueError('Repeated strategy marker')
                    markers[key]=dict(cycle=e['cycle'],row=row,pc=e['inst_ptr'])
                if e['name'] not in ('FMULS','FADDS'):continue
                ins=instructions.setdefault(e['uid'],dict(uid=e['uid'],pc=e['inst_ptr'],name=e['name'],
                    assembly=dis['instruction'],source=dis.get('source'),dispatch=e['cycle'],lanes=[]))
                assert ins['pc']==e['inst_ptr']
            elif e['event_type']=='hwm_pipe_trace_entry' and e.get('stage')==6 and e.get('simdi')!=255:
                ins=instructions.get(e['uid'])
                if ins is not None:ins['lanes'].append(dict(cycle=e['cycle'],row=row,index=e['data'],lane=e['simdi'],
                    **{k:e[k] for k in ('src0','src1','dest')}))
    assert discarded==0
    return instructions,markers


def spmv_scenes():
    base=ROOT/'microbench/iremit';meta=json.loads((base/'meta.json').read_text())
    result=json.loads((base/'result.json').read_text());cost=json.loads((base/'measured.json').read_text())['per_strategy']
    assert (meta['NROWS'],meta['NCOLS'])==(16,16)
    ptr=[0];col=[];val=[];coordinates=[]
    for r in range(16):
        lo=max(0,r-1)
        for k in range(lo,min(15,r+2)+1):
            col.append(k);val.append((r*4+k-lo+1)*0.25);coordinates.append([r,k])
        ptr.append(len(col))
    x=[(k+1)*0.5 for k in range(16)];instructions,markers=trace_spmv(base)
    scenes=[]
    for name,label in [('scalar','Scalar CSR gather'),('ir','Hand-authored IR'),('blk','Block gather'),('dia','Diagonal streams')]:
        start,end=[markers[i] for i in meta['MARK'][name]]
        assert end['cycle']-start['cycle']==cost[name]['cycles']
        records={op:[] for op in ('FMULS','FADDS')}
        for ins in instructions.values():
            if start['cycle']<ins['dispatch']<end['cycle']:
                for lane in ins['lanes']:
                    records[ins['name']].append(dict(**{k:v for k,v in ins.items() if k!='lanes'},**lane))
        for op in records:records[op].sort(key=lambda e:(e['cycle'],e['row']))
        order=list(range(len(col)))
        if name=='dia':order.sort(key=lambda p:(coordinates[p][1]-coordinates[p][0],coordinates[p][0]))
        assert len(records['FMULS'])==len(records['FADDS'])==60
        outputs=[dict(r=r,c=0,pe=[0,0],steps=[],result=None,reference=None,observed=result['strategies'][name]['y'][r]) for r in range(16)]
        for ordinal,p in enumerate(order):
            r,k=coordinates[p];out=outputs[r];old=out['steps'][-1]['acc'] if out['steps'] else 0.0
            product,acc=mac(old,val[p],x[k]);mul,add=records['FMULS'][ordinal],records['FADDS'][ordinal]
            assert sorted([mul['src0'],mul['src1']])==sorted([bits(val[p]),bits(x[k])]),(name,p,'multiply operands')
            assert mul['dest']==bits(product),(name,p,'product')
            assert sorted([add['src0'],add['src1']])==sorted([bits(old),bits(product)]),(name,p,'add operands')
            assert add['dest']==bits(acc) and add['cycle']>=mul['cycle']
            out['steps'].append(dict(p=p,storage_p=ordinal if name=='dia' else p,storage_name='dia_val' if name=='dia' else 'val',
                k=k,a=val[p],b=x[k],old=old,product=product,acc=acc,action='accumulate',match=True,mul=mul,add=add))
        for out in outputs:
            out['result']=out['steps'][-1]['acc'];out['reference']=sum(val[p]*x[col[p]] for p in range(ptr[out['r']],ptr[out['r']+1]))
            assert out['result']==out['reference']==out['observed']
        scenes.append(dict(id='spmv-'+name,family='SpMV',title='SpMV · '+label,n=16,m=16,nnz=60,
            matrix='Retained 16×16 banded microbenchmark',mode='recorded',description=label+' on the same 60 nonzeros and vector.',
            evidence='Every multiply/add operand and result matches retained S6 bits. All 16 final outputs match host readback. Input indexing is reconstructed from run.py.'+(' The CSR row is a canonical comparison view; this strategy reads diagonal-packed dia_val storage.' if name=='dia' else ''),
            timing=f"Recorded strategy window: {cost[name]['cycles']} cycles; {cost[name]['instrs']} dispatched instructions.",
            transport='One application PE at fabric (4,1). Host loads CSR/diagonal arrays and x; no application PE-to-PE messages.',
            mesh=[1,1],rows_per_pe=16,cols_per_pe=1,ptr=ptr,idx=col,val=val,coordinates=coordinates,rhs=[[v] for v in x],outputs=outputs,
            start=start,end=end,trace=str((base/'events.jsonl.gz').relative_to(REPO)),
            regression=dict(label='Separate failing DSD reduction regression',observed=result['strategies']['blk_dsdred']['y'],
                note='The retained regression returns the last product per row. It is not one of the four passing strategies.'),
            sources=[str((base/f).relative_to(REPO)) for f in ('run.py','pe.csl','spmv_ir_body.ll','patched.ll','result.json','measured.json','meta.json','disasm.json','events.jsonl.gz','out/bin/out_0_0.elf','simfab_traces/global_simdata.json')]))
    return scenes


def load_sparse(kernel):
    base=REPO/'kernels'/kernel/'CSL'
    spec=importlib.util.spec_from_file_location('sparse_fixture',base/'sparse_inputs.py')
    mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod)
    csr,entry=mod.load_manifest_matrix(base/'data/manifest.json',7)
    matrix=base/'data'/entry['file']
    assert hashlib.sha256(matrix.read_bytes()).hexdigest()==entry['sha256']
    assert (csr.n,csr.m,csr.nnz)==(entry['n'],entry['m'],entry['nnz'])
    sources=[str((base/f).relative_to(REPO)) for f in ('run.py','pe.csl','layout.csl','commands_wse3.sh','sparse_inputs.py','data/manifest.json','data/'+entry['file'])]
    return base,mod,csr,entry,sources


def spmm_scene():
    base,mod,csr,entry,sources=load_sparse('SpMM-CSR-Dense')
    command=(base/'commands_wse3.sh').read_text()
    params={k:int(v) for k,v in re.findall(r'(\w+):(\d+)',command)}
    P,Mt,K,Nt=[params[k] for k in ('P','Mt','K','Nt')];N=P*Nt
    assert params['structure_id']==0 and csr.n<=P*Mt and csr.m<=K
    B=np.zeros((K,N),np.float32);B[:csr.m]=np.random.default_rng([7,1]).uniform(-1,1,(csr.m,N)).astype(np.float32)
    val=csr.val.astype(np.float32);ref=(csr.dense()@B[:csr.m].astype(np.float64)).astype(np.float32)
    outputs=[]
    for r in range(csr.n):
        for c in range(N):
            steps=[];old=0.0
            for p in range(int(csr.row_ptr[r]),int(csr.row_ptr[r+1])):
                k=int(csr.col[p]);a=float(val[p]);b=float(B[k,c]);product,acc=mac(old,a,b)
                steps.append(dict(p=p,local_p=p-int(csr.row_ptr[(r//Mt)*Mt]),k=k,a=a,b=b,old=old,product=product,acc=acc,action='accumulate',match=True));old=acc
            outputs.append(dict(r=r,c=c,pe=[c//Nt,r//Mt],steps=steps,result=old,reference=float(ref[r,c]),observed=None))
    got=np.array([o['result'] for o in outputs]).reshape(csr.n,N)
    np.testing.assert_allclose(got,ref,rtol=1e-4,atol=1e-5)
    report='code_translation/results/rebaseline_sparse_20260916/rebaseline_20260916_025528.json'
    benchmark=json.loads((REPO/report).read_text())['kernels']['SpMM-CSR-Dense']['small'];sources.append(report)
    return dict(id='spmm',family='SpMM',title='SpMM · CSR × dense',n=csr.n,m=csr.m,nnz=csr.nnz,matrix=entry['id']+' · seed 7',mode='reconstructed',
        description=f'{csr.n}×{csr.m} sparse A × {csr.m}×{N} dense B; {P}×{P} PEs, each owning {Mt}×{Nt} output capacity.',
        evidence='Numeric steps reconstructed from the retained matrix and current host/kernel sources using seed 7. NumPy reference checked locally. Per-element device output and instruction traces were not retained in the reviewed artifacts.',
        timing=f"Separate retained simulator benchmark: {benchmark['cycles_send']} cycles, status {benchmark['status']}; no per-step timing inferred.",
        transport='Host replicates each CSR row tile along a mesh row and each B slice down a mesh column. Local computation has no application PE-to-PE exchange.',
        mesh=[P,P],rows_per_pe=Mt,cols_per_pe=Nt,ptr=csr.row_ptr.tolist(),idx=csr.col.tolist(),val=val.tolist(),coordinates=np.column_stack([csr.rows(),csr.col]).tolist(),
        rhs=B.tolist(),outputs=outputs,sources=sources,params=params,reference_max_abs_error=float(np.max(np.abs(got-ref))))


def spgemm_scene():
    base,mod,csr,entry,sources=load_sparse('SpGEMM-Masked-Dot')
    params={k:int(v) for k,v in re.findall(r'(\w+):(\d+)',(base/'commands_wse3.sh').read_text())}
    csc=mod.csc_pad(csr,params['n'],params['max_nnz']);ptr,idx,val=csc['col_ptr'],csc['row'],csc['val']
    dense=csr.dense();ref=(dense.T@dense).astype(np.float32);pattern=(dense!=0).astype(np.int64);exists_ref=pattern.T@pattern
    outputs=[]
    for j in range(csr.n):
        for p in range(int(ptr[j]),int(ptr[j+1])):
            i=int(idx[p]);steps,acc,exists=merge_dot(ptr,idx,val,i,j)
            assert exists==bool(exists_ref[i,j]>0)
            target=float(ref[i,j]) if exists else 0.0
            np.testing.assert_allclose(acc,target,rtol=1e-5,atol=1e-6)
            outputs.append(dict(r=i,c=j,pe=[0,0],mask_slot=p,steps=steps,result=acc,reference=target,observed=None,
                exists=exists,zombie=not exists,row_code=i if exists else (~i)&0xffffffff))
    report='code_translation/results/hw_sparse_refs_20260916.json'
    benchmark=next(x for x in json.loads((REPO/report).read_text()) if x['kernel']=='SpGEMM-Masked-Dot');sources.append(report)
    return dict(id='spgemm',family='SpGEMM',title='SpGEMM · masked AᵀA',n=csr.n,m=csr.m,nnz=csr.nnz,matrix=entry['id']+' · seed 7',mode='reconstructed',
        description='Compute A(:,i) · A(:,j) only at mask positions (i,j) stored in A. Two sorted CSC lists advance until their row indices match.',
        evidence='Source-based reconstruction of the retained matrix fixture. Every mask value and structural existence flag checked against dense AᵀA and patternᵀpattern. This is masked AᵀA, not a general unmasked SpGEMM.',
        timing=f"Separate retained runs passed: simulator {benchmark['arms']['sim']['cycles_send']} cycles; hardware {benchmark['arms']['hw']['cycles_send']} cycles. No instruction-level timeline retained here.",
        transport='One application PE. Host provides CSC arrays; all index matching and accumulation is local. No application PE-to-PE hop is implied.',
        mesh=[1,1],rows_per_pe=params['n'],cols_per_pe=params['n'],ptr=ptr[:csr.n+1].tolist(),idx=idx[:csr.nnz].tolist(),val=val[:csr.nnz].tolist(),
        coordinates=np.column_stack([csr.rows(),csr.col]).tolist(),outputs=outputs,sources=sources,zombies=sum(o['zombie'] for o in outputs))


def build():
    scenes=spmv_scenes()+[spmm_scene(),spgemm_scene()]
    paths=sorted({p for s in scenes for p in s['sources']})
    hashes={p:hashlib.sha256((REPO/p).read_bytes()).hexdigest() for p in paths}
    data=dict(schema='sparse-walkthrough/1',numpy_version=np.__version__,scenes=scenes,sources=hashes,
        limits='Recorded SpMV S6 values and final readbacks are separated from source-based SpMM/SpGEMM reconstruction. Logical steps are not device cycles. No new device jobs were launched.')
    OUT.mkdir(parents=True,exist_ok=True)
    payload=json.dumps(data,separators=(',',':'),allow_nan=False)
    (OUT/'sparse.json').write_text(payload+'\n')
    (OUT/'sparse.html').write_text((ROOT/'tools/sparse_viz.html.tpl').read_text().replace('__DATA__',payload.replace('<','\\u003c')))
    verification=dict(scenes=[dict(id=s['id'],mode=s['mode'],outputs=len(s['outputs']),steps=sum(len(o['steps']) for o in s['outputs'])) for s in scenes],
        source_files=len(hashes),recorded_arithmetic_lanes=480,
        data_sha256=hashlib.sha256((OUT/'sparse.json').read_bytes()).hexdigest())
    (OUT/'verification.json').write_text(json.dumps(verification,indent=2)+'\n')
    print(json.dumps(verification,indent=2))


if __name__=='__main__':build()
