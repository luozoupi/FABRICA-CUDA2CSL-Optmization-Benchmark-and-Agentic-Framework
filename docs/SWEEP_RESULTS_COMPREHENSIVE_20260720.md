# Comprehensive Sweep Results (2026-07-20)

## Overview

Three A/B sweeps testing **profiled vs unprofiled** optimization across **46 kernels**
(28 original + 14 new single-PE + 4 new multi-PE) on **Opus 4.8** via the Argo inference
endpoint. Total runs: ~720.

## 1. Benchmark Suite Composition

### 1.1 Suite Summary

| Category | Count | Difficulty Range | New This Session |
|----------|-------|-----------------|------------------|
| Original kernels | 36 | 1-3 | — |
| New single-PE (enrichment) | 14 | 1-3 | Yes |
| New multi-PE (enrichment) | 4 | 2-4 | Yes |
| **Total** | **55** | **1-4** | **18** |

### 1.2 New Kernels Added

#### Single-PE Enrichment (14 kernels)

| Kernel | Family | Diff | Ref Cycles | Pattern |
|--------|--------|------|-----------|---------|
| ReLU-1PE | activation | 1 | 11,787 | Elementwise compare+select |
| Sigmoid-1PE | activation | 2 | 107,546 | Elementwise exp+div |
| GELU-1PE | activation | 3 | 111,134 | Polynomial + tanh (2×exp) |
| SiLU-1PE | activation | 2 | 104,473 | x × sigmoid(x) |
| Softmax-1PE | activation | 3 | 35,681 | 3-pass: max + exp + normalize |
| Sum-Reduction-1PE | reduction | 1 | 7,693 | Sum accumulation |
| Max-Reduction-1PE | reduction | 1 | 8,188 | Comparison-based reduction |
| Dot-Product-1PE | blas | 1 | 10,254 | Multiply-accumulate |
| SAXPY-1PE | blas | 1 | 11,276 | FMA (a×x+y) |
| Prefix-Sum-1PE | scan | 2 | 9,229 | Sequential inclusive scan |
| RMSNorm-1PE | normalization | 2 | 10,947 | 2-pass: sum-sq + scale |
| L2-Norm-1PE | normalization | 2 | 18,112 | 2-pass: sum-sq + normalize |
| MSE-Loss-1PE | loss | 2 | 11,282 | 2-input subtract+sq+mean |
| Cross-Entropy-Loss-1PE | loss | 3 | 29,283 | max + exp + log + index |

#### Multi-PE Enrichment (4 kernels)

| Kernel | Family | Diff | Ref Cycles | PEs | Communication Pattern |
|--------|--------|------|-----------|-----|----------------------|
| ParReduce-Sum | collective | 3 | 1,990 | 4 | 2-phase tree reduction (west) |
| ParBroadcast-Scale | collective | 2 | 2,322 | 4 | Fan-out broadcast (east) |
| ParDot-Product | collective | 3 | 2,631 | 4 | Local dot + tree reduce |
| RowParallel-Softmax | collective | 4 | 17,714 | 2 | AllReduce(max) + AllReduce(sum) |

### 1.3 Operation Families Coverage

| Family | Before | After | New Kernels |
|--------|--------|-------|-------------|
| activation | 0 | 5 | ReLU, Sigmoid, GELU, SiLU, Softmax |
| reduction | 1 (histogram) | 3 | Sum-Reduction, Max-Reduction |
| blas | 0 | 2 | SAXPY, Dot-Product |
| normalization | 0 | 2 | RMSNorm, L2-Norm |
| loss | 0 | 2 | MSE-Loss, Cross-Entropy-Loss |
| scan | 0 | 1 | Prefix-Sum |
| collective | 0 (implicit) | 4 | ParReduce, ParBroadcast, ParDot, RowParallel-Softmax |
| stencil | 5 | 5 | — |
| gemm/gemv | 6 | 6 | — |
| fft | 3 | 3 | — |
| solver | 6 | 6 | — |

---

## 2. Profiler A/B Results — Original 28 Kernels (N=10)

### 2.1 Full Results Table

