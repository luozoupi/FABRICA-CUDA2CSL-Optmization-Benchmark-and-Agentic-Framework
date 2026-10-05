"""Report registered predictions without refitting or hiding missing observations."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parent
b=json.loads((ROOT/'broadcast-model-results.json').read_text());out=json.loads((ROOT/'output-model-results.json').read_text());reg=json.loads((ROOT/'local-work-model-registration.json').read_text());local=json.loads((ROOT/'local-work-model-results.json').read_text())
lines=['# Predictions tested on larger inputs','',
'These predictions were saved before the target timing checkpoints appeared. The full registrations identify calibration inputs, excluded development evidence, coefficients, target cases, and acceptance rules. They are conditional models of this implementation on SDK 2.10.1; they do not measure physical WSE instruction latency. Missing observations stay missing, and validated records from a later timeout retain failed workflow status.','',
'## Additional B-distribution time','',
'The saved hypothesis predicts broadcast-mode root time minus resident-mode root time as twice the number of B payload words minus four cycles. Its single calibration point is the 16×16 four-PE case; a prior 64×64 development smoke was disclosed but excluded from fitting. No coefficient has been adjusted using the following targets.','',
'| Target | Predicted extra cycles | Observed extra cycles | Residual | Suite status |','|---|---:|---:|---:|---|']
for r in b['results']:
 lines.append(f"| `{r['case']}` | {r['predicted_extra_cycles']:,} | {r.get('observed_extra_cycles','—')} | {r.get('residual','—')} | {r.get('case_status','missing')} |")
measured=[r for r in b['results']if r['status']=='measured'];exact=sum(r['residual']==0 for r in measured)
lines+=['',f'{len(measured)}/{len(b["results"])} targets have measurements; {exact} match the exact saved prediction. Every nonzero residual is retained. A close payload relationship does not identify a branch, packet, or clock-alignment cause for the residual. These mode differences are not assumed to be additive shares of total runtime.','',
'## Output construction at fixed candidate-product count','',
'For the one-PE 256×256 full-accumulator case, the banded and uniform inputs each generate 2,304 candidate products, but 1,280 and 2,268 structural output entries. The frozen prediction is that the uniform input takes 24,700 more root cycles, using the 25-cycle-per-additional-output contrast observed at 64×64. This is a within-build comparison, not a universal store cost.','',
 f"Target status: **{out['status']}**. Observed difference: **{out.get('observed_difference','unavailable')}**; residual: **{out.get('residual','unavailable')}**; suite status: **{out.get('case_status','missing')}**.",'',
'## Local computation from source work counts','',
'An ordinary least-squares model uses one constant, assigned row count, row count times output width, local A nonzeros, candidate products, and structural output entries. Calibration uses 192 PE median durations from completed full-accumulator runs at sizes 16 and 64. Each PE observation has equal weight. Those PEs and matrix families are correlated; the observation count is not an independent statistical sample size.','',
'| Work feature | Frozen coefficient |','|---|---:|']
for name,coef in zip(['Constant','Assigned rows','Assigned rows × output width','Local A nonzeros','Candidate products','Structural output entries'],reg['coefficients']):lines.append(f'| {name} | {coef:.8f} |')
lines+=['',f"Calibration RMS error is {reg['calibration_errors']['rms']:.2f} cycles and maximum absolute error is {reg['calibration_errors']['max_abs']:.2f} cycles. The saved coefficients predict 339 PE observations at size 256. No larger-size measurements were available at registration.",'',
 f"Measured targets: **{local['measured']}/339**; missing: **{local['missing']}**; within 1% relative error: **{local['within_one_percent']}/{local['measured']}**.",'']
if local['measured']:lines.append(f"Maximum absolute relative residual: **{100*local['max_absolute_relative_residual']:.4f}%**.")
lines+=['','The output count is obtained from the independent oracle for explanation; calculating it is not free preprocessing in a production predictor. B rows all have the same degree here, so local A nonzeros can be recovered from candidate products divided by that degree. That shortcut is invalid when B-row lengths vary.','',
'The model predicts the locally timed computation only. It excludes broadcast, completion waiting and reduction. Its coefficients must not be interpreted as measured instruction costs or causal runtime percentages. A prediction can be accurate while merging several mechanisms into one correlated term. The saved per-PE residuals are in `local-work-model-results.json`.','']
(ROOT/'MODELS.md').write_text('\n'.join(lines))
print('Wrote prediction report')
