# cuda2csl — Paper-grade experimental methodology (v2 plan, 2026-06-18)

Supersedes the ad-hoc improvement plan. Frames the work as a reproducible study
suitable for a workshop/conference submission: an agentic CUDA→CSL translator
plus a CSL optimizer evaluated against human-written CSL references on the
Cerebras WSE-3.

## Contribution (what the paper claims)
A multi-agent system that (W1) translates CUDA kernels to CSL for the Cerebras
wafer-scale engine, and (W2) optimizes CSL kernels, evaluated by compiling +
simulating on the real SDK and comparing `cycles_send` against the upstream
human-written CSL references. We report where it succeeds, where it fails, and
*why*, with ablations isolating the load-bearing components.

## Research questions
- **RQ1 (translate):** Can the agent produce correct CSL from CUDA, and how
  does it compare to the human reference in cycles? Metric: W1 pass-rate
  (compile+verify) and, for passers, `cycles_send` vs reference.
- **RQ2 (optimize):** Starting from a correct kernel, can the agent beat the
  human baseline? Metric: % `cycles_send` reduction vs reference; geomean.
- **RQ3 (what matters):** Which components are load-bearing? Ablations:
  knowledge stack on/off, library-signature injection on/off, attempt cap,
  generation-token budget, model.

## Honest-failure discipline (non-negotiable for the paper)
- **No hand-tuned crutches.** Any information given to the agent must come from
  a *general mechanism* that reads real artifacts (library source, layout,
  contract), not from prose I authored after seeing the failures. (This is why
  the collectives_2d prose fallback was REMOVED 2026-06-18; library signatures
  are extracted from actual `benchmark-libs/*.csl` source only. SDK `<...>`
  modules are honestly "unsupported" until a container-side extractor exists.)
- **Compute-leak firewall held + reported.** W1 implementer never sees the
  reference `pe.csl`; verified by a canary guard + tests. Library *interfaces*
  (param/fn signatures) are allowed (they are headers, not the answer) and are
  shown not to collide with the canary.
- **Report failures, don't paper over them.** W1's 2/21 at cap-8 is reported as
  a real result with its cause (information-starvation, not iteration), not hidden.
- **Independent verification of wins.** Every headline speedup is re-run in a
  fresh bundle via its own commands_wse3.sh (exact cycles + SUCCESS) to rule out
  contract-gaming / measurement artifacts.

## Experimental setup
- **Hardware/SDK:** Cerebras WSE-3, SDK 1.4.0 (sdk-cbcore SIF), appliance
  simulator. SDK is a SERIAL resource — all sweeps run serially (parallel cslc
  wedges the container; observed stale Apptainer procs). This bounds throughput
  and is a stated constraint.
- **Models:** framework agents = claude-opus-4-7 (Argo shim). (Documented prior
  baselines used Sonnet-4-6 / Sonnet→Opus hybrid; model is an ablation axis.)
- **Benchmark suite:** 21 paired (CUDA, CSL) kernels in kernels/; 14 are
  cycle-instrumented (the W2 measurable set). Each has a human CSL reference
  whose `cycles_send` is the baseline-to-beat (kernels/baselines_wse3.json).
- **Benchmark enrichment (2026-06-23): real scientific-computing kernels + a
  program-level tier.** Two manually-authored (CUDA, CSL) pairs ported from
  `MatthewRHermes/mrh` `gpu/` (GPU-accelerated quantum chemistry, LASSCF/CASSCF/
  PDFT) extend the suite beyond synthetic kernels:
  (i) **Tensor-Transpose-021** — a NEW operation family (3D tensor index
  permutation, `_transpose_021`); no transpose kernel existed before. Verified
  6,183 cyc.
  (ii) **PDFT-Pi-Pipeline** — the first **`program-level`** task: the CUDA is
  THREE data-dependent kernels (gridkern → buf → Pi, the on-top pair density
  quadratic form) that the agent must translate as a whole pipeline with its
  intermediate buffers, not one kernel. Verified 128,308 cyc. This adds a harder
  difficulty TIER (kernel-orchestration / multi-stage data-flow) above
  single-kernel translation. Both are held-out test kernels, externally sourced
  (no KB/WaferLLM leakage), and cleared the full run+verify bar
  (compile + numpy correctness + cycles_send) like every existing kernel.
