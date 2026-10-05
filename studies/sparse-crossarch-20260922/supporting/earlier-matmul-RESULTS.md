# Measured local implementation results

65 accepted builds; 5 rejected after simulator diagnostics; 0 retired before acceptance; 0 pending. Accepted artifacts contain 822 checked launches and 1047 verified debug snapshots.

All cycle counts below are **WSE-3 SDK simulator intervals on one PE**, including output reset and required scratch work. Three timed samples follow a checked warm-up; changed-input and restored-input sessions are correctness audits. Debug instrumentation is excluded from these timings. Raw samples and ranges are retained in `results.json`. Hardware replay is pending.

## Dense GEMM

| Implementation | Layout | 8 × 8 × 8 cycles | 16 × 16 × 16 cycles |
|---|---|---:|---:|
| Whole-column descriptor FMA | column-major | 2,967 | 17,634 |
| Whole-column descriptor FMA | row-major | 2,773 | 17,138 |
| Vector multiply + scalar reduction | row-major | 4,110 | 22,566 |
| One-element descriptor FMA | row-major | 15,445 | 162,803 |
| Whole-row descriptor FMA | column-major | 2,773 | 17,138 |
| Whole-row descriptor FMA | row-major | 2,967 | 17,634 |
| Scalar ijk | row-major | 6,853 | 111,296 |
| Scalar ijk, explicitly unrolled K | row-major | — | 51,627 |
| Scalar ikj | row-major | 8,052 | 110,834 |
| Scalar jik | row-major | 7,088 | 111,536 |
| Scalar jki | row-major | 7,784 | 114,626 |
| Scalar kij | row-major | 7,280 | 111,074 |
| Scalar kji | row-major | 7,165 | 114,385 |
| 2 × 2 local tiles / row FMA | row-major | 9,395 | 75,141 |
| 4 × 4 local tiles / row FMA | row-major | 4,881 | 43,175 |

## CSR SpMV and SpMM

| Output width | Input pattern | Scalar cycles | Descriptor / 32-bit cycles | Descriptor / 16-bit cycles | Gather + reduce cycles |
|---:|---|---:|---:|---:|---:|
| 1 | banded | 1,855 | 2,433 | 2,431 | 3,127 |
| 1 | uniform | 1,855 | 2,433 | 2,431 | 3,127 |
| 1 | skewed | 2,487 | 3,433 | 3,459 | 4,033 |
| 4 | banded | 4,076 | 2,765 | 2,779 | — |
| 4 | uniform | 4,076 | 2,765 | 2,779 | — |
| 4 | skewed | 5,384 | 3,929 | 3,967 | — |
| 16 | banded | 21,488 | 3,964 | 3,963 | — |
| 16 | uniform | 21,488 | 3,964 | 3,963 | — |
| 16 | skewed | 32,016 | 5,704 | 5,727 | — |

The patterns do not all have the same nonzero count or row-length distribution. Compare implementations within a row; differences between rows are not an isolated test of row imbalance. This is one PE, so these timings cannot establish distributed load balance.

## Masked AᵀA

| Pattern | Sorted merge cycles | Nested matching cycles |
|---|---:|---:|
| banded | 16,941 | 19,376 |
| uniform | 20,461 | 17,696 |
| skewed | 30,237 | 43,088 |

## Evidence and limits

- Every comparison group was checked to have the same logical A/B hashes across implementations.
- Every accepted build has matching saved source and ELF hashes, checked output values, and no ERROR/FATAL simulator diagnostics.
- Original and restored inputs produce identical outputs, while timestamp starts advance across launches.
- Natural scalar code and descriptor FMA use different instruction forms. The one-element descriptor FMA is the direct extent control.
- The timer-control interval is reported separately; it is not subtracted. Identical simulator repetitions do not measure hardware variance.
- The zero-stride reduction prototypes demonstrate that correct numerical output alone is insufficient. Their operand-overlap diagnostics disqualify their timing results. The versioned replacements use scalar reduction loops.
- The pattern sweep contains synthetic inputs, not SuiteSparse matrices. Large-matrix scaling, communication costs, preprocessing amortization and general SpGEMM are outside this local experiment.
