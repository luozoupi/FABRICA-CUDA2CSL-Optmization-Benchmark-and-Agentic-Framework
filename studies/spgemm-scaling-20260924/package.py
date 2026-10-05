"""Publish compact evidence after all registered cases finish; retain raw builds locally."""
import argparse,datetime,gzip,hashlib,json,shutil,tarfile
from pathlib import Path
ROOT=Path(__file__).resolve().parent
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--destination',type=Path,required=True);ap.add_argument('--progress',action='store_true');args=ap.parse_args();dest=args.destination.resolve()
 summary=json.loads((ROOT/'summary.json').read_text());assert args.progress or summary['all_registered_complete'],'Do not publish final evidence while cases are pending'
 reg=json.loads((ROOT/'registration.json').read_text());dest.mkdir(parents=True,exist_ok=True)
 original={};failures=[];resources=[]
 completed_ids={c['id']for c in summary['cases']if c['status']!='pending'}
 for group in ('cases','development','development-failures','timing-audit','interrupted-attempts','coordination-failures'):
  if not(ROOT/group).exists():continue
  for d in sorted((ROOT/group).iterdir()):
   if not d.is_dir():continue
   target=dest/group/d.name;target.mkdir(parents=True,exist_ok=True)
   finished=(d/'result.json').exists()and(group!='cases'or d.name in completed_ids)
   for f in d.rglob('*'):
    if f.is_file()and '__pycache__'not in f.parts and (finished or f.name in ('case.json','pe.csl','layout.csl','single_collective.csl','host.py','inputs.py')):original[str(f)]=sha(f)
   for name in ('case.json','pe.csl','layout.csl','single_collective.csl','host.py','inputs.py','result.json','compile.log','run.log','sim_stats.json','simconfig.json','supervisor-state.json','supervisor-launch.json','durable_resume.py'):
    if(d/name).exists()and (finished or name in ('case.json','pe.csl','layout.csl','single_collective.csl','host.py','inputs.py')):shutil.copy2(d/name,target/name)
   if finished:
    result=json.loads((d/'result.json').read_text());resources.append(dict(group=group,**result))
    if result['status']!='pass':failures.append(dict(group=group,**result))
 resources_summary=dict(cases=resources,phase_wall_seconds={phase:sum(p['wall_seconds']for r in resources for p in r.get('phases',[dict(phase='run',wall_seconds=r['wall_seconds'])]if 'wall_seconds'in r else [])if p['phase']==phase)for phase in ('compile','run')},queue_wait_seconds=sum(r.get('queue_wait_seconds',0)for r in resources),API_calls=0,physical_WSE_runs=0,admission_retry_wait_seconds=sum(e['wait_seconds']for e in summary.get('admission_events',[])),prior_admission_failures=summary.get('coordination_failures',[]),unsupervised_simulator_reported_seconds=sum(r.get('unsupervised_simulator_reported_seconds',0)for r in resources),
  note='Outer-process wall times include simulator execution and SDK overhead. Host launch API call durations are not device latency or complete simulator runtime; result-readback calls can drive simulator progress. Interrupted unsupervised runtime is reported separately from the SDK log and is not included in measured outer-process phase times.')
 audit_observations={str(p.parent.relative_to(ROOT)):json.loads(p.read_text())for p in (ROOT/'timing-audit').glob('*/observations.json')}
 if audit_observations:(ROOT/'timing-audit-measurements.json.gz').write_bytes(gzip.compress(json.dumps(audit_observations).encode(),mtime=0))
 (ROOT/'resources.json').write_text(json.dumps(resources_summary,indent=2)+'\n');(ROOT/'retained-failures.json').write_text(json.dumps(failures,indent=2)+'\n')
 archive=ROOT/'replay-bundles.tar.gz'
 if summary['all_registered_complete'] and not archive.exists():
  with tarfile.open(archive,'w:gz')as tar:
   for group in ('cases','development','development-failures','timing-audit','interrupted-attempts','coordination-failures'):
    if not(ROOT/group).exists():continue
    for d in sorted((ROOT/group).iterdir()):
     for name in ('out','case.json','pe.csl','layout.csl','single_collective.csl','host.py','inputs.py','observations.json','observations.partial.json','result.json','compile.log','run.log','sim_stats.json','simconfig.json','supervisor-state.json','supervisor-launch.json','durable_resume.py'):
      if(d/name).exists():tar.add(d/name,arcname=str((d/name).relative_to(ROOT)))
   for name in ('registration.json','sdk-identity.json','PROTOCOL.md','broadcast-model-registration.json'):tar.add(ROOT/name,arcname=name)
 for p in ROOT.iterdir():
  if p.is_file()and (p.suffix in ('.py','.csl','.in','.md','.json','.csv','.png','.pdf','.svg','.html')or p.name in ('measurements.json.gz','timing-audit-measurements.json.gz','interrupted-observations.json.gz'))and p.name!='evidence-manifest.json':shutil.copy2(p,dest/p.name)
 manifest=dict(created_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),origin=reg['origin'],framework_base=reg['framework_base'],local_root=str(ROOT),
  progress_snapshot=not summary['all_registered_complete'],sdk=json.loads((ROOT/'sdk-identity.json').read_text()),replay_bundle=dict(path=str(archive),bytes=archive.stat().st_size,sha256=sha(archive))if archive.exists()else None,original_evidence_sha256=original,
  compact_sha256={str(p.relative_to(dest)):sha(p)for p in dest.rglob('*')if p.is_file()and p.name!='evidence-manifest.json'and '__pycache__'not in p.parts and p.suffix!='.pyc'})
 (ROOT/'evidence-manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');shutil.copy2(ROOT/'evidence-manifest.json',dest/'evidence-manifest.json')
 print('Packaged',len(manifest['compact_sha256']),'files;',len(original),'original evidence hashes;',archive.stat().st_size if archive.exists()else 0,'archive bytes')
if __name__=='__main__':main()
