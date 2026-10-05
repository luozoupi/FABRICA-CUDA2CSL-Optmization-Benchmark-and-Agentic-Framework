# Predictions tested on larger inputs

These predictions were saved before the target timing checkpoints appeared. The full registrations identify calibration inputs, excluded development evidence, coefficients, target cases, and acceptance rules. They are conditional models of this implementation on SDK 2.10.1; they do not measure physical WSE instruction latency. Missing observations stay missing, and validated records from a later timeout retain failed workflow status.

## Additional B-distribution time

The saved hypothesis predicts broadcast-mode root time minus resident-mode root time as twice the number of B payload words minus four cycles. Its single calibration point is the 16×16 four-PE case; a prior 64×64 development smoke was disclosed but excluded from fitting. No coefficient has been adjusted using the following targets.

| Target | Predicted extra cycles | Observed extra cycles | Residual | Suite status |
|---|---:|---:|---:|---|
| `weak-m64-k64-n64-p16-d3-full` | 896 | 898 | 2 | pass |
| `strong-m64-k64-n64-p4-d3-full` | 896 | 898 | 2 | pass |
| `density-m64-k64-n64-p4-d8-full` | 2,176 | 2178 | 2 | pass |
| `density-m64-k64-n64-p16-d8-full` | 2,176 | 2178 | 2 | pass |
| `weak-m16-k64-n64-p4-d3-full` | 896 | 898 | 2 | pass |
| `density-m64-k64-n64-p64-d8-full` | 2,176 | 2178 | 2 | pass |
| `strong-m64-k64-n64-p16-d3-full` | 896 | 898 | 2 | pass |
| `weak-m256-k64-n64-p64-d3-full` | 896 | 898 | 2 | pass |
| `strong-m256-k256-n256-p4-d3-full` | 3,584 | — | — | missing |
| `strong-m64-k64-n64-p64-d3-full` | 896 | 898 | 2 | pass |
| `strong-m256-k256-n256-p16-d3-full` | 3,584 | — | — | missing |
| `strong-m256-k256-n256-p64-d3-full` | 3,584 | — | — | missing |

9/12 targets have measurements; 0 match the exact saved prediction. Every nonzero residual is retained. A close payload relationship does not identify a branch, packet, or clock-alignment cause for the residual. These mode differences are not assumed to be additive shares of total runtime.

## Output construction at fixed candidate-product count

For the one-PE 256×256 full-accumulator case, the banded and uniform inputs each generate 2,304 candidate products, but 1,280 and 2,268 structural output entries. The frozen prediction is that the uniform input takes 24,700 more root cycles, using the 25-cycle-per-additional-output contrast observed at 64×64. This is a within-build comparison, not a universal store cost.

Target status: **missing**. Observed difference: **unavailable**; residual: **unavailable**; suite status: **missing**.

## Local computation from source work counts

An ordinary least-squares model uses one constant, assigned row count, row count times output width, local A nonzeros, candidate products, and structural output entries. Calibration uses 192 PE median durations from completed full-accumulator runs at sizes 16 and 64. Each PE observation has equal weight. Those PEs and matrix families are correlated; the observation count is not an independent statistical sample size.

| Work feature | Frozen coefficient |
|---|---:|
| Constant | 51.76456581 |
| Assigned rows | 87.56503154 |
| Assigned rows × output width | 33.26615878 |
| Local A nonzeros | 44.00703206 |
| Candidate products | 44.98394290 |
| Structural output entries | 25.03828571 |

Calibration RMS error is 11.27 cycles and maximum absolute error is 86.84 cycles. The saved coefficients predict 339 PE observations at size 256. No larger-size measurements were available at registration.

Measured targets: **0/339**; missing: **339**; within 1% relative error: **0/0**.


The output count is obtained from the independent oracle for explanation; calculating it is not free preprocessing in a production predictor. B rows all have the same degree here, so local A nonzeros can be recovered from candidate products divided by that degree. That shortcut is invalid when B-row lengths vary.

The model predicts the locally timed computation only. It excludes broadcast, completion waiting and reduction. Its coefficients must not be interpreted as measured instruction costs or causal runtime percentages. A prediction can be accurate while merging several mechanisms into one correlated term. The saved per-PE residuals are in `local-work-model-results.json`.
