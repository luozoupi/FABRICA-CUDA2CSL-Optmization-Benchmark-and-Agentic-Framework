#!/usr/bin/env bash
# A/B sweep: tutorials RAG corpus ON vs OFF, on gpt-oss-120b, on the 4 hard kernels.
#
# H: baseline — XKERNEL_TUTORIALS=0 (debug-recipes + mesh-patterns + release-notes
#    + reviewer all still on; only the new tutorials corpus is suppressed)
# I: full — XKERNEL_TUTORIALS=1 (the post-tutorial wiring)
#
# Same reviewer config across both so the only variable is the tutorial corpus.

set -e

KERNELS="Game-of-Life,Residual,7pt-Stencil,FFT-1D-2D"
MODEL="openai/gpt-oss-120b"
TS=$(date -u +%Y%m%d_%H%M%S)
ROOT="/home/USER/xkernel/code_translation/results/ab_tutorials_${TS}"
mkdir -p "$ROOT"
LOG="$ROOT/ab.log"
: > "$LOG"

export XKERNEL_LLM_TIMEOUT_S=180

run_config() {
    local NAME=$1; local TUT=$2
    local OUT="$ROOT/$NAME"
    echo "==== START $NAME (XKERNEL_TUTORIALS=$TUT) ====" | tee -a "$LOG"
    date -u +"start: %Y-%m-%dT%H:%M:%SZ" | tee -a "$LOG"
    XKERNEL_TUTORIALS=$TUT bash /home/USER/xkernel/run_alcf_sweep_one.sh \
        "$MODEL" "$OUT" \
        --kernels "$KERNELS" --reviewer-max-attempts 8 \
        --timeout 1800 --inter-kernel-delay 15 \
        >>"$LOG" 2>&1
    local RC=$?
    echo "EXIT=$RC for $NAME" | tee -a "$LOG"
    date -u +"end:   %Y-%m-%dT%H:%M:%SZ" | tee -a "$LOG"
    echo | tee -a "$LOG"
}

run_config "H_no_tutorials"   "0"
run_config "I_with_tutorials" "1"

echo "===== TUTORIALS A/B SWEEP COMPLETE =====" | tee -a "$LOG"
echo "$ROOT" > /tmp/ab_tutorials_root
echo "Outputs under: $ROOT"
