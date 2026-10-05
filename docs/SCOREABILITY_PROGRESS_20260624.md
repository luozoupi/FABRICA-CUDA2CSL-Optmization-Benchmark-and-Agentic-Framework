# Benchmark scoreability — progress, challenges, and proposed fixes (2026-06-24)

This documents the push to make the xkernel benchmark suite fully scoreable to the
agent: what was addressed, what challenges remain, and concrete proposed fixes.

## Headline

The suite went from **~7/22 effectively-scoreable** (fragmented; several kernels
not-scoreable for unclear reasons) to **25/29 cycle-scoreable + 1 correctness-only =
26/29 scoreable** with a principled metric policy. The remaining 3 are well-defined
engineering tasks with documented blockers, not open questions.

## Metric policy (the framing that made "scoreable" well-defined)

Every kernel declares a metric class in `spec.yaml` (`cuda2csl.resolve_metric`):
- **`cycles`** (default) — agent writes the timed compute; data-independent work →
  `cycles_send` is the speed metric. (24 kernels)
- **`normalized_cycles`** — data-dependent work → cycles per work-unit on a pinned config.
- **`correctness_only`** — compute delegated to an SDK library → score pass/fail (a cycle
  count would measure the library, not the agent). (Histogram, multi-PE)

Primary metric is cycles; the others are opt-in per kernel with a stated reason. No
wall-time anywhere (simulator: wall-time measures the sim host, not the wafer). See
`docs/METRICS.md`.

## What was ADDRESSED this session

### A. New kernels registered / made scoreable (7)
- **Jacobi-2D-5pt** — already a complete WSE-3 bundle; registered (cycles).
- **Histogram** — WSE-2→WSE-3 ported (data-task/input-queue migration + queue-init);
  registered (correctness_only; multi-PE tally via SDK lib). See `docs/WSE3_PORTING.md`.
- **Hand-written-compute family (5)** — real-translation counterparts to library-delegated
  kernels, so the agent writes the actual arithmetic and cycles measure its work
  (`docs/HANDWRITTEN_KERNELS.md`):
  | kernel | replaces library | cycles |
  |---|---|---|
  | SpMV-CSR | hypersparse_spmv + allreduce | 6,927 |
  | Histogram-1PE | `<kernels/tally>` | 6,191 |
  | Stencil7pt-1PE | stencil_3d_7pts + allreduce | 40,497 |
  | DFT-1PE | `<kernels/fft>` | 145,233 |
  | (7pt-Stencil-1PE counted as Stencil7pt-1PE) | | |

### B. Cycle instrumentation added to kernels that lacked a metric (3)
On-device TSC timing, each WSE-3-validated:
- **Mandelbrot** — streaming pixel pipeline; tic on first pixel, toc on last (pinned
  max_iters). cycles_send=41,023.
- **GEMV-Checkerboard** — streaming data-task kernel (no host launch); tic on first
  wavelet, toc when local y=A*x completes. cycles_send=197.
- **FFT-1D-2D** — bracket the synchronous butterfly mod.fft()/ifft() (excludes the async
  transpose). cycles 422/486/408/461 across fwd/inv × 1D/2D.

### C. Integrity infrastructure (earlier this session, supporting all of the above)
- Input-level train/test split (`eval:` block, held-out seeds) — anti-hardcoding, on all
  hand-written kernels + 8 others.
- Metric-class system + registry-coverage test (every registered kernel resolves its
  files) + `test_registry_and_metric.py`.

## Reference-baseline sweep (all scoreable kernels)

Sweep `scoreable_sweep_20260624` — each kernel's REFERENCE bundle compiled + run on the
WSE-3 simulator, recording SUCCESS + cycles_send (the agent-translation baseline).

**Result: 26/26 PASS** — every scoreable kernel's reference compiles, runs on WSE-3, and
emits its metric. (Reference baselines = the targets the agent's translations are scored
against.)

