"""Serialize SDK experiments; preserve every attempt and bounded resource usage."""
import argparse,fcntl,hashlib,json,os,signal,subprocess,time
from pathlib import Path
ROOT=Path(__file__).resolve().parent;SDK=Path('/home/USER/cs_sdk')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(d):
 if (d/'result.json').exists():return json.loads((d/'result.json').read_text())
 c=json.loads((d/'case.json').read_text());result=dict(case=c['id'],status='running',phases=[],case_sha256=sha(d/'case.json'))
 if c['preflight']!='compile_required':
  result.update(status='capacity_excluded',reason=c['preflight'],declared_application_bytes=c['declared_application_bytes']);(d/'result.json').write_text(json.dumps(result,indent=2)+'\n');return result
 locks=[open(x,'a')for x in ('/tmp/xkernel_singularity.lock',f'/tmp/xkernel_singularity_{os.getuid()}.lock')];q=time.monotonic()
 while True:
  held=[]
  try:
   for lock in locks:fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB);held.append(lock)
   break
  except BlockingIOError:
   for lock in held:fcntl.flock(lock,fcntl.LOCK_UN)
   if time.monotonic()-q>600:raise TimeoutError('simulator queue wait')
   time.sleep(1)
 result['queue_wait_seconds']=time.monotonic()-q
 env=dict(os.environ,OMP_NUM_THREADS='1',OPENBLAS_NUM_THREADS='1',APPTAINERENV_CSL_SUPPRESS_SIMFAB_TRACE='1')
 commands=[]
 params=','.join(f'{k}:{c[k]}'for k in ('S','N','K','R','AC','BC','OC','W'))
 commands.append(('compile',[str(SDK/'cslc'),'layout.csl','--arch=wse3',f'--fabric-dims={c["S"]+7},{c["S"]+2}','--fabric-offsets=4,1','--memcpy','--channels=1','--width-west-buf=0','--width-east-buf=0','--out-routes','--params='+params,'-o','out'],600))
 commands.append(('run',[str(SDK/'cs_python'),'host.py'],2400))
 try:
  for phase,cmd,limit in commands:
   print(c['id'],phase,flush=True);start=time.monotonic()
   with (d/(phase+'.log')).open('w')as log:
    proc=subprocess.Popen(cmd,cwd=d,env=env,stdout=log,stderr=subprocess.STDOUT,start_new_session=True)
    try:rc=proc.wait(timeout=limit)
    except subprocess.TimeoutExpired:
     os.killpg(proc.pid,signal.SIGTERM)
     try:proc.wait(timeout=10)
     except subprocess.TimeoutExpired:os.killpg(proc.pid,signal.SIGKILL);proc.wait()
     rc=124
   result['phases'].append(dict(phase=phase,command=cmd,returncode=rc,wall_seconds=time.monotonic()-start))
   if rc:result['status']=phase+'_failed';print((d/(phase+'.log')).read_text()[-1600:],flush=True);break
  else:
   obs=json.loads((d/'observations.json').read_text());assert obs['status']=='pass'
   errors=[line for line in (d/'sim.log').read_text().splitlines()if ' ERROR:'in line or ' FATAL:'in line]
   result['status']='simulator_diagnostic_failure' if errors else 'pass';result['errors']=errors
 finally:
  for lock in locks:fcntl.flock(lock,fcntl.LOCK_UN);lock.close()
 result['elf_sha256']={str(p.relative_to(d)):sha(p)for p in d.rglob('*.elf')}
 result['source_sha256']={p.name:sha(p)for p in d.iterdir()if p.suffix in ('.py','.csl','.json')and p.name not in ('result.json','observations.partial.json')}
 (d/'result.json').write_text(json.dumps(result,indent=2)+'\n');print(c['id'],result['status'],flush=True);return result

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--development',action='store_true');ap.add_argument('--only',action='append');args=ap.parse_args()
 group=ROOT/('development'if args.development else 'cases');results=[]
 dirs=sorted(group.iterdir(),key=lambda p:(json.loads((p/'case.json').read_text())['N'],json.loads((p/'case.json').read_text())['P'],p.name))
 for d in dirs:
  if args.only and d.name not in args.only:continue
  results.append(run(d));(ROOT/('development-progress.json'if args.development else 'progress.json')).write_text(json.dumps(results,indent=2)+'\n')
if __name__=='__main__':main()
