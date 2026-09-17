#!/usr/bin/env bash
# Shared environment resolution for the Fabrica launchers. SOURCE this file;
# do not execute it. Every value can be pre-set in the environment; the
# defaults below reproduce the original single-user setup on the ALCF
# Cerebras user nodes, but work for any account that has the SDK and a
# micromamba environment built from code_translation/environment.micromamba.yml.
#
#   XKERNEL_ROOT        repo checkout (default: directory of this file)
#   XKERNEL_SDK_ROOT    Cerebras SDK wrappers dir containing cslc/cs_python
#                       (default: first existing of ~/cs_sdk-1.4.0,
#                        /software/cerebras/cs_sdk-1.4.0, /software/cerebras/cs_sdk-2.10)
#   XKERNEL_MICROMAMBA  micromamba binary (default: ~/bin/micromamba, else on PATH)
#   XKERNEL_ENV         micromamba env name (default: fabrica-agent)
#   XKERNEL_HTTPS_PROXY optional outbound proxy for public LLM APIs
#                       (e.g. http://proxy.alcf.anl.gov:3128); unset = no proxy

_xk_here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XKERNEL_ROOT="${XKERNEL_ROOT:-$_xk_here}"

if [ -z "${XKERNEL_SDK_ROOT:-}" ]; then
  for _xk_d in "$HOME/cs_sdk-1.4.0" /software/cerebras/cs_sdk-1.4.0 /software/cerebras/cs_sdk-2.10; do
    if [ -x "$_xk_d/cslc" ]; then XKERNEL_SDK_ROOT="$_xk_d"; break; fi
  done
fi
XKERNEL_SDK_ROOT="${XKERNEL_SDK_ROOT:-$HOME/cs_sdk-1.4.0}"

if [ -z "${XKERNEL_MICROMAMBA:-}" ]; then
  if [ -x "$HOME/bin/micromamba" ]; then
    XKERNEL_MICROMAMBA="$HOME/bin/micromamba"
  elif command -v micromamba >/dev/null 2>&1; then
    XKERNEL_MICROMAMBA="$(command -v micromamba)"
  elif [ -n "${MAMBA_EXE:-}" ] && [ -x "$MAMBA_EXE" ]; then
    XKERNEL_MICROMAMBA="$MAMBA_EXE"
  else
    XKERNEL_MICROMAMBA="micromamba"
  fi
fi
XKERNEL_ENV="${XKERNEL_ENV:-fabrica-agent}"

if [ -n "${XKERNEL_HTTPS_PROXY:-}" ]; then
  export HTTPS_PROXY="$XKERNEL_HTTPS_PROXY" HTTP_PROXY="$XKERNEL_HTTPS_PROXY"
  export https_proxy="$XKERNEL_HTTPS_PROXY" http_proxy="$XKERNEL_HTTPS_PROXY"
fi

# Run a Python program inside the agent environment.
xk_python() {
  if [ -n "${FABRICA_PYTHON:-}" ]; then
    "$FABRICA_PYTHON" "$@"
  elif [ -n "${VIRTUAL_ENV:-}" ]; then
    python "$@"
  elif command -v "$XKERNEL_MICROMAMBA" >/dev/null 2>&1; then
    "$XKERNEL_MICROMAMBA" run -n "$XKERNEL_ENV" python "$@"
  else
    python3 "$@"
  fi
}

export XKERNEL_ROOT XKERNEL_SDK_ROOT XKERNEL_MICROMAMBA XKERNEL_ENV
unset _xk_here _xk_d
