# Audited progress tables — 23 September 2026

These tables summarize existing evidence. Remote hardware measurements were reported by the WSE-3 node; this audit runs on the NVIDIA GPU node without device jobs. See [README.md](README.md) for the scope and next work.

## Luna optimizer results

Each entry is the median simulator cycles over three retained seeds. Ratios above one favor the added treatment.

| Task | Existing feedback (O0) | Sparse guidance (O1) | Added compiler feedback (O1I) |
|---|---:|---:|---:|
| SpGEMM-Masked-Dot | 209,541 | 202,106 | 228,040 |
| SpMM-CSR-Dense | 29,270 | 29,289 | 29,550 |
| SpMV-RowBlock | 37,012 | 37,012 | 35,396 |

All 27 of 27 workflows retained a passing program. The tables contain 309 candidate records and 10–12 attempts used per workflow. These are the other node's exploratory cohort, not the ten-proposal matched study.

Geometric mean of per-task median speedup ratios: O1/O0 **1.012×**; O1I/O1 **0.972×**. The reported paper intervals include one; there is no demonstrated overall arm benefit in this small cohort.

## Hardware coverage

| Group | Expected records | Present | Full 3/3 trial success |
|---|---:|---:|---:|
| Frozen starts | 3 | 3 | 3 |
| O0/O1 retained cells | 18 | 18 | 16 |
| O1I retained cells | 9 | 0 | 0 |

Two SpMV O0 records (seeds 2 and 3) are marked `fail` with 2/3 trials passed. Overall: 61/63 reported trials passed. The tables do not establish the cause of those failures. Counts refer to cell records, not unique source binaries.

Using all 21 records with measured cycles, hardware/simulator ratios are **0.948–1.009**, geometric mean **0.980**. Two contributing records are partial successes. SpGEMM rank agreement is 0.9048, SpMM is 1.0, and SpMV is undefined because all values tie.

## Transfer coverage

| Task | Passing retained-program/matrix pairs | O0 beats start | O1 beats start | O1I beats start |
|---|---:|---:|---:|---:|
| SpGEMM-Masked-Dot | 27/27 | 9/9 | 9/9 | 9/9 |
| SpMM-CSR-Dense | 27/27 | 9/9 | 9/9 | 9/9 |
| SpMV-RowBlock | 27/27 | 0/9 | 0/9 | 6/9 |

All 81 retained-program/matrix pairs pass. These matrices were already part of the retained-pass gate; this establishes transfer within the acceptance set, not performance on untouched final-test matrices. Nine additional frozen-start observations provide the comparison baselines.

## Completed local scaling measurements

These are **provisional simulator timestamp spans**, not admitted hardware latencies or scaling efficiencies. Both hosts combine timestamps from different PEs; clock alignment has not been audited. SpMM has host-preloaded replicated operands and no timed device communication.

| Task / scaling | 1 PE | 4 PEs | 16 PEs | 64 PEs | 256 PEs |
|---|---:|---:|---:|---:|---:|
| SpMV-RowBlock / strong | PE memory failure | 37,330 | 12,718 | 4,178 | 1,873 |
| SpMM-CSR-Dense / strong | PE memory failure | 106,606 | 29,570 | 6,837 | 2,493 |
| SpMV-RowBlock / weak | 4,513 | 4,658 | 5,064 | 6,689 | 13,093 |
| SpMM-CSR-Dense / weak | 111,520 | 111,520 | 111,520 | 111,520 | No success marker |

All 17 passing configurations have three equal cycle samples and passed validation seeds 101, 202 and 303 with matching seed echoes. Both one-PE strong-scaling builds report linker PE-memory exhaustion. The weak SpMM 256-PE run compiled but returned no numerical success marker after approximately 300 seconds; its root cause remains unresolved.

Strong SpMV fixes 1,024 rows and columns. Strong SpMM fixes 256 rows, shared dimension 256, and 16 output columns. Weak SpMV fixes 32 rows and 128 stored nonzeros per PE while vector length grows from 32 to 8,192. Weak SpMM fixes 128 local rows, shared dimension 256, eight local output columns and 512 stored nonzeros per PE. Matrix replication and distribution are framework-provided.

## Completed local DeepSeek smoke

The older frozen three-translation/three-optimization-attempt smoke recorded four independently audited correct final programs. Only the masked product improved over its own first correct program; comparisons against the handwritten reference answer a different question. Returned identity was recorded as `deepseek-flash`; these observations do not verify a separately named V4.1 model.

| Task | First correct cycles | Final cycles | Reference cycles |
|---|---:|---:|---:|
| RowScale-CSR | 27,335 | 27,335 | 45,868 |
| SpGEMM-Masked-Dot | 261,918 | 229,550 | 260,903 |
| SpMM-CSR-Dense | 104,615 | 104,615 | 106,606 |
| SpMV-CSR | 7,464 | 7,464 | 7,429 |

The export records 44 returned calls: two truncated, 37 without a qualifying exact-code evaluation match, and five correct matched examples. Each exported SFT/outcome/GRPO-prompt file has five records and its recorded hash verifies. These are provisional development examples under the old gate; they require revalidation under the current contract before training. Raw records remain private to the local experiment archive.

The [machine-readable audit](audit.json) and [evidence manifest](evidence-manifest.json) provide calculations, coverage and source hashes. The historical device runs were not repeated by this audit.
