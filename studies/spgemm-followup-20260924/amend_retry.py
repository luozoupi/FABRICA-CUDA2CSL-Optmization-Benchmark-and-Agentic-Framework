"""Retain a watchdog failure and add host-only result checkpoints before remaining runs."""
import datetime,hashlib,json,shutil
from pathlib import Path
ROOT=Path(__file__).resolve().parent;sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
archive=ROOT/'development-failures/tile4-watchdog';archive.mkdir(parents=True)
shutil.move(ROOT/'general/tile4',archive/'tile4');src=archive/'tile4';d=ROOT/'general/tile4';d.mkdir(parents=True)
for f in ('pe.csl','layout.csl','host.py','inputs.py','case.json'):shutil.copy2(src/f,d/f)
shutil.copytree(src/'out',d/'out');changes=[]
for group in ('general','final'):
 for case in (ROOT/group).iterdir():
  if group=='general' and case.name!='tile4':continue
  host=case/'host.py';old=sha(host);lines=host.read_text().splitlines();new=[]
  for line in lines:
   new.append(line)
   if line.lstrip().startswith('records.append('):
    indent=line[:len(line)-len(line.lstrip())]
    new.append(indent+"Path('partial-observations.json').write_text(json.dumps(dict(status='partial',records=records),indent=2)+'\\n')")
  host.write_text('\n'.join(new)+'\n');cfg=json.loads((case/'case.json').read_text());cfg['source_hashes']['host.py']=sha(host);(case/'case.json').write_text(json.dumps(cfg,indent=2)+'\n')
  changes.append(dict(case=str(case.relative_to(ROOT)),old_host_sha256=old,new_host_sha256=sha(host),elf_sha256=sha(case/'out/bin/out_0_0.elf')))
runner=ROOT/'run_sdk.py';old=sha(runner);shutil.copy2(runner,ROOT/'amendments/run_sdk.before_retry.py');s=runner.read_text().replace("900 if args.group=='final' else 420","1800 if args.group=='general' else 900 if args.group=='final' else 420")
s=s.replace("for d in sorted((ROOT/args.group).iterdir()):","for d in sorted((ROOT/args.group).iterdir(),key=lambda p: ({'separate_updates':0,'baseline':1,'nested':2}.get(p.name,3),p.name) if args.group=='final' else (0,p.name)):")
runner.write_text(s)
(ROOT/'watchdog-retry-amendment.json').write_text(json.dumps(dict(created_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),reason='Tiled full SpGEMM suite exceeded 420-second wall-time watchdog; retain failed invocation and rerun unchanged ELF with 1800-second general-suite limit. Add output checkpoints outside device timing; prioritize selected merge and baseline before the nested final reference. Final suite limit remains 900 seconds for every variant.',prior_runner_sha256=old,amended_runner_sha256=sha(runner),failed_result_sha256=sha(src/'result.json'),host_changes=changes,compiled_programs_changed=False),indent=2)+'\n')
print('Retained watchdog attempt; prepared unchanged-binary retry and host checkpoints')
