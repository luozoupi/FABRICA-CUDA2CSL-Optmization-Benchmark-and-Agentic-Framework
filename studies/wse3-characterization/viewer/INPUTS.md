# Where the GEMM/GEMV inputs live

The inputs are stored in PE-local arrays. Their absence from the visible time
planes was a presentation omission: the old page displayed accumulator states
and kept input values in a collapsed section below the view.

The [layered view](../results/gemv-walkthrough/space-time.html) now draws input
arrays **inside every PE tile on every time plane**, including exported SVGs.
GEMV tiles contain X/W; GEMM tiles contain the initial A/B arrays and, for
multi-PE cases, time-bounded receive values in abuf/bbuf. Inputs and observed
outputs occupy separately labelled regions of the same tile. Global indices
label the initial matrices; received buffers use local row/column indices with
global coordinates and receive cycles in their tooltips. The last observed
multiply's operands are highlighted.

The default **3D stack overview** restores the full-width style of
`space-time-initial.png`, including the layer rail, camera controls and transfer
arrows. **Expand selected layer** isolates and enlarges that mesh for reading its
arrays. **Readable time layers** remains an optional scrollable presentation.
Both contain the same arrays and values. In stack mode, the additional input
inspector is below the figure inside the selected-PE panel, preserving the full
width of the stack; readable mode keeps its adjacent inspector.
The [time-slice view](../results/gemv-walkthrough/time-slices.html)
also shows that inspector next to its mesh. Select a PE and a layer/cycle to see
global matrix indices, local array names, packing order, relative byte offsets,
and the operands of the last matched multiply. On narrow screens it moves below
the stack. Frame/layer JSON exports now include input context.

## Verified storage and placement

| Workload | Host-loaded arrays on PE (x,y) | Storage and evidence |
|---|---|---|
| GEMV, X @ W | `X[y*T:(y+1)*T]`; `W[y*T:(y+1)*T, x*T:(x+1)*T]` | X is replicated across mesh columns. W is row-major. The captured host runner reads both arrays back; the existing verifier checks every f32 value. Matched multiply operands provide additional checks. |
| GEMM, A @ B | Initial A and B tiles at matrix rows y*T… and columns x*T… | One-PE case is row-major; multi-PE cases pack each tile column-major. The captures retain host input bits, `a_seen`/`b_seen` panel histories, and matched arithmetic operands. They do not separately read final A/B arrays back. |

These placements follow the retained runners' blocking `memcpy_h2d` calls with
`streaming=False`, executed before the `run` launch. The retained CSL declares
local f32 arrays, exports their pointers to those symbols and indexes them in
the compute loop. Placement records relate local PE coordinates to fabric
coordinates. The inspector reports offsets relative to each array; it does not
invent physical SRAM bank addresses or instruction-level store timestamps.

## SRAM backing confirmed in the executed builds

