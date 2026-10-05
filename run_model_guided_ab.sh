#!/usr/bin/env bash
# Optimizer arms from a FROZEN first-correct program per kernel (every run is --optimize-only,
# so translation variance is excluded; all arms of a kernel start from the same program under
# results/first_correct/<tag>/<kernel>/).
#
# v1 arms (general study, docs/IPDPS_PREREG.md v1):
#   O0  = Fabrica's optimizer with heuristic profile feedback (baseline)
#   O1  = O0 + silicon-model readout, model-derived angles, model-guided selection
#   O1A / O1S = ablations (new angles only / model selector only)
# v2 arms (sparse study, docs/IPDPS_PREREG.md v2; use --sdk 2.10 and --fc .../sparse_<date>):
#   O1   = silicon model + input-structure readout + sparse angles
#   O1I  = O1 + the IR/disassembly readout in the prompt (XKERNEL_IR_CAPTURE=best)
#   O1nS = O1 with the structure readout off;  O1nA = O1 with the sparse angles off
# Uniform instrumentation for every arm (v2): the disassembly hazard scan of each passing
# candidate (XKERNEL_IR_CAPTURE=disasm) and the hazard policy XKERNEL_IR_HAZARD_POLICY=heldout,
# so the arms differ only in what the agent is TOLD. Set XKERNEL_IR_CAPTURE_BASE=0 to switch the
# instrumentation off (v1 behaviour).
#
# Resumable: a (kernel, arm, seed) whose output dir holds optimization_summary.json
# is skipped. Arms are interleaved per seed. Strictly serial (the SDK container
# is a serial resource). 90-minute watchdog per run.
#
# Usage:
#   bash run_model_guided_ab.sh [--kernels A,B,...] [--seeds N] [--arms O0,O1,O1I] [--sdk 1.4|2.10] \
#        [--fc results/first_correct/template_20260722] [--tag NAME] [--resume DIR]
# Env: XKERNEL_LAUNCHER (default run_cuda2csl_anthropic.sh; use run_cuda2csl_argo.sh
#      for Argo), XKERNEL_MODEL / ARGO_MODEL (model id), XKERNEL_MIN_OPT / XKERNEL_MAX_OPT
#      (default 5/12), XKERNEL_RUN_TIMEOUT (default 5400 s).
set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${XKERNEL_ROOT:-$SCRIPT_DIR}/xkernel_env.sh"

LAUNCHER="${XKERNEL_LAUNCHER:-$XKERNEL_ROOT/run_cuda2csl_anthropic.sh}"
FC_ROOT="$XKERNEL_ROOT/code_translation/results/first_correct/template_20260722"
N_SEEDS=5
ARMS="O0,O1"
TAG="model_guided_ab"
RESUME=""
SIZE_NAME=""     # optional spec size (e.g. it10): the optimiser benchmarks against that size's build script
KERNEL_LIST=""
SEED_FROM="${XKERNEL_SEED_FROM:-1}"   # run seeds SEED_FROM..N_SEEDS (split one cell across nodes)
MIN_OPT="${XKERNEL_MIN_OPT:-5}"
MAX_OPT="${XKERNEL_MAX_OPT:-12}"
RUN_TIMEOUT="${XKERNEL_RUN_TIMEOUT:-5400}"
SDK_FLAVOR="${XKERNEL_SDK_FLAVOR:-1.4}"

while [ $# -gt 0 ]; do
  case "$1" in
    --sdk) SDK_FLAVOR="$2"; shift 2;;
    --kernels) KERNEL_LIST="$2"; shift 2;;
    --seeds) N_SEEDS="$2"; shift 2;;
    --arms) ARMS="$2"; shift 2;;
    --fc) FC_ROOT="$2"; shift 2;;
    --tag) TAG="$2"; shift 2;;
    --resume) RESUME="$2"; shift 2;;
    --size) SIZE_NAME="$2"; shift 2;;
    *) echo "unknown arg $1" >&2; exit 2;;
  esac
done

# Toolchain: --sdk 2.10 runs the whole sweep on SDK 2.10 (root, the agent's target SDK, the
# mechanical 1.4 -> 2.10 fix-up of staged CSL); see xkernel_env.sh XKERNEL_SDK_FLAVOR.
if [ "$SDK_FLAVOR" = "2.10" ]; then
  export XKERNEL_SDK_FLAVOR=2.10
  export XKERNEL_SDK_ROOT="${XKERNEL_SDK_ROOT_210:-/software/cerebras/cs_sdk-2.10}"
  export XKERNEL_TARGET_SDK="${XKERNEL_TARGET_SDK:-2.10.0}"
  export XKERNEL_SDK210_FIXUP="${XKERNEL_SDK210_FIXUP:-1}"
