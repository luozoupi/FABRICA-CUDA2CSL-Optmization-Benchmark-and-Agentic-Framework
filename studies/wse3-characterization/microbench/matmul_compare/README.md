# Controlled matmul comparison and trace replay

Open [the WebGL comparison](../../results/matmul-compare/matmul.html). Full
results and interpretation are in [MATMUL_COMPARISON.md](../../MATMUL_COMPARISON.md).

This follow-up keeps the original `microbench/matmulorder` capture intact and
changes two implementation details explicitly: accumulating reduction semantics,
and B packing for a blocked `@map` kernel. All kernels run on one application PE
(fabric 4,1), use f16, and perform the same n³ mathematical MACs. Twelve variants
include eleven correct implementations and one intentionally incorrect control.

`generate.py` derives sources from the retained generator into new directories.
`run.py` uses deterministic integer inputs in [-2,2], for which these f16 products
and sums are exact, then checks every output with exact equality. It records all
inputs, outputs, 48-bit timer endpoints, and four invocations (one warmup and
three timed). It excludes zeroing/saving C and host I/O from the kernel interval.
B packing happens on the host and is excluded; the retained host duration is a
single sample, not an end-to-end performance claim.

`capture.py` runs serially on the SDK user node, capturing compiler IR, ELFs,
disassembly, logs and hashes. 4×4/8×8 runs retain CTF and decoded instruction
traces; the 32×32 timing run suppresses traces. Sources and optimization are not
rewritten to optnone. No hardware job is submitted.

```bash
ssh user-node-1
cd /home/USER/xkernel/studies/wse3-characterization
PATH=/software/cerebras/cs_sdk-2.10:/usr/bin:/bin:$PATH \
  python3 microbench/matmul_compare/capture.py \
  --root results/matmul-compare/new-capture --sizes 4 8 32
```

Use a new capture root. The native container runtime must precede the login-node
relay wrapper on PATH. Each subprocess has a timeout; the capture lock prevents
concurrent instances of this campaign.

Build and inspect from the study directory:

```bash
python tools/matmul_compare.py --root results/matmul-compare/try-20260922a
npm --prefix viewer run build:matmul
python viewer/build_standalone.py --dist dist/matmul --page matmul.html \
  --bundle matmul-bundle.json --global-name MATMUL_BUNDLE \
  --out results/matmul-compare/matmul.html
python tools/dataflow_server.py --static viewer/dist/matmul --port 8766
```

The server exposes `/api/matmul` and `/matmul.html`. The exported HTML works
without network access. Run the Python tests in `tests/test_matmul_compare.py`
and browser tests with `viewer/playwright.matmul.config.ts`.

The debug exporter checks the entire ordered floating-point dispatch stream,
vector lengths, and each captured operand/result for the non-scalar variants
across all four invocations. It preserves UID, PC, lane, cycle, and raw row links.
The displayed trace is the first invocation, which was the warmup. The scalar
compiler can reorder operations, so its teaching steps have no cycle binding.
No displayed memory offset is claimed to be a trace-observed load/store address.
