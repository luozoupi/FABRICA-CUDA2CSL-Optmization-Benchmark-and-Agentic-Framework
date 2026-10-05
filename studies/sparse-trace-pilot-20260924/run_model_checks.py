"""Test preregistered simulator predictions without recompiling the measured ELF."""
import fcntl
import hashlib
import json
import os
from pathlib import Path
import signal
import subprocess
import time
ROOT=Path(__file__).resolve().parent
registration=json.loads((ROOT/'model-check-registration.json').read_text())
registration_hash=hashlib.sha256((ROOT/'model-check-registration.json').read_bytes()).hexdigest()
env=dict(os.environ,OMP_NUM_THREADS='1',OPENBLAS_NUM_THREADS='1',CSL_SUPPRESS_SIMFAB_TRACE='1',APPTAINERENV_CSL_SUPPRESS_SIMFAB_TRACE='1',SINGULARITYENV_CSL_SUPPRESS_SIMFAB_TRACE='1')
results=[]
for name in ('descriptor-n1','scalar-n4'):
 d=ROOT/'model-checks'/name
 if (d/'validation-result.json').exists():raise RuntimeError('Preserve prior model validation; use a new version for reruns')
 binding=json.loads((d/'elf-binding.json').read_text())
 for rel,h in binding['elf_sha256'].items():
  assert hashlib.sha256((d/'out'/rel).read_bytes()).hexdigest()==h
 handles=[open(p,'a') for p in ('/tmp/xkernel_singularity.lock',f'/tmp/xkernel_singularity_{os.getuid()}.lock')]
 queued=time.monotonic()
 while True:
  acquired=[]
  try:
   for h in handles:fcntl.flock(h,fcntl.LOCK_EX|fcntl.LOCK_NB);acquired.append(h)
   break
  except BlockingIOError:
   for h in acquired:fcntl.flock(h,fcntl.LOCK_UN)
   if time.monotonic()-queued>600:raise TimeoutError('SDK locks occupied')
   time.sleep(1)
 queue_wait=time.monotonic()-queued;t=time.monotonic();print(name,'model checks starting',flush=True)
 try:
  with open(d/'run.log','w') as log:
   proc=subprocess.Popen(['/home/USER/cs_sdk/cs_python','host.py'],cwd=d,env=env,stdout=log,stderr=subprocess.STDOUT,start_new_session=True)
   try:rc=proc.wait(timeout=240)
   except subprocess.TimeoutExpired:
    os.killpg(proc.pid,signal.SIGTERM)
    try:proc.wait(timeout=10)
    except subprocess.TimeoutExpired:os.killpg(proc.pid,signal.SIGKILL);proc.wait()
    rc=124
 finally:
  for h in handles:fcntl.flock(h,fcntl.LOCK_UN);h.close()
 errors=[line for line in (d/'sim.log').read_text().splitlines() if ' ERROR:' in line or ' FATAL:' in line] if (d/'sim.log').exists() else ['missing sim.log']
 result=dict(case=name,returncode=rc,queue_wait_s=queue_wait,execution_s=time.monotonic()-t,numerical_pass=rc==0 and not errors,diagnostic_errors=errors,registration_sha256=registration_hash)
 if result['numerical_pass']:
  obs=json.loads((d/'observations.json').read_text());configs={c['id']:c for c in obs['case']['inputs']};cells=[]
  for p in registration['predictions']:
   if p['case']!=name:continue
   records=[r for r in obs['records'] if configs[r['input_id']]['nonempty_rows']==p['nonempty_rows']]
   samples=[s for r in records for s in r['samples']];assert len(samples)==12 and all(s['correct'] for s in samples)
   measured=sorted({s['cycles'] for s in samples})
   cells.append(dict(**p,observed_cycles=measured,all_launches_match_prediction=measured==[p['predicted_cycles']],checked_launches=len(samples)))
  result['cells']=cells
 (d/'validation-result.json').write_text(json.dumps(result,indent=2)+'\n');results.append(result)
 (ROOT/'model-check-results.json').write_text(json.dumps(results,indent=2)+'\n');print(name,result,flush=True)
 if not result['numerical_pass']:break
