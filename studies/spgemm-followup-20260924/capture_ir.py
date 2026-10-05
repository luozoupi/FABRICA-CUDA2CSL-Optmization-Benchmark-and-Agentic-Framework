"""Capture compiler IR with the existing interceptor; require full measured-ELF identity."""
import datetime,fcntl,json,os,signal,subprocess,sys,time
from pathlib import Path
from audit_common import sha
ROOT=Path(__file__).resolve().parent
TOOL=Path('/home/USER/xkernel-profiling-review-20260924/studies/wse3-characterization/tools/cslc_ir.py')
SIF=json.loads((ROOT/'sdk-identity.json').read_text())['image'];chosen=json.loads((ROOT/'selection-decision.json').read_text())['selected']
registration=ROOT/'ir-registration.json'
if not registration.exists():registration.write_text(json.dumps(dict(created_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),cases=['baseline',chosen],tool=str(TOOL),tool_sha256=sha(TOOL),acceptance='Full SHA-256 equality between measured and intercepted application ELF; original binaries and CSL sources unchanged. IR is the version-specific backend input, not a public cslc export API.'),indent=2)+'\n')
results=[]
for name in ('baseline',chosen):
 src=ROOT/'selection'/name;capture=ROOT/'ir'/name;shadow=src/'.ir-shadow';capture.mkdir(parents=True,exist_ok=True)
 result_file=capture/'result.json'
 if result_file.exists():results.append(json.loads(result_file.read_text()));continue
 locks=[open(p,'a') for p in ('/tmp/xkernel_singularity.lock',f'/tmp/xkernel_singularity_{os.getuid()}.lock')];wait=time.monotonic()
 while True:
  held=[]
  try:
   for l in locks:fcntl.flock(l,fcntl.LOCK_EX|fcntl.LOCK_NB);held.append(l)
   break
  except BlockingIOError:
   for l in held:fcntl.flock(l,fcntl.LOCK_UN)
   if time.monotonic()-wait>600:raise TimeoutError('SDK locks')
   time.sleep(1)
 original={str(p.relative_to(src)):sha(p) for p in src.rglob('*.elf')};original.update({f:sha(src/f) for f in ('pe.csl','layout.csl')})
 command=[sys.executable,str(TOOL),'capture','-o',str(capture),'--','layout.csl','--arch=wse3','--fabric-dims=8,3','--fabric-offsets=4,1','--memcpy','--channels=1','--width-west-buf=0','--width-east-buf=0','--out-routes','-o',str(shadow)]
 env=dict(os.environ,CS_SDK_SIF=SIF,OMP_NUM_THREADS='1',OPENBLAS_NUM_THREADS='1');start=time.monotonic();queue=start-wait
 try:
  print(name,'IR capture',flush=True)
  with (capture/'capture.log').open('w') as log:
   proc=subprocess.Popen(command,cwd=src,env=env,stdout=log,stderr=subprocess.STDOUT,start_new_session=True)
   try:rc=proc.wait(timeout=180)
   except subprocess.TimeoutExpired:
    os.killpg(proc.pid,signal.SIGTERM)
    try:proc.wait(timeout=10)
    except subprocess.TimeoutExpired:os.killpg(proc.pid,signal.SIGKILL);proc.wait()
    rc=124
 finally:
  for l in locks:fcntl.flock(l,fcntl.LOCK_UN);l.close()
 assert all(sha(src/f)==h for f,h in original.items()),'Measured source/binary changed'
 result=dict(case=name,command=command,queue_wait_s=queue,wall_s=time.monotonic()-start,returncode=rc,measured_elf_sha256=sha(src/'out/bin/out_0_0.elf'),measured_files_unchanged=True)
 if rc==0:
  result['shadow_elf_sha256']=sha(shadow/'bin/out_0_0.elf');result['byte_identical']=result['shadow_elf_sha256']==result['measured_elf_sha256']
  matches=[p for p in capture.glob('*/meta.json') if Path(json.loads(p.read_text())['elf'])==shadow/'bin/out_0_0.elf'];assert len(matches)==1
  ll=matches[0].parent/'program.ll';result['ir_file']=str(ll);result['ir_sha256']=sha(ll);result['status']='accepted' if result['byte_identical'] else 'unmatched'
 else:result['status']='failed';result['diagnostic']=(capture/'capture.log').read_text()[-2000:]
 result_file.write_text(json.dumps(result,indent=2)+'\n');results.append(result);(ROOT/'ir-results.json').write_text(json.dumps(results,indent=2)+'\n');print(name,result['status'],flush=True)
