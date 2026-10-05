"""Build compact compiled-path and output-emission accounting from verified traces."""
from collections import defaultdict
import json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parent;x=json.loads((ROOT/'trace-audit.json').read_text());results=[]
def comparisons(A):
 n=len(A);cols=[[i for i in range(n) if A[i][j]!=0] for j in range(n)];count=0
 for j,right in enumerate(cols):
  for i in right:
   left=cols[i];p=q=0
   while p<len(left) and q<len(right):
    count+=1
    if left[p]==right[q]:p+=1;q+=1
    elif left[p]<right[q]:p+=1
    else:q+=1
 return count
for r in x['results']:
 assert r['passed']
 chosen={w['pattern']:w for w in r['windows'] if not w['warmup']};item=dict(case=r['case'],rows=[])
 for pattern,w in chosen.items():
  groups=defaultdict(lambda:dict(dispatches=0,cycles=0))
  for pc,g in w['pc_intervals'].items():
   groups[g['source']]['dispatches']+=g['count'];groups[g['source']]['cycles']+=g['cycles']
  row=dict(pattern=pattern,cycles=w['cycles'],dispatches=w['dispatches'],products=w['products'],opcode_dispatches=w['opcode_dispatches'],source_intervals=dict(groups))
  if r['case'].startswith('general'):
   visits=sum(g['count'] for g in w['pc_intervals'].values() if 'const j: u16 = @as(u16,bj[q]);' in (g['source'] or '') and re.match(r'imov32\.nf d[0-9]+ = \[',g['assembly']))
   factor=4 if r['case']=='general-tile4' else 1
   assert visits==factor*w['products'],(r['case'],pattern,visits,w['products'])
   row['verified_B_index_reads']=visits
  row['cycles_per_dispatch_event']=w['cycles']/w['dispatches']
  if r['case'].startswith('selection'):
   obs=json.loads((ROOT/'traces'/r['case']/'observations.json').read_text());record=next(x for x in obs['records'] if x['pattern']==pattern)
   expected=comparisons(record['A'])
   observed=sum(g['count'] for g in w['pc_intervals'].values() if 'if (ri == rj)' in (g['source'] or '') and g['assembly'].startswith('eq16'))
   assert observed==expected,(r['case'],pattern,observed,expected)
   row['verified_equality_checks']=observed
  item['rows'].append(row)
 if 'banded' in chosen and 'uniform' in chosen:
  groups=defaultdict(lambda:[0,0])
  for i,pattern in enumerate(('banded','uniform')):
   for pc,g in chosen[pattern]['pc_intervals'].items():groups[g['source']][i]+=g['cycles']
  item['uniform_minus_banded']=[dict(source=s,cycles=v[1]-v[0]) for s,v in groups.items() if v[0]!=v[1]]
  assert sum(v['cycles'] for v in item['uniform_minus_banded'])==chosen['uniform']['cycles']-chosen['banded']['cycles']
 results.append(item)
(ROOT/'trace-findings.json').write_text(json.dumps(dict(results=results,scope='Source-attributed dispatch intervals, not causal runtime percentages or physical instruction latencies.'),indent=2)+'\n')
for x in results:
 print(x['case'],[(r['pattern'],r['cycles'],r['dispatches'],r['products']) for r in x['rows']])
 if x['case'].startswith('general'):print('output-size change accounting',x['uniform_minus_banded'])
