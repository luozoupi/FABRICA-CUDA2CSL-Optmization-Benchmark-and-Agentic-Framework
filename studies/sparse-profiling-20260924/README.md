# Sparse profiling review — 24 September 2026

Prepared on the **NVIDIA GPU node with Cerebras SDK**, without physical WSE-3 access. This contribution reviews the shared manuscript and adds an offline audit of retained simulator traces. No new model calls, compilation, simulation, or hardware measurements were performed.

## Reconciled state

| Repository | Reviewed remote revision |
|---|---|
| Framework, `v2_0` | `3264cfc3707b00aa3c0cc31788b1c974f74e4f44` |
| Framework, `sparse_ipdps` | `7413ed46fa0f572f4b46e7fd9b7056462a31a770` |
| Paper, `main` | `bb7f61ad30873f64ebca758101f5e03d313c37d9` |

The latest shared paper commit is dated September 23, 14:55:51 UTC. No later committed update was visible at this review. The clean local paper checkout was fast-forwarded from `d1f9e72` to `bb7f61a`; no manuscript prose was changed. Git establishes the shared revision, not the originating compute node. The WSE node remains the manuscript integrator.

The seven paper commits add expert comparisons, size transfer, three optimizer repetitions, compiler-feedback results, and hardware/simulator comparisons. The existing method already captures LLVM IR through an internal backend interceptor and disassembles the measured ELF. Additional static histograms alone would add little. The next contribution should connect a compiled change to an observed execution change and test the proposed explanation with a controlled transformation.

The [previous numerical audit](../sparse-progress-20260923/RESULTS.md) still applies:

- The 27 Luna workflows retained passing programs, but used 10–12 attempts. Keep this exploratory cohort separate from the fixed-budget study.
- Geometric mean speedup is 1.012 for sparse guidance versus existing feedback, and 0.972 for compiler feedback versus sparse guidance. Both reported intervals include one. The draft correctly acknowledges the absence of an aggregate benefit.
- None of the nine compiler-feedback cells has a committed hardware record in the reviewed summaries. Two of the 21 available reference/retained records have only two successful trials out of three. Statements about replaying every retained program and universal hardware success need these qualifications.
- The 81 passing transfer pairs use matrices already included in candidate acceptance. Describe these as acceptance-validation transfer until an untouched final-test split is evaluated.

## New verified result: instruction counts do not determine execution time

`profile_timed_windows.py` reanalyzes three retained, uninstrumented, one-PE FP32 GEMM builds from SDK 2.10.1. All multiply 16×16 matrices. Each trace contains one warmup and three measurements; all four windows have identical metrics within each implementation.

| Implementation | Simulator cycles | Dispatched instructions | Multiplications | Cycles/dispatch | Conventional FLOP/cycle |
|---|---:|---:|---:|---:|---:|
| Scalar i-j-k | 111,296 | 68,706 | 4,096 | 1.620 | 0.0736 |
| Row descriptor | 17,634 | 7,556 | 4,096 | 2.334 | 0.4646 |
| Column descriptor | 17,138 | 7,796 | 4,096 | 2.198 | 0.4780 |

Each descriptor implementation dispatches 256 FMAC instructions, producing 4,096 FP32 result elements. The scalar implementation dispatches 4,096 multiplies and 4,096 adds. Conventional work is 8,192 FLOPs per launch in all three cases. This comparison therefore includes instruction fusion as well as descriptor processing; it is not a pure descriptor-only ablation.

The row descriptor program is 6.31× faster than the scalar program even though its cycles/dispatch increases. The column descriptor program dispatches 240 more instructions than the row version, all additional shifts, but takes 496 fewer cycles. Its 16-element FMAC result spans range from 26 to 44 cycles, with median 26; the row version always spans 31 cycles. A result span runs from first to last result event and excludes preceding setup. These observations establish a difference in execution timing, but do **not** identify bank conflicts, scheduling, or overlap as its cause.

