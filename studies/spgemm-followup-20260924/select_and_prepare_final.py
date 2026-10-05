"""Freeze selection before executing any final-test matrix."""
import datetime,hashlib,json,math,shutil
from pathlib import Path
ROOT=Path(__file__).resolve().parent;reg=json.loads((ROOT/'registration.json').read_text())
if (ROOT/'selection-decision.json').exists():raise RuntimeError('Selection is immutable')
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
metrics={};failures={}
for name in reg['masked_variants']:
 d=ROOT/'selection'/name;status=json.loads((d/'result.json').read_text())
 if status['status']!='pass':failures[name]=status['status'];continue
 obs=json.loads((d/'observations.json').read_text());original={r['pattern']:r['median_cycles'] for i,r in enumerate(obs['records']) if i%3==0}
 assert set(original)==set(reg['selection_patterns']);metrics[name]=original
base=metrics['baseline'];scores={name:math.exp(sum(math.log(v[p]/base[p]) for p in base)/len(base)) for name,v in metrics.items() if name!='nested'}
selected=min(scores,key=lambda name:(scores[name],reg['masked_variants'].index(name)))
choice=dict(created_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),registration_sha256=sha(ROOT/'registration.json'),selected=selected,geometric_cycle_ratios=scores,original_medians=metrics,failures=failures,observation_hashes={name:sha(ROOT/'selection'/name/'observations.json') for name in metrics})
(ROOT/'selection-decision.json').write_text(json.dumps(choice,indent=2)+'\n')
for name in dict.fromkeys(['baseline',selected,'nested']):
 src=ROOT/'selection'/name;d=ROOT/'final'/name;d.mkdir(parents=True)
 for f in ('host.py','pe.csl','layout.csl','inputs.py'):shutil.copy2(src/f,d/f)
 shutil.copytree(src/'out',d/'out');cfg=json.loads((src/'case.json').read_text());cfg.update(patterns=reg['final_patterns'],phase='final',selection_decision_sha256=sha(ROOT/'selection-decision.json'))
 (d/'case.json').write_text(json.dumps(cfg,indent=2)+'\n')
 assert sha(d/'out/bin/out_0_0.elf')==sha(src/'out/bin/out_0_0.elf')
print(json.dumps(choice,indent=2))
