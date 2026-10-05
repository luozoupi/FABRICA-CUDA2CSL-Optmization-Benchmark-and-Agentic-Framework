#!/usr/bin/env bash
# Full-suite sweep: from-CUDA translate + auto-optimize over EVERY sweepable
# registry kernel (22; MC-Particle-Transport skipped — no run.py verifier).
# One draw per kernel, cap 12. Serial — the SDK container wedges under parallel
# cslc. Integrity guards live (dead-timer floor + frozen-fn splice). This is the
# big-picture scoreboard: per-kernel pass/fail + cycles vs the (runtime-measured)
# expert reference.
#
# Usage: run_full_suite_sweep.sh [--cap N] [--model M]
set -u
MODEL="${ARGO_MODEL:-claude-opus-4-7}"
CAP="${CAP:-12}"
LAUNCHER="$HOME/xkernel/run_cuda2csl_argo.sh"

# (kernel:sizeflag). large where a decomposition/compute-scaled size exists in
# spec.yaml; none otherwise. Order: train-pool first, then test, then others.
PAIRS=(
  # --- gemm/gemv family ---
  "GEMV:large" "GEMM:large" "GEMM-Collectives-2D:none" "GEMV-Checkerboard:none"
  "GEMV-Collectives-2D:none" "Wide-Multiplication:none" "Single-Tile-Matvec:none"
  # --- iterative solvers ---
  "Power-Method:none" "CG:none" "Preconditioned-CG:none" "BiCGSTAB:none"
  # --- stencils / halo ---
  "7pt-Stencil:large" "Laplacian2D-Halo:large" "Laplacian2D-Reduce:none"
  "LorenzoPredictor-Tile:none"
  # --- other compute ---
  "Cholesky:small" "Residual:none" "Game-of-Life:none" "Mandelbrot:none"
  "FFT-1D-2D:none"
  # --- scientific (mrh/gpu) ---
  "Tensor-Transpose-021:none" "PDFT-Pi-Pipeline:none"
)

while [ $# -gt 0 ]; do
  case "$1" in
    --cap) CAP="$2"; shift 2 ;;
    --model) MODEL="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 2 ;;
  esac
done

TS=$(date -u +%Y%m%d_%H%M%S)
ROOT="$HOME/xkernel/code_translation/results/full_suite_sweep_${TS}"
mkdir -p "$ROOT"
echo "Full-suite sweep root: $ROOT  model=$MODEL cap=$CAP  kernels=${#PAIRS[@]}" | tee "$ROOT/config.txt"

_passed() {
  local bj; bj=$(ls -t "$1"/run_*/"$2"/benchmark.json 2>/dev/null | head -1)
  [ -n "$bj" ] && python3 -c "import json,sys;sys.exit(0 if json.load(open('$bj')).get('status')=='pass' else 1)" 2>/dev/null
}
_metric() {
  local bj; bj=$(ls -t "$1"/run_*/"$2"/benchmark.json 2>/dev/null | head -1)
  [ -n "$bj" ] || { echo "-"; return; }
  python3 -c "import json;d=json.load(open('$bj'));print(d.get('$3') or '-')" 2>/dev/null || echo "-"
}

for PAIR in "${PAIRS[@]}"; do
  K="${PAIR%%:*}"; SIZE="${PAIR##*:}"
  OUT="$ROOT/$K"; mkdir -p "$OUT"
  SIZE_FLAG=(); [ "$SIZE" != "none" ] && SIZE_FLAG=(--size "$SIZE")
  echo "==== [$K] size=$SIZE ====" | tee -a "$ROOT/sweep.log"
  XKERNEL_HARD_KERNEL_HINTS=1 XKERNEL_SPLICE_FROZEN=1 XKERNEL_CODESIGN_EXEMPLAR=1 ARGO_MODEL="$MODEL" \
    bash "$LAUNCHER" --kernel "$K" --output "$OUT" "${SIZE_FLAG[@]}" \
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

echo "FULL_SUITE_DONE" | tee -a "$ROOT/VERDICT.txt"
# Summary: pass count
python3 - "$ROOT/VERDICT.txt" <<'PY' | tee -a "$ROOT/VERDICT.txt"
import sys
rows=[l.split() for l in open(sys.argv[1]) if l.startswith("RESULT")]
p=sum(1 for r in rows if r[3]=="pass")
print(f"\n==== FULL-SUITE SUMMARY: {p}/{len(rows)} translation pass ====")
for r in rows:
    print("  "+" ".join(r[1:]))
PY
echo "Root: $ROOT"
