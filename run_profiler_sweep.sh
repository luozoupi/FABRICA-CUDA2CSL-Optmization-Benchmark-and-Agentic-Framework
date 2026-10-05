#!/usr/bin/env bash
# Profiler A/B sweep: full 28-kernel sweep WITH architectural profiling enabled.
# Compare against the existing Opus 4.8 sweep (no profiling) to measure
# whether sim.log bottleneck classification + cs_readelf memory analysis
# improves W2 optimization outcomes.
set -u
LAUNCHER="$HOME/xkernel/run_cuda2csl_argo.sh"
CAP=40
TS=$(date -u +%Y%m%d_%H%M%S)
ROOT="$HOME/xkernel/code_translation/results/profiler_sweep_${TS}"
mkdir -p "$ROOT"
VERDICT="$ROOT/VERDICT.txt"
echo "PROFILER SWEEP: cap=$CAP, profile-feedback=ON, Opus 4.8  $TS" | tee "$VERDICT"

# All improvements ON + profiling
export XKERNEL_DRY_CHECK=1
export XKERNEL_ERROR_GOTCHA=1
export XKERNEL_HARD_KERNEL_HINTS=1
export XKERNEL_SPLICE_FROZEN=1
export XKERNEL_BEST_OF_N=3
export XKERNEL_DEBUGGER=1
export XKERNEL_DEBUGGER_V2=1
export XKERNEL_LIB_BEHAVIORAL=1
export XKERNEL_LAYER_CLEARANCE=1
export XKERNEL_PROFILE_MEMORY=1
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

  EXTRA_ENV=""
  if [ "$name" = "Cholesky" ]; then
    EXTRA_ENV="XKERNEL_CODESIGN_LAYOUT=1 XKERNEL_FORCE_RESPIN_CAP=4"
  fi

  env $EXTRA_ENV bash "$LAUNCHER" --kernel "$name" --output "$OUT" \
    --auto-optimize --profile-feedback \
    --reviewer-max-attempts "$CAP" \
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
echo "PROFILER_SWEEP_DONE" | tee -a "$VERDICT"

# Summary + comparison with baseline
python3 - "$VERDICT" <<'PY' | tee -a "$VERDICT"
import sys, collections
rows=[l.split() for l in open(sys.argv[1]) if l.startswith("RESULT")]
agg=collections.Counter(); beats=[]; cycles={}
for r in rows:
    split=r[1].strip("[]"); name=r[2].rstrip(":"); ok="PASS" in r
    agg[(split,"pass" if ok else "fail")]+=1
    if ok and "vs_ref=" in " ".join(r):
        vr=[x for x in r if x.startswith("vs_ref=")]
        ag=[x for x in r if x.startswith("agent=")]
        if vr:
            v=vr[0].split("=")[1]
            try:
                if v.endswith("x") and float(v[:-1])>1.0:
                    beats.append((name, v))
            except: pass
        if ag:
            try: cycles[name]=int(ag[0].split("=")[1])
            except: pass
print("\n=== PROFILER SWEEP SUMMARY ===")
for split in ("test","train"):
    p=agg[(split,"pass")]; f=agg[(split,"fail")]
    if p+f>0: print(f"  {split}: {p} pass / {p+f} total")
if beats:
    print(f"  beats-expert ({len(beats)}):")
    for n,v in sorted(beats): print(f"    {n}: {v}")

# Compare with Opus 4.8 baseline (no profiling)
baseline = {
    "DFT-1PE": 12967, "Game-of-Life": 3358, "Histogram-1PE": 5644,
    "Jacobi-2D-5pt": 738, "Laplacian2D-Halo": 653, "Mandelbrot": 5155,
    "PDFT-Pi-Pipeline": 17662, "Residual": 474, "Stencil7pt-1PE": 5494,
    "Tensor-Transpose-021": 528, "Wide-Multiplication": 6638,
    "GEMV-RowPart": 144, "GEMM": 47633, "GEMM-Collectives-2D": 47180,
    "BiCGSTAB": 32105, "CG": 10787, "Preconditioned-CG": 23650,
    "FFT-1D-2D": 454,
}
print("\n=== PROFILER vs BASELINE CYCLE COMPARISON ===")
better=0; worse=0; same=0
for name, prof_cyc in sorted(cycles.items()):
    base = baseline.get(name)
    if base and prof_cyc:
        delta = prof_cyc - base
        pct = round(100*delta/base, 1)
        tag = "BETTER" if delta < 0 else ("WORSE" if delta > 0 else "SAME")
        if delta < 0: better += 1
        elif delta > 0: worse += 1
        else: same += 1
        print(f"  {name:25s}  profiled={prof_cyc:>8d}  baseline={base:>8d}  Δ={delta:>+8d} ({pct:>+6.1f}%) {tag}")
print(f"\n  Better: {better}, Worse: {worse}, Same: {same}")
PY
