"""Independent saved-output and provenance audit; uses SciPy sparse FP64 oracle."""
import hashlib,json
from pathlib import Path
import numpy as np
import scipy.sparse as sp
ROOT=Path(__file__).resolve().parent
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def main():
    manifests=[json.loads((ROOT/'inputs/manifest.json').read_text())]
    if (ROOT/'inputs/capacity-manifest.json').exists():manifests.append(json.loads((ROOT/'inputs/capacity-manifest.json').read_text()))
    cases={c['id']:c for mf in manifests for c in mf['cases']};gpu_cases=0;gpu_methods=0;gpu_checks=0;failures=[];wse_builds=0;wse_checks=0
    for mf in manifests:
        for mat in mf['matrices']:
            for f,h in mat['sha256'].items():assert sha(ROOT/'inputs'/mat['id']/f)==h
    for directory in ('gpu','gpu-capacity','gpu-replay1','gpu-replay2'):
        for result in sorted((ROOT/directory).glob('*/result.json')):
            r=json.loads(result.read_text());c=cases[r['case']['id']];m,k,n=c['M'],c['K'],c['N'];d=ROOT/c['matrix_path'];bpath=ROOT/c['dense_path'];gpu_cases+=1
            for f,h in c['sha256'].items():assert sha(bpath/f)==h
            for f,h in r['output_hashes'].items():assert sha(result.parent/f)==h
            assert r['returncode']==0
            rp=np.fromfile(d/'row_ptr.bin',np.int32);ix=np.fromfile(d/'col_idx.bin',np.int32);av=np.fromfile(d/'values.bin',np.float32);b=np.fromfile(bpath/'B.bin',np.float32).reshape(k,n)
            passed=[v for v in r['records']if v.get('type')=='measurement'and v['status']=='pass'];gpu_methods+=len(passed)
            failures +=[dict(case=c['id'],**v)for v in r['records']if v.get('type')=='measurement'and v['status']!='pass']
            for session in range(3):
                v=-2*av if session else av;bb=b+1 if session else b;col=(ix+17)%k if session==2 else ix
                a=sp.csr_matrix((v.astype(np.float64),col,rp),shape=(m,k));ref=a@bb.astype(np.float64)
                if session==0:np.testing.assert_array_equal(ref,np.fromfile(bpath/'expected.bin',np.float64).reshape(m,n))
                for method in passed:
                    out=np.fromfile(result.parent/f'{method["method"]}-session{session}.bin',np.float32).reshape(m,n)
                    assert np.isfinite(out).all();assert np.all(np.abs(out-ref)<=5e-5+5e-5*np.abs(ref))
                    if c['synthetic']:np.testing.assert_array_equal(out,ref)
                    gpu_checks+=1
    for p in sorted((ROOT/'wse').glob('*/acceptance.json')):
        ac=json.loads(p.read_text())
        if ac['status']!='pass':failures.append(dict(wse=p.parent.name,status=ac['status']));continue
        for f,h in ac['hashes'].items():assert sha(p.parent/f)==h,(p.parent.name,f)
        x=json.loads((p.parent/'observations.json').read_text());wse_builds+=1
        for record in x['records']:
            c=cases[record['input_id']];n=c['N'];d=ROOT/c['matrix_path'];dd=ROOT/c['dense_path'];rp=np.fromfile(d/'row_ptr.bin',np.int32);ix=np.fromfile(d/'col_idx.bin',np.int32);av=np.fromfile(d/'values.bin',np.float32);b=np.fromfile(dd/'B.bin',np.float32).reshape(c['K'],n)
            if record['changed']:ix=(ix+17)%c['K'];av=-2*av;b=b+1
            a=sp.csr_matrix((av.astype(np.float64),ix,rp),shape=(c['M'],c['K']));ref=a@b.astype(np.float64)
            out=np.fromfile(p.parent/'inputs'/c['id']/f'output-session{record["session"]}.bin',np.float32).reshape(c['M'],n);np.testing.assert_array_equal(out,ref)
            for s in record['samples']:assert s['cycles']==s['end']-s['start']>0;assert s['correct'];wse_checks+=1
        for phase in ('compile','run'):
            import re
            assert not re.search(r'\b(ERROR|FATAL)\b',(p.parent/(phase+'.log')).read_text())
    result=dict(status='pass',gpu_cases=gpu_cases,gpu_accepted_methods=gpu_methods,gpu_independent_output_checks=gpu_checks,wse_builds=wse_builds,wse_checked_launches=wse_checks,retained_failures=failures,input_manifest_hashes={f:sha(ROOT/f)for f in ['inputs/manifest.json','inputs/capacity-manifest.json']if(ROOT/f).exists()})
    (ROOT/'audit.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))
if __name__=='__main__':main()
