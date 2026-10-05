# Sparse comparison results

Registered GPU workloads: **124**. Accepted primary implementation cases: **804**; rejected: **41**. WSE builds accepted: **8 / 12**.

GPU numbers below are measured warm captured-graph microseconds per operation, median of nine samples. WSE numbers are one-PE simulator cycles. No architecture speedup is computed. All results and sample ranges are in [results.json](results.json), [GPU CSV](gpu-results.csv), and [WSE CSV](wse-results.csv).

## GPU implementation comparisons

| A / family | Output width | GE plain | GE cache | GE merge ×2 | Best cuSPARSE (algorithm) |
|---|---:|---:|---:|---:|---:|
| 65536x65536-uniform8 | 1 | 10.903 | 17.196 | 18.827 | 7.813 (cusparse_alg1_row) |
| 65536x65536-uniform8 | 16 | 10.804 | 17.303 | 18.878 | 10.492 (cusparse_alg3_row) |
| 65536x65536-uniform8 | 64 | 26.221 | 33.659 | 23.242 | 26.943 (cusparse_alg3_row) |
| 65536x65536-block8 | 64 | 24.599 | 32.607 | 18.923 | 27.248 (cusparse_alg3_row) |
| 65536x65536-skew8 | 64 | 33.632 | 35.688 | 23.156 | 28.187 (cusparse_alg3_row) |
| 262144x262144-uniform8 | 64 | 104.184 | 133.325 | 98.109 | 128.314 (cusparse_alg3_row) |
| 262144x262144-block8 | 64 | 166.148 | 242.101 | 159.021 | 151.674 (cusparse_alg3_row) |
| 262144x262144-uniform8 | 128 | 263.054 | 326.759 | 274.452 | 323.311 (cusparse_alg3_row) |
| 262144x262144-block8 | 128 | 267.806 | 487.352 | 300.665 | 290.996 (cusparse_alg3_row) |
| HB-sherman1 | 64 | 2.430 | 2.515 | 2.636 | 1.972 (cusparse_alg3_row) |
| HB-bcspwr09 | 64 | 3.717 | 4.008 | 3.860 | 2.245 (cusparse_alg3_row) |

Across 118 accepted workload comparisons, the best of the three optimized GE variants is over 5% faster than the best tested cuSPARSE algorithm in 36 cases; cuSPARSE is over 5% faster in 73. The remaining cases are within that descriptive band. This threshold is not a statistical significance test. These are retrospective selections and not a deployed selector. GE plain is reported separately; its wins must not be credited to caching or merging.

## Exact same inputs on the WSE simulator

A is 32 × 64. Columns below use uniform degree 8 (256 nonzeros); outputs are exactly checked against the same frozen oracle as CUDA. A dash means the full registered build did not complete and was not accepted.

| Output width | Scalar | Row descriptor | Descriptor constructed once per row |
|---:|---:|---:|---:|
| 1 | 8163 | 11429 | 11429 |
| 4 | 18044 | 13181 | 13181 |
| 16 | — | 19420 | 19420 |
| 64 | — | — | — |

| Registered WSE build | Compilation | Acceptance |
|---|---|---|
| descriptor-n1 | compiled | pass |
| descriptor-n16 | compiled | pass |
| descriptor-n4 | compiled | pass |
| descriptor-n64 | compiled | 360-second host wall-time limit; not a correctness or memory-capacity verdict |
| hoisted-n1 | compiled | pass |
| hoisted-n16 | compiled | pass |
| hoisted-n4 | compiled | pass |
| hoisted-n64 | compiled | 360-second host wall-time limit; not a correctness or memory-capacity verdict |
| scalar-n1 | compiled | pass |
| scalar-n16 | compiled | 360-second host wall-time limit; not a correctness or memory-capacity verdict |
| scalar-n4 | compiled | pass |
| scalar-n64 | compiled | 360-second host wall-time limit; not a correctness or memory-capacity verdict |

## Independent GPU replay

Seven selected workloads were rerun in two additional processes. The table gives the range of the three run medians, not a confidence interval. The selected set was registered after the original results, as a stability check, not independent final-test evidence.

| Workload | GE merge ×2, µs | cuSPARSE CSR 3, µs |
|---|---:|---:|
| 65536x65536-uniform8-n64 | 23.220–23.253 (3 runs) | 26.888–26.969 (3 runs) |
| 65536x65536-block8-n64 | 18.915–18.923 (3 runs) | 27.208–27.254 (3 runs) |
| 65536x65536-skew8-n64 | 23.152–23.169 (3 runs) | 28.121–28.187 (3 runs) |
| 262144x262144-uniform8-n64 | 94.526–98.125 (3 runs) | 125.965–128.332 (3 runs) |
| 262144x262144-uniform8-n128 | 269.188–274.452 (3 runs) | 323.311–323.397 (3 runs) |
| 262144x262144-block8-n64 | 158.992–159.021 (3 runs) | 151.074–151.674 (3 runs) |
| 262144x262144-block8-n128 | 299.099–301.377 (3 runs) | 290.033–290.996 (3 runs) |

## Numerical failure retained

All 41 tested implementations on the six HB/bcsstk08 widths fail the fixed componentwise gate on at least one validation session. The gate is unchanged and their timing results are excluded. See [numerical-diagnostic.json](numerical-diagnostic.json). This is not a claim that both libraries contain the same bug. A representative changed-value SpMV row has reference 2106.1337890625, result 2106.25, error 0.1162109375, and allowed error 0.105356689453125. Its absolute product sum is about 8.15 million: strong cancellation makes the requested componentwise relative accuracy harder than the overall scale suggests.

## Cost scope

The explorer shows device preparation plus 1, 10 or 100 resident graph operations, graph construction, CPU layout packing and raw single-call measurements separately. The preparation interval is event-bracketed and can include submission/event overhead even for a no-op preparation API. These values do not include a complete application distribution or host-device transfer path.
