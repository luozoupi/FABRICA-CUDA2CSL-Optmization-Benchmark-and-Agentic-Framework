# Sparse operators on a wafer-scale engine: what prior work does, what the machine costs, and what follows for SpMV, SpMM and SpGEMM

Written 21 September 2026 for the IPDPS sparse study. Every cost below is a measurement of
this project's WSE-3 characterisation (`studies/wse3-characterization/FINDINGS.md`, silicon
unless marked) or of this suite; every design is either a published one, cited, or one measured
here. The companion `SPARSE_BOTTLENECKS.md` holds the ISA-level diagnosis of the current kernels
and its refuted remedy; this document is the constructive half.

## 1. How prior work maps sparse kernels onto the wafer

Three published designs, and what each committed to.

**Cerebras' own hypersparse SpMV** (`csl-examples/benchmarks/spmv-hypersparse`, WSE-2). The
matrix is cut into a 2-D grid of PE tiles; PE `(px, py)` owns the block A_ij with `bx = ceil(nrows /
fabx)` rows and `by = ceil(ncols / faby)` columns, stored per PE as compressed columns. The input
vector is distributed by columns of PEs and the output by rows, so `x` moves along one mesh axis
and partial `y` reduces along the other -- two one-dimensional collectives. The example's README
says outright that performance depends on load balance and ships `util/analyze.cpp`, which
searches for row and column permutations `(P, Q)` minimising the variance of `nnz(B_ij)` across
tiles. Two facts for our purposes: the communication per PE is `O(ncols/faby + nrows/fabx)`, not
`O(ncols)`, and *balance is a preprocessing decision made from the matrix's structure*, exactly
the quantity our structure readout reports as `pe_imbalance`. Its WSE-2 fabric idioms do not
port to WSE-3 (`docs/WSE3_PORTING.md`), which is why this suite has its own strip kernel.

**Shah, Di and Becchi, SpMM and SDDMM on the CS-3** (arXiv 2604.27985). Low-level designs with
distinct PE roles -- routers that move operands, workers that compute, accumulators that
reduce -- a SELL-PACK-like layout for the sparse operand of SpMM and COO for SDDMM, on
synthetic matrices up to 65,536 rows. Reported up to 100x over a CPU for SpMM at 90% sparsity,
with the advantage *growing* with matrix dimension and *collapsing* past 99% sparsity toward or
below CPU libraries. The collapse is the point of contact with this study: at high sparsity
the per-nonzero fixed costs dominate, and those costs are what Section 2 measures.

