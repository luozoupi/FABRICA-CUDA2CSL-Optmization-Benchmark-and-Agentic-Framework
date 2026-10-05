# Repivot — cycle reduction as the primary objective

**Date:** 2026-06-01
**Status:** decided, replaces the implicit "produce passing CSL" goal
**Owner:** xkernel agentic framework

## What changed

Until 2026-06-01 the framework was implicitly optimized for the **translation correctness** sub-problem: take CUDA source, produce CSL that compiles and matches the reference output. Five A/B sweeps and roughly 14 hours of compute confirmed that on the 5 kernels where the agent already produces working CSL, the generated kernel runs in **≤ 0.005% of the Cerebras reference's cycle count** — i.e., the agent essentially reproduces the reference, cycle-for-cycle.

Under the **actual** goal that has now been made explicit, this is a *failure case*. Reaching parity with the reference is the bare minimum the framework must clear before the work starts. The actual objective is to **strictly reduce the kernel's on-WSE cycle count** beyond the reference.

## The two workflows

### Workflow 1 — CUDA → CSL (translate, then optimize)

| Phase | Input | Output | Attempts | Termination |
|---|---|---|---|---|
| Translate | CUDA source + reference contract (entrypoint name, exported symbols, expected I/O shapes) | first compiling CSL whose benchmark passes | **5 minimum, 10 maximum** | first pass OR attempt cap |
| Optimize | the passing CSL + its cycle count as `baseline_cycles` | a CSL variant with strictly fewer cycles | **5 minimum, 10 maximum** | best-known cycle count, or attempt cap |

Total budget per kernel: 10–20 LLM-driven attempts. The framework transitions from translate → optimize **automatically** on the first benchmark pass, capturing that pass's `cycles_send` as the optimization baseline.

### Workflow 2 — Existing CSL → optimize only

| Phase | Input | Output | Attempts | Termination |
|---|---|---|---|---|
| Optimize | existing CSL + its cycle count + ONLY {input shapes, task description, expected outputs} | a CSL variant with strictly fewer cycles than the input | **5 minimum, 10 maximum** | best-known cycle count, or attempt cap |

The agent does **NOT see**:
- the reference compute file's source code
- the human's algorithmic structure (DSD layouts, fabric topology choices)
- comments from the reference bundle's README explaining the algorithm

The agent **does see**:
- the input/output tensor shapes
- a short task description ("compute y = A·x where A is M×N, distributed across PEs row-wise; result on column 0")
- the expected output's verification function (so it knows what "correct" means)
- the cycle count it has to beat

This is the harder mode because the framework cannot just look at the reference and tweak — it must understand the *task* and produce an implementation.

## Success metric

A run is **successful** iff:

