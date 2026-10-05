# Sparse cross-architecture characterization, 2026-09-22

This is a new, deterministic characterization study, separate from the frozen agent experiments and earlier matmul microbenchmarks. No result is attributed to an API model. Framework local revision c7ad437d80de5b3f077a15576cfbaca18112e657; fetched shared tip b48041ef6787568ec66bf294efac2d001e8c6d83; paper tip d1f9e720642fd030f0a7e1ec8334975ceeb4a99e. Those repositories are unchanged.

## Questions and registered inputs

1. When does output width amortize sparse traversal and CSL descriptor setup?
2. At fixed nonzero count, how do column locality and row imbalance change the result?
3. Does explicitly reusing the output descriptor once per row improve CSL?
4. How do GE-SpMM row caching and warp merging compare with current cuSPARSE on this GPU?
5. What capacity, replication and load imbalance constraints remain when distributing these local kernels across WSE PEs?

All products are FP32 CSR sparse A times dense B, alpha=1, beta=0, non-transposed. GE-SpMM is a GPU SpMM implementation, not sparse-times-sparse SpGEMM. CSR indices are 32-bit on both platforms. Input values include signs and cancellation. Synthetic values are small integers, original real-matrix values are rounded to FP32; no normalization. Oracle: SciPy CSR in FP64. Fixed componentwise tolerance: 5e-5 + 5e-5*abs(reference); synthetic results must additionally be exact.

Shared single-PE cases: A is 32 by 64, output widths 1, 4, 16, 64. Families: uniform degree 2, 8, 32; degree-8 banded; degree-8 block structured; degree-8 mean skewed (one eighth of rows have degree 64, remainder empty). Banded, blocked, uniform-8 and skewed have exactly the same nonzero count. Uniform uses a deterministic pseudorandom permutation per row, without duplicate columns. Skewed heavy rows are clustered, intentionally exposing equal-row partition imbalance. No data-dependent algorithm tuning of the input generator.

GPU expansion: 4096-square and 65536-square A with the same six families; widths 1, 4, 16, 32, 64, 128. Rectangular A of 4096 by 65536 and 65536 by 4096, uniform degree 8, widths 1, 16, 64. Three already-downloaded application matrices (HB/sherman1, HB/bcspwr09, HB/bcsstk08), same six widths. These are characterization inputs, not optimizer training or final-test feedback. Matrix/input hashes are frozen before execution. Large matrices remain sparse in the oracle.

## Implementations and timing

CSL: scalar CSR, a whole-row FMA descriptor per nonzero, and the same descriptor implementation with the C-row descriptor constructed outside sparse traversal. SDK 2.10.1, WSE-3 simulator, one application PE, 8 by 3 fabric. Buffers are resident in SRAM; interval includes output clearing and two timestamp reads; transfer and host launch excluded. Six families share a compiled build. Each family is run original -> changed values and sparsity pattern -> original, one checked warmup and three measured launches per session. Clean simulator logs, changing timestamps, source/build hashes and numerical correctness are required. Infeasible builds are retained. This is not a wafer-scale hardware latency measurement.

CUDA: official GE-SpMM kernels 0 (plain), 1 (row caching), 2 (two outputs/thread), 3 (four outputs/thread), fixed four rows/block, extracted byte-for-byte from the pinned upstream file; its obsolete standalone CUDA-10 benchmark harness is replaced. This fixes launch geometry instead of claiming exhaustive GE tuning. cuSPARSE SpMV CSR algorithms 1 and 2; SpMM CSR algorithms 1 (column-major), 2 and 3 (row-major). Each has explicit workspace, preparation and numerical checks. Layout conversion is recorded separately. All implementations overwrite output. Warm resident operands; no cache flush; nine samples per timing mode. CUDA event single-call time and captured-graph time per operation (100 dependent repeated operations) are separate. cuSPARSE preparation precedes graph capture. Before/after preparation host-enqueued batch measurements are diagnostic and include submission gaps. Report GPU, driver, runtime/library version, clock observations and raw samples. Other GPUs can be busy; this is not an isolated node or fixed-clock experiment.

Correctness includes poisoned output, a second launch with changed A and B values, and a third launch with changed column indices. cuSPARSE descriptors/preparation are rebuilt for changed sparsity. Timing uses original inputs only. Compiler/source/binary identities and copied outputs are retained. GE kernels additionally get compute-sanitizer checks on representative narrow/tail/empty-row cases where available. Profiling permission failures are recorded rather than worked around through system configuration.

Preprocessing analysis reports device preparation and graph construction separately, and costs for 1, 10 and 100 resident uses. A break-even estimate is only valid for the stated alternative and timing scope; layout conversion, H2D, distribution and graph construction must be added where required by an application. Best-of-algorithm tables are a retrospective oracle, not an implemented automatic selector.

## Interpretation limits

Do not divide GPU microseconds by simulator cycles to claim an architecture speedup. Analyze implementation ratios within each platform and separately report exact-input results. Static partition nonzero counts and communication volumes are predictions, not measured fabric time. WSE hardware replay, cross-PE synchronization, large distributed matrices, memory/traffic counters, cold-cache measurements and independent final-test selection are needed before principal IPDPS architecture claims. Keep unsuccessful variants. An observed latency difference alone does not identify a memory-bank or bandwidth bottleneck.
