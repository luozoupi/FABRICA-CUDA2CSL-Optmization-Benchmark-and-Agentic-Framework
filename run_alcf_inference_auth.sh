#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/fabrica_env.sh"
xk_python "${ALCF_INFERENCE_AUTH_HELPER:-$XKERNEL_ROOT/code_translation/inference_auth_token.py}" "$@"
