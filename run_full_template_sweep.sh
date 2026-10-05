#!/usr/bin/env bash
# Full 46-kernel template sweep: CUDA->CSL translate+optimize with template-based
# generation enabled (XKERNEL_TEMPLATE_GEN=1 + full IR stack).
#
# Coverage sweep: single draw (1 seed), cap=10, Opus 4.8 via Argo.
# All 28 original + 18 enrichment kernels.
#
# Usage:
#   bash run_full_template_sweep.sh
set -u

LAUNCHER="$HOME/xkernel/run_cuda2csl_argo.sh"
CAP=10
TS=$(date -u +%Y%m%d_%H%M%S)
ROOT="$HOME/xkernel/code_translation/results/full_template_sweep_${TS}"
mkdir -p "$ROOT"
VERDICT="$ROOT/VERDICT.txt"
echo "FULL TEMPLATE SWEEP $TS  cap=$CAP  translate+optimize  model=claude-opus-4-8" | tee "$VERDICT"

# ---------- Model ----------
export ARGO_MODEL="claude-opus-4-8"

# ---------- Threading ----------
export OMP_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
export MKL_NUM_THREADS=1

# ---------- Template generation + full IR stack ----------
export XKERNEL_TEMPLATE_GEN=1
export XKERNEL_DESIGN_SCHEMA=1
export XKERNEL_WIRING_PLAN=1
export XKERNEL_TRANSLATION_FACTS=1

# ---------- Standard production gates ----------
export XKERNEL_DRY_CHECK=1
export XKERNEL_ERROR_GOTCHA=1
export XKERNEL_SPLICE_FROZEN=1
export XKERNEL_LIB_BEHAVIORAL=1
export XKERNEL_LAYER_CLEARANCE=1
export XKERNEL_HARD_KERNEL_HINTS=1
export XKERNEL_LIB_SIGNATURES=1
export XKERNEL_ARCH_MAPPING=1
export XKERNEL_W1_GOTCHAS=1
export XKERNEL_W1_CLUSTER_QUERIES=1
export XKERNEL_MINED_GOTCHAS=1
export XKERNEL_FIXES_C4_C5_C10=1
export XKERNEL_FIXES_20260625=1
export XKERNEL_CODESIGN_EXEMPLAR=1
export XKERNEL_BUILTIN_WHITELIST=1
export XKERNEL_MULTIPE_PROMPT=1
export XKERNEL_DEBUG_TECHNIQUES=1
export XKERNEL_TUTORIALS=1
export XKERNEL_EXPLORED_TUTORIALS=1
export XKERNEL_SKILLS=1
export XKERNEL_MESH_PATTERNS=1
export XKERNEL_EXPLORED_EXPERIENCES=1
export XKERNEL_OPTIMIZER_EXPLORED=1
export XKERNEL_LIB_OVERLAY_NOTE=1
export XKERNEL_SDK_SIG=1
export XKERNEL_HELDOUT_EVAL=1
export XKERNEL_BEST_OF_N=1
export XKERNEL_DEBUGGER=0
export XKERNEL_DEBUGGER_V2=0

