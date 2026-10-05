"""Publish compact scientific evidence; preserve measured binaries and raw traces locally."""
import argparse,csv,gzip,json,shutil,tarfile
from pathlib import Path
from audit_common import sha
ROOT=Path(__file__).resolve().parent
ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--destination',type=Path,required=True);args=ap.parse_args();dest=args.destination.resolve();dest.mkdir(parents=True,exist_ok=True)
summary=json.loads((ROOT/'summary.json').read_text());audit=json.loads((ROOT/'trace-audit.json').read_text());assert audit['results'] and all(r['passed'] for r in audit['results'])
measurements={};failures=[];original_files={};groups=['selection','final','general','model','traces']
for group in groups:
 measurements[group]={}
 for d in sorted((ROOT/group).iterdir()):
  if not d.is_dir():continue
  for f in d.rglob('*'):
   if f.is_file() and (f.suffix in ('.csl','.py','.json','.elf','.am') or f.parent.name=='simfab_traces'):original_files[str(f)]=sha(f)
  record={}
  for name in ('case.json','result.json','observations.json','partial-observations.json','binding.json'):
   if (d/name).exists():record[name]=json.loads((d/name).read_text())
  measurements[group][d.name]=record
  fixture=dest/'fixtures'/group/d.name;fixture.mkdir(parents=True,exist_ok=True)
  for name in ('case.json','pe.csl','layout.csl','host.py','inputs.py'):
   if (d/name).exists():shutil.copy2(d/name,fixture/name)
for f in (ROOT/'development-failures').rglob('result.json'):
 r=json.loads(f.read_text());log=f.parent/'run.log';failures.append(dict(path=str(f),result=r,run_log=log.read_text() if log.exists() else None));original_files[str(f)]=sha(f)
 for name in ('host.py','pe.csl','layout.csl','inputs.py','case.json','compile.log','run.log'):
  if (f.parent/name).exists():original_files[str(f.parent/name)]=sha(f.parent/name)
for f in (ROOT/'ir/development-failures').rglob('collection-failure.json'):
 failures.append(dict(path=str(f),kind='IR artifact collection',diagnostic=json.loads(f.read_text())))
 original_files[str(f)]=sha(f)
for r in json.loads((ROOT/'ir-results.json').read_text()):
 if r['status']=='accepted':
  directory=Path(r['ir_file']).parent
  for f in directory.iterdir():
   if f.is_file():original_files[str(f)]=sha(f)
(ROOT/'retained-failures.json').write_text(json.dumps(failures,indent=2)+'\n')
for name,payload in [('measurements.json.gz',json.dumps(measurements).encode()),('trace-audit.json.gz',(ROOT/'trace-audit.json').read_bytes())]:
 with gzip.GzipFile(filename=str(ROOT/name),mode='wb',mtime=0) as f:f.write(payload)
with (ROOT/'timings.csv').open('w',newline='') as f:
 writer=csv.DictWriter(f,lineterminator='\n',fieldnames=['group','case','pattern','session','changed','cycles','min_cycles','max_cycles']);writer.writeheader()
 for group,data in summary['groups'].items():
  for row in data['rows']:writer.writerow(dict(group=group,**{k:row[k] for k in writer.fieldnames if k!='group'}))
archive=ROOT/'replay-bundles.tar.gz'
if not archive.exists():
 with tarfile.open(archive,'w:gz') as tar:
  for group in groups:
   for d in sorted((ROOT/group).iterdir()):
    for name in ('case.json','pe.csl','layout.csl','host.py','inputs.py','out','observations.json','partial-observations.json','result.json','disassembly.json','binding.json'):
     if (d/name).exists():tar.add(d/name,arcname=str((d/name).relative_to(ROOT)))
  for name in ('registration.json','selection-decision.json','sdk-identity.json'):tar.add(ROOT/name,arcname=name)
  for r in json.loads((ROOT/'ir-results.json').read_text()):
   if r['status']=='accepted':tar.add(Path(r['ir_file']).parent,arcname='accepted-ir/'+r['case'])
files=[p for p in ROOT.iterdir() if p.is_file() and p.suffix in ('.py','.md','.json','.csv','.png','.pdf','.svg') and p.name not in ('trace-audit.json','evidence-manifest.json')]
files += [ROOT/'measurements.json.gz',ROOT/'trace-audit.json.gz'] + list(ROOT.glob('kernel-*.ll.txt'))
for f in files:shutil.copy2(f,dest/f.name)
shutil.copytree(ROOT/'amendments',dest/'amendments',dirs_exist_ok=True)
shutil.copytree(ROOT/'tools-used',dest/'tools-used',dirs_exist_ok=True)
manifest=dict(origin='NVIDIA GPU node with Cerebras SDK; one-PE simulator experiments',framework_base='196523eb1e25b832d9f6fa8a665838c042c751e3',local_root=str(ROOT),
 sdk=json.loads((ROOT/'sdk-identity.json').read_text()),artifact_origin='Deterministic reference/control programs, no API/model completions',
 replay_bundle=dict(path=str(archive),bytes=archive.stat().st_size,sha256=sha(archive)),original_evidence_sha256=original_files,
 compact_sha256={str(p.relative_to(dest)):sha(p) for p in dest.rglob('*') if p.is_file() and p.name!='evidence-manifest.json' and '__pycache__' not in p.parts and p.suffix!='.pyc'})
(ROOT/'evidence-manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');shutil.copy2(ROOT/'evidence-manifest.json',dest/'evidence-manifest.json')
print('Packaged',len(manifest['compact_sha256']),'files;',len(failures),'retained failed invocations; replay bundle',archive.stat().st_size,'bytes')
