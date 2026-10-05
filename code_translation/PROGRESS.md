# Framework Progress Report

## 1. Headline

The translation/optimization framework now spans three modes working in concert: it **generates** new CSL kernels from scratch (84 bundles across 27 unique kernel ideas), **instruments** vendor kernels that ship without cycle counters (6 kernels lifted from `NO_CYCLES` to benchable), and **optimizes** accepted CSL kernels via a branching DAG search guided by a persistent cross-kernel pattern catalog (329 LLM rounds today, 21 accepts across 6 kernels). The largest single win was **GEMM_Collectives_2D dropping from 51 738 to 35 794 cycles (1.45x) via a one-shot `per_row_dsd_unroll`**; the deepest chain was **Laplacian2D-Halo, 1709 -> 671 cycles (2.55x) over six iterative accepts**. Of the 27 kernel directories under `kernels/`, **11 are now READY** for `optimize_explore` (commands + `cycles_send` printed, no external data dependency), and a new `bench_structure.py` + `optimization_planner.py` pair was landed today to fix the root cause behind the four iterative-solver kernels (BiCGSTAB, CG, PCG, Power Method) that have logged 0 accepts despite 120+ attempts each.

---

## 2. Width: Kernel Coverage

### 2.1 Generated kernels (`explore_csl.py`)

Bundles under `/home/USER/xkernel/knowledge/explored/successes/`:

- **84 successful bundles** across **27 unique `kernel_id`s**.
- Top concepts by bundle count:

| Bundles | Kernel ID |
|---:|---|
| 8 | `segmented_sum`, `row_broadcast_apply` |
| 7 | `matvec_batched_2d` |
| 6 | `top_k_per_pe` |
| 5 | `power_iteration_step`, `layernorm_forward` |
| 4 | `row_softmax`, `dropout_mask_apply`, `conv1d_direct_small_kernel` |
| 3 | `stencil_5pt_2d`, `segmented_sum_distributed`, `prefix_sum_inclusive`, `histogram_1d`, `gather_index` |
| 2 | `transpose_2d`, `spmm_csr_dense_distributed`, `relu_inplace`, `matvec_batched`, `matmul_blocked` |
| 1 | 8 long-tail kernels (`saxpy_1d_row`, `rmsnorm_forward`, `matmul_summa_2d`, `dot_product`, ...) |

### 2.2 Instrumented kernels (`instrument_kernel.py`)

Comparing first-git-recorded `run.py` against the current tree:

- **6 kernels instrumented by the framework**: Cholesky, Game of Life, GEMM, GEMM Collectives 2D, GEMV, Laplacian2D-Halo.
- **7 kernels shipped with `cycles_send` already**: 7-Point Stencil, BiCGSTAB, Conjugate Gradient, Power Method, Preconditioned CG, SpMV, SpMV Hypersparse.
- **11 still `NO_CYCLES`**: 25-Point Stencil, FFT 1D-2D, GEMV Checkerboard, GEMV Collectives 2D, Histogram, Laplacian2D-Reduce, LorenzoPredictor-Tile, Mandelbrot, Residual, Single Tile Matvec, Wide Multiplication.

### 2.3 Optimized kernels (`optimize_explore.py`)

`/home/USER/xkernel/knowledge/explored/optimization/accepted/` — 21 accepts across 6 kernels:

| Accepts | Kernel | Patterns used |
|---:|---|---|
| 7 | Game of Life | `task_hop_elimination_via_async_chaining` x3 + others |
| 6 | Laplacian2D-Halo | `column_gather_via_strided_dsd`, `hoist_comptime_constants`, `skip_terminal_copyback_pingpong`, ... |
| 5 | Cholesky | 3x `hoist_comptime_constants`, `promote_var_dsd_to_const`, `per_row_dsd_unroll` |
| 1 | GEMM Collectives 2D | `per_row_dsd_unroll` |
| 1 | GEMM | `hoist_comptime_constants` |
| 1 | 7-Point Stencil | `comptime_value_tuning` (one-line `BLOCK_SIZE` rebind) |

### 2.4 Coverage by mode

