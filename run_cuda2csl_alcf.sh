#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/fabrica_env.sh"
# printf %q preserves spaces in the checkout path inside the auth command.
printf -v AUTH_COMMAND 'bash %q get_access_token' "$SCRIPT_DIR/run_alcf_inference_auth.sh"
xk_python "$XKERNEL_ROOT/code_translation/cuda2csl.py" \
  --alcf-endpoint "${ALCF_INFERENCE_ENDPOINT:-metis}" \
  --api-key-command "$AUTH_COMMAND" --sdk-root "$XKERNEL_SDK_ROOT" "$@"
