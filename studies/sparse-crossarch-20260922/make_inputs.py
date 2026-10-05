"""Generate and freeze matched CSR inputs; no model or optimizer is involved."""
import hashlib,json,shutil,sys,time
from pathlib import Path
import numpy as np
import scipy.sparse as sp
from scipy.io import mmread
ROOT=Path(__file__).resolve().parent
FAMILIES=['uniform2','uniform8','uniform32','banded8','block8','skew8']
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def save(p,x):Path(p).write_text(json.dumps(x,indent=2)+'\n')
def synthetic(m,k,family):
    degree=int(family.removeprefix('uniform')) if family.startswith('uniform') else 8
    lens=np.full(m,degree,dtype=np.int32)
    if family=='skew8':lens[:]=0;lens[:m//8]=64
    ptr=np.r_[0,np.cumsum(lens)].astype(np.int32)
    # For power-of-two column counts, an odd multiplier generates unique columns.
    rows=np.repeat(np.arange(m,dtype=np.int64),lens)
    pos=np.arange(int(ptr[-1]))-np.repeat(ptr[:-1],lens)
    if family.startswith('uniform') or family=='skew8':
        h=(rows*1103515245+12345)&0x7fffffff
        ix=((h%k)+pos*((h//k)%k|1))%k
    elif family=='banded8':ix=(rows+pos-3)%k
    else:ix=((rows//8*8)%k)+pos
    v=(((rows*3+ix*5+1)%7)-3).astype(np.float32);v[v==0]=1
    a=sp.csr_matrix((v,ix.astype(np.int32),ptr),shape=(m,k));a.sort_indices()
    assert a.nnz==int(lens.sum()) and a.has_canonical_format
    return a
def dense(k,n):
    r=np.arange(k,dtype=np.int64)[:,None];c=np.arange(n,dtype=np.int64)[None,:]
    return (((r*3+c*2)%7)-3).astype(np.float32)
def main():
    if (ROOT/'inputs/manifest.json').exists():raise RuntimeError('Inputs already frozen')
    matrices=[];cases=[]
    specs=[(32,64,f,True)for f in FAMILIES]
    specs += [(m,m,f,False)for m in (4096,65536)for f in FAMILIES]
    specs += [(m,k,'uniform8',False)for m,k in ((4096,65536),(65536,4096))]
    def add(mid,a,widths,shared,family,provenance):
        d=ROOT/'inputs'/mid;d.mkdir(parents=True)
        a=a.tocsr();a.sum_duplicates();a.sort_indices();a.data=a.data.astype(np.float32)
        rp=a.indptr.astype('<i4');ci=a.indices.astype('<i4');av=a.data.astype('<f4')
        for name,x in [('row_ptr',rp),('col_idx',ci),('values',av)]:x.tofile(d/(name+'.bin'))
        lens=np.diff(rp);m,k=a.shape
        parts={}
        for pe in (1,4,16,64,256):
            groups=np.array_split(lens,pe);loads=[int(g.sum())for g in groups]
            parts[str(pe)]=dict(equal_row_nonzeros=loads,max_over_mean=max(loads)/(a.nnz/pe),ideal_split_row_max_nonzeros=int(np.ceil(a.nnz/pe)))
        mat=dict(id=mid,M=m,K=k,nnz=a.nnz,family=family,shared_wse=shared,values=provenance,density=a.nnz/(m*k),row_mean=float(lens.mean()),row_max=int(lens.max()),empty_rows=int((lens==0).sum()),row_cv=float(lens.std()/lens.mean()),partition_predictions=parts)
        mat['sha256']={p.name:sha(p)for p in d.glob('*.bin')};matrices.append(mat)
        for n in widths:
            bd=d/f'n{n}';bd.mkdir();b=dense(k,n);t=time.perf_counter();ref=a.astype(np.float64)@b.astype(np.float64);oracle_s=time.perf_counter()-t
            b.tofile(bd/'B.bin');ref.tofile(bd/'expected.bin')
            case=dict(id=f'{mid}-n{n}',matrix_id=mid,M=m,K=k,N=n,nnz=a.nnz,shared_wse=shared,synthetic=family!='real',family=family,matrix_path=str(d.relative_to(ROOT)),dense_path=str(bd.relative_to(ROOT)),oracle_s=oracle_s,sha256={p.name:sha(p)for p in bd.glob('*.bin')})
            save(bd/'case.json',case);cases.append(case)
    for m,k,f,shared in specs:add(f'{m}x{k}-{f}',synthetic(m,k,f),[1,4,16,64]if shared else [1,16,64]if m!=k else [1,4,16,32,64,128],shared,f,'synthetic signed small integers')
    for name in ('sherman1','bcspwr09','bcsstk08'):
        p=ROOT/'sources'/f'{name}.mtx'
        # The repository package retains the original Matrix Market sources here.
        add('HB-'+name,mmread(p),[1,4,16,32,64,128],False,'real',dict(source='https://sparse.tamu.edu/HB/'+name,sha256=sha(p),conversion='Matrix Market symmetry expanded, duplicates summed, original numeric values rounded to FP32'))
    save(ROOT/'inputs/manifest.json',dict(schema=1,matrices=matrices,cases=cases,protocol_sha256=sha(ROOT/'PROTOCOL.md')))
    print(len(matrices),'matrices;',len(cases),'width cases')
if __name__=='__main__':main()
