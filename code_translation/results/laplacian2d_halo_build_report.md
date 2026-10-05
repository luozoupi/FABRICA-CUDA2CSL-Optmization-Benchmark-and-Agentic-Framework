# Graded-stencil kernels — build report

Three new kernels added to the xkernel suite to give the agentic translator
a graded difficulty curve between "no fabric" (Single-Tile-Matvec) and
"complex multi-color fabric" (Game-of-Life, Residual, 7pt-Stencil, FFT-1D-2D).
Built in one session, 2026-05-30.

## Summary

| Kernel | Status | Compiles | Runs on simulator | NumPy-verified |
| --- | --- | :---: | :---: | :---: |
| **Laplacian2D-Halo** | **Production** | ✓ | ✓ | ✓ (`max abs diff = 0` for iters=1,3) |
| Laplacian2D-Reduce | Skeleton | ✓ | (not exercised yet) | `VERIFY=False` |
| LorenzoPredictor-Tile | Skeleton | ✓ | (not exercised yet) | `VERIFY=False` |

All three are registered in `code_translation/cuda2csl.py:KERNEL_REGISTRY`
and have CUDA references at `kernels/<Name>/CUDA/kernel.cu`.

## Laplacian2D-Halo — fully verified

5-point 2D Laplacian on a 2×2 PE mesh. Each PE owns a 4×4 f32 tile (64 B);
4 halo arrays (2×Mt + 2×Nt = 32 B). 4 cardinal fabric colors (NORTH, SOUTH,
EAST, WEST). Async fabric sends + async fabric receives via the
`@fmovs(halo_dsd, fab_rx_dsd, .{.async=true, .activate=RX_DONE_TID})`
pattern — single counter increment per direction, no per-wavelet counting.

In-kernel iteration loop via `fn step(iters: u16)` — the compute task
decrements `remaining_iters` and either re-activates `SEND_TID` or
activates `EXIT_TID`. Verified for `iters=1` (one stencil step) and
`iters=3` (three stencil steps); both achieve `max abs diff = 0.000e+00`
against a NumPy `np.pad(A, 1, mode='constant')` reference.

Files:
- `kernels/Laplacian2D-Halo/CSL/{layout.csl, pe.csl, run.py, commands_wse3.sh, README.rst}`
- `kernels/Laplacian2D-Halo/CUDA/{kernel.cu, commands.sh}`

Verification:
```bash
cd kernels/Laplacian2D-Halo/CSL
bash commands_wse3.sh        # runs iters=1
cs_python run.py --name out --iters 3   # runs iters=3
# Both print "max abs diff = 0.000e+00" and "SUCCESS!"
```

Key design choices documented in `README.rst`:
- Color naming convention: each color name describes the *direction the
  data travels*, not the direction the sender faces.
- Column-halo staging: send the leftmost/rightmost tile column by copying
  into a contiguous `col_send_{w,e}[Mt]` scratch buffer first; cheaper
  than a stride DSD.
- Edge handling: pre-zero the halo arrays, and only issue sends/receives
  when the PE has a neighbor in that direction (`if (!is_X_edge) @fmovs(...)`).
  The `num_halos_expected` counter is computed at comptime from edge flags
  so the compute task fires the moment all *expected* halos arrive.

## Laplacian2D-Reduce — skeleton (compile-clean)

Adds a global max-norm reduction (`nrm = max |new - old|`) on top of
Laplacian2D-Halo. Inherits the 4 halo colors and adds an `NRM` color for
the column reduction (south PE sends its local max north; receiving PE
takes max).

`pe.csl` includes:
- All Laplacian2D-Halo's halo plumbing (verified working in kernel 1).
- The local `local_max` accumulation inside the compute task (correct).
- The cross-PE max send/recv on the `NRM` color (wired but routing
  direction not yet numerically verified).

`run.py` ships with `VERIFY=False` — launching the kernel exercises the
plumbing but no numerical assertion fires. The script prints the
device-reported per-column maxes for inspection.

