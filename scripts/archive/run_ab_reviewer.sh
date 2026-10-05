#!/usr/bin/env bash
# A/B test for the reviewer agent + failure routing.
#
# Runs gpt-oss-120b on the 4 kernels that errored in the original agentic sweep
# (Game-of-Life, Residual, 7pt-Stencil, FFT-1D-2D) under 3 configurations:
#
#   E: baseline           — --skip-reviewer (legacy fix prompt, --turns 4)
#   F: reviewer only      — reviewer ON, architect respin cap = 0 (set via env)
#   G: reviewer + respin  — reviewer ON, architect respin cap = 2 (default)
#
# Output: results/ab_reviewer_<ts>/{E,F,G}/<batch_*>/results.json
set -e

KERNELS="Game-of-Life,Residual,7pt-Stencil,FFT-1D-2D"
MODEL="openai/gpt-oss-120b"
TS=$(date -u +%Y%m%d_%H%M%S)
ROOT="/home/USER/xkernel/code_translation/results/ab_reviewer_${TS}"
mkdir -p "$ROOT"
LOG="$ROOT/ab.log"
: > "$LOG"

export XKERNEL_LLM_TIMEOUT_S=180

run_config() {
    local NAME=$1; shift
    local EXTRA_FLAGS=$@
    local OUT="$ROOT/$NAME"
    echo "==== START config $NAME (flags=$EXTRA_FLAGS) ====" | tee -a "$LOG"
    date -u +"start: %Y-%m-%dT%H:%M:%SZ" | tee -a "$LOG"
    bash /home/USER/xkernel/run_alcf_sweep_one.sh \
        "$MODEL" "$OUT" \
        --kernels "$KERNELS" --timeout 1800 --inter-kernel-delay 15 \
        $EXTRA_FLAGS \
        >>"$LOG" 2>&1
    local RC=$?
    echo "EXIT=$RC for $NAME" | tee -a "$LOG"
    date -u +"end:   %Y-%m-%dT%H:%M:%SZ" | tee -a "$LOG"
    echo | tee -a "$LOG"
}

# E: legacy --skip-reviewer baseline; --turns 4 is the legacy default
run_config "E_baseline" "--skip-reviewer --turns 4"

# F: reviewer ON, but respin cap = 0 via env so all A verdicts demote to B
# (we set MAX_ARCHITECT_RESPINS=0 by patching the class default in a tiny wrapper)
XKERNEL_FORCE_RESPIN_CAP=0 run_config "F_reviewer_only" "--reviewer-max-attempts 8"

# G: reviewer ON with respin enabled (default cap = 2)
run_config "G_reviewer_plus_respin" "--reviewer-max-attempts 8"

echo "===== A/B REVIEWER SWEEP COMPLETE =====" | tee -a "$LOG"
echo "Outputs under: $ROOT"
echo "$ROOT" > /tmp/ab_reviewer_root
