# Tiny GEMM walkthrough

An executable teaching benchmark and an offline viewer, starting with explicit
scalar multiply/add operations and retaining the actual operands and partial sums.

| Scene | Matrix size | Application mesh | C tile per PE | Contributions |
|---|---:|---:|---:|---:|
| G0 | 4 × 4 | 1 × 1 | 4 × 4 | 64 |
| G1 | 4 × 4 | 2 × 2 | 2 × 2 | 64 |
| G2 | 8 × 8 | 2 × 2 | 4 × 4 | 512 |

G0 loops over `i,j,k` in one PE. G1/G2 use two SUMMA panel rounds: PE `(x,y)`
owns C rows `y*T:(y+1)*T`, columns `x*T:(x+1)*T`; round `s` broadcasts
A from `(s,y)` across the row and B from `(x,s)` down the column. Each PE updates
its own C tile in ascending k order. G0 uses row-major storage; the distributed
cases pack each tile in column-major order. Indices are zero-based.

## Try the existing capture

Open `../../results/gemm-walkthrough/gemm.html` in a browser. It contains the
viewer and evidence, needs no server, and can be copied to a laptop as one file.

1. Choose G0, select C[0,0], and step through sums **1, 1, 7, 11**.
2. Choose G1 and C[2,2]: owner PE (1,1), sums **27, 47, 58, 58**.
3. Inspect the A/B panels in each round, their source PEs, and local-buffer offsets.
4. Open Assembly, Timeline, CSL, and LLVM IR. Click an instruction to inspect its
   operand/result bits and raw trace row references.
5. Try G2, select any output, and compare the eight partial sums with simulator
   history and the final output.

The first complete six-run capture is in
`results/gemm-walkthrough/try-20260914d/`, relative to the study root.
Earlier `try-*` directories retain incomplete diagnostic attempts and are not
the source of the packaged demo.

## Reproduce

From the study root, create sources without running anything:

```bash
python3 microbench/gemm_walkthrough/generate.py --help
python3 microbench/gemm_walkthrough/capture.py --cases g0
```

Run on the SDK user node, serially. The output directory must be new:

```bash
ssh user-node-1
cd /home/USER/xkernel/studies/wse3-characterization
python3 microbench/gemm_walkthrough/capture.py --execute \
  --out results/gemm-walkthrough/my-capture
```

This runs the WSE-3 **simulator**, including a history-enabled and history-free
control for every scene. It does not submit a hardware job. It uses SDK 2.10,
the installed SIF, and the existing IR capture/rebuild, disassembler, and CTF
decoder tools. A lock prevents concurrent walkthrough captures; avoid running
other SDK jobs on the same user node during capture.

Export and build the viewer:

```bash
python3 study.py viz-export --captures results/gemm-walkthrough/my-capture \
  --out viewer/public
cd viewer
npm ci
npm run build
python3 build_standalone.py
```

For live development, run `npm run dev` and forward its localhost port over SSH.
Omit `--captures` to export reference-only scenes with no fabricated measurements.

## Evidence and limits

- Every history contribution records A, B, old C, new C, and a local timestamp.
  The exporter independently recomputes all terms, final outputs, and panel
  contents. Small integer inputs make these f32 comparisons exact.
- The teaching `gemm` function is rebuilt with `noinline optnone`. Both the
  original and executed ELF/IR are retained. These are deliberately explicit
  scalar operations, not an optimized production GEMM performance claim.
- ELF load-segment tile IDs bind application coordinates to binaries. ELF
  filenames are program identifiers and must not be interpreted as PE coordinates.
- A term is linked to FMULS/FADDS only when the full ordered operation counts,
  execute-stage operand bits, results, and checked history agree. The viewer
  retains eight neighboring instructions on either side as context; those
  neighbors are not individually claimed as semantic memory operations.
- Local TSC ticks start independently on each PE. Trace cycles use a different
  origin. The exporter never uses TSC values to filter the trace. History/control
  duration comparisons use each PE's own elapsed timer interval.
- Panel readbacks verify values available on each destination PE. Animated/logical
  routes do not establish which raw packet carried an element. Raw fabric rows
  shown in the viewer are application-PE observations on colors 0, 1, 4, and 5;
  the complete decoded trace remains in the capture directory.
- No silicon counters, internal forwarding paths, queue residence times, or
  absolute load/store addresses are inferred from the mathematical diagram.
- SHA-256 manifests bind sources, IR, ELF, runtime configuration, readbacks,
  disassembly, and raw/decoded traces. Export rejects changed or missing hashed
  files. Detailed trace context is intentionally smaller than the raw capture.

## Validation

```bash
python3 -m unittest tests.test_gemm_viz tests.test_cli
cd viewer
npx playwright install chromium
npm test
```

The browser tests use the built viewer and packaged HTML. They check linked
selection, partial sums, PE ownership, all-scene instruction counts, reload
bookmarks, desktop/mobile rendering, and offline loading without HTTP requests.
Linux needs Chromium's usual runtime libraries. On this ALCF login node, isolated
libraries were installed under `~/.cache/gemm-browser-deps`; tests can use
`LD_LIBRARY_PATH=$HOME/.cache/gemm-browser-deps/lib npm test`.
