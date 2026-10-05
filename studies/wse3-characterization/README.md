# WSE-3 spatial and data-movement characterization

**Start here: [4 × 4 GEMM on four PEs — a text-and-figure tutorial](results/four-pe-tutorial/tutorial.html).**
Six numeric figures explain tile placement, color-0 X wavelets, color-4 W wavelets,
both rounds of one-hop transfers and local output accumulation. Also available as
[PDF](results/four-pe-tutorial/tutorial.pdf) and [Markdown](results/four-pe-tutorial/tutorial.md).

**New: [GEMM hardware residency / weight-streaming WebGL walkthrough](results/matmul-compare/matmul.html#view=stream).**
Follow exact activation slices, streamed weights, local partials and row reductions.
The [generation-aware review](GEMM_HARDWARE_DATAFLOW.md) distinguishes the documented
vendor mapping from our captured WSE-3 SUMMA, Cannon and single-PE kernels.

> **Results live in [FINDINGS.md](FINDINGS.md).** This file documents the study's design,
> evidence taxonomy and commands; FINDINGS.md records what was measured.

**New: [WebGL dataflow lab](results/dataflow/dataflow.html).** Follow exact host
inputs through PE SRAM, local arithmetic, matched PE packets and host output.
It includes time layers and newly verified before/after SRAM/GPR snapshots for
Add, a two-PE relay and four-PE GEMM. [Viewer/backend guide](viewer/DATAFLOW.md) ·
[snapshot experiments](microbench/snapshots/README.md).
Start the local read-only backend with `python tools/dataflow_server.py`.

The [2026-09-17 architecture review](ARCHITECTURE_REVIEW.md) compares official
WSE-3 core diagrams and SDK tools with our captured datapaths, tests conditional
timing estimates, and maps the supplied MIPS lecture to a WSE teaching model.
It includes a [standalone datapath/timing figure](results/architecture-review/datapath.svg)
and records the installed trace CLI's CTF limitations.

This is a standalone, evidence-labelled study of the CSL kernels in xkernel. It
does not participate in CUDA2CSL generation, optimization, or `fast_p` scoring.

The [architecture and performance-model roadmap](ARCHITECTURE_MODEL_PLAN.md)
connects the numerical viewers to controlled PE/mesh experiments and predictions
for unseen workload sizes and mappings, with separate simulator and silicon validation.

**Try the tiny GEMM explorer:** open
[`results/gemm-walkthrough/gemm.html`](results/gemm-walkthrough/gemm.html) for
4×4 and 8×8 GEMMs with exact numbers, PE ownership, partial sums, panel transfers,
and linked simulator instructions. The [walkthrough guide](microbench/gemm_walkthrough/README.md)
documents the retained captures, reproduction commands, and evidence limits.

**MeshGEMV and time slices:** the
[MeshGEMV walkthrough](results/gemv-walkthrough/gemv.html) follows small X @ W
examples through local partials, vertical reduction, and output replicas. A
separate [time-slice presentation](results/gemv-walkthrough/time-slices.html)
shows numeric changes across the mesh for both GEMV and GEMM. See the
[MeshGEMV guide](microbench/gemv_walkthrough/README.md) for examples and reproduction.

The [stacked PE/time view](results/gemv-walkthrough/space-time.html) displays
multiple mesh snapshots as connected planes, with rotation, numeric selection,
and a detailed PE inspector. [Layer-view guide](viewer/LAYERS.md).
Every PE tile in the time layers now contains its input X/W or A/B arrays beside
its observed outputs; GEMM also shows timed abuf/bbuf receive values. The default
full-width 3D overview and optional readable layout both include these arrays in SVG exports.
An additional [input inspector](viewer/INPUTS.md) shows storage details, indexed
operand values and GEMM round panels for the selected PE.

The [datapath comparison](results/anatomy/datapath_review.html) puts GEMM,
Add, fill/copy, and controlled load/store dependencies on the same functional
PE diagram and recorded-stage timeline. The [review](DATAPATH_REVIEW.md)
explains the raw-record audit, silicon comparison, and remaining ambiguities.

The [PE-hop viewer](results/pe-hops/hops.html) follows exact f32 words through
send instructions, adjacent routers, receive instructions and arithmetic uses.
The [hop review](PE_HOP_REVIEW.md) covers 184 GEMM/GEMV packets, the relay timing
comparison, the recovered high payload half, and the next controlled experiment.

The [receiver-readiness experiment](results/readiness/readiness.html) now tests
that next step with fixed-route two-PE transfers, verified delay instructions,
exact input values and layered send/router/receive/Add observations. Its
[report](microbench/readiness/README.md) compares 1–16-word messages and explains
the repeatable receiver-dependent delay seen in the 16-word case.

The [sparse walkthrough](results/sparse-walkthrough/sparse.html) adds SpMV,
CSR×dense SpMM, and masked sparse AᵀA, with index traversal, PE ownership and
numeric accumulator snapshots. Its [guide](SPARSE_VISUALIZATION.md) distinguishes
recorded SpMV instruction values from source-based SpMM/SpGEMM reconstruction.

The study answers four different questions without conflating their evidence:

1. What does Cerebras document about the architecture?
2. Which compiler-visible PEs, coordinates, colors, queues, and routes does a
   kernel allocate?
3. Which wavelets and instructions actually execute in the deterministic SDK
   simulator?
4. What timing and explicit telemetry can be measured on the ALCF WSE-3?

The compiler fabric map is exact for the specific retained compilation that
produced its ELFs. Retained SDK 1.4 or small simulator-fabric artifacts are
decoder-validation evidence, not proof of the SDK 2.10/full-fabric hardware
campaign. Cerebras's private defect/spare remapping and a cycle-by-cycle
hardware trace are not exposed through the appliance API and are not claimed.

## Scientific model

The WSE is a spatial MIMD system: each PE has its own program counter, SRAM,
compute engine, and router. WSE-3 DSD operations can use SIMD, and up to eight
microthreads provide asynchronous data-movement contexts. Microthreads, task
IDs, queue IDs, and SIMD lanes are distinct concepts; none is a CUDA warp.

Every reported value is tagged as one of:

- `documented`
- `compiled`
- `simulator`
- `silicon`
- `inferred`

## Commands

Run from this directory, or invoke `study.py` by absolute path.

```bash
# Freeze the active sweep and decode all compilation artifacts currently present.
python3 study.py inventory --campaign results/wse3-full

# Decode stored simfab traces. This does not launch the simulator by default.
python3 study.py trace --campaign results/wse3-full --all

# Correlate retained log-export ZIPs/extractions with ledger job IDs. This is
# read-only and performs no archive extraction.
python3 study.py trace --campaign results/wse3-full --discover-artifacts

# Bind one accepted simulator job and cross-check CTF wavelet counts against
# already-produced official csdb per-PE logs.
python3 study.py trace --campaign results/wse3-full --ingest-artifacts \
  --job-id wsjob-REDACTED

# A batched simulator job has several TSC windows; select one explicitly.
python3 study.py trace --campaign results/wse3-full --ingest-artifacts \
  --job-id <simulator-wsjob> --event-key <ledger-event-key>

# Materialize the exact calibration request matrix without submitting jobs.
python3 study.py calibrate --campaign results/wse3-full

# Select one exact case, independent of its position in the family matrix.
python3 study.py calibrate --campaign results/wse3-full --materialize \
  --case contention-s1-distinct-q6-m1-d0-8dbde7e8

# --case is repeatable (and accepts comma-separated IDs). Exact cases are
# intersected with any --family selection, then the existing --limit cap is
# applied in canonical matrix order. An unknown case ID is a command error.

# Materialize the 49-kernel simulator/hardware campaign without submitting jobs.
# This also writes a fail-closed full-telemetry override work item per staged
# kernel. A completed override is materialized into a separately hashed full
# copy and request; execution remains gated by compile/correctness/D2H evidence.
python3 study.py run-suite --campaign results/wse3-full

# Execute only after preflight succeeds on an ALCF service/scheduled node.
python3 study.py run-suite --campaign results/wse3-full \
  --execute --confirm-hardware

# Re-inventory retained compiler tarballs after compilation. This performs no
# submission and never writes into kernels/; qualification is fail-closed.
python3 study.py inventory --campaign results/wse3-full --bind-artifacts

# Generate report.md, report.json, and the fitted latency model when samples exist.
python3 study.py report --campaign results/wse3-full

# Run all offline tests.
python3 -m unittest discover -s tests -v
```

## Standalone tools

These run directly on a compiled bundle or a decoded trace and do not need the campaign
machinery. Only `csdisasm.py` and `fabric_probe.py` require the SDK container.

```bash
# Decode a barectf CTF trace into events.jsonl.gz (accepts an out_ dir or simfab_traces/).
python3 tools/decode_trace.py <out_dir> -o events.jsonl.gz

# Instruction mix, elements/dispatch, microthreads, SIMD lanes.
python3 tools/isa_probe.py events.jsonl.gz --top 8

# Static disassembly (stages the ELF itself; the SDK container mounts only cwd).
python3 tools/csdisasm.py <bundle>/bin/out_0_0.elf --summary

# Fabric-wide routing, switches, SRAM banks, PE roles.
python3 tools/fabric_probe.py <out_dir> --json fabric.json

# Per-link NoC occupancy (positional: trace, then fabric json).
python3 tools/noc_model.py events.jsonl.gz fabric.json --measured <cycle_span>

# Bottleneck class and recommended fix per kernel.
python3 tools/bottleneck.py --kernel <name>

# Pipeline depth, RAW stalls and xcptn, by joining disassembly operands to pipe cycles.
python3 tools/hazard_probe.py events.jsonl.gz disasm.json

# Measured SRAM budget as usable matrix shapes.
python3 tools/capacity_table.py

# Chrome JSON for https://ui.perfetto.dev -- PE tracks, task slices, wavelet flow arrows.
# Perfetto cannot read CTF; this converter is the only route in.
python3 tools/trace_to_perfetto.py events.jsonl.gz -o trace.json --flows

# Anatomy pages: instruction-level MIPS-style pipeline charts from microbench traces.
# add_anatomy reads microbench/atomic_add; ops_anatomy reads microbench/atomic_ops and
# the one-message relay run (microbench/relay, N=1 B=8) for the send/receive chart.
python3 tools/add_anatomy.py    # -> results/anatomy/add_anatomy.html
python3 tools/ops_anatomy.py    # -> results/anatomy/ops_anatomy.html (−O2 and optnone builds; optnone from microbench/atomic_ops/ir_cap/optnone_sim)
python3 tools/mesh_stages.py    # -> results/anatomy/mesh_stages.html (stages on the 2-D mesh, cycle scrubber)
python3 tools/overlap_probe.py  # DSD vs independent scalar work: serial or overlapped? (needs microbench/overlap)
python3 tools/addfam_model.py    # add-family lowering rules; predicts both boundaries from the source form
python3 tools/addfam_page.py     # -> results/anatomy/addfam_model.html
python3 microbench/iremit/build.py   # IR-emission gate test + SpMV strategy costs (Cerebras node only)
python3 tools/pe_model.py        # -> results/anatomy/pe_model.html (functional datapath, dependency graph, timeline per walkthrough; quotes pcsweep)

# The layer below CSL: capture cslc's LLVM IR transparently, then rebuild an ELF from patched IR.
# (Cerebras user node only; runs the real cslc-backend / cslc-linker from the SDK container.)
python3 tools/cslc_ir.py capture -o ir_cap -- ./layout.csl --arch=wse3 --fabric-dims=8,3 --fabric-offsets=4,1 -o out --memcpy --channels=1 --width-west-buf=0 --width-east-buf=0
python3 tools/cslc_ir.py rebuild ir_cap/out_out_0_0 -o patched.elf --optnone compute
python3 tools/cslc_ir.py rebuild ir_cap/out_out_0_0 -o patched.elf --asm-after 'store i16 23040,' 'movri r5 = 0x1234'

# Compile-time side channels: per-PE colour routes (rx/tx/switches) and the DSR interference graph.
cslc ./layout.csl --arch=wse3 ... --out-routes | grep -E '^\||^Total' > routes.txt
cslc ./layout.csl --arch=wse3 ... --dump-dsr-alloc-graph      # -> out/bin/<prog>.{greedy,dsatur}.dot

# Vendor debug shell (Cerebras user node): symbol addresses per PE and per-PE wavelet logs with Ctrl/Link.
printf 'context select out\ntrace select [0]\nimage lookup --name mark\nwavelet read-trace --fmt hex\nexit\n' | csdb .
```

Published pages and which file backs each URL: `results/anatomy/PUBLISHED.md`.

External corpus: `external/wse-stencil` is the ASPLOS'26 MLIR stencil→CSL generator (BSD-3, xDSL 0.35), used for compile-feasibility and structural comparison on SDK 2.10 (`external/run_d.sh`; `external/bin/mlir-opt` forwards to the container's binary).

