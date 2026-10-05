#!/usr/bin/env bash
# A/B sweep to PROVE the WS3+WS4.3 translator levers (Finding-A discipline:
# default-on only on a >=2-kernel lift). Two arms over the held-out test split:
#   off : baseline (both levers off)
#   on  : XKERNEL_WHY_FASTER_RULES=1 + XKERNEL_LEAVE_ONE_OUT=1
# Translate-focused (the levers act on TRANSLATION); --auto-optimize still on so a
# pass is a real end-to-end pass. Serial SDK. cap 12.
#
# Usage: run_lever_ab_sweep.sh [--cap N]
set -u
CAP="${CAP:-12}"
LAUNCHER="$HOME/xkernel/run_cuda2csl_argo.sh"
# Test-split kernels (real-translation, scoreable). Cholesky excluded (structural
# fail + loose-tolerance false pass); FFT excluded (quarantine). Use the ones
# where a lever could plausibly move translation.
PAIRS=(
  "7pt-Stencil:large" "Laplacian2D-Halo:large" "Residual:none"
  "Game-of-Life:none" "Single-Tile-Matvec:none" "Wide-Multiplication:none"
  "Tensor-Transpose-021:none" "PDFT-Pi-Pipeline:none"
)
while [ $# -gt 0 ]; do case "$1" in --cap) CAP="$2"; shift 2;; *) echo "bad arg $1">&2; exit 2;; esac; done

TS=$(date -u +%Y%m%d_%H%M%S)
ROOT="$HOME/xkernel/code_translation/results/lever_ab_${TS}"
mkdir -p "$ROOT"
echo "Lever A/B root: $ROOT cap=$CAP" | tee "$ROOT/config.txt"

_passed() { local bj; bj=$(ls -t "$1"/run_*/"$2"/benchmark.json 2>/dev/null|head -1); [ -n "$bj" ] && python3 -c "import json,sys;sys.exit(0 if json.load(open('$bj')).get('status')=='pass' else 1)" 2>/dev/null; }
_cyc() { local bj; bj=$(ls -t "$1"/run_*/"$2"/benchmark.json 2>/dev/null|head -1); [ -n "$bj" ] && python3 -c "import json;print(json.load(open('$bj')).get('cycles_send') or '-')" 2>/dev/null || echo "-"; }

for ARM in off on; do
  if [ "$ARM" = on ]; then export XKERNEL_WHY_FASTER_RULES=1 XKERNEL_LEAVE_ONE_OUT=1
  else unset XKERNEL_WHY_FASTER_RULES XKERNEL_LEAVE_ONE_OUT; fi
  for PAIR in "${PAIRS[@]}"; do
    K="${PAIR%%:*}"; SIZE="${PAIR##*:}"; SF=(); [ "$SIZE" != none ] && SF=(--size "$SIZE")
    OUT="$ROOT/$ARM/$K"; mkdir -p "$OUT"
    echo "==== [$ARM] $K size=$SIZE ====" | tee -a "$ROOT/sweep.log"
    XKERNEL_HARD_KERNEL_HINTS=1 XKERNEL_SPLICE_FROZEN=1 ARGO_MODEL=claude-opus-4-7 \
      bash "$LAUNCHER" --kernel "$K" --output "$OUT" "${SF[@]}" \
        --auto-optimize --reviewer-max-attempts "$CAP" --max-optimize-attempts "$CAP" --min-optimize-attempts 4 \
        >>"$OUT/run.log" 2>&1 || true
    if _passed "$OUT" "$K"; then echo "RESULT $ARM $K: pass cycles=$(_cyc "$OUT" "$K")" | tee -a "$ROOT/VERDICT.txt"
    else echo "RESULT $ARM $K: fail" | tee -a "$ROOT/VERDICT.txt"; fi
  done
done
echo "LEVER_AB_DONE" | tee -a "$ROOT/VERDICT.txt"
python3 - "$ROOT/VERDICT.txt" <<'PY' | tee -a "$ROOT/VERDICT.txt"
import sys, collections
rows=[l.split() for l in open(sys.argv[1]) if l.startswith("RESULT")]
arm=collections.defaultdict(lambda:[0,0])
passes=collections.defaultdict(set)
for r in rows:
    a=r[1]; k=r[2].rstrip(':'); res=r[3]
    arm[a][0 if res=='pass' else 1]+=1
    if res=='pass': passes[a].add(k)
print("\n==== LEVER A/B SUMMARY ====")
for a in ('off','on'):
    p,f=arm[a]; print(f"  {a:3s}: {p} pass / {p+f}")
only_on = passes['on']-passes['off']; only_off = passes['off']-passes['on']
print(f"  kernels passing ONLY with levers on:  {sorted(only_on)}")
print(f"  kernels passing ONLY with levers off: {sorted(only_off)}")
print(f"  NET lever lift: {len(only_on)-len(only_off)} kernels (keep default-on if >=2)")
PY
echo "Root: $ROOT"
