"""Prepare short exact-binary traces after the fixed candidate selection."""
import hashlib,json,shutil
from pathlib import Path
ROOT=Path(__file__).resolve().parent;decision=json.loads((ROOT/'selection-decision.json').read_text());sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
for group,names,patterns in [('selection',['baseline',decision['selected']],['banded','uniform']),('general',['full_row','tile4'],['banded','uniform'])]:
 for name in dict.fromkeys(names):
  src=ROOT/group/name;dest=ROOT/'traces'/(group+'-'+name);dest.mkdir(parents=True,exist_ok=False)
  for f in ('pe.csl','layout.csl','inputs.py'):shutil.copy2(src/f,dest/f)
  host=(src/'host.py').read_text()
  if group=='selection':host=host.replace("([False] if c['debug'] else [False,True,False])",'[False]')
  else:
   host=host.replace('enumerate([False,True,False])','enumerate([False])')
   start=host.index('  for pattern,limit in ');end=host.index(' finally:',start);host=host[:start]+host[end:]
  (dest/'host.py').write_text(host);shutil.copytree(src/'out',dest/'out')
  cfg=json.loads((src/'case.json').read_text());cfg.update(patterns=patterns,repetitions=1,phase='trace')
  cfg['source_hashes']={f:sha(dest/f) for f in ('pe.csl','layout.csl','host.py','inputs.py')};(dest/'case.json').write_text(json.dumps(cfg,indent=2)+'\n')
  binding=dict(source=str(src),source_result_sha256=sha(src/'result.json'),original_observations_sha256=sha(src/'observations.json'),elf_sha256={str(p.relative_to(src/'out')):sha(p) for p in (src/'out').rglob('*.elf')})
  for rel,h in binding['elf_sha256'].items():assert sha(dest/'out'/rel)==h
  (dest/'binding.json').write_text(json.dumps(binding,indent=2)+'\n')
print('Prepared short exact measured-build traces')
