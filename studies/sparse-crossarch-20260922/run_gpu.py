import argparse,hashlib,json,os,subprocess,time
from pathlib import Path
ROOT=Path(__file__).resolve().parent
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def main():
    ap=argparse.ArgumentParser();ap.add_argument('--only');ap.add_argument('--device',default='6');ap.add_argument('--method',default='all');ap.add_argument('--out',default='gpu');ap.add_argument('--manifest',default='inputs/manifest.json');a=ap.parse_args()
    env=dict(os.environ,CUDA_VISIBLE_DEVICES=a.device,OMP_NUM_THREADS='1',OPENBLAS_NUM_THREADS='1')
    manifest=json.loads((ROOT/a.manifest).read_text());build=json.loads((ROOT/'gpu-build.json').read_text());assert build['returncode']==0
    for f,h in build['hashes'].items():assert sha(ROOT/f)==h,f
    out=ROOT/a.out;out.mkdir(exist_ok=True)
    def snapshot(name):
        p=subprocess.run(['nvidia-smi','-i',a.device,'--query-gpu=uuid,name,driver_version,pstate,temperature.gpu,clocks.sm,clocks.mem,power.draw,memory.used,utilization.gpu','--format=csv'],capture_output=True,text=True);(out/name).write_text(p.stdout+p.stderr)
    snapshot('gpu-before.csv');summary=[]
    for case in manifest['cases']:
        if a.only and case['id']!=a.only:continue
        d=out/case['id'];d.mkdir(exist_ok=True)
        if (d/'result.json').exists():summary.append(json.loads((d/'result.json').read_text()));continue
        mat=next(m for m in manifest['matrices']if m['id']==case['matrix_id'])
        for folder,hashes in [(case['matrix_path'],mat['sha256']),(case['dense_path'],case['sha256'])]:
            for f,h in hashes.items():assert sha(ROOT/folder/f)==h
        cmd=[str(ROOT/'gpu-bench'),str(ROOT/case['matrix_path']),str(ROOT/case['dense_path']),*[str(case[k])for k in ('M','K','N','nnz')],str(int(case['synthetic'])),str(d),a.method]
        t=time.monotonic()
        try:p=subprocess.run(cmd,env=env,capture_output=True,text=True,timeout=300);rc=p.returncode;stdout=p.stdout;stderr=p.stderr
        except subprocess.TimeoutExpired as e:rc=124;stdout=(e.stdout or b'').decode();stderr=(e.stderr or b'').decode()
        (d/'stdout.jsonl').write_text(stdout);(d/'stderr.log').write_text(stderr)
        rows=[json.loads(line)for line in stdout.splitlines()if line.startswith('{')]
        result=dict(case=case,command=cmd,device=a.device,returncode=rc,wall_s=time.monotonic()-t,build_sha256=sha(ROOT/'gpu-build.json'),records=rows,output_hashes={p.name:sha(p)for p in d.glob('*.bin')})
        (d/'result.json').write_text(json.dumps(result,indent=2)+'\n');summary.append(result);(out/'summary.json').write_text(json.dumps(summary,indent=2)+'\n')
        print(case['id'],rc,[(r['method'],r['status'])for r in rows if r['type']=='measurement'],flush=True)
    snapshot('gpu-after.csv');(out/'summary.json').write_text(json.dumps(summary,indent=2)+'\n')
if __name__=='__main__':main()