| kernel | cycles | metric | | kernel | cycles | metric |
|---|---:|---|---|---|---:|---|
| 7pt-Stencil | 2,129 | cycles | | Jacobi-2D-5pt | 1,566 | cycles |
| BiCGSTAB | 59,385 | cycles | | Laplacian2D-Halo | 1,709 | cycles |
| CG | 11,635 | cycles | | Mandelbrot | 41,023 | cycles* |
| Cholesky | 12,476 | cycles | | PDFT-Pi-Pipeline | 128,308 | cycles |
| DFT-1PE | 145,233 | cycles | | Power-Method | 43,436 | cycles |
| FFT-1D-2D | 422 | cycles* | | Preconditioned-CG | 13,826 | cycles |
| GEMM | 51,753 | cycles | | Residual | 674 | cycles |
| GEMM-Collectives-2D | 51,738 | cycles | | Single-Tile-Matvec | 780 | cycles |
| GEMV | 4,007 | cycles | | SpMV-CSR | 6,927 | cycles† |
| GEMV-Checkerboard | 197 | cycles* | | Stencil7pt-1PE | 40,497 | cycles† |
| GEMV-Collectives-2D | 4,003 | cycles | | Tensor-Transpose-021 | 6,183 | cycles |
| Game-of-Life | 7,838 | cycles | | Wide-Multiplication | 81,741 | cycles |
| Histogram | (pass) | correctness | | Histogram-1PE | 6,191 | cycles† |

\* cycle instrumentation added this session (was no-metric).  † hand-written-compute
kernel added this session (real-translation counterpart to a library-delegated reference).

## Remaining CHALLENGES (3 kernels) + proposed fixes

These are genuine engineering tasks, each with a specific blocker (verified empirically):

### 1. Laplacian2D-Reduce — incorrect device reduction
- **Status:** compiles + runs, but the device computes the WRONG value (device nrm = 8.0
  vs reference 72.0). `VERIFY=False` in run.py flags this; the cross-PE max-reduction
  merge on py=0 PEs is unfinished.
- **Proposed fix:** complete the cross-PE max-reduction (the partial-column norms must be
  merged across the py axis before the final max). The numpy reference + launch window +
  cycle timing are all already in place — only the device reduction logic is wrong. Once
  correct, flip `VERIFY=True`; it becomes cycles-scoreable immediately.

### 2. LorenzoPredictor-Tile — device stall
- **Status:** compiles, but STALLS at runtime (D2H 0/256 bytes, then crashes).
  `VERIFY=False`; the NW-scalar routing / inter-tile plumbing is incomplete.
- **Proposed fix:** finish the diagonal (NW) neighbor routing so every tile receives its
  predictor inputs before computing; resolve the fabric deadlock (likely a missing
  receive-before-send or an uninitialized queue, à la the C3/Histogram pattern). Then
  flip `VERIFY=True`.

### 3. MC-Particle-Transport — nonstandard harness, likely wse2-only
- **Status:** uses a bespoke `compile.py` + `host_code.py` flow (no `run.py`, no standard
  `cycles_send`/SUCCESS contract); registered as wse3 but the build calls a nonexistent
  `compile.py` in the framework path. Likely upstream-wse2-only (like SpMV-Hypersparse,
  which was confirmed wse2-only by upstream design).
- **Proposed fix:** EITHER (a) write a standard `run.py` + `commands_wse3.sh` that drives
  it via `SdkRuntime` with a TSC window and a `normalized_cycles` (per-particle, RNG-off)
  metric; OR (b) author a hand-written **MC-Particle-1PE** variant (single-PE
  cross-section lookup + tally) in the established hand-written style — likely the lower-
  risk path, mirroring SpMV-CSR/DFT-1PE.

## Broader still-open challenges (beyond the 6)
- **SpMV-Hypersparse / SpMV** — WSE-2-only by upstream design (vendored libs use wse2-only
  fabric idioms; no upstream wse3 build). Addressed instead by the hand-written **SpMV-CSR**
  (real cycle-scoreable translation). Keep the wrappers as correctness_only documentation
  of the "delegate to SDK" task class.
- **Capability frontiers (not scoreability gaps):** iterative solvers (CG/PCG/Power-Method
  numerics), collective-decomposition (GEMV/GEMM-Collectives), and fabric-routing stencils
  (Game-of-Life) are SCOREABLE but the AGENT often fails to translate them — that is the
  benchmark working as intended (honest capability measurement), not a defect.

## Proposed next steps (ranked)
1. **Finish the 2 skeletons' device logic** (Lap2D-Reduce reduction; Lorenzo routing) —
   highest value, makes them cycles-scoreable; reference + timing already in place.
2. **Hand-written MC-Particle-1PE** — lower-risk than porting the bespoke harness.
3. **FFT-radix2 hand-written** (O(N log N)) — a faster, harder FFT-family translation than
   the direct DFT-1PE.
4. **Multi-seed cycle-delta eval** for the cycle-scoreable kernels — turn single-draw
   pass/fail into variance-bounded speed claims (the standing Finding-A discipline).
