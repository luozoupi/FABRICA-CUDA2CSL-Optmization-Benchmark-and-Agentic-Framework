# Immune Kernels — Piece 3f: deeper sweep + pre-flight-aware planner

## Headline

After threading pre-flight skip context into the planner (Piece 3e) and
budgeting 8 rounds per kernel (Piece 3f), the 4 immune kernels produced
**0 wins out of 32 total attempts** — but for entirely different reasons
than the prior infrastructure-bug attempts. The framework is now
empirically pinned against the **noise floor** of these kernels: every
candidate across 32 attempts landed within a ≤ 7-cycle window around
baseline.

| Attempt | Multi-file fired | Wins | Headline |
|---|:---:|:---:|---|
| Piece 3d v1 | 0/4 | 0/4 | Planner returned `len(focus_files)==1`; multi-file path dead code. |
| Piece 3d v2 | 3/4 | 0/4 | Multi-file fired; three downstream bugs blocked benchmarks. |
| Piece 3d v3 | 4/4 | 0/4 | Only 3 angles sampled per kernel (`comptime_value_tuning` → `iterative_phase_fusion` → OPEN). |
| **Piece 3f** | **4/4** | **0/4** | **6 distinct angles sampled per kernel; cycle span 0–7 across 32 attempts — noise floor reached.** |

## Per-kernel results

| Kernel | Baseline | Min cand | Max cand | Span | Rounds | Distinct angles | Contract rejects |
|---|---:|---:|---:|---:|---:|---:|---:|
| BiCGSTAB | 69,217 | 69,213 | 69,220 | 7 | 8 | 6 | 2 |
| Conjugate_Gradient | 14,959 | 14,958 | 14,960 | 2 | 8 | 6 | 1 |
| Preconditioned_CG | 17,197 | 17,197 | 17,200 | 3 | 8 | 6 | 0 |
| Power_Method | 47,402 | 47,402 | 47,402 | 0 | 8 | 6 | 0 |

Each accept threshold (baseline × 0.99) sits ~70–690 cycles below the
observed candidates. **No round on any kernel got close.** Power_Method
is the extreme case: 24 sub-runs (8 rounds × 3 num-runs) all returned
*exactly* 47,402 cycles — perfect determinism, zero movement on any edit.

## What Piece 3e + 3f unlocked

**Piece 3e — planner pre-flight awareness** (verified live):
- `preflight_skipped_angles` threaded through `_load_plan` →
  `get_or_make_plan` → `make_plan` → `_build_prompt`.
- Fingerprint includes the skip set, so plans regenerate when pre-flight
  changes.
