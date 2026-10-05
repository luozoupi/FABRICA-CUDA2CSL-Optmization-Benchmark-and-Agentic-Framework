#!/usr/bin/env bash
# Held-out TEST-split sweep: from-CUDA translate + auto-optimize, at the LARGE
# size where one exists (else small), scored against the human reference.
#
# This is the paper's main-table experiment. METHODOLOGY CAVEATS (documented in
# results + docs/SPLIT_AND_LEAKAGE.md):
#   - The standard framework SHOWS reference layout.csl to the agent (the canary
#     hides only the reference COMPUTE file). So this measures
#     "translate the compute + optimize, GIVEN the decomposition skeleton",
#     NOT "discover the decomposition" (that is the stronger GEMV holed-template
#     claim, which has a per-kernel harness only for GEMV today).
#   - Test-split large sizes are compute-dominant (bigger z-pencil / tile on the
#     same mesh), not decomposition-mandatory like GEMV 512x256.
#   - GEMM/GEMV are TRAIN-only (WaferLLM overlap) -> excluded from this claim.
#
# Serial only: the SDK container wedges under parallel cslc.
#
# Usage: run_test_split_sweep.sh [--cap N] [--model M] [--kernel K --size S]...
set -u

MODEL="${ARGO_MODEL:-claude-opus-4-7}"
CAP="${CAP:-12}"
LAUNCHER="$HOME/xkernel/run_cuda2csl_argo.sh"

# (kernel, size) pairs. large where a decomposition/compute-scaled size exists;
# "none" for kernels with NO spec.yaml size axis -> omit --size (would raise
# "size not found"; they synthesize only a 'default' size from the registry).
PAIRS=(
  "7pt-Stencil:large"
  "Laplacian2D-Halo:large"
  "Cholesky:small"
  "Residual:none"
  "Game-of-Life:none"
  "Single-Tile-Matvec:none"
  "Wide-Multiplication:none"
)

# allow overriding the pair list from CLI: --only "7pt-Stencil:large Cholesky:small"
while [ $# -gt 0 ]; do
  case "$1" in
    --cap)   CAP="$2"; shift 2 ;;
    --model) MODEL="$2"; shift 2 ;;
    --only)  read -r -a PAIRS <<< "$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 2 ;;
  esac
done

TS=$(date -u +%Y%m%d_%H%M%S)
ROOT="$HOME/xkernel/code_translation/results/test_split_sweep_${TS}"
mkdir -p "$ROOT"
echo "Test-split sweep root: $ROOT"
echo "model=$MODEL cap=$CAP pairs=${PAIRS[*]}" | tee "$ROOT/config.txt"

_passed() {  # results_dir kernel_key
  local bj
  bj=$(ls -t "$1"/run_*/"$2"/benchmark.json 2>/dev/null | head -1)
  [ -n "$bj" ] && [ -f "$bj" ] || return 1
  python3 -c "import json,sys
try: sys.exit(0 if json.load(open(sys.argv[1])).get('status')=='pass' else 1)
except Exception: sys.exit(2)" "$bj"
}
_metric() {  # results_dir kernel_key field
  local bj
  bj=$(ls -t "$1"/run_*/"$2"/benchmark.json 2>/dev/null | head -1)
  [ -n "$bj" ] || { echo "-"; return; }
  python3 -c "import json
try:
    d=json.load(open('$bj')); print(d.get('$3') or d.get('metrics',{}).get('$3') or '-')
except Exception: print('-')"
}

for PAIR in "${PAIRS[@]}"; do
  K="${PAIR%%:*}"; SIZE="${PAIR##*:}"
  OUT="$ROOT/$K"
  mkdir -p "$OUT"
  echo "==== [$K] size=$SIZE ====" | tee -a "$ROOT/sweep.log"
  SIZE_FLAG=(); [ "$SIZE" != "none" ] && SIZE_FLAG=(--size "$SIZE")
  ARGO_MODEL="$MODEL" bash "$LAUNCHER" \
    --kernel "$K" --output "$OUT" "${SIZE_FLAG[@]}" \
    --auto-optimize --reviewer-max-attempts "$CAP" \
    --max-optimize-attempts "$CAP" --min-optimize-attempts 4 \
    >>"$OUT/run.log" 2>&1 || true
  if _passed "$OUT" "$K"; then
    CY=$(_metric "$OUT" "$K" cycles_send)
    echo "RESULT $K $SIZE: pass cycles=$CY" | tee -a "$ROOT/VERDICT.txt"
  else
    echo "RESULT $K $SIZE: fail" | tee -a "$ROOT/VERDICT.txt"
  fi
done

echo "SWEEP_DONE" | tee -a "$ROOT/VERDICT.txt"
echo "Root: $ROOT"