## Microbenches

Each is self-contained with a `commands.sh` that compiles and runs it.

| path | question |
|---|---|
| `microbench/ilp/` | instruction latency vs issue width, at constant work |
| `microbench/bank/` | SRAM read/write bank conflicts, with a positive control |
| `microbench/capacity/` | largest allocation `cslc` will link; fabric-dims bound |
| `microbench/extent/` | how many elements one dispatch covers |
| `microbench/loopform/` | cost of each software-loop level at constant FP work |
| `microbench/dsdlen/` | DSD extent field vs backing array; max elements per operand |
| `microbench/levers/` | reachable cslc lever sweep (fp16-format, lomem reservation) |
| `microbench/atomic_add/` | five forms of c = a + b executed once each; the atomic instruction sequence, verified |
| `microbench/atomic_ops/` | 22 MIPS-style basic operations (arith/logic/control/convert/memory/vector) executed once each behind exported markers; all verified against a numpy model (`gen.py`, `run.py`) | `ir_cap/` holds the captured LLVM IR of the same program and the `optnone` rebuild that ran on the simulator (all forms verified, markers in order).
| `microbench/overlap/` | does independent scalar work overlap a DSD hardware loop? a 2048-element DSD and a 256-step register-only chain, alone and together; all values verified (`gen.py`, `run.py`, `commands.sh`) |
| `microbench/addfam/` | add-family compilation model: 18 one-factor-apart programs with captured LLVM IR, object, ELF, disassembly and DSR graphs per case, an explicit region contract, numerical acceptance checks (`run.py`, `runall.sh`), a full SHA-256 `MANIFEST.json` and an append-only `prediction_history.json` |
| `microbench/pcsweep/` | producer→consumer bubble sweeps: one program per dependency class (DSR load-use ×3 orders, GPR load-use, f16 and i16 dependent pairs, inline-asm distance-1 chains, flag→jump, store→load, reduction→store), 8 pairs with 0–24 `nop` fillers inserted at the IR level under `optnone`; dispatch bubble, consumer decode→execute and region timing per pair (`gen.py`, `build.py`, `run.py`) |
| `microbench/iremit/` | the IR-emission gate test and the sparse gather strategies: a whole `@spmv_ir` body authored in LLVM IR, scalar gather, runtime-base block gather, diagonal (vectorised across rows), plus two reduction probes and a checked regression case for the f32 DSD reduction hazard (`gen.py`, `build.py`, `run.py`) |
| `microbench/relay_compute/` | fabric receive followed by a vector add on the received data, two PEs; values verified end to end; the trace for the fifth PE-model walkthrough |
| `microbench/branch/` | taken vs not-taken branch cost, prediction test, compare→jump distance; results verified |
| `microbench/relay/` | N-stage store-and-forward relay: link rate and per-stage overhead |
| `microbench/singlepe/` | four-suite single-PE roofline: memory, compute, mixed, edge cases (`gen.py`, shared `run.py`, `analyze.py`) |


