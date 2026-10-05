#!/usr/bin/env bash
# Multi-seed profiler A/B: N=5 seeds × 6 robust kernels × 2 arms (profiled/unprofiled).
# Measures whether the architectural profiler (sim.log parsing + bottleneck classification)
# improves W2 optimization outcomes, controlling for single-draw variance.
#
# Comparison: median final cycles per kernel, profiled vs unprofiled.
set -u
LAUNCHER="$HOME/xkernel/run_cuda2csl_argo.sh"
CAP=20
N_SEEDS=5
TS=$(date -u +%Y%m%d_%H%M%S)
ROOT="$HOME/xkernel/code_translation/results/profiler_ab_${TS}"
mkdir -p "$ROOT"
VERDICT="$ROOT/VERDICT.txt"
echo "PROFILER A/B: N=$N_SEEDS seeds, cap=$CAP, Opus 4.8  $TS" | tee "$VERDICT"

# Common improvements
export XKERNEL_DRY_CHECK=1
export XKERNEL_ERROR_GOTCHA=1
export XKERNEL_HARD_KERNEL_HINTS=1
export XKERNEL_SPLICE_FROZEN=1
export XKERNEL_LIB_BEHAVIORAL=1
export XKERNEL_LAYER_CLEARANCE=1
export XKERNEL_PROFILE_MEMORY=1
export ARGO_MODEL="claude-opus-4-8"

# Only robust (3/3) kernels — these reliably pass W1 and enter W2
KERNELS=(
  "7pt-Stencil|2129"
  "DFT-1PE|145233"
  "Histogram-1PE|6191"
  "Jacobi-2D-5pt|1566"
  "Laplacian2D-Halo|1709"
  "Game-of-Life|7838"
)

_cyc() {
  local bj; bj=$(ls -t "$1"/run_*/*/benchmark.json 2>/dev/null | head -1)
  [ -n "$bj" ] && python3 -c "import json; c=json.load(open('$bj')).get('cycles_send'); print(c if isinstance(c,int) else '-')" 2>/dev/null || echo "-"
}

for entry in "${KERNELS[@]}"; do
  IFS='|' read -r name ref <<< "$entry"
  echo "==== $name (ref=$ref) ====" | tee -a "$ROOT/sweep.log"

  profiled_cycles=""
  unprofiled_cycles=""

  for seed in $(seq 1 $N_SEEDS); do
    # ARM A: with profiling
    OUT_P="$ROOT/${name}/profiled/seed_${seed}"; mkdir -p "$OUT_P"
    echo "  [$name] seed=$seed ARM=profiled" | tee -a "$ROOT/sweep.log"
    bash "$LAUNCHER" --kernel "$name" --output "$OUT_P" \
      --auto-optimize --profile-feedback \
      --reviewer-max-attempts "$CAP" \
      --max-optimize-attempts "$CAP" --min-optimize-attempts 4 \
      >>"$OUT_P/run.log" 2>&1 || true
    cyc_p=$(_cyc "$OUT_P")
    profiled_cycles="${profiled_cycles}${cyc_p},"

    # ARM B: without profiling
    OUT_U="$ROOT/${name}/unprofiled/seed_${seed}"; mkdir -p "$OUT_U"
    echo "  [$name] seed=$seed ARM=unprofiled" | tee -a "$ROOT/sweep.log"
    bash "$LAUNCHER" --kernel "$name" --output "$OUT_U" \
      --auto-optimize \
      --reviewer-max-attempts "$CAP" \
      --max-optimize-attempts "$CAP" --min-optimize-attempts 4 \
      >>"$OUT_U/run.log" 2>&1 || true
    cyc_u=$(_cyc "$OUT_U")
    unprofiled_cycles="${unprofiled_cycles}${cyc_u},"
  done

  echo "RESULT $name: profiled=[$profiled_cycles] unprofiled=[$unprofiled_cycles] ref=$ref" | tee -a "$VERDICT"
done

echo "PROFILER_AB_DONE" | tee -a "$VERDICT"

# Statistical analysis
python3 - "$VERDICT" <<'PY' | tee -a "$VERDICT"
import sys, re, statistics

print("\n=== PROFILER A/B ANALYSIS ===\n")
lines = [l for l in open(sys.argv[1]) if l.startswith("RESULT")]

for line in lines:
    m = re.match(r"RESULT (\S+): profiled=\[([^\]]*)\] unprofiled=\[([^\]]*)\] ref=(\d+)", line)
    if not m: continue
    name, p_str, u_str, ref = m.group(1), m.group(2), m.group(3), int(m.group(4))

    p_vals = [int(x) for x in p_str.strip(",").split(",") if x.strip() not in ("-","")]
    u_vals = [int(x) for x in u_str.strip(",").split(",") if x.strip() not in ("-","")]

    if not p_vals or not u_vals:
        print(f"  {name}: insufficient data (profiled={len(p_vals)}, unprofiled={len(u_vals)})")
        continue

    p_med = statistics.median(p_vals)
    u_med = statistics.median(u_vals)
    delta = p_med - u_med
    pct = round(100 * delta / u_med, 1) if u_med > 0 else 0
    tag = "BETTER" if delta < 0 else ("WORSE" if delta > 0 else "SAME")

    print(f"  {name:25s}")
    print(f"    profiled:   median={p_med:>8.0f}  values={p_vals}")
    print(f"    unprofiled: median={u_med:>8.0f}  values={u_vals}")
    print(f"    delta: {delta:>+8.0f} ({pct:>+6.1f}%) {tag}")
    print(f"    vs ref ({ref}): profiled {ref/p_med:.2f}x, unprofiled {ref/u_med:.2f}x")
    print()
PY
