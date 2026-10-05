# WSE-3 Characterization — Findings

Progress summary for the ALCF Cerebras WSE-3 campaign. Companion to `README.md`,
which describes the study's *design*; this records what it *found*.

**Current architecture interpretation (2026-09-17):** read the
[official-materials and model review](ARCHITECTURE_REVIEW.md) alongside this
historical log. Earlier “pipeline depth = 3,” universal hop-cost and
“minimum = unstalled latency” wording is not an established WSE-3 specification.
S3/S6 are documented decode/execution anchors; physical intervening stages remain
unidentified. Later bank-stride silicon results, receiver-readiness experiments,
and full-word packet binding supersede the corresponding older open questions.
The new review also separates WSE-3's documented 512-byte cache from older
generations, and tests conditional models without new workload execution.

Every claim carries an evidence class:
**`silicon`** measured on a real CS-3 · **`simulator`** SDK fabric simulator ·
**`compiled`** read from the compiler's own ELF output.

Published: [Fabric Readout](https://claude.ai/code/artifact/8778b38b-c44f-421f-8587-46fa94b275d5) · [Programmer's Reference](https://claude.ai/code/artifact/da197d66-face-4cc1-b4b1-0503f7468fe1) · [MeshGEMM dataflow](https://claude.ai/code/artifact/0d86ae65-016f-498f-ad0d-6e1d83ac7eb3) · [MeshGEMV dataflow](https://claude.ai/code/artifact/be866a68-b4e1-419e-9c50-189af5dbeec3) · anatomy: [AXPY & Dot](https://claude.ai/code/artifact/d09b1720-e2d4-4b1b-8b29-60475e394b3c), [Copy & Stride](https://claude.ai/code/artifact/15d7d577-76f0-42b7-b4fd-c74657703219), [Elementwise](https://claude.ai/code/artifact/43de5237-9f96-4017-979b-146d8911b9f3) · [microbench harness mesh](https://claude.ai/code/artifact/18ced05e-03c6-47aa-a6b5-ef1eb17969ae)  
(Earlier readout/reference/MeshGEMM URLs live in a different claude.ai organization and are superseded by these.)
(findings narrative) · [Programmer's Reference](https://claude.ai/code/artifact/7f0d8b14-a77c-4266-8877-944ce848521d)
(lookup reference).

---

## Tiny GEMM walkthrough — 2026-09-14

**Evidence: `simulator` + `compiled`.** Six serial SDK 2.10 captures now exercise
handwritten scalar 4×4 GEMM on one PE, the same matrices on a 2×2 PE mesh, and
8×8 GEMM on that mesh, each with and without history instrumentation.

| Scene | Contributions matched to FMULS/FADDS | Final outputs verified | Numerical comparisons |
|---|---:|---:|---:|
| G0: 4×4, one PE | 64/64 | 16/16 | 274 |
| G1: 4×4, four PEs | 64/64 | 16/16 | 288 |
| G2: 8×8, four PEs | 512/512 | 64/64 | 2,128 |

Every operand, old/new accumulator, final output, and panel readback comparison
passes. All history-free controls also return the expected C. Instruction
associations require ordered operation counts and exact execute operand/result
bits. Each history trace reports zero discarded events. PE placement is checked
against ELF load segments, not inferred from image filenames.

The [offline viewer](results/gemm-walkthrough/gemm.html) links matrices, ownership,
partial sums, logical panel transfers, buffer offsets, CSL/IR/assembly, and
instruction timelines. [Validation summary](results/gemm_walkthrough_verified.json)
retains run identity, manifest hashes, counts, and per-PE elapsed times;
[reproduction instructions](microbench/gemm_walkthrough/README.md) document the
capture pipeline and boundaries.

Two correctness lessons from implementation: concurrent compiler capture workers
need atomic unique request filenames, and a PE's enabled/reset TSC has a different
origin from simulator trace cycles. History adds substantial overhead: G0 took
29,724 local cycles versus 4,455 without history. These explicit scalar teaching
builds use `optnone gemm`; they are not production GEMM performance measurements.
Packet-to-element binding and internal forwarding remain unresolved.

## MeshGEMV and time-slice presentations — 2026-09-15

**Evidence: `simulator` + `compiled`.** A scalar f32 teaching implementation of
MeshGEMV now follows X @ W with PE rows partitioning input k and PE columns
partitioning output j. V0 uses one PE for a 4×4 matrix; V1/V2 use a 2×2 mesh for
4×4/8×8 matrices. Top PEs broadcast local partials down their columns, bottom
PEs add them to their own partials, and the final values are broadcast back.
This two-peer lesson is distinct from WaferLLM's larger f16/DSD/two-tree kernel.

| Case | Products mapped | Reduction adds mapped | Checkpoints mapped | Value/flag checks | Output |
|---|---:|---:|---:|---:|---|
| V0 | 16/16 | 0 | 3/3 | 97 | [41,46,51,56] |
| V1 | 16/16 | 4/4 | 18/18 | 144 | [41,46,51,56] |
| V2 | 64/64 | 8/8 | 18/18 | 428 | [158,164,170,176,182,188,194,200] |

All 28 stored output replicas match, all history-free controls match, and every
history trace reports zero discarded events. The six serial SDK 2.10 captures
are retained in `results/gemv-walkthrough/try-20260915a`. The
[validation summary](results/gemv_walkthrough_verified.json) retains hashes,
counts, checkpoint cycles, and per-PE history/control durations.

The [MeshGEMV page](results/gemv-walkthrough/gemv.html) links local numbers,
partial sums, PE ownership, reduction, replicas, source/IR, and assembly. The
separate [time-slice page](results/gemv-walkthrough/time-slices.html) covers these
three cases plus the three retained GEMMs. For V1, PE (0,1)'s peer-buffer
checkpoint is at cycle 11,315; at 11,359 a matched FADDS computes 30 + 11 = 41.
The top replica is shown only after its final checkpoint at 12,438.

Phase cycles are the last observed execute within named checkpoint functions,
bound through ELF symbol ranges and checked flags/readbacks. Local TSC ticks
remain separate. Frames hold last observed arithmetic values and explicit phase
buffer values, not reconstructed SRAM contents or queue states. GEMM has only
arithmetic time bindings in this presentation. Every final frame agrees with its
run's readback. [Guide and reproduction](microbench/gemv_walkthrough/README.md).

The separate [layered PE/time presentation](results/gemv-walkthrough/space-time.html)
repeats the same mesh across successive recorded cycles in a rotatable stack.
It reuses these captures and adds no new timing measurements. All six GEMV/GEMM
scenes support output selection, per-PE numeric histories, and guided, uniform,
or consecutive-event sampling. Dashed GEMV connections represent the compiled
partial-transfer and replication steps with checked checkpoint endpoints;
their geometry does not assert packet timing. The default V1 story exposes
11 and 30 becoming 41, with unknown future results preserved. An offline HTML
and self-contained SVG export support sharing. [Layer guide](viewer/LAYERS.md).

## 1. The machine


| fact | value | evidence |
|---|---|---|
| ISA family | **proprietary Cerebras** — not RISC-V, ARM or x86 | `compiled` |
| instruction width | **32-bit fixed**, PC counted in 16-bit words | `compiled` |
| SRAM | 48 KiB/PE, **8 banks**, address bits[3:1] | `compiled` |
| routable colours | 24 (21–23 reserved by `<memcpy>`) | `compiled` |
| microthreads | ut_id 0–7 | `simulator` |

The CSL toolchain contains exactly **one** LLVM target backend, `Cerebras`.
RISCV/ARM/AArch64/X86/Mips/PowerPC backend libraries are all absent. Cerebras's own
arch codenames are `EINSTEIN` and `FEYNMAN`. RISC-*shaped* — fixed width, load/store,
three predicate registers — but nearest relative is a DSP.

## 2. Reading the machine code

**There is no assembler.** No binary in the Cerebras toolchain assembles; `llvm-mc`
rejects `invalid target 'cerebras'`; `cslc` refuses `.s`. `libLLVMCerebrasAsmParser.so`
ships with no front-end.

**There is a disassembler, under a misleading name.** `elf2lst` — the tool named for the
job — always fails, because it shells out to an `llvm-objdump` with no Cerebras target.
**`elf2am` links the disassembler in-process and works.**

| artefact | value |
|---|---|
| ISA reference | **76 mnemonics** across 2 codebases |
| encoding table | **5,489 encodings ↔ 5,489 texts**, bijective |
| cross-codebase conflicts | **0** |

The bijection makes the table invertible, so it doubles as a lookup assembler
(`results/encoding_table.json`, `decode` + `assemble`).

## 3. Single-PE cost model — `silicon`

`cycles = a + b·N`, fitted with zero residual, then re-measured on hardware.

| operation | elem/cycle (sim) | elem/cycle (**silicon**) | setup |
|---|---:|---:|---:|
| copy fp16 | 8.00 | **4.82** | 15 |
| copy fp32 | 4.00 | **2.44** | 15 |
| fma fp16 | 4.00 | **2.92** | 16 |
| fma fp32 | 0.50 | **0.50** | 17 |

- Move path is **bandwidth**-limited (both copies → same bit/cycle); arithmetic is
  **lane**-limited.
- **fp16 FMA is 5.84× fp32 on silicon** — the largest arithmetic lever on the machine.
  Simulation says 8.0× and overstates it by 37%.
- **The simulator is optimistic only on the memory path.** fp32 FMA — arithmetic-bound —
  matches silicon exactly at every N; the three move-bound ops run 1.37–1.66× slower.

### Bank conflicts — `silicon`, and directly actionable

8 banks, f32 spans 2 words ⇒ element offset has period **4**. Four alignment classes,
**exactly one slow per stride**, penalty **1.94×** (up to 2.86×).

**24 cases, 2,520 events, every point matching the simulator to within one cycle.**
Fixed by an `align()` annotation — which appears in **one file** in the entire kernel corpus.

## 4. Fabric — `silicon`

| term | simulator | **silicon** |
|---|---:|---:|
| per hop | 2.000 | **2.000** (isotropic) |
| per wavelet | 1.000 | **1.125** |
| per turn | ~33 | **~20** (≈10 hops, not 17) |
| contention | — | **full serialisation** (1.3% error at 2 sources) |

Open: **west degrades past 32 hops** (2.000 → 3.09 → 3.30) while east holds 2.000 to
h128. A slope change, not an offset — unexplained.

## 5. NoC occupancy model — `simulator`

A latency model predicts one transfer; a kernel runs many at once. Summing wavelets
predicted **161% of ParDot-Product's runtime** — parallel links billed as serial.

**The fix: `fields[4:0]` of `wavelet_trace_entry` is the colour id** — verified against
the compiler's routing tables on **38/38 PEs, zero inconsistencies**. Colour is the join
that turns per-PE counts into per-**link** ones:

```
tile_index -> PE ; fields[4:0] -> colour ; PE+colour -> ELF routes -> the link
```

| kernel | sum model | **link model** |
|---|---:|---:|
| ParDot-Product | 161% ✗ | **14.7%** |
| ParReduce-Sum | 123% ✗ | **12.2%** |
| ParBroadcast-Scale | 93% | **10.7%** |
| Jacobi-2D-5pt | 46% | **5.1%** |
| Laplacian2D-Halo | 45% | **5.0%** |
| RowParallel-Softmax | 21% | **2.6%** |

**100% of wavelets attributed on all six.** None of these kernels is fabric-bound.

## 6. Where the performance actually goes

**Roofline** (per PE, silicon ceilings): fp16 FMA **5.84 FLOP/cyc**, local move 9.62 B/cyc,
fabric 4.0 B/cyc. Ridge points **0.61** and **1.46 FLOP/byte**.

> **The best kernel in the suite reaches 3.65% of the fp16 ceiling.** Every kernel sits
> below both ridge points — none is compute-limited.

**Bottleneck classes** (`tools/bottleneck.py`, 20 kernels): IPC on the busiest PE, float %
of the instruction mix, wavelets per dispatch.

| class | test | fix | count |
|---|---|---|---:|
| I/O-dominated | wav/disp > 0.8 | fuse / batch | 5 |
| Stalled | IPC < 0.35 | overlap via distinct ut_ids | 1 |
| **Overhead-bound** | float < 8% | addressing & control | **8** |
| Arithmetic-bound | otherwise | vectorise, move to f16 | 6 |

Validated blind: Laplacian2D-Halo was classed overhead-bound from its 1.3% float content;
its recorded 1709→671 optimisation history was won **entirely** by addressing/control angles.

**PE overhead**: a 1-PE kernel occupies **24 PEs** — 1 application, 23 `<memcpy>` plumbing.

## 7. Cross-codebase check: WaferLLM (OSDI'25) — `simulator`

WaferLLM's MeshGEMV and MeshGEMM were compiled and traced through the identical pipeline.
This is the first code in the study written by someone else, for this machine, by people who
had the hardware. It functions as a control on every conclusion above.

| | our corpus (20 kernels) | MeshGEMV | MeshGEMM |
|---|---|---|---|
| elements/dispatch | 1.15 – 6.16 | **13.52** | **29.25** |
| f16 share of float arithmetic | **0%** (all `FMACS`/`FMULS`) | **100%** (`FMACH`) | **100%** (`FMACH`) |
| SIMD lanes observed (`simdi`) | `[0]` only | `[0..7]` | `[0..7]` |
| bottleneck class | 8 overhead / 6 arithmetic | overhead-bound | **arithmetic-bound** |
| busiest-link occupancy | 2.6 – 14.7% of runtime (6 multi-PE kernels) | **36%** | 8.5% |
| turns as share of routed hops | 21 – 50% | **6.2%** | **6.7%** |

Four things follow.

1. **Both of our headline optimisation levers are real, and unused only by us.** WaferLLM
   runs f16 arithmetic at 16 elements per `FMACH` dispatch; our corpus runs fp32 at ~2. The
   5.84× f16 ceiling and the DSD-width advice are not theoretical — they are the gap between
   the two codebases.

2. **The bottleneck classifier discriminates.** Same algorithm family, same author, same
   fabric: GEMV lands overhead-bound (2.8% float, 36% link occupancy) and GEMM lands
   arithmetic-bound (10.8% float, 8.5% link occupancy). That is the textbook GEMV/GEMM
   arithmetic-intensity split, recovered from traces alone with no knowledge of the algorithm.

3. **Turns are engineered away, and turn count does not grow with PE count.** Our measured
   turn cost is ~20 cycles against ~2 cycles/hop — a turn is worth ten hops. WaferLLM's
   routing is dimension-ordered on per-dimension colours: 83–91 straight-through route
   entries and exactly **6** turns. Those 6 turns carry the colour signature `{0:3, 1:2, 3:1}`,
   *identical* to Jacobi-2D-5pt's, so they are the launch/`memcpy` harness, not application
   data — the application routing adds no turns at all. This is the concrete mechanism behind
   the INTERLEAVE 2-hop bound, and it is portable to our kernels.

4. **The classifier's *advice* was wrong before its *class* ever was.** MeshGEMV was correctly
   called overhead-bound and then told to vectorise — at 13.5 elements/dispatch. Fixed:
   `bottleneck.py` now reports elements/dispatch and f16 arithmetic share alongside float%,
   and suppresses width/precision advice when those levers are already spent, redirecting to
   occupancy (IPC 0.457 against a 1.0 issue ceiling) instead.

Scale caveat: both were run at P=4 on the simulator (MeshGEMM 64³, 8.3 M trace events).
Every row above is `simulator` evidence about *code structure*, which is scale-invariant;
none of it is a silicon timing claim.


## 8. Pipeline and data hazards — `simulator`

Instrument: `hwm_pipe_trace_entry.stage` is exactly `{3, 6}`, which Cerebras documents as
instruction decode and instruction execution. `uid` is **unique per instruction instance
within a PE** (48,704 dispatches, 48,704 distinct uids), and `inst_ptr` equals the `elf2am`
PC exactly. So dispatch, pipe and disassembly join cleanly: `uid` ties the first two, PC ties
both to real register operands. `tools/hazard_probe.py` does that join.

This matters because neither stream is usable alone. The pipe trace's `dest`/`src0..2`
carry operand **values**, not register indices — decoding them as f32 recovers the exact
constants fed in from the host — so they cannot say which instruction produced an input.
Only the disassembly knows that.

### Pipeline depth, decode → execute

| mnemonic | n | mean | min | max |
|---|---:|---:|---:|---:|
| FADDS | 16,410 | **4.25** | 3 | 5 |
| FMULS | 16,384 | **4.03** | 3 | 5 |
| LTU16 | 2,055 | 3.75 | 3 | 5 |
| ADD16.NF | 2,184 | 3.28 | 3 | 6 |
| LD16RP | 3,600 | 3.14 | 3 | 5 |
| JMP / LD16 / ST16 / MOVRI | 5,700 | **3.00** | 3 | 3 |

**Baseline depth is 3 cycles and is exact** — jumps, loads and stores never vary. FP is
deeper, and the excess is not a constant: it is the stall.

### The stall is visible in the depth

| RAW distance | n | mean depth |
|---|---:|---:|
| 1 | 24,810 | **4.18** |
| 2 | 1,547 | 3.00 |
| 4 | 2,569 | 3.60 |
| 6 | 515 | 3.00 |

An instruction whose operand was produced by the *immediately* preceding instruction waits
in the pipe; one whose producer is 2 or 6 back never does. `stage 6 − stage 3` measures that
wait directly.

### Issue intervals — the answer to open item #1

Measured on the ILP microbench, where all four variants issue identical instruction counts
with identical loop overhead and differ only in dependency-chain depth:

| chain depth | 1-cycle gaps | 2-cycle gaps | cycles/FP op |
|---|---:|---:|---:|
| 8 (fully serial) | 512 | **7,168** | 2.436 |
| 4 | 1,536 | 6,144 | 2.249 |
| 2 | 4,096 | 3,584 | 1.936 |
| 1 | *contaminated by 14 spill instructions/iteration* | | 2.686 |

In the pure serial chain **7,168 of 8,192 execute-to-execute gaps are exactly 2 cycles**.
As chain depth halves the share of back-to-back single-cycle issues rises monotonically —
6.7% → 20% → 53%. So:

- **dependent FP op → dependent FP op: 2 cycles**
- **independent FP ops: 1 cycle** — issue width is 1/cycle
- **loop back edge: 9–10 cycles**, once per iteration, and at 19 instructions per iteration
  that alone is a third of the loop's cost

### `xcptn` decoded

| mnemonic | xcptn histogram |
|---|---|
| FMULS | `{4: 16358, 0: 26}` |
| FADDS | `{0: 16365, 4: 45}` |
| every integer / memory op | `{0: ...}` |

Never non-zero outside FP, and **data-dependent within each FP opcode** (26 FMULS at 0, 45
FADDS at 4). That rules out an opcode tag: `xcptn` is an FP status field, and bit 2 is
consistent with *inexact* — the microbench multiplies by 1.0009765625 (inexact) and adds 0.5
(usually exact). MeshGEMV's `{0: 88504, 4: 46354, 255: 265142}` fits, with 255 the
not-applicable sentinel.

### What was refuted

RAW distance alone does **not** determine the issue gap: modal-gap-per-distance scores
**57.2%** on dispatch gaps and **65.1%** on execute gaps across the whole kernel. The laws
above hold in the controlled loop; they are not a general predictor for mixed code, and the
tool prints the hit rate so this cannot be quietly overstated.

### SRAM read/write bank conflicts — inconclusive, and why

The `cs-readelf` man page says conflicts arise when concurrent accesses hit the same bank or
the same bank modulo 4. `microbench/bank/` sweeps a DSD copy's destination across all 8 bank
offsets. Result: **identical to the cycle** at every offset, at both 2048- and 16-element
vector lengths.

That is *not* reported as "no read/write penalty exists", because the probe carries a
positive control in the same binary — four strided variants reproducing what the study's
own `single-pe-bank` family varies (`calibration_codegen.py:1886`). **The control is also
flat (spread 1.000×)**, so this probe cannot see the alignment effect the study already
measured at 1.94× on silicon. A flat treatment next to a flat control proves nothing about
the treatment. Stride itself does register: stride 2 costs **1.981×** at n=2048, falling to
1.286× at n=16 as setup amortisation shrinks.

Open: find the access form that reproduces the known alignment effect, then re-run the
read/write sweep against it, on silicon — this is exactly where the simulator's 1.37–1.66×
memory-path optimism lives.


## 9. Capacity limits — `compiled`

### One PE, measured to the byte

`microbench/capacity/` bisects the largest allocation `cslc` will link:

| u16 words | total ELF bytes | result |
|---:|---:|---|
| 22,480 | 49,136 | links |
| **22,488** | **49,152** | **links — exactly 48 KiB** |
| 22,496 | 49,168 | `ld.lld: ran out of PE memory` |

So the PE holds **exactly 49,152 bytes**, confirmed to the word rather than taken from a
datasheet. Across the whole sweep the ELF total is user bytes **+ 4,176** with no variation,
so a minimal `<memcpy>` kernel costs 4,176 bytes and leaves **44,976 bytes** for data. A real
kernel costs more: MeshGEMM's application PE occupies 8,336 bytes against 2,560 bytes of
named tiles, i.e. ~5,776 bytes of code and runtime.

### Shapes that fit one PE (`tools/capacity_table.py`)

| shape | f16 minimal | f16 realistic | f32 minimal | f32 realistic |
|---|---:|---:|---:|---:|
| dense vector `n` | 22,488 | 21,688 | 11,244 | 10,844 |
| square GEMV `n×n` | 148 | 146 | 105 | 103 |
| square GEMM `n×n×n` | **86** | 85 | 61 | 60 |

**Verified, not just arithmetic.** Compiling three square f16 tiles: n=86 links at 48,576
bytes; **n=87 fails**. The predicted ceiling is the observed one.

The practical reading: a single WSE-3 PE holds a 86×86 f16 GEMM or a 148×148 f16 matrix-vector
problem. Anything larger is a distribution problem, which is why WaferLLM tiles at 16.

### The wafer bound is NOT a compiler fact

`cslc` accepts **any** `--fabric-dims` tried — 762×1172, 1024×1024, 1500×1500 and 2048×2048
all link. The fabric size is a declared canvas, not a validated hardware bound, so no wafer
capacity figure can be derived from the compiler. That requires an appliance run and is **not
established here**. The PE overhead tax is real and measured though: a 1-PE kernel occupies
24 PEs, 23 of them `<memcpy>` plumbing.

### Two defects in the study's own SRAM probe

The `single-pe-sram` family (15 compile-only cases) had never been run. Running it found it
measures nothing:

1. `inspect_memory.sh` looked for `out/out_0_0.elf`; the ELF is at `out/bin/out_0_0.elf`.
   Fixed in `calibration_codegen.py:2244`.
2. Its `allocation` array is declared but never written, so it does not survive to the ELF —
   `cs_readelf --ms` reports **1,024 bytes for every case**, from 1 KiB to 50 KiB requested,
   and no `allocation` symbol exists. The family needs the array touched, exactly as
   `microbench/capacity/pe.csl` does, before its numbers mean anything.


## 10. The single-loop form — `simulator` + `compiled`

### The DSD covers the whole PE in one instruction

`microbench/extent/` sweeps the requested DSD length and reads `num_data` back out of the
dispatch trace. Every length from 8 to **22,000** issued **exactly one dispatch** with
`num_data` equal to the request — for `@fmach`, `@fmulh` and `@fmovh` alike, including
non-power-of-two lengths like 17. Nothing splits.

**So `FMACH`'s 16 in WaferLLM is a tile-size choice, not an ISA limit** — it is 1/1375th of
what one dispatch can do. The binding constraint on a single loop is not the instruction set
but the 44,976-byte working set from §9: the hardware loop runs out of *memory* before it
runs out of *extent*.

That is shown directly, not inferred. CSL **does not bounds-check a DSD's declared extent
against its backing array** — a 1,024-element array with a declared extent of 32,000 compiles
cleanly — and `cslc` accepts extents up to **262,143** without complaint. So the extent field
is not what stops you.

### Maximum elements in one dispatch

| operands | f16 | f32 | set by |
|---|---:|---:|---|
| 1 — fill (`@fmovh`) | **22,488** | 11,244 | PE memory |
| 2 (`@fmulh`) | 11,244 | 5,622 | PE memory |
| 3 — FMA (`@fmach`) | **7,492** | 3,746 | PE memory |

The 3-operand row is measured, not divided: three f16 arrays link at **n=7,492** (49,152
bytes exactly) and fail at n=7,496. All three operands must be resident simultaneously, so a
useful FMA reaches a third of the single-array figure.

Distinguish this from *throughput*: one dispatch **addresses** up to 7,492 elements per
operand, but **retires** 4.00 f16 FMA elements/cycle in simulation and 2.92 on silicon (§3),
with SIMD lanes 0–7 observed. A 7,492-element `@fmach` is one instruction that occupies the
core for roughly 1,900 cycles.

### What each nesting level costs

`microbench/loopform/`, four shapes, **4,096 f16 FMA elements each** — verified in the trace:
one dispatch of `num_data=4096` plus 768 dispatches of `num_data=16`, 16,384 elements total.

| form | software loops | shape | cycles | cyc/FP elem | vs L0 |
|---|---:|---|---:|---:|---:|
| **L0** | **0** | one `@fmach` over the whole DSD | **1,040** | **0.254** | **1.00×** |
| L1 | 1 | `while` over 16-element tiles | 4,617 | 1.127 | 4.44× |
| L2 | 2 | `@map` + tile — the MeshGEMV shape | 2,840 | 0.693 | 2.73× |
| L3 | 3 | `for` + `@map` + tile — the MeshGEMM shape | 3,032 | 0.740 | 2.92× |

**L0 reaches 3.94 elements/cycle — the documented f16 FMA peak of 4.00.** The tiled forms
reach 23–37% of it. Tiling to 16 costs between 2.7× and 4.4× on the arithmetic itself.

Two results worth separating out:

1. **A hand-written `while` loop (L1) is the *worst* form — worse than either deeper
   nesting.** `@map` beats it by 1.6×. The intuition that fewer levels is faster is wrong
   here: what matters is whether the compiler recognises the construct, and it generates
   better code for `@map` than for an equivalent `while`.
2. **The gap between L2 and L3 is small (1.07×).** Adding the third level costs almost
   nothing; the expensive step is leaving L0 at all. So the payoff is in widening the DSD,
   not in unwinding the outer loops.

### What this implies for MeshGEMM, stated carefully

MeshGEMM issues ~9.2 dispatches per 16-wide `FMACH` and is 10.8% float (§7). Widening its
DSD is the lever with real headroom, but Amdahl bounds it: at 10.8% arithmetic share, even
a 4.4× on the FP portion is a ~1.09× end-to-end. The larger prize is that a wider DSD also
removes the addressing and control instructions that make up the other 89% — which is a
rewrite, not a parameter change, and is not attempted here.

The honest limit on this: the `Kt` loop in MeshGEMM carries a reduction, and `@fmach`'s
multiplier is a scalar drawn from `@map`, so a fully collapsed DSD may not be expressible for
the accumulate pattern. §10 measures the *cost of the levels*; it does not demonstrate that
GEMM specifically can shed them.


## 10b. Input/output flow, and whether the dataflow is deterministic

### Where data enters and leaves the fabric

The host boundary is visible in the compiled routing, not inferred. For MeshGEMV (P=4,
fabric 11x6) the application grid is x=4..7, y=1..4 — exactly the 16 PEs of a 4x4 mesh — and
the columns on either side are the I/O path:

| column | role | evidence |
|---|---|---|
| **x=3** | host&rarr;device entry | `colour 22/23: RAMP -> EAST` — injects into the fabric |
| x=4..7 | application | `colour 22/23: WEST -> EAST,RAMP` — passes east *and* taps into the CE |
| **x=8** | device&rarr;host exit | `colour 21: WEST -> RAMP`; PEs (8,2)&ndash;(8,4) only receive |

So **colours 22 and 23 carry H2D, colour 21 carries D2H**, both flowing west&rarr;east, and every
application PE taps the stream as it passes. Applying the verified `fields[4:0]` colour decoding
to the wavelet trace splits the traffic:

| | H2D (22,23) | D2H (21) | memcpy control ring | kernel compute (app↔app) | host-path share |
|---|---:|---:|---:|---:|---:|
| MeshGEMV | 18,704 | 1,728 | **28,793** | **2,464** | **95%** |
| MeshGEMM | 34,288 | 20,928 | 74,957 | 215,040 | 38% |

**Correction.** An earlier version of this table classified every non-memcpy colour as "kernel
compute" (31,257 / 289,997). Classifying by *region* as well — a hop is compute only if both
endpoints are application PEs — shows that most of GEMV's "compute" traffic was the memcpy
library's control/credit ring on colours 0/1/2/3/5 between plumbing PEs (the same colours the
application also uses, which is why colour alone could not separate them). GEMV's fabric
traffic is ~95% host path; only 2,464 hops carry the algorithm. GEMM's compute share is 62%.
Those control-ring wavelets are also the westward arrows visible on the mesh pages: the east
gateway returning credits into the D2H collector column, and the colour-0/5 ring that leaves the
east fabric edge and re-enters at the west edge through the host side.

### The dataflow is deterministic; the timing is not quite

MeshGEMV was run twice on the simulator and the traces compared record by record.

**Identical across runs:**

- **every wavelet, ignoring cycle** — same `(tile, ident, index, data, fields)` multiset,
  SHA-256 `686cd4b6ac874666` in both runs, 72,960 records
- per-PE wavelet counts, across all 38 PEs
- per-colour counts, so the H2D / D2H / compute split above is reproducible exactly

**Not identical:**

- total cycle span: **14,122 vs 14,125** (3 cycles, 0.02%)
- dispatch count: 112,685 vs 112,686
- pipe records: 540,327 vs 540,352
- exactly **three** `(PE, PC)` pairs differ in execution count

Those three localise completely: PE(3,1) at `0x17c`, PE(3,3) and PE(3,4) at `0x18c` — all
`IMOV32.NF`, all on **task colour 24** (the memcpy control colour), all in **column x=3, the H2D
entry column**, at a PC executed ~1,054 times. They are a host-interface polling loop, and it
spins a few more or fewer times depending on host timing.

**Conclusion: routing, volume and payload are deterministic; only the iteration count of the
host-transfer spin loop varies.** Nothing about which PE sends what to which neighbour is random.

Two caveats worth keeping attached. This is the *simulator*; on silicon the study has already
measured run-to-run `cycles_send` variation up to **2×** (7pt-Stencil: 1076 / 1233 / 2129 on
identical runs), so timing determinism must not be assumed on hardware. And this tests one
program twice, not the general case — a kernel with data-dependent control flow or contended
multi-source colours could behave differently.

### Visualising it

`tools/mesh_view.py` renders the whole thing: PEs at true fabric coordinates, wavelets replayed
on the links they took at the cycles they occurred, with link colour selectable between traffic
volume, **link utilisation** (against the silicon-fitted ceiling of one wavelet per 2 cycles),
**hop delay** (2 cycles is free-flowing; more is queueing), and **input/output/compute class**.
Output is one self-contained HTML file.


## 10c. The single-PE model, and what a programmer can actually control

### The model, as measured

Everything a single PE does is now bounded by a measured number rather than a datasheet one.

| property | value | evidence |
|---|---|---|
| SRAM | **49,152 B** exactly | 22,488 u16 words link, 22,496 fail (§9) |
| usable for data | 44,976 B (minimal kernel costs 4,176 B) | constant across the sweep |
| banks | 8, selected by address bits[3:1] | `documented` + silicon (§3) |
| issue width | **1 instruction / cycle** | independent FP ops issue 1 cycle apart (§8) |
| dependent FP latency | **2 cycles** | 7,168 of 8,192 serial-chain gaps (§8) |
| pipeline depth | **3 cycles** baseline, 4.03–4.25 for FP | exact for JMP/LD16/ST16/MOVRI (§8) |
| loop back edge | 9–10 cycles | once per iteration (§8) |
| SIMD lanes | 8 | `simdi` 0–7 in WaferLLM (§7) |
| f16 FMA | 4.00 elem/cyc sim, **2.92 silicon** | fitted cost model (§3) |
| f32 FMA | 0.50 elem/cyc, both | fitted cost model (§3) |
| one dispatch reaches | ≥22,000 elements; **7,492 f16** per operand for a 3-operand FMA | §10 |
| best achievable | 3.94 elem/cyc — 98.5% of the f16 FMA peak | L0 loop form (§10) |

The practical summary: **one PE is a 1-issue, in-order core with a 3-cycle pipe, a 2-cycle
dependent-FP recurrence, 48 KiB of 8-bank SRAM, and a hardware loop that can cover the entire
memory in a single instruction.** Peak is reachable — L0 hits 98.5% of it — but only if the
work is expressed as one wide DSD.

### Controllable granularity — the lever map

`cslc --help` is the frontend; the real surface is `cslc-driver`, which the frontend forwards
unrecognised options to. Enumerated directly:

| granularity | lever | status |
|---|---|---|
| precision | `--fp16-format={f16,cb16,bf16}` | **exists, needs source change** — `cb16`/`bf16` fail with `cannot export name with type '[*]f16'` |
| single PE | `--single-pe` compilation mode | never used by this study |
| microthreads | `--disable-auto-microthread-id` | never used; relevant to the m2/m4/m8 compile failures (§15) |
| loop expansion | `--max-inlined-iterations`, `--comptime-func-depth-limit` | never varied |
| parallelism | `--max-parallelism=N` | never varied |
| memory layout | `--lomem-reservation-end`, `--link-section-start-address-bytes` | **measured, see below** |
| I/O | `--channels`, `--width-west-buf`, `--width-east-buf` | `--channels=1` in 60/60 compiles; buffers 0 in 48/48 |
| introspection | `--out-routes`, `--dump-dsr-alloc-graph`, `--output-json` | unused; `--dump-dsr-alloc-graph` would expose DSR allocation |
| source | DSD width, `@map` vs `while`, f16 vs f32, `mem4d_dsd`, `align()` | **the levers that actually pay** (§10) |

**Correction to the v3 plan.** Its headline experiment was to A/B `--cerebras-slp-vectorize`.
That flag is **not reachable**: `cslc-driver --help-hidden` lists 68 lines and both its
"Color Options" and "General options" categories are empty — no LLVM optimisation flags are
exposed. Whatever the backend libraries contain, the driver does not surface it. Vectorisation
is therefore a *source-level* decision in CSL, not a compiler switch, which is exactly why the
loop-form result (§10) matters: the programmer must write L0; no flag will produce it.

### Memory placement moves, and the simulator does not care

`--lomem-reservation-end` shifts every array. The treatment is verified real — the ELFs differ
(distinct md5s at reservations 0/8/16) and reported memory moves 31,040 → 31,056 bytes — and a
reservation of 8 bytes shifts the bank index by 4, exactly the "same bank modulo 4" case the
man page warns about.

Every reservation returns **identical cycle counts to four decimal places**, on both the
read/write sweep and the strided control.

Taken with §8's flat bank probe, this upgrades that inconclusive result: with a *verified*
treatment and a flat outcome, the most likely explanation is that **the simulator does not
model SRAM bank conflicts on the DSD path at all**. That is a concrete candidate for its
documented 1.37–1.66× optimism on the memory path, and it means the silicon bank result
(1.94×, §3) cannot be reproduced in simulation by any placement lever. Bank tuning must be
validated on hardware.


## 10d. The single-PE roofline suite — `simulator`, validated against §3

`microbench/singlepe/` implements the four-suite roofline plan (pure memory / pure compute /
mixed / edge cases), 70 variants over 5 separately-compiled kernels, all on one PE with no
fabric traffic in the timed region. Two families reproduce the §3 silicon-campaign sim model
independently — copy 7.98 vs 8.00 elem/cyc, FMA 3.94 vs 4.00 — which validates the instrument.

| family | asymptote | setup | note |
|---|---:|---:|---|
| write (fill) | 7.93 elem/cyc | 8 cyc | |
| copy | 7.85 elem/cyc | 8 cyc | read+write simultaneously |
| strided read | **8/stride elem/cyc** exactly | | bandwidth is per touched span, not per element |
| axpy (`@fmach`) | 3.94 elem/cyc | 13 cyc | = f16 FMA peak; N=2047 vs 2048 costs 0.05% |
| ew add / mul | 3.96 elem/cyc | 9 cyc | identical cycles for add and mul — memory-bound |
| **i16 ew add** | 3.94 elem/cyc | 9 cyc | integer DSD = f16 rate |
| **bf16 ew** | identical to f16 **to the cycle** | | same width, same datapath |
| reduction (`@faddh` scalar dest) | 2.00 cyc/elem | 8 cyc | the dependent-FADDH recurrence, third independent measurement |
| vector dot (mul + reduce) | 2.25 cyc/elem | 20 cyc | additive: 0.25 + 2.00 |
| scalar dot, rolled | 22–25 cyc/elem | | **87× worse than the DSD form** |
| scalar dot, K=1 | 19 cyc/elem | | the finest-granularity overhead number |
| GEMV single tile | 0.52 cyc/MAC | **358 cyc** | k-loop structure dominates small tiles; 64×32 beats 32×64 by 1.6× at equal work |
| 5-pt stencil (4 shifted adds) | 0.93 out/cyc | | offset vectors run at full ew rate |

Findings beyond the numbers:

- **A scalar-register DSD destination serialises at exactly 1.000 elem/cyc.** Any
  "read into a register" instrument measures that funnel, not SRAM bandwidth — the first
  version of the stride sweep was flat for exactly this reason.
- **No `@fdph` builtin exists** (the LLVM table's FDPH is unreachable from CSL), but
  `@faddh(&scalar, scalar, dsd)` is a true hardware reduction.
- **No vector integer multiply** (`@mult16` unknown); scalar i16 multiply exists. i8 is a
  storage type only — every fold-proofed i8 loop was eliminated; no datapath number obtainable.
- **The compiler defeats naive microbenches three ways**, all observed here: dead-code
  elimination, loop-invariant hoisting (small-K dot loops kept only the FADDH chain — visible
  in disassembly), and integer reassociation (`reps × sum`). Fold-proofing needs the
  accumulator carried across reps *and* a rep-dependent index.
- **BF16 requires `--fp16-format=bf16` plus the type spelled `bf16`** — under that flag,
  `f16` becomes comptime-only, which is what the earlier export error actually meant.

Evidence: `simulator`. The memory families inherit the documented 1.37–1.66× sim optimism
and the invisible bank conflicts (§10c); arithmetic families match silicon per §3.

## 10e. External cross-check: the HPDC'24 wafer-scale Reduce model

Luczynski & Gianinazzi et al., *Near-Optimal Wafer-Scale Reduce* (HPDC'24, arXiv:2404.15888)
build the only published validated runtime model for WSE collectives — WSE-2, SDK 1.0. Their
synthesis, with D = depth (store-and-forward stages), L = distance (hops), E = energy
(element·hops), C = per-PE contention, N = links used, T_R ≈ 2 (ramp):

> **T = max(C, E/N + L) + (2·T_R + 1)·D**

Cross-check against this study's measurements:

| their parameter | their value (WSE-2) | ours (WSE-3) | verdict |
|---|---|---|---|
| link bandwidth | 1 wavelet/cyc/link | 4 B/cyc silicon = 1 wavelet/cyc | **agree** |
| hop latency | 1 cyc/hop (distance = L cycles) | **2 cyc/hop** (silicon fit; 72% of sim hop deltas exactly 2) | **disagree ×2** — their distance term underpredicts on WSE-3 |
| turn cost | absent | **~20 cyc/turn** | their gap; matters for their X-Y 2D routes |
| ramp T_R | ≈2 cyc | never isolated here (receiver-overlap open item) | their gap → ours; measurable |
| compute | 1 cyc/element store | full per-instruction model (§3, §8, §10d) | ours far finer |
| contention C | max elements through one PE | per-link occupancy (§5), verified colour attribution | same idea, finer resolution |
| race rule | two wavelets, same colour, same cycle = UB; routers accept one direction at a time via **control wavelets** | matches our fail-closed "one rx direction per colour"; control-wavelet switching unprobed by us | agree + their machinery is unexplored here |

Two things in the paper bear directly on our open problems:

1. **Thermal no-op insertion.** They report the machine inserts no-ops to prevent overheating
   and calibrate around it. This is a concrete candidate mechanism for our unexplained 2×
   silicon run-to-run noise (7pt-Stencil 1076/1233/2129 on identical runs) — previously
   attributed to nothing.
2. **Their clock-sync methodology beats ours.** Broadcast-distributed reference clock, per-PE
   offset correction (i+j+2), and an α-tuned busy-wait loop, achieving start skew ≤57 cycles
   (1D) / ≤129 (2D). Our silicon cross-PE timing used the SDK bandwidth-test sync — whose hop
   correction we already showed assumes 1 cyc/hop while the fabric runs 2.

What they validate that we never have: **end-to-end runtime prediction** — 4% error on the 2D
snake at large sizes, 8–21% on broadcast, and a 3.27× win over the vendor collective from
model-driven code generation (a DP over pre-order reduction trees minimizing energy under
depth/contention bounds — the "workload-aware routing optimizer" this study previously judged
plausible, demonstrated real). Our study predicts *components* (per-link occupancy, hop
latency, instruction costs) with verified attribution, but has never synthesized them into a
runtime estimate and scored it.

Evidence: their numbers `documented` (external, WSE-2); the comparisons `silicon`/`simulator`
per the row cited.

## 10f. Runtime synthesis, tested — `simulator` + `inferred`

Open item #11 executed: the HPDC'24 form **T = max(C, E/N + 2·L, W) + k·D + c**, with every
term measured from the trace (`tools/runtime_model.py`) and k, c fitted corpus-wide
(`tools/runtime_fit.py`), scored on all 22 traced kernels against their measured spans.

| evaluation | median \|err\| | mean \|err\| |
|---|---:|---:|
| HPDC constants (k=5, c=0), no fitting | **34.7%** | 34.8% |
| fitted (k=2.07, c=17,318) | 26.4% | 65.6% |
| leave-one-out | 27.7% | 70.3% |

Headline rows: **MeshGEMM −1.8%** fitted (roof 79,835 of measured 122,770, W-dominated),
Cross-Entropy +3.4%, Prefix-Sum −1.7%, RMSNorm +5.8%, SAXPY −7.1%.

What the test established:

1. **The model form carries over to whole programs.** Their model was built for one
   collective with synchronized starts; scored here on full spans (H2D + compute + D2H) it
   still lands a 35% median with *their* constants and no fitting.
2. **The WSE-3 relay stage fits at k ≈ 2.1 cyc** vs their 2·T_R+1 = 5 on WSE-2 — suspiciously
   equal to our 2-cyc hop and 2-cyc dependent-FP recurrence. Two live hypotheses: the WSE-3
   ramp is genuinely cheaper, or our trace-inferred D over-counts by including cheap memcpy
   stream relays, diluting k. A relay microbench (open item #3 lineage) separates them.
3. **The first fit failed, and the failure was a finding.** Charging async DSD ops
   (`ut_id ≠ 255`) at elements×rate serialized the microthread overlap and overpredicted
   MeshGEMM's W by 17×. An async dispatch costs one issue cycle; its data movement belongs to
   the fabric terms. Their model has no async concept at all — on WSE-3 it must.
4. **The residual structure is the I/O phase.** The fitted c = 17,318 is a program-fixed
   stand-in for load/drain, which is why the small multi-PE kernels (Jacobi +198%,
   ParReduce +249%) blow up: their whole span is smaller than c. The next refinement is an
   explicit H2D/D2H term from the colour-classified wavelet counts (§10b) instead of a
   constant — the model's terms are per-phase, and whole programs serialize phases.
5. **W dominates the roof in every kernel** — even MeshGEMV (C=4,372 < W=5,752). On these
   workloads the fabric never sets the roof; it sets the *phases*.

D and L are `inferred` (relay DAG by latest-arrival rule; longest per-ident path). Everything
else `simulator`. Components per kernel in `results/runtime_model/`.

## 10g. The HPDC follow-ups, executed — `silicon` re-analysis, `simulator`, `inferred`

Five of the six items from §10e, run in the recommended order; the sixth is a prepared
silicon batch (§15).

### Optimality gaps (item 4) — `simulator`

Lower bound per kernel = max(busiest link wavelets, E/N + 2·L, FP floor), where the FP floor is
the busiest PE's f16 elements ÷ 4 + f32 elements ÷ 1. `bottleneck.py` now prints `%bound`.

| kernel | measured | bound | % of bound | binding |
|---|---:|---:|---:|---|
| MeshGEMV | 14,122 | 4,372 | **31.0%** | link |
| MeshGEMM | 122,770 | 28,672 | **23.4%** | compute |
| GELU-1PE | 145,990 | 25,088 | 17.2% | compute |
| … 15 corpus kernels … | | | 2–15% | |
| SAXPY-1PE / ReLU-1PE / Prefix-Sum | ~45k | 1,032–1,111 | **2.2–2.3%** | link |

The best kernel anyone has run on this fabric sits at 31% of its bound; most of our corpus is
below 15%. This is the number that replaces "arithmetic-bound / overhead-bound" as the
diagnosis: it says how far there is to go, not just which lever to pull.

### Phase model (item 1 refinement) — a null

Splitting the roof into serialized load / compute / drain roofs (colour-classified terms,
application-only relay depth) scored **26.2% median vs 26.4%** for the plain HPDC form, and
worse without an offset (37.4% vs 34.7%). The ~17k-cycle fitted offset is therefore **not**
I/O phase cost. Left as is; the offset's origin is open.

### Relay stage cost (item 3) — `simulator`, `microbench/relay/`

An N-stage store-and-forward chain (PE0 sends B wavelets; each PE receives the whole message
then re-sends; N ∈ {1,2,4,8}, B ∈ {64,512}):

> **T = 1.001 · N·B + 16.1 · N + 16.5**   — all 8 points within 4%, six within 0.6%

- **Link rate exactly 1 wavelet/cycle** (1.001) — agrees with theirs and with our silicon 4 B/cyc.
- **Per-stage overhead 16.1 cycles = the DSD setup constant of §3 (15–17).** A store-and-forward
  stage on WSE-3 costs one DSD launch, not the ~5 cycles of their element-pipelined chain — a
  different mechanism, and the reason the corpus-fitted k ≈ 2 (§10f) measures dense pipelined
  streams rather than this.
- First sweep deadlocked: the receive queues were never bound to their colours
  (`@initialize_queue(iq, .{ .color = … })`); on WSE-3 queue ids and colours are distinct.

### Sync retro-correction (item 6) — `silicon` re-analysis, and a closure

The SDK bandwidth-test sync subtracts (x+y) from each reference stamp: **1 cyc/hop assumed**.
The ledger kept every raw start/end/reference word for 2,100 silicon straight-path samples
(hops 1–128, payloads 64–4096), so the correction was redone at τ=2 (`tools/retro_sync.py`):

| direction | τ=1 (SDK) cyc/hop | τ=2 cyc/hop |
|---|---:|---:|
| east | 1.000 | **2.000** |
| south | 1.000 | **2.000** |
| north | 3.000 | **2.000** |
| west | 3.909 | 2.909 |

The τ=1 asymmetry is exactly the ±1·hops bias the sync must produce, and it is the mechanism
behind the "antisymmetric −157,696 cycles" observation in §13. **The silicon fabric runs at
2.000 cyc/hop**, matching the simulator constant independently. West is 2.0 cyc/hop up to 32
hops (medians 42/44/48/56/72/104 at 1…32) and degrades beyond — open item #4, now bounded.
The per-wavelet coefficient refits at 1.125 cyc/wavelet, identical to `noc_model.CYC_WAVE`.

### Model-driven Reduce planner (item 5) — `inferred`, `tools/reduce_dp.py`

Their five patterns (star, chain, tree, two-phase, Auto-Gen DP over pre-order trees —
reconstructed from the paper's recursion) evaluated under their constants (hop 1, k 5) and ours
(hop 2, k 2.07) for P ∈ {8..64}, B ∈ {1..4096}. **3 of 16 decisions flip** under our constants,
all in the intermediate band (P=8 B=16: auto-gen→chain; P=16 B=16: auto-gen→two-phase; P=64
B=256: two-phase→chain) — precisely where their Two-Phase/Auto-Gen live. Analytical only: no CSL
generated, nothing validated on a run; with the relay result above, the stage cost to use for
message-granular relays is 16, not 2.07 or 5.


## 10h. Pipeline shape, branches, and verification — `simulator`

### Pipelined, not single-cycle

The profiles settle this without a new experiment. The pipe trace's `stage` field takes exactly
the values 3 and 6 — decode and execute, per Cerebras — and decode→execute is **exactly 3 cycles**
for every JMP, LD16, ST16 and MOVRI (min = max = 3, §8). Yet independent instructions dispatch
**1 cycle apart** (§8): three instructions are in flight between decode and execute at any time.
That overlap is the definition of a pipeline; a single-cycle machine would have throughput equal
to 1/latency. The hazard behaviour is the classic in-order-pipeline signature: a RAW dependence on
the immediately preceding instruction stretches decode→execute to 4–5 (interlock stall), while
dependent FP still issues every 2 cycles (result forwarding, not a full round trip). Fetch and
writeback stages are not traced, so the stage count beyond "≥ 6 numbered stages" is not observable.
The DSD engine and the 8 microthreads sit beside this scalar pipeline as the streaming/vector unit.

### Branch cost (`microbench/branch/`)

Same code, three host-supplied flag patterns, every result sum verified against an int16 replay:

| outcome | cycles from `jmp` to next dispatch | n |
|---|---:|---:|
| not taken (fall-through) | **3.0** | 15,858 / 8,350 / 12,192 |
| taken | **6.0** | 7,849 / 7,843 / 4,324 |

- The 3-cycle not-taken cost equals the pipeline depth: **the fetch stream waits for the branch to
  resolve at execute — there is no speculation.** A taken branch pays 3 more for the redirect and
  refill: **6 cycles**.
- **No branch predictor.** Costs depend only on the outcome, not on history: the alternating
  pattern (`cond_alt`) pays exactly 6.0 taken / 3.0 not-taken, the same as the all-true and all-false
  patterns. Prediction would have made alternation cost more.
- The compare that sets the predicate sits 2 instructions before the `jmp` in every emitted loop
  (`ltu16.and cflag0 …`, `add16 …`, `cflag0 ? jmp`). The 9–10-cycle loop back edge measured in
  §8 decomposes as 3 (control instructions) + 6 (taken branch).
- `straight`, the unrolled 512-add baseline, ran in 0.127 cyc/add — **not** because it vectorised
  (no wide ops in its window, 180 dispatches for 8,192 nominal adds) but because the compiler
  hoisted the loop-invariant integer sum out of the timed region. Integer reassociation across a
  timer boundary: the third time this study has caught the compiler removing the work it was asked
  to time. `loop` (15.0 cyc/iter for an 8-instruction body) is the honest scalar baseline.

### Verification of the single-PE suites

Until now the suites ran on zeros and checked nothing. They now receive known inputs over H2D, read
every array back over D2H, and compare against a numpy replay of the **exact variant sequence** —
variants share arrays, so only the final state is observable and the model must reproduce the whole
program — with f16 rounding applied where the hardware rounds (once per fused FMA, once per add or
multiply, sequentially inside scalar-destination reductions). Tolerance 2 ulp for f16; copies and
integers bit-exact.

| suite | arrays | register accumulators / checksums | verdict |
|---|---|---|---|
| A copy / write / strided | **0 ulp, 100% exact** | drain −27.25; checksums −466 / −4128 / −4936, all exact | **PASS** |
| B axpy / dot / reduce | `x`, `y`, `t`, `z` **0 ulp** after 4,600+ FMA reps | axpy 293, dot 256, vdot/reduce **1148** (the f16 stagnation point), all exact | **PASS** |
| C1 GEMV / stencil | **0 ulp** | exact | **PASS** |
| C2 ew add / mul | **0 ulp** | exact | **PASS** |
| D i16 / i8 | **bit-exact** | exact | **PASS** |

Three things the verification caught that the timing alone never would have:

1. **Dead-store elimination removed four whole variants.** `copy_16 … copy_1024` were overwritten by
   `copy_4096` before anything read them, so the compiler deleted them and their TSC windows were
   empty. Every variant's result is now written to an exported sink immediately after its timed
   region, which keeps it live. (The first zero-input runs did not show this — a reminder that a
   benchmark that "ran" on zeros may not have run.)
2. **The f16 emulation is exact.** `y` after thousands of chained `FMACH` reps, `t = x·y`, GEMV and
   the stencil all match to 0 ulp — so `FMACH` is a true fused multiply-add with a single rounding,
   and the DSD ops round to nearest-even exactly as modelled.
3. **The accumulators overflowed identically.** With the first input set the sequential f16
   reductions ran to −inf on the hardware and in the model at the same point — agreement, but not a
   useful check. The inputs are now exactly-cancelling pairs with a single +0.125 offset, so every
   reduction is finite and non-trivial; they park at **1148**, where the f16 spacing (1.0) exceeds
   the increment — stagnation reproduced to the bit.
4. **Dead-store elimination survives a scalar sink.** Writing `Bb[0]` to the sink was not enough:
   the compiler forwarded `A[0]` and still deleted the copies, and shrank `copy_4096` to the 16
   elements the strided variant does not overwrite. Each copy's *whole* result is now consumed by a
   checksum reduction outside the timed region, which the model replays exactly.
5. **The TSC and the trace clock do not share an origin.** With a long H2D before `compute()`, the
   variant windows were 10k–264k cycles off the trace and landed on memcpy traffic; earlier runs
   only aligned because `compute()` started within a few hundred cycles of trace start. Coverage-
   maximising alignment picks the wrong region (memcpy is denser than the benchmark); anchoring on
   the first benchmark DSD op — an FP/i16 op with `num_data` ≥ the first variant's length, which the
   library never issues — aligns every suite. Only the first variant of each suite then shows fabric
   traffic at the PE: the tail of the H2D stream is still landing when the timed region begins.

The compute PE also executes the `<memcpy>` library's own per-wavelet handling — ~350k dispatches
outside the timed regions for suite A's 16k input and output elements. The host transfer is not free
for the application core.


## 10i. Anatomy of an add — the atomic level, from a real trace

`microbench/atomic_add/` runs five forms of `c = a + b` exactly once each and reads the result
straight off the dispatch trace, the pipe trace (stage 3 = decode, stage 6 = execute, joined by
`uid`) and the ELF disassembly (joined by PC). Every result verified against the host
(ci = 1234 + (−4321) = −3087; cf = 1.5 + (−0.25) = 1.25; all 64 elements of c = a + b in f16).
Page: `results/anatomy/add_anatomy.html`. Each form is introduced by a three-column ladder —
what it does, the C a programmer would write for it, and the CSL that was compiled — followed by
a note naming where the C form and the WSE form are *not* in correspondence. The table lives in
`tools/anatomy_common.py` (`LADDER`, 27 entries, 18 carrying a divergence note) and is shared by
all three anatomy pages so they cannot drift apart.

### Scalar add (i16 and f16 identical in shape)

| cycle | instruction | decode | execute | touches |
|---:|---|---:|---:|---|
| 0 | `ld16 r5 = [a]` | 0 | 3 | SRAM word → GPR |
| 1 | `ld16 r8 = [b]` | 1 | 4 | SRAM word → GPR |
| 2 | `add16.nf r5 = r8, r5` (or `faddh r5 = r8, r5`) | 2 | 5 | scalar ALU / FP unit |
| 3 | `st16 [c] = r5` | 3 | 6 | GPR → SRAM word |

**Four instructions, four consecutive dispatch cycles, each exactly 3 cycles from decode to
execute; first dispatch to last execute = 7 cycles.** The add executes one cycle after the second
load executes — the load result is available to the next instruction with no stall (forwarding at
the execute stage). The f16 scalar add is the same four instructions with `faddh` in register form.

### DSD add (8 / 16 / 64 elements)

| cycle | instruction | decode | execute | touches |
|---:|---|---:|---:|---|
| 0 | `lddwds dds1 = [desc]` | 0 | 3 | descriptor memory → destination DSR |
| 1 | `lds0wds s0ds1 = [desc]` | 1 | 4 | → source-0 DSR |
| 2 | `lds1wds s1ds1 = [desc]` | 2 | 5 | → source-1 DSR |
| 6 | `faddh [dds1] = [s0ds1], [s1ds1]` | 6 | 10 | address generators walk both DSRs → 8 f16 lanes → destination stream |

- **A DSD op is three DSR loads plus one instruction.** The DSRs hold base/length/stride; the
  `faddh` *is* the loop.
- **DSR load-use: a 4-cycle dispatch gap is observed** (last DSR load dispatched at 2, the op at 6) —
  a dependency identified in this capture. The later controlled sweep (§10l) varies this distance
  and compares prepared descriptors: the dispatch bubble disappears with three fillers, while
  the op's own decode→first-value interval remains 4, including in the prepared control.
- **Two different numbers, kept apart.** The op's **completion latency** — dispatch to its
  *last* stage-6 record, the only boundary at which the whole result exists — is
  2 + 2·(elements/8): **4 / 6 / 18** cycles for 8 / 16 / 64 elements. The **next instruction's
  dispatch** comes at 6 + 2·(elements/8): **8 / 10 / 22**. Two cycles per 8-element group is the
  4 elem/cyc f16 rate measured everywhere in this study. Both figures were previously reported as
  one; §13 explains why conflating them is a measurement error, and `microbench/overlap` (§10k)
  shows the occupancy reading is the right one — the machine issues nothing else while the loop
  runs.
- Total first-dispatch → last-execute: 11 / 13 / 25 cycles for 8 / 16 / 64 elements. The scalar
  path adds 8 elements in 8 × 7 = 56 dispatch-serialised cycles; the DSD path in 11.

### What the machine is, in MIPS terms

In-order, single-issue, ≥ 6 numbered stages of which decode (3) and execute (6) are traced;
fetch and writeback exist but are not observable. No branch prediction (§10h). Two operand
paths: GPRs for scalars (`ld16` / `st16`, 3-cycle depth) and DSRs for streams — a *hardware
loop* whose per-element cost is set by the lane count, not by instruction issue. The
`<memcpy>` harness and fabric are absent from all five forms: for a compute variant every byte
moved is SRAM ↔ core.

Lesson banked while building it: the marker stores meant to cut the trace were dead-store
eliminated (never read), so the cut is by instruction pattern instead.

## 10j. Anatomy of the basic ISA — 22 operations and one message, each executed once

`microbench/atomic_ops/` writes the rest of a MIPS-style basic set once each in CSL — integer
and f16 arithmetic, logic and shifts, compare/branch, a data-bounded loop, format conversion,
fill / copy / strided copy / reduction through the DSD engine, and the 8-element vector forms —
behind marker stores into an *exported* array (so they survive dead-store elimination), and reads
each form off the dispatch trace, the pipe trace (stage 3 / stage 6 by `uid`) and the disassembly
(by PC). All 22 results verified against a numpy model of the same f16/i16 arithmetic.
`microbench/relay/` at N = 1, B = 8 supplies the primitive MIPS never had: one 8-word message from
a PE to its east neighbour, both PEs and the link on one cycle axis.
Page: `results/anatomy/ops_anatomy.html` (`tools/ops_anatomy.py`). Evidence: `simulator`.

| class | CSL | core instruction(s) | decode→execute | consumer dispatch interval | next dispatch after |
|---|---|---|---:|---:|---:|
| arith | `ai - bi` | `sub16.nf` | 3 | 1 | 1 |
| arith | `ai * bi` | `imul16` | 3 | 1 | 1 |
| arith | `af * bf` | `fmulh r` | 3 | 1 | 1 |
| arith | `af*bf + af2` | `fmulh r` **then** `faddh r` — not fused | 3, 4 | 2 | 2 |
| logic | `& \| ^` | `and16` `or16` `xor16` | 3 | 1 | 1 |
| logic | `<< 3`, `>> 2` | `sll16.nf`, `sar16.nf` | 3, 4 | 1 | 1 |
| control | `if (a<b) x=11 else x=22` | `lt16.and cflag0 = …` then `!cflag0 ? imov16.nf` — predicated, **no jump** | 3 | 1 | 1 |
| control | data-bounded `while` | `eq16/ltu16.and cflag0` + `cflag0 ? jmp` | jmp has no stage-6 record | — | 3 after every jmp |
| convert | `@as(f32, f16)`, `@as(f16, f32)` | `fh2s d0 = r5`, `fs2h r5 = d0` | 3 | 1 | 1 |
| memory | fill 8 | `fmov16.nf [dds1] = r5` (register broadcast into a stream) | 3 | — | 1 |
| memory | copy 8, stride-2 copy 8 | `fmov16.nf [dds1] = [s1ds1]` — same instruction, stride in the descriptor | 3 | — | 1, 2 |
| memory | reduce 8 → scalar | `faddh r5 = r5, [s1ds1]` — DSD source, register destination | 3 | 13 (the store of the sum) | 13 |
| vector | `@fmulh` `@fmach` `@add16` ×8 | 3 DSR loads + `fmulh` / `fmach … , r5` / `add16.nf [dds1] = [s0ds1],[s1ds1]` | 4 | — | 1 |
| vector | `@fadds` ×8 (f32) | 3 DSR loads + `fadds [dds1] = [s0ds1],[s1ds1]` | 4 | — | 3 |

What the traces establish:

- **Every scalar op is one instruction with a 3-cycle decode→execute and its result stored on
  the next cycle** — including the integer multiply `imul16`, which shows no extra latency at
  this level. The f16 dependent chain shows one bubble: the `faddh` consuming the `fmulh`
  product dispatched 3 cycles later and still stalled a cycle (decode→execute 4), the 2-cycle
  dependent f16 latency of §10c seen one instruction at a time.
- **The compiler, not the ISA, sets the instruction count of an add.** The **LLVM mid-end, downstream of the
  capture boundary** (§12c), kept the marker stores in program order but hoisted the two
  operand `ld16` once and fed *seven*
  independent integer ops from them, shared the f16 product between the multiply and the
  multiply-add forms, and moved both conversions past their markers. The "4 instructions per
  add" of §10i is the cost of an isolated add; in straight-line code each further op is 1 ALU
  instruction + 1 store. Consequence for the method: marker stores pin order only for stores;
  attribution in `ops_anatomy.py` is by mnemonic, and the page shows the body as scheduled.
- **Scalar f16 multiply-add is not fused.** `fmach` exists only as a DSD instruction; the scalar
  form is `fmulh` + `faddh`.
- **Both if/else forms became predication, not branches**: a compare writes `cflag0`, a
  predicated `imov16.nf` executes only when the flag allows. No jump, no bubble, and the
  "taken" and "not-taken" cases cost the same — the compiler's answer to a core without a
  branch predictor (§10h). Real `jmp`s appear only where control depends on data the compiler
  cannot resolve (the loop bound read from memory); each shows no stage-6 record — it resolves
  at dispatch — and the next instruction dispatches 3 cycles later whether taken or not.
- **A DSD op holds the machine for its whole duration** (§10k). The 8-element forms here cannot
  show this either way: their entire loop executes in one cycle, so the next scalar instruction
  dispatching 1 cycle later is simply *after* completion. An earlier version of this section read
  that as proof of overlap; it is not, and the dedicated measurement refutes it.
  The reduction is the one form here whose completion the trace exposes through a dependent
  consumer: completion latency **17** cycles for 8 elements (elements execute 2 cycles apart),
  while the store of the sum merely *dispatched* 13 cycles in and executed at +19.
- **Fill, copy and strided copy are one instruction with different DSRs**, and a reduction is
  the same DSD mechanism with a register as destination. Fill is a register broadcast into a
  destination stream — no source DSR at all.

### Each operation in isolation — the optnone build

The `optnone` rebuild of §12 (same CSL, same IR, scheduler disabled on `compute()`, run on the
simulator, all 22 results re-verified) gives the per-form costs the −O2 body could not, because
nothing crosses a marker any more. The ISA page has a build toggle (−O2 / optnone) and the mesh
page a third scene for it. Cycles are simulator cycles; "span" is first dispatch → last execute of
the form's own instructions, "to next" the dispatch distance to the next marker.

| form | instr | span | to next | what it is |
|---|---:|---:|---:|---|
| sub / imul / and / or / xor (i16), fmulh (f16) | 4 | 7 | 4 | `ld16, ld16, op, st16` — every scalar binary op, integer or f16, multiply included |
| shl, shr | 3 | 6 | 3 | one load, shift by immediate, store |
| fma_f16 | 6 | 9 | 6 | `ld16, ld16, fmulh, ld16, faddh, st16` — not fused |
| f16↔f32 | 3 | 6 | 3 | load, `fh2s`/`fs2h`, store |
| br_taken / br_not | 6 / 7 | 11 / 15 | 8 / 13 | compare + real `cflag0 ? jmp` at O0; the not-taken path pays the extra fall-through block |
| loop2 (2 iterations) | 47 | 77 | 79 | counter on the stack (`st16 sp[..]`, `ld16 sp[..]`), 2 iterations |
| dsd_fill8 / copy8 / stride2 | 3 | 8 / 9 / 9 | 5 / 6 / 7 | 1–2 DSR loads + one `fmov16` for 8 elements |
| dsd_mulh8 / fmach8 / add16x8 / fadds8 | 4–5 | 11 | 7 / 7 / 7 / 9 | 3 DSR loads (+ scalar for fmach) + one op for 8 elements |
| dsd_reduce8 | 6 | 29 | 24 | DSR load, `faddh r = r,[s1ds1]`, store: the 8-element chain at 2 cycles/element |

Whole body: **267 cycles / 134 form instructions** isolated, against **171 cycles** at −O2 — the
optimiser's worth on this code is the shared loads, the predication, and the register-resident
loop. The isolated figures are the honest "cost of one operation" numbers: a scalar op is 4
instructions and 7 cycles from first load to stored result; an 8-element DSD op is 4 instructions
and 11 cycles; a reduction is the only form where element count shows up as latency.

### The values are in the trace too

Every stage-6 (execute) record of `hwm_pipe_trace_entry` carries the operands the datapath
used — `dest`, `src0`, `src1`, `src2` (0xFFFFFFFF = not applicable) — and a DSD instruction
emits **one such record per element**, tagged with the element index (`data`) and the SIMD lane
(`simdi`). The earlier reading of these fields as "mostly sentinel" counted decode-stage and
placeholder records; filtered to populated stage-6 records they are complete and agree value for
value with Cerebras's own decoder (`SimfabInstructionTraceCtf.get_instruction_trace_at`, e.g.
`SUB16.NF dest=5555 src0=1234 src1=61215`). What this exposes, all `simulator`:

- the numbers that moved: `ld16 → 1234`, `ld16 → −4321`, `add16.nf → −3087`, `st16 ← −3087`;
  `fmulh → 0xB600 = −0.375`; the predicated `imov16` in the taken branch has **no execute
  record** — a predicated-off instruction is squashed, not executed with a no-op result;
- the SIMD width, directly: the 8-element `fmov16`, `fmulh`, `fmach`, `add16` and `fadds` each
  produce 8 records in **one cycle**, lanes 0–7; the stride-2 copy produced lanes 0–3 in one
  cycle and 4–7 in the next (half rate through the strided address generator);
- the reduction's dependent chain, element by element: `faddh r5 = r5, [s1ds1]` records element 0
  at +3, element 1 at +5, … — 2 cycles per element, the f16 dependent latency of §10c, which is
  why an 8-element reduction takes 13 cycles to its consumer;
- the DSR loads' payload: `lddwds`/`lds*wds` record the descriptor words they install (two
  records each), so base/length/stride are readable per op.

`tools/anatomy_common.py` decodes and types these values (i16 / f16 / f32 / i32 by mnemonic;
`fh2s`/`fs2h` mixed), and all three anatomy pages now show them: a "values at X" column on every
instruction, and per-element lane tables for the DSD forms.

### On the mesh, cycle by cycle

`tools/mesh_stages.py` → `results/anatomy/mesh_stages.html` puts the same joins on the 2-D
mesh: each PE tile carries four slots (D = stage 3, two in-flight stages, X = stage 6) with the
instruction in each, a source→target line for the executing instruction (SRAM address, GPR, DSR,
fabric queue), and the wavelets travel the links at the cycles the routers recorded them,
paired across neighbours by `ident`. A cycle scrubber steps both scenes (the message below and
the ISA body above). Each executing instruction is annotated with its recorded operand values;
each wavelet with the link its record was taken on (R = the PE's own ramp, E/N/S/W = a link,
decoded from the trace's field bits — see §12b); each tile with the compiled route of the colours
crossing it (`cslc --out-routes`). What a DSR stream points at — SRAM or a fabric queue — is not
in the disassembly; it is confirmed by the compiled route where one exists (the relay's colour 6:
PE0 `R→E`, PE1 `W→R`) and labelled *inferred* otherwise. Harness PEs are drawn as context with their instructions
hidden by default (their code is not disassembled; the trace gives mnemonics only).

### One message, send to receive

| cycle | PE0 (sender) | link | PE1 (receiver) |
|---:|---|---|---|
| 360–361 | | | `lddwds`, `lds1wds` (dest = SRAM, source = **fabin** queue) |
| 365 | | | `fmov32.nf [dds1] = [s1ds1]` ×8 dispatched — **no data exists yet** |
| 370–371 | `lddwds`, `lds1wds` (dest = **fabout** queue, source = SRAM) | | waiting in the pipe |
| 375 | `fmov32.nf [dds1] = [s1ds1]` ×8 dispatched | | waiting |
| 377–381 | `st16`; completion task 20 (`ublk`) | | waiting |
| 382–389 | | 8 wavelets leave PE0's router, one per cycle (colour 6) | |
| 384–391 | | each arrives at PE1's router **2 cycles** later | receive re-dispatched at 384, executes 387 |
| 394 | | | completion task 19 runs (3 cycles after the last wavelet) |

- **A send is a DSD copy whose destination DSR names an output queue; a receive is a DSD copy
  whose source DSR names an input queue.** Neither needs a special instruction: both are
  `fmov32.nf` with `num_data = 8`.
- **Dispatch → first wavelet on the link: 7 cycles.** Then one wavelet per cycle — the 1
  wavelet/cycle link rate of the relay fit (§10g), seen directly.
- **Hop latency 2 cycles**, wavelet by wavelet, the same 2.000 cyc/hop measured on silicon
  (§10e, `retro_sync`).
- **A receive is a load whose operand is on the wire.** The receiving instruction was dispatched
  19 cycles before the first wavelet arrived and simply waited in the pipe: the trace records a
  second dispatch at the cycle the first wavelet reached the router (384) and execution 3
  cycles later. No polling instructions were issued; the stall is in place, like a blocking
  load. The completion task fires 3 cycles after the last wavelet.
- **Send dispatch → receive-complete task: 19 cycles for 8 words over one hop.** The TSC-timed
  figure for the same run, 36 cycles, includes the timer reads and the completion handshake —
  the difference is the "per-stage 16.1 cycles" of the relay fit, now itemised.

## 10k. Does independent scalar work overlap a memory-to-memory DSD op? No, for the tested configuration

`microbench/overlap` was built to settle a claim this study made and then contradicted. The
8-element DSD ops of §10j execute their whole loop in a single cycle, so "the next scalar
instruction dispatched 1 cycle later" says nothing about concurrency — consecutive dispatch on an
in-order machine is not simultaneous execution. The test needs windows long enough to tell apart.

Three functions on one PE, called separately so region boundaries need no markers:

| region | work | measured |
|---|---|---:|
| A | a 2048-element `@add16` DSD alone | completion **514** cyc |
| B | an independent 256-step register-only scalar chain alone (`acc = acc*acc + k`) | **514** cyc |
| C | both, mutually independent | **1027** cyc |

- serial prediction (A + B) = **1028**; full-overlap prediction max(A, B) = **514**
- observed C = **1027** — **99.9%** of serial, **199.8%** of full overlap
- **zero** of the chain's 256 execute records fall inside the DSD's execute window
- the PE issues **no application instruction for 511** of the DSD's 514 cycles

**Scope.** This establishes serialization for the tested configuration only: a memory-to-memory i16
`@add16` DSD on one PE, dispatched without a microthread (`ut_id` 255 in the trace). Fabric-bound DSD
copies run as microthreads — the relay's send and receive carry `ut_id` 6 — and asynchronous or
microthreaded modes were not tested; the result does not establish serialization for them.

**Verdict: serialized in the tested configuration. There is no execution overlap.** So the 6 + 2·(elements/8) figure of §10i
*is* issue-slot occupancy, as originally reported, and the "next dispatch" columns on the anatomy
pages are scheduling observations, not evidence of overlap.

Two design points that the first attempt got wrong and that matter for anyone repeating this:

- **The scalar chain must be algebraically uncollapsible.** A first version used a Horner fold,
  `acc = (acc << 1) + ia[k]`. The compiler proved that shifting an i16 left 16 times zeroes the
  earlier terms and deleted all but the last ~16 of 256 steps; the "chain" measured 4 cycles.
  A squaring recurrence cannot be folded and survives at 2.01 cyc/step.
- **The chain must not touch memory.** A dependent-load chain would contend with the DSD for the
  memory port, confounding a structural conflict with a pipeline hold. The register-only chain
  shares only the execute pipeline, which is the thing under test.

Every value was verified exactly: all 2048 elements of both DSD outputs, and both chain results
in wrapped int16. Evidence: `simulator`; tool `tools/overlap_probe.py`.

## 10l. Producer–consumer sweeps: which dependencies stall, and where the stall shows

`microbench/pcsweep` separates a dependency from a stall by controlled experiment. One program per
dependency class; each program's `compute()` holds eight marker-bracketed producer–consumer pairs.
The programs are compiled once, then rebuilt from their captured IR (`tools/cslc_ir.py`) with
function-local `optnone`, so source order survives, and with K = 0, 1, 2, 3, 4, 6, 12, 24 inline
`nop` instructions inserted between producer and consumer at the IR level. Every sequence was
verified from the disassembly to have survived compilation exactly (`k_nop` = K in every pair), every
value-producing class passed its numerical check, and every pair is measured from the trace by uid
and PC. Two chain classes that cannot be written in CSL at distance 1 under `optnone` (a load always
lands between two dependent ops) are inline Cerebras assembly, timing only. Evidence: `simulator`.

**Two stall signatures, read separately.** The *dispatch bubble* is the consumer's dispatch spacing
beyond one cycle per instruction: it could not enter the pipeline. The *execute-stage delay* is the
consumer's decode-to-value-record beyond the usual 3: it entered on time and then waited in the
execute stage. The trace makes the second visible because a delayed instruction emits one stage-6
record per cycle it waits — placeholders with sentinel operands — and the value lands in the last.
Measuring decode to the *first* record reads 3 for every instruction and hides every execute-stage
stall; an earlier version of the sweep did exactly that (§13).

| class | producer → consumer | dispatch bubble at k = 0,1,2,3… | execute-stage delay at k = 0,1,2… | reading |
|---|---|---|---|---|
| `dsr_s1last`, `dsr_s0last`, `dsr_dlast` | last descriptor load → `add16 [dds]=[s0ds],[s1ds]` | **3, 2, 1, 0**, then 0 | 1 at every k, and 1 for the prepared-DSR control | the op cannot dispatch until 4 cycles after the last descriptor load, whichever DSR that is; fillers fill the gap one-for-one. The prepared-DSR control (no loads of its own) dispatches 1 cycle after its predecessor. The DSD op's own decode→value of 4 is intrinsic, not part of the dependency |
| `gpr` | `ld16` → `add16` (distance 1) | 0 everywhere | 0 everywhere | load-use is fully covered at distance 1 |
| `i16chain_asm` | `add16` → `add16` (distance 1) | 0 | 0 | integer dependent chain: no cost |
| `f16chain_asm` | `faddh` → `faddh` (distance 1) | 0 | **1**, then 0 from k = 1 | dependent f16 latency 2: one wasted execute cycle at distance 1, none at distance 2 |
| `f16dep` | `fmulh` → (`ld16`) → `faddh` (distance 2) | 0 | 0 | consistent with the above |
| `mem` | `st16 [x]` → `ld16 [x]` | 0 everywhere | **2, 1, 0** | a load of a just-stored address gets its value late unless two instructions separate them; the stall is at the execute stage, not at dispatch, and it backs up: the instructions behind the delayed load execute 2 cycles late and the fourth one dispatches late |
| `cflag_jmp` | `lte16.and cflag0` → `cflag0 ? jmp` | 0 everywhere | 0 for taken jumps; undefined for not-taken | see below |
| `reduce` | `faddh r = r,[s1ds]` (8 elements) → `st16 r` | **12, 13, 14, 14, …** at every k | **3, 1, 0** | the DSD op holds dispatch ≈ 13–15 cycles regardless of fillers; the store's value then waits for the last element (+2) |

Three observations beyond the table:

- **A conditional jump has execute records only when taken.** Pairs whose comparison made the
  jump fall through have no stage-6 record at all; taken jumps have the usual two, at decode + 3.
  The earlier statement "a jump has no execute record" was true only of not-taken jumps. Where either
  resolves is still not observed. The instruction after a taken jump dispatched 3 cycles after it at
  k ≥ 3 and 5 cycles at k = 1; a taken pair's region is 5–6 cycles longer than a not-taken pair's.
- **Fillers dispatch inside a dependent DSD op's element gaps.** The reduction's elements execute 2
  cycles apart; with fillers present, the first `nop`s dispatched at +13, +15, +17 after the op —
  alternating with its remaining element records — and at one per cycle only once it had completed.
  So the issue slot is not held for the op's whole duration when the op's own elements leave cycles
  free. This does not contradict §10k, whose memory-to-memory `add16` produced 4–8 elements every
  cycle and left none; it bounds it: serialization is a property of the op's element rate, not of
  DSD ops as a class. Observed in one class; not yet varied.
- **The execute-stage stall backs up the in-order pipeline.** In the `mem` class at k = 0 the delayed
  load's value record lands 2 cycles late, the two instructions behind it execute 2 cycles late with
  their dispatch on time, and the fourth dispatches 2 cycles late: the front keeps dispatching until
  the pipeline is full, then stalls. A dispatch-only measurement sees the stall two instructions
  downstream of its cause.

What the sweep did not test: fabric-input dependencies (one instance is dissected in §10m),
microthreaded producers, and whether the DSR load-use bubble depends on descriptor length or on which
descriptor field changed. Tools: `microbench/pcsweep/{gen,build,run}.py`, results in
`results.json`; the PE-model page (§10m) quotes these tables next to every dependency edge they
support.

## 10m. A Cerebras PE, MIPS-style: functional datapath, dependencies, timeline

`tools/pe_model.py` → `results/anatomy/pe_model.html` follows an instruction through the PE the way a
MIPS textbook does, with one deliberate difference in scope. The trace anchors exactly two moments
per instruction — the stage-3 decode record and the stage-6 execute records (one per element for a
vector op) — plus dispatch, redispatch and wavelet records. So the page is a model of **resources and
functions** (PC/sequencer, GPR file, DSR file, descriptor memory, data SRAM, address generators,
scalar unit, SIMD lanes, condition flags, fabric queues, task activation), not of pipeline registers,
ports or forwarding networks. Fetch timing, what stages 4–5 do, operand-read timing and writeback
timing are stated as unobserved on every walkthrough. This SDK's trace has **no execute-idle
records** (event types are dispatch, pipe and wavelet only), so no bubble is ever inferred from a
missing row. Every timing statement carries one of three labels — *dependency identified*, *delay
observed*, *stall cause supported* — and the third is granted only where `microbench/pcsweep`
(§10l) varied the producer–consumer distance and the delay followed.

Per dynamic instruction the model retains PE, uid, PC, task colour, microthread id, decoded operands
(and, for streams, the fabric role from a hint that comes from the CSL source, since the encoding
does not carry it), every dispatch including redispatch, the decode record and all execute records
with element index and lane. Three linked views per walkthrough: a functional datapath with numbered
steps (the descriptor path drawn apart from the operand path — `lds1wds` loads control state and
moves no operand; the vector op then reads its data *through* the DSRs), a dynamic dependency graph
(RAW/WAR/WAW over GPR, DSR, flag, memory, stream and task resources, each edge with its dispatch
spacing and execute-to-execute gap), and a cycle timeline.

The five walkthroughs and what their traces show (all `simulator`):

| # | walkthrough | source | what the records show |
|---|---|---|---|
| 1 | scalar load, add, store | atomic_add, −O2 | four instructions, one decode and one execute record each, 3 cycles apart, dispatched one per cycle; the add executes one cycle after the second load does |
| 2 | descriptor load, then a vector op | atomic_add dsd8 | three `ld*wds` write DSRs and move no data; the op reads all three DSRs and produces 8 element records in one cycle; the next instruction dispatches 4 cycles after the op's last record, with nothing in the trace saying what fills them |
| 3a | dependent f16 pair | atomic_ops optnone `fma_f16` | `fmulh` → one load → `faddh`: the consumer's decode→execute is 3; no delay at this distance |
| 3b | 8-element reduction | atomic_ops optnone `dsd_reduce8` | one instruction, eight records 2 cycles apart (+3 … +17); the consuming store dispatches long before the last element executes |
| 4a | conditional control as a jump | atomic_ops optnone `br_taken` | compare writes `cflag0`, the jump reads it, the jump has **no execute record** (where it resolves is not observed), the next instruction dispatches 3 cycles later |
| 4b | conditional control as predication | atomic_ops −O2 `br_taken` | the same source with no jump: a flag-guarded move one dispatch after the compare; when its predicate is false it leaves no execute record — squashed, not executed as a no-op |
| 5 | fabric receive, then compute | `microbench/relay_compute` | two PEs, verified end to end (res = buf + loc exact) — see below |

**Walkthrough 5 reverses the relay's ordering and confirms its mechanism.** In `microbench/relay`
the receiver's `fmov32` was dispatched before any data existed and was redispatched 19 cycles later,
when the first wavelet reached the router. In `relay_compute` the host's RPC reached PE1 later: PE0's
send (microthread 6, eight elements in two execute-record cycles, four lanes each) put its wavelets
on PE0's ramp at +7 … +14 and on PE1's link two cycles later, and PE1's receive was not dispatched
until +48 — some forty cycles after the last wavelet arrived. The data waited in the input queue. The
receive was **still redispatched, 2 cycles after its first dispatch**: the redispatch marks the source
queue becoming non-empty, whichever side was late. It drained the queue as 4, 2 and 2 elements in
three record cycles; the completion task's first instruction dispatched in the same cycle as the last
element record (no visible activation gap, one instance); inside the task the add's three descriptor
loads preceded it by the same 4-cycle DSR load-use spacing pcsweep measured, and its eight f32
elements executed in two cycles, four lanes each, with the verified sums in their execute records
(7.75 = −2.25 + 10.0, …). The fabric copies' own execute records carry **no payload values** (they
read as 0): a message's values are visible only where it is consumed.

## 10n. Emitting LLVM IR for the backend: the gate test, and what CSL costs on sparse

`microbench/iremit` asks whether the captured-IR path is an *emission* surface or only a patch
surface, and prices the gather strategies a sparse kernel can choose between. One PE, one banded
16x16 matrix with 60 nonzeros so every row's columns are contiguous, four strategies over identical
data, every output checked against numpy. Evidence: `compiled` for what the toolchain accepted,
`simulator` for the cycles.

### The gate test passed

`@spmv_ir`'s entire body was replaced with **48 lines of hand-authored LLVM IR**: both nested loops,
the CSR indirection, the accumulator phi, the marker stores and the task activation. Only the
`define` line and its attribute group survive from the CSL stub, so the backend regenerates the task
table for a host-callable function unchanged. It compiled, linked, ran, and its output matched numpy
exactly. Against the CSL implementation of the same algorithm in the same program:

| strategy | verified | cycles | instructions |
|---|---|---:|---:|
| `spmv_scalar`, written in CSL | yes, exact | 2,172 | 1,354 |
| `spmv_ir`, body authored in LLVM IR | yes, exact | 2,172 | 1,354 |

Identical, which is the desirable result: hand-authored IR is neither better nor worse than the
frontend's for this algorithm, so the emission path costs nothing in code quality. **IR authoring is
a real target for a code generator on this SDK.**

One interface constraint had to be discovered to get there. **CSL does not name every array global
after its CSL variable.** An array the device code only reads is emitted as
`@"$$csl_base_address$$N$$val"`, while one it writes keeps `@y_ir`. Assuming the plain name fails
with `use of undefined value '@val'`. An emitter therefore needs a symbol-resolution step against
the captured module; `build.py` does this and prints the bindings.

### A silent-wrong-answer hazard in the f32 DSD reduction, isolated by a regression case

`@fadds(&acc, acc, dsd)` lowers to the right IR, `call float @llvm.sdr.fadds.rrs1(float %acc, i16 N)`,
whose semantics require the backend to put the accumulator in the same register for destination and
source-0. **Sometimes it does not**, and then nothing accumulates across the descriptor's elements
and the call returns the last product alone. In `microbench/iremit` the same program contains both
outcomes, five register-destination reductions in one ELF:

| pc | instruction | outcome |
|---|---|---|
| 0x0160 | `fadds d0 = d0, [s1ds1]` | accumulates |
| 0x02a6 | `fadds d12 = d0, [s1ds1]` | **last write wins** |
| 0x046c | `fadds d0 = d0, [s1ds1]` | accumulates |

`spmv_blk_dsdred` is kept in the tree as a **checked regression case** whose output is expected to be
wrong: it returns each row's final term (1.125, 4.0, 7.5, … against true sums 1.75, 8.75, 19.0). The
configuration that fails differs from the two that work in three ways at once, and which one is the
trigger is **not isolated**: the failing reduction has a *runtime-length* descriptor, sits *inside a
loop*, and reduces a buffer an immediately preceding `@fmuls` just wrote. The working ones are
straight-line with a compile-time length.

Two hypotheses were tested and refuted, both recorded so they are not retried:

- **Not f32 versus f16.** An f32 reduction over a fixed-length descriptor accumulates correctly
  (`probe_reduce`, 64 elements, got 472.25 against a true sum of 472.25).
- **Not a compile-time-constant accumulator.** Seeding the accumulator from host memory and seeding
  it with a literal `0.0` both accumulate (`probe_reduce`, `probe_reduce_const`, identical results).

The practical rule is therefore not a source-level one. **Disassemble any f32 DSD reduction and check
that the destination and source-0 registers match.** The danger is sharpened by the cost: the broken
form is *faster*, 18.5 cycles per nonzero against 31.8 for the correct one, because it skips the work
it was supposed to do. A silently wrong kernel that also benchmarks well is the worst failure mode
this study has found.

### What the strategies cost: the crossover a sparse code generator would key on

All four SpMV strategies now verify exactly against numpy on identical data. One PE, 16x16 banded
matrix, 60 nonzeros, 3.75 per row:

| strategy | verified | cycles | instructions | cycles/nonzero | against scalar |
|---|---|---:|---:|---:|---:|
| scalar gather, in CSL | exact | 2,172 | 1,354 | 36.20 | 1.00x |
| the same algorithm, body authored in LLVM IR | exact | 2,172 | 1,354 | 36.20 | 1.00x |
| block gather: runtime-base, runtime-length DSD per row | exact | 1,906 | 1,284 | 31.77 | **1.14x** |
| diagonal: vectorised across rows | exact | 438 | 276 | 7.30 | **4.96x** |
| *(regression case: block gather with the broken DSD reduction)* | **wrong** | 1,108 | 799 | 18.47 | — |

The result that matters for a code generator is the gap between the two transformations:

- **Per-row blocking barely pays.** Giving each row a runtime-based descriptor removes the
  element-wise gather but keeps a per-row descriptor setup and a horizontal reduction, and wins only
  14%. For rows this short the setup is most of the work.
- **Vectorising across rows pays 5x.** The diagonal form has no gather and no horizontal reduction:
  every operand is an affine run and every destination is a stream, two DSD ops per diagonal for the
  whole matrix. Its instruction profile is dominated by descriptor setup (100 `st16` of 276
  instructions), so on larger matrices the advantage grows rather than shrinks.
- **The scalar baseline is almost entirely addressing.** 288 index adds, 212 scale shifts, 212
  narrow shifts and 92 jumps for 60 nonzeros; the arithmetic is a rounding error. The scale-and-narrow
  pair appears 3.5 times per nonzero, exactly as §12c rule M5 predicts.

So the lowering rule a sparse dialect should encode is not "replace gather with a descriptor" but
**"eliminate the horizontal reduction by choosing the vectorised axis"**, with per-row blocking as a
fallback worth about 14% when the structure does not permit it.

## 10o. Route templates: 543,122 wavelet observations are 170 shapes

Building a 3-D replay of the fabric forced a question the study had not asked:
how much *distinct* routing does a WaferLLM kernel actually perform?

Group every `wavelet_trace_entry` by `ident`, order by cycle, drop repeat
observations at one PE, and keep only chains whose consecutive PEs are cardinally
adjacent. Define a **route shape** as the pair (sequence of PE coordinates,
per-hop cycle offsets relative to the first observation). Then:

| kernel | wavelet obs. | packets (idents) | route shapes |
|---|---:|---:|---:|
| MeshGEMM, whole run | 543,122 | 197,909 | 170 |
| MeshGEMM, 70,000-82,000 | 61,440 | 24,576 | 40 |
| MeshGEMV, whole run | 72,960 | 21,271 | 90 |
| atomic_ops, 1 app PE | 3,021 | 1,345 | 87 |
| relay N=1 B=8 | 261 | 81 | 11 |

`simulator`, except the pairing rule, which is `inferred`. Of MeshGEMM's 197,909
idents, 348 were observed at one PE only and form no chain; they are excluded
from the shape count and from the replay.

A 122,741-cycle kernel reuses 170 routes. That is the compiled routing tables
showing through: the colours and their per-PE rx/tx sets are fixed before the
program runs, so the software loop can only replay paths the compiler already
laid down. It also means a packet is losslessly three integers -- shape id,
launch cycle, colour -- which is what makes a browser-side replay of the full
trace possible at all.

### The per-hop delay is 2 cycles, and it is flat

Counting cycle intervals between consecutive hops **within** a route shape:

| scene | intervals | exactly 2 cycles |
|---|---:|---:|
| MeshGEMM, steady-state window | 60 | 60 |
| MeshGEMV, whole run | 235 | 209 |

Instance-weighted the result is sharper still: of the 1,104 hops falling inside a
24-layer stack over the MeshGEMM window, **1,104 have an interval of exactly 2**.

`simulator`. The MeshGEMV residue is 3, 5, 13-20 cycles and sits on shapes that
begin or end at a PE which was also dispatching, i.e. injection and drain, not
transit. No shape shows a transit hop slower than 2 cycles, in either kernel,
including during the 20,480-wavelet broadcast bursts. Router congestion, if it
exists in these kernels, is not visible as hop latency.

### A stretch of compute with no fabric traffic

The MeshGEMM steady state is not uniformly busy. Binning the whole run at 2,000
cycles shows cycles 80,000-81,999 with 18,175 dispatches, 4,096 `FMACH`, and
**zero** wavelet observations; 114,000-115,999 is the same shape. Meanwhile
cycles 36,000-59,999 are the mirror image: ~5,680 dispatches per bin across only
5 PEs, no `FMACH` at all, which is the memcpy runtime and not the kernel.

Neither is visible in a whole-run average, and both matter for the compilation
model: the first says the kernel is compute-bound in its inner phase, the second
says a quarter of the wall clock is runtime plumbing.

### The issue ceiling, confirmed across the whole corpus

Binning dispatches per PE at a stride chosen per scene (1 to 16 cycles) gives an
independent check on the 1-instruction-per-cycle issue rate the ILP microbench
established. In all six trellis scenes the maximum count in any (PE, bin) pair is
**exactly the bin width, and never more**:

| scene | bin width | max dispatches in one bin |
|---|---:|---:|
| relay, relay_compute | 1 | 1 |
| MeshGEMV, MeshGEMM window | 2 | 2 |
| atomic_ops | 3 | 3 |
| MeshGEMM whole run | 16 | 16 |

`simulator`. The ceiling is reached in every trace, so it binds rather than being
a limit nothing approaches. Within the MeshGEMM steady-state window the rate is
not pinned there: over 6,001 two-cycle bins across 16 application PEs, 38.9% issue
two instructions, 46.8% issue one and 14.3% issue none. Per-PE fine-bin totals sum
to the scene's dispatch count exactly (119,668), which is how the encoding is
checked.

## 10p. Cross-workload datapath reverse engineering — `simulator`

`tools/datapath_xwl.py` measures the *same opcodes* in deliberately different
company, because a single workload cannot separate a functional unit's intrinsic
latency from stalls the surrounding code imposes. Eight traces, four classes:

| class | traces | busiest PE |
|---|---|---|
| GEMM | MeshGEMV, MeshGEMM (cycles 70,000-82,000) | (4,4), (4,3) |
| add | atomic_add, atomic_ops | (4,1) |
| read/write | pcsweep mem, pcsweep gpr | (4,1) |
| elementwise | GELU-1PE, Dot-Product-1PE | (4,1) |

### What the pipe trace actually contains

Each instruction emits **one stage-3 record per element** as the front end feeds
it, and at stage 6 both an instruction-level placeholder (`simdi` = 255, all
operands sentinel) and **one record per lane** carrying real operand values with
`data` = element index. Earlier work read the raw record count; the lane records
are the timing-bearing ones. An `IMOV32.NF` over 8 elements shows stage-3 at 8
consecutive cycles and lane records at 8 consecutive cycles, each exactly 3 later.

### The SIMD datapath is 128 bits wide, and the lanes are directly visible

One `ADD16.NF` over 8 elements retires **all 8 lanes in a single cycle**, each
with independent `dest`/`src0`/`src1`. Read as 16-bit two's complement, every
lane verifies: lane 0 computes -100 + 60 = -40, lane 3 computes 11 + 21 = 32,
lane 7 computes 159 + (-31) = 128. This is measured arithmetic, not inference.

| operand width | lanes per cycle | evidence |
|---|---:|---|
| 16-bit | **8** | `ADD16.NF` at 2,048 elements sustains 8/cycle; `FMACH` at 16 elements is 8 lanes x 2 cycles; `FMOV16.NF`, `FMULH` |
| 32-bit | **4** | `FADDS` and `FMOV32.NF` at 14, 15 and 16 elements retire 4/cycle |

8 x 16 = 4 x 32 = **128 bits**, consistent across both element types. This also
explains WaferLLM's `FMACH` always carrying exactly 16 elements (§ earlier): 16 is
two passes of the hardware width, not a hardware maximum.

### Latency is a unit property: 37 of 40 opcodes are invariant across workloads

Minimum decode-to-first-execute over many instances is the unstalled latency. Of
40 opcodes appearing in three or more of the eight workloads, **37 have the same
minimum in every one**, pooled over 288 (opcode, workload) pairs of which 276 sit
at exactly 3.

| unit | lanes | latency | instances | opcodes |
|---|---:|---:|---:|---|
| scalar ALU, branch, load, store | 1 | **3** | 90,374 | `MOVRI` `LD16` `ST16` `JMP` `NOP` `LT16` `EQ16` `AND16/32` `LD16RP` `ADDSP` `SLL16.NF` … |
| int16 SIMD | 8 | **3** | 2,823 | `ADD16.NF` |
| f16 SIMD move | 8 | **3** | 1,685 | `FMOV16.NF` |
| f16 fused multiply-add | 8 | **4** | 1,457 | `FMACH` |
| f32 SIMD | 4 | **4** | 6,145 | `FADDS`, `FMOV32.NF` |
| 16-bit move | 1 | **6** | 858 | `IMOV16.NF` |

`FMACH` is 4 in all three workloads it appears in, by both minimum and median.
`IMOV16.NF` is median 6 in all seven, and why a 16-bit move costs twice a 32-bit
one is **not explained**; a fabric-queue source is a candidate and is untested.
The three opcodes whose minimum is not invariant are `FADDS` (median 4 in all
three, but minimum 3 in GELU's 5,632 instances against 4 elsewhere), `SAR16.NF`
(n = 1 at 4 in atomic_ops, 3 in three other workloads) and `IMOV16.NF`.

### Dependent element chains collapse the lanes

Width is only reached when elements are independent. A `FADDH` accumulation shows
`src0` of element k equal to `dest` of element k-1 -- the recurrence is visible in
the operands -- and runs **one element per 2 cycles on one lane**, matching the
dependent f16 add latency of 2 from the §10l sweep. `FADDS` over 64 elements in
an accumulation likewise uses one lane, where the same opcode over 16 independent
elements uses four. The f32 DSD reduction hazard (§10n) sits in exactly this
regime.

### Microthreads break uid pairing, and had to be excluded

`IMOV16.NF` and `IMOV32.NF` issue on microthread 0 in six of the eight traces
(1,401 instances in the MeshGEMM window alone). These overlap the main thread, so
`uid` no longer identifies one in-flight instruction and naive pairing yields
impossible latencies including 0. All latency figures above are main-thread only
(`ut_id` = 255); microthreaded counts are reported separately per workload.

### What remains unobserved

Stages 4 and 5 emit nothing, so operand-read and writeback timing are still
unknown, as are register-file port counts and any forwarding network. Nothing
here is `silicon`.

## 10q. Auditing the wavelet pairing rule, and a refuted claim — `simulator`

`ARCHITECTURE_MODEL_PLAN.md` names three risks the mesh viewers must not paper
over: multicast needs branching paths; packet identities apply only within their
capture and active relays mint new ones; and equal numbers cannot establish
lineage. `tools/wavelet_lineage_audit.py` measures what the viewers' pairing rule
(same `ident`, cardinally adjacent, cycle-ordered) costs against the first and
third of those.

Three failure modes are possible and each is tested per identity. **Branching**:
some PE has two or more cardinal successors, so a multicast tree would be drawn as
one arbitrary strand. **Ambiguity**: a step has more than one equally recent
cardinal predecessor, making the join a coin flip. **Non-adjacency**: a
consecutive pair is not adjacent at all, so the chain is fiction.

| capture | identities | simple path | branching | ambiguous | non-adjacent | seen once | shared origin |
|---|---:|---:|---:|---:|---:|---:|---:|
| relay | 81 | 67 | 0 | 0 | 0 | 14 | 0 |
| relay_compute | 345 | 290 | 0 | 0 | 0 | 55 | 0 |
| single_pe | 1,345 | 1,126 | 0 | 0 | 0 | 219 | 0 |
| meshgemv | 21,271 | 20,979 | 0 | 0 | 0 | 292 | 0 |
| meshgemm_full | 197,909 | 197,561 | 0 | 0 | 0 | 348 | 0 |

**None of the three failure modes occurs anywhere.** Across 220,951 identities in
five captures, every multi-observation packet forms a simple cardinal path and no
step has a competing predecessor, so the pairing rule has a unique solution rather
than a chosen one. 928 identities (0.4%) are observed exactly
once and form no path; they are dropped by the viewers and now counted on the page
rather than silently discarded.

### These kernels do not multicast, and the "broadcast tree" description was wrong

A multicast implemented by replicating a packet would show several identities
originating at one PE in one cycle. There are **zero** such cases in any capture,
and zero cases of identities sharing an origin then diverging. MeshGEMV's apparent
fan is thousands of independent point-to-point packets issued at different cycles
over the same compiled routes; one route shape alone carries 8,118 of them.

The earlier mesh pages described this as "broadcast trees fan the vector across
rows". That is **withdrawn**: no evidence in the corpus supports packet
replication, and the viewers and their walkthroughs were corrected. What the
audit cannot decide is whether the routers replicate below the trace's
granularity and the simulator assigns each replica its own identity; that would be
invisible here, and the plan's warning about relays minting identities applies.
Separately, 249 pairs of MeshGEMV packets carry the same payload word in the same
cycle under different identities — equal values, which are not lineage.

### Other corrections made under the plan's cautions

* "occupancy" was replaced by "dispatches" in the trellis colour control, and the
  page now states that a dispatch count is not utilisation and a router
  observation is not a memory write.
* The datapath page now says "decode" and "execute" are the *simulator's* labels
  for its stages 3 and 6, naming where a record appears rather than a verified
  physical stage, and that a lane count counts records retiring together rather
  than proving physically distinct adders.
* Both pages now state that cycles are the simulator trace clock, a separate clock
  domain from host time.

## 10r. Which matmul traversal a PE wants, and why — `simulator`

**2026-09-22 follow-up:** the tables below preserve the original measurements.
The [controlled matmul comparison](MATMUL_COMPARISON.md) corrects the reduction
implementation and adds packed blocking. It demonstrates correct vector dot
products and a correct tiled `@map` implementation; neither was ruled out by
the earlier failures. Rankings apply to the tested single-PE implementations.

### FMACH is a fused axpy, not a dot product

Reading operand values out of the stage-6 lane records of MeshGEMV's `FMACH`
instructions (2,816 lane records over 176 instructions) gives the operation
exactly. `src2` takes a single value per instruction, identical across all eight
lanes — a broadcast scalar — and the arithmetic resolves as

    dest = src0 + src1 * src2

Of the 2,816 records, 2,651 cannot distinguish a fused from an unfused
multiply-add. Of the **165 that can, 100% match a single rounding and 0% match
two**. So FMACH is a true fused multiply-add, and the hardware's FMA shape is an
**axpy**: a vector plus a vector times a broadcast scalar. `simulator`.

This operand shape favors updating an **output** vector with a broadcast
scalar. A unit-stride vector FMACH uses all eight f16 lanes in these captures.
The tested dot-product implementation instead multiplies a vector and reduces
its products; the dependent f16 accumulation was measured at one element per
two cycles on one lane. These observations explain the implementations tested
here; they do not establish a limit on every possible ISA formulation.

### All six orders measured, plus the idiom that beats them

`microbench/matmulorder`: C = A·B, 32x32x32 f16, 32,768 MACs per variant on one
PE, every variant's result checked against a host reference.

| variant | innermost | cycles | MAC/cycle | vs best | result |
|---|---|---:|---:|---:|---|
| `ikj` + @map idiom | output row | 10,239 | 3.20 | 1.0x | ok |
| `ikj` | output row | 45,327 | 0.72 | 4.43x | ok |
| `kij` | output row | 45,352 | 0.72 | 4.43x | ok |
| `kji` | output col | 103,849 | 0.32 | 10.14x | ok |
| `jki` | output col | 104,844 | 0.31 | 10.24x | ok |
| `ijk` | K (dot) | 108,586 | -- | -- | **WRONG** |
| `jik` | K (dot) | 111,496 | -- | -- | **WRONG** |
| `ijk` scalar | K (dot) | 867,560 | 0.04 | 84.73x | ok |

Three results, in order of how much they matter:

1. **The idiom beats the traversal.** `ikj` and `ikj_map` are the *same* loop
   order; the second loads its descriptors once per output row and lets `@map`
   supply the scalars, instead of recomputing two DSD offsets every inner
   iteration. That alone is **4.43x**. Naive `ikj` spends about 44 cycles per
   inner iteration of which roughly 4 are the FMACH.
2. **Among axpy forms, stride costs 2.3x.** Output-row-innermost (unit stride)
   beats output-column-innermost (stride 32 f16 = 64 B, which lands every access
   in one SRAM bank) by 2.29-2.31x.
3. **The original scalar dot implementation is about 85x slower.** It reaches
   0.04 MAC/cycle against 3.20 for the best form. The original vector versions
   fail because their scalar source does not feed back the destination. The
   follow-up's correct zero-stride DSD reductions take 177,322 cycles (`ijk`)
   or 145,801 cycles with B transposed, substantially faster than the scalar
   loop but still slower than the tested row updates.

Best measured is 3.20 MAC/cycle against the 8 MAC/cycle the 8-lane f16 path
allows, so even the winning form runs at 40% of the SIMD ceiling. Per-row DSR
loads and `@map` control contribute overhead; this ratio alone does not attribute
every remaining cycle. WaferLLM's MeshGEMV uses exactly
the `ikj_map` shape, which this now explains rather than merely describes.

### The original reduction overwrites its destination

`ijk` and `jik` fail their value check, and the failure is characterised exactly:
they return `A[i,K-1]*B[K-1,j]`, with **max error 0.000000** against that
hypothesis. The disassembly shows the mechanism, the same one recorded in §10n
for f32:

    faddh r15 = r5, [s1ds1]        # dest != src0, so nothing accumulates

Here `r5` supplies the same initial zero for every element, while `r15` is
overwritten. A pointer destination alone does not make the scalar source feed
back the running sum. The 2026-09-22 experiment uses the same zero-stride
memory DSD for destination and source 0 of `@faddh`. All 4x4, 8x8 and 32x32
outputs then pass; simulator S6 records at the small sizes confirm the
element-by-element accumulation. This isolates the matmul failure to the
original operand formulation, rather than establishing a compiler reduction
bug or a restriction caused by a preceding multiply. It does not independently
retest the separate f32 example in §10n.

The old formulation remains as `ijk_bad` in the new comparison. Its failure
is intentional, and it is excluded from performance rankings.

### 10r-bis. Stride, descriptor setup and packing affect traversal cost

Extending `microbench/matmulorder` to ten variants covering all three textbook
families plus tiling, a transposed-B control and the `@map` idiom:

| variant | textbook family | operand stride | cycles | lanes | vs best | value check |
|---|---|---|---:|---:|---:|---|
| `ikj_map` | axpy | all unit | 10,239 | 8 | 1.00x | ok |
| `ikj` | axpy | all unit | 45,327 | 8 | 4.43x | ok |
| `kij` | outer product | all unit | 45,352 | 8 | 4.43x | ok |
| `ijk_bt` | inner product | all unit (B transposed) | 75,021 | 8 | -- | **wrong** |
| `kji` | outer product | stride 32 | 103,849 | 1 | 10.14x | ok |
| `jki` | axpy | stride 32 | 104,844 | 1 | 10.24x | ok |
| `ijk` | inner product | B col stride 32 | 108,586 | 1 | -- | **wrong** |
| `jik` | inner product | B col stride 32 | 111,496 | 1 | -- | **wrong** |
| `ikj_map_blk` | axpy, tiled | all unit, len 8 | 158,988 | 8 | 15.53x | ok |
| `ijk_scalar` | inner product | scalar regs | 868,586 | 1 | 84.83x | ok |

**The classical grouping alone does not predict these timings.** `ikj` is an
axpy and `kij` is an outer product and they differ by 0.06%; `ikj` and `jki` are
both axpy forms and differ by 2.31x. The innermost loop determines vector stride
in these implementations. Descriptor setup and physical packing also matter,
as the two row-update forms and the later packed-tile control demonstrate.

**The stride mechanism, tested rather than asserted.** `ijk_bt` differs from `ijk`
only in reading B from a pre-transposed copy so both operands are unit stride.
Same opcode, same 32 elements, same nest. The multiply goes from **1 lane over 32
cycles to 8 lanes over 4**, and the variant gets 1.45x faster. Across all ten
variants the rule separates perfectly: every all-unit-stride operation runs 8
elements per cycle, every operation with any strided operand runs 1. Layout fixes
the lanes; it does not fix the reduction, and `ijk_bt` still returns wrong values.

**The original blocked implementation costs 15.5x; this is not a general tiling
penalty.** Each 8-wide tile still gets all eight lanes, but this implementation
rebuilds descriptors inside the k loop. Applying the full-row streaming idiom
directly to that row-major layout walks the wrong elements because the stream
advances by the tile width rather than the row pitch.

The follow-up packs B as `[j_tile][k][j_inside_tile]`, making each tile's k
traversal contiguous. This correct tiled `@map` implementation takes **17,550
cycles**, versus **158,988** for descriptor-reloading blocking and **10,239**
for full-row `@map`. Packing improves this blocked case by 9.06x, although it
remains 1.71x slower than the full-row kernel. Host packing and its additional
buffer are outside these kernel timings. Tiling can also manage SRAM capacity
and inter-PE communication; those benefits require larger or distributed
experiments and cannot be settled by this single-PE case.

### 10r-ter. Cross-machine check against the CPU/GPU account — `simulator`

The seven-traversal walkthrough at artifact `A7Zvd8JtB62NfzebTENCGr` covers the same
formulations for CPUs and GPUs. Its taxonomy matches §10r-bis; its central thesis is
that **the outer product is the real inner loop**, because a T_M x T_N block of
register accumulators yields T_M*T_N/(T_M+T_N) FMAs per element loaded: 0.5 at 1x1,
4 at 8x8, 8 at 16x16.

That thesis does not transfer, and the trace says why. **The accumulator cannot stay
in a register on WSE-3.** FMACH's destination is a vector descriptor and a vector
destination is memory, so C is read back and rewritten every k step. Verified on
`ikj_map`: `src0` of each step equals the previous step's `dest` for the same
element, 20 of 20.

| register tile | source | MACs per element loaded |
|---|---|---:|
| 1 x 1 | their naive inner-product kernel | 0.50 |
| 8 x 8 | their GEMM micro-kernel | 4.00 |
| 16 x 16 | a tensor-core MMA step | 8.00 |
| 1 x 32, **not resident** | WSE-3, the winning form measured here | **0.49** |

The fastest formulation on this machine has the arithmetic intensity their page
assigns to the naive one. The single scalar port caps the tile at 1 x N; the memory
destination stops even that being resident. This is the ceiling behind the measured
3.20 MAC/cycle against an 8-lane peak of 8.

**The forced trade-off:** the only variant that keeps its accumulator in a register
is `ijk_scalar`, which declares a scalar `acc` -- and it cannot use the lanes, so it
is 85x slower. On WSE-3 you can have the eight lanes or a resident accumulator, not
both.

Where the two accounts agree: row AXPY as the loop-interchange win and the
stride-1 argument (confirmed, and it is what buys the 8 lanes); column AXPY as
strided under row-major (confirmed, 2.3x and 8 lanes to 1); tiling as orthogonal
recursion rather than a form (agreed, though here it costs 15.5x); and bit-identical
results across the plain orders (true of the four correct ones). Where they diverge:
the three-family taxonomy predicts nothing here, and the outer product is not the
inner loop because there is no register tier to tile into.

Their note that Gustavson's sparse algorithm is the row-wise form matches §10n's
finding that vectorising across the output rather than reducing along it was worth
about 5x on SpMV.

### 10r-quater. Repairing the failed variants, and tiling the outer product

Three inner-product variants returned wrong values, leaving that family without an
honest vector measurement. `ijk_tree` supplies one: the miscompiling
`@faddh(&acc, acc, dsd)` is replaced by a five-level tree of **elementwise** vector
adds (32 -> 16 -> 8 -> 4 -> 2 -> 1), every step lane-parallel and none of them a
horizontal reduction. It is correct, and at 76,075 cycles it is **faster than the
108,586 of the broken variant it replaces**, because it reads B transposed and so
keeps 8 lanes on the multiply. The claim that the broken form is faster (§10n, from
SpMV) does not generalise.

The outer product then gets the tiling its GPU reputation rests on: four rows of C
held as a tile, k walked once, each B row feeding 4 x 32 MACs instead of 32. Three
spellings of the identical tile:

| spelling | cycles | instructions per FMA | limiter |
|---|---:|---:|---|
| naive index arithmetic | 41,173 | 26.6 | the four C descriptors spill every iteration (56 stores around 4 FMACHs) |
| running offsets, no multiplies | 38,377 | -- | barely helps; this is how spilling was identified |
| descriptors pinned in DSRs | **19,019** | -- | nothing spills; one B load feeds four FMACHs |

**Pinning descriptors is worth 2.2x.** A CSL `var` holding a descriptor is not a
descriptor register, and four live ones in a loop exceed what the compiler keeps in
place. This is a general hazard for tiled kernels on this machine.

**Can the tiled outer product beat its inner-product rival?** Yes: 19,019 against
76,075, a factor of **4.0**, and 45.7x against the scalar inner product. But it
loses to the *untiled* outer product with hoisted descriptors by 1.9x. Tiling buys
nothing here that hoisting does not buy more cheaply, because the reuse a tile
captures needs a register tier this machine lacks.

**The outer product is now the overall winner.** `kij_map` at 10,079 cycles edges
`ikj_map` at 10,239 by 1.6%. The mechanism is not what was predicted: both issue
FMACHs at an identical 9-cycle cadence (mode 992 of 1024 in each), so the
read-after-write dependency on `ikj_map`'s accumulator row costs nothing. The margin
is 155 fewer bookkeeping instructions in the outer loop.

Full ranking, 32x32x32 f16, 32,768 MACs each:

| variant | cycles | MAC/cycle | vs best | value check |
|---|---:|---:|---:|---|
| `kij_map` | 10,079 | 3.251 | 1.00x | ok |
| `ikj_map` | 10,239 | 3.2 | 1.02x | ok |
| `outer_tile4c` | 19,019 | 1.723 | 1.89x | ok |
| `outer_tile4b` | 38,377 | 0.854 | 3.81x | ok |
| `outer_tile4` | 41,173 | 0.796 | 4.09x | ok |
| `kij` | 45,321 | 0.723 | 4.50x | ok |
| `ikj` | 45,361 | 0.722 | 4.50x | ok |
| `ijk_tree` | 76,075 | 0.431 | 7.55x | ok |
| `ijk_bt` | 75,021 | -- | -- | **wrong** |
| `kji` | 103,849 | 0.316 | 10.30x | ok |
| `jki` | 104,843 | 0.313 | 10.40x | ok |
| `ijk` | 108,586 | -- | -- | **wrong** |
| `jik` | 111,496 | -- | -- | **wrong** |
| `ikj_map_blk` | 159,051 | 0.206 | 15.78x | ok |
| `ijk_scalar` | 868,586 | 0.038 | 86.18x | ok |

Verification footprint was reduced to fit 15 variants in 48 KiB: the first 4 rows of
C verbatim (4 is also the tile height) plus all 32 row sums, checked against a host
reference. All 15 phases were located in the trace and agree with the on-device
cycle counter to within 0.69%.

## 10s. GEMM dataflow on the wafer: documented, compiled and measured

Sources: Sean Lie, *Cerebras Architecture Deep Dive*, Hot Chips 34 (2022), cached at
`external/hc34/hc2022_cerebras.pdf` (`documented`, **WSE-2**); WaferLLM kernel and host
source (`source-derived`); compiled route tables (`compiled`); traces (`simulator`).

### What HC2022 documents about one PE (WSE-2)

* 48 kB SRAM, 8 banks of 6 kB, 32 b wide, single-ported; **2 full reads + 1 full write per
  cycle** into the datapath. A 256 B software-managed cache "used for high frequency access
  data such as accumulators" (slide 9).
* 64 b datapath with **4** FP16 FMACs; tensors are first-class operands, e.g.
  `fmach [fpsum] = [fpsum], [fwd_wgt], r_in`; 44 DSRs, 16 GPRs; "compact **6-stage**
  pipeline" (slide 11).
* 5-port router, 32 b packets of 16 b data + 16 b index, 24 static colours, hardware
  broadcast/multicast (slide 17).

The eight observed 16-bit SIMD lanes agree with the WSE-3 core diagram in HC2024
(p. 29). Width alone does not establish sustained throughput. WSE-2's six-stage
pipeline does not assign physical meanings to WSE-3 simulator stage numbers 3 and 6.
HC2024 documents 48 DSRs, 16 GPRs and a 512 B local cache for WSE-3; a 16-entry
operand-specific DSR allocation file is not the total DSR count. SRAM-backed
accumulator operands do not reveal whether a particular access uses the local cache.
The WSE-2 bank counts and access bandwidth above must not be treated as a measured
WSE-3 memory service model. See [the generation-aware dataflow review](GEMM_HARDWARE_DATAFLOW.md).

### What HC2022 documents about GEMM across PEs (weight-streaming mode)

Activations are sliced across the whole wafer and stay in PE SRAM. Weights live off-wafer
in MemoryX, are streamed in one layer at a time, broadcast as a row "over columns of
cores", without allocating a full local weight array, and each arriving weight triggers FMACs against the local activation
column. Zero weights are never streamed. Partial sums are reduced "over rows of cores in a
ring" on PSUM commands, and an FSUM command steers final sums to their owning column,
overlapped with the next weights (slides 20-25). Transient queues and operand storage
are compatible with this description; “never stored” must not be read as an absence
of every temporary hardware holding location.

### What WaferLLM actually does (measured, WSE-3 SDK)

**MeshGEMM is output-stationary Cannon on a folded ring.** From the source: each PE keeps
its C block for all P steps; X tiles shift along rows and W tiles along columns, double-
buffered, one tile per step; `assignId` folds the ring into a line so every link is at most
**2 hops** for any P, instead of a torus wraparound. `tools/meshgemm_sim.py` ports the host
placement and ring verbatim and computes C = X.W **exactly** for every P from 3 to 12 (P = 2
is not a valid ring, matching the kernel's P >= 3 assertion). For P = 4 the ring is
0 -> 2 -> 3 -> 1 -> 0, two 1-hop and two 2-hop links, which predicts equal 1-hop and 2-hop
traffic. Measured over cycles 70,000-82,000:

| traffic | packets | axis |
|---|---:|---|
| X shift, colours 1-3 | 10,240 | east/west only |
| W shift, colours 4-6 | 10,240 | north/south only |
| of which 1-hop / 2-hop | 5,120 / 5,120 | as predicted |
| X initial skew, colours 7-9, 12, 13, 16 | 4,096 | east/west |
| anything carrying C | **0** | -- |

No packet is observed at more than 3 PEs, and no kernel colour both delivers and forwards:
MeshGEMM does not multicast and does not reduce.

**MeshGEMV is weight-stationary with a column allreduce.** Each PE multiplies its stationary
W tile by its x slice (x supplies the broadcast scalars), then partial results are reduced
down each column in two stages and the result is multicast back up. Recovered from packet
origins, in cycle order: stage 1 (colour 6) rows 0->1 and 2->3; stage 2 (colour 15) row
1->3 through 2; broadcast (colour 9) row 3->2->1->0, **every one of 352 packets observed at
all four PEs**. The source configures colour 9 as `rx SOUTH -> tx RAMP, NORTH`, "for
directly broadcast in y-axis".

### Inner or outer product? Both, at different levels

All three dataflows run an **outer product inside each PE** and an **inner product across
PEs**, the same split cuBLAS uses (inner product between tiles, outer product within one).
The per-PE half is forced by the FMA: one scalar port and two vector ports leave no way to
issue a dot product.

Measured for MeshGEMM on four PEs over cycles 70,000-72,000
(`tools/meshgemm_outer_runs.py`): every complete run is **exactly 16 consecutive FMACHs
sharing one vector operand** while the broadcast scalar changes. Each run is one rank-1
update C += X[:,k] (x) W[k,:] of the 16x16 C tile. (Two runs on one PE show 15 distinct
scalars instead of 16 because two random W values coincide; run length is 16 throughout.)

Across PEs the k-sum differs. MeshGEMM performs it **in time**: the C block stays and each
Cannon step adds one k-block term, so nothing is reduced. MeshGEMV and the Hot Chips design
perform it **in space**: K is split across PEs (down a column, or along a row) and partial
sums are reduced.

MeshGEMM's per-PE order is k -> n -> m, i.e. `kji`, which was slow in §10r (103,849 cycles).
It is fast here because the C tile is stored column-major and X k-major, so the innermost
walk is unit stride and keeps all 8 lanes. Same traversal, different layout.

### Correction to §10q

§10q concluded "these kernels do not multicast" from an audit of packet identities. That
audit can only see *tree* replication. A **line** multicast, where each PE delivers and
forwards, keeps one identity and a simple path, and is invisible to it. The compiled routes
show 41 deliver-and-forward entries in MeshGEMV (colour 9 is the kernel's) and 33 in
MeshGEMM (all on memcpy colours 22/23). Corrected statement: **MeshGEMV multicasts its
result; MeshGEMM's kernel does not.**

### Correction to §10r-ter

§10r-ter called WSE-3's low arithmetic intensity "the real ceiling" behind 3.20 MAC/cycle.
The WSE-2 memory diagram cannot by itself establish the WSE-3 bottleneck. Our
stronger evidence is the observed instruction cadence: FMACHs issue every 9 cycles
while arithmetic spans 4 (§10r-quater). That supports investigating issue/setup gaps
in this capture, without proving the cause of every gap or a universal memory ceiling.
The intensity comparison with a GPU register tile stands as a description; its causal
claim is withdrawn. Local cache residency remains unobserved.


### 10s-bis. End-to-end lifecycle, host to host (simulator, 2026-09-23)

Tools: `meshgemm_lifecycle.py`, `meshgemv_lifecycle.py`, `io_paths.py` → `results/datapath/*_lifecycle.json`.
Classification is by fabric region, not colour: memcpy reuses colours in the support columns.

- **I/O is one channel on each edge** (`--channels 1`). Everything enters at the west halo
  (0,1), crosses to (1,1), runs down support column x = 2, and turns east into each kernel row.
  Every row stream passes all four PEs, and PE px keeps packets px, px+4, … Host streams carry
  **1 value per 32-bit packet**.
  - MeshGEMM: 8,204 entry packets, 2,048 values per row, cycles 180–8,955.
  - MeshGEMV: 4,364 entry packets, 1,088 values per row.
  - X/W tiles as received equal the tiles computed on: 16/16 for each tensor in both kernels.
- **Output** leaves each kernel PE eastward into support column x = 8, runs down to row 4, and
  exits at the east halo (10,4).
  - MeshGEMM: each PE sends 256 data + 256 control packets. The control packets end before the
    edge, so exactly 4,096 C values leave. Those values are all of C and nothing else.
  - MeshGEMV exit: 336 packets = 256 y values + 80 timing words (3 + 2 per PE).
- **MeshGEMM skew = 2 transfers per PE, 2 f16 per packet** (@mov16), 4,096 packets.
  - First transfer: own tile 16/16. Second transfer: the predicted tile 16/16.
  - Rows 0 and 2 go backward, 1 and 3 forward. Rows keep rotations 0, 1, 1, 2.
  - Step transfers are 128 packets each; X 64/64 and W 64/64 carry exactly the tile computed on.
- **The run is I/O-bound at this size:** streaming C out (41,978 cycles) takes 5.5× the
  skew + multiply (7,614 cycles). Input takes 8,775 cycles.
- The FMACH chain recomputed in JavaScript (round-to-nearest-even f16, single rounding per
  term) matches all 16,384 traced C results (64 tile-steps × 256). This confirms fused
  single-rounding semantics independently of the Python check.

## 11. The headroom, demonstrated

Ran WaferLLM (OSDI'25) MeshGEMV on the same toolchain and traced it:

| | xkernel corpus | WaferLLM MeshGEMV |
|---|---|---|
| FP arithmetic `num_data` | **1**, all ~95,000 dispatches | **16**, all 2,816 `FMACH` |
| f16 builtins | essentially unused | entire compute |
| `.simd_mode` fabric packing | **0 uses** | 12 uses |
| microthreads | ≤2 | ids 0–5 active |

Same hardware, same SDK, same compiler. **The scalar arithmetic in the corpus is a property
of the source, not a hardware or compiler limit.**


### 10s-ter. Buffers, queues, hops and repeats: MeshGEMM at port and buffer granularity (simulator + docs, 2026-09-25)

Tools: `meshgemm_repeats.py` (one pass over all 8.3 M records), `meshgemm_links.py`, `meshgemm_phases.py`. Outputs: `results/datapath/meshgemm_{repeats,links,phases}.json`.

**Addresses in the trace.**
- `ST16` pipe records carry the stored value. Their `imm` is the low byte of the word address, and the ELF symbol table ties each `imm` to a named variable:

  | imm | variable |
  |---|---|
  | 116 | `X_dsd` base |
  | 118 | `W_dsd` base |
  | 122 / 124 | `ptr_X_send` / `ptr_X_recv` |
  | 126 / 128 | `ptr_W_send` / `ptr_W_recv` |
  | 146 / 148 / 150 | the `comm_pe` send/recv DSD bases |

- The buffers, 512 B each (compiled): X_0 0x1140, X_1 0x1340, W_0 0x1540, W_1 0x1740, res 0x1940.
- A store is accepted only if its value lies inside that variable's domain. `imm` 128 collides with another variable 8,464 times, and those stores are rejected.

**SRAM double buffering, measured over all 7 repeats x 16 PEs x 4 steps = 448 steps:**
- The FMACHs read one buffer while the receive writes the other: 448/448 for X, 448/448 for W.
- All 16 k of a step read one buffer (448/448).
- The buffer just filled is the one multiplied next (336/336).
- MeshGEMV has no receive buffer. The reduce adds straight from the input queue, `@faddh(y, fabin, y)` (src0 = IQ), and senders stream `@fmovh(fabout, y)` (source).

**Communication does not overlap compute on a PE (simulator).**
- In every step window (128/128), the 128-packet transfer takes 254-257 cycles and finishes 27-45 cycles before that step's first FMACH.
- At PE (0,0), step 1:
  - four micro-thread IMOV16s (ut1-ut4: X out, X in, W out, W in) run for about 300 cycles, while the main thread issues about 55 instructions;
  - then 256 FMACHs run over 1,890 cycles with no micro-thread dispatches.
- **Correction:** the page's earlier sentence "double buffering overlaps the two" was wrong. The second buffer holds the next tile; it does not hide the transfer.

**Hops.**
- All 48 (kind, src, dst) paths are straight runs between neighbouring routers.
- Each of the 72 directed links used carries exactly one transfer.
- Colours:

  | transfer | 1 hop | 2 hops |
  |---|---|---|
  | X | 1 | 2 (east), 3 (west) |
  | W | 4 | 5, 6 |
  | skew forward | 12 | 13, 16 |
  | skew backward | 7 | 8, 9 |

- A 2-hop transfer passes the middle router on its colour and never reaches that core, as `x_tran_color` / `y_tran_color` say.

**Queues (documented, SDK 2.10 DSD page).**
- WSE-3 IQ0-7 hold 8, 8, 4, 4, 4, 4, 4, 4 words; OQ0-7 hold 8 words each. A 256-value tile is 128 wavelets, so software must buffer tiles in SRAM.
- memcpy reserves IQ0-1, OQ0, micro-thread 0 and colours 21-23 (23 = host to device, as traced).
- MeshGEMM uses OQ/IQ 2 (X), 5 (W), 3 (skew forward), 4 (skew backward). MeshGEMV uses 3, 5 and 6.

**Router buffers (documented for WSE-2 only).** Each colour has dedicated buffering; flow control is lossless, with backpressure (Hot Chips 2022; IEEE Micro 2023). Depth is not published, and nothing is published for WSE-3.

**The skew runs right before compute in every repeat.** In 7/7 repeats, every PE runs skew (256 packets per PE) → FMOV16 clearing res → first FMACH, with about 380 cycles between the clear and the first FMACH (step 1's tile pass).

**Only repeat 1 multiplies matched k-blocks.** Tiles were identified by content against the verified repeat-1 tiles; all are identified in every repeat. X and W k-blocks agree on 64/64 PE-steps in repeat 1, 32/64 in repeat 2 and 16/64 in repeats 3-7.
- **Cause (source):** `x_shift_step` is set only in `init_task` and counts down during the skew, so the skew's pointer swaps differ after the first repeat. Repeat 2 (the timing run's warm-up, after `init_task`) re-skews an already skewed X.
- **Effect:**
  - repeat 1, the run the host checks, is correct;
  - timing is unaffected: every repeat has the same instruction stream and traffic, and repeats start 9,663-9,692 cycles apart;
  - the timed repeats' values are not X·W;
  - `launch_device.py` has the same pattern; not checked on silicon.

**Host side (source).**
- X and W come from `np.random` (seed 2025) in host RAM; no WaferLLM launcher reads storage.
- The host pre-skews W (`ind`), tiles both matrices, and zero-extends every f16 into a 32-bit word. The SDK requires this for 16-bit memcpy, so the fabric carries one value per wavelet.
- Transport (documented): 100 GbE from an appliance worker node; CS-3 has 1.2 Tb/s of system I/O; I/O channels on the east/west edges, 62 per edge on WSE-3; about 7 Gb/s per channel; this kernel uses `--channels 1`.


### 10t. Sparse products traced: SpMV-RowBlock, SpMM-CSR-Dense, SpGEMM-Masked-Dot (simulator, 2026-09-30)

Harness: `microbench/sparse_walk/capture.py` runs the unmodified reference kernels (layout.csl + pe.csl copied
from `kernels/<Task>/CSL`, hashes in each `manifest.json`) on small integer instances with the study's own
host programs, one container job at a time behind the relay, then decodes and disassembles. Values:
`tools/sparse_walk_values.py` -> `results/datapath/sparse_walk.json`. Page: `tools/sparse_dataflow_build.py`.
All four runs are exact against numpy, and every FMULS/FADDS lane record matches the source's product or
running sum bit for bit.

| run | instance | arithmetic | outputs | h2d words found | d2h words found | device window |
|---|---|---|---|---|---|---|
| SpMV-RowBlock, 1 x 4 | 16 x 16, 39 nnz, x[16] | [39, 39] | [16, 16] | 132/132 in 136 pk | 16/16 in 82 pk | 392 cyc (TSC) |
| SpMM-CSR-Dense, 2 x 2 | 8 x 8, 19 nnz; B 8 x 4 | [76, 76] | [32, 32] | 180/180 in 188 pk | 32/32 in 116 pk | 669 cyc |
| SpGEMM merge, 1 PE | 8 x 8, 22 nnz, 9 zombies | [26, 26] | c_val [22, 22], codes [22, 22] | 57/57 | 44/44 | 5406 cyc |
| SpGEMM accumulator (expert) | same | [62, 62] | same | same | same | 4970 cyc |

**SpMV: the x multicast.** `@fmovs(fab_x_out, x_dsd)` on PE 0 (FMOV32.NF, micro-thread 2, cycle 5759) puts
16 wavelets on colour 8 from cycle 5766; every packet is seen at all 4 kernel routers,
2 cycle(s) per hop, payload = x in order (f32 in one 32-bit wavelet: index = high half, data = low half;
x[0] = 4.0 traced as index 0x4080, data 0x0000). PEs 1-3 arm the receive at 5761, before the first packet, so it waits
in IQ2; the last packet reaches PE 3 at 5787. PE 0 activates COMPUTE at once and starts multiplying at
5805, PE 1 at 5822. The routes are the multicast: PEs 1-2 rx WEST -> tx RAMP, EAST; PE 3 rx WEST -> tx RAMP.
Nothing of the matrix crosses the fabric; each PE gathers x by col_idx (39 gathered reads for 39 nonzeros).

**SpMV cost.** One nonzero is 19 dispatched instructions from the previous FADDS to its FMULS (two stack
loads of the loop state, shift+add to form &x[col], the gathered FMOV32, the FMOV32 of val, ADD/LTU/JMP), about
30.3 cycles per nonzero on PE 1. The row loop is unrolled (nrows_pe is a compile-time
parameter): the four y stores sit at four different pcs.

**SpMM.** 76 scalar multiply-adds = nnz(tile) x Nt per PE; the compiled inner loop runs the output columns from
Nt-1 down to 0. No kernel fabric traffic (only memcpy colours [21, 22, 23]); mesh rows finish at different times
([669, 669, 549, 549] cycles) because their row tiles hold different nonzero counts.

**SpGEMM.** The merge's compute window is 5289 cycles for 22 mask entries (240 per entry, 142-222 dispatched
instructions each): 52 float dispatches out of 3783, 1002 compare/branch, 181 stores
(the merge pointers are spilled to the stack every step). c_val and c_row are written by memory-destination
FMOV32/IMOV32, not ST32; a zombie costs as much as a hit. The dense-accumulator variant does 62 products
(36 of them by 0.0) with 377 compare/branch: 4787 cycles and 3173 instructions over the entries
against 5289 and 3638 for the merge (1.10x on this tiny instance; the expert README records 1.17x-1.43x at size).

**Colours bound by the kernels:** SpMV one (8), SpMM and SpGEMM none; memcpy 21-23 everywhere, 0-3/5 only in the support columns.


### 10s-quater. Per-cycle animation of MeshGEMM, in the manner of qin00162/Cerebras (2026-10-02)

The reference tool (`profiling/animate_native.py` in https://github.com/qin00162/Cerebras) renders the WaferLLM Prefill
GEMM-T and MeshGEMM Q×WQ round 0 as one frame per simulator cycle: a 4×4 physical grid, green PEs inside a compute
window derived from source-line matches (`prefill.csl` lines 377/390/408 and 421/437/455), per-PE instruction tags
(COMM DSD / ASYNC TX / ASYNC RX / FMAC / OTHER) from source-attributed dispatches, and per data group per physical hop a
batch envelope [first upstream event, last downstream arrival) with wavelets matched by route + colour + payload within
64 cycles. It states explicitly that the envelopes are not fabric-busy and green is not per-cycle FMAC.

`tools/meshgemm_cycles.py` reproduces the three ingredients from this study's trace (repeat 1, cycles 9,632-19,400):
- compute = the measured FMACH span of each step (first to last FMACH dispatch) plus the C clear, rather than a source scope;
- links follow packet identity (`ident`), so every one of the 160 transfers is attributed to its tile and every hop
  envelope is exact (128 wavelets each; 2 cycles per hop on steps, 2-5 on the skew where the queue backs up);
- ops are runs of same-tag dispatches with the function the pc lies in (ELF symbols: `mm_compute`, `left_matrix_shift_callback`,
  `meshgemm_entry`, memcpy) and the CSL source line where csdisasm has it (about a third of the pcs).
Tags: ASYNC TX/RX are the micro-thread IMOV16s whose DSR operand is a fabric DSR (dds2-5 out, s1ds2-5 in).
The animation shows the serialisation finding directly: while a step's tiles are in flight no PE is green.


### 10s-quinquies. MeshGEMM at 8×8 on 16 PEs, traced, with per-stay residency (simulator, 2026-10-05)

`microbench/mesh_small/capture.py` runs the unmodified MeshGEMM at P = 4, Mt = Kt = Nt = 2 (X, W 8×8, small integers so f16 is exact),
one checked repeat, and `tools/mesh_cycles.py` turns the trace into a per-cycle, per-PE record (`results/datapath/mesh_small_cycles.json`).
- P = 2 is not a valid configuration of this kernel: `assignId(pc, 2)` returns ids −1 and −2, so the folded two-hop ring needs P ≥ 3.
- Whole run 5,055 cycles from the first host word at a kernel PE to the last C word out; host words land at the PEs by cycle ~1,330,
  the skew runs 3,370–3,450, step FMACH spans are 48 cycles each (8 FMACHs of 2 lanes), steps are ~194 cycles apart, C streams out
  4,782–5,018. All 64 (PE, step) X and W tiles identified from the FMACH operands match the host's blocks; final C matches on 16/16 PEs.
- Residency is modelled per stay with the kernel's own pointer logic (x_shift_step by row; swaps in left_matrix_shift_callback and
  mm_compute). The model is asserted against the FMACH-identified tiles at every step on every PE (16/16). Consequences visible in
  the data: row 0 receives both skew transfers into X_1 and keeps computing on its host-loaded X_0; a host-loaded W tile stays
  resident ~2,300 cycles until step 3's transfer overwrites it; the step-4 transfers deliver tiles that are never used.
- Per-hop latency is 2 cycles on the steps and 2–5 on the skew (queue back-pressure) for these 2-wavelet transfers as well.

## 12. The layer below CSL — the IR cslc generates, captured, patched and rebuilt

`cslc` ships no flag that emits assembly or IR: its `--help-hidden` lists only CSL options,
`--print-after-all` is accepted and does nothing, `elf2lst` cannot disassemble ("failed to find
llvm-objdump"), and the container's generic LLVM (`/cb/toolchains/llvm/monolith-mlir`, with `llc`,
`opt`, `llvm-dis`, `llvm-objdump`) registers only x86 targets. But `cslc --verbose` shows what the
front-end actually runs, and every stage is a separate process with a file-based protocol:

| stage | binary (`/cb/toolchains/cslang/rel-sdk-2.10.0/<ver>/bin/`) | input | output |
|---|---|---|---|
| CSL → LLVM IR | `cslc-driver --arch=wse3 … layout.csl` | CSL | `/tmp/cslc-*/cslc-*.ll` — textual IR, triple `cs_sdr-cerebras-csos`, cpu `schrodinger`, data layout `p:16:16` (16-bit pointers) |
| IR → object | `cslc-backend schrodinger cs_sdr-cerebras-csos -v`, stdin = `in.ll` / `out.o` / `task.ld` paths + blank line | IR | ELF relocatable + task table |
| object → ELF | `cslc-linker -v`, stdin = `.o` / `link.ld` / `out.elf` / `libclang_rt.builtins-cs_sdr.a` / `libcsl_rt_cs_sdr.a` | object | the PE ELF |

The IR is the ISA one level up: each hardware instruction is an intrinsic — `@llvm.sdr.lddwds`,
`@llvm.sdr.lds1wds`, `@llvm.sdr.fmov16.ds1`, `@llvm.sdr.fmach.ds0s1r.f16`, `@llvm.sdr.faddh.rrs1.f16`,
`@llvm.sdr.add16.ds0s1`, `@llvm.sdr.actvt.r`, `@llvm.sdr.blk.r`, … — while scalar CSL becomes plain
LLVM (`load i16`, `sub i16`, `fmul half`, `icmp slt`, `br i1`). The atomic-ops body is 3,684 lines /
61 functions of IR for 842 instructions of ELF.

`tools/cslc_ir.py` makes this a working surface. `capture` binds a wrapper directory over the
cslang `bin/` inside the container: the backend and linker wrappers record their stdin request,
copy the driver's live temp directory (the `.ll` exists before the backend runs), then execute the
real tool — the compile is unchanged and the ELF **byte-identical** (checked on every capture).
`rebuild` reruns the real backend and linker on the captured request templates with a patched
`.ll`; with no patch it reproduces the object and the ELF byte-for-byte.

Three things this enables that CSL cannot express, each verified:

- **`optnone` on one function.** `rebuild --optnone compute` on the atomic-ops program: 176 → the
  scheduler no longer reorders anything. Run on the simulator (`ir_cap/optnone_sim/`): **all 22
  forms verify, all 23 markers dispatch in program order**, and every form sits between its own
  markers — `ld16, ld16, sub16.nf, st16` (6 cycles), `ld16, ld16, imul16, st16`, … — the exact
  marker-cut anatomy §10j could not get from `-O2` code. Cost: the body takes 273 cycles instead
  of 180 (loads no longer shared, loop kept on the stack, and the `if/else` forms become real
  `cflag0 ? jmp` rather than predicated moves — if-conversion is an optimisation, not codegen).
- **Inline Cerebras assembly.** `call void asm sideeffect "movri r5 = 0x1234", ""()` and
  `"add16.nf r9 = r8, r5"` inserted into the IR appear verbatim in the linked ELF (the backend
  links `libLLVMCerebrasAsmParser`; it accepts the syntax the disassembler prints). Instruction
  sequences can therefore be written by hand and timed with the same trace machinery.
- **Hand-written IR.** Any function can be replaced or added at the IR level and linked against
  the unchanged runtime and memcpy programs; the task table is regenerated by the backend.

### 12d. Reproducing the ASPLOS'26 stencil generator on SDK 2.10: four version walls

`external/wse-stencil` is the open-source generator from the ASPLOS'26 MLIR stencil paper (BSD-3,
xDSL 0.35 pinned, three commits, no releases). Running it here to obtain a corpus of expert-quality
generated CSL hit four independent version walls. The first three are solved and the pipeline now
produces CSL; the fourth blocks compilation and bounds the remaining work.

1. **No `mlir-opt` outside the container**, and the container's is LLVM 14, which registers only x86
   targets. `external/bin/mlir-opt` forwards through the same singularity relay the SDK uses.
2. **`test-math-algebraic-simplification` is a test-only pass**, absent from release builds of LLVM
   14, 20.1.8 and 23.1.1 alike. The paper's pipeline calls it; only the `cse` half of that stage is
   kept, with `pipeline.sh.orig` preserved beside it.
3. **xDSL 0.35 emits `bufferization.to_memref`, which LLVM renamed to `to_buffer`.** LLVM 23.1.1
   rejects the module outright; the container's 14 is far too old. **LLVM 20.1.8 is inside the
   window** and runs the pipeline end to end, emitting a 151-line PE program and its layout.
4. **CSL removed `comptime_struct` between SDK 1.3 and 2.10.** It appears **zero times** in SDK
   2.10's own libraries, so it was deleted from the language rather than renamed. In the *generated*
   files it occurs only as a type annotation, and `external/sdk210_fixup.sed` strips those two forms
   mechanically, after which the generated code passes the front end. The blocker is the generator's
   hand-written routing library `routes.csl`, which returns `comptime_struct` from functions
   (`fn computeAllRoutes(...) comptime_struct`); that has no mechanical substitution and needs a
   173-line port.

A false lead worth recording: `--allow-unregistered-dialect` is **not** missing. xDSL supplies it
itself and puts bracket contents inside `-p 'builtin.module(...)'`, so adding it to the bracket list
turns it into an invalid pass name. Reproducing the failure by hand without that flag misleads,
because xDSL never invokes `mlir-opt` without it.

**The same language removal blocks the expert baseline.** Cerebras's hand-written 25-point stencil
does not compile on SDK 2.10 on either architecture: `unknown builtin @concat_structs`, and its own
`routes.csl` returns `comptime_struct` too. So the paper's generated code and the hand-written kernel
it beat by 7.9% are *both* unbuildable on this SDK, for the same reason. That is the generation gap
the paper itself exploited when it noted the expert kernel does not run on WSE-3, one SDK generation
further on.

### 12b. What `--verbose`, the driver's dump options and `csdb` add

`cslc --verbose` itself is thin (the driver, backend and linker command lines — which is what made
§12 possible). The driver's documented options are richer:

- **`--dump-dsr-alloc-graph`** writes `bin/<prog>.greedy.dot` and `bin/<prog>.dsatur.dot`: the
  DSR *interference graph* the compiler coloured, one node per DSD operand (`DEST`, `SRC0`,
  `SRC1`) with its source location, the assigned DSR, and the allowable range `[0,16)` — 16 DSRs.
  For the atomic-ops program the greedy pass **fails** (`COLORING FAILED HERE`) on the memcpy
  library's node, which demands `Explicit DSR = 0`; DSATUR then assigns DSR 1 to every
  application operand. That is why every DSD op in §10i–§10j reads `dds1 / s0ds1 / s1ds1`: one
  DSR set, forced by the runtime's reservation, reloaded before every op.
- **`--out-routes`** prints, per layout PE and colour, receive side, transmit side(s) and switch
  positions (`R` = ramp, `E/W/N/S` = links). Relay N=1: colour 6 is `R→E` on PE (0,0) and `W→R`
  on PE (1,0); memcpy 21 is `R→E`, 22/23 `W→R,E` (a broadcast chain). Saved as
  `microbench/*/routes*.txt`; `anatomy_common.parse_routes` maps layout to fabric coordinates.
  Evidence `compiled`, available without running anything.
- `--output-json` is already emitted by the front-end and cannot be repeated.

`csdb` is a click shell (`csdb <workdir>` reads commands from stdin; a compile directory is a
cslc output dir with `out.json`). Useful offline: `image lookup --name <sym>` (symbol address and
size per PE), `wavelet read-trace [--color c] [--fmt hex]` and `wavelet read-timeline --color c`
(per-PE wavelet logs with Cycle / Color / Ctrl / Link / Index / Data). Joining its rendering to our
`wavelet_trace_entry.fields` for **3,021 wavelets with zero mismatches** fixed the bit layout of
that opaque word: bits 0–4 colour, bit 5 ctrl, bit 7 always set, **bit 10 = on the PE's ramp
(R)**, otherwise bits 8–9 = link (0 E, 1 N, 3 S; 2 = W by elimination), bits 11–15 repeat the
colour. `anatomy_common.wavelet_fields` implements it (`tests/test_anatomy_common.py`); the mesh
page uses it. So a wavelet's two records — sender on `R`, receiver on `E` — are now read, not
inferred. `memory read` / `register read` need a *target*. Initial dump-opening
attempts failed, but the **2026-09-19 stopped-snapshot experiment supersedes the
hardware-only conclusion**: csdb accepts the `corefile.cs1` CGZ prefix and its
SRAM/GPR reads agree with the ELF-core reader after stopping. Running dumps
returned stale SRAM. See [snapshot experiments](microbench/snapshots/README.md).

Cerebras's trace reader is importable (`cerebras.sdk.debug.lib.symbol.csldebugpybind.
SimfabInstructionTraceCtf(elf_dir, simfab_log)`): `get_instruction_trace_at(coord, c0, c1)`
returns cycle, PC, mnemonic, dest/src0/src1/src2 values, source file:line, task and uthread;
`get_tasks_at` / `get_uthreads_at` give task and microthread activity intervals;
`get_instruction_trace_summary` gives per-PC cycle totals (it charges a DSD op one cycle per
element). It is the same data as `events.jsonl.gz`; its value here was as the reference that
validated our value decode and the wavelet bit layout.

Evidence: `compiled` (every ELF is produced by Cerebras's own backend and linker); the `optnone`
correctness and ordering are `simulator`.

### 12c. The add family: a version-bound compilation model

`microbench/addfam` compiles 18 programs, each a single `compute()` one factor apart, retaining
the captured IR, object, ELF, disassembly and DSR graphs per case; `tools/addfam_model.py` is an
executable model that computes predictions from the source form; `tools/overlap_probe.py`'s
sibling `manifest.py` records every artifact with a full SHA-256. Rule set `addfam-v2`.
Scope: SDK 2.10.0, cslang `rel-sdk-2.10.0/202604012315-1813-1394a6ea`, `--arch=wse3`, memcpy
layout, 1×1 rectangle, exported `i16[64]` arrays, `-O2`.
Page: `results/anatomy/addfam_model.html`.

**A match means one specific thing.** `exact` is equality of the static instruction-role count
multiset over the region contract. It asserts nothing about instruction identity, operands,
register allocation, numerical results or timing. Correctness is a separate acceptance check:
all 18 cases run on the simulator against a Python model of their CSL body, and all 18 pass,
including a check that no element outside the expected set was written.

#### Two boundaries, not one

The retained IR is the input to `clang -cc1 … -x ir … -O2`, but it is **not** a neutral
pre-target form — it already carries CSL specialisation and target lowering. The DSD cases
settle this outright:

```
dsd16          3 descriptor loads + llvm.sdr.add16.ds0s1  (i16 1, i16 1, i16 1)
W_dsd_inplace  2 descriptor loads + llvm.sdr.add16.s0s0s1 (i16 0, i16 0, i16 1)
```

The intrinsic *name* encodes the operand roles and its *arguments* are the chosen DSR indices.
Descriptor elision, intrinsic selection and DSR numbering are therefore all pre-capture. The
model is split accordingly, and both halves are evaluated separately:

| boundary | what it predicts | result |
|---|---|---|
| CSL source form → captured IR | the IR op multiset and intrinsic form | 10/10 of the in-scope source forms; 8 declared out of scope rather than guessed |
| captured IR → machine code | instruction-role counts | 17/18, the single miss attributed to open item X1 |

#### No pass names and no pass order, permanently

Three channels for an intermediate transformation log were tried and all fail on this SDK:

- stock `opt` from the container rejects the captured IR outright — `Address space 0 can never be
  non-integral`, from the target's `ni:0` data layout;
- the `clang` the driver's own log names is **not a binary in the container**; it runs in-process
  inside `cslc-backend`, so there is no process to add `-mllvm` flags to;
- `cslc-backend` answers `--print-after-all`, `--print-changed`, `--debug-pass=Structure` and
  `--time-passes` with its usage message; it accepts only `<arch> <triple> [-v]`.

So only endpoints are observable. Every rule states resulting structure and never the sequence
that produced it, and the model names no LLVM pass. In particular the earlier claim that
invariant work is hoisted *before* unrolling is withdrawn: the observed endpoints are equally
consistent with unrolling first and eliminating redundancy afterwards.

#### The region contract

Debug attribution is not a region boundary. The region is the `pe.csl`-attributed body up to and
including `@activate(EXIT)`, plus the **transitive** closure of the nearest preceding definition
of every register the body reads before defining. Reported per case: entry live-ins, the closure,
and any unresolved live-in.

| case | body | init | total | entry live-in | closure |
|---|---:|---:|---:|---|---|
| 15 of 18 cases | — | 0 | = body | none | — |
| `const_both` | 2 | 1 | 3 | `r5` | `movri r5 = 0xa`, tagged `memcpy.csl` |
| `loop_runtime` | 22 | 1 | **23** | `r5` | `movri r5 = 0x0`, tagged `memcpy.csl` |
| `W_const_in_loop` | 9 | 2 | 11 | `r5` | `ld16 r5 = […]` and `add16.nf r5 = r5, 0x5`, both tagged `memcpy.csl` |

No live-in is unresolved. `loop_runtime` was previously reported as 22 because a one-step
backward walk stopped at `brk 0x2` and never reached the induction variable's initialisation.

#### Rules, with what was not tested

Thirteen rules, each carrying its tested and untested scope. The preconditions are now narrowed
to what the experiments actually establish:

| id | rule | tested | untested |
|---|---|---|---|
| F2 | a constant operand is already an IR immediate | the constant 7 | the immediate encoding boundary |
| F4 | DSD form, descriptor sharing and DSR indices chosen pre-capture | the same DSD value in both roles | separately constructed DSDs describing equivalent accesses; a destination aliasing source-1 |
| M3 | index-independent loop work computed once | trip count 8, single-statement body | other trip counts and body sizes |
| M4 | comptime loops fully unrolled, data-bounded loops not | trip counts 8 and 16 | the unroll threshold, so no other trip count is predicted |
| M5 | runtime indexing costs a fixed address sequence | two and three array bases | more bases; indices wider than u16 |
| X1 | **open**: register copies not modelled | one of two data-bounded loops has a stray `fmov16.nf r0 = r5` | what determines whether the copy appears |

The headline cost figures for this family are unchanged: 16 elements cost 5 instructions through a
DSD, 65 fully unrolled, and 23 in a data-bounded loop that computes one element rather than
sixteen.

#### Prediction history is preserved, not overwritten

`microbench/addfam/prediction_history.json` is append-only. Rule set `addfam-v1` keeps its own
evaluation (14/14 fit under the v1 contract; of four withheld cases, two predicted blind, one
correct after a revision stated before inspection, one refuted) together with the five defects
later found in it. `addfam-v2` records what changed. The four withheld cases have now contributed
to rule refinement, so they are demoted to **regression** cases: a fresh withheld set is required
for the next evaluation and does not yet exist.

`MANIFEST.json` records 216 artifacts across the 18 cases, each with a full SHA-256 and the exact
compile, backend and linker commands.

Evidence: `compiled` for every compilation observation, `simulator` for the correctness checks;
each rule is `inferred` as a general statement.

## 13. Negative results and corrections

Worth keeping — each one would have produced a wrong claim.

- **An f32 DSD reduction can be silently wrong, and one of ours was.** `@fadds(&acc, acc, dsd)`
  lowered to `fadds d10 = d0, [s1ds1]`: dest and src0 in different registers, so the accumulation
  never happens and the last element is returned. The f16 form of the same idiom coalesced and was
  correct, which is why §10j's reduction verified and §10n's did not. Anything in this study or the
  sibling projects that reduces f32 through a descriptor needs its disassembly checked for
  `dest == src0` (§10n).
- **An IR emitter cannot assume CSL global names.** Read-only device arrays are emitted as
  `@"$$csl_base_address$$N$$name"`; only written arrays keep the plain name.
- **Measuring decode→execute to the first execute record hides every execute-stage stall.** The first
  sweep reported a consumer decode→execute of 3 for the store→load, dependent-f16 and reduction
  consumers and would have concluded "no stall"; those consumers dispatch on time and wait in the
  execute stage, emitting placeholder records, and only their *last* record carries the value: 2, 1
  and 3 cycles late respectively. Every anatomy page and the sweep now measure to the value record.
- **"A jump has no execute record" was half true.** Not-taken predicated jumps have none; taken jumps
  have the usual two records. The atomic-ops loop's jumps happened to be sampled not-taken.
- **Five presentation and attribution defects in the anatomy pages, from external review.** (1) The
  Add page's per-element table selected the *descriptor-load* records (two words each) instead of the
  vector op's element records; the selector now picks the vector op. (2) Its DSD note quoted
  6 + 2·(elements/8) = 8/10/22 as completion, which is the next-dispatch interval; decode→last-execute
  is 4/6/18, and both are now named separately everywhere, with the 4-cycle gap between them stated
  as unexplained. (3) "Resolves at dispatch" for jumps inferred a resolution point from a missing
  execute record; replaced by "not observed". (4) Extra decode→execute delay was drawn and described
  as "a stall in stage 5"; it is now a layout choice with the location stated as unobserved. (5) The
  serialization result of §10k was stated without scope; it holds for a memory-to-memory i16 DSD on
  one PE without a microthread, and the trace shows fabric DSD copies run as microthreads, so other
  modes are untested. Every timing statement on the pages now carries one of three labels — dependency
  identified, delay observed, stall cause supported by a controlled experiment — and only the overlap
  and ILP experiments currently earn the third.
- **Three presentation defects on the anatomy pages, found by a reader.** (1) The −O2 region charts
  were headed "marker N — written as `<CSL line>`", inviting the reading that the window *is* that
  line's code; in fact marker 8's window holds the arithmetic of nine forms, because `mark`, `ci`
  and `cf` are distinct exported arrays that cannot alias, so result stores move freely across
  marker stores. Now headed "PC window", with a per-window list of the forms present. (2) The two
  cells between D and X were legended "in flight (stages 4–5)" without saying they are untraced and
  inferred, and could be read as decode taking three cycles; decode is the single D cycle. (3) The
  optnone body cost was given as 273 vs 180 on one page and 267 vs 171 on another, two different
  measures under one name; both pages now report marker-to-marker dispatch, 267 vs 171. The same
  sweep replaced every remaining "the scheduler" with the optimiser (§12c) and every "scheduler
  disabled" with function-local `optnone`, which disables most LLVM optimisations, not one.
- **DSD descriptor sharing and DSR assignment were placed after the capture boundary; they are
  before it.** The captured IR already contains `llvm.sdr.add16.ds0s1(1,1,1)` against
  `llvm.sdr.add16.s0s0s1(0,0,1)`: the intrinsic name encodes the operand roles and its arguments
  are the DSR indices. So the two-descriptor form was never a machine-code counterexample, and
  presenting it as one mislocated the decision. Corrected in §12c, which now models two
  boundaries instead of one.
- **A pass order was asserted from endpoints that cannot distinguish it.** "Invariant work is
  hoisted *before* unrolling" is withdrawn: hoist-then-unroll and unroll-then-eliminate produce
  the same observed structure. Naming `mem2reg` as the transformation that promotes allocas is
  withdrawn for the same reason. Three channels for a transformation log were then tried and all
  fail (§12c), so this is a permanent constraint rather than a temporary gap.
- **A one-step region extension matched a count for the wrong reason.** `loop_runtime` was
  reported as 22 with a prediction term for "induction init and increment"; the init actually sits
  outside the region and the term was counting an in-region register copy. Under the transitive
  contract the case is 23, the copy is unexplained, and it is recorded as open item X1 rather than
  absorbed into a rule.
- **Load sharing was attributed to "the scheduler"; it is the LLVM mid-end.** §12c places the
  capture boundary before LLVM's optimiser, so common-subexpression elimination, `alloca`
  promotion, store-to-load forwarding, loop-invariant hoisting and unrolling all happen after the
  captured IR and none of them are the machine scheduler. The plan's warning applies exactly:
  identical machine code can come from different internal sequences, and a dispatch interval
  identifies no compiler rule by itself.
- **A DSD op does not always need three descriptor loads.** The unconditional rule predicted 5
  instructions for `@add16(ad, ad, bd)` and 4 were observed: when the destination DSD aliases a
  source, one descriptor load is elided and a single DSR serves both roles. Recorded as R14 with
  the refuted form kept.
- **A consumer's dispatch is not a producer's completion — and I reported it as one.** The anatomy
  pages had a column headed "result used after" holding the dispatch-to-dispatch distance to the
  first instruction reading the result. On an in-order machine that is a scheduling fact, not an
  availability time: the reduction dispatches at 10390, its consuming store dispatches at 10403
  (+13), but the reduction's last element executes at 10407 (+17) and the store's own value record
  appears at 10409. The column is now "consumer dispatch interval" and a separate "completion
  latency" reports dispatch → last execute, the only verified boundary. `anatomy_common.completion`
  and `tests/test_anatomy_common.py` pin this down.
- **"DSD ops do not hold the issue slot" was wrong, and was inferred from consecutive dispatch.**
  Refuted by §10k. The evidence for it — a scalar instruction dispatching 1 cycle after an
  8-element DSD op — could not distinguish overlap from "the loop already finished", because an
  8-element loop executes in one cycle. Corrected in §10i and §10j.
- **A vector op's later execute records were being dropped from the animation.** The mesh view took
  an instruction's *first* execute cycle and removed it from the picture afterwards, even though a
  DSD op emits one record per element across several cycles. It now renders every recorded execute
  cycle, distinguishes the first record, subsequent records and the last, and marks the cycles
  between them as the loop running rather than leaving them blank.
- **Application instructions were being labelled harness because their mnemonic did not decode.**
  The tools filtered each PE's disassembly by source file, which dropped the `<memcpy>` runtime
  instructions that execute *on* the application PE (10 of them inside the atomic-ops body alone).
  Those PCs then looked undecodable and were hidden, removing real cycles and inventing bubbles in
  any interval measured from what remained. Origin is now decided by the source file the code came
  from, the whole ELF is disassembled, and instructions that still cannot be placed are shown and
  labelled `unknown` (PC absent from a supplied ELF) or `no-disasm` (no ELF supplied for that PE).
  Relabelling them turned up something the old view hid: on both relay PEs a few dispatches sit at
  PCs *above* the disassembled range (0x700, 0x708, 0x770 against a 0x5be maximum), carrying the
  completion-task colours 19 and 20 and tracing as `nop`. `elf2am` does not emit them, so they are
  genuinely unknown rather than misfiled — task-entry stubs, most likely. They are now visible and
  labelled instead of being counted as undecodable harness.
- **No cslc flag emits IR or assembly, and `--print-after-all` is a silent no-op.** The option is
  accepted (LLVM's hidden options are parsed) but the driver does not run instrumented passes; the
  compile is unchanged. The IR is reachable only by intercepting the driver→backend hand-off (§12).
- **Earlier simulator core-dump conclusion superseded, 2026-09-19.** Use the
  documented `corefile.cs1` CGZ prefix, not its `.idx` file or the separate ELF
  image, with `target create --core-file`. Independent stopped runs now verify
  SRAM and named GPR snapshots for Add, relay/Add and four-PE GEMM. Running-dump
  validity and arbitrary-cycle capture are separate questions. See
  [snapshot experiments](microbench/snapshots/README.md).
- **`elf2lst` is not a disassembler in this SDK** ("failed to find llvm-objdump"), and the generic
  LLVM under `monolith-mlir` has no Cerebras target. `elf2am` remains the one static
  disassembly path (`tools/csdisasm.py`).
- **`simdi` *is* a lane index — my earlier "it is not" was wrong.** Our corpus shows only
  `{0, 255}`, which I read as proof the field carried no lane information. WaferLLM shows
  lanes **0..7**, confirming SIMD-8 independently of the docs. The corpus was not evidence
  about the field; it was evidence our own kernels never issue SIMD. `isa_probe.py` now
  reports a width only when more than one lane is observed, and otherwise says so explicitly.
- **`single-pe-chains` did not measure dependency chains.** It emitted N independent bulk
  `@fmacs` over disjoint slices, so N chains did N× the work. Superseded by `microbench/ilp`,
  which holds work and loop overhead constant and varies only chain depth; latency and issue
  width are now measured (§8).
- **The "stride-1 anomaly" was a confound**, not an effect — the stride sweep held alignment
  at 0, which is the bad class for stride 1 only.
- **Raw timestamps are valid in simulation and meaningless on silicon** (−157,696 cycles,
  antisymmetric between directions). The sync correction is mandatory on hardware — and is
  itself wrong by a factor: it assumes 1 cyc/hop, the fabric runs at 2.
- **`wavelet_trace_entry` has no `direction` or `color` field.** I claimed it did without
  reading the metadata; the colour had to be recovered from `fields[4:0]` instead.
- **Trace categories cannot be enabled.** `simconfig.json` is regenerated every run,
  `SIMFABRIC_CONFIGFILE` has no effect (env verified to reach the container), `SdkRuntime`
  is a pybind with no trace surface. This blocks `backpressure_trace_entry`, which carries
  exactly the `back_pressure` + `link` fields a queueing model needs.
- **Two codegen defects found and fixed** in the calibration harness: concurrent async
  receives sharing `ut_id 0` (silent payload corruption), and same-colour multi-source
  merge, which is architecturally impossible — a WSE-3 router accepts **at most one rx
  direction per colour**.

## 14. Tools

| tool | purpose |
|---|---|
| `tools/trace_to_perfetto.py` | trace → Chrome JSON for ui.perfetto.dev (PE tracks, task slices, wavelet flow arrows) |
| `tools/hazard_probe.py` | joins disassembly operands to pipe-stage cycles; pipeline depth, RAW stalls, `xcptn` |
| `tools/capacity_table.py` | measured SRAM budget → per-PE matrix shapes (f16/f32, GEMV/GEMM) |
| `tools/mesh_view.py` | animated 2-D mesh replay: PEs at true coordinates, wavelets on the links they took; per-PE arithmetic utilisation / instruction-mix node modes and a click-to-inspect compute-vs-movement profile |
| `tools/retro_sync.py` | re-correct silicon fabric samples from raw TSC/reference words under τ cyc/hop sync |
| `tools/reduce_dp.py` | model-driven 1-D Reduce planner (star/chain/tree/two-phase/Auto-Gen DP) under theirs vs our constants |
| `tools/runtime_model.py` + `runtime_fit.py` | trace → C/E/N/L/D/W components; corpus-wide fit and scoring of the synthesized runtime model |
| `tools/add_anatomy.py` | atomic add: five forms run once, dispatch+pipe+disasm joined by uid/PC, MIPS-style pipeline chart and component dataflow |
| `tools/ops_anatomy.py` | atomic ISA: 22 basic operations + one fabric message, run once; summary table (D→X, result-use, next-issue), the body as scheduled per marker, two-PE send/receive chart |
| `tools/mesh_stages.py` | the same joins on the 2-D mesh, one cycle at a time: per-PE pipeline slots (D / in-flight / X), source→target of the executing instruction, wavelets moving on the links (paired by ident); relay and atomic-ISA scenes |
| `tools/anatomy_common.py` | shared decoders for the anatomy pages: stage-6 operand values (per element/lane for DSD ops), typed rendering, wavelet `fields` bits (csdb-equivalent: colour/ctrl/link), `cslc --out-routes` table parser |
| `tools/pe_model.py` | the single-PE model page: per dynamic instruction (PE, uid, PC, task, microthread, operands, every dispatch and execute record) a functional datapath with numbered steps, a RAW/WAR/WAW dependency graph over GPR/DSR/flag/memory/stream/task resources, and a cycle timeline; quotes pcsweep for every edge it supports |
| `microbench/pcsweep/build.py` | producer→consumer sweeps: IR-level `nop` insertion under `optnone`, verified sequences, dispatch bubble and execute-stage (value-record) delay per pair |
| `tools/overlap_probe.py` | DSD-versus-scalar execution overlap from `microbench/overlap`: completion boundaries, serial and full-overlap predictions, execute-window occupancy, issue-hold |
| `tools/addfam_model.py` | the add-family compilation model: dataflow role classification, 16 rules with preconditions, fit and withheld-prediction evaluation |
| `tools/cslc_ir.py` | capture the LLVM IR cslc generates (transparent wrapper over cslc-backend/linker, byte-identical ELF), rebuild ELFs from patched IR (`--optnone FUNC`, `--asm-after REGEX ASM`, or a hand-written `.ll`) |
| `tools/bench_anatomy.py` | single-PE instruction anatomy: every dispatch as a timed block, wide DSD ops labelled with element counts, decode→execute depth per instruction; per-variant PE dataflow diagram (SRAM streams → CE → destination, measured B/cyc, bank-interleave strip, fabric wavelets in window) |
| `tools/decode_trace.py` | barectf CTF (`simfab_traces/`) → `events.jsonl.gz`; derives fabric width from `global_simdata.json` |
| `tools/fabric_probe.py` | `cs_readelf` → fabric-wide routing, switches, SRAM banks, PE roles |
| `tools/csdisasm.py` | `elf2am` → address-ordered disassembly with CSL source correlation (stages the ELF itself; the SDK container mounts only cwd) |
| `tools/isa_probe.py` | CTF dispatch trace → instruction mix, elements/dispatch, microthreads (`--listing`) |
| `tools/noc_model.py` | per-link occupancy from colour decoding + ELF routes |
| `tools/bottleneck.py` | bottleneck class + recommended fix per kernel |
| `tools/decode_fields.py` | `fields` bitfield reverse-engineering against routing ground truth |
| `tools/disasm_all.sh`, `probe_all.sh` | corpus-wide batch drivers |
| `tools/archive_reclaim.sh` | archive + reclaim regenerable campaign artifacts |

* `microbench/matmulorder/{gen,run}.py` -- eight matmul traversals on one PE with
  per-variant value checks; results in `matmulorder_results.json`.
* `tools/gemm_dataflow_probe.py` -- per-colour packet counts, direction, hop length and
  PEs-per-packet for the WaferLLM kernels; `results/datapath/gemm_dataflow.json`.
* `tools/meshgemm_sim.py` -- verbatim port of MeshGEMM's placement and two-hop ring;
  verifies C = X.W exactly for P = 3..12; `results/datapath/meshgemm_steps.json`.
* `tools/wavelet_lineage_audit.py` -- per-identity classification of the mesh
  viewers' pairing rule; writes `results/datapath/lineage_audit.json`.
* `tools/datapath_xwl.py` -- cross-workload opcode latency, SIMD lane count and
  element rate; writes `results/datapath/xworkload.json`.
* `tools/mesh3d_extract.py` -- route-template dedup and per-PE time binning from a
  decoded `events.jsonl.gz`; turns a trace into a browser-sized scene. Emits two
  binnings: a coarse one for the run-length activity ribbon, and a fine one
  (1-16 cycles, base64 Uint8) that colours per-cycle PE occupancy in the trellis.
* `tools/mesh3d_scenes.py` -- builds the six cached scenes into `results/mesh3d/scenes/`.
* `tools/mesh3d.py` + `tools/mesh3d.html.tpl` -- renders them into one self-contained
  WebGL page (three.js r128 from cdnjs, orbit camera written in-page). Two readings
  of the same scene: an animated replay, and a space-time trellis that stacks one
  mesh plane per cycle and draws each hop as a line between planes.

## 15. Open

1. ~~**Instruction latency / issue width**~~ — **answered in §8**: baseline pipeline depth 3,
   dependent FP issue every 2 cycles, independent every 1. A pointer chase is still absent, so
   general pointer-chase load-use latency remains unmeasured. The later §10l sweep covers the
   specific immediate `ld16 → add16` case with no extra delay; it does not establish every load form.
2. **Backpressure and queue depth** — blocked on trace categories.
3. **Per-port aggregate bandwidth** — expressible now, needs a multi-port probe.
4. **West degradation past 32 hops** — now bounded (§10g): westbound is 2.000 cyc/hop to 32
   hops, then the coefficient rises to 2.9 over the full range. Still unexplained mechanistically.
5. **Microthread scaling** — m2/m4/m8 fail to compile (`ApplianceUnknownError`); needs local
   reproduction for the real CSL error.
6. **`fields` upper 14 bits** — undecoded (bits[4:0] = colour, bit 7 always set).
7. **SRAM read/write bank conflicts** — probe built; flat under both a positive control and a
   verified memory-placement shift (§8, §10c). Working hypothesis: the simulator does not model
   them on the DSD path. Needs silicon to settle.
8. **Receiver-side compute overlap** — unmeasurable with the current instrument. The probe
   timestamps inside the DONE task, so receive and compute cannot be separated; the C2 sweep
   returned an identical 30,075 cycles across binaries verified to differ. Needs a probe that
   samples the TSC outside the completion handler.
9. **WaferLLM at P > 4 and MeshGEMM on silicon** — the comparison in §7 is simulator-only.
10. **GEMM-specific flattening** — §10 measures what nesting costs but does not show that
    MeshGEMM's `Kt` reduction can be collapsed into one DSD. Needs a forked implementation.
11. **Runtime-model synthesis** — done (§10f, §10g). Phase-term refinement was a null; the
    17k-cycle offset's origin is open. Relay microbench settled the stage cost: 16.1 cyc per
    message-granular store-and-forward stage (= DSD setup); k≈2.07 measures pipelined streams.
12. **Thermal no-op hypothesis** — partially answered from the ledger: 58 silicon batches ×
    100 trials of short device-internal windows show max/min = 1.000 and zero late-trial drift,
    so no-op insertion does not touch windows of a few thousand cycles. The 2× noise came from
    long kernels via `cycles_send`. **Silicon batch (prepared):** long hot kernels (GELU-1PE,
    MeshGEMM at P=4) × 30 trials with trial-order recorded, plus their α-calibrated start.
13. **Control-wavelet switching** — cost and mechanics unprobed; `switch_pos_trace_entry` is
    already decoded but unused.
15. **Silicon batch, ready to run** (needs an appliance window; nothing here executes hardware
    without `--execute --confirm-hardware`): (a) `microbench/relay/` at N ∈ {1,2,4,8}, B ∈ {64,512}
    — tests the 16.1-cyc stage cost and 1.001 link rate on hardware; (b) `microbench/bank/` — the
    read/write bank sweep the simulator cannot see (§8, §10c); (c) the thermal test in #12; (d) a
    broadcast-reference clock-sync probe to replace the SDK bandwidth-test sync, now that its
    1-cyc/hop bias is measured; (e) MeshGEMM at P=4 for the §7 comparison on silicon.
14. **Wafer capacity** — undetermined. `cslc` does not validate `--fabric-dims` (§9), so the
    real bound needs an appliance run at increasing fabric sizes.

## 16. Controlled receiver readiness — 2026-09-16 simulator pilot

The [two-PE experiment](microbench/readiness/README.md) and
[offline layered comparison](results/readiness/readiness.html) add 19 executions
with 172 exact numeric words bound through send S6, both routers, receive S6 and
subsequent Add S6. All readbacks pass; the native SDK CTF reader independently
agrees on all 344 router observations. The sender ELF is fixed within each
length/build group, and receiver NOP prefixes are verified statically and dynamically.

With an undelayed receiver, all tested lengths (1, 4, 5, 8, 16 words) have two-cycle
router-observation intervals. Adding 256 receiver NOPs preserves those intervals
for 1–8 words. For 16 words, intervals for words 8–11 become 182–183 cycles and
the first-to-last source-router span grows from 15 to 193 cycles. First receive
dispatch moves by exactly 256 cycles while send dispatch stays fixed. Early/late
8- and 16-word repetitions reproduce the same values and observation cycles.

This establishes receiver-dependent transmission timing for this simulator path.
It constrains a flow-control model without exposing queue occupancy, physical
queue depth, or silicon timing. Cross-length launch offsets differ and are reported
explicitly. Intermediate lengths and readiness offsets are the next discriminating
probe. The earlier open question about direct backpressure-category traces remains
unresolved; this experiment observes timing consequences through available records.