Hardware operations are dry-run by default, sequential, and resumable. The
ledger key includes source and request hashes, so rerunning a completed request
does not silently submit another WSE job. A kernel is not complete until its
correctness check, exact layout, detailed simulator trace, and 30 valid
device-internal hardware trials are all present.

Execution is batched within each request: the 3 warmups plus 30 suite trials
share one appliance runtime, and the 5 warmups plus 100 generated-calibration
trials share one generated-host runtime. Every sample still has its own hashed
event identity, validation result, append-only ledger record, and resume state.
Generated hosts stream an explicit `event_key`, `warmup`, and `trial` into
JSONL; warmups are retained for audit but excluded from headline projections.
If a batch stops early, completed samples are retained and resume begins at the
first missing or rejected event. Because resume creates a fresh runtime, the
runner first replays the configured warmup count as unscored conditioning
events; it does not mistake warmups from an older runtime for conditioning of
the new one. Third-party and test runners that only expose the single-event API
continue to run one event at a time.

The generated data-movement bundles are topology-specific. L-shaped turns use
one exact cardinal corner; multicast uses explicit `RAMP` taps on a cardinal
trunk; contention gives every source an equal 32-hop path into a shared
eastbound bottleneck. Queue sweeps bind the requested physical queue, and
microthread sweeps partition a fixed payload across real WSE-3 `ut_id` values.
The generated PE imports `<memcpy>`, which reserves input queues 0/1 and output
queue 0. Traffic and official synchronization therefore use only the
duplex-safe intersection 2–7. Requested queue 0/1 cases are not remapped and
remain fail-closed. Four- and eight-color contention also remain fail-closed
because their traffic queues plus three official-sync queues exceed that
six-ID pool. Every runnable manifest contains the complete input/output
resource ledger; no queue or microthread parameter is silently ignored.
With this ledger applied, the frozen 752-case generator matrix contains 633
runnable cases, 15 compile-only SRAM probes, and 104 explicit unsupported
cases. Within data movement, turns are 32/32 runnable, multicast is 16/16,
and contention is 6/43.

