# Sparse–sparse product trace pilot — 24 September 2026

Executed on the **NVIDIA GPU node with Cerebras SDK 2.10.1**, using the WSE-3 simulator. Two existing masked sparse-product binaries passed **72 new kernel launches**. Dynamic instruction and operand checks explain a workload-dependent reversal between sorted merging and nested matching. No API/model calls, new compilations, CUDA measurements, or physical WSE measurements were made.

The measured operation is **masked sparse A-transpose times A**, with a predetermined mask and fixed dense output/presence buffers. It is not general SpGEMM. The original microbenchmarks were generated deterministically, not by a model; these results are mechanism evidence, not agent improvement results. This extends the [SpMV/SpMM pilot](../sparse-trace-pilot-20260924/README.md).

## Contract, execution, and verification

Both programs use one application PE at fabric coordinate (4,1), within an 8×3 simulator fabric, and a 16×16 FP32 matrix A. For each requested position (i,j) where A[i,j] is nonzero, they compute:

```
C[i,j] = sum over k of A[k,i] × A[k,j]
```

Other positions remain zero. A separate presence buffer records whether the two sparse columns have any common index, even if their numerical sum cancels to zero. The host packs CSR of A-transpose, equivalent to CSC of A, so both input columns can be traversed as sorted contiguous index/value lists. Although the generic host records a dense B, these masked kernels do not use it.

Sorted merge advances through both column lists, updating C only on matching row indices. Nested matching checks every pair of stored indices and performs the same update on a match. These are comparisons of complete compiled implementations: merge uses 16-bit local index comparisons, while nested matching uses 32-bit equality. They are not a pure branch-only or index-width ablation. The host verifies that these small indices and offsets fit in 16 bits.

Each implementation runs banded, uniform, and skewed inputs in three sessions: original, changed values and column pattern, then restored original. Each session contains one warmup and three measured launches: 36 launches per implementation. All numerical results match the FP64 host oracle exactly; all structural presence buffers match the independent Boolean-product oracle. An additional set-intersection oracle in the trace auditor independently reconstructs every final numerical output and operation count. The skewed input exercises two cancelled output positions originally and six after the change. These limited small-integer cases do not establish general FP32 numerical robustness.

All 72 cycle counts and numerical output hashes match the original September 21 measurements. Repeated timings within each implementation/input/session are identical. Three timer controls per implementation each measure ten cycles; no overhead is subtracted. The time window includes output clearing, synchronous computation, and timestamp work. Packing, host transfers, and allocation are excluded. There is no inter-PE data movement in the timed kernel.

The audit uses the original compiled ELFs, without recompilation or inserted device instrumentation. It checks:

- Source, original observation, disassembly, and all ELF hashes.
- Every timed dispatch encoding against the application ELF.
- All 72 measured intervals against actual timestamp-read dispatch anchors, plus six timer-control intervals.
- Every equality-check count, merge less-than count, and useful-product count against an independent traversal of the saved input.
- All **10,128 scalar multiplication results and 10,128 scalar addition results** against their traced FP32 operands.
- Every recorded branch successor against the disassembly, allowing encoded unconditional jumps that have no separate dispatch event.
- Complete CTF streams, with no discarded events, and no SDK error diagnostics.

The simulator log reports SDK revision `8faf87a26e4ea7ca1816636218fe53dd94e4b34a`. Both SDK lock conventions were acquired and the simulations ran serially. Replay execution took approximately 137.8 and 136.6 seconds; queue waits were below a millisecond. These wall times include simulator/trace overhead and are not kernel latencies.

## Finding: index overlap changes the best implementation

Original-input medians, in simulator cycles:

| Input | Input nonzeros | Merge equality checks | Nested equality checks | Useful products, either method | Merge cycles | Nested cycles | Faster implementation |
|---|---:|---:|---:|---:|---:|---:|---|
| Banded | 48 | 148 | 432 | 112 | 16,941 | 19,376 | Merge, 1.14× |
| Uniform | 48 | 213 | 432 | 28 | 20,461 | 17,696 | Nested, 1.16× |
| Skewed | 72 | 321 | 1,332 | 288 | 30,237 | 43,088 | Merge, 1.43× |

Banded and uniform inputs have identical dimensions, nonzero count, **and every row and column degree: three**. Nevertheless, their algorithm ranking reverses. Merge performs fewer equality checks in all three cases, but this does not guarantee lower time.

