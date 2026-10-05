# Two-PE receiver-readiness experiment

Open the [offline comparison](../../results/readiness/readiness.html).
The [evidence JSON](../../results/readiness/readiness.json) contains exact words,
all transfer dispatches, per-element S6 records, packet identities, raw row
references, delay checks, executed IR paths and source hashes.

## What ran

The 2026-09-16 pilot ran **19 serial WSE-3 simulator executions**, covering
**172 numeric words / 344 router observations**, on the SDK user node. It ran
no appliance workload. Application PEs (0,0) and (1,0) map to fabric (4,1) and
(5,1) in a 9×3 simulator fabric. A static color-6 route sends eastward.

The sender uses `@mov32` to send a known f32 array without changing its bits.
The receiver copies it into `buf[]`, then its completion task computes
`res[] = buf[] + loc[]`. Inputs include signed finite values with nonzero low
16-bit halves. The host verifies sender input, received input, local operands,
and every result as uint32 bit patterns. No history stores are added to the
device program; tracing supplies the per-word observations.

The sender's `run()` has a fixed 64-NOP prefix. Receiver prefixes are inserted
into captured LLVM IR, rebuilt under `optnone`, and checked in both disassembly
and dynamic dispatch records. Within a message-length/build group, sender ELF
bytes are identical, input bits are identical, and the receiver's `run()` body
is identical after removing the NOP prefix. Original and rebuilt IR/ELFs remain
available. All inserted NOPs dispatched consecutively in the retained runs.

| Capture group | Message lengths | Receiver NOPs | Repetitions |
|---|---|---|---|
| `try-20260916a` | 8 | 0, 64, 256 | 1 |
| `try-20260916b` | 1, 4, 5, 16 | 0, 256 | 1 |
| `repeat-20260916a` | 8 | 0, 256 | 2 |
| `repeat16-20260916a` | 16 | 0, 256 | 2 |

This is a pilot subset, not the complete length × delay matrix proposed in the
roadmap. Host launch skew varies with length; the viewer reports actual first
receive-minus-send dispatch, rather than assuming synchronized entry to `run()`.
Across delay treatments within each group, receive dispatch shifts by exactly
the inserted NOP count and send dispatch remains unchanged.

## Result: receiver delay can propagate into the observed transmission

All reported units below are simulator cycles. “Completion” means last Add S6
minus first application-send dispatch; it excludes host upload/download and
command completion overhead.

| Words | Receiver NOPs | Receive − send dispatch | Router interval min–max | First–last source-router span | Completion |
|---:|---:|---:|---:|---:|---:|
| 1 | 0 | −15 | 2–2 | 0 | 23 |
| 1 | 256 | 241 | 2–2 | 0 | 261 |
| 4 | 0 | −15 | 2–2 | 3 | 27 |
| 4 | 256 | 241 | 2–2 | 3 | 262 |
| 5 | 0 | −15 | 2–2 | 4 | 29 |
| 5 | 256 | 241 | 2–2 | 4 | 264 |
| 8 | 0 | −16 | 2–2 | 7 | 33 |
| 8 | 64 | 48 | 2–2 | 7 | 71 |
| 8 | 256 | 240 | 2–2 | 7 | 263 |
| 16 | 0 | −62 | 2–2 | 15 | 45 |
| 16 | 256 | 194 | 2–183 | 193 | 228 |

In the delayed 16-word case, per-word router intervals are:

```text
word:       0  1  2  3  4  5  6  7    8    9   10   11  12  13  14  15
interval:   2  2  2  2  2  2  2  2  182  182  183  183   6   6   5   5
```

The 1–8-word messages still have two-cycle router intervals under delayed
receive, while landing-to-receive-S6 intervals grow. With 16 words, the receiver
delay also changes later router observations and stretches the source-router
span. That supports receiver-dependent flow control in this tested path.
The controlled experiment does **not** determine an eight-word physical queue:
these observations cannot partition capacity among injection, transit, receiver
or execution resources. Nor does it prove that all long intervals in GEMM/GEMV
have this cause; their collectives have additional routing and scheduling behavior.

The repeated 8- and 16-word early/late trials have identical value and observation
timings within each repeated treatment. This checks simulator reproducibility,
not silicon variation. There are zero reported discarded events in the captures.

For performance modelling, the immediate implication is to make transfer
completion depend on receiver service as well as message length and distance.
An unconditional “two cycles per hop” cannot explain this delayed 16-word case.
Next, probe lengths 9–15 and additional measured readiness offsets, then repeat
over passive transit routes. Treat queue sizes and internal mechanisms as
hypotheses until those discriminating experiments constrain them.

## Using the presentation

- Select a capture and a word. Five planes show its send S6, source router,
  destination router, receive S6 and Add S6 observations.
- Input `buf[]` and `loc[]` appear beside the mesh with exact-bit tooltips.
  Scrollable arrays keep the selected slot visible. Received operands and results
  remain unknown until their respective observations.
- Click a plane or use the cycle slider to inspect the state. Plane spacing is
  schematic; the comparison chart below uses a proportional cycle axis.
- Compare treatments in the table and inspect every dispatch of an instruction,
  including redispatch, in the audit section. JSON export retains all evidence.

Router landing is not SRAM commit. S6 is an observed value record, not a physical
pipeline-stage claim. The page uses offline HTML/SVG, without WebGL or a CDN.

## Reproduction

On the SDK user node, with no other SDK container job running, use a **new** output
directory. `--execute` explicitly enables the simulator, and the runner shares
the existing walkthrough capture lock:

```bash
python3 microbench/readiness/capture.py --execute \
  --lengths 1 4 5 8 16 --delays 0 16 64 256 --repeat 2 \
  --out results/readiness/new-full-matrix
```

That command is an optional fuller experiment, not the exact pilot executed above.
To rebuild the retained pilot's audit and standalone page without new device runs:

```bash
python3 tools/readiness.py \
  results/readiness/try-20260916a results/readiness/try-20260916b \
  results/readiness/repeat-20260916a results/readiness/repeat16-20260916a
python3 -m unittest discover -s tests -p test_readiness.py
```

On the SDK node, the following independently compares all exposed router fields,
multiplicities and formatted f32 values with the native SDK CTF reader:

```bash
PATH=/software/cerebras/cs_sdk-2.10:/usr/bin:/bin:$PATH \
  cs_python tools/readiness_vendor_check.py
```

All 344 observations agree across the 19 captures. The report is
[vendor_parity.json](../../results/readiness/vendor_parity.json).
Packet identity is checked by the raw-record binder because the native display
API does not expose it. Run `npm test -- tests/readiness.spec.ts` from `viewer/`
for offline word stepping, temporal visibility, export, and desktop/mobile checks.
The four Python audit tests and the browser check of all 172 selected words pass.
