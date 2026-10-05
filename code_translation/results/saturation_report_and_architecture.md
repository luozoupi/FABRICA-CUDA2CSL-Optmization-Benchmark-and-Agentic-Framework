# Saturation report + agentic framework architecture

**Date:** 2026-06-01
**Status:** corpus-stacking and prompt-engineering phase closed; debugger sub-agent landed but unmeasured.

This single document covers two things the project now needs in one place:

1. **Saturation report** — what every A/B has shown, and the diagnosis that the implementer model is the binding ceiling on the 4 hard kernels.
2. **Architecture reference** — how the agentic CUDA→CSL framework is actually wired (files, classes, prompts, knowledge layers, env gates, repair-loop routing). This is the source-of-truth doc for anyone touching the system; it reflects the code at this commit, not an earlier design.

---

# Part 1 — Saturation report

## 1.1 Headline

After **5 independent A/B experiments** across **3 frontier models** on the same **4 consistently-failing kernels**, no intervention has produced a pass-count delta exceeding the run-to-run noise floor (±1 pass). Summary table:

| Intervention | gpt-oss-120b | Sonnet 4.6 | Opus 4.7 |
|---|---:|---:|---:|
| Baseline (reviewer + debug-recipes + mesh + release-notes) | 1/4 | 1–2/4 | 1–2/4 |
| + Mesh patterns (8 hand-curated patterns) | Δ=0 | Δ=0 | Δ=0 |
| + Tutorials broad (217 chunks, 33 tutorials) | Δ=0 | Δ=0 | Δ=0 |
| + Tutorials narrow (29 chunks, 4 hand-picked tutorials) | Δ=0 | — | — |
| + Skills corpus (328 chunks from cerebras-csl-skills) | Δ=0 | Δ=0 | Δ=0 |
| **+ @-builtin whitelist (hard constraint in prompt)** | **Δ=0** | **Δ=0** | **Δ=−1** (within noise) |

The 4 hard kernels and their failure signatures:

| Kernel | Typical failure |
|---|---|
| **Game-of-Life** | Returns 0 bytes (PE never sends results — fabric/queue wiring wrong) |
| **Residual** | Implementer hallucinates `@my_pe_x` / similar builtins; compile error |
| **7pt-Stencil** | **Passes consistently** (model already produces correct CSL) |
| **FFT-1D-2D** | Executes but numerical mismatch (algorithm fidelity issue) |

## 1.2 Diagnosis

The corpus stack has been **fully saturated**. The pass/fail boundary on these kernels is **not** moved by:
- more reference material below the implementer (5 corpora tested)
- structural prompt rules naming the right idioms (whitelist tested)
- multi-agent routing (reviewer with bucket A/B/C + architect respin already wired)