The traces expose the difference. Moving from banded to uniform, merge's matching path runs 112 → 28 times, while its unequal-index path runs 36 → 185 times. It also executes more loop-bound checks, gathers, and pointer updates. In the emitted unequal-index path, the compiler selects which local pointer to increment and updates it through stack-address calculations and an indirect load/store sequence. The complete dispatch count rises from 10,730 to 13,261 despite the reduction in useful products. Nested matching's count falls from 10,805 to 9,713.

This is a useful distinction from the preceding SpMM experiment. In that experiment, contiguous output width could amortize descriptor setup. Here, finding matching indices and updating sparse traversal state are central costs. Merely counting nonzeros, products, or comparisons misses the compiled execution paths.

The changed-input sessions retain the reversal: merge/nested take 16,772/19,056 cycles for banded and 20,638/17,656 for uniform. They are replay checks on known cases, not a held-out evaluation of a learned selection rule.

## Where the extra merge cycles appear

For each timed dispatch, the auditor records the interval until the next dispatch, including the ending timestamp anchor. These intervals sum exactly to elapsed cycles. Grouping their differences by compiler source attribution gives:

| Merge, uniform minus banded | Change in dispatch-interval sum |
|---|---:|
| Unequal-index pointer-update path | +2,086 |
| Inner-loop bound/control source line | +1,449 |
| Two index-load source lines | +845 |
| Equality test and its conditional jump | +707 |
| Successful multiply/add, presence store, and both-pointer increment | −2,352 |
| Instructions without source attribution | +785 |
| **Total measured change** | **+3,520** |

For nested matching, equality-check count remains 432, and the reduction of 84 matching pairs removes 1,680 cycles from the dispatch timeline. This agrees with the observed 19,376 → 17,696 cycles. The saved audit retains PC-specific counts, branch successors, and interval histograms.

These are trace accounting identities, **not instruction latencies, retired-instruction CPI, stall counters, or causal runtime percentages**. The interval following an instruction can include dependent and intervening work. Compiler source attribution is also imperfect, as the unattributed group shows. These counts motivate a controlled transformation; they do not establish how much a rewrite will save on silicon.

A concrete next CSL experiment is to keep merge cursors in registers, reduce repeated bounds/address calculations, and inspect whether the emitted unequal-index path actually loses its stack updates. A second experiment would select merge versus short-list nested matching using sampled intersection/path statistics. Both require preprocessing cost and out-of-sample validation. Neither optimization has been implemented or claimed successful by this pilot.

## An element-level view on the PE

For the original banded matrix, column zero contains row indices `[0, 1, 15]` with values `[-2, 1, 1]`. The first requested output is C[0,0]. Its mathematical reduction is `4 + 1 + 1 = 6`.

In the measured merge launch, the first two scalar products and additions are:

| Operation | Dispatch cycle | Result cycle | Recorded operands/result |
|---|---:|---:|---|
| Multiply at PC 576 | 61,306 | 61,309 | (−2) × (−2) = 4 |
| Add at PC 582 | 61,311 | 61,314 | 0 + 4 = 4 |
| Multiply at PC 576 | 61,379 | 61,382 | 1 × 1 = 1 |
| Add at PC 582 | 61,384 | 61,387 | 4 + 1 = 5 |

These are actual simulator operand events from repetition one, not an animation estimate. The full result of six is independently checked by the host oracle. Traversal and addressing instructions between useful arithmetic explain why two three-cycle dispatch-to-result observations cannot be used as a performance model for the whole sparse operation. All operands and accumulations in this example reside on one PE; a distributed implementation must also supply the columns to their computation owners.

## What changes for general SpGEMM

General SpGEMM computes sparse A×B and must discover, combine, and store output entries whose structure is not already supplied by a mask. The existing fixed dense buffers avoid output capacity discovery, dynamic sparse allocation, compaction, and distributed ownership. The difference is substantial even for these tiny inputs:

| Input | Requested mask positions | Masked useful products | Full A-transpose×A products | Full structural output positions |
|---|---:|---:|---:|---:|
| Banded | 48 | 112 | 144 | 80 |
| Uniform | 48 | 28 | 144 | 80 |
| Skewed | 72 | 288 | 1,032 | 256 |

The full-product columns are **host-computed structural statistics**, not measured general-SpGEMM performance. The skewed input produces a structurally dense 16×16 result, despite having only 72 input nonzeros. Cancellation must not be confused with absent structure. A pruning policy, if used, must be declared consistently.

A WSE study of general SpGEMM should track candidate products per output row,

```
P_i = sum over k stored in A[i,:] of nnz(B[k,:])
```

