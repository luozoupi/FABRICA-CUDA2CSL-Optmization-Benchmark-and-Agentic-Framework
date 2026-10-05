# WSE-3 hardware campaign for the sparse study (v2)

All jobs go through the SDK 2.10 appliance client (`~/cs_appliance_sdk/bin/python`, which works
on the user node user-node-1, not on the login nodes) via `code_translation/hw_sparse_refs.py`
(reference bundles, per size) and `code_translation/hw_replay.py` (agent artifacts). One
bundle = one appliance compile + one simulator run + one silicon run with 3 batched trials;
about 6-10 minutes each. Results are archived under `docs/data/`.

| step | what | bundles | status |
|---|---|---|---|
| HW-S0 | smoke: RowScale-CSR + SpMV-RowBlock `small`, sim+hw | 2 | **done 16 Sep**: 41,346 / 36,776 cycles on silicon vs 45,868 / 37,330 on the appliance simulator (hw/sim 0.90 / 0.985); the appliance simulator equals the local SDK 2.10 counts exactly; 3 trials identical |
| HW-S1 | every size of every S task | 11 | **done 16 Sep** (`docs/data/hw_sparse_refs_20260916.json`): all 11 pass on silicon, hw/sim geomean 0.956, range 0.90-1.02; table below |
| HW-S2 | retained programs of every optimize arm (median seed per arm + first-correct) | ~28 | after the optimize sweeps |
| HW-S3 | fidelity: every benchmarked candidate of 4 tasks x 3 seeds (`hw_replay.py --versions`) | ~60 | after the optimize sweeps |
| HW-S4 | transfer: retained programs on held-out matrices | ~21 | after the sweeps; the simulator leg is `code_translation/transfer_retained.py` (compiles once, then re-runs the run step per held-out seed and parses cycles, matrix id and nnz from the runner's stdout) |
| HW-S5 | the f32 reduction hazard on silicon (`microbench/iremit` regression case) | 4 | any time |

Hardware go-ahead for the whole campaign (HW-S0 to HW-S5): given 16 Sep 2026.

```bash
# on user-node-1
cd ~/xkernel
nohup ~/cs_appliance_sdk/bin/python code_translation/hw_sparse_refs.py --sizes all --arms sim,hw --repeats 3 \
  --out code_translation/results/hw_sparse_refs_$(date -u +%Y%m%d).json > code_translation/results/hw_sparse_refs_$(date -u +%Y%m%d).log 2>&1 &
```

Every row records `spec_sim_cycles` (local SDK 2.10 simulator, the study's reference) next to
the appliance simulator and hardware counts, so three numbers per bundle are available: the
appliance-vs-local simulator delta (a toolchain check, expected 1.000) and the hardware-vs-
simulator ratio (the fidelity number). Only device-internal timing rows enter the paper; every S
task times on-device.

## HW-S1 result (16 Sep 2026)

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

## HW-S6 (26 Sep 2026): the NVIDIA node's distributed SpGEMM fixtures on the CS-3

Five strong-scaling cases of `studies/spgemm-scaling-20260924` (full-row accumulator; 16x16 on 4/16 PEs,
64x64 on 4/16/64 PEs), unchanged sources and inputs, real B broadcast and completion reductions, run
through `code_translation/hw_spgemm_dist.py` with the study's own `host.py` validating every launch.
Appliance simulator == the study's local simulator exactly. Silicon / simulator: 0.965, 1.008, 0.898,
0.927, 0.991 (uniform session). Full tables, per-session numbers and the two kept failed attempts:
`studies/spgemm-scaling-20260924/hardware-replay-20260926/HARDWARE_REPLAY_20260926.md`.

## HW-S3 (28 Sep 2026): candidate-level fidelity

44 programs: the nine O1I retained programs and every benchmarked candidate of three optimiser cells
(SpGEMM O0 seed 3, SpMM O0 seed 2, SpMV O1I seed 3), three trials each, through `hw_replay.py --versions`
on a pseudo-sweep of file links (`results/hw_s3_pseudo_20260928`). hw/sim 0.953-1.032 (geomean 0.992);
Kendall's tau between simulator and hardware rankings within a cell 1.00 / 0.97 / 0.94; the optimiser's
accepted chains reproduce on silicon except one one-cycle acceptance on SpMM. Data:
`docs/data/hw_s3_20260928.json`.
