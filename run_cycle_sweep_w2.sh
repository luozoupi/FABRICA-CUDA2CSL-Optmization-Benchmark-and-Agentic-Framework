#!/usr/bin/env bash
# Workflow-2 cycle-reduction sweep across the 5 cycle-instrumented kernels.
# Each kernel: --optimize-only against its reference CSL, baseline = the
# reference's measured cycles_send, 10 attempts max. Contract validator
# gates every variant. Per kernels/BENCHMARK.md, success = fast_1.1+
# (≥9% reduction); the 7pt-Stencil smoke just landed fast_1.5 (1.73×).
set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${XKERNEL_ROOT:-$SCRIPT_DIR}/xkernel_env.sh"

KERNELS=(
    "7pt-Stencil:kernels/7-Point Stencil/CSL/src/kernel.csl"
    "Power-Method:kernels/Power Method/CSL/src/kernel_power.csl"
    "CG:kernels/Conjugate Gradient/CSL/src/kernel_cg.csl"
    "Preconditioned-CG:kernels/Preconditioned CG/CSL/src/kernel_pcg.csl"
    "BiCGSTAB:kernels/BiCGSTAB/CSL/src/kernel_bicgstab.csl"
)

TS=$(date -u +%Y%m%d_%H%M%S)
ROOT=$XKERNEL_ROOT/code_translation/results/cycle_sweep_w2_${TS}
mkdir -p "$ROOT"
LOG="$ROOT/sweep.log"
: > "$LOG"
echo "$ROOT" > /tmp/cycle_sweep_w2_root

export XKERNEL_LLM_TIMEOUT_S=180

for spec in "${KERNELS[@]}"; do
    KNAME="${spec%%:*}"
    CSL_PATH="$XKERNEL_ROOT/${spec#*:}"
    KOUT="$ROOT/${KNAME}"
    mkdir -p "$KOUT"
    echo "==== START $KNAME ====" | tee -a "$LOG"
    date -u +"start: %Y-%m-%dT%H:%M:%SZ" | tee -a "$LOG"
    "$XKERNEL_MICROMAMBA" run -n $XKERNEL_ENV python \
        $XKERNEL_ROOT/code_translation/cuda2csl.py \
        --kernel "$KNAME" \
        --optimize-only \
        --csl-path "$CSL_PATH" \
        --model openai/gpt-oss-120b \
        --api-key-file /dev/null \
        --alcf-endpoint sophia \
        --api-key-command "$XKERNEL_MICROMAMBA run -n globus_env python $XKERNEL_ROOT/code_translation/inference_auth_token.py get_access_token" \
        --sdk-root $XKERNEL_SDK_ROOT \
        --min-optimize-attempts 5 \
        --max-optimize-attempts 10 \
        --output "$KOUT" \
        >> "$LOG" 2>&1
    RC=$?
    echo "EXIT=$RC for $KNAME" | tee -a "$LOG"
    date -u +"end:   %Y-%m-%dT%H:%M:%SZ" | tee -a "$LOG"
    echo | tee -a "$LOG"
    sleep 10  # short endpoint cooldown
done
echo "===== CYCLE W2 SWEEP COMPLETE =====" | tee -a "$LOG"
echo "Outputs under: $ROOT"
