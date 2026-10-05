# Agentic sweep: the three newly-enabled kernels (2026-08-07)

First results for three kernels that produced none before 2026-08-06. See
[`EXCLUDED_TASKS_AUDIT_20260806.md`](EXCLUDED_TASKS_AUDIT_20260806.md) for why
each was unavailable and what was fixed.

Data: `docs/data/newly_enabled_sweep.csv`
Raw: `code_translation/results/newly_enabled_sweep_20260806_211740/`
Script: `run_newly_enabled_sweep.sh`

## Configuration

| Parameter | Value |
|---|---|
| Model | `claude-opus-4-8` (Anthropic API directly, not the argo-shim proxy) |
| Launcher | `run_cuda2csl_anthropic.sh` |
| Reviewer / optimizer cap | 10 (min optimize 4) |
| Seeds | 3 per kernel |
| Gates | template-gen + the standard knowledge stack, matching the 46-kernel template sweep |
| Metric | `cycles_send`, SDK 1.4.0 local simulator |

The framework's `llm_complete()` sends only `model`/`max_tokens`/`messages`/
`system` for Anthropic models — no `temperature`, `top_p`, `top_k`, or
`thinking.budget_tokens`, all of which return 400 on Opus 4.7+. Adaptive
thinking is therefore off, matching how the earlier argo-shim sweeps ran.

## Results

| Kernel | Seed | Status | Agent cycles | Reference | Speedup |
|---|---:|---|---:|---:|---:|
| GEMM-1PE | 1 | PASS | 16,318 | 119,197 | 7.30x |
| GEMM-1PE | 2 | PASS | 13,867 | 119,197 | 8.60x |
| GEMM-1PE | 3 | PASS | 16,800 | 119,197 | 7.10x |
| Laplacian2D-Reduce | 1 | PASS | 763 | 1,950 | 2.56x |
| Laplacian2D-Reduce | 2 | PASS | 1,698 | 1,950 | 1.15x |
| Laplacian2D-Reduce | 3 | PASS | 1,013 | 1,950 | 1.92x |
| LorenzoPredictor-Tile | 1 | PASS | 575 | 1,315 | 2.29x |
| LorenzoPredictor-Tile | 2 | FAIL | — | 1,315 | — |
| LorenzoPredictor-Tile | 3 | PASS | 542 | 1,315 | 2.43x |

### Per kernel

| Kernel | Pass rate | Speedup geomean | Spread |
|---|---|---:|---|
| GEMM-1PE | **3/3** | **7.64x** | 7.10 – 8.60 (tight) |
| Laplacian2D-Reduce | **3/3** | 1.78x | 1.15 – 2.56 (wide) |
| LorenzoPredictor-Tile | **2/3** | 2.36x | 2.29 – 2.43 (tight) |
| **Total** | **8/9 (89%)** | — | every pass beat the reference |

## How much weight each result carries

These are **not** equally strong claims, and the difference matters.

**GEMM-1PE — the strongest.** Its 119,197-cycle reference was authored and
validated on 2026-06-24, independent of this session, and the kernel is a
TEST-split, deliberately leak-free hand-written dense matmul (`spec.yaml`:
"the SIMPLE counterpart to the collective SUMMA GEMM (no library, no
decomposition)"). Three seeds land in a tight 7.10–8.60x band. Nothing about
this kernel was touched this session — it was fully scoreable for six weeks and
simply never appeared in a sweep list.

**Laplacian2D-Reduce and LorenzoPredictor-Tile — weaker, by construction.**
Both kernels were repaired *and* had their references generated on 2026-08-06,
hours before the sweep. The references are verified — exact (0.0 error) for
Laplacian2D-Reduce and ≤9.5e-7 for LorenzoPredictor-Tile, on the train seed and
all three held-out seeds — but they have not had the scrutiny a six-week-old
baseline has. Beating a same-day reference is a softer claim than beating an
established one, and should be labelled as such.

**Laplacian2D-Reduce's spread is wide** (1.15x to 2.56x, a 2.2x range across
three seeds). Quote its geomean, not its best draw.

**The single failure is honest variance.** LorenzoPredictor-Tile passed on
seeds 1 and 3 with near-identical cycles (575, 542); seed 2 failed outright.
That is the fragile-kernel behaviour seen throughout this benchmark, not a
harness problem.

## Hardware caveat

Every number here is an SDK 1.4.0 **simulator** measurement. The paired
hardware study ([`HW_VS_SIM_20260806.md`](HW_VS_SIM_20260806.md)) finds
simulator and silicon agree within a few percent in aggregate, but with
per-kernel scatter — and it did not cover these three kernels, which were
enabled after the template sweep whose artifacts it replays. Their speedups
have not been confirmed on hardware.
