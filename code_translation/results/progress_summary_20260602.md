# xkernel — progress summary, architecture, and current state

**Date:** 2026-06-02
**Goal:** Build an agentic framework that translates CUDA kernels to Cerebras CSL **and** strictly reduces their on-WSE cycle count below the human-written Cerebras reference (`fast_p` scoring metric, where `fast_1` = parity, `fast_1.5` = ≥1.5×, `fast_2` = ≥2×).

---

## Part 1 — Progress timeline (what was built, in order)

| Phase | What | Outcome |
|---|---|---|
| Foundation (May 27–28) | One-shot baseline sweep + 4-turn agentic sweep across 17 kernels × 5 models | gpt-oss-120b leads agentic at 13/17 pass; Claude Sonnet 4.6 one-shot 14/17 |
| Multi-agent split (May 28–29) | Reframe planner as architect emitting free-form DESIGN.md; reviewer agent classifies failures into bucket A (architect respin) / B (implementer fix) / C (contract violation); routed repair loop with respin cap | Reviewer A/B confirmed routing works; pass count flat (within ±1 noise) |
| Knowledge layers (May 30) | 5 JSONL corpora wired through 3 audience-specific lens functions (architect / implementer / reviewer): SDK release notes (77), debug techniques (12), tutorials broad (217), tutorials narrow (29), cerebras-csl-skills (328) | All corpora verifiably cited in transcripts; **zero pass-count delta on the 4 hard kernels** (Game-of-Life / Residual / 7pt-Stencil / FFT-1D-2D) across all 5 corpus experiments × 3 models |
| Prompt hardening (May 31) | Hard `@`-builtin whitelist (62 proven builtins + anti-patterns) injected at end of every implementer prompt | Stopped recurring `@my_pe_x` hallucinations; failure mode shifted to other CSL bugs |
| Debugger sub-agent (May 31) | Structured-JSON diagnosis agent fires on bucket-B repeats; emits `diagnostic_run`/`diagnosis`/`recommended_patch`/`confidence` for the implementer to apply | Code complete + 11/11 unit tests; A/B Δ pass count = 0 across 3 models |
| **Cycle-reduction pivot (Jun 1)** | Repivoted from correctness-only to strict cycle reduction. `cycles_send` extraction in benchmark, `optimize()` loop with min 5 / max 10 attempts + regression guard, `--auto-optimize` flag for W1, `--optimize-only` flag for W2 | First framework primitive that targets the actual goal |
| **First real win (Jun 1)** | Smoke #2 on 7pt-Stencil W2: **2129 → 1233 cycles (1.73×, fast_1.5)**. Single-line CSL change (`.BLOCK_SIZE = MAX_ZDIM` inside stencil module import struct). Bitwise-correct output, all timing fns unchanged. | First verified cycle reduction below Cerebras reference |
| Contract lockdown (Jun 1) | Discovered smoke #1's "24.5× speedup" was metric gaming (`f_tic`/`f_toc` no-op'd + `BLOCK_SIZE_LOCAL` shadow). Added FROZEN section to prompt + `contract_check.py` validator (6/6 tests, catches both gaming patterns) | Validator confirmed working on Track B's 7pt-Stencil run |
| xkernel-bench formalization (Jun 1) | `SPEC_SCHEMA.md` + `BENCHMARK.md` + `baselines_wse3.json` + 6 `spec.yaml` files; `fast_p` scoring rule; spec loader + `task_summary` injection into optimizer prompt | Per-kernel spec format that doubles as the "what the agent sees" surface for W1/W2 split |
| **Track B (Jun 2)** | Hard 4 kernels W1 + `--auto-optimize`: confirmed 0 correctness regressions (1/4 same as before). **7pt-Stencil: 2129 → 1076 cycles (1.98× ≈ fast_2)** via `fmac_bulk` angle. Contract validator caught and rejected a tampering attempt during the same run. | Second real win on 7pt-Stencil; lockdown empirically validated |
| Track C (Jun 2) | 9 already-passing kernels: **9/9 still pass**; auto-optimize gracefully skipped each ("no baseline cycles_send"). Run-time within ±10% of original sweep (noise band). | Zero correctness regression on all 13 already-translated kernels |
| **W1-hidden experiments (Jun 2)** | Removed reference compute file from W1 translate prompt. Smoke v1: 7pt-Stencil 0/8 attempts pass — agent misplaced `@export_symbol` at top level instead of inside `comptime{}`. Added structural-idioms block ((a)). Smoke v2: also 0/8 — agent guesses wrong about layout↔compute interface (which task IDs layout exports, what fields `stencilParams` has, etc.). | **Negative signal that motivates option (b)** — agent needs layout structure, not just language docs |

## Part 2 — Architecture as it stands

### Layout

