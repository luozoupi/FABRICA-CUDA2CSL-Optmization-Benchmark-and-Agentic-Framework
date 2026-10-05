"""Register predictions before generating and executing new controlled matrices."""
import datetime
import hashlib
import json
from pathlib import Path
import shutil
import numpy as np
ROOT=Path(__file__).resolve().parent
predictions=[]
for name,base,slope in [('descriptor-n1',11429,-3),('scalar-n4',18044,45)]:
    for nonempty in (8,16):
        predictions.append(dict(case=name,nonempty_rows=nonempty,rows=32,nnz=256,
                                predicted_cycles=base+slope*(nonempty-32)))
registration=dict(created_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
    hypothesis='At fixed dimensions, nnz and output width, measured row-control and setup gaps predict a linear dependence on nonempty rows for these compiled simulator kernels.',
    calibration_inputs=['uniform8: 32 nonempty rows','skew8: 4 nonempty rows'],
    calibrated_models={'descriptor-n1':'11429 - 3*(nonempty_rows - 32)',
                       'scalar-n4':'18044 + 45*(nonempty_rows - 32)'},
    predictions=predictions,acceptance='All correct launches match the preregistered predicted cycle count exactly; otherwise retain discrepancy and revise only in a new experiment.',
    launches=48,warmups_per_session=1,timed_repetitions_per_session=3,
    sessions=['original','changed values/indices/dense operand','restore original'],
    scope='New controlled validation matrices; not real-matrix generalization, hardware validation, or final-test matrices for the agent study.')
(ROOT/'model-check-registration.json').write_text(json.dumps(registration,indent=2)+'\n')
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
for name in ('descriptor-n1','scalar-n4'):
    old=ROOT/'cases'/name; d=ROOT/'model-checks'/name; d.mkdir(parents=True)
    cfg=json.loads((old/'case.json').read_text()); cfg['inputs']=[]
    for f in ('pe.csl','layout.csl','host.py'):shutil.copy2(old/f,d/f)
    shutil.copytree(old/'out',d/'out'); n=cfg['N'];k=cfg['K']
    src=old/'inputs'/f'32x64-uniform8-n{n}'
    values=np.fromfile(src/'values.bin',np.float32); dense=np.fromfile(src/'B.bin',np.float32).reshape(k,n)
    for nonempty in (8,16):
        rowsize=256//nonempty
        rp=np.r_[np.arange(nonempty+1)*rowsize,np.full(32-nonempty,256)].astype(np.uint32)
        ix=np.concatenate([(5*r+3*np.arange(rowsize))%k for r in range(nonempty)]).astype(np.uint32)
        expected=np.zeros((32,n),np.float64)
        for row in range(32):
            a,b=rp[row:row+2];expected[row]=(values[a:b,None].astype(np.float64)*dense[ix[a:b]].astype(np.float64)).sum(axis=0)
        identifier=f'32x64-nnz256-nonempty{nonempty}-n{n}';inp=d/'inputs'/identifier;inp.mkdir(parents=True)
        for filename,array in [('row_ptr.bin',rp),('col_idx.bin',ix),('values.bin',values),('B.bin',dense),('expected.bin',expected)]:array.tofile(inp/filename)
        cfg['inputs'].append(dict(id=identifier,family=f'nonempty{nonempty}',input_hashes={p.name:sha(p) for p in inp.iterdir()},nonempty_rows=nonempty))
    (d/'case.json').write_text(json.dumps(cfg,indent=2)+'\n')
    (d/'elf-binding.json').write_text(json.dumps(dict(original=str(old),elf_sha256={str(p.relative_to(old/'out')):sha(p) for p in (old/'out').rglob('*.elf')}),indent=2)+'\n')
print('Registered model predictions before execution:',predictions)
