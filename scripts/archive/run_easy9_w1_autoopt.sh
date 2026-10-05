#!/usr/bin/env bash
# Track C: re-test the 9 already-passing-correctness kernels (gpt-oss-120b
# original sweep, May 27) that DON'T have cycles_send instrumentation.
# Two things measured at once:
#   (1) Correctness regression check — does the post-pivot pipeline still
#       translate these as well as the old one (which got 9/9 of them)?
#   (2) Cycle-reduction noop confirmation — --auto-optimize is set; it
#       should skip with "no baseline cycles_send" rather than spinning the
#       optimizer pointlessly. That gate is the only thing to verify.
# The 4 cycle-instrumented kernels (BiCGSTAB/CG/Power/PCG) are NOT in this
# set; they're covered by Track A's cycle sweep.
set -u

KERNELS="GEMM,GEMV,GEMM-Collectives-2D,GEMV-Checkerboard,GEMV-Collectives-2D,Wide-Multiplication,Single-Tile-Matvec,Cholesky,Mandelbrot"
TS=$(date -u +%Y%m%d_%H%M%S)
ROOT=/home/USER/xkernel/code_translation/results/easy9_w1_autoopt_${TS}
mkdir -p "$ROOT"
LOG="$ROOT/sweep.log"
: > "$LOG"
echo "$ROOT" > /tmp/easy9_w1_autoopt_root

export XKERNEL_LLM_TIMEOUT_S=180
export XKERNEL_SKILLS=1
export XKERNEL_TUTORIALS=1
export XKERNEL_TUTORIALS_KB_PATH=/home/USER/xkernel/knowledge/data/cerebras_tutorials_narrow.jsonl
export XKERNEL_BUILTIN_WHITELIST=1

echo "==== START easy9 W1 + auto-optimize ====" | tee -a "$LOG"
date -u +"start: %Y-%m-%dT%H:%M:%SZ" | tee -a "$LOG"

bash /home/USER/xkernel/run_alcf_sweep_one.sh \
    "openai/gpt-oss-120b" "$ROOT" \
    --kernels "$KERNELS" --reviewer-max-attempts 8 \
    --auto-optimize --min-optimize-attempts 5 --max-optimize-attempts 10 \
    --timeout 1800 --inter-kernel-delay 15 \
    >> "$LOG" 2>&1
RC=$?

echo "EXIT=$RC" | tee -a "$LOG"
date -u +"end:   %Y-%m-%dT%H:%M:%SZ" | tee -a "$LOG"
echo "===== EASY9 W1 + auto-optimize COMPLETE =====" | tee -a "$LOG"
echo "Outputs under: $ROOT"
