#!/usr/bin/env bash
# Hybrid sweep: Sonnet 4.6 first, promote to Opus 4.7 only for clusters where
# Opus has demonstrated empirical advantage. Halo-recv kernels are gated OFF
# from Opus promotion (Opus = strictly worse on 7/7 in prior runs).
#
# Usage: run_hybrid_sweep.sh --kernel <name> [--kernel <name> ...]
set -u

SONNET_MODEL="claude-sonnet-4-6"
OPUS_MODEL="claude-opus-4-7"
REVIEWER_MAX_ATTEMPTS=8
LAUNCHER="$HOME/xkernel/run_cuda2csl_argo.sh"

# Clusters where Opus is allowed to retry after a Sonnet failure.
PROMOTION_CLUSTERS=("collectives_2d" "dsr_queue_fabric_init")

# Kernel -> cluster mapping (hard-coded from cross-model A/B analysis).
_cluster_for() {
    case "$1" in
        GEMV|GEMM|GEMV-Collectives-2D|GEMM-Collectives-2D)
            echo "collectives_2d" ;;
        LorenzoPredictor-Tile|Cholesky|Laplacian2D-Halo|Laplacian2D-Reduce|Game-of-Life|Residual|GEMV-Checkerboard)
            echo "halo_recv_unblock" ;;
        7pt-Stencil|Mandelbrot|FFT-1D-2D)
            echo "dsr_queue_fabric_init" ;;
        Single-Tile-Matvec)
            echo "none" ;;
        *)
            echo "unknown" ;;
    esac
}

_is_promotable_cluster() {
    local c="$1"
    for p in "${PROMOTION_CLUSTERS[@]}"; do
        [ "$c" = "$p" ] && return 0
    done
    return 1
}

_check_passed() {
    # Argument: path to a model output dir (e.g. .../sonnet). The launcher
    # writes its real output under <dir>/run_<timestamp>/<kernel>/, NOT under
    # <dir>/<kernel>/. We resolve the actual benchmark.json via a glob, taking
    # the most recently modified one if multiple runs exist.
    #
    # Two bugs previously bit this helper:
    # (a) compared $SDIR/$K/benchmark.json (wrong path); fixed 2026-06-03.
    # (b) used `grep -q '"status": "pass"'` which matched INNER per-step
    #     transcript entries whose individual "status": "pass" lines exist
    #     even when the top-level kernel status is "fail". Fixed 2026-06-14
    #     by parsing JSON with python and checking only the top-level
    #     "status" field.
    local model_dir="$1"
    local kernel="$2"
    local bj
    # ls -t sorts by mtime descending so the first match is newest.
    bj=$(ls -t "$model_dir"/run_*/"$kernel"/benchmark.json 2>/dev/null | head -1)
    [ -n "$bj" ] && [ -f "$bj" ] || return 1
    python3 -c "
import json, sys
try:
    with open(sys.argv[1]) as f:
        d = json.load(f)
    sys.exit(0 if d.get('status') == 'pass' else 1)
except Exception:
    sys.exit(2)
" "$bj"
}

_run_dir_for() {
    # Echo the newest run_*/<kernel>/ subdir under model_dir, or empty.
    local model_dir="$1"
    local kernel="$2"
    ls -td "$model_dir"/run_*/"$kernel"/ 2>/dev/null | head -1
}

_count_attempts() {
    # Best-effort attempt count from translation_log.json (falls back to "?").
    local model_dir="$1"
    local kernel="$2"
    local rd
    rd=$(_run_dir_for "$model_dir" "$kernel")
    [ -n "$rd" ] || { echo "?"; return; }
    local tl="$rd/translation_log.json"
    if [ -f "$tl" ]; then
        python3 -c "import json
try:
    d=json.load(open('$tl'))
    n=len(d.get('attempts') or d.get('rounds') or d.get('reviews') or [])
    print(n if n else '?')
except Exception:
    print('?')" 2>/dev/null || echo "?"
    else
        echo "?"
    fi
}

usage() {
    cat <<EOF >&2
Usage: $0 --kernel <name> [--kernel <name> ...]

Runs each kernel through Sonnet 4.6 first; on failure, promotes to Opus 4.7
only when the kernel belongs to one of: ${PROMOTION_CLUSTERS[*]}.
Halo-recv kernels are skipped from Opus promotion by design.
EOF
    exit 2
}