## Output contract

```text
<campaign>/
├── campaign.json
├── measurements.csv
├── ledger.jsonl
├── kernels/<kernel>/
│   ├── layout.json
│   ├── trace_summary.json
│   ├── events.jsonl.gz
│   ├── wavelets.jsonl.gz
│   ├── wafer.svg
│   └── layout.svg
├── calibration/
│   ├── requests.json
│   └── latency_samples.jsonl
├── models/latency_model.json
├── work/full-telemetry-overrides/<kernel>.json
├── work/full-telemetry-bundles/<kernel>/<endpoint>-<override>-<generator>/
│   ├── .wse3study_full_override.json
│   ├── .wse3study_full_adapter.json
│   └── wse3study/{profile_timestamp.csl,sync/}
├── work/compiled-artifacts/<kernel>/<arm>/<artifact-hash>/
├── artifacts/<kernel>/<arm>/<request-key>/
│   ├── compile.json
│   └── cs_*.tar.gz
├── artifacts/trace-discovery.json
├── artifacts/trace-ingest/<simulator-wsjob>/<event-key>/
│   ├── binding.json
│   ├── csdb_summary.json
│   ├── csdb_wavelets.jsonl.gz
│   ├── csdb_crosscheck.json
│   └── trace_manifest.json
├── report.md
└── report.json
```

