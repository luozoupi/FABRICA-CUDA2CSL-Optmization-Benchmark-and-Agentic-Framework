#!/usr/bin/env bash
# Builtin-whitelist A/B on gpt-oss-120b + Sonnet 4.6 + Opus 4.7.
# 4 hard kernels. Baseline = best-known config (skills ON + narrow tutorials).
# Tests whether a hard whitelist of @-builtins (defined in prompt_cuda2csl.py)
# stops the recurring @my_pe_x / hallucinated-builtin failures.
#
#   M: XKERNEL_BUILTIN_WHITELIST=0  (baseline)
#   N: XKERNEL_BUILTIN_WHITELIST=1  (whitelist injected)
#
# Sweeps both configs on gpt-oss + Sonnet + Opus (~5-6h total wall).
set -e

KERNELS="Game-of-Life,Residual,7pt-Stencil,FFT-1D-2D"
NARROW_KB="/home/USER/xkernel/knowledge/data/cerebras_tutorials_narrow.jsonl"
TS=$(date -u +%Y%m%d_%H%M%S)
ROOT="/home/USER/xkernel/code_translation/results/ab_whitelist_${TS}"
mkdir -p "$ROOT"
LOG="$ROOT/ab.log"
: > "$LOG"

export XKERNEL_LLM_TIMEOUT_S=180

# Shared layer defaults across all runs
export XKERNEL_SKILLS=1
export XKERNEL_TUTORIALS=1
export XKERNEL_TUTORIALS_KB_PATH="$NARROW_KB"

run_alcf() {
    local NAME=$1; local WL=$2
    local OUT="$ROOT/$NAME"
    echo "==== START $NAME on gpt-oss-120b (XKERNEL_BUILTIN_WHITELIST=$WL) ====" | tee -a "$LOG"
    date -u +"start: %Y-%m-%dT%H:%M:%SZ" | tee -a "$LOG"
    XKERNEL_BUILTIN_WHITELIST=$WL \
    bash /home/USER/xkernel/run_alcf_sweep_one.sh \
        "openai/gpt-oss-120b" "$OUT" \
        --kernels "$KERNELS" --reviewer-max-attempts 8 \
        --timeout 1800 --inter-kernel-delay 15 \
        >>"$LOG" 2>&1
    local RC=$?
    echo "EXIT=$RC for $NAME" | tee -a "$LOG"
    date -u +"end:   %Y-%m-%dT%H:%M:%SZ" | tee -a "$LOG"
    echo | tee -a "$LOG"
}

run_argo() {
    local MODEL=$1; local NAME=$2; local WL=$3
    local OUT="$ROOT/$NAME"
    echo "==== START $NAME on $MODEL (XKERNEL_BUILTIN_WHITELIST=$WL) ====" | tee -a "$LOG"
    date -u +"start: %Y-%m-%dT%H:%M:%SZ" | tee -a "$LOG"
    XKERNEL_BUILTIN_WHITELIST=$WL \
    XKERNEL_LLM_TIMEOUT_S=240 \
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

# Sequence: gpt-oss first (fastest, cheapest signal), then Sonnet, then Opus
run_alcf "gptoss_M_no_whitelist"   "0"
run_alcf "gptoss_N_with_whitelist" "1"

run_argo "claude-sonnet-4-6" "sonnet_M_no_whitelist"   "0"
run_argo "claude-sonnet-4-6" "sonnet_N_with_whitelist" "1"

run_argo "claude-opus-4-7" "opus_M_no_whitelist"   "0"
run_argo "claude-opus-4-7" "opus_N_with_whitelist" "1"

echo "===== WHITELIST A/B SWEEP COMPLETE =====" | tee -a "$LOG"
echo "$ROOT" > /tmp/ab_whitelist_root
echo "Outputs under: $ROOT"
