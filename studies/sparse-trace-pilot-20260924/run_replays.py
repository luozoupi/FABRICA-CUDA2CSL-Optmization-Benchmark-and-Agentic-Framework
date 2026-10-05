"""Run frozen sparse ELFs with SDK traces; serialize with both local lock conventions."""
import fcntl
import hashlib
import json
import os
from pathlib import Path
import signal
import subprocess
import time

ROOT = Path(__file__).resolve().parent
REGISTRATION = json.loads((ROOT/'registration.json').read_text())
env = dict(os.environ, OMP_NUM_THREADS='1', OPENBLAS_NUM_THREADS='1')
for key in ('CSL_SUPPRESS_SIMFAB_TRACE','APPTAINERENV_CSL_SUPPRESS_SIMFAB_TRACE','SINGULARITYENV_CSL_SUPPRESS_SIMFAB_TRACE'):
    env.pop(key, None)
results = []
for name in REGISTRATION['cases']:
    directory = ROOT/'cases'/name
    if (directory/'replay-result.json').exists():
        result = json.loads((directory/'replay-result.json').read_text())
        if result['status'] == 'pass':
            results.append(result)
            continue
        raise RuntimeError(f'Prior failure retained in {directory}; investigate before retrying')
    handles = [open(p,'a') for p in ('/tmp/xkernel_singularity.lock',f'/tmp/xkernel_singularity_{os.getuid()}.lock')]
    start = time.monotonic()
    while True:
        acquired = []
        try:
            for handle in handles:
                fcntl.flock(handle, fcntl.LOCK_EX | fcntl.LOCK_NB)
                acquired.append(handle)
            break
        except BlockingIOError:
            for handle in acquired: fcntl.flock(handle,fcntl.LOCK_UN)
            if time.monotonic()-start > 600: raise TimeoutError('SDK locks occupied for 600s')
            time.sleep(1)
    queued = time.monotonic()-start
    print(name,'replay starting',flush=True)
    start = time.monotonic()
    try:
        with open(directory/'trace-run.log','w') as log:
            proc = subprocess.Popen(['/home/USER/cs_sdk/cs_python','trace_host.py'],cwd=directory,
                                    env=env,stdout=log,stderr=subprocess.STDOUT,start_new_session=True)
            try: rc = proc.wait(timeout=360)
            except subprocess.TimeoutExpired:
                os.killpg(proc.pid,signal.SIGTERM)
                try: proc.wait(timeout=10)
                except subprocess.TimeoutExpired:
                    os.killpg(proc.pid,signal.SIGKILL); proc.wait()
                rc = 124
    finally:
        for handle in handles: fcntl.flock(handle,fcntl.LOCK_UN); handle.close()
    errors = [line for line in (directory/'sim.log').read_text().splitlines()
              if ' ERROR:' in line or ' FATAL:' in line] if (directory/'sim.log').exists() else ['missing sim.log']
    result = dict(case=name,status='pass' if rc==0 and not errors else 'failed',returncode=rc,
                  queue_wait_s=queued,execution_s=time.monotonic()-start,diagnostic_errors=errors[:20])
    if result['status']=='pass':
        observation = json.loads((directory/'observations.json').read_text())
        if len(observation['records'])!=6: raise ValueError('Wrong replay record count')
        result['checked_launches']=sum(len(r['samples']) for r in observation['records'])
        result['traces_bytes']=sum(p.stat().st_size for p in (directory/'simfab_traces').iterdir() if p.is_file())
        result['trace_host_sha256']=hashlib.sha256((directory/'trace_host.py').read_bytes()).hexdigest()
    (directory/'replay-result.json').write_text(json.dumps(result,indent=2)+'\n')
    results.append(result)
    (ROOT/'replay-summary.json').write_text(json.dumps(results,indent=2)+'\n')
    print(name,result['status'],round(result['execution_s'],2),'seconds',flush=True)
    if result['status']!='pass': break
