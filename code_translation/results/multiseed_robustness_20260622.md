# Multi-seed robustness — putting variance bars on the test-split wins (2026-06-22)

**Why.** The held-out test-split headline reported single-draw results. Translation
is high-variance near the attempt cap (each run is an independent LLM sampling draw;
there is no seed flag). To make the claims rigorous, each scoreable kernel's full
translate+optimize pipeline was re-run N=3 times (hints + frozen-splice on, cap 12)
and we report pass-rate + cycle distribution. Runner: `run_multiseed_robustness.sh`.

## Results (3 independent draws per kernel)
| kernel | rep1 | rep2 | rep3 | pass-rate | cycles (passes) | ref | profile |
|---|---|---|---|---|---|---|---|
| Wide-Multiplication | 11,356 | 8,896 | 9,287 | **3/3** | 8,896–11,356 | 81,739 | **ROBUST** (7.2–9.2× win every draw) |
| Single-Tile-Matvec | 1,249 | 1,008 | 785 | **3/3** | 785–1,249 | 780 | **ROBUST** (parity→1.6× slow; always passes) |
| 7pt-Stencil | 17,026 | 17,146 | 17,026 | **3/3** | 17,026–17,146 | 17,134 | **ROBUST** (parity; library-delegating; tightest spread) |
| Laplacian2D-Halo | fail | 16,664 | fail | **1/3** | 16,664 | 25,627 | **FRAGILE** (halo deadlock; wide quality) |
| Residual | 528 | fail | fail | **1/3** | 528 | 674 | **FRAGILE** (multi-PE comms stall) |
| Game-of-Life | fail | 3,365 ✅ | fail | **1/3** | 3,365 | 7,838 | **FRAGILE** (8-neighbor deadlock; high ceiling) |

**A perfectly clean split: every ROBUST kernel 3/3, every FRAGILE kernel 1/3.**

## The finding: two variance axes, both tracking fabric-routing complexity
1. **Pass-rate axis.** ROBUST kernels (Wide-Mult, Single-Tile-Matvec, 7pt) pass
   ~3/3; FRAGILE kernels (Laplacian, Residual, Game-of-Life) pass ~1/3. The split
   is NOT about kernel "simplicity" or compute size — it is about whether the kernel
   needs **deadlock-free multi-PE fabric routing**, which the agent lands only
   intermittently within the cap. (Wide-Mult is compute-heavy but has simple comms →
   robust; Residual is a thin axpy/norm but is multi-PE → fragile.)
2. **Quality axis.** For the FRAGILE/routing kernels, the cycle count when they DO
   pass also varies enormously: Laplacian 16,664 here vs 3,365 in the original sweep
   (1.5× vs 7.6× win); Game-of-Life fail / 7,584 (earlier hinted) / 3,365 (a verified
   2.3× win). The ROBUST kernels are tight on both axes.

**Implication for the headline table:** the single-draw "7.6× Laplacian" was a
BEST-OF-DRAWS outlier, not the expected result. The honest claims are:
- **Dependable wins** (high pass-rate, consistent cycles): **Wide-Multiplication
  ~3/3 at 7–9×**; Single-Tile-Matvec 3/3 at parity; 7pt 3/3 at parity.
- **Intermittent wins** (low pass-rate, wide quality): Laplacian, Game-of-Life,
  Residual — real when they land (independently verified), but ~1/3 of draws, with
  the magnitude itself high-variance. Report as "best-of-N" with the pass-rate, not
  as a typical number.

## Anti-gaming note
The Game-of-Life rep2 = 3,365 looked suspicious (2.3× over ref; coincidentally equal
to Laplacian's number). Checked: correct reference baseline (7,838, GoL's not
Laplacian's), `np.testing.assert_equal(ref_states, all_states)` exact-equality
correctness, dead-timer floor cleared (3,365 ≫ 100), code_similarity 0.086.
INDEPENDENTLY RE-VERIFIED in a clean bundle: 3,365, SUCCESS. Real win, preserved at
`results/test_split_sweep_artifacts/game_of_life_3365_verified_pe_program.csl`.

## Method notes
- No seed flag — variance is from LLM sampling; N=3 independent runs per kernel.
- Failing reps consume the full 12-attempt budget (~8 min each), so the run is long
  but the per-rep pass/fail + cycles are the signal.
- Cholesky excluded (structural fail; handled by the co-design experiment).
- N=3 is a floor; pass-rate point estimates have wide CIs. The robust/fragile
  SEPARATION is the robust finding; exact rates (1/3 vs 3/3) need larger N to pin down.