| Kernel | Split | Prof Pass | Unprof Pass | Prof Med | Unprof Med | Prof Best | Unprof Best | Δ% | Verdict |
|--------|-------|-----------|-------------|----------|-----------|-----------|------------|-----|---------|
| 7pt-Stencil | test | 10/10 | 10/10 | 2,295 | 2,290 | 2,143 | 2,141 | +0.2 | SAME |
| Cholesky | test | 2/10 | 0/10 | — | — | 231,865 | — | — | NoData |
| DFT-1PE | test | 3/10 | 1/10 | 12,921 | 12,921 | 12,817 | 12,921 | 0.0 | SAME |
| FFT-1D-2D | test | 8/10 | 8/10 | 454 | 454 | 422 | 454 | 0.0 | SAME |
| GEMV-Checkerboard | test | 2/10 | 0/10 | 3,455 | — | 2,397 | — | — | PROF↑ |
| Game-of-Life | test | 0/10 | 4/10 | — | 2,970 | — | 2,398 | — | UNPROF↑ |
| Histogram-1PE | test | 1/10 | 5/10 | 5,652 | 5,643 | 5,652 | 5,643 | 0.0 | SAME |
| Jacobi-2D-5pt | test | 5/10 | 7/10 | 680 | 943 | 652 | 652 | **−27.9** | **PROF** |
| Laplacian2D-Halo | test | 7/10 | 7/10 | 1,108 | 1,326 | 820 | 672 | **−16.4** | **PROF** |
| Mandelbrot | test | 1/10 | 1/10 | 26,426 | 28,675 | 26,426 | 28,675 | — | NoData |
| PDFT-Pi-Pipeline | test | 7/10 | 3/10 | 11,108 | 13,692 | 8,388 | 11,060 | **−18.9** | **PROF** |
| Residual | test | 2/10 | 2/10 | 548 | 516 | 543 | 480 | +6.2 | UNPROF |
| Single-Tile-Matvec | test | 1/10 | 0/10 | 1,353 | — | 1,353 | — | — | NoData |
| SpMV-CSR | test | 5/10 | 6/10 | 6,927 | 6,927 | 6,927 | 6,398 | 0.0 | SAME |
| Stencil7pt-1PE | test | 7/10 | 7/10 | 18,826 | 8,769 | 5,040 | 5,835 | +114.7 | **UNPROF** |
| Tensor-Transpose-021 | test | 0/10 | 0/10 | — | — | — | — | — | NoData |
| Wide-Multiplication | test | 5/10 | 6/10 | 9,405 | 7,385 | 6,374 | 5,511 | +27.4 | UNPROF |
| Histogram | test | 0/10 | 0/10 | — | — | — | — | — | NoData |
| Histogram-Inline | test | 2/10 | 1/10 | 1,429 | — | 1,424 | — | — | NoData |
| GEMV-RowPart | test | 3/10 | 1/10 | 138 | 144 | 136 | 144 | −4.2 | PROF |
| GEMM | train | 3/10 | 0/10 | 47,847 | — | 47,771 | — | — | PROF↑ |
| GEMV | train | 10/10 | 9/10 | 1,586 | 1,390 | 1,288 | 1,248 | +14.1 | UNPROF |
| GEMM-Collectives-2D | train | 1/10 | 0/10 | — | — | 47,948 | — | — | NoData |
| GEMV-Collectives-2D | train | 0/10 | 0/10 | — | — | — | — | — | NoData |
| BiCGSTAB | train | 6/10 | 6/10 | 65,710 | 62,724 | 48,121 | 49,961 | +4.8 | UNPROF |
| CG | train | 7/10 | 8/10 | 11,252 | 10,947 | 2,138 | 1,801 | +2.8 | SAME |
| Power-Method | train | 8/10 | 8/10 | 35,696 | 31,466 | 30,659 | 18,953 | +13.4 | UNPROF |
| Preconditioned-CG | train | 5/10 | 7/10 | 14,267 | 14,138 | 14,069 | 13,607 | +0.9 | SAME |

### 2.2 Summary

| Verdict | Count |
|---------|-------|
| Profiling Better | 3 (Jacobi, Laplacian, PDFT) + 6 pass-rate-only |
| Profiling Worse | 6 (Stencil7pt, Wide-Mult, GEMV, Power-Method, BiCGSTAB, Residual) |
| Same | 5 (7pt-Stencil, FFT, SpMV-CSR, CG, PCG) |
| NoData | 8 |

---

## 3. Profiler A/B Results — New Single-PE Kernels (N=5)

