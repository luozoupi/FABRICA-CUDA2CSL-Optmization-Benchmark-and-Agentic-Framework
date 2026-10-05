# Review of the supplied seven-traversal walkthrough

Reviewed 2026-09-22: `/home/USER/matmul-7ways.html`, 134,462 bytes. This updated
file contains the actual application, replacing the earlier incomplete page
shell. The public Claude URL's access failure no longer blocks review.

Open the [working reference copy](external/matmul-reference/matmul-seven-traversals-working.html).
The original is preserved. Its saved DOM already contains seven tabs and sixteen
ΔC cells; initialization appends them again, producing fourteen tabs, thirty-two
cells and `Cannot read properties of undefined (reading 'tag')`. The working
copy clears those two containers before initialization and removes the missing
optional font stylesheet/preconnects. It uses system font fallbacks. No arithmetic
or explanatory text was changed.

## What the seven tabs actually represent

The page uses HTML/CSS grids and JavaScript, with no Canvas or WebGL renderer.
It fixes M=N=K=4 and uses 2×2 tiles. These are seven teaching views, not seven
independent loop permutations. GEMV and vector–matrix views group the row/column
AXPY steps; blocking introduces another level of traversal.

| View | Coarse step (count) | Fine step (count) | Mapping to our WSE experiments |
|---|---|---|---|
| Inner product, `ijk` | Complete one C element (16) | One MAC (64) | Corrected `ijk_reduce`; `jik_reduce` changes output order |
| Outer product, `kij` | Rank-one update of all C (4) | One MAC (64) | `kij` decomposes each rank-one update into row FMACH instructions |
| Row AXPY, `ikj` | Update one C row for one k (16) | One MAC (64) | `ikj` and `ikj_map` share the mathematics but differ in descriptor reuse |
| Column AXPY, `jki` | Update one C column for one k (16) | One MAC (64) | `jki`; row-major layout gives strided vector operands |
| Matrix × column vectors | Complete one C column / GEMV (4) | Column AXPY (16) | Groups the `jki` steps; this does not independently specify a PE partition |
| Row vectors × matrix | Complete one C row (4) | Row AXPY (16) | Groups `ikj_map`; B residency must be established from the chosen kernel |
| Tiling | One 2×2 tile multiply–accumulate (8) | Length-two partial dot for one output (32) | A future I/J/K-tiled control; our current blocked controls split only j into row segments |

The last distinction matters: the existing packed-B result is evidence about a
particular row-segment implementation. It does not yet measure the reference's
full two-dimensional output tiling with an independent K tile loop.

## Validation

The retained [review script](external/matmul-reference/review-local.mjs) checks
all fourteen method/granularity combinations against an independent matrix
product for the supplied inputs and ten deterministic signed input sets. All
154 cases pass, with 4,268 intermediate states checked for ΔC consistency,
correct finalized elements and a total of 64 MACs per traversal.

Chromium checks all fourteen combinations in the repaired copy, including final
matrix values and progress counters. Next-step and keyboard stepping work;
there are no page errors or failed resource requests in that copy. The
[machine-readable review](external/matmul-reference/local-review.json) records
the original SHA-256, original browser error and validation results. Screenshots:
[tiling](external/matmul-reference/local-tiling.png),
[fine row update](external/matmul-reference/local-row-fine.png).

## What to carry into the WSE presentation

The strongest features are the persistent numeric A/B/C arrays, a separate ΔC
panel, highlighted loop indices, and the distinction between touched outputs
and finalized outputs. Coarse/fine navigation makes the same computation readable
at several levels. Our WebGL viewer can adopt that hierarchy while retaining
the observed instruction operands and cycles beneath it.

Several interpretations need to stay explicit:

- A teaching step is not a cycle. Fine mode can mean one MAC, a whole AXPY, or a
  two-product partial dot, depending on the tab. Same-cycle SIMD lanes in our
  captures must remain simultaneous when stepping down to individual elements.
- The page starts after its first mathematical update; reset does not show an
  all-zero initial state. A WSE journey also needs pre-load, SRAM population,
  communication, arithmetic and readback stages.
- A stationary-looking matrix is a mathematical convention, not a measurement
  of its storage or movement. In our tested vector kernels, C is backed by a
  memory DSD. The corrected dot reduction uses a zero-stride memory accumulator.
  Neither should be drawn as an observed register-resident output tile.
- CPU/GPU statements about cache traffic, register tiles or bandwidth do not
  determine WSE timings. Count bytes at a named boundary: host/wafer, PE/PE,
  or local SRAM/arithmetic unit. Equal operand values alone do not identify the
  storage path; use the source, descriptors, disassembly and trace together.
- The reference's traffic estimate of `3T²` elements when C also moves needs
  qualification: reading an existing C tile and writing it back moves `2T²`
  C elements, giving `4T²` total with A and B. `3T²` applies when C requires
  only an output write, for example a zero-initialized standalone tile product.

## Concrete next comparison

Add a true I/J/P tiled microbenchmark with independently selected output tile
shape, K chunk and in-tile kernel. Compare against the existing full-row and
packed-row kernels with the same inputs and precision; account for packing and
SRAM footprint separately. Use this teaching hierarchy:

**whole GEMM → output tile on its owner PE → K-panel arrival → local row/rank-one
update → compiled instruction → observed SIMD operands/results.**

Then hold a 2×2-PE SUMMA schedule fixed while changing the local kernel. For each
panel, show the numbers, source/destination PE, observed hops and readiness
before computation. This separates local instruction efficiency from network
placement and communication costs. The seven reference tabs provide the
mathematical explanation; measurements determine which implementation wins.