| Mode | Today's totals |
|---|---|
| LLM rounds | **329** (all dated 20260604-20260605) |
| Accepts | **21** (~6.4% accept rate) |
| Rejected/failed bundles archived | 258 (in `optimization/failures/`) |
| Generated-kernel bundles persisted | 84 |
| Bench readiness (`optimize_explore --audit`) | **READY=11, PARTIAL=2, NO_CYCLES=11, BROKEN=3** |

---

## 3. Depth: Per-Kernel Optimization Trees

Six kernels carry exploration trees under `/home/USER/xkernel/knowledge/explored/optimization/trees/`, totaling **20 accept nodes**. Five are linear accept-chains; **Cholesky is the only tree with sibling branches off the root**.

### 3.1 Laplacian2D-Halo — 1709 -> 671, **2.55x**, 6 accepts

```
root[1709] -> n1[1156] -> n2[1081] -> n3[959] -> n4[730] -> n5[680] -> n6[671]
```

> "The scalar `while` loop that staged the east/west boundary columns into `col_send_{e,w}` was replaced by two strided `mem1d_dsd` views into `tile` driven by single `@fmovs` calls. The hardware streams the strided column extraction and the bulk tile copy as single DSD operations, collapsing dozens of scalar instructions into one issue each." *(root -> n1, -553 cycles)*

> "Hoisting `MN`, `MN_MINUS_NT`, `NT_MINUS_1` to `const` and predefining row/column DSDs lets the compiler fold extents and strides at compile time, so the hardware DSD engines stream contiguous spans instead of executing per-element address arithmetic and branch checks." *(n3 -> n4, -229 cycles)*

### 3.2 Game of Life — 7838 -> 4690, **1.67x**, 7 accepts

```
root[7838] -> n1[7461] -> n2[7407] -> n3[6946] -> n4[6641] -> n5[6546] -> n6[6261] -> n7[4690]
```

> "Avoid the per-generation `@block/@unblock` churn on the recv tasks: instead of blocking each recv task when it has received all its expected messages and re-unblocking from `advance_generation`, track expected counts and stop processing once the per-direction count is hit. This eliminates 4 `@block` + 4 `@unblock` builtin calls per generation from the critical path." *(n6 -> n7, -1571 cycles — by far the largest absolute single-step win in the entire corpus)*

### 3.3 Cholesky — 12 479 -> 11 549, **1.08x**, 5 accepts, **3 branches**

```
root [12479]
 |-- n1 [11702]   buffer_cleanup           (promote_var_dsd_to_const)
 |-- n2 [11653]   comptime_value_tuning    (per_row_dsd_unroll)
 \-- n3 [11702]   open                     (hoist_comptime_constants)
      \-- n4 [11621]   open                (hoist_comptime_constants)
           \-- n5 [11549]   open           (hoist_comptime_constants)  <-- best
```

> "Module-scope DSDs that were never reassigned were promoted from `var` to `const`. In the `cont` task, the per-iteration `var invsqrt` was made `const` -- eliminating mutable storage for DSD descriptors lets the compiler keep them in registers and skip reload/spill traffic across the task boundary." *(root -> n1, -777 cycles)*

This is the one tree where iterative re-application of the same pattern paid off three times in a row (n3 -> n4 -> n5 each shaved ~80 cycles).

### 3.4 7-Point Stencil — 2129 -> 1076, **1.98x**, 1 accept

```
root[2129] -> n1[1076]
```

> "The only change is in the `comptime_struct` passed to the `stencil_3d_7pts` module import: the `.BLOCK_SIZE` field was rebound from the host-supplied `BLOCK_SIZE` param to the `MAX_ZDIM` param. Raising the stencil's compile-time chunk size to the full vector length collapses the inner blocking loop in `spmv` to a single iteration, eliminating per-chunk loop overhead, DSD re-setup, and communication-pipeline drain/refill." *(one-line change, -1053 cycles)*

### 3.5 GEMM Collectives 2D — 51 738 -> 35 794, **1.45x**, 1 accept

```
root[51738] -> n1[35794]
```

