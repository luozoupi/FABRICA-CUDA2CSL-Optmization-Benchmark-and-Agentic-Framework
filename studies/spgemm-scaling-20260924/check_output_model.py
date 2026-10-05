"""Evaluate the preregistered larger-size output-cardinality contrast."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parent
reg=json.loads((ROOT/'output-model-registration.json').read_text());s=json.loads((ROOT/'summary.json').read_text())
rows={r['pattern']:r for r in s['rows']if r['case']==reg['case']and r['initial']and r['mode']=='broadcast'and r['policy']=='row_blocks'}
result=dict(registration=reg,status='missing')
if all(p in rows for p in ('banded','uniform')):
 for pattern in ('banded','uniform'):
  assert rows[pattern]['products']==reg['input_points'][pattern]['products']
  assert rows[pattern]['output_nnz']==reg['input_points'][pattern]['output_nnz']
 difference=rows['uniform']['root_cycles']-rows['banded']['root_cycles']
 result.update(status='measured',observed_difference=difference,residual=difference-reg['predicted_cycle_difference'],case_status=rows['uniform']['case_status'])
(ROOT/'output-model-results.json').write_text(json.dumps(result,indent=2)+'\n')
print('Larger-size output contrast:',result['status'],result.get('residual'))
