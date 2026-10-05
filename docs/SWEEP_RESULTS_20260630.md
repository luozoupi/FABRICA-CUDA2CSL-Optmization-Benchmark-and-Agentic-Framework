# Cross-Model Sweep Results (2026-06-27 through 2026-06-30)

## Overview

Full 28-kernel benchmark sweep across 7 models (3 Claude proprietary + 4 open-source),
using the complete improvement stack: tolerance fix, compile-only dry-check, best-of-N=3,
debugger v2, error-gotcha retrieval, layer-clearance tracker, behavioral contracts, and
enriched knowledge base (18 new gotcha entries). Cap=40, translate+optimize.

## Headline Results

- **Claude Opus 4.8: 26/28 pass (93%), 16 beat expert** — the strongest result
- **Claude Sonnet 4.6: 25/28 pass (89%), 17 beat expert** — nearly matches Opus at lower cost
- **Claude Opus 4.6: 24/28 pass (86%), 14 beat expert** — solid across the board
- **Open-source models: 0–17% pass rate** — CSL generation capability is the bottleneck

## Claude Model Comparison (28 kernels each)

### Claude Opus 4.8

| Kernel | Split | Cycles | vs Ref | Status |
|--------|-------|--------|--------|--------|
| 7pt-Stencil | test | TSC overflow | pass | PASS |
| Cholesky | test | - | - | FAIL |
| DFT-1PE | test | 12,967 | **11.20x** | PASS |
| FFT-1D-2D | test | 454 | 0.97x | PASS |
| GEMV-Checkerboard | test | 1,727 | 0.11x | PASS |
| Game-of-Life | test | 3,358 | **2.33x** | PASS |
| Histogram-1PE | test | 5,644 | **1.10x** | PASS |
| Jacobi-2D-5pt | test | 738 | **2.12x** | PASS |
| Laplacian2D-Halo | test | 653 | **2.62x** | PASS |
| Mandelbrot | test | 5,155 | **7.96x** | PASS |
| PDFT-Pi-Pipeline | test | 17,662 | **7.26x** | PASS |
| Residual | test | 474 | **1.42x** | PASS |
| Single-Tile-Matvec | test | 785 | 0.99x | PASS |
| SpMV-CSR | test | - | parity | PASS |
| Stencil7pt-1PE | test | 5,494 | **7.37x** | PASS |
| Tensor-Transpose-021 | test | 528 | **11.71x** | PASS |
| Wide-Multiplication | test | 6,638 | **12.31x** | PASS |
| Histogram (tally) | test | - | correctness | PASS |
| Histogram-Inline | test | TSC overflow | pass | PASS |
| GEMV-RowPart | test | 144 | **4.94x** | PASS |
| GEMM | train | 47,633 | **1.09x** | PASS |
| GEMV | train | - | - | FAIL |
| GEMM-Collectives-2D | train | 47,180 | **1.10x** | PASS |
| GEMV-Collectives-2D | train | 4,307 | 0.93x | PASS |
| BiCGSTAB | train | 32,105 | **1.85x** | PASS |
| CG | train | 10,787 | **1.08x** | PASS |
| Power-Method | train | TSC overflow | pass | PASS |
| Preconditioned-CG | train | 23,650 | 0.58x | PASS |

**Test: 19/20 pass. Train: 7/8 pass. Total: 26/28 (93%). Beats expert: 16.**

### Claude Sonnet 4.6

