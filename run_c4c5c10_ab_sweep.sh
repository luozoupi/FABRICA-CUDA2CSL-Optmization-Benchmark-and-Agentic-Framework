#!/usr/bin/env bash
# Attributable A/B sweep for the C4/C5/C10 firewall-safe translation fixes.
# Two arms over the kernels these fixes TARGET:
#   off : XKERNEL_FIXES_C4_C5_C10=0  (drops exactly C4 introspection + C10 reserved-id
#         + reverts C5 to arch-neutral lib-sigs; everything else identical)
#   on  : XKERNEL_FIXES_C4_C5_C10=1  (the new fixes active)
# Everything else held constant (W1 gotchas on, lib-sigs on, hard-kernel hints on,
# frozen splice on). Serial SDK. cap configurable.
#
# Target kernels (where C4/C5/C10 can plausibly move translation):
#   C4  collectives introspection : GEMV-Collectives-2D, GEMM-Collectives-2D, GEMV-Checkerboard
#   C5  benchmark-libs arch sigs   : CG, Preconditioned-CG, Power-Method, BiCGSTAB
#   C10 reserved resource-id       : Game-of-Life  (FFT-1D-2D is quarantine -> skipped)
#
# Usage: run_c4c5c10_ab_sweep.sh [--cap N] [--reps R]
#   --reps R repeats each (arm,kernel) R times for multi-seed pass-rate (default 1).
# Honest discipline: translation is high-variance; a 1-kernel delta at R=1 is noise.
# Report pass-RATE across reps; only claim a lift on a >=2-kernel or multi-rep margin.
set -u
CAP="${CAP:-12}"
REPS="${REPS:-1}"
LAUNCHER="$HOME/xkernel/run_cuda2csl_argo.sh"
KERNELS=(
  "GEMV-Collectives-2D" "GEMM-Collectives-2D" "GEMV-Checkerboard"
  "CG" "Preconditioned-CG" "Power-Method" "BiCGSTAB"
  "Game-of-Life"
)
while [ $# -gt 0 ]; do case "$1" in
  --cap) CAP="$2"; shift 2;;
  --reps) REPS="$2"; shift 2;;
  *) echo "bad arg $1" >&2; exit 2;; esac; done

TS=$(date -u +%Y%m%d_%H%M%S)
ROOT="$HOME/xkernel/code_translation/results/c4c5c10_ab_${TS}"
mkdir -p "$ROOT"
echo "C4/C5/C10 A/B root: $ROOT cap=$CAP reps=$REPS" | tee "$ROOT/config.txt"

_passed() { local bj; bj=$(ls -t "$1"/run_*/*/benchmark.json 2>/dev/null|head -1); [ -n "$bj" ] && python3 -c "import json,sys;sys.exit(0 if json.load(open('$bj')).get('status')=='pass' else 1)" 2>/dev/null; }
_cyc() { local bj; bj=$(ls -t "$1"/run_*/*/benchmark.json 2>/dev/null|head -1); [ -n "$bj" ] && python3 -c "import json;print(json.load(open('$bj')).get('cycles_send') or '-')" 2>/dev/null || echo "-"; }

for ARM in off on; do
  if [ "$ARM" = on ]; then export XKERNEL_FIXES_C4_C5_C10=1
  else export XKERNEL_FIXES_C4_C5_C10=0; fi
  for REP in $(seq 1 "$REPS"); do
    for K in "${KERNELS[@]}"; do
      OUT="$ROOT/$ARM/rep${REP}/$K"; mkdir -p "$OUT"
      echo "==== [$ARM rep$REP] $K ====" | tee -a "$ROOT/sweep.log"
      XKERNEL_HARD_KERNEL_HINTS=1 XKERNEL_SPLICE_FROZEN=1 \
        bash "$LAUNCHER" --kernel "$K" --output "$OUT" \
          --auto-optimize --reviewer-max-attempts "$CAP" \
          --max-optimize-attempts "$CAP" --min-optimize-attempts 4 \
          >>"$OUT/run.log" 2>&1 || true
      if _passed "$OUT"; then echo "RESULT $ARM rep$REP $K: pass cycles=$(_cyc "$OUT")" | tee -a "$ROOT/VERDICT.txt"
      else echo "RESULT $ARM rep$REP $K: fail" | tee -a "$ROOT/VERDICT.txt"; fi
    done
  done
done
echo "C4C5C10_AB_DONE" | tee -a "$ROOT/VERDICT.txt"

python3 - "$ROOT/VERDICT.txt" <<'PY' | tee -a "$ROOT/VERDICT.txt"
import sys, collections
rows = [l.split() for l in open(sys.argv[1]) if l.startswith("RESULT")]
# RESULT <arm> rep<N> <K>: pass|fail ...
agg = collections.defaultdict(lambda: [0, 0])  # arm -> [pass, total]
perk = collections.defaultdict(lambda: collections.defaultdict(lambda: [0, 0]))
for r in rows:
    arm = r[1]; k = r[3].rstrip(":"); ok = ("pass" in r)
    agg[arm][0] += ok; agg[arm][1] += 1
    perk[k][arm][0] += ok; perk[k][arm][1] += 1
print("\n=== C4/C5/C10 A/B pass-rate ===")
for arm in ("off", "on"):
    p, t = agg[arm]
    print(f"  {arm}: {p}/{t}")
print("  per-kernel (off -> on):")
for k in sorted(perk):
    o = perk[k]["off"]; n = perk[k]["on"]
    print(f"    {k:24s} {o[0]}/{o[1]} -> {n[0]}/{n[1]}")
print("\nFinding-A discipline: claim a lift only on a >=2-kernel or clear multi-rep margin.")
PY
