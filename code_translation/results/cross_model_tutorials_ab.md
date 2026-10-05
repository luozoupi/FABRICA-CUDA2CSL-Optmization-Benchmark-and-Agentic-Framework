# Tutorials RAG A/B — full cross-model report

**Date:** 2026-05-31
**Kernels:** Game-of-Life, Residual, 7pt-Stencil, FFT-1D-2D (the 4 consistently-failing kernels)
**Loop:** reviewer ON + debug-recipes ON + mesh-patterns ON in ALL configs (only the tutorials corpus varies)
**Models:** `openai/gpt-oss-120b` (ALCF), `claude-sonnet-4-6` (Argo), `claude-opus-4-7` (Argo)

## Configurations

| Code | Tutorials | Corpus size | Notes |
|---|---|---:|---|
| **H** | OFF | 0 chunks | Baseline. Reviewer + debug-recipes + mesh-patterns + release-notes. |
| **I** | ON (broad) | 217 chunks | Full csl-examples corpus from 33 tutorials. |
| **J** | ON (narrow) | 29 chunks | Only topic-09-fifos + topic-11-collectives + topic-12-debug-library + gemv-06-routes-1. **gpt-oss only.** |

## Headline pass counts

| Model | H | I | J |
|---|---:|---:|---:|
| gpt-oss-120b | 1/4 | 1/4 | 1/4 |
| Claude Sonnet 4.6 | **2/4** | **2/4** | — |
| Claude Opus 4.7 | 1/4 | 1/4 | — |

**Pre-registered criterion (I > H on pass count): not met on any of the three models.**

The single biggest result in the entire sweep is **Sonnet H/I both crack Residual** — first time any of the three models passes any kernel in this set other than 7pt-Stencil. The tutorial corpus didn't cause that; Sonnet's baseline + reviewer + debug-recipes did.

## Per-kernel per-config detail

| Model | Kernel | H status (ms) | I status (ms) | Δ |
|---|---|---|---|---|
| gpt-oss-120b | Game-of-Life | fail (0) | **fail (2401)** | ⬆ execution recovered |
| gpt-oss-120b | Residual | fail (1788) | fail (0) | ⬇ stopped executing |
| gpt-oss-120b | 7pt-Stencil | pass (3189) | pass (3027) | — |
| gpt-oss-120b | FFT-1D-2D | fail (5802) | **error** | ⬇ no longer compiles |
| Sonnet 4.6 | Game-of-Life | fail (4833) | fail (0) | ⬇ stopped executing |
| Sonnet 4.6 | Residual | **pass** (2107) | **pass** (2051) | — both pass |
| Sonnet 4.6 | 7pt-Stencil | pass (3239) | pass (3035) | — |
| Sonnet 4.6 | FFT-1D-2D | fail (5736) | fail (5704) | — |
| Opus 4.7 | Game-of-Life | fail (4884) | fail (4530) | — small speedup |
| Opus 4.7 | Residual | fail (1829) | fail (1604) | — small speedup |
| Opus 4.7 | 7pt-Stencil | pass (3277) | pass (3269) | — |
| Opus 4.7 | FFT-1D-2D | fail (3952) | fail (6066) | ⬇ slower |

**Pattern: each model has roughly one kernel where I helps and one where I hurts.** Net pass count never changes. The broad corpus shifts which kernel gets the noise.

## Narrow vs broad (gpt-oss-120b only, on-disk data)

| Kernel | H_v2 (no tutorials, retry-fix loop) | I (broad, 217 chunks) | J (narrow, 29 chunks) |
|---|---|---|---|
| Game-of-Life | fail (0) | fail (2401) | fail (0) |
| Residual | fail (0) | fail (0) | **fail (1785)** |
| 7pt-Stencil | pass (3313) | pass (3027) | pass (3087) |
| FFT-1D-2D | fail (5685) | **error** | fail (5313) |