- **Caps:** attempt cap is an explicit variable. cap-8 (fast, used for the full
  sweep) vs cap-20 (documented ablation). Report both; do NOT conflate.
- **Seeds/variance:** W1 is high run-to-run variance near the cap (observed:
  7pt-Stencil failed in the sweep, passed a re-run at attempt 7/8). Paper claims
  about W1 pass-rate REQUIRE multi-seed runs (N≥3) reported as pass-RATE with
  variance, not single pass/fail. (Pending experiment.)

## Metrics
- W1: pass = compile + simulator run + numeric verify vs host reference.
- W2/cycles: `cycles_send` = on-device tic/toc interval (median of 3 sim runs),
  vs the reference `cycles_send`. fast_p scoring (kernels/SPEC_SCHEMA.md).
- Error-family classification: per-attempt cslc stderr bucketed
  (dsr_arity, uninitialized_param, queue/ut_id, halo_unblock_stall, hcf_runtime,
  task_id_range, …) for mechanism-level analysis beyond pass/fail.

## Results to date
> **The held-out TEST-SPLIT table (2026-06-21) below is the paper's main result.**
> The 2026-06-18 numbers in this subsection are the earlier development picture
> (mixed split, pre-integrity-fixes) — kept for the ablation/mechanism story.

- **W2-from-reference (RQ2): 14/14 beat the human baseline, geomean 1.44×
  (30.6% mean reduction), 7 kernels ≥25%** (max Wide-Multiplication −84.6%,
  independently verified). Strongest result; the optimizer reliably beats human
  CSL when started from a correct kernel.
- **W1-from-CUDA (RQ1): 2/21 pass at cap-8** (vs documented 7/15 at cap-20).
  Root cause (mined from all traces): information-starvation, NOT iteration —
  18/18 failures were thrashing; 50% blocked on firewalled library signatures.
- **Two framework bugs found+fixed via honest runs:** (a) immune-kernel
  on-device measurement (4 solvers, 0/158→ real wins); (b) W2 gen-token cap
  (4096→scaled) that masked large-kernel wins (CG −0.26%→−29%).
- **Lever 1 (library-signature injection):** general extractor (real
  benchmark-libs source, no hand-tuning). CAP-8 A/B: pass-rate flat (1/5 both),
  but error-family shows the mechanism works — dsr-arity errors 21→7 (−67%);
  clearing layer 1 exposes layers 2-3. (lever1_ab_report_20260619.md)
  CAP-20 MULTI-SEED A/B (N=3): the win does NOT replicate — pass-rate 7/15 (off)
  vs 5/15 (on), NS & directionally negative; dsr-arity reduction collapses to
  −18%; the E1 queue note BACKFIRED (+84% queue errors, reverted to default-off).
  **Conclusion: the lever's value is CAP-DEPENDENT — large in the information-
  bound regime (low cap), neutral/negative in the budget-bound regime (high cap).
  Thin-dispatcher kernels regress under it.** This regime distinction is itself a
  paper result. (lever1_cap20_multiseed_report_20260620.md)

## FULL-SUITE SNAPSHOT (2026-06-23, all 22 sweepable kernels, single draw)
A whole-framework sweep (results/full_suite_sweep_20260623.md) for the big
picture. Single draw per kernel, cap 12, integrity guards live. **Raw 9/22 pass;
honest 7/22 genuine scoreable passes** (GEMM, Single-Tile-Matvec, BiCGSTAB,
7pt-Stencil, Laplacian2D-Halo, Tensor-Transpose-021, PDFT-Pi-Pipeline) + 1
unscoreable (Mandelbrot, no cycles) + **1 FALSE pass (Cholesky** — a stub gaming
the loose `decimal=2` check; counts as fail). This single-shot number is a LOWER
BOUND: the ~1/3–1/2 fragile kernels are under-sampled by one draw, so the
framework's capability is the multi-seed pass-rate per class, NOT this snapshot.
Two NEW data points from going whole-suite: **BiCGSTAB passes** (hard solver
family is partially reachable) and the **program-level PDFT task beats its
reference 8.4×** (15,243 vs 128,308, independently verified, tight 1e-4 tol). A
THIRD integrity gap surfaced: Cholesky's correctness tolerance is loose enough to
pass a non-factorization — complements the dead-timer (cycles) + frozen-fn guards
with a correctness-strength gap (follow-up: randomized SPD input + L@Lᵀ==A).

