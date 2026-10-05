"""Compare immutable preregistered cycle predictions with new measured inputs."""
import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parent;reg=json.loads((ROOT/'model-registration.json').read_text());d=ROOT/'model/output_emission'
assert json.loads((d/'result.json').read_text())['status']=='pass'
assert hashlib.sha256((d/'out/bin/out_0_0.elf').read_bytes()).hexdigest()==reg['elf_sha256']
obs=json.loads((d/'observations.json').read_text());results=[]
for pred,record in zip(reg['predictions'],obs['records']):
 assert pred['pattern']==record['pattern'] and pred['input_sha256']==record['input_sha256']
 assert pred['products']==record['intermediate_products'] and all(s['correct'] and s['expected_nnz']==pred['output_nnz'] for s in record['samples'])
 cycles=[s['cycles'] for s in record['samples']]
 results.append(dict(**pred,observed_cycles=cycles,all_predictions_exact=all(x==pred['predicted_cycles'] for x in cycles),errors=[x-pred['predicted_cycles'] for x in cycles],correct_launches=len(cycles)))
report=dict(registration_sha256=hashlib.sha256((ROOT/'model-registration.json').read_bytes()).hexdigest(),observations_sha256=hashlib.sha256((d/'observations.json').read_bytes()).hexdigest(),results=results,all_predictions_exact=all(r['all_predictions_exact'] for r in results),correct_launches=sum(r['correct_launches'] for r in results))
(ROOT/'model-results.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))
