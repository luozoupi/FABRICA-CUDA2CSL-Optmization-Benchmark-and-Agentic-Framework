# Verifier-hardening integrity sweep (2026-06-24)

5th integrity pass. Closes **correctness-gaming** doors in the benchmark's pass
gates — the complement to the timing (dead-timer floor) and contract (frozen-fn
splice) guards already in place. Triggered by a false pass in the full-suite sweep
(a non-factorizing Cholesky stub scored "pass, cycles=473").

## Root cause (the false pass)
`kernels/Cholesky/CSL/run.py` verified `assert_almost_equal(result, L, decimal=2)`
against a **deterministic** answer key (`L[i,j]=i(i+1)/2+j+1`). The stub hardcoded
exactly that formula in CSL and **never read the input matrix** — so it reproduced
the answer key without factoring anything, and the loose `decimal=2` compare passed.
Two independent weaknesses: (a) a deterministic, reverse-engineerable answer key,
(b) a loose tolerance. An audit of all ~29 `kernels/*/CSL/run.py` verifiers showed
the pattern was not Cholesky-only.

## Fixes (each validated against the live reference)

| kernel | weakness | fix | validation |
|---|---|---|---|
| **Cholesky** | deterministic answer key + `decimal=2` | randomized seeded SPD input + invariant: result lower-triangular AND `‖LLᵀ−A‖/‖A‖ < 1e-3` + tight `assert_allclose(L, rtol=1e-4)` | **WSE-3**: ref passes (1.86e-07); **stub rejected** (3.20e+04), still 473 cyc |
| **SpMV** | `verify_result()` only printed PASS/FAIL, never raised → ungated | `assert is_correct` then print SUCCESS | syntax+logic (WSE-2-only) |
| **SpMV-Hypersparse** | same ungated print | `assert is_correct` then print SUCCESS | syntax+logic (WSE-2-only) |
| **FFT-1D-2D** | `rtol=0.25` (25% err), `atol=0` | measured real err (3e-8…5e-4) → `rtol=1e-2` + `atol=1e-3·scale` | ref passes with orders of margin |
| **3D-FFT** | `rtol=0.5` fp16 / `0.01`, `atol=0` | `rtol=5e-2`(fp16)/`1e-2` + `atol=1e-3·scale` | by inspection (WSE-2-only) |
| **Jacobi-2D-5pt** | tolerance a relaxable CLI arg | clamp `min(args.tolerance, 1e-5)` | **WSE-3**: ref passes (err 0.0, clamped) |

Strong verifiers left untouched (exact-equality or tight-1e-5 / invariant already):
Game-of-Life, Histogram, Mandelbrot, Wide-Mult, GEMM, GEMV, 7pt, PDFT,
Single-Tile-Matvec, Residual, CG, PCG, BiCGSTAB.

## Backstop (static, harness-level)
`check_timing_integrity.check_success_gated(text)`: flags any `run.py` that prints a
`SUCCESS` marker (which the harness scrapes as the pass signal) with **no enforcement
primitive** anywhere on its path — `assert`, `raise`, `np.testing.assert_*`, or a
nonzero `exit`/`SystemExit`. This is exactly the SpMV ungated-verifier shape; a
`raise SystemExit(0)` is correctly *not* counted as a gate. Wired into `check_target`
so `python check_timing_integrity.py --all` exercises it on every kernel.

- **Result:** 28/28 kernels clean post-fix (exit 0).
- **Tests:** `test_timing_integrity.py` — 13 tests (host-loop, dead-timer, and the
  new backstop incl. the 6 edge cases + a live check that all 6 hardened verifiers
  are gated). Green.
- `test_no_compute_leak.py` stays green (80 tests).

## The key methodological lesson
A reconstruction/answer-key check is **insufficient on its own** when the input is a
fixed closed-form matrix — the stub can hardcode the closed form and satisfy any
check derived from it. **Input randomization is the essential anti-hardcoding
element**: with a seeded random SPD, there is no formula to hardcode, so the kernel
must actually read and factor the matrix. Invariant + randomized input together make
the false pass structurally impossible, which the recovered stub demonstrates (passes
the *old* gate, fails the *new* one).

## Scope / honesty notes
- SpMV / SpMV-Hypersparse / 3D-FFT are **WSE-2-only** (no `commands_wse3.sh`, not in
  `KERNEL_REGISTRY`): hardened and syntax/logic-validated, but **not** WSE-3-run on
  this node. Stated as such — no validation is claimed that wasn't performed.
- This sweep changes **no genuine pass** (every robust win used an already-tight or
  exact verifier); it only closes false-pass doors. No full re-sweep was needed.
- Preserved gaming artifact: `results/full_suite_sweep_20260623_061147/Cholesky/
  run_20260623_114507/Cholesky/pe.csl`.