# ---------- SINGULARITYENV_ mirrors (cs_python -C strips host env) ----------
export SINGULARITYENV_XKERNEL_TEMPLATE_GEN=1
export SINGULARITYENV_XKERNEL_DESIGN_SCHEMA=1
export SINGULARITYENV_XKERNEL_WIRING_PLAN=1
export SINGULARITYENV_XKERNEL_TRANSLATION_FACTS=1
export SINGULARITYENV_XKERNEL_DRY_CHECK=1
export SINGULARITYENV_XKERNEL_ERROR_GOTCHA=1
export SINGULARITYENV_XKERNEL_SPLICE_FROZEN=1
export SINGULARITYENV_XKERNEL_LIB_BEHAVIORAL=1
export SINGULARITYENV_XKERNEL_LAYER_CLEARANCE=1
export SINGULARITYENV_XKERNEL_HARD_KERNEL_HINTS=1
export SINGULARITYENV_XKERNEL_LIB_SIGNATURES=1
export SINGULARITYENV_XKERNEL_ARCH_MAPPING=1
export SINGULARITYENV_XKERNEL_W1_GOTCHAS=1
export SINGULARITYENV_XKERNEL_W1_CLUSTER_QUERIES=1
export SINGULARITYENV_XKERNEL_MINED_GOTCHAS=1
export SINGULARITYENV_XKERNEL_FIXES_C4_C5_C10=1
export SINGULARITYENV_XKERNEL_FIXES_20260625=1
export SINGULARITYENV_XKERNEL_CODESIGN_EXEMPLAR=1
export SINGULARITYENV_XKERNEL_BUILTIN_WHITELIST=1
export SINGULARITYENV_XKERNEL_MULTIPE_PROMPT=1
export SINGULARITYENV_XKERNEL_DEBUG_TECHNIQUES=1
export SINGULARITYENV_XKERNEL_TUTORIALS=1
export SINGULARITYENV_XKERNEL_EXPLORED_TUTORIALS=1
export SINGULARITYENV_XKERNEL_SKILLS=1
export SINGULARITYENV_XKERNEL_MESH_PATTERNS=1
export SINGULARITYENV_XKERNEL_EXPLORED_EXPERIENCES=1
export SINGULARITYENV_XKERNEL_OPTIMIZER_EXPLORED=1
export SINGULARITYENV_XKERNEL_LIB_OVERLAY_NOTE=1
export SINGULARITYENV_XKERNEL_SDK_SIG=1
export SINGULARITYENV_XKERNEL_HELDOUT_EVAL=1
export SINGULARITYENV_XKERNEL_BEST_OF_N=1
export SINGULARITYENV_XKERNEL_DEBUGGER=0
export SINGULARITYENV_XKERNEL_DEBUGGER_V2=0
# Apptainer aliases (newer runtimes)
export APPTAINERENV_XKERNEL_TEMPLATE_GEN=1
export APPTAINERENV_XKERNEL_DESIGN_SCHEMA=1
export APPTAINERENV_XKERNEL_WIRING_PLAN=1
export APPTAINERENV_XKERNEL_TRANSLATION_FACTS=1

# ---------- All 46 kernels: name|ref_cycles|split ----------
KERNELS=(
  # --- Original 28 ---
  # TEST split (held-out, the beats-expert claim)
  "7pt-Stencil|2129|test"
  "Cholesky|12476|test"
  "DFT-1PE|145233|test"
  "FFT-1D-2D|422|test"
  "GEMV-Checkerboard|197|test"
  "Game-of-Life|7838|test"
  "Histogram-1PE|6191|test"
  "Jacobi-2D-5pt|1566|test"
  "Laplacian2D-Halo|1709|test"
  "Mandelbrot|41023|test"
  "PDFT-Pi-Pipeline|128308|test"
  "Residual|674|test"
  "Single-Tile-Matvec|780|test"
  "SpMV-CSR|6927|test"
  "Stencil7pt-1PE|40497|test"
  "Tensor-Transpose-021|6183|test"
  "Wide-Multiplication|81741|test"
  # Histogram: correctness-only (multi-PE tally lib, no ref cycles)
  "Histogram|-|test"
  # Inline histogram + GEMV-RowPart (v2 enrichment, original suite)
  "Histogram-Inline|1967|test"
  "GEMV-RowPart|711|test"
  # TRAIN split (dev snapshot only; not the held-out claim)
  "GEMM|51753|train"
  "GEMV|4007|train"
  "GEMM-Collectives-2D|51738|train"
  "GEMV-Collectives-2D|4003|train"
  "BiCGSTAB|59385|train"
  "CG|11635|train"
  "Power-Method|43436|train"
  "Preconditioned-CG|13826|train"
  # --- 14 new single-PE enrichment kernels ---
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
  # --- 4 new multi-PE enrichment kernels ---
  "ParReduce-Sum|1990|test"
  "ParBroadcast-Scale|2322|test"
  "ParDot-Product|2631|test"
  "RowParallel-Softmax|17714|test"

  # --- 3 kernels enabled 2026-08-06 (see docs/EXCLUDED_TASKS_AUDIT_20260806.md) ---
  # GEMM-1PE was already fully scoreable and simply never appeared in a sweep
  # list. Laplacian2D-Reduce and LorenzoPredictor-Tile were VERIFY=False
  # skeletons until their halo/reduction routing was fixed and TSC added.
  "GEMM-1PE|119197|test"
  "Laplacian2D-Reduce|1950|test"
  "LorenzoPredictor-Tile|1315|test"
)

