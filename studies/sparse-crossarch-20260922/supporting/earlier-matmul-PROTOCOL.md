# Matrix implementation microbenchmarks, version 1

This is a controlled, deterministic implementation study, separate from the agent-generation experiments. No model API is called. The input teaching page is `../matmul-7ways.html`; its default 4 × 4 matrices are used in the dense debug builds. The page's seven views are not seven independent algorithms: column GEMV expands to column AXPY, row-vector multiplication expands to row AXPY, and blocking adds a level of traversal.

## Questions and controls

1. How do the six scalar loop orders compare using the same natural FP32 multiply-add expression? Fusion is a compiler decision. A separate one-element descriptor FMA provides a control for the whole-row descriptor FMA, so instruction fusion is not silently attributed to loop order or vector width.
2. How does a descriptor row update compare with a descriptor column update under row-major and column-major storage?
3. How do a descriptor dot-product reduction and local blocking compare with whole-row descriptor updates?
4. For CSR SpMV/SpMM, when does output width amortize descriptor setup and sparse index traversal?
5. Do 16-bit local row offsets and indices reduce cost relative to 32-bit storage on these bounded inputs?
6. Does gathering irregular SpMV vector entries into a contiguous scratch vector pay for itself within a single use? Gathering is included in the timed kernel.
7. For masked AᵀA, how does merging sorted index lists compare with nested matching? Numerical values and structural presence are both checked.

The dense sizes are 8 × 8 × 8 and 16 × 16 × 16. Sparse A is 16 × 16, with dense output widths 1, 4 and 16. Width 1 is SpMV; larger widths are SpMM. Banded, uniform and skewed patterns are deterministic; the skewed pattern includes empty and full rows. They are synthetic matrices. All variants within a comparison receive identical logical inputs, including changed-input sessions. `configurations.json` is the complete build inventory. Failed compilation or execution remains a reported failure.

## Timing and correctness

All new builds use **one application PE**, at fabric coordinate (4,1), inside an 8 × 3 simulator fabric. Input arrays are already in PE SRAM when device timing starts. The interval includes output clearing, required scratch preparation, traversal, arithmetic, and device timestamp overhead. All descriptor calls are synchronous. The stop timestamp occurs after completion. Host input preparation, copies and command submission are excluded from device cycles and recorded separately. The current host preparation field includes the oracle calculation and must not be interpreted as production preprocessing cost.

Each performance input session has one checked warm-up and three checked measurements. The same loaded program receives original inputs, changed values and column positions, and the original inputs again. Every output is checked against a separate float64 matrix oracle; the small integer data makes the expected FP32 arithmetic exact. Masked multiplication also checks the presence mask. Both raw 48-bit timestamps and cycle differences are saved. Empty timestamp intervals are measured separately and are **not subtracted**. Report median and range; deterministic simulator repetitions do not establish hardware uncertainty.

No clock frequency is assumed and no simulator cycles are converted into measured hardware latency. A single PE avoids cross-PE clock-alignment assumptions. This study does not measure wafer-scale throughput, network contention, or end-to-end host latency.

## Debug dataflow

Separate 4 × 4 debug builds record output snapshots after each scalar FMA, row/column descriptor update, complete descriptor dot product, or matched sparse term. The journal metadata names the loop indices and descriptor extent. The host reads the journal and verifies every snapshot by recomputing the specified updates. Journal builds retain simulator traces. Their instrumentation changes execution, so **their times are excluded from the performance table**.

The microbenchmark viewer displays these saved values as semantic steps, not as individual hardware cycles. The existing “Verified WSE-3 simulator runs” pane continues to show instruction/wavelet records, including actual multi-PE broadcasts and reductions. The two views distinguish local SRAM traversal from movement between PEs.

## WSE interpretation

A C tile belongs to a PE. Within that PE, loop order and DSD extent control local loads, accumulator updates, and instruction setup. A stationary operand must be described at a stated scope: all the single-PE inputs here are preloaded, so a loop label alone does not prove a different communication schedule or eliminate host transfers. Multi-PE SUMMA adds row and column broadcasts; partitioned GEMV adds reductions. Those are separate algorithmic choices.

The official [DSD reference](https://sdk.cerebras.ai/csl/language/dsds) explains vector extents, strides, and type-aware offset increments. The [GEMV tutorial](https://sdk.cerebras.ai/csl/tutorials/gemv-02-memory-dsds) provides a single-PE column-update example. These establish programming semantics; measured results from this batch establish only the behavior of the saved builds and inputs.

## Provenance and hardware replay

Source and host hashes, compile/run commands, ELF files, input hashes, raw output arrays, timestamps, and failures are retained. The framework checkout remains at `c7ad437d80de5b3f077a15576cfbaca18112e657`; the latest reviewed remote tip is `b48041e`. This standalone study does not merge or change the other node's active framework or manuscript work.

The runtime host supports `--cmaddr` and an alternate compiled `--name` for installations using SdkRuntime. The WSE node must compile or deploy through its actual SDK cluster workflow, record the compiler/system identity, and write results to a separate output file with `--output`. Appliance-mode submission needs the site's launcher adapter; simulator binaries alone do not establish that deployment is supported. Keep hardware results separate until the exact deployment and timing scope are verified.