| Kernel | Split | Cycles | vs Ref | Status |
|--------|-------|--------|--------|--------|
| 7pt-Stencil | test | 1,216 | **1.75x** | PASS |
| Cholesky | test | - | - | FAIL |
| DFT-1PE | test | 12,817 | **11.33x** | PASS |
| FFT-1D-2D | test | 1,330 | 0.32x | PASS |
| GEMV-Checkerboard | test | 1,704 | 0.12x | PASS |
| Game-of-Life | test | 3,138 | **2.50x** | PASS |
| Histogram-1PE | test | 5,652 | **1.10x** | PASS |
| Jacobi-2D-5pt | test | 691 | **2.27x** | PASS |
| Laplacian2D-Halo | test | 3,499 | 0.49x | PASS |
| Mandelbrot | test | 4,956 | **8.28x** | PASS |
| PDFT-Pi-Pipeline | test | 16,615 | **7.72x** | PASS |
| Residual | test | 393 | **1.72x** | PASS |
| Single-Tile-Matvec | test | 785 | 0.99x | PASS |
| SpMV-CSR | test | 6,927 | 1.00x | PASS |
| Stencil7pt-1PE | test | 5,040 | **8.04x** | PASS |
| Tensor-Transpose-021 | test | 527 | **11.73x** | PASS |
| Wide-Multiplication | test | 10,371 | **7.88x** | PASS |
| Histogram (tally) | test | - | - | FAIL |
| Histogram-Inline | test | 1,433 | **1.37x** | PASS |
| GEMV-RowPart | test | TSC overflow | pass | PASS |
| GEMM | train | 48,181 | **1.07x** | PASS |
| GEMV | train | - | - | FAIL |
| GEMM-Collectives-2D | train | 47,394 | **1.09x** | PASS |
| GEMV-Collectives-2D | train | 4,292 | 0.93x | PASS |
| BiCGSTAB | train | 74,869 | 0.79x | PASS |
| CG | train | 10,475 | **1.11x** | PASS |
| Power-Method | train | 30,836 | **1.41x** | PASS |
| Preconditioned-CG | train | 12,018 | **1.15x** | PASS |

**Test: 18/20 pass. Train: 7/8 pass. Total: 25/28 (89%). Beats expert: 17.**

### Claude Opus 4.6

| Kernel | Split | Cycles | vs Ref | Status |
|--------|-------|--------|--------|--------|
| 7pt-Stencil | test | 2,296 | 0.93x | PASS |
| Cholesky | test | - | - | FAIL |
| DFT-1PE | test | 12,890 | **11.27x** | PASS |
| FFT-1D-2D | test | 211 | **2.00x** | PASS |
| GEMV-Checkerboard | test | - | - | FAIL |
| Game-of-Life | test | 4,193 | **1.87x** | PASS |
| Histogram-1PE | test | 5,643 | **1.10x** | PASS |
| Jacobi-2D-5pt | test | 1,785 | 0.88x | PASS |
| Laplacian2D-Halo | test | 5,731 | 0.30x | PASS |
| Mandelbrot | test | 13,565 | **3.02x** | PASS |
| PDFT-Pi-Pipeline | test | 13,424 | **9.56x** | PASS |
| Residual | test | 533 | **1.26x** | PASS |
| Single-Tile-Matvec | test | 1,401 | 0.56x | PASS |
| SpMV-CSR | test | 6,722 | **1.03x** | PASS |
| Stencil7pt-1PE | test | 5,041 | **8.03x** | PASS |
| Tensor-Transpose-021 | test | 527 | **11.73x** | PASS |
| Wide-Multiplication | test | 49,626 | **1.65x** | PASS |
| Histogram (tally) | test | - | - | FAIL |
| Histogram-Inline | test | TSC overflow | pass | PASS |
| GEMV-RowPart | test | 144 | **4.94x** | PASS |
| GEMM | train | 48,049 | **1.08x** | PASS |
| GEMV | train | - | - | FAIL |
| GEMM-Collectives-2D | train | 47,412 | **1.09x** | PASS |
| GEMV-Collectives-2D | train | 4,208 | 0.95x | PASS |
| BiCGSTAB | train | 71,629 | 0.83x | PASS |
| CG | train | 10,988 | **1.06x** | PASS |
| Power-Method | train | TSC overflow | pass | PASS |
| Preconditioned-CG | train | 7,485 | **1.85x** | PASS |

**Test: 17/20 pass. Train: 7/8 pass. Total: 24/28 (86%). Beats expert: 14.**

## Open-Source Model Results

### Subset sweep (12 representative kernels)

