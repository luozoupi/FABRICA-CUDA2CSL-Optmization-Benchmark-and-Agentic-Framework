#!/usr/bin/env bash
# A/B sweep on 4 NEW multi-PE enrichment kernels: N=5 seeds × 2 arms.
set -u
LAUNCHER="$HOME/xkernel/run_cuda2csl_argo.sh"
CAP=20
N_SEEDS=5
TS=$(date -u +%Y%m%d_%H%M%S)
ROOT="$HOME/xkernel/code_translation/results/multi_pe_ab_${TS}"
mkdir -p "$ROOT"
VERDICT="$ROOT/VERDICT.txt"
echo "MULTI-PE A/B: N=$N_SEEDS seeds, cap=$CAP, Opus 4.8  $TS" | tee "$VERDICT"

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

KERNELS=(
  "ParReduce-Sum|1990|test"
  "ParBroadcast-Scale|2322|test"
  "ParDot-Product|2631|test"
  "RowParallel-Softmax|17714|test"
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

echo "MULTI_PE_AB_DONE" | tee -a "$VERDICT"

python3 - "$VERDICT" <<'PY' | tee -a "$VERDICT"
import sys, re, statistics

print("\n=== MULTI-PE A/B ANALYSIS (N=5) ===\n")
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
    pct = round(100*(p_med-u_med)/u_med,1) if u_med>0 else 0
    tag = "~SAME" if abs(pct)<3 else ("BETTER" if pct<0 else "WORSE")
    if abs(pct)<3: same+=1
    elif pct<0: better+=1
    else: worse+=1
    beat_ref = ""
    if ref:
        beat_ref = f"  vs_ref: prof={ref/p_med:.1f}x unprof={ref/u_med:.1f}x"
    print(f"  {name:30s}  prof={p_med:>8.0f} ({len(p_vals)}/5)  unprof={u_med:>8.0f} ({len(u_vals)}/5)  Δ={pct:>+.1f}% {tag}{beat_ref}")
print(f"\n  Better:{better} Worse:{worse} Same:{same} NoData:{nodata}")
PY
