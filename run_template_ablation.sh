#!/usr/bin/env bash
# 2-arm template ablation: (template OFF) vs (template ON + full IR stack).
#
# Two arms:
#   A  no-template  : full production harness, cap=10, XKERNEL_TEMPLATE_GEN=0
#                     (identical to Cell B from the IR ablation -- reuse if available)
#   B  template     : full production harness, cap=10, XKERNEL_TEMPLATE_GEN=1
#                     plus XKERNEL_DESIGN_SCHEMA=1 XKERNEL_WIRING_PLAN=1
#                     XKERNEL_TRANSLATION_FACTS=1 (full IR stack, since templates
#                     build on it)
#
# 8 kernels x 5 seeds, Opus 4.8 via Argo.
#
# Usage:
#   bash run_template_ablation.sh           # run both arms
#   bash run_template_ablation.sh A         # run only arm A
#   bash run_template_ablation.sh B         # run only arm B
set -u

LAUNCHER="$HOME/xkernel/run_cuda2csl_argo.sh"
N_SEEDS=5
SEEDS=(101 202 303 404 505)
TS=$(date -u +%Y%m%d_%H%M%S)
ROOT="$HOME/xkernel/code_translation/results/template_ablation_${TS}"
mkdir -p "$ROOT"

export ARGO_MODEL="claude-opus-4-8"
export OMP_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
export MKL_NUM_THREADS=1

# ---------- kernels: name|ref_cycles|split ----------
KERNELS=(
  "ReLU-1PE|11787|test"
  "SAXPY-1PE|11276|test"
  "Histogram-1PE|6191|test"
  "GEMV|4007|train"
  "Laplacian2D-Halo|1709|test"
  "Wide-Multiplication|81741|test"
  "Game-of-Life|7838|test"
  "PDFT-Pi-Pipeline|128308|test"
)

# ---------- helpers ----------
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

