#!/usr/bin/env bash
# Enrichment kernel sweep for Claude models: Opus 4.6, Sonnet 4.6, Opus 4.8.
# Runs 18 new kernels (14 single-PE + 4 multi-PE) on all three Claude tiers.
# Single-draw (no profiler A/B), cap=20, consistent with original cross-model eval.
set -u

LAUNCHER="$HOME/xkernel/run_cuda2csl_argo.sh"
CAP=20
TS=$(date -u +%Y%m%d_%H%M%S)
ROOT="$HOME/xkernel/code_translation/results/claude_enrichment_${TS}"
mkdir -p "$ROOT"

export XKERNEL_DRY_CHECK=1
export XKERNEL_ERROR_GOTCHA=1
export XKERNEL_HARD_KERNEL_HINTS=1
export XKERNEL_SPLICE_FROZEN=1
export XKERNEL_LIB_BEHAVIORAL=1
export XKERNEL_LAYER_CLEARANCE=1

export OMP_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
export MKL_NUM_THREADS=1

CLAUDE_MODELS=(
  "claude-opus-4-6"
  "claude-sonnet-4-6"
  "claude-opus-4-8"
)

KERNELS=(
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
  "ParReduce-Sum|1990|test"
  "ParBroadcast-Scale|2322|test"
  "ParDot-Product|2631|test"
  "RowParallel-Softmax|17714|test"
)

_passed() { local bj; bj=$(ls -t "$1"/run_*/*/benchmark.json 2>/dev/null | head -1); [ -n "$bj" ] && python3 -c "import json,sys;sys.exit(0 if json.load(open('$bj')).get('status')=='pass' else 1)" 2>/dev/null; }
_cyc() { local bj; bj=$(ls -t "$1"/run_*/*/benchmark.json 2>/dev/null | head -1); [ -n "$bj" ] && python3 -c "import json;print(json.load(open('$bj')).get('cycles_send') or '-')" 2>/dev/null || echo "-"; }

for model in "${CLAUDE_MODELS[@]}"; do
  MODEL_SHORT="$model"
  export ARGO_MODEL="$model"
  MODEL_DIR="$ROOT/$MODEL_SHORT"
  VERDICT="$MODEL_DIR/VERDICT.txt"
  mkdir -p "$MODEL_DIR"
  echo "=== MODEL: $model ===" | tee "$VERDICT"
  echo "Started: $(date -u)" | tee -a "$VERDICT"

  for entry in "${KERNELS[@]}"; do
    IFS='|' read -r name ref split <<< "$entry"
    OUT="$MODEL_DIR/$name"; mkdir -p "$OUT"
    echo "  [$split] $name (ref=$ref)" | tee -a "$MODEL_DIR/sweep.log"

    bash "$LAUNCHER" --kernel "$name" --output "$OUT" \
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
done

echo "CLAUDE_ENRICHMENT_DONE"
