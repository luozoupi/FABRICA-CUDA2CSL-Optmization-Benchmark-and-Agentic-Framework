#!/usr/bin/env bash
# Reviewer A/B on Claude Opus 4.7 via Argo. Same shape as the Sonnet sweep.
set -e

KERNELS="Game-of-Life,Residual,7pt-Stencil,FFT-1D-2D"
MODEL="claude-opus-4-7"
TS=$(date -u +%Y%m%d_%H%M%S)
ROOT="/home/USER/xkernel/code_translation/results/ab_reviewer_opus_${TS}"
mkdir -p "$ROOT"
LOG="$ROOT/ab.log"
: > "$LOG"

export XKERNEL_LLM_TIMEOUT_S=240

run_config() {
    local NAME=$1; shift
    local EXTRA_FLAGS=$@
    local OUT="$ROOT/$NAME"
    echo "==== START $NAME (flags=$EXTRA_FLAGS) ====" | tee -a "$LOG"
    date -u +"start: %Y-%m-%dT%H:%M:%SZ" | tee -a "$LOG"
    bash /home/USER/xkernel/run_argo_sweep_one.sh \
        "$MODEL" "$OUT" \
        --kernels "$KERNELS" --timeout 1800 --inter-kernel-delay 15 \
        $EXTRA_FLAGS \
        >>"$LOG" 2>&1
    local RC=$?
    echo "EXIT=$RC for $NAME" | tee -a "$LOG"
    date -u +"end:   %Y-%m-%dT%H:%M:%SZ" | tee -a "$LOG"
    echo | tee -a "$LOG"
}

run_config "E_baseline" "--skip-reviewer --turns 4"
run_config "G_reviewer_plus_respin" "--reviewer-max-attempts 8"

echo "===== OPUS A/B REVIEWER SWEEP COMPLETE =====" | tee -a "$LOG"
echo "$ROOT" > /tmp/ab_reviewer_opus_root
