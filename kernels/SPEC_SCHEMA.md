# FABRICA-BENCH — per-kernel spec format

**Format:** YAML, one `spec.yaml` per `kernels/<name>/` directory.
**Scope:** describes what a kernel does, how it's measured, and what the agent is allowed to see.
**Design lineage:** borrows from [NVIDIA compute-eval](https://github.com/NVIDIA/compute-eval) (per-problem `problem-spec.yaml`, visible/hidden split) and [Stanford KernelBench](https://github.com/ScalingIntelligence/KernelBench) (difficulty tiers, `fast_p` scoring, per-hardware baseline table).

The spec exists so the framework knows two things it currently has to infer from the directory layout: **(a)** what the kernel is supposed to do (so the agent can be evaluated on tasks rather than on reading the reference CSL); and **(b)** how fast the human-written reference runs on the target hardware (so cycle reduction can be measured rigorously).

---

## File location

```
kernels/<kernel_id>/
├── spec.yaml             # this file
├── CUDA/kernel.cu        # the CUDA source (FABRICA-BENCH input)
├── CSL/                  # the human-written CSL bundle (reference, hidden from workflow-2 agent)
│   ├── *.csl
│   ├── run.py            # host driver — its tic()/toc() prints define cycles_send
│   ├── commands_wse3.sh  # build script (cslc invocation + cs_python launch)
│   └── README.rst        # human prose; not parsed by the framework
└── README.md             # (optional) kernel-specific notes for humans
```

## spec.yaml schema

```yaml
# Required fields
kernel_id: "7pt-Stencil"                  # matches kernels/<dir>/ name (kebab/Pascal-Case ok)
group: "stencil"                          # one of: gemv | gemm | stencil | linalg | fft | reduction | app
difficulty: 2                             # 1 = single-tile / no fabric routing
                                          # 2 = multi-PE with collective + routing
                                          # 3 = full application (multi-kernel pipeline)

tasks:                                    # 1-3 sentence task description (workflow 2 sees this)
  - "Compute y = A * x for a 3D 7-point stencil operator, where A is a
     row-distributed sparse matrix and x is a 3D scalar field with z-dimension k."
  - "Row-reduce partial products across PEs in each row."
  - "Output y on the leftmost column of the PE rectangle."

inputs:
  - {name: "A_coeffs", shape: "[width, height, k, 7]", dtype: "f32",
     description: "7-point stencil coefficients per PE"}
  - {name: "x", shape: "[width, height, k]", dtype: "f32",
     description: "input 3D field, distributed by PE rectangle"}

outputs:
  - {name: "y", shape: "[width, height, k]", dtype: "f32",
     tolerance_abs: 1e-5, tolerance_rel: 1e-5,
     description: "y = A * x; verified against host NumPy reference"}

# Problem-size axis (Phase-2, 2026-06-20). A kernel runs at one or more named
# sizes. `small` is the tiny CI/correctness config; `large` is the size at which
# decomposition is the only way to run (forces multi-PE, or a single-PE/naive
# variant overflows ~48 KB/PE SRAM). This is what lets the suite REWARD better
# decomposition rather than only polished idioms. Each size carries its own
# params, its own build command, and its own reference cycle baseline.
sizes:
  - name: small
    role: correctness                     # CI / sanity; baseline for fast_p at this size
    params: {width: 5, height: 5, MAX_ZDIM: 5, BLOCK_SIZE: 2, m: 5, n: 5, k: 5}
    commands_script: "commands_wse3.sh"
    wse3_reference: {cycles_send: 2129, time_send_us: 2.5047}
  - name: large
    role: decomposition                   # the size where decomposition matters
    params: {width: 5, height: 5, MAX_ZDIM: 40, BLOCK_SIZE: 2, m: 5, n: 5, k: 40}
    commands_script: "commands_wse3_large.sh"
    wse3_reference: {cycles_send: null, time_send_us: null}   # measured by WS1.2 crossover

# Per-pair classification (Phase-2). Governs the train/test split + which kernels
# count as real translation tasks. See code_translation/FIREWALL.md.
#   real-translation : CUDA explicit compute -> CSL explicit compute (a real task)
#   library-wrapper  : both sides just call a library (e.g. cuFFT <-> SDK fft lib) -> quarantined
#   algorithm-level  : requires re-deriving the algorithm, not a line-by-line port
#   program-level    : CUDA is MULTIPLE data-dependent kernels (a pipeline); the
#                      agent must translate the whole program + its intermediate
#                      buffers, not one kernel. Document the data-flow in `stages:`.
task_class: "real-translation"
split: "train"                            # train | test (held-out); see code_translation/FIREWALL.md

# OPTIONAL — input-level train/test split (2026-06-24). Defends against
# answer-hardcoding: the agent is shown run.py (the host-side contract), which
# contains BOTH the input construction and the reference-answer computation. If the
# input is deterministic, a kernel can reproduce the answer WITHOUT computing it
# (this is how the Cholesky stub false-passed). Fix: run.py draws its input from a
# seed read at run time; the harness re-scores correctness on HELD-OUT seeds the
# agent never saw. A hardcoded answer passes the train seed but fails the held-out
# seeds. Requires: (a) run.py reads `os.environ[seed_env]` (default = train_seed),
# (b) the reference answer is recomputed from the drawn input every run (true for
# all current kernels — np.dot / np.fft / b-A@x / etc.). Enforced by the harness
# only when XKERNEL_HELDOUT_EVAL=1. Absent `eval:` => no held-out gate (back-compat).
# FIREWALL: heldout_seeds are HARNESS-ONLY — spec.yaml is never injected into a
# prompt, so the values stay hidden (asserted by test_no_compute_leak.py).
eval:
  train_seed: 7                          # the seed baked into run.py (agent may see this)
  heldout_seeds: [101, 202, 303]         # harness-only; correctness must pass on ALL
  seed_env: "XKERNEL_EVAL_SEED"          # env var run.py reads (default = train_seed)

# OPTIONAL (program-level tasks only): the pipeline's data-flow. Each stage reads
# the buffer the previous stage wrote. Absent => single-kernel task (the default).
# stages:
#   - {name: "make_gridkern", out: "gridkern[g][a]", reads: "mo_grid", formula: "..."}
#   - {name: "make_buf",      out: "buf[g][b]",      reads: "gridkern, cascm2", formula: "..."}
#   - {name: "make_Pi_final", out: "Pi[g]",          reads: "gridkern, buf",    formula: "..."}

# WSE-3 reference baseline — DEPRECATED top-level form (kept for back-compat).
# New specs put per-size baselines under `sizes:`. Loaders treat a bare
# `wse3_reference`/`params` as sizes:[{name: default, ...}].
wse3_reference:
  cycles_send: 2129                       # see kernels/baselines_wse3.json
  time_send_us: 2.5047
  upstream_source: "csl-examples/benchmarks/7pt-stencil-spmv"
  params: {width: 5, height: 5, MAX_ZDIM: 5, BLOCK_SIZE: 2, m: 5, n: 5, k: 5}

# Build + verification commands (the agent's CSL must remain compatible with these)
build_command: "bash commands_wse3.sh"
verify: "embedded in run.py (asserts |y_ref - y_wes| == 0 or under tolerance)"

# Workflow 2 visibility control: what the agent IS NOT allowed to see
hidden_from_optimize_only:
  - "CSL/src/kernel.csl"                  # the reference compute file
  - "CSL/src/*.csl"                       # any other compute file in the bundle
  # NOTE: layout.csl, run.py, commands_wse3.sh are NOT hidden — they
  # describe the launch environment the optimized CSL must plug into.

# (optional) tags for filtering / scoreboards
tags:
  - "iterative"
  - "fabric_collective_row_reduce"
  - "z_dimension_loop"

# (optional) for kernels with no WSE-3 reference (e.g. SpMV-Hypersparse)
# Use: implicit_baseline_from_first_pass: true
# Meaning: the optimizer takes the agent's own first passing variant's
# cycles_send as the baseline; "beat the baseline" then means beat itself.

# (optional) contract validator — per-kernel overrides
# When the optimizer accepts a variant with strictly fewer cycles, a
# post-benchmark validator first checks that the variant didn't game the
# cycle metric by editing the timing-capture functions or by shadowing a
# host-supplied param. The defaults (in code_translation/contract_check.py)
# cover the standard Cerebras run.py pattern. Override here if a kernel
# uses non-standard function or param names.
frozen_functions:
  - "f_tic"
  - "f_toc"
  - "f_memcpy_timestamps"
  - "f_reference_timestamps"
frozen_params:
  - "BLOCK_SIZE"
  - "MAX_ZDIM"
  - "STARTUP"
  - "width"
  - "height"
  - "memcpyParams"
  - "reduceParams"
  - "stencilParams"
```

## Timing protocol `device_internal_v2`

```yaml
timing_protocol: device_internal_v2   # multi-PE references re-instrumented 2026-09-08
```

The reference stamps its own window on-device: `f_tic_dev()` is the first
statement of every host-launched entry point (an exported `fn` other than the
timing helpers) and `f_toc_dev()` immediately precedes every
`sys_mod.unblock_cmd_stream()` outside the helpers. The runner no longer
launches `f_tic`/`f_toc`, so simulator and WSE-3 cycles are comparable
(host launches cost ~488 us of RPC on hardware). Enforcement:
`contract_check` rule 4 (structure-agnostic: an agent program may end its work
in a different task than the reference, but every entry point must start with
the start stamp and every host unblock must be preceded by the end stamp; the
two helper bodies are frozen) and `check_timing_integrity.check_device_window`.
`code_translation/timing_protocol.py` holds the shared check and a mechanical
instrumenter for programs written for the old protocol.

## Optimization angles, precision contract, and angle gates

```yaml
# (optional) whitelist of optimizer angles for this kernel. Names come from
# code_translation/prompt_cuda2csl.py:CSL_OPTIMIZATION_STEPS_CATALOG. When
# absent, the launcher's --steps list (default: the 6 generic angles) is used.
optimization_angles:
  - fmac_bulk
  - dsd_offset_chaining
  - dsd_width_flatten_l0      # model-derived (see below)

# (optional) precision contract. f16_precision is admitted only when the task
# allows internal f16 arithmetic or its I/O is already f16; exported symbol
# types and the host I/O never change.
precision:
  io_dtype: f32               # f32 | f16
  accumulate: f32
  allow_f16_internal: false
```

Under `XKERNEL_MODEL_ANGLES=1` (default when `XKERNEL_MODEL_GUIDED=1`) the
model-derived angles in `MODEL_CSL_OPT_STEPS` are appended to whichever
whitelist applies. Angles carry gate flags that
`CUDA2CSLOrchestrator._filter_angles` enforces and records under
`angles_denied` in `optimization_summary.json`:

| Flag | Meaning | Admitted when |
|---|---|---|
| `requires_precision_ok` | changes internal arithmetic precision (`f16_precision`) | `precision.allow_f16_internal: true` or `precision.io_dtype: f16` |
| `hardware_validated` | the simulator cannot observe the effect (`bank_class_offset`) | `XKERNEL_HW_ANGLES=1` (hardware acceptance) |
| `codesign_only` | needs an editable `layout.csl` (`turn_free_routing`) | `XKERNEL_CODESIGN_LAYOUT=1` |

`XKERNEL_ANGLE_DENYLIST=a,b` removes angles from any whitelist (used by the
O1S ablation arm).

## Required vs optional

**Required for workflow-1 (CUDA→CSL translate, then optimize):**
- `kernel_id`, `group`, `difficulty`
- `tasks` (used in implementer prompt augmentation)
- `inputs`, `outputs` (correctness contract)
- `wse3_reference.cycles_send` if measurable (else `implicit_baseline_from_first_pass: true`)
- `build_command`

**Required for workflow-2 (existing CSL → optimize only):**
- All of the above PLUS
- `hidden_from_optimize_only` (list of paths the agent must NOT see)

## fast_p scoring (FABRICA-BENCH's success metric)

A submission for a kernel reports a single `fast_p` value:

| fast_p | Meaning |
|---|---|
| `fast_0`   | Generated CSL compiles, runs, and passes the correctness verification |
| `fast_1`   | `fast_0` AND `agent_cycles ≤ wse3_reference.cycles_send` (parity) |
| `fast_1.1` | `fast_0` AND `agent_cycles ≤ 0.91 × wse3_reference.cycles_send` (9% faster) |
| `fast_1.5` | `fast_0` AND `agent_cycles ≤ 0.67 × wse3_reference.cycles_send` (1.5× faster) |
| `fast_2`   | `fast_0` AND `agent_cycles ≤ 0.50 × wse3_reference.cycles_send` (2× faster) |
| `fast_p`   | `fast_0` AND `agent_cycles ≤ (1/p) × wse3_reference.cycles_send` |

The fractional p values (`fast_1.1`, `fast_1.5`) are the realistic graduation steps; `fast_2` is a stretch goal that almost certainly requires algorithmic restructuring, not just better CSL idioms.

For kernels with `implicit_baseline_from_first_pass: true`, `fast_p` is computed against the agent's own first-passing variant cycle count rather than a human reference. Such kernels test "can the optimizer iteratively reduce its own kernel's cycles", not "can it beat humans".

## Per-suite aggregate

A run reports one number per metric, aggregated across all N kernels in the suite the run targeted:

```
fast_0 rate:   passed / N         (correctness)
fast_1 rate:   parity_or_better / N
fast_1.1 rate: 9%_faster_or_better / N
fast_p_mean:   geometric mean of (cycles_ref / cycles_agent) across passing kernels
```

## Scope of "what the agent sees"

| Workflow | Sees CUDA source | Sees reference CSL | Sees layout.csl + run.py | Sees task description |
|---|---|---|---|---|
| W1 (CUDA→CSL translate + optimize) | YES | **NO** — the reference `pe.csl` is HIDDEN from the translator and a compute-leak canary (`cuda2csl.py::_assert_no_compute_leak`, asserted on every `_llm_call`) fails the run if it leaks. The agent gets CUDA + task + layout.csl + run.py + commands.sh only. | YES (contract) | YES |
| W2 (existing CSL → optimize) | NO | NO (the agent loads what's at `--csl-path`; that becomes "current code at N cycles", not "reference") | YES (contract) | YES |

The W1/W2 split exists so we can test "given just a task spec, can the agent write fast CSL" without contaminating the experiment with the reference's algorithmic structure. **The reference CSL is a pure scoring oracle for W1 — never shown to the translator** (corrected 2026-06-20; the earlier "worked example for translator" wording was stale relative to the code, which has always hidden it via the canary).

## When a spec is missing

If `kernels/<name>/spec.yaml` doesn't exist, the framework falls back to today's behavior: it reads the reference CSL + layout.csl + run.py via `build_reference_contract()` and uses the in-kernel `cycles_send` print as the cycle metric. The spec is purely additive — code without it still works.

## Validation

`code_translation/validate_specs.py` (to be authored if needed) — walk `kernels/*/spec.yaml`, validate the schema, check that `wse3_reference.cycles_send` matches `kernels/baselines_wse3.json`, check that `hidden_from_optimize_only` paths actually exist.

## Versioning

Spec format version: `v1.0` (this document). Bump when a backwards-incompatible field change is made.
