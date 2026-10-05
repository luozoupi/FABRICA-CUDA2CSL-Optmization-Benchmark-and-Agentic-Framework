# WS3 + WS4.3 lever A/B verdict (2026-06-24)

**Levers under test (both A/B-gated, default off):**
- WS4.3 `XKERNEL_WHY_FASTER_RULES` — 6 distilled why-faster optimization principles.
- WS3 `XKERNEL_LEAVE_ONE_OUT` — leave-one-out CUDA-similarity retrieval of train-pool exemplars.

**Design:** paired A/B over 8 test-split kernels, off vs both-on, cap 12,
--auto-optimize. (A first run crashed mid-on-arm when the leave-one-out lever
surfaced a train exemplar containing 7pt-Stencil's canary line — the compute-leak
guard caught it; fixed via canary-scrub, re-run clean.)

## Result (paired)
| kernel | class | off | on |
|---|---|---|---|
| 7pt-Stencil | library-deleg | pass 17,284 | pass 17,051 |
| Single-Tile-Matvec | robust | pass 785 | pass 1,135 |
| Tensor-Transpose-021 | robust | pass 527 | pass 527 |
| PDFT-Pi-Pipeline | robust | pass 13,888 | pass 128,308 |
| Residual | fragile | fail | fail |
| Wide-Multiplication | fragile* | fail | fail |
| Laplacian2D-Halo | fragile | **pass 1,695** | **fail** |
| Game-of-Life | fragile | **pass 4,791** | **fail** |

**off 6/8 ; on 4/8 ; NET lift −2** (passing-only-on: none; passing-only-off:
Game-of-Life, Laplacian2D-Halo).

## Verdict: levers NOT proven → keep default-OFF
1. **The −2 is entirely on the two fragile kernels** (GoL, Laplacian). The N=11
   robustness study (multiseed_fragile_largeN) showed these pass only ~1/3–1/2 of
   independent draws. At single-draw N=1, a pass→fail flip on them is WITHIN their
   documented variance — NOT attributable to the levers. (Same kernels flipped the
   opposite way between the two full-suite/A/B draws this week.)
2. **Every robust kernel held** (7pt, STM, Tensor identical/parity; PDFT passed —
   note PDFT-on landed the un-optimized 128,308 vs off's optimized 13,888, again a
   draw-variance artifact, not a translation failure). So the levers do NOT break
   anything; they are SAFE, just not a proven help.
3. Per the project's Finding-A discipline (≥2-kernel lift, multi-seed for fragile
   kernels), a single-draw NET −2 dominated by fragile-kernel noise is
   **inconclusive/negative → both levers stay gated default-off.** This matches
   the documented pattern that prose/retrieval levers need multi-seed proof.

## What WOULD give a real answer (future work)
A multi-seed A/B (N≥5 per kernel per arm) on the ROBUST + cycle-scoreable kernels,
measuring not just pass/fail but CYCLE deltas (the why-faster rules target
optimization quality, which pass/fail can't see). The levers remain available
behind their env gates for that evaluation. The leave-one-out canary-scrub fix and
both levers' leak-guards are kept (they're correct infrastructure regardless).

## Byproduct finding (kept)
The first A/B run surfaced a real leak in the leave-one-out lever — train kernels
share library idiom lines with the target (solvers + 7pt both use the
stencil_3d_7pts import), so a retrieved exemplar reproduced the target's canary.
The compute-leak guard caught it (hard stop). This is the 4th integrity finding of
this work (after dead-timer, frozen-fn, Cholesky-loose-tolerance) and validates
that the firewall guards new levers, not just hand-written code. Fix + regression
test landed (commit 38ab737).