`layout.json` reports application, I/O/support, route-only, loaded, and
dynamically active PE populations separately. A wavelet trace record carries
its identifier, branch, coordinates, direction, cycle, per-hop delta, raw CTF
fields, and evidence. Undecoded SDK fields remain explicitly raw.
`events.jsonl.gz` preserves decoded instruction, landing, router/backpressure,
task, and pipeline records instead of reducing them to summary counts.

The SVGs always distinguish compiled routes from red trace-derived overlays.
Overlay volume and latency are labelled `inferred` when path membership comes
from identifier/time/cardinal adjacency; the underlying observations and cycle
deltas remain `simulator`. `wafer.svg` uses the documented 762×1172 WSE-3
compiler-fabric bounds, while `layout.svg` zooms to occupied coordinates.

Campaign acceptance is stricter than successful decoding. A layout must be
bound to SDK 2.10.x, `--arch=wse3`, the 762×1172 compiler setting, all active
compile variants, and retained ELF coordinates. A detailed trace additionally
needs a `.wse3study_trace_manifest.json` beside `simfab_traces/`, with matching
`source_sha256`, `compile_command_sha256`, `sdk_version`,
`fabric_dimensions`, and a device TSC window. CTF discarded-event counters
make a trace incomplete. The report presents decoded legacy artifacts and
campaign-qualified artifacts as separate totals.

