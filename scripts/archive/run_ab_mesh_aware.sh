#!/usr/bin/env bash
# A/B test for the wafer-scale pattern catalog + mesh-decomposition planner.
#
# Runs gpt-oss-120b agentic on the 4 kernels that errored in the original
# agentic sweep (Game-of-Life, Residual, 7pt-Stencil, FFT-1D-2D), under 4
# configurations:
#   A: baseline      — XKERNEL_MESH_PATTERNS=0, --skip-planner
#   B: catalog only  — XKERNEL_MESH_PATTERNS=1, --skip-planner
#   C: planner only  — XKERNEL_MESH_PATTERNS=0, planner active
#   D: both          — XKERNEL_MESH_PATTERNS=1, planner active
#
# Output: results/ab_mesh_<ts>/{A,B,C,D}/<batch_*>/results.json
set -e

KERNELS="Game-of-Life,Residual,7pt-Stencil,FFT-1D-2D"
MODEL="openai/gpt-oss-120b"
TS=$(date -u +%Y%m%d_%H%M%S)
ROOT="/home/USER/xkernel/code_translation/results/ab_mesh_${TS}"
mkdir -p "$ROOT"
LOG="$ROOT/ab.log"
: > "$LOG"

export XKERNEL_LLM_TIMEOUT_S=180

run_config() {
    local NAME=$1; local MESH=$2; local SKIP_PLANNER_FLAG=$3
    local OUT="$ROOT/$NAME"
    echo "==== START config $NAME (mesh=$MESH planner_flag=$SKIP_PLANNER_FLAG) ====" | tee -a "$LOG"
    date -u +"start: %Y-%m-%dT%H:%M:%SZ" | tee -a "$LOG"
    XKERNEL_MESH_PATTERNS=$MESH bash /home/USER/xkernel/run_alcf_sweep_one.sh \
        "$MODEL" "$OUT" \
        --kernels "$KERNELS" --turns 4 --timeout 1800 --inter-kernel-delay 15 \
        $SKIP_PLANNER_FLAG \
        >>"$LOG" 2>&1
    local RC=$?
    echo "EXIT=$RC for $NAME" | tee -a "$LOG"
    date -u +"end:   %Y-%m-%dT%H:%M:%SZ" | tee -a "$LOG"
    echo | tee -a "$LOG"
}

run_config "A_baseline"      0 "--skip-planner"
run_config "B_catalog_only"  1 "--skip-planner"
run_config "C_planner_only"  0 ""
run_config "D_both"          1 ""

echo "===== A/B SWEEP COMPLETE =====" | tee -a "$LOG"
echo "Outputs under: $ROOT"
echo "$ROOT" > /tmp/ab_root
