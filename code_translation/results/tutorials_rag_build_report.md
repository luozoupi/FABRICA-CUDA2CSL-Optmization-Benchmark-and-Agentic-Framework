# CSL tutorials RAG — build & verification report

Date: 2026-05-30

## What landed

| Deliverable | Status |
| --- | --- |
| `knowledge/ingest_tutorials.py` (~430 LOC) | ✓ idempotent ingestion CLI |
| `knowledge/data/cerebras_tutorials.jsonl` (~700 KB, 217 chunks) | ✓ generated, validated |
| `knowledge/data/tutorials_manifest.json` | ✓ provenance recorded |
| `knowledge/cerebras_docs.py` — `prompt_context(sections=…)` passthrough | ✓ 2-line, backward-compat |
| `code_translation/csl_knowledge_base.py` — `tutorial_context(audience, ...)` + 3 lens edits | ✓ env-gated, audience-routed |
| End-to-end smoke on Residual via gpt-oss-120b | ✓ tutorials cited in prompts; reviewer emits concrete csdb commands |

## Corpus characteristics

- **Source**: `/home/USER/csl-examples/tutorials/` (33 tutorials)
- **Chunks emitted**: 217
  - `tutorial_csl_implementer`: 151 (one per `fn`/`task`/`comptime` block, preamble inlined)
  - `tutorial_readme_architect`: 33 (one prose chunk per tutorial)
  - `tutorial_readme_reviewer`: 33 (same prose, separate section for independent TF-IDF ranking)
- **Top tags**: Tutorial (217), CSL (183), WSE-3 (88), WSE-2 (74), SdkLayout (69), GEMV (67), Queues (67), Fabric (65), DSD (59), MultiPE (40), Beta (36)
- **Benchmarks excluded**: hard-asserted in ingestion + `grep` verification = 0 hits

## Per-agent dispatch

The existing `CerebrasKnowledgeBase.query(sections=…)` filter does the work; no
new retrieval code beyond `tutorial_context()`. Audience → section map:

| Audience | Section filter | Sees |
| --- | --- | --- |
| architect | `tutorial_readme_architect` | README prose only (reasoning, no code) |
| implementer | `tutorial_csl_implementer` | CSL fn/task/comptime worked code (preamble inlined for self-containment) |
| reviewer | `tutorial_readme_reviewer` | README prose (separate copy for independent ranking) |

Each lens function appends `tutorial_context(query, audience=..., max_chars=...)`
after its existing knowledge sources, keeping tutorials *last* so they sit
closest to the user message for best instruction-following recency.

## Lens size impact

Pre- vs post-tutorial bytes injected per lens (query = "GEMV halo"):

| Lens | Before | After | Δ |
| --- | ---: | ---: | ---: |
| `for_architect` | 8,891 | 11,532 | +2,641 |
| `for_implementer` | 11,958 | 16,021 | +4,063 |
| `for_reviewer` | 8,007 | 10,643 | +2,636 |

All still well under any model's context window. With `XKERNEL_TUTORIALS=0`,
sizes return *exactly* to pre-tutorial.

## End-to-end smoke (Residual, gpt-oss-120b, reviewer ON)

- **3 of 3 attempts** received tutorial CSL chunks in the implementer prompt
  (3 occurrences of `cerebras-tutorial-` chunk IDs across the messages list).
- **Reviewer's debug_action recommendations** now name concrete csdb commands:
  - attempt 1: `cslc --show-ast residual.csl`
  - attempt 2: `csdb symbol-list --artifact_dir out`
  - attempt 3: `csdb symbols --artifact_dir out`
  These commands map directly to the debug-recipes corpus authored earlier.
- **Status `fail` not `error`**: one attempt actually produced runnable CSL
  (`run_ms=1765.0`) — the agent reached the simulator instead of crashing at
  compile time, which is the qualitative shift the corpus is meant to enable.

## Files changed (full list)

| Path | Change |
| --- | --- |
| `knowledge/ingest_tutorials.py` | **NEW** — ingestion CLI |
| `knowledge/data/cerebras_tutorials.jsonl` | **NEW** — generated corpus |
| `knowledge/data/tutorials_manifest.json` | **NEW** — provenance |
| `knowledge/cerebras_docs.py` | `prompt_context()` adds `sections=`, `tags=` kwargs |
| `code_translation/csl_knowledge_base.py` | `_TUTORIALS_KB_PATH`, `_TUTORIAL_AUDIENCE_CONFIG`, `tutorial_context()`, 3 lens wiring edits |

## What's NOT touched (per plan constraints)

- `cuda2csl.py` — zero edits. Lens call sites pass through unchanged.
- `prompt_cuda2csl.py` — all prompt templates unchanged.
- `csl_mesh_patterns.py` — independent catalog, unchanged.
- `cerebras_sdk_docs.jsonl` and `cerebras_debug_techniques.jsonl` — independent corpora, unchanged.

## How to use

```bash
# Regenerate the corpus (after upstream tutorials change):
~/bin/micromamba run -n xkernel-agent python knowledge/ingest_tutorials.py

# Check for drift in CI / pre-commit:
~/bin/micromamba run -n xkernel-agent python knowledge/ingest_tutorials.py --check

# Disable tutorial RAG entirely (for A/B comparison):
XKERNEL_TUTORIALS=0 python code_translation/cuda2csl.py --kernel Residual ...
```

## Deferred to future iterations

- **Query expansion** in `design_architecture` (post-process `cuda_analysis` for
  kernel-class hints like stencil/reduction/gemm before retrieval) — defer until
  retrieval-quality measurement justifies it.
- **`for_optimization()` tutorial wiring** — orthogonal to the agent pipeline;
  add when running optimization sweeps.
- **`sdklayout-*` downweighting** — currently tagged `Beta`; observe whether
  these tutorials over-suggest the beta API before adding an exclude filter.
