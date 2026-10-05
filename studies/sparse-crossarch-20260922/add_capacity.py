import json,time
from pathlib import Path
import numpy as np
from make_inputs import ROOT,synthetic,dense,save,sha
manifest=dict(schema=1,amendment_sha256=sha(ROOT/'CAPACITY_AMENDMENT.md'),matrices=[],cases=[])
for family in ('uniform8','block8'):
    m=k=262144;a=synthetic(m,k,family);mid=f'{m}x{k}-{family}';d=ROOT/'inputs'/mid;d.mkdir(parents=True,exist_ok=False)
    for name,x in [('row_ptr',a.indptr.astype('<i4')),('col_idx',a.indices.astype('<i4')),('values',a.data.astype('<f4'))]:x.tofile(d/(name+'.bin'))
    lens=np.diff(a.indptr);parts={}
    for pe in (1,4,16,64,256):
        loads=[int(g.sum())for g in np.array_split(lens,pe)];parts[str(pe)]=dict(equal_row_nonzeros=loads,max_over_mean=max(loads)/(a.nnz/pe),ideal_split_row_max_nonzeros=int(np.ceil(a.nnz/pe)))
    manifest['matrices'].append(dict(id=mid,M=m,K=k,nnz=a.nnz,family=family,shared_wse=False,values='synthetic signed small integers',density=a.nnz/(m*k),row_mean=8,row_max=8,empty_rows=0,row_cv=0,partition_predictions=parts,sha256={p.name:sha(p)for p in d.glob('*.bin')}))
    for n in (64,128):
        bd=d/f'n{n}';bd.mkdir();b=dense(k,n);t=time.perf_counter();ref=a.astype(np.float64)@b.astype(np.float64);elapsed=time.perf_counter()-t;b.tofile(bd/'B.bin');ref.tofile(bd/'expected.bin')
        c=dict(id=f'{mid}-n{n}',matrix_id=mid,M=m,K=k,N=n,nnz=a.nnz,shared_wse=False,synthetic=True,family=family,matrix_path=str(d.relative_to(ROOT)),dense_path=str(bd.relative_to(ROOT)),oracle_s=elapsed,sha256={p.name:sha(p)for p in bd.glob('*.bin')});save(bd/'case.json',c);manifest['cases'].append(c)
save(ROOT/'inputs/capacity-manifest.json',manifest);print('Registered 4 cases')