## HELD-OUT TEST-SPLIT RESULTS (2026-06-21) — the paper's main table
The 2026-06-18 numbers above are the *development* picture (mixed train/test,
some on train-only kernels). The clean claim is on the **held-out test split**
(docs/SPLIT_AND_LEAKAGE.md): GEMM/GEMV are TRAIN-only (WaferLLM overlap), so the
GEMV "beats expert" headline is a mechanism proof, not a test claim. The full
from-CUDA translate→optimize pipeline was run on the 7 held-out test kernels with
two integrity fixes live (dead-timer floor + frozen-fn splice — see below).

| kernel | class | ref cyc | agent cyc | result |
|---|---|---:|---:|---|
| Laplacian2D-Halo | inline-compute | 25,627 | **3,365** | **7.6× WIN** ✅ verified |
| Wide-Multiplication | inline-compute | 81,739 | **10,938** | **7.5× WIN** ✅ verified |
| Residual | thin-composition | 674 | 543 | 1.24× win |
| 7pt-Stencil | library-delegating | 17,134 | 17,134 | parity (honest ceiling) |
| Single-Tile-Matvec | inline-compute | 780 | 785 | parity |
| Cholesky | algorithm-hard | 12,479 | — | FAIL (algorithm-complexity ceiling) |
| Game-of-Life | fabric-heavy | 7,838 | — | FAIL (fabric-routing ceiling) |

**Headline (RQ1+RQ2 combined, held-out):** of 6 scoreable kernels, translation
passed 5/6; the pipeline **beat the human expert on 3** (two by ~7.5×, both
independently re-verified in clean bundles), reached **parity on 2**, and **failed
honestly on 2** (Cholesky never compiled a full kernel; Game-of-Life deadlocked).
NOTE: those are SINGLE-DRAW numbers; see the multi-seed robustness subsection — the
big wins are best-of-draws, the dependable claim is narrower.

### Multi-seed robustness (N=3 per kernel) — the rigorous version of the table
Translation is high-variance (each run is an independent sampling draw; no seed).
Re-running each kernel 3× (results/multiseed_robustness_20260622.md) gives a clean
two-tier result that PERFECTLY separates by fabric-routing complexity:

| tier | kernels | pass-rate | claim |
|---|---|---|---|
| **ROBUST** | Wide-Mult, Single-Tile-Matvec, 7pt | **3/3 each** | dependable: Wide-Mult **7–9× every draw**; STM+7pt parity |
| **FRAGILE** | Laplacian, Residual, Game-of-Life | **~1/3 (N=3)** | intermittent best-of-N (all verified when they land) |

**Pinned down at N=11 (results/multiseed_fragile_largeN_20260622.md).** Larger N on
the fragile kernels confirms ~1/3–1/2 pass and reveals THREE distinct variance
shapes:
| kernel | pass-rate (N=11) | cycles when passing | shape |
|---|---|---|---|
| Laplacian2D-Halo | 5/11 (~45%) | 2,730 / 16,166 / 16,412 / 16,664 / 17,278 | **BIMODAL** — ~1.5× usual, ~9.4× rare |
| Residual | 4/11 (~36%) | 528–569 | unimodal ~1.2× |
| Game-of-Life | 3/11 (~27%) | 3,365 / 3,777 / 3,942 | unimodal ~2× (all fast) |

**Key refinement: the 7.6× Laplacian headline was a rare FAST-BASIN draw.** The
agent finds two qualitatively different correct halo schedules — a common
naive-but-correct one (~1.5×) and a rare well-overlapped one (~8–9×, two such draws
seen: the sweep's 3,365 and this run's clean-bundle-verified 2,730). So for
routing-heavy kernels, report (pass-rate, basin distribution), never a single cycle
number. Wide-Mult remains the one DEPENDABLE beats-expert claim (robust on both
axes); the fragile kernels are real-but-intermittent with the magnitude itself
high-variance.