```
/home/USER/xkernel/
├── code_translation/           # the agentic translator + orchestrator
│   ├── cuda2csl.py             # CUDA2CSLOrchestrator + main()
│   ├── prompt_cuda2csl.py      # 11 prompt templates + builtin whitelist
│   ├── benchmark_csl.py        # cslc + cs_python harness, cycles_send extraction
│   ├── csl_knowledge_base.py   # 3 audience lens functions + 5 corpora composition
│   ├── debugger_agent.py       # v1 structured-JSON debugger
│   ├── contract_check.py       # frozen-fn + frozen-param validator (the lockdown)
│   ├── profile_csl.py          # per-kernel timing + per-PE cycle artifacts
│   ├── csl_mesh_patterns.py    # 8 hand-curated wafer-scale patterns
│   ├── REPIVOT_CYCLES.md       # pivot doc (file-of-record)
│   ├── DEBUGGER_AGENT_DESIGN.md
│   └── results/                # per-run outputs + cross-experiment reports
│       └── saturation_report_and_architecture.md  # the full reference doc
├── knowledge/                  # JSONL corpora + ingestion scripts
│   ├── ingest_tutorials.py
│   ├── ingest_skills.py
│   ├── cerebras_docs.py        # KnowledgeChunk + TF-IDF query
│   └── data/                   # 5 .jsonl corpora (635 total chunks)
└── kernels/                    # 27 CUDA+CSL pairs (xkernel-bench suite)
    ├── BENCHMARK.md            # the benchmark spec
    ├── SPEC_SCHEMA.md          # per-kernel spec.yaml format
    ├── baselines_wse3.json     # measured WSE-3 cycle counts for 5 kernels
    └── <each kernel>/CUDA + CSL + spec.yaml (6 specs landed)
```

### The 4 agent roles (all use the same LLM, different system prompts + threads)

| Agent | Entry point | Lens | Output |
|---|---|---|---|
| **Architect** | `design_architecture()` | `for_architect()` | free-form DESIGN.md |
| **Implementer** | `translate()` body | `for_implementer()` | CSL compute file in a ```csl fence |
| **Reviewer** | `review_failure()` | `for_reviewer()` | verdict dict `{bucket, rationale, debug_action, missing_symbol, design_amendment}` |
| **Debugger** (opt-in, `XKERNEL_DEBUGGER=1`) | `DebuggerAgent.diagnose()` | static bundle | `DebuggerReport` JSON |

### Knowledge composition (per-audience lens functions)

| Lens | Sources composed |
|---|---|
| `for_architect(q)` | ARCHITECT_CONTEXT + mesh-patterns + release-notes + tutorials(arch=3KB) + skills(arch=3KB) |
| `for_implementer(q)` | TYPE_RULES + DSD_PATTERNS + TASK_SYSTEM + WSE3_RULES + KNOWN_GOTCHAS + release-notes + mesh-patterns + tutorials(impl=4KB) + skills(impl=4KB) |
| `for_reviewer(q)` | REVIEWER_CHECKLIST + KNOWN_GOTCHAS + debug-techniques + release-notes + tutorials(rev=2.5KB) + skills(rev=3KB) |

### Repair loop (current state)

```
attempt = 1
while attempt <= effective_limit and wasted_attempts < cap:
    benchmark = _benchmark_current_code()  # compile + run + verify
    if pass: break
    verdict = review_failure()  # bucket A/B/C + rationale + debug_action
    if A: design_architecture(failure_context); replay implementer thread
    elif C: csl_bundle_fix_contract prompt (with REQUIRED FIX: missing_symbol)
    else (B):
        if debugger_should_fire(): inject DebuggerReport block
        csl_bundle_fix_with_review prompt + builtin_whitelist
    reply = llm_call(); extract csl; benchmark; loop
