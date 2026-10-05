# Following exact numbers between WSE-3 PEs

Open the [offline hop viewer](results/pe-hops/hops.html). It connects each selected
number to its source instruction, two router observations, receive instruction,
and subsequent arithmetic. It covers the retained 4×4 and 8×8 GEMM and MeshGEMV
history captures on a 2×2 application mesh. Rendering uses HTML and SVG, not WebGL.

## The missing half of the payload

The earlier walkthrough exports kept `wavelet.data`, but omitted `wavelet.index`.
For these 32-bit numeric wavelets, the installed SDK 2.10 formatter reconstructs
the complete word as `(index << 16) | data`, then interprets those bits as f32.
For example, `index=0x4130, data=0x0000` is **11**, not zero;
`index=0xc010, data=0x0000` is **−2.25**. Control packets must retain their control
flag and must not be displayed as numerical tensor values.

This viewer reads both halves directly from the retained raw records. The older
bundles have not been regenerated: their `data` fields remain low-half fields.
This correction concerns wavelet payloads; zero operands in some fabric
`FMOV32` S6 records remain unsuitable for reconstructing the transferred values.

## One complete example: 11 becomes an operand

V1 computes `X @ W`, with `X=[1,2,−1,3]` and row-major `W=1…16`.
PE (0,0) computes the top partial **11** for output 0. PE (0,1) computes **30**
locally and receives 11. Their fabric coordinates are (4,1) and (4,2).

| Observation | Simulator cycle | Decompressed JSONL row |
|---|---:|---:|
| Source `IMOV32.NF` S6, UID 5915, PC `0x824` | 10807 | 170667 |
| Source router, packet `14310831030273` | 10811 | 170736 |
| Destination router, same identity and `0x41300000` | 10857 | 171452 |
| Receive `IMOV32.NF` S6, UID 5930, PC `0x926` | 10903 | 171911 |
| `FADDS`, UID 6242, PC `0x1ba`: **30 + 11 = 41** | 11359 | 177711 |

Source: `results/gemv-walkthrough/try-20260915a/v1-history/events.jsonl.gz`.
The complete message is `[11,14]`, color 4, followed by a separate control
packet. The final output `[41,46,51,56]` agrees with the retained host readback.
Output replicas travel back upward in separate messages with new identities.

## What the four captures establish

| Capture | Bound numeric packets | Complete messages | Observed router intervals, cycles |
|---|---:|---:|---|
| V1: 4×4 MeshGEMV | 8 | 4 | Down: 46 or 93; up: 2 |
| V2: 8×8 MeshGEMV | 16 | 4 | 2 |
| G1: 4×4 GEMM | 32 | 8 | 2, 31, 72 |
| G2: 8×8 GEMM | 128 | 8 | 2, 3, 4, 5, 21, 34 |

The exporter retains **416 scoped router observations**: two endpoints for each
of 184 data packets and 24 control packets. All form unique adjacent-PE pairs
within the selected application coordinates and colors. This is not a claim
that every host-transfer or service-PE wavelet in the capture was analyzed.

The native SDK CTF reader independently matches all 416 observations on cycle,
color, link code, control bit, both payload halves and multiplicity. Its display
API omits packet identity; that check uses raw JSONL. The SDK formatter agrees
with every bound numeric endpoint. The audit also confirms 62 source hashes
unchanged and 52 matches against the original capture manifests. Four binding
unit tests and the offline browser test pass, including all 184 selections.

GEMM includes east, west, north, and south movement. A and B panels use the
program's column-major packing. Repeated values are disambiguated by the entire
ordered vector, endpoints, color, and instruction chronology. Captured CSL
assigns DSR 1 to horizontal A collectives and DSR 2 to vertical B collectives;
checking those registers excludes earlier identical host copies using DSR 0.
Each panel word is also checked against its first consuming multiply on the
destination PE. Later reuse is available in the existing GEMM walkthrough.

