# xkernel-bench — the kernel-translation + cycle-reduction benchmark

**Version:** v1.1 (2026-08-06)
**Hardware target:** Cerebras WSE-3, SDK 1.4.0
**Scoring:** `fast_p` — see [SPEC_SCHEMA.md](SPEC_SCHEMA.md)

This directory is more than a code library — it's a structured benchmark for evaluating LLM-driven CUDA→CSL translation and pure-CSL optimization on the Cerebras Wafer-Scale Engine. Each kernel has a CUDA reference, a CSL reference (human-written by Cerebras), and (for the 6 cycle-instrumented kernels) a measured cycle baseline. Submissions are scored on `fast_p`: did the agent produce CSL that compiles, runs, passes verification, AND used strictly fewer WSE-3 cycles than the reference.

## Design lineage

xkernel-bench borrows selectively from two prior LLM-for-kernel benchmarks:

- **[NVIDIA/compute-eval](https://github.com/NVIDIA/compute-eval)** — per-kernel `problem-spec.yaml` separating model-visible context from hidden test harness; `pass@k` reporting; difficulty + group tags
- **[ScalingIntelligence/KernelBench](https://github.com/ScalingIntelligence/KernelBench)** — difficulty tiers; `fast_p` metric (`fast_0` = correct, `fast_1` = correct + at-or-better than reference, `fast_2` = ≥2× faster); per-hardware baseline table

xkernel-bench differs by targeting **wafer-scale** rather than GPU, using **cycle count from the kernel's own `tic()/toc()`** rather than wall clock (wall clock is dominated by simulator startup), and adding a **W1/W2 split** (CUDA-source vs CSL-only) so the framework can be evaluated on both translation and pure optimization.

## Suite contents

**54 kernel tasks** on disk (`benchmark-libs/` is the shared CSL library, not a
task). **50** are addressable by the harness via
`code_translation/cuda2csl.py:KERNEL_REGISTRY`; **49** are in the active sweep
list (`run_full_template_sweep.sh`). The table below is the original v1.0
27-kernel core; the remainder are the 2026-06/07 enrichment sets (single-PE ML
ops, multi-PE collectives) plus the three enabled on 2026-08-06. For the
accounting of the 5 tasks that are registered-but-unswept or unportable, and
why, see [`../docs/EXCLUDED_TASKS_AUDIT_20260806.md`](../docs/EXCLUDED_TASKS_AUDIT_20260806.md).

Original v1.0 core, 27 kernels across 7 categories:

| Group | Kernels | Has WSE-3 cycle reference? |
|---|---|---|
| `stencil` | 7-Point Stencil, 25-Point Stencil, Laplacian2D-Halo, Laplacian2D-Reduce | 7-Point Stencil only |
| `gemv` | GEMV, GEMV Checkerboard, GEMV Collectives 2D, Single Tile Matvec | none |
| `gemm` | GEMM, GEMM Collectives 2D | none |
| `linalg` | Conjugate Gradient, Preconditioned CG, BiCGSTAB, Power Method, Cholesky, Residual | 4 of 6 |
| `fft` | FFT 1D-2D, 3D FFT | none |
| `app` | Game of Life, Mandelbrot, Histogram, LorenzoPredictor-Tile, Wide Multiplication, MC-Particle-Transport | none |
| `sparse` | SpMV, SpMV Hypersparse | SpMV Hypersparse uses implicit baseline (no WSE-3 upstream) |

**Cycle baselines** are in [`baselines_wse3.json`](baselines_wse3.json): 17 entries
carry a measured `cycles_send`, and one (SpMV-Hypersparse) is recorded with a null
baseline because upstream ships a WSE-2 build only. Most other swept kernels carry
their reference in their own `spec.yaml` under `wse3_reference`. Three tasks still
have no cycle instrumentation — 25-Point Stencil, 3D FFT and MC-Particle-Transport —
each for a documented reason (see the excluded-task audit).

> **All cycle numbers in this benchmark are SDK simulator measurements.** A paired
> hardware-vs-simulator study is in
> [`../docs/HW_VS_SIM_20260806.md`](../docs/HW_VS_SIM_20260806.md); the gap is
> kernel-dependent and runs in both directions, so simulator cycles should not be
> read as silicon cycles.

## The two workflows

Submissions follow one of two paths, controlled by `cuda2csl.py` flags:

### Workflow 1 — CUDA → CSL (translate, then optimize)

```bash
python cuda2csl.py --kernel 7pt-Stencil --auto-optimize \
    --reviewer-max-attempts 8 \
    --min-optimize-attempts 5 --max-optimize-attempts 10
```

Pipeline: analyse CUDA → architect designs decomposition → implementer writes CSL → benchmark → on first pass, **auto-transition** into the optimize() loop targeting `cycles_send` strictly less than baseline.

The agent sees the CUDA source, the reference contract (`layout.csl`, `run.py`, `commands_wse3.sh`), AND the reference CSL (during the translate phase only — the optimizer's prompt does not include it, to avoid bias toward mimicry).

### Workflow 2 — Existing CSL → optimize only

```bash
python cuda2csl.py --kernel 7pt-Stencil --optimize-only \
    --csl-path "kernels/7-Point Stencil/CSL/src/kernel.csl" \
    --min-optimize-attempts 5 --max-optimize-attempts 10
```

Pipeline: load the CSL at `--csl-path` → benchmark for baseline cycles → optimize() loop. The agent NEVER sees the reference labeled as "reference" — the input CSL is presented as "current code at N cycles, beat this number". This isolates optimization from translation.

The agent DOES see: the task description (from `spec.yaml`), input/output shapes, the launch contract (`layout.csl` + `run.py`). It does NOT see anything in the `hidden_from_optimize_only` list (the reference compute files).

## Scoring (`fast_p`)

For each kernel in a submission:

| Score | Condition |
|---|---|
| `fast_0`   | Agent CSL compiles, runs, passes correctness verification |
| `fast_1`   | `fast_0` AND `agent_cycles ≤ wse3_reference.cycles_send` (parity) |
| `fast_1.1` | `fast_0` AND `agent_cycles ≤ 0.91 × wse3_reference.cycles_send` (≥9% faster) |
| `fast_1.5` | `fast_0` AND `agent_cycles ≤ 0.67 × wse3_reference.cycles_send` (≥1.5× faster) |
| `fast_2`   | `fast_0` AND `agent_cycles ≤ 0.50 × wse3_reference.cycles_send` (≥2× faster) |

Aggregate over a suite as `fast_p_rate` (fraction of kernels meeting the threshold) or `fast_p_mean` (geometric mean of cycles_ref / cycles_agent over passing kernels).

For kernels with `implicit_baseline_from_first_pass: true` (e.g. SpMV-Hypersparse), `fast_p` compares against the agent's own first passing variant rather than a human reference. These kernels measure "can the optimizer iteratively reduce its own kernel's cycles".

## Per-kernel file layout

```
kernels/<kernel_id>/
├── spec.yaml             # benchmark spec — see SPEC_SCHEMA.md
├── CUDA/kernel.cu        # CUDA reference (W1 input)
├── CSL/                  # human-written CSL bundle (reference + launch contract)
│   ├── src/*.csl         # reference compute files (hidden in W2)
│   ├── run.py            # host driver + verification + tic()/toc() prints
│   ├── commands_wse3.sh  # build script
│   └── README.rst        # human prose
└── README.md             # (optional) per-kernel notes
```

Files NOT hidden in W2: `run.py`, `commands_wse3.sh`, `layout.csl` (these describe the launch contract; the agent's CSL must plug into this environment unchanged).

## Reproducing a baseline measurement

```bash
export PATH=$HOME/cs_sdk-1.4.0:$PATH
export CSL_IMPORT_PATH=$(realpath /home/USER/csl-examples/benchmarks/benchmark-libs)
cd /home/USER/csl-examples/benchmarks/<benchmark-name>
bash commands_wse3.sh 2>&1 | grep -E "cycles_send|time_send|SUCCESS"
```

For example, 7pt-Stencil at the standard problem size (width=height=k=5) reports `cycles_send = 2129 cycles` reliably. This is the number stored in `baselines_wse3.json` and in each kernel's `spec.yaml`.

## Adding a kernel to the suite

1. Create `kernels/<NewKernel>/` with `CUDA/kernel.cu` + `CSL/` bundle.
2. Add `--params=...` and `cs_python run.py ...` to `commands_wse3.sh`.
3. Instrument `run.py` with `tic()/toc()` + `print(f"cycles_send = {cycles} cycles")` + `print(f"time_send = {us} us")`.
4. Run `bash commands_wse3.sh` against the upstream Cerebras bundle (if one exists) OR record the agent's own first-pass cycles as the implicit baseline.
5. Add a row to `baselines_wse3.json` with the measured `cycles_send` + `time_send_us`.
6. Author `spec.yaml` per [SPEC_SCHEMA.md](SPEC_SCHEMA.md).
7. Register the kernel in `code_translation/cuda2csl.py:KERNEL_REGISTRY`.

## Status (2026-08-06, updated)

- **54 tasks on disk / 50 registered / 49 swept.** 17 measured baselines in
  `baselines_wse3.json`, plus per-kernel `wse3_reference` values in `spec.yaml`.
- **Every published cycle number is from the SDK simulator.** Real WSE-3 is
  reachable through the SDK 2.10 appliance client; see the hardware-vs-simulator
  study for the measured deltas and for why the earlier
  `results/hardware_validation/*.json` figures should not be used (4 of 9 are
  below the dead-timer floor).
- **W2 optimize-from-reference is strong:** on the 14 cycle-instrumented kernels,
  the agentic optimizer beat the human reference **14/14, geomean 1.44×** (max
  Wide-Multiplication −84.6%, 7pt-Stencil −49.9%, BiCGSTAB −43.1%), independently
  re-verified. The "0 fast_1" line below was true on 2026-06-01 and is now
  **stale** — the framework clears fast_1 broadly at the current (small) sizes.
- **W1 translate-from-CUDA is the open problem:** 2/21 at cap-8; failures are
  layered/information-bound (see `code_translation/results/w1_failure_analysis_20260618.md`).
- **Key caveat driving Phase-2:** all of the above is at ONE tiny size per kernel,
  where only micro-optimization is rewarded (so W2 wins by construction). Phase-2
  adds a problem-size axis (`spec.yaml sizes:`) so the suite can reward
  *decomposition*, plus a leak-free train/test split. See
  `docs/PAPER_METHODOLOGY.md`, `docs/TRANSLATION_QUALITY_DESIGN.md`, and (when
  written) `docs/SPLIT_AND_LEAKAGE.md`.

### Historical (2026-06-01)
- 0 agent submissions achieved `fast_1` as of that date (the cycle-reduction
  optimizer had just landed). Superseded by the W2 14/14 result above.

## Companion docs

- [SPEC_SCHEMA.md](SPEC_SCHEMA.md) — per-kernel `spec.yaml` format
- [baselines_wse3.json](baselines_wse3.json) — measured cycle counts
- [README.md](README.md) — kernel-selection rationale (older doc, kept for context)
- [`../code_translation/REPIVOT_CYCLES.md`](../code_translation/REPIVOT_CYCLES.md) — why we pivoted from correctness-only to cycle reduction
- [`../code_translation/results/saturation_report_and_architecture.md`](../code_translation/results/saturation_report_and_architecture.md) — full architecture reference for the agentic framework
