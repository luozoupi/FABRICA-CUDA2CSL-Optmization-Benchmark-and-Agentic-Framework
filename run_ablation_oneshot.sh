#!/usr/bin/env bash
# Experiment #1: One-shot ablation — cap=1, no knowledge, no repair loop.
# Isolates the raw model's CUDA→CSL translation ability without any system help.
# Paired with the full-stack sweep (cap=40, all improvements) to measure the
# system's contribution.
#
# Run on Opus 4.8 for direct comparison with the full-stack sweep.
set -u
LAUNCHER="$HOME/xkernel/run_cuda2csl_argo.sh"
TS=$(date -u +%Y%m%d_%H%M%S)
ROOT="$HOME/xkernel/code_translation/results/ablation_oneshot_${TS}"
mkdir -p "$ROOT"
VERDICT="$ROOT/VERDICT.txt"
echo "ONE-SHOT ABLATION: cap=1, no-knowledge, Opus 4.8  $TS" | tee "$VERDICT"

# Disable ALL improvements
unset XKERNEL_DRY_CHECK
unset XKERNEL_ERROR_GOTCHA
unset XKERNEL_HARD_KERNEL_HINTS
unset XKERNEL_SPLICE_FROZEN
unset XKERNEL_BEST_OF_N
unset XKERNEL_DEBUGGER
unset XKERNEL_DEBUGGER_V2
unset XKERNEL_LIB_BEHAVIORAL
unset XKERNEL_LAYER_CLEARANCE
export XKERNEL_DRY_CHECK=0
export XKERNEL_ERROR_GOTCHA=0
export XKERNEL_LIB_BEHAVIORAL=0
export XKERNEL_LAYER_CLEARANCE=0
export ARGO_MODEL="claude-opus-4-8"

KERNELS=(
  "7pt-Stencil|2129|test"
  "Cholesky|12476|test"
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
  "Histogram|-|test"
  "Histogram-Inline|1967|test"
  "GEMV-RowPart|711|test"
  "GEMM|51753|train"
  "GEMV|4007|train"
  "GEMM-Collectives-2D|51738|train"
  "GEMV-Collectives-2D|4003|train"
  "BiCGSTAB|59385|train"
  "CG|11635|train"
  "Power-Method|43436|train"
  "Preconditioned-CG|13826|train"
)

_passed() { local bj; bj=$(ls -t "$1"/run_*/*/benchmark.json 2>/dev/null | head -1); [ -n "$bj" ] && python3 -c "import json,sys;sys.exit(0 if json.load(open('$bj')).get('status')=='pass' else 1)" 2>/dev/null; }
_cyc() { local bj; bj=$(ls -t "$1"/run_*/*/benchmark.json 2>/dev/null | head -1); [ -n "$bj" ] && python3 -c "import json;print(json.load(open('$bj')).get('cycles_send') or '-')" 2>/dev/null || echo "-"; }

for entry in "${KERNELS[@]}"; do
  IFS='|' read -r name ref split <<< "$entry"
  OUT="$ROOT/$name"; mkdir -p "$OUT"
  echo "==== [$split] $name (ref=$ref) ====" | tee -a "$ROOT/sweep.log"

  bash "$LAUNCHER" --kernel "$name" --output "$OUT" \
    --no-knowledge \
    --reviewer-max-attempts 1 \
    --skip-reviewer \
    --turns 1 \
    >>"$OUT/run.log" 2>&1 || true

  if _passed "$OUT"; then
    cyc=$(_cyc "$OUT")
    speedup="-"
    if [ "$ref" != "-" ] && [ "$cyc" != "-" ]; then
      speedup=$(python3 -c "print(f'{$ref/$cyc:.2f}x')" 2>/dev/null || echo "-")
    fi
    echo "RESULT [$split] $name: PASS agent=$cyc ref=$ref vs_ref=$speedup" | tee -a "$VERDICT"
  else
    echo "RESULT [$split] $name: FAIL ref=$ref" | tee -a "$VERDICT"
  fi
done
echo "ABLATION_ONESHOT_DONE" | tee -a "$VERDICT"

python3 - "$VERDICT" <<'PY' | tee -a "$VERDICT"
import sys, collections
rows=[l.split() for l in open(sys.argv[1]) if l.startswith("RESULT")]
agg=collections.Counter(); beats=[]
for r in rows:
    split=r[1].strip("[]"); ok="PASS" in r
    agg[(split,"pass" if ok else "fail")]+=1
    if ok and "vs_ref=" in " ".join(r):
        vr=[x for x in r if x.startswith("vs_ref=")]
        if vr:
            v=vr[0].split("=")[1]
            try:
                if v.endswith("x") and float(v[:-1])>1.0:
                    beats.append((r[2].rstrip(":"), v))
            except: pass
print("\n=== ONE-SHOT ABLATION SUMMARY ===")
for split in ("test","train"):
    p=agg[(split,"pass")]; f=agg[(split,"fail")]
    if p+f>0: print(f"  {split}: {p} pass / {p+f} total")
if beats:
    print(f"  beats-expert:")
    for n,v in sorted(beats): print(f"    {n}: {v}")
PY
