# xkernel — progress summary 2026-06-04 (delta from 2026-06-03)

**Date:** 2026-06-04
**One-line bottom line:** Phase 1 regex-IR ("translation facts") feasibility A/B fired against the W1 corpus — verdict was **discard** (0 wins, 2 losses, 17 ties of 19 attempts vs Opus 4.7 + RAG). Wiring pulled; extractor + harness + tests retained as reusable infrastructure for future implementer-prompt experiments.

This is a verdict-and-revert report. The architecture deltas live in `progress_summary_20260603.md`; this doc only records what changed on 2026-06-04.

---

## Part 1 — What we tried

**Intent.** Insert a regex-extracted "translation facts" YAML block between CUDA and CSL during agentic translation, so the implementer LLM had structured facts to reason from instead of just unstructured prose. Hypothesis: dominant W1 failures are mechanical lookup errors (`@fmacs` arity, `c2d_params.x.dim_size` vs `NUM_PES`, task-id collisions, queue 0/1 collisions), and a structured facts block would prevent them.

**Plan.** 5 sequenced steps, all delivered:
1. **F1** — `code_translation/csl_builtins.yaml`: hand-scraped table of ~30 builtins (arities, params, notes) covering the W1 failure surface.
2. **F2** — `code_translation/translation_facts.py`: regex extractor over layout.csl + run.py + commands_wse3.sh, with a 30-line YAML cap and high-leverage-first truncation policy. Surfaces task IDs owned by layout, memcpy queue reservations, tile-code params pe.csl must declare, host launch sequence, and per-import field schemas (including the explicit "use `NUM_PES`, NOT `dim_size`" gotcha for `<collectives_2d/pe>`).
3. **F3** — `{translation_facts}` slot wired into `q_translate_cuda_to_csl_bundle`, `csl_bundle_fix_with_review`, `csl_bundle_fix_contract`; computed once per kernel in `cuda2csl.translate()`, threaded through 5 `.format()` call sites; env-gated `XKERNEL_TRANSLATION_FACTS=0`.
4. **F4** — 9 new unit tests; 70/70 passing after wiring.
5. **F5** — `tools/ab_translation_facts.py`: A/B replay harness that re-fires each captured implementer call from `results/resweep_w1_opus_rag_20260603/` twice (with and without the facts block), scores each reply against a structural-class checker for the 4 known W1 failure classes (`c2d_params.dim_size`, `@fmacs` arity, queue 0/1 reuse, task-id collision), and writes a CSV verdict.

**Plan's pre-stated verdict gate** (from `/home/USER/.claude/plans/hi-under-the-current-quizzical-jellyfish.md`):
- ≥30% lift on fact-class errors → proceed to end-to-end re-sweep
- 10–30% → narrow the facts surface and re-A/B
- <10% lift → discard, faster verdict than the semantic_bridge experiment

---

## Part 2b — Re-run on Opus 4.8 (2026-06-16) — discard CONFIRMED across two model tiers

Per user direction ("re-execute verbatim on Opus 4.8"), the same verdict gate was
re-fired against the **same fixed corpus** (`resweep_w1_opus_rag_20260603`, the 2026-06-04
attempt logs) so the result is byte-comparable to the original 4.7 run. Only the
`--model` changed (`claude-opus-4-7` → `claude-opus-4-8`). Artifacts:
`tools/ab_translation_facts_opus48_20260616.csv` (+`.log`).

```
================ A/B SUMMARY (Opus 4.8) ================
Scored attempts: 18  (1 dropped: transient 401/403 proxy blip on
                      GEMV-Checkerboard #2 with-arm; not a result)
  WIN  (with-facts ok, without-facts not): 1
  LOSS (without-facts ok, with-facts not): 0
  TIE  (both same):                        17
  Net lift: +5.6%   (gate: >=30% proceed / <10% discard)  -> DISCARD
=======================================================
```

| | Opus 4.7 (2026-06-04) | Opus 4.8 (2026-06-16) |
|---|---|---|
| WIN | 0 | 1 |
| LOSS | 2 | 0 |
| TIE | 17 | 17 |
| Net lift | −10.5% | +5.6% |
| Verdict | discard | **discard** |

