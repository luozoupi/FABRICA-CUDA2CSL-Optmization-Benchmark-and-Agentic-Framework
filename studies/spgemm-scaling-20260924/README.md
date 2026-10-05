# SpGEMM matrix-size and PE sweep

Executed on the **NVIDIA GPU node with Cerebras SDK 2.10.1**, targeting WSE-3 simulation. These are complete sparse A×B products with distributed CSR output. This report measures real inter-PE broadcast and completion communication as well as local computation. No model/API calls or physical WSE/GPU timings are included. Workflow completion status and validated partial timings are reported separately.

Status: **21/28 configurations passed**; {'pass': 21, 'pending': 7}. Verified 784 distributed numerical launches, representing 13,456 PE numerical results, plus 84 communication-only controls. These are repeated launches of synthetic inputs, not independent applications or model successes.

Completed-attempt accounting: **{'pass': 21, 'interrupted_supervision': 1}**. 1 additional interrupted attempt(s) are retained separately from the 28 configuration outcomes; see [recovery record](RECOVERY.md). Unsupervised observations are excluded from the primary timing tables.

Queue coordination failures before SDK launch: **1**; recorded admission retries under `queue-admission-v2`: **0**. The queue recovery changes pre-launch waiting only; compiler/simulator watchdogs and frozen measurements remain fixed. See [administrative revision](queue-recovery-registration.json).

[Interactive PE comparison](explorer.html) · [Scaling figure (PDF)](scaling.pdf) · [Scaling figure (PNG)](scaling.png)

## What is timed

Each PE owns complete output rows. The root broadcasts sparse B along the top row and down columns; every PE computes its assigned rows and returns a unit completion acknowledgement. The root verifies all P acknowledgements and measures the interval on its own clock. Local compute times use each PE’s own start/end pair. No timing subtracts clocks from different PEs. [TIMING.md](TIMING.md) gives the exact boundaries, including the untimed acknowledgement-buffer resets and telemetry stores.

```mermaid
flowchart LR
  H[Host: pack and distribute A rows] --> R[Root: start timer]
  R --> X[Broadcast B along top row]
  X --> Y[Broadcast B down columns]
  Y --> C[Each PE: discover and emit its CSR rows]
  C --> A[Column completion reductions]
  A --> Z[Top-row reduction to root]
  Z --> T[Root: stop timer and verify P acknowledgements]
```

The **broadcast** interval includes B distribution, local computation, completion waiting and reductions. The **resident** control sends a one-word start token while retaining the same computation and completion protocol. A separate communication-only control skips the kernel. These intervals can overlap work across PEs, so their differences are not asserted to be additive instruction or communication percentages. Packing, host transfers, library initialization, and global CSR gathering are excluded from device cycles.

## Strong scaling: identical matrices across PE counts

Uniform inputs have three nonzeros per row in A and B. The table uses the full-row accumulator and the first unchanged-input session. All cross-PE comparisons have matching global matrix hashes. Speedup is relative to the matching one-PE communication-inclusive interval.

| Matrix size | PEs | Root interval, cycles | Max local compute, cycles | Resident root, cycles | Speedup | Efficiency |
|---|---:|---:|---:|---:|---:|---:|
| 16×16 | 1 | 21,718 | 21,673 | 21,718 | 1.00× | 100.0% |
| 16×16 | 4 | 7,684 | 5,510 | 7,460 | 2.83× | 70.7% |
| 16×16 | 16 | 3,649 | 1,430 | 3,425 | 5.95× | 37.2% |
| 64×64 | 1 | 190,071 | 190,026 | 190,071 | 1.00× | 100.0% |
| 64×64 | 4 | 50,464 | 47,616 | 49,566 | 3.77× | 94.2% |
| 64×64 | 16 | 14,853 | 11,969 | 13,955 | 12.80× | 80.0% |
| 64×64 | 64 | 6,017 | 3,026 | 5,119 | 31.59× | 49.4% |

A dagger (†) marks a timing record or one-PE baseline from a suite that later hit the unchanged watchdog. Such rows contain complete validated repetitions, but that workflow still counts as failed; see `partial-timing-policy.json`. Raw minima, maxima, and all three timing repetitions are retained in `timings.csv` and `measurements.json.gz`. Repetition ranges describe simulator repeatability on these inputs; they are not confidence intervals across a population of matrices. The one-PE build uses a local callback adapter because the installed collective library fails to compile a dimension of one. Its stage sequence is retained and no inter-PE traffic is claimed.

## Row assignment and indivisible work

The skewed input clusters long rows and empty rows. A deterministic assignment balances candidate-product counts while retaining the same maximum number of rows per PE. Rows remain indivisible. “Compute imbalance” is maximum divided by mean per-PE local duration; product imbalance is a separate structural quantity.

| Size | PEs | Equal-row blocks, cycles | Balanced rows, cycles | Speedup | Compute imbalance, before → after |
|---|---:|---:|---:|---:|---|
| 16 | 4 | 11,187 | 7,942 | 1.41× | 1.75 → 1.12 |
| 16 | 16 | 6,172 | 6,172 | 1.00× | 2.95 → 2.95 |
| 64 | 4 | 69,790 | 50,323 | 1.39× | 1.41 → 1.00 |
| 64 | 16 | 27,607 | 15,911 | 1.74× | 2.08 → 1.09 |
| 64 | 64 | 9,223 | 9,223 | 1.00× | 2.10 → 2.10 |

## Accumulator size

