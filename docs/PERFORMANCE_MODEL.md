> Reference notes preserved from the original characterization study. Paths to
> raw study results, visualization pages, and microbenchmarks below describe the
> original study and are not included in this minimal source release. The retained
> runtime is in `code_translation/performance_model/`.

# WSE-3 Characterization — Findings

Progress summary for the ALCF Cerebras WSE-3 campaign. Companion to `README.md`,
which describes the study's *design*; this records what it *found*.

Every claim carries an evidence class:
**`silicon`** measured on a real CS-3 · **`simulator`** SDK fabric simulator ·
**`compiled`** read from the compiler's own ELF output.

Published: [Fabric Readout](https://claude.ai/code/artifact/8778b38b-c44f-421f-8587-46fa94b275d5) · [Programmer's Reference](https://claude.ai/code/artifact/da197d66-face-4cc1-b4b1-0503f7468fe1) · [MeshGEMM dataflow](https://claude.ai/code/artifact/0d86ae65-016f-498f-ad0d-6e1d83ac7eb3) · [MeshGEMV dataflow](https://claude.ai/code/artifact/be866a68-b4e1-419e-9c50-189af5dbeec3) · anatomy: [AXPY & Dot](https://claude.ai/code/artifact/d09b1720-e2d4-4b1b-8b29-60475e394b3c), [Copy & Stride](https://claude.ai/code/artifact/15d7d577-76f0-42b7-b4fd-c74657703219), [Elementwise](https://claude.ai/code/artifact/43de5237-9f96-4017-979b-146d8911b9f3) · [microbench harness mesh](https://claude.ai/code/artifact/18ced05e-03c6-47aa-a6b5-ef1eb17969ae)
(Earlier readout/reference/MeshGEMM URLs live in a different claude.ai organization and are superseded by these.)
(findings narrative) · [Programmer's Reference](https://claude.ai/code/artifact/7f0d8b14-a77c-4266-8877-944ce848521d)
(lookup reference).

---

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
Page: `results/anatomy/add_anatomy.html`.

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
- **DSR load-use is 4 cycles** (last DSR load dispatched at 2, the op at 6) and the op's own
  decode→execute is 4, one more than scalar.
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

## 10k. Does independent scalar work overlap a DSD hardware loop? No.

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

**Verdict: serialized. There is no execution overlap.** So the 6 + 2·(elements/8) figure of §10i
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
inferred. `memory read` / `register read` need a *target*: the simulator's `SdkRuntime.dump_core`
and `dump_elf_core` do write files, but csdb 2.10 rejects both as "invalid checkpoint file", so
those readers are for hardware (CM) sessions only.

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
- **csdb cannot open the simulator's core dumps.** `SdkRuntime.dump_core` / `dump_elf_core` write
  `<prefix>.idx` + `<prefix>_N.cgz` and an ELF image, but `target create --core-file` rejects
  them ("invalid checkpoint file"); `memory read` / `register read` therefore need a live CM.
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

## 15. Open

1. ~~**Instruction latency / issue width**~~ — **answered in §8**: baseline pipeline depth 3,
   dependent FP issue every 2 cycles, independent every 1. A pointer chase is still absent, so
   load-use latency specifically remains unmeasured.
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
