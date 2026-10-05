# GPT-5.6-Luna sparse pilot — 2026-09-20

Completed: **3/4 tasks passed independent validation; 1/3 passing translations
improved during optimization; 0/4 beat the handwritten references.** This is a
four-task pilot of the configured framework, including its templates and retrieved
guidance, not a model-wide capability estimate or a matched comparison with DeepSeek.

## Independently measured results

All values are **simulated kernel cycles**, not simulator wall time or GPU timing.
Every numeric entry below is from three timing repeats. All repeats were identical.
Each passing initial/final artifact also passed the original numerical verifier on
training seed 7 and held-out seeds 101, 202, and 303 in separate SDK runs.
The timing table uses seed 7; held-out inputs were correctness checks, not an
aggregate performance evaluation across matrices.

| Task, registered small size | Reference | Initial Luna translation | Final Luna artifact | Independent check |
|---|---:|---:|---:|---|
| RowScale-CSR | 45,868 | 45,868 | 45,868 | Pass |
| SpMV-CSR | 7,429 | 7,464 | 7,464 | Pass |
| SpMM-CSR-Dense | 106,606 | — | — | Fail |
| SpGEMM-Masked-Dot | 260,903 | 392,341 | 386,940 | Pass |

RowScale matches its reference. SpMV is 0.47% slower. Masked SpGEMM improves
**1.3766%** from Luna's own initial translation (392,341 → 386,940), but remains
**48.31% slower** than the handwritten reference. SpMM failed at runtime, so it
has no valid performance result and did not enter optimization.

Across the nine optimization candidates in the corrected pilot, four failed
numerical checks, three failed compilation, one was correct but slower, and one
was accepted. The separate diagnostic run described below is excluded from those
nine candidates and included in API accounting.

## What the artifacts show

- **RowScale:** the retained program is a scalar CSR traversal. Index narrowing
  introduced preparation in the frozen wrapper; restoring the wrapper removed
  that preparation and the resulting candidate produced zeros. Another candidate
  passed four DSD operands to `@fmacs`; SDK 2.10 requires a scalar `f32` fourth
  operand. Short-row unrolling passed correctness at 48,879 cycles, so it was
  rejected as slower than the 45,868-cycle baseline.
- **SpMV:** the scalar gather/reduction translation passed. Two proposals placed
  required preparation/reduction work in the frozen wrapper and failed after the
  contract was restored. The third used a builtin with three arguments where four
  were required. The final artifact is identical to the initial passing translation.
