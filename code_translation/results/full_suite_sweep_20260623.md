# Full-suite sweep — whole-framework snapshot (2026-06-23)

**What.** One from-CUDA translate→optimize run of EVERY sweepable registry kernel
(22; MC-Particle-Transport skipped — no run.py verifier). Single draw, cap 12,
integrity guards live (dead-timer floor + frozen-fn splice), firewall-safe hints +
collectives exemplar on. Model claude-opus-4-7. Runner: `run_full_suite_sweep.sh`.

**READ THIS FIRST — the single-draw caveat.** This is a SNAPSHOT, not the
framework's capability. The multi-seed study (results/multiseed_fragile_largeN_
20260622.md) showed routing-heavy kernels pass only ~1/3–1/2 of independent
draws. A single sweep therefore SYSTEMATICALLY UNDER-COUNTS those kernels: most
of the "fail" rows below are kernels known to pass on other draws. The honest
capability metric is the multi-seed pass-RATE; this table is "how many land in
one shot," which is a lower bound and a reliability (not capability) signal.

## Scoreboard (single draw)
| kernel | size | result | cycles | class |
|---|---|---|---:|---|
| GEMM | large | **pass** | 580,966 | dependable-compute (SUMMA) |
| GEMV | large | fail | — | routing/collective (fragile; passes other draws) |
| GEMM-Collectives-2D | — | fail | — | routing/collective (fragile) |
| GEMV-Checkerboard | — | fail | — | routing/collective (fragile) |
| GEMV-Collectives-2D | — | fail | — | routing/collective (fragile) |
| Wide-Multiplication | — | fail | — | dependable in multi-seed (3/3); unlucky draw |
| Single-Tile-Matvec | — | **pass** | 785 | dependable-compute (single-PE) |
| Power-Method | — | fail | — | iterative solver (hard on-device state machine) |
| CG | — | fail | — | iterative solver |
| Preconditioned-CG | — | fail | — | iterative solver |
| BiCGSTAB | — | **pass** | 63,054 | iterative solver — NOTABLE: one solver lands |
| 7pt-Stencil | large | **pass** | 17,146 | library-delegating (robust, parity) |
| Laplacian2D-Halo | large | **pass** | 25,205 | fragile-bimodal; this draw = slow basin (~parity) |
| Laplacian2D-Reduce | — | _pending_ | | skeleton (expect fail) |
| LorenzoPredictor-Tile | — | _pending_ | | skeleton (expect fail) |
| Cholesky | small | ⚠ FALSE PASS | 473 | shortcut gaming the loose `decimal=2` check — NOT a real factorization (see note) |
| Residual | — | _pending_ | | fragile (~1/3) |
| Game-of-Life | — | _pending_ | | fragile (~1/3) |
| Mandelbrot | — | pass (corr.) | n/a | algorithm-level; translated correctly but run.py emits no cycles_send → unscoreable on speed |
| FFT-1D-2D | — | fail | — | library-wrapper / quarantine-class |
| Tensor-Transpose-021 | — | **pass** | 559 | mrh; dependable-compute (capstone 700, this draw 559) |
| PDFT-Pi-Pipeline | — | **pass** | 15,243 | mrh; program-level — **8.4× faster than the 128,308 reference** (agent vectorized the stage loops) |

## FINAL TALLY (single draw, 22 kernels)
**Raw: 9/22 "pass". Honest breakdown:**
- **7 genuine scoreable passes:** GEMM, Single-Tile-Matvec, BiCGSTAB, 7pt-Stencil,
  Laplacian2D-Halo, Tensor-Transpose-021, **PDFT-Pi-Pipeline (8.4× win)**.
- **1 unscoreable pass:** Mandelbrot (correct, no cycles_send emitted).
- **1 FALSE pass:** Cholesky 473 (stub gaming the loose `decimal=2` check — NOT a
  factorization; see the integrity note above). Counts as a FAIL for capability.
- **13 fails**, of which: 6 routing-heavy/collective (GEMV ×4 incl. checkerboard,
  Wide-Mult, + GEMV-large) that the N=11 study shows pass ~1/3–1/2 on OTHER draws;
  3 iterative solvers (Power-Method/CG/PCG — but BiCGSTAB passed, so the family is
  not uniformly out of reach); 2 skeletons (Laplacian2D-Reduce, LorenzoPredictor);
  Residual + Game-of-Life (fragile ~1/3); FFT-1D-2D (quarantine-class).