The row disassembly also contains twelve descriptor-configuration stores and six explicit NOP instructions per vector FMAC. Those instructions occur dynamically 256 times per launch. They are a concrete target for a descriptor-reuse experiment. Neither store counts nor NOP counts establish a percentage of runtime lost to setup. Earlier sparse experiments found that moving descriptor construction in CSL did not necessarily change the emitted loop; check the ELF before attributing a source-level rewrite to reduced setup.

The new audit verifies:

1. All saved replay ELF hashes match the original measured builds; source and disassembly bindings agree.
2. Each dynamically dispatched instruction in a timed region matches its encoding in the measured application ELF. Cerebras instruction PCs are word addresses; ELF locations are byte addresses.
3. Executed timestamp-read anchors reproduce all twelve saved device timer intervals exactly.
4. Every window contains exactly 4,096 multiplication results, with no arithmetic crossing the boundaries or appearing outside the twelve windows. The saved numerical-pass and original-timing flags are required; numerical execution was not repeated today.
5. The CTF parser reports no discarded events or warnings. All observed FP arithmetic lane identifiers are zero.

The interval includes output initialization and timestamp instructions inside the start/end anchors; host transfers are outside it. Global trace cycles and device timer values differ by an offset and are not interchanged. The compiler shared the final timer-reading helper and omitted its source attribution, so selecting only PCs attributed to the time library would be incomplete. The analyzer identifies actual timer-register reads, checks the repeated control-flow pair, and verifies interval lengths.

Three additional negative checks confirmed rejection of a changed ELF hash, a missing timestamp event, and a timer interval inconsistent with the saved measurement. These checks used synthetic corrupted events without modifying the original archive.

This is a demonstration on hand-written GEMM microbenchmarks, **not** an additional agent improvement or sparse hardware result. Cycles/dispatch is a descriptive simulator statistic, not CPU retired-instruction CPI or arithmetic utilization.

## What the official information enables

