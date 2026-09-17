# Performance-model runtime

Extracted from the original WSE-3 characterization study for use by `wse3_model.py`.
Includes trace decoding, instruction profiling, fabric extraction, bottleneck
classification, and runtime estimation. `runtime_fit.json` retains only the original
fitted coefficients and calibration sample count, not per-kernel result artifacts.

The optional `XKERNEL_WSE3_STUDY_ROOT` override must point to the same runtime layout.
The reference notes are in [docs/PERFORMANCE_MODEL.md](../../docs/PERFORMANCE_MODEL.md).
Microbenchmarks, build outputs, raw traces, and study presentation tools are omitted.
