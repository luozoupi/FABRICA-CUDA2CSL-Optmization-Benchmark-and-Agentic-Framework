#!/usr/bin/env bash
# Launcher for the CUDA->CSL agentic workflow on login-node.
# Sets HTTPS_PROXY for OpenAI API access and uses the xkernel-agent micromamba env.
set -e
# Outbound proxy for public LLM endpoints (ALCF default). Set XKERNEL_HTTPS_PROXY="" to disable.
XKERNEL_HTTPS_PROXY="${XKERNEL_HTTPS_PROXY-http://proxy.alcf.anl.gov:3128}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${XKERNEL_ROOT:-$SCRIPT_DIR}/xkernel_env.sh"


# Model: XKERNEL_MODEL, as in run_cuda2csl_anthropic.sh (XKERNEL_MODEL) and
# run_cuda2csl_argo.sh (ARGO_MODEL). Without this the launcher silently ran cuda2csl.py's
# own default while the caller believed it had selected a model: a sweep launched on
# 2026-09-20 with XKERNEL_MODEL=gpt-5.6-luna ran entirely on gpt-4.1, and only the usage log
# showed it. An explicit --model in "$@" still wins, because it comes after this one.
MODEL_ARGS=()
if [ -n "${XKERNEL_MODEL:-}" ]; then MODEL_ARGS=(--model "$XKERNEL_MODEL"); fi

exec "$XKERNEL_MICROMAMBA" run -n $XKERNEL_ENV \
  python "$XKERNEL_ROOT"/code_translation/cuda2csl.py \
    --api-key-file "${OPENAI_KEY_FILE:-$HOME/codex-api-key.txt}" \
    --sdk-root "$XKERNEL_SDK_ROOT" \
    "${MODEL_ARGS[@]}" \
    "$@"