The [compiler documentation](https://sdk.cerebras.ai/csl/csl-compiler) documents ELF output, resolved parameter JSON, route reporting, and default DWARF information. Use explicit `--arch=wse3`, retain debug information, and archive the compile command, `--output-json`, and `--out-routes` output. The public page does not establish a stable LLVM-IR export option. Label the existing backend interceptor as an SDK-version-specific method and require its shadow ELF to match the measured ELF.

The [debugging guide](https://sdk.cerebras.ai/debug/debugging) supports CSDB image/core inspection and simulator instruction/wavelet traces. On WSE-3, decode is stage 3 and execution is stage 6. Instruction identity and vector-element records allow dispatches to be distinguished from arithmetic elements. FP32 FMAC is SIMD-1; a long descriptor does not imply eight simultaneous FP32 products. CSDB hardware debugging is not supported through appliance mode. Existing local checks established image, symbol, and trace access; core memory/register inspection on this SDK still needs a dedicated validation before it is promised as a working facility.

The [SIMD appendix](https://sdk.cerebras.ai/csl/language/appendix) gives builtin-specific widths and recommends `cs_readelf --sym` for inspecting symbol placement and possible memory-bank conflicts. Treat address-based conflict detection as a hypothesis, then test controlled padding/stride variants on the actual WSE-3. Do not turn static symbol addresses into claimed dynamic stall counts.

[WSE-3 microthread documentation](https://sdk.cerebras.ai/csl/language/microthreads_wse3) provides explicit microthread IDs for asynchronous descriptor operations. This supports experiments that overlap input movement, computation, and reductions. Different IDs permit concurrency; they do not establish useful overlap without a timeline and completion checks.

The [GEMV tutorials](https://sdk.cerebras.ai/csl/tutorials/index) provide a sensible control sequence: scalar local computation, memory descriptors, multiple PEs, then routes and fabric descriptors. Add sparse indexing only after each stage is verified, so local compute and communication effects can be separated.

The [Hot Chips 2022 presentation](https://www.hc34.hotchips.org/assets/program/conference/day2/Machine%20Learning/HC2022_Cerebras_Final_v02.pdf) describes **WSE-2**. Its sparse-weight dataflow motivates streaming nonzero values and indices into PEs holding dense operands, and overlapping partial-sum reduction with later work. It is not evidence that arbitrary CSR kernels automatically obtain that behavior. Do not transfer its clock, pipeline timing, or link-latency numbers to WSE-3. Any compressed value/index representation must preserve the numerical contract.

## Prioritized sparse experiments

| Question | Measurements and controlled comparison | Candidate CSL solution |
|---|---|---|
| When does a descriptor pay for itself? | Sweep SpMM output width 1, 2, 4, 8, 16, 32 with fixed CSR structure, local work, and precision. Include scalar, one-element FMAC, and whole-panel descriptors. Count actual setup instructions, descriptor extents, executed products, and timed cycles. | Choose scalar processing for short work; reuse loaded descriptors and process contiguous dense panels when setup can be amortized. Check emitted code after every proposed hoist. |
| How much does irregular indexing cost? | Hold dimensions and nonzeros fixed; vary empty rows, long rows, row-length variation, and column locality. Compare validated local 16-bit and 32-bit indices and offset chaining. Count index loads/shifts/comparisons and measure cycle changes. | Use narrower local indices only after range checks; reuse offsets; use specialized regular regions plus a correct irregular fallback. Preserve signed-offset and capacity limits. |
| Does local placement limit throughput? | Use identical arithmetic with controlled operand padding, offsets, and strides; record actual ELF addresses, code/data size, descriptor extents, and hardware timing. Repeat across FP32 and separately declared lower-precision contracts. | Change placement or layout when a hardware-controlled experiment demonstrates a benefit. Avoid assuming every descriptor builtin has the same width. |
| Does balancing arithmetic increase communication? | Compare equal-row and nonzero-balanced partitions across 1, 4, 16, 64, 256 PEs. Record local work, vector/panel replication, wavelets per application route, and completion spread. Separate host preload, required communication, and computation. | Partition using both work and operand locality; selectively replicate small operands; stream or tile large dense panels. Keep framework scaffolds separate from agent-generated computation. |
| Can communication be hidden? | Compare sequential and double-buffered schedules with the same traffic. Correlate wavelet identities, routes, task activation, arithmetic intervals, and final completion. Audit clock alignment before cross-PE subtraction. | Pipeline sparse blocks, panel delivery, and output reduction with explicit dependencies and asynchronous operations. Include buffer capacity and initialization in the contract. |
| When does sparse-product reformulation help? | For the existing masked product, vary list lengths, overlap, mask size, and output density. Count actual comparisons and products, accumulator touches/clears, and output writes. | Choose merge/intersection, direct accumulation, or block processing by measured structure and capacity. General SpGEMM requires its own symbolic/output-allocation contract and is outside these masked-product results. |

For the first two rows, include banded, block-structured, uniform, and skewed matrices with identical nonzero budgets where possible. Preserve off-diagonal exceptions and cancellation cases. Test repeated launches with changed values **and** sparsity. Newly converted indices, changed reduction order, and persistent scratch state must pass the same numerical oracle and tolerance as every other condition.

Local ELF inspection should cover every distinct application-PE role, not simply the first two filenames. Keep memcpy infrastructure identified separately. Wavelet counts should use the compiled application routes and PE rectangle; opaque trace fields should not be decoded by guessed bit positions.

## A model that can predict a useful change

Use a local cost model with separate row setup, sparse-index processing, descriptor setup, arithmetic service, and required zero/merge/output work. For SpMM, a starting hypothesis is:

```
T_local = T_row_setup + T_zero
        + nnz * (a_index + a_descriptor + b_fmac * output_width)
        + T_output
```

This is a hypothesis for a specified implementation and data type, not a hardware identity. Fit scalar and descriptor alternatives independently using controlled microbenchmarks. Descriptor setup should be charged per actual descriptor use, not blindly per nonzero if a transformation changes reuse. If overlap is substantial, replace additive terms with a measured dependency schedule. A matrix-wide lower bound based on maximum per-PE work is insufficient when communication, synchronization, or dependency stalls dominate.

Derive a crossover width only where the fitted slopes and intercepts predict one and the memory capacity permits it. Then test whether selecting kernels by that prediction works on unseen matrix families, dimensions, widths, and PE counts. Compare with static rules and expert variants. Report absolute/relative prediction error and selection regret (time of chosen variant divided by fastest valid candidate), including losses. Fitting the same three kernels that motivate the model is not an independent validation.

For distributed cases, model the critical path through local work, movement, and completion. Do not add overlapping instruction durations, and do not interpret the complement of FP result-event cycles as memory-stall time. Correlate observed gaps with controlled changes before assigning a cause.

For format conversion or partition preparation, use `T_total(R) = T_prepare + R*T_iteration` and report R = 1, 10, 100. The smallest beneficial reuse count must satisfy the inequality against the complete baseline cost; include preparation on both sides when required. Measure preprocessing separately from oracle construction. The existing microbench host-preparation field includes oracle work and cannot supply this cost.

Across CUDA and WSE, compare matched numerical work, precision, matrix structure, and explicit timing scopes. A reduction in GPU global-memory requests and a reduction in WSE descriptor/index work can favor different mappings. Use the existing CUDA/cuSPARSE evidence for that comparison; simulator cycle estimates must remain separate from measured GPU and CS-3 latency. Do not equate a PE, GPU warp, and GPU SM or infer utilization from their instruction counts.

## Paper changes for the integrator

Use the new measurement method first on the SpMV compiler-feedback success and a SpMM or masked-product non-improvement. Request exact starting/final source bundles, measured ELFs, build identities, raw trial results, and matching simulator traces for those cells. Hardware replay of the nine missing compiler-feedback variants is the first coverage priority. Keep raw failures and SDK diagnostics with the bundle.

The strongest additional result would be a demonstrated mechanism and its limit: for example, a predicted width or reuse threshold that selects a faster implementation on unseen matrices, together with cases where communication or capacity removes that advantage. Additional annotated assembly without a tested prediction would be weaker evidence.

Replace “addressing tax” with **index and address-generation overhead** and “sparse angles” with **sparse transformations**. Avoid explaining the architecture only as “no cache”: identify local SRAM, operand storage, and explicit movement. Replace “tile only when capacity forces P>1” with a statement that tiling can manage capacity, reuse, communication, and overlap. Describe unsupported operand forms as compilation failures unless a minimized test establishes a compiler defect; a static hazard pattern alone does not prove a defective compiler.

Suggested new case-study paragraph, pending sparse and hardware evidence:

> Compiled instruction counts identify what changed, but do not alone explain execution time. We pair each measured binary with simulator instruction and arithmetic traces bounded by verified timestamp reads. We then test whether descriptor setup, index processing, or communication predicts the observed change using controlled implementations. The resulting model is evaluated on matrices excluded from optimization. We report both successful selections and cases where the predicted improvement is removed by capacity, communication, or numerical constraints.

This paragraph describes the intended completed method; only the GEMM timed-window demonstration is complete in this contribution. Do not present the planned sparse/hardware validation as already performed.

## Reproduction and handoff

From a repository checkout containing this study and `studies/wse3-characterization`:

```bash
python3 studies/sparse-profiling-20260924/profile_timed_windows.py \
  --microbench-root /home/USER/wse-matmul-microbench \
  --trace-library studies/wse3-characterization \
  --output /tmp/sparse-timed-window-audit.json
```

The raw trace bundle is external to Git. On another machine, supply the transferred microbenchmark archive and replace the root path. The JSON records source, ELF, disassembly, CTF stream, and parser hashes. Missing inputs, timer mismatches, ambiguous PC mapping, encoding mismatches, discarded events, or incorrect work counts fail the audit. The parser uses the retained trace metadata rather than a newly installed SDK layout.

Completed: shared-tip review, clean paper fast-forward, three exact-binary timer audits / twelve launch windows, and this profiling proposal. Running cells: none launched by this contribution. Next NVIDIA work: apply the audited trace method to exact sparse bundles and run the local width/index controls. Next WSE-node work: complete missing hardware replays and validate descriptor, placement, and communication hypotheses on silicon. Model experiments remain governed by the separately frozen matched-study protocol.