The bounded accumulator has four slots at size 16 and sixteen slots at sizes 64 and 256. It repeats sparse traversal for every output-column tile. The table compares the same uniform matrices, PE grids, row assignments, and broadcast timing scope. A ratio above one means the bounded implementation is slower.

| Size | PEs | Full-row cycles | Bounded cycles | Bounded / full-row | Accumulator bytes, full → bounded |
|---|---:|---:|---:|---:|---|
| 16 | 1 | 21,718 | 33,376 | 1.54× | 96 → 24 |
| 16 | 4 | 7,684 | 10,601 | 1.38× | 96 → 24 |
| 64 | 1 | 190,071 | 278,057 | 1.46× | 384 → 96 |
| 64 | 4 | 50,464 | 73,943 | 1.47× | 384 → 96 |
| 64 | 16 | 14,853 | 20,727 | 1.40× | 384 → 96 |
| 64 | 64 | 6,017 | 7,484 | 1.24× | 384 → 96 |

Accumulator bytes describe two scratch arrays only. Declared input/output arrays, collective code, other static allocations, and runtime stack use also matter. `summary.json` retains each unique application ELF’s allocated sections below the 48-KiB SRAM boundary and their sizes; one emitted ELF can be loaded onto several PEs, each with its own local code/data allocation. These static section sums do not measure peak dynamic stack use. Hardware configuration-register sections are excluded.

## Weak scaling and density control

Weak scaling fixes K=N=64, degree three, and four output rows per PE. It increases A’s height with the PE count and keeps a full copy of B on each PE. The total B replication therefore grows with P, even though the per-PE B allocation stays fixed. This is a row-wise rectangular weak-scaling experiment.

| A shape × B shape | PEs | Products / PE | Root cycles | Max local compute | Resident root cycles |
|---|---:|---:|---:|---:|---:|
| 4×64 · 64×64 | 1 | 36 | 11,931 | 11,886 | 11,931 |
| 16×64 · 64×64 | 4 | 36 | 14,811 | 11,969 | 13,913 |
| 64×64 · 64×64 | 16 | 36 | 14,853 | 11,969 | 13,955 |
| 256×64 · 64×64 | 64 | 36 | 14,963 | 11,969 | 14,065 |

Density control at size 64 compares degree three with degree eight using the full-row accumulator. The output size is discovered by the kernel; output capacity uses a conservative candidate-product bound, not a precomputed output pattern.

| Degree | Input density | PEs | Products | Output entries | Root cycles |
|---|---:|---:|---:|---:|---:|
| 3 | 4.69% | 1 | 576 | 549 | 190,071 |
| 3 | 4.69% | 4 | 576 | 549 | 50,464 |
| 3 | 4.69% | 16 | 576 | 549 | 14,853 |
| 3 | 4.69% | 64 | 576 | 549 | 6,017 |
| 8 | 12.50% | 1 | 4,096 | 2,686 | 415,976 |
| 8 | 12.50% | 4 | 4,096 | 2,686 | 108,266 |
| 8 | 12.50% | 16 | 4,096 | 2,686 | 30,368 |
| 8 | 12.50% | 64 | 4,096 | 2,686 | 10,924 |

## Correctness and retained failures

An independent sparse FP64 dictionary oracle checks the complete numerical result and structural occupancy, including cancellation to zero. The oracle was separately checked against dense FP64 multiplication on 36 input cases. Every launch checks row pointers, sorted column indices, values, output counts, capacity status and guards. Receiver B buffers are poisoned at the start of each session and read back after broadcast. Changed/restored sessions verify repeated use.

- `strong-m256-k256-n256-p1-d3-full`: **pending**. See its retained phase record/log; no performance value is filled in.
- `strong-m256-k256-n256-p4-d3-full`: **pending**. See its retained phase record/log; no performance value is filled in.
- `strong-m256-k256-n256-p4-d3-tiled`: **pending**. See its retained phase record/log; no performance value is filled in.
- `strong-m256-k256-n256-p16-d3-full`: **pending**. See its retained phase record/log; no performance value is filled in.
- `strong-m256-k256-n256-p16-d3-tiled`: **pending**. See its retained phase record/log; no performance value is filled in.
- `strong-m256-k256-n256-p64-d3-full`: **pending**. See its retained phase record/log; no performance value is filled in.
- `strong-m256-k256-n256-p64-d3-tiled`: **pending**. See its retained phase record/log; no performance value is filled in.

Three development compile failures are retained separately: CSL array initialization syntax, the installed collective library’s one-PE switch-case error, and a rejected conditional module-import expression while implementing the local adapter. The successful one/four/sixteen-PE smoke cases are excluded from registered performance tables.

## Evidence and next measurements

These experiments test synthetic matrices up to 256, at most 64 simulated PEs, one row-ownership scheme, and replicated B. They do not establish physical WSE latency, production-scale SpGEMM performance, or model/agent gains. A stronger distributed implementation would also test partitioned B, splitting exceptionally costly output rows, and the storage/preparation/communication costs of those choices.

Artifacts: [interpretation](ANALYSIS.md), [registered predictions](MODELS.md), [memory accounting](MEMORY.md), [protocol](PROTOCOL.md), [raw timing table](timings.csv), [audited summary](summary.json), and [hardware-node handoff](HANDOFF.md). Sources, compiler/runtime identities, hashes, failures, and compact observations are published with the study. Original builds and full per-case records remain at `/home/USER/spgemm-scaling-20260924`.
