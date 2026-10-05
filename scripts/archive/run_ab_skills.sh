#!/usr/bin/env bash
# Skills RAG A/B on gpt-oss-120b. Same 4 hard kernels.
#
# Configs (all layers below the implementer are the same as previous best):
#   K: XKERNEL_SKILLS=0 + XKERNEL_TUTORIALS=1 (narrow)  -- baseline (current best)
#   L: XKERNEL_SKILLS=1 + XKERNEL_TUTORIALS=1 (narrow)  -- skills + narrow tutorials
#
# The narrow tutorials corpus is locked in as the baseline because the
# tutorials A/B showed broad>narrow only hurt pass count on this set.
# Skills is the only new variable here.
set -e

KERNELS="Game-of-Life,Residual,7pt-Stencil,FFT-1D-2D"
MODEL="openai/gpt-oss-120b"
NARROW_KB="/home/USER/xkernel/knowledge/data/cerebras_tutorials_narrow.jsonl"
TS=$(date -u +%Y%m%d_%H%M%S)
ROOT="/home/USER/xkernel/code_translation/results/ab_skills_${TS}"
mkdir -p "$ROOT"
LOG="$ROOT/ab.log"
: > "$LOG"

export XKERNEL_LLM_TIMEOUT_S=180

run_config() {
    local NAME=$1; local SKILLS=$2
    local OUT="$ROOT/$NAME"
    echo "==== START $NAME (XKERNEL_SKILLS=$SKILLS, tutorials=narrow) ====" | tee -a "$LOG"
    date -u +"start: %Y-%m-%dT%H:%M:%SZ" | tee -a "$LOG"
    XKERNEL_SKILLS=$SKILLS \
    XKERNEL_TUTORIALS=1 \
    XKERNEL_TUTORIALS_KB_PATH="$NARROW_KB" \
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

run_config "K_no_skills"    "0"
run_config "L_with_skills"  "1"

echo "===== SKILLS A/B SWEEP COMPLETE =====" | tee -a "$LOG"
echo "$ROOT" > /tmp/ab_skills_root
echo "Outputs under: $ROOT"
