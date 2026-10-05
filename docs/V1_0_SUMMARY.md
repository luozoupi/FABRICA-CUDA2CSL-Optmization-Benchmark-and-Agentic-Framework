# xkernel v1.0 — CUDA → CSL Agentic Translator

**What this is.** An LLM-agent pipeline that ports GPU (CUDA) kernels to the Cerebras
Wafer-Scale Engine language (CSL), compiles + simulates them, and verifies correctness
against a reference. It includes a benchmark suite of paired (CUDA, CSL) kernels, a
knowledge-injection layer distilled from the CSL SDK, and an experimental harness for
measuring what actually drives translation success.

This document summarizes the architecture, the two workflows, the knowledge system, the
`--no-knowledge` ablation mode, and the empirical findings from the v1.0 development
cycle. For node/SDK setup see [`code_translation/README.md`](../code_translation/README.md);
for the firewall/security invariant see
[`code_translation/FIREWALL.md`](../code_translation/FIREWALL.md).

---

## 1. Architecture

### The translation pipeline (W1: CUDA → CSL)

A four-role agent chain, orchestrated by `code_translation/cuda2csl.py`:

```
CUDA source
   │
   ▼
[1] Analyzer    — summarizes the computation, math, I/O, parallel strategy
   │
   ▼
[2] Architect   — chooses the wafer-scale decomposition (mesh layout, halo/
   │              collectives/ping-pong pattern) → DESIGN memo
   ▼
[3] Implementer — writes the CSL compute file against a FIXED reference bundle
   │              (layout.csl + run.py + commands.sh are given; pe.csl is written)
   ▼
[4] Reviewer ───► benchmark (cslc compile → simulator run → verify vs reference)
   │   ▲              │
   │   │         pass │ fail
   │   └──── route ◄──┘  (A: re-architect / B: re-implement / C: fix contract)
   ▼
PASS: validated CSL  ──►  [optional] Optimize loop (cycle reduction)
```

Key control loops (both honor a `--reviewer-max-attempts` / `--max-optimize-attempts`
cap and exit early on success):

- **Reviewer repair loop** — up to N benchmark+repair cycles; the reviewer triages each
  failure into a route (re-architect / re-implement / fix-contract).
- **Optimize loop** — after a passing baseline, applies cycle-reduction "angles" with a
  best-of-N selector and patience-based early stop. Scored by `cycles_send` vs the
  measured reference.

### The reverse pipeline (W2 / csl2cuda)

`code_translation/csl2cuda.py` ports CSL back to CUDA (used for benchmark enrichment).

### Benchmark suite

`kernels/` holds ~28 kernels, each with paired CUDA + CSL implementations and a
`spec.yaml` (task description, I/O shapes, tolerances, WSE-3 reference cycles,
optimization angles). `kernels/SPEC_SCHEMA.md` documents the format.

---

## 2. The knowledge system (and its three tiers)

Translation prompts are augmented with CSL knowledge assembled in
`code_translation/csl_knowledge_base.py`. v1.0 introduced a **tiered ablation model** that
classifies every knowledge layer:

| Tier | Contents | Role |
|------|----------|------|
| **A — curated / retrieved** | RAG cluster queries, hand-curated W1 failure gotchas, tutorial/skill excerpts, mesh patterns, optimizer experience memory | enrichment; the layers added incrementally during development |
| **B — CSL language primer** | type rules, DSD patterns, task system, WSE-3 rules; architect/reviewer role framing | "what the language is" |
| **C — structure** | the CUDA source, the `layout.csl` skeleton, the reference contract, the builtin whitelist | necessary task inputs (in the prompt templates, not the knowledge functions) |

The **compute-leak firewall** (see `FIREWALL.md`) enforces a hard invariant: the
implementer may see `layout.csl` + `run.py` + `commands.sh` of the reference bundle, but
**never** the reference `pe.csl` (the compute it must reproduce). A canary guard fails the
run if reference compute leaks into any prompt. Injected knowledge is sourced from SDK
tutorials, never from benchmark kernels' own compute.

### `--no-knowledge` ablation mode (v1.0)

A single switch lets you strip knowledge tiers to measure their marginal value:

```bash
# soft: strip TIER-A curated/retrieved knowledge; keep the CSL primer + structure
bash run_cuda2csl_argo.sh --kernel GEMV --no-knowledge \
     --auto-optimize --reviewer-max-attempts 20

# bare: also strip TIER-B (the for_* knowledge functions return empty)
bash run_cuda2csl_argo.sh --kernel GEMV --no-knowledge --bare \
     --auto-optimize --reviewer-max-attempts 20
```

Implemented as a single chokepoint (`csl_knowledge_base.knowledge_tier()`) read by the
four role functions. The reviewer stays active in all modes (do **not** pass
`--skip-reviewer`, which caps the loop at `--turns`). The builtin whitelist (TIER-C) has
its own independent gate and stays on. Tests:
`code_translation/test_no_compute_leak.py::NoKnowledgeBaselineTest`.

