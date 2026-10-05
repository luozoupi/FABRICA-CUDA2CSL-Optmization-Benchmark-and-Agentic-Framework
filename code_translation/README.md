# Code Translation Workflows

This directory contains two translation workflows:

- `cuda2csl.py`: CUDA → CSL path with staged bundle benchmarking
- `csl2cuda.py`: CSL → CUDA reverse path

---

> New account? Start with the repository-level [SETUP.md](../SETUP.md). The
> launchers at the repo root (`run_cuda2csl_argo.sh`, `run_cuda2csl_anthropic.sh`,
> `run_cuda2csl.sh`, `run_cuda2csl_alcf.sh`) source `xkernel_env.sh`, which
> discovers the SDK (`XKERNEL_SDK_ROOT`) and micromamba (`XKERNEL_MICROMAMBA`).
> The node-topology and SSH-shim notes below describe the original single-user
> setup on a login node without a container runtime; on the Cerebras user nodes,
> where apptainer is local, the shim is unnecessary.

## HPC Node Topology (ALCF Cerebras Cluster, original setup)

Two nodes are relevant:

| Node | Role | Singularity | Python 3.11 |
|------|------|-------------|-------------|
| `login-node` | Login / dev node (where you edit and run agents) | Not installed | Not in system PATH |
| `user-node-1` | Compute node | `/usr/bin/singularity` (apptainer 1.4.1) | Available |

Both nodes share the same NFS home, so all file paths are identical from either node.

The CSL SDK wrappers (`cslc`, `cs_python`, `sdk_debug_shell`) all call `singularity` to run the compiler and runtime inside a container. They must therefore be able to reach `user-node-1`.

---

## One-Time Setup (login node)

### 1. Singularity SSH shim (only if your node lacks a container runtime)

Create `~/bin/singularity` so that `cslc` and `cs_python` work from the login node. It SSH-relays every singularity call to `user-node-1` transparently. Passwordless SSH to `user-node-1` must already be in place (it is for the `USER` account).

```bash
cat > ~/bin/singularity << 'EOF'
#!/usr/bin/env bash
# Route singularity calls to user-node-1 where it is installed (/usr/bin/singularity).
# The home directory is NFS-mounted at the same path on both nodes so bind mounts work.
exec ssh -o BatchMode=yes -o StrictHostKeyChecking=no \
         -o ConnectTimeout=10 \
         user-node-1 /usr/bin/singularity "$@"
EOF
chmod +x ~/bin/singularity
```

Verify it works:

```bash
~/bin/singularity --version
# apptainer version 1.4.1-1.el8
```

### 2. Agent Python environment

The `xkernel-agent` micromamba environment already exists with all required packages. If it ever needs to be recreated:

```bash
~/bin/micromamba create -y -n xkernel-agent -f code_translation/environment.micromamba.yml
```

### 3. Launcher script

`run_cuda2csl.sh` (OpenAI-compatible), `run_cuda2csl_argo.sh` (Argo via
argo-shim), `run_cuda2csl_anthropic.sh` (Anthropic direct) and
`run_cuda2csl_alcf.sh` (ALCF endpoints) all source `xkernel_env.sh`, set the
proxy where a public API needs it, and run `cuda2csl.py` inside the micromamba
env. Use them instead of calling `cuda2csl.py` directly; credentials come from
environment variables or key files outside the repo (see `../SETUP.md`).

---

## Running the Workflow

### Environment check

```bash
bash run_cuda2csl.sh --check-env
```

Expected: `"overall_status": "ready"` with both `cslc_launch` and `cs_python_launch` showing `"status": "ready"`.

### CUDA → CSL translation (GEMV example)

```bash
bash run_cuda2csl.sh --kernel GEMV --model gpt-4.1 --turns 4
```

### With optimization passes

```bash
bash run_cuda2csl.sh --kernel GEMV --model gpt-4.1 --turns 4 \
  --optimize --steps task_simplify,buffer_cleanup,comptime_cleanup
```

### With profiler feedback

Add `--profile-feedback` to turn each staged CSL benchmark into a compact
feedback report for the optimization agent. The report records compile/run wall
time, success status, generated SDK artifacts such as `sim.log` and
`simfab_traces`, and SDK-version notes that affect profiling on WSE-3.

```bash
bash run_cuda2csl.sh --kernel GEMV --model gpt-4.1 --turns 4 \
  --profile-feedback --optimize --steps task_simplify
```

Outputs are saved as `profiler_feedback.json` and `profiler_feedback.txt` in
the kernel result directory. To profile an existing translated bundle without
running the LLM path:

```bash
source xkernel_env.sh && xk_python code_translation/profile_csl.py \
  --translated-dir code_translation/results/cuda2csl/run_<timestamp>/GEMV \
  --target-sdk 1.4.0
```

### Ad-hoc CUDA file

```bash
bash run_cuda2csl.sh \
  --cuda path/to/kernel.cu \
  --reference-csl-dir path/to/csl_bundle/ \
  --model gpt-4.1 --turns 4
```

### Target SDK-aware knowledge

The translation and optimization prompts load the local Cerebras SDK knowledge
base from `knowledge/data/cerebras_sdk_docs.jsonl` (tracked in git).
Retrieval is filtered by target SDK so the agent does not use newer CSL features
against an older local compiler:

```bash
bash run_cuda2csl.sh \
  --kernel GEMV \
  --target-sdk 1.4.0 \
  --model gpt-4.1 --turns 4
```

Refresh or query the corpus from `knowledge/`; see `knowledge/README.md`.

Results are written to:

```
code_translation/results/cuda2csl/run_<timestamp>/<kernel>/
```

---

## Why Not `~/R_2.9.0/venv_cerebras_pt`?

On `login-node`, `python3.11` is not in the system path, so the venv's shebang lines fail with `bad interpreter`. The venv works on `user-node-1` (which has Python 3.11) but the agent workflow runs on the login node. Use the `xkernel-agent` micromamba env instead — it provides Python 3.11 from conda-forge regardless of the system Python.

---

## Why `HTTPS_PROXY`?

Outbound HTTPS from `login-node` to `api.openai.com`,
`inference-api.alcf.anl.gov`, GitHub raw downloads, and PyPI should go through
the ALCF proxy. The launcher scripts set this automatically:

```
HTTPS_PROXY=http://proxy.alcf.anl.gov:3128
HTTP_PROXY=http://proxy.alcf.anl.gov:3128
https_proxy=http://proxy.alcf.anl.gov:3128
http_proxy=http://proxy.alcf.anl.gov:3128
```

Without it, API calls or `wget https://raw.githubusercontent.com/...` may hang
or time out while trying direct egress.

---

## API Key

The workflow reads the API key from `~/codex-api-key.txt` by default (via `--api-key-file`). You can also set `OPENAI_API_KEY` in the environment.

To use a local or alternative OpenAI-compatible endpoint:

```bash
bash run_cuda2csl.sh --kernel GEMV --base-url http://localhost:8000/v1
```

---

## ALCF Inference Endpoint API

The ALCF Inference Endpoints expose OpenAI-compatible APIs using Globus bearer
tokens instead of a static OpenAI API key. The web UI is not required for the
CUDA→CSL workflow.

### One-time setup

The ALCF auth helper is already installed at:

```text
code_translation/inference_auth_token.py
```

If it ever needs to be downloaded again, use the proxy:

```bash
export HTTPS_PROXY=http://proxy.alcf.anl.gov:3128
export HTTP_PROXY=http://proxy.alcf.anl.gov:3128
export https_proxy=http://proxy.alcf.anl.gov:3128
export http_proxy=http://proxy.alcf.anl.gov:3128

curl -L -o code_translation/inference_auth_token.py \
  https://raw.githubusercontent.com/argonne-lcf/inference-endpoints/refs/heads/main/inference_auth_token.py
```

Ensure `globus-sdk` is available inside either `xkernel-agent` or a dedicated
`globus_env`:

```bash
~/bin/micromamba run -n xkernel-agent \
  python -m pip install 'globus-sdk>=3.0.0'
```

Authenticate once with your ALCF/Globus account:

```bash
bash run_alcf_inference_auth.sh authenticate
```

This stores Globus refresh/access tokens in your home directory as managed by
the official helper. Access tokens are short-lived and are refreshed by:

```bash
bash run_alcf_inference_auth.sh get_access_token
```

To use a specific auth environment, for example your `globus_env`:

```bash
ALCF_AUTH_ENV=globus_env \
bash run_alcf_inference_auth.sh authenticate
```

### Run CUDA→CSL with ALCF inference

Use the dedicated launcher so the token is fetched dynamically and is never
written to the repo:

```bash
bash run_cuda2csl_alcf.sh --check-env

bash run_cuda2csl_alcf.sh --kernel GEMV --turns 4
```

By default, token refresh runs in `xkernel-agent`. If you authenticated in
`globus_env`, either environment can still read the same token cache under
`~/.globus`; you can also force token refresh through `globus_env`:

```bash
ALCF_AUTH_ENV=globus_env \
bash run_cuda2csl_alcf.sh --kernel GEMV --turns 4
```

Defaults:

```text
ALCF_INFERENCE_ENDPOINT=metis
model=gpt-oss-120b
base_url=https://inference-api.alcf.anl.gov/resource_server/metis/api/v1
```

To use Sophia/vLLM instead:

```bash
ALCF_INFERENCE_ENDPOINT=sophia \
bash run_cuda2csl_alcf.sh \
  --kernel GEMV \
  --model openai/gpt-oss-120b
```

The direct CLI form is:

```bash
~/bin/micromamba run -n xkernel-agent \
  python code_translation/cuda2csl.py \
    --alcf-endpoint metis \
    --api-key-command 'python code_translation/inference_auth_token.py get_access_token' \
    --kernel GEMV
```

The workflow stores `api_key_source: command` in metadata, not the token.

---

## Benchmark Re-run

To re-benchmark an existing translation output without re-running the LLM:

```bash
export HTTPS_PROXY=http://proxy.alcf.anl.gov:3128
~/bin/micromamba run -n xkernel-agent \
  python code_translation/benchmark_csl.py \
    --translated-dir code_translation/results/cuda2csl/run_<timestamp>/GEMV \
    --sdk-root ~/cs_sdk-1.4.0
```