**WaferLLM** (OSDI'25) and this project's MeshGEMV walkthrough. Dense, but they fix the
decomposition vocabulary this suite inherits: PE rows partition one operand index, PE columns
the other, partial sums travel one axis and results replicate back. The lesson that carries
over is that a PE is one instruction stream with about 45 KB of memory, so *everything* larger
is a distribution problem, and the wafer bound comes from capacity and routing before it comes
from arithmetic (FINDINGS 9: a single PE holds a 148x148 f16 matrix-vector problem and no
more).

**GraphBLAS' GPU kernels** (`GraphBLAS/CUDA`), our translation sources, solve a different
problem: keeping thousands of threads independent. Bucketing mask entries by list length
(`vsvs`, `vssp`, `mergepath`), recovering a row by binary search over the row pointers
(`ek_slice`), warp shuffles for reductions, atomics for scatter, cumulative sums for output
sizing. None of these mechanisms exists on a PE; each has a mapping (`CUDA_TO_CSL_SPARSE_PATTERNS.md`,
15 patterns), and one of those mappings has now been refuted by measurement (P6's branchless
merge). The catalogue is a set of measured facts, not a theory, and it is corrected when the
harness says so.

## 2. What the machine costs, in the units sparse code is paid in

| quantity | value | evidence |
|---|---:|---|
| PE memory for the application | 44,976 B | compiled, FINDINGS 9 |
| descriptor (DSD) setup | 15--17 cycles per dispatch | silicon, FINDINGS 3 |
| loop back-edge | 9--10 cycles | simulator, FINDINGS 10h |
| a taken branch | 9--10 cycles | simulator, FINDINGS 10h |
| fp32 FMA | 0.5 elements/cycle | silicon, FINDINGS 3 |
| fp16 FMA | 2.92 elements/cycle | silicon, FINDINGS 3 |
| fabric hop | 2.0 cycles, isotropic | silicon, FINDINGS 4 |
| fabric wavelet | 1.125 cycles (1.0 in the simulator) | silicon, FINDINGS 4 |
| route turn | ~20 cycles | silicon, FINDINGS 4 |
| store-and-forward relay stage | 1.001 N B + 16.1 N + 16.5 | simulator, FINDINGS 10g |
| SRAM bank class penalty (f32, period 4) | 1.94x same-class, up to 2.86x | silicon, FINDINGS 3; invisible in the simulator |
| the sparse ladder, one PE | 36.2 / 31.8 / 7.3 cycles per nnz (scalar / per-row DSD / diagonal) | simulator, FINDINGS 10n |
| u32 index arithmetic | 3.5 scale-and-narrow shift pairs per nonzero | FINDINGS 10n, 12c |

Three consequences organise every design below.

1. **A nonzero is worth about 36 cycles as a scalar gather and about 7 as an element of a stream.**
   The whole game on one PE is turning gathers into streams, and a stream needs an affine run,
   which a sparse matrix only has along an axis its structure defines.
2. **Fixed costs are in the tens of cycles.** A descriptor costs 16 cycles to set up, a branch 10,
   a relay stage 16. Any per-row or per-entry mechanism amortised over fewer than ~16 elements is
   setup-bound; that is Shah et al.'s collapse at 99% sparsity in one line.
3. **Communication is cheap per wavelet and expensive per turn.** 2 cycles a hop and ~1 a wavelet
   mean broadcasting a 1,024-element vector along a strip of 16 PEs costs about as much as
   scattering 30 nonzeros; a route turn costs as much as ten hops. Straight lines, few turns.

## 3. What follows for each operator, and what the measurements did to it

### SpMV: the axis change is a layout decision, and layout is decided by the host contract

The suite's SpMV runs at 34.9 cycles per nonzero on its busiest PE, the scalar rung, on a
training matrix that holds 90% of its nonzeros in six diagonals (`SPARSE_BOTTLENECKS.md`). The
characterisation study measured the diagonal form, which streams each diagonal against a shifted
window of x and accumulates into y with memory-destination adds, at 7.3 cycles per nonzero.
The catalogue's P5 therefore said: choose the vectorised axis from the structure, and build the
layout on the PE if the host contract is CSR.

Hand-written, robust to the held-out matrices (the first ten distinct diagonals go to a dense
diagonal store, everything else is compacted in place into a remainder CSR and swept scalar),
with the conversion inside the timed window because that is where it runs:

| program, `small` (4 PEs, one product) | cycles | against the reference |
|---|---:|---:|
| reference, scalar CSR | 37,330 | 1.00x |
| **diagonals + remainder, converted on the PE** | **172,302** | **0.22x** |

Correct on every matrix, and 4.6x slower. The conversion is a scalar pass that, per nonzero,
searches the slot table for the nonzero's diagonal -- a branch per slot at 9-10 cycles each -- and
computes a 32-bit index; at roughly 150 cycles per nonzero it costs four scalar SpMVs before the
first descriptor is dispatched. The ladder's 4.96x is real, but it was measured with the layout
already in place. Under a CSR host contract at one product per launch, changing the axis on the
PE is a loss, and P5's "build the layout once on the PE" is a prescription that ignores where
the cycles of "once" are counted.

Both follow-ups were measured the same afternoon, prediction recorded first (a loss at one
product, a win of a few times at ten):

| SpMV-RowBlock, 4 PEs, held-out passing | 1 product (`small`) | 10 resident products (`it10`) |
|---|---:|---:|
| reference, scalar CSR | 37,330 | 373,685 (exactly 10x) |
| diagonals + remainder, v1 (slot search) | 172,302 (0.22x) | 290,550 (1.29x) |
| **diagonals + remainder, v2 (O(1) slot table)** | 72,585 (0.51x) | **191,462 (1.95x)** |

The two v2 points decompose exactly into cost = C + iters * S: a one-time conversion **C = 59,376**
cycles and a per-product sweep **S = 13,209**, which is 2.83x the reference per product once the
layout exists; the conversion costs 1.6 reference products; break-even is **2.5 products**. The
gap to the ladder's 4.96x is padding -- the diagonal store holds zeros where a diagonal has no
entry, so the busiest PE streams about 1.7x more elements than it has nonzeros -- and the
remainder pass still visits every row. Both are recoverable and neither changes the shape.

So the prescription is rewritten, not withdrawn. **The axis change pays when the matrix is
resident** -- from the third product on here, 1.95x at ten, 2.83x asymptotically -- and loses at one
product under a CSR contract because the conversion is charged inside the window. The right home
for the conversion is the host, as Cerebras' hypersparse example does with its preprocessing
step and Shah et al. with SELL-PACK; the agent's job, given the structure readout, is to
recognise that the contract should change or that the workload is resident. The `it10` size
exists so that an optimiser arm can be paid for exactly that recognition.

*Measured 22 Sep, `it10` (ten resident products, the size on which the axis change pays):* luna O0 takes the frozen program from 380,296 to **363,378** (1.047x; 1.028x below the reference) by generic steps; O1 selects `vectorise_along_structure` and fails to compile it (`@fmacs` operand form), ending at the start. The expert DIA v2 ceiling on this size is 1.95x. The gap between "the angle names the transformation" and "the model writes it" is the open problem this operator exposes.

### SpGEMM: replace the merge with an accumulator, and expect a modest win at short rows

*Measured 26-27 Sep:* the NVIDIA node's explicit-cursor-paths rewrite of the merge (the two cursor updates as control-flow paths with `continue`; cslc then emits conditional register increments instead of an indirectly selected stack cursor) gives **1.18x** on the reference at list 3.6 and **1.15x** at 9.0 -- so P6's cost is the indirect cursor, not the branch count (the branchless advance kept the indirection and lost, 0.45x). As an optimiser angle (arm O1X, 3 seeds) it was selected once and delivered 1.15x over its start when chosen, but the descriptor angles that give 2.1x from the same start win the selection every time.

The masked product C<M> = A'A computes, for each mask entry (i, j), the dot product of two sparse
columns. GraphBLAS does it as a two-pointer merge; on this core that merge is ~44 cycles per step
of which ~38 are branch (`SPARSE_BOTTLENECKS.md`), and the branches cannot be removed from source
(P6, refuted: 0.45x). The structural alternative is Gustavson's: scatter A(:,j) into a dense
accumulator over the row index once per column, then compute every mask entry of that column as
a *gather* of A(:,i) against it. No comparison, no merge; one branch per mask entry for the
zombie test. The accumulator is un-scattered rather than cleared, so the per-column cost stays
proportional to the column's nonzeros, and a parallel pattern accumulator supplies the "exists"
bit. Extra state: n f32 + n u32, 2 KB at n = 256.

Measured, hand-written, held-out matrices passing:

| program | cycles | against the reference |
|---|---:|---:|
| reference merge | 260,903 | 1.00x |
| **dense accumulator (P7)** | **222,989** | **1.17x** |
| branchless merge (P6, refuted) | 577,853 | 0.45x |
| gpt-5.6-luna, optimiser arm O1 | 202,106 | 1.29x |

Two readings. P7 is validated but modest: at a mean list length of 3.6 the merge is ~7 steps,
and the accumulator's three scalar passes over the same ~3.6 entries cost nearly as much; the
accumulator's advantage grows with list length, which the new `n144` size measures. Its reference baseline is in: 845,529 cycles for 1,296 mask entries, **652 cycles per entry against 316** on the `small` class -- the mean list is 2.5x longer (9.0 against 3.6) and the merge costs 2.06x per entry, close to linear in the two lengths combined, as a two-pointer merge should. The accumulator's per-column cost is also linear in the lists, and the constants now have a second point: on `n144` the accumulator runs 590,279 against the reference's 845,529, **1.43x**, up from 1.17x at list length 3.6 -- the predicted growth. Luna's O1 program, optimised on the `small` class and never shown this one, runs 601,662 (1.41x): the optimiser's rewrites of the merge transfer across matrix classes and land within 2% of the structural rewrite.

### SpMM: the agent already took the axis; what is left is amortisation

*Measured 22 Sep, three seeds:* the best SpMM program is luna O1 seed 3 at **27,114 (1.14x over the start, 3.93x over the reference)** -- `dense_row_accumulator`, read on SpMM as "first product with `@fmuls`, no zero pass, chained C descriptor"; medians O0 29,270 / O1 29,289. SpMV `small`: null in 6/6 cells, and O1's candidates compile+run 9/30 against O0's 22/30 -- the layout-changing angles are named but not written. SpGEMM: 194,615-264,805 over six cells (1.34x faster to 1% slower than the reference); O1/O0 geomean over the three tasks 1.012x (0.999-1.037).

*Measured 21 Sep (re-run after the contract correction):* the optimiser amortises further -- luna O0 takes the frozen 30,954 to **28,444 (1.088x)** with a `fmac_bulk` form (3 descriptor operations against 1), O1 to 29,289; both below the W1 best of 29,807. On SpMV `small` neither arm improved on 37,012, as the crossover predicts for one product; two faster SpMV candidates (36,297 and 8,768 cycles) failed the numerical check, and the axis change was selected but never compiled (`@fmacs` with four DSD operands).

Row-tiled A against column-sliced dense B is communication-free on a P x P mesh, and the inner
sweep over the dense operand's columns is an affine run of length N_t -- the agent turned it into
one descriptor multiply-accumulate per row-nonzero and beat the reference 3.58x. The remaining
cost is the descriptor setup, 15--17 cycles amortised over only N_t = 8 elements: 441 setups on
the busiest PE, about 24% of the run. The lever is N_t: the new `n16` size doubles the columns
per PE at the same matrices (capacity forced `max_nnz_pe` from 2048 to 1536, which the class
still fits), so the same program is paid the same setup for twice the streamed work. The *reference* at `n16` runs 289,574 cycles against 106,606 at half the width -- 2.72x for 2x the multiply-adds, 41 against 30 cycles each -- because its scalar inner loop pays index arithmetic per element and the wider tile lengthens the strided access into the dense operand. That is the number the agent's descriptor form is measured against on this size, and it was: the W1 best runs 37,454 on `n16` against 29,807 on `small` -- **1.26x the cycles for 2x the multiply-adds**, 8.45 -> 5.31 cycles per multiply-add -- so the setup is amortised as predicted and the agent's advantage over the scalar reference goes from 3.58x at Nt=8 to **7.73x at Nt=16**. A single size would have reported 3.58x. Shah et
al.'s SELL-PACK layout is the same instinct applied to the sparse operand: pack rows so that
every descriptor covers a full run.

## 4. The workload axis: sizes that expose the stories

A single point per task cannot separate the fixed costs from the streaming costs, or the
structure that pays from the structure that does not. Four sizes are added; every existing size,
cap and matrix is unchanged, so nothing already measured moves.

| task | size | what changes | what it exposes |
|---|---|---|---|
| SpMV-RowBlock | `p8` | 8 PEs on the *same* matrices as `small` (4) and alongside `p16` | strong scaling of a 1-D strip: per-PE nonzeros halve, the x broadcast does not |
| SpMV-RowBlock | `it10` | `small` with the matrix resident for 10 iterations | the iterative-solver workload: a one-time layout conversion amortises, setup costs do not |
| SpMM-CSR-Dense | `n16` | `small` with N_t = 16 | descriptor-setup amortisation, the 24% |
| SpGEMM-Masked-Dot | `n144` | a second matrix class, mean row length 9.0 against 3.6 | merge cost against list length, and where the accumulator overtakes it |

Capacity decides what is *not* there: SpMV at P = 1 or 2 on the `small` class does not fit
(8,704 and 4,352 nonzeros per PE with 32-bit indices exceed the PE), and SpGEMM at n = 512
does not fit with five 32-bit arrays per nonzero. Those absences are themselves a finding about
32-bit indices on a 45 KB machine, and the pre-registration records the sizes that were
considered and rejected as well as the ones added.

The SpGEMM size needed a `structure_id` parameter to select its matrix class. It is declared and
consumed in `layout.csl` only, so `pe.csl` -- the file the agent writes, and every frozen
first-correct program -- is byte-for-byte unchanged and the existing size's cycle count must
reproduce exactly; that reproduction is part of the baseline run.

## 5. What remains untested, stated plainly

- The 4.8x axis change for SpMV has not been reached by any agent arm: the angle was in the
  whitelist, undenied, and never selected within the 5--12 attempt budget by three models.
- The accumulator's growth with list length has two points (1.17x, 1.43x); a third class would
  fix the curve.
- Everything here is one PE to sixteen PEs; the 2-D tiling of the hypersparse example and
  the router/worker/accumulator roles of Shah et al. are the designs that scale further, and
  this suite does not test them.
- Static instruction counts compare a program with its own reference under one compiler; they
  are not a cost model, and the cycles quoted are always measured `cycles_send`.
