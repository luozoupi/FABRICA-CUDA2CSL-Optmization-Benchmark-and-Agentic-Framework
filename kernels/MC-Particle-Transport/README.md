# MC-Particle-Transport

Monte Carlo continuous-energy cross-section lookup kernel, originally from
Argonne National Laboratory (MIT license). Imported here from
`https://github.com/hpc-science/mc_on_accelerators` on 2026-05-31.

The original upstream README is preserved in-tree as a reference; this file
documents how the kernel is registered within xkernel.

## Reference paper

Tramm, J., et al. "Efficient algorithms for Monte Carlo particle transport on
AI accelerator hardware." *Computer Physics Communications*, vol. 298 (2024),
p. 109072. doi:10.1016/j.cpc.2024.109072.

## What's here

- `CUDA/kernel.cu` — CUDA baseline (`main.cu` in the upstream repo, renamed to
  match the xkernel registry convention `kernel.cu`). 554 LOC. Builds with `make`.
- `CUDA/Makefile` — upstream's nvcc invocation (SM 80 default).
- `CSL/device_code.csl` — WSE-2 device-side CSL (1126 LOC).
- `CSL/device_layout.csl` — WSE-2 fabric layout (186 LOC).
- `CSL/host_code.py` — Host-side driver (856 LOC).
- `CSL/commands_wse3.sh` — Upstream singularity-mode build script (driving
  `compile.py` + `cs_python host_code.py`, **not** direct `cslc`). Filename
  kept as `commands_wse3.sh` only to satisfy the xkernel registry; the
  actual target is **WSE-2** under singularity.
- `LICENSE` — Upstream MIT license.

## Status: reference-only

This kernel is registered in `code_translation/cuda2csl.py:KERNEL_REGISTRY`
with `arch=wse2`. The default xkernel agentic sweep targets WSE-3 with a
direct `cslc → cs_python run.py` flow; **MC-Particle-Transport is not
compatible out of the box** because:

1. Architecture is WSE-2, with different microthread / queue-ID limits than WSE-3.
2. Build script uses `compile.py` + `singularity`, not direct `cslc`.
3. Host driver is 856 LOC with numerical-validation paths gated behind
   comment-block uncommenting (see upstream `CSL/README.md`).

It is registered so the agent can **read the CUDA source as part of
translation context** (e.g. as a worked example of a particle-tracking
kernel layout) and so the CSL files participate in any future reference
corpus. It is NOT included in any of the default sweep configurations.

## To run the original implementation

Use the upstream singularity build flow per `CSL/README.md` and
`CSL/commands_wse3.sh`. Do not invoke via `run_alcf_sweep_one.sh` or
`cuda2csl.py --kernel MC-Particle-Transport` without first porting the
build to direct `cslc` against WSE-3 and writing a `run.py` verifier.

## License

MIT. See `LICENSE`.
