# Cerebras-side validation report — jacobi2d_5pt

**Date:** 2026-06-15
**SDK:** Cerebras SDK 1.4.0 (container image `sdk-cbcore-202505010205-2-ef181f81.sif`)
**Backend:** WSE-3 simulator (cs_python via singularity wrapper)
**Source:** manual hand-translation; no agent framework involvement
**Reference for CUDA:** new — small clean reference written for the issue
formula (`kernels/Jacobi-2D-5pt/CUDA/kernel.cu`). The upstream
`MMichel/CudaJacobi` and `navdeeprana/cudaFiniteDifferences` repos were
reviewed but neither implements the issue's exact stencil (`B[i,j] = 0.25 *
(A[i-1,j] + A[i+1,j] + A[i,j-1] + A[i,j+1])`): MMichel is the Jacobi linear
solver Ax=b (GEMV-shape), navdeeprana is a 4th-order central-difference
derivative kernel in CUDA Fortran.

## Deviations from the issue's file-name list — and why

The issue's "Target kernel uses existing files" list named six artifacts that
were assumed to already exist in the repo (`kernel.cu`, `expected_ir.json`,
`plan.json`, `pseudo_dsl.py`, `cpu_reference.py`, `TRACE.md`). The first
existed in concept but not yet on disk; the other five were assumed
milestone-1 *agent* outputs — and there is no milestone-1 agent in this repo.
Per the user's direction to "manually translate and generate the
corresponding CSL pair to enrich the benchmarks," I produced an explicit,
faithful manual translation rather than fabricating the missing
intermediate-IR artifacts. Concretely:

| Issue-listed file | Resolution |
|---|---|
| `kernels/jacobi2d_5pt/kernel.cu` | **Created** as `kernels/Jacobi-2D-5pt/CUDA/kernel.cu`. Implements the issue's exact stencil + preserved-boundary policy. Verified self-consistent (the embedded CPU reference matches the device kernel to 0 max abs error). |
| `expected_ir.json` | **N/A.** No milestone-1 IR artifact exists for this kernel in this repo; manual translation does not require one. The de-facto "IR" is the issue's plain-English plan reproduced in `cerebras_validation/jacobi2d_5pt/README.md`. |
| `plan.json` | **N/A.** Same reason; the plan ("2D block mapping, halo=1, N/S/E/W, interior update only, boundary preserved") is documented inline in `README.md` and `spec.yaml`. |
| `pseudo_dsl.py` | **N/A.** No pseudo-DSL stage in this repo. The Python reference is `check_output.py:jacobi_step_preserved_boundary`. |
| `cpu_reference.py` | **Equivalent: `check_output.py`** — exposes `jacobi_step_preserved_boundary` and `jacobi_n_steps` so an external harness can compute the reference without invoking the SDK. |
| `TRACE.md` | **N/A.** This document (`REPORT.md`) plus the inline notes in `README.md` cover the same ground (decomposition, file inventory, verification evidence) without a separate trace file. |

## Deviations from the issue's "Suggested files" list

| Issue-suggested file | What I shipped |
|---|---|
| `layout.csl` | shipped verbatim |
| `pe_program.csl` | shipped as `pe.csl` — matches the canonical filename used across all 27 kernels in this repo (`kernels/*/CSL/pe.csl`). Behaviorally identical; only the name differs. |
| `run.py` | shipped — slimmer than before; the input generation and reference compute have been factored out (see next two rows). |
| `input_generator.py` | shipped — `make_input(H, W, seed=7)` plus a CLI for ahead-of-time `.npy` dump. Imported by `run.py`. |
| `check_output.py` | shipped — `jacobi_step_preserved_boundary`, `jacobi_n_steps`, `check_correctness` plus a CLI that prints `NUMPY_CORRECTNESS_PASS` / `NUMPY_CORRECTNESS_FAIL`. Imported by `run.py`. |
| `README.md` | shipped |

## Standalone helper usage (post-hoc verification path)

`input_generator.py` and `check_output.py` are independently invokable so the
same correctness check can be applied to any output (live simulator, hardware
run, alternative CSL implementation) without bringing up `SdkRuntime`:

```bash
cd cerebras_validation/jacobi2d_5pt
PATH="/home/USER/cs_sdk-1.4.0:$PATH" cs_python input_generator.py 8 8 /tmp/A.npy
# (your harness writes /tmp/out.npy here)
PATH="/home/USER/cs_sdk-1.4.0:$PATH" cs_python check_output.py /tmp/A.npy /tmp/out.npy --iters 1
# → prints NUMPY_CORRECTNESS_PASS or NUMPY_CORRECTNESS_FAIL with concrete max abs error
```

Verified 2026-06-15: PASS case (correctly-computed expected output) prints
`NUMPY_CORRECTNESS_PASS` with `max_abs_error=0.000e+00`; FAIL case (zeroed
output as a negative control) prints `NUMPY_CORRECTNESS_FAIL` with
`max_abs_error=9.780e-01`.

## Headline table (issue-mandated format)

| Kernel | Source | CSL compile | Simulator run | NumPy correctness | Hardware run | Notes |
|---|---|---|---|---|---|---|
| jacobi2d_5pt | manual CSL adapted from existing Laplacian2D-Halo template | **PASS** | **PASS** | **PASS** | NOT_EVALUATED | Adapted layout/pe/run from `kernels/Laplacian2D-Halo/`. Only kernel-level difference is `pe.csl:f_compute` boundary policy (preserved vs zero-Dirichlet) and the matching numpy reference. Both 1-iter and 5-iter runs produce max_abs_error=0.000e+00 vs numpy reference at fp32. cycles_send (1 iter) = 1566 cycles ≈ 1.84 μs. Bundle promoted to `kernels/Jacobi-2D-5pt/` as a permanent benchmark addition; spec.yaml + CUDA reference + CSL bundle all in place. |

## Detailed evidence

### Task 1 — SDK environment

Per `ENVIRONMENT.md`:
- SDK 1.4.0 installed at `/home/USER/cs_sdk-1.4.0/`.
- Container image: `sdk-cbcore-202505010205-2-ef181f81.sif`.
- `cslc` and `cs_python` available with `PATH=/home/USER/cs_sdk-1.4.0:$PATH`.

### Task 2 — Official CSL example smoke

Bundle: `csl-examples/tutorials/gemv-04-params` (smallest single-PE bundle).

```
PATH="/home/USER/cs_sdk-1.4.0:$PATH" bash commands_wse3.sh
```

Output (excerpt):
```
[INFO] === Beginning compilation ===
[INFO] Compilation successful
[INFO] === Calling container-hosted python ===
SUCCESS!
```

Verdict: **SDK_SMOKE_PASS**. Toolchain healthy.

### Task 3 — Manual jacobi2d_5pt CSL

Files at `cerebras_validation/jacobi2d_5pt/`:
- `layout.csl` — 2x2 PE mesh, 4 cardinal fabric colors (C_N/C_S/C_E/C_W),
  sentinel color 15 for edge PEs' missing neighbors, color routing identical
  to `kernels/Laplacian2D-Halo/CSL/layout.csl`.
- `pe.csl` — tasks: `f_send` (stage halos + async fabric send/recv),
  `f_rx_done` (counter-based completion), `f_compute` (**preserved-boundary
  5-pt stencil — the only material difference from Laplacian2D-Halo**),
  `f_exit` (cmd-stream unblock). In-kernel iteration loop via
  `remaining_iters`.
- `input_generator.py` — `make_input(H, W, seed=7)` plus a CLI for
  ahead-of-time `.npy` dump. Used by `run.py` and standalone post-hoc
  verifiers.
- `check_output.py` — `jacobi_step_preserved_boundary`, `jacobi_n_steps`,
  `check_correctness` plus a CLI that prints `NUMPY_CORRECTNESS_PASS` /
  `NUMPY_CORRECTNESS_FAIL` for any (input, output) `.npy` pair.
- `run.py` — host driver: imports `make_input` + `jacobi_n_steps` +
  `check_correctness` from the helpers, cliff-distributes onto the 2x2 mesh,
  launches `step(iters)`, reads back, compares.
- `commands_wse3.sh` — `cslc --arch=wse3 ... -o=out --memcpy --channels=1`
  then `cs_python run.py --name out --iters 1`.

### Task 4 — CSL compile

```bash
cd cerebras_validation/jacobi2d_5pt
PATH="/home/USER/cs_sdk-1.4.0:$PATH" bash commands_wse3.sh
```

Output:
```
[INFO] === Beginning compilation ===
[INFO] Compilation successful
```

Verdict: **CSL_COMPILE_PASS**. No warnings, no errors. Single-pass clean compile.

### Task 5 — Simulator run

Output (continuing the same run):
```
[INFO] === Calling container-hosted python ===
Jacobi-2D-5pt: H=8, W=8, mesh=2x2, tile=4x4, iters=1, boundary=preserved
cycles_send = 1566 cycles
time_send = 1.8424 us
```

Run completes without timeout, error, or hang. Verdict: **CEREBRAS_SIM_RUN_PASS**.

### Task 6 — NumPy correctness

Continuing the same run:

```
input dtype       = float32, shape = (8, 8)
tolerance         = 1e-05
max_abs_error     = 0.000e+00
boundary policy   = preserved (Dirichlet)
SUCCESS!
```

Per-axis details:
- **Input shape:** `(8, 8)` (H=8, W=8 = Mt·height x Nt·width = 4·2 x 4·2).
- **Dtype:** `float32`.
- **Input generator:** `np.random.seed(7); A = np.random.rand(H, W).astype(np.float32)` — deterministic, same generator the CUDA reference can use.
- **Tolerance:** `1e-5` (absolute, fp32).
- **Max absolute error:** `0.000e+00` (exact bit-equal — fp32 stencil avg is order-deterministic when both sides apply the operations in the same order).
- **Boundary handling:** Preserved verbatim. Cells at i==0, i==H-1, j==0, j==W-1 mirror the corresponding input cells unchanged. Interior cells get the standard 5-pt average.

Multi-iteration smoke (independent of the headline run):
```
Jacobi-2D-5pt: H=8, W=8, mesh=2x2, tile=4x4, iters=5, boundary=preserved
cycles_send = 6002 cycles
time_send = 7.0612 us
max_abs_error = 0.000e+00
SUCCESS!
```

5 iterations also produce exact match — the in-kernel iteration loop with
ping-pong via `tile`/`new_tile` is working correctly.

Verdict: **NUMPY_CORRECTNESS_PASS**.

### Task 7 — Hardware run

**NOT_EVALUATED.** This node has the simulator only; there's no Cerebras
hardware attached. The issue's "Do not" rule is honored: no hardware-run
claim is made.

## Final answer to the main question

**Yes** — the jacobi2d_5pt CSL implementation compiles, runs in the Cerebras
simulator, and matches the NumPy reference exactly (max_abs_error = 0 at fp32
tolerance 1e-5) for both 1-iter and 5-iter scenarios.

Bundle has been promoted to `kernels/Jacobi-2D-5pt/` (with `CUDA/`, `CSL/`,
and `spec.yaml`) as a permanent benchmark addition. The existing W2 framework
(`code_translation/explore_csl.py`, hybrid sweep, etc.) can now optimize this
kernel directly; the reference cycles in `spec.yaml` (1566) form the cycle
budget the agent must beat.

## Caveats and follow-ups

1. **No hardware run.** Per the issue's "Do not" rule.
2. **Different mesh sizes not tested.** Layout `@comptime_assert(width == 2)`
   hardcodes 2x2. Generalizing to NxM requires layout changes; that's a
   follow-up.
3. **Deterministic input only.** I picked `np.random.seed(7)` for parity with
   the rest of this repo's bench conventions. The bundle accepts any
   deterministic generator without bundle changes.
4. **Iteration count.** Tested at iters ∈ {1, 5}. Larger iter counts increase
   cycles linearly (~890 cycles/iter from the 1→5 delta); no correctness drift
   observed.
5. **Boundary policy choice.** I chose "preserved" (Dirichlet-style B[edge] =
   A[edge]) per the issue's "boundary skipped or preserved" guidance. The
   "skipped" interpretation (don't touch B[edge] at all, leaving it at zero
   from `@zeros`) would change the boundary cells of `new_tile` to zero on the
   first iteration; can be swapped in `pe.csl:f_compute` by removing the
   `new_tile[i*Nt+j] = tile[i*Nt+j]` line.
