#!/usr/bin/env bash
# Launcher for the CUDA->CSL agent against the Anthropic API directly
# (rather than the Argo proxy).
#
# Credentials: ANTHROPIC_API_KEY (env) or a key file at ANTHROPIC_KEY_FILE
# (default ~/claude-api-key.txt). The key is never copied into the repo.
#
# Model: XKERNEL_MODEL (default claude-opus-4-8). Note the framework's
# llm_complete() sends only model/max_tokens/messages/system for Anthropic
# models -- no temperature, top_p, top_k, or thinking.budget_tokens -- all of
# which return 400 on Opus 4.7+. Adaptive thinking is therefore off, matching
# how the earlier argo-shim sweeps ran.
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XKERNEL_ROOT="${XKERNEL_ROOT:-$SCRIPT_DIR}"
source "$XKERNEL_ROOT/fabrica_env.sh"

KEY_FILE="${ANTHROPIC_KEY_FILE:-$HOME/claude-api-key.txt}"
if [ -n "${ANTHROPIC_API_KEY:-}" ]; then
  KEY_FILE="${TMPDIR:-/tmp}/xkernel-anthropic-key-$$.txt"
  ( umask 077; printf '%s\n' "$ANTHROPIC_API_KEY" > "$KEY_FILE" )
  trap 'rm -f "$KEY_FILE"' EXIT
elif [ ! -s "$KEY_FILE" ]; then
  echo "run_cuda2csl_anthropic.sh: no API key. Set ANTHROPIC_API_KEY or ANTHROPIC_KEY_FILE ($KEY_FILE missing)" >&2
  exit 1
fi

# `exec` would drop the EXIT trap that removes a temporary key file.
xk_python "$XKERNEL_ROOT/code_translation/cuda2csl.py" \
    --api-key-file "$KEY_FILE" \
    --model "${XKERNEL_MODEL:-claude-opus-4-8}" \
    --sdk-root "$XKERNEL_SDK_ROOT" \
    "$@"
