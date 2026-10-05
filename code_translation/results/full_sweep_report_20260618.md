# Full agentic sweep — report (2026-06-18)

Two complementary sweeps run serially on the WSE-3 node (SDK is a serial
resource; no parallel fan-out). Driver model: claude-opus-4-7 via the Argo
shim (the framework's internal agents); orchestrated by Claude Opus 4.8.

## Sweep 1 — W1 (CUDA→CSL translate) then W2 (optimize passers), all 21 kernels

Per kernel: `cuda2csl --kernel K --auto-optimize --reviewer-max-attempts 8
--min-optimize-attempts 3 --max-optimize-attempts 6 --max-tokens 12288`.

| metric | value |
|---|---|
| W1 pass-rate | **2 / 21** (GEMM, Single-Tile-Matvec; MC-Particle errored) |
| cycle-scored passers | 1 (GEMM) |
| GEMM vs human reference | 51753 → **50487 = −2.4%** (agent translated from CUDA AND beat the human kernel) |
| Single-Tile-Matvec | pass, but NO_CYCLES (correctness only) |

### CRITICAL caveat — this is W1 at a CONSTRAINED budget, not the framework's ceiling
The documented W1 capability is **6–7/15** (`baseline_ablation_report_20260616`,
Sonnet cap-20 / hybrid). This sweep used **`--reviewer-max-attempts 8`**, chosen
to bound a 21-kernel SERIAL batch (~4h) — roughly HALF the repair budget. So
**2/21 measures "W1 under a halved attempt budget," and under-represents the
framework.** It is not comparable to the 6–7/15 headline. A faithful W1
capability sweep needs cap-20 (and ideally the Sonnet→Opus hybrid), which is a
~10h serial run — deferred.

### What Sweep 1 DOES show (robustly, budget-independent)
- W1 difficulty is concentrated exactly where the docs say: the easy single-PE
  / dense kernels (GEMM, Single-Tile-Matvec) pass; collectives / halo / DSR /
  iterative-solver kernels fail to be re-derived from CUDA in 8 attempts.
- The from-CUDA translation, when it succeeds, is competitive: GEMM's agent
  kernel started 5% SLOWER than the human ref (54459 vs 51753) but W2 pulled it
  to 2.4% FASTER — so the translate→optimize pipeline can beat a human baseline
  end-to-end.
- The iterative solvers (Power-Method/CG/PCG/BiCGSTAB) fail W1-from-CUDA
  (re-deriving the on-device state machine from scratch in 8 attempts is very
  hard) — but that is a DIFFERENT workflow from the W2-from-reference path that
  won today (Sweep 2 below).

## Sweep 2 — W2-from-REFERENCE, 14 cycle-instrumented kernels  [COMPLETE]

Optimize each kernel's HUMAN reference CSL directly (`--optimize-only --csl-path
<reference>`, opus-4-7, x2.5 gen-token budget, ≤8 attempts). Measures how much
the agentic optimizer beats each human baseline.

| kernel | ref | best | % vs ref |
|---|---:|---:|---:|
| GEMV | 4003 | 3994 | −0.2 |
| GEMM | 51753 | 49573 | −4.2 |
| GEMV-Collectives-2D | 4003 | 3996 | −0.2 |
| GEMM-Collectives-2D | 51738 | 49558 | −4.2 |
| 7pt-Stencil | 2129 | 1066 | **−49.9** |
| Laplacian2D-Halo | 1709 | 999 | **−41.5** |
| Cholesky | 12479 | 11630 | −6.8 |
| Residual | 674 | 563 | −16.5 |
| Game-of-Life | 7838 | 6739 | −14.0 |
| Wide-Multiplication | 81739 | 12591 | **−84.6** |
| Power-Method | 43436 | 31411 | **−27.7** |
| CG | 11635 | 8276 | **−28.9** |
| Preconditioned-CG | 13826 | 10258 | **−25.8** |
| BiCGSTAB | 59385 | 33811 | **−43.1** |

**HEADLINE: 14/14 kernels beat their human baseline. Geomean 1.44× speedup
(30.6% mean cycle reduction). 7 kernels ≥25%.**

Independently verified (re-run optimized CSL in a fresh bundle via its own
commands_wse3.sh, exact cycles + SUCCESS): Wide-Multiplication (12591),
7pt-Stencil (1066), Power-Method (31411), plus CG/PCG/BiCGSTAB earlier. These
are genuine correctness-preserving speedups, not contract-gamed numbers.

Notable: Power-Method jumped from −3.5% (morning run, x1.6 budget, token-capped)
to −27.7% (x2.5 budget) — the gen-token-budget fix
([[project-w2-gen-token-budget-bug]]) was a large multiplier, not just for the
immune kernels but across the board.

### The contrast that answers the user's question
- W1-from-CUDA (Sweep 1, cap-8): 2/21 pass — translation is the hard,
  information-starved bottleneck (see w1_failure_analysis_20260618.md).
- W2-from-reference (Sweep 2): 14/14 beat baseline, 1.44× geomean — once it
  starts from a correct kernel, the agentic optimizer reliably and often
  dramatically beats the human baselines.

## Why two sweeps
Sweep 1's W2 can only optimize the agent's OWN W1 output (often worse than the
human reference), so it cannot cleanly answer "does the agent beat the
benchmark baseline?" Sweep 2 starts FROM the baseline, so any negative %vs_ref
is a genuine win over the human kernel. The decisive performance numbers are in
Sweep 2.
