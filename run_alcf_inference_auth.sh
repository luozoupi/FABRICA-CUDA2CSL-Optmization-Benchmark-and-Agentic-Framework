#!/usr/bin/env bash
# Authenticate or inspect ALCF Inference Endpoint Globus tokens.
set -e
# Outbound proxy for public LLM endpoints (ALCF default). Set XKERNEL_HTTPS_PROXY="" to disable.
XKERNEL_HTTPS_PROXY="${XKERNEL_HTTPS_PROXY-http://proxy.alcf.anl.gov:3128}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${XKERNEL_ROOT:-$SCRIPT_DIR}/xkernel_env.sh"


AUTH_ENV="${ALCF_AUTH_ENV:-globus_env}"
AUTH_HELPER="${ALCF_INFERENCE_AUTH_HELPER:-$HOME/xkernel/code_translation/inference_auth_token.py}"
ACTION="${1:-authenticate}"
shift || true

if [[ ! -f "$AUTH_HELPER" ]]; then
  cat >&2 <<EOF
Missing ALCF inference auth helper:
  $AUTH_HELPER

The helper already lives in the repo on this node in normal setup. If it ever
needs to be downloaded again, run through the ALCF proxy:

  HTTPS_PROXY=http://proxy.alcf.anl.gov:3128 \\
  HTTP_PROXY=http://proxy.alcf.anl.gov:3128 \\
  curl -L -o "$AUTH_HELPER" \\
    https://raw.githubusercontent.com/argonne-lcf/inference-endpoints/refs/heads/main/inference_auth_token.py
EOF
  exit 2
fi

exec "$XKERNEL_MICROMAMBA" run -n "$AUTH_ENV" \
  python "$AUTH_HELPER" "$ACTION" "$@"
