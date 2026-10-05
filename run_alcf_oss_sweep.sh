#!/usr/bin/env bash
# Open-source model sweep via ALCF Sophia endpoint.
# Tests 3 top open-source models against all scoreable kernels.
# Auth: Globus token refreshed per kernel via --api-key-command.
#
# Usage: bash run_alcf_oss_sweep.sh
# Prerequisite: run `micromamba run -n globus_env python inference_auth_token.py authenticate --force`
set -u

LAUNCHER="$HOME/xkernel/run_cuda2csl_alcf.sh"
CAP=40
TS=$(date -u +%Y%m%d_%H%M%S)
ROOT="$HOME/xkernel/code_translation/results/alcf_oss_sweep_${TS}"
mkdir -p "$ROOT"

# Use globus_env for auth (xkernel-agent has glibc issues with cryptography)
export ALCF_AUTH_ENV=globus_env
export ALCF_INFERENCE_ENDPOINT=sophia

# All improvements ON
export XKERNEL_DRY_CHECK=1
export XKERNEL_ERROR_GOTCHA=1
export XKERNEL_HARD_KERNEL_HINTS=1
export XKERNEL_SPLICE_FROZEN=1
export XKERNEL_BEST_OF_N=3
export XKERNEL_DEBUGGER=1
export XKERNEL_DEBUGGER_V2=1
export XKERNEL_LIB_BEHAVIORAL=1
export XKERNEL_LAYER_CLEARANCE=1

# Models to sweep (confirmed live on ALCF Sophia)
MODELS=(
  "meta-llama/Meta-Llama-3.1-70B-Instruct"
  "google/gemma-4-31B-it"
  "meta-llama/Llama-3.3-70B-Instruct"
  "openai/gpt-oss-120b"
)

# Subset of kernels — focus on the most informative mix:
# - 5 historically robust test-split (should pass with any decent model)
# - 3 previously-failing test-split (CG/Laplacian/GoL — tests our improvements)
# - 2 new v2 kernels (Histogram-Inline/GEMV-RowPart — no info starvation)
# - 2 hard kernels (FFT/Histogram — tests capability frontiers)
KERNELS=(
  # Robust test-split (baseline check)
  "DFT-1PE|145233|test"
  "Mandelbrot|41023|test"
  "Wide-Multiplication|81741|test"
  "Residual|674|test"
  "Stencil7pt-1PE|40497|test"
  # Previously-failing (improvement validation)
  "Laplacian2D-Halo|1709|test"
  "Game-of-Life|7838|test"
  "CG|11635|train"
  # New v2 (no info starvation)
  "Histogram-Inline|1967|test"
  "GEMV-RowPart|711|test"
  # Hard (capability frontier)
  "FFT-1D-2D|422|test"
  "Histogram|-|test"
)

_passed() { local bj; bj=$(ls -t "$1"/run_*/*/benchmark.json 2>/dev/null | head -1); [ -n "$bj" ] && python3 -c "import json,sys;sys.exit(0 if json.load(open('$bj')).get('status')=='pass' else 1)" 2>/dev/null; }
_cyc() { local bj; bj=$(ls -t "$1"/run_*/*/benchmark.json 2>/dev/null | head -1); [ -n "$bj" ] && python3 -c "import json;print(json.load(open('$bj')).get('cycles_send') or '-')" 2>/dev/null || echo "-"; }

for model in "${MODELS[@]}"; do
  MODEL_SHORT=$(echo "$model" | sed 's|.*/||; s|-Instruct.*||; s|-2512||')
  MODEL_DIR="$ROOT/$MODEL_SHORT"
  VERDICT="$MODEL_DIR/VERDICT.txt"
  mkdir -p "$MODEL_DIR"
  echo "=== MODEL: $model ($MODEL_SHORT) ===" | tee "$VERDICT"
  echo "Started: $(date -u)" | tee -a "$VERDICT"

  for entry in "${KERNELS[@]}"; do
    IFS='|' read -r name ref split <<< "$entry"
    OUT="$MODEL_DIR/$name"; mkdir -p "$OUT"
    echo "  [$split] $name (ref=$ref)" | tee -a "$MODEL_DIR/sweep.log"

    EXTRA_ENV=""
    if [ "$name" = "Cholesky" ]; then
      EXTRA_ENV="XKERNEL_CODESIGN_LAYOUT=1 XKERNEL_FORCE_RESPIN_CAP=4"
    fi

    env $EXTRA_ENV bash "$LAUNCHER" --kernel "$name" --output "$OUT" \
      --model "$model" \
      --auto-optimize --reviewer-max-attempts "$CAP" \
      --max-optimize-attempts "$CAP" --min-optimize-attempts 4 \
      >>"$OUT/run.log" 2>&1 || true

    if _passed "$OUT"; then
      cyc=$(_cyc "$OUT")
      speedup="-"
      if [ "$ref" != "-" ] && [ "$cyc" != "-" ]; then
        speedup=$(python3 -c "print(f'{$ref/$cyc:.2f}x')" 2>/dev/null || echo "-")
      fi
      echo "  RESULT [$split] $name: PASS agent=$cyc ref=$ref vs_ref=$speedup" | tee -a "$VERDICT"
    else
      echo "  RESULT [$split] $name: FAIL ref=$ref" | tee -a "$VERDICT"
    fi
  done

  echo "Finished: $(date -u)" | tee -a "$VERDICT"

  # Per-model summary
  python3 - "$VERDICT" <<'PY' | tee -a "$VERDICT"
import sys, collections
rows=[l.split() for l in open(sys.argv[1]) if l.strip().startswith("RESULT")]
agg=collections.Counter(); beats=[]
for r in rows:
    split=r[1].strip("[]"); ok="PASS" in r
    agg[(split,"pass" if ok else "fail")]+=1
    if ok and "vs_ref=" in " ".join(r):
        vr=[x for x in r if x.startswith("vs_ref=")]
        if vr:
            v=vr[0].split("=")[1]
            try:
                if v.endswith("x") and float(v[:-1])>1.0:
                    beats.append((r[2].rstrip(":"), v))
            except: pass
print(f"\n--- {sys.argv[1].split('/')[-2]} summary ---")
for split in ("test","train"):
    p=agg[(split,"pass")]; f=agg[(split,"fail")]
    if p+f>0: print(f"  {split}: {p} pass / {p+f} total")
if beats:
    print(f"  beats-expert:")
    for n,v in sorted(beats): print(f"    {n}: {v}")
PY
  echo ""
done

echo "ALCF_OSS_SWEEP_DONE" | tee -a "$ROOT/DONE.txt"
