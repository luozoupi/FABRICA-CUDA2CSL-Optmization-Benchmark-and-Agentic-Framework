# Proposal: graded-difficulty stencil kernels for reviewer A/B testing

## Why this is a proposal, not a PR

Authoring a brand-new CSL bundle (`layout.csl` + `pe.csl` + `run.py` + `commands_wse3.sh` + CUDA reference + verified end-to-end correctness on the WSE) is a 3-6 hour SDK iteration task, not a 30-minute edit. I'm capturing the design so it can be picked up when there's dedicated SDK-iteration time. The existing kernel suite already includes the hard end of the spectrum (Game-of-Life, 7pt-Stencil, FFT-1D-2D); what's missing is **intermediate-difficulty halo-exchange kernels** that the agent might actually pass — and whose passing or failing would inform the loop design.

## What the current suite teaches us

| Kernel | Multi-PE? | Fabric exchange? | Best result so far |
|---|---|---|---|
| Wide-Multiplication | No (1×1) | No | passes (Claude, gpt-oss) |
| Single-Tile-Matvec | Yes (width×height) | No | passes (Claude, gpt-oss) |
| GEMV / GEMM | Yes (P×P) | Yes (collectives_2d) | passes (reference bundle wires colors) |
| 7pt-Stencil | Yes (5×5) | Yes (stencil_3d_7pts library + allreduce) | passes once on Claude, fails most other runs |
| Residual | Yes (2×2) | Yes (custom colors: PSUM, NRM) | fails on all reviewer A/B runs |
| Game-of-Life | Yes (x_dim×y_dim) | Yes (8 colors, even/odd checkerboard) | fails on all runs |
| FFT-1D-2D | Yes (multi-file bundle) | Yes (multi-direction) | fails on all runs |

The gap: **all "fabric-exchange-required" kernels in the suite use either external libraries (collectives_2d, stencil_3d_7pts, allreduce) OR multi-color checkerboard patterns**. There's no "small, hand-routed, 4-color halo exchange" kernel that exercises just *one* fabric idiom in isolation. The Residual kernel is the closest, but its routing combines PSUM (E-W reduction) and NRM (N-S reduction) in non-trivial directions.

## The three kernels to author

### Kernel 1: `Laplacian2D-Halo` — easy halo, no reduction
Goal: test whether the agent can produce a clean 2×2 halo-exchange kernel when *only* the halo-exchange idiom is required.

**Algorithm:** one iteration of the 5-point Laplacian:
```c
new[i,j] = 0.25f * (old[i-1,j] + old[i+1,j] + old[i,j-1] + old[i,j+1])
```

**Mesh:** 2×2 PEs, each owns an `Mt×Nt` tile (e.g., 4×4 f32 = 64 bytes/PE — comfortably small).

**Routing (4 colors):**
- `EAST`: each PE sends its rightmost column to its east neighbor; receives leftmost column from west
- `WEST`: opposite direction
- `NORTH`: each PE sends its top row south; receives bottom row from north
- `SOUTH`: opposite direction

**Why graded:** no reduction, no broadcast, no checkerboard. Just 4 cardinal halo exchanges + local stencil. The simplest non-trivial halo pattern.

**Contract:**
- Exports: `tile_in: [*]f32`, `tile_out: [*]f32`, `f_step: fn() void`
- Boundary PEs supply zero for missing neighbors (or read a host-provided boundary tile)

**Reference:** a 10-line CUDA `__global__` kernel that does the same thing on a single large tile (no halo needed since shared memory handles it). The agent must figure out how to decompose.

### Kernel 2: `Laplacian2D-Reduce` — halo + global norm
Goal: test combining the halo exchange (kernel 1) with a global reduction (already exercised in Residual).

Same Laplacian, but also compute `nrm = max |new - old|` across the whole grid. Adds the column reduction pattern Residual already uses.

**Why graded:** if the agent passes kernel 1 but fails this, the bottleneck is the reduction-after-exchange coordination, not the exchange itself. If it fails both, the bottleneck is the halo exchange.

### Kernel 3: `LorenzoPredictor-Tile` — CereSZ-style (advanced)
The simplest piece of the CereSZ lossy-compression pipeline: per-tile Lorenzo prediction. Each output element is the residual against a linear prediction from its left/up neighbors.

```c
predicted = A[i-1,j] + A[i,j-1] - A[i-1,j-1]
residual[i,j] = A[i,j] - predicted
```

**Mesh:** 2×2 or 4×4. The agent must figure out that:
- Tile boundaries need 1-cell halo (left column + top row from neighbors)
- The 4 cardinal halo exchanges from kernel 1 carry over
- This is the "compressor without entropy coding" — pure dataflow, no reduction

**Why valuable:** it's a real HPC primitive (CereSZ uses exactly this), not a toy. Passing this validates the loop on a published reference workload.

## Effort estimate

| Step | Time |
|---|---|
| Write `layout.csl` + per-PE `pe.csl` for kernel 1 | ~1 hour |
| Write `run.py` (data setup + memcpy + verify against NumPy) | ~30 min |
| Write `commands_wse3.sh` (cslc + cs_python invocation) | ~10 min |
| Compile + run on local apptainer; debug | ~1-2 hours |
| Write CUDA reference + ensure semantics match | ~30 min |
| Add to `KERNEL_REGISTRY` in `cuda2csl.py` | 5 min |
| Repeat for kernel 2 (mostly inherits routing) | ~1 hour |
| Repeat for kernel 3 (mostly inherits routing + small algorithm change) | ~1.5 hours |
| **Total per kernel: ~3-4 hours; full set: ~8-10 hours** | |

## What this would unlock

Once these kernels are in the suite, the reviewer A/B becomes a real measurement:

- If the loop passes kernel 1 but fails kernels 2 and 3 → the bottleneck is *compound* coordination (halo + reduction together), and adding a "compound idiom" pattern to `csl_mesh_patterns.py` is the next move
- If the loop fails kernel 1 → the bottleneck is the *single* halo-exchange idiom, and we need a more authoritative halo-exchange catalog entry (the current `halo_exchange_stencil` is marked `[inferred]`)
- If the loop passes all three → the reviewer + architect + catalog stack actually works on non-trivial kernels and the 4 existing failures are model-specific (knowledge gap), not architecture-specific

The cost is real but the experimental value is high. Without these kernels, the reviewer A/B can only report "no change" indefinitely on the saturated existing suite.

## Related: what's already there

A 5-point Laplacian could be subdivided into the existing `7pt-Stencil` (it's the 2D version of 3D 7-point), but that kernel's bundle uses external libraries (`stencil_3d_7pts`, `allreduce`) that make it strictly harder than what we want here. The Laplacian-Halo kernel above is the standalone, library-free version that should exist between Single-Tile-Matvec (no fabric) and 7pt-Stencil (lots of fabric).
