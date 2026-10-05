#!/usr/bin/env bash
# W1 translation sweep of the sparse suite S (docs/IPDPS_PREREG.md v2, RQ1): CUDA -> CSL
# translation of the GraphBLAS-derived tasks with the production stack of the published
# sweeps, two arms that differ only in sparse awareness, N independent repeats ("seeds").
#
#   T0 = today's agent           (XKERNEL_SPARSE_MAPPING=0 XKERNEL_STRUCTURE_READOUT=0)
#   T1 = T0 + the sparse mapping catalogue + the input-structure readout on the task summary
#
# Translate ONLY (no --auto-optimize): the optimizer arms run separately from the frozen
# first-correct programs (run_model_guided_ab.sh), which extract_first_correct.py pulls
# out of THIS sweep's T0 runs by the blind lowest-seed rule.
#
# Resumable: a (kernel, arm, seed) whose output dir holds run_*/<kernel>/benchmark.json is
# skipped. Arms interleaved per seed. Strictly serial (one SDK container per node).
#
# Usage:
#   bash run_sparse_translate_sweep.sh [--kernels A,B,...] [--seeds 5] [--arms T0,T1] [--sdk 2.10]
#        [--cap 10] [--tag NAME] [--resume DIR]
# Env: XKERNEL_LAUNCHER (default run_cuda2csl_anthropic.sh; use run_cuda2csl_argo.sh for Argo),
#      ARGO_MODEL / XKERNEL_MODEL (the study's model id: claude-opus-4-8), XKERNEL_RUN_TIMEOUT (5400 s).
set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${XKERNEL_ROOT:-$SCRIPT_DIR}/xkernel_env.sh"

LAUNCHER="${XKERNEL_LAUNCHER:-$XKERNEL_ROOT/run_cuda2csl_anthropic.sh}"
N_SEEDS=5
ARMS="T0,T1"
TAG="sparse_translate"
RESUME=""
KERNEL_LIST=""
CAP=10
RUN_TIMEOUT="${XKERNEL_RUN_TIMEOUT:-5400}"
SDK_FLAVOR="${XKERNEL_SDK_FLAVOR:-2.10}"

while [ $# -gt 0 ]; do
  case "$1" in
    --kernels) KERNEL_LIST="$2"; shift 2;;
    --seeds) N_SEEDS="$2"; shift 2;;
    --arms) ARMS="$2"; shift 2;;
    --sdk) SDK_FLAVOR="$2"; shift 2;;
    --cap) CAP="$2"; shift 2;;
    --tag) TAG="$2"; shift 2;;
    --resume) RESUME="$2"; shift 2;;
    *) echo "unknown arg $1" >&2; exit 2;;
  esac
done

if [ "$SDK_FLAVOR" = "2.10" ]; then
  export XKERNEL_SDK_FLAVOR=2.10
  export XKERNEL_SDK_ROOT="${XKERNEL_SDK_ROOT_210:-/software/cerebras/cs_sdk-2.10}"
  export XKERNEL_TARGET_SDK="${XKERNEL_TARGET_SDK:-2.10.0}"
  export XKERNEL_SDK210_FIXUP="${XKERNEL_SDK210_FIXUP:-1}"
fi
if [ -n "$RESUME" ]; then ROOT="$RESUME"; else ROOT="$XKERNEL_ROOT/code_translation/results/${TAG}_$(date -u +%Y%m%d_%H%M%S)"; fi
mkdir -p "$ROOT"
LOG="$ROOT/sweep.log"; VERDICT="$ROOT/VERDICT.txt"
echo "SPARSE TRANSLATE SWEEP  arms=$ARMS seeds=$N_SEEDS cap=$CAP sdk=$SDK_FLAVOR root=$XKERNEL_SDK_ROOT launcher=$(basename "$LAUNCHER") model=${XKERNEL_MODEL:-${ARGO_MODEL:-default}} commit=$(cd "$XKERNEL_ROOT" && ${GIT:-git} rev-parse --short HEAD 2>/dev/null || echo n/a)  $(date -u +%FT%TZ)" | tee -a "$VERDICT"

