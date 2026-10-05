# Hand-written compute vs library-delegated kernels (2026-06-24)

## The question
Several benchmarks score `correctness_only` because their CSL reference DELEGATES the
compute to an SDK/vendored library (3D-FFT → `<kernels/fft>`, SpMV / SpMV-Hypersparse
→ `hypersparse_spmv` + `allreduce2R1E`, Histogram's tally → `<kernels/tally>`,
7pt-Stencil → `stencil_3d_7pts`). A cycle count there measures the *library*, not the
agent's translation — so it's not a real optimization target.

**Can we hand-write the compute instead of calling the library, making these genuine
cycle-scoreable translation tasks?** Yes — and it's the better benchmark.

## Why this is the right move
1. **The CUDA sources are simple, explicit algorithms** (not library calls):
   - SpMV: `for j in [row_ptr[r], row_ptr[r+1]): sum += val[j] * x[col_idx[j]]` — a
     textbook CSR matvec (kernels/SpMV/CUDA/kernel.cu:44-46).
   - Histogram: `for i: output[bucket(input[i])]++` — bin counting (kernel.cu:40-46).
   - 3D-FFT: cuFFT calls, but the math is a separable radix-2 butterfly — and we ALREADY
     hand-code radix-2 in CSL (kernels/FFT 1D-2D/CSL/fft.csl).
2. **A real translation task** measures what the benchmark is FOR: the agent writes the
   actual arithmetic (indexed gather + fmac, bin increment, butterfly), and `cycles_send`
   over an `f_tic/f_toc` window measures the agent's compute. Library-wrapper translation
   is "call spmv_mod.spmv()" — near-zero translation content.
3. **The pattern is already proven in this repo.** The beats-expert wins —
   Wide-Multiplication, Tensor-Transpose-021, PDFT-Pi-Pipeline — are all HAND-WRITTEN
   inline-compute references (single-PE / small-mesh, real arithmetic, TSC-timed), not
   library wrappers. We just apply the same authoring pattern to the lib-only kernels.
4. **It sidesteps the WSE-3 library-port wall.** SpMV-Hypersparse is upstream-wse2-only
   and its libs use wse2 fabric idioms; porting the wrapper means re-deriving Cerebras's
   own unported library. A fresh hand-written single-PE/small-mesh kernel is wse3-native
   from the start.

