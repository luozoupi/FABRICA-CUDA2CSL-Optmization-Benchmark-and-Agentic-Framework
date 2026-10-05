"""Predict local compute from source work counts; coefficients are not instruction latencies."""
import argparse,datetime,hashlib,json
from pathlib import Path
import numpy as np
from inputs import packed
ROOT=Path(__file__).resolve().parent
FEATURES=['constant','assigned_rows','assigned_rows_times_output_width','A_nonzeros','candidate_products','structural_output_entries']
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def features(rows,n,products,degree,outputs):
 assert products%degree==0
 return [1,rows,rows*n,products//degree,products,outputs]
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--register',action='store_true');args=ap.parse_args()
 path=ROOT/'local-work-model-registration.json';s=json.loads((ROOT/'summary.json').read_text())
 if args.register:
  assert not path.exists()
  assert not any((d/'observations.partial.json').exists()for d in (ROOT/'cases').glob('strong-m256-*'))
  calibration=[]
  for r in s['rows']:
   if not(r['initial']and r['variant']=='full'and r['mode']=='broadcast'and r['case_status']=='pass'):continue
   c=json.loads((ROOT/'cases'/r['case']/'case.json').read_text())
   data=packed(c,r['pattern'],r['policy'],False)
   assert data['matrix_hashes']==r['matrix_hashes']
   for p,assigned in enumerate(data['groups']):
    x=features(len(assigned),r['N'],r['products_per_pe'][p],r['degree'],r['outputs_per_pe'][p])
    calibration.append(dict(case=r['case'],pattern=r['pattern'],policy=r['policy'],pe=p,x=x,cycles=r['local_cycles'][p]))
  X=np.array([r['x']for r in calibration]);Y=np.array([r['cycles']for r in calibration]);coef,_,rank,_=np.linalg.lstsq(X,Y,rcond=None);assert rank==len(FEATURES)
  targets=[]
  for d in sorted((ROOT/'cases').glob('strong-m256-*-full')):
   c=json.loads((d/'case.json').read_text());seen=set()
   for spec in c['sessions']:
    key=(spec['pattern'],spec['policy'])
    if spec['changed']or key in seen:continue
    seen.add(key);data=packed(c,*key,False)
    for p,assigned in enumerate(data['groups']):
     x=features(len(assigned),c['N'],data['counts'][p],c['degree'],data['outputs'][p])
     targets.append(dict(case=d.name,pattern=key[0],policy=key[1],pe=p,x=x,predicted_cycles=float(np.dot(coef,x)),matrix_hashes=data['matrix_hashes']))
  reg=dict(created_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),driver_sha256=sha(Path(__file__)),features=FEATURES,coefficients=coef.tolist(),calibration=calibration,targets=targets,
   calibration_errors=dict(max_abs=float(max(abs(Y-X@coef))),rms=float(np.sqrt(np.mean((Y-X@coef)**2)))),
   method='Unweighted least squares over completed first-input broadcast full-accumulator PE medians at N=16/64. Every PE observation is equally weighted; correlated PEs and matrix families are not independent statistical repetitions.',
   interpretation='A source-work prediction for local compute only. A-nonzero counts are candidate_products divided by uniform B degree; this identity would be invalid with varying B-row degrees. Coefficients are conditional model terms, not isolated instruction costs or causal runtime percentages.',
   acceptance='Freeze coefficients before any N=256 checkpoint. Report every available predicted/observed PE interval, absolute and relative residuals, and fraction within 1 percent; report missing targets and workflow status. Do not refit or replace primary measurements.',
   evidence_status='All calibration cases have ended. No registered N=256 timing checkpoint exists. Matrix structure is known in advance; output counts come from the independent oracle and are explanatory features, not free preprocessing.')
  path.write_text(json.dumps(reg,indent=2)+'\n');print('Registered local-work model:',len(calibration),'calibration PE observations,',len(targets),'future PE observations');return
 reg=json.loads(path.read_text());assert sha(Path(__file__))==reg['driver_sha256'];results=[]
 for target in reg['targets']:
  matches=[r for r in s['rows']if r['initial']and r['mode']=='broadcast'and all(r[k]==target[k]for k in ('case','pattern','policy'))]
  result=dict(target,status='missing')
  if matches:
   assert len(matches)==1;r=matches[0];assert r['matrix_hashes']==target['matrix_hashes'];observed=r['local_cycles'][target['pe']];error=observed-target['predicted_cycles']
   result.update(status='measured',case_status=r['case_status'],observed_cycles=observed,residual=error,relative_residual=error/observed,within_one_percent=abs(error/observed)<=.01)
  results.append(result)
 measured=[r for r in results if r['status']=='measured']
 output=dict(results=results,measured=len(measured),missing=len(results)-len(measured),within_one_percent=sum(r['within_one_percent']for r in measured),max_absolute_relative_residual=max((abs(r['relative_residual'])for r in measured),default=None))
 (ROOT/'local-work-model-results.json').write_text(json.dumps(output,indent=2)+'\n');print({k:v for k,v in output.items()if k!='results'})
if __name__=='__main__':main()
