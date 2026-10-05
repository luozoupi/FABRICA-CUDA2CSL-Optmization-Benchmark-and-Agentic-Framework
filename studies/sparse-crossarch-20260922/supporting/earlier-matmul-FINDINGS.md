# What the controlled simulator runs show

These are results from handwritten/generated deterministic CSL microbenchmarks, not improvements made by DeepSeek or Luna. All performance intervals come from one WSE-3 simulator PE with operands preloaded. They identify local implementation choices worth testing on hardware and inside distributed kernels. The [complete tables](earlier-matmul-RESULTS.md), [protocol](earlier-matmul-PROTOCOL.md), and [raw results](earlier-matmul-results.json) define their scope.

## Descriptor extent matters more than selecting a vector builtin

For the same 16 × 16 × 16 GEMM, a one-element descriptor FMA takes **162,803 cycles**, while a whole-row descriptor FMA takes **17,634**: a **9.23×** reduction. Both explicitly use FMA, so this comparison does not attribute the difference between separate multiply/add and fused arithmetic to vector length. The longer descriptor amortizes address calculation, descriptor setup and loop control across output columns.

Local 2 × 2 and 4 × 4 tiles take **75,141** and **43,175 cycles**, respectively, versus **17,634** for whole-row updates. These tiles shorten descriptors and add loops while all operands already fit in local SRAM. This does not establish that distributed tiling is bad: larger problems still need capacity management, partitioning and panel delivery. It establishes that a CPU-style local blocking transformation cannot be assumed to help this resident working set.

## Compiler loop structure is a measurable optimization opportunity

Official disassembly contains eight static multiplication/addition sites in the scalar `ijk` kernel at size 8, but one site in a loop at size 16. A separately registered control expands the shared-dimension loop explicitly at size 16. Its interval drops from **111,296 to 51,627 cycles**, a **2.16×** improvement, with unchanged logical inputs, storage and timing scope.

The `.text` section grows from **3,268 to 4,184 bytes**; both sizes include the linked runtime code. Unrolling therefore has an instruction-memory cost. Whole-row descriptor FMA is still faster at **17,634 cycles** on this case. A useful agent transformation would consider extent, compiler unrolling and available instruction memory together, rather than simply trying loop permutations.

## Sparse output width changes the preferred implementation

The banded 16 × 16 input has 48 nonzeros. The same logical A and B are used by all implementations within each row:

| Dense output width | Scalar cycles | Descriptor, 32-bit indices | Result |
|---:|---:|---:|---|
| 1, SpMV | 1,855 | 2,433 | Scalar wins; a one-element descriptor does not amortize setup. |
| 4, SpMM | 4,076 | 2,765 | Descriptor is 1.47× faster. |
| 16, SpMM | 21,488 | 3,964 | Descriptor is 5.42× faster. |

For width 1, gathering x into scratch, multiplying a contiguous vector and reducing it takes **3,127 cycles**, including the gather. Contiguity alone does not pay back the preparation in this single-use test. This is not a preprocessing-reuse experiment: a separate reuse sweep would be needed to establish a break-even count.

Storing CSR offsets and indices in 16 bits does **not** yield a consistent speedup here. At width 4, the banded case changes from **2,765 to 2,779 cycles**; at width 16 it changes from **3,964 to 3,963**. The allocated index arrays shrink by **546 bytes** per PE, so capacity is a separate possible benefit. These inputs fit safely in 16-bit indices; no claim is made for unvalidated larger indices.

## Sparse intersections require more information than density and row degree

The banded and uniform masked-product inputs both have **48 nonzeros, three entries per row and three per column**. Nevertheless, the preferred intersection algorithm reverses:

| Pattern | Sorted merge | Nested matching | Products contributing to the mask | Requested positions with an intersection |
|---|---:|---:|---:|---:|
| Banded | 16,941 cycles | 19,376 cycles | 112 | 48 / 48 |
| Uniform | 20,461 cycles | 17,696 cycles | 28 | 16 / 48 |
| Skewed | 30,237 cycles | 43,088 cycles | 288 | 72 / 72 |

The uniform case asks for many empty intersections. Sorted merging performs less arithmetic there than on the banded case, yet takes longer. Index comparisons, branch paths and termination checks matter. The skewed case has a different nonzero count and degree distribution, so it is not an isolated layout control.

For an agent's matrix features, this motivates measuring requested intersection lengths and the fraction of empty requested intersections in addition to row lengths. It supports testing algorithm selection on short sparse lists. It does not establish the preferred algorithm for large SuiteSparse matrices or general SpGEMM.

## Instruction counts alone do not explain every cycle

On the 16-cube GEMM, the strided column update takes **17,138 cycles**, slightly less than the contiguous row update's **17,634**. Four exact measured ELF builds were replayed with raw tracing; every timing sample matched the original measurement. The column case has more dispatches attributed to the CSL source across those replays, despite being faster.

Both versions issue 256 FMA descriptor instructions per launch. The observed span between the first and last element results of an FMA is always 31 cycles in the row case, but ranges from 26 to 44 with median 26 in the column case. This narrows the investigation to execution scheduling and memory access behavior; it does not by itself identify a particular SRAM-bank conflict or assign a runtime percentage. Padding and operand-placement controls are appropriate follow-up experiments. The [trace analysis](earlier-matmul-performance-trace-analysis.json) states the count denominators and exclusions.

## Correct answers do not suffice to accept a kernel

Five original zero-stride reduction configurations produced numerically correct outputs but logged simulator operand-overlap errors. They are excluded from timings and accepted journals. The [versioned replacements](earlier-matmul-safe-reduction-amendment.json) use explicitly sequenced scalar reductions and pass both numerical checks and clean-log checks. These are implementation-development failures, not established compiler defects.

## Mapping the findings to several WSE PEs

Use these local choices inside a separately specified distribution scheme. SUMMA delivers A and B panels to output-owning PEs; partitioned GEMV reduces partial sums; row-partitioned SpMV distributes x. The existing viewer includes verified examples of those routes. A local speedup can disappear if operand replication, communication or an uneven partition dominates completion time.

The next hardware controls should replay these exact logical cases, then vary local tile width and row distribution under a fixed distributed layout. Measure preparation and communication explicitly, test whether narrow indices change feasible capacity, and retain unsuccessful choices. These simulator results are evidence for selecting those experiments, not final wafer-scale performance claims.
