# Setting up xkernel on a new account

xkernel translates CUDA kernels to Cerebras CSL with an LLM agent, benchmarks the
result in the Cerebras SDK simulator (and optionally on WSE-3 hardware), and
optimizes correct kernels for device cycles. This guide gets a second user from a
fresh clone to a passing smoke run. Everything site-specific is an environment
variable; the defaults reproduce the setup used for the published sweeps on the
ALCF Cerebras user nodes.

## 1. Requirements

| Need | Notes |
|---|---|
| A machine with the Cerebras SDK 1.4.0 wrappers (`cslc`, `cs_python`, `cs_readelf`) and apptainer/singularity | On the ALCF Cerebras user nodes the SDKs are at `/software/cerebras/cs_sdk-1.4.0` and `/software/cerebras/cs_sdk-2.10`; a per-user copy at `~/cs_sdk-1.4.0` also works. |
| Python 3.11 via micromamba | `~/bin/micromamba` is the default location; any `micromamba` on `PATH` works. |
| An LLM route | Argonne **Argo** (Anthropic-compatible, via `argo-shim`), the **Anthropic API** directly, or an OpenAI-compatible endpoint (incl. ALCF inference endpoints for open-weight models). |
| git | Not on `PATH` on the Cerebras nodes by default; e.g. `micromamba create -n dev -c conda-forge git`. |

The SDK container is a **serial resource**: never run two `cslc`/`cs_python`
processes at once on the same node (the container runtime wedges). All sweep
scripts run kernels one after another for this reason.

## 2. Clone and create the agent environment

```bash
# --branch v2_0 is required: the default branch is far behind and lacks the
# current study's tooling (docs/EXPERIMENT_RUNBOOK.md, code_translation/task_sets.py).
git clone --branch sparse-csl-kernels https://github.com/luozoupi/FABRICA-CUDA2CSL-Optmization-Benchmark-and-Agentic-Framework.git ~/xkernel
cd ~/xkernel
git rev-parse --abbrev-ref HEAD                  # must print v2_0
~/bin/micromamba create -y -n xkernel-agent -f code_translation/environment.micromamba.yml
# optional: post-training / Ollama extras
# ~/bin/micromamba install -y -n xkernel-agent -f code_translation/environment-extras.yml
```

## 3. Site configuration (`xkernel_env.sh`)

Every launcher sources `xkernel_env.sh`. Pre-set a variable to override its default:

| Variable | Default | Meaning |
|---|---|---|
| `XKERNEL_ROOT` | directory of the launcher | repo checkout |
| `XKERNEL_SDK_ROOT` | first existing of `~/cs_sdk-1.4.0`, `/software/cerebras/cs_sdk-1.4.0`, `/software/cerebras/cs_sdk-2.10` | SDK wrappers directory |
| `XKERNEL_SDK_SIF` | the `*.sif` inside `XKERNEL_SDK_ROOT` | SDK container image (library-signature extraction, `cs_readelf`) |
| `XKERNEL_MICROMAMBA` | `~/bin/micromamba`, else `micromamba` on `PATH` | micromamba binary |
| `XKERNEL_ENV` | `xkernel-agent` | environment name |
| `XKERNEL_HTTPS_PROXY` | unset (the OpenAI/ALCF launchers default to `http://proxy.alcf.anl.gov:3128`; set `""` to disable) | outbound proxy for public APIs |

Check what resolved on your machine:

```bash
source xkernel_env.sh && echo "$XKERNEL_SDK_ROOT $XKERNEL_MICROMAMBA"
```

## 4. Choose an LLM route

### 4a. Argo (Argonne) through argo-shim — the route used for the published Claude sweeps

```bash
pip install argo-shim                    # https://github.com/n-getty/argo-shim
argo-shim                                # on a node with SSH access to CELS; prints the local base URL
# compute nodes without outbound SSH: `argo-shim --tunnel` on a UAN, then
# `argo-shim --tunnel-host <uan>` on the compute node. If your ALCF username
# differs from your CELS username: export CELS_USERNAME=<cels-user>
```

argo-shim writes `ANTHROPIC_BASE_URL` and an `apiKeyHelper` into
`~/.claude/settings.json`; `run_cuda2csl_argo.sh` reads both from there. You can
also bypass the settings file:

```bash
export ANTHROPIC_BASE_URL=http://127.0.0.1:<port>/argoapi   # printed by argo-shim
export ANTHROPIC_API_KEY=<your Argo key>                     # or ARGO_API_KEY_FILE=/path/to/keyfile
export ARGO_MODEL=claude-opus-4-8                            # default claude-opus-4-7
bash run_cuda2csl_argo.sh --check-env
```

### 4b. Anthropic API directly

```bash
export ANTHROPIC_API_KEY=<key>            # or ANTHROPIC_KEY_FILE=~/claude-api-key.txt (mode 0600)
export XKERNEL_MODEL=claude-opus-4-8
bash run_cuda2csl_anthropic.sh --check-env
```

