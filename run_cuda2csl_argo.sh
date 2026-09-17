#!/usr/bin/env bash
# Launcher for the CUDA->CSL agent routed through the Argonne Argo API
# (Anthropic-compatible endpoint), normally via the local argo-shim proxy
# (`pip install argo-shim`; https://github.com/n-getty/argo-shim).
#
# Credentials, in order of precedence:
#   1. ANTHROPIC_API_KEY   (env)  -> written to $ARGO_API_KEY_FILE (mode 0600)
#   2. ARGO_API_KEY_FILE   (env)  -> an existing key file is used as is
#   3. ~/.claude/settings.json    -> the apiKeyHelper that argo-shim installs
#                                    (legacy single-user path; ARGO_SETTINGS_FILE)
# Endpoint: ANTHROPIC_BASE_URL (env), else env.ANTHROPIC_BASE_URL from the same
# settings file (argo-shim writes it, e.g. http://127.0.0.1:<port>/argoapi).
# Model: ARGO_MODEL (default claude-opus-4-7).
set -e

# Resolve cuda2csl.py relative to THIS script's own directory so worktree-
# based A/B experiments (.claude/worktrees/foo/run_cuda2csl_argo.sh) call
# the worktree's own code_translation/cuda2csl.py, not the main tree's.
# Override with XKERNEL_ROOT=/some/path if you want explicit pinning.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XKERNEL_ROOT="${XKERNEL_ROOT:-$SCRIPT_DIR}"
source "$XKERNEL_ROOT/fabrica_env.sh"

KEY_FILE="${ARGO_API_KEY_FILE:-${ARGO_KEY_FILE:-$HOME/.argo-api-key.txt}}"
SETTINGS_FILE="${ARGO_SETTINGS_FILE:-$HOME/.claude/settings.json}"

if [ -n "${ANTHROPIC_API_KEY:-}" ]; then
  ( umask 077; printf '%s\n' "$ANTHROPIC_API_KEY" > "$KEY_FILE" )
elif [ -n "${ARGO_API_KEY_FILE:-}" ] && [ -s "$KEY_FILE" ]; then
  :  # explicit key file supplied
elif [ -f "$SETTINGS_FILE" ]; then
  python3 "$XKERNEL_ROOT/code_translation/argo_key_from_settings.py" \
    --settings "$SETTINGS_FILE" --out "$KEY_FILE" >/dev/null
else
  echo "run_cuda2csl_argo.sh: no credentials. Set ANTHROPIC_API_KEY, or ARGO_API_KEY_FILE," >&2
  echo "  or run argo-shim so that $SETTINGS_FILE carries its apiKeyHelper." >&2
  exit 1
fi

if [ -z "${ANTHROPIC_BASE_URL:-}" ] && [ -f "$SETTINGS_FILE" ]; then
  ANTHROPIC_BASE_URL=$(python3 -c 'import json,os,sys; d=json.load(open(os.path.expanduser(sys.argv[1]))); print((d.get("env") or {}).get("ANTHROPIC_BASE_URL",""))' "$SETTINGS_FILE")
fi
if [ -z "${ANTHROPIC_BASE_URL:-}" ]; then
  echo "run_cuda2csl_argo.sh: set ANTHROPIC_BASE_URL (argo-shim prints it) or let argo-shim write $SETTINGS_FILE" >&2
  exit 1
fi
export ANTHROPIC_BASE_URL
export no_proxy="localhost,127.0.0.1"
export NO_PROXY="localhost,127.0.0.1"

xk_python "$XKERNEL_ROOT/code_translation/cuda2csl.py" \
    --api-key-file "$KEY_FILE" \
    --model "${ARGO_MODEL:-claude-opus-4-7}" \
    --sdk-root "$XKERNEL_SDK_ROOT" \
    "$@"