> "The inner-loop trip counter, branch, and runtime `@increment_dsd_offset` updates on `C_dsd`/`A_dsd` are eliminated: the `inline for` over `Nt` expands into a straight-line sequence of `@fmacs` whose DSD offsets (`j*Mt`, `k*Mt`) are comptime constants folded into descriptor setup." *(-15 944 cycles, ~31% drop)*

### 3.6 GEMM — 51 753 -> 49 573, **1.04x**, 1 accept

```
root[51753] -> n1[49573]
```

> "Swapping the loop nest fixes a single C column across the entire `Kt` inner sweep, so each `@fmacs` reuses the same `C_dsd` register state and only the A pointer advances per k. The `j*Kt` multiply is hoisted out of the `Kt`-long inner loop, replacing `Kt` multiplies with one add-base." *(-2180 cycles)*

---

## 4. Cross-Kernel Patterns

From `/home/USER/xkernel/knowledge/explored/optimization/trees/pattern_index.json`:

| Pattern ID | n Kernels | Kernels | In named catalog? |
|---|---:|---|---|
| `hoist_comptime_constants` | **3** | Cholesky (x3), Laplacian2D-Halo (x3), GEMM | **Yes** (promoted today) |
| `per_row_dsd_unroll` | **3** | Cholesky, Laplacian2D-Halo, GEMM_Collectives_2D | **Yes** (promoted today) |
| `column_gather_via_strided_dsd` | 1 | Laplacian2D-Halo (n1-n5, 5x) | **Yes** (promoted today) |
| `task_hop_elimination_via_async_chaining` | 1 | Game_of_Life (n1, n3, n4) | No -- pending |
| `promote_var_dsd_to_const` | 1 | Cholesky | No -- pending |
| `skip_terminal_copyback_pingpong` | 1 | Laplacian2D-Halo | No -- pending |

The two genuine cross-kernel angles are **`hoist_comptime_constants`** (3 kernels, 7 total applications) and **`per_row_dsd_unroll`** (3 kernels). The other four patterns show real wins but are so far single-kernel; they remain in the index for future promotion if a second kernel adopts them.

---

## 5. Framework Infrastructure Shipped (2026-06-04 -> 2026-06-05)

### 5.1 New modules

| File | Role |
|---|---|
| `code_translation/optimization_tree.py` | Per-kernel accept-DAG: writes `optimization/trees/<kernel>.json` (nodes/edges/leaves/current_best) plus `pattern_index.json`. Replaces flat `experiences.jsonl` so branched accepts aren't lost. |
| `code_translation/backfill_trees.py` | One-shot idempotent rebuild of every tree from existing accepts; prints promotion candidates. |
| `code_translation/instrument_kernel.py` | LLM-driven splice of `tic`/`toc` + `cycles_send` print into a kernel's compute file + `run.py`. Only writes back if smoke-run shows a fresh `cycles_send` line. Idempotent. |
| `code_translation/bench_structure.py` | Pure-code (no LLM) bench scanner: walks `@import_module(...)` from the root compute file, classifies stdlib vs local-editable, computes arithmetic density per file. Flags **thin-dispatcher kernels** (root <2% density, >=50 LOC) -- the diagnostic that nailed the iterative-solver bug. |
| `code_translation/optimization_planner.py` | Round-0 LLM call that takes the `BenchStructure` snapshot and decides which files the optimizer should expose/focus on. Caches `optimization/plans/<kernel>.json` keyed on structural fingerprint; trivial path skips LLM for self-contained kernels. |

### 5.2 Modified modules

- `optimize_explore.py` -- now consumes tree `current_best` as baseline and routes promotions through the planner.
- `knowledge_persistence.py`, `csl_knowledge_base.py` -- extended to keep cross-kernel pattern wins persistent.
- `workflow_common.py`, `benchmark_csl.py` -- refactors to support the new tree/baseline path.
- `prompt_cuda2csl.py` -- catalog promotions from accepted explores.

### 5.3 Catalog growth

`CSL_OPTIMIZATION_STEPS_CATALOG` now has **23 entries**, **3 of which were auto-promoted from `explored/` this session** (`column_gather_via_strided_dsd`, `per_row_dsd_unroll`, `hoist_comptime_constants`). The promotion threshold is satisfied automatically when a pattern appears in >=2 kernels' accept chains.

### 5.4 Tests

