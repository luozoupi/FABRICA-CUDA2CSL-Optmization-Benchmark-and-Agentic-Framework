# Setting up FABRICA

## Environment

Install Python 3.11 and create the virtual environment shown in [README.md](README.md).
Alternatively:

```bash
micromamba create -n fabrica-agent -f code_translation/environment.micromamba.yml
```

Launchers use `FABRICA_PYTHON` if set, then an active virtual environment, then
micromamba (`XKERNEL_ENV`, default `fabrica-agent`), then `python3` on PATH.
Set `FABRICA_PYTHON=/absolute/path/to/python` to select an interpreter explicitly.

For simulator execution, install the Cerebras SDK on a supported Linux host, then set
`XKERNEL_SDK_ROOT` to the directory containing `cslc` and `cs_python`.
The original simulator benchmark targets SDK 1.4.0 and WSE-3. SDK 2.10 hardware replay
has additional requirements below. The SDK/container images are not bundled.
Run SDK jobs serially on a shared node; the original environment requires serialized
container access. Keep the checkout in a directory that the SDK container can mount.

```bash
export XKERNEL_SDK_ROOT=/path/to/cs_sdk-1.4.0
# Only if your site needs a proxy:
# export XKERNEL_HTTPS_PROXY=http://your-proxy:3128
bash run_cuda2csl.sh --check-env
```

The environment report probes SDK launches. Missing credentials or SDK tools appear
in the report; a printed report alone does not establish that the environment is ready.

## LLM providers

Choose a model available to your account. Model names in examples can be replaced
with `--model`; defaults are inherited from the original framework.

### OpenAI or a compatible endpoint

```bash
export OPENAI_API_KEY=your-key
bash run_cuda2csl.sh --model gpt-4.1 --kernel ReLU-1PE --turns 4
# For another compatible provider, also pass --base-url https://your-endpoint/v1
```

A key file can be supplied with `OPENAI_KEY_FILE=/path/to/key`. Avoid committing keys.

### Anthropic

```bash
export ANTHROPIC_API_KEY=your-key
bash run_cuda2csl_anthropic.sh --model your-claude-model --kernel ReLU-1PE
```

Alternatively set `ANTHROPIC_KEY_FILE=/path/to/key`. The launcher creates and removes
a permission-restricted temporary key file when using the environment variable.
Set `ANTHROPIC_BASE_URL` for an Anthropic-compatible proxy.

### Argonne Argo

Start your Argo-compatible proxy separately. The launcher accepts
`ANTHROPIC_BASE_URL` plus `ANTHROPIC_API_KEY` or `ARGO_API_KEY_FILE`. It can also
read an existing Argo configuration from `ARGO_SETTINGS_FILE` (default
`~/.claude/settings.json`).

```bash
export ANTHROPIC_BASE_URL=http://127.0.0.1:PORT/argoapi
export ARGO_API_KEY_FILE=/path/to/argo-key
bash run_cuda2csl_argo.sh --model your-claude-model --kernel ReLU-1PE
```

### ALCF inference endpoints

```bash
bash run_alcf_inference_auth.sh authenticate
bash run_cuda2csl_alcf.sh --kernel ReLU-1PE
```

The helper uses Globus credentials stored outside this repository.
`ALCF_INFERENCE_ENDPOINT` selects an endpoint (default `metis`).

## Translation, optimization, and batch execution

```bash
# Translate and repair; optimize only after a passing implementation.
bash run_cuda2csl.sh --kernel ReLU-1PE --auto-optimize \
  --reviewer-max-attempts 10 --min-optimize-attempts 3 --max-optimize-attempts 5

# Optimize an existing compute file.
bash run_cuda2csl.sh --kernel ReLU-1PE --optimize-only \
  --csl-path kernels/ReLU-1PE/CSL/pe.csl

# Preview a serial batch without making API calls or launching the SDK.
python code_translation/batch_cuda2csl.py --kernels ReLU-1PE,SAXPY-1PE --dry-run
# Remove --dry-run to execute. The batch script's default tier list is a legacy
# subset; specify --kernels explicitly for newer tasks.
```

For all options run `python code_translation/cuda2csl.py --help`.
Runs are written under `code_translation/results/`; staging is under
`code_translation/sandbox/`. Both are ignored by Git. Persistent bandit/MCTS
state defaults to `~/.cache/fabrica/rl_data/`.

Inspect `benchmark.json`, held-out verification, and `optimization_summary.json`
before comparing results. Simulator wall time includes startup overhead; use the
benchmark's cycle metric and matching timing windows. The trusted-reference and
held-out-input rules are described in [code_translation/FIREWALL.md](code_translation/FIREWALL.md).

## Hardware replay (optional)

Hardware execution requires a WSE allocation and an SDK 2.10 appliance environment.
The original replay workflow uses `cerebras_appliance==2.10.0` and
`cerebras_sdk==2.10.0` in a separate environment; these are not installed by the
agent requirements file. Inspect the hardware CLI before submitting jobs:

```bash
python code_translation/hw_replay.py --help
python code_translation/hw_vs_sim.py --help
```

Simulator checks do not establish hardware compatibility for every reference.

## Source checks

```bash
python -m unittest discover -s code_translation -p 'test_*.py'
python scripts/check_no_secrets.py
```

These checks do not call an LLM or run a CUDA/Cerebras kernel. Full correctness and
performance validation must run on the corresponding SDK/GPU/hardware environment.