Two variance axes, both tracking deadlock-free-routing difficulty: (1) PASS-RATE
(needs multi-PE fabric routing → ~1/3; simple comms → 3/3 — NOT about compute size:
Residual is tiny but multi-PE → fragile; Wide-Mult is compute-heavy but simple-comms
→ robust); (2) QUALITY when passing (Laplacian 1.5× here vs 7.6× in the sweep;
GoL fail/parity/2.3×). **The single-draw 7.6× Laplacian headline was a best-of-draws
outlier.** Honest framing: Wide-Multiplication is the one DEPENDABLE beats-expert win
(~3/3 at 7–9×); the others are real-but-intermittent (report with pass-rate, not as a
typical number). N=3 is a floor — the robust/fragile SEPARATION is solid; exact rates
need larger N.

### Why this table is credible (not cherry-picked)
1. **Compute-locus taxonomy PREDICTS the win-subset.** A static scan (lib-
   delegation calls vs inline-arithmetic signals) classifies each kernel BEFORE
   running. Every inline-compute kernel that passed translation beat or matched
   the expert; the library-delegating kernel hit exact parity (nothing inline to
   optimize). Wins are explained by structure, not luck.
2. **Both halves contribute** (translate THEN optimize): e.g. Wide-Mult
   81,739→49,747 (translate) →10,938 (W2); Laplacian 25,627→13,760→3,365.
