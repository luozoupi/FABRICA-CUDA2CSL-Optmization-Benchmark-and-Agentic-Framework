"""Serialized SDK compile/run/disassembly with retained failures and hashes."""
import argparse,fcntl,hashlib,json,os,signal,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parent;SDK=Path('/home/USER/cs_sdk')
sys.path.insert(0,'/home/USER/xkernel-profiling-review-20260924/studies/wse3-characterization/tools')
from csdisasm import parse_am

def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--group',required=True);ap.add_argument('--only',action='append');ap.add_argument('--trace',action='store_true');args=ap.parse_args()
 env=dict(os.environ,OMP_NUM_THREADS='1',OPENBLAS_NUM_THREADS='1')
 for k in ('CSL_SUPPRESS_SIMFAB_TRACE','APPTAINERENV_CSL_SUPPRESS_SIMFAB_TRACE','SINGULARITYENV_CSL_SUPPRESS_SIMFAB_TRACE'):env.pop(k,None)
 if not args.trace:env['APPTAINERENV_CSL_SUPPRESS_SIMFAB_TRACE']='1'
 results=[]
 for d in sorted((ROOT/args.group).iterdir(),key=lambda p: ({'separate_updates':0,'baseline':1,'nested':2}.get(p.name,3),p.name) if args.group=='final' else (0,p.name)):
  if not d.is_dir() or (args.only and d.name not in args.only):continue
  if (d/'result.json').exists():results.append(json.loads((d/'result.json').read_text()));continue
  locks=[open(p,'a') for p in ('/tmp/xkernel_singularity.lock',f'/tmp/xkernel_singularity_{os.getuid()}.lock')];queued=time.monotonic()
  while True:
   held=[]
   try:
    for l in locks:fcntl.flock(l,fcntl.LOCK_EX|fcntl.LOCK_NB);held.append(l)
    break
   except BlockingIOError:
    for l in held:fcntl.flock(l,fcntl.LOCK_UN)
    if time.monotonic()-queued>600:raise TimeoutError('SDK lock wait')
    time.sleep(1)
  result=dict(case=d.name,group=args.group,queue_wait_s=time.monotonic()-queued,phases=[],status='pass',trace_enabled=args.trace)
  try:
   commands=[]
   if not (d/'out').exists():commands.append(('compile',[str(SDK/'cslc'),'layout.csl','--arch=wse3','--fabric-dims=8,3','--fabric-offsets=4,1','--memcpy','--channels=1','--width-west-buf=0','--width-east-buf=0','--out-routes','-o','out']))
   commands.append(('run',[str(SDK/'cs_python'),'host.py']))
   script="import glob,subprocess\np=glob.glob('/cb/toolchains/llvm/cerebras/*/bin/elf2am')[0]\nsubprocess.run([p,'-o=kernel.am','out/bin/out_0_0.elf'],check=True)"
   commands.append(('disassemble',[str(SDK/'cs_python'),'-c',script]))
   for phase,cmd in commands:
    print(args.group,d.name,phase,flush=True);t=time.monotonic()
    with (d/(phase+'.log')).open('w') as log:
     proc=subprocess.Popen(cmd,cwd=d,env=env,stdout=log,stderr=subprocess.STDOUT,start_new_session=True)
     try:rc=proc.wait(timeout=1800 if args.group=='general' else 900 if args.group=='final' else 420)
     except subprocess.TimeoutExpired:
      os.killpg(proc.pid,signal.SIGTERM)
      try:proc.wait(timeout=10)
      except subprocess.TimeoutExpired:os.killpg(proc.pid,signal.SIGKILL);proc.wait()
      rc=124
    result['phases'].append(dict(phase=phase,command=cmd,returncode=rc,wall_s=time.monotonic()-t))
    if rc:result['status']=phase+'_failed';print((d/(phase+'.log')).read_text()[-3000:],flush=True);break
   if result['status']=='pass':
    errors=[l for l in (d/'sim.log').read_text().splitlines() if ' ERROR:' in l or ' FATAL:' in l]
    if errors:result['status']='simulator_diagnostic_failure';result['errors']=errors
    (d/'disassembly.json').write_text(json.dumps({'kernel.am':parse_am(d/'kernel.am')},indent=2)+'\n')
  finally:
   for l in locks:fcntl.flock(l,fcntl.LOCK_UN);l.close()
  result['hashes']={str(p.relative_to(d)):digest(p) for p in d.rglob('*') if p.is_file() and (p.suffix in ('.py','.csl','.json','.elf') or p.name=='kernel.am') and p.name!='result.json'}
  (d/'result.json').write_text(json.dumps(result,indent=2)+'\n');results.append(result)
  (ROOT/(args.group+'-progress.json')).write_text(json.dumps(results,indent=2)+'\n');print(d.name,result['status'],flush=True)
 (ROOT/(args.group+'-progress.json')).write_text(json.dumps(results,indent=2)+'\n')
if __name__=='__main__':main()
