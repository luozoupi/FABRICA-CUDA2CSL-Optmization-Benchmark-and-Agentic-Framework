# MeshGEMV and dataflow through time

Three separate, self-contained presentations are ready to open or copy to a laptop:

- [MeshGEMV walkthrough](../../results/gemv-walkthrough/gemv.html): select an
  output, follow its local products and partial sums, identify the computing PE,
  then inspect the reduction and replicated result. Includes CSL, LLVM IR,
  assembly, operand bits, and instruction timelines.
- [Time-slice presentation](../../results/gemv-walkthrough/time-slices.html):
  compare previous/current/next frames across the whole mesh. Step by observed
  event or a fixed number of simulator cycles. Inspect per-PE values and numeric
  changes, jump to recorded phases, or export the current frame as JSON.
- [Stacked PE/time layers](../../results/gemv-walkthrough/space-time.html):
  view repeated mesh planes in a rotatable stack, select a value's history,
  inspect its local dataflow, and export a vector diagram. See the
  [layer-view guide](../../viewer/LAYERS.md).

All work offline. The time-slice and stacked-layer pages include the three MeshGEMV cases and
the three retained GEMM cases. Its default case is V1, the 4×4 MeshGEMV on four PEs.

## Numerical example and placement

The retained WaferLLM MeshGEMV computes **Y = X @ W**, with a row vector X. This
teaching implementation preserves that orientation and the vertical reduction.
PE `(px,py)` stores W rows `py*T:(py+1)*T`, columns `px*T:(px+1)*T`. X's matching
input segment is initialized on every PE in that PE row. Local W tiles use
row-major storage.

| Case | W size | Application mesh | W tile per PE | Local products | Reduction adds |
|---|---:|---:|---:|---:|---:|
| V0 | 4×4 | 1×1 | 4×4 | 16 | 0 |
| V1 | 4×4 | 2×2 | 2×2 | 16 | 4 |
| V2 | 8×8 | 2×2 | 4×4 | 64 | 8 |

For V0/V1, W contains integers 1 through 16 in row order and
`X = [1, 2, -1, 3]`. The final vector is **[41, 46, 51, 56]**.

Follow **Y[0]** in V1:

1. PE (0,0) computes `1*1 + 2*5 = 11`, with partials **1 → 11**.
2. PE (0,1) computes `-1*9 + 3*13 = 30`, with partials **-9 → 30**.
3. The top PE broadcasts its partial vector down the column. The bottom PE
   records the received values and computes **30 + 11 = 41**.
4. The bottom PE broadcasts its final vector up the column; both PEs retain
   the verified output replica.

The other PE column computes Y[2:4]. In V2, W contains 1 through 64 and
`X = [1, 2, -1, 3, 0, -2, 1, 2]`. The final vector is
**[158, 164, 170, 176, 182, 188, 194, 200]**.

This small scalar f32 teaching kernel is distinct from the original WaferLLM
f16/DSD implementation, whose two-tree reduction requires a larger mesh. The
2×2 lesson explicitly exchanges two peers' partials, adds at the bottom PE,
and broadcasts the result. It does not claim to replay the original two-tree
algorithm. The original source was inspected at
`/home/USER/WaferLLM/MeshGEMV/WSE-3/src/meshgemv.csl`.

## A concrete time-slice lesson

In the retained V1 run, go to **cycle 11,359** in the time-slice page:

- At the previous event frame, cycle **11,315**, PE (0,1) has a local partial
  `[30,32]` and a recorded peer buffer `[11,14]`.
- At **11,359**, its traced FADDS computes `30 + 11 = 41`. The first reduction
  result becomes visible on that PE; its second result remains unknown.
- The top replica remains unknown until a recorded final-availability
  checkpoint. PE (0,0)'s checkpoint is at **12,438**.
- The other column progresses independently. The final checkpoint of the whole
  four-PE run is at **12,487**.

These are actual cycles of this instrumented simulator capture. They are not
universal kernel latencies. Choosing a 50-cycle fixed slice preserves the real
time gaps; choosing event stepping skips to the next observed change. All
observations at the same cycle are applied together. The current frame uses
only observations at or before its selected cycle; the explicitly labeled
next-frame thumbnail is a preview.

## Evidence and validation

The six serial simulator runs are retained in
`results/gemv-walkthrough/try-20260915a`, relative to the study root. Each case has
history-enabled and history-free builds. No hardware job was submitted.

