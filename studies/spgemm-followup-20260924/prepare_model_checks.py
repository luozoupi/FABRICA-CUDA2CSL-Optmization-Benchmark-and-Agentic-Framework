"""Register two new fixed-degree sparse pairs to test the output-emission cost model."""
import datetime,hashlib,json,shutil,sys
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parent
if (ROOT/'model-registration.json').exists():raise RuntimeError('Already registered')
src=ROOT/'general/full_row';obs=json.loads((src/'observations.json').read_text());rows={r['pattern']:r for i,r in enumerate(obs['records']) if i%3==0};banded=rows['banded'];uniform=rows['uniform']
delta=uniform['median_cycles']-banded['median_cycles'];count_delta=uniform['samples'][0]['output_nnz']-banded['samples'][0]['output_nnz'];slope=delta/count_delta;assert slope==25
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
d=ROOT/'model/output_emission';d.mkdir(parents=True)
for f in ('pe.csl','layout.csl'):shutil.copy2(src/f,d/f)
shutil.copytree(src/'out',d/'out')
host=(src/'host.py').read_text().replace('enumerate([False,True,False])','enumerate([False])');start=host.index('  for pattern,limit in ');end=host.index(' finally:',start);host=host[:start]+host[end:];(d/'host.py').write_text(host)
inputs=(src/'inputs.py').read_text()+'''
_original_sparse_pair=sparse_pair
def sparse_pair(pattern,changed=False):
    assert not changed
    A,_=_original_sparse_pair('uniform',False)
    seed={'probe928':928,'probe930':930}[pattern]
    rng=np.random.default_rng(seed);B=np.zeros((16,16),np.float32)
    for row in range(16):
        cols=rng.choice(16,3,replace=False)
        B[row,cols]=rng.choice(np.array([-3,-2,-1,1,2,3],np.float32),3)
    return A,B
'''
(d/'inputs.py').write_text(inputs);cfg=json.loads((src/'case.json').read_text());cfg.update(id='output-emission-model-check',patterns=['probe928','probe930'],phase='model_check',repetitions=3);cfg['source_hashes']={f:sha(d/f) for f in ('pe.csl','layout.csl','host.py','inputs.py')};(d/'case.json').write_text(json.dumps(cfg,indent=2)+'\n')
namespace={};exec(inputs,namespace);pred=[]
for pattern in cfg['patterns']:
 A,B=namespace['sparse_pair'](pattern);S=(A!=0).astype(np.int32)@(B!=0).astype(np.int32);P=int(S.sum());C=int(np.count_nonzero(S));assert P==144
 pred.append(dict(pattern=pattern,input_sha256={name:hashlib.sha256(a.tobytes()).hexdigest() for name,a in [('A',A),('B',B)]},products=P,output_nnz=C,predicted_cycles=uniform['median_cycles']+slope*(C-144)))
reg=dict(created_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),derivation_observations_sha256=sha(src/'observations.json'),base_pattern='uniform',base_cycles=uniform['median_cycles'],base_output_nnz=144,cycles_per_extra_output=slope,
 scope='Conditional model for this fixed ELF, dimensions, A pattern and 3 entries per B row; not universal CSR emission latency. Fresh input seeds fixed before SDK runs.',predictions=pred,elf_sha256=sha(d/'out/bin/out_0_0.elf'),files={str(p.relative_to(ROOT)):sha(p) for p in d.glob('*') if p.is_file()})
(ROOT/'model-registration.json').write_text(json.dumps(reg,indent=2)+'\n');print(json.dumps(pred,indent=2))
