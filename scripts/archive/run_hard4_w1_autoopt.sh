#!/usr/bin/env bash
# Workflow-1 re-test on the 4 hard kernels with --auto-optimize.
# Tests two things at once:
#   (1) Regression: does the post-pivot pipeline still translate
#       Game-of-Life / Residual / FFT-1D-2D at the rate the old one did?
#   (2) End-to-end cycle reduction: on 7pt-Stencil (the one that passes),
#       does the auto-optimize chain produce a < 2129-cycle variant?
# Workflow 1 = full CUDA→CSL translate, then auto-chain into optimize().
# Contract validator + builtin whitelist + skills + narrow tutorials all on.
set -u

KERNELS="Game-of-Life,Residual,7pt-Stencil,FFT-1D-2D"
TS=$(date -u +%Y%m%d_%H%M%S)
ROOT=/home/USER/xkernel/code_translation/results/hard4_w1_autoopt_${TS}
mkdir -p "$ROOT"
LOG="$ROOT/sweep.log"
: > "$LOG"
echo "$ROOT" > /tmp/hard4_w1_autoopt_root

export XKERNEL_LLM_TIMEOUT_S=180
export XKERNEL_SKILLS=1
export XKERNEL_TUTORIALS=1
export XKERNEL_TUTORIALS_KB_PATH=/home/USER/xkernel/knowledge/data/cerebras_tutorials_narrow.jsonl
export XKERNEL_BUILTIN_WHITELIST=1

echo "==== START hard4 W1 + auto-optimize ====" | tee -a "$LOG"
date -u +"start: %Y-%m-%dT%H:%M:%SZ" | tee -a "$LOG"

bash /home/USER/xkernel/run_alcf_sweep_one.sh \
    "openai/gpt-oss-120b" "$ROOT" \
    --kernels "$KERNELS" --reviewer-max-attempts 8 \
    --auto-optimize --min-optimize-attempts 5 --max-optimize-attempts 10 \
    --timeout 1800 --inter-kernel-delay 15 \
    >> "$LOG" 2>&1
RC=$?

echo "EXIT=$RC" | tee -a "$LOG"
date -u +"end:   %Y-%m-%dT%H:%M:%SZ" | tee -a "$LOG"
echo "===== HARD4 W1 + auto-optimize COMPLETE =====" | tee -a "$LOG"
echo "Outputs under: $ROOT"
