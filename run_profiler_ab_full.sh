#!/usr/bin/env bash
# Full profiler A/B: ALL 28 kernels × N=10 seeds × 2 arms.
# Runs STRICTLY SEQUENTIALLY with container cleanup between runs to avoid
# thread exhaustion (RLIMIT_NPROC=16384 on shared usernode).
set -u
LAUNCHER="$HOME/xkernel/run_cuda2csl_argo.sh"
CAP=20
N_SEEDS=10
TS=$(date -u +%Y%m%d_%H%M%S)
ROOT="$HOME/xkernel/code_translation/results/profiler_ab_full_${TS}"
mkdir -p "$ROOT"
VERDICT="$ROOT/VERDICT.txt"
echo "PROFILER A/B FULL: N=$N_SEEDS seeds, cap=$CAP, all kernels, Opus 4.8  $TS" | tee "$VERDICT"

export XKERNEL_DRY_CHECK=1
export XKERNEL_ERROR_GOTCHA=1
export XKERNEL_HARD_KERNEL_HINTS=1
export XKERNEL_SPLICE_FROZEN=1
export XKERNEL_LIB_BEHAVIORAL=1
export XKERNEL_LAYER_CLEARANCE=1
export XKERNEL_PROFILE_MEMORY=1
export ARGO_MODEL="claude-opus-4-8"

# Limit OpenBLAS/MKL threads to prevent thread explosion inside containers
export OMP_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
export MKL_NUM_THREADS=1

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

_cyc() {
  local bj; bj=$(ls -t "$1"/run_*/*/benchmark.json 2>/dev/null | head -1)
  [ -n "$bj" ] && python3 -c "import json; c=json.load(open('$bj')).get('cycles_send'); print(c if isinstance(c,int) else '-')" 2>/dev/null || echo "-"
}

_cleanup() {
  # Kill orphaned squashfuse/apptainer to prevent thread leak
  pkill -u $(whoami) -f "squashfuse_ll" 2>/dev/null || true
  sleep 1
}

for entry in "${KERNELS[@]}"; do
  IFS='|' read -r name ref split <<< "$entry"
  echo "==== [$split] $name (ref=$ref) ====" | tee -a "$ROOT/sweep.log"

  profiled_cycles=""
  unprofiled_cycles=""

  EXTRA_ENV=""
  if [ "$name" = "Cholesky" ]; then
    EXTRA_ENV="XKERNEL_CODESIGN_LAYOUT=1 XKERNEL_FORCE_RESPIN_CAP=4"
  fi

  for seed in $(seq 1 $N_SEEDS); do
    # ARM A: profiled
    OUT_P="$ROOT/${name}/profiled/seed_${seed}"; mkdir -p "$OUT_P"
    echo "  [$name] seed=$seed profiled $(date +%H:%M)" | tee -a "$ROOT/sweep.log"
    env $EXTRA_ENV bash "$LAUNCHER" --kernel "$name" --output "$OUT_P" \
      --auto-optimize --profile-feedback \
      --reviewer-max-attempts "$CAP" \
      --max-optimize-attempts "$CAP" --min-optimize-attempts 4 \
      >>"$OUT_P/run.log" 2>&1 || true
    cyc_p=$(_cyc "$OUT_P")
    profiled_cycles="${profiled_cycles}${cyc_p},"
    _cleanup

    # ARM B: unprofiled
    OUT_U="$ROOT/${name}/unprofiled/seed_${seed}"; mkdir -p "$OUT_U"
    echo "  [$name] seed=$seed unprofiled $(date +%H:%M)" | tee -a "$ROOT/sweep.log"
    env $EXTRA_ENV bash "$LAUNCHER" --kernel "$name" --output "$OUT_U" \
      --auto-optimize \
      --reviewer-max-attempts "$CAP" \
      --max-optimize-attempts "$CAP" --min-optimize-attempts 4 \
      >>"$OUT_U/run.log" 2>&1 || true
    cyc_u=$(_cyc "$OUT_U")
    unprofiled_cycles="${unprofiled_cycles}${cyc_u},"
    _cleanup
  done

  echo "RESULT [$split] $name: profiled=[$profiled_cycles] unprofiled=[$unprofiled_cycles] ref=$ref" | tee -a "$VERDICT"
done

echo "PROFILER_AB_FULL_DONE" | tee -a "$VERDICT"

python3 - "$VERDICT" <<'PY' | tee -a "$VERDICT"
import sys, re, statistics

print("\n=== PROFILER A/B FULL ANALYSIS (N=10) ===\n")
lines = [l for l in open(sys.argv[1]) if l.startswith("RESULT")]
better=0; worse=0; same=0; nodata=0

for line in lines:
    m = re.match(r"RESULT \[\w+\] (\S+): profiled=\[([^\]]*)\] unprofiled=\[([^\]]*)\] ref=(\S+)", line)
    if not m: continue
    name, p_str, u_str, ref_str = m.group(1), m.group(2), m.group(3), m.group(4)
    ref = int(ref_str) if ref_str.isdigit() else None
    p_vals = [int(x) for x in p_str.strip(",").split(",") if x.strip() not in ("-","")]
    u_vals = [int(x) for x in u_str.strip(",").split(",") if x.strip() not in ("-","")]
    if len(p_vals) < 2 or len(u_vals) < 2:
        nodata += 1
        print(f"  {name:25s}  pass: profiled={len(p_vals)}/10 unprofiled={len(u_vals)}/10")
        continue
    p_med = statistics.median(p_vals); u_med = statistics.median(u_vals)
    delta = p_med - u_med
    pct = round(100*delta/u_med,1) if u_med>0 else 0
    tag = "~SAME" if abs(pct)<3 else ("BETTER" if pct<0 else "WORSE")
    if abs(pct)<3: same+=1
    elif pct<0: better+=1
    else: worse+=1
    ref_p = f"{ref/p_med:.2f}x" if ref and p_med>0 else "-"
    ref_u = f"{ref/u_med:.2f}x" if ref and u_med>0 else "-"
    print(f"  {name:25s}  prof={p_med:>8.0f} ({len(p_vals)}/10)  unprof={u_med:>8.0f} ({len(u_vals)}/10)  Δ={pct:>+.1f}% {tag}")
print(f"\n  Better:{better} Worse:{worse} Same:{same} NoData:{nodata}")
PY
