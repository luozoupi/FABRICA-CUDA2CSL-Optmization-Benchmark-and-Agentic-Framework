#!/usr/bin/env bash
# Launcher for the CUDA->CSL agentic workflow against a LOCAL OpenAI-compatible server
# (vLLM `vllm serve ...` or SGLang `python -m sglang.launch_server ...`), for on-policy data
# collection and evaluation of post-trained open models (docs/POSTTRAINING.md).
#   XKERNEL_BASE_URL   default http://localhost:8000/v1
#   XKERNEL_MODEL      the served model name (required)
#   XKERNEL_API_KEY_FILE  a file holding the server's key; default: a file containing EMPTY
# Usable as XKERNEL_LAUNCHER for run_sparse_translate_sweep.sh and run_model_guided_ab.sh.
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XKERNEL_HTTPS_PROXY="${XKERNEL_HTTPS_PROXY-}"
source "${XKERNEL_ROOT:-$SCRIPT_DIR}/xkernel_env.sh"
: "${XKERNEL_MODEL:?set XKERNEL_MODEL to the served model name}"
KEY_FILE="${XKERNEL_API_KEY_FILE:-}"
if [ -z "$KEY_FILE" ]; then
  KEY_FILE="$(mktemp)"; echo EMPTY > "$KEY_FILE"; trap 'rm -f "$KEY_FILE"' EXIT
fi
"$XKERNEL_MICROMAMBA" run -n $XKERNEL_ENV \
  python "$XKERNEL_ROOT"/code_translation/cuda2csl.py \
    --api-key-file "$KEY_FILE" \
    --base-url "${XKERNEL_BASE_URL:-http://localhost:8000/v1}" \
    --sdk-root "$XKERNEL_SDK_ROOT" \
    --model "$XKERNEL_MODEL" \
    "$@"
