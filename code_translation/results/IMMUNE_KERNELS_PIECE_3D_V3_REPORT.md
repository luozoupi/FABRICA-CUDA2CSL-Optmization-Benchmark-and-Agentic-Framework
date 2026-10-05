# Immune Kernels — Piece 3D, Attempt 3 Report

## 1. Headline

- **Attempt 1**: 0/4 unblocked, 0/4 won — planner emitted `len==1` `focus_files`, so `_is_multifile` never fired and the multi-file pipeline was effectively dead code.
- **Attempt 2**: 3/4 unblocked, 0/4 won — planner + prompt fix opened the multi-file path, but three downstream bugs (focus truncation, missing-file firewall too strict, no aux persistence) kept proposals from reaching the benchmark cleanly.
- **Attempt 3 (this run)**: **4/4 unblocked, 0/4 won** — every kernel reached the benchmark via the multi-file path with zero contract/missing-focus/compile rejections; all rejections were noise-floor "no-improvement" calls, meaning the plumbing is healthy but the LLM produced no >1% speedups on these kernels.

> Note on the BiCGSTAB input: the supplied note described a forced-early termination of the reporting agent, not the kernel run itself. The `DONE` marker `/tmp/piece3d_v3_BiCGSTAB_DONE.txt` is now present and the log `/tmp/piece3d_v3_BiCGSTAB_20260605T232125Z.log` shows the run finished cleanly at 23:32:19 UTC with baseline=69217, 3 rounds, 0 accepts, the planner emitting `focus=['src/kernel_bicgstab.csl', 'src/blas.csl']`, and the omit-as-unchanged log line firing in rounds 1 and 2. So BiCGSTAB is reclassified UNBLOCK, not ERROR, and the headline is 4/4 unblocked.

## 2. Per-kernel results

| Kernel | Baseline cyc | Best cyc | Speedup | Multi-file fired | blas.csl reached bench | Outcome |
|---|---:|---:|---:|:---:|:---:|---|
| BiCGSTAB | 69217 | 69217 (no accept) | 1.0000x | yes | no (LLM omitted) | UNBLOCK |
| Conjugate_Gradient | 14958 | 14957 | 1.0001x | yes | no (LLM omitted) | UNBLOCK (NOOP) |
| Preconditioned_CG | 17199 | 17197 | 1.0001x | yes | no (LLM omitted) | UNBLOCK |
| Power_Method | 47402 | 47402 | 1.0000x | yes | no (LLM omitted) | UNBLOCK |

In all four runs the planner emitted a 2-element focus list `[src/kernel_*.csl, src/blas.csl]`, the multi-file branch executed in every named-angle round, auto-mode kicked OPEN after 2 consecutive rejects, and the only rejection reason was no-improvement vs the 1.01x epsilon threshold. No contract / missing-focus / compile rejections appeared in any of the four logs.

## 3. What the three bug fixes unlocked

**Fix #1 — focus-clip / truncation.** Confirmed indirectly across all four kernels: `kernel_*.csl` files reached the LLM intact (edits compiled and benched in CG/PCG/Power), and the larger `blas.csl` was exposed without warnings. The previous attempt's "focus truncation" failure mode did not appear in any of the four logs.

**Fix #2 — omit-as-unchanged firewall.** Verified live on every kernel. The log line `multi-file: 1/2 focus files unchanged (omitted by LLM, treated as no-op): ['src/blas.csl']` (optimize_explore.py:1183) fired in:
- BiCGSTAB rounds 1, 2
- Conjugate_Gradient rounds 1, 2
- Preconditioned_CG rounds 1, 2
- Power_Method rounds 1, 2

Compare against the Attempt-2 failure signature `multi-file reply missing focus files: ['src/blas.csl']`, which is visible in the prior 20260605T231157Z experience row but has zero occurrences this run. The firewall now treats LLM-omitted focus files as "preserve current state" rather than rejecting the candidate, which is exactly what unblocks the pipeline for kernels where the LLM has no useful edit to make on the aux file.

**Fix #3 — aux persistence in `failures/<slug>/`.** **Not exercised by live data.** The code path is wired (knowledge_persistence.py:442-447 `record_optimization(extra_files=...)`; ACCEPT-side multi-file path at optimize_explore.py:1281-1299 passes `aux_extras` correctly), but the LLM declined to edit `blas.csl` in any of the 11 multi-file rounds across the four kernels. Every failure bundle in `/home/USER/xkernel/knowledge/explored/optimization/failures/{bicgstab,conjugate_gradient,preconditioned_cg,power_method}_*__20260605T*Z/` therefore contains only `error_log.txt` + `last_pe.csl` — there is no `blas.csl` to persist. Additionally, a code audit shows the REJECT path at optimize_explore.py:2204 does not pass `extra_files=bench_files`, so even if the LLM had edited `blas.csl` and the candidate were rejected, the failure bundle would still miss the aux file. **This is a latent gap that fix #3 does not actually close on the reject path.**

## 4. What is still preventing wins

