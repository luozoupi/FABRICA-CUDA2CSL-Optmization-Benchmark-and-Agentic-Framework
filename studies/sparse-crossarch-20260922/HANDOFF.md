# NVIDIA-node handoff to the WSE-3 node

## Revisions and ownership

Checked/fetched framework shared tip **b48041ef6787568ec66bf294efac2d001e8c6d83**; NVIDIA-node framework **c7ad437d80de5b3f077a15576cfbaca18112e657**. Paper local/remote **d1f9e720642fd030f0a7e1ec8334975ceeb4a99e**. Framework branch is ahead 8 / behind 8; no automatic merge, branch switch, manuscript edits or model experiments were made in this characterization batch.

New standalone directory: `/home/USER/sparse-crossarch-20260922/`. The generated `handoff-manifest.json` contains source/configuration/result hashes and final cell status. The original experiment version and the four-case capacity amendment are separate. This is deterministic benchmark evidence, not an agent capability result.

For transfer, use `wse-hardware-replay.tar.gz` and `hardware-bundle-manifest.json`. This compact archive contains the exact WSE builds and inputs, checked output copies and comparison tables. It omits the large raw GPU output archive and binary profiler reports, which remain on this node. Extract into a new directory before hardware replay.

## Completed evidence

The [result tables](RESULTS.md) and [audit](audit.json) give authoritative accepted/rejected counts. GPU work comprises 124 workload configurations, seven implementation choices where applicable, plus two repeats of seven selected cases. Primary results accept 804 implementation cases and reject 41 numerical cases. All rejected GPU cases concern HB/bcsstk08 under the unchanged componentwise gate; do not quote their performance. Independent outputs, raw API-call timing samples, executable/source hashes, memory checks and Nsight reports are retained.

The twelve new CSL configurations compile for one WSE-3 application PE. Full validation acceptance is listed separately in `wse-summary.json`; wide/long-running simulator cases hit the 360-second wall-time limit and must not be cited as correct from compilation alone. In completed width-1/4/16 descriptor tests, explicitly hoisting the output descriptor gives no cycle gain. At width 16, the compiler emits the same loop; this is a useful null optimization example. Final pending/running state is recorded in the manifest rather than inferred from existing output files.

## Hardware replay requested

1. Copy the study to a **new hardware output directory**, preserving source/input/build hashes and this batch's results. Start with completed width-1/4/16 scalar/descriptor cases. Record exact SDK/compiler identity, actual device clock, hardware job configuration and command. Use the node's established hardware launcher; `wse_host.py` supports `--cmaddr` for environments that use that interface. It writes observations relative to its working directory, so never run it in the original result directory.
2. Replay the compiled width-64 cases with their full validation sessions. They contain changed values, changed column indices, empty rows and long rows, and clear poisoned output on every session. A simulator timeout is a resource limitation of this run, not permission to skip correctness.
3. For distributed SpMV/SpMM, compare equal-row grouping with a capacity- and locality-aware balanced grouping. Preserve output ownership or explicitly account for partial-result reductions. Nonzero balance alone is insufficient. Add row/output initialization work and distinct B demand to the partition features.
4. Measure local compute and complete fabric makespan independently, with clock alignment and completion checks. The official hypersparse SpMV example offers a clock-reference mechanism; use the established WSE-3 frequency, not the older example's frequency conversion. Report required operand distribution and preprocessing at 1, 10 and 100 uses.
5. Send back exact input IDs/hashes, compiled build IDs/hashes, all attempted configurations, raw per-PE timestamps, validation logs, communication scope, measured clock and failed/infeasible cases. This node can audit returned outputs and update the explorer without modifying the manuscript.

## Findings suitable for further study

- GPU row caching reduces load requests but increases instructions and can lose; width and footprint alter the ranking. Avoid treating GE's staging as a universal CSL transformation.
- Band/block structure changes GPU behavior and WSE distribution needs even where resident one-PE descriptor cycles are identical.
- Balancing the skewed 65,536-row matrix across 16 PEs lowers the predicted maximum/mean nonzero ratio from 8 to 1 but triples B-row replication. Rebalancing the already balanced banded input increases replication nearly eightfold without a compute-balance gain. These are static predictions pending hardware measurement.
- Compiler feedback should identify when source transformations leave the executed loop unchanged.
- Numerical cancellation needs a preregistered accuracy contract and stronger-accuracy candidates; excluded faster results are not successes.

Keep the manuscript distinction centered on an evaluated generation/selection method and measured limits. Existing CS-3 sparse work already covers large matrices; these local studies alone do not support a general WSE-versus-GPU speedup claim.