# ---------- Production stack of the published translation sweeps (run_full_template_sweep.sh) ----------
export XKERNEL_TEMPLATE_GEN=1 XKERNEL_DESIGN_SCHEMA=1 XKERNEL_WIRING_PLAN=1 XKERNEL_TRANSLATION_FACTS=1
export XKERNEL_DRY_CHECK=1 XKERNEL_ERROR_GOTCHA=1 XKERNEL_SPLICE_FROZEN=1 XKERNEL_LIB_BEHAVIORAL=1
export XKERNEL_LAYER_CLEARANCE=1 XKERNEL_HARD_KERNEL_HINTS=1 XKERNEL_LIB_SIGNATURES=1 XKERNEL_ARCH_MAPPING=1
export XKERNEL_W1_GOTCHAS=1 XKERNEL_W1_CLUSTER_QUERIES=1 XKERNEL_MINED_GOTCHAS=1 XKERNEL_FIXES_C4_C5_C10=1
export XKERNEL_FIXES_20260625=1 XKERNEL_CODESIGN_EXEMPLAR=1 XKERNEL_BUILTIN_WHITELIST=1 XKERNEL_MULTIPE_PROMPT=1
export XKERNEL_DEBUG_TECHNIQUES=1 XKERNEL_TUTORIALS=1 XKERNEL_EXPLORED_TUTORIALS=1 XKERNEL_SKILLS=1
export XKERNEL_MESH_PATTERNS=1 XKERNEL_EXPLORED_EXPERIENCES=1 XKERNEL_OPTIMIZER_EXPLORED=1
export XKERNEL_LIB_OVERLAY_NOTE=1 XKERNEL_SDK_SIG=1 XKERNEL_HELDOUT_EVAL=1 XKERNEL_BEST_OF_N=1
export XKERNEL_DEBUGGER=0 XKERNEL_DEBUGGER_V2=0
export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1

if [ -n "$KERNEL_LIST" ]; then
  IFS=',' read -r -a KERNELS <<< "$KERNEL_LIST"
else
  IFS=',' read -r -a KERNELS <<< "$("$XKERNEL_MICROMAMBA" run -n "$XKERNEL_ENV" python "$XKERNEL_ROOT/code_translation/task_sets.py" --kernels S)"
fi
IFS=',' read -r -a ARM_LIST <<< "$ARMS"
echo "kernels (${#KERNELS[@]}): ${KERNELS[*]}" | tee -a "$LOG"

_arm_env() {
  case "$1" in
    T0) echo "XKERNEL_SPARSE_MAPPING=0 XKERNEL_STRUCTURE_READOUT=0";;
    T1) echo "XKERNEL_SPARSE_MAPPING=1 XKERNEL_STRUCTURE_READOUT=1";;
    *) echo "unknown arm $1" >&2; exit 2;;
  esac
}
_cleanup() { pkill -u "$(whoami)" -f "squashfuse_ll" 2>/dev/null || true; sleep 1; }
_status() {   # newest benchmark.json of a run dir -> pass|fail|-
  local bj; bj=$(ls -t "$1"/run_*/*/benchmark.json 2>/dev/null | head -1)
  [ -n "$bj" ] && python3 -c "import json;d=json.load(open('$bj'));print('pass' if d.get('status')=='pass' and d.get('success_marker') else 'fail')" 2>/dev/null || echo "-"
}

for name in "${KERNELS[@]}"; do
  echo "==== $name ====" | tee -a "$LOG"
  for seed in $(seq 1 "$N_SEEDS"); do
    if [ $((seed % 2)) -eq 1 ]; then order=("${ARM_LIST[@]}"); else order=(); for ((i=${#ARM_LIST[@]}-1;i>=0;i--)); do order+=("${ARM_LIST[$i]}"); done; fi
    for arm in "${order[@]}"; do
      OUT="$ROOT/$name/$arm/seed_$seed"
      if ls "$OUT"/run_*/"$name"/benchmark.json >/dev/null 2>&1; then
        echo "  [$name] $arm seed=$seed already done ($(_status "$OUT"))" | tee -a "$LOG"; continue
      fi
      mkdir -p "$OUT"
      echo "  [$name] $arm seed=$seed start $(date -u +%H:%M:%S)" | tee -a "$LOG"
      env $(_arm_env "$arm") timeout "$RUN_TIMEOUT" bash "$LAUNCHER" --kernel "$name" --output "$OUT" \
        --reviewer-max-attempts "$CAP" >>"$OUT/run.log" 2>&1
      rc=$?
      echo "  [$name] $arm seed=$seed exit=$rc status=$(_status "$OUT") $(date -u +%H:%M:%S)" | tee -a "$LOG"
      _cleanup
    done
  done
done
echo "SPARSE_TRANSLATE_DONE $(date -u +%FT%TZ)" | tee -a "$VERDICT"
# pass counts per (kernel, arm), plus the failure families of every attempt
for name in "${KERNELS[@]}"; do
  for arm in "${ARM_LIST[@]}"; do
    n=0; p=0
    for d in "$ROOT/$name/$arm"/seed_*/; do [ -d "$d" ] || continue; n=$((n+1)); [ "$(_status "$d")" = "pass" ] && p=$((p+1)); done
    echo "  $name $arm: $p/$n retained passes" | tee -a "$VERDICT"
  done
done
"$XKERNEL_MICROMAMBA" run -n "$XKERNEL_ENV" python "$XKERNEL_ROOT/code_translation/error_family.py" --corpus "$ROOT" --out "$ROOT/error_families.csv" 2>/dev/null | tail -3 | tee -a "$VERDICT"