# ---------- Helpers ----------
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
  pkill -u "$(whoami)" -f "squashfuse_ll" 2>/dev/null || true
  sleep 1
}

# ---------- Main sweep loop ----------
echo "Started: $(date -u)" | tee -a "$VERDICT"
echo "Root: $ROOT" | tee -a "$VERDICT"
echo "" | tee -a "$VERDICT"

for entry in "${KERNELS[@]}"; do
  IFS='|' read -r name ref split <<< "$entry"
  OUT="$ROOT/$name"; mkdir -p "$OUT"
  echo "==== [$split] $name (ref=$ref) ====" | tee -a "$ROOT/sweep.log"

  # Cholesky special handling: co-design mode + force respin cap
  EXTRA_ENV=""
  EXTRA_SING_ENV=""
  if [ "$name" = "Cholesky" ]; then
    EXTRA_ENV="XKERNEL_CODESIGN_LAYOUT=1 XKERNEL_FORCE_RESPIN_CAP=4"
    EXTRA_SING_ENV="SINGULARITYENV_XKERNEL_CODESIGN_LAYOUT=1 SINGULARITYENV_XKERNEL_FORCE_RESPIN_CAP=4 APPTAINERENV_XKERNEL_CODESIGN_LAYOUT=1 APPTAINERENV_XKERNEL_FORCE_RESPIN_CAP=4"
  fi

  env $EXTRA_ENV $EXTRA_SING_ENV \
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
    echo "RESULT [$split] $name: PASS agent=$cyc ref=$ref vs_ref=$speedup" | tee -a "$VERDICT"
  else
    echo "RESULT [$split] $name: FAIL ref=$ref" | tee -a "$VERDICT"
  fi

  _cleanup
done

echo "" | tee -a "$VERDICT"
echo "Finished: $(date -u)" | tee -a "$VERDICT"
echo "FULL_TEMPLATE_SWEEP_DONE" | tee -a "$VERDICT"

# ---------- Python summary ----------
python3 - "$VERDICT" <<'PY' | tee -a "$VERDICT"
import sys, collections

rows = [l.split() for l in open(sys.argv[1]) if l.startswith("RESULT")]
agg = collections.Counter()
beats = []

for r in rows:
    split = r[1].strip("[]")
    ok = "PASS" in r
    agg[(split, "pass" if ok else "fail")] += 1
    if ok and "vs_ref=" in " ".join(r):
        vr = [x for x in r if x.startswith("vs_ref=")]
        if vr:
            v = vr[0].split("=")[1]
            try:
                if v.endswith("x") and float(v[:-1]) > 1.0:
                    beats.append((r[2].rstrip(":"), v))
            except:
                pass

total_pass = sum(v for (s, o), v in agg.items() if o == "pass")
total_fail = sum(v for (s, o), v in agg.items() if o == "fail")
total = total_pass + total_fail

print("\n=== FULL TEMPLATE SWEEP SUMMARY ===")
print(f"  Total: {total_pass} pass / {total} total ({100*total_pass/total:.0f}%)" if total > 0 else "  Total: 0/0")
for split in ("test", "train"):
    p = agg[(split, "pass")]
    f = agg[(split, "fail")]
    if p + f > 0:
        print(f"  {split}: {p} pass / {p+f} total ({100*p/(p+f):.0f}%)")
print(f"  beats-expert (>1x vs ref):")
for n, v in sorted(beats):
    print(f"    {n}: {v}")
if not beats:
    print(f"    (none)")

# Failure list
fails = []
for r in rows:
    if "FAIL" in r:
        name = r[2].rstrip(":")
        split = r[1].strip("[]")
        fails.append((split, name))
if fails:
    print(f"  failures ({len(fails)}):")
    for s, n in fails:
        print(f"    [{s}] {n}")
PY