---

## 3. Empirical findings (v1.0)

Two complementary results, both from controlled A/B experiments. They are not in tension.

### Finding A — Adding *more* knowledge to the prompt is a dead lever.

Three pre-prompt augmentations were built, A/B-tested, and **discarded**:

| Intervention | Form | Verdict |
|---|---|---|
| `semantic_bridge` | prose CUDA→CSL mapping tables | discard (no lift) |
| `translation_facts` (Opus 4.7) | structured YAML contract facts | discard (0W / 2L / 17T) |
| `translation_facts` (Opus 4.8) | same, re-run on a stronger model | discard (1W / 0L / 17T) — *stronger* discard |

The failure surface these targeted is already covered by existing RAG + the model's
training. More capable models erase even the small perturbation noise. See
`code_translation/results/progress_summary_20260604.md`.

### Finding B — But the knowledge stack *as a whole* is correctness-critical.

A 15-kernel × 3-tier baseline ablation (Sonnet 4.6, loop cap 20):

| Arm | Pass rate |
|-----|-----------|
| full knowledge | **7 / 15** |
| `--no-knowledge` (strip TIER-A) | **1 / 15** |
| `--no-knowledge --bare` (also strip TIER-B) | **1 / 15** |

**6 of 7 kernels that pass with knowledge fail without it, even after 20 repair
attempts.** The only kernel that survives knowledge-stripping is the single trivial
single-PE kernel; every collectives / halo / DSR kernel needs the curated idioms. A
brute-force loop does **not** substitute for knowledge. See
`code_translation/results/baseline_ablation_report_20260616.md`.

### The synthesis

The knowledge stack is at the point of **diminishing returns to additions** (Finding A)
while being **essential in aggregate** (Finding B). The lever for further improvement is
therefore neither "more knowledge" nor "more looping" — it is **model capability** (e.g.
the Sonnet→Opus hybrid promotion path) plus the hard-cluster idioms already curated.

> **Caveat on all sweeps:** Sonnet's run-to-run variance is ±1 kernel on the 15-kernel
> suite (measured). Single-run deltas of one kernel are noise; the findings above rest on
> gaps far larger than that floor. Iterative-solver kernels (Power-Method, BiCGSTAB, CG,
> PCG) have a known measurement caveat — their `cycles_send` is host-RPC-bounded, so
> pass-rate, not cycles, is the meaningful signal there.

---

## 4. Repository layout

```
code_translation/      the agent framework
  cuda2csl.py            W1 orchestrator (analyzer→architect→implementer→reviewer + optimize)
  csl2cuda.py            W2 reverse path
  csl_knowledge_base.py  knowledge tiers + knowledge_tier() ablation chokepoint
  prompt_cuda2csl.py     prompt templates
  benchmark_csl.py       cslc compile + simulator run + verify
  contract_check.py      anti-gaming contract validator
  test_no_compute_leak.py  firewall + ablation tests
  results/               curated reports (bulk sweep output gitignored)
  FIREWALL.md            the compute-leak invariant
  README.md              node topology + SDK setup
kernels/               ~28 paired (CUDA, CSL) benchmark kernels + spec.yaml each
cerebras_validation/   standalone hand-validated kernel (jacobi2d_5pt) + ENVIRONMENT/REPORT
tools/                 A/B replay harness (ab_translation_facts.py) + verdict CSVs
knowledge/             SDK tutorial/skill ingestion (raw corpora gitignored)
scripts/archive/       archived one-off A/B + experiment runners
docs/                  this summary
run_cuda2csl_argo.sh   active launcher (Anthropic via Argo shim)
run_baseline_ablation_sweep.sh   3-arm knowledge-ablation sweep
run_hybrid_sweep.sh    Sonnet→Opus hybrid promotion sweep
```

Excluded from the repo (see `.gitignore`): `sandbox/`, `rl_data/`, `**/out/`,
`**/simfab_traces/`, `*.log`, bulk `results/` — all large and regenerable.

---

## 5. Running it

Prerequisites and node setup: [`code_translation/README.md`](../code_translation/README.md).

```bash
# Single kernel, full pipeline + optimize
bash run_cuda2csl_argo.sh --kernel GEMV --auto-optimize --reviewer-max-attempts 8

# Hybrid sweep (Sonnet first, promote to Opus on hard clusters)
bash run_hybrid_sweep.sh --kernel GEMV --kernel GEMM   # ...

# Knowledge-ablation baseline (3 arms)
bash run_baseline_ablation_sweep.sh --cap 20 --kernel GEMV   # ...

# Tests
micromamba run -n xkernel-agent python3 -m unittest \
  code_translation/test_no_compute_leak.py
```