- Deterministic `_drop_blas_when_fmac_bulk_skipped` guard demotes
  `blas.csl` from focus to read-only when `fmac_bulk` is skipped (fired
  on BiCGSTAB, CG, PCG; correctly DID NOT fire on Power_Method since
  its baseline doesn't use bulk @fmacs).
- Planner's `suggested_first_angle` flipped from `fmac_bulk` to
  `dsd_offset_chaining` on the 3 kernels where Piece 3e fired.

**Piece 3f — deeper sweep** (verified live):
- `--n-rounds 8 --open-after 5` sampled 5 named angles before falling to
  OPEN (vs only 2 in attempt 3). All 4 kernels reached 6 distinct angle
  attempts (5 named + 1–3 OPEN rounds).
- Auto-mode rotation worked: each kernel cycled through
  `comptime_value_tuning` → `iterative_phase_fusion` →
  `dsd_offset_chaining` → `async_detach_overlap` →
  `task_chaining_unblock_activate` → OPEN.
- Roughly 90 sub-benchmarks (32 angle attempts × 3 num-runs minus 3
  contract-failed) all ran cleanly to completion.

**Bonus bug fix surfaced during monitoring** — `select_angle` was
ignoring `plan.suggested_first_angle`. Round 1 of every kernel ran
`comptime_value_tuning` (catalog order) instead of the planner's hint
(`dsd_offset_chaining` on the demote-eligible kernels). Patched: round 1
now honors the planner's first-angle suggestion when it's in the active
angles list; rounds 2+ revert to the fewest-attempts scheduler. **4 new
tests; 181 total tests pass.** The fix lands AFTER these runs and will
take effect on the next experiment.

## What's still preventing wins

The infrastructure is healthy; the wins simply aren't there to find on
these specific kernels with this LLM + catalog. Three distinct failure
modes appeared:

**(1) Noise-floor pinning (CG, PCG, BiCGSTAB).** Every angle the LLM
tried produced a cycle count within ±3 cycles of baseline. Run-to-run
variance on the simulator itself is ±2 cycles (e.g. CG baseline
`runs=[14958, 14958, 14958]`, OPEN attempt
`runs=[14959, 14958, 14958]`). The candidates are statistically
indistinguishable from baseline. With ε=0.01 (1% threshold), a real win
would require cutting ~70–690 cycles — nothing in the candidate
distribution comes close.

**(2) Determinism stuck (Power_Method).** 24/24 sub-runs returned
*exactly* 47,402. This suggests every edit the LLM made was either:
- a semantic no-op the compiler folded identically, or
- a change to code that doesn't appear in the cycles_send-measured
  region (e.g. one-time host setup vs the on-WSE compute interval).
  The `f_tic`/`f_toc` measurement bounds need verification.

**(3) Contract violations on `f_reference_timestamps` (BiCGSTAB ×2, CG
×1).** The LLM tripped the frozen-symbol guard on this function across
multiple angles. The frozen-functions list in `spec.yaml` includes
`f_reference_timestamps`, but the multi-file prompt doesn't surface that
list in a structured "do not touch" callout — the LLM only discovers it
post-rewrite via reject. Not a noise issue, but adjacent prompt-budget
waste worth fixing.

## Recommended next move

1. **Single-kernel deep dive on Power_Method.** The exact-baseline result
   across 24 sub-runs is the strongest evidence of a measurement issue
   rather than an optimization failure. Inspect `kernel_power.csl`'s
   `f_tic`/`f_toc` placement: does the measured interval include the
   inner compute, or only the per-iteration dispatcher? If the latter,
   no LLM edit to the dispatcher or BLAS routines will move the cycle
   count by construction. This is a kernel-instrumentation question, not
   a framework question.

2. **Move on to other immune-style kernels.** With 4 immune kernels
   producing the same "infrastructure healthy, no LLM win" outcome, we
   have evidence that *some* thin-dispatcher kernels are genuinely
   near-optimal. Pick a different bench to test the multi-file pipeline
   against — e.g. one of the still-untested GEMV variants showing
   `0 accepts logged in trees`, where the structure might offer real
   wins blas.csl-style helpers can claim. Use the Piece 3e+3f+select_angle
   improvements as the new default.

3. **Surface frozen functions in the multi-file prompt** — small
   prompt-template tweak. Add `frozen_functions` and `frozen_params`
   from `spec.yaml` as a literal "DO NOT EDIT" callout. Currently the
   prompt has a "FROZEN" section but doesn't list the specific
   functions, so the LLM only discovers them by violating them.

## Appendix: source data

- Logs (4 files):
  - `/tmp/piece3f_BiCGSTAB_20260606T023122Z.log`
  - `/tmp/piece3f_Conjugate_Gradient_20260606T023125Z.log`
  - `/tmp/piece3f_Preconditioned_CG_20260606T023120Z.log`
  - `/tmp/piece3f_Power_Method_20260606T023119Z.log`
- Plans:
  `~/xkernel/knowledge/explored/optimization/plans/{bicgstab,conjugate_gradient,preconditioned_cg,power_method}.json`
- Experience rows: 32 in
  `~/xkernel/knowledge/explored/optimization/experiences.jsonl`
  (`ts >= 20260606T023000Z`)
- 181 total unit tests pass.
