# Mined-gotcha A/B validation — report (2026-06-18)

This session mined 2 CSL gotchas from real compiler failures and added an
instrument_kernel.py prompt section. This report records how each was validated
and the honest verdict for each.

## Background: which workflow each gotcha targets

W1 translate (`cuda2csl.py`) gives the implementer a FIXED reference
`layout.csl` and asks it to write ONLY the compute file. So gotchas about
*adding host-visible exports* or *adding timing* are **inert for W1** — they
only fire in the instrumentation / explore workflows, where the agent writes
the layout. A generic W1 ablation sweep (`run_baseline_ablation_sweep.sh`)
would therefore show **zero** signal for these two gotchas *by construction*;
the meaningful A/B is the instrumenter pass-rate. (See memory
`project-mined-gotchas-validation-scope`.)

## Gotcha 1 — `@export_symbol` ↔ `@export_name` pairing  (VALIDATED, high confidence)

Root cause was a **deterministic framework bug**, not a probabilistic prompt
nudge: `instrument_kernel.py` hardcoded the layout filename as `layout.csl`,
so on bundles whose layout is `code.csl` (Wide Multiplication, Mandelbrot,
Histogram) the `@export_name` additions were written to a non-existent file and
the LLM was shown "(no layout.csl)".

A/B (natural, this session):
- BEFORE fix: Wide Multiplication FAILED — `name 'time_buf_u16' was not
  declared during layout evaluation`.
- AFTER `_find_layout_file` + the mined gotcha: Wide Multiplication PASSED
  (cycles_send=81739), wrote pe.csl + run.py + **code.csl** correctly.

Verdict: **KEEP.** A wrong-filename bug fixed deterministically; the fail→pass
flip is causal, not noise. `_find_layout_file` also fixed Residual and
GEMV-Collectives-2D instrumentation.

## Gotcha 2 — multi-PE timestamp-D2H stall / per-PE unblock  (INCONCLUSIVE)

Mined from the first multi-PE instrument batch (4/5 stalled with
`received length N not expected M, could be a kernel stall`). Added as a KB
gotcha (halo cluster) AND as a `_MULTIPE_PROMPT_BLOCK` section in
instrument_kernel.py, gated by `XKERNEL_MULTIPE_PROMPT` for A/B.

Controlled A/B (GEMV Collectives 2D, a real multi-PE *verifying* kernel,
fresh bundle per trial from git HEAD, model = claude-opus-4-7, N=3/arm):

| Arm | multi-PE prompt | pass rate | cycles (passes) |
|-----|-----------------|-----------|-----------------|
| A | OFF (`XKERNEL_MULTIPE_PROMPT=0`) | **3/3** | 4007, 3999, 3999 |
| B | ON  (default) | **3/3** | 4003, 4003, 3999 |

Verdict: **NO MEASURABLE LIFT on this kernel.** Opus 4.7 instruments GEMV
Collectives 2D correctly with or without the prompt section. The kernels the
section *would* discriminate on (Laplacian2D-Reduce, LorenzoPredictor-Tile)
are skeletons (run.py `VERIFY=False`) that fail for unrelated reasons, so they
can't serve as a clean A/B. The prompt section is **kept as documentation**
(it encodes a correct recipe and can't hurt) but is **NOT validated as a
pass-rate lever** on the currently-available kernel set. Honest status:
unproven, not disproven.

## Method notes
- A/B gate for KB gotchas: `XKERNEL_MINED_GOTCHAS` (0/1) — toggles both mined
  gotchas in `_filter_w1_gotchas_for_clusters`. Unit-verified (present when ON,
  absent when OFF, per cluster).
- A/B gate for the instrumenter prompt: `XKERNEL_MULTIPE_PROMPT` (0/1).
- Noise floor caveat (from V1_0 docs): single-kernel single-run deltas are
  noise; keep only on ≥2-kernel or multi-rep lift. Gotcha 2 shows 0 delta over
  3 reps → no claim.

## Bottom line
The session's durable W1/instrumentation win is the **deterministic
`_find_layout_file` fix** (+ the translation_facts truncation reorder that
keeps the collectives note from being evicted by timing boilerplate). The
prose gotchas are correct and retained, but only Gotcha 1 has causal evidence;
Gotcha 2 is documentation pending a discriminating non-skeleton multi-PE kernel.
