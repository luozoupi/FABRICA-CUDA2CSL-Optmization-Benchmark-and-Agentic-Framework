#!/usr/bin/env bash
# Tutorials A/B on Claude models via Argo. Same 4 hard kernels, two configs:
#   H: XKERNEL_TUTORIALS=0 (baseline — reviewer + debug-recipes + mesh + release-notes)
#   I: XKERNEL_TUTORIALS=1 (full stack incl. 217-chunk tutorials corpus)
#
# Runs on BOTH claude-sonnet-4-6 and claude-opus-4-7 sequentially. ETA ~3-4h.
set -e

KERNELS="Game-of-Life,Residual,7pt-Stencil,FFT-1D-2D"
TS=$(date -u +%Y%m%d_%H%M%S)
ROOT="/home/USER/xkernel/code_translation/results/ab_tutorials_claude_${TS}"
mkdir -p "$ROOT"
LOG="$ROOT/ab.log"
: > "$LOG"

export XKERNEL_LLM_TIMEOUT_S=240

run_config() {
    local MODEL=$1; local NAME=$2; local TUT=$3
    local OUT="$ROOT/$NAME"
    echo "==== START $NAME on $MODEL (XKERNEL_TUTORIALS=$TUT) ====" | tee -a "$LOG"
    date -u +"start: %Y-%m-%dT%H:%M:%SZ" | tee -a "$LOG"
    XKERNEL_TUTORIALS=$TUT bash /home/USER/xkernel/run_argo_sweep_one.sh \
        "$MODEL" "$OUT" \
        --kernels "$KERNELS" --reviewer-max-attempts 8 \
        --timeout 1800 --inter-kernel-delay 15 \
        >>"$LOG" 2>&1
    local RC=$?
    echo "EXIT=$RC for $NAME" | tee -a "$LOG"
    date -u +"end:   %Y-%m-%dT%H:%M:%SZ" | tee -a "$LOG"
    echo | tee -a "$LOG"
}

# Sonnet 4.6 first (faster; if anything blows up we know early).
run_config "claude-sonnet-4-6" "sonnet_H_no_tutorials"   "0"
run_config "claude-sonnet-4-6" "sonnet_I_with_tutorials" "1"

# Opus 4.7.
run_config "claude-opus-4-7" "opus_H_no_tutorials"   "0"
run_config "claude-opus-4-7" "opus_I_with_tutorials" "1"

echo "===== CLAUDE TUTORIALS A/B SWEEP COMPLETE =====" | tee -a "$LOG"
echo "$ROOT" > /tmp/ab_tutorials_claude_root
echo "Outputs under: $ROOT"
