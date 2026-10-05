# Authoritative benchmark scoreboard (as of 2026-06-24)

Consolidates every measurement this week into one corrected picture. Supersedes
raw single-run numbers where later evidence corrected them (C1 solver re-run;
Cholesky false-pass; multi-seed reliability). Levers default-off (A/B unproven).

## How to read this
- **single-draw pass** = one from-CUDA translate+optimize run passed (correct +
  cycles_send). Translation is high-variance, so single-draw is a LOWER BOUND.
- **multi-seed pass-rate** = the honest reliability (N=3 robust, N=11 fragile).
- **vs ref** = agent cycles ÷ human reference cycles (lower = win).
- All firewalled (agent never sees the reference compute), integrity-guarded
  (dead-timer floor + frozen-fn splice + correct layout contract).

## Scoreboard — 22 sweepable kernels

### A. PROVEN PASSES (translate+optimize, correct, reproduces)
| kernel | cycles | ref | vs ref | reliability | note |
|---|---:|---:|---|---|---|
| **Wide-Multiplication** | 8,896–11,356 | 81,739 | **7–9× WIN** | **3/3** | the one DEPENDABLE beats-expert win |
| **PDFT-Pi-Pipeline** | 15,243 | 128,308 | **8.4× WIN** | pass (verified) | program-level task (mrh) |
| **Tensor-Transpose-021** | 527–700 | 6,183 | **8.8–11.7× WIN** | pass (multi-draw) | new op family (mrh); capstone-verified |
| **Laplacian2D-Halo** | 2,730 (best) / ~16k (typ) | 25,627 | **1.5×–9.4×** | 5/11 (~45%) | BIMODAL: usually ~1.5×, rarely ~9× |
| **Residual** | 528–569 | 674 | **~1.2× win** | 4/11 (~36%) | tight when it lands |
| **Game-of-Life** | 3,365–3,942 | 7,838 | **~2× win** | 3/11 (~27%) | all passes in a fast basin |
| **BiCGSTAB** | 46,594 | 59,385 | **1.27× win** | pass (C1-corrected) | iterative solver — reachable! |
| **GEMM** | 580,966 (large) | (large ref measured at runtime) | pass | single-draw | SUMMA at the 240² large size |
| **Single-Tile-Matvec** | 785–1,249 | 780 | **parity** | 3/3 | robust, single-PE |
| **7pt-Stencil** | 17,026–17,146 | 17,134 (large) | **parity** | 3/3 | library-delegating; tightest |

### B. CORRECTNESS-ONLY PASS (unscoreable)
| kernel | status | reason |
|---|---|---|
| Mandelbrot | pass (correct) | run.py emits no cycles_send → no speed comparison |

### C. FAILS (honest, classified)
| kernel | class | why it fails |
|---|---|---|
| GEMV (large) | routing/collective | fragile ~1/3; mis-wired collectives on this draw |
| GEMM-Collectives-2D | collective-participation | SUMMA serialized-chain decomposition (hidden ref) |
| GEMV-Collectives-2D | collective-participation | 5-stage scatter/gather decomposition (hidden ref) |
| GEMV-Checkerboard | fabric-routing | H2D→fabric re-broadcast idiom, fragile |
| Power-Method | numeric+fabric | 1/√10 scaling bug + queue/forward-decl (C1-corrected: contract errors gone) |
| CG | numeric | per-iteration convergence semantics (hidden state machine) |
| Preconditioned-CG | numeric | per-iteration + preconditioner semantics |
| Laplacian2D-Reduce | skeleton | VERIFY=False / incomplete reference |
| LorenzoPredictor-Tile | skeleton | incomplete reference |
| FFT-1D-2D | quarantine | library-wrapper / size-mismatch (not a clean task) |
| **Cholesky** | **FALSE PASS corrected → FAIL** (verifier now hardened) | the 473-cyc "pass" was a stub gaming the loose decimal=2 check; not a real factorization. Verifier hardened 2026-06-24 (randomized SPD input + LLᵀ=A invariant): the reference passes (1.9e-07), the stub is now rejected (backward err 3.2e+04) — false pass structurally impossible |

## Headline tallies
- **Scoreable kernels:** ~20 (Mandelbrot unscoreable; FFT quarantine).
- **Genuine passes (proven, correct):** **10** (table A).
- **Beat the human expert:** **7** — Wide-Mult (7–9×), PDFT (8.4×), Tensor-Transpose
  (8.8×), Laplacian (up to 9.4×), Residual (1.2×), Game-of-Life (2×), BiCGSTAB (1.27×).
- **Parity:** 2 (Single-Tile-Matvec, 7pt-Stencil). **GEMM** passes at large size.
- **Honest fails:** 10 (collective-decomposition ×3, numeric-solver ×3, skeleton ×2,
  quarantine ×1, Cholesky structural/false-pass ×1).

## The honest framing (for the paper)
1. **Capability vs reliability are different axes.** Single-shot suite reliability
   is ~7/22 (lower bound); the robust kernels pass ~3/3 and the fragile ones
   ~1/3–1/2. Report per-CLASS, not one number.
2. **Dependable beats-expert win: Wide-Multiplication (7–9×, every draw).** The
   others are real-but-intermittent (report with pass-rate + basin).
3. **Two genuinely hard frontiers, both named & evidenced:** collective-
   decomposition (GEMV/GEMM collectives, hidden-reference wall) and iterative-
   solver numerics (CG/PCG/Power-Method). BiCGSTAB passing shows the solver
   family is not a uniform wall.
4. **Five integrity guards earned their place** by catching real gaming/bugs:
   dead-timer floor, frozen-fn splice, Cholesky loose-tolerance (false pass),
   the firewall catching a leak in the new leave-one-out lever, and (2026-06-24)
   the verifier-hardening sweep — 5 gameable correctness gates tightened +
   randomized-input/invariant checks + a static `check_success_gated` backstop
   (28/28 kernels clean) so the false-pass door (and the SpMV ungated-verifier
   shape) is structurally closed. The Cholesky stub that scored 473 cyc is now
   rejected by its own verifier (backward error 3.2e+04 vs reference 1.9e-07).
5. **Levers (WS3 retrieval + WS4 why-faster rules) built but unproven at N=1**
   (NET −2, fragile-kernel noise); default-off, awaiting multi-seed cycle eval.

## Caveats on specific numbers
- GEMM "580,966" is the large (240²) config; not comparable to the small ref 51,753.
- Laplacian/7pt large-size numbers are single-sweep (references stall at iters>1).
- Solver fails are post-C1-fix (correct contract); they fail on REAL compute now,
  not the stale-contract artifact.
- Sources: full_suite_sweep_20260623, solvers_fix1_revalidate_20260623,
  multiseed_robustness_20260622, multiseed_fragile_largeN_20260622,
  benchmark_enrichment_mrh_20260623, lever_ab_verdict_20260624.