| File | Tests |
|---|---:|
| `test_explore_csl.py` | 57 |
| `test_no_compute_leak.py` | 61 |
| `test_bench_structure.py` | **17 (new)** |
| `test_optimization_planner.py` | **14 (new)** |
| `test_phase_c.py` | 0 |
| **Total** | **149** (31 new in this window) |

---

## 6. Open Problems

### 6.1 Iterative-solver kernels: 0 accepts despite 120+ attempts each

BiCGSTAB (45 attempts), Conjugate Gradient (15), Preconditioned CG (15), Power Method (45) -- **zero accepts between them**. Root cause now diagnosed: the compute lives in imported library files (`spmv`, `pcg`, etc.) and the optimizer only sees the thin dispatcher in `pe.csl`. The bench-structure scanner flags this exact pattern (**root <2% arithmetic density, >=50 LOC**, 11 such kernels found in the audit). **Piece 1 (the scanner)** landed; **Piece 2 (the planner that exposes the right imported file to the LLM)** also landed today. **Piece 3 (the multi-file edit/verify loop)** is still pending -- until then, these four kernels remain stuck.

### 6.2 Singularity gate contention at high concurrency

One kernel in batch C died from a `singularity` invocation timeout at 7 concurrent runs. The default per-run timeout was raised from 600s to 1800s, which papers over the symptom, but a proper **batch-level concurrency cap** is still not in place -- the orchestrator will happily launch as many parallel singularity calls as there are pending attempts. This needs a semaphore in `optimize_explore.py`.

---

## 7. What's Next

1. **Piece 3: multi-file optimization loop.** With the planner now nominating which imported file to edit, the runner needs to accept multi-file diffs, re-bench, and persist correctly. This unblocks BiCGSTAB / CG / PCG / Power Method (45+45+15+15 = 120 wasted attempts).
2. **Instrument the remaining 11 `NO_CYCLES` kernels.** The instrumentation pipeline is proven on 6 kernels; the next batch should pick the easy targets first (Single Tile Matvec, Residual, Wide Multiplication).
3. **Batch-concurrency cap.** Add a configurable semaphore around the singularity invocation in `optimize_explore.py` (default 4-6); keep the 1800s timeout as a safety net.
4. **Promote `task_hop_elimination_via_async_chaining`** as soon as a second kernel adopts it -- Game of Life used it 3x with the largest absolute win in the corpus, but the catalog rule requires 2 kernels.
5. **GEMV optimization.** 113 attempts, 0 accepts logged in trees -- likely a variant of the multi-file problem, worth re-running once Piece 3 lands.

---

## 8. Piece 3 Landed (2026-06-05): infrastructure unblocked, wins still pending

**Status as of 2026-06-05**: the full multi-file optimization loop is live. 172 unit tests pass. Three live runs against the 4 immune kernels (BiCGSTAB, CG, PCG, Power Method) iterated on:

| Attempt | Multi-file fired | Wins | Headline |
|---|:---:|:---:|---|
| v1 | 0/4 | 0/4 | Planner returned `len(focus_files)==1` on every kernel; `_is_multifile()` never fired. |
| v2 | 3/4 | 0/4 | Planner-prompt + auto-promote fix unblocked focus_files. But focus files were clipped, the "missing focus file" firewall was too strict, and aux file content wasn't persisted on rejects -- 3 distinct downstream bugs caught the actual benchmarks. |
| v3 | **4/4** | 0/4 | Three downstream bugs fixed. Every kernel now reaches the benchmark cleanly via the multi-file path. Best speedup observed: 1.0001x (well under the 1.01x epsilon). |

**Pieces complete:**
- 3a: `OptimizationOrchestrator._load_plan()` + `benchmark_with_files(target, dict)` overlay/rerun helper. `XKERNEL_OPTIMIZATION_PLANS_ROOT` env for test isolation.
- 3b: `q_optimize_csl_compute_multifile` prompt with per-file fences; `extract_multi_file_blocks()` parser; `_attempt_round_multifile` dispatched when `plan.focus_files > 1` OR when the lone focus disagrees with the dispatcher.
- 3c: `for_optimizer_explored()` firewall filter on `current_kernel`; `FIREWALL.md` documents the W1/W2/W3 access matrix.
- 3d: live validation. 4/4 unblocked. 0/4 won (see "What's still pending" below).