- **96/96 local products**, **12/12 reduction adds**, and **39/39 phase
  checkpoints** are bound to executed instructions.
- **16 distinct output values** and **28 stored output replicas** match the
  independent reference. All control outputs pass too.
- **669 value/checkpoint checks** pass: 97 in V0, 144 in V1, and 428 in V2.
- All three history traces report **zero discarded events**.
- All six GEMV/GEMM time-slice scenes finish with states matching final readback.

The exporter verifies source/artifact SHA-256 manifests, input identity, local
W/X buffers, local partials, peer buffers, each old/new accumulator, reduction
operands, result replicas, and phase flags. It maps PE coordinates using ELF
load-segment tile IDs and maps functions using ELF symbol byte ranges converted
to the simulator's 16-bit-word PCs. Scalar operations require matching counts,
ordered inputs, and exact execute operand/result bits.

Phase checkpoints are explicit `phase_*` functions with recorded flags and local
timestamps. Their displayed simulator cycle is the last observed execute cycle
inside the corresponding ELF function range. Buffer/history readback plus the
compiled phase's semantics establishes what is available by that checkpoint;
this is not an exact packet arrival cycle or a simultaneous SRAM dump. Timer
ticks have a separate origin and are never used as simulator trace cycles.

Time-slice accumulator values are last observed arithmetic results. Unknown
values stay unknown. Raw wavelets remain available separately; opaque raw words
are not labeled as tensor elements, and nearby events are not assumed causal.
The older GEMM captures have arithmetic bindings but no aligned panel-receipt or
final-buffer checkpoints. Their timeline explicitly retains that limitation.

The teaching compute, reduction, and marker functions use `optnone`; history and
markers affect timing. Controls quantify that effect. Internal forwarding,
queue occupancy, exact packet-to-element mapping, and silicon cycles are not
claimed by either presentation.

## Reproduce the capture and presentations

From the study root, preview a run without executing:

```bash
python3 microbench/gemv_walkthrough/capture.py --cases v1
```

On the SDK user node, with no other SDK job running, execute serially into a new
directory. The runner shares the GEMM walkthrough's capture lock:

```bash
ssh user-node-1
cd /home/USER/xkernel/studies/wse3-characterization
python3 microbench/gemv_walkthrough/capture.py --execute \
  --out results/gemv-walkthrough/my-capture
```

Export the checked data and build all presentation pages:

```bash
python3 -m wse3study.gemv_viz \
  --captures results/gemv-walkthrough/my-capture \
  --out viewer/public/gemv-bundle.json
python3 -m wse3study.time_slices \
  --gemv viewer/public/gemv-bundle.json \
  --gemm viewer/public/bundle.json \
  --out viewer/public/time-bundle.json
cd viewer
npm ci
npm run build
python3 build_standalone.py --dist dist/gemv --page gemv.html \
  --bundle gemv-bundle.json --global-name GEMV_BUNDLE \
  --out ../results/gemv-walkthrough/gemv.html
python3 build_standalone.py --dist dist/time-slices --page time-slices.html \
  --bundle time-bundle.json --global-name TIME_BUNDLE \
  --out ../results/gemv-walkthrough/time-slices.html
```

Omit `--gemm` for a MeshGEMV-only time-slice deck. To recreate the GEMM bundle,
see the [GEMM guide](../gemm_walkthrough/README.md). Export validates manifests and
refuses to construct time slices from incomplete arithmetic/checkpoint bindings.

For development, `npm run dev` serves `/gemv.html` and `/time-slices.html`.
The production preview serves `/gemv/gemv.html` and
`/time-slices/time-slices.html`. The portable HTML pages need no server.

Validation commands:

```bash
python3 -m unittest tests.test_gemv_viz tests.test_gemm_viz \
  tests.test_ir_capture_concurrency tests.test_cli
cd viewer
npm test
```

The browser suite checks both new pages and the existing GEMM page. It covers
partial-sum reset at a PE boundary, reduction instructions, checkpoint/time-slice
boundaries, unknown future values, every final mesh state, frame export,
bookmark reload, mobile layout, and offline loading without HTTP requests.
On this ALCF login node, use the already installed isolated browser libraries:
`LD_LIBRARY_PATH=$HOME/.cache/gemm-browser-deps/lib npm test`.
