#!/usr/bin/env bash
# Tutorials A/B narrow-corpus ablation on gpt-oss-120b.
#
# H: XKERNEL_TUTORIALS=0 (baseline — reviewer + debug-recipes + mesh + release-notes)
# I: XKERNEL_TUTORIALS=1 (broad corpus, 217 chunks across 33 tutorials)
# J: XKERNEL_TUTORIALS=1 + XKERNEL_TUTORIALS_KB_PATH=...narrow.jsonl
#    (29 chunks from JUST: topic-09-fifos, topic-11-collectives,
#     topic-12-debug-library, gemv-06-routes-1)
#
# I already lives at ab_tutorials_20260530_195632/I_with_tutorials/. This
# script re-runs H (for clean comparison against today's loop state, which
# now includes the initial-translate retry fix) and J. Compare to I from
# the prior sweep.
set -e

KERNELS="Game-of-Life,Residual,7pt-Stencil,FFT-1D-2D"
MODEL="openai/gpt-oss-120b"
NARROW_KB="/home/USER/xkernel/knowledge/data/cerebras_tutorials_narrow.jsonl"
TS=$(date -u +%Y%m%d_%H%M%S)
ROOT="/home/USER/xkernel/code_translation/results/ab_tutorials_narrow_${TS}"
mkdir -p "$ROOT"
LOG="$ROOT/ab.log"
: > "$LOG"

export XKERNEL_LLM_TIMEOUT_S=180

run_config() {
    local NAME=$1; local TUT=$2; local KB_PATH=$3
    local OUT="$ROOT/$NAME"
    echo "==== START $NAME (XKERNEL_TUTORIALS=$TUT, KB_PATH=${KB_PATH:-default}) ====" | tee -a "$LOG"
    date -u +"start: %Y-%m-%dT%H:%M:%SZ" | tee -a "$LOG"
    XKERNEL_TUTORIALS=$TUT \
    XKERNEL_TUTORIALS_KB_PATH="$KB_PATH" \
    bash /home/USER/xkernel/run_alcf_sweep_one.sh \
        "$MODEL" "$OUT" \
        --kernels "$KERNELS" --reviewer-max-attempts 8 \
        --timeout 1800 --inter-kernel-delay 15 \
        >>"$LOG" 2>&1
    local RC=$?
    echo "EXIT=$RC for $NAME" | tee -a "$LOG"
    date -u +"end:   %Y-%m-%dT%H:%M:%SZ" | tee -a "$LOG"
    echo | tee -a "$LOG"
}

run_config "H_no_tutorials_v2"  "0" ""
run_config "J_narrow_tutorials" "1" "$NARROW_KB"

echo "===== NARROW TUTORIALS A/B SWEEP COMPLETE =====" | tee -a "$LOG"
echo "$ROOT" > /tmp/ab_tutorials_narrow_root
echo "Outputs under: $ROOT"