**Yes: X is backed by PE-local SRAM, just like W.** These are distinct allocated
arrays in the same PE-local memory, not a separate global input memory.
Cerebras describes each PE's private memory as the home of its code and data,
with communication required to exchange data between PEs. Its architecture
description identifies this local memory as SRAM.
[SDK architecture](https://sdk.cerebras.ai/computing-with-cerebras),
[Cerebras architecture explanation](https://www.cerebras.ai/blog/cerebras-architecture-deep-dive-first-look-inside-the-hw-sw-co-design-for-deep-learning).

The reproducible [storage audit](../tools/input_storage.py) checks all six teaching
scenes: **52 arrays across 18 application PEs**. For every array it checks the
captured manifest hashes, executed ELF tile identity, expected f32 allocation
size, allocated/writable `.bss` section, containing PE load segment, and retained
executed IR definition. The arrays have distinct, nonoverlapping allocations.
The [machine-readable report](../results/input-storage.json) records each symbol,
address, size and source identity. Reproduce with `python3 tools/input_storage.py`
from the study directory; no device execution is required.

For V1's **PE (0,1), fabric (4,2)**, the executed ELF contains:

| Array | Values | ELF local byte address | Bytes | Section |
|---|---|---:|---:|---|
| W | `[[9,10],[13,14]]` | `0x1b58` (7000) | 16 | `.bss` |
| X | `[-1,3]` | `0x1b68` (7016) | 8 | `.bss` |

These are addresses for this particular instrumented build; they are not portable
across builds or a physical SRAM-bank measurement. `.bss` names zero-initialized
storage in the executable. Blocking host copies fill those arrays with the
nonzero inputs before computation starts.

The retained CSL uses `W[k*T+j]` and `X[k]`. Its IR contains indexed `load float`
operations from both globals, and the executed disassembly includes memory-to-
register moves such as `fmov32.nf d0 = [r6]`, followed by `fmuls d0 = d0, d2`.
Thus the numerical path in these scalar teaching builds is **SRAM array →
temporary operand/register copy → arithmetic → accumulator storage**. Reading
an operand does not remove the array from SRAM. The source does not overwrite
X/W during computation, and the final X/W readbacks match their uploaded bits.

GEMM's A/B arrays and abuf/bbuf receive arrays are likewise allocated in local
SRAM. The kernel selects its own A/B tile or the corresponding received panel
for each round. On G1 PE (0,0), A/B occupy 16 bytes each at `0x1bbc`/`0x1bcc`,
while abuf/bbuf occupy 16 bytes each at `0x1da0`/`0x1db0`. That spatial allocation
does not make a router arrival an SRAM write timestamp: values can also exist
temporarily in fabric buffers and execution operands. The viewer therefore
continues to label receive S6 observations separately from physical writeback.

This conclusion applies to the retained GEMM/GEMV programs. Other kernels can
stream fabric operands directly into operations without first materializing a
complete input array in local SRAM; the mathematical label “input” alone does
not determine storage. GEMM's numerical evidence remains its host bits, panel
histories and matched arithmetic, without a separate final A/B readback.

For V1, PE (0,1), fabric (4,2), contains:

```text
X[2:4]       = [-1, 3]
W[2:4, 0:2]  = [[9, 10],
                 [13, 14]]
```

Its partial for Y[0] is `−1×9 + 3×13 = 30`. PE (1,1) has the same X slice and
the neighboring W columns `[[11,12],[15,16]]`. Those inputs are in local memory;
the later vertical communication exchanges partial sums and result replicas.

## Initial tiles versus GEMM's round inputs

In round s, PE (x,y) uses an A panel from PE (s,y) and a B panel from PE (x,s).
The retained `panels()` and `gemm()` select `A` versus `abuf` according to x==s,
and `B` versus `bbuf` according to y==s. A panel broadcasts horizontally and a
B panel vertically.

For G1, PE (0,0) initially owns `A=[[1,2],[5,6]]`, packed as `[1,5,2,6]`.
Round 1 uses `A=[[3,4],[7,8]]` from PE (1,0), through `abuf`. The new inspector
shows the unchanged initial tile and the round panel separately. It selects a
round only after a matched multiply in that round is observed. Its title says
“last observed input use”; it does not claim that operation runs at the selected
snapshot's exact cycle.

The full round panel is checked against the captured `a_seen`/`b_seen` history.
That is distinct from its receive timing. The expandable receive section uses
the [PE-hop audit](../PE_HOP_REVIEW.md): each value appears only at or after its
bound receive S6 cycle, and retains packet identity and raw row reference. It
does not equate S6 with an SRAM write. Before a receive observation the value
remains unknown. The current G1/G2 data contains 160 such numeric receipts.

Initial inputs remain visible as workload context even before a PE's input
checkpoint. They were host-loaded before launch; the inspector separately says
whether the selected PE's recorded checkpoint has been reached. This avoids
confusing static input knowledge with a timed memory observation.

## Reproduction and checks

From the study directory:

```bash
python3 -m wse3study.time_slices \
  --gemv viewer/public/gemv-bundle.json --gemm viewer/public/bundle.json \
  --hops results/pe-hops/hops.json --out viewer/public/time-bundle.json
python3 -m unittest discover -s tests -p test_input_tiles.py
```

Then follow [LAYERS.md](LAYERS.md) to build the pages; package `time-slices.html`
from `dist/time-slices` with the same time bundle as well. Browser checks are
`npm test -- tests/inputs.spec.ts tests/layers.spec.ts tests/meshgemv.spec.ts`.

Checks cover X replication, global tile indices, column-major packing, changing
round panels, rejection of mismatched readbacks/hop words, no future operand or
receive disclosure, selection synchronization, offline export and mobile layout.
Existing accumulator events and layer cycles are unchanged. SVG export now
includes all the input arrays drawn within the time planes, using the selected
presentation's aspect ratio. The offline HTML and JSON also retain the separate
input inspector/context. No new simulator or hardware workload is required.

`npm test -- tests/layer-inputs.spec.ts tests/layers.spec.ts tests/inputs.spec.ts`
additionally checks on-plane values, per-word receive visibility, figure export,
readable text sizing, selection and camera interactions.
