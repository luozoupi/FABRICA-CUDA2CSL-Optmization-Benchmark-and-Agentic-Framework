#!/usr/bin/env bash
# Debugger sub-agent A/B on gpt-oss-120b + Sonnet 4.6 + Opus 4.7.
# 4 hard kernels. Baseline = current best (whitelist ON + skills ON + narrow tutorials).
# Tests whether the structured debugger report (XKERNEL_DEBUGGER=1) actually
# moves the implementer's behavior beyond what reviewer+whitelist already do.
#
#   P: XKERNEL_DEBUGGER=0  (baseline — debugger off, current behavior)
#   Q: XKERNEL_DEBUGGER=1  (debugger fires per debugger_agent.should_fire)
#
# Sweeps both configs on gpt-oss + Sonnet + Opus (~5-6h total wall).
set -e

KERNELS="Game-of-Life,Residual,7pt-Stencil,FFT-1D-2D"
NARROW_KB="/home/USER/xkernel/knowledge/data/cerebras_tutorials_narrow.jsonl"
TS=$(date -u +%Y%m%d_%H%M%S)
ROOT="/home/USER/xkernel/code_translation/results/ab_debugger_${TS}"
mkdir -p "$ROOT"
LOG="$ROOT/ab.log"
: > "$LOG"

export XKERNEL_LLM_TIMEOUT_S=180

# Shared layer defaults across all runs (best-known baseline).
export XKERNEL_SKILLS=1
export XKERNEL_TUTORIALS=1
export XKERNEL_TUTORIALS_KB_PATH="$NARROW_KB"
export XKERNEL_BUILTIN_WHITELIST=1

run_alcf() {
    local NAME=$1; local DBG=$2
    local OUT="$ROOT/$NAME"
    echo "==== START $NAME on gpt-oss-120b (XKERNEL_DEBUGGER=$DBG) ====" | tee -a "$LOG"
    date -u +"start: %Y-%m-%dT%H:%M:%SZ" | tee -a "$LOG"
    XKERNEL_DEBUGGER=$DBG \
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
    local MODEL=$1; local NAME=$2; local DBG=$3
    local OUT="$ROOT/$NAME"
    echo "==== START $NAME on $MODEL (XKERNEL_DEBUGGER=$DBG) ====" | tee -a "$LOG"
    date -u +"start: %Y-%m-%dT%H:%M:%SZ" | tee -a "$LOG"
    XKERNEL_DEBUGGER=$DBG \
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

run_alcf "gptoss_P_no_debugger"     "0"
run_alcf "gptoss_Q_with_debugger"   "1"

run_argo "claude-sonnet-4-6" "sonnet_P_no_debugger"   "0"
run_argo "claude-sonnet-4-6" "sonnet_Q_with_debugger" "1"

run_argo "claude-opus-4-7" "opus_P_no_debugger"   "0"
run_argo "claude-opus-4-7" "opus_Q_with_debugger" "1"

echo "===== DEBUGGER A/B SWEEP COMPLETE =====" | tee -a "$LOG"
echo "$ROOT" > /tmp/ab_debugger_root
echo "Outputs under: $ROOT"
