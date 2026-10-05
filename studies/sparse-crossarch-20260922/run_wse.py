import argparse,fcntl,hashlib,json,os,re,subprocess,time
from pathlib import Path
ROOT=Path(__file__).resolve().parent
SDK=Path(os.environ.get('CEREBRAS_SDK_DIR',str(ROOT.parent/'cs_sdk'))).expanduser()
def main():
    if (ROOT/'packaging-manifest.json').exists():
        raise RuntimeError('Preserve the recorded study: use prepare_replay.py in a new directory')
    ap=argparse.ArgumentParser();ap.add_argument('--only');args=ap.parse_args();results=[]
    env=dict(os.environ,CSL_SUPPRESS_SIMFAB_TRACE='1',APPTAINERENV_CSL_SUPPRESS_SIMFAB_TRACE='1',OMP_NUM_THREADS='1',OPENBLAS_NUM_THREADS='1')
    for d in sorted((ROOT/'wse').iterdir()):
        if args.only and d.name!=args.only:continue
        if (d/'acceptance.json').exists():results.append(json.loads((d/'acceptance.json').read_text()));continue
        result=dict(id=d.name,status='pass',phases=[]);t=time.monotonic()
        with open('/tmp/xkernel_singularity.lock','a')as lock:
            fcntl.flock(lock,fcntl.LOCK_EX);result['queue_wait_s']=time.monotonic()-t
            for phase,cmd in [('compile',[str(SDK/'cslc'),'layout.csl','--arch=wse3','--fabric-dims=8,3','--fabric-offsets=4,1','--memcpy','--channels=1','--width-west-buf=0','--width-east-buf=0','--out-routes','-o','out']),('run',[str(SDK/'cs_python'),'host.py'])]:
                print(d.name,phase,flush=True);t=time.monotonic()
                with open(d/(phase+'.log'),'w')as log:
                    try:rc=subprocess.run(cmd,cwd=d,env=env,stdout=log,stderr=subprocess.STDOUT,timeout=360).returncode
                    except subprocess.TimeoutExpired:rc=124
                result['phases'].append(dict(phase=phase,cmd=cmd,rc=rc,wall_s=time.monotonic()-t))
                errors=re.findall(r'^.*(?:\bERROR\b|\bFATAL\b).*$',(d/(phase+'.log')).read_text(),re.M)
                if rc or errors:result.update(status=phase+'_failed',errors=errors[:10]);break
        if result['status']=='pass':
            obs=json.loads((d/'observations.json').read_text());assert obs['status']=='pass';result['checked_launches']=sum(len(r['samples'])for r in obs['records'])
        result['hashes']={str(p.relative_to(d)):hashlib.sha256(p.read_bytes()).hexdigest()for p in d.rglob('*')if p.is_file()and p.suffix in ('.csl','.py','.elf','.json','.bin')}
        (d/'acceptance.json').write_text(json.dumps(result,indent=2)+'\n');results.append(result);(ROOT/'wse-summary.json').write_text(json.dumps(results,indent=2)+'\n');print(d.name,result['status'],flush=True)
    (ROOT/'wse-summary.json').write_text(json.dumps(results,indent=2)+'\n')
if __name__=='__main__':main()
