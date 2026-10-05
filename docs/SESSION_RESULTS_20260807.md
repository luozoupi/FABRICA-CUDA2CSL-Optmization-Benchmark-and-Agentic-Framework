# Session results index — 2026-08-06/07

Four studies, one benchmark expansion, and five document corrections. This page
is the index; each study has its own document and machine-readable table.

| Study | Document | Data |
|---|---|---|
| Profiler A/B recount | [`PROFILER_AB_RECOUNT_20260806.md`](PROFILER_AB_RECOUNT_20260806.md) | [`data/profiler_ab_recount.csv`](data/profiler_ab_recount.csv) |
| Excluded-task audit + port | [`EXCLUDED_TASKS_AUDIT_20260806.md`](EXCLUDED_TASKS_AUDIT_20260806.md) | — |
| Newly-enabled agentic sweep | [`NEWLY_ENABLED_SWEEP_20260807.md`](NEWLY_ENABLED_SWEEP_20260807.md) | [`data/newly_enabled_sweep.csv`](data/newly_enabled_sweep.csv) |
| Hardware vs simulator | [`HW_VS_SIM_20260806.md`](HW_VS_SIM_20260806.md) | [`data/hw_vs_sim_full.csv`](data/hw_vs_sim_full.csv) |

---

## Headline numbers

| Result | Value | n |
|---|---|---|
| **Beats-expert on real WSE-3 silicon** | **3.47x geomean** (3.75x on simulator, −7.5%) | 27 kernels |
| Simulator fidelity, agent kernels (hw/sim) | 1.027 geomean, range 0.894–1.563 | 25 |
| Simulator fidelity, reference kernels (hw/sim) | 0.953 geomean, range 0.810–1.087 | 27 |
| Profiler feedback effect on pass rate | +1.3 points (147/370 vs 142/370) | 740 runs |
| Newly-enabled kernels, agentic sweep | 8/9 pass, all beat reference | 9 runs |
| Suite size | 46 → 49 swept kernels | — |

**The single most important result:** the agent's advantage over human-written
CSL survives on real hardware. Every speedup in this project was previously a
simulator measurement; measured natively on silicon the geomean advantage is
3.47x, down 7.5% from the simulated 3.75x.

**The most important caveat:** per-kernel scatter is much larger than the
aggregate shift, and it is worst for the largest speedups. ReLU-1PE drops from
86.6x to 46.2x (−47%) — it is a 142-cycle kernel where fixed costs dominate.
The headline geomean is robust; the single most impressive number in the paper
is the least robust one.

---

## What changed in the benchmark

| | Before | After |
|---|---|---|
| Kernel tasks on disk | 54 | 54 |
| Registered in `KERNEL_REGISTRY` | 50 | 50 |
| In the sweep list | 46 | **49** |
| Measured baselines in `baselines_wse3.json` | 15 | **17** (+ GEMM-1PE, Laplacian2D-Reduce, LorenzoPredictor-Tile) |

Three kernels enabled:

| Kernel | Was | Reference cycles |
|---|---|---:|
| GEMM-1PE | fully scoreable; never in a sweep list | 119,197 |
| Laplacian2D-Reduce | `VERIFY=False` skeleton — NRM reduction predicate inverted against its own layout | 1,950 |
| LorenzoPredictor-Tile | `VERIFY=False` skeleton — row color routed backwards; NW scalar hard-wired to 0 | 1,315 |

Five remain unavailable, each with a documented blocker (WSE-2-only upstream,
no compute surface, fabric-queue exhaustion, missing build dependencies,
non-reproducible hardware RNG). All five use host-bracketed timing, so they
could not have contributed to the hardware study regardless.

---

## Documents corrected

| Document | Correction |
|---|---|
| `HARDWARE_VALIDATION_20260706.md` | **Superseded.** Its "hardware runs ~9% faster" conclusion does not hold; 4 of its 9 numbers are below the dead-timer floor. |
| `PROFILER_AB_RESULTS_20260715.md` | Verdict tallies superseded by the recount |
| `SWEEP_RESULTS_COMPREHENSIVE_20260720.md` | §2.2 / §5.2 tallies superseded |
| `kernels/BENCHMARK.md` | "27 kernels" → 54/50/49; baseline count corrected; simulator caveat added |
| `kernels/baselines_wse3.json` | 3 baselines added; stale `kernels_without_cycle_instrumentation` list refreshed |

