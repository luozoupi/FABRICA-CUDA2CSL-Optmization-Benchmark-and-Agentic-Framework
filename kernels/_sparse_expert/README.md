# Hand-written expert variants of the sparse references

Each file is the reference `pe.csl` of its task with ONE catalogue prescription applied by hand,
measured through the same harness as the agent's programs (held-out matrices on, SDK 2.10),
so that a prescription is validated or refuted by the compiler and the simulator rather than
argued. They live outside every `kernels/<Task>/CSL/` directory on purpose: bundle staging copies
a task's whole `CSL/` tree, and nothing here may reach an agent's prompt or bundle.

| task | variant | prescription | cycles vs reference | verdict |
|---|---|---|---:|---|
| SpGEMM-Masked-Dot | `pe_branchless_merge.csl` | P6: advance the merge pointers by adding the predicate | 577,853 vs 260,903 (0.45x) | **refuted**: cslc keeps the 11 branches and adds the arithmetic |
| SpGEMM-Masked-Dot | `pe_dense_accumulator.csl` | P7: Gustavson accumulator instead of a merge | 222,989 vs 260,903 (1.17x) at list 3.6; **590,279 vs 845,529 (1.43x)** at list 9.0 (`n144`) | validated and growing with list length; the agent's O1 best is 202,106 / 601,662 on the two sizes |
| P6' explicit cursor paths (SpGEMM) | `SpGEMM-Masked-Dot/pe_cursor_paths.csl` | 221,649 vs 260,903 (1.18x) at list 3.6; 733,097 vs 845,529 (1.15x) at list 9.0 | validated 26 Sep (the NVIDIA node's 1.216x rewrite on our merge); keeps the branches, removes the indirect cursor update; the agent's O1 best (202,106) still beats it |
| SpMV-RowBlock | `pe_dia_remainder_v1.csl` | P5: diagonals as streams, CSR->DIA converted on the PE, linear slot search | 172,302 vs 37,330 at one product (0.22x); 290,550 vs 373,685 at ten (1.29x) | loses at one product (the conversion costs four SpMVs), wins at ten |
| SpMV-RowBlock | `pe_dia_remainder_v2.csl` | P5 with an O(1) slot table | 72,585 vs 37,330 at one product (0.51x); **191,462 vs 373,685 at ten (1.95x)** | **crossover at 2.5 products**: conversion 59,376 once, sweep 13,209 per product (2.83x) |

**Expert ports of GPU kernel designs (5 Oct 2026).** For the paper's agent-versus-expert comparison, each
file below replaces the kernel function of its task's reference with the best-known GPU design for that
input class, written by hand with the CUDA-to-CSL patterns; the timed wrapper, capacities and host program
are the reference's. Cycles: training seed 7 and held-out seeds 101/202/303, SDK 2.10 simulator, measured
with `code_translation/results/formats_agent/measure_size.py`
(`code_translation/results/expert_ports/{experts,experts_b,heldout_c,heldout_d}.csv`).

| task (commands) | file | GPU design | expert (train; held-out) | reference (train; held-out) | agent best (train; held-out) |
|---|---|---|---:|---:|---:|
| SpMV-CSR (`it10`) | `SpMV-CSR/pe_dense_tile.csl` | dense tile, one `@fmacs` per column (dense GEMV) | 35,847; 36,441 / 35,959 / 36,435 | 76,931; 83,071 / 78,091 / 83,021 | 22,681; 23,242 / 22,791 / 23,248 |
| SpMV-CSR-Block (`it10`) | `SpMV-CSR-Block/pe_bsr4.csl` | 4x4 BSR, 256 block slots, falls back to the CSR loop when they overflow | 212,212; 211,684 / 212,212 / 212,124 | 438,091; 434,611 / 438,091 / 437,511 | 209,245; 208,705 / 209,245 / 209,155 |
| SpMV-RowBlock-Iter | `SpMV-RowBlock-Iter/pe_dia.csl` | DIA with ten diagonal slots (O(1) table) and a CSR remainder | 194,540; 780,145 / 255,975 / 515,176 | 373,488; 740,415 / 726,996 / 571,557 | 211,467; 656,170 / 359,771 / 543,848 |
| RowScale-CSR | `RowScale-CSR/pe_row_dsd.csl` | one `@fmuls` per row (row per warp) | 23,891; 23,865 / 24,741 / 22,930 | 45,868; 51,082 / 56,806 / 45,271 | 20,116; 20,493 / 21,538 / 19,395 |

The SpGEMM variants above were re-measured on the held-out seeds the same day (`heldout_d.csv`): dense
accumulator 115,501 / 809,642 / 234,341 and cursor paths 131,043 / 1,677,471 / 229,507 against the
reference's 151,268 / 1,870,611 / 269,483 and the agent's best program's 87,549 / 672,311 / 194,811
(`heldout_c.csv`). Density and block-fill sweeps of the
dense-tile and BSR ports: `code_translation/results/sparsity_bench/bench_{csrx,blkx}.csv` (the dense tile
overtakes the CSR loop at about 9% density; the BSR port finishes on the uniform input, 490,381 vs 433,161
for the reference).

Results: `code_translation/results/expert_*_20260921/`, archived to `docs/data/`; the reasoning
is in `docs/SPARSE_ON_WSE.md` and `docs/SPARSE_BOTTLENECKS.md`; every measurement is dated in
`docs/IPDPS_PREREG.md` with its prediction recorded before the number.
