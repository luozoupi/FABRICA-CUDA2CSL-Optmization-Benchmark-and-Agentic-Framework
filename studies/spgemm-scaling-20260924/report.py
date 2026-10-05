"""Generate comparison tables from audited complete cases; never fill missing timings."""
import json,statistics
from pathlib import Path
ROOT=Path(__file__).resolve().parent
s=json.loads((ROOT/'summary.json').read_text());rows=[r for r in s['rows']if r['initial']]
def selected(**kwargs):return [r for r in rows if all(r[k]==v for k,v in kwargs.items())]
def status(r):return '†' if r.get('case_status')!='pass' or r.get('baseline_case_status') not in (None,'pass') else ''
def comparison_status(x):return '†'if x['case_status']!='pass' or x['reference_case_status']!='pass'else ''
def cycle(x):return '—'if x is None else f'{x:,.0f}'
def speed(x):return '—'if x is None else f'{x:.2f}×'
lines=['# SpGEMM matrix-size and PE sweep','',
'Executed on the **NVIDIA GPU node with Cerebras SDK 2.10.1**, targeting WSE-3 simulation. These are complete sparse A×B products with distributed CSR output. This report measures real inter-PE broadcast and completion communication as well as local computation. No model/API calls or physical WSE/GPU timings are included. Workflow completion status and validated partial timings are reported separately.','',
 f"Status: **{s['case_statuses'].get('pass',0)}/{s['registered_cases']} configurations passed**; {s['case_statuses']}. Verified {s['verified_distributed_launches']:,} distributed numerical launches, representing {s['verified_PE_numerical_results']:,} PE numerical results, plus {s['verified_communication_controls']:,} communication-only controls. These are repeated launches of synthetic inputs, not independent applications or model successes.",'',
f"Completed-attempt accounting: **{s.get('completed_attempt_statuses',s['case_statuses'])}**. {len(s.get('additional_attempts',[]))} additional interrupted attempt(s) are retained separately from the 28 configuration outcomes; see [recovery record](RECOVERY.md). Unsupervised observations are excluded from the primary timing tables.",'',
f"Queue coordination failures before SDK launch: **{len(s.get('coordination_failures',[]))}**; recorded admission retries under `queue-admission-v2`: **{len(s.get('admission_events',[]))}**. The queue recovery changes pre-launch waiting only; compiler/simulator watchdogs and frozen measurements remain fixed. See [administrative revision](queue-recovery-registration.json).",'',
'[Interactive PE comparison](explorer.html) · [Scaling figure (PDF)](scaling.pdf) · [Scaling figure (PNG)](scaling.png)','',
'## What is timed','',
'Each PE owns complete output rows. The root broadcasts sparse B along the top row and down columns; every PE computes its assigned rows and returns a unit completion acknowledgement. The root verifies all P acknowledgements and measures the interval on its own clock. Local compute times use each PE’s own start/end pair. No timing subtracts clocks from different PEs. [TIMING.md](TIMING.md) gives the exact boundaries, including the untimed acknowledgement-buffer resets and telemetry stores.','',
'```mermaid','flowchart LR','  H[Host: pack and distribute A rows] --> R[Root: start timer]','  R --> X[Broadcast B along top row]','  X --> Y[Broadcast B down columns]','  Y --> C[Each PE: discover and emit its CSR rows]','  C --> A[Column completion reductions]','  A --> Z[Top-row reduction to root]','  Z --> T[Root: stop timer and verify P acknowledgements]','```','',
'The **broadcast** interval includes B distribution, local computation, completion waiting and reductions. The **resident** control sends a one-word start token while retaining the same computation and completion protocol. A separate communication-only control skips the kernel. These intervals can overlap work across PEs, so their differences are not asserted to be additive instruction or communication percentages. Packing, host transfers, library initialization, and global CSR gathering are excluded from device cycles.','',
'## Strong scaling: identical matrices across PE counts','',
'Uniform inputs have three nonzeros per row in A and B. The table uses the full-row accumulator and the first unchanged-input session. All cross-PE comparisons have matching global matrix hashes. Speedup is relative to the matching one-PE communication-inclusive interval.','',
'| Matrix size | PEs | Root interval, cycles | Max local compute, cycles | Resident root, cycles | Speedup | Efficiency |','|---|---:|---:|---:|---:|---:|---:|']
for r in sorted(selected(group='strong',variant='full',pattern='uniform',policy='row_blocks',mode='broadcast'),key=lambda x:(x['N'],x['P'])):
 resident=next(iter(selected(group='strong',N=r['N'],P=r['P'],variant='full',pattern='uniform',policy='row_blocks',mode='resident')),dict(root_cycles=None))
 lines.append(f"| {r['N']}×{r['N']}{status(r)} | {r['P']} | {cycle(r['root_cycles'])} | {cycle(r['local_max'])} | {cycle(resident['root_cycles'])} | {speed(r['strong_speedup'])} | {'—'if r['strong_efficiency']is None else format(r['strong_efficiency'],'.1%')} |")
