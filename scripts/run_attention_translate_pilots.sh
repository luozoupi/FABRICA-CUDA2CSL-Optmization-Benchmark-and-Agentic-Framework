#!/usr/bin/env bash
# Attention translation pilots (W1, no optimization): Attention-1PE and
# Attention-QP x 3 seeds through the Anthropic launcher. Serial SDK: never run
# alongside another cslc/cs_python. Resumable: a seed with a benchmark.json is
# skipped. Relaunched 2026-09-08 after the compile-only dry-check fix
# (benchmark_csl.select_compile_only_commands).
set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/xkernel_env.sh"
export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1
KERNELS="${KERNELS:-Attention-1PE Attention-QP}"
SEEDS="${SEEDS:-1 2 3}"
TAG="${TAG:-attention_translate_$(date -u +%Y%m%d)}"
LOG="$XKERNEL_ROOT/code_translation/results/${TAG}.log"
echo "pilots start $(date -u +%FT%TZ) kernels=[$KERNELS] seeds=[$SEEDS]" | tee -a "$LOG"
for k in $KERNELS; do
  for seed in $SEEDS; do
    OUT="$XKERNEL_ROOT/code_translation/results/$TAG/$k/seed_$seed"
    if ls "$OUT"/run_*/"$k"/benchmark.json >/dev/null 2>&1; then echo "skip $k seed $seed (done)" | tee -a "$LOG"; continue; fi
    mkdir -p "$OUT"
    echo "translate $k seed $seed start $(date -u +%H:%M:%S)" | tee -a "$LOG"
    XKERNEL_TEMPLATE_GEN=1 XKERNEL_DRY_CHECK=1 XKERNEL_ERROR_GOTCHA=1 XKERNEL_HELDOUT_EVAL=1 XKERNEL_KEEP_CANDIDATES=1 \
      timeout 5400 bash "$XKERNEL_ROOT/run_cuda2csl_anthropic.sh" --kernel "$k" --turns 4 --reviewer-max-attempts 10 \
      --output "$OUT" >>"$OUT/run.log" 2>&1
    rc=$?
    echo "translate $k seed $seed exit=$rc $(date -u +%H:%M:%S)" | tee -a "$LOG"
    pkill -u "$(whoami)" -f squashfuse_ll 2>/dev/null || true
  done
done
echo "pilots done $(date -u +%FT%TZ)" | tee -a "$LOG"