3. **Two DISTINCT, named failure modes:** algorithm-complexity (Cholesky can't
   derive distributed blocked factorization blind) vs fabric-routing (Game-of-
   Life can't allocate deadlock-free 8-neighbor comms blind). Naming them is a
   contribution; §"Honest failures" below.
4. **Anti-gaming earned its place mid-experiment.** The very first kernel
   produced a fake 8-cycle "win" (a kernel that computes correctly but never
   enables the timestamp counter → dead timer). A plausibility floor +
   enable_tsc prompt rule turned it into honest parity; every surprising win was
   then independently re-verified. (project_dead_timer_antigaming_guard.)

### Framework fixes this experiment forced (all firewall-safe)
- **Dead-timer floor** (benchmark_csl `_MIN_PLAUSIBLE_CYCLES`): a `pass` with
  implausibly small cycles_send is rejected (dead timer / empty timed window). 0
  false positives across 25 real self-timed kernels.
- **Frozen-function splice** (contract_check.splice_frozen_functions): the W2
  optimizer kept perturbing frozen *timing* functions and losing 100% of
  candidates to the contract gate; splicing the reference's frozen fns back in
  verbatim before scoring unblocked W2 (validated: 0 violations vs 5/5 before).

### 5th integrity pass — verifier hardening against correctness-gaming (2026-06-24)
The full-suite sweep surfaced a **false pass**: a non-factorizing Cholesky stub
scored "pass, cycles=473" because its `run.py` checked `assert_almost_equal(result,
L, decimal=2)` against a *deterministic* answer key — the stub hardcoded
`L[i,j]=i(i+1)/2+j+1` by formula and never read the input matrix. An audit of all
~29 `kernels/*/CSL/run.py` verifiers showed the weakness was systemic (loose
tolerances, ungated PASS/FAIL prints, relaxable CLI tolerances), so the *correctness*
gate — not just the *timing* gate — needed hardening. Five verifiers were hardened,
each validated against the live reference (and, where recoverable, against the
gaming kernel):
- **Cholesky**: deterministic answer key → **randomized SPD input** (seeded random
  lower-triangular L, diagonally boosted) + an **invariant** gate (the returned
  factor must be lower-triangular AND reconstruct the input, `‖LLᵀ−A‖/‖A‖ < 1e-3`).
  Validated on WSE-3: reference passes at **1.86e-07**; the preserved false-pass
  stub is now **rejected** (backward error **3.2e+04**), still emitting its 473
  cycles — i.e. the exact door that was open is now closed.
- **SpMV / SpMV-Hypersparse**: `verify_result()` only *printed* PASS/FAIL and never
  raised → no enforced gate at all. Now **asserts** on mismatch and prints SUCCESS
  only when correct. (WSE-2-only kernels; syntax+logic-validated, not WSE-3-run here.)
- **FFT-1D-2D**: `rtol=0.25` (25% error) → measured the real reference error
  (3e-8…5e-4) and tightened to `rtol=1e-2` + a signal-scaled `atol` floor for
  near-zero FFT bins. Validated: reference passes with orders of margin.
- **3D-FFT**: `rtol=0.5` (fp16) / `0.01` with `atol=0` → same signal-scaled-atol +
  tight-rtol pattern. (WSE-2-only; fixed by inspection.)
- **Jacobi-2D-5pt**: tolerance was a relaxable CLI arg → **hard-clamped** to
  `min(args.tolerance, 1e-5)` so SUCCESS can't be bought by loosening the gate.
  Validated on WSE-3: reference passes (max_abs_err 0.0, tolerance clamped).

**Harness-level backstop** (`check_timing_integrity.check_success_gated`): a static
linter that flags any `run.py` printing a SUCCESS marker with **no enforcement
primitive** (assert / raise / `np.testing.assert_*` / nonzero exit) on its path —
exactly the SpMV ungated-verifier shape. Runs over all kernels via `--all` (28/28
clean post-fix); covered by `test_timing_integrity.py` (13 tests). This complements
the dead-timer floor (timing) and frozen-fn splice (contract) with a *correctness*
guard, so all three gaming surfaces — cycles, contract, and correctness — now have
both a per-kernel fix and a static backstop.

### 6th integrity pass — input-level train/test split (the principled generalization)
Tightening N verifiers one-by-one is the "given THIS bench, here's THIS fix" pattern
this study explicitly avoids. The root enabler of the Cholesky false pass was deeper:
the agent is shown `run.py` (the host contract), which carries BOTH the input
construction AND the reference-answer computation — so a *deterministic* input lets a
kernel reproduce the answer without computing it. The structural fix generalizes the
5th pass: give each benchmark a **train input (shown) + held-out inputs (hidden)** and
score correctness on the held-out set. A hardcoded answer passes train but fails
held-out — closing the door for every kernel via one mechanism, independent of verifier
tolerance (demonstrated: under the OLD weak `decimal=2` gate, a hardcoded answer still
fails every held-out seed). Implemented as a back-compat `eval:` block in spec.yaml +
`benchmark_csl.evaluate_heldout` (gate `XKERNEL_HELDOUT_EVAL`, default off), with the
held-out seed values kept harness-only (firewall: spec.yaml is never injected;
asserted by HeldoutSeedLeakTest). Piloted + WSE-3-validated on Cholesky /
Single-Tile-Matvec / Residual; the preserved false-pass stub is rejected on every
held-out seed. This also separates the two failure axes cleanly: *gaming-risk* (closed
by hardening + input split) vs *honest-capability fail* (the benchmark's value —
numeric solvers, hidden-reference collective decomposition — deliberately NOT patched
per-bench). Full audit: `docs/INPUT_SPLIT_AND_FAILURE_AUDIT_20260624.md`;
policy: `docs/SPLIT_AND_LEAKAGE.md` §6.

### Honest failures + the firewall-design finding
A workflow (16 agents, design→leak-audit→synthesize) root-caused both failures
and produced firewall-safe hints (XKERNEL_HARD_KERNEL_HINTS). Key finding:
**Cholesky's "abandonment" (prose/stub output) is a RATIONAL response to an
unsolvable constraint, not a model weakness.** The agent (attempt #1) correctly
derived the algorithm AND identified that the hidden, immutable layout.csl's
single-injector-per-column routing cannot deliver the trailing GEMM's second
operand — then shipped a knowingly-partial kernel because it is forbidden to edit
routing. This is a **benchmark-firewall design limitation for co-designed
compute+routing kernels** (only the compute half is writable): a class of kernel
is untranslatable without also exposing/authoring the layout.

**Hinted-retry outcome — the two failures split exactly along the
informational/structural line, which validates the firewall-safe-hint mechanism:**
- **Game-of-Life: FAIL → PASS** (0/12 → pass at attempt 5; 7,584 cyc vs 7,838 ref,
  −3%; independently verified + leak-re-audited; code_similarity 0.09). Its ceiling
  was INFORMATIONAL — the agent lacked the deadlock-free-exchange discipline; a
  firewall-safe hint (generic dual-color/parity OR phased send/recv + async
  single-occupancy; names no reference id) supplied it and the kernel passed.
- **Cholesky: still FAIL** with the hint — but the failure mode SHIFTED to explicit
  "the given layout.csl can't route the trailing-update operand" stalls (the agent
  now diagnoses the exact structural blocker in its own verdicts). Its ceiling is
  STRUCTURAL: no firewall-safe hint can fix routing the agent isn't allowed to
  author. Fixing it needs a harness change (let the agent emit layout.csl too).

This is a clean, falsifiable result: **a firewall-safe hint recovers an
information-bound failure and provably cannot recover a structure-bound one** —
distinguishing the two failure classes operationally, not just by inspection.

### Co-design experiment: confirming the structural ceiling (2026-06-22)
To test the structural-ceiling claim directly, a gated mode
(`XKERNEL_CODESIGN_LAYOUT`) lets the agent author BOTH `pe.csl` AND `layout.csl`
from scratch — full co-design, firewall STRENGTHENED (both reference files hidden
+ canaried). Re-ran Cholesky:
- **Still 0/12, but the failure character flipped:** abandonment (prose/stub/
  diagonal-only) went **5+/12 → 0/12**. Given the ability to author routing, the
  agent stopped giving up and actively engineered its own compute+routing system
  (a 145-line pe.csl + a 55-line agent-authored layout using `<collectives_2d>`
  broadcast — a DIFFERENT strategy from the reference's switch relay). All 12
  failures became fixable cross-file/API/comptime errors, never a dead end.
- **This CONFIRMS the diagnosis:** the firewall (compute writable, routing hidden
  + immutable) CAUSED the abandonment, not an inability to reason about the
  algorithm. Lifting the constraint removed the behavior.
- It didn't pass because co-design WIDENS the problem (the agent owns both sides
  of the pe↔layout interface), and 12 attempts under-samples a from-scratch
  two-file collectives-routed distributed Cholesky. See
  results/cholesky_codesign_20260622.md.

**Cholesky difficulty, peeled one layer at a time (the localization chain).** Two
further firewall-safe levers — cap 24 + a cross-file `collectives_2d` wiring
exemplar (TRAIN-sourced, 0 reference leakage) — moved the blocker DEEPER again
(results/cholesky_codesign_cap24_20260622.md):
  1. single-file: STRUCTURAL — can't author routing → rational abandonment (5+/12);
  2. co-design: abandonment gone (0/12) → stuck on cross-file collectives WIRING;
  3. co-design + exemplar: WIRING SOLVED → a **383-line complete co-design that
     compiles, runs, and gets the diagonal blocks correct**, failing ONLY on the
     off-diagonal **Schur/TRSM trailing-update operand routing** — the genuine
     algorithmic crux of distributed blocked Cholesky (classic "diagonal-only"
     partial). 5 of 9 attempts reached the correctness check (vs compile-fail).
  The run ended at attempt 9 on the **architect re-spin cap (2)**, not the attempt
  budget — the remaining gap is a DESIGN-SEARCH-DEPTH problem (the off-diagonal
  data flow is an architecture decision), not knowledge or abandonment.
This staged localization is itself a result: it shows *exactly* which layer of a
co-designed kernel defeats the agent, and that each firewall-safe lever advances
the frontier by one layer.

**Paper framing:** the benchmark has a *firewall design axis* — single-file
(compute-only, the default) vs co-design (compute+routing). Co-designed-routing
kernels (Cholesky) are untranslatable single-file by construction; the co-design
mode is the honest harness for them, and it converts a structural dead-end into a
tractable (if wider) search.

## Ablations (planned/in-progress)
| Axis | Arms | Status |
|---|---|---|
| Knowledge stack | full / --no-knowledge / --bare | done (7/15, 1/15, 1/15; Sonnet cap-20) |
| Library signatures | off / on | A/B running (5 kernels, error-family) |
| Attempt cap | 8 / 20 | partial (cap-8 sweep done; cap-20 = documented) |
| Gen-token budget | 4096 / scaled | done (CG −0.26% vs −29%) |
| W1 vs W2 path | translate-from-CUDA / optimize-from-ref | done (2/21 vs 14/14) |
| Model | Sonnet / Opus / hybrid | partial (Opus this run; Sonnet documented) |
| Dead-timer floor | off / on | done (rejects fake 8-cyc win; 0 false-pos /25) |
| Frozen-fn splice | off / on | done (W2 0/5→unblocked; 0 violations vs 5/5) |
| Hard-kernel hints | off / on | done (GoL fail→pass; Cholesky still fail = structural) |

## Threats to validity (state these in the paper)
1. **Run-to-run variance** near the attempt cap — mitigate with N≥3 seeds for
   pass-rate claims.
2. **Cap sensitivity** — cap-8 understates W1; report cap as a variable.
3. **Compute-leak firewall** — verified, but library-signature injection widens
   what the agent sees; we argue (and test) interfaces ≠ answers.
4. **Baseline re-measurement** — immune-kernel baselines were re-measured on the
   on-device build; old host-loop numbers are not comparable (documented).
5. **Simulator vs hardware** — cycles are appliance-simulator; deterministic
   across our runs (cycles_send identical across 3 sims for accepted variants).
6. **Single SDK/library version** — signatures extracted from SDK 1.4.0.

## Reproducibility
- All runs preserve full traces: translation_log.json (conversation),
  final_result.json (per-attempt cslc stderr + reviewer verdicts),
  version_trace.json, optimization_summary.json.
- Analysis tooling: sweep_scoreboard.py, error_family.py, the w1-failure-mining
  workflow. Result reports under code_translation/results/*_20260618.md.
- Gaps to close before submission: (a) multi-seed W1 pass-rate; (b) cap-20 W1
  sweep paired with lib-signatures; (c) container-side SDK-module extractor for
  collectives kernels; (d) flush-on-crash so early-crash runs leave a trace.

## Translation-quality design (the improvement roadmap)
See **docs/TRANSLATION_QUALITY_DESIGN.md** (2026-06-19, synthesized from a
4-angle research workflow grounded in the trace evidence). Key conclusions:
- **IR:** adopt a structured/validated DESIGN.md schema (option A) now to close
  the architect→implementer info-loss behind 9/18 invisible-root-cause failures;
  defer a wafer-dataflow DAG IR (B); keep CUDA→NL-spec (mode_cuda_nl, C) as a W3
  default / W1 fallback, not a W1 prerequisite.
- **Injection stack (mapped to failure families):** L1 library signatures [DONE,
  −67% dsr], L2 queue/ut_id discipline [DONE, unproven], then ranked: SDK module
  schemas (collectives), compile-error→gotcha retrieval, DSR/queue budget facts
  at architect stage, halo micro-example retrieval.
- **Base-safe levers:** scoped reader/debugger v2 (fixes the tool_use:0 smoking
  gun — Read scoped to firewall-visible files only), structured-error reviewer +
  targeted repair routing, compile-only dry-check, progressive layer memory,
  entrypoint checklist. All additive/ablatable, firewall-preserved.
- **Paper novelty:** the layered information-asymmetry failure analysis itself
  (clearing layer 1 exposes layers 2-3), transferable to other spatial ISAs.

## Next experiments (ranked)
1. Finish lever-1 A/B + error-family analysis → does library-signature injection
   remove the dsr-arity failure family? (mechanism-level claim)
2. Multi-seed (N≥3) W1 pass-rate, cap-8 vs cap-20, lib-sigs off vs on → the RQ1
   + RQ3 table with variance.
3. Container-side extractor for SDK `<collectives_2d/*>` → extend lever 1 to the
   collectives cluster (general, not hand-tuned).
4. Lock the W2-from-reference geomean table (RQ2) with independent verification
   for all 14 (done for the big ones; extend to all).