fi
if [ -n "$RESUME" ]; then ROOT="$RESUME"; else ROOT="$XKERNEL_ROOT/code_translation/results/${TAG}_$(date -u +%Y%m%d_%H%M%S)"; fi
mkdir -p "$ROOT"
LOG="$ROOT/sweep.log"; VERDICT="$ROOT/VERDICT.txt"
echo "MODEL-GUIDED A/B  arms=$ARMS seeds=$N_SEEDS size=${SIZE_NAME:-default} opt=$MIN_OPT/$MAX_OPT sdk=$SDK_FLAVOR root=$XKERNEL_SDK_ROOT fc=$FC_ROOT launcher=$(basename "$LAUNCHER") model=${XKERNEL_MODEL:-${ARGO_MODEL:-default}} commit=$(cd "$XKERNEL_ROOT" && ${GIT:-git} rev-parse --short HEAD 2>/dev/null || echo n/a)  $(date -u +%FT%TZ)" | tee -a "$VERDICT"

# Production gates shared by both arms (as in the published sweeps).
export XKERNEL_DRY_CHECK=1 XKERNEL_ERROR_GOTCHA=1 XKERNEL_SPLICE_FROZEN=1 XKERNEL_LIB_BEHAVIORAL=1
export XKERNEL_LAYER_CLEARANCE=1 XKERNEL_PROFILE_MEMORY=1
# Retained pass (pre-registered) requires the held-out inputs: the optimizer's final
# confirmation re-benchmarks the winner on the hidden seeds.
export XKERNEL_HELDOUT_EVAL=1
# Keep every benchmarked optimizer candidate (code + cycles) so the O2 arm can
# replay the candidate sets on WSE-3 and the fidelity study can rank them.
export XKERNEL_KEEP_CANDIDATES=1
export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1

# Kernel set: every kernel with a frozen first-correct program, unless --kernels.
if [ -n "$KERNEL_LIST" ]; then
  IFS=',' read -r -a KERNELS <<< "$KERNEL_LIST"
