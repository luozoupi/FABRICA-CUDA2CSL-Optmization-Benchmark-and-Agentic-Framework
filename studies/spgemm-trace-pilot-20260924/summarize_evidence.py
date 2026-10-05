"""Build compact verified tables and a source-attributed dispatch-interval comparison."""
from collections import defaultdict
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parent
x=json.loads((ROOT/'trace-analysis.json').read_text())
rows=[];comparisons=[]
for case in x['results']:
    assert case['passed']
    chosen={w['pattern']:w for w in case['windows'] if w['session']==0 and w['repetition']==1}
    for pattern,w in chosen.items():
        c=w['algorithm_counts'];assert c['products']==w['floating_results']['FMULS']==w['floating_results']['FADDS']
        rows.append(dict(case=case['id'],pattern=pattern,cycles=w['cycles'],dispatches=w['dispatches'],
          equality_checks=c[case['id']+'_comparisons'],products=c['products'],nnz=c['nnz'],
          mask_positions=c['mask_positions'],structural_output_positions=c['structural_output_positions'],
          cancelled_output_positions=c.get('cancelled_output_positions',0),
          unmasked_products=c['unmasked_products'],unmasked_structural_output_positions=c['unmasked_structural_output_positions']))
    a,b=chosen['banded'],chosen['uniform'];groups=defaultdict(lambda:[0,0])
    for i,w in enumerate((a,b)):
        for pc,g in w['pc_gaps'].items():groups[g['source']][i]+=g['cycle_sum']
    changes=[dict(source=k,banded_cycles=v[0],uniform_cycles=v[1],difference=v[1]-v[0]) for k,v in groups.items() if v[0]!=v[1]]
    assert sum(v['difference'] for v in changes)==b['cycles']-a['cycles']
    comparisons.append(dict(case=case['id'],comparison='uniform minus banded',cycle_difference=b['cycles']-a['cycles'],source_dispatch_intervals=changes))
result=dict(verified_launches=sum(len(c['windows']) for c in x['results']),
 multiplication_results=sum(w['floating_results']['FMULS'] for c in x['results'] for w in c['windows']),
 addition_results=sum(w['floating_results']['FADDS'] for c in x['results'] for w in c['windows']),
 original_input_rows=rows,comparisons=comparisons,
 interpretation='Dispatch-to-next-dispatch intervals partition elapsed cycles; they are not instruction latencies, stall counters, or causal runtime percentages.')
(ROOT/'findings.json').write_text(json.dumps(result,indent=2)+'\n')
print('Verified compact evidence:',result['verified_launches'],'launches;',result['multiplication_results'],'products')
