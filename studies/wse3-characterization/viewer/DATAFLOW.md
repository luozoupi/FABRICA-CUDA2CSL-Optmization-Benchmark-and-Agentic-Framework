# WSE-3 WebGL dataflow presentation

Open [the standalone presentation](../results/dataflow/dataflow.html), or start
the local backend from the study directory:

```bash
python tools/dataflow_server.py --port 8765
```

Then open `http://127.0.0.1:8765/dataflow.html`. If your browser is on another
machine, forward that port over your existing SSH connection. The backend binds
to loopback by default. The standalone HTML needs neither a server nor network
assets.

## What to inspect

The default **Streaming & tiles** view adds an explicit teaching sequence to all
six retained 4×4/8×8 GEMM and GEMV captures:

1. Host memory → fixed edge I/O → the SDK's three west / two east support PE
   columns → the user kernel. Gray halo and orange support PEs are distinct from
   blue user PEs. This is a compressed schematic of the compile rectangle.
2. Global matrices remain visible, with tile boundaries and global indices.
   Click a global input cell, a PE, or a tile in the inspector to inspect its
   ownership. Placement steps expose the SRAM symbol, ELF byte address, row view,
   and exact packed payload. Host PE ordering and local column-major packing are
   separate concepts.
3. GEMM distributes **A along rows**, then **B along columns**, one operand class
   per frame. Each round names the owner and receiving PE; remote panels use
   `abuf` or `bbuf`. Solid arrows link matched PE payloads.
4. Every compute step shows all PE partial results. Select a PE and an output
   cell to see `old + A × B = new` (or `old + X × W = new`). Its multiply and add
   buttons open the observed journey at their real instruction cycles.
5. GEMV shows local partials, the downward combination, and the upward final
   result replicas separately. For example, `[30,32] + [11,14] = [41,46]` on
   PE (0,1). X replication in these runs is performed by host uploads.
6. Output tiles populate the host matrix at their original indices. Dashed,
   rounded I/O arrows stay outside unrelated PE cards. Host assembly omits
   duplicate GEMV replicas while retaining their verification.

**Teaching order is not simulator time.** In particular, grouping all cells by
k does not assert lockstep execution across cells or PEs. The backend checks
all 736 multiplies and 736 accumulations against retained operands/results, and
assigns every one of the 184 matched PE packets to a teaching transfer. No
synthetic cycles are assigned to a teaching step. Partial matrices are checked
algorithmic reconstructions, not simultaneous SRAM snapshots.

The next/previous buttons and step selector support manual presentation; Auto
step advances every 2.2 seconds. The URL preserves the workload, teaching step,
selected PE, and selected scalar. Example:
`dataflow.html#scene=g1&view=streaming&step=17&pe=0,0&cell=0`.

The **Observed journey** view retains its seven chapters:
host input numbers → SDK I/O support → PE SRAM → local arithmetic → PE packets →
PE results → host readback. Select an input to highlight its initial owners and
list its matched multiply uses. Select an output to follow its arithmetic,
including GEMV reduction. Clicking an arithmetic observation selects its PE and
cycle. GEMM's inspector also shows time-bounded `abuf`/`bbuf` receive operands.

The packet selector follows **184 matched full-word packets** using their
identities, endpoint coordinates, router cycles, receive/send operands and
arithmetic consumers when bound. On the mesh, the selected packet's displayed
position interpolates between observations; it does not expose queue occupancy.

“Time layers” repeats the same physical PE grid at the previous, selected and
next observed cycles. Input arrays remain on every layer. Drag to rotate,
wheel to zoom, Shift-drag to pan, or use the PE buttons without mouse picking.

The separate snapshot lab contains newly verified SRAM and named GPR dumps for
one-PE Add, a two-PE relay/Add and four-PE GEMM. Before/after values come from
separate stopped runs and are never assigned the older scene's cycle numbers.
The [snapshot report](../microbench/snapshots/README.md) explains the validity
checks and SDK limitations.

## Evidence boundaries

- Host copy calls, packed input values, destinations and output readbacks come
  from the retained runs. No exact host transfer cycles are assigned.
