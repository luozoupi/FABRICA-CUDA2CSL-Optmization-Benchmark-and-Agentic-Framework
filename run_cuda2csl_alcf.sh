#!/usr/bin/env bash
# Launcher for CUDA->CSL using ALCF Inference Endpoints.
set -e
# Outbound proxy for public LLM endpoints (ALCF default). Set XKERNEL_HTTPS_PROXY="" to disable.
XKERNEL_HTTPS_PROXY="${XKERNEL_HTTPS_PROXY-http://proxy.alcf.anl.gov:3128}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${XKERNEL_ROOT:-$SCRIPT_DIR}/xkernel_env.sh"


AUTH_HELPER="${ALCF_INFERENCE_AUTH_HELPER:-$HOME/xkernel/code_translation/inference_auth_token.py}"
ALCF_ENDPOINT="${ALCF_INFERENCE_ENDPOINT:-metis}"
AUTH_ENV="${ALCF_AUTH_ENV:-xkernel-agent}"

if [[ ! -f "$AUTH_HELPER" ]]; then
  cat >&2 <<EOF
Missing ALCF inference auth helper:
  $AUTH_HELPER

Install it with:
  curl -L -o "$AUTH_HELPER" \\
    https://raw.githubusercontent.com/argonne-lcf/inference-endpoints/refs/heads/main/inference_auth_token.py

Then authenticate once:
  "$XKERNEL_MICROMAMBA" run -n $XKERNEL_ENV python "$AUTH_HELPER" authenticate
EOF
  exit 2
fi

exec "$XKERNEL_MICROMAMBA" run -n $XKERNEL_ENV \
  python "$XKERNEL_ROOT"/code_translation/cuda2csl.py \
    --alcf-endpoint "$ALCF_ENDPOINT" \
    --api-key-command "$XKERNEL_MICROMAMBA run -n $AUTH_ENV python $AUTH_HELPER get_access_token" \
    --sdk-root "$XKERNEL_SDK_ROOT" \
    "$@"
