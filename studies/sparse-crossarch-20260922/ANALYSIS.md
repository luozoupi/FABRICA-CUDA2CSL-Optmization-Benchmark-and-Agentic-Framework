# What the sparse comparisons tell us

The useful research question is which resource limits each workload, and which transformations actually change its use of that resource. A single sparse/dense label or sparsity percentage cannot answer it. This study supplies measured GPU comparisons, checked local CSL experiments, instruction evidence, and explicit distribution predictions. It does not yet supply matched wafer-scale hardware measurements or agent-generated improvements.

The [result tables](RESULTS.md) and [interactive explorer](index.html) separate measured CUDA microseconds from WSE simulator cycles. The NVIDIA device is an RTX PRO 6000 Blackwell Server Edition with 188 SMs and 128 MiB of L2; the installed toolkit is CUDA 13.0, driver 595.58.03, and cuSPARSE library 12.6.3. The latter is a library version, not the CUDA toolkit version. CSL uses the existing SDK 2.10.1 image and WSE-3 target.

## 1. GPU caching can reduce loads and still lose

For a 65,536-square matrix with eight nonzeros per row and 64 output columns, the official GE plain kernel takes **26.221 µs**, row caching takes **33.659 µs**, and two-output warp merging takes **23.242 µs**. Two additional process replays reproduce these rankings. The result does not support treating shared-memory row caching as an unconditional improvement on this GPU.

Nsight Compute on the exact executable gives a mechanism worth investigating:

| Measured counter for one profiled kernel | Plain | Row caching | Cache + two outputs/thread |
|---|---:|---:|---:|
| Global-load sectors requested at L1 | 6,553,600 | 4,718,592 | 4,456,448 |
| Executed warp instructions | 14,483,456 | 24,838,144 | 15,597,568 |
| L2 traffic, bytes | 160,481,376 | 160,642,080 | 155,938,208 |

Caching reduces the first count by **28%**, but adds about **71%** to the instruction count and barely changes L2 traffic. The warm, small-footprint profiler replay moves very little data to DRAM. Thus the evidence points to cache traffic and instruction/synchronization work, not a simple DRAM-bandwidth explanation. The counters are from instrumented replay; timing tables come from the uninstrumented executable. Profiler replay, caches and clocks are not fixed, so the counter values are not an exact decomposition of runtime.

