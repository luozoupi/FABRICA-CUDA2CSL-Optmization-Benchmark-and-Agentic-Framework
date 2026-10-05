# Immune Kernels — Piece 3D Re-run Report

## 1. Headline

- **Prior run:** 0/4 immune kernels unblocked, 0/4 won — the multi-file path never fired and `blas.csl` was never touched on any of BiCGSTAB, Conjugate Gradient, Preconditioned CG, or Power Method.
- **This run:** 3/4 unblocked (multi-file path fired on Conjugate Gradient, Preconditioned CG, and Power Method; `blas.csl` was edited on Conjugate Gradient and Power Method) and 0/4 won (no candidate cleared the 1.01x speedup threshold; best observed was 1.00013x on Conjugate Gradient). BiCGSTAB is still in flight and its outcome is unresolved.

## 2. Per-kernel results

| Kernel | Baseline cyc | Best accepted cyc | Speedup | Multi-file fired | blas.csl edited | Outcome |
|---|---:|---:|---:|:---:|:---:|:---:|
| BiCGSTAB | — | — | — | no (still in baseline phase) | no | ERROR (in-flight) |
| Conjugate_Gradient | 14,960 | — | — (best non-accept 1.00013x) | yes | yes | UNBLOCK |
| Preconditioned_CG | 17,198 | — | — (best non-accept 1.00006x) | yes | no | NOOP |
| Power_Method | 47,402 | — | — (best non-accept 1.00000x) | yes | yes | UNBLOCK |

Notes on "best accepted" column: no kernel produced an accepted bundle this run; the parenthetical speedups are the best non-accepted measurements observed across rounds.

## 3. What changed since the prior run

Two fixes landed before this re-run:

1. **Planner prompt / auto-promote** now reliably emits two-file plans for kernels where `blas.csl` carries a meaningful share of compute. All three completed kernels loaded cached plans with `focus_files=[src/kernel_*.csl, src/blas.csl]` (CG split rationale cites 2.4% root vs 11.1% blas density; PCG and Power Method plans are analogous). BiCGSTAB's plan was also regenerated correctly with both files in focus.
2. **Multi-file validator / firewall** at `optimize_explore.py:1144-1154` is now actively enforced end-to-end. Round 2 on Power Method was rejected pre-bench with `reject_reason='multi-file reply missing focus files: [src/blas.csl]'`, and Round 2 on Conjugate Gradient was rejected with `multi-file reply missing focus files: src/kernel_cg.csl`. The firewall correctly refuses partial replies. Conversely, Power Method Round 1 and CG Round 1 passed the firewall and benchmarked, confirming both focus files were present in the reply.

Combined, these two changes are why the multi-file path now fires on every completed kernel (3/3) versus 0/4 previously.

## 4. What is still broken

Even with the planner and firewall working, we got 0 wins. Honest diagnosis:

- **Prompt-construction truncation bug (PCG).** `_build_exposed_files_block` in `optimize_explore.py:836-863` clips every exposed file to `max_chars_per_file=6000`. `kernel_pcg.csl` is 12,281 chars, so the LLM saw a `(6481 chars elided)` marker and explicitly refused to emit code in both multi-file rounds ("I cannot reliably reconstruct the elided kernel content"). This is why PCG shows `blas_csl_edited=false` despite multi-file firing — the model never produced any code blocks at all. Focus files should never be clipped; only read-only context files should be.
- **Model behavior under the multi-file contract (CG).** In CG Round 2 the model emitted only `blas.csl` (its reasoning trace says "I'll emit only blas.csl optimization") and got rejected by the firewall for dropping `kernel_cg.csl`. The contract requires verbatim echo of unchanged files, but the model treats that as wasteful and silently drops them. Strengthening the prompt (or relaxing the contract so unchanged files are implicitly preserved) would recover these rounds.
- **No real speedup found even when edits ran cleanly (Power Method, CG OPEN round).** Power Method Round 1 successfully bumped `BLOCK_SIZE` to `MAX_ZDIM` via comptime override and benchmarked, but cycles did not move from 47,402. CG OPEN round produced a real fusion edit and moved cycles by 2 (14,958 vs 14,960). These are signal-free or sub-noise wins — the candidate edits are not the right ones for these kernels.
- **Failure-bundle ergonomics.** The failure persistence layer only saves the root `last_pe.csl` via `extract_code_block`, so aux-file edits (e.g. the blas.csl block that Power Method Round 1 must have included to clear the firewall) cannot be audited without re-running.
- **BiCGSTAB unresolved.** The stop hook fired ~80s into the baseline phase, before any rounds started. Plan is correct on disk; this is purely a wall-clock issue made worse by running 4 kernels in parallel.

## 5. Recommended next move

1. **Fix the truncation bug.** In `_build_exposed_files_block`, never clip files listed in `self.plan.focus_files`; only clip read-only context. Alternatively, raise `max_chars_per_file` to ~16k so even the larger kernel files survive. This single change should turn PCG from NOOP into a real attempt (and likely unblocks other large-kernel cases not in this batch).
2. **Tighten the multi-file contract.** Either (a) add an explicit "echo unchanged focus files verbatim — the firewall will reject if any are missing" line to the multi-file prompt with a one-shot example, or (b) relax the firewall to allow omitted files when their content would be unchanged, treating missing files as no-op rather than a reject. Option (b) is safer for model ergonomics; option (a) preserves the strict contract. Either should recover CG Round 2 and similar drops.

Secondary: re-run BiCGSTAB serially with a longer timeout once the parallel load clears, and have the failure bundle persist each per-file block from multi-file replies so aux-file diffs are auditable post-hoc.
