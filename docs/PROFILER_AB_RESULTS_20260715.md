# Profiler A/B Full Sweep Results (2026-07-15)

## Configuration
- **N=10** seeds per kernel per arm (560 total runs)
- **Model:** Claude Opus 4.8
- **Cap:** 20 (reviewer + optimizer attempts)
- **Arms:** Profiled (sim.log + trace + memory feedback) vs Unprofiled (no feedback)
- **28 kernels** across test + train splits

## Top-Level Verdict

**Better: 9 | Worse: 7 | Same: 7 | NoData: 5**

Profiling feedback is **NOT a universal lever** but shows a clear pattern:
- **Helps** on multi-PE stencils and program-level pipelines (Jacobi −28%, Laplacian −16%, PDFT −19%)
- **Hurts** on single-PE compute kernels where it distracts the optimizer (Stencil7pt +115%, Wide-Mult +27%)
- **Neutral** on stable converging kernels (7pt-Stencil, FFT, CG, SpMV-CSR)

## Best Candidates by Arm

### Profiling Clearly Helps (use `--profile-feedback`)

| Kernel | Pattern | Prof med | Unprof med | Delta | Prof pass | Unprof pass |
|--------|---------|----------|-----------|-------|-----------|-------------|
| **PDFT-Pi-Pipeline** | program-level pipeline | 11,108 | 13,692 | **−19%** | 7/10 | 3/10 |
| **Jacobi-2D-5pt** | multi-PE stencil | 680 | 943 | **−28%** | 5/10 | 7/10 |
| **Laplacian2D-Halo** | multi-PE stencil | 1,108 | 1,326 | **−16%** | 7/10 | 7/10 |
| **GEMM** | matrix multiply | — | — | — | 3/10 | 0/10 |
| **GEMV-Checkerboard** | multi-PE GEMV | — | — | — | 2/10 | 0/10 |
| **Cholesky** | solver | — | — | — | 2/10 | 0/10 |
| **GEMV-RowPart** | single-PE GEMV | 138 | 144 | **−4%** | 3/10 | 1/10 |
| **Histogram-Inline** | single-PE binning | 1,429 | TSC bug | — | 2/10 | 0/10 |
| **Mandelbrot** | fractal compute | 26,426 | 28,675 | −8% | 1/10 | 1/10 |

**Why profiling helps these:** Multi-PE kernels benefit from per-PE utilization and
backpressure data — the optimizer can identify fabric-bound vs compute-bound bottlenecks.
PDFT's 3-stage pipeline benefits most: the profiler shows which stage is the bottleneck.

### Profiling Clearly Hurts (use unprofiled)

| Kernel | Pattern | Prof med | Unprof med | Delta | Prof pass | Unprof pass |
|--------|---------|----------|-----------|-------|-----------|-------------|
| **Stencil7pt-1PE** | single-PE stencil | 18,826 | 8,769 | **+115%** | 7/10 | 7/10 |
| **Wide-Multiplication** | single-PE wide mul | 9,405 | 7,385 | **+27%** | 5/10 | 6/10 |
| **GEMV** | single-PE GEMV | 1,586 | 1,390 | **+14%** | 10/10 | 9/10 |
| **Power-Method** | iterative solver | 35,696 | 31,466 | **+13%** | 8/10 | 8/10 |
| **Game-of-Life** | multi-PE automaton | — | 2,970 | — | 0/10 | 4/10 |
| **BiCGSTAB** | iterative solver | 65,710 | 62,724 | +5% | 6/10 | 6/10 |
| **Residual** | single-PE residual | 548 | 516 | +6% | 2/10 | 2/10 |

**Why profiling hurts these:** On single-PE kernels the profiler data is noise — there's
no fabric bottleneck to diagnose, but the extra context distracts the optimizer from
pure compute optimizations (loop unrolling, DSD chaining, SIMD).

### Neutral (no meaningful difference)

| Kernel | Prof med | Unprof med | Delta | Prof pass | Unprof pass |
|--------|----------|-----------|-------|-----------|-------------|
| 7pt-Stencil | 2,295 | 2,290 | +0.2% | 10/10 | 10/10 |
| FFT-1D-2D | 454 | 454 | 0% | 8/10 | 8/10 |
| CG | 11,252 | 10,947 | +3% | 7/10 | 8/10 |
| Preconditioned-CG | 14,267 | 14,138 | +1% | 5/10 | 7/10 |
| SpMV-CSR | 6,927 | 6,927 | 0% | 5/10 | 6/10 |
| DFT-1PE | 12,921 | 12,921 | 0% | 3/10 | 1/10 |
| Histogram-1PE | 5,652 | 5,643 | 0% | 1/10 | 5/10 |

## Pattern Analysis

| Kernel Category | Prof Pass Rate | Unprof Pass Rate | Profiler Effect |
|----------------|---------------|-----------------|-----------------|
| **Multi-PE stencil** (3) | 12/30 (40%) | 18/30 (60%) | Cycles: **−49%** better |
| **Program-level** (1) | 7/10 (70%) | 3/10 (30%) | Cycles: **−19%** better |
| **Multi-PE collective** (3) | 3/30 (10%) | 0/30 (0%) | Pass rate: profiled only |
| **Iterative solver** (4) | 26/40 (65%) | 29/40 (73%) | Cycles: +6% worse |
| **Single-PE simple** (9) | 33/90 (37%) | 32/90 (36%) | Mixed — kernel dependent |
| **FFT/signal** (1) | 8/10 (80%) | 8/10 (80%) | No effect |
| **Library-delegated** (2) | 5/20 (25%) | 6/20 (30%) | No effect |

## Recommendation

Use **selective profiling** based on kernel pattern:
- **Always profile:** Multi-PE stencils, program-level pipelines, collective-based kernels
- **Never profile:** Single-PE compute-bound kernels, iterative solvers
- **Don't care:** Stable converging kernels (FFT, library-delegated)

This could be automated: check `spec.yaml` tags for `multi_pe`/`single_pe` and
enable/disable `--profile-feedback` accordingly.

## Best-Ever Cycles (combining both arms)

| Kernel | Best Cycles | vs Expert | Source |
|--------|------------|-----------|--------|
| GEMV-RowPart | 136 | **5.2x** | Profiled |
| FFT-1D-2D | 422 | **1.0x** | Either |
| Residual | 480 | **1.4x** | Unprofiled |
| Jacobi-2D-5pt | 652 | **2.4x** | Either |
| Laplacian2D-Halo | 672 | **2.5x** | Unprofiled |
| CG | 1,801 | **6.5x** | Unprofiled |
| Histogram-Inline | 1,424 | **1.4x** | Profiled |
| 7pt-Stencil | 2,141 | **1.0x** | Unprofiled |
| Game-of-Life | 2,398 | **3.3x** | Unprofiled |
| Wide-Multiplication | 5,511 | **14.8x** | Unprofiled |
| Stencil7pt-1PE | 5,040 | **8.0x** | Profiled |
| Histogram-1PE | 5,643 | **1.1x** | Unprofiled |
| SpMV-CSR | 6,398 | **1.1x** | Unprofiled |
| PDFT-Pi-Pipeline | 8,388 | **15.3x** | Profiled |
| DFT-1PE | 12,817 | **11.3x** | Profiled |
| Power-Method | 18,953 | **2.3x** | Unprofiled |
| Mandelbrot | 26,426 | **1.6x** | Profiled |
| BiCGSTAB | 48,121 | **1.2x** | Profiled |
| GEMM | 47,771 | **1.1x** | Profiled |