Run-to-run variance is **±1 pass** on these 4 kernels at the K config baseline — observed when the same Sonnet baseline scored 2/4 in one earlier sweep and 1/4 in the next without any code change. Therefore single-point A/B comparisons over 4 kernels × 3 models × 2 configs (the budget we've been running) **lack the statistical power** to detect anything smaller than ±1 pass-count delta.

## 1.3 What DID change — qualitative

Even though pass count didn't move, the corpora and the whitelist genuinely altered behavior:

1. **Whitelist eliminated `@my_pe_x` hallucinations entirely.** Pre-whitelist Residual runs had the implementer reaching for `@my_pe_x` / `@pe_*` / similar fake builtins on every attempt. Post-whitelist Residual runs only emit `@`-tokens from the 62 proven builtins. The failure mode *shifted* to a different bug (a `comptime { var = ... }` mis-scope) which we then patched into the whitelist's anti-pattern list. The whitelist is doing its job at the level it was designed for.
2. **Skills cited 3 chunks per kernel** in every L-config run (per audience: implementer skills like SKILL-DSDS / SKILL-BUILTINS / SKILL-SIMD). The implementer reads them and ignores them at the action level. The retrieval is working; the application isn't.
3. **Reviewer's `SUGGESTED_DEBUG_ACTION` quality is high** across all configs — it correctly localized the `comptime` issue, the `@my_pe_x` problem, the FFT numerical question. The implementer treats it as an optional hint.
4. **Sonnet passed Residual for the first time** during the tutorials A/B (cross-model report), showing that **at the right model + the right knowledge configuration, kernels we'd called "hard" do pass** — they just don't do so reliably across runs.

## 1.4 Implementer is the binding ceiling

Five independent context interventions and one prompt-structure intervention all land at zero pass-count delta. The remaining levers are not on the input side:

- **Implementer model**: stronger Claude / GPT release would likely move the floor. Out of our control absent the model becoming available.
- **Debugger sub-agent with structured patch**: forces the reviewer's debug action through a structured slot the implementer is told to apply verbatim. **Code landed; not yet measured.** This is the last in-pipeline intervention before we'd be replicating runs for variance estimation.
- **Replication for variance estimation**: run a single config 5 times back-to-back to get a true noise floor. Required before claiming any future ±1 shift is meaningful.
- **More/different kernels**: extend the set so a ±1 pass-count delta is a smaller fraction of the total. The 4-kernel set was chosen as "consistently failing"; success rates above 25% would carry less noise.

The next experiment to run is the debugger A/B (#72); after that, replication or kernel-set extension.

## 1.5 What the whitelist A/B specifically showed (just landed)

| Model | M (whitelist OFF) | N (whitelist ON) | Wall M | Wall N |
|---|---:|---:|---:|---:|
| gpt-oss-120b | 1/4 (7pt) | 1/4 (7pt) | 35.7 min | 40.9 min |
| Sonnet 4.6 | 1/4 (7pt) | 1/4 (7pt) | 64.2 min | 63.1 min |
| **Opus 4.7** | **2/4** (Residual + 7pt) | 1/4 (7pt) | 39.0 min | 50.4 min |

- The Opus-M Residual pass is the **only Residual pass anywhere in this whole sweep series**.
- Within-run runtime shifts: Opus FFT-1D-2D **30% faster with whitelist** (3911 vs 5533 ms), Sonnet FFT-1D-2D **27% faster** (3926 vs 5383). gpt-oss FFT-1D-2D 56% **slower** (6066 vs 3890). No clean pattern.
- Net pass-count: **0** across all three models when read within the ±1 noise band.

## 1.6 Cumulative experiment ledger

| # | Date | Experiment | Models | Outcome |
|---|---|---|---|---|
| 18 | 2026-05-28 | Mesh patterns A/B | gpt-oss | Δ=0 |
| 30 | 2026-05-29 | Reviewer A/B (B/G configs) | gpt-oss + Sonnet | Δ=0 net (Sonnet showed bucket-routing wins on individual kernels) |
| 38 | 2026-05-29 | Reviewer A/B on Opus | Opus | Δ=0 |
| 60 | 2026-05-30 | Tutorials A/B broad | gpt-oss | Δ=0 |
| 62 | 2026-05-30 | Tutorials A/B on Claude | Sonnet + Opus | Δ=0 |
| 63 | 2026-05-30 | Tutorials narrow ablation | gpt-oss | Δ=0 (narrow ≥ broad qualitatively) |
| 67 | 2026-05-31 | Skills A/B (gpt-oss) | gpt-oss | Δ=0 |
| 68 | 2026-05-31 | Cross-model skills A/B | Sonnet + Opus | Δ=0 |
| 71 | 2026-05-31 | Whitelist A/B | all 3 | Δ=0 net |
| 72 | queued | Debugger A/B | all 3 | TBD |

---

# Part 2 — Architecture reference

The framework lives in `/home/USER/xkernel/` with three top-level subtrees:

```
/home/USER/xkernel/
├── code_translation/       # the agentic translator + orchestrator
├── knowledge/              # JSONL corpora + ingestion scripts
└── kernels/                # 21 CUDA reference kernels + their CSL bundles
```

## 2.1 Top-level data flow

```
CUDA source (kernels/<name>/CUDA/kernel.cu)
        │
        ▼
   ┌──────────────────────────────────────────────────────────┐
   │ CUDA2CSLOrchestrator (cuda2csl.py:414)                   │
   │   one orchestrator instance per kernel                   │
   │                                                          │
   │   1. analyse_cuda    ──► self.cuda_analysis              │
   │   2. design_architecture ──► self.decomposition_plan     │
   │   3. translate (loop):                                   │
   │      • implementer call  ──► self.current_code           │
   │      • benchmark_current_code (compile + run + verify)   │
   │      • if pass: return                                   │
   │      • else: review_failure ──► verdict {bucket, ...}    │
   │              if bucket A: design_architecture again      │
   │              if bucket B: [debugger fire?] + fix prompt  │
   │              if bucket C: contract repair prompt         │
   └──────────────────────────────────────────────────────────┘
        │
        ▼
   CSL bundle (kernels/<name>/CSL/) + translation_log.json + final_result.json
```

Output lands in `code_translation/results/cuda2csl/run_<TS>/<kernel>/` with full message history, all attempt artifacts, and the reviewer's verdicts.

## 2.2 The three agents

All three agents are **the same LLM with different system prompts and different conversation threads**. There is no separate model per agent in v1.

| Agent | Entry point | Thread | Knowledge lens | What it emits |
|---|---|---|---|---|
| **Architect** | `design_architecture()` | own thread, no persistence | `csl_knowledge_base.for_architect()` | `decomposition_plan` (free-form DESIGN.md) |
| **Implementer** | `translate()` body | persists in `self.messages`, replayed across attempts | `csl_knowledge_base.for_implementer()` | CSL compute file in a ```csl fence |
| **Reviewer** | `review_failure()` | own thread, no persistence | `csl_knowledge_base.for_reviewer()` | `verdict` dict: `{bucket: A/B/C, rationale, missing_symbol, debug_action, design_amendment, raw}` |
| **Debugger** (v1, opt-in) | `DebuggerAgent.diagnose()` (debugger_agent.py:280) | own thread, no persistence | static read-only bundle (failing CSL + stderr + layout.csl + reviewer rationale + builtin whitelist) | `DebuggerReport` JSON: `{diagnostic_run, diagnostic_output, diagnosis, recommended_patch, confidence}` |

### Architect details

**Prompt template:** `q_design_architecture` (prompt_cuda2csl.py:84) — explicitly instructs the agent **not to write CSL code**, only to reason about decomposition, memory layout, fabric topology, and to cite mesh-pattern names by retrieval. Output is consumed verbatim as `self.decomposition_plan`.

**Optional inputs:**
- `failure_context` (when invoked during a bucket-A respin) — appends the failure rationale + reviewer's `DESIGN_AMENDMENT` to the prompt
- Respin cap: `MAX_ARCHITECT_RESPINS=2` by default, env-overridable via `XKERNEL_FORCE_RESPIN_CAP`. Subsequent A verdicts are demoted to B.

### Implementer details

**Three prompt templates** (all in prompt_cuda2csl.py):
- `q_translate_cuda_to_csl_bundle` — initial translation (line 103)
- `csl_bundle_fix_with_review` — bucket-B/A-fallback fix prompt (line 442)
- `csl_bundle_fix_contract` — bucket-C contract repair prompt (line 482)

**Persistent thread**: `self.messages` carries the system prompt + analysis turn + every translation/repair attempt. On context overflow, `_llm_call_with_trim_on_overflow()` retries with [system, analyse_q, analyse_a, last_user_prompt] only.

**Initial-translate retry**: if the model returns no ```csl fence, up to 3 retries with a one-line nudge (no attempt-budget consumed).

**Wasted-attempt accounting**: in the repair loop, if `extract_code_block` returns nothing, decrement the attempt counter and bump `wasted_attempts` (capped) so the implementer never "loses" an attempt to a malformed reply.

### Reviewer details

**Prompt template:** `q_review_failure` (prompt_cuda2csl.py:379) — the agent must emit a verdict in a regex-parseable format:

```
BUCKET: <A|B|C>
RATIONALE: <one sentence, ≤200 chars>
MISSING_SYMBOL: <required for bucket C only>
SUGGESTED_DEBUG_ACTION: <concrete diagnostic step>
DESIGN_AMENDMENT: <required for bucket A only>
```

**Bucket semantics:**
- **A** = architectural failure — wrong decomposition, wrong tiling, wrong collective topology → architect respin
- **B** = implementation bug — DSD built inside a loop, missing cast, color collision, etc. → implementer fix
- **C** = contract violation — exported symbol renamed, task ID changed, new file introduced → contract repair

**Robust parser** (`_parse_reviewer_verdict` at cuda2csl.py:647) — falls back to bucket B with a "defaulted" rationale on any parse failure. Never raises.

### Debugger details (v1, behind `XKERNEL_DEBUGGER=0`)

**File:** `code_translation/debugger_agent.py` (357 LOC)

**Fire decision** (`should_fire()`): all of
- `XKERNEL_DEBUGGER != "0"`
- `bucket == "B"`
- `debug_action` non-empty
- either (a) `debug_action.startswith(verb)` where verb ∈ `{run, grep, cslc, compile, trace, wavelet, csdb, inspect, cs_readelf, check, verify}`, OR (b) current failure_reason matches previous attempt's (repeat detection via normalized 80-char prefix)
- per-kernel fire count < `DEBUGGER_MAX_FIRES_PER_KERNEL` (= 1)

**v1 inputs (no real tool use)**: failing CSL + stderr tail + reviewer rationale + reviewer debug action + reference contract + layout.csl body (read via `read_layout_csl()`). The system prompt explicitly tells the agent "you have no real tool access — set confidence to 'low' or 'unknown' if you can't justify a claim from the bundle".

**v1 output**: a single-line JSON object with 5 string fields. The orchestrator parses it (robust to markdown fences and extra prose), packages it as a prompt block via `DebuggerReport.to_prompt_block()`, and injects it into the bucket-B fix prompt via the `{debugger_report}` slot. On fire failure (LLM error / parse error) the orchestrator proceeds without the debugger — pure-additive design.

**v2 (deferred)**: real tool surface (`cslc_dry_compile`, `grep_corpus`, `read_kernel_file`). Spec at `code_translation/DEBUGGER_AGENT_DESIGN.md`.

## 2.3 Knowledge layer (`code_translation/csl_knowledge_base.py`)

The implementer doesn't query corpora directly — it gets context via **lens functions** that compose multiple knowledge sources per audience.

### Three lenses

| Lens | Sources composed (in order) | Used by |
|---|---|---|
| `for_architect(query)` | `ARCHITECT_CONTEXT` (hard prose) + mesh-patterns + release-notes + tutorials (audience=architect, 3 KB) + skills (audience=architect, 3 KB) | architect prompts |
| `for_implementer(query)` | `TYPE_RULES + DSD_PATTERNS + TASK_SYSTEM + WSE3_RULES + KNOWN_GOTCHAS` + release-notes (3 KB) + mesh-patterns (5 KB) + tutorials (audience=implementer, 4 KB) + skills (audience=implementer, 4 KB) | initial translate + fix prompts |
| `for_reviewer(query)` | `REVIEWER_CHECKLIST + KNOWN_GOTCHAS` + debug-techniques (3.5 KB) + release-notes (1.5 KB) + tutorials (audience=reviewer, 2.5 KB) + skills (audience=reviewer, 3 KB) | reviewer prompts |

### Five JSONL corpora (`knowledge/data/*.jsonl`)

| Corpus | File | Chunks | Bytes | Built by | Per-lens dispatch |
|---|---|---:|---:|---|---|
| SDK release-notes | `cerebras_sdk_docs.jsonl` | 77 | 99 KB | hand-curated | all 3 lenses |
| Debug techniques | `cerebras_debug_techniques.jsonl` | 12 | 23 KB | hand-authored | reviewer only |
| Tutorials (broad) | `cerebras_tutorials.jsonl` | 217 | 344 KB | `knowledge/ingest_tutorials.py` | section filter: `tutorial_readme_{architect,reviewer}` and `tutorial_csl_implementer` |
| Tutorials (narrow) | `cerebras_tutorials_narrow.jsonl` | 29 | 50 KB | manual subset (FIFO + collectives + debug + routes) | same dispatch, opt-in via `XKERNEL_TUTORIALS_KB_PATH` |
| **Skills (NEW 2026-05-31)** | `cerebras_skills.jsonl` | 328 | 443 KB | `knowledge/ingest_skills.py` | section filter: `csl_skill_{architect,implementer,reviewer}` |

All corpora share the `KnowledgeChunk` schema (`knowledge/cerebras_docs.py:46`) and the TF-IDF scorer in `CerebrasKnowledgeBase`. Per-section dispatch was added by extending `prompt_context()` to accept `sections=` (passthrough to `query()`).

### Mesh patterns

`code_translation/csl_mesh_patterns.py` — 8 hand-curated wafer-scale CSL patterns from WaferLLM (allreduce, ping-pong, halo exchange, …). `retrieve(query, top_k=3, max_chars=5000)` does keyword scoring; consumed by architect + implementer lenses.

### Environment gates (all disable cleanly)

| Env var | Default | Effect |
|---|---|---|
| `XKERNEL_TARGET_SDK` | `1.4.0` | Filter corpus chunks by SDK version |
| `XKERNEL_TARGET_ARCH` | `wse3` | Architecture filter |
| `XKERNEL_DEBUG_TECHNIQUES` | `1` | Toggle debug-techniques in reviewer lens |
| `XKERNEL_TUTORIALS` | `1` | Toggle tutorials across all lenses |
| `XKERNEL_TUTORIALS_KB_PATH` | (unset) | Override tutorials corpus path (used for narrow ablation) |
| `XKERNEL_SKILLS` | `1` | Toggle skills corpus |
| `XKERNEL_SKILLS_KB_PATH` | (unset) | Override skills corpus path |
| `XKERNEL_MESH_PATTERNS` | `1` | Toggle mesh patterns in architect + implementer |
| `XKERNEL_BUILTIN_WHITELIST` | `1` | Toggle hard @-builtin constraint in implementer prompts |
| `XKERNEL_DEBUGGER` | `0` | Enable debugger sub-agent (opt-in, additive) |
| `XKERNEL_FORCE_RESPIN_CAP` | `2` | Override architect respin cap |
| `XKERNEL_LLM_TIMEOUT_S` | — | Per-LLM-call timeout |

Every gate is one-line, fail-soft, and reads `os.getenv` inside the function (no import-time capture).

## 2.4 Repair loop routing (cuda2csl.py:`translate`)

```
attempt = 1
while attempt <= effective_limit and wasted_attempts < cap:
    benchmark = _benchmark_current_code()        # compile + run + verify
    if benchmark.status == "pass": break
    if --skip-reviewer: verdict = {bucket: B}
    else:                verdict = review_failure(current_code, benchmark, reference_contract)

    if bucket == "A" and architect_respin_count >= MAX_ARCHITECT_RESPINS:
        verdict.bucket = "B"  # demote; rationale tagged

    if bucket == "A":
        architect_respin_count += 1
        design_architecture(... failure_context=failure_ctx)
        # reset implementer thread to [system, analyse_q, analyse_a]
        implementer prompt = q_translate_cuda_to_csl_bundle (with new design)
    elif bucket == "C":
        implementer prompt = csl_bundle_fix_contract (with missing_symbol)
    else:  # bucket B (default)
        if debugger_should_fire(bucket, debug_action, cur_reason, prev_reason, fires_used):
            report = DebuggerAgent.diagnose(...)
            debugger_report_block = report.to_prompt_block()
            debugger_fires_used += 1
        implementer prompt = csl_bundle_fix_with_review (with reviewer + debugger + whitelist)

    previous_failure_reason = benchmark.failure_reason  # for next iter's repeat detection
    reply = llm_call(self.messages)
    repaired = extract_code_block(reply, "csl")
    if not repaired: wasted_attempts++ ; continue  # don't consume attempt
    self.current_code = repaired
    attempt += 1
```

Two attempt-budget mechanisms:
- `reviewer_max_attempts` (CLI flag, default 8) — total benchmark attempts
- `wasted_attempts` (capped) — attempts that produced no CSL fence and so don't count

## 2.5 The builtin whitelist (`prompt_cuda2csl.py:14`)

A 3.4-KB structural prompt block that names:
- 62 **proven** `@`-builtins (union of every builtin used in `/home/USER/csl-examples/tutorials/` + `/benchmarks/`)
- The canonical **PE coordinate idiom** (`layout_mod.get_x_coord()` — NOT `@my_pe_x`)
- A **`comptime { var = ... }` anti-pattern** caught in our own logs
- 5 **named anti-patterns** for hallucinated `@send_to_neighbor`, `@allocate_circbuf`, `@cuda_*`, etc.

Injected at the **END** of the 3 implementer prompts via the `{builtin_whitelist}` slot — recency-favored so the rule sits closest to the model's response. Env-gated by `XKERNEL_BUILTIN_WHITELIST` (default ON); call sites wired in `cuda2csl.py` at the 5 implementer format() calls.

## 2.6 Kernel registry (`cuda2csl.py:95`)

21 entries. Each is a dict: `{cuda_path, reference_csl_dir, target_relpath, commands_script, arch}`. The `_k(name, target)` helper builds the standard entry (`arch=wse3`, `commands_script=commands_wse3.sh`).

**Recent additions:**
- 3 graded halo-exchange kernels: `Laplacian2D-Halo` (fully verified, max abs diff = 0), `Laplacian2D-Reduce`, `LorenzoPredictor-Tile`
- `MC-Particle-Transport` registered with `arch=wse2` — reference-only (singularity build flow, not compatible with default WSE-3 sweep harness)

## 2.7 LLM transport

`workflow_common.py` handles both backends:
- **Anthropic API** (Claude Sonnet / Opus via Argo proxy `~/.argo-api-key.txt`) — `create_anthropic_client` + `is_anthropic_model`
- **OpenAI-compatible** (ALCF sophia/vllm endpoint for gpt-oss-120b) — `create_openai_client`, Globus token sourced via `inference_auth_token.py`

`llm_complete(client, model, messages, max_tokens)` is the single entry point; transparently dispatches by client type. `_llm_call_with_trim_on_overflow()` retries with trimmed conversation history on context-overflow errors only (not on transport errors).

## 2.8 Result artifacts (per kernel)

| File | Producer | Content |
|---|---|---|
| `final_result.json` | `write_final_artifacts` | top-level kernel status + best benchmark + experience-store summary |
| `translation_log.json` | orchestrator | full `self.messages` history (every prompt + every response) |
| `<target>.csl` | implementer | the final CSL compute file written into the bundle |
| `bundle_metadata.json` | orchestrator | reference contract + commands script path + arch |
| `benchmark.json` | `_benchmark_current_code` | per-attempt compile + run + verify records, with reviewer verdict stashed under `reviewer_verdict`, debugger output under `debugger_report` |
| `env_check.json` | startup | SDK + venv readiness probe |
| `optimization_summary.json` | (if optimizer ran) | per-step delta |

Per-batch: `code_translation/results/.../batch_<TS>/results.json` aggregates pass/fail/wall across all kernels in the sweep.

## 2.9 Test harness scripts (top-level)

| Script | Purpose |
|---|---|
| `run_alcf_sweep_one.sh` | Single model × N kernels via ALCF (Globus auth) |
| `run_argo_sweep_one.sh` | Single model × N kernels via Argo (Claude) |
| `run_ab_tutorials.sh` / `..._claude.sh` / `..._narrow.sh` | tutorials A/B variants |
| `run_ab_skills.sh` / `run_ab_skills_claude.sh` | skills A/B variants |
| `run_ab_whitelist.sh` | builtin whitelist A/B across all 3 models |

Each sweep launcher: declares `XKERNEL_*` env vars + invokes the appropriate `run_*_sweep_one.sh` per config, writes `ab.log` for terminal markers, drops `results.json` per config under a `<ts>` root.

## 2.10 What's deliberately NOT done

- **Real tool use** in any agent — v1 debugger is prompt-only; reviewer + architect have no tools either
- **Cross-attempt memory beyond the conversation thread** — the experience store records attempts to disk but doesn't feed back into prompts
- **Optimizer in the default sweep** — `optimize()` exists for the legacy CSL-optimization path but the staged-optimization step list (`task_simplify`, `buffer_cleanup`, etc.) isn't invoked during translation sweeps
- **Per-agent model selection** — every agent uses `self.model`; no architect=Opus / implementer=gpt-oss split. `analysis_model` is the only per-phase override.
- **Profile feedback** — `profile_feedback_enabled` exists but stays off in the agentic-translation runs

---

# Part 3 — What to do next (sequenced)

1. **Smoke the debugger** end-to-end on Residual (~15 min) — verify it actually fires and emits a parseable report when invoked against a real LLM
2. **Run debugger A/B** (#72) — same 4 kernels × 3 models × {debugger OFF, debugger ON}; ~5-6h wall
3. If debugger A/B is also null, the next move is **replication for variance estimation** — 5 back-to-back runs of one config to nail down the actual noise floor, since every future ±1 claim depends on that number
4. If the noise floor is large (which the cross-model report's evidence suggests it is), the binding constraint is the kernel set itself — extending it with kernels that pass ~50% of the time would give the A/B harness statistical resolution it currently lacks

Everything below the implementer is now well-instrumented and saturated. The remaining work is either (a) the debugger lever or (b) measurement infrastructure for variance.
