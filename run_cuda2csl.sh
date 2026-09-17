#!/usr/bin/env bash
# Launcher for the CUDA->CSL agentic workflow on a Cerebras SDK host.
# Uses the configured Fabrica Python environment.
set -e
# Optional outbound proxy, configured with XKERNEL_HTTPS_PROXY.
XKERNEL_HTTPS_PROXY="${XKERNEL_HTTPS_PROXY-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${XKERNEL_ROOT:-$SCRIPT_DIR}/fabrica_env.sh"


xk_python "$XKERNEL_ROOT"/code_translation/cuda2csl.py \
    --api-key-file "${OPENAI_KEY_FILE:-$HOME/codex-api-key.txt}" \
    --sdk-root "$XKERNEL_SDK_ROOT" \
    "$@"