_failure_reason() {
  local bj
  bj=$(ls -t "$1"/run_*/*/benchmark.json 2>/dev/null | head -1)
  [ -n "$bj" ] && python3 -c "import json; print(json.load(open('$bj')).get('failure_reason') or 'unknown')" 2>/dev/null || echo "no_benchmark"
}

# ---------- per-arm summary ----------
_summarize_arm() {
  local verdict_file="$1"
  local arm_label="$2"
  python3 - "$verdict_file" "$arm_label" <<'PY' | tee -a "$verdict_file"
import sys, re
rows = [l for l in open(sys.argv[1]) if l.startswith("RESULT")]
label = sys.argv[2]
total_pass, total_runs = 0, 0
robust, fragile, fail = [], [], []
for r in rows:
    m = re.search(r'(\S+): (\d)/(\d) pass', r)
    if not m:
        continue
    name = m.group(1).rstrip(":")
    p, n = int(m.group(2)), int(m.group(3))
    total_pass += p
    total_runs += n
    if p == n:
        robust.append(name)
    elif p > 0:
        fragile.append(f"{name} ({p}/{n})")
    else:
        fail.append(name)
print(f"\n=== ARM {label} SUMMARY ===")
print(f"  Overall: {total_pass}/{total_runs} pass")
print(f"  Robust  ({len(robust)}): {', '.join(robust) or '(none)'}")
print(f"  Fragile ({len(fragile)}): {', '.join(fragile) or '(none)'}")
print(f"  Fail    ({len(fail)}): {', '.join(fail) or '(none)'}")
PY
}

# ---------- arm environment setters ----------
_env_harness_gates() {
  # Standard production gates (same as Cell B in the IR ablation)
  export XKERNEL_DRY_CHECK=1
  export XKERNEL_ERROR_GOTCHA=1
  export XKERNEL_HARD_KERNEL_HINTS=1
  export XKERNEL_SPLICE_FROZEN=1
  export XKERNEL_LIB_BEHAVIORAL=1
  export XKERNEL_LAYER_CLEARANCE=1
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
}

# ================================================================
# Arm A: no-template (full harness, IR OFF, template OFF)
#   Identical to Cell B from the IR ablation -- reuse if available.
# ================================================================
_check_reuse_cell_b() {
  # Look for existing Cell B results from the IR ablation.
  # Validate that all 8 kernels x 5 seeds have a VERDICT.txt entry.
  local reuse_dir=""
  for d in "$HOME"/xkernel/code_translation/results/ir_ablation_2x2_*/B_harness_only; do
    [ -d "$d" ] || continue
    local vf="$d/VERDICT.txt"
    [ -f "$vf" ] || continue
    # Check that every kernel has a RESULT line
    local found_all=true
    for entry in "${KERNELS[@]}"; do
      IFS='|' read -r name ref split <<< "$entry"
      if ! grep -q "^RESULT .*${name}:" "$vf" 2>/dev/null; then
        found_all=false
        break
      fi
    done
    if $found_all; then
      reuse_dir="$d"
      # Prefer the most recent (last in glob order)
    fi
  done
  echo "$reuse_dir"
}

run_arm_A() {
  local ARM="A_no_template"
  local ARM_ROOT="$ROOT/$ARM"
  local ARM_VERDICT="$ARM_ROOT/VERDICT.txt"

  # Check for reusable Cell B results
  local reuse_dir
  reuse_dir=$(_check_reuse_cell_b)

  if [ -n "$reuse_dir" ]; then
    echo "Reusing Cell B results from: $reuse_dir" | tee -a "$ROOT/EXPERIMENT.txt"
    # Symlink the entire arm directory
    ln -sfn "$reuse_dir" "$ARM_ROOT"
    # Copy VERDICT.txt so it appears under our root with the right header
    if [ -f "$ARM_ROOT/VERDICT.txt" ]; then
      echo "ARM A (no-template): reused from $reuse_dir" > "$ROOT/A_VERDICT_NOTE.txt"
    fi
    return
  fi

  # Run fresh
  mkdir -p "$ARM_ROOT"
  echo "ARM A (no-template): cap=10, full pipeline, standard gates ON, IR OFF, TEMPLATE_GEN=0  $(date -u)" | tee "$ARM_VERDICT"

  _env_harness_gates
  export XKERNEL_DESIGN_SCHEMA=0
  export XKERNEL_WIRING_PLAN=0
  export XKERNEL_TRANSLATION_FACTS=0
  export XKERNEL_TEMPLATE_GEN=0

  for entry in "${KERNELS[@]}"; do
    IFS='|' read -r name ref split <<< "$entry"
    pass_count=0
    cycles_list=""
    fail_reasons=""

    for seed in "${SEEDS[@]}"; do
      OUT="$ARM_ROOT/${name}/seed_${seed}"; mkdir -p "$OUT"
      echo "  [A] [$split] $name seed=$seed $(date +%H:%M)" | tee -a "$ARM_ROOT/sweep.log"

      SINGULARITYENV_XKERNEL_EVAL_SEED="$seed" \
      APPTAINERENV_XKERNEL_EVAL_SEED="$seed" \
      XKERNEL_EVAL_SEED="$seed" \
      SINGULARITYENV_XKERNEL_TEMPLATE_GEN=0 \
      APPTAINERENV_XKERNEL_TEMPLATE_GEN=0 \
        bash "$LAUNCHER" --kernel "$name" --output "$OUT" \
          --auto-optimize --reviewer-max-attempts 10 \
          --max-optimize-attempts 10 --min-optimize-attempts 4 \
          >>"$OUT/run.log" 2>&1 || true

      if _passed "$OUT"; then
        pass_count=$((pass_count + 1))
        cyc=$(_cyc "$OUT")
        cycles_list="${cycles_list}${cyc},"
      else
        fr=$(_failure_reason "$OUT")
        fail_reasons="${fail_reasons}${fr},"
      fi
      _cleanup
    done

    rate="${pass_count}/${N_SEEDS}"
    if [ $pass_count -gt 0 ]; then
      echo "RESULT [$split] $name: $rate pass  cycles=[$cycles_list] ref=$ref" | tee -a "$ARM_VERDICT"
    else
      echo "RESULT [$split] $name: $rate pass  fail_reasons=[$fail_reasons] ref=$ref" | tee -a "$ARM_VERDICT"
    fi
  done
  echo "ARM_A_DONE" | tee -a "$ARM_VERDICT"

  _summarize_arm "$ARM_VERDICT" "A (no-template)"
}

# ================================================================
# Arm B: template (full harness, IR ON, template ON)
# ================================================================
run_arm_B() {
  local ARM="B_template"
  local ARM_ROOT="$ROOT/$ARM"
  local ARM_VERDICT="$ARM_ROOT/VERDICT.txt"
  mkdir -p "$ARM_ROOT"
  echo "ARM B (template): cap=10, full pipeline, standard gates + IR ON + TEMPLATE_GEN=1  $(date -u)" | tee "$ARM_VERDICT"

  _env_harness_gates
  export XKERNEL_DESIGN_SCHEMA=1
  export XKERNEL_WIRING_PLAN=1
  export XKERNEL_TRANSLATION_FACTS=1
  export XKERNEL_TEMPLATE_GEN=1

  for entry in "${KERNELS[@]}"; do
    IFS='|' read -r name ref split <<< "$entry"
    pass_count=0
    cycles_list=""
    fail_reasons=""

    for seed in "${SEEDS[@]}"; do
      OUT="$ARM_ROOT/${name}/seed_${seed}"; mkdir -p "$OUT"
      echo "  [B] [$split] $name seed=$seed $(date +%H:%M)" | tee -a "$ARM_ROOT/sweep.log"

      SINGULARITYENV_XKERNEL_EVAL_SEED="$seed" \
      APPTAINERENV_XKERNEL_EVAL_SEED="$seed" \
      XKERNEL_EVAL_SEED="$seed" \
      SINGULARITYENV_XKERNEL_TEMPLATE_GEN=1 \
      APPTAINERENV_XKERNEL_TEMPLATE_GEN=1 \
      SINGULARITYENV_XKERNEL_DESIGN_SCHEMA=1 \
      APPTAINERENV_XKERNEL_DESIGN_SCHEMA=1 \
      SINGULARITYENV_XKERNEL_WIRING_PLAN=1 \
      APPTAINERENV_XKERNEL_WIRING_PLAN=1 \
      SINGULARITYENV_XKERNEL_TRANSLATION_FACTS=1 \
      APPTAINERENV_XKERNEL_TRANSLATION_FACTS=1 \
        bash "$LAUNCHER" --kernel "$name" --output "$OUT" \
          --auto-optimize --reviewer-max-attempts 10 \
          --max-optimize-attempts 10 --min-optimize-attempts 4 \
          >>"$OUT/run.log" 2>&1 || true

      if _passed "$OUT"; then
        pass_count=$((pass_count + 1))
        cyc=$(_cyc "$OUT")
        cycles_list="${cycles_list}${cyc},"
      else
        fr=$(_failure_reason "$OUT")
        fail_reasons="${fail_reasons}${fr},"
      fi
      _cleanup
    done

    rate="${pass_count}/${N_SEEDS}"
    if [ $pass_count -gt 0 ]; then
      echo "RESULT [$split] $name: $rate pass  cycles=[$cycles_list] ref=$ref" | tee -a "$ARM_VERDICT"
    else
      echo "RESULT [$split] $name: $rate pass  fail_reasons=[$fail_reasons] ref=$ref" | tee -a "$ARM_VERDICT"
    fi
  done
  echo "ARM_B_DONE" | tee -a "$ARM_VERDICT"

  _summarize_arm "$ARM_VERDICT" "B (template)"
}

# ================================================================
# Main: parse arm selection, default = both
# ================================================================
ARMS_TO_RUN=("$@")
if [ ${#ARMS_TO_RUN[@]} -eq 0 ]; then
  ARMS_TO_RUN=(A B)
fi

echo "TEMPLATE ABLATION: arms=[${ARMS_TO_RUN[*]}] seeds=[${SEEDS[*]}] model=$ARGO_MODEL  $TS" | tee "$ROOT/EXPERIMENT.txt"
echo "Root: $ROOT" | tee -a "$ROOT/EXPERIMENT.txt"

for ARM in "${ARMS_TO_RUN[@]}"; do
  case "$ARM" in
    A) run_arm_A ;;
    B) run_arm_B ;;
    *) echo "Unknown arm: $ARM (valid: A B)" >&2 ;;
  esac
