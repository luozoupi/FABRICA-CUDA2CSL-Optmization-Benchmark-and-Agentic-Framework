# WSE-3 datapath and performance model: materials versus measurements

Reviewed 2026-09-17. **We can build a useful instruction/dataflow teaching model
and a conditional performance model now.** A complete physical pipeline schematic
is still unavailable from the materials and traces inspected here. The useful next
step is to model operand readiness, descriptor setup, element delivery, receiver
service, and dependencies explicitly, then test predictions on new builds.

This review reads the supplied [processor lecture](/home/USER/lecture4.1_processor.pdf),
current Cerebras SDK documentation, the vendor's Hot Chips presentation, and the
retained compiler, simulator and silicon results. It also runs **read-only SDK
tool probes** and **offline model evaluations**. It launches no new simulator or
appliance workload and does not change the existing numerical viewers.

Open the original [datapath and timing figure](results/architecture-review/datapath.svg).
For interactive instruction/value selection use the existing
[datapath comparison](results/anatomy/datapath_review.html),
[exact packet paths](results/pe-hops/hops.html), and
[PE/time layers](results/gemv-walkthrough/space-time.html).

## 1. What the public WSE-3 diagram adds

The most useful physical core summary is **PDF page 29, “WSE-3 Core,”** in
[Cerebras's Hot Chips 2024 presentation](https://hc2024.hotchips.org/assets/program/conference/day2/72_HC2024.Cerebras.Sean.v03.final.pdf).
The figure was visually inspected, not just text-searched. It specifies:

| Component | WSE-3 vendor material | Comparison with our artifacts |
|---|---|---|
| Local SRAM | 48 KB per core | Executed ELF allocations place X/W, A/B, buffers, code and stack in PE-local memory. |
| Local cache | 512 bytes | An additional component to include; our retained records do not identify cache contents, hits or management policy. |
| General-purpose registers | 16 | Compatible with scalar disassembly and paired-register f32 operands. |
| Data-structure registers | 48 | Consistent with three operand files and the compiler's 16-register allocation ranges per file. |
| 16-bit SIMD | 8 lanes, FP/BF16 | Our vector Add and larger FMACH traces show groups of eight results. |
| 8-bit SIMD | 16 lanes, fixed/INT8 | Hardware capability; not demonstrated by our captured workloads. |

The SIMD widths are capacities, not a guarantee of that many results every cycle.
In our FADDH example, eight results appear every **two** cycles. The first
64-element operation modeled below therefore has a different rate from a full-width,
one-group-per-cycle ideal.

**Keep generations separate.** The older vendor
[architecture deep-dive](https://www.cerebras.ai/blog/cerebras-architecture-deep-dive-first-look-inside-the-hw-sw-co-design-for-deep-learning)
describes four FP16 FMAC units, 44 DSRs, a 256-byte cache and a six-stage scalar
pipeline. It helps explain the design lineage, but those numbers cannot be copied
into a WSE-3 specification. In particular, its six-stage statement does not identify
WSE-3 stages 0–6, their latches, or their bypass paths.

The current [SDK SIMD appendix](https://sdk.cerebras.ai/csl/language/appendix)
provides a more useful **per-builtin** width table: for WSE-3, FADDH and FMACH can
use eight lanes; FADDS and FMOVS can use four. Full f32 FMACS is a different form;
the [versioned debugging guide](https://cerebras-sdk-docs-130.netlify.app/debug/debugging)
illustrates it with one lane. Preserve mnemonic, operand form, precision and
SIMD settings in every model key. “FP32 = one lane” and “all operations = eight
lanes” are both too broad.

## 2. SRAM, cache, registers and incoming operands are different locations

For the teaching programs, the prior [52-array storage audit](viewer/INPUTS.md)
still holds: **X and W both have SRAM backing**, as do GEMM's A/B and abuf/bbuf.
This review additionally ran the vendor's `cs-readelf --units=byte --sym` on the
executed V1 PE (0,1) ELF:

| Array | Byte address | Bytes | Banks spanned in native symbol output |
|---|---:|---:|---|
| W | `0x1b58` | 16 | 0–7, starting at bank 4 |
| X | `0x1b68` | 8 | 4–7, starting at bank 4 |

The installed readelf manual defines the logical bank as `(byte_address >> 1) & 7`.
A 32-bit element spans two 16-bit bank positions. The full command output,
including the manual and symbol table, is in
[tool-probe.json](results/architecture-review/tool-probe.json). These are logical
address banks, not recovered physical SRAM layout. Sharing a bank number does
not establish a conflict: the accesses must compete at the relevant time.

The [SDK PE memory model](https://sdk.cerebras.ai/computing-with-cerebras)
also documents incoming queues and a wavelet-triggered task receiving its argument
in a register. A fabric DSD can consume incoming data as an operand. Thus the
functional choices for a received value are:

```text
router → input queue → scalar task argument → arithmetic
router → input queue → fabric DSD operand → arithmetic
router → input queue → receive/copy → local SRAM buffer → later arithmetic
```

Our GEMM receive buffers demonstrate the third case. It is unnecessary to assume
every streamed operand becomes an array in SRAM. Conversely, SRAM allocation does
not mean an executing arithmetic instruction reads its operand directly from an
SRAM cell at the S6 timestamp. Operand copies can be in registers or internal
datapath storage. The newly documented 512-byte cache does not establish that
these tiny inputs were cached, even if their footprint would fit.

**Address-unit pitfall:** native `cs-readelf` defaults to byte units; installed
`csdb memory read --address/--length` uses **two-byte words**. Reading X at the
above address would require address `0xdb4`, length `4`, in that csdb command,
with a compatible target selected. Neither the CLI help nor a symbol allocation
constitutes a live memory snapshot.

## 3. Translating the lecture into a WSE teaching diagram

The supplied lecture is titled **“The Processor: Single-Cycle Implementation.”**
Pages 8, 14–19, 29–35 and 37 describe instruction actions, datapath selection,
control signals and the critical path. It mentions a pipelined implementation,
but it does not supply a pipelined WSE-style timing specification.

| Lecture concept | WSE functional equivalent | How to display it |
|---|---|---|
| PC / instruction memory | Local code, task selection, PC and decoded instruction | Highlight selected task, exact PC and source/IR/disassembly. Do not assume MIPS's fixed PC+4 increment. |
| Register read / ALU input mux | Scalar register/immediate operands, memory streams and fabric streams | Highlight the selected **functional** source; mux circuitry is unspecified. |
| Load/store address calculation | Scalar addresses plus descriptor base/extent/stride state | Show byte address, element index and logical bank where recoverable. |
| ALU operation | Integer/FP/move or vector instruction form | Show every observed input, result and lane, not just an output tile. |
| Control unit | Instruction semantics, predicates, task activation, DSR/queue configuration | Use semantic controls such as source kind and destination kind, not invented electrical signals. |
| Register writeback | Result dependency and eventual destination | S6 is a value observation; a separately measured WB/commit stage is absent. |
| Pipeline hazard | Operand, descriptor, memory or receiver readiness constraint | Show the producer-consumer edge and the controlled experiment supporting its delay. |
| Multiple processors | Per-PE execution plus routed transfers | Show source/receive readiness, transit observations and the dependent consumer. |

The [DSR documentation](https://sdk.cerebras.ai/csl/language/dsrs) explains how
descriptors are loaded into destination, source-0 and source-1 register files;
multidimensional streams additionally use XDSRs and stride registers. Those
descriptor values control address generation rather than holding tensor elements.
Explicit DSR reuse and base-address updates are therefore worthwhile performance
experiments.

For each selected instruction, the presentation should show:

1. The active operand and destination paths, with known values and addresses.
2. The observed dispatch, S3 decode, and all operand-bearing S6 records.
3. Dependency constraints, with their exact tested instruction forms.
4. The predicted next event and observed residual, if a valid model exists.

The SDK guide identifies **S3 as decode and S6 as execution on WSE-3**.
We can label those anchors confidently. Fetch, intermediate stage functions,
forwarding selections, memory commit and physical writeback remain unspecified.
An empty/payload-free S6 record alone is not a stall indicator. A three-cycle
S3-to-value interval does not establish a three-stage processor.

## 4. Tools checked against the installed compiler and capture format

[sdk_architecture_probe.py](tools/sdk_architecture_probe.py) records executable
paths, hashes, help text, return codes and Python debug API signatures. The
installed image is `sdk-cbcore-2.10.1-sdk-202606181328-8faf87a26e.sif`;
the compiler driver identifies itself as **CSL 2.10**. Driver and LLVM toolchain
paths have separate build identifiers. `cslc --version` fails at the Python
frontend; `cslc-driver --version` works inside the container.

| Tool or capability | Result of this review | Value for the model |
|---|---|---|
| `cslc-driver --help-hidden` | Rechecked; includes DSR graph, routes, section placement and loop-inlining limit options | Reuse DSR allocation graphs; control array placement; inspect when compiler loop structure changes. Always pass `--arch=wse3`; the displayed default is wse2. |
| `--dump-dsr-alloc-graph`, `--out-routes` | Available; earlier captured graphs/routes remain useful | Descriptor pressure and initial routes are compiled evidence. Route changes during execution need runtime evidence too. |
| `--link-section-start-address-bytes` | Available, addresses explicitly in bytes | Controlled placement experiments with named `linksection`s; validate the resulting ELF, sizes and alignment. |
| `tools/cslc_ir.py` | Existing driver/backend interception remains the retained IR path | Bind original and executed IR/ELF hashes, and distinguish optimized from `optnone` builds. No new supported IR/assembly output flag was found in driver help. |
| `elf2am`, `cs-readelf` | Installed; help and native symbol output captured | Disassembly/source mapping, symbol sizes, banks, architecture and PE load rectangles. Generic LLVM-looking help options are not evidence of a usable scheduling model. |
| SDK GUI | Current docs and release notes say WSE-3 instruction panes work from 2.10 | Useful vendor comparison for instructions, source, tasks, microthreads and wavelets; GUI rendering was not launched in this review. |
| `sdk_debug_shell instr-trace` and `wavelet-trace --backpressure` | Options exist, but **all three tested reads reject our CTF artifact directory** | Installed command requests `csdb`; an advertised flag does not provide additional backpressure records for these captures. |
| `csdb` and native CTF APIs | csdb trace/timeline help and native method signatures verified | Continue using the existing native CTF cross-checks; retain raw identity/line evidence absent from formatted output. |
| `SimfabConfig` | Constructor exposes threads, suppress-trace and core-dump settings; no category selector in this exposed signature | This inspection found no new way to enable per-link backpressure categories. |
| `csdb memory/register read` | **2026-09-19 update: simulator dumps verified after stop** | Use `corefile.cs1` as the CGZ prefix. SRAM and named GPR words agree with the ELF-core reader for one-PE Add, a relay and four-PE GEMM. Running dumps were stale; arbitrary-cycle capture remains unresolved. See [snapshot experiments](microbench/snapshots/README.md). |

The [SDK GUI guide](https://sdk.cerebras.ai/debug/sdk-gui) documents combined
instruction/wavelet timelines and congestion/backpressure displays. The
[SDK 2.10 release notes](https://sdk.cerebras.ai/sdk-release-notes/sdk-rel-notes-cumulative)
confirm the instruction-pane fix. These UI capabilities must be distinguished
from the legacy CLI's CTF rejection and from the categories actually emitted
by a capture.

Further useful documented mechanisms include `@queue_flush` and queue-empty
handlers: asynchronous instruction completion and an empty output queue are
different boundaries. These could add a completion measurement to a new probe;
they do not reveal a queue's capacity. See
[queue builtins](https://sdk.cerebras.ai/csl/language/builtins).
SDK 2.10 also documents dense queue mode and restricts a DSD operation to at most
one fabric-input operand. Thus a proposed “two remote operands into one FMA”
mapping needs a local operand or additional staging; it cannot be assumed legal.

## 5. An estimated model already tested against retained profiles

Run `python3 tools/architecture_model.py` to reproduce
[estimates.json](results/architecture-review/estimates.json). It rechecks **221 raw
S3/S6 records** and **five GEMV path records**, verifies the six dependency-capture hashes, and records the
calibration and evaluation rows. These are retrospective splits of evidence we
have already inspected, not blind experiments or new silicon validation.

### Vector execution: distinguish width, interval and setup

For the contiguous memory-to-memory FADDH cases, calibrating with the 8- and
16-element operations gives:

```text
T(S3 → last value) = Lfirst + IIgroup × (ceil(N / W) − 1)
W = 8 elements, Lfirst = 4 cycles, IIgroup = 2 cycles
```

The 64-element case is excluded from parameter calculation. Prediction: **18
cycles**; observation: **18 cycles**. Assuming the same width but one group each
cycle would predict 11, seven cycles too short. This formula excludes DSR loads,
loop setup, completion handling and later dependencies. It is a tested model
of this instruction form and schedule, not universal FADDH latency.

### Dependency rules

Let K be intervening NOPs in the retained controlled pair. Endpoint calibration
uses K=0 and K=24; the six intermediate K values test the rule.

| Exact controlled case | Estimated extra dispatch gap | S3 → consumer value |
|---|---:|---:|
| Last DSR load → vector Add, each of three operand roles | `max(0, 3−K)` | 4 |
| Register f16 Add → dependent f16 Add | 0 | `3 + max(0, 1−K)` |
| Same-address st16 → ld16 | 0 | `3 + max(0, 2−K)` |
| ld16 → dependent integer Add | 0 | 3 |

All **36** intermediate cases match both timing fields. The f16 chain is the
earlier timing/marker check, not a new numerical validation. These rules must not
be automatically attached to f32 operations, WAR/WAW dependencies, or different
address/descriptor forms. The older `pe_model.py` resource matcher has those
generality limitations; the new estimator uses only the named controlled cases.

### Memory: why the generated program matters

For the suite-A cases with exactly 8,192 total f16 elements, fit
`cycles = intercept + per_repeat × repetitions` using extent 256 and 1,024.

| Evaluation case | Predicted cycles | Measured cycles | Absolute relative error |
|---|---:|---:|---:|
| Copy, extent 4,096 | 1,044 | 1,044 | 0% |
| Fill, extent 4,096 | 1,042 | 1,042 | 0% |
| Read-to-scalar, extent 4,096 | 8,148.5 | 8,212 | 0.77% |
| Copy, extent 16 | 3,594 | 6,153 | 41.59% |
| Fill, extent 16 | 3,082 | 7,176 | 57.05% |

The fitted copy and fill slopes are five and four cycles per repetition **in
this fit**, not independently isolated DSD-launch costs. Since total element
work is fixed, the intercept combines stream cost and window overhead: those
two contributions are not identifiable separately. The small-extent failures
make instruction/loop structure a required model feature, rather than something
to absorb into one fitted constant. Existing single-PE controls also show that
read-to-scalar is not an aggregate SRAM-read bandwidth measurement.

Silicon must have a separate memory calibration. The retained bank-stride
campaign has 100 accepted trials per case: stride-2 timing changes from 273 to
529 cycles for some alignments; stride-8 reaches 781. The simulator placement
probe is nearly flat. This discrepancy supports an alignment-sensitive hardware
cost term, but the two suites are not matched executions that isolate one port
conflict. See [the raw-audited comparison](DATAPATH_REVIEW.md).

### Communication: receiver service is part of the model

Calibrating on early-receive one- and four-word cases gives a source-router span
of `N−1` cycles and an adjacent recorded router interval of two cycles. The early
16-word case fits: span 15. The delayed 16-word case has span **193**, so the
same rule misses **178 cycles**, identically across its three retained repeats.

A one-wavelet-per-cycle stream rate and a two-cycle adjacent arrival interval
can coexist: throughput and latency measure different things. The architecture
introduction's one-cycle communication wording is not a calibrated latency for
our send-S6 → receive-S6 window. Use named boundaries and a specified generation,
rather than transferring a number from a general overview or WSE-2 model.

For this path, two cycles is an observed unstretched router interval; it is not
a complete message latency law. A minimal model needs release times, injection
rate, receiver service and downstream blocking. An eight-word physical queue
cannot be identified just because the first eight arrivals are unstretched.

## 6. Composing PE and mesh performance

Use an event/dependency graph whose inputs are workload dimensions, the compiled
schedule and operand forms, placement/routes and independently calibrated costs.
Do not require the target execution trace to make the prediction.

For a local vector operation:

```text
start = max(program-order permission, operand-ready times,
            descriptor-ready times, required-resource availability)
last_value = start + Lfirst + IIgroup × (ceil(N / Weffective) − 1)
```

This is an event model. An operation's resource reservation interval can differ
from its value latency. A reduction also has an accumulator recurrence, which
may restrict Weffective to one; independent output accumulators may overlap.
The actual compiler-selected form determines which rule is applicable.

For a transfer, track per-word arrivals and downstream service. With contention
and buffering unspecified, retain an optimistic service schedule and alternative
blocking hypotheses. Do not fit one endpoint delay and call it a queue depth.
Compute mesh completion along dependencies: taking a single global maximum
loses serialized work; adding all compute and communication double-counts overlap.

For GEMM, annotate each round with A/B ownership or panel delivery, descriptor
setup, local products/accumulations and the next round's readiness. For GEMV,
annotate X/W use, local partials, reduction and replication separately. For sparse
work, additionally account for index loads, gather locality, nonzeros per PE,
and reduction imbalance; the dense lane count alone cannot predict it.

As an **illustrative arithmetic issue budget**, the unfused scalar 4×4 GEMM has
64 products and 64 adds. At the observed one-instruction-per-cycle issue rate,
128 issue cycles on one PE (32 per PE with an even four-PE distribution) cover
only those arithmetic instructions. Loads, address work, spills, loops, tracing
stores, communication and dependencies remain to be scheduled. The retained
single-PE control actually takes 4,455 local timer cycles; history takes 29,724.
Neither timing is optimized vector-GEMM throughput. This is precisely why the
instruction path needs to accompany a tensor-level diagram.

The older runtime synthesis is a useful explanatory baseline, but its feature
counts come from the target trace. Its retained 22-kernel summary gives a fitted
median absolute error of **26.45%**, or **27.74%** leave-one-out, with fitted
coefficients 2.074 and 17,318.2 cycles. Those numbers do not validate an unseen
workload predictor, prove a physical relay cost or identify the origin of the
offset. Some older “lower bound” terminology also uses assumed costs and inferred
paths; treat those results as model-dependent reference estimates.

## 7. The next experiments, in order

| Priority | Concrete experiment | What would make the model more decisive |
|---|---|---|
| 1 | Matched optimized f16/f32 vector Add/FMA/copy; lengths 7,8,9,15,16,17,32,64; explicit DSR reuse versus reload | Separate first-result delay, group interval, tail handling and descriptor setup; explain the gap between documented maximum width and our two-cycle arithmetic groups. |
| 2 | Register-only f32 multiply/add chains versus independent accumulators, then the same work with stack spills | Isolate the dependencies seen in the tiny GEMM path, without importing f16 rules. |
| 3 | Same/different address and bank, controlled byte placement, simulator plus matched silicon windows | Distinguish visibility, banking and generated-code effects. Include a positive control. |
| 4 | Readiness lengths 9–15 plus additional offsets, followed by passive 1/2/4-hop and turning routes | Constrain receiver-service/blocking models and observe every transit PE. Test multicast separately. |
| 5 | Local repeated access around 256/512/1,024 bytes, with identical arithmetic and checked placement | Investigate the documented cache only after identifying its supported access/control mechanism; a timing knee alone would not prove a cache hit/miss. |
| 6 | Freeze primitive parameters, then predict history-free 4×4/8×8 GEMM/GEMV and an unseen tile/mesh size | Report phase and total residuals and predict a faster mapping before measuring it. |

These extend [the architecture roadmap](ARCHITECTURE_MODEL_PLAN.md), rather than
restarting the already completed readiness work. Keep host transfer, initialization,
kernel and completion windows separate. Keep simulator cycles separate from local
TSC and synchronized cross-PE silicon time. Every prediction needs a validity range;
every unobserved interval needs an explicit unknown or estimated label.

## Reproduction and retained outputs

From this study directory:

```bash
# Local files only: audit selected trace anchors and reproduce estimates/figure.
python3 tools/architecture_model.py
python3 tools/architecture_figure.py

# SDK user-node access, read-only help/API/symbol probes; no workload launch.
PATH=/home/USER/bin:$PATH /software/cerebras/cs_sdk-2.10/cs_python \
  tools/sdk_architecture_probe.py
```

Outputs: [model inputs, parameters and errors](results/architecture-review/estimates.json),
[native tool probe](results/architecture-review/tool-probe.json),
and [standalone SVG](results/architecture-review/datapath.svg).
Raw trace locators and hashes remain attached to the selected evidence. Public
pages were checked on the review date; the versioned debugging guide is explicitly
SDK 1.3 and is used for trace terminology, not installed-tool compatibility.