as well as unique output columns, duplicate accumulation, peak row/tile accumulator size, and bytes communicated. Input nonzeros alone do not determine compute work or storage requirements.

Proposed WSE/CSL experiments, not results from this pilot:

| Challenge | Candidate implementation | Required measurement |
|---|---|---|
| Unknown output pattern and fill | Separate symbolic discovery/capacity checking from numerical accumulation | All phase times, overflow rate, output size, scratch capacity |
| Expensive short-list intersections | Compare nested, merge, and bounded bitmap/index lookup; select using matrix features | Executed paths, preparation cost, correctness on irregular indices |
| Repeated products for one output entry | Assign output rows/tiles to owning PEs; compare bounded dense, bitmap, and sparse accumulators | Duplicate count, local accesses, touched-entry clearing, emitted instruction cost |
| Long rows and uneven expansion | Partition by estimated candidate products and accumulator demand; split oversized rows with explicit reductions | Per-PE completion spread, communication/reduction cost, infeasible points |
| Operand distribution | Stream required B rows to owners and test bounded buffering/overlap | Bytes, backpressure, buffer occupancy, end-to-end completion |
| Repeated use of fixed sparsity | Reuse symbolic structure and routing where values alone change | Total cost over 1, 10, and 100 uses, including preparation and invalidation on pattern changes |

Any bounded accumulator needs a correct overflow path; truncating products is unacceptable. The original study plan keeps general SpGEMM outside the required seven-task expansion. This pilot supplies evidence and a separate experimental contract without changing those completion requirements.

## CUDA comparison and evidence boundary

A future general-SpGEMM comparator should use the same sparse A/B inputs and output contract, with explicit treatment of symbolic/work estimation, scratch allocation, numerical work, output assembly, and repeated-pattern reuse. NVIDIA documents work-estimation, memory-estimation, compute, and copy operations, and a chunked algorithm controlling intermediate-product memory in the [official cuSPARSE SpGEMM documentation](https://docs.nvidia.com/cuda/cusparse/#cusparsespgemm). Consult the documentation matching the installed CUDA version before implementing the harness; the linked current manual describes 13.4.

A masked one-PE CSL kernel and a full cuSPARSE product perform different work and cannot establish an architecture speedup by comparing their raw times. GE-SpMM is sparse×dense, so it is not a general-SpGEMM comparator. Report measured GPU and CS-3 latency separately from simulator cycle counts. This pilot adds no such cross-architecture performance ratio.

## Artifacts and reproduction

Reviewed framework base: `3b8ebd80b0452e9245fb50601975aa11b48c81c5` on `v2_0`. The sparse branch was `7413ed46fa0f572f4b46e7fd9b7056462a31a770`; the manuscript base was `bb7f61ad30873f64ebca758101f5e03d313c37d9`. This study does not edit the manuscript or change running model experiments.

Full local archive: `/home/USER/spgemm-trace-pilot-20260924`. Raw CTF traces total **2,419,839,913 bytes** and remain outside Git. Sources, original measured ELFs, observations, disassembly, logs, and all 72 full window analyses are retained locally. A separate local `replay-inputs.tar.gz` contains the original accepted build bundles for transfer to the hardware node; hashes and paths are in `evidence-manifest.json`. Compact results and compressed audit are committed, with source fixtures for inspection.

`registration.json` was written before the new replays. It explicitly says that these are known ranking results being replayed for explanation, not a newly discovered algorithm ranking or blind performance prediction. The preparation command was subsequently given path arguments for portability. Scripts assume the installed SDK launcher at `/home/USER/cs_sdk/cs_python`; adapt this path on another node.

To run again, copy the scripts into a fresh workspace, extract the original build bundle into a separate source directory, then use:

```bash
python3 prepare_replays.py --source-root /path/to/original-builds --output-root "$PWD"
python3 run_replays.py
python3 analyze_spgemm.py --root "$PWD" --trace-library /path/to/xkernel/studies/wse3-characterization
python3 summarize_evidence.py
```

The original compiler invocation, retained in the microbenchmark runner, is:

```bash
cslc layout.csl --arch=wse3 --fabric-dims=8,3 --fabric-offsets=4,1 --memcpy --channels=1 --width-west-buf=0 --width-east-buf=0 --out-routes -o out
```

Recompilation creates a new recorded build. Exact-binary replay uses the retained `out` directory instead. The analyzer intentionally requires the original source bundle and observation hashes; a fresh run must preserve that provenance, not substitute a later fast build.
