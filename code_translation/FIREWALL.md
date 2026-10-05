# Knowledge Firewall — what flows where

The framework has three orthogonal workflows, each with its own knowledge
access policy. This document is the authoritative reference for what
each workflow may read.

## Workflows

- **W1 — Translate** (`cuda2csl.py`): CUDA source → CSL bundle for a
  vendor-shipped kernel under `kernels/`. The agent must NOT see the
  reference CSL it is supposed to produce, or it would just copy it.
- **W2 — Optimize-existing** (`cuda2csl.py --optimize-only`,
  `optimize_explore.py`): take a passing CSL kernel from `kernels/` and
  reduce its `cycles_send`. The agent IS allowed to see the bundle —
  the bundle is its input — but it must not see the same kernel's
  prior optimization accepts in a way that would let it recall the
  answer rather than rediscover it.
- **W3 — Explore (kernel generation)** (`explore_csl.py`): generate a
  new CSL kernel from an idea description. No vendor reference exists,
  no constraint on which catalog knowledge the agent reads.

## Knowledge sources

| Source | Description | Where written |
|---|---|---|
| `csl_knowledge_base.TYPE_RULES` etc | Static prose, hand-curated CSL language facts | in-source constants |
| `cerebras_skills.jsonl` | CSL stdlib reference (the `<time>`, `<math>`, etc modules) | `knowledge/data/` |
| `cerebras_tutorials.jsonl` | csl-examples tutorial chunks | `knowledge/data/` |
| `cerebras_debug_techniques.jsonl` | Symptom → diagnosis pairs | `knowledge/data/` |
| `cerebras_sdk_docs.jsonl` | Crawled SDK release notes | `knowledge/data/` |
| `CSL_OPTIMIZATION_STEPS_CATALOG` | Named angles for W2 (`fmac_bulk`, `comptime_hoist`, `per_row_dsd_unroll`, `hoist_comptime_constants`, ...) | `prompt_cuda2csl.py` |
| `explored/successes/<id>__<ts>/` | **Full CSL bundles** produced by W3 (pe.csl, layout.csl, run.py) | `explore_csl` runs |
| `explored/ingest/explored_tutorials.jsonl` | Leak-checked tutorial-style distillations of W3 successes | `explore_promote.py` |
| `explored/ingest/explored_experiences.jsonl` | Raw kernel-generation outcome rows (success/failure + lessons) | `explore_csl` runs |
| `explored/optimization/accepted/<kernel>__<angle>__<ts>/` | **Full optimized CSL files** from W2 accepts | `optimize_explore` runs |
| `explored/optimization/ingest/optimization_experiences.jsonl` | Distilled per-accept lessons (kernel name + diff_summary text) | `optimize_explore` runs |
| `explored/optimization/experiences.jsonl` | Raw per-attempt rows (all rounds, accept + reject) | `optimize_explore` runs |
| `explored/optimization/trees/<kernel>.json` | Per-kernel accept DAGs | `optimization_tree.py` |
| `explored/optimization/trees/pattern_index.json` | Cross-kernel pattern → (kernel, bundle) index | `optimization_tree.py` |
| `explored/optimization/plans/<kernel>.json` | Planner output (which files to optimize) | `optimization_planner.py` |

## Access matrix

✓ = workflow MAY read | ✗ = MUST NOT read | △ = conditional (see notes)

| Source | W1 translate | W2 optimize | W3 explore |
|---|:---:|:---:|:---:|
| `TYPE_RULES`, `DSD_PATTERNS`, `KNOWN_GOTCHAS` | ✓ | ✓ | ✓ |
| `cerebras_skills.jsonl` | ✓ | ✓ | ✓ |
| `cerebras_tutorials.jsonl` | ✓ | ✓ | ✓ |
| `cerebras_debug_techniques.jsonl` | ✓ | ✓ | ✓ |
| `cerebras_sdk_docs.jsonl` | ✓ | ✓ | ✓ |
| `CSL_OPTIMIZATION_STEPS_CATALOG` (curated) | ✓ | ✓ | △ |
| `CSL_OPTIMIZATION_STEPS_CATALOG` (W3-promoted: `per_row_dsd_unroll`, `hoist_comptime_constants`) | ✓ | ✓ | ✓ |
| `explored/successes/<bundle>/pe.csl` etc | ✗ | ✗ | ✓ |
| `explored/ingest/explored_tutorials.jsonl` (leak-checked) | ✓ | ✓ | ✓ |
| `explored/ingest/explored_experiences.jsonl` (raw) | ✗ | ✗ | ✓ |
| `explored/optimization/accepted/<bundle>/pe.csl` | △ same-kernel only at smoke-test time | △ same-kernel only at smoke-test time | ✗ |
| `explored/optimization/ingest/optimization_experiences.jsonl` | △ other-kernel chunks only (firewall) | △ other-kernel chunks only (firewall) | ✓ |
| `explored/optimization/experiences.jsonl` (aggregate stats) | ✓ | ✓ | ✓ |
| `explored/optimization/trees/<kernel>.json` | △ same-kernel allowed (current-best baseline picking) | △ same-kernel allowed | n/a |
| `explored/optimization/trees/pattern_index.json` | ✓ | ✓ | ✓ |
| `explored/optimization/plans/<kernel>.json` | △ same-kernel allowed | △ same-kernel allowed | n/a |