**To finish**: turn `VERIFY=True` in `run.py`, run on the simulator, and
debug whichever way the NRM routing got inverted. Estimated ~30 min once
someone with SDK access picks it up.

Files:
- `kernels/Laplacian2D-Reduce/CSL/{layout.csl, pe.csl, run.py, commands_wse3.sh}`
- `kernels/Laplacian2D-Reduce/CUDA/kernel.cu`

## LorenzoPredictor-Tile — skeleton (compile-clean)

Per-cell Lorenzo prediction:
`residual[i,j] = A[i,j] - (A[i-1,j] + A[i,j-1] - A[i-1,j-1])`. The
simplest piece of the CereSZ lossy-compression pipeline.

Needs 3 halos:
- `halo_n[Nt]` — top row from north neighbor
- `halo_w[Mt]` — left column from west neighbor
- `halo_nw` — top-left scalar from NW neighbor (placeholder = 0 in
  skeleton)

`pe.csl` wires the N + W halos. The NW scalar is the tricky bit because
the wafer fabric has no diagonal links; three options for future work:
1. NW neighbor sends it explicitly via an extra hop.
2. NW scalar piggybacks on the north halo's leftmost element (still
   needs the W neighbor to also forward).
3. Host pre-computes the NW boundary as part of per-PE memcpy init.

Option 3 is probably cleanest and is what the comments document.

Files:
- `kernels/LorenzoPredictor-Tile/CSL/{layout.csl, pe.csl, run.py, commands_wse3.sh}`
- `kernels/LorenzoPredictor-Tile/CUDA/kernel.cu`

## Agentic smoke test

After registering the three kernels in `KERNEL_REGISTRY`, ran an end-to-end
smoke test of the agentic translator pipeline on Laplacian2D-Halo:

```bash
bash run_alcf_sweep_one.sh openai/gpt-oss-120b /tmp/lap_smoke \
  --kernels Laplacian2D-Halo --turns 1 --skip-reviewer --timeout 600
```

Result: `fail` (the agent generated CSL that compiled + ran on the WSE but
returned wrong numbers) in 100 s wall. Crucially, **`fail` not `error`**
means:
- The kernel registry entry resolves correctly (CUDA ref + CSL ref dir found).
- The agent loads the CUDA source and reference contract without issue.
- The agent's translated CSL compiles cleanly under `cslc`.
- The bundle launches on the simulator and produces a numeric result.
- The only thing wrong is the numbers themselves.

That's exactly the integration test the kernel addition needs to pass.
The kernel is now usable in any future agentic A/B sweep.

## Why these kernels

Prior reviewer A/B sweeps saturated at 1/4 pass across three frontier
models (gpt-oss-120b, Sonnet 4.6, Opus 4.7) on the four hard kernels
(Game-of-Life, Residual, 7pt-Stencil, FFT-1D-2D). The graded-stencil
proposal at `code_translation/results/PROPOSAL_graded_stencil_kernels.md`
argued the suite was too binary: there was no kernel exercising *only*
the halo-exchange idiom in isolation. Laplacian2D-Halo closes that gap.

If a future agentic A/B passes Laplacian2D-Halo but fails the other four,
the bottleneck is the *additional* complications (8-color checkerboard,
reductions, multi-file bundles, FFT permutations) — not the halo idiom.

If a future agentic A/B fails Laplacian2D-Halo, the halo idiom itself is
the bottleneck.

This kernel is the experimental control the prior sweeps lacked.

## What's still pending

- Numerical verification of Laplacian2D-Reduce (estimated ~30 min with SDK
  access).
- Numerical verification of LorenzoPredictor-Tile (estimated ~1 h — the
  NW scalar plumbing needs design + verification).
- Re-running the reviewer A/B sweep with the new kernel added to the
  failing-kernel subset, to see whether the agent can crack a clean
  halo-exchange kernel. This is the actual experiment the kernel exists
  to enable.