The [relay comparison](results/pe-hops/relay_comparison.json) separately checks
the eight-word color-6 transfer from fabric (4,1) to (5,1). The older relay has
eight 2-cycle intervals. `relay_compute` has intervals `[2,2,2,2,2,3,3,3]`,
correcting the earlier all-2-cycle description. Its words decode to
`[-2.25,-0.75,0.75,2.25,3.75,5.25,6.75,8.25]`; all eight receiving Add operands
and results match the retained host output. The older relay did not retain
equivalent numeric readback, so it supplies timing evidence only. These are
different programs, not a controlled readiness experiment.

## Limits that matter for the next experiment

- A router interval is the difference between two recorded landing observations.
  It is not isolated link latency. Waiting, route setup and backpressure are
  hypotheses to test, not explanations already established by these pairs.
- A router arrival is not an input-queue insertion or an SRAM write. Seeing eight
  arrivals before a receive instruction does not establish an eight-word queue.
- S6 supplies operand/result evidence. It does not identify all internal physical
  stages, register ports, SRAM banks or writeback times as a MIPS block diagram might.
- SDK link codes are preserved verbatim. Arrows derive from coordinates; a link
  code is not silently renamed as a receiver's compass-facing input port.
- The collectives can reconfigure routing. An initial compiled route table alone
  does not describe the later upward replica phase.
- This binder deliberately rejects identities with more than two scoped
  observations. Longer routes and multicast need a graph of adjacent observations,
  including transit PEs, rather than a guessed endpoint-to-endpoint line.
- These are simulator observations for instrumented scalar programs. They do not
  establish cycle-accurate behavior on silicon or production GEMM performance.

## Decisive next experiment

Update, 2026-09-16: the first adjacent-PE readiness/length pilot is now
[implemented and measured](microbench/readiness/README.md), with a
[layered comparison](results/readiness/readiness.html). The experiment below
remains the broader design; passive multi-hop and active-relay treatments have
not been added by this pilot.

Start with a direct two-PE, color-6 transfer and a fixed, known f32 payload.
Use sentinels with nonzero low halves as well as ordinary signed values. Preserve
the uint32 bits at initialization, both routers, receive, and host readback.

| Variable | Initial treatments | Purpose |
|---|---|---|
| Receiver readiness | Early receive; then 16, 64, 256 programmed delay cycles | Separate receiver scheduling from distance; measure actual dispatch cycles |
| Message length | 1, 4, 5, 8, 16 words | Locate buffering/flow-control transitions without inferring occupancy |
| Passive route | 1, 2, 4 eastward hops; then east→south | Observe each transit router and distinguish turns from straight paths |
| Active relay, separate experiment | Receive into SRAM → Add → send again | Bind the newly generated packet identities through arithmetic lineage |

Run the readiness/length matrix at one hop first. Repeat a small set of early
and delayed cases over longer routes only after exact payload and trace-completeness
checks pass. Keep tracing configuration, payload, compiler version and placement
fixed within comparisons; retain disassembly and runtime route/stall observations
where available. Repetition checks simulator reproducibility, not hardware variance.

For each word, export send S6→source router, every adjacent router interval,
destination router→receive S6, and receive S6→first arithmetic use. For an active
relay, include both incoming and outgoing identities and the operation linking
their values. Feed those observed events into the existing stacked time-plane
presentation. Do not interpolate an unobserved physical packet position.

The original hop review launched no new workload or hardware sweep. The linked
follow-up runs simulator-only readiness experiments.

## Reproduce and inspect

From this study directory:

```bash
python3 tools/pe_hops.py
python3 tools/pe_hops_relay.py
python3 -m unittest discover -s tests -p test_pe_hops.py
/software/cerebras/cs_sdk-2.10/cs_python tools/pe_hops_vendor_check.py
```

Browser check, from `viewer/`:

```bash
LD_LIBRARY_PATH=/home/USER/.cache/gemm-browser-deps/lib \
PATH=/home/USER/.nvm/versions/node/v24.16.0/bin:$PATH \
npm test -- tests/pe-hops.spec.ts
```

The viewer supports all 184 word selections, observation stepping, raw row
references, desktop/mobile layouts and offline JSON export. Its evidence is in
[`hops.json`](results/pe-hops/hops.json); the SDK comparison is retained in
[`vendor_parity.json`](results/pe-hops/vendor_parity.json). Source hashes accompany
the export, including captured CSL, placement, disassembly and ELF files.
