#!/usr/bin/env bash
# Skills RAG A/B on Claude models via Argo. Same 4 hard kernels, two configs:
#   K: XKERNEL_SKILLS=0 + narrow tutorials (baseline)
#   L: XKERNEL_SKILLS=1 + narrow tutorials (skills layer added)
#
# Runs on BOTH claude-sonnet-4-6 and claude-opus-4-7 sequentially. ETA ~3-4h.
# All other knowledge layers (reviewer, debug-recipes, mesh, release-notes)
# stay ON in both configs.
set -e

KERNELS="Game-of-Life,Residual,7pt-Stencil,FFT-1D-2D"
NARROW_KB="/home/USER/xkernel/knowledge/data/cerebras_tutorials_narrow.jsonl"
TS=$(date -u +%Y%m%d_%H%M%S)
ROOT="/home/USER/xkernel/code_translation/results/ab_skills_claude_${TS}"
mkdir -p "$ROOT"
LOG="$ROOT/ab.log"
: > "$LOG"

export XKERNEL_LLM_TIMEOUT_S=240

run_config() {
    local MODEL=$1; local NAME=$2; local SKILLS=$3
    local OUT="$ROOT/$NAME"
    echo "==== START $NAME on $MODEL (XKERNEL_SKILLS=$SKILLS, tutorials=narrow) ====" | tee -a "$LOG"
    date -u +"start: %Y-%m-%dT%H:%M:%SZ" | tee -a "$LOG"
    XKERNEL_SKILLS=$SKILLS \
    XKERNEL_TUTORIALS=1 \
    XKERNEL_TUTORIALS_KB_PATH="$NARROW_KB" \
    bash /home/USER/xkernel/run_argo_sweep_one.sh \
        "$MODEL" "$OUT" \
        --kernels "$KERNELS" --reviewer-max-attempts 8 \
        --timeout 1800 --inter-kernel-delay 15 \
        >>"$LOG" 2>&1
    local RC=$?
    echo "EXIT=$RC for $NAME" | tee -a "$LOG"
    date -u +"end:   %Y-%m-%dT%H:%M:%SZ" | tee -a "$LOG"
    echo | tee -a "$LOG"
}

# Sonnet 4.6 first (faster).
run_config "claude-sonnet-4-6" "sonnet_K_no_skills"   "0"
run_config "claude-sonnet-4-6" "sonnet_L_with_skills" "1"

# Opus 4.7.
run_config "claude-opus-4-7" "opus_K_no_skills"   "0"
run_config "claude-opus-4-7" "opus_L_with_skills" "1"

echo "===== CLAUDE SKILLS A/B SWEEP COMPLETE =====" | tee -a "$LOG"
echo "$ROOT" > /tmp/ab_skills_claude_root
echo "Outputs under: $ROOT"