done

# ---------- cross-arm summary ----------
echo ""
echo "========================================"
echo "TEMPLATE ABLATION COMPLETE: $ROOT"
echo "========================================"

python3 - "$ROOT" <<'PY' | tee "$ROOT/SUMMARY.txt"
import sys, re, os

root = sys.argv[1]
arms = {
    "A_no_template": "A (no-template)",
    "B_template":    "B (template)",
}

results = {}  # arm -> {kernel -> (pass_count, n_seeds, cycles_list)}
for arm_dir, arm_label in arms.items():
    vf = os.path.join(root, arm_dir, "VERDICT.txt")
    if not os.path.exists(vf):
        continue
    results[arm_label] = {}
    for line in open(vf):
        m = re.match(r"RESULT \[(\w+)\] (\S+): (\d)/(\d) pass", line)
        if not m:
            continue
        split, name, p, n = m.group(1), m.group(2).rstrip(":"), int(m.group(3)), int(m.group(4))
        cm = re.search(r"cycles=\[([^\]]*)\]", line)
        cyc_str = cm.group(1) if cm else ""
        cyc_list = [int(x) for x in cyc_str.strip(",").split(",") if x.strip() not in ("", "-")]
        results[arm_label][name] = (p, n, cyc_list)

if not results:
    print("No results found yet.")
    sys.exit(0)

