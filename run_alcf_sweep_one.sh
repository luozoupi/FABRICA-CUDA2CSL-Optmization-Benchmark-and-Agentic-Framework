#!/usr/bin/env bash
# Run batch_cuda2csl.py for one model against the ALCF sophia endpoint.
# Usage: run_alcf_sweep_one.sh <model> <output-dir> [extra args passed through]
#
# The Globus access token is refreshed *per kernel* via --api-key-command,
# so a multi-hour sweep can't be killed by token expiry.
set -e
# Outbound proxy for public LLM endpoints (ALCF default). Set XKERNEL_HTTPS_PROXY="" to disable.
XKERNEL_HTTPS_PROXY="${XKERNEL_HTTPS_PROXY-http://proxy.alcf.anl.gov:3128}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${XKERNEL_ROOT:-$SCRIPT_DIR}/xkernel_env.sh"

MODEL="${1:?missing model}"
OUT_DIR="${2:?missing output dir}"
shift 2


AUTH_HELPER="$HOME/xkernel/code_translation/inference_auth_token.py"
# IMPORTANT: globus_sdk needs cryptography that links against newer glibc than
# this host has, so the wheel inside xkernel-agent fails to import. Use the
# dedicated globus_env (matches run_alcf_inference_auth.sh).
AUTH_ENV="${ALCF_AUTH_ENV:-globus_env}"
AUTH_CMD="$XKERNEL_MICROMAMBA run -n $AUTH_ENV python $AUTH_HELPER get_access_token"

mkdir -p "$OUT_DIR"

exec "$XKERNEL_MICROMAMBA" run -n $XKERNEL_ENV \
  python "$HOME/xkernel/code_translation/batch_cuda2csl.py" \
    --model "$MODEL" \
    --api-key-file /dev/null \
    --sdk-root "$XKERNEL_SDK_ROOT" \
    --output "$OUT_DIR" \
    --alcf-endpoint sophia \
    --api-key-command "$AUTH_CMD" \
    "$@"