GE-SpMM's published mechanisms are cooperative CSR row caching and reuse across multiple outputs per thread. We use the authors' kernel bodies unchanged, with a new harness for the installed CUDA toolkit. Their historical speedups on older GPUs are not assumed to hold here. [GE-SpMM paper](https://arxiv.org/abs/2007.03179), [official source](https://github.com/hgyhungry/ge-spmm).

**WSE implication:** CSR already in local SRAM does not need a GPU-style shared-memory staging step merely because that step appears in a successful CUDA kernel. Prefer eliminating repeated index/control work and using each sparse value across a useful output width. Any additional gather or packing must repay its own cost. The earlier controlled SpMV gather test already lost when its preparation was included.

## 2. Output width and footprint change the winning implementation

The earlier verified one-PE experiment found scalar SpMV faster than a length-one descriptor (1,855 versus 2,433 cycles). At output width 16, the row descriptor took 3,964 cycles versus scalar's 21,488. These particular numbers belong to the earlier 16-square matrix experiment; they are not substituted into this study's 32-by-64 tables. [Earlier evidence](supporting/earlier-matmul-FINDINGS.md).

The new 32-by-64, degree-8 inputs confirm the narrower part of that crossover: scalar SpMV takes **8,163 cycles**, versus **11,429** for a descriptor; at width four, scalar takes **18,044**, versus **13,181** for a descriptor (**1.37×** faster). Scalar multiplication/addition and descriptor FMA also differ in instruction form, so this comparison does not isolate descriptor setup as the sole cause.

On the GPU, the 65,536-square block-structured width-64 case favors GE merging: **18.923 µs**, versus **24.599** for plain GE and **27.248** for the best tested cuSPARSE choice. Increasing both matrix size and output width changes that result. On the 262,144-square block case at width 128, plain GE takes **267.806 µs**, versus **300.665** for two-output merging and **290.996** for the best cuSPARSE choice. Three independent runs retain this ordering.

For the latter shape, A+B+C alone occupies about **273 MiB**, exceeding L2. The larger uniform case's profiled two-output kernel moves about **298 MB through DRAM**, versus negligible DRAM traffic for the smaller resident replay. This is a different execution regime. Array size is only a capacity check; counters are the stronger evidence that the traffic changed. Even here, lower total traffic does not completely predict the ranking: the large block and uniform cases have different L2 traffic and latency. Memory scheduling, cache behavior and access distribution need additional controlled tests before assigning a specific cause.

**WSE solution:** choose the local output width together with local CSR capacity, B storage, output storage, code and scratch. A wider descriptor amortizes sparse traversal but consumes more SRAM and may require more replicated B data or a different distribution. Select the local implementation and the PE partition jointly; a local width optimum is not automatically a wafer-scale optimum.

## 3. A source optimization can already be present in the compiled program

The new CSL candidate moves construction of the output-row descriptor outside the nonzero loop. On the completed widths 1, 4 and 16, it produces **exactly the same measured cycles** as constructing it inside that loop, for all six input families and changed-input sessions.

At width 16, official ELF disassembly shows the same instruction sequence after the initial setup, with only the order of two setup pairs changed. Both complete linked text sections contain 820 instructions and 3,280 bytes. They are not byte-identical ELF files, and equal static counts alone would not prove equal runtime; the measured cycles independently establish the null result on these inputs.

**Agent-framework implication:** compare emitted code as well as source. A transformation that only changes source placement may add no optimization. The earlier explicit-unrolling experiment did change the generated loop and its cycles. This contrast is a useful compiler-feedback case study. Neither deterministic experiment is an improvement attributable to DeepSeek or Luna.

## 4. Balancing nonzeros can greatly increase operand replication

For the 65,536-row skewed input, static assignment to 16 equal row ranges gives maximum work **8× the mean**. Greedy whole-row assignment by nonzeros reduces that ratio to **1×**, but distinct B-row copies summed across PEs increase from **128,670 to 413,446**—about **3.21×**. These are exact counts from frozen CSR indices, not measured network bytes or speedups.

The banded input is already balanced. Blindly reassigning its rows gives no improvement in maximum nonzero count and increases B-row copies from **65,648 to 524,288**, about **7.99×**. For the small skewed case, only four rows carry work; distributing complete rows cannot utilize 16 PEs evenly. The best nonzero balance is still **4× the mean** unless rows are split and partial outputs are reduced.

**WSE solution:** use a partition objective that considers nonzeros, row/output initialization, distinct remote B rows, SRAM limits and reduction work. Preserve contiguous/local row groups when they are already balanced. Split exceptionally long rows only when shortening the completion tail repays partial-result communication. A tie-break on row count is needed even for empty rows; zero arithmetic does not imply zero output/storage work. The current static comparison is a diagnostic, not the final partitioner.

For a CSR output-owning PE, a useful capacity estimate is:

`8 × local nonzeros + 4 × (local rows + 1) + 4 × retained B rows × local width + 4 × local rows × local width + code + scratch`.

With 65,536 shared-dimension entries and width 64, replicating all of B needs **16 MiB per PE**, so that simple layout is infeasible. Tile the shared dimension or fetch only needed B panels, and include those transfers and any partial-result reduction in the measured interval. Cerebras's official hypersparse SpMV example provides a relevant 2D distribution and explicitly accounts for unsynchronized PE clocks. Its example frequency conversion is not a measured WSE-3 clock. [Official example](https://github.com/Cerebras/sdk-examples/tree/master/benchmarks/spmv-hypersparse).

## 5. Sparsity percentage misses important changes in work

At degree 8, growing a square matrix from 4,096 to 65,536 rows lowers density by 16× while increasing nonzero work by 16×. Increasing output width multiplies arithmetic without changing A's density. At fixed rows and nonzeros, clustering entries changes which B rows must be delivered, while skew changes completion imbalance. Report dimensions, nonzeros, row-length distribution, B-row locality, dense width and reuse count alongside sparsity.

Our equal-degree banded, block and distributed-column inputs produce identical local descriptor cycles in the completed resident WSE tests. Their static distribution costs differ greatly. This is a direct reason to keep local kernel characterization and inter-PE delivery in separate experimental controls before combining them.

## 6. Numerical requirements can become the limiting condition

Every tested implementation on HB/bcsstk08 is rejected under the fixed componentwise tolerance on at least one session. A representative changed-value SpMV output has reference **2106.1337890625** and computed result **2106.25**. The absolute product sum is approximately **8.15 million**, about 3,868 times the final result. This supports cancellation in FP32 accumulation as an explanation to test; it is not evidence that every CUDA implementation has an indexing bug.

The original acceptance gate and excluded results are retained. For a new protocol, register normwise and componentwise residuals, adversarial cancellation inputs and an appropriate higher-accuracy reference before running optimization. On WSE, test pairwise or compensated accumulation where numerical requirements demand it, including extra storage, instructions and communication. A faster answer outside the numerical contract is not a successful optimization.

## 7. Baseline selection and preparation are part of the experiment

Use cuSPARSE's supported CSR algorithms with compatible dense layouts, not a single arbitrary call. In our width-64 uniform example, algorithm 2 takes about **36.986 µs**, while algorithm 3 takes **26.943 µs**. Comparing GE only against algorithm 2 would overstate its advantage. The pinned CUDA documentation describes algorithm/layout preferences and optional preprocessing; changing CSR indices requires rebuilding preparation. [CUDA 13.0 cuSPARSE documentation](https://docs.nvidia.com/cuda/archive/13.0.0/cusparse/index.html).

The explorer reports preparation, layout packing, graph construction, single-call events and repeated-use device estimates separately. For two complete alternatives with costs P₀+R·T₀ and P₁+R·T₁, a break-even count is ceil((P₁−P₀)/(T₀−T₁)) only when the candidate has lower steady latency and both P terms contain the same required scope. The current measurements do not provide all host-distribution costs, so we do not report a universal end-to-end break-even count.

The authors direct newer GE-related implementations to [dgSPARSE](https://github.com/dgSPARSE/dgSPARSE-Lib); [merge-spmm](https://github.com/owensgroup/merge-spmm) is another useful load-balancing comparison. They are identified here, not benchmarked or labeled equivalent to the tested kernels. Blocked-ELL/tensor-core methods require a separate precision, padding and conversion-cost contract; they are not interchangeable arbitrary-CSR baselines.

## A concrete CSL implementation to test next

For the 65,536-square, degree-8, width-64 case, a plausible **capacity configuration, not a measured result**, assigns 128 output rows and four output columns to each PE. It needs 512 row groups × 16 column groups = 8,192 PEs. Each PE stores 1,024 local nonzeros (8 KiB with FP32 values and 32-bit columns), 129 row offsets, 128×4 output values (2 KiB), and at most 1,024 distinct needed B rows × four columns (16 KiB). These named data buffers total about **26.5 KiB** before code, routing state, maps and scratch. The compiler and hardware must validate the remaining capacity. Skewed inputs require the corresponding actual maximum local counts, not the mean degree.

The workflow is explicit:

1. Assign output rows and a contiguous output-column slice. Build a compact list of distinct global B-row indices required by that row group; rewrite CSR indices to checked local offsets. Retain the original-to-local map and count its preparation cost.
2. Deliver each needed B row slice to its output-owning PE. Where several PEs need the same slice, compare planned multicast with repeated sends. If values change with fixed sparsity, retain the maps; if sparsity changes, rebuild and charge them.
3. Clear the local output once. For each CSR entry, read its local B-row offset and value, then perform a contiguous vector update of the corresponding output row. Use scalar processing as a separate candidate for width one.
4. If the needed B slices do not fit, stream shared-dimension panels and group CSR entries by panel beforehand. Otherwise repeated scans of all CSR entries could erase the benefit. Double buffering is a candidate only after completion dependencies and scratch reuse are verified.
5. Return completed output tiles or feed the next resident operator. Splitting the shared dimension across PEs creates partial outputs and needs an explicitly measured reduction; splitting output rows or columns does not.

This compact-B design addresses capacity without requiring a complete B copy on every PE. It creates a real tradeoff: preparation and irregular delivery versus local storage and repeated reuse. An agent should choose among these documented distribution scaffolds and generate the local computation, with both contributions reported separately. Batching independent SpMV right-hand sides into SpMM can also amortize sparse traversal when the application naturally provides them; it increases work and changes latency requirements, so it is not a speedup of one isolated SpMV.

## What would make this an IPDPS architecture result

The principal next experiment is matched hardware replay on the other node: identical frozen inputs, scalar and descriptor CSL, equal-row and locality-aware balanced partitions, and explicit preparation/communication boundaries. SpMV and SpMM need 1/4/16/64/256-PE controls with synchronized timestamps, plus infeasible points. Replay the shared local cases first; then expand capacity using a documented distributed scaffold. The complete wide simulator builds exceed the local wall-time limit and remain excluded; successful compilation alone is not correctness evidence.

Use the matrix features to select a small candidate set, and evaluate that selector on untouched matrices against both a deterministic selector and the best measured reference. The new method must show when feedback improves selection, when it fails and what cost it adds. Existing CS-3 work already studies much larger sparse matrices and host/device transfer effects, so novelty cannot be merely “SpMM runs on Cerebras.” [CS-3 sparse study](https://arxiv.org/html/2604.27985v2).
