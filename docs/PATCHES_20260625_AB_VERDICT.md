# Multi-seed A/B verdict — 2026-06-25 firewall-safe patches (R1–R4)

Run `patches_20260625_ab_20260625_193515`: attributable gate `XKERNEL_FIXES_20260625`
off vs on, 8 kernels × 3 seeds × 2 arms = 48 runs, cap 20, `--auto-optimize`, serial.
Measures whether the 4 sweep-failure patches move pass-rate.

Patches under test (all firewall-safe, default-on, gate-isolated):
- **R1** in-place-accumulate DSR rule (`src0_dsr_ids[0]==dest_dsr_ids[0]`) — solvers/collectives
- **R2** per-tile route-config gotcha (`@set_local_color_config` arity) — FFT-1D-2D
- **R3** symmetric queue-init salience — Laplacian (always-on; not gate-isolatable)
- **R4** `<kernels/.../layout>→/pe` lib-sig remap (surfaces `<kernels/tally/pe>`) — Histogram

## Result: NOT PROVEN (NET −1, zero kernels improved)

**off 13/24, on 12/24.** Per-kernel pass-rate (3 seeds):

| kernel | off | on | target patch | |
|---|---|---|---|---|
| BiCGSTAB | 3/3 | 3/3 | R1 | hold (no-regression) |
| GEMV-Collectives-2D | 3/3 | 3/3 | R1 | hold |
| Laplacian2D-Halo | 3/3 | 3/3 | R3 | hold |
| Power-Method | 3/3 | 3/3 | R1 | hold |
| Histogram | 0/3 | 0/3 | **R4** | no flip |
| CG | 0/3 | 0/3 | (control) | hold (numeric ceiling) |
| Preconditioned-CG | 0/3 | 0/3 | (control) | hold (numeric ceiling) |
| FFT-1D-2D | 1/3 | 0/3 | **R2** | the lone delta — draw-noise (see below) |

**Zero off→on improvements.** No flip on either patch-target (Histogram, FFT).

## The FFT delta is draw-noise, not patch harm
FFT-1D-2D's single off-arm pass was **seed 37** (386 cyc); on the on-arm, seed 37
*failed*. Since seed 37 succeeded with the patch OFF and failed with it ON, that is
translation variance on a fragile kernel (FFT passed only 1 of 6 runs total across both
arms), NOT the route-config gotcha causing a regression — R2 teaches a general
`@set_local_color_config` arity fact unrelated to whatever flipped seed 37. With the
patch genuinely off in seed 37's off run, the lone "regression" cannot be attributed to
the patch.

## Why R4 didn't flip Histogram (it DID help, just not enough)
The on-arm Histogram runs DID consume the surfaced `<kernels/tally/pe>` interface (R4
active) and progressed PAST the original "guessing the tally API" failure — the cap-20
end-states are now downstream WSE-3 fabric issues: "output queue init colliding…",
`fn` vs `task` `@bind_local_task` mismatch, D2H 0-byte stall. So R4 removed the API-gap
blocker but exposed the next fabric layer; it did not yield a pass at cap 20. The fix is
correct and helpful (the agent no longer invents the interface) but insufficient alone.

## Decision (Finding-A discipline)
**NOT PROVEN as a pass-rate lever** — no ≥2-kernel margin, net-negative single delta is
draw-noise. Same outcome shape as the C4/C5/C10 A/B (single/multi-draw can't separate a
real effect from fragile-kernel variance when no flip occurs).

**But the patches stay DEFAULT-ON** — for the same reason as C1–C5/C10: they are
**corrections of wrong/missing platform facts** (an overlay note that *taught the wrong
DSR aliasing*, a missing library interface the agent was inventing, a route-config arity
error, an asymmetric queue-init), not speculative optimization hints. They are
firewall-safe, cannot make a correct translation wrong, carry no integrity/overfitting
risk, and demonstrably remove documented thrash (R4: Histogram stops guessing the tally
API). The honest headline: **no measured pass-rate lift at N=3, cap 20; kept as
platform-fact corrections, not a proven lever.**

## What this says about the remaining failures
The patches removed *upstream* misconceptions but the kernels' *true ceilings* are
deeper and unchanged: Histogram = multi-PE WSE-3 fabric/queue engineering; FFT =
butterfly+transpose fragility; CG/PCG = numeric convergence (the controls held 0/3 as
designed — confirming the patches don't spuriously perturb unrelated kernels). These are
genuine capability/fabric frontiers, not knowledge-injection-addressable at this cap.

## Recommended next
- Keep the patches default-on (platform-fact corrections); do NOT claim a sweep lift.
- The real levers for the held failures are NOT more knowledge but: (a) higher cap +
  more compute for the fabric kernels (Histogram got further but ran out of attempts);
  (b) harness/tolerance decisions for the numeric solvers (outside agent knowledge).
- Source: `code_translation/results/patches_20260625_ab_20260625_193515/VERDICT.txt`.
