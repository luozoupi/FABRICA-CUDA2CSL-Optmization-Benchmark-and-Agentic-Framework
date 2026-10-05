# The sparse task suite S (IPDPS 2027 v2 study)

Seven CUDA-to-CSL tasks derived from **SuiteSparse:GraphBLAS CUDA** kernels
(github.com/DrTimothyAldenDavis/GraphBLAS, `stable` @ `afbe9aae`, v10.5.x), concretized
by hand to the plus-times f32 semiring with int indices and no JIT macros (every
`CUDA/kernel.cu` header names its template). Inputs are real matrices from the
**SuiteSparse Matrix Collection** (Harwell-Boeing group, CC-BY 4.0), with **held-out
matrices** of the same class instead of held-out seeds. References are honest
textbook scalar CSL, SDK 2.10-native (they compile on 1.4 too); the structure-aware
and hardware-aware rewrites are what the optimizer has to find.

Pre-registration: `docs/IPDPS_PREREG.md` (v2). Machine-readable membership:
`code_translation/task_sets.py --kernels S` / `--verify`.

## Tasks

| task | GraphBLAS origin | PEs / sizes | matrix class (train; held-out) | caps | reference cycles (SDK 2.10 sim, train matrix) |
|---|---|---|---|---|---|
| SpMV-CSR (pre-existing) | textbook scalar CSR | 1 | synthetic uniform 32x32, density 0.25 | nrows 32, max_nnz 256 | 7,429 |
| RowScale-CSR (C = D*A) | `mxm/template/GB_jit_kernel_cuda_colscale.cu` (CSC colscale read in CSR terms: row lookup per nonzero) | 1 | hb_n512: 494_bus; bcspwr05, gre_512, west0479 | nrows 512, max_nnz 2304 | 45,868 (27.5 cyc/nnz) |
| ColScale-CSR (C = A*D) | `mxm/template/GB_jit_kernel_cuda_rowscale.cu` (per-nonzero gather) | 1 | hb_n512 | nrows 512, max_nnz 2304 | 53,329 (32.0 cyc/nnz) |
| RowReduce-CSR (row sums + total) | `reduce/template/GB_jit_kernel_cuda_reduce.cu` + reduce-to-vector (dot3 spdn) | 1 | hb_n512 | nrows 512, max_nnz 2304 | 41,067 (24.7 cyc/nnz) |
| SpGEMM-Masked-Dot (C<M> = A'A) | `mxm/template/GB_cuda_jit_AxB_dot3_phase3_vsvs.cuh` (two-pointer merge, zombies) | 1 | hb_n256: dwt_234; gre_216a, fs_183_1, west0167 | n 256, max_nnz 1536 | 260,903 (313 cyc/mask entry) |
| SpMV-RowBlock (y = A*x) | `..._dot3_phase3_spdn.cuh` with B := x (CSR-vector, warp per row) | 1x1 `p1`, 4x1 `small`, 16x1 `p16` | p1 hb_n512; small hb_n1024: sherman1; jagmesh1, gr_30_30, dwt_1005; p16 hb_power_n2048: bcspwr07; bcspwr06, bcspwr08, bcspwr09 | per PE: 512/2304, 256/2560, 128/1024 (rows/nnz) | 61,107 / 37,330 / 19,375 |
| SpMM-CSR-Dense (C = A*B, B dense) | `..._dot3_phase3_spdn.cuh` with B full, full mask (row-split SpMM) | 1x1 `p1`, 2x2 `small`, 4x4 `p4` | p1 hb_n144: bcspwr03; ash85, arc130, can_144; small hb_n256: dwt_234; can_229, gre_216a, can_256; p4 hb_n512 | per PE: Mt/nnz 144/1536, 128/2048, 128/1024; N = 16/16/32 | 301,132 / 106,606 / 103,213 |

Cycles are deterministic on the simulator (three runs identical). Every size's caps are
the class maxima after the spec's partition, rounded up; `test_sparse_suite.py` enforces
`caps >= manifest maxima`.

## The input contract

* `kernels/<Task>/CSL/data/manifest.json` (one per size class: `manifest_<structure_id>.json`
  for the other sizes) lists the **train matrix first** and the held-out matrices after it.
  `run.py` maps the evaluation seed to an index with `sparse_inputs.seed_to_index`
  (`0` for the train seed, `1 + seed % (n-1)` otherwise; seeds 101/202/303 -> 3/2/1), so
  the agent's whole loop runs on one pinned input and the held-out gate flips through the
  others. Values are re-drawn from the seed (`values: seeded_uniform`) because most
  power-network matrices are patterns.
* The seed reaches `run.py` through `XKERNEL_EVAL_SEED` **or** the harness file
  `.xkernel_eval_env.json` in the bundle (`sparse_inputs.resolve_eval_seed`); the runner
  echoes `eval_seed = N` and `benchmark_csl.evaluate_heldout` fails with
  `heldout_env_not_propagated` if the echo does not match. This matters on login nodes,
  where the ssh relay in front of `singularity` drops the environment (see
  `scripts/singularity_relay_env.sh`).
* `run.py` prints `xkernel_structure = {...}` (features of the loaded matrix); the harness
  turns it into the structure readout. `spec.yaml`'s `structure:` block (`format`, `class`,
  `manifest`, `partition`, `caps`, `readout`) drives the translation-side readout
  (`XKERNEL_STRUCTURE_READOUT=1`).
