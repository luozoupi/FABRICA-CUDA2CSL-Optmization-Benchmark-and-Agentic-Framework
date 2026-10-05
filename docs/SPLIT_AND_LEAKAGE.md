# Train/Test Split & Leakage Policy (xkernel-bench)

**Version:** v1.0 (2026-06-20). First-class, versioned. Every "the agent beats
the human reference" claim in the paper MUST report on the held-out **test**
split and obey the leakage rules below.

## Why this exists
The publishable claim is "an agent discovers wafer-scale decompositions from CUDA
that beat human-written CSL." That claim is only credible if the test kernels'
references were never (a) shown to the translator, (b) used as retrieval
exemplars, or (c) the source of a knowledge-base pattern. This doc defines the
taxonomy, the split, and the leakage rules that make the claim leak-free.

## 1. Kernel taxonomy (`task_class` in spec.yaml)
- **real-translation** — CUDA expresses the explicit compute; CSL must express
  the explicit compute. A genuine translation task. (e.g. GEMM, GEMV, 7pt-Stencil,
  the iterative solvers, Laplacian2D-Halo, Game-of-Life, Mandelbrot, Residual.)
- **library-wrapper** — both sides just call a library; "translation" is
  cuFFT-call → SDK-fft-call, not algorithm work. **Quarantined from the
  translation track.**
  - **3D-FFT**: CUDA calls `cufftPlan3d/cufftExec*`; CSL calls
    `<kernels/fft/fft3d_layout>`. Library↔library → **QUARANTINE.**
  - **FFT 1D-2D**: mixed — CUDA implements radix-2 in-kernel, CSL delegates to
    `ucode_1d/2d`. Also has a severe size mismatch (CUDA N=1024 vs CSL Nz=4) and
    a CSL-side library dependency → **QUARANTINE** until re-scoped as an explicit
    butterfly translation at matched size.