# Collect all kernel names in order
all_kernels = []
for arm_data in results.values():
    for k in arm_data:
        if k not in all_kernels:
            all_kernels.append(k)

print("\n=== TEMPLATE ABLATION SUMMARY ===\n")

# Pass-rate table
arm_labels = sorted(results.keys())
header = f"{'Kernel':<25s}"
for al in arm_labels:
    header += f"  {al:>18s}"
print(header)
print("-" * len(header))

arm_totals = {al: [0, 0] for al in arm_labels}
for k in all_kernels:
    row = f"{k:<25s}"
    for al in arm_labels:
        if k in results.get(al, {}):
            p, n, _ = results[al][k]
            row += f"  {f'{p}/{n}':>18s}"
            arm_totals[al][0] += p
            arm_totals[al][1] += n
        else:
            row += f"  {'---':>18s}"
    print(row)

print("-" * len(header))
row = f"{'TOTAL':<25s}"
for al in arm_labels:
    p, n = arm_totals[al]
    pct = f"{p}/{n} ({100*p/n:.0f}%)" if n > 0 else "---"
    row += f"  {pct:>18s}"
print(row)

# Delta
if len(arm_labels) == 2:
    a_p, a_n = arm_totals[arm_labels[0]]
    b_p, b_n = arm_totals[arm_labels[1]]
    if a_n > 0 and b_n > 0:
        delta_pp = (b_p / b_n - a_p / a_n) * 100
        print(f"\nPass-rate delta (template effect): {delta_pp:+.1f}pp")

# Per-kernel comparison
if len(arm_labels) == 2:
    print("\n--- Per-Kernel Delta ---")
    for k in all_kernels:
        a_data = results.get(arm_labels[0], {}).get(k, (0, 5, []))
        b_data = results.get(arm_labels[1], {}).get(k, (0, 5, []))
        a_p, a_n = a_data[0], a_data[1]
        b_p, b_n = b_data[0], b_data[1]
        delta = b_p - a_p
        tag = "TEMPLATE_WINS" if delta > 0 else ("TEMPLATE_LOSES" if delta < 0 else "TIE")
        a_cyc = a_data[2]
        b_cyc = b_data[2]
        cyc_note = ""
        if a_cyc and b_cyc:
            a_best = min(a_cyc)
            b_best = min(b_cyc)
            if b_best < a_best:
                cyc_note = f"  cycles: {a_best}->{b_best} ({(a_best-b_best)/a_best*100:.0f}% reduction)"
            elif a_best < b_best:
                cyc_note = f"  cycles: {a_best}->{b_best} ({(b_best-a_best)/a_best*100:.0f}% increase)"
        print(f"  {k:<25s} {a_p}/{a_n} -> {b_p}/{b_n}  delta={delta:+d}  {tag}{cyc_note}")
PY

echo ""
echo "TEMPLATE_ABLATION_DONE" | tee -a "$ROOT/EXPERIMENT.txt"