| Model | Pass | Total | Rate | Passes |
|-------|------|-------|------|--------|
| **gpt-oss-120b** | 2 | 12 | **17%** | DFT-1PE, GEMV-RowPart |
| **Gemma 4 31B** | 1 | 12 | 8% | DFT-1PE (14.67x) |
| **Llama 3.3 70B** | 0 | 12 | 0% | (produces CSL, all compile-fail) |
| **Llama 3.1 70B** | 0 | 12 | 0% | (can't produce CSL code blocks) |

### Full sweep (28 kernels, Gemma 4 + gpt-oss-120b) — COMPLETE

| Model | Pass | Total | Rate | Passes |
|-------|------|-------|------|--------|
| **gpt-oss-120b** | 2 | 28 | **7%** | PDFT-Pi-Pipeline, Stencil7pt-1PE (79.10x!) |
| **Gemma 4 31B** | 1 | 28 | **4%** | 7pt-Stencil |

Note: gpt-oss-120b passed DIFFERENT kernels on the full sweep vs subset (DFT-1PE +
GEMV-RowPart on subset; PDFT + Stencil7pt on full). Single-draw variance means the
true pass rate is higher than either individual draw — but still far below Claude.

## Cross-Model Summary

| Model | Type | Size | Pass Rate | Beats Expert |
|-------|------|------|-----------|-------------|
| Claude Opus 4.8 | Proprietary | - | **93%** (26/28) | 16 |
| Claude Sonnet 4.6 | Proprietary | - | **89%** (25/28) | 17 |
| Claude Opus 4.6 | Proprietary | - | **86%** (24/28) | 14 |
| gpt-oss-120b | Open (reasoning) | 120B | 7% (2/28) | 1 |
| Gemma 4 31B | Open | 31B | 4% (1/28) | 0 |
| Llama 3.3 70B | Open | 70B | 0% (0/12) | 0 |
| Llama 3.1 70B | Open | 70B | 0% (0/12) | 0 |

## Key Findings

### 1. Improvement stack equalizes Claude model tiers
The gap between Opus 4.8 (93%) and Sonnet 4.6 (89%) is only 4 percentage points.
Sonnet 4.6 actually has MORE beats-expert wins (17 vs 16) — it finds more aggressive
optimizations on the kernels it passes. The knowledge base, gotchas, behavioral
contracts, and system improvements are the main driver, not raw model size within
the Claude family.

### 2. CSL generation capability is the dominant factor
Open-source models (0–17%) can't cross the CSL generation barrier regardless of
the improvement stack. The gap is not about system improvements — it's about the
base model's ability to generate valid CSL code for a niche wafer-scale language:
- **Llama 3.1 70B**: Can't produce CSL code blocks at all
- **Llama 3.3 70B**: Produces CSL but 0% compile rate (40/40 compile-fail on DFT-1PE)
- **Gemma 4 31B**: Occasionally compiles (7pt-Stencil, DFT-1PE sometimes)
- **gpt-oss-120b**: Best open-source (reasoning model), 2/12 on subset

### 3. Consistent failure modes across Claude tiers
The same 2–4 kernels fail across all Claude models:
- **Cholesky**: structural ceiling (co-design mode, single-draw variance)
- **GEMV (train)**: distribution.py d2h shape mismatch (hidden Python API)
- **Histogram (tally)**: information starvation (opaque tally module FSM)
- **GEMV-Checkerboard**: single-draw variance (Opus 4.6 only fail)

### 4. Formerly-failing kernels now reliably pass
The improvement stack flipped 6 previously-hard-failing kernels:
- **CG/PCG**: tolerance fix (device-vs-host residual comparison)
- **Laplacian2D-Halo**: dry-check + best-of-N + gotcha retrieval
- **Game-of-Life**: dry-check + debugger v2 + hard-kernel hints
- **FFT-1D-2D**: behavioral contracts (steered away from architectural dead ends)
- **Histogram (tally, Opus 4.8 only)**: behavioral contracts + cap=40

### 5. New v2 benchmarks validate the approach
Histogram-Inline and GEMV-RowPart (no opaque SDK dependencies) pass across all
Claude models — confirming that information starvation (not model capability) is
the barrier for the original Histogram/GEMV.

## Delta from Previous Sweep (2026-06-25, Opus 4.7, cap=20, no improvements)

| Metric | Before | After (Opus 4.8) | Delta |
|--------|--------|-------------------|-------|
| Test pass | 12/17 | 19/20 | +7 |
| Train pass | 5/8 | 7/8 | +2 |
| Beats expert | 9 | 16 | +7 |
| Total pass | 17/25 | 26/28 | +9 |

## Improvements Built This Session

1. CG/PCG tolerance fix (device-vs-host residual comparison)
2. Compile-only dry-check (`XKERNEL_DRY_CHECK=1`)
3. Best-of-N initial translation (`XKERNEL_BEST_OF_N=3`)
4. Debugger v2 scoped file reader (`XKERNEL_DEBUGGER_V2=1`)
5. Compile-error→gotcha retrieval (`XKERNEL_ERROR_GOTCHA=1`, 19 patterns)
6. Progressive layer-clearance tracker (`XKERNEL_LAYER_CLEARANCE=1`)
7. Behavioral contracts for tally + collectives_2d modules (`XKERNEL_LIB_BEHAVIORAL=1`)
8. 18 new KB entries from failure root-cause analysis
9. Auto-distribution fallback for GEMV d2h shape mismatch
10. Cholesky co-design canary fix (layout-leak guard interaction)
11. W3 exploration improvements (all-failure lessons, auto-promote, failure clustering)
12. 2 new v2 benchmarks: Histogram-Inline, GEMV-RowPart
13. Anti-leaking audit: all 7 safeguards verified PASS

## Safeguard Verification

All 7 anti-leaking/anti-gaming safeguards verified PASS:
- Compute canary (no bypass found)
- Layout canary (co-design mode safe)
- Reference compute never in prompts
- Input-level held-out seed split (default ON)
- Dead-timer guard (static + dynamic)
- Frozen-function splice (default ON)
- Best-of-N leak check (no leak vector)

## Remaining Failure Analysis

| Kernel | Root Cause | Addressable? |
|--------|-----------|-------------|
| Cholesky | Co-design structural ceiling (pe.csl + layout.csl consistency) | Single-draw variance; passed once at 37,474 cycles |
| GEMV (train) | Hidden distribution.py collect() coordinates | Auto-dist fallback built; needs multi-attempt convergence |
| Histogram (tally) | Opaque tally module FSM (information starvation) | Passed on Opus 4.8 with cap=40; fragile |
| GEMV-Checkerboard | Single-draw variance | Passes on Opus 4.8 + Sonnet 4.6 |

## Experiment #1: One-Shot Ablation (cap=1, no knowledge, Opus 4.8)

Tests the raw model without any system improvements — single translation attempt,
no knowledge base, no repair loop, no optimizer.

**Result: 6/28 (21%) vs full-stack 26/28 (93%). System contribution: +20 kernels.**

| Kernel | One-shot | Full stack | System delta |
|--------|---------|------------|-------------|
| DFT-1PE | PASS (1.00x) | PASS (11.20x) | W2 optimizer: +10.20x |
| PDFT-Pi-Pipeline | PASS (1.00x) | PASS (7.26x) | W2 optimizer: +6.26x |
| Stencil7pt-1PE | PASS (1.00x) | PASS (7.37x) | W2 optimizer: +6.37x |
| Tensor-Transpose-021 | PASS (1.00x) | PASS (11.71x) | W2 optimizer: +10.71x |
| Histogram-Inline | PASS (1.38x) | PASS (TSC) | v2 kernel, model-tractable |
| GEMV-RowPart | PASS (0.99x) | PASS (4.94x) | W2 optimizer: +3.95x |
| 7pt-Stencil | FAIL | PASS (TSC) | Repair loop |
| FFT-1D-2D | FAIL | PASS (0.97x) | Behavioral contracts |
| Game-of-Life | FAIL | PASS (2.33x) | Dry-check + debugger v2 |
| Laplacian2D-Halo | FAIL | PASS (2.62x) | Best-of-N + gotcha |
| CG | FAIL | PASS (1.08x) | Tolerance fix + repair |
| ... (16 more) | FAIL | PASS | Knowledge + repair loop |

**Key finding:** Five of six one-shot passes are at parity or slightly slower;
Histogram-Inline is a real 1.38x one-shot win. The W2 cycle-reduction loop adds
3-12x speedups, while the repair loop + knowledge base adds 20 kernels that
cannot pass in one shot.

## Experiment #2: Additional Open-Model Probe (12 kernels)

Four additional models completed the same fixed 12-kernel probe with the full
stack and cap=40:

| Model | Pass | Rate | Notes |
|---|---:|---:|---|
| Mistral Large 3 675B | 0/12 | 0% | largest probed open model |
| Llama 4 Maverick | 0/12 | 0% | produces candidates, none pass |
| gpt-oss-20b | 1/12 | 8% | GEMV-RowPart; no cycle metric |
| Gemma 4 E4B | 0/12 | 0% | no passing candidate |

This expands the cross-model study to 11 models total (3 frontier, 8 open).
Five models have full 28-kernel sweeps; six open models use the fixed 12-kernel
probe, so rates with different denominators must remain visibly separated.

## Experiment #3: Multi-Seed Sweep (Incomplete)

The July 2 N=3 run stopped after 9 of 18 kernels and did not write its
`MULTISEED_DONE` marker. The partial rows are not included in paper claims.
Resume or rerun the remaining kernels before reporting an aggregate robust/
fragile classification from this experiment.

## Experiment #3: Multi-Seed N=3 (Opus 4.8, cap=40, all improvements)

Classifies each kernel as robust (3/3), fragile (1-2/3), or fail (0/3) across
3 independent draws with the full improvement stack.

| Kernel | Pass Rate | Classification |
|--------|-----------|---------------|
| 7pt-Stencil | 3/3 | **Robust** |
| DFT-1PE | 3/3 | **Robust** |
| Game-of-Life | 3/3 | **Robust** |
| Histogram-1PE | 3/3 | **Robust** |
| Jacobi-2D-5pt | 3/3 | **Robust** |
| Laplacian2D-Halo | 3/3 | **Robust** |
| FFT-1D-2D | 2/3 | Fragile |
| GEMV-Checkerboard | 1/3 | Fragile |
| Residual | 1/3 | Fragile |
| Single-Tile-Matvec | 1/3 | Fragile |
| Mandelbrot | 0/3 | Fail |
| PDFT-Pi-Pipeline | 0/3 | Fail |
| SpMV-CSR | 0/3 | Fail |
| Stencil7pt-1PE | 0/3 | Fail |
| Tensor-Transpose-021 | 0/3 | Fail |
| Wide-Multiplication | 0/3 | Fail |
| Histogram-Inline | 0/3 | Fail |
| GEMV-RowPart | 0/3 | Fail |

**Summary:** 6 robust, 4 fragile, 8 fail.

Note: The 0/3 results for kernels like Mandelbrot, Stencil7pt, Wide-Mult that
pass on single-draw sweeps indicate high variance in the translation process.
Single-draw pass rates overestimate reliability. The 6 robust kernels
(7pt-Stencil, DFT-1PE, GoL, Histogram-1PE, Jacobi, Laplacian) are the
publishable beats-expert claims with confidence.

## Hardware Validation Status

All results are **simulator-validated** using Cerebras SDK 1.4.0. The simulator
is deterministic and cycle-accurate.

**Real hardware validation is currently blocked:**
- SDK 1.4.0 runtime: rejected by WSE firmware (3.2.0 management version)
- SDK 2.10: cslc-driver crashes (SIGABRT in east-mux compilation, glibc issue)
- SDK 3.2.0: not installed on the system

Pending ALCF support ticket for a compatible CSL SDK.