**The 4.8 run is a STRONGER discard, not a reopening.** The single "win" (Game-of-Life
#1) is the same fence-drop noise as the 4.7 losses, landing heads this time: the
*without*-arm randomly omitted its ```` ```csl ```` fence (`without_err = "no csl fence"`),
while the structural fact-class checker (`c2d_params.dim_size`, `@fmacs` arity, queue 0/1
reuse, task-id collision) fired **zero times in either arm across all 18 attempts** — same
as 4.7. The more capable model erased both of 4.7's losses (FFT-1D-2D #1, Game-of-Life #1
perturbations), confirming the block's only measurable effect (occasional fence-drop)
shrinks toward pure no-op as the model improves. There is no model tier on which this
block helps. **Gate not cleared → plan steps 3 (wire slot) and 6 (end-to-end re-sweep)
were correctly NOT executed; production prompt files untouched.** This closes the one open
question the 2026-06-04 discard left ("does a smaller-RAG/different-tier model show
different signal") on the upward tier; the downward tier (Sonnet/Haiku, where RAG gotchas
may not saturate) remains the only untested direction if this is ever revisited.

---

## Part 2 — A/B result (original, Opus 4.7)

Fired 19 attempts × 2 arms = 38 LLM calls against Argo Opus 4.7 (~30 min wall-clock).

```
================ A/B SUMMARY ================
Total attempts replayed: 19  (fired both arms: 19)
WIN  (with-facts ok, without-facts not): 0
LOSS (without-facts ok, with-facts not): 2
TIE  (both same):                        17
Median prompt delta (chars):             781
=============================================
```

| Kernel | Attempt | Without facts | With facts | Verdict |
|---|---:|:-:|:-:|:-:|
| GEMM-Collectives-2D | 1 | ok | ok | tie |
| GEMV-Collectives-2D | 1 | ok | ok | tie |
| FFT-1D-2D | 1 | ok | **no csl fence** | LOSS |
| FFT-1D-2D | 2 | ok | ok | tie |
| Laplacian2D-Halo | 1 | ok | ok | tie |
| Laplacian2D-Reduce | 1 | ok | ok | tie |
| Laplacian2D-Reduce | 2 | ok | ok | tie |
| Mandelbrot | 1 | ok | ok | tie |
| Mandelbrot | 2 | ok | ok | tie |
| Mandelbrot | 3 | ok | ok | tie |
| Cholesky | 1 | ok | ok | tie |
| Cholesky | 2 | no csl fence | no csl fence | tie |
| Cholesky | 3 | ok | ok | tie |
| Game-of-Life | 1 | ok | **no csl fence** | LOSS |
| Game-of-Life | 2 | ok | ok | tie |
| Game-of-Life | 3 | ok | ok | tie |
| Residual | 1 | ok | ok | tie |
| GEMV-Checkerboard | 1 | ok | ok | tie |
| GEMV-Checkerboard | 2 | ok | ok | tie |

**Net lift: −10.5%** (0 wins minus 2 losses, over 19 trials). Decisive **discard** under the plan's gate (<10%).

---

## Part 3 — Root cause analysis

Two observations from the verdict, in priority order:

**1. The W1-failure signal the block was designed to prevent has effectively disappeared in this corpus.** The structural checker (built specifically to detect `c2d_params.dim_size`, `@fmacs` arity, queue collisions, task-id reuse) **never flagged a fact-class violation in either arm** across all 19 attempts. The only non-tie outcomes were `"no csl fence in reply"` — a different failure mode the facts block doesn't address. The RAG'd gotchas (added 2026-06-03 in the resweep run that captured this corpus) already cover the surface the facts block targets. We were attacking a problem that's already half-solved.

**2. The block introduced its own perturbation.** Adding ~780 chars (~0.5% of prompt) before `{knowledge_base}` shifted Opus's response distribution just enough to occasionally drop the code fence (FFT-1D-2D #1, Game-of-Life #1). The intervention is small but not invisible to the model. This is the **same root cause as the semantic_bridge discard**: extra context before the implementer is a noisy intervention when the implementer isn't bottlenecked on what's being added.

**Pattern across discarded interventions on the W1 prompt:**

| Intervention | Form | Verdict | Lesson |
|---|---|---|---|
| `semantic_bridge` (2026-06-03) | prose mapping tables CUDA→CSL primitives | discard (1/4 vs 1/4) | algorithm-level prose doesn't address syntax-level failures |
| `translation_facts` (2026-06-04) | structured YAML facts (CSL contract surface) | discard (0W/2L/17T) | structured facts don't help when the failure surface is already covered by RAG'd gotchas + Opus's training |

Two augmentations, same shape, same outcome. The third would be embedding-based RAG. Worth thinking about whether ANY pre-prompt augmentation can move the needle on a model that already has good RAG, or whether the next leverage point is somewhere else (in-loop / post-failure / different model tier).

---

## Part 4 — What we kept vs pulled

### Pulled (today)

- `{translation_facts}` slot removed from all 3 prompts in `prompt_cuda2csl.py` (q_translate_cuda_to_csl_bundle, csl_bundle_fix_with_review, csl_bundle_fix_contract). Templates are now byte-equal to the pre-Phase-1 state.
- Wiring removed from `cuda2csl.py` (5 `.format()` call sites, the per-kernel `_translation_facts_block` computation, the `XKERNEL_TRANSLATION_FACTS` env-gate, and the `from translation_facts import render_facts_block` import).
- 2 slot-presence tests pruned from `test_no_compute_leak.py` (`test_facts_slot_present_in_implementer_and_repair_prompts`, `test_facts_render_renders_before_knowledge_base_in_translate`).
- 3 existing prompt-render tests reverted to drop the `translation_facts=` kwarg.

### Kept (still useful infrastructure)

- **`code_translation/translation_facts.py`** (~330 LOC) — extractor + YAML formatter + builtin lookup helpers. Module is self-contained and preserves the no-leak invariant (`_LAYOUT_VISIBLE_FILENAMES` whitelist). Useful for future inspection scripts that need a structured view of a kernel's contract surface.
- **`code_translation/csl_builtins.yaml`** (~190 lines) — hand-curated builtin reference covering ~30 builtins. Useful for: documentation reference, future cross-check tools, debug-message enrichment. Not currently wired into the production prompt path.
- **7 of 9 `TranslationFactsTest` tests** in `test_no_compute_leak.py` — exercise the extractor, the builtins YAML, the truncation policy, the no-leak invariant on a temp dir with a canary pe.csl, the never-raises render contract, the `validate_facts_against_builtins` cross-checker. Worth keeping while the module stays.
- **`tools/ab_translation_facts.py`** — the A/B replay harness is the most reusable piece. It can re-fire ANY captured implementer prompt and structural-check the response, regardless of what's being A/B-tested. Future implementer-prompt experiments (e.g. different RAG cluster ordering, different builtin whitelist budget, different model) can reuse it by changing the `_inject_*` step.

### Test count: 70 → 68 (both pre-existing 61 and the 7 kept new tests pass)

---

## Part 5 — What this rules in / out for future work

### Rules out
- ✗ Pre-prompt augmentation in the form of a structured facts block in YAML (Phase 1 verdict).
- ✗ Pre-prompt augmentation in the form of prose mapping tables (semantic_bridge verdict, 2026-06-03).
- ✗ More-builtin-coverage variations on the same shape (no signal to chase — both arms ok in 17/19).

### Rules in (worth pursuing)
- ✓ The captured-attempt replay harness is a faster verdict tool than end-to-end sweeps. ~30 min vs days. Use it for any future prompt-shape experiment.
- ✓ The structural-class checker is a faster proxy than full cslc compile. Cheap and fires on the specific failure modes we care about.
- ✓ Reverting cleanly preserves the option to re-attach if a future model tier (or a smaller model where the RAG gotchas don't already help) shows different signal.

### Still pending (priorities unchanged from 2026-06-03)
1. **Re-run hybrid sweep** with the `run_hybrid_sweep.sh` path-bug fix (still un-rerun). Expected: clean union-pass measurement 4-6/15.
2. **Halo RAG iteration round 2** — ship the 5 missing gotchas the synthesizer flagged (static color routes, punted-fabric detector, per-PE expected_events for 2x2, diagonal-neighbor two-orthogonal, DSD-over-fn-arg-ptr).
3. **Per-fn cycle timing on BiCGSTAB** (task #11) — unlocks the "focus on the hot fn" selector signal that would help the W2 transformation gap on iterative solvers.
4. **Audit `run_cuda2csl_argo.sh`** hard-coded main-tree path (blocks future worktree-based A/B tests).

---

## Part 6 — Headline metrics (2026-06-04)

| Metric | 2026-06-03 | 2026-06-04 |
|---|---|---|
| W1 pass rate (15-failed resweep, Sonnet RAG) | 2/15 | (unchanged) |
| W1 pass rate (15-failed resweep, Opus RAG) | 4/15 | (unchanged) |
| Theoretical hybrid union ceiling | 6/15 | (unchanged) |
| Translation-facts feasibility verdict | n/a | **discard** (0W/2L/17T over 19 attempts) |
| Production prompt slots | 7 | 7 (unchanged after revert) |
| Unit tests | 61 | **68** (+7 kept facts/extractor tests) |
| Reusable harnesses for future prompt A/Bs | 1 (hybrid sweep) | **2** (+ ab_translation_facts.py) |

---

## Part 7 — Files touched today

- `code_translation/prompt_cuda2csl.py` — 3 slot insertions reverted (clean diff vs 2026-06-03).
- `code_translation/cuda2csl.py` — 5 call-site kwargs + 1 import + 1 per-kernel computation block reverted.
- `code_translation/test_no_compute_leak.py` — 2 tests pruned, 3 reverted to pre-slot form.
- `code_translation/translation_facts.py` (NEW, kept) — ~330 LOC, no production caller.
- `code_translation/csl_builtins.yaml` (NEW, kept) — ~190 lines, no production caller.
- `tools/ab_translation_facts.py` (NEW, kept) — ~310 LOC, reusable replay harness.
- `tools/ab_translation_facts_20260604.csv` — the verdict artifact (19 rows).
- `tools/ab_translation_facts_20260604.log` — full LLM-call log (~390 KB).
- `code_translation/results/progress_summary_20260604.md` — this doc.

— End of progress summary 2026-06-04 —
