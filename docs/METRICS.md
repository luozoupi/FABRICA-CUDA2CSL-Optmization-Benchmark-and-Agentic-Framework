# Scoring metrics for xkernel-bench (2026-06-24)

The benchmark scores an agent's CUDA→CSL translation **primarily by `cycles_send`** —
the on-device hardware cycle count of the timed compute window (`f_tic`/`f_toc` reading
the WSE timestamp counter). Wall-clock time is deliberately NOT used: the suite runs on
the WSE simulator, where wall-time is dominated by simulator startup + memcpy + Python
verification, none of which reflects on-device compute (`benchmark_csl.py` `_extract_kernel_cycles`).

But a single raw cycle number isn't honest for every kernel. A kernel declares its
metric class in `spec.yaml` via an optional `metric:` field (default `cycles`, so all
existing specs are unchanged). Read by `cuda2csl.resolve_metric()`.

## The three classes

### 1. `cycles` (default)
The timed window contains the **agent's own inline compute** and the work is
**data-independent** (fixed trip count for a given problem size), so a single
`cycles_send` is stable and attributable to the translation.
- Examples: GEMM, GEMV, Wide-Mult, Residual, Single-Tile-Matvec, Tensor-Transpose,
  PDFT, Laplacian2D-Halo, 7pt-Stencil, Game-of-Life, Power-Method, BiCGSTAB, the
  Collectives-2D kernels, **Jacobi-2D-5pt**.
- `spec.yaml`: omit `metric:` (or `metric: cycles`).

### 2. `normalized_cycles` (data-dependent work)
The compute is the agent's, but per-input/per-PE work VARIES (sparsity, particle count,
iteration count), so a raw cycle number is unstable. Score **cycles per work-unit** on a
**pinned, deterministic configuration** (fixed seed, RNG-interpolation off, etc.).
- Examples: SpMV-Hypersparse (per `2*nnz+m`), MC-Particle-Transport (per particle).
- `spec.yaml`:
  ```yaml
  metric:
    class: normalized_cycles
    work_unit: "2*nnz + m"
    reason: "per-row sparsity varies; normalize to make cycles comparable across matrices"
  ```
- The run.py should emit BOTH raw `cycles_send` and the normalized figure; the pinned
  config is part of the build (e.g. `--use_rng_interp false`, fixed `--seed`).

### 3. `correctness_only` (library-delegated compute)
The kernel's compute is DELEGATED to an SDK library import (the agent writes a thin
wrapper, not the algorithm). A cycle count would measure the **library**, not the
translation — so it is not a meaningful optimization target. Score **pass/fail** only.
- Examples: 3D-FFT (`<kernels/fft/fft3d_layout>`), SpMV (hypersparse_spmv library).
- `spec.yaml`:
  ```yaml
  metric:
    class: correctness_only
    reason: "compute delegated to <kernels/fft/...>; cycles would measure the SDK lib, not the agent"
  ```
- The harness already supports this: a pass with `cycles_send=None` survives (the
  dead-timer floor only fires on an int, `benchmark_csl.py`), and `--auto-optimize`
  cleanly reports "no baseline target" instead of erroring.

## How to choose
- Does the **agent** write the timed compute (vs an SDK library)? No → `correctness_only`.
- Is the per-input work **fixed** for a given size? No → `normalized_cycles` (pin + normalize).
- Otherwise → `cycles` (the default).

## Scoreboard reporting
Group results by class. Only `cycles` / `normalized_cycles` kernels carry a speed
("beats-expert") claim; `correctness_only` kernels report pass/fail. This keeps the
headline honest: we never present a library's cycle count as the agent's achievement.

## Why not wall-time anywhere?
Same reason for all classes: on a simulator, wall-time measures the sim host, not the
wafer. Even for `correctness_only` kernels we report pass/fail, not seconds. If the suite
ever runs on real WSE hardware, `cycles_send` remains the apples-to-apples metric
(hardware-independent of host load); wall-time would still be reported only as a
secondary diagnostic, never the scored figure.