Pipeline mechanics are healthy on this run; the cause of 0/4 wins is upstream of the orchestrator. Ranked by evidence:

1. **Most likely: the LLM doesn't see a real optimization target on these BLAS-heavy iterative solvers.** In all four kernels the LLM emitted `kernel_*.csl` edits only and left `blas.csl` untouched. For CG the round-3 OPEN-mode attempt restructured the state machine (introduced `STATE_FUSED_REDUCE` plus a 3-element `fused_red` reduce buffer) — a substantive rewrite that compiled and benched — yet only shaved 1 cycle off 14958 (1.000067x). For PCG the LLM rewrote kernel_pcg.csl from 445→365 lines and still only landed 2 cycles below baseline. That pattern says the candidates are *plausible* but not *winning*, which points at the LLM's WSE-3 micro-arch understanding (or the angle catalog's coverage) rather than any pipeline bug.

2. **Noise-floor / epsilon ceiling.** All four best_speedups (1.000067x, 1.000116x, 1.0000x, 1.0000x) land between 0 and 1 cycle of measurement noise. Baseline `sigma=2.36` for BiCGSTAB → 2σ/median ≈ 0.0001, well below the 0.01 epsilon. The epsilon is appropriately set; the candidates simply aren't moving the needle.

3. **Angle catalog is exhausted for these shapes.** Pre-flight already pruned `fmac_bulk` (baseline already uses bulk @fmacs over DSD) and `comptime_hoist` (no @as casts in runtime loops) on BiCGSTAB, leaving 7 active angles. The two named angles auto-mode actually selected (`comptime_value_tuning`, `iterative_phase_fusion`) are the LLM's "safe" defaults and neither produced an edit substantive enough to bend the cycle curve. The remaining 5 angles (dsd_offset_chaining, async_detach_overlap, task_chaining_unblock_activate, prefetch_fabric_async, buffer_cleanup) were never tried because auto-mode forces OPEN after 2 consecutive rejects.

4. **Auto-mode round budget too small.** 3 rounds with auto-OPEN after 2 rejects means only 2 named-angle attempts per kernel before the pipeline gives up on the catalog. With 7 active angles per kernel this samples ~28% of the angle space and never gets to the more invasive angles (async_detach_overlap, task_chaining_unblock_activate, prefetch_fabric_async) that are most likely to actually shift cycles on iterative solvers.

5. **BLAS file is already near-optimal for these problem sizes.** PCG's report explicitly notes "the LLM not finding meaningful optimizations on this near-baseline kernel rather than any pipeline bug" — i.e. blas.csl was hand-tuned, and the orchestrator note for CG observes "the BLAS @fmacs are bulk-DSD already." If the aux file is already at the cycle floor, the planner should drop it from focus and free the round budget for kernel-only experiments.

## 5. Recommended next move

1. **Increase the named-angle budget and force coverage of the unsampled angles.** Bump `--n-rounds` from 3 → 6-8 and either disable auto-OPEN until the named-angle catalog is exhausted, or raise the consecutive-reject threshold from 2 → 4. The five never-tried angles (`dsd_offset_chaining`, `async_detach_overlap`, `task_chaining_unblock_activate`, `prefetch_fabric_async`, `buffer_cleanup`) are exactly the ones with structural reordering potential on iterative solvers and should be sampled before declaring the kernel "no-improvement."

2. **Teach the planner to drop `blas.csl` from focus when pre-flight already flagged it as bulk-DSD.** Right now the planner exposes blas.csl for all four kernels but the LLM omits it in 11/11 multi-file rounds. Either (a) drop it from `focus` (keep in `expose` for context) when pre-flight reports `fmac_bulk: baseline already uses bulk @fmacs over a DSD`, which would free the multi-file path to either generate single-file edits or focus on a different aux (e.g. a launch/layout file), or (b) close the latent fix-#3 gap by adding `extra_files=bench_files` to the REJECT path at optimize_explore.py:2204 and then run a kernel where the LLM is known to edit aux files (e.g. a stencil or GEMM variant) to get a live aux-persistence verification.

## Appendix — file references

- Logs: `/tmp/piece3d_v3_{BiCGSTAB,Conjugate_Gradient,Preconditioned_CG,Power_Method}_20260605T*Z.log`
- DONE marker: `/tmp/piece3d_v3_BiCGSTAB_DONE.txt`
- Experiences: `/home/USER/xkernel/knowledge/explored/optimization/experiences.jsonl` (rows ts >= 20260605T232120Z)
- Failure bundles: `/home/USER/xkernel/knowledge/explored/optimization/failures/{bicgstab,conjugate_gradient,preconditioned_cg,power_method}_*__20260605T*Z/`
- Plans: `/home/USER/xkernel/knowledge/explored/optimization/plans/{bicgstab,conjugate_gradient,preconditioned_cg,power_method}.json`
- Code paths audited: `/home/USER/xkernel/code_translation/optimize_explore.py:{1094,1183,1242-1263,1281-1299,1559,2073,2108,2204}`, `/home/USER/xkernel/code_translation/knowledge_persistence.py:{366,426-447}`
