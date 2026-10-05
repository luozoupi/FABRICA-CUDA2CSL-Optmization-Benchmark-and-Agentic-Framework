#!/usr/bin/env bash
# A/B sweep on 14 NEW enrichment kernels: N=5 seeds × 2 arms (profiled/unprofiled).
# Runs sequentially with cleanup to avoid thread exhaustion.
set -u
LAUNCHER="$HOME/xkernel/run_cuda2csl_argo.sh"
CAP=20
N_SEEDS=5
TS=$(date -u +%Y%m%d_%H%M%S)
ROOT="$HOME/xkernel/code_translation/results/new_kernels_ab_${TS}"
mkdir -p "$ROOT"
VERDICT="$ROOT/VERDICT.txt"
echo "NEW KERNELS A/B: N=$N_SEEDS seeds, cap=$CAP, Opus 4.8  $TS" | tee "$VERDICT"

export XKERNEL_DRY_CHECK=1
export XKERNEL_ERROR_GOTCHA=1
export XKERNEL_HARD_KERNEL_HINTS=1
export XKERNEL_SPLICE_FROZEN=1
export XKERNEL_LIB_BEHAVIORAL=1
export XKERNEL_LAYER_CLEARANCE=1
export XKERNEL_PROFILE_MEMORY=1
export ARGO_MODEL="claude-opus-4-8"

export OMP_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
export MKL_NUM_THREADS=1

# 14 new enrichment kernels with reference cycles from simulator
KERNELS=(
  "ReLU-1PE|11787|test"
  "Sum-Reduction-1PE|7693|test"
  "Sigmoid-1PE|107546|test"
  "Max-Reduction-1PE|8188|test"
  "RMSNorm-1PE|10947|test"
  "GELU-1PE|111134|test"
  "MSE-Loss-1PE|11282|test"
  "SAXPY-1PE|11276|test"
  "Dot-Product-1PE|10254|test"
  "Softmax-1PE|35681|test"
  "Prefix-Sum-1PE|9229|test"
  "SiLU-1PE|104473|test"
  "L2-Norm-1PE|18112|test"
  "Cross-Entropy-Loss-1PE|29283|test"
)

_cyc() {
  local bj; bj=$(ls -t "$1"/run_*/*/benchmark.json 2>/dev/null | head -1)
  [ -n "$bj" ] && python3 -c "import json; c=json.load(open('$bj')).get('cycles_send'); print(c if isinstance(c,int) else '-')" 2>/dev/null || echo "-"
}

_cleanup() {
  pkill -u $(whoami) -f "squashfuse_ll" 2>/dev/null || true
  sleep 1
}

for entry in "${KERNELS[@]}"; do
  IFS='|' read -r name ref split <<< "$entry"
  echo "==== [$split] $name (ref=$ref) ====" | tee -a "$ROOT/sweep.log"

  profiled_cycles=""
  unprofiled_cycles=""

  for seed in $(seq 1 $N_SEEDS); do
    # ARM A: profiled
    OUT_P="$ROOT/${name}/profiled/seed_${seed}"; mkdir -p "$OUT_P"
    echo "  [$name] seed=$seed profiled $(date +%H:%M)" | tee -a "$ROOT/sweep.log"
    bash "$LAUNCHER" --kernel "$name" --output "$OUT_P" \
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
    bash "$LAUNCHER" --kernel "$name" --output "$OUT_U" \
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

echo "NEW_KERNELS_AB_DONE" | tee -a "$VERDICT"

python3 - "$VERDICT" <<'PY' | tee -a "$VERDICT"
import sys, re, statistics

print("\n=== NEW KERNELS A/B ANALYSIS (N=5) ===\n")
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
        print(f"  {name:30s}  pass: profiled={len(p_vals)}/5 unprofiled={len(u_vals)}/5")
        continue
    p_med = statistics.median(p_vals); u_med = statistics.median(u_vals)
    delta = p_med - u_med
    pct = round(100*delta/u_med,1) if u_med>0 else 0
    tag = "~SAME" if abs(pct)<3 else ("BETTER" if pct<0 else "WORSE")
    if abs(pct)<3: same+=1
    elif pct<0: better+=1
    else: worse+=1
    beat_ref = ""
    if ref:
        p_vs = f"{ref/p_med:.1f}x" if p_med > 0 else "-"
        u_vs = f"{ref/u_med:.1f}x" if u_med > 0 else "-"
        beat_ref = f"  vs_ref: prof={p_vs} unprof={u_vs}"
    print(f"  {name:30s}  prof={p_med:>8.0f} ({len(p_vals)}/5)  unprof={u_med:>8.0f} ({len(u_vals)}/5)  Δ={pct:>+.1f}% {tag}{beat_ref}")
print(f"\n  Better:{better} Worse:{worse} Same:{same} NoData:{nodata}")
PY
