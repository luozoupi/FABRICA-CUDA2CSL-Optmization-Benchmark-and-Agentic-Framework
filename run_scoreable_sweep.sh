#!/usr/bin/env bash
# Reference-baseline sweep over all scoreable kernels. For each, stage the reference
# bundle to a space-free /tmp dir, run its commands_wse3.sh on the WSE-3 simulator, and
# record SUCCESS + cycles_send. This validates that every "scoreable" kernel actually
# compiles + runs + emits its metric on the reference (the agent-translation baseline).
# Serial SDK. Results -> results/scoreable_sweep_<ts>/.
set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${XKERNEL_ROOT:-$SCRIPT_DIR}/xkernel_env.sh"
export PATH=$XKERNEL_SDK_ROOT:$PATH
TS=$(date -u +%Y%m%d_%H%M%S)
ROOT="$HOME/xkernel/code_translation/results/scoreable_sweep_${TS}"
mkdir -p "$ROOT"
VERDICT="$ROOT/VERDICT.txt"
echo "scoreable reference-baseline sweep $TS" | tee "$VERDICT"

# name|dir (dir is the kernels/<dir>/CSL path component)
KERNELS=(
  "7pt-Stencil|7-Point Stencil"
  "BiCGSTAB|BiCGSTAB"
  "CG|Conjugate Gradient"
  "Cholesky|Cholesky"
  "DFT-1PE|DFT-1PE"
  "FFT-1D-2D|FFT 1D-2D"
  "GEMM|GEMM"
  "GEMM-Collectives-2D|GEMM Collectives 2D"
  "GEMV|GEMV"
  "GEMV-Checkerboard|GEMV Checkerboard"
  "GEMV-Collectives-2D|GEMV Collectives 2D"
  "Game-of-Life|Game of Life"
  "Histogram|Histogram"
  "Histogram-1PE|Histogram-1PE"
  "Jacobi-2D-5pt|Jacobi-2D-5pt"
  "Laplacian2D-Halo|Laplacian2D-Halo"
  "Mandelbrot|Mandelbrot"
  "PDFT-Pi-Pipeline|PDFT-Pi-Pipeline"
  "Power-Method|Power Method"
  "Preconditioned-CG|Preconditioned CG"
  "Residual|Residual"
  "Single-Tile-Matvec|Single Tile Matvec"
  "SpMV-CSR|SpMV-CSR"
  "Stencil7pt-1PE|Stencil7pt-1PE"
  "Tensor-Transpose-021|Tensor-Transpose-021"
  "Wide-Multiplication|Wide Multiplication"
)

for entry in "${KERNELS[@]}"; do
  name="${entry%%|*}"; dir="${entry##*|}"
  src="$HOME/xkernel/kernels/$dir/CSL"
  stage="/tmp/sweep_${name//[^A-Za-z0-9_]/_}"
  rm -rf "$stage"; mkdir -p "$stage"
  cp -r "$src/." "$stage/" 2>/dev/null
  # stage benchmark-libs if the bundle imports them (solvers/7pt)
  if grep -rqE "benchmark-libs" "$stage"/*.csl "$stage"/src/*.csl 2>/dev/null; then
    cp -r "$HOME/xkernel/kernels/benchmark-libs" "$(dirname "$stage")/benchmark-libs" 2>/dev/null || true
  fi
  echo "==== $name ====" | tee -a "$ROOT/sweep.log"
  ( cd "$stage" && timeout 360 bash commands_wse3.sh ) >"$ROOT/${name}.log" 2>&1
  rc=$?
  ok=$(grep -ac "SUCCESS" "$ROOT/${name}.log")
  cyc=$(grep -aoE "cycles_send = [0-9]+" "$ROOT/${name}.log" | head -1 | grep -oE "[0-9]+")
  cyc="${cyc:--}"
  if [ "$ok" -ge 1 ]; then
    echo "RESULT $name: PASS cycles=$cyc" | tee -a "$VERDICT"
  else
    reason=$(grep -aoE "kernel stall|not match|AssertionError|command not found|No such file|error:" "$ROOT/${name}.log" | head -1)
    echo "RESULT $name: FAIL (rc=$rc; ${reason:-see log})" | tee -a "$VERDICT"
  fi
  pkill -f "$stage" 2>/dev/null
done
echo "SCOREABLE_SWEEP_DONE" | tee -a "$VERDICT"

python3 - "$VERDICT" <<'PY' | tee -a "$VERDICT"
import sys
rows=[l for l in open(sys.argv[1]) if l.startswith("RESULT")]
p=sum(1 for l in rows if "PASS" in l); t=len(rows)
print(f"\n=== scoreable reference sweep: {p}/{t} PASS ===")
PY
