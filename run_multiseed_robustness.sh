#!/usr/bin/env bash
# Multi-seed robustness for the test-split results: re-run each kernel's full
# translate+optimize pipeline N times (independent LLM draws — there is no seed
# flag; variance comes from sampling) and report pass-rate + cycle distribution.
# Puts variance bars on the headline table (translation is high-variance near
# the cap). Serial — the SDK container wedges under parallel cslc.
#
# Usage: run_multiseed_robustness.sh [--reps N] [--cap C] [--kernels "K1 K2 ..."]
set -u
REPS="${REPS:-3}"
CAP="${CAP:-12}"
LAUNCHER="$HOME/xkernel/run_cuda2csl_argo.sh"
# default: the scoreable test-split kernels that translated (exclude Cholesky,
# which is the structural-fail case handled separately). Game-of-Life needs the
# hint. Each entry: "KernelName:sizeflag" where sizeflag is large|small|none.
KERNELS="Laplacian2D-Halo:large Wide-Multiplication:none Residual:none Single-Tile-Matvec:none Game-of-Life:none 7pt-Stencil:large"

while [ $# -gt 0 ]; do
  case "$1" in
    --reps) REPS="$2"; shift 2 ;;
    --cap) CAP="$2"; shift 2 ;;
    --kernels) KERNELS="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 2 ;;
  esac
done

TS=$(date -u +%Y%m%d_%H%M%S)
ROOT="$HOME/xkernel/code_translation/results/multiseed_${TS}"
mkdir -p "$ROOT"
echo "Multi-seed root: $ROOT  reps=$REPS cap=$CAP" | tee "$ROOT/config.txt"
echo "kernels: $KERNELS" | tee -a "$ROOT/config.txt"

for PAIR in $KERNELS; do
  K="${PAIR%%:*}"; SIZE="${PAIR##*:}"
  SIZE_FLAG=(); [ "$SIZE" != "none" ] && SIZE_FLAG=(--size "$SIZE")
  for rep in $(seq 1 "$REPS"); do
    OUT="$ROOT/$K/rep$rep"; mkdir -p "$OUT"
    echo "==== [$K] size=$SIZE rep $rep/$REPS ====" | tee -a "$ROOT/sweep.log"
    XKERNEL_HARD_KERNEL_HINTS=1 XKERNEL_SPLICE_FROZEN=1 ARGO_MODEL=claude-opus-4-7 \
      bash "$LAUNCHER" --kernel "$K" --output "$OUT" "${SIZE_FLAG[@]}" \
        --auto-optimize --reviewer-max-attempts "$CAP" \
        --max-optimize-attempts "$CAP" --min-optimize-attempts 4 \
        >>"$OUT/run.log" 2>&1 || true
    BJ=$(ls -t "$OUT"/run_*/"$K"/benchmark.json 2>/dev/null | head -1)
    if [ -n "$BJ" ] && python3 -c "import json,sys;sys.exit(0 if json.load(open('$BJ')).get('status')=='pass' else 1)" 2>/dev/null; then
      CY=$(python3 -c "import json;print(json.load(open('$BJ')).get('cycles_send'))" 2>/dev/null)
      echo "RESULT $K rep$rep: pass cycles=$CY" | tee -a "$ROOT/VERDICT.txt"
    else
      echo "RESULT $K rep$rep: fail" | tee -a "$ROOT/VERDICT.txt"
    fi
  done
done

echo "MULTISEED_DONE" | tee -a "$ROOT/VERDICT.txt"
# Summary: pass-rate + cycle min/median/max per kernel
python3 - "$ROOT/VERDICT.txt" <<'PY' | tee -a "$ROOT/VERDICT.txt"
import sys, re, collections, statistics
rows = [l.split() for l in open(sys.argv[1]) if l.startswith("RESULT")]
byk = collections.defaultdict(lambda: {"pass":0,"total":0,"cyc":[]})
for r in rows:
    k = r[1]; res = r[3]
    byk[k]["total"] += 1
    if res == "pass":
        byk[k]["pass"] += 1
        m = re.search(r"cycles=(\d+)", " ".join(r))
        if m: byk[k]["cyc"].append(int(m.group(1)))
print("\n==== MULTI-SEED SUMMARY ====")
for k, d in byk.items():
    c = d["cyc"]
    dist = f"min={min(c)} med={int(statistics.median(c))} max={max(c)}" if c else "n/a"
    print(f"  {k:22s}: {d['pass']}/{d['total']} pass  cycles[{dist}]")
PY
echo "Root: $ROOT"