**Bugs fixed during 3d that the live runs surfaced:**
- Planner prompt was biased toward single-file plans; rewrote to make multi-file the default for the immune-kernels shape (`root < 5%` + `helper >= 7%`). Plus a deterministic `_maybe_promote_thin_dispatcher` post-validator as a safety net.
- `_build_exposed_files_block` clipped focus files to 6k chars, causing the LLM to refuse to emit code ("cannot reliably reconstruct elided content"). Focus files now never clip; read-only context clip raised to 16k.
- The "every focus file must be present in the reply" firewall was too strict — Opus reliably omits unchanged files as a token-saving measure. Now omitted focus files are preserved as no-ops (`exposed[rel]` fallback). The cycle-acceptance gate still defends against phantom wins. Prompt updated to tell the LLM omission is explicit and safe.
- `record_optimization` now accepts `extra_files: Dict[str, str]`. Both accepted/ and failures/ bundles persist aux file content under their relpath, so offline audit can inspect helper edits. Aux extras are threaded from the multi-file accept AND reject paths via `RoundOutcome.accepted_files`.
- `resolve_target` accepted the `kernels/<Name>/CSL/{src/,commands_*.sh,run.py}` layout (no root `pe.csl`/`layout.csl`) — was previously rejected.
- State propagation across multi-file rounds: `run()` now stashes the accepted dict in `current_files_override` and threads it through `attempt_round` → `_attempt_round_multifile`. Without this, round 2's prompt showed round-0 disk state and discarded round 1's win.

**What's still pending (and why 0 wins):**

The infrastructure works. The 12 candidates across the 4 kernels all landed within ±5 cycles of baseline — meaningfully under the 1% epsilon and within baseline noise. Two empirical observations:
- **The LLM omitted blas.csl in 11/11 multi-file rounds.** Pre-flight already skips `fmac_bulk` (the BLAS routines are already bulk-DSD) and `comptime_hoist` (no `@as` casts in runtime loops), so Opus is being asked to find non-obvious wins. It declines to touch blas.csl on the remaining angles because they're not BLAS-shaped (e.g. `iterative_phase_fusion` is a state-machine restructure, not an arithmetic fix).
- **Auto-mode samples only 3/7 active angles in 3 rounds** (`comptime_value_tuning`, `iterative_phase_fusion`, then falls to OPEN). The four never-sampled angles for these kernels — `dsd_offset_chaining`, `async_detach_overlap`, `task_chaining_unblock_activate`, `prefetch_fabric_async` — are exactly the ones a thin-dispatcher kernel might benefit from (async overlap of the per-iteration allreduce, DSD reuse across iterations).

Concrete next moves:
1. **Re-run the 4 immune kernels with `--n-rounds 8 --open-after 5`** so auto-mode samples all 7 active angles before falling to OPEN. This is cheap (each kernel ~10 min) and grounds the "do these kernels admit any LLM-found speedup at all" question.
2. **Improve the planner's helper-file targeting.** When pre-flight already says "blas.csl is bulk-DSD" (i.e. `fmac_bulk` is skipped), the planner should NOT include blas.csl in `focus_files` — it's noise that distracts from the dispatcher angles that ARE in play. Add the pre-flight skip set to the planner's input.

---

*Report generated on 2026-06-04 (Piece 1-2 audit) and 2026-06-05 (Piece 3 landed) from `explored/optimization/{trees,accepted,experiences.jsonl}`.*

---

## 9. Piece 3e/3f/3g/3h/3i Landed (2026-06-06): the immune kernels were a measurement bug

After the Piece 3d landing, two concrete moves (planner pre-flight awareness + deeper sweep) and three derivative ones (frozen-symbol prompt callout, Power_Method instrumentation audit, GEMV live experiment) landed in sequence. The deeper sweep produced 0 wins across 32 attempts — but the **Power_Method audit explains why** at a level that retroactively explains the entire 158-attempt 0-accept history of the immune-kernels family.

