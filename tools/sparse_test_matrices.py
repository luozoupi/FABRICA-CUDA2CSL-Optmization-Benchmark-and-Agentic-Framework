#!/usr/bin/env python3
"""Freeze controlled final-test matrices outside agent-visible input bundles.

These stress cases supplement real application matrices; they do not substitute
for the still-required application selection or establish scaling performance.
"""
import argparse,json,sys,shutil,re,hashlib
from pathlib import Path
import numpy as np
import yaml
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'code_translation'));sys.path.insert(0,str(ROOT/'tools'))
import sparse_inputs as si
from sparse_study import sha,save

def cases(n,m,limit):
    seed=89173;k=max(1,min(3,limit//n,m))
    values=[('banded',si.banded(n,0,seed,m=m)),
            ('uniform',si.uniform_random(n,seed,m=m,nnz_per_row=k)),
            ('blocks',si.block_diagonal(min(n,m),min(k,3),seed,fill=1.0))]
    # Empty rows, one long row, explicit zero, cancellation and entries well away
    # from the dominant diagonal. All positions are unique and indices valid.
    width=min(m,max(1,limit//2));cols=list(range(width));rows=[n//2]*width
    for r in range(0,n,7):
        c=(r+m//2)%m
        if r!=n//2:rows.append(r);cols.append(c)
    count=min(len(rows),limit);v=np.where(np.arange(count)%2==0,1.0,-1.0);v[0]=0
    values.append(('long_empty_irregular',si.from_coo(n,m,rows[:count],cols[:count],v)))
    for name,c in values:
        if c.nnz>limit:raise ValueError('Controlled matrix exceeds global capacity')
        yield name,c

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--study',type=Path,required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--include-real',action='store_true');a=p.parse_args()
    manifest=json.loads((a.study/'inputs/manifest.json').read_text());a.out.mkdir(parents=True,exist_ok=False);rows=[]
    for name,spec in manifest['tasks'].items():
        bundle=Path(spec['reference_csl_dir']);ks=yaml.safe_load((bundle.parent/'spec.yaml').read_text());params=next(s['params'] for s in ks['sizes'] if s['name']=='small')
        side=int(params.get('P',1));local=int(params.get('nrows_pe',params.get('Mt',params.get('nrows',params.get('n',0)))))
        n=side*local;m=int(params.get('ncols',params.get('K',params.get('n',n))))
        cap=int(params.get('max_nnz_pe',params.get('max_nnz',0)))
        # Limit total to one PE's capacity too, so the long row remains feasible
        # regardless of where the row partition boundary falls.
        for family,csr in cases(n,m,cap):
            rel=Path(name)/(family+'.mtx');path=a.out/rel;path.parent.mkdir(parents=True,exist_ok=True)
            si.write_mtx(path,csr,comment='Generated controlled final-test matrix; values are synthetic.')
            rows.append(dict(kernel=name,id='controlled/'+name+'/'+family,path=str(rel),sha256=sha(path),partition='final_test',values='original',value_provenance='generated and stored in Matrix Market',family=family,n=csr.n,m=csr.m,nnz=csr.nnz,row_length_max=int(np.diff(csr.row_ptr).max()),row_length_cv=float(np.std(np.diff(csr.row_ptr))/max(np.mean(np.diff(csr.row_ptr)),1e-30))))
    if a.include_real:
        choices={name:['bcspwr04','dwt_245','nos4'] for name in ('RowScale-CSR','ColScale-CSR','RowReduce-CSR')}
        choices.update({'SpMV-CSR':['ibm32','pores_1'],'SpMV-RowBlock':['orsirr_2','nos6','jagmesh2'],
                        'SpMM-CSR-Dense':['dwt_245','nos4','bcsstk01'],'SpGEMM-Masked-Dot':['dwt_245','nos4','bcsstk01']})
        def pattern(c):
            h=hashlib.sha256(str((c.n,c.m)).encode());h.update(c.row_ptr.astype('<i8').tobytes());h.update(c.col.astype('<i8').tobytes());return h.hexdigest()
        development={pattern(si.read_mtx(a.study/'inputs'/p)) for p in manifest['sha256'] if p.endswith('.mtx')}
        for name,ids in choices.items():
            bundle=Path(manifest['tasks'][name]['reference_csl_dir']);ks=yaml.safe_load((bundle.parent/'spec.yaml').read_text());params=next(s['params'] for s in ks['sizes'] if s['name']=='small')
            side=int(params.get('P',1));local=int(params.get('nrows_pe',params.get('Mt',params.get('nrows',params.get('n',0)))))
            columns=int(params.get('ncols',params.get('K',params.get('n',side*local))));cap=int(params.get('max_nnz_pe',params.get('max_nnz',0)))
            for mid in ids:
                src=ROOT/'kernels/_sparse_data'/(mid+'.mtx');csr=si.read_mtx(src)
                if pattern(csr) in development:raise RuntimeError('Real test matrix overlaps development: '+mid)
                assert csr.n<=side*local and csr.m<=columns
                assert all(part.nnz<=cap for part in si.partition_row_block(csr,side,local))
                rel=Path(name)/(mid+'.mtx');shutil.copy2(src,a.out/rel)
                header=src.read_text().splitlines()[:15];kind=next((x.split(':',1)[1].strip() for x in header if x.startswith('% kind:')),'not supplied')
                pattern_only=' pattern ' in header[0]
                lens=np.diff(csr.row_ptr)
                rows.append(dict(kernel=name,id='HB/'+mid,path=str(rel),sha256=sha(src),partition='final_test',values='original',
                                 value_provenance='unit values for pattern-only source' if pattern_only else 'original source values',
                                 family='real',application=kind,source_url='https://sparse.tamu.edu/HB/'+mid,
                                 n=csr.n,m=csr.m,nnz=csr.nnz,row_length_max=int(lens.max()),row_length_cv=float(lens.std()/max(lens.mean(),1e-30))))
    save(a.out/'manifest.json',dict(schema='xkernel.final_test_matrices/1',framework_commit=manifest['source_commit'],
        selection_rule='Named application matrices not used in any frozen development bundle; check full sparsity-pattern disjointness and fixed capacities; no speed-based selection. Small 32-row SpMV has two real tests.',
        scope='registered small-size final test; larger scaling inputs are a separate experiment version',matrices=rows))
    print(json.dumps(dict(matrices=len(rows),manifest=str(a.out/'manifest.json'),sha256=sha(a.out/'manifest.json'))))

if __name__=='__main__':main()
