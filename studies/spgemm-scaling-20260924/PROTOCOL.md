# Registered SpGEMM size and PE sweep

Origin: NVIDIA GPU node, Cerebras SDK 2.10.1 simulator, WSE-3 target. Framework base `3c7e9f383fa1874f24c633f27d64cf1dadec5346`; sparse branch `7413ed46fa0f572f4b46e7fd9b7056462a31a770`; manuscript `bb7f61ad30873f64ebca758101f5e03d313c37d9`. The manuscript is unchanged. These deterministic reference implementations are separate from agent/model experiments.

## Design

- Strong scaling: square matrices of size 16, 64, and 256, with 1, 4, 16, and 64 application PEs, using square PE grids. Omit configurations with more PEs than rows. Input matrices stay identical across PE counts for a given size, degree, structure, and changed-input state.
- Primary degree: three entries per row in B and in regular A. Banded and uniform A have fixed row degree. Skewed A has clustered long and empty rows; its degree is stated separately rather than described as uniformly three.
- Two fixed implementations: full output-row accumulator; a bounded accumulator of four slots at size 16 and sixteen slots at sizes 64 and 256. The bounded form repeats traversal for each output tile. The selected subset of size/PE comparisons is explicitly frozen in `registration.json`; absent variants are not failures or measured ties.
- Density control: size 64, eight entries per row, full accumulator, four PE counts.
- Weak scaling: four rows per PE, fixed inner and output dimensions of 64, fixed degree three, full accumulator. A grows with the PE count; the replicated B and local output-row count remain fixed. This is rectangular row scaling, not square weak scaling.
- Rows stay whole. Compare contiguous equal-row blocks with a deterministic assignment that balances candidate-product counts under the same row quota. This cannot divide the work of a single long row among PEs. Balanced assignment is tested on skewed inputs with more than one PE.
- Every session uses one warmup and three measured launches. Changed-input and restored-input sessions test reuse. All launches are checked; warmups are excluded from timing medians. No input or implementation is selected using the resulting speed.

## Dataflow and timing

The host packs complete CSR rows of A onto assigned PEs. Only PE (0,0) initially holds B; all receiver B buffers are poisoned. The SDK `collectives_2d` library broadcasts B along the top row and then down every column. Each PE builds CSR output for its assigned rows. Numerical contributions for one output row do not cross PEs. The host validates row ownership, sorted indices, values, structural zeros after cancellation, and untouched output guards. It also reads back all received B words and checks them independently of the numerical result.

Every launch begins with a causal broadcast from the root and ends with column reductions of unit acknowledgements followed by a top-row reduction. The root must receive exactly P. The reported distributed interval is the root's own end-minus-start timestamp. It includes the start/B broadcast, computation and waiting, and completion reductions. It does not subtract timestamps from different PEs. Per-PE compute and preparation intervals likewise use same-PE differences only. Their maxima and means describe local work, not a synchronized global span.

The resident-data control broadcasts one word to start computation with previously distributed B. It retains the same completion reductions. The communication-only control uses the complete B payload and acknowledgements but skips the kernel. Report these controls separately; do not subtract them to assert additive communication percentages because phases can overlap across PEs.

Host packing, input transfers, output transfers/gathering, initial library setup, and compilation are outside device timing. Host wall times are recorded separately. The output is distributed CSR with preallocated capacity; no global CSR gather or dynamic output allocation is timed. Consequently this is not an end-to-end library comparison.

## Capacity and correctness

Input indices and row pointers are 32-bit storage with checked conversion to 16-bit local offsets. The output allocation uses a conservative bound: sum over local rows of min(output columns, candidate-product count). This does not require knowing the output sparsity pattern. Capacities are fixed at the maximum needed across the registered sessions/assignments for each build. Four guard entries follow output index and value buffers.

Declared application arrays exceeding 48 KiB are recorded as capacity exclusions for this implementation. Passing that check does not guarantee fit: compiler, collective, stack, and library memory also matter. Compiler failures remain recorded separately. Replicating B imposes a scaling limit even when local A/C storage shrinks. Accumulator-byte savings must not be described as total PE-memory savings.

An independent sparse dictionary oracle uses FP64 accumulation. Values are small exactly representable signed integers, and exact comparison is required. An offline check compares that oracle to dense FP64 multiplication for the studied dimensions. All source/configuration hashes, measured ELF hashes, raw per-PE timestamps, assignments, product/output counts, and failed attempts are retained.

The four-PE development smoke is excluded from the registered results. Its initial compile failed because an array initializer used a tuple literal; the corrected source uses typed zero arrays and explicit runtime initialization. No experiment data informed that syntax correction. The installed collective module also fails to compile with a dimension of one because two switch cases coincide. The one-PE build therefore uses a local callback adapter with the same stage sequence and no fabric traffic. A first attempt at conditional module import was rejected by CSL; source generation now selects the module path explicitly. All three failed development compiles are retained. Multi-PE builds use the installed SDK collective module unchanged.

## Resource limits and interpretation

All SDK operations use both shared local locks. Limits are 600 seconds per compilation, 2,400 per complete case run, and 600 seconds waiting for the SDK lock. Preserve partial checkpoints and all timeouts. A failed case may be corrected only through a recorded amendment with unchanged original evidence; do not silently overwrite results.

Sixty-four PEs is the upper bound of this SDK sweep. Physical WSE runs, 256 PEs, large real-world matrices, distributed B ownership, splitting heavy rows, floating-point error sensitivity, and GPU library comparisons remain later work. Scaling speedups use the same implementation, matrix, and timing scope. If a one-PE point is infeasible, do not manufacture a speedup relative to it. Matrices here isolate structure and memory/communication effects; they do not establish performance for production-scale SpGEMM.
