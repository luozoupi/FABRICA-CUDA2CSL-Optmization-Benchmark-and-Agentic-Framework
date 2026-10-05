#!/usr/bin/env bash
# 3-arm knowledge-ablation baseline sweep.
#
# Measures the marginal value of the W1 knowledge stack by running each kernel
# under three knowledge tiers, all else identical (same model, same loop cap):
#
#   knowon : full knowledge (current production pipeline)
#   soft   : --no-knowledge        (strip TIER-A curated/retrieved knowledge,
#                                    keep TIER-B CSL language primer + TIER-C)
#   bare   : --no-knowledge --bare  (also strip TIER-B; only TIER-C structure)
#
# The reviewer stays ACTIVE in all arms (do NOT pass --skip-reviewer, which
# would cap the loop at --turns). Loop cap is --reviewer-max-attempts 20 so each
# arm gets up to 20 attempts to reach a passing kernel, then the final/best CSL
# is scored against the reference by the pipeline's own build_version_trace.
#
# Usage: run_baseline_ablation_sweep.sh [--arms "knowon soft bare"] --kernel K [--kernel K ...]
set -u

MODEL="${ARGO_MODEL:-claude-sonnet-4-6}"   # match the 6/15 knowledge-on baseline arm
CAP=20
LAUNCHER="$HOME/xkernel/run_cuda2csl_argo.sh"
ARMS="knowon soft bare"

KERNELS=()
while [ $# -gt 0 ]; do
    case "$1" in
        --arms)   ARMS="$2"; shift 2 ;;
        --kernel) KERNELS+=("$2"); shift 2 ;;
        --cap)    CAP="$2"; shift 2 ;;
        --model)  MODEL="$2"; shift 2 ;;
        *) echo "Unknown arg: $1" >&2; exit 2 ;;
    esac
done
[ ${#KERNELS[@]} -gt 0 ] || { echo "need --kernel" >&2; exit 2; }

TS=$(date -u +%Y%m%d_%H%M%S)
ROOT="$HOME/xkernel/code_translation/results/baseline_ablation_${TS}"
mkdir -p "$ROOT"
echo "Baseline-ablation sweep root: $ROOT"
echo "arms=[$ARMS]  model=$MODEL  cap=$CAP  kernels=${KERNELS[*]}"

_arm_flags() {
    case "$1" in
        knowon) echo "" ;;
        soft)   echo "--no-knowledge" ;;
        bare)   echo "--no-knowledge --bare" ;;
        *) echo "BADARM" ;;
    esac
}

_passed() {
    local bj
    bj=$(ls -t "$1"/run_*/"$2"/benchmark.json 2>/dev/null | head -1)
    [ -n "$bj" ] && [ -f "$bj" ] || return 1
    python3 -c "import json,sys
try: sys.exit(0 if json.load(open(sys.argv[1])).get('status')=='pass' else 1)
except Exception: sys.exit(2)" "$bj"
}

_cycles() {
    local bj
    bj=$(ls -t "$1"/run_*/"$2"/benchmark.json 2>/dev/null | head -1)
    [ -n "$bj" ] || { echo "-"; return; }
    python3 -c "import json
try:
    d=json.load(open('$bj')); print(d.get('cycles_send') or d.get('metrics',{}).get('cycles_send') or '-')
except Exception: print('-')" 2>/dev/null || echo "-"
}

for K in "${KERNELS[@]}"; do
    for ARM in $ARMS; do
        FLAGS=$(_arm_flags "$ARM")
        OUT="$ROOT/$ARM/$K"
        mkdir -p "$OUT"
        echo "==== [$K] arm=$ARM (flags='$FLAGS') ====" | tee -a "$ROOT/sweep.log"
        ARGO_MODEL="$MODEL" bash "$LAUNCHER" \
            --kernel "$K" --output "$OUT" \
            --auto-optimize --reviewer-max-attempts "$CAP" \
            --max-optimize-attempts "$CAP" --min-optimize-attempts 5 \
            $FLAGS \
            >>"$ROOT/$ARM/$K.log" 2>&1 || true
        if _passed "$OUT" "$K"; then
            CY=$(_cycles "$OUT" "$K")
            echo "RESULT $K $ARM: pass cycles=$CY" | tee -a "$ROOT/VERDICT.txt"
        else
            echo "RESULT $K $ARM: fail" | tee -a "$ROOT/VERDICT.txt"
        fi
    done
done

echo "SWEEP_DONE" | tee -a "$ROOT/VERDICT.txt"
echo "==== SUMMARY ===="
python3 -c "
import re,collections
rows=[l.split() for l in open('$ROOT/VERDICT.txt') if l.startswith('RESULT')]
by_arm=collections.defaultdict(lambda:[0,0])
for r in rows:
    arm=r[2].rstrip(':'); res=r[3]
    by_arm[arm][0 if res=='pass' else 1]+=1
for arm,(p,f) in by_arm.items():
    print(f'  {arm:7s}: {p} pass / {p+f} total')
" 2>&1
echo "Root: $ROOT"