* 1-PE tasks: `compute()` is the frozen TSC wrapper around the kernel function
  (`frozen_functions`, `frozen_params` in the spec). Multi-PE tasks: `timing_protocol:
  device_internal_v2` (`f_tic_dev` at the start of `main`, `f_toc_dev` before the unblock;
  `cycles_send = max(end) - min(start)` over the mesh).

## Transfer to the held-out matrices (RQ3)

The acceptance gate proves a retained program is *correct* on the held-out matrices but
records no cycle count for them, and never measures the frozen first-correct program
there. `code_translation/transfer_retained.py` supplies both:

```bash
~/bin/micromamba run -n xkernel-agent python transfer_retained.py \
  --sweep results/<mg sweep> --kernels "$(python task_sets.py --kernels S)" \
  --arms O0,O1,O1I --seeds median --fc results/first_correct/sparse_20260924 \
  --out results/transfer/transfer_<tag>.json --csv ~/<paper>/figures/ipdps_sparse_transfer.csv
```

It benchmarks each program once (compile + train matrix, bundle kept), then re-runs only
the `cs_python run.py` step per held-out seed on that compiled bundle and parses
`cycles_send`, the matrix id and its nnz from the runner's own prints. A seed echo that
disagrees with the requested seed is recorded as `env_not_propagated` (infrastructure),
never as a kernel property. Resumable per (kernel, series, seed, eval seed); the printed
summary is the pre-registration's transfer estimator (passed, and passed-and-beats-FC).

## Verifying and re-baselining

```bash
cd code_translation
~/bin/micromamba run -n xkernel-agent python task_sets.py --verify
XKERNEL_HELDOUT_EVAL=1 ~/bin/micromamba run -n xkernel-agent python rebaseline_references.py \
  --kernels RowScale-CSR --num-runs 3 --sdk-root /software/cerebras/cs_sdk-2.10 --protocol in_kernel_tsc --write
# multi-PE tasks, all sizes:
XKERNEL_HELDOUT_EVAL=1 ~/bin/micromamba run -n xkernel-agent python rebaseline_references.py \
  --kernels SpMV-RowBlock --sizes p1,small,p16 --num-runs 3 --sdk-root /software/cerebras/cs_sdk-2.10 --protocol device_internal_v2 --write
```

`--write` records the SDK 2.10 counts in `kernels/baselines_wse3_sdk210.json` (never mixed
with the 1.4 counts in `baselines_wse3.json`); the report prints the held-out result with
the (requested, echoed) seeds. Matrices: `tools/fetch_suitesparse.py --fetch --stats --pin
--install` (manifest in `kernels/_sparse_data/MANIFEST.json`).

## Adding a task

Copy a sibling directory; keep the export convention (`@export_name(name, [*]T, true)` +
`var ptr: [*]T = &arr;`), the untyped `param memcpy_params;`, the frozen wrapper or the
v2 timing helpers verbatim, literal `--params` in the build script, `run.py` reading the
seed through `sparse_inputs.resolve_eval_seed` and echoing it; add the registry entry
(`cuda2csl.KERNEL_REGISTRY`), the `task_sets.S` membership and partition, the
`installs` entry in `MANIFEST.json`, then run the unit tests and `rebaseline_references.py`.

## CS-3 hardware counts of the references (HW-S1, 16 Sep 2026)

From `docs/data/hw_sparse_refs_20260916.json` (`code_translation/hw_sparse_refs.py`, appliance client on the user node):

| task | size | local SDK 2.10 sim | appliance sim | CS-3 (min of 3, all identical) | hw/sim |
|---|---|---|---|---|---|
| SpMV-CSR | small | 6,927 | 7,429 | 7,336 | 0.988 |
| RowScale-CSR | small | 45,868 | 45,868 | 41,346 | 0.901 |
| ColScale-CSR | small | 53,329 | 53,329 | 48,332 | 0.906 |
| RowReduce-CSR | small | 41,067 | 41,067 | 37,318 | 0.909 |
| SpGEMM-Masked-Dot | small | 260,903 | 260,903 | 258,351 | 0.990 |
| SpMV-RowBlock | small | 37,330 | 37,330 | 36,776 | 0.985 |
| SpMV-RowBlock | p1 | 61,107 | 61,107 | 59,028 | 0.966 |
| SpMV-RowBlock | p16 | 19,375 | 19,375 | 19,792 | 1.022 |
| SpMM-CSR-Dense | small | 106,606 | 106,606 | 103,157 | 0.968 |
| SpMM-CSR-Dense | p1 | 301,132 | 301,132 | 280,458 | 0.931 |
| SpMM-CSR-Dense | p4 | 103,213 | 103,213 | 99,503 | 0.964 |

SpMV-CSR's spec still carries the SDK 1.4 count (6,927); its SDK 2.10 count is 7,429 on both simulators (`kernels/baselines_wse3_sdk210.json`). All 11 bundles print SUCCESS on silicon; every hardware window repeated exactly over 3 batched trials (spread 1.000); geometric-mean hw/sim 0.956, range 0.901 (RowScale-CSR) to 1.022 (SpMV-RowBlock p16, the only bundle the simulator underestimates). Client 1.14.0 against cluster 1.20.2 (warning only).
