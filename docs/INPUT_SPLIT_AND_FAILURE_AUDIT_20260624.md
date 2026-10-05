# Input-level train/test split + per-kernel failure audit (2026-06-24)

This answers two linked questions:
1. *Can each benchmark have a train/test INPUT split so a "fix" isn't "given THIS
   bench, here's THIS hardcoded answer"?* — **Yes.** §1–§3.
2. *Why did the other kernels fail, and how do we avoid the gaming case there too?*
   — §4 classifies every failure as **gaming-risk** / **honest-capability** /
   **fixable-knowledge-gap**, and says what we did about each.

---

## 1. The problem the input-split solves

The W1 agent is shown `run.py` (it's the host-side launch contract — cuda2csl.py:650).
`run.py` contains BOTH the input construction AND the reference-answer computation.
If the input is **deterministic** (a fixed formula, `np.arange`, a single hardcoded
seed), the agent can reproduce the answer **without computing it**. That is exactly
how the Cholesky stub false-passed: it hardcoded `L[i,j]=i(i+1)/2+j+1` and never read
the input matrix.

Patching one verifier at a time (commit 7feed5c) works but is the "bespoke fix per
bench" pattern we want to avoid. The **input split** is the general fix: it makes
answer-hardcoding fail *structurally*, for every kernel, via one mechanism.

## 2. Mechanism (train seed shown, held-out seeds hidden)

Each kernel's `spec.yaml` declares an `eval:` block:
```yaml
eval:
  train_seed: 7              # baked into run.py — the agent may see this
  heldout_seeds: [101, 202, 303]   # harness-only; correctness must pass on ALL
  seed_env: "XKERNEL_EVAL_SEED"
```
- `run.py` builds its input from `os.environ[seed_env]` (default = train seed) and
  **recomputes the reference answer from the drawn input every run** (true for all
  current kernels — `np.dot`, `np.fft.*`, `b−A@x`, the Cholesky `LLᵀ=A` invariant,
  CA-rule loops). So a new seed changes BOTH the input and the golden answer.
- After a train-seed pass, the harness (`benchmark_csl.evaluate_heldout`,
  gate `XKERNEL_HELDOUT_EVAL`, default OFF) **re-runs only the `cs_python` step**
  per held-out seed (no recompile) and requires SUCCESS on all of them. A hardcoded
  answer passes train but fails held-out → flipped to `fail`.
- **Firewall:** the held-out seed *values* are harness-only. `spec.yaml` is never
  injected into a prompt; the agent sees only the *mechanism* (`XKERNEL_EVAL_SEED`),
  never the values. Asserted by `HeldoutSeedLeakTest` in test_no_compute_leak.py.

Container gotcha (important for anyone extending this): `cs_python` runs
`singularity exec -C` (contain), which **strips host env vars**. The gate sets the
`SINGULARITYENV_`/`APPTAINERENV_`-prefixed forms so the seed actually reaches run.py
inside the SIF.

## 3. Pilot result (WSE-3, real simulator)

Piloted on 3 representative kernels (the plan's "design + pilot + gated hook" scope):

| kernel | input before | input after | train pass | held-out {101,202,303} | role |
|---|---|---|---|---|---|
| **Cholesky** | seeded (fixed) | seeded by env | ✅ | ✅✅✅ (recon err varies per seed 1.9/1.8/1.5/1.4e-7) | the false-pass kernel |
| **Single-Tile-Matvec** | unseeded rand | seeded by env | ✅ | ✅✅✅ | no-false-NEGATIVE control |
| **Residual** | `np.arange` (vuln.) | seeded by env | ✅ | ✅✅✅ | class-A → generalizes |

- The preserved **Cholesky false-pass stub is REJECTED on every held-out seed**
  (backward error ~3.2e+04). `evaluate_heldout` on the live ref bundle → `passed=True`;
  on the stub bundle → `passed=False, failing_seed=101`.
- **Independence proof:** under the *old weak* `decimal=2` gate, a hardcoded answer
  still passes the train seed but fails every held-out seed. So the input split is a
  defense **independent of verifier tolerance** — the two compose.

Reconstruction error *varying per seed* (vs byte-identical) is the tell that the
input truly changes; it also caught the container env-strip bug during validation.

## 4. Per-kernel failure audit — gaming-risk vs honest-capability vs fixable

Root causes are from the 29-agent failure analysis
(`code_translation/results/failure_analysis_improvements_20260623.md`). The key
distinction the user asked for:

### 4a. Gaming-risk (could false-pass like Cholesky) → covered by the input split
A kernel is gaming-risk if its verifier could be satisfied without real compute —
deterministic input + loose/answer-key gate. The 5th integrity pass (7feed5c) tightened
the gates; the input split (this work) removes the *deterministic input* that made
hardcoding possible in the first place.
- **Closed (verifier hardened + pilot input-split):** Cholesky.
- **Verifier hardened (7feed5c), input-split candidates for roll-out:** SpMV /
  SpMV-Hypersparse (were ungated), FFT-1D-2D, 3D-FFT (were loose-tol), Jacobi-2D-5pt
  (relaxable CLI tol). These already draw seeded-random or randomizable inputs; adding
  an `eval:` block is the follow-up roll-out (out of scope for this pilot round).
- **Already robust (exact-equality or tight invariant, low gaming-risk):**
  Game-of-Life, Histogram, Mandelbrot, Wide-Mult; GEMM/GEMV/7pt/PDFT/STM/Residual/
  CG/PCG/BiCGSTAB. Most already use a seeded RNG; the input split formalizes it.

**Conclusion:** no kernel in the suite now has a deterministic-input + loose-gate
combination that survives BOTH the verifier hardening AND (where rolled out) the input
split. The gaming door is closed structurally, not per-bench.

### 4b. Honest-capability fails — the benchmark's VALUE, not bugs to paper over
These fail because the agent genuinely cannot (yet) do the task. **We deliberately do
NOT "fix" them with per-kernel tactics** — injecting the answer for a specific bench is
exactly the overfitting that would make the benchmark meaningless. They are reported as
honest failures.
- **Numeric / iterative-solver semantics (C7):** Power-Method (1/√10 scaling),
  CG / PCG (per-iteration convergence + preconditioner). The agent must re-derive
  per-iteration numerics from CUDA; this is a real capability frontier. (BiCGSTAB
  passing shows the family is not a uniform wall.)
- **Collective-participation decomposition under a hidden reference (C8):**
  GEMM-Collectives-2D, GEMV-Collectives-2D, GEMV-Checkerboard. The decomposition
  (SUMMA serialized chain / 5-stage scatter-gather) lives in the hidden compute the
  firewall withholds; Cholesky's co-design study showed this is partly a
  *benchmark-firewall design limit* for co-designed compute+routing, not pure model
  weakness. Tracked separately (co-design mode), not patched per-bench.
- **Skeletons (C9):** Laplacian2D-Reduce, LorenzoPredictor-Tile (VERIFY=False /
  incomplete reference). Not scoreable until the reference is real; not a translation
  failure.

### 4c. Fixable-knowledge-gap → general, firewall-safe (implemented this round)
These fail on *general SDK knowledge* the agent was denied, not on the specific
benchmark's answer. Fixing them is firewall-safe (generic platform facts) and
A/B-gated. C1/C2/C3 shipped earlier (e857d38); C4/C5/C10 this round (commit 6e7a75e):
- **C1** stale-layout export-contract (5 kernels) — harness resolves layout from the
  active build script. *Done.*
- **C2** get_x_coord/get_y_coord at module-scope comptime (6) — prompt + KB teach the
  runtime-only idiom. *Done.*
- **C3** WSE-3 queue-init / async-fabric idioms (5) — KB routing + layout-folded query.
  *Done.*
- **C4** collectives_2d introspection field names (4) — KB section + fake→real map.
  *This round.*
- **C5** benchmark-libs arch-correct param arities (4) — arch-specific pe.csl + overlay
  note. *This round.*
- **C10** reserved resource-ID ranges (2) — KB safe-allocation table + cluster. *This
  round.*

The line between 4b and 4c is the important one: **4c gives the agent the platform
manual; 4b would give it the answer.** We do the former, never the latter.

## 5. Status (rollout complete)
- Input split: **mechanism built + validated + ROLLED OUT + default-on integrity gate.**
  8 scoreable kernels carry an `eval:` block and are WSE-3-validated to pass train +
  every held-out seed (Cholesky, Single-Tile-Matvec, Residual, GEMM, Wide-Mult,
  Tensor-Transpose-021, PDFT-Pi-Pipeline, Laplacian2D-Halo). The held-out gate is now
  the DEFAULT scoring path (acts only on eval-enabled kernels; W2 inner loop skips it,
  final winner is confirmed with it on). Excluded with reasons: GEMV (`--seed`
  override footgun — harness now refuses rather than false-pass), Game-of-Life (glider
  default, data-independent), Histogram/7pt/solvers/collectives (no build / library-
  delegating / honest-capability fails).
- C4/C5/C10: implemented + attributably gated (`XKERNEL_FIXES_C4_C5_C10`) + tested;
  pass-rate A/B in §6.
- See `docs/SPLIT_AND_LEAKAGE.md` §6 (input-level split policy) and
  `docs/PAPER_METHODOLOGY.md` (input split as the principled generalization of the
  5th integrity pass).

## 6. C4/C5/C10 A/B verdict
Attributable A/B (`XKERNEL_FIXES_C4_C5_C10` off vs on; everything else held constant)
over the kernels these fixes target — C4: GEMV/GEMM-Collectives-2D, GEMV-Checkerboard;
C5: CG/PCG/Power-Method/BiCGSTAB; C10: Game-of-Life. cap 12, `--auto-optimize`, serial.
Most targets are honest-capability fails (collective-decomposition / solver-numerics),
so the fixes are knowledge that *could* convert a fail→pass, not a guaranteed lift.

**VERDICT (sweep `c4c5c10_ab_20260624_073019`, N=1, cap 12): NOT PROVEN.**

| kernel | off | on | |
|---|---|---|---|
| GEMV-Collectives-2D | pass 3988 | pass 4345 | hold |
| GEMM-Collectives-2D | pass 50336 | pass 48795 | hold |
| GEMV-Checkerboard | **fail** | **fail** | no flip |
| CG | **fail** | **fail** | no flip |
| Preconditioned-CG | **fail** | **fail** | no flip |
| Power-Method | pass 43289 | pass 31438 | hold |
| BiCGSTAB | pass 58495 | pass 32285 | hold |
| Game-of-Life | pass 3147 | **fail** | regressed (draw-noise) |

**off 5/8, on 4/8 → NET −1, ZERO fail→pass flips.** Every kernel held its pass/fail
status across arms except Game-of-Life, which flipped pass→fail on-arm.

The single delta is **fragile-kernel translation draw-noise, not a C10 regression**,
confirmed by reading both runs: GoL-OFF got a passing W1 translation on attempt 1 and
spent all 12 steps in the W2 optimizer (6844→3147); GoL-ON never landed a passing W1
translation — it thrashed in the repair loop on bucket-B FABRIC-ROUTING stalls ("D2H 0
bytes", "same-color send/recv collision", deadlock). That is GoL's documented
deadlock-free-exchange ceiling, which C10 (reserved *id-range* knowledge) does not
address. The arms differed only in which W1 attempt happened to land — exactly the N=1
confound Finding-A warns about. The three C4/C5-targeted fails (GEMV-Checkerboard, CG,
PCG) held as fails on BOTH arms: no lift.

**Decision (Finding-A):** no ≥2-kernel margin and a net-negative single draw → the
C4/C5/C10 lift is **NOT proven**. As with the WS3/WS4 levers, single-draw A/B cannot
separate a real effect from fragile-kernel variance; a proper test needs a multi-seed
cycle-delta eval, not pass/fail at N=1.

**But default-on is still the right call here — for a different reason than "proven
lift."** Unlike the WS3/WS4 levers (which were kept default-OFF), C1–C5/C10 are
*corrections of wrong/missing platform facts* (illegal color ceilings, hallucinated
field names, untyped library arities), not speculative optimization hints. They are
firewall-safe general SDK knowledge with no benchmark answers, so they carry no
integrity or overfitting risk, and they cannot make a *correct* translation wrong.
They remain DEFAULT-ON (the attributable gate `XKERNEL_FIXES_C4_C5_C10` exists only to
re-run this A/B), and the honest headline records: **no measured pass-rate lift at N=1;
kept on as platform-fact corrections, not as a proven lever.** A multi-seed cycle-delta
re-test is the follow-up if a stronger claim is wanted.