# on first pass with cycles_send AND --auto-optimize:
#   call optimize() — min 5 / max 10 attempts; reject any variant that
#   fails contract_check OR doesn't strictly reduce cycles
```

### Two workflows

| Workflow | Input | Agent sees | Agent does NOT see |
|---|---|---|---|
| **W1** (CUDA → CSL) | CUDA source + spec.yaml task | task_summary + reference_contract (layout.csl + run.py + commands_wse3.sh) + CUDA | **reference compute CSL (after Jun 2 W1-hiding change)** |
| **W2** (existing CSL → optimize) | a CSL file + spec.yaml task | the input CSL labeled "current code at N cycles" + task_summary + reference_contract | the reference compute CSL is never labeled as "reference" |

### Two metrics

| Metric | Source | When |
|---|---|---|
| `cycles_send` | `run.py`'s `tic()/toc()` interval | 7 of 27 kernels print it (W2-eligible for fast_p) |
| `run_time_ms` | wall-clock around `cs_python run.py` | all kernels; noise 1–10%, dominated by sim startup/memcpy/Python verify |

---

## Part 3 — The success and the setback

### 🟢 The success — 7pt-Stencil

Two independent runs (smoke #2 W2, and Track B W1) **both produced strictly faster CSL than the Cerebras reference**:

| Run | Workflow | Reference | Best | Speedup | Score |
|---|---|---|---|---|---|
| Smoke #2 | W2 (optimize-only) | 2129 | 1233 | 1.73× | fast_1.5 |
| Track B | W1 (translate + optimize) | 2129 | 1076 | **1.98×** | **fast_2** |

**Why these are real, not gaming**:
- `|y_ref - y_wes| = 0.0` (bitwise-correct output) in both runs
- `contract_check.py` validator confirms `f_tic` / `f_toc` / `f_memcpy_timestamps` / `f_reference_timestamps` bodies match reference byte-for-byte after whitespace normalization
- No top-level param redeclarations or `BLOCK_SIZE_LOCAL` shadows
- Substantive optimizations: smoke #2 changed `.BLOCK_SIZE = BLOCK_SIZE` to `.BLOCK_SIZE = MAX_ZDIM` (eliminates inner-chunk loop overhead); Track B's `fmac_bulk` angle similarly optimized DSD usage

**What this proves**: the framework can produce CSL that strictly beats a Cerebras human-written reference on at least one kernel, with the metric and the lockdown both verified honest. **This is the first evidence the optimizer architecture works.**

### 🔴 The setbacks

**(1) The 1.73×/1.98× result has not generalized.** Track A ran W2 across 5 cycle-instrumented kernels (7pt-Stencil, Power-Method, CG, PCG, BiCGSTAB) under the same configuration. Results:

| Kernel | Track A cycle reduction |
|---|---|
| 7pt-Stencil | **0%** (no improvement — run-to-run variance vs the smoke's 42%) |
| Power-Method | 0% |
| CG | 0.027% (4 cycles, noise) |
| Preconditioned-CG | 0% |
| BiCGSTAB | 0% |

The dominant failure was `no_csl_block` (10/10 attempts on PCG and BiCGSTAB) — gpt-oss-120b declined to emit code when the prompt grew past a threshold on the larger reference compute files (CG/PCG/BiCGSTAB compute files are 9–14 KB on disk).

**(2) The W1-hiding experiment exposed a deeper limitation.** Two smoke runs on 7pt-Stencil with the reference compute hidden:

- **v1** (8/8 fail): agent placed `@export_symbol` at top level instead of inside `comptime{}`. We added a structural-idioms block to the prompt — fix landed.
- **v2** (8/8 fail): agent now gets structural idioms right but **8 different errors in 8 attempts**, all about the layout↔compute interface (which task IDs layout exports, what fields `stencilParams` contains, what params layout passes through). Trajectory: `fabout_dsd undefined` → `width undeclared` → `param unbound` → `EN_STENCIL_1 undeclared` → `comptime DSD with runtime var` → `stencilParams.fabin_dsd missing` → `fabin not a DSD type`.

The validator also caught v2's final attempt tampering with all 4 timing functions — the lockdown saved us from a false-positive but the translation never converged.

**Root cause**: the reference compute file was teaching the agent the **specific protocol** between this kernel's `layout.csl` and `kernel.csl` (which params, which task IDs, which struct fields, in what order). The whitelist + skills + tutorials give it **language knowledge**; nothing in the existing knowledge stack teaches it the **per-kernel interface**.

**(3) Run-to-run variance is meaningful.** 7pt-Stencil produced 3 different cycle outcomes across 3 ostensibly-identical W2 runs: 1233 cycles, 1076 cycles, and 2129 (baseline, no improvement). The framework can find optimizations but doesn't find the same one twice — single-point measurements lack the statistical power to characterize what the framework is reliably capable of.

**(4) The xkernel-bench suite has uneven cycle coverage.** Only 7 of 27 kernels print `cycles_send` from their `run.py`. The other 20 are correctness-only until their `run.py` is instrumented with `tic()/toc()` + the canonical timestamp readback. Per-kernel instrumentation effort is ~30–60 minutes of careful CSL+Python editing (verified against BiCGSTAB and SpMV templates).

---

## Part 4 — The path forward (decisions pending)

Three options on the table for the W1-hiding setback, ranked by recommendation:

| Option | Cost | Likely outcome |
|---|---|---|
| **(1)** Hide compute, **show layout.csl** explicitly in W1 (currently buried inside `reference_contract`, drowned by other content) | ~15 min | High-probability fix — layout *is* the protocol the agent was guessing about; making it explicit gives the agent the interface it needs to translate |
| **(2)** Implement task #93 — agent generates layout.csl from spec, then compute from spec+generated-layout | ~300 LOC + several smoke rounds | More ambitious test of "everything from scratch"; closed-loop interface (agent decides params, then uses them) makes it self-consistent by construction; harder to validate |
| **(3)** Roll back W1-hiding entirely; reference compute shown as in Track B | ~5 min | Restores the working W1 that achieved fast_2; accepts the agent leans on reference as worked example |

A separate parallel question is whether to invest the ~3-hour `run.py` instrumentation work on GEMM / GEMV / Cholesky / Mandelbrot to expand the fast_p scoreboard from 7 kernels to 11.

The choice gates the next experiment.