## How the firewalls are enforced

### 1. W1 and W2 do not reach `explored/successes/`

The path appears only in docstrings inside
`code_translation/optimize_explore.py` (lines 412, 1611) and never as a
filesystem read. `cuda2csl.py` does not reference the path at all. The
W3 generator's outputs are isolated by directory layout — no helper in
`csl_knowledge_base.py` or `prompt_cuda2csl.py` reads from
`explored/successes/`.

### 2. W1 only sees leak-checked W3 distillations

`csl_knowledge_base.tutorial_context()` (line ~960) reads from BOTH
`cerebras_tutorials.jsonl` AND, when present,
`explored/ingest/explored_tutorials.jsonl`. The latter is populated by
`explore_promote.py` only after `_tutorial_leak_check()` confirms the
distilled tutorial does NOT contain identifiers ≥ 6 chars from the
source bundle. The check rejects with stricter regeneration; if both
attempts fail, the tutorial is dropped and a `needs_human_tutorialize`
row is written to the index.

### 3. W2 sees its own kernel's history only via the planner, not via
   the KB chunks

`for_optimizer_explored()` now accepts a `current_kernel` parameter; when
provided, every KB chunk whose title starts with that kernel name is
filtered out before TF-IDF ranking. This prevents Cholesky's own
diff_summaries from being injected into a Cholesky re-optimization round
as if they were impersonal catalog wisdom.

The summary table (aggregate stats per `(kernel_group, angle)`) is NOT
filtered — it carries no per-kernel source code, just counts and
speedup means, so it stays informative without leaking answers.

Same-kernel optimization history IS available via
`optimization_tree.current_best_pe_path()` — but that's a deliberate
baseline-pick, not a hint injected into the prompt. The orchestrator
either uses the prior accept as the literal starting point or it
doesn't; the LLM is never asked to "recall what worked last time" via
prose.

### 4. W3 sees everything (it's the producer, not a consumer of vendor
   benches)

`explore_csl.py` has no firewall on `explored/` — by design. It IS the
mode that produces and consumes that corpus. It cannot leak bench
answers because it has no vendor benches in scope; every artefact it
sees is one it (or a prior W3 round) authored.

## Memory crossover that IS allowed (and useful)

The mechanism W3 → W2 → W1 transfer works through is the catalog itself:

1. W3 (or W2 itself) discovers a pattern in OPEN mode.
2. `optimization_tree.detect_patterns()` recognises the pattern in the
   diff_summary and tags the accept with a pattern_id.
3. `pattern_index.json` accumulates (kernel, accept) entries per pattern.
4. `optimization_tree.promotion_candidates()` flags any pattern_id that
   spans ≥ 3 distinct kernels but is not yet in the named-angle catalog.
5. A human (or future automated promoter) adds the named angle to
   `CSL_OPTIMIZATION_STEPS_CATALOG` with prose, examples, and
   `applicable_groups`.
6. Once promoted, W1 and W2 see it like any other catalog entry — no
   bench-specific identifiers leak because the catalog entry is
   distilled prose, not a copy of any single bundle's source.

This is how `per_row_dsd_unroll` (originally a Laplacian2D-Halo OPEN
insight) went on to win 1.45× on GEMM_Collectives_2D in its first
attempt: distilled, promoted, applied — without GEMM_Collectives_2D ever
seeing Laplacian2D-Halo's source. The same path now exists for
`hoist_comptime_constants` (Cholesky + GEMM + Laplacian2D-Halo).

## How to verify the firewall

```bash
# 1. Confirm W1's translate prompt has zero references to explored/successes
grep -nE "explored/successes" code_translation/cuda2csl.py  # should return nothing

# 2. Confirm tutorial chunks injected into W1's for_implementer are leak-checked
grep -nE "tutorial_leak_check" code_translation/explore_promote.py

# 3. Confirm W2's for_optimization filters same-kernel chunks
grep -nE "current_kernel" code_translation/csl_knowledge_base.py code_translation/optimize_explore.py

# 4. Live confirmation. The KB renders only chunk *bodies* (not titles)
# into the prompt context, so to prove the firewall worked we check that
# Cholesky-specific identifiers from the diff_summary bodies disappear
# when the filter is active. `col_buf_dsd`, `invsqrt`, and the cycle
# number `11702` are unique to Cholesky's prior accepts.
python3 -c "
import csl_knowledge_base as kb
ctx_unfiltered = kb.for_optimizer_explored('cholesky', kernel_group='linalg')
ctx_filtered   = kb.for_optimizer_explored('cholesky', kernel_group='linalg', current_kernel='Cholesky')
for marker in ('col_buf_dsd', 'invsqrt', '11702'):
    assert marker in ctx_unfiltered, f'expected {marker!r} in unfiltered context'
    assert marker not in ctx_filtered, f'{marker!r} leaked through firewall'
assert len(ctx_filtered) < len(ctx_unfiltered)
print(f'firewall ok: unfiltered={len(ctx_unfiltered)} chars, filtered={len(ctx_filtered)} chars')
"
```