# Parse args.
KERNELS=()
while [ $# -gt 0 ]; do
    case "$1" in
        --kernel) KERNELS+=("$2"); shift 2 ;;
        -h|--help) usage ;;
        *) echo "Unknown arg: $1" >&2; usage ;;
    esac
done
[ ${#KERNELS[@]} -gt 0 ] || usage

TS=$(date -u +%Y%m%d_%H%M%S)
SWEEP_ROOT="$HOME/xkernel/code_translation/results/hybrid_sweep_${TS}"
mkdir -p "$SWEEP_ROOT"
echo "Hybrid sweep root: $SWEEP_ROOT"

declare -A VERDICT
declare -A WINNER
declare -A SONNET_ATT
declare -A OPUS_ATT
declare -A KCLUSTER

for K in "${KERNELS[@]}"; do
    CLUSTER=$(_cluster_for "$K")
    KCLUSTER["$K"]="$CLUSTER"
    KROOT="$SWEEP_ROOT/$K"
    SDIR="$KROOT/sonnet"
    ODIR="$KROOT/opus"
    mkdir -p "$SDIR" "$ODIR"

    echo "==== [$K] Sonnet 4.6 (cluster=$CLUSTER) ====" | tee "$KROOT/run.log"
    ARGO_MODEL="$SONNET_MODEL" bash "$LAUNCHER" \
        --kernel "$K" --output "$SDIR" \
        --auto-optimize --reviewer-max-attempts "$REVIEWER_MAX_ATTEMPTS" \
        >>"$KROOT/run.log" 2>&1 || true

    SONNET_ATT["$K"]=$(_count_attempts "$SDIR" "$K")

    if _check_passed "$SDIR" "$K"; then
        VERDICT["$K"]="pass"
        WINNER["$K"]="sonnet"
        OPUS_ATT["$K"]="-"
        SRUN=$(_run_dir_for "$SDIR" "$K")
        [ -n "$SRUN" ] && cp -f "$SRUN/pe.csl" "$KROOT/pe.csl" 2>/dev/null || true
        continue
    fi

    if _is_promotable_cluster "$CLUSTER"; then
        echo "==== [$K] Sonnet failed, promoting to Opus 4.7 ====" | tee -a "$KROOT/run.log"
        ARGO_MODEL="$OPUS_MODEL" bash "$LAUNCHER" \
            --kernel "$K" --output "$ODIR" \
            --auto-optimize --reviewer-max-attempts "$REVIEWER_MAX_ATTEMPTS" \
            >>"$KROOT/run.log" 2>&1 || true
        OPUS_ATT["$K"]=$(_count_attempts "$ODIR" "$K")
        if _check_passed "$ODIR" "$K"; then
            VERDICT["$K"]="pass"
            WINNER["$K"]="opus"
            ORUN=$(_run_dir_for "$ODIR" "$K")
            [ -n "$ORUN" ] && cp -f "$ORUN/pe.csl" "$KROOT/pe.csl" 2>/dev/null || true
            continue
        fi
        VERDICT["$K"]="fail"
        WINNER["$K"]="-"
    else
        VERDICT["$K"]="fail"
        WINNER["$K"]="-"
        OPUS_ATT["$K"]="skip"
        echo "==== [$K] Sonnet failed, cluster=$CLUSTER not promotable, skipping Opus ====" | tee -a "$KROOT/run.log"
    fi
done

# Final summary.
echo
echo "================ HYBRID SWEEP SUMMARY ================"
PASS=0; FAIL=0
for K in "${KERNELS[@]}"; do
    V=${VERDICT[$K]}
    W=${WINNER[$K]}
    SA=${SONNET_ATT[$K]}
    OA=${OPUS_ATT[$K]}
    C=${KCLUSTER[$K]}
    if [ "$V" = "pass" ]; then
        echo "$K: $W in $([ "$W" = "sonnet" ] && echo "$SA" || echo "$OA") attempts (cluster: $C)"
        PASS=$((PASS+1))
    else
        echo "$K: FAIL (sonnet:$SA, opus:$OA, cluster: $C)"
        FAIL=$((FAIL+1))
    fi
done
TOTAL=${#KERNELS[@]}
echo "------------------------------------------------------"
echo "Union pass rate: $PASS/$TOTAL  (fail: $FAIL)"
echo "Sweep root:      $SWEEP_ROOT"
echo "======================================================"
