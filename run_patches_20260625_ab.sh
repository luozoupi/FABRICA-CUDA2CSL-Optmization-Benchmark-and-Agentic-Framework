#!/usr/bin/env bash
# Multi-seed A/B for the 2026-06-25 firewall-safe patch set (R1-R4), gated by
# XKERNEL_FIXES_20260625. Two arms (off / on) x N seeds over the kernels R1-R4 target.
# Measures whether the patches move pass-rate with variance bars (Finding-A discipline:
# claim a lift only on a >=2-kernel or clear multi-rep margin, never single-draw).
# Serial SDK -> long (~9-12h at cap 20, 3 seeds, 8 kernels). Results -> results/.
set -u
LAUNCHER="$HOME/xkernel/run_cuda2csl_argo.sh"
CAP="${CAP:-20}"
SEEDS=("${SEEDS:-11 23 37}")   # 3 translation-variance reps (also drive XKERNEL_EVAL_SEED)
read -r -a SEED_ARR <<< "${SEEDS[*]}"
TS=$(date -u +%Y%m%d_%H%M%S)
ROOT="$HOME/xkernel/code_translation/results/patches_20260625_ab_${TS}"
mkdir -p "$ROOT"
VERDICT="$ROOT/VERDICT.txt"
echo "patches-20260625 A/B  $TS  cap=$CAP  seeds=${SEED_ARR[*]}" | tee "$VERDICT"

# Kernels the R1-R4 patches act on (R1 in-place-DSR: solvers/collectives; R2: FFT;
# R3: Laplacian; R4: Histogram). CG/PCG are known numeric ceilings (control).
KERNELS=(Histogram FFT-1D-2D Laplacian2D-Halo Power-Method BiCGSTAB Preconditioned-CG CG GEMV-Collectives-2D)

_passed() { local bj; bj=$(ls -t "$1"/run_*/*/benchmark.json 2>/dev/null | head -1); [ -n "$bj" ] && python3 -c "import json,sys;sys.exit(0 if json.load(open('$bj')).get('status')=='pass' else 1)" 2>/dev/null; }
_cyc() { local bj; bj=$(ls -t "$1"/run_*/*/benchmark.json 2>/dev/null | head -1); [ -n "$bj" ] && python3 -c "import json;print(json.load(open('$bj')).get('cycles_send') or '-')" 2>/dev/null || echo "-"; }

for ARM in off on; do
  if [ "$ARM" = on ]; then export XKERNEL_FIXES_20260625=1; else export XKERNEL_FIXES_20260625=0; fi
  for SEED in "${SEED_ARR[@]}"; do
    for K in "${KERNELS[@]}"; do
      OUT="$ROOT/$ARM/seed${SEED}/$K"; mkdir -p "$OUT"
      echo "==== [$ARM seed$SEED] $K ====" | tee -a "$ROOT/sweep.log"
      XKERNEL_HARD_KERNEL_HINTS=1 XKERNEL_SPLICE_FROZEN=1 \
      SINGULARITYENV_XKERNEL_EVAL_SEED="$SEED" APPTAINERENV_XKERNEL_EVAL_SEED="$SEED" XKERNEL_EVAL_SEED="$SEED" \
        bash "$LAUNCHER" --kernel "$K" --output "$OUT" \
          --auto-optimize --reviewer-max-attempts "$CAP" \
          --max-optimize-attempts "$CAP" --min-optimize-attempts 4 \
          >>"$OUT/run.log" 2>&1 || true
      if _passed "$OUT"; then echo "RESULT $ARM seed$SEED $K: PASS cycles=$(_cyc "$OUT")" | tee -a "$VERDICT"
      else echo "RESULT $ARM seed$SEED $K: FAIL" | tee -a "$VERDICT"; fi
    done
  done
done
echo "PATCHES_20260625_AB_DONE" | tee -a "$VERDICT"

python3 - "$VERDICT" <<'PY' | tee -a "$VERDICT"
import sys, collections
rows=[l.split() for l in open(sys.argv[1]) if l.startswith("RESULT")]
# RESULT <arm> seed<S> <K>: PASS|FAIL
agg=collections.defaultdict(lambda:[0,0])         # arm -> [pass,total]
perk=collections.defaultdict(lambda: collections.defaultdict(lambda:[0,0]))  # K -> arm -> [pass,total]
for r in rows:
    arm=r[1]; k=r[3].rstrip(":"); ok=("PASS" in r)
    agg[arm][0]+=ok; agg[arm][1]+=1
    perk[k][arm][0]+=ok; perk[k][arm][1]+=1
print("\n=== patches-20260625 A/B (multi-seed pass-rate) ===")
for arm in ("off","on"):
    p,t=agg[arm]; print(f"  {arm}: {p}/{t}")
print("  per-kernel (off -> on, pass/seeds):")
flips=0
for k in sorted(perk):
    o=perk[k]["off"]; n=perk[k]["on"]
    mark=""
    if n[0]>o[0]: mark=" <== improved"; flips+=1
    elif n[0]<o[0]: mark=" <== regressed"
    print(f"    {k:22s} {o[0]}/{o[1]} -> {n[0]}/{n[1]}{mark}")
print(f"\n  kernels improved on->off: {flips}")
print("  Finding-A: claim a lift only on a >=2-kernel or clear multi-rep margin.")
PY
