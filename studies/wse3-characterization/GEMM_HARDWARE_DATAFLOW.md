# GEMM hardware residency and weight streaming

Updated 2026-09-23. Open the [WebGL matmul microscope](results/matmul-compare/matmul.html#view=stream),
then **Hardware residency · weight streaming**. The original single-PE and captured
mesh workflows remain available in the first two tabs.

The important finding is that there is no single WSE GEMM placement. The user-supplied
presentation describes a vendor training mapping, while our small CSL GEMM and
WaferLLM use different algorithms. The new view explicitly separates a documented
numerical model from captured execution.

## What the official material establishes

In the training mapping, activation features are partitioned across PE columns and
samples across PE rows. Activation slices reside in local SRAM. MemoryX streams
indexed weights down columns; each nonzero drives a local vector update. Partial
sums are reduced across rows, with PSUM/FSUM controlling reduction and final ownership.
See [HC2022, pp. 20–25](https://hc34.hotchips.org/assets/program/conference/day2/Machine%20Learning/HC2022_Cerebras_Final_v02.pdf#page=20).

The [official accompanying explanation](https://www.cerebras.ai/blog/cerebras-architecture-deep-dive-first-look-inside-the-hw-sw-co-design-for-deep-learning)
places local accumulators in a software-managed cache and describes overlap of
reduction with subsequent weights. No full local weight array is needed in that
mapping; this does not exclude transient weights in fabric queues or operand storage.

The 2022 chip is **WSE-2**. [HC2024, p. 29](https://hc2024.hotchips.org/assets/program/conference/day2/72_HC2024.Cerebras.Sean.v03.final.pdf#page=29)
documents WSE-3 with 48 KB local SRAM, a 512 B local cache, 48 DSRs, 16 GPRs, and
eight 16-bit SIMD lanes. Its [inference mapping, p. 41](https://hc2024.hotchips.org/assets/program/conference/day2/72_HC2024.Cerebras.Sean.v03.final.pdf#page=41)
keeps weights and KV on wafer and passes activations between layer regions. Weight
streaming is therefore not a universal description of WSE-3 execution.

## Numerical reconstruction

The new model uses **the captured g1 inputs**, with `X=A`, `W=Bᵀ`, and `Y=XWᵀ=C`.
All numbers are small integers, so this example is exactly representable without
introducing a rounding-policy assumption. The PE grid is 2 × 2:

| Logical PE | Samples b | Input features k | Local X SRAM slice | Final output features |
|---|---|---|---|---|
| (0,0) | 0,1 | 0,1 | [[1,2],[5,6]] | 0,1 |
| (1,0) | 0,1 | 2,3 | [[3,4],[7,8]] | 2,3 |
| (0,1) | 2,3 | 0,1 | [[9,10],[13,14]] | 0,1 |
| (1,1) | 2,3 | 2,3 | [[11,12],[15,16]] | 2,3 |

For output feature 0, `W[0,:]=[1,0,2,1]`:

1. Weight 1 with index 0 reaches column 0. PE (0,0) reads `[1,5]` and updates
   its partial vector from `[0,0]` to `[1,5]`. PE (0,1) similarly updates `[9,13]`.
2. The zero coefficient at index 1 is omitted.
3. Weight 2 with index 2 reaches column 1. PE (1,0) computes `[3,7]×2=[6,14]`.
4. Weight 1 with index 3 adds `[4,8]`, giving `[10,22]` on PE (1,0).
5. Row reduction combines `[1,5]+[10,22]=[11,27]` at PE (0,0).
   The other row produces `[43,59]`.
6. These become the first output feature in the owning PE's SRAM. Local partial
   vectors are cleared for the next output feature.

The viewer exposes each dependency step, exact before/product/after values, selected
PE input and output slices, recent state history, and separate WebGL mesh and core
views. Vertical green paths carry weights; horizontal purple paths carry partials.
Only the active mesh transfer is drawn. Final outputs remain dots until reduction
and placement finish; they are not confused with local partial sums.

We chose contiguous output-feature ownership and serialized output rows for clarity.
The ingress edge, packet ordering, two-column reduction route and intermediate
buffering are illustrative. The model has **no cycle timestamps**, no fabricated
cache snapshots and no claimed proprietary instruction sequence. A true vendor
schedule can overlap operations; these diagrams do not establish its overlap.

## Comparison with local evidence

| Implementation | Stationary / resident | Movement | Accumulator evidence |
|---|---|---|---|
| Tiny SUMMA-like g1/g2 | Original A/B tiles and owner C | A panels across rows, B panels down columns into remote `abuf`/`bbuf` | f32 scalar instruction operands; source stores C after each term; no C reduction across PEs |
| WaferLLM MeshGEMM | Owner C; double-buffered X/W | X shifts horizontally, W vertically on folded rings | Source-derived Cannon reconstruction; bounded fabric profile in FINDINGS §10s |
| Single-PE `ikj_map` | A/B/C SRAM-backed arrays | Local scalar/vector operand reads | Captured f16 FMACH operands and results; C described by a memory DSD |
| Vendor training model | Local X slices, off-wafer W | Weight broadcast and partial-sum reduction | Documented software-managed partial storage; not an SDK capture |

For the small captured GEMM, the source/ELF/IR and trace-supported path is:

```text
owner A/B SRAM → fabric send → PE router / input queue
             → remote abuf/bbuf SRAM → scalar GPR operands
             → FMULS / FADDS → owner C SRAM
```

Panel-owning PEs use original A/B arrays directly. C stays on its owner throughout
K rounds. The [existing mesh tab](results/matmul-compare/matmul.html) links packet
values to actual send, receive and consumer instructions. Source-defined SRAM
backing does not determine every internal cache access, bank selection or commit
cycle. DSRs contain operand descriptors, not whole activation arrays.

The prior §10s comparison has been corrected: WSE-2 pipeline labels and memory
bandwidth do not prove WSE-3 stage meanings or bottlenecks. A per-operand 16-entry
DSR file is not the total number of DSRs. The [architecture review](ARCHITECTURE_REVIEW.md)
contains the broader WSE-3 evidence and open questions.

## Performance quantities this model can support

The example has 13 nonzero weights, 26 PE weight deliveries, 52 scalar products,
8 peer partial-vector transfers (16 scalar partial values), and 16 final outputs.
These are counts in the **chosen two-column schedule**, excluding commands,
encoding, transport headers, host transfer and topology-dependent routing.
Logical PE delivery counts are not off-chip byte counts.

For a future matched implementation, estimate separate terms for weight injection,
AXPY service, row reduction and setup. Under full overlap the steady-state lower
bound is the maximum resource demand; a serialized schedule sums the terms.
Measured startup/drain and dependencies must be added. Fit rates and overlap from
new traces rather than treating this lesson's step count as time.

The next useful experiment is an SDK analogue with resident X, fabric-streamed
indexed weights and explicit row reduction, alongside the existing SUMMA kernel
with identical operands. Vary samples per PE, local K size, sparsity and PE columns;
retain matched arithmetic and wavelet traces plus endpoint readback. This would
test the public dataflow idea, not reproduce the undisclosed MemoryX runtime.
No new device execution or speed comparison is claimed in this update.

## Reproduction and validation

`tools/weight_streaming.py` builds the model as part of `tools/matmul_compare.py`.
The existing read-only backend serves it inside `/api/matmul`; the standalone HTML
embeds the same bundle and works without a server or network access.

```bash
python tools/matmul_compare.py
npm --prefix viewer run build:matmul
python viewer/build_standalone.py --dist dist/matmul --page matmul.html \
  --bundle matmul-bundle.json --global-name MATMUL_BUNDLE \
  --out results/matmul-compare/matmul.html
python -m unittest discover -s tests -p 'test_weight_streaming.py' -v
```

Model tests independently check coverage of every nonzero product, skipped zeros,
column destinations, local partials, horizontal reductions, single output ownership
and equality with g1 readback. Browser tests exercise stepping, numeric matrices,
both WebGL scenes, mobile layout and offline loading alongside existing workflows.

Validation completed: **14 Python tests and 10 browser tests passed**, plus the
TypeScript/Vite build. The model has 48 dependency steps. See the
[validation record](results/matmul-compare/weight-streaming-validation.json),
[broadcast detail](results/matmul-compare/weight-streaming-broadcast.png), and
[complete reduction view](results/matmul-compare/weight-streaming-reduction.png).
