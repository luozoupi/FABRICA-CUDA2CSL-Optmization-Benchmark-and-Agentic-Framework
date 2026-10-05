# Larger-N robustness on the FRAGILE test-split kernels (2026-06-22)

**Why.** The N=3 multi-seed run gave a clean robust/fragile separation but wide
CIs on the exact pass-rate of the three FRAGILE kernels (Laplacian2D-Halo,
Residual, Game-of-Life). Ran N=8 more per kernel (total N=11 with the original 3)
to pin down the pass-rate and characterize the cycle distribution. cap 12, hints +
splice on, independent draws. Runner: `run_multiseed_robustness.sh --reps 8
--kernels "..."`.

## Pass-rates (N=11 each: 3 original + 8 new)
| kernel | passes / draws | pass-rate | cycles when passing | ref | win when it lands |
|---|---|---|---:|---:|---|
| Laplacian2D-Halo | 5/11 | **~45%** | {2,730; 16,166; 16,412; 16,664; 17,278} | 25,627 | **BIMODAL** (1.5× usual / 9.4× rare) |
| Residual | 4/11 | **~36%** | {528; 533; 536; 569} | 674 | tight ~1.2× (unimodal) |
| Game-of-Life | 3/11 | **~27%** | {3,365; 3,777; 3,942} | 7,838 | tight ~2× (all fast basin) |

(Original N=3: Laplacian fail/16664/fail; Residual 528/fail/fail; GoL fail/3365/fail.
 New N=8 Laplacian: 17278/F/16166/F/F/16412/F/2730; Residual 536/533/F/F/F/F/F/569;
 GoL F/F/3777/3942/F/F/F/F.)

## Headline finding: the fragile kernels pass ~35-45%, and Laplacian is BIMODAL
1. **Pass-rate ~1/3-to-1/2, not the lucky single draw.** Larger N confirms the
   FRAGILE tier sits around 36-45% pass — the original "~1/3" was right to within
   the noise. These kernels need deadlock-free multi-PE routing the agent lands
   on roughly 4-in-9 independent draws (cap 12).

2. **Laplacian's win magnitude is BIMODAL — a genuinely new finding.** Of its 5
   passes, FOUR land in a "slow basin" (~16-17k cycles, ~1.5× vs the 25,627 ref)
   and ONE lands in a "fast basin" (2,730 cycles, **9.4×**). The original sweep's
   3,365 (7.6×) was ALSO a fast-basin draw. So the agent finds two qualitatively
   different correct halo schedules: a common naive-but-correct one (~1.5×) and a
   rare well-overlapped one (~8-9×). Both bit-exact, both independently verified in
   clean bundles. **The 7.6× headline was the rare good basin, not the typical
   result** — but the good basin is real and reproducible (2 of ~6 passes hit it).
   - Verified: rep8 2,730 re-run in a clean bundle → 2,730, max abs diff 0.000e+00.
     Artifact: results/test_split_sweep_artifacts/laplacian_2730_fast_basin_verified_pe.csl.

3. **Residual is unimodal-tight.** All 4 passes within 528-569 (~1.2×). When the
   thin axpy/norm composition's multi-PE comms work, the cycle count is stable;
   the variance is purely pass/fail, not magnitude.

4. **Game-of-Life: lowest pass-rate (~27%) but every pass is a ~2× win.** All 3
   passes cluster 3,365-3,942 (~2× vs the 7,838 ref) — unimodal in a fast band.
   GoL is the hardest to land (8-neighbor deadlock-free routing) but when the agent
   gets it, it consistently beats the reference ~2×. (The 3,365 pass was
   independently re-verified in a clean bundle with exact-equality correctness.)

## The variance taxonomy, refined (3 distinct shapes)
- **ROBUST** (Wide-Mult, STM, 7pt; from the N=3 run): ~3/3 pass, tight cycles.
- **FRAGILE-UNIMODAL** (Residual ~36% @ ~1.2×; Game-of-Life ~27% @ ~2×):
  intermittent pass, but consistent win magnitude when they land.
- **FRAGILE-BIMODAL** (Laplacian ~45%): intermittent pass AND two solution basins
  of very different quality (~1.5× common, ~9.4× rare). Single-draw cycle numbers
  for this kernel are especially unreliable as a "typical".

## What this means for the paper's claims
- **Honest restatement of the test-split wins:**
  - Wide-Multiplication: DEPENDABLE (3/3, 7-9× every draw) — the headline win.
  - Laplacian2D-Halo: ~45% pass; *usually* ~1.5×, *occasionally* (~1/3 of passes)
    a verified ~8-9×. Report as "passes ~45%, bimodal: 1.5× typical / up to 9.4×".
  - Residual: ~36% pass, consistent ~1.2× when it lands.
  - Game-of-Life: _pending_ (see table).
- **The bimodality is a finding, not noise:** it shows the agent's search has
  distinct solution basins of very different quality for routing-heavy kernels —
  a target for future work (bias the search toward the fast basin), and a caution
  that any single-draw cycle number for these kernels is unreliable as a "typical".

## Method notes
- N=11 total per kernel; failing draws consume the full 12-attempt budget.
- Cholesky excluded (structural; co-design experiments cover it separately).
- Pass-rate point estimates now ±~15% (binomial, N=11); the robust/fragile
  SEPARATION and the bimodality are the solid results.