### 4c. OpenAI-compatible endpoints

`run_cuda2csl.sh` uses `OPENAI_API_KEY` or `OPENAI_KEY_FILE` (default
`~/codex-api-key.txt`) and `--model gpt-4.1`-style names; `run_cuda2csl_alcf.sh`
uses Globus authentication for the ALCF inference endpoints (open-weight models),
see `code_translation/README.md`.

Keys are never stored in the repository; `scripts/check_no_secrets.sh` scans
tracked files before a push.

## 5. Verify

```bash
# 1. environment report: expect "overall_status": "ready" with cslc_launch and
#    cs_python_launch both "ready" (the SDK probe starts the container; ~1 min)
bash run_cuda2csl_argo.sh --check-env        # or run_cuda2csl_anthropic.sh

# 2. unit tests (CPU only, ~10 s; the legacy Ollama prototype is skipped)
( cd code_translation && ~/bin/micromamba run -n xkernel-agent python -m unittest discover -p 'test_*.py' )

# 3. smoke run: translate + repair one single-PE kernel (~3-15 min, a few LLM calls)
bash run_cuda2csl_argo.sh --kernel ReLU-1PE --turns 4 --reviewer-max-attempts 10 \
     --output code_translation/results/smoke_$(date -u +%Y%m%d_%H%M%S)
```

A run directory contains `benchmark.json` (status, `cycles_send`, held-out
result), `translation_log.json` (the full conversation), `version_trace.json`,
`optimization_summary.json` when `--optimize`/`--auto-optimize` is on, and the
staged bundle transcript. `code_translation/results/` is git-ignored except for
curated `*.md` reports.

### Argo-only generation without a Cerebras SDK

Use this on a development machine that can reach Argo but cannot run the
Cerebras SDK:

```bash
bash run_cuda2csl_argo.sh --check-env --generate-only
bash run_cuda2csl_argo.sh --kernel ReLU-1PE --generate-only \
     --output code_translation/results/argo_handoff_$(date -u +%Y%m%d_%H%M%S)
```

This mode deliberately performs no SDK probe, reference measurement, compile,
simulation, reviewer repair, profiling, or optimization. The generated compute
file is saved at the kernel's normal `target_relpath`, while `benchmark.json`
and `bundle_metadata.json` mark it `unverified`. It is a handoff candidate, not
a passing benchmark. Options that require measurements (`--optimize`,
`--auto-optimize`, `--optimize-only`, `--profile-feedback`, `--rl-bandit`, and
`--rl-mcts`) are rejected when combined with `--generate-only`.

## 6. Running the paper sweeps

**If you are running cells of the current study, stop here and follow
[`docs/EXPERIMENT_RUNBOOK.md`](docs/EXPERIMENT_RUNBOOK.md).** It is the
operating manual: the arms, the task sets, the preflight that proves your node's
numbers are poolable with the other account's, the exact sweep command, the
checks to run on your own results, and how to ship them back. Start with

```bash
XKERNEL_LAUNCHER=$PWD/run_cuda2csl_argo.sh bash scripts/preflight_study.sh
```

which must print `PREFLIGHT OK` before any sweep is worth paying for.

For the earlier experiments: the `run_*.sh` scripts at the repo root are their
entry points (one model, one lever, N seeds, kernels run serially) and `docs/`
holds the corresponding write-ups -- `run_profiler_ab_full.sh` for a two-arm A/B,
`run_full_template_sweep.sh` for a whole-suite pass. Levers are `XKERNEL_*`
environment gates documented in `code_translation/cuda2csl.py --help` and
`docs/PAPER_METHODOLOGY.md`. `COLLABORATION.md` covers the ground rules for
sharing a node and exchanging results.

## 7. Hardware (optional)

WSE-3 replay uses the SDK 2.10 appliance client in a separate virtualenv
(`pip install cerebras_appliance==2.10.0 cerebras_sdk==2.10.0`, see
`docs/HW_VS_SIM_20260806.md`) and an ALCF allocation:
`code_translation/hw_replay.py`, `hw_vs_sim.py`, `aggregate_hw_vs_sim.py`.

## 8. Troubleshooting

- Clone under your home directory (or another path the container can bind).
  The SDK wrappers bind-mount the working directory into the container; a
  checkout under `/tmp` fails with `skipping mount of ...: no such file or
  directory` and `--check-env` reports `cslc_launch: fail`.
- `cslc_launch: blocked/fail` in `--check-env`: `XKERNEL_SDK_ROOT` does not contain
  the wrappers, or the container runtime is unavailable on this node.
- A run hangs at compile: another `cslc`/`cs_python` is running (`pgrep -u $USER -f 'cslc|cs_python'`).
- apptainer refuses to start because the uid has no `/etc/passwd` entry: the
  Anthropic launcher wraps the run in `unshare -r`; copy that pattern.
- Public API calls time out on ALCF nodes: keep the proxy default; Argo via
  argo-shim needs `no_proxy=localhost,127.0.0.1` (set by the launcher).
