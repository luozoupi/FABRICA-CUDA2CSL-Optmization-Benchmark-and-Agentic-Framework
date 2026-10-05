| Slide claim | Evidence | Caveat | Source |
|---|---|---|---|
| Full xkernel stack reaches 26/28 pass on Opus 4.8. | 26/28 pass, 16 beats-expert wins. | Single-draw full sweep; multi-seed robustness still incomplete. | SWEEP_RESULTS_20260630.md |
| System adds 20 passing kernels over raw one-shot. | 6/28 one-shot vs 26/28 full stack. | Whole-system ablation, not component-wise attribution. | SESSION_PROGRESS_20260702.md |
| Open models still struggle with CSL generation. | Open models range 0-8% on probes and 4-7% on full sweeps. | Different model access and denominators; keep full/probe labels visible. | SWEEP_RESULTS_20260630.md; SESSION_PROGRESS_20260702.md |
| Real WSE-3 hardware execution is now working. | Reference kernels compile and run correctly on ALCF WSE-3. | Some cycle readbacks are partial/suspicious; correctness is solid. | HARDWARE_VALIDATION_20260706.md |
| Profiler feedback improves multi-PE optimization. | Trace-profiled Jacobi improves 11%; GoL improves 28% vs previous best. | Early evidence on two multi-PE kernels; expand to full suite. | HARDWARE_VALIDATION_20260706.md; PROFILING_ARCHITECTURE.md |
