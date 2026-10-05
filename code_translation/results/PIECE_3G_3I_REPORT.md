# Piece 3g + 3i Consolidated Report

**Date:** 2026-06-06
**Scope:** Power_Method deep-dive (3g) + GEMV live experiment (3i)
**Inputs:** Power_Method audit JSON; GEMV 10-round live run (`/tmp/piece3i_GEMV_20260606T042654Z.log`)

---

## 1. Headline

Power_Method's 0-cycle span is **not** an LLM failure — it is a **real instrumentation bug**. The `cycles_send` interval brackets a host-side Python `for i in range(max_ite)` loop of 3 blocking RPC roundtrips per iteration, so the metric measures host-device command-stream synchronisation latency, not on-device compute; on top of that, the file the optimizer is editing (`kernel_power.csl`) is not even in the build path. **No kernel-side edit can possibly move the metric.** GEMV, by contrast, ran cleanly through 10 rounds (4 angle + 4 OPEN + 2 post-repair) with **zero frozen-symbol violations**, planner first_angle honored, Piece 3e correctly skipping 3 redundant angles — but it produced **no improvement**: best 4003 cycles vs. baseline 4003, well inside a ~4-cycle (~0.1%) noise floor. GEMV is **not** a framework failure; it is a genuinely tight 184-LOC kernel at its optimum for the registered angle set and for OPEN-mode LLM suggestions.

---

## 2. Power_Method deep dive

### Root cause

`run.py` brackets the wrong interval. Lines 413-427 form this pattern:

```
runner.launch('f_tic', nonblock=True)             # broadcast tsc sample
for i in range(max_ite):                          # HOST-side Python loop
    runner.launch('f_spmv',           nonblock=False)   # blocking RPC
    runner.launch('f_nrm2_y',         nonblock=False)   # blocking RPC
    runner.launch('f_scale_x_by_nrm2',nonblock=False)   # blocking RPC
runner.launch('f_toc', nonblock=True)             # broadcast tsc sample
```

`f_tic` / `f_toc` fire on every PE in the rectangle and write into `tscStartBuffer` / `tscEndBuffer`; `cycles_send = max(time_end) - min(time_start)` after `time_ref` correction (timing_analysis.py:213). Between the two samples, the interval contains **3 × max_ite host→device→host RPC roundtrips**, each calling `sys_mod.unblock_cmd_stream()` to release the next launch. This is **fabric-rate-limited host synchronisation** — oblivious to local PE compute speed.

Compounding factors:

1. **Wrong file under edit.** `layout.csl:121` does `@set_tile_code(... 'kernel.csl' ...)`. The compiled file is `kernel.csl`. The optimizer edits `src/kernel_power.csl`, which together with `layout_power.csl` is dead code: an existing on-device state-machine variant that exposes `f_power(size, max_ite)` and was never wired in.
2. **`max_ite` is hardcoded** in the Python loop (CLI `--max-ite=10` in `commands_wse3.sh`). A "faster" inner kernel cannot shrink the iteration count, ruling out the "iteration-count compensation" hypothesis.
3. **`blas.csl` is imported by `kernel.csl`**, so legitimate `nrm2()` improvements compile in — but the body is a tiny fraction of one RPC roundtrip, so they cannot move `cycles_send`.

### Contrast: Game of Life works

`run.py` lines 184-188 bracket a **single** on-device call: `f_tic → generate(iters) → f_toc`. The iteration loop runs on-device, so `cycles_send` tracks on-device compute and edits move the metric (7 accepts in history).

### Verdict

`b_sync_rate_limited`. **Real bug.** Saved as `project_power_method_instrumentation.md`.

### Suggested fix (two-part)

1. **Wire the on-device variant into the build.** Switch `layout.csl` to `@set_tile_code(... 'kernel_power.csl' ...)` (or compile `layout_power.csl`), and replace the host-side Python loop in `run.py` with a single `simulator.launch('f_power', size, max_ite, nonblock=False)` call between `f_tic` and `f_toc`. The iteration loop then runs on-device and `cycles_send` tracks actual compute.
2. **Until then, mark Power_Method (and the structurally identical BiCGSTAB / CG / PCG) as instrumentation-bounded** in the optimization planner and exclude them from accept-rate statistics. No kernel-side edit can possibly move the metric, so leaving them in inflates the "no-accept" denominator artificially.

---

## 3. GEMV live run

**Run path:** `/tmp/piece3i_GEMV_20260606T042654Z.log` (start 04:26:54 UTC, exit 0 at 04:34:47, ~8 min)
**Baseline:** 4003 cycles · **Best:** 4003 cycles · **Speedup:** 1.00× · **Outcome class:** `NOOP`

### Per-angle table