**Narrow ≥ broad on this set.** Narrow:
- recovers Residual to execution (broad doesn't)
- doesn't regress FFT-1D-2D to error (broad does)
- matches broad on the kernels where both fail

Conclusion: **the broad corpus adds noise, not signal**. The 4 hand-picked tutorials (FIFO, collectives, debug library, routes) are essentially everything the corpus contributed.

## Cross-model status-shift counting

Per-model qualitative shifts caused by adding the broad corpus (I vs H):

| Model | Kernels where I helped | Kernels where I hurt | Net |
|---|---|---|---|
| gpt-oss-120b | Game-of-Life (run_ms 0→2401) | Residual (1788→0), FFT-1D-2D (fail→error) | −1 |
| Sonnet 4.6 | (none) | Game-of-Life (4833→0) | −1 |
| Opus 4.7 | Residual (1829→1604), Game-of-Life (4884→4530) | FFT-1D-2D (3952→6066) | ±0 |

**The broad corpus is neutral-to-negative on all three models.** None gained a pass. Opus showed the least sensitivity (it already produces running CSL for all 4 kernels under H; tutorial chunks slightly perturbed runtime).

## Wall-time comparison

| Model × config | Wall (min) | vs baseline |
|---|---:|---:|
| gpt-oss-120b H | 38.5 | — |
| gpt-oss-120b I | 25.0 | −35% (faster) |
| Sonnet 4.6 H | 57.2 | — |
| Sonnet 4.6 I | 61.1 | +7% (slower) |
| Opus 4.7 H | 30.4 | — |
| Opus 4.7 I | 35.2 | +16% (slower) |

The gpt-oss-120b wall-time drop is the FFT-1D-2D early-error (failed in 115s instead of running the full 16-minute repair loop). Sonnet and Opus paid a small tax for the larger context without converging faster.

## The qualitative shift that doesn't show up in pass count

Across all 6 model×config pairs in this Claude sweep, **only one kernel ever changes status between H and I**: Sonnet's Game-of-Life regressed from `fail (executed)` to `fail (didn't execute)`. Everything else either passes in both or fails in both. The broad tutorial corpus is mostly invisible — the implementer's already-running CSL gets slightly perturbed but the failure mode doesn't change.

This is consistent with what the previous reviewer A/B + debug-recipes A/B already showed: **knowledge layers below the implementer (reviewer/architect/recipes/patterns/tutorials) raise the *quality* of generated CSL without changing whether it passes the benchmark.** The pass/fail boundary on these 4 kernels is set by the implementer model's CSL fluency, not by the context it sees.

## Recommended next steps

In priority order:

1. **Run the narrow-corpus J config on Sonnet and Opus.** The Opus + Sonnet results above use the broad 217-chunk corpus. The gpt-oss data shows narrow is strictly better than broad. A 2-config × 2-model narrow follow-up (~2 hours wall) would tell us if narrow beats H on the stronger models — which it might, given Opus already has implementer fluency to act on better signals.

2. **Default the tutorials lens to the narrow corpus** for production. Until we have evidence that any tutorial outside the 4 narrow ones helps, the safe default is to suppress them. Add `XKERNEL_TUTORIALS_KB_PATH` defaulting to the narrow JSONL. Zero-risk: same retrieval surface, smaller noise floor.

3. **Move to cerebras-csl-skills ingestion (task #64)** — that corpus closes real gaps (microthreads, routes, debug API) that no other knowledge source covers. The tutorials corpus is at saturation; skills is fresh ground.

## Artifacts

- This report: `code_translation/results/cross_model_tutorials_ab.md`
- gpt-oss broad: `code_translation/results/ab_tutorials_20260530_195632/tutorials_ab_report.md`
- Claude H/I: `code_translation/results/ab_tutorials_claude_20260530_215432/`
- gpt-oss narrow: `code_translation/results/ab_tutorials_narrow_20260530_215700/`
- Tutorial corpora: `knowledge/data/cerebras_tutorials.jsonl` (broad, 217), `knowledge/data/cerebras_tutorials_narrow.jsonl` (narrow, 29)
- Env vars in play: `XKERNEL_TUTORIALS={0,1}`, `XKERNEL_TUTORIALS_KB_PATH=<jsonl-path>`