- I/O support geometry follows the
  [SDK tensor-streaming guide](https://cerebras-sdk-docs-140.netlify.app/tensor-streaming)
  and the retained compiler's zero-buffer configuration. The requested current
  `/tensor-streaming` URL was unavailable during review; the versioned official
  guide was accessible. Support blocks and external links are schematic; this
  is not a physical wafer defect/remapping diagram.
- Initialized arrays have ELF-backed local SRAM storage. Arithmetic/S6 values
  and receive operands are not automatically SRAM write-commit events.
- Unknown intermediate results stay `?`. The future host output is labelled
  expected until the host-output chapter.
- Snapshot GPR values include runtime completion activity. Arbitrary-cycle
  stepping, internal latches and a complete state-write journal remain absent.

The requested `/home/USER/matmul-7ways.html` is a saved page shell titled
“矩阵乘法的七种遍历”. Its referenced `矩阵乘法的七种遍历_files/_t.html` is absent,
so the embedded interactive example was not available for inspection. The
stepwise tile presentation here is independently implemented from the verified
workload artifacts and the supplied Cerebras layout diagram.

The organization draws on [Adam Harley's neural-network visualization](https://github.com/aharley/nn_vis)
and [Brendan Bycroft's LLM visualization](https://github.com/bbycroft/llm-viz).
The renderer and application code here are independently implemented.

## Implementation and backend

`src/dataflow-gl.ts` renders depth-tested geometry and numeric texture cards
with **WebGL2**. Canvas2D only rasterizes text into textures. The mesh, links,
cards and packet are rendered through WebGL shaders; this page has no SVG scene
renderer and no external graphics dependency. HTML provides readable tables,
controls and the PE inspector.

`tools/dataflow_bundle.py` joins numerical captures, packet bindings, input
storage and snapshot validation with source hashes. The read-only Python
backend loads that bundle once; the client caches each small scene for responsive
scrubbing and requests frame data while inspecting clocked chapters. The server
does not compile, launch jobs, expose a shell, or serve the study directory.

| Endpoint | Result |
|---|---|
| `/api/scenes` | Available workloads and simulator ranges |
| `/api/scenes/v1` | Scene metadata, inputs, observations, packets and provenance |
| `/api/scenes/v1/walkthrough` | Checked teaching steps, tile ownership, numerical states and packet links |
| `/api/scenes/v1/events?start=8500&end=9000&limit=100&offset=0` | Bounded, paginated numeric events |
| `/api/scenes/v1/frame?cycle=10857` | Latest observed PE state, preserving unknowns |
| `/api/scenes/v1/lineage?output=0` | Arithmetic observations for Y[0], including reduction |
| `/api/snapshots` | Independently verified SRAM/GPR phase snapshots |

The static root is only `viewer/dist/dataflow`. Request validation rejects bad
indices/windows, and returned snapshot data includes hashes linking to the
retained source files. This prototype intentionally uses a file-backed bundle;
future larger captures can retain the API and replace its event store.

## Build and verify

From the study directory, with Node on PATH:

```bash
python tools/snapshot_summary.py
python tools/dataflow_bundle.py
npm --prefix viewer run build:dataflow
python viewer/build_standalone.py --dist dist/dataflow --page dataflow.html \
  --bundle dataflow-bundle.json --global-name DATAFLOW_BUNDLE \
  --out results/dataflow/dataflow.html
python -m unittest discover -s tests -p test_dataflow.py -v
```

Browser/API validation, from `viewer/`:

```bash
LD_LIBRARY_PATH=/home/USER/.cache/gemm-browser-deps/lib \
  npx playwright test --config playwright.dataflow.config.ts
```

Checks cover independent arithmetic on all six scenes, every input tile's global
ownership, all packet words, unknown initial state, output lineage, snapshot
reader agreement, actual rendered WebGL pixels, camera movement, API errors and
pagination, mobile overflow, and offline operation without HTTP requests. Teaching checks additionally cover
every intermediate partial independently, complete operation/packet coverage,
packed panel payloads, output assembly without duplicates, scalar-to-cycle
navigation, GEMV reduction/replication, and 8×8 and single-PE layouts.

Preview images: [input loading](../results/dataflow-inputs.png),
[packet journey](../results/dataflow-packet.png), [time layers](../results/dataflow-layers.png),
and [snapshot comparison](../results/dataflow-snapshots.png).

New walkthrough figures: [SDK layout](../results/dataflow/streaming-architecture.png),
[GEMM tile placement](../results/dataflow/gemm-tile-placement.png),
[panel round](../results/dataflow/gemm-panel-round.png),
[scalar calculation](../results/dataflow/gemm-scalar-step.png),
[GEMV reduction](../results/dataflow/gemv-reduction-step.png), and
[host assembly](../results/dataflow/gemv-host-assembly.png).
