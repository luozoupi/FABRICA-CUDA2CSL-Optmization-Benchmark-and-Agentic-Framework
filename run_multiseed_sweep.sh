#!/usr/bin/env bash
# Experiment #3: Multi-seed sweep — N=3 draws per kernel for confidence intervals.
# Runs 3 independent translate+optimize attempts on each kernel with Opus 4.8.
# Results: per-kernel pass rate (0/3, 1/3, 2/3, 3/3) for robust/fragile classification.
set -u
LAUNCHER="$HOME/xkernel/run_cuda2csl_argo.sh"
CAP=40
SEEDS=(1 2 3)
TS=$(date -u +%Y%m%d_%H%M%S)
ROOT="$HOME/xkernel/code_translation/results/multiseed_${TS}"
mkdir -p "$ROOT"
VERDICT="$ROOT/VERDICT.txt"
echo "MULTI-SEED SWEEP: N=3, cap=$CAP, Opus 4.8  $TS" | tee "$VERDICT"

export XKERNEL_DRY_CHECK=1
export XKERNEL_ERROR_GOTCHA=1
export XKERNEL_HARD_KERNEL_HINTS=1
export XKERNEL_SPLICE_FROZEN=1
export XKERNEL_BEST_OF_N=3
export XKERNEL_DEBUGGER=1
export XKERNEL_DEBUGGER_V2=1
export XKERNEL_LIB_BEHAVIORAL=1
export XKERNEL_LAYER_CLEARANCE=1
export ARGO_MODEL="claude-opus-4-8"

# Focus on test-split kernels for publishable pass-rate CIs
KERNELS=(
  "7pt-Stencil|2129|test"
  "DFT-1PE|145233|test"
  "FFT-1D-2D|422|test"
  "GEMV-Checkerboard|197|test"
  "Game-of-Life|7838|test"
  "Histogram-1PE|6191|test"
  "Jacobi-2D-5pt|1566|test"
  "Laplacian2D-Halo|1709|test"
  "Mandelbrot|41023|test"
  "PDFT-Pi-Pipeline|128308|test"
  "Residual|674|test"
  "Single-Tile-Matvec|780|test"
  "SpMV-CSR|6927|test"
  "Stencil7pt-1PE|40497|test"
  "Tensor-Transpose-021|6183|test"
  "Wide-Multiplication|81741|test"
  "Histogram-Inline|1967|test"
  "GEMV-RowPart|711|test"
)

_passed() { local bj; bj=$(ls -t "$1"/run_*/*/benchmark.json 2>/dev/null | head -1); [ -n "$bj" ] && python3 -c "import json,sys;sys.exit(0 if json.load(open('$bj')).get('status')=='pass' else 1)" 2>/dev/null; }
_cyc() { local bj; bj=$(ls -t "$1"/run_*/*/benchmark.json 2>/dev/null | head -1); [ -n "$bj" ] && python3 -c "import json;print(json.load(open('$bj')).get('cycles_send') or '-')" 2>/dev/null || echo "-"; }

for entry in "${KERNELS[@]}"; do
  IFS='|' read -r name ref split <<< "$entry"
  pass_count=0
  cycles_list=""

  for seed in "${SEEDS[@]}"; do
    OUT="$ROOT/${name}/seed_${seed}"; mkdir -p "$OUT"
    echo "  [$split] $name seed=$seed (ref=$ref)" | tee -a "$ROOT/sweep.log"

    EXTRA_ENV=""
    if [ "$name" = "Cholesky" ]; then
      EXTRA_ENV="XKERNEL_CODESIGN_LAYOUT=1 XKERNEL_FORCE_RESPIN_CAP=4"
    fi

    env $EXTRA_ENV bash "$LAUNCHER" --kernel "$name" --output "$OUT" \
      --auto-optimize --reviewer-max-attempts "$CAP" \
      --max-optimize-attempts "$CAP" --min-optimize-attempts 4 \
      >>"$OUT/run.log" 2>&1 || true

    if _passed "$OUT"; then
      pass_count=$((pass_count + 1))
      cyc=$(_cyc "$OUT")
      cycles_list="${cycles_list}${cyc},"
    fi
  done

  rate="${pass_count}/${#SEEDS[@]}"
  if [ $pass_count -gt 0 ]; then
    echo "RESULT [$split] $name: $rate pass  cycles=[$cycles_list] ref=$ref" | tee -a "$VERDICT"
  else
    echo "RESULT [$split] $name: $rate pass  ref=$ref" | tee -a "$VERDICT"
  fi
done
echo "MULTISEED_DONE" | tee -a "$VERDICT"

# Summary
python3 - "$VERDICT" <<'PY' | tee -a "$VERDICT"
import sys, re
rows=[l for l in open(sys.argv[1]) if l.startswith("RESULT")]
robust, fragile, fail = [], [], []
for r in rows:
    m = re.search(r'(\S+): (\d)/(\d) pass', r)
    if not m: continue
    name, p, n = m.group(1).rstrip(":"), int(m.group(2)), int(m.group(3))
    if p == n: robust.append(name)
    elif p > 0: fragile.append(f"{name} ({p}/{n})")
    else: fail.append(name)
print(f"\n=== MULTI-SEED SUMMARY (N={n if rows else '?'}) ===")
print(f"  Robust ({len(robust)}): {', '.join(robust)}")
print(f"  Fragile ({len(fragile)}): {', '.join(fragile)}")
print(f"  Fail ({len(fail)}): {', '.join(fail)}")
PY