lines+=['','A dagger (†) marks a timing record or one-PE baseline from a suite that later hit the unchanged watchdog. Such rows contain complete validated repetitions, but that workflow still counts as failed; see `partial-timing-policy.json`. Raw minima, maxima, and all three timing repetitions are retained in `timings.csv` and `measurements.json.gz`. Repetition ranges describe simulator repeatability on these inputs; they are not confidence intervals across a population of matrices. The one-PE build uses a local callback adapter because the installed collective library fails to compile a dimension of one. Its stage sequence is retained and no inter-PE traffic is claimed.','',
'## Row assignment and indivisible work','',
'The skewed input clusters long rows and empty rows. A deterministic assignment balances candidate-product counts while retaining the same maximum number of rows per PE. Rows remain indivisible. “Compute imbalance” is maximum divided by mean per-PE local duration; product imbalance is a separate structural quantity.','',
'| Size | PEs | Equal-row blocks, cycles | Balanced rows, cycles | Speedup | Compute imbalance, before → after |','|---|---:|---:|---:|---:|---|']
for x in s['comparisons']:
 if x['kind']=='partition'and x['mode']=='broadcast'and x['case'].endswith('-full'):
  lines.append(f"| {x['N']}{comparison_status(x)} | {x['P']} | {cycle(x['blocks_cycles'])} | {cycle(x['balanced_cycles'])} | {x['speedup_balanced']:.2f}× | {x['blocks_compute_imbalance']:.2f} → {x['balanced_compute_imbalance']:.2f} |")
lines+=['','## Accumulator size','',
'The bounded accumulator has four slots at size 16 and sixteen slots at sizes 64 and 256. It repeats sparse traversal for every output-column tile. The table compares the same uniform matrices, PE grids, row assignments, and broadcast timing scope. A ratio above one means the bounded implementation is slower.','',
'| Size | PEs | Full-row cycles | Bounded cycles | Bounded / full-row | Accumulator bytes, full → bounded |','|---|---:|---:|---:|---:|---|']
for x in s['comparisons']:
 if x['kind']=='accumulator'and x['pattern']=='uniform'and x['policy']=='row_blocks'and x['mode']=='broadcast':
  w=4 if x['N']==16 else 16
  lines.append(f"| {x['N']}{comparison_status(x)} | {x['P']} | {cycle(x['full_cycles'])} | {cycle(x['tiled_cycles'])} | {x['ratio_tiled_over_full']:.2f}× | {6*x['N']} → {6*w} |")
lines+=['','Accumulator bytes describe two scratch arrays only. Declared input/output arrays, collective code, other static allocations, and runtime stack use also matter. `summary.json` retains each unique application ELF’s allocated sections below the 48-KiB SRAM boundary and their sizes; one emitted ELF can be loaded onto several PEs, each with its own local code/data allocation. These static section sums do not measure peak dynamic stack use. Hardware configuration-register sections are excluded.','',
'## Weak scaling and density control','',
'Weak scaling fixes K=N=64, degree three, and four output rows per PE. It increases A’s height with the PE count and keeps a full copy of B on each PE. The total B replication therefore grows with P, even though the per-PE B allocation stays fixed. This is a row-wise rectangular weak-scaling experiment.','',
'| A shape × B shape | PEs | Products / PE | Root cycles | Max local compute | Resident root cycles |','|---|---:|---:|---:|---:|---:|']
for r in sorted(selected(group='weak',variant='full',pattern='uniform',policy='row_blocks',mode='broadcast'),key=lambda x:x['P']):
 rr=next(iter(selected(group='weak',P=r['P'],pattern='uniform',policy='row_blocks',mode='resident')),dict(root_cycles=None))
 lines.append(f"| {r['M']}×64 · 64×64{status(r)} | {r['P']} | {r['products']/r['P']:.0f} | {cycle(r['root_cycles'])} | {cycle(r['local_max'])} | {cycle(rr['root_cycles'])} |")
lines+=['','Density control at size 64 compares degree three with degree eight using the full-row accumulator. The output size is discovered by the kernel; output capacity uses a conservative candidate-product bound, not a precomputed output pattern.','',
'| Degree | Input density | PEs | Products | Output entries | Root cycles |','|---|---:|---:|---:|---:|---:|']
for degree,group in ((3,'strong'),(8,'density')):
 for r in sorted(selected(group=group,N=64,degree=degree,variant='full',pattern='uniform',policy='row_blocks',mode='broadcast'),key=lambda x:x['P']):
  lines.append(f"| {degree}{status(r)} | {degree/64:.2%} | {r['P']} | {r['products']:,} | {r['output_nnz']:,} | {cycle(r['root_cycles'])} |")
lines+=['','## Correctness and retained failures','',
'An independent sparse FP64 dictionary oracle checks the complete numerical result and structural occupancy, including cancellation to zero. The oracle was separately checked against dense FP64 multiplication on 36 input cases. Every launch checks row pointers, sorted column indices, values, output counts, capacity status and guards. Receiver B buffers are poisoned at the start of each session and read back after broadcast. Changed/restored sessions verify repeated use.','']
for c in s['cases']:
 if c['status']!='pass':lines.append(f"- `{c['id']}`: **{c['status']}**. See its retained phase record/log; no performance value is filled in.")
lines+=['','Three development compile failures are retained separately: CSL array initialization syntax, the installed collective library’s one-PE switch-case error, and a rejected conditional module-import expression while implementing the local adapter. The successful one/four/sixteen-PE smoke cases are excluded from registered performance tables.','',
'## Evidence and next measurements','',
'These experiments test synthetic matrices up to 256, at most 64 simulated PEs, one row-ownership scheme, and replicated B. They do not establish physical WSE latency, production-scale SpGEMM performance, or model/agent gains. A stronger distributed implementation would also test partitioned B, splitting exceptionally costly output rows, and the storage/preparation/communication costs of those choices.','',
'Artifacts: [interpretation](ANALYSIS.md), [registered predictions](MODELS.md), [memory accounting](MEMORY.md), [protocol](PROTOCOL.md), [raw timing table](timings.csv), [audited summary](summary.json), and [hardware-node handoff](HANDOFF.md). Sources, compiler/runtime identities, hashes, failures, and compact observations are published with the study. Original builds and full per-case records remain at `/home/USER/spgemm-scaling-20260924`.','']
(ROOT/'README.md').write_text('\n'.join(lines))
print('Generated report:',s['case_statuses'])
