#!/usr/bin/env bash
# DeepSeek Chat Completions route; the key stays in its external file.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export XKERNEL_SDK_ROOT="${XKERNEL_SDK_ROOT:-$HOME/cs_sdk}"
export XKERNEL_TARGET_SDK="${XKERNEL_TARGET_SDK:-2.10}"
export XKERNEL_SINGULARITY_GATE=1
export XKERNEL_LLM_TIMEOUT_S="${XKERNEL_LLM_TIMEOUT_S:-600}"
export XKERNEL_DEEPSEEK_THINKING="${XKERNEL_DEEPSEEK_THINKING:-enabled}"
export XKERNEL_DEEPSEEK_EFFORT="${XKERNEL_DEEPSEEK_EFFORT:-high}"
export XKERNEL_DEEPSEEK_MIN_TOKENS="${XKERNEL_DEEPSEEK_MIN_TOKENS:-65536}"
export APPTAINERENV_CSL_SUPPRESS_SIMFAB_TRACE=1
export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1
if [[ -f "$XKERNEL_SDK_ROOT/env.sh" ]]; then source "$XKERNEL_SDK_ROOT/env.sh"; fi
exec "${XKERNEL_PYTHON:-python3}" "$SCRIPT_DIR/code_translation/cuda2csl.py" \
  --api-key-file "${DEEPSEEK_KEY_FILE:-$HOME/deepseek-api.txt}" \
  --base-url "${DEEPSEEK_BASE_URL:-https://api.deepseek.com}" \
  --model "${DEEPSEEK_MODEL:-deepseek-flash}" \
  --sdk-root "$XKERNEL_SDK_ROOT" --target-sdk "$XKERNEL_TARGET_SDK" \
  --max-tokens 16384 "$@"