- **SpMM:** the initial template used incompatible exports (`maxmin_time` and
  `compute`, rather than the host's `time_buf_u16` and `main`). Repairs reached a
  compilable program, but independent replay received 0 bytes when 16,384 bytes
  of `C_tile` were expected. Source review points to exported helper functions
  returning without `unblock_cmd_stream()`; this diagnosis was not counted as a
  manually repaired model success. The final emitted repair was audited even
  though it was emitted after the framework's last tested translation attempt.
- **Masked SpGEMM:** the passing translation binary-searches for the owning column
  of each stored entry, then merges sorted sparse columns. The accepted rewrite
  builds a row-indexed mask list and uses a stamped dense scratch column for dot
  products. All preparation stays inside the timed kernel. It retains the owner
  lookup, whereas the handwritten reference traverses columns directly. The
  observed gain is modest. Earlier proposals failed through missing preparation
  or an attempted 65,536-element array dimension that overflowed `u16`.

Measured ELFs, disassembly, compiler errors, simulator traces, and profile feedback
are retained. The retained RowScale, SpMV, and SpGEMM ELFs were successfully decoded
into 796, 806, and 1,056 disassembly records respectively. These are whole-program
static record counts, not dynamic instruction counts or CPI. This pilot captured
disassembly; it did not perform a new LLVM-IR or timing-window CPI study.

## Method and limits

- Worktree `/home/USER/xkernel-luna-sparse`, branch
  `luna-sparse-sdk210-smoke`, based on fetched `origin/sparse_ipdps` commit
  `690df427a06fa8aa9937de75203c12bd085052d9`.
- SDK `2.10.1-sdk-202606181328-8faf87a26e`, WSE-3 simulator.
- Exact API-returned model `gpt-5.6-luna`, Responses API, reasoning `medium`.
  Configured output ceiling 16,384 tokens, per-call floor 8,192, one bounded
  truncation retry. All 44 returned pilot/diagnostic calls identified this model.
- Up to three framework-tested translation/repair versions per task, then three
  optimization attempts for each passing translation.
  Sparse structure/mapping and disassembly feedback were enabled. The silicon
  performance model was disabled. No human arithmetic repairs were credited.
- The reference compute was withheld from translation prompts. CUDA, task and
  host/layout interfaces, framework guidance, and generated-code/compiler/profile
  feedback were supplied under the user's explicit API-payload approval.
- RowScale, SpMM, and masked SpGEMM use pinned SuiteSparse matrices with separate
  held-out matrices; SpMV uses synthetic seeded CSR. A local SDK probe confirmed
  four distinct SpMV input fingerprints and nonzero counts 235/256/239/256.
- Independent audits recompile the stored initial and final programs against the
  original host verifier. All 54 frozen input files retain their original hashes.
  Additional input checks constrain overfitting but do not prove correctness on
  arbitrary inputs or constitute a statistically independent model evaluation.
- Results cover the registered **small** sizes and `iters=1`. The single-PE
  translations omit the general repetition parameter. SpGEMM is the benchmark's
  masked `A^T A` dot-product operation, not arbitrary general SpGEMM.
- Each tested invocation starts with fresh device state. The optimized SpGEMM's
  persistent `dense_mark` scratch starts at zero and is not cleared on entry;
  reuse across changed sparsity patterns is **not validated**. These results
  therefore do not establish production readiness for repeated calls.
- There were no new CUDA/GPU timing measurements in this pilot. Simulator cycles
  are not physical WSE measurements or simulator wall-clock latency.

## Harness fixes and diagnostic provenance

The first RowScale translation passed, but the optimizer copied the hidden
reference's `compute()` wrapper into it. That introduced undeclared `iters` and
`rowscale()` dependencies, invalidating all three proposals. The diagnostic run
is preserved in `diagnostics/wrapper_bug/` under the result root. RowScale then
resumed from the **byte-identical** first passing Luna translation with three
fresh optimization attempts; the other tasks started fresh.

The pilot's opt-in `XKERNEL_FREEZE_MEASURED_BASELINE=1` mode freezes the measured
translation's wrapper, with reference workload-size and device-protocol checks
retained. The repository's default reference-freezing policy is unchanged. Source
reviews in `timing_source_review.json` confirm the retained programs place the
actual work inside the measured window.

Other local fixes restore a training-input trace after held-out evaluation,
skip simulation during compile-only checks, use the actual SDK path for
disassembly, preserve SuiteSparse manifests, account for every returned API call,
and terminate owned SDK subprocess groups on timeout. Experience logging now uses
per-task files; the initial diagnostic run appended feature-only records to the
framework's default log in the original worktree. Original source edits there were
preserved.

A further fix makes the translation stage honor `--num-runs`. It was added after
the model workers had started: their internal W1 benchmark used one training
measurement, except RowScale's optimization restart. **All table measurements
come from separate three-repeat audits**, so the headline measurements do not rely
on that bug. `configuration_all.json` and `implementation_all.patch` record the
running pilot integration; `configuration_final.json` and `implementation_final.patch`
record the subsequent fixes. **66 unit tests pass**, along with Python compilation,
shell syntax, and diff whitespace checks.

## API usage and saved outputs

Provider-reported totals, including the preserved diagnostic optimization calls:
**44 returned calls, 353,145 input tokens, 72,337 output tokens**. Cached input
(70,436 tokens) is included in the input total. Six calls were diagnostic
optimization attempts invalidated by the wrapper bug. This is usage accounting,
not a billing invoice. The earlier minimal `READY` access probe adds 11 input and
5 output tokens. Credentials remain outside the repository and were not placed
in prompts or reports.

Result root: `code_translation/results/luna_sparse_20260920/`.
Key evidence: `summary.json`, `headline.csv`, `api_accounting.json`,
`inputs/manifest.json`, `reference/*/benchmark.json`, `audit/*/*/benchmark.json`,
`timing_source_review.json`, `unit_tests.log`, and each task's artifact directory.
The compact table is [luna_sparse_pilot_20260920.csv](data/luna_sparse_pilot_20260920.csv).

- [RowScale-CSR final source](/home/USER/xkernel-luna-sparse/code_translation/results/luna_sparse_20260920/pilot/RowScale-CSR/artifacts/run_20260920_151207/RowScale-CSR/pe.csl)
- [SpMV-CSR final source](/home/USER/xkernel-luna-sparse/code_translation/results/luna_sparse_20260920/pilot/SpMV-CSR/artifacts/run_20260920_152253/SpMV-CSR/pe.csl)
- [SpMM-CSR-Dense final source](/home/USER/xkernel-luna-sparse/code_translation/results/luna_sparse_20260920/pilot/SpMM-CSR-Dense/artifacts/run_20260920_152651/SpMM-CSR-Dense/pe.csl)
- [SpGEMM-Masked-Dot final source](/home/USER/xkernel-luna-sparse/code_translation/results/luna_sparse_20260920/pilot/SpGEMM-Masked-Dot/artifacts/run_20260920_152925/SpGEMM-Masked-Dot/pe.csl)

The retained invocation and settings are in `pilot/<task>/invocation.json`.
The reusable pilot entry point is `python -u tools/luna_sparse_smoke.py --phase all`
from the isolated worktree; completed runs are resumed from saved outcomes.
