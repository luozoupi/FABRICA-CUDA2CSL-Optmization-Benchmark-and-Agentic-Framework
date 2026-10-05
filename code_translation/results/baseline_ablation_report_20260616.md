# Knowledge-ablation baseline sweep — report (2026-06-16 → 2026-06-17)

**One-line bottom line:** Across 15 W1 kernels × 3 knowledge tiers (45 translations,
~28h, Sonnet 4.6, loop cap 20), the knowledge stack is **necessary for correctness on
every non-trivial kernel and dispensable only on the single trivial single-PE kernel.**
A 20-attempt repair loop with knowledge stripped recovered **0 of the 6** kernels that
pass with knowledge. Brute-force looping does not substitute for knowledge.

Run root: `code_translation/results/baseline_ablation_20260616_170615/`
Mode: `--no-knowledge` (soft) / `--no-knowledge --bare` (bare), built this session
(tasks #76–77). Sweep runner: `run_baseline_ablation_sweep.sh`.

---

## Design

Three arms, all else identical (Sonnet 4.6, `--reviewer-max-attempts 20
--auto-optimize --max-optimize-attempts 20`, reviewer ACTIVE, reference measured but
never shown — compute-leak invariant held):

| Arm | Flag | TIER-A curated/retrieved (RAG, gotchas, tutorials, skills, mesh, experience) | TIER-B CSL language primer (types, DSDs, tasks, WSE3) | TIER-C structure (layout.csl, contract, CUDA source, builtin whitelist) |
|---|---|:---:|:---:|:---:|
| **knowon** | (none) | ✓ | ✓ | ✓ |
| **soft** | `--no-knowledge` | ✗ | ✓ | ✓ |
| **bare** | `--no-knowledge --bare` | ✗ | ✗ | ✓ |

Goal-check + scoring identical across arms: `benchmark_translated_compute_file`
(compile + simulate + verify vs reference) → `status=pass`, then
`build_version_trace` records cycles_send vs the measured reference.

---

## Full results (45 verdicts)

| Kernel | Cluster | knowon | soft | bare | knowon cycles |
|---|---|:---:|:---:|:---:|---:|
| GEMV | collectives | **pass** | fail | fail | 4449 |
| GEMM | collectives | **pass** | fail | fail | 55807 |
| GEMV-Collectives-2D | collectives | **pass** | fail | fail | n/a* |
| GEMM-Collectives-2D | collectives | **pass** | fail | fail | 310549 |
| FFT-1D-2D | dsr | **pass** | fail | fail | n/a* |
| Laplacian2D-Halo | halo | **pass** | fail | fail | 1268 |
| 7pt-Stencil | dsr | fail | fail | fail | — |
| Mandelbrot | dsr | fail | fail | fail | — |
| Residual | halo | fail | fail | fail | — |
| Cholesky | halo | fail | fail | fail | — |
| Laplacian2D-Reduce | halo | fail | fail | fail | — |
| LorenzoPredictor-Tile | halo | fail | fail | fail | — |
| Game-of-Life | halo | fail | fail | fail | — |
| GEMV-Checkerboard | halo | fail | fail | fail | — |
| Single-Tile-Matvec | none (1 PE) | **pass** | **pass** | **pass** | n/a* |

\* cycles_send is `None` in benchmark.json — these kernels' run.py lacks timestamp
instrumentation. Correctness (status=pass) is captured; cycle count is not. Not a
parse bug.

### Pass-rate by arm

| Arm | Pass rate |
|---|---|
| knowon | **7 / 15** |
| soft | **1 / 15** |
| bare | **1 / 15** |

---

## Interpretation

### 1. Knowledge buys correctness, and looping does not substitute for it.

Of the 7 kernels that pass with full knowledge, **6 fail in both soft and bare** even
after 20 repair attempts. The lone kernel that passes without knowledge
(Single-Tile-Matvec) is the **only single-PE, no-fabric kernel** in the set — it needs
no wafer-scale idioms at all. Every kernel requiring collectives, halo exchange, or
DSR/queue setup **requires the curated knowledge** to translate correctly; a
20-iteration brute-force loop never rediscovers those idioms.

This is the **control group the knowledge-injection program never had.** It reframes the
three earlier prompt-augmentation discards (semantic_bridge, translation_facts ×2):
those measured the *marginal* value of *adding more* knowledge on top of an
already-knowledgeable pipeline — and found none. This sweep measures the *total* value
of the knowledge stack vs none, and finds it is **large and correctness-critical**, not
substitutable by compute. "Adding more knowledge doesn't help" and "the existing
knowledge is essential" are both true and not in tension.

### 2. The knowledge value is concentrated exactly where the idioms are hard.

| Kernel class | knowledge needed for correctness? |
|---|---|
| Single-PE, no fabric (Single-Tile-Matvec) | **No** — passes bare. Model's training + structure suffice. |
| Collectives (GEMV/GEMM/×-Collectives-2D) | **Yes** — 4/4 pass knowon, 0/4 without. |
| Halo / DSR (the kernels that pass at all: FFT, Laplacian2D-Halo) | **Yes** — pass knowon, fail without. |

Actionable: knowledge investment should target the hard-idiom clusters (collectives,
halo, DSR). Spending knowledge budget on simple kernels is wasted — they pass without it.

### 3. soft ≈ bare (both 1/15). The CSL language primer (TIER-B) added nothing here.

The only kernel either tier passed (Single-Tile-Matvec) passed in **both** soft and bare
— so stripping the CSL primer on top of the curated knowledge made no difference. For a
trivial kernel the model knows enough CSL from training; for the hard kernels the primer
alone (without curated idioms) is insufficient. The primer is not the load-bearing layer
either way. (Caveat: a stronger model, or harder-but-not-idiom-bound kernels, might show
primer value; this set doesn't.)

---

## Caveats (important — do not over-read)

1. **Sonnet-only; this is NOT the production hybrid.** The ablation runner calls
   cuda2csl directly, so the **knowon arm = "Sonnet + full knowledge"**, which is weaker
   than the production hybrid (Sonnet→Opus promotion = 6/15 union). 7pt-Stencil,
   Mandelbrot, etc. fail all three arms here because **Sonnet can't do them at all**, with
   or without knowledge — that is a model-ceiling result, not a knowledge result. The
   knowon arm is the correct control **for soft/bare** (same model, only knowledge
   differs); it is not comparable to the hybrid 6/15 number.

2. **±1-kernel Sonnet variance floor** (measured 2026-06-16, see
   `project_w1_prompt_augmentation_discards` memory). Single-run-per-arm; a single
   pass/fail flip could be noise. BUT the headline here is a **6-kernel gap** (knowon 7 vs
   soft/bare 1), far outside the noise floor — the conclusion is robust even if one
   individual cell is variance. The one kernel I'd flag specifically: Laplacian2D-Halo is
   ~1/3-reliable even with knowledge (tie-break earlier), so its soft/bare fails are
   partly confounded by variance — but it passing knowon and not soft/bare is consistent
   with the overall pattern regardless.

3. **Cycles not the signal.** This sweep measures **correctness** (does it translate at
   all). Cycle-quality comparisons aren't meaningful when soft/bare produce no passing
   kernel to compare. Where both a kernel's arms passed (only Single-Tile-Matvec), cycle
   instrumentation was absent anyway.

4. **Iterative-solver measurement caveat** (`project_power_method_instrumentation`) does
   not apply here — none of the 15 are in that family.

---

## Bottom line for the project

- The W1 knowledge stack is **doing real work**: it is the difference between 7/15 and
  1/15 correctness on Sonnet. It is not decorative, and it is not replaceable by a longer
  loop.
- This **coexists** with the augmentation discards: the stack is at the point of
  *diminishing returns to additions* (3 discards) while still being *essential in
  aggregate* (this sweep). The lever for improvement is therefore NOT "more knowledge"
  and NOT "more looping" — it is **model capability** (the hybrid Opus path) and the
  hard-cluster idioms already curated.
- The `--no-knowledge` mode is now a permanent, tested ablation harness for re-asking
  this question on future models (e.g. when a model gets strong enough that soft starts
  matching knowon, the knowledge stack can be retired — this sweep is the baseline to
  measure that against).

— End of report —
