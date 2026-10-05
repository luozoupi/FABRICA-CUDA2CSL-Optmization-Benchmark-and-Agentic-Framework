# xkernel — progress summary, architecture, and current state

**Date:** 2026-06-03 (delta from `progress_summary_20260602.md`)
**Goal (unchanged):** Build an agentic framework that translates CUDA kernels to Cerebras CSL **and** strictly reduces their on-WSE cycle count below the human-written Cerebras reference (`fast_p` scoring, where `fast_1` = parity, `fast_2` = ≥2×).

This doc is one self-contained snapshot covering: progress since 2026-06-02, the current architecture, the design decisions taken and discarded today, and the open challenges that gate further progress.

---

## Part 1 — Progress since 2026-06-02

### One-line bottom line

**End of 2026-06-02**: 1 cycle win across the bench (7pt-Stencil 2129→1076, fast_2). W1 translation success rate 5/21 (24%). Verdict: framework's *direction-finding* works; *transformation* gates on the implementer model.

**End of 2026-06-03**:
- **W2 (--optimize-only) wins**: 1 of 9 cycle-instrumented kernels (7pt-Stencil, reproduced on Sonnet **and** Opus).
- **W1 (CUDA→CSL) wins**: up to **4 of 15 previously-failed kernels** translated under Opus + RAG (was 1/15 with budget bump alone). Plus 2 cycle reductions on translated kernels (GEMM 7.4%, GEMV 0.3%).
- **Combined union (hybrid Sonnet+Opus + RAG, taking both models' passes)**: ~6/15 W1 translations theoretically reachable; observed 2/15 in actual hybrid sweep due to a wrapper path bug (fixed but not re-run).
- **Bench cycle-instrumentation coverage**: 7/27 → **11/27** kernels (added GEMV, GEMM, Cholesky, Laplacian2D-Halo via the bulk-instrumentation workflow).
- **Tests**: 49 → **61** passing.
- **Framework gained**: planner→profiler→coder bottleneck-matched selection, ✗ NO-OP memory, in-run hard ban, top-K reservoir, version_trace, head+tail clip + cslc warning dedupe, RAG cluster-keyed query augmentation + 9 cluster-gated W1 gotchas, hybrid Sonnet/Opus wrapper.
- **Framework rejected**: semantic-bridge agent step (A/B verdict = discard — algorithm framing didn't address syntax-error failure mode).

### Daily timeline

| Phase | What | Outcome |
|---|---|---|
| **Bench coverage** | Auto-instrumented GEMV, GEMM, Cholesky, Laplacian2D-Halo via worktree-isolated agents | 4 new kernels gained cycle measurement; bench coverage 7→11/27 |
| **Full bench W1+W2 sweep** | Sonnet 4.6 across 21 W1 + 9 W2 kernels | W2: 1/9 wins (7pt-Stencil 49.5%); W1: 5/21 translated, 0 cycle wins |
| **Audit `format_command_transcript`** | Workflow: 3 code-trace + 1 empirical-measurement on a real Mandelbrot failure | 92.3% transcript loss to head-only truncation — error messages live at tail; fixed |
| **Audit fixes** | head+tail clip with elision marker; cslc warning dedupe; per-step blocked_reason in header; debugger targets first non-zero-returncode step | Shipped; 49→55 tests |
| **Reviewer budget probe** | Resweep 15 W1 failures with `--reviewer-max-attempts 8` (was 4) | Marginal pass-rate from attempts 5-8 = 0/14 (flat curve). Verdict: budget isn't the bottleneck |
| **RAG analysis workflow** | 4-phase: extract agent failure vocabulary, query tutorial corpus, contamination-check candidates, curate commit-ready entries | 5 KNOWN_GOTCHAS distilled from `csl-examples/tutorials/`, all contamination-clean. 3 cluster-keyed query augmentations |
| **RAG resweep on Sonnet** | Same 15 W1 kernels, RAG layer 1+2 active | 0/15 → 2/15 (+ GEMM-Collectives-2D, Residual). 1 regression (Single-Tile-Matvec) — gotchas were "always-on" |
| **Cluster-gate fix** | Refactor: gotchas only injected when query markers match their cluster | Regression fixed; 4 unit tests, 57 → 61 total |
| **Opus 4.7 W1 RAG resweep** | Same 15 kernels via Argo claude-opus-4-7 | **4/15 pass (Single-Tile-Matvec, GEMV, GEMM, 7pt-Stencil)**. Cycle reductions on GEMM (7.4%), GEMV (0.3%) |
| **Semantic-bridge A/B (DISCARDED)** | Worktree-isolated impl of CUDA→CSL bridge agent step + 4-kernel A/B | bridge_on 1/4, bridge_off 1/4. Bridge content conceptually correct but didn't address syntax-error failure mode. Not promoted to main |
| **Hybrid wrapper (Phase A) + Halo RAG iteration (Phase B)** | 8-phase workflow: write `run_hybrid_sweep.sh`, smoke gate, full 15-kernel hybrid sweep, halo failure extract from Opus logs, draft new RAG gotchas, ship, halo resweep | Wrapper shipped (path bug surfaced + fixed); 4 new halo gotchas committed; hybrid sweep net union 2/15 (tainted by wrapper bug, needs rerun); halo resweep net new passes 0 |

---

## Part 2 — Architecture as it stands

### Repository layout (unchanged from 2026-06-02 except as noted)

```
/home/USER/xkernel/
├── code_translation/                # the agentic translator + orchestrator
│   ├── cuda2csl.py                  # 3097 LOC (was ~2500). CUDA2CSLOrchestrator + main()
│   ├── prompt_cuda2csl.py           # 1380 LOC. 11 prompt templates + 18-angle catalog + builtin whitelist
│   ├── benchmark_csl.py             # 759 LOC. cslc + cs_python harness, cycles_send extraction, warning dedupe
│   ├── csl_knowledge_base.py        # 1338 LOC. 3 audience lens functions + 5 corpora + cluster-gated W1 gotchas
│   ├── workflow_common.py           # shared helpers including format_command_transcript with head+tail clip
│   ├── debugger_agent.py            # structured-JSON debugger sub-agent
│   ├── contract_check.py            # frozen-fn + frozen-param validator
│   ├── profile_csl.py               # per-kernel timing + per-PE cycle artifacts (variance feedback added)
│   ├── csl_mesh_patterns.py         # 8 hand-curated wafer-scale patterns
│   ├── test_no_compute_leak.py      # 61 unit tests (was 24)
│   └── results/                     # per-run outputs + cross-experiment reports
├── knowledge/                       # JSONL corpora + ingestion scripts
├── kernels/                         # 27 CUDA+CSL pairs (xkernel-bench suite)
│   ├── baselines_wse3.json          # measured WSE-3 cycle counts (now 11 kernels)
│   ├── 7-Point Stencil/spec.yaml    # has proven_angles + attempted_no_op_angles
│   ├── BiCGSTAB/spec.yaml           # has optimization_angles + attempted_no_op_angles
│   ├── Conjugate Gradient/spec.yaml # …
│   ├── Power Method/spec.yaml       # …
│   ├── Preconditioned CG/spec.yaml  # …
│   ├── GEMV/spec.yaml               # NEW: instrumented today; baseline 4007 cycles
│   ├── GEMM/spec.yaml               # NEW: 51753 cycles
│   ├── Cholesky/spec.yaml           # NEW: 12479 cycles
│   ├── Laplacian2D-Halo/spec.yaml   # NEW: 1709 cycles
│   └── …
├── run_cuda2csl_argo.sh             # existing single-model launcher (Argo proxy → Claude)
├── run_cuda2csl_alcf.sh             # existing launcher for ALCF inference endpoints (gpt-oss-120b)
└── run_hybrid_sweep.sh              # NEW today: Sonnet-first, Opus on Sonnet-fail for promotable clusters
```

### Four agent roles (unchanged)

Analyzer / Architect / Implementer / Reviewer (+ optional Debugger sub-agent). Knowledge composition via 3 audience lens functions (`for_architect`, `for_implementer`, `for_reviewer`).

### Two workflows (unchanged)

**W1** (CUDA → CSL → optimize): the agent translates from CUDA source. Reference compute CSL is **hidden** by the compute-leak guard; agent sees layout.csl, run.py, commands.sh.

**W2** (`--optimize-only`): existing CSL → strict cycle reduction. The input CSL is labeled "current code at N cycles". `_w2_disarm_compute_canary = True` correctly suppresses the leak guard because the input IS the reference (by design of W2).

### What's NEW in the architecture today

**1. Bottleneck-matched optimization angle selector (planner→profiler→coder loop)** *(landed earlier in this work-cycle; mature)*
- `prompt_cuda2csl.py:CSL_OPTIMIZATION_STEPS_CATALOG` — 18 angles with `{description, applicable_groups, applicable_bottlenecks, source_skill, knowledge_query_hint}`
- `cuda2csl.py:_profile_bottleneck_signature()` — regex/AST static profiler emitting 9 bottleneck classes (dsd_rebuild_in_loop, scalar_loops_over_arrays, runtime_size_in_inner_loop, polling_async, sync_fabric_ops, circular_buffer_manual, separate_mul_then_add, unexplored_comptime_config, many_launch_dispatched_fns). Sibling-file-aware for split-file kernels (e.g. Power-Method's `kernel_power.csl` + `kernel.csl`).
- `cuda2csl.py:_match_angles_to_bottlenecks()` — deterministic matcher: whitelist × signature → ranked angles
- `cuda2csl.py:_select_optimization_angle()` — per-round LLM selector picks ONE angle from kernel's spec.yaml whitelist, biased by `★ PROVEN` + `⚙ BOTTLENECK MATCH` + `✗ NO-OP` annotations
- `spec.yaml:optimization_angles` per kernel — curated whitelist
- `spec.yaml:proven_angles` — pointers to historical wins (7pt-Stencil: `comptime_value_tuning → 1072`)
- `spec.yaml:attempted_no_op_angles` — cross-run + in-run accumulated failures
- **In-run hard ban**: angles tried ≥3 times this run without cycle reduction get removed from whitelist
- **Top-K reservoir + branch-on-stall**: when patience exhausts on best lineage, branch from `top_k[1]`
- **Distinct-angle best-of-N**: `--best-of N` now generates N candidates from N DIFFERENT angles
- **`comptime_value_tuning` angle + `unexplored_comptime_config` detector**: the lever behind 7pt-Stencil's 1076 win, generalized

**2. Multi-run benchmark + version_trace** *(landed earlier in this cycle)*
- `--num-runs N` (default 1, optimize default 3) — repeats `cs_python run.py` N times, returns median + min + max + per-run list
- `cycles_send` reports median (robust to ~20-30% sim noise)
- `build_version_trace()` writes per-kernel `version_trace.json` with each translate/optimize attempt + cycles/ms vs measured reference

**3. Phase 2a/2b: layout hoist + run.py compression** *(earlier)*
- `layout.csl` is its own labeled section in 4 implementer prompts (not buried inside `reference_contract`)
- `build_reference_contract(..., max_chars=12000)` compresses `run.py` to host-protocol skeleton (keeps `simulator.launch`, `memcpy_*`, `cycles_send`, verification block, drops licensing/argparse/diagnostics). BiCGSTAB shrunk 20613→3978 chars (5.2×); 7pt-Stencil 14562→3073 (4.7×)

**4. Compute-leak guard** *(earlier)*
- `_set_compute_canary()` picks a CSL-builtin line (must contain `@fmacs` / `@get_dsd` / `@mov32` etc.) from reference compute file
- `_assert_no_compute_leak()` raises AssertionError if any user/system role message contains the canary
- Hardened twice today: skips assistant role (agent's own replies don't count as leaks); requires CSL `@`-builtin (avoids false-positives on CUDA comments mentioning CSL function names)
- Disarmed in W2 mode (the input CSL legitimately IS the reference, by W2 design)

**5. format_command_transcript audit fixes** *(today)*
- `workflow_common.py:_clip_head_tail(s, head=400, tail=800)` — head+tail with visible `... N chars elided ...` marker
- `benchmark_csl.py:_dedupe_cslc_warnings()` — collapses repeated `file:line:col` warning blocks to one with `[×N occurrences elided]` annotation
- Per-step `blocked_reason` rendered in transcript header
- Debugger picks first non-zero-returncode step in `transcript` (not blindly `transcript[-1]`)

**6. RAG injection layer 1+2** *(today)*
- `csl_knowledge_base.py:KNOWN_GOTCHAS_W1_FAILURE_PATTERNS` — 9 distilled tutorial gotchas (5 from initial RAG analysis + 4 from halo iteration)
  - collectives_2d cluster: "collectives_2d/pe import takes DSR-id arrays, not just colors", "Library .csl files with uninitialized `param`s expect you to extend the params struct"
  - halo_recv_unblock cluster: "Receivers must call sys_mod.unblock_cmd_stream()", "Synchronous @fmovs on a fabric DSD blocks the calling task", "Edge / corner / guarded PE branches MUST still reach unblock_cmd_stream()", "WSE-3 queue / microthread ID pools and the @initialize_queue discipline", "Canonical halo receive: async fabin_dsd + ut_id + activate, posted before sends", "Per-PE role at runtime: use layout_mod.get_x_coord()/get_y_coord() inside fn/task bodies"
  - dsr_queue_fabric_init cluster: "memcpy library reserves input queues 0 and 1", "Synchronous @fmovs" (shared with halo), "Library param struct extension" (shared with collectives)
  - **All 9 contamination-checked**: every entry cites `csl-examples/tutorials/*` sources, zero benchmark identifiers (`f_spmv`, `stencil_mod`, `BLOCK_SIZE`, etc.)
- `_W1_CLUSTER_QUERY_AUGMENTATIONS` — when query mentions cluster markers (collectives_2d, halo, dest_dsr_ids, etc.), appends 50-100 chars of cluster-specific keywords to the TF-IDF query so relevant tutorial chunks rank higher
- `_detect_w1_clusters_for_kernel()` + `_GOTCHA_SECTIONS_BY_CLUSTER` — cluster-gated injection: a trivial single-PE kernel without halo/collectives/queue markers gets ZERO W1 gotchas (fixes Single-Tile-Matvec regression)
- Env-gated: `XKERNEL_W1_GOTCHAS=0`, `XKERNEL_W1_CLUSTER_QUERIES=0`, `XKERNEL_W1_GOTCHAS_FORCE_ALL=1`

**7. Hybrid Sonnet-then-Opus wrapper** *(today)*
- `run_hybrid_sweep.sh` (168 LOC): runs Sonnet 4.6 first; on failure, promotes to Opus 4.7 only when kernel cluster ∈ {collectives_2d, dsr_queue_fabric_init}
- Halo cluster is hard-skipped from Opus promotion (Opus is empirically 0/7 there)
- Output: timestamped `results/hybrid_sweep_<ts>/<kernel>/{sonnet,opus}/` with winning variant promoted to `<kernel>/pe.csl`
- Path bug found by smoke phase + fixed this turn (resolves `run_*/<kernel>/benchmark.json` via glob)

---

## Part 3 — Results matrix

### W2 (`--optimize-only`) on 9 cycle-instrumented kernels

| Kernel | Baseline | Best | Reduction | Model + angle |
|---|---:|---:|---:|---|
| **7pt-Stencil** | 2129 | **1076** | **49.46%** | Sonnet + Opus both reach 1076 via `comptime_value_tuning` (BLOCK_SIZE=MAX_ZDIM) |
| Power-Method | 4877 | 4877 | 0% | both models |
| CG | 14957 | 14957 | 0% | both models |
| PCG | 17197 | 17197 | 0% | both models |
| BiCGSTAB | 25970 | 25970 | 0% | both models |
| GEMV | 4003 | 4003 | 0% | Sonnet W2 |
| GEMM | 51753 | 51753 | 0% | Sonnet W2 |
| Cholesky | 12479 | 12479 | 0% | Sonnet W2 |
| Laplacian2D-Halo | 1709 | 1709 | 0% | Sonnet W2 |

### W1 (CUDA → CSL → optimize) on the 15 kernels that failed the initial full-bench sweep

| Kernel | Cluster | pre-RAG Sonnet | Sonnet + RAG | Opus + RAG |
|---|---|:-:|:-:|:-:|
| Single-Tile-Matvec | none | ✓ (3) | ✗ (regression, fixed) | ✓ (2) |
| GEMV | collectives_2d | ✗ | ✗ | **✓ (7) + opt 0.3%** |
| GEMM | collectives_2d | ✗ | ✗ | **✓ (4) + opt 7.4%** |
| GEMV-Collectives-2D | collectives_2d | ✗ | ✗ | ✗ |
| GEMM-Collectives-2D | collectives_2d | ✗ | **✓ (6)** | ✗ |
| 7pt-Stencil | dsr_queue_fabric_init | ✗ | ✗ | **✓ (8)** |
| Mandelbrot | dsr_queue_fabric_init | ✗ | ✗ | ✗ |
| FFT-1D-2D | dsr_queue_fabric_init | ✗ | ✗ | ✗ |
| Residual | halo_recv_unblock | ✗ | **✓ (6)** | ✗ |
| Laplacian2D-Halo | halo_recv_unblock | ✗ | ✗ (after halo RAG iter: ✓ at 4) | ✗ |
| Cholesky | halo_recv_unblock | ✗ | ✗ | ✗ |
| Laplacian2D-Reduce | halo_recv_unblock | ✗ | ✗ | ✗ |
| LorenzoPredictor-Tile | halo_recv_unblock | ✗ | ✗ | ✗ |
| Game-of-Life | halo_recv_unblock | ✗ | ✗ | ✗ |
| GEMV-Checkerboard | halo_recv_unblock | ✗ | ✗ | ✗ |
| **TOTAL** | | **1/15 (6.7%)** | **2/15 (13.3%)** | **4/15 (26.7%)** |

### Cross-model complementarity finding

**ZERO shared passes between Sonnet-RAG and Opus-RAG**. Each model cracked different kernels:
- Opus-only: Single-Tile-Matvec, GEMV, GEMM, 7pt-Stencil (collectives_2d wins + dsr win)
- Sonnet-only: GEMM-Collectives-2D, Residual (halo wins)
- Theoretical union: 6/15 = 40%. Hybrid sweep was supposed to capture this but was tainted by the wrapper path bug (now fixed; rerun pending).

### Per-cluster impact of RAG + model choice

| Cluster | Kernels | pre-RAG | Sonnet+RAG | Opus+RAG |
|---|---:|---:|---:|---:|
| collectives_2d | 4 | 0 | 1 | 2 |
| halo_recv_unblock | 7 | 0 | 1 | 0 |
| dsr_queue_fabric_init | 3 | 0 | 0 | 1 |
| none | 1 | 1 | 0 (regr.) → 1 (after cluster-gate fix) | 1 |

---

## Part 4 — Design decisions taken today

### Adopted

- **Cluster-keyed query augmentation** (TF-IDF biasing): keeps the existing 217-chunk tutorial corpus + 328-chunk skills corpus and just appends ~50-100 char cluster-specific keywords to the implementer's query string. Zero new infrastructure; only ranking.
- **Distilled KNOWN_GOTCHAS over corpus chunks**: TF-IDF retrieval brings in too much noise per chunk (1-2 KB each); a 5-15 line distilled gotcha is denser per token. Source-cite every entry to a tutorial.
- **Contamination check is a hard gate**, not an audit. Three layers: (1) source provenance (tutorial dirs vs kernel dirs), (2) identifier blacklist (regex grep for bench-specific names), (3) explicit verdict labels (`safe_to_inject` / `rewrite_required` / `reject`) — only `safe` content ships.
- **Cluster-gated knowledge injection**: gotchas only injected when the query contains markers for that cluster's bottlenecks. Trivial kernels get no W1 gotchas (fixes Single-Tile-Matvec regression).
- **Hybrid model promotion by cluster, not by attempt count**: empirically, Opus is strictly worse than Sonnet on halo cluster (0/7 vs 1/7). Hard-skip Opus there; only promote on clusters where Opus has demonstrated lift.
- **In-run hard ban + ✗ NO-OP cross-run memory**: angles that fail repeatedly get removed from the whitelist, forcing the selector to widen rather than loop on a saturated lever.
- **Per-version trace**: every W1 translate attempt + every optimize attempt is recorded with `cycles_send`, `run_time_ms`, and `vs_reference_*_pct`. Honest measurement vs the human reference.
- **Workflow-based dispatch for parallel work**: heavyweight sweeps (15-kernel × 8-attempt) dispatched as parallel Workflow agents with explicit gating (probe → smoke → full → aggregate). Each phase short-circuits cleanly on failure.

### Rejected

- **Semantic-bridge agent step** (CUDA→CSL primitive map): A/B test verdict was `discard`. Bridge correctly identified algorithms (e.g. SUMMA-style GEMM → Collectives-2D row/col broadcasts) but the dominant failures were syntax-level (`@export_symbol(&main)`, wrong field names, DSR id collisions) not algorithm-level. Worktree preserved at `~/xkernel/.claude/worktrees/wf-semantic-bridge/` for possible redesign as a CSL-syntax-error-prevention checklist instead of an algorithm-summary.
- **Reviewer budget bump 4→8**: marginal pass-rate from attempts 5-8 was 0/14. Empirically flat. Budget isn't the bottleneck.
- **Tutorial-chunk regurgitation as gotchas**: rejected on contamination grounds. Distilled paraphrases citing the tutorial are safe; copy-pasted code blocks risk leaking benchmark patterns.
- **Always-on W1 gotchas**: caused Single-Tile-Matvec regression. Replaced with cluster-gated injection.

---

## Part 5 — Challenges that gate further progress

Ordered by how concretely we can attack them:

### 1. The transformation problem (highest leverage, blocks W2 wins)

The framework's *direction* is solved: it correctly identifies which angle to pursue on every kernel. The remaining gap is that the implementer (Sonnet 4.6 / Opus 4.7) rarely produces a working transformation:
- W2 wins: 1/9 cycle-instrumented kernels (only 7pt-Stencil, because the lever is a 1-line config flip)
- Even Opus on 5 iterative-solver kernels: 0% reduction. Sonnet same.

The selector says "try iterative_phase_fusion"; both models return either identical code or a syntactically broken variant. **The bottleneck is the model's CSL fluency on multi-line structural changes**, not the catalog content.

Concrete attack surfaces:
- **Sharper per-angle templates**: the catalog says "merge separately-launched f_dot/f_axpy/f_spmv calls"; it doesn't show the canonical CSL diff. Adding "before/after" snippets to the angle prompt (not in the catalog metadata) might help.
- **Per-fn timing (tasks #11/#12/#13 still pending)**: would tell the agent "f_spmv_Ap is 60% of cycles, focus there" — narrows the target so the structural change is smaller in scope.
- **Stronger model**: Opus W2 results are unchanged vs Sonnet on 5/5 iterative solvers. No evidence a bigger model alone solves this.

### 2. Halo_recv_unblock cluster — content gap, not capability gap

- Sonnet 1/7, Opus 0/7. Opus's own logs self-diagnose "unimplementable under current routing constraints" (Cholesky) — that's a reasoning admission of a missing abstraction.
- Halo RAG iteration today added 4 new gotchas, net 0 new passes. Synthesizer identified 5 specific missing patterns: (a) static color routes can't rotate roots across iterative steps, (b) punted-fabric / "step-0 only" detector, (c) per-PE expected_events for 2x2 mesh (no interior PE), (d) diagonal-neighbor exchange needs two orthogonal sends, (e) DSDs must be over comptime-known concrete arrays, not function-arg pointers.

This is the most addressable cluster: known failure patterns, identifiable canonical idioms, contamination-clean source material in the tutorials. The next RAG iteration on halo is high-leverage.

### 3. Variance + per-version cycle attribution

- `--num-runs 3` + median is in place but rarely run because of wall-clock cost (3-5s sim startup per repetition × 10 attempts × N candidates).
- **No per-fn cycle attribution yet** (tasks #11/#12/#13). Today's selector picks angles based on static-code patterns and history; with per-fn timing, it could pick based on actual cycle hotspots ("f_spmv_Ap consumes 60% of timed region — focus there"). Would directly attack challenge #1.

### 4. Wrapper / harness reliability

- `run_hybrid_sweep.sh` path bug caught by smoke today, fixed but not re-run for clean measurement. Pattern: orchestration shell scripts go untested until they're invoked in production sweeps.
- 2 of 15 kernels in the hybrid sweep had `sonnet_attempts=0` — apparent harness skip (probably `--output` collision when 15 parallel runs use the same timestamp). Worth auditing.
- `run_cuda2csl_argo.sh` hard-codes the `cuda2csl.py` path to the main tree, which broke the semantic-bridge worktree A/B test (1 of 4 bridge_on arms ran main-tree code by accident).

### 5. Bench cycle-instrumentation coverage

- 11/27 kernels measurable today. Remaining 16 are correctness-only.
- The instrumentation script-and-template pattern is proven (workflow w3f5hejlp added 4 kernels in one batch with worktree isolation + verification). Could be re-run on the next 4-8 kernels.
- Candidates: GEMV-Checkerboard, GEMV-Collectives-2D, GEMM-Collectives-2D, Game-of-Life, Wide-Multiplication, LorenzoPredictor-Tile, Mandelbrot, FFT-1D-2D.

### 6. RAG retrieval still TF-IDF — works but ceiling visible

- Cluster augmentation got real lift but the underlying TF-IDF still loses signal on novel kernels.
- Switching to embedding-based retrieval would help but the contamination check is harder (similarity doesn't carry source provenance the way TF-IDF + section filtering does).
- Not blocking today; revisit if the cluster-gate approach plateaus.

### 7. Model-cost vs pass-rate tradeoff

- Opus 4.7 reaches 4/15 (26.7%) but ~3-5× Sonnet's cost. Sonnet RAG reaches 2/15 (13.3%).
- Today's hybrid wrapper aims to capture both models' wins at ~50% Opus-only cost. Once the path bug rerun is done, we'll have a clean number.
- Theoretical union ceiling 6/15 (40%) — confirmed by complementary-pass evidence (zero shared kernels).

### 8. Selector occasionally loops on saturated levers

- In-run hard ban (threshold 3) addresses this when the failed attempts produce comparable results.
- Doesn't help when 2 candidates per attempt × best-of-3 makes the "3 failed attempts" threshold come fast — could end up burning the whole whitelist in 2-3 attempts.
- Tune threshold or make it adaptive to budget.

---

## Part 6 — Status snapshot

- **Tests**: 61 passing (TestNoComputeLeak, AngleCatalog, SpecYamlAngles, SelectorFallback, VersionTrace, BottleneckProfiler, TranscriptClipAndDedupe, KnowledgeInjection, SemanticBridge (worktree only)).
- **Main tree state**: `csl_knowledge_base.py` 1338 LOC, `cuda2csl.py` 3097 LOC, `prompt_cuda2csl.py` 1380 LOC, `benchmark_csl.py` 759 LOC.
- **Preserved worktrees**: `~/xkernel/.claude/worktrees/wf-semantic-bridge/` for potential redesign of the bridge as a syntax-checklist.
- **Result trees from today**:
  - `results/full_bench_sweep_20260602/` — initial full-bench W1+W2 (Sonnet)
  - `results/resweep_w1_8attempts_20260603/` — pre-RAG, budget-only test (Sonnet, 0/15 net)
  - `results/resweep_w1_rag_20260603/` — Sonnet + RAG always-on (2/15)
  - `results/resweep_w1_opus_rag_20260603/` — Opus + RAG cluster-gated (4/15)
  - `results/hybrid_w1_20260603/` — hybrid sweep with the path bug (2/15, suspect)
  - `results/halo_resweep_after_rag_iter_20260603/` — halo RAG iteration (1/7, no net gain)
  - `results/semantic_bridge_ab_20260603/` — discarded experiment
- **Env vars added today** (all default-safe):
  - `XKERNEL_W1_GOTCHAS=0` — disable the W1 gotcha block entirely
  - `XKERNEL_W1_CLUSTER_QUERIES=0` — disable query augmentation
  - `XKERNEL_W1_GOTCHAS_FORCE_ALL=1` — debug override: include all gotchas regardless of cluster match

---

## Part 7 — Recommended next moves (in priority order)

1. **Re-run hybrid sweep with the path bug fixed** — gives a clean measurement of the hybrid Sonnet+Opus approach. Expected: 4-6/15 union pass rate.
2. **Halo RAG iteration round 2**: ship the 5 missing gotchas the synthesizer flagged (static color routes, punted-fabric detector, per-PE expected_events for 2x2, diagonal-neighbor two-orthogonal, DSD-over-fn-arg-ptr). Re-sweep halo cluster on Sonnet. Highest-leverage knowledge-content target.
3. **Per-fn cycle timing on BiCGSTAB** (task #11): unlocks the "focus on the hot fn" selector signal that would help challenge #1 broadly. Hand-instrument first, auto-instrumenter follows.
4. **Audit `run_cuda2csl_argo.sh`'s hard-coded main-tree path**: blocks future worktree-based A/B tests cleanly.
5. **Instrument 4-8 more kernels** (Wide-Multiplication, Game-of-Life, FFT-1D-2D, Mandelbrot, GEMV-Checkerboard, etc.) — bench cycle coverage from 11/27 → ~17/27.
6. **Per-angle before/after snippets** in the optimizer prompt: convert the catalog metadata into example diffs, narrowing the transformation surface for the implementer (challenge #1).
7. **Tighten in-run ban threshold** when `--best-of N > 1`: current `3 attempts × N candidates = 3N samples` may saturate the whitelist too fast.

---

## Appendix A — Headline metrics

| Metric | 2026-06-02 | 2026-06-03 |
|---|---|---|
| Cycle-instrumented kernels | 7/27 | **11/27** |
| W2 wins (cycle reductions on instrumented kernels) | 1/9 | 1/9 (unchanged; transformation gap) |
| W1 translation pass rate (full bench, Sonnet) | 5/21 | 5/21 + 1 lost to wrapper bug |
| W1 pass rate on 15-failed-kernel resweep (Sonnet, pre-RAG) | 1/15 | (same) |
| W1 pass rate on 15-failed resweep (Sonnet, RAG) | — | **2/15** (+ failure-mode shift on 4 more) |
| W1 pass rate on 15-failed resweep (Opus, RAG) | — | **4/15** |
| Theoretical hybrid union ceiling | — | **6/15** (40%, zero shared) |
| KNOWN_GOTCHAS sections in implementer prompt | 0 (W1 cluster-specific) | **9** (cluster-gated) |
| Unit tests | 49 | **61** |
| Single-call selector LLM cost per optimize attempt | n/a | ~1024 tok @ Sonnet ≈ 1.5¢; trivial vs full-attempt cost |

— End of progress summary 2026-06-03 —