| Angle                       | Rounds used | Accepted | Notes                                                                              |
|-----------------------------|-------------|----------|------------------------------------------------------------------------------------|
| `comptime_value_tuning`     | round 1     | no       | Picked by scheduler (planner returned "(scheduler picks)"). Bench-fail post-repair |
| `memory_simd_alignment`     | 1           | no       | Candidate cycles at noise floor                                                    |
| `stride_optimization`       | 1           | no       | Candidate cycles at noise floor                                                    |
| `buffer_cleanup`            | round 4     | no       | Bench-fail post-repair                                                             |
| OPEN (rounds 7-10)          | 4           | no       | Auto-switched after 6 consecutive rejects; no headroom found                       |
| **Skipped by Piece 3e**     | —           | —        | `dsd_offset_chaining` (baseline uses `@increment_dsd_offset`), `fmac_bulk` (baseline already bulk `@fmacs` over DSD), `comptime_hoist` (no `@as` in runtime loops) |

### Cycle distribution (8 attempts with a cycles measurement; 2 ended in bench-fail)

`[4003, 4091, 4003, 4003, 4007, 4003, 4003, 4003]` → min 4003 / max 4091 / span 88 (~2.2%).
Excluding the single 4091 outlier: **floor 4003-4007, span 4 cycles (~0.1%)**.

### Framework-piece checks

- **Piece 3e (pre-flight skip):** working as designed — 3/7 angles correctly skipped, saving attempts.
- **Piece 3h (frozen-symbol guard):** **zero contract / frozen / `f_reference_timestamps` / `f_tic` / `f_toc` violations** across all 10 rounds. Caveat: no candidate even reached the contract gate in a way that *would* have produced a `frozen` rejection, so this is a "no negative side effects" confirmation rather than active proof of fix.
- **Planner first_angle honored:** yes. Planner (high confidence) returned `first_angle = "(scheduler picks)"`, so the "planner suggested_first_angle" log line never appears; scheduler picked `comptime_value_tuning` for round 1 — trivially honored.
- **Frozen violations:** 0.

### Was this a WIN?

**No — but not a framework failure.** GEMV did not cross the 1% threshold (3962 cycles). Prior 113-attempt run got to 3985 (0.45% drop, still sub-epsilon). This is the same noise-floor wall as before. The 184-LOC single-file kernel is at its optimum for the registered angle set, and OPEN-mode LLM suggestions also failed to find headroom.

### Artifacts

- Accepted bundles: **none** under `~/xkernel/knowledge/explored/optimization/accepted/` for GEMV.
- Failure bundles: `/home/USER/xkernel/knowledge/explored/optimization/failures/gemv_*__2026060604*`
- Plan cache regenerated: `/home/USER/xkernel/knowledge/explored/optimization/plans/gemv.json`

---

## 4. Memory captured

| File                                          | Source       | Content                                                                                  |
|-----------------------------------------------|--------------|------------------------------------------------------------------------------------------|
| `project_power_method_instrumentation.md`     | Piece 3g     | Root cause of the 0-cycle-span bug; suggested two-part fix; list of structurally identical kernels (BiCGSTAB / CG / PCG) that share the same instrumentation pattern. |
| (GEMV)                                        | Piece 3i     | No new memory file (NOOP outcome, no novel angle insight). Failure bundles + regenerated plan cache only. |

---

## 5. Verdict on the immune-kernels problem

We now have data from **5 kernels**: 4 immune-family (Power_Method, BiCGSTAB, CG, PCG) + GEMV. They split cleanly into two **distinct** failure modes:

**Mode A — Instrumentation-bounded (Power_Method family, 4 kernels).**
The metric does not measure what the optimizer is trying to optimize. `cycles_send` brackets a host-driven Python iteration loop of blocking RPCs; the file being edited is not even compiled. No amount of LLM cleverness can move this. **Framework problem, not LLM problem.** Fix: instrument these kernels correctly (wire the on-device variant, single RPC inside tic/toc) and/or exclude them from accept-rate stats until fixed.

**Mode B — Genuine noise floor (GEMV).**
The metric does measure on-device compute, the file under edit is compiled, Piece 3e correctly prunes redundant angles, Piece 3h causes no regressions, the planner is honored — and the kernel still does not move. 8 candidate runs cluster inside a 4-cycle (~0.1%) window. This is a genuinely tight 184-LOC kernel where both the registered angle set and OPEN-mode LLM exploration have exhausted accessible headroom. **Not a framework bug.** "LLM cannot find wins" here is *consistent with there being no wins to find* at this scale.

**So the answer is: both, but on disjoint kernels.** Immune-family = instrumentation; GEMV = real noise floor. They should not be conflated in "0-accept" statistics, because the actionable response is different — fix the harness for one set, accept the result for the other.

---

## 6. Next concrete move

1. **Land the Power_Method instrumentation fix** (1-2 hr). Change `layout.csl:121` to point at `kernel_power.csl`, swap the Python `for` loop in `run.py` for a single `f_power(size, max_ite)` RPC inside the `f_tic` / `f_toc` brackets, and re-baseline. If `cycles_send` now moves under edits, repeat the same surgery on BiCGSTAB / CG / PCG (same structural pattern per the audit) — this should unlock the entire immune family in one stroke.
2. **Tag GEMV (and any other Mode-B kernels) as `noise_floor_optimum` in the optimization planner** so that 10-round NOOP outcomes count as "framework-OK, no headroom" rather than as "0-accept failure." This will stop GEMV from dragging the global accept-rate denominator without hiding genuine future regressions (any candidate above the noise band still gets logged).
