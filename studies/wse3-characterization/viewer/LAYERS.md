# Layers of PE execution

Open [space-time.html](../results/gemv-walkthrough/space-time.html), or copy that
single file to a laptop. It uses the checked GEMV/GEMM captures already exported
to `viewer/public/time-bundle.json`; no new simulator or hardware run is needed.

Every PE tile on every layer includes its host-loaded X/W or A/B arrays, global
indices, and observed outputs. Multi-PE GEMM also shows abuf/bbuf values only
after their receive observations. The last observed multiply's operands are
highlighted. These inputs are part of the figure and its SVG export, in addition
to the separate selected-PE inspector. See [input storage verification](INPUTS.md).

This presentation follows the stacked node-link idea in
[Adam Harley's interactive CNN visualization](https://github.com/aharley/nn_vis).
Each plane here is a later snapshot of the **same physical PE mesh**. The two
in-plane dimensions represent PE coordinates; the stack direction represents
time. Every layer displays its actual simulator cycle.

## Try the default example

The default is V1, 4×4 MeshGEMV on a 2×2 mesh, following Y[0]. Six layers expose
the numeric story:

| Layer | Cycle | Selected output's progress |
|---|---:|---|
| Input checkpoints | 8,525 | Input-checkpoint snapshots; other PEs can already be computing |
| Local partials | 10,730 | Top partial 11; bottom partial 30 |
| Partial received | 11,315 | Bottom PE's recorded received partial is 11 |
| Combine Y[0] | 11,359 | Bottom PE's matched FADDS computes 30 + 11 = 41 |
| Root result ready | 11,831 | Bottom PE's result-buffer checkpoint contains [41,46] |
| Replicas available | 12,487 | All final checkpoints have completed; both rows hold result replicas |

The selected PE starts at (0,1) in the combination layer. Its inspector shows
the local partial, received value, result, arithmetic instruction, operand bits,
and raw trace references. At the previous layer its result is unknown; the top
replica is still unknown at the combination layer.

## Interactions

- **3D stack overview** is the default, matching `space-time-initial.png`: a
  full-width perspective stack, time-layer buttons below, and PE details below
  those. Every PE now also contains its input arrays.
- **Readable time layers** is optional: scroll through legible mesh planes,
  with inputs and outputs inside each PE. Small screens can scroll horizontally
  within the figure as well.
- **Drag** to rotate the stack; **shift-drag** to pan; use the wheel or ± buttons
  to zoom. **Expand selected layer** isolates one mesh and enlarges its PE values.
- Click a number in a PE to select its output, buffer, and time layer. Click an
  accessible layer button underneath the diagram to switch the inspector's time.
- **Follow output** highlights the contributing PE column for GEMV or owning PE
  for GEMM. The PE inspector shows the selected output's last matched operation.
- Choose a guided output story, equal cycle intervals, or consecutive observed
  event frames. The latter two modes support three through eight layers.
- **Play layers** advances the selection through the displayed snapshots.
- **Export SVG** produces an independent vector image of the chosen presentation,
  including its input matrices, with colors and text styles embedded. Readable
  mode exports all planes as a tall figure. **Export displayed layer data**
  saves cycles, states, logical transfer provenance, and source identity as JSON.

The stack supports all three GEMV examples and all three GEMM examples. It shares
the original numerical state reducer, and all equal-interval final layers agree
with the captured final readbacks.

## Reading connections

Thin lines connect the same PE across snapshots. They show temporal continuity,
including held values when no new observation is available. They do not assert
that every internal register or buffer stayed unchanged between samples.

Dashed amber links show the two-peer MeshGEMV's logical partial transfer and
result replication. A link is created only when both relevant checkpoint records
exist, their order is valid, and the source/destination scalar values agree.
For the default Y[0], the partial link carries 11 and the replica link carries 41.
Changing or removing an endpoint prevents that link from being drawn.

The source-ready and destination-available cycles are recorded checkpoint bounds.
They do **not** give the send/receive time of an individual packet. Link endpoints
are the first displayed snapshots satisfying those availability checks; their
snapshot times can be later than the underlying checkpoints. If the selected
window omits the required states, the connection is not drawn.

GEMM has no cross-PE arrows in this page; its lines show temporal PE continuity.
Its abuf/bbuf cells now use the audited receive S6 bindings, retaining unknowns
until each word is observed. The numerical PE inspector also shows matched A/B
operands, multiply, old accumulator, and add result.

Guided/event layers are spaced for readability, with actual cycle deltas below
them. Their geometric distance is not a duration measurement. PEs can occupy
different phases within one layer. Unknown values stay unknown until an event or
checkpoint establishes them. The inspector's arithmetic is explicitly labeled
as the last matched update at or before the selected frame.

## Build and test

From `viewer/`, after the existing time bundle is available:

```bash
npm run build
python3 build_standalone.py --dist dist/space-time --page space-time.html \
  --bundle time-bundle.json --global-name TIME_BUNDLE \
  --out ../results/gemv-walkthrough/space-time.html
npm test -- tests/layers.spec.ts
```

For the ALCF login node's browser libraries:

```bash
LD_LIBRARY_PATH=$HOME/.cache/gemm-browser-deps/lib npm test
```

Development route: `/space-time.html`; production preview route:
`/space-time/space-time.html`. See the
[capture/export guide](../microbench/gemv_walkthrough/README.md) to regenerate
the underlying data.

The layer tests cover independent PE histories, unknown future results,
checkpoint-based connection checks, missing/mismatched endpoint rejection,
all-scene final readbacks, selection, camera movement without numeric changes,
layer sampling, bookmark reload, keyboard picking, mobile layout, offline use,
and self-contained SVG export.
