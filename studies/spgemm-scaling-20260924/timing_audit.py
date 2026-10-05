"""Replay exact measured builds with root-only readback gating as an observer control."""
import argparse,datetime,fcntl,hashlib,json,os,shutil,signal,subprocess,time
from pathlib import Path
ROOT=Path(__file__).resolve().parent;SDK=Path('/home/USER/cs_sdk')
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
TARGETS=['density-m64-k64-n64-p4-d8-full','strong-m64-k64-n64-p64-d3-full']
def register():
 p=ROOT/'timing-audit-registration.json'
 if p.exists():raise RuntimeError('Already registered')
 reg=dict(created_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),targets=TARGETS,
  reason='Check whether queued rectangle-wide telemetry readback changes the root interval compared with first reading only the root after its completion acknowledgement.',
  policies=['rectangle_first','root_first'],repetitions=3,warmups=1,
  acceptance='Replay the exact original ELF bundles. Validate all CSR/B/acknowledgement results and compare each root-cycle sample against the matching original record and other readback policy. Report all differences; do not silently replace the original sweep.',
  scope='Independent timing-method audit; not one of the 28 registered size/PE configurations. No compiler or kernel changes.',
  execution='After the primary sweep, serially under both shared SDK locks. Uniform input for density case; uniform and skewed equal-row-block inputs for the 64-PE case.',
  driver_sha256=sha(Path(__file__)))
 p.write_text(json.dumps(reg,indent=2)+'\n');print('Registered timing audit')

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--register',action='store_true');args=ap.parse_args()
 if args.register:register();return
 reg=json.loads((ROOT/'timing-audit-registration.json').read_text());assert sha(Path(__file__))==reg['driver_sha256']
 results=[]
 for name in reg['targets']:
  original=ROOT/'cases'/name
  if not(original/'observations.json').exists():results.append(dict(case=name,status='missing_complete_reference'));continue
  observed=json.loads((original/'observations.json').read_text());c=observed['case']
  for policy in reg['policies']:
   d=ROOT/'timing-audit'/f'{name}-{policy}'
   if(d/'result.json').exists():results.append(json.loads((d/'result.json').read_text()));continue
   d.mkdir(parents=True,exist_ok=True);cfg=dict(c);cfg['id']=d.name;cfg['readback_policy']=policy
   cfg['sessions']=[spec for spec in c['sessions'][:len(c['sessions'])-2]if spec['pattern']in ('uniform','skewed')and spec['policy']=='row_blocks']
   cfg['source_hashes']=dict(c['source_hashes'])
   for file in c['source_hashes']:shutil.copy2(original/file,d/file)
   host=(d/'host.py').read_text().replace("report=get('report',24,True);ack=get('total_sum',1,root=True).view(np.float32)[0,0]", "root_report=get('report',24,True,root=True)if c['readback_policy']=='root_first'else None\n  report=get('report',24,True)\n  if root_report is not None:np.testing.assert_array_equal(root_report[0],report[0])\n  ack=get('total_sum',1,root=True).view(np.float32)[0,0]")
   assert host!=(d/'host.py').read_text();(d/'host.py').write_text(host);cfg['source_hashes']['host.py']=sha(d/'host.py')
   (d/'case.json').write_text(json.dumps(cfg,indent=2)+'\n');shutil.copytree(original/'out',d/'out')
   expected={str(p.relative_to(original/'out')):sha(p)for p in (original/'out').rglob('*.elf')}
   assert expected=={str(p.relative_to(d/'out')):sha(p)for p in (d/'out').rglob('*.elf')}
   locks=[open(p,'a')for p in ('/tmp/xkernel_singularity.lock',f'/tmp/xkernel_singularity_{os.getuid()}.lock')];queued=time.monotonic()
   for lock in locks:fcntl.flock(lock,fcntl.LOCK_EX)
   record=dict(case=name,policy=policy,status='running',queue_wait_seconds=time.monotonic()-queued,elf_sha256=expected)
   env=dict(os.environ,OMP_NUM_THREADS='1',OPENBLAS_NUM_THREADS='1',APPTAINERENV_CSL_SUPPRESS_SIMFAB_TRACE='1');started=time.monotonic()
   try:
    with(d/'run.log').open('w')as log:
     proc=subprocess.Popen([str(SDK/'cs_python'),'host.py'],cwd=d,env=env,stdout=log,stderr=subprocess.STDOUT,start_new_session=True)
     try:rc=proc.wait(timeout=900)
     except subprocess.TimeoutExpired:
      os.killpg(proc.pid,signal.SIGTERM)
      try:proc.wait(timeout=10)
      except subprocess.TimeoutExpired:os.killpg(proc.pid,signal.SIGKILL);proc.wait()
      rc=124
    record.update(returncode=rc,wall_seconds=time.monotonic()-started)
    if rc:record['status']='run_failed'
    else:
     replay=json.loads((d/'observations.json').read_text());comparisons=[]
     assert replay['status']=='pass'
     for r in replay['records']:
      prior=next(x for x in observed['records']if all(x[k]==r[k]for k in ('pattern','policy','changed','mode')))
      assert r['matrix_hashes']==prior['matrix_hashes']
      before=[x['root_span_cycles']for x in prior['samples']];after=[x['root_span_cycles']for x in r['samples']]
      comparisons.append(dict(pattern=r['pattern'],mode=r['mode'],original_cycles=before,replay_cycles=after,differences=[a-b for a,b in zip(after,before)]))
     assert expected=={str(p.relative_to(d/'out')):sha(p)for p in (d/'out').rglob('*.elf')}
     errors=[x for x in (d/'sim.log').read_text().splitlines()if ' ERROR:'in x or ' FATAL:'in x]
     record.update(status='pass'if not errors else 'simulator_diagnostic_failure',comparisons=comparisons,errors=errors,
      numerical_launches=sum(len(r['samples'])for r in replay['records']),all_root_samples_identical=all(not any(x['differences'])for x in comparisons))
   finally:
    for lock in locks:fcntl.flock(lock,fcntl.LOCK_UN);lock.close()
   (d/'result.json').write_text(json.dumps(record,indent=2)+'\n');results.append(record)
   (ROOT/'timing-audit-results.json').write_text(json.dumps(results,indent=2)+'\n');print(name,policy,record['status'],record.get('all_root_samples_identical'),flush=True)
 (ROOT/'timing-audit-results.json').write_text(json.dumps(results,indent=2)+'\n')
if __name__=='__main__':main()
