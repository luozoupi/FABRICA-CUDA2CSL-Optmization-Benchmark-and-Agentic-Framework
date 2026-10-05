#!/usr/bin/env bash
# (b) Retry the two test-split translation FAILURES with firewall-safe
# hard-kernel hints live (XKERNEL_HARD_KERNEL_HINTS=1, default). Serial — the
# SDK container wedges under parallel cslc. Cholesky first (harder), then GoL.
#
# Honest result either way: a pass is a hint-enabled recovery; a fail with the
# hints active is itself a finding (e.g. Cholesky may be unsolvable from pe.csl
# alone given hidden routing — see project_hard_kernel_hints memory).
set -u
LAUNCHER="$HOME/xkernel/run_cuda2csl_argo.sh"
CAP="${CAP:-12}"
TS=$(date -u +%Y%m%d_%H%M%S)
ROOT="$HOME/xkernel/code_translation/results/hinted_retries_${TS}"
mkdir -p "$ROOT"
echo "Hinted-retry root: $ROOT (cap=$CAP, hints ON)"

for K in Cholesky Game-of-Life; do
  OUT="$ROOT/$K"; mkdir -p "$OUT"
  echo "==== [$K] hinted retry ===="
  XKERNEL_HARD_KERNEL_HINTS=1 XKERNEL_SPLICE_FROZEN=1 ARGO_MODEL=claude-opus-4-7 \
    bash "$LAUNCHER" --kernel "$K" --output "$OUT" \
      --auto-optimize --reviewer-max-attempts "$CAP" \
      --max-optimize-attempts "$CAP" --min-optimize-attempts 4 \
      >>"$OUT/run.log" 2>&1 || true
  # crude pass detection
  BJ=$(ls -t "$OUT"/run_*/"$K"/benchmark.json 2>/dev/null | head -1)
  if [ -n "$BJ" ] && python3 -c "import json,sys; sys.exit(0 if json.load(open('$BJ')).get('status')=='pass' else 1)" 2>/dev/null; then
    CY=$(python3 -c "import json; print(json.load(open('$BJ')).get('cycles_send'))" 2>/dev/null)
    echo "RESULT $K: pass cycles=$CY" | tee -a "$ROOT/VERDICT.txt"
  else
    echo "RESULT $K: fail" | tee -a "$ROOT/VERDICT.txt"
  fi
done
echo "HINTED_RETRIES_DONE" | tee -a "$ROOT/VERDICT.txt"
echo "Root: $ROOT"
