#!/usr/bin/env bash
# Supplemental full-benchmark sweep for the 4 extra OSS models (previously 12-kernel probe only).
# Runs the REMAINING 16 kernels from the 28-kernel suite (skips the 12 already done in probe).
# Also runs all 18 new enrichment kernels (14 single-PE + 4 multi-PE).
# Models: Mistral-Large-3 675B, Llama-4-Maverick, gpt-oss-20b, Gemma-4-E4B.
set -u

LAUNCHER="$HOME/xkernel/run_cuda2csl_alcf.sh"
CAP=40
TS=$(date -u +%Y%m%d_%H%M%S)
ROOT="$HOME/xkernel/code_translation/results/alcf_oss_supplement_${TS}"
mkdir -p "$ROOT"

export ALCF_AUTH_ENV=globus_env

export XKERNEL_DRY_CHECK=1
export XKERNEL_ERROR_GOTCHA=1
export XKERNEL_HARD_KERNEL_HINTS=1
export XKERNEL_SPLICE_FROZEN=1
export XKERNEL_BEST_OF_N=3
export XKERNEL_DEBUGGER=1
export XKERNEL_DEBUGGER_V2=1
export XKERNEL_LIB_BEHAVIORAL=1
export XKERNEL_LAYER_CLEARANCE=1

export OMP_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
export MKL_NUM_THREADS=1

# The 16 kernels from the 28-set NOT in the 12-kernel probe
KERNELS_REMAINING_28=(
  "7pt-Stencil|2129|test"
  "Cholesky|12476|test"
  "GEMV-Checkerboard|197|test"
  "Histogram-1PE|6191|test"
  "Jacobi-2D-5pt|1566|test"
  "PDFT-Pi-Pipeline|128308|test"
  "Single-Tile-Matvec|780|test"
  "SpMV-CSR|6927|test"
  "Tensor-Transpose-021|6183|test"
  "Wide-Multiplication|81741|test"
  "GEMM|51753|train"
  "GEMV|4007|train"
  "GEMM-Collectives-2D|51738|train"
  "GEMV-Collectives-2D|4003|train"
  "BiCGSTAB|59385|train"
  "Power-Method|43436|train"
  "Preconditioned-CG|13826|train"
)

# 14 new single-PE enrichment kernels
KERNELS_NEW_SINGLE=(
  "ReLU-1PE|11787|test"
  "Sigmoid-1PE|107546|test"
  "GELU-1PE|111134|test"
  "SiLU-1PE|104473|test"
  "Softmax-1PE|35681|test"
  "Sum-Reduction-1PE|7693|test"
  "Max-Reduction-1PE|8188|test"
  "Dot-Product-1PE|10254|test"
  "SAXPY-1PE|11276|test"
  "Prefix-Sum-1PE|9229|test"
  "RMSNorm-1PE|10947|test"
  "L2-Norm-1PE|18112|test"
  "MSE-Loss-1PE|11282|test"
  "Cross-Entropy-Loss-1PE|29283|test"
)

# 4 new multi-PE enrichment kernels
KERNELS_NEW_MULTI=(
  "ParReduce-Sum|1990|test"
  "ParBroadcast-Scale|2322|test"
  "ParDot-Product|2631|test"
  "RowParallel-Softmax|17714|test"
)

ALL_KERNELS=("${KERNELS_REMAINING_28[@]}" "${KERNELS_NEW_SINGLE[@]}" "${KERNELS_NEW_MULTI[@]}")

_passed() { local bj; bj=$(ls -t "$1"/run_*/*/benchmark.json 2>/dev/null | head -1); [ -n "$bj" ] && python3 -c "import json,sys;sys.exit(0 if json.load(open('$bj')).get('status')=='pass' else 1)" 2>/dev/null; }
_cyc() { local bj; bj=$(ls -t "$1"/run_*/*/benchmark.json 2>/dev/null | head -1); [ -n "$bj" ] && python3 -c "import json;print(json.load(open('$bj')).get('cycles_send') or '-')" 2>/dev/null || echo "-"; }

run_model() {
  local model="$1" endpoint="$2" short="$3"
  export ALCF_INFERENCE_ENDPOINT="$endpoint"
  MODEL_DIR="$ROOT/$short"
  VERDICT="$MODEL_DIR/VERDICT.txt"
  mkdir -p "$MODEL_DIR"
  echo "=== MODEL: $model ($short) endpoint=$endpoint ===" | tee "$VERDICT"
  echo "Started: $(date -u)" | tee -a "$VERDICT"

  for entry in "${ALL_KERNELS[@]}"; do
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

    pkill -u "$(whoami)" -f "squashfuse_ll" 2>/dev/null || true
    sleep 1
  done

  echo "Finished: $(date -u)" | tee -a "$VERDICT"
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
}

# 1. Mistral-Large-3 675B (Metis) — 0/12 on probe, testing full suite
run_model "Mistral-Large-3-675B-Instruct-2512" "metis" "Mistral-Large-3-675B"

# 2. Llama-4-Maverick (Metis) — 0/12 on probe
run_model "Llama-4-Maverick-17B-128E-Instruct" "metis" "Llama-4-Maverick"

# 3. gpt-oss-20b (Sophia) — 1/12 on probe (GEMV-RowPart)
run_model "openai/gpt-oss-20b" "sophia" "gpt-oss-20b"

# 4. Gemma-4-E4B (Sophia) — 0/12 on probe
run_model "google/gemma-4-E4B-it" "sophia" "gemma-4-E4B"

echo "ALCF_OSS_SUPPLEMENT_DONE"
