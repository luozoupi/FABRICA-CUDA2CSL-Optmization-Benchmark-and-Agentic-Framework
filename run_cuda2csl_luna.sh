#!/usr/bin/env bash
# Local OpenAI route for the sparse smoke study; credentials stay outside the repo.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export XKERNEL_SDK_ROOT="${XKERNEL_SDK_ROOT:-$HOME/cs_sdk}"
export XKERNEL_TARGET_SDK="${XKERNEL_TARGET_SDK:-2.10.1}"
export XKERNEL_SDK210_FIXUP=1 XKERNEL_SINGULARITY_GATE=1
export XKERNEL_LLM_TIMEOUT_S="${XKERNEL_LLM_TIMEOUT_S:-300}"
export XKERNEL_OPENAI_REASONING_EFFORT="${XKERNEL_OPENAI_REASONING_EFFORT:-medium}"
export XKERNEL_OPENAI_MIN_TOKENS="${XKERNEL_OPENAI_MIN_TOKENS:-8192}"
export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1
if [[ -f "$XKERNEL_SDK_ROOT/env.sh" ]]; then source "$XKERNEL_SDK_ROOT/env.sh"; fi
exec "${XKERNEL_PYTHON:-python3}" "$SCRIPT_DIR/code_translation/cuda2csl.py" \
  --api-key-file "${OPENAI_KEY_FILE:-$HOME/gpt-key.txt}" \
  --base-url https://api.openai.com/v1 --model gpt-5.6-luna \
  --sdk-root "$XKERNEL_SDK_ROOT" --target-sdk "$XKERNEL_TARGET_SDK" \
  --max-tokens 16384 "$@"
