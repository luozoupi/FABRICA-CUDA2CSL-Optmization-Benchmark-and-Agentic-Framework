#!/usr/bin/env bash
# Full AGENT benchmark sweep: run the firewalled CUDA->CSL translate+optimize agent on
# every scoreable kernel (cap 20) and score the result against the reference baseline.
# Serial SDK -> long (~8-10h). Results + scoreboard -> results/agent_full_sweep_<ts>/.
#
# This is the real experiment: does the agent (W1 translate, hidden reference compute)
# + W2 optimize produce a passing kernel, and how do its cycles compare to the human
# reference? Train-split kernels (GEMM/GEMV/collectives/solvers) are run for the dev
# snapshot but do NOT count toward the held-out beats-expert claim (see
# docs/SPLIT_AND_LEAKAGE.md).
set -u
LAUNCHER="$HOME/xkernel/run_cuda2csl_argo.sh"
CAP="${CAP:-20}"
TS=$(date -u +%Y%m%d_%H%M%S)
ROOT="$HOME/xkernel/code_translation/results/agent_full_sweep_${TS}"
mkdir -p "$ROOT"
VERDICT="$ROOT/VERDICT.txt"
echo "AGENT full sweep $TS  cap=$CAP  translate+optimize" | tee "$VERDICT"

# name | reference_cycles | split   (ref baselines from scoreable_sweep_20260624)
KERNELS=(
  # --- held-out TEST split (the beats-expert claim) ---
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
  # --- TRAIN split (dev snapshot only; not the claim) ---
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
  XKERNEL_HARD_KERNEL_HINTS=1 XKERNEL_SPLICE_FROZEN=1 \
    bash "$LAUNCHER" --kernel "$name" --output "$OUT" \
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
echo "AGENT_FULL_SWEEP_DONE" | tee -a "$VERDICT"

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
print("\n=== AGENT FULL SWEEP SUMMARY ===")
for split in ("test","train"):
    p=agg[(split,"pass")]; f=agg[(split,"fail")]
    print(f"  {split}: {p} pass / {p+f} total")
print(f"  beats-expert (>1x vs ref):")
for n,v in sorted(beats): print(f"    {n}: {v}")
PY
