# Matmul formulation, implementation and dataflow comparison

Open [the WebGL debugger-style presentation](results/matmul-compare/matmul.html).
The **Hardware residency · weight streaming** tab adds a numerical reconstruction
of the HC2022 mapping, using the same operands as captured g1. See the
[hardware dataflow review](GEMM_HARDWARE_DATAFLOW.md) for SRAM/cache distinctions,
generation-specific sources and validation boundaries.
The new capture is [try-20260922a](results/matmul-compare/try-20260922a).
[Reproduction instructions](microbench/matmul_compare/README.md) preserve the
older `matmulorder` capture.

## Reference review

The updated `/home/USER/matmul-7ways.html` now contains the full application and
has been reviewed. See the [seven-view mapping and validation](MATMUL_REFERENCE_REVIEW.md)
and [working reference copy](external/matmul-reference/matmul-seven-traversals-working.html).
The copy fixes duplicate initialization in the browser-saved DOM; the supplied
file is preserved. The earlier missing-iframe and public-URL access failures
describe the previous copy, not the newly supplied content.

Its seven tabs are inner product, outer product, row AXPY, column AXPY, matrix
times column vectors, row vectors times matrix, and tiling. The GEMV views group
AXPY operations; tiling adds a hierarchy. Our twelve CSL implementations vary
loop order, reduction, descriptor reuse and packing. In particular, our blocked
controls split output rows into j segments; they are not yet the reference's
full I/J/K tiled algorithm.

## Current result

The row-wise `@map` implementation is fastest among the eleven correct variants
at each tested size. Its advantage is the combination of contiguous row access,
scalar/vector FMA shape, and descriptor reuse. The original experiment changed
more than loop order: dot products had incorrect reduction semantics, while
blocked rows reloaded descriptors. Both confounders now have executable controls.

Median simulator kernel cycles, three timed invocations after one warmup:

| Implementation | 4×4 | 8×8 | 32×32 |
|---|---:|---:|---:|
| Row `ikj` + `@map` | 203 | 471 | 10,239 |
| Row `ikj` | 497 | 2,087 | 45,327 |
| Outer product by rows `kij` | 490 | 2,031 | 45,352 |
| Column `jki` | 510 | 2,441 | 104,813 |
| Outer product by columns `kji` | 512 | 2,444 | 103,849 |
| Corrected dot `ijk` | 725 | 4,033 | 177,322 |
| Corrected dot `jik` | 708 | 3,957 | 180,232 |
| Corrected dot with Bᵀ | 689 | 3,462 | 145,801 |
| Blocked row, descriptor reload | 1,937 | 7,663 | 158,988 |
| Blocked row, packed B + `@map` | 872 | 2,116 | 17,550 |
| Scalar dot | 528 | 3,175 | 868,586 |

All three timed repetitions are identical in this deterministic simulator
configuration. This is not a silicon variability estimate. Each result passes
exact equality against an independently computed integer reference. f16 inputs
are integers in [-2,2]; products and all sums stay exactly representable. The
intentionally incorrect `ijk_bad` diagnostic fails at all sizes and is excluded
from ranking.

At 32×32, packed blocking is about 9.06× faster than the descriptor-reload
blocked implementation and 1.71× slower than the full-row `@map` kernel. The
packed variant uses an additional B buffer, and host packing is outside the
reported kernel interval. This demonstrates that tiling can retain a streaming
DSR when the physical layout matches its advance; it does not establish an
end-to-end advantage once packing and transfers are included.

## What each method actually does

| Form | Operation / data movement on one PE | Main controlled cost |
|---|---|---|
| `ikj`, `kij` | A scalar + contiguous B row + contiguous C row → vector FMACH | Per-step address/descriptor setup versus reusable DSRs |
| `jki`, `kji` | B scalar + strided A column + strided C column → FMACH | Layout and observed SIMD lane use |
| `ijk`, `jik` | Vector multiply A row / B column → temporary products → accumulating reduction | Strided operand and dependency through accumulator |
| Bᵀ dot | Two contiguous rows → products → same corrected reduction | Changes B stride while retaining reduction |
| Blocked row | A scalar + a portion of B row + C tile → FMACH | Vector width, descriptor setup, packing |

