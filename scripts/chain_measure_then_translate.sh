#!/usr/bin/env bash
# Serial SDK chain (2026-09-08): measure the new references and scaling sizes,
# then translate the attention tasks (3 seeds each) if their references pass.
# Run in the background; never in parallel with another cslc/cs_python.
set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/xkernel_env.sh"
export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1
LOG="$XKERNEL_ROOT/code_translation/results/chain_$(date -u +%Y%m%d_%H%M%S).log"
echo "chain start $(date -u +%FT%TZ)" | tee "$LOG"

# 1) attention references (all sizes) and the new GEMM / GEMV-Collectives-2D sizes
xk_python code_translation/rebaseline_references.py --kernels Attention-1PE,Attention-QP --num-runs 3 2>&1 | tee -a "$LOG"
xk_python code_translation/rebaseline_references.py --kernels GEMM --sizes p2,p8_t14 --num-runs 3 2>&1 | tee -a "$LOG"
xk_python code_translation/rebaseline_references.py --kernels GEMV-Collectives-2D --sizes p2,p8 --num-runs 3 2>&1 | tee -a "$LOG"

# 2) attention translation pilots (full workflow, no optimization) if the small references passed
latest=$(ls -t "$XKERNEL_ROOT"/code_translation/results/rebaseline/rebaseline_*.json | head -3)
ok=$(python3 - $latest <<'PY'
import json, sys
ok = {"Attention-1PE": False, "Attention-QP": False}
for p in sys.argv[1:]:
    d = json.load(open(p))
    for k in ok:
        m = (d.get("kernels", {}).get(k) or {}).get("small")
        if m and m.get("status") == "pass" and m.get("success_marker"):
            ok[k] = True
print(" ".join(k for k, v in ok.items() if v))
PY
)
echo "attention references passing: [$ok]" | tee -a "$LOG"
for k in $ok; do
  for seed in 1 2 3; do
    OUT="$XKERNEL_ROOT/code_translation/results/attention_translate_$(date -u +%Y%m%d)/$k/seed_$seed"
    if ls "$OUT"/run_*/"$k"/benchmark.json >/dev/null 2>&1; then echo "skip $k seed $seed (done)" | tee -a "$LOG"; continue; fi
    mkdir -p "$OUT"
    echo "translate $k seed $seed start $(date -u +%H:%M:%S)" | tee -a "$LOG"
    XKERNEL_TEMPLATE_GEN=1 XKERNEL_DRY_CHECK=1 XKERNEL_ERROR_GOTCHA=1 XKERNEL_HELDOUT_EVAL=1 XKERNEL_KEEP_CANDIDATES=1 \
      timeout 5400 bash "$XKERNEL_ROOT/run_cuda2csl_anthropic.sh" --kernel "$k" --turns 4 --reviewer-max-attempts 10 \
      --output "$OUT" >>"$OUT/run.log" 2>&1
    echo "translate $k seed $seed exit=$? $(date -u +%H:%M:%S)" | tee -a "$LOG"
    pkill -u "$(whoami)" -f squashfuse_ll 2>/dev/null || true
  done
done
echo "chain done $(date -u +%FT%TZ)" | tee -a "$LOG"