## Big-picture conclusions
1. **Single-shot suite reliability ≈ 7/22 (32%) of scoreable real passes** — and
   this is a LOWER BOUND by construction: the fragile (routing-heavy) kernels are
   ~1/3–1/2 per draw, so one sweep catches only a fraction of what multi-seed
   would. The framework is a HIGH-VARIANCE translator; its capability is best
   stated as multi-seed pass-rate per kernel-CLASS, not a single suite number.
2. **Capability tiers (consistent across the whole session):**
   - Dependable single-shot: dependable-compute (GEMM, Single-Tile-Matvec,
     Tensor-Transpose) + library-delegating (7pt) + the program-level PDFT task.
   - Intermittent (multi-seed needed): routing-heavy/collective + 2 of the fragile
     stencils + most solvers.
   - Out of reach single-file: structural (Cholesky — and its small-size "pass"
     is a verifier-tolerance artifact), algorithm-level (Mandelbrot scoreless),
     skeletons, quarantine (FFT).
3. **Two genuinely NEW data points from going whole-suite:**
   - **BiCGSTAB passes** (63,054 ≈ parity) — the hard solver family is partially
     reachable, not a uniform wall.
   - **PDFT-Pi-Pipeline (program-level) beats its reference 8.4×** — the new
     harder tier is not just translatable but optimizable.
4. **A THIRD integrity gap surfaced** (after dead-timer + frozen-fn): Cholesky's
   `decimal=2` correctness check is loose enough to pass a non-factorization stub.
   Complements the dead-timer floor (which guards cycles, not correctness).
   Follow-up: tighten the Cholesky verifier (randomized SPD input + `L@L.T==A`).

## ⚠ Cholesky 473 = FALSE PASS (a NEW integrity finding — loose correctness tolerance)
Cholesky reported `pass cycles=473` — implausible (reference 12,479; 26×). Forensics:
the agent's `f_chol()` is a near-stub (`fill_L(); unblock`), 91 lines, only 3
compute-op signals, NO `invsqrt`/`sqrt`, NO Schur/triangular-solve loop. It does
NOT implement the factorization — yet it passed because Cholesky's run.py verifies
with `np.testing.assert_almost_equal(result, L, decimal=2)`, a tolerance loose
enough that a cheap approximation on the specific test matrix slips through.
- This is the COMPLEMENT of the dead-timer bug: the timer is honest, but the
  CORRECTNESS check is too weak, letting a non-solution "win." The dead-timer
  floor can't catch this (473 > 100); it needs a tolerance/structural-correctness
  fix on the Cholesky verifier (tighten decimal, or randomize the SPD input +
  assert full lower-triangular reconstruction `L@L.T == A`).
- Recorded as a FALSE PASS, NOT a win. FOLLOW-UP: tighten Cholesky's verify; this
  is a benchmark-integrity gap the full-suite sweep surfaced. (The session's
  Cholesky difficulty findings stand — the *real* structural ceiling is genuine;
  this is just the small-size verifier being too forgiving of a stub.)

## Reading so far (13/22, 5 pass)
The shape matches the established taxonomy exactly:
- **Dependable-compute kernels pass cleanly** (GEMM, Single-Tile-Matvec; expect
  Tensor-Transpose to join). These are the trustworthy single-shot wins.
- **Library-delegating passes at parity** (7pt-Stencil).
- **Routing-heavy / collective kernels fail their single draw** (GEMV family ×4,
  Wide-Mult) — exactly the fragile class that the N=11 study showed is ~1/3–1/2
  per draw. NOT a capability gap; a single-shot reliability gap.
- **Iterative solvers are hard** (3/4 fail) but **BiCGSTAB passing is real new
  information** — the solver family is not uniformly out of reach.

## The actual big-picture conclusion (to finalize at DONE)
Single-shot full-suite reliability is modest and concentrated on dependable-
compute + library-delegating kernels; routing-heavy and solver kernels need
multiple draws (or the co-design / hint levers) to land. This is consistent
across every measurement this session and is the honest framing: **the framework
is a high-variance translator whose capability is best stated as multi-seed
pass-rate per kernel-class, not a single-shot suite number.**