else
  KERNELS=()
  for d in "$FC_ROOT"/*/; do
    k=$(basename "$d"); [ -f "$d/meta.json" ] && KERNELS+=("$k")
  done
fi
IFS=',' read -r -a ARM_LIST <<< "$ARMS"
echo "kernels (${#KERNELS[@]}): ${KERNELS[*]}" | tee -a "$LOG"

_cleanup() { pkill -u "$(whoami)" -f "squashfuse_ll" 2>/dev/null || true; sleep 1; }

# Uniform instrumentation (every arm): disassembly hazard scan + hazard policy. Off with
# XKERNEL_IR_CAPTURE_BASE=0.
_BASE_ENV="XKERNEL_IR_CAPTURE=${XKERNEL_IR_CAPTURE_BASE:-disasm} XKERNEL_IR_HAZARD_POLICY=${XKERNEL_IR_HAZARD_POLICY:-heldout}"
_arm_env() {
  case "$1" in
    O0)   echo "$_BASE_ENV XKERNEL_MODEL_GUIDED=0 XKERNEL_MODEL_ANGLES=0 XKERNEL_STRUCTURE_READOUT=0 XKERNEL_SPARSE_ANGLES=0 XKERNEL_IR_READOUT=0";;
    O1)   echo "$_BASE_ENV XKERNEL_MODEL_GUIDED=1 XKERNEL_MODEL_ANGLES=1 XKERNEL_STRUCTURE_READOUT=1 XKERNEL_SPARSE_ANGLES=1 XKERNEL_IR_READOUT=0";;
    O1I)  echo "$_BASE_ENV XKERNEL_MODEL_GUIDED=1 XKERNEL_MODEL_ANGLES=1 XKERNEL_STRUCTURE_READOUT=1 XKERNEL_SPARSE_ANGLES=1 XKERNEL_IR_READOUT=1 XKERNEL_IR_CAPTURE=best";;
    O1X)  echo "$_BASE_ENV XKERNEL_MODEL_GUIDED=1 XKERNEL_MODEL_ANGLES=1 XKERNEL_STRUCTURE_READOUT=1 XKERNEL_SPARSE_ANGLES=1 XKERNEL_IR_READOUT=0 XKERNEL_SPARSE_ANGLES_EXTRA=cursor_path_split";;   # O1 + the cursor-paths angle (2026-09-26)
    O1N)  echo "$_BASE_ENV XKERNEL_MODEL_GUIDED=1 XKERNEL_MODEL_ANGLES=1 XKERNEL_STRUCTURE_READOUT=1 XKERNEL_SPARSE_ANGLES=1 XKERNEL_IR_READOUT=0 XKERNEL_NOOP_FEEDBACK=1";;   # O1 + compiled-identity feedback (2026-09-28)
    O2)   echo "$_BASE_ENV XKERNEL_MODEL_GUIDED=1 XKERNEL_MODEL_ANGLES=1 XKERNEL_STRUCTURE_READOUT=1 XKERNEL_SPARSE_ANGLES=1 XKERNEL_IR_READOUT=0 XKERNEL_ANGLE_WHITELIST=cursor_path_split,index_type_narrowing,dsd_setup_hoist,dense_row_accumulator";;   # staged: second-order angles from an O1 retained start (2026-09-28)
    O1W)  echo "$_BASE_ENV XKERNEL_MODEL_GUIDED=1 XKERNEL_MODEL_ANGLES=1 XKERNEL_STRUCTURE_READOUT=1 XKERNEL_SPARSE_ANGLES=1 XKERNEL_IR_READOUT=0 XKERNEL_FABRIC_HOOKS=1";;   # O1 + wafer-level mapping hook and per-PE readout (2026-09-30)
    O1B)  echo "$_BASE_ENV XKERNEL_MODEL_GUIDED=1 XKERNEL_MODEL_ANGLES=1 XKERNEL_STRUCTURE_READOUT=1 XKERNEL_SPARSE_ANGLES=1 XKERNEL_IR_READOUT=0 XKERNEL_SPARSE_BLOCKS=1";;   # O1 + verified building blocks (2026-10-03)
    O1B2) echo "$_BASE_ENV XKERNEL_MODEL_GUIDED=1 XKERNEL_MODEL_ANGLES=1 XKERNEL_STRUCTURE_READOUT=1 XKERNEL_SPARSE_ANGLES=1 XKERNEL_IR_READOUT=0 XKERNEL_SPARSE_BLOCKS=2";;   # O1 + verified building blocks, version 2 (2026-10-03)
    O1B3) echo "$_BASE_ENV XKERNEL_MODEL_GUIDED=1 XKERNEL_MODEL_ANGLES=1 XKERNEL_STRUCTURE_READOUT=1 XKERNEL_SPARSE_ANGLES=1 XKERNEL_IR_READOUT=0 XKERNEL_SPARSE_BLOCKS=3 XKERNEL_SPARSE_ANGLES_EXTRA=dense_tile_format,block_sparse_format";;   # O1 + format blocks, version 3 (2026-10-04)
    O1nS) echo "$_BASE_ENV XKERNEL_MODEL_GUIDED=1 XKERNEL_MODEL_ANGLES=1 XKERNEL_STRUCTURE_READOUT=0 XKERNEL_SPARSE_ANGLES=1 XKERNEL_IR_READOUT=0";;   # structure ablation
    O1nA) echo "$_BASE_ENV XKERNEL_MODEL_GUIDED=1 XKERNEL_MODEL_ANGLES=1 XKERNEL_STRUCTURE_READOUT=1 XKERNEL_SPARSE_ANGLES=0 XKERNEL_IR_READOUT=0";;   # sparse-angle ablation
    O1A)  echo "$_BASE_ENV XKERNEL_MODEL_GUIDED=0 XKERNEL_MODEL_ANGLES=1";;   # v1 ablation: new angles, old selector
    O1S)  echo "$_BASE_ENV XKERNEL_MODEL_GUIDED=1 XKERNEL_MODEL_ANGLES=0";;   # v1 ablation: old catalogue, model selector
    *) echo "unknown arm $1" >&2; exit 2;;
  esac
}

for name in "${KERNELS[@]}"; do
  meta="$FC_ROOT/$name/meta.json"
  if [ ! -f "$meta" ]; then echo "SKIP $name: no first-correct program" | tee -a "$LOG"; continue; fi
  rel=$(python3 -c "import json,sys; print(json.load(open(sys.argv[1])).get('target_relpath') or 'pe.csl')" "$meta")
  FC="$FC_ROOT/$name/$rel"
  fc_cycles=$(python3 -c "import json,sys; print(json.load(open(sys.argv[1])).get('fc_cycles_send'))" "$meta")
  echo "==== $name (first-correct ${fc_cycles} cycles) ====" | tee -a "$LOG"
  for seed in $(seq "$SEED_FROM" "$N_SEEDS"); do
    # interleave arm order per seed so time-of-day effects do not align with one arm
    if [ $((seed % 2)) -eq 1 ]; then order=("${ARM_LIST[@]}"); else order=(); for ((i=${#ARM_LIST[@]}-1;i>=0;i--)); do order+=("${ARM_LIST[$i]}"); done; fi
    for arm in "${order[@]}"; do
      OUT="$ROOT/$name/$arm/seed_$seed"
      if ls "$OUT"/run_*/"$name"/optimization_summary.json >/dev/null 2>&1; then
        echo "  [$name] $arm seed=$seed already done" | tee -a "$LOG"; continue
      fi
      mkdir -p "$OUT"
      echo "  [$name] $arm seed=$seed start $(date -u +%H:%M:%S)" | tee -a "$LOG"
      env $(_arm_env "$arm") timeout "$RUN_TIMEOUT" bash "$LAUNCHER" --kernel "$name" \
        --optimize-only --csl-path "$FC" --profile-feedback \
        ${SIZE_NAME:+--size "$SIZE_NAME"} \
        --min-optimize-attempts "$MIN_OPT" --max-optimize-attempts "$MAX_OPT" \
        --output "$OUT" >>"$OUT/run.log" 2>&1
      rc=$?
      echo "  [$name] $arm seed=$seed exit=$rc $(date -u +%H:%M:%S)" | tee -a "$LOG"
      _cleanup
    done
  done
done
echo "MODEL_GUIDED_AB_DONE $(date -u +%FT%TZ)" | tee -a "$VERDICT"
"$XKERNEL_MICROMAMBA" run -n "$XKERNEL_ENV" python "$XKERNEL_ROOT/code_translation/aggregate_model_guided.py" "$ROOT" --fc "$FC_ROOT" | tee -a "$VERDICT"
