"""Test the saved communication prediction without refitting its coefficients."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parent
reg=json.loads((ROOT/'broadcast-model-registration.json').read_text());s=json.loads((ROOT/'summary.json').read_text());results=[]
for t in reg['targets']:
 rows=[r for r in s['rows']if r['case']==t['case']and r['initial']and r['pattern']=='uniform'and r['policy']=='row_blocks']
 modes={r['mode']:r for r in rows};r=dict(t)
 if set(modes)!={'broadcast','resident'}:r['status']='missing';results.append(r);continue
 a,b=modes['broadcast'],modes['resident'];assert a['matrix_hashes']==b['matrix_hashes']
 observed=a['root_cycles']-b['root_cycles'];r.update(status='measured',observed_extra_cycles=observed,residual=observed-t['predicted_extra_cycles'],N=a['N'],P=a['P'],degree=a['degree'],group=a['group'],case_status=a['case_status'])
 results.append(r)
(ROOT/'broadcast-model-results.json').write_text(json.dumps(dict(registration=reg,results=results),indent=2)+'\n')
print('Broadcast model targets:',len(results),'measured:',sum(r['status']=='measured'for r in results),'exact:',sum(r.get('residual')==0 for r in results))
