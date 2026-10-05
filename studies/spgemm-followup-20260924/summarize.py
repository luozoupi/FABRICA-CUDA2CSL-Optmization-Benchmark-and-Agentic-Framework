"""Summarize completed fixed-budget SDK controls and preserve all failures."""
from collections import Counter
import hashlib,json,math
from pathlib import Path
from audit_common import elf_text
ROOT=Path(__file__).resolve().parent;sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
reg=json.loads((ROOT/'registration.json').read_text());decision=json.loads((ROOT/'selection-decision.json').read_text())
for rel,h in reg['frozen_files_sha256'].items():
 if rel=='run_sdk.py':
  amendment=json.loads((ROOT/'final-timeout-amendment.json').read_text());assert h==amendment['original_runner_sha256'];retry=json.loads((ROOT/'watchdog-retry-amendment.json').read_text());assert retry['prior_runner_sha256']==amendment['amended_runner_sha256'];binding=json.loads((ROOT/'disassembly-bind-amendment.json').read_text());assert binding['prior_runner_sha256']==retry['amended_runner_sha256'];assert sha(ROOT/rel)==binding['amended_runner_sha256']
 else:assert sha(ROOT/rel)==h,rel
result=dict(framework_base=reg['framework_commit'],selected=decision['selected'],selection=decision,groups={},failures=[],static={})
for group in ('selection','final','general'):
 rows=[];launches=0;capacity=0
 for d in sorted((ROOT/group).iterdir()):
  status=json.loads((d/'result.json').read_text())
  if status['status']!='pass':
   result['failures'].append(dict(group=group,case=d.name,status=status['status'],phases=status['phases']))
   if not (d/'partial-observations.json').exists():continue
   obs=json.loads((d/'partial-observations.json').read_text())
  else:obs=json.loads((d/'observations.json').read_text())
  cfg=json.loads((d/'case.json').read_text())
  for f,h in cfg['source_hashes'].items():assert sha(d/f)==h
  for i,r in enumerate(obs['records']):
   for s in r['samples']:assert s['correct'] and s.get('structural_correct',True)
   launches+=len(r['samples'])
   cycles=[s['cycles'] for s in r['samples'] if not s['warmup']];assert len(cycles)==3
   row=dict(case=d.name,pattern=r['pattern'],session=i%3,changed=r['changed'],cycles=r['median_cycles'],min_cycles=min(cycles),max_cycles=max(cycles),input_sha256=r['input_sha256'],elf_sha256=sha(d/'out/bin/out_0_0.elf'))
   if group=='general':row.update(input_nnz=r['input_nnz'],products=r['intermediate_products'],output_nnz=r['samples'][0]['expected_nnz'],cancelled_positions=r['samples'][0]['cancelled_positions'],accumulator_bytes=cfg['accumulator_bytes'],index_visits=r['intermediate_products']*(16//cfg['tile_width']))
   rows.append(row)
  for c in obs.get('capacity_checks',[]):assert c['sample']['correct'];capacity+=1
 result['groups'][group]=dict(rows=rows,correct_numerical_launches=launches,correct_capacity_checks=capacity)
base={r['pattern']:r for r in result['groups']['final']['rows'] if r['case']=='baseline' and r['session']==0}
winner={r['pattern']:r for r in result['groups']['final']['rows'] if r['case']==decision['selected'] and r['session']==0}
nested={r['pattern']:r for r in result['groups']['final']['rows'] if r['case']=='nested' and r['session']==0}
assert set(base)==set(reg['final_patterns'])==set(winner)
comparison_patterns=sorted(set(base)&set(nested))
ratios=[base[p]['cycles']/winner[p]['cycles'] for p in base]
result['final_comparison']=dict(patterns=len(ratios),faster_than_baseline=sum(x>1 for x in ratios),equal_to_baseline=sum(x==1 for x in ratios),geometric_speedup_over_baseline=math.exp(sum(math.log(x) for x in ratios)/len(ratios)),
 nested_comparable_patterns=len(comparison_patterns),faster_than_nested=sum(winner[p]['cycles']<nested[p]['cycles'] for p in comparison_patterns),geometric_speedup_over_nested=math.exp(sum(math.log(nested[p]['cycles']/winner[p]['cycles']) for p in comparison_patterns)/len(comparison_patterns)) if comparison_patterns else None,rows=[dict(pattern=p,baseline=base[p]['cycles'],selected=winner[p]['cycles'],nested=nested[p]['cycles'] if p in nested else None,speedup=base[p]['cycles']/winner[p]['cycles']) for p in reg['final_patterns']])
asm={}
for d in sorted((ROOT/'selection').iterdir()):
 if not(d/'disassembly.json').exists():continue
 asm[d.name]=[r for v in json.loads((d/'disassembly.json').read_text()).values() for r in v]
base_instructions=[r['instruction'] for r in asm['baseline']]
for name,rows in asm.items():
 instructions=[r['instruction'] for r in rows]
 result['static'][name]=dict(instructions=len(rows),identical_instruction_sequence_to_baseline=instructions==base_instructions,
   equal_length_differences=[dict(pc=r['pc'],baseline=a,candidate=b,source=r.get('source')) for r,a,b in zip(rows,base_instructions,instructions) if a!=b] if len(rows)==len(base_instructions) else None)
old=Path('/home/USER/spgemm-trace-pilot-20260924/cases/merge/out/bin/out_0_0.elf')
result['rebuilt_baseline_text_matches_prior']=elf_text(old)==elf_text(ROOT/'selection/baseline/out/bin/out_0_0.elf')
result['total_nontrace_correct_checks']=sum(g['correct_numerical_launches']+g['correct_capacity_checks'] for g in result['groups'].values())
(ROOT/'summary.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(selected=result['selected'],final=result['final_comparison'],checks=result['total_nontrace_correct_checks'],failures=result['failures']),indent=2))
