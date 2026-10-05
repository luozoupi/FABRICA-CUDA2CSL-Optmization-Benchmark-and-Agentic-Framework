#!/usr/bin/env bash
# Single-model sweep launcher routed through the local argo-shim Anthropic proxy.
# Usage: run_argo_sweep_one.sh <model> <output-dir> [extra args]
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${XKERNEL_ROOT:-$SCRIPT_DIR}/xkernel_env.sh"

MODEL="${1:?missing model}"
OUT_DIR="${2:?missing output dir}"
shift 2

KEY_FILE="${ARGO_KEY_FILE:-$HOME/.argo-api-key.txt}"
SETTINGS_FILE="${ARGO_SETTINGS_FILE:-$HOME/.claude/settings.json}"

# Refresh the Argo key file from settings.json each run (apiKeyHelper may rotate).
python3 "$HOME/xkernel/code_translation/argo_key_from_settings.py" \
  --settings "$SETTINGS_FILE" --out "$KEY_FILE" >/dev/null

# Pull the live base URL out of settings.json (port can rotate too).
if [ -z "${ANTHROPIC_BASE_URL:-}" ]; then
  ANTHROPIC_BASE_URL=$(python3 -c 'import json,os,sys; d=json.load(open(os.path.expanduser(sys.argv[1]))); print((d.get("env") or {}).get("ANTHROPIC_BASE_URL",""))' "$SETTINGS_FILE")
fi
export ANTHROPIC_BASE_URL no_proxy="localhost,127.0.0.1" NO_PROXY="localhost,127.0.0.1"

mkdir -p "$OUT_DIR"

exec "$XKERNEL_MICROMAMBA" run -n $XKERNEL_ENV \
  python "$HOME/xkernel/code_translation/batch_cuda2csl.py" \
    --model "$MODEL" \
    --api-key-file "$KEY_FILE" \
    --sdk-root "$XKERNEL_SDK_ROOT" \
    --output "$OUT_DIR" \
    "$@"