**The headline finding (Piece 3g, verified):** Power_Method's `run.py` brackets `f_tic`/`f_toc` around a host-side Python `for i in range(max_ite)` loop that issues 3 blocking RPCs per iteration. The cycles_send metric measures host↔device command-stream synchronisation, NOT on-device compute. AND the file the optimizer was editing (`src/kernel_power.csl`) is not even in the build path — `layout.csl` line 121 compiles `kernel.csl` instead. Every edit to `kernel_power.csl` was a literal no-op. The same host-loop pattern was independently verified in BiCGSTAB, CG, and PCG. So the immune-kernels family wasn't an LLM weakness; it was the framework optimizing dead code while measuring a metric that ignored on-device compute. Saved as auto-memory `project_power_method_instrumentation.md` for future sessions.

**Piece 3e — planner pre-flight awareness** (177 tests pass). When pre-flight skips `fmac_bulk`, the deterministic `_drop_blas_when_fmac_bulk_skipped` guard demotes blas.csl from focus to read-only; the planner-prompt has a new "already-satisfied angles" block; fingerprint includes the skip set for cache invalidation. Live-verified: BiCGSTAB plan flipped `suggested_first_angle` from `fmac_bulk` to `dsd_offset_chaining`.

**Piece 3f — deeper sweep** (8 rounds × 4 kernels = 32 attempts). All 4 kernels exercised 6 distinct angles each (vs only 2 in attempt 3). 0 wins; cycle spans 0/2/3/7 around baseline — the noise floor (which was the *symptom* of Piece 3g's root cause).

**Bonus fix surfaced during 3f monitoring**: `select_angle` was ignoring `plan.suggested_first_angle`. Patched (round 1 honors the hint when in active list; rounds 2+ revert to fewest-attempts scheduler). 4 new tests; total 181.

**Piece 3h — frozen symbols** (184 tests pass). New `default_frozen_callout_block(spec)` module fn renders a structured DO-NOT-EDIT block listing specific function and param names. Threaded through `q_optimize_csl_compute`, `q_optimize_csl_compute_multifile`, `q_optimize_open_compute`; 3 external callers updated. GEMV live run confirms **zero frozen-symbol violations across 10 rounds** (vs 3 of 32 in Piece 3f).

**Piece 3i — GEMV live experiment** (10 rounds, single-file path). The highest-attempt 0-accept kernel from history (113 prior attempts). Confirms a different, legitimate noise-floor case: pre-flight cleanly skipped 3/7 angles (`fmac_bulk`, `dsd_offset_chaining`, `comptime_hoist`), the remaining 4 angles + OPEN sampled cleanly, and cycle span was ~4 cycles (~0.1%) excluding one outlier — GEMV genuinely sits at its optimum for the registered angle set on a 184-LOC self-contained dispatcher.

**Verdict on the immune-kernels problem:** The 4 iterative-solver kernels (Power_Method/BiCGSTAB/CG/PCG) are *not* immune to LLM optimization — they're instrumented in a way that makes on-device optimization invisible. Until `run.py` is rewritten to push the iteration loop on-device (the on-device state-machine `kernel_power.csl` etc. already exist as dead code), no kernel-side edit can move the metric. GEMV is a separate, legitimate noise-floor case; the framework correctly refused to accept its sub-noise candidates.

### What's next

1. **Piece 3j (pending)** — Detect host-loop-bounded run.py automatically (regex `for ... in range(...)` between `f_tic` and `f_toc`); flag those kernels in the planner output so future runs don't waste LLM budget on them.
2. **Wire `kernel_power.csl` into the build** — the on-device state-machine variant already exists for at least Power_Method; switching `layout.csl` to `@set_tile_code(... "kernel_power.csl" ...)` plus a single `f_power(size, max_ite)` launch in `run.py` would make `cycles_send` meaningful and unblock 158 attempts' worth of LLM work.
3. **Pick a fresh kernel family for the multi-file pipeline.** Cholesky, Game_of_Life, Laplacian2D-Halo, 7-Point Stencil all have ≥1 accept in history and admit further optimization — they're the right targets to demonstrate the Piece 3a-h stack on a kernel where wins are actually findable.

*Section added 2026-06-06.*
