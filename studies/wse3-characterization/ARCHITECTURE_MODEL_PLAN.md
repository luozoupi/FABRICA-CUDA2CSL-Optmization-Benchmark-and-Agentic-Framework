# WSE architecture experiments and predictive workload modelling

Updated 2026-09-16. This is the research objective behind the numerical viewers:
understand how one PE and a mesh execute AI workloads, infer testable architectural
rules, and use those rules to predict performance for new workloads and mappings.
The following experiments and model extensions are planned, not completed results.

Implementation update, 2026-09-16: experiment 1 has a completed
[two-PE pilot](microbench/readiness/README.md) and
[interactive comparison](results/readiness/readiness.html). Delayed receive
preserves two-cycle router intervals for 1–8 words but stretches later router
intervals in the 16-word case. The larger matrix and subsequent experiments
below remain future work.

Research update, 2026-09-17: the
[official-materials comparison](ARCHITECTURE_REVIEW.md) adds the WSE-3 core/cache
diagram, an installed SDK capability audit and
[retrospective primitive model checks](results/architecture-review/estimates.json).
The 64-element vector Add and controlled hazard cases follow conditional rules;
delayed 16-word transfers and small copy/fill loops expose where simpler models
fail. These checks are a starting point for experiment 2, not validation of a
complete workload predictor. Add cache-access characterization only once the
supported mechanism is identified, and keep primitive parameters specific to
instruction form and compiler-generated schedule.

## Start from the retained evidence

| Available foundation | What it supports | Next unresolved question |
|---|---|---|
| [GEMM/GEMV input inspector](viewer/INPUTS.md) | PE-local input ownership, packing, observed operands, partials and final outputs | How does changing reuse or packing change execution cost? |
| [Datapath review](DATAPATH_REVIEW.md) | Functional memory/register/descriptor/arithmetic paths and controlled dependency spacing | Which rules generalize across instruction forms and optimized code? |
| [Hop review](PE_HOP_REVIEW.md) | Exact word lineage through send, routers, receive and arithmetic | How much delay comes from distance, receiver readiness or competing traffic? |
| [Runtime synthesis](tools/runtime_model.py) and [fit](tools/runtime_fit.py) | A trace-derived compute/traffic baseline and whole-program error measurements | Can costs be predicted without the target execution trace? |
| [Sparse walkthrough](SPARSE_VISUALIZATION.md) | Recorded SpMV values and labelled source reconstructions for SpMM/SpGEMM | How do sparsity distribution, index overhead and imbalance affect measured runtime? |

Use the existing model as a baseline. Its traffic and dispatch features come from
the execution being explained; its inferred relay dependencies and fitted offset
are not independently established architectural constants. A good fit alone does
not identify a physical mechanism. Keep simulator-derived parameters separate
from silicon-derived parameters, including where the older model combines them.

## Follow a value and account for its time

The linked presentation should support this chain for each selected tensor value:

`global index → owning PE/local slot → observed operand → operation/result →
send → router observations → receive → subsequent use → final output`

Each connection records the run/build identity, evidence locator, clock domain
and confidence: observed, source-derived, inferred, predicted or unknown. Equal
numbers alone cannot establish lineage. Packet identities apply within their
capture; active relays create new identities that require an explicit dataflow
binding. Multicast needs branching paths, including transit PEs.

Beside each time layer, show inputs, received values, accumulator state and the
last observed operation. Add measured intervals and model predictions with their
residuals. An unaccounted interval stays unexplained until a controlled experiment
supports an attribution. A router observation is not an SRAM write, a dispatch
count is not utilization, and simulator stage labels do not reveal physical stages.

## Experiment sequence

