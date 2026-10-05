# Sparse workload walkthrough

Open [the offline sparse viewer](results/sparse-walkthrough/sparse.html). It uses
the same HTML/SVG presentation style as the GEMM/GEMV and PE-hop views, with
workload/output selectors, exact operands, partial sums, PE ownership, step
controls, accumulator snapshots and downloadable evidence. It needs no server.

## Available evidence

| Workload | Artifact used | Numeric presentation | Timing evidence |
|---|---|---|---|
| SpMV | `microbench/iremit/`: source, authored IR, ELF, disassembly, JSONL trace and result arrays | Four 16×16 implementations, 60 nonzeros each; every product and accumulation bound to recorded S6 operands/results | Actual instruction cycles and strategy marker windows |
| SpMM | `kernels/SpMM-CSR-Dense/CSL/`: matrix, manifest, input loader, runner and kernel; retained rebaseline report | Reconstructed 234×234 sparse A × 234×16 dense B; 3,744 output values, 13,344 products | Separate retained simulator aggregate: 106,606 cycles; no reconstructed step assigned a cycle |
| SpGEMM | `kernels/SpGEMM-Masked-Dot/CSL/`: matrix, CSC packing, runner and kernel; retained simulator/hardware report | Reconstructed masked AᵀA; 834 output-mask entries, 3,854 two-pointer comparisons | Separate retained aggregates: simulator 260,903, hardware 258,351 cycles |

The SpMM and SpGEMM views regenerate the documented training fixture, seed 7,
from `HB/dwt_234`, whose file SHA-256 is checked against its manifest. The
loader supplies the pattern and generates numeric values; those values are
rounded to f32 as in the host upload. SpMM also regenerates B with the host's
`default_rng([7,1])`. The export records the NumPy version and source hashes.

These regenerated numbers are **not retained per-element device readbacks**.
The run reports establish aggregate timings and a passing verification status;
they do not establish instruction-level execution of the reconstructed steps.
No suitable SpMM/SpGEMM instruction/wavelet capture was found in the reviewed
kernel, study, or code-translation artifact paths. The viewer labels the gap.

## What to inspect

**SpMV:** select a row, then advance through its stored nonzeros. The CSR pointer
range determines which slots exist, each column index selects an x value, and
the two recorded arithmetic instructions show the product and new accumulator.
Row 0 is `0.25×0.5 + 0.5×1 + 0.75×1.5 = 1.75`.
Its first product appears at cycle 13657 and first addition at 13659 in the
scalar capture. Each instruction includes UID, PC, lane, bits and raw JSONL row.

The four strategies are scalar CSR, hand-authored IR, block gather and diagonal
streams. Their marker windows are 2172, 2172, 1906 and 438 cycles, respectively.
All use one application PE at fabric (4,1). The diagonal view displays a
canonical CSR row for comparison and separately identifies the actual
`dia_val` packed slot; it does not claim a CSR gather occurs in that strategy.
The separate failing DSD-reduction regression remains visibly marked as failing.

**SpMM:** each CSR value A[r,k] scales a dense B[k,:] slice. Select columns on
either side of the 7/8 boundary and rows on either side of the 127/128 boundary
to see ownership change across the 2×2 mesh. Each PE has capacity for 128×8 C
entries. A's row tiles are host-replicated along mesh rows; B's column slices
are host-replicated down mesh columns. There is no application-level peer
communication during this kernel's compute phase. Pointer displays include both
global CSR slots and their PE-local offsets.

**SpGEMM:** this artifact computes `C<M> = AᵀA`, where M is A's stored pattern.
It is not a general unmasked sparse matrix product. For requested C[i,j], the
view places CSC columns A[:,i] and A[:,j] side by side. Unequal row indices
advance one pointer without a product; equal indices multiply and accumulate.
The output retains its mask slot and row code. A missing structural intersection
would produce the kernel's complemented row code, called a zombie. The selected
fixture has zero zombies; synthetic unit tests exercise disjoint/empty columns
and numeric cancellation so zero is never confused with structural absence.

Snapshot cards show the selected output's partial accumulator. In SpMV they
carry actual Add S6 cycles. In SpMM/SpGEMM they show logical loop steps. They
are not synchronized global mesh snapshots and do not assign SRAM timing,
queue occupancy or packet motion where those observations are unavailable.

## Validation and reproduction

The exporter checks all 480 SpMV arithmetic lane records against expected f32
operand/result bits, and all 64 retained output values across the four passing
strategies. It checks every reconstructed SpMM output against the runner-style
dense reference, and every masked SpGEMM value and structural-existence flag
against dense AᵀA and patternᵀpattern. Reconstructed multiplication and addition
round separately to f32; a compiled fused operation is not assumed.

From the study directory, using an environment with NumPy:

```bash
/home/USER/micromamba/envs/dev/bin/python tools/sparse_viz.py
/home/USER/micromamba/envs/dev/bin/python -m unittest discover -s tests -p test_sparse_viz.py
```

Browser checks from `viewer/`:

```bash
LD_LIBRARY_PATH=/home/USER/.cache/gemm-browser-deps/lib \
PATH=/home/USER/.nvm/versions/node/v24.16.0/bin:$PATH \
npm test -- tests/sparse.spec.ts
```

Outputs are [sparse.json](results/sparse-walkthrough/sparse.json),
[verification.json](results/sparse-walkthrough/verification.json) and the HTML.
Source paths in the export are relative to the xkernel repository. Browser tests
exercise all four SpMV strategies, PE ownership boundaries in SpMM, matching
and skipping in SpGEMM, offline operation, JSON export and a mobile viewport.

No new simulator or hardware workload was launched. To reach the same evidence
level as the PE-hop viewer, the next sparse capture should retain tiny-run
input/output arrays, per-step values, ELF/disassembly, placement and instruction
traces together. A sparse peer-hop demonstration additionally needs an explicit
distributed exchange; it should not be drawn onto these local-compute kernels.