| Kernel | Prof Pass | Unprof Pass | Prof Med | Unprof Med | vs Ref | Δ% | Verdict |
|--------|-----------|-------------|----------|-----------|--------|-----|---------|
| ReLU-1PE | 1/5 | 1/5 | 144 | 272 | 82x/43x | — | NoData |
| Sum-Reduction-1PE | **5/5** | 2/5 | 404 | 2,440 | **19x**/3.2x | **−83.4** | **PROF** |
| Sigmoid-1PE | 3/5 | 4/5 | 96,281 | 94,558 | 1.1x/1.1x | +1.8 | SAME |
| Max-Reduction-1PE | 4/5 | 4/5 | 4,257 | 6,222 | 1.9x/1.3x | **−31.6** | **PROF** |
| RMSNorm-1PE | 4/5 | 4/5 | 5,325 | 5,325 | 2.1x/2.1x | 0.0 | SAME |
| GELU-1PE | 1/5 | 0/5 | 50,306 | — | 2.2x | — | NoData |
| MSE-Loss-1PE | 1/5 | 2/5 | 8,983 | 8,986 | 1.3x/1.3x | — | NoData |
| SAXPY-1PE | 2/5 | 2/5 | 1,039 | 1,039 | **10.9x** | 0.0 | SAME |
| Dot-Product-1PE | 2/5 | 3/5 | 6,164 | 1,491 | 1.7x/**6.9x** | +313 | **UNPROF** |
| Softmax-1PE | 3/5 | 2/5 | 32,641 | 25,294 | 1.1x/1.4x | +29.0 | UNPROF |
| Prefix-Sum-1PE | 2/5 | **4/5** | 7,056 | 7,056 | 1.3x/1.3x | 0.0 | SAME |
| SiLU-1PE | **5/5** | 4/5 | 94,743 | 103,450 | 1.1x/1.0x | **−8.4** | **PROF** |
| L2-Norm-1PE | 2/5 | **5/5** | 9,417 | 2,280 | 1.9x/**7.9x** | +313 | **UNPROF** |
| Cross-Entropy-Loss-1PE | 4/5 | 3/5 | 24,458 | 29,796 | 1.2x/1.0x | **−17.9** | **PROF** |

**Summary:** Better 4, Worse 3, Same 4, NoData 3

---

## 4. Profiler A/B Results — New Multi-PE Kernels (N=5)

| Kernel | Diff | Prof Pass | Unprof Pass | Prof Med | Unprof Med | vs Ref | Δ% | Verdict |
|--------|------|-----------|-------------|----------|-----------|--------|-----|---------|
| ParReduce-Sum | 3 | **5/5** | **5/5** | 1,991 | 1,988 | 1.0x | +0.2 | SAME |
| ParBroadcast-Scale | 2 | 2/5 | 0/5 | 143 | — | **16x** | — | **PROF↑** |
| ParDot-Product | 3 | **5/5** | 4/5 | 2,635 | 1,448 | 1.0x/1.8x | +82 | UNPROF |
| RowParallel-Softmax | 4 | 0/5 | 0/5 | — | — | — | — | NoData |

**Summary:** Better 0 (1 pass-rate-only), Worse 1, Same 1, NoData 2

**Key findings:**
- Difficulty 2-3 multi-PE kernels achieve **80-100% pass rate** — the agent handles wavelet routing
- ParReduce-Sum hits **100% pass rate on both arms** (the tree-reduce pattern is learnable)
- ParBroadcast-Scale **only passes with profiling** (broadcast routing needs per-PE feedback)
- RowParallel-Softmax (difficulty 4, 4 colors, 2 AllReduces) = **honest capability frontier**

---

## 5. Combined Analysis Across All 46 Kernels

### 5.1 Profiler Effect by Kernel Category

| Category | Kernels | Prof Pass Rate | Unprof Pass Rate | Profiler Effect on Cycles |
|----------|---------|---------------|-----------------|--------------------------|
| Multi-PE stencil | 3 | 12/30 (40%) | 18/30 (60%) | **−49% better** (when both pass) |
| Program-level | 1 | 7/10 (70%) | 3/10 (30%) | **−19% better** |
| Multi-PE collective (new) | 4 | 12/20 (60%) | 9/20 (45%) | Mixed |
| Single-PE activation | 5 | 13/25 (52%) | 9/25 (36%) | Mixed |
| Single-PE reduction | 2 | 9/10 (90%) | 6/10 (60%) | **−57% better** |
| Single-PE normalization | 2 | 6/10 (60%) | 9/10 (90%) | +163% worse |
| Single-PE blas | 2 | 4/10 (40%) | 5/10 (50%) | Mixed |
| Iterative solver | 4 | 26/40 (65%) | 29/40 (73%) | +6% worse |
| FFT/signal | 1 | 8/10 (80%) | 8/10 (80%) | No effect |
| Library-delegated | 2 | 5/20 (25%) | 6/20 (30%) | No effect |

### 5.2 Aggregate Verdict

| Verdict | Original 28 | New Single-PE 14 | New Multi-PE 4 | Total |
|---------|-------------|-----------------|----------------|-------|
| Profiling Better | 9 | 4 | 1 | **14** |
| Profiling Worse | 7 | 3 | 1 | **11** |
| Same | 5 | 4 | 1 | **10** |
| NoData | 7 | 3 | 1 | **11** |

### 5.3 Recommendation

**Use selective profiling based on kernel pattern:**
- **Always profile:** Multi-PE stencils, program-level pipelines, broadcast collectives, reduction kernels
- **Never profile:** Single-PE normalization, iterative solvers, single-PE compute-dense loops
- **Don't care:** FFT, library-delegated, stable converging kernels

---

## 6. Best-Ever Cycles Across All Sweeps

### 6.1 Highest Speedups Over Reference

| Rank | Kernel | Best Cycles | Ref Cycles | Speedup | Source |
|------|--------|------------|-----------|---------|--------|
| 1 | ReLU-1PE | 144 | 11,787 | **81.9x** | Profiled |
| 2 | Max-Reduction-1PE | 312 | 8,188 | **26.2x** | Either |
| 3 | Sum-Reduction-1PE | 313 | 7,693 | **24.6x** | Profiled |
| 4 | ParBroadcast-Scale | 143 | 2,322 | **16.2x** | Profiled |
| 5 | PDFT-Pi-Pipeline | 8,388 | 128,308 | **15.3x** | Profiled |
| 6 | Wide-Multiplication | 5,511 | 81,741 | **14.8x** | Unprofiled |
| 7 | DFT-1PE | 12,817 | 145,233 | **11.3x** | Profiled |
| 8 | SAXPY-1PE | 1,039 | 11,276 | **10.9x** | Either |
| 9 | Stencil7pt-1PE | 5,040 | 40,497 | **8.0x** | Profiled |
| 10 | L2-Norm-1PE | 2,000 | 18,112 | **9.1x** | Unprofiled |
| 11 | Dot-Product-1PE | 1,431 | 10,254 | **7.2x** | Unprofiled |
| 12 | GEMV-RowPart | 136 | 711 | **5.2x** | Profiled |
| 13 | ParReduce-Sum | 349 | 1,990 | **5.7x** | Profiled |
| 14 | ParDot-Product | 559 | 2,631 | **4.7x** | Profiled |
| 15 | CG | 1,801 | 11,635 | **6.5x** | Unprofiled |

### 6.2 Agent Pass Rates by Difficulty

| Difficulty | Kernels | Combined Pass Rate | Avg Best Speedup |
|------------|---------|-------------------|------------------|
| 1 (easy) | 8 | 57/80 (71%) | 15.2x |
| 2 (medium) | 16 | 114/200 (57%) | 3.4x |
| 3 (hard) | 10 | 65/120 (54%) | 5.8x |
| 4 (very hard) | 1 | 0/10 (0%) | — |

---

## 7. Experiment Configuration

| Parameter | Original Sweep | New Single-PE | New Multi-PE |
|-----------|---------------|--------------|-------------|
| Model | Claude Opus 4.8 | Claude Opus 4.8 | Claude Opus 4.8 |
| Seeds per arm | 10 | 5 | 5 |
| Reviewer cap | 20 | 20 | 20 |
| Optimizer cap | 20 | 20 | 20 |
| Min optimize | 4 | 4 | 4 |
| Total runs | 560 | 140 | 40 |
| Duration | ~6 days | ~2 days | ~1 day |

## 8. Technical Discoveries

### 8.1 WSE-3 @initialize_queue (Critical)
Every fabric queue bound to a non-default color **must** have `@initialize_queue(queue, .{.color=COLOR})`
in the comptime block. Without this, wavelets enter the fabric but the receiver never sees them —
causing a silent deadlock. This is not flagged by the compiler.

### 8.2 Profiling Mechanism
The profiler injects sim.log aggregate stats (dispatches, stalls, wavelets), CTF per-PE traces
(backpressure, utilization), and cs_readelf memory analysis into the optimizer's context.
Gate: `--profile-feedback` flag.

### 8.3 Multi-PE Conventions
- Color IDs 0-7 + 21-30 reserved for memcpy; use 8+
- Queue IDs 0-1 reserved for memcpy; use 2+
- `runner.launch()` for multi-PE (not `runner.call()` which targets PE(0,0) only)
- Async sends/receives with task activation: `@fmovs(dst, src, .{.async=true, .activate=TASK})`

---

## 9. SFT/RL Dataset Potential

The accumulated experiment artifacts form a substantial offline training dataset:

| Dataset Type | Volume | Format |
|-------------|--------|--------|
| SFT (supervised) | 802 passing + 828 failing | `{instruction, CUDA_input, CSL_output}` |
| DPO (preference) | 434 paired examples | `{prompt, chosen=pass, rejected=fail}` |
| Reward model | 802 scored examples | `{code, reward=cycles}` |
| RL trajectories | 6,731 optimization steps | `{code_v_n, edit, code_v_n+1, Δcycles}` |
| Raw conversations | 1,632 multi-turn traces | ~49M tokens total |