---

## Two findings that generalise beyond this project

**1. A timing-instrumentation flaw that is invisible on a simulator.** Kernels
that bracket the timed region with *separate host launches* —

```python
runner.launch("f_tic"); runner.launch("step"); runner.launch("f_toc")
```

— leave the device TSC running across two host↔device round trips. On a local
simulator that costs nothing. On a networked appliance each is a real RPC
(~488 µs here), so the "timed window" measures network latency. Four kernels
were affected; two unrelated ones both landed at ~829,400 cycles, which is the
overhead rather than the kernels. Their *simulator* numbers are unaffected, so
published results stand — but they cannot be quoted for hardware without
re-instrumenting to time inside a single device launch.

Any project publishing simulator cycle counts with host-bracketed timers has
the same latent issue and would not discover it until running on silicon.

**2. Counting "produced a number" as "passed".** The profiler A/B harness
extracted `cycles_send` with no check on `status` or `success_marker`, so its
pass column counted runs that produced a timer reading regardless of
correctness. GEMV was published at 10/10 while having **zero** correct runs in
740 attempts. Any harness that reads a metric field without also reading the
status field can report this.

---

## Tooling added

| File | Purpose |
|---|---|
| `code_translation/hw_vs_sim.py` | Paired hardware/simulator benchmark for one bundle |
| `code_translation/hw_replay.py` | Replays sweep artifacts (or reference bundles) on both targets |
| `code_translation/hw_sim_shim.py` | Lets a kernel's own `run.py` drive the appliance SDK unmodified |
| `code_translation/aggregate_hw_vs_sim.py` | Generates `HW_VS_SIM_*.md` from the result JSONs |
| `code_translation/recount_profiler_ab.py` | Recounts a profiler A/B sweep with correct pass semantics |
| `code_translation/recount_profiler_ab_tally.py` | Aggregates that recount across all three sweep sets |
| `run_cuda2csl_anthropic.sh` | Agent launcher against the Anthropic API directly |
| `run_newly_enabled_sweep.sh` | Sweep for the three enabled kernels |

### Method note: why the kernel's own `run.py` drives both arms

`hw_vs_sim.py` ports each bundle to SDK 2.10 once, then compiles and runs it
**both** ways through the same appliance client, driven by the kernel's own
`run.py` via `hw_sim_shim`. The host sequence is therefore identical on both
arms by construction, so a hardware/simulator delta cannot be an artifact of
different host code — and the `f_enable_timer` launch cannot go missing on one
side, which is exactly how the July 2026 attempt produced its sub-floor
readings. Both arms are checked for the SUCCESS marker and screened against the
same 100-cycle plausibility floor.

### Reproducing

The Cerebras SDK runs under apptainer, which refuses to start when the calling
uid has no `/etc/passwd` entry. `unshare -r` maps the caller to uid 0 in a new
user namespace, which resolves; it creates only a USER namespace, so networking
is unaffected. `run_cuda2csl_anthropic.sh` applies it automatically when needed.

```bash
# hardware vs simulator, one kernel
~/cs_appliance_sdk/bin/python code_translation/hw_vs_sim.py --kernel ReLU-1PE

# replay a whole sweep's artifacts, then the reference bundles
~/cs_appliance_sdk/bin/python code_translation/hw_replay.py \
    --sweep code_translation/results/full_template_sweep_20260722_192305 \
    --arms sim,hw --out code_translation/results/hw_replay_agent_artifacts.json
~/cs_appliance_sdk/bin/python code_translation/hw_replay.py \
    --sweep code_translation/results/full_template_sweep_20260722_192305 \
    --reference --arms sim,hw \
    --out code_translation/results/hw_replay_reference.json

# regenerate the report
python3 code_translation/aggregate_hw_vs_sim.py \
    --agent code_translation/results/hw_replay_agent_artifacts.json \
    --reference code_translation/results/hw_replay_reference.json \
    --out docs/HW_VS_SIM_20260806.md
```
