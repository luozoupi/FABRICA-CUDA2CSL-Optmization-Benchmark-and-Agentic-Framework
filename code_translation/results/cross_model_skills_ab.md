# Cross-model skills A/B — gpt-oss-120b + Sonnet 4.6 + Opus 4.7

**Date:** 2026-05-31
**Kernels:** Game-of-Life, Residual, 7pt-Stencil, FFT-1D-2D (the 4 consistently-failing kernels)
**Skills corpus:** 328 chunks (architect 53 / implementer 202 / reviewer 73), per-audience dispatch via section filter
**Tutorials baseline (constant across configs):** narrow corpus, 29 chunks (best per prior tutorials A/B)

## Configurations

| Code | XKERNEL_SKILLS | Tutorials | Notes |
|---|---|---|---|
| **K** | 0 | narrow (29 chunks) | Baseline. All other layers ON (reviewer + debug-recipes + mesh + release-notes). |
| **L** | 1 | narrow (29 chunks) | Skills layer added on top of K. |

## Headline pass counts

| Model | K (skills OFF) | L (skills ON) | Δ |
|---|---:|---:|---|
| gpt-oss-120b | 1/4 | 1/4 | 0 |
| Claude Sonnet 4.6 | 1/4 | 1/4 | 0 |
| Claude Opus 4.7 | 1/4 | 1/4 | 0 |

**No pass-count change on any model. Skills corpus does not move the needle.**

## Per-kernel detail

### gpt-oss-120b (from `ab_skills_20260531_011246/`)

| Kernel | K | L |
|---|---|---|
| Game-of-Life | fail (0 ms) | fail (0 ms) |
| Residual | fail (0 ms) | fail (0 ms) |
| 7pt-Stencil | **pass** (3346 ms) | **pass** (3338 ms) |
| FFT-1D-2D | fail (3933 ms) | fail (3883 ms) |

### Sonnet 4.6 (from `ab_skills_claude_20260531_043333/sonnet_*`)

| Kernel | K | L |
|---|---|---|
| Game-of-Life | fail (0 ms) | fail (4458 ms) |
| Residual | fail (1861 ms) | **timeout** |
| 7pt-Stencil | **pass** (3356 ms) | **pass** (3357 ms) |
| FFT-1D-2D | **timeout** | fail (5468 ms) |

### Opus 4.7 (from `ab_skills_claude_20260531_043333/opus_*`)

| Kernel | K | L |
|---|---|---|
| Game-of-Life | fail (4812 ms) | fail (4519 ms) |
| Residual | fail (1456 ms) | **timeout** |
| 7pt-Stencil | **pass** (3055 ms) | **pass** (3290 ms) |
| FFT-1D-2D | fail (3951 ms) | fail (6016 ms) |

## Wall time

| Model × config | Wall (min) | Δ vs K |
|---|---:|---:|
| gpt-oss K | 33.0 | — |
| gpt-oss L | 41.8 | +27% |
| Sonnet K | 63.0 | — |
| Sonnet L | 74.5 | +18% |
| Opus K | 50.0 | — |
| Opus L | 54.7 | +9% |

Skills-ON consistently costs wall time (more context, longer repair loops). Effect strongest on gpt-oss, smallest on Opus.

## Observed status flips

Across the 12 kernel×model points in the A/B, skills flipped the qualitative status (fail/pass/timeout/exec) on **5 of 12** points — but always sideways (fail→timeout, no-exec→exec, etc.), never to pass:

| Model | Kernel | K → L flip |
|---|---|---|
| Sonnet | Game-of-Life | fail (0 ms) → fail (executed, 4458 ms) |
| Sonnet | Residual | fail (executed, 1861 ms) → timeout |
| Sonnet | FFT-1D-2D | timeout → fail (executed, 5468 ms) |
| Opus | Residual | fail (executed, 1456 ms) → timeout |
| Opus | FFT-1D-2D | fail (3951 ms) → fail (6016 ms, slower) |

Pattern: skills-ON tends to push runs toward execution (Sonnet's Game-of-Life and FFT-1D-2D got further), but at the cost of timeouts on Residual (both Sonnet and Opus). Net pass count: unchanged.

## Run-to-run variance is significant

Pre-skills sweeps had **Sonnet at 2/4** (Residual + 7pt-Stencil). Today's K config (intended to be a baseline equivalent to those earlier sweeps) lands at **1/4** — Residual fails. The reviewer/architect/implementer stack is the same, the seeds aren't fixed (LLM stochasticity), and what looks like a "ceiling" is actually a noisy plateau where pass count can drift by ±1 across nominally-identical runs.

**This is the most important meta-finding of the entire corpus-experiment series.** Single-point A/B comparisons on 4 kernels × 1 model × 1 config don't have the statistical power to detect anything smaller than ±1 pass. Future experiments need either (a) replication (≥3 runs per config) or (b) larger kernel sets, or (c) acceptance that we're measuring qualitative shifts (status flips, attempt-quality, citation evidence) not pass count.

## What the corpus-stack saturation looks like

| Corpus added | gpt-oss-120b Δpass | Sonnet Δpass | Opus Δpass |
|---|---:|---:|---:|
| Mesh patterns (8 patterns) | 0 | 0 | 0 |
| Tutorials broad (217 chunks) | 0 | 0 | 0 |
| Tutorials narrow (29 chunks) | 0 | — | — |
| **Skills (328 chunks)** | **0** | **0** | **0** |

Four independent corpora landed across 3 frontier models. Zero pass-count deltas. The corpus stack is fully saturated on this kernel set.

## What changes the picture

The skills A/B closes the corpus-stacking phase of the project. The next ground to break is **not more knowledge** but interventions one level up:

1. **Hard whitelist of @-builtins in the implementer prompt** (#69, landed today). Smoke evidence shows it stopped `@my_pe_x` hallucinations entirely on gpt-oss-120b. Cross-model A/B running (#71).
2. **Dedicated debugger sub-agent** with structured-JSON diagnosis (#70, landed today, behind `XKERNEL_DEBUGGER=0` by default). Reviewer produces good debug actions; implementer ignores them; debugger forces them into a slot the implementer is told to apply verbatim.
3. **Replication for variance estimation** — run a single config 5 times back-to-back to get a true noise floor before claiming any ±1 shift is meaningful.

## Artifacts

- This report: `code_translation/results/cross_model_skills_ab.md`
- gpt-oss data: `code_translation/results/ab_skills_20260531_011246/`
- Claude data: `code_translation/results/ab_skills_claude_20260531_043333/`
- Skills corpus: `knowledge/data/cerebras_skills.jsonl` (328 chunks, 443 KB)
- Skills ingestion: `knowledge/ingest_skills.py`
- Lens wiring: `code_translation/csl_knowledge_base.py:skills_context()` + 3-lens injection
- Env vars: `XKERNEL_SKILLS={0,1}`, `XKERNEL_SKILLS_KB_PATH=<jsonl-path>`