| Order | Controlled comparison | Measurements and decision |
|---|---|---|
| 1. Two-PE readiness | Fixed f32 payload and route; early receive versus delayed receive; vary message length separately | Bind every word end to end. Compare send/receive dispatches, first/last router observations and final readback. Test whether the long intervals in tiny GEMV track receiver readiness. |
| 2. Single-PE execution | Fixed work with dependent versus independent arithmetic; scalar versus optimized DSD; copy/fill/read/write; length, stride and alignment | Separate setup, dependency latency and sustained element rate. Verify generated instructions and packing; reuse existing sweeps before adding cases. |
| 3. Route scaling | Passive routes of 1, 2 and 4 hops, straight versus turning; then a separate active relay | Measure all transit observations and distinguish message startup, stream rate, path effects and relay computation. |
| 4. Resource interaction | Compute alone, transfer alone, concurrent compute/transfer; then controlled competing flows | Test overlap and interference with matched work. Record actual launch/completion boundaries; do not derive queue capacity from arrival counts. |
| 5. Dense composition | Same global GEMM/GEMV on one PE and 2×2 PEs; vary local tiles and then mesh size | Predict phase and total times, identify the critical dependency path, and check whether the predicted faster mapping is faster. |
| 6. Varied applications | Reductions, softmax/RMSNorm, attention components, SpMV/SpMM/SpGEMM, stencil/graph patterns | Test reuse, reduction, irregular access and imbalance separately before composing larger applications. Sparse runtime claims require captured execution, beyond numerical reconstruction. |

For experiment 1, begin with the hop review's proposed lengths 1, 4, 5, 8 and
16 words and receiver delay treatments 0, 16, 64 and 256. These are requested
treatments: use the recorded dispatch cycles to determine the actual delay.
Check disassembly so the delay construction has not been optimized away. Use
signed sentinels with nonzero low payload halves, preserving exact uint32 bits.
Hold route, color, sender code and payload fixed across readiness treatments.
These comparisons can constrain a flow-control hypothesis without proving a
particular queue implementation or depth.

Tiny scalar teaching programs establish correctness and lineage. Optimized
performance variants need their own builds and captures, including history-free
controls; timings cannot be transplanted between those executions. Match numerical
results under an explicit rounding policy when changing precision or FMA usage.

## Model to build

Predict from workload dimensions, sparsity structure, PE placement, compiled
instruction/descriptor structure and separately calibrated costs. Do not use the
held-out target trace's event counts or timestamps as prediction inputs.

Represent local operations, transfers and synchronization as a dependency graph
with resource constraints. Use measured startup costs and sustained rates within
their tested regimes, and explicit operation dependencies for readiness. Compute
completion from the resulting schedule: summing compute and communication would
double-count overlap, while taking one global maximum would lose serialization.
Where resource sharing is unknown, compare alternative models or report bounds.

Keep host upload/download, device initialization, kernel phases and completion
separate. Use identical measurement boundaries for prediction and observation.
Same-PE elapsed TSC measurements avoid cross-PE clock subtraction; multi-PE
hardware timing needs a validated synchronization procedure and uncertainty.
The simulator trace clock is a separate clock domain.

For each prediction retain parameter provenance and validity ranges, predicted
phase/total cycles, measured cycles, signed residual and absolute relative error.
Report absolute cycle errors for short phases too. Identify critical-path
operations and candidate limiting resources; call a bottleneck established only
when a controlled change produces the expected performance response.

## Validation and completion criteria

1. Preserve the current exact-value checks and reject mismatched build/trace
   bindings. Account for every scoped numeric transfer, explicitly reporting
   ambiguous or missing evidence.
2. Fit primitive costs on calibration experiments; freeze parameters before
   testing unseen lengths, tile sizes and placements. Hold out whole workload
   families as a stronger generalization check.
3. Compare against the existing runtime baseline on matching measurement windows.
   Report per-case errors and failures as well as aggregate error. Choose an
   application-specific error budget before judging a model successful.
4. Validate selected predictions with matched hardware measurements. Keep
   instrumented and control builds distinct, retain raw timing words and trial
   order, and quantify variation rather than transferring simulator precision.
5. Demonstrate usefulness by predicting a mapping or implementation change,
   measuring it, and explaining both its value path and performance difference.

The two-PE readiness pilot and comparison view are available. Next refine the
observed transition with intermediate lengths/readiness offsets, then build a
calibrated single-PE model composed into tiny GEMM/GEMV. The pilot ran simulator
jobs only; appliance validation remains separate.
