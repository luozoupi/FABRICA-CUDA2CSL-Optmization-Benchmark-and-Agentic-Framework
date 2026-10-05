"""Build tables without mixing GPU microseconds and WSE simulator cycles."""
import csv,hashlib,json,math,statistics,struct
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parent
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def stats(x):return dict(median=statistics.median(x),min=min(x),max=max(x),samples=x)
def elf_text(p):
    b=p.read_bytes();assert b[:4]==b'\x7fELF' and b[5]==1
    if b[4]==1:off=struct.unpack_from('<I',b,32)[0];size,num,names=struct.unpack_from('<HHH',b,46);fmt='<IIIIIIIIII'
    else:off=struct.unpack_from('<Q',b,40)[0];size,num,names=struct.unpack_from('<HHH',b,58);fmt='<IIQQQQIIQQ'
    sections=[struct.unpack_from(fmt,b,off+i*size)for i in range(num)];s=sections[names];strings=b[s[4]:s[4]+s[5]]
    for s in sections:
        if strings[s[0]:].split(b'\0')[0]==b'.text':return dict(text_bytes=s[5],text_sha256=hashlib.sha256(b[s[4]:s[4]+s[5]]).hexdigest(),elf_sha256=sha(p))
    raise ValueError('no text')
def main():
    manifests=[json.loads((ROOT/'inputs'/f).read_text())for f in ('manifest.json','capacity-manifest.json')if(ROOT/'inputs'/f).exists()]
    cases=[c for m in manifests for c in m['cases']];matrices=[a for m in manifests for a in m['matrices']];gpus=[];wse=[];builds=[];failure=[]
    for directory in ('gpu','gpu-capacity','gpu-replay1','gpu-replay2'):
        for p in sorted((ROOT/directory).glob('*/result.json')):
            raw=json.loads(p.read_text());c=raw['case']
            for r in raw['records']:
                if r.get('type')!='measurement':continue
                row=dict(case=c['id'],M=c['M'],K=c['K'],N=c['N'],nnz=c['nnz'],family=c['family'],batch=directory,**r)
                if r['status']=='pass':
                    row['single']=stats(r['single_us']);row['graph']=stats(r['graph_us']);row['effective_gflops']=2*c['nnz']*c['N']/(row['graph']['median']*1000)
                    row['prepared_device_reuse_us']={str(n):r['preprocess_device_us']+n*row['graph']['median']for n in (1,10,100)}
                else:failure.append(row)
                gpus.append(row)
    for p in sorted((ROOT/'wse').glob('*/case.json')):
        c=json.loads(p.read_text());ac=p.parent/'acceptance.json';a=json.loads(ac.read_text())if ac.exists()else dict(status='pending')
        compiled=list((p.parent/'out/bin').glob('*.elf'));build=dict(id=c['id'],status=a['status'],variant=c['variant'],N=c['N'],compiled=bool(compiled))
        if compiled:build.update(elf_text(compiled[0]))
        if any(v['rc']==124 for v in a.get('phases',[])):build['failure_reason']='360-second host wall-time limit; not a correctness or memory-capacity verdict'
        builds.append(build)
        if a['status']!='pass':continue
        obs=json.loads((p.parent/'observations.json').read_text())
        for cid in sorted(set(v['input_id']for v in obs['records'])):
            rec=[v for v in obs['records']if v['input_id']==cid and not v['changed']];vals=[s['cycles']for v in rec for s in v['samples']if not s['warmup']]
            wse.append(dict(case=cid,variant=c['variant'],N=c['N'],cycles=stats(vals),build=c['id'],validated_sessions=3,checked_launches=12))
    comparisons=[]
    for c in cases:
        group=[r for r in gpus if r['case']==c['id']and r['batch']in ('gpu','gpu-capacity')and r['status']=='pass']
        ge=[r for r in group if r['method']in ('ge_cache','ge_merge2','ge_merge4')];cu=[r for r in group if r['method'].startswith('cusparse')]
        if not ge or not cu:continue
        g=min(ge,key=lambda r:r['graph']['median']);v=min(cu,key=lambda r:r['graph']['median'])
        comparisons.append(dict(case=c['id'],best_ge=g['method'],ge_us=g['graph']['median'],best_cusparse=v['method'],cusparse_us=v['graph']['median'],cusparse_over_ge=v['graph']['median']/g['graph']['median']))
    examples=[]
    for c in cases:
        if not c['shared_wse']:continue
        d=ROOT/c['matrix_path'];dd=ROOT/c['dense_path']
        examples.append(dict(case=c['id'],M=c['M'],K=c['K'],N=c['N'],row_ptr=np.fromfile(d/'row_ptr.bin',np.int32).tolist(),col_idx=np.fromfile(d/'col_idx.bin',np.int32).tolist(),values=np.fromfile(d/'values.bin',np.float32).tolist(),B=np.fromfile(dd/'B.bin',np.float32).reshape(c['K'],c['N']).tolist(),expected=np.fromfile(dd/'expected.bin',np.float64).reshape(c['M'],c['N']).tolist()))
    result=dict(schema=1,cases=cases,matrices=matrices,gpu=gpus,wse=wse,wse_builds=builds,comparisons=comparisons,failures=failure,examples=examples,partition=json.loads((ROOT/'partition-analysis.json').read_text()),scope='GPU: measured warm CUDA graph per-operation latency. WSE: single-PE resident simulator cycles. Never form a GPU/WSE latency ratio.',counts=dict(gpu_cases=len(cases),gpu_primary_accepted=sum(r['status']=='pass'and r['batch']in ('gpu','gpu-capacity')for r in gpus),gpu_primary_rejected=sum(r['status']!='pass'and r['batch']in ('gpu','gpu-capacity')for r in gpus),wse_passed=sum(b['status']=='pass'for b in builds),wse_total=len(builds),ge_faster_over_5pct=sum(c['cusparse_over_ge']>1.05 for c in comparisons),cusparse_faster_over_5pct=sum(c['cusparse_over_ge']<1/1.05 for c in comparisons),matched_gpu_comparisons=len(comparisons)))
    (ROOT/'results.json').write_text(json.dumps(result,indent=2)+'\n')
    columns=['case','method','batch','status','graph_us_median','graph_us_min','graph_us_max','single_us_median','preprocess_device_us','graph_build_wall_us','effective_gflops','reason']
    with (ROOT/'gpu-results.csv').open('w')as f:
        writer=csv.DictWriter(f,fieldnames=columns);writer.writeheader()
        for r in gpus:
            row={k:r[k]for k in columns if k in r}
            if r['status']=='pass':row.update(graph_us_median=r['graph']['median'],graph_us_min=r['graph']['min'],graph_us_max=r['graph']['max'],single_us_median=r['single']['median'])
            writer.writerow(row)
    with (ROOT/'wse-results.csv').open('w')as f:
        writer=csv.writer(f);writer.writerow(['case','variant','median_cycles','min_cycles','max_cycles'])
        for r in wse:writer.writerow([r['case'],r['variant'],r['cycles']['median'],r['cycles']['min'],r['cycles']['max']])
    print(json.dumps(result['counts']))
if __name__=='__main__':main()