## Proposed: hand-written reference kernels (a new, honest benchmark family)
Author small, self-contained CSL references that do the REAL compute, sized so they fit
a single PE or a small mesh (like Single-Tile-Matvec / Residual / Wide-Mult). Each:
`commands_wse3.sh` + a `pe.csl` with inline arithmetic + `f_tic/f_toc` + a `run.py`
printing `cycles_send` + a gated invariant verifier (per docs/METRICS.md, with the
input-split `eval:` block so it's anti-hardcoding from day one).

| candidate | hand-written core | size | metric | tractability |
|---|---|---|---|---|
| **SpMV-Dense / SpMV-CSR-1PE** | CSR loop: indexed gather of x[col_idx[j]] + fmac into y[row] | single PE, small N | cycles | **HIGH** — trivial loop, the gather is the only CSL nuance |
| **Histogram-1PE** | per-element bucket index + increment a local hist[] | single PE | cycles | **HIGH** — already inline; drop the fabric tally, sum locally |
| **FFT-radix2-1PE** | reuse the existing fft.csl butterfly as the compute, time it | single PE, power-of-2 N | cycles | **MEDIUM** — fft.csl exists; needs a clean 1-PE harness + timing (this is also T2 for FFT-1D-2D) |
| **Dense-3D-stencil / 3D-FFT-small** | separable 1D FFTs (hand butterfly) over a small cube | small | cycles | **MEDIUM-HARD** — 3 axes + transposes |

These do NOT replace the existing library-wrapper references (those stay as
`correctness_only`, documenting the "delegate to SDK" task class). They ADD a
hand-written translation variant that is cycle-scoreable — strictly more benchmark
coverage, and the variant that actually exercises the agent's compute-translation skill.

## Naming / split
Register as distinct kernels (e.g. `SpMV-CSR` separate from `SpMV`) so the scoreboard
shows both the library-wrapper (correctness_only) and the hand-written (cycles) task.
Mark hand-written ones `split: test` (they're new, no WaferLLM/pattern overlap) and give
them an `eval:` block (randomized input, held-out seeds) so they're anti-hardcoding from
the start.

## Recommended first build
**SpMV-CSR single-PE** — highest tractability, directly answers "hand-write the compute
the hypersparse library hides," and the CUDA reference is a 3-line loop. Author pe.csl
(CSR arrays in PE memory, gather+fmac loop, TSC window) + run.py (random sparse matrix,
`y_ref = A@x` invariant check, prints cycles_send) + spec.yaml (metric: cycles, eval:
block). Validate on WSE-3, then it's a real beats-expert-eligible translation task.

## STATUS — hand-written-compute family BUILT (5 kernels, all WSE-3-validated)
Each is single-PE, explicit arithmetic (no library), TSC-timed, `metric: cycles`, with
an input-split `eval:` block. All validated on the simulator (first try) + registered.

| kernel | library/complex sibling it pairs with | compute | ref cycles | agent (full sweep) | commit |
|---|---|---|---:|---|---|
| **SpMV-CSR** | hypersparse_spmv + allreduce | CSR matvec (gather + fmac) | 6,927 | 6,927 (1.00×) | c11f58e |
| **Histogram-1PE** | `<kernels/tally>` | per-element binning (div/mod + indexed inc) | 6,191 | 4,117 (**1.50×**) | 9906517 |
| **Stencil7pt-1PE** | stencil_3d_7pts + allreduce | 3D 7-point weighted sum + boundary guards | 40,497 | 5,843 (**6.93×**) | 3cd8552 |
| **DFT-1PE** | `<kernels/fft>` / fft.csl | direct O(N²) DFT complex MAC | 145,233 | 13,147 (**11.05×**) | 2920940 |
| **GEMM-1PE** | GEMM-Collectives-2D (SUMMA) | dense triple-loop fmac C=A*B | 119,197 | (next sweep) | 41cae9e |

These ADD to (don't replace) the library/collective references, which stay as the
`correctness_only`/train "delegate to SDK or decompose" task class. Both task styles are
now represented for the SpMV, Histogram, stencil, FFT, and GEMM families. **In the
2026-06-24 agent sweep, the hand-written kernels delivered: DFT-1PE 11×, Stencil7pt-1PE
6.9×, Histogram-1PE 1.5× beats-expert, SpMV-CSR parity — every one that ran either beat
expert or hit parity.** GEMM-1PE is registered + reference-validated (119,197 cyc); its
agent score lands in the next sweep.

### Family-paired split (simple test / complex train) — see SPLIT_AND_LEAKAGE.md §3
The hand-written kernel is the leak-free **test** kernel (no library, no WaferLLM-pattern
overlap → beats-expert-eligible); its complex library/collective sibling stays **train**.
e.g. GEMM-1PE (test) vs GEMM-Collectives-2D (train, MeshGEMM overlap).

- **3D-FFT-small — intentionally NOT built (marginal).** A separable 3D DFT is just the
  DFT-1PE compute applied along 3 axes with transposes — much more code for the same
  conceptual coverage the DFT-1PE already provides (the FFT family is represented). If a
  multi-axis variant is wanted later, build it by composing 3 DFT-1PE passes + a
  transpose; not worth the complexity for benchmark coverage now.
- **FFT-radix2 (faster O(N log N))** — a possible follow-on: an FFT-structured (butterfly)
  hand-written kernel would be a harder, faster translation than the direct DFT. The
  existing kernels/FFT 1D-2D/CSL/fft.csl is a starting point. Deferred (the DFT already
  covers the "hand-write the transform vs call the lib" point).

## Expert references: Attention-QP, Attention-1PE (2026-09-08)

Unlike the `*-1PE` operators, whose references are validated scalar loops, the
attention tasks use an expert-tuned reference (query-parallel PE grid, K/V
replicated, DSD + `@fmacs`/`@fmaxs`/`@fmuls` inner loops; 6.7x faster than the
scalar version of the same layout at P=4, S=64, d=32). "Beats the reference"
on these tasks therefore means beating expert code. `compute()` is the frozen
timing wrapper; the agent edits `attention()`. Sizes p2/small/p8 give a
PE-count axis (4/16/64 PEs).

Host contract (2026-09-08, after the first translation pilot): the imported
layouts declared the output `O` with `@export_name("O", [*]f32, false)` and a
`const` pointer, unlike every other task (`true` + `var` pointer). The agent
spent 6 of 10 attempts on that mismatch, so both attention kernels now follow
the suite convention; the reference cycles are unchanged (838,551 / 21,089 /
68,764 / 65,962, re-measured). The build scripts use literal `--params`
(`test_commands_scripts.py`), because the compile-only dry check and the
hardware porter read the `cslc` line verbatim.
