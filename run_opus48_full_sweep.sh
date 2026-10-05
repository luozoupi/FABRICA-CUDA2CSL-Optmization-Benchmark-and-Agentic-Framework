#!/usr/bin/env bash
# Full sweep: Opus 4.8, cap=40, all improvements ON (behavioral contracts,
# dry-check, gotcha retrieval, debugger v2, layer-clearance, best-of-N=3).
# Includes the 2 new v2 inline kernels (Histogram-Inline, GEMV-RowPart).
set -u
LAUNCHER="$HOME/xkernel/run_cuda2csl_argo.sh"
CAP=40
TS=$(date -u +%Y%m%d_%H%M%S)
ROOT="$HOME/xkernel/code_translation/results/opus48_sweep_${TS}"
mkdir -p "$ROOT"
VERDICT="$ROOT/VERDICT.txt"
echo "OPUS-4.8 full sweep $TS  cap=$CAP  translate+optimize" | tee "$VERDICT"

# All improvements ON
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

# name | reference_cycles | split
KERNELS=(
  # --- held-out TEST split ---
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
  # --- Histogram (correctness_only, multi-PE tally lib) ---
  "Histogram|-|test"
  # --- NEW v2 inline kernels (no opaque SDK deps) ---
  "Histogram-Inline|1967|test"
  "GEMV-RowPart|711|test"
  # --- TRAIN split ---
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

  # Cholesky uses co-design mode
  EXTRA_ENV=""
  if [ "$name" = "Cholesky" ]; then
    EXTRA_ENV="XKERNEL_CODESIGN_LAYOUT=1 XKERNEL_FORCE_RESPIN_CAP=4"
  fi

  env $EXTRA_ENV bash "$LAUNCHER" --kernel "$name" --output "$OUT" \
    --auto-optimize --reviewer-max-attempts "$CAP" \
    --max-optimize-attempts "$CAP" --min-optimize-attempts 4 \
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
echo "OPUS48_SWEEP_DONE" | tee -a "$VERDICT"

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
print("\n=== OPUS-4.8 SWEEP SUMMARY ===")
for split in ("test","train"):
    p=agg[(split,"pass")]; f=agg[(split,"fail")]
    print(f"  {split}: {p} pass / {p+f} total")
print(f"  beats-expert (>1x vs ref):")
for n,v in sorted(beats): print(f"    {n}: {v}")
PY