`inventory --bind-artifacts` validates each tar member before extraction,
rejects absolute/traversal paths, links, special files, duplicate members and
oversized payloads, and never executes `compile_command.sh`. The compile command
inside the tarball must exactly match the effective argument vector recorded by
the runner. The sidecar must also match the frozen suite request, canonical-to-
staged source hashes, exact SDK/client versions, selected CSL main, architecture,
fabric dimensions, artifact hash and uploaded-CSL hash. Sidecars created before
this binding schema remain decode-only. A command bundle with multiple `cslc`
lines is never resolved by “last command wins”: it is rejected until each
variant is staged and requested explicitly. Canonical kernel sources are read
for freezing only; archive extraction is confined to the campaign `work/` tree.

Artifact trace ingestion is offline and fail-closed. It validates ZIP member
names and types without extraction, rejects traversal paths, links, special
files, duplicates, encryption, and oversized payloads, and walks an existing
extraction without following links. Qualification requires one accepted
simulator ledger event, exact request/source/compile identities, SDK/client
2.10.x provenance, an identical retained compiler archive inside the exported
workdir, matching effective compiler arguments and compact simulator fabric
dimensions, byte-identical CTF core files in the retained ZIP, zero CTF
discarded events, and a non-empty raw 48-bit device TSC window. If one batched
runtime has several trial windows, `--event-key` is mandatory.

Official `csdb wavelet read-trace` output is parsed from
`wavelet-trace-x<X>y<Y>.log` only after that binding succeeds. A complete
cross-check requires one log—including zero-event logs—for every PE in the
compiled simulator plane and exact total and per-PE agreement with raw CTF
`wavelet_trace_entry` counts. The retained SDK 2.10 control has 36 PE logs and
1,253 events in both decoders. `Link` remains a raw csdb column. Every csdb and
CTF record is tagged `simulator`; none is a physical WSE trace.

## Timing validity

- TSC timing must start and end inside one device operation.
- Readings below the legacy dead-timer screening floor are accepted only when
  the structured result proves that TSC was enabled and preserves distinct,
  valid raw start/end words; otherwise they are rejected as frozen/dead timers.
- Cross-PE comparisons require the official SDK bandwidth-test synchronization
  reference and its explicit hop correction.
- Host RPC, H2D, D2H, compilation, and queue time are reported separately.
- Primary units are cycles. The study does not assume an 850 MHz clock when
  emitting physical time.
- Performance-counter slots 0 and 1 remain raw because the public SDK does not
  identify their configured events.

The generated instrumentation contract is documented in
`instrumentation/ADAPTER_CONTRACT.md`. Canonical kernel bundles are never
modified; adapters are installed only into campaign work copies.

A full override is not a bag of guessed function names. It hashes every input
file it edits and identifies each phase/counter site by function plus a unique
literal anchor. It also supplies exact layout/PE sync wiring, a replacement for
the old host launch sequence, telemetry export/D2H code, collision-audited
colors/queues/task IDs, and marker-bounded numerical-correctness text that edits
may not touch. `run-suite` materializes such an override atomically into the
separate `full-telemetry-bundles` tree, keyed by endpoint, override, and
materializer-generator hashes.
The emitted `ready_for_compile` audit is `inferred` evidence only; a full request
cannot execute until retained compile, original-correctness, and per-PE D2H
schema evidence all bind the same full source hash.

The resource audit is recomputed against a hash-bound, campaign-qualified
compiled-layout snapshot. It rejects any reserved sync color/queue/task overlap,
unresolved resource list, or missing application PE program; a literal
`collision_check: passed` cannot bypass those comparisons.

## Matmul formulation comparison and trace replay

The [controlled comparison](MATMUL_COMPARISON.md) tests twelve single-PE f16
implementations at 4×4, 8×8 and 32×32, including corrected reductions and packed
blocked rows. Open the [WebGL matmul microscope](results/matmul-compare/matmul.html)
to step instructions, inspect SIMD operands, and stop on a selected output cell.
The reference-style layout now keeps numeric A/B/C and ΔC visible, with
coarse/fine controls and host-to-SRAM-to-readback stages. Its **Mesh GEMM / GEMV**
view includes captured 2×2-PE tile placement, packed panel payloads, local
arithmetic, partial reductions and output assembly. WebGL routes distinguish
observed PE packets from schematic host I/O; the offline HTML includes all data.
Original captures remain under `microbench/matmulorder`; follow-up captures and
reproduction are in [microbench/matmul_compare](microbench/matmul_compare/README.md).