1. The final variant compiles cleanly
2. Its output passes the same verification as the baseline
3. Its `cycles_send` (from `run.py`'s in-kernel `tic()/toc()` timing) is **strictly less than** the baseline `cycles_send`

Anything else is failure. In particular:
- ✗ Same cycles, "cleaner code" — not success.
- ✗ Fewer wall-clock ms but same cycles (just less harness overhead) — not success.
- ✗ Passing benchmark but no cycle reduction — not success.
- ✗ Lower cycles but wrong output — not success.

## Per-kernel scoreboard format

Each optimization run produces a row in a scoreboard:

| Kernel | Baseline cycles | Best agentic cycles | Δ | % reduction | Workflow |
|---|---:|---:|---:|---:|---|
| 7pt-Stencil | 2,129 | TBD | TBD | TBD | W1 or W2 |
| Power-Method | 4,877 | TBD | TBD | TBD | W2 |
| ... | | | | | |

A blank Δ is the honest reporting state until the run completes. A run that hits the cap without improving prints "Δ=0, no improvement". A regression (variant accepted but slower) cannot happen because the guard rejects non-improving variants.

## What the framework changes (architecture deltas)

### Code changes (planned)

| # | Component | Change |
|---|---|---|
| 74 | `benchmark_csl.py` | Parse `cycles_send` from run-step stdout into `benchmark.cycles_send` field |
| 75 | `cuda2csl.py:optimize()` | Re-target on cycles. 5–10 attempts. Hard regression guard: reject any variant whose cycles ≥ baseline. Loop continues until no improvement OR cap. |
| 75 | `prompt_cuda2csl.py:q_optimize_csl_compute` | Lead with cycle target. Remove `{reference_compute}` slot from the optimizer (was biasing to mimicry). |
| 76 | `cuda2csl.py:translate()` | On first pass, auto-transition into `optimize()` with that pass as baseline. |
| 77 | `cuda2csl.py:main()` + new flag | `--optimize-only --csl-path <file>` for workflow 2. Skips analyse + design + translate. |
| 78 | `profile_csl.py` | Surface `cycles_send` + per-PE cycle distribution into `latest_profiler_feedback` |

### Code that stays unchanged (and why)

- **Reviewer / debugger / architect agents** stay — they're useful for correctness on the translate phase. Reviewer's debug actions also serve the optimizer when a variant breaks.
- **All 5 knowledge corpora** stay — they're indexed by topic, the optimizer's queries naturally pick up DSD/streaming/comptime patterns relevant to cycle reduction.
- **Builtin whitelist** stays — anti-hallucination is orthogonal to optimization.
- **Repair loop bucket routing** stays — covers the case where an optimization attempt produces broken CSL.

### Code that gets deliberately decoupled

- **The reference compute file** is currently shown to **both** the translator AND the optimizer. After the pivot: only the translator sees it; the optimizer never does (would bias to mimicry).
- **`benchmark_csl.benchmark_translated_dir`** currently doesn't know what cycle count to report. After: returns `cycles_send` in the structured result.

## What deliberately stays the same in the goal

- **Correctness is a hard prerequisite**, not a tradeoff axis. A faster wrong answer is not a "Pareto point"; it's a regression.
- **The kernel registry** doesn't change. Workflow 2 takes a `--csl-path` that points at any CSL file; it doesn't add new kernels.
- **The 4 hard kernels** (Game-of-Life, Residual, FFT-1D-2D, Mandelbrot) stay in scope — but for those, the framework's job is to produce passing CSL first. Cycle-reduction on them is N/A until they pass.

## Concurrent work

While the pivot lands, the **debugger A/B (#72)** continues to completion on the existing endpoint — it's still useful data for correctness even though it doesn't address the new objective. After it finishes, no further correctness-focused experiments are queued.

The **4-hard-kernel re-test** (#80) runs after the new translate→optimize chain is in. Same kernels, new pipeline. Two questions:

1. Does the auto-chain to optimize() break anything in the correctness path? (Regression test)
2. Does 7pt-Stencil — the only one of the 4 that passes — get its cycles below 2129 after the optimization loop? (First evidence of the pivot working)

## Honest framing of the difficulty

Getting **any** cycle reduction below the Cerebras reference is hard. The reference is written by Cerebras engineers who understand WSE-3 deeply — DSD layout choices, microthread scheduling, fabric routing, sometimes hand-tuned at the assembly level. The LLM has none of that experience and would need to:

1. Recognize a specific micro-optimization opportunity (e.g., "this @fmacs chain can be replaced with one wider DSD op")
2. Apply it without breaking correctness
3. Verify the variant actually reduced cycles, not just shuffled code

The mesh-patterns corpus, the skills corpus, and the tutorials all contain examples of *what* an optimized CSL looks like. None of them frame those examples as "this is faster than the naive version because of X". That's a gap. The optimizer's prompt needs to be specific about *what to try* — "replace per-iteration DSD construction with @increment_dsd_offset" is a known winning pattern; "make it faster" is not.

## What "success" looks like over the next 1–2 weeks

| Milestone | Definition | Status |
|---|---|---|
| M1 — Cycles measurable | `cycles_send` lands in `benchmark.json`, surfaces in optimizer prompt | not started |
| M2 — Cycle-aware optimizer | optimize() rejects non-improving variants, loop terminates correctly | not started |
| M3 — Auto-transition | translate() → optimize() chain works without breaking correctness | not started |
| M4 — Workflow 2 | --optimize-only mode launches against a CSL file with no CUDA | not started |
| M5 — First cycle reduction | Any kernel, any model, any workflow shows cycles < baseline | unknown |
| M6 — 5-kernel scoreboard | All 5 cycle-printing kernels have a "best agentic cycles" entry, even if Δ=0 | unknown |

M1–M4 are deterministic code work, ~3 days. M5–M6 depend on the LLM actually finding optimizations — the first real measurement of whether this framework can do the harder job.

## Cost of being wrong about the goal

I spent five weeks building corpora, multi-agent routing, a whitelist, and a debugger. All of those are useful, but none of them measure cycles. The cross-everything reports I wrote celebrated parity with the reference as if it were success — it wasn't. **This doc replaces that interpretation.** The 5-corpus + 4-agent stack is the *substrate* the cycle-optimization loop runs on, not the result.
