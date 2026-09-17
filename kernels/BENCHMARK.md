# FABRICA-BENCH

This directory contains paired CUDA/CSL tasks plus supporting reference examples.
The current framework registers **52 tasks**. The [paper](https://arxiv.org/abs/2608.25124)
evaluated a 49-task subset; this working source snapshot contains later additions.
See [CATALOG.md](CATALOG.md) for registry names and paths. Unregistered example
folders are reference material and are not part of the default runnable registry.

Each registered entry in `code_translation/cuda2csl.py:KERNEL_REGISTRY` specifies:

- a CUDA source;
- a CSL reference directory with host-side verification;
- the compute file to translate;
- a build/run script for the target architecture.

Task specifications define inputs, outputs, verification tolerances, train/test
splits, held-out seeds, timing policy, and optional size configurations. Shared CSL
libraries in `benchmark-libs/` and matrix input files are required benchmark inputs.
Read [SPEC_SCHEMA.md](SPEC_SCHEMA.md) for field meanings.

```bash
bash run_cuda2csl.sh --kernel ReLU-1PE --turns 4
bash run_cuda2csl.sh --kernel ReLU-1PE --auto-optimize
python code_translation/batch_cuda2csl.py --kernels ReLU-1PE,SAXPY-1PE --dry-run
```

Run these commands from the repository root. SDK and provider setup are documented
in [SETUP.md](../SETUP.md).

A candidate must compile, execute, pass numerical verification, and satisfy the
configured held-out checks. Cycle-scored tasks compare `cycles_send` using the
reference recorded in `spec.yaml` or `baselines_wse3.json`. `fast_p` requires a
correct candidate at least p times as fast as its baseline. Correctness-only tasks
must not be included in cycle-speedup aggregates. Some tasks use a first-passing
candidate baseline, explicitly marked in their metadata.

The preserved baseline numbers are historical measurements. They were not remeasured
during source cleanup. SDK version, sizes, timing windows, and hardware versus
simulator mode must match before interpreting speedups. Registry completeness and
CPU tests do not establish fresh SDK/hardware validation of all kernels.
