#!/usr/bin/env bash
# Agentic translate+optimize sweep over the kernels enabled 2026-08-06.
#
#   GEMM-1PE              -- was already scoreable; never appeared in a sweep list
#   Laplacian2D-Reduce    -- was a VERIFY=False skeleton (inverted NRM predicate)
#   LorenzoPredictor-Tile -- was a VERIFY=False skeleton (row color routed backwards,
#                            NW scalar hard-wired to 0)
#
# Model: claude-opus-4-8 via the Anthropic API directly (run_cuda2csl_anthropic.sh),
# not the argo-shim proxy used by the earlier sweeps.
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAUNCHER="$SCRIPT_DIR/run_cuda2csl_anthropic.sh"
CAP="${CAP:-10}"
SEEDS="${SEEDS:-3}"

TS=$(date -u +%Y%m%d_%H%M%S)
ROOT="$SCRIPT_DIR/code_translation/results/newly_enabled_sweep_$TS"
mkdir -p "$ROOT"
VERDICT="$ROOT/VERDICT.txt"

echo "NEWLY-ENABLED SWEEP $TS  model=claude-opus-4-8  cap=$CAP  seeds=$SEEDS" | tee "$VERDICT"

# Template-based generation + the standard knowledge stack, matching the
# configuration of the 46-kernel template sweep so results are comparable.
for V in TEMPLATE_GEN DESIGN_SCHEMA WIRING_PLAN TRANSLATION_FACTS DRY_CHECK \
         ERROR_GOTCHA SPLICE_FROZEN LIB_BEHAVIORAL LAYER_CLEARANCE HARD_KERNEL_HINTS \
         LIB_SIGNATURES ARCH_MAPPING W1_GOTCHAS W1_CLUSTER_QUERIES MINED_GOTCHAS \
         FIXES_C4_C5_C10 FIXES_20260625 CODESIGN_EXEMPLAR BUILTIN_WHITELIST \
         MULTIPE_PROMPT DEBUG_TECHNIQUES TUTORIALS EXPLORED_TUTORIALS SKILLS \
         MESH_PATTERNS EXPLORED_EXPERIENCES OPTIMIZER_EXPLORED LIB_OVERLAY_NOTE \
         SDK_SIG HELDOUT_EVAL BEST_OF_N; do
  export "XKERNEL_$V=1"
  export "SINGULARITYENV_XKERNEL_$V=1"
  export "APPTAINERENV_XKERNEL_$V=1"
done
export XKERNEL_DEBUGGER=0 XKERNEL_DEBUGGER_V2=0
export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1

# name|ref_cycles|split
KERNELS=(
  "GEMM-1PE|119197|test"
  "Laplacian2D-Reduce|1950|test"
  "LorenzoPredictor-Tile|1315|test"
)

_passed() {
  local bj
  bj=$(ls -t "$1"/run_*/*/benchmark.json 2>/dev/null | head -1)
  [ -n "$bj" ] && python3 -c "import json,sys;sys.exit(0 if json.load(open('$bj')).get('status')=='pass' else 1)" 2>/dev/null
}

_cyc() {
  local bj
  bj=$(ls -t "$1"/run_*/*/benchmark.json 2>/dev/null | head -1)
  [ -n "$bj" ] && python3 -c "import json; c=json.load(open('$bj')).get('cycles_send'); print(c if isinstance(c,int) else '-')" 2>/dev/null || echo "-"
}

_cleanup() {
  pkill -u "$(id -u)" -f "squashfuse_ll" 2>/dev/null || true
  sleep 1
}

echo "Started: $(date -u)" | tee -a "$VERDICT"
echo "Root: $ROOT" | tee -a "$VERDICT"
echo "" | tee -a "$VERDICT"

for entry in "${KERNELS[@]}"; do
  IFS='|' read -r name ref split <<< "$entry"
  for seed in $(seq 1 "$SEEDS"); do
    OUT="$ROOT/$name/seed_$seed"; mkdir -p "$OUT"
    echo "==== [$split] $name seed=$seed (ref=$ref) $(date -u +%H:%M) ====" | tee -a "$ROOT/sweep.log"

    bash "$LAUNCHER" --kernel "$name" --output "$OUT" \
      --auto-optimize --reviewer-max-attempts "$CAP" \
      --max-optimize-attempts "$CAP" --min-optimize-attempts 4 \
      >>"$OUT/run.log" 2>&1 || true

    if _passed "$OUT"; then
      cyc=$(_cyc "$OUT")
      speedup="-"
      if [ "$ref" != "-" ] && [ "$cyc" != "-" ] && [ "$cyc" != "0" ]; then
        speedup=$(python3 -c "print(f'{$ref/$cyc:.2f}x')" 2>/dev/null || echo "-")
      fi
      echo "RESULT [$split] $name seed=$seed: PASS agent=$cyc ref=$ref vs_ref=$speedup" | tee -a "$VERDICT"
    else
      echo "RESULT [$split] $name seed=$seed: FAIL ref=$ref" | tee -a "$VERDICT"
    fi
    _cleanup
  done
done

echo "" | tee -a "$VERDICT"
echo "Finished: $(date -u)" | tee -a "$VERDICT"
echo "NEWLY_ENABLED_SWEEP_DONE" | tee -a "$VERDICT"