- **algorithm-level** — requires re-deriving the algorithm, not a line-by-line
  port (e.g. data-dependent control flow needing static-graph reformulation:
  Mandelbrot's escape-iteration loop). Kept in-track but flagged; needs the WS3
  static-graph pre-pass.

## 2. Leakage sources audited (2026-06-20)
- **Reference CSL → translator:** ALREADY hidden. `cuda2csl.py` injects only
  CUDA + task + layout.csl + run.py + commands.sh; a compute-leak canary
  (`_assert_no_compute_leak`, asserted on every `_llm_call`) fails the run if the
  reference `pe.csl` leaks. (The old `SPEC_SCHEMA.md` wording "shown as worked
  example" was stale; fixed.)
- **Knowledge base ↔ WaferLLM:** the KB *cites* WaferLLM's MeshGEMM as an
  external pattern in `knowledge/data/cerebras_debug_techniques.jsonl` and
  `csl_mesh_patterns.py` carries a `two_hop_async_fabric_dma` pattern. WaferLLM's
  SUMMA / MeshGEMM / MeshGEMV overlap the GEMM/GEMV references → any GEMM/GEMV
  result that used those patterns is parity-ceilinged / leaky. **Policy: GEMM and
  GEMV are TRAIN-only** (they may seed patterns); they do NOT count toward the
  held-out "beat the expert" claim. (Alternatively, WS3 rebuilds the patterns
  from non-benchmark sources and re-qualifies them — until then, train-only.)
- **Optimization catalog (W2 wins):** `per_row_dsd_unroll`,
  `hoist_comptime_constants`, etc. are distilled from W2 accepts on specific
  kernels. When WS4 feeds the catalog into the W1 implementer, a catalog entry
  derived from a TEST kernel must be excluded for that kernel (leave-one-out at
  the pattern level).

## 3. The split (`split` field in spec.yaml)
Principle: **test** kernels are real-translation, non-quarantined, and free of
WaferLLM/catalog overlap on their own reference. **train** kernels may seed
patterns/retrieval.

| split | kernels (initial) | rationale |
|---|---|---|
| **train** (pattern/retrieval pool) | GEMM, GEMV (WaferLLM overlap); GEMM-Collectives-2D, GEMV-Collectives-2D (collectives idiom source); Power-Method, CG, PCG, BiCGSTAB (solver family, on-device idiom source) | may contribute KB patterns + retrieval exemplars |
| **test** (held-out; the claim) | 7pt-Stencil, Laplacian2D-Halo, Cholesky, Residual, Game-of-Life, Single-Tile-Matvec, Wide-Multiplication; **Tensor-Transpose-021, PDFT-Pi-Pipeline** (mrh/gpu); **hand-written-compute (2026-06-24): SpMV-CSR, Histogram-1PE, Stencil7pt-1PE, DFT-1PE, GEMM-1PE** | real-translation, no WaferLLM-pattern dependence on their own reference |
| **quarantine** (out of translation track) | 3D-FFT (library-wrapper), MC-Particle-Transport (no run.py / WSE-2 only) | not valid translation tasks as-is |

### Family-paired splits: simple (test) vs library-decomposition (train)
Several families now have BOTH a simple hand-written kernel and a complex
library/collective kernel. The hand-written one is the leak-free held-out **test**
kernel; the library/collective one stays **train** (its decomposition overlaps SDK/
WaferLLM patterns in the KB). This pairs an honest beats-expert claim (simple, no leak)
with a pattern-source kernel (complex, leaky) in the same family:
- **GEMM:** GEMM-1PE (hand-written dense triple-loop) = **test**; GEMM-Collectives-2D
  (SUMMA via collectives_2d, MeshGEMM overlap) = **train**.
- **SpMV:** SpMV-CSR (hand-written CSR matvec) = **test**; SpMV-Hypersparse (vendored
  hypersparse lib, wse2-only) = out-of-track.
- **Histogram:** Histogram-1PE (hand-written binning) = **test**; Histogram (multi-PE
  `<kernels/tally>` lib) = test-but-correctness_only.
- **Stencil / FFT:** Stencil7pt-1PE / DFT-1PE (hand-written) = **test**; the
  library-delegated 7pt-Stencil / FFT-1D-2D / 3D-FFT carry their own caveats.

(This is the initial assignment; finalize after the WS1.2 crossover confirms each
test kernel has a runnable `large` size. Mandelbrot/LorenzoPredictor/Laplacian2D-
Reduce are skeleton/algorithm-level → held until correctness is real.)

### External-source kernels (mrh/gpu, added 2026-06-23) — leakage-clean
**Tensor-Transpose-021** (a new tensor index-permutation family) and
**PDFT-Pi-Pipeline** (the first `program-level` task — a 3-stage data-dependent
pipeline) are manually authored from `MatthewRHermes/mrh` `gpu/src/pm/
device_cuda.cpp` (GPU quantum chemistry). The source is EXTERNAL to this
benchmark: it is not a WaferLLM/SUMMA derivative and is not a KB pattern source
or retrieval exemplar, so neither kernel's reference can leak into its own
translation. Both verified full-bar on WSE-3 (compile + run + numpy correctness +
cycles_send): transpose 6,183 cyc; PDFT pipeline 128,308 cyc. They are held-out
**test** kernels. `program-level` = the CUDA is multiple data-dependent kernels;
the agent must translate the whole pipeline + intermediate buffers, a harder
difficulty tier than single-kernel translation.

## 4. Leakage rules (enforced)
1. No **test** kernel's reference CSL is ever shown to the W1 translator (canary).
2. No **test** kernel's reference is a retrieval exemplar for itself
   (leave-one-out) — and ideally exemplars come only from the **train** pool.
3. No KB mesh-pattern that overlaps a **test** kernel's reference is active when
   translating that kernel (WaferLLM-overlap patterns → GEMM/GEMV are train-only).
4. No optimization-catalog entry distilled from a **test** kernel is injected
   when translating that kernel.
5. Results tables separate **train** (development) from **test** (the claim).

## 5. Reporting
The headline metric — fast_1+ subset where the agent's from-CUDA translation
beats the human reference at the **large** size — is computed ONLY over the
**test** split, with multi-seed variance and this policy version cited.

## 6. Input-level train/test split (2026-06-24) — anti-hardcoding
The §1–§5 split is **kernel-level** (which kernels may seed patterns/exemplars). It
does NOT stop a kernel from hardcoding the *answer* to its own shown input. That is a
separate axis, added 2026-06-24 after the Cholesky false pass.

**Why it's needed.** The W1 agent is shown `run.py` (the host contract), which contains
both the input construction and the reference-answer computation. With a deterministic
input, a kernel can reproduce the answer without computing it.

**Mechanism.** Each kernel's `spec.yaml` may carry an `eval:` block:
```yaml
eval: {train_seed: 7, heldout_seeds: [101, 202, 303], seed_env: "XKERNEL_EVAL_SEED"}
```
`run.py` builds its input from `os.environ[seed_env]` (default = train seed) and
recomputes the reference answer from the drawn input. After a train-seed pass, the
harness re-scores correctness on the held-out seeds (`benchmark_csl.evaluate_heldout`,
gate `XKERNEL_HELDOUT_EVAL`). A hardcoded answer passes train but fails held-out.

**Leakage rule (firewall).** `heldout_seeds` are HARNESS-ONLY. `spec.yaml` is never
injected into a prompt, so the agent sees the *mechanism* (`XKERNEL_EVAL_SEED`) but
never the held-out values. Enforced by `HeldoutSeedLeakTest` (test_no_compute_leak.py)
and by the harness setting the values only via `SINGULARITYENV_`-prefixed env vars.

**Status.** Piloted + WSE-3-validated on Cholesky, Single-Tile-Matvec, Residual; the
false-pass stub is rejected on every held-out seed; default-off pending roll-out. Full
detail + per-kernel gaming-risk audit: `docs/INPUT_SPLIT_AND_FAILURE_AUDIT_20260624.md`.

## Provenance / audit trail
Taxonomy + leakage verified by two read-only code audits (2026-06-20): FFT
library-wrapper confirmed (3D-FFT cuFFT↔fft3d_layout); reference-hidden canary
confirmed in cuda2csl.py; WaferLLM citation confirmed in
cerebras_debug_techniques.jsonl + csl_mesh_patterns.py. See
`code_translation/results/` and `docs/PAPER_METHODOLOGY.md`.

## 7. Attention tasks (added 2026-09-08)

`Attention-QP` and `Attention-1PE` import the hand-written SIMD attention
kernel of the authors' separate `attention-wse` project as their CSL reference
(expert-tuned, not merely validated). Leakage audit: the retrieval corpus
(`knowledge/data/*.jsonl`, `knowledge/explored/ingest/*.jsonl`) contains no
attention, flash-attention or softmax-over-QK^T material, and `attention-wse`
was never ingested; the reference `pe.csl` is hidden from the agent
(`hidden_from_optimize_only`) and covered by the compute-leak canary. Both
tasks are `split: test`. The CUDA sources were written for this benchmark (one
thread per query row) and describe the math, not the CSL structure.