The current [Cerebras DSD guide](https://sdk.cerebras.ai/csl/language/dsds)
describes a pointer destination as repeated writes to one address. A scalar
source passed to that operation supplies one value; it is not automatically a
feedback accumulator. The corrected probe supplies the same zero-stride memory
DSD to destination and src0. Captured FADDH operands then carry the changing sum.
See also the [documented builtin forms](https://sdk.cerebras.ai/csl/language/builtins).
The old failure was an implementation-semantics issue; it is not evidence that
correct dot products are impossible, nor proof of a compiler defect.

## Debug presentation and evidence

The updated artifact adopts the supplied reference's light layout, persistent
numeric A/B/C matrices, ΔC panel, form tabs and coarse/fine navigation. It keeps
the measured WSE instruction evidence and adds the existing mesh captures to
the same offline file and read-only backend.

- **Single PE · formulations:** choose a mathematical view and implementation.
  Coarse groups captured arithmetic instructions into a dot product, rank-one
  update, AXPY, full output row/column or row segment. Fine advances one
  instruction; element buttons inspect its SIMD operands. The inspector labels
  which instruction is shown when the matrix represents a larger group.
- **Host inputs → Copy to SRAM → Initialize C → Compute → Readback:** these
  controls expose the full source/host workflow, including the initial zeros
  and exact retained output. They do not assign fabricated cycles to host I/O.
- **Mesh GEMM / GEMV · full workflow:** choose captured 4×4 or 8×8 GEMM, or 4×4
  MeshGEMV, on 2×2 PEs. Step through tile placement, panel broadcasts or partial
  reduction, arithmetic, result replication where applicable, and host gather.
  The inspector shows local arrays, packed order, and ELF storage addresses.
- Mesh **Fine · event / word** replays individual arithmetic events within the
  selected teaching group, or inspects a single transferred word. The WebGL map
  labels the payload and route. The ledger retains packet ID, routing color,
  raw word, observed locations/cycles/rows, send, receive and arithmetic consumer.

Mesh scenes are copied with a SHA-256 reference to `viewer/public/dataflow-bundle.json`.
They retain their original instrumented f32 captures; this presentation change
does not add device runs or equate their timings with the f16 kernel comparison.
Fine replay within a mathematical group is not a global chronological SRAM
snapshot. Complete input panels are checked round history, even when the
inspector selects just one word's arrival. Host routes are dashed schematics;
application packet routes are solid. GEMV's X slices are host-replicated;
its observed PE traffic carries partials and completed-result replicas.

- Choose a method and 4×4 or 8×8 inputs. Global A, logical/physical B, and C remain
  visible. The selected input numbers, loop indices, relative SRAM offsets, and
  arithmetic operands are shown together.
- Step one compiled arithmetic instruction; inspect its individual SIMD element,
  lane, UID, PC, dispatch cycle, S6 cycle, and raw trace row. A cell breakpoint
  advances replay to the next instruction writing a chosen C[i,j].
- C is the mathematical state after the complete instruction. Selecting another
  element inspects it; it does not serialize lanes that execute in the same cycle.
- The exporter checks vector lengths, full ordered arithmetic dispatch counts,
  and all used operands/results across four invocations. The displayed warmup
  has 960 matched elements at 4×4 and 7,680 at 8×8: 8,640 displayed and 34,560
  validated across all four invocations. Scalar source-order steps are explicitly
  unbound because the optimizer reorders some scalar instructions.
- No optnone rewrite or per-product device logging is used in these captures.
  The 32×32 timing run suppresses simulator traces; 4×4 and 8×8 retain them.
  The [SDK runtime docs](https://sdk.cerebras.ai/api-docs/sdkruntime-api)
  document this option as a way to reduce simulator wall-clock overhead.
- This is read-only trace replay, not a live hardware debugger. Relative offsets
  are source-derived, not observed memory addresses. Operand observations do not
  reveal arbitrary-cycle SRAM/register snapshots or pipeline latch contents.

## Next controlled experiments on multiple PEs

The existing multi-PE GEMM uses SUMMA-style A-row/B-column panel broadcasts and
keeps C on its owner. Those teaching captures use explicit f32 operations and
instrumentation; their durations must not be compared directly with this f16
optimized single-PE sweep.

1. Hold SUMMA placement, f16 inputs, message schedule and output ownership fixed;
   replace only the local panel-update kernel with plain row FMACH, full-row
   `@map`, and packed blocked `@map`. Start with 2×2 PEs and local widths 8/16.
2. Record separate panel-send, receive-ready, local-compute, and round-complete
   intervals. Bind wavelet identity, full payload and consuming instruction;
   display each panel's numbers before and after its hop.
3. Compare the same global work on 1×1, 2×2 and 4×4 PE grids, while also reporting
   local tile dimensions and SRAM footprint. Include warmup, repeated trials,
   correctness, packing time, and host transfers as separate quantities.
4. Once local compute is controlled, vary the communication algorithm: SUMMA
   panel broadcasts versus a nearest-neighbor shifting schedule. The timeline
   should measure exposed waits and overlap rather than infer network latency
   from the difference between two endpoint timestamps.

A useful fitted model is kernel launch + descriptor setup + arithmetic execution
+ exposed operand/communication waits. These terms overlap and cannot simply be
summed from instruction counts. Fit them from controlled perturbations (tile
size, stride, descriptor reuse, and hop count), then test the model on held-out
matrix shapes. Rankings remain conditional on precision, layout, tile size,
PE count, SRAM capacity, and whether packing/I/O are amortized.
