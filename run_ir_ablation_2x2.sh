#!/usr/bin/env bash
# 2x2 factorial IR ablation: (Harness ON/OFF) x (IR ON/OFF), 8 kernels x 5 seeds.
#
# Four cells:
#   A  bare-baseline : no knowledge, no reviewer, cap=1, all XKERNEL_* OFF
#   B  harness-only  : full production pipeline, cap=10, all default gates ON, IR OFF
#   C  ir-only       : same as A but XKERNEL_DESIGN_SCHEMA/WIRING_PLAN/TRANSLATION_FACTS=1
#   D  full-stack    : same as B plus DESIGN_SCHEMA/WIRING_PLAN/TRANSLATION_FACTS=1
#
# Model: Opus 4.8 via Argo.
#
# Usage:
#   bash run_ir_ablation_2x2.sh           # run all 4 cells
#   bash run_ir_ablation_2x2.sh A         # run only cell A
#   bash run_ir_ablation_2x2.sh B D       # run cells B and D
set -u

LAUNCHER="$HOME/xkernel/run_cuda2csl_argo.sh"
N_SEEDS=5
SEEDS=(101 202 303 404 505)
TS=$(date -u +%Y%m%d_%H%M%S)
ROOT="$HOME/xkernel/code_translation/results/ir_ablation_2x2_${TS}"
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

# ---------- cell environment setters ----------
_env_clear_all_gates() {
  # Turn OFF every improvement gate for the bare-baseline cells (A and C)
  export XKERNEL_DRY_CHECK=0
  export XKERNEL_ERROR_GOTCHA=0
  export XKERNEL_HARD_KERNEL_HINTS=0
  export XKERNEL_SPLICE_FROZEN=0
  export XKERNEL_LIB_BEHAVIORAL=0
  export XKERNEL_LAYER_CLEARANCE=0
  export XKERNEL_LIB_SIGNATURES=0
  export XKERNEL_ARCH_MAPPING=0
  export XKERNEL_W1_GOTCHAS=0
  export XKERNEL_W1_CLUSTER_QUERIES=0
  export XKERNEL_MINED_GOTCHAS=0
  export XKERNEL_FIXES_C4_C5_C10=0
  export XKERNEL_FIXES_20260625=0
  export XKERNEL_CODESIGN_EXEMPLAR=0
  export XKERNEL_BUILTIN_WHITELIST=0
  export XKERNEL_MULTIPE_PROMPT=0
  export XKERNEL_DEBUG_TECHNIQUES=0
  export XKERNEL_TUTORIALS=0
  export XKERNEL_EXPLORED_TUTORIALS=0
  export XKERNEL_SKILLS=0
  export XKERNEL_MESH_PATTERNS=0
  export XKERNEL_EXPLORED_EXPERIENCES=0
  export XKERNEL_OPTIMIZER_EXPLORED=0
  export XKERNEL_LIB_OVERLAY_NOTE=0
  export XKERNEL_SDK_SIG=0
  export XKERNEL_HELDOUT_EVAL=0
  export XKERNEL_BEST_OF_N=1
  export XKERNEL_DEBUGGER=0
  export XKERNEL_DEBUGGER_V2=0
  # IR gates OFF explicitly
  export XKERNEL_DESIGN_SCHEMA=0
  export XKERNEL_WIRING_PLAN=0
  export XKERNEL_TRANSLATION_FACTS=0
}

_env_harness_gates() {
  # Standard production gates for harness-on cells (B and D)
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
  # IR gates OFF (will be turned ON separately for cells C/D)
  export XKERNEL_DESIGN_SCHEMA=0
  export XKERNEL_WIRING_PLAN=0
  export XKERNEL_TRANSLATION_FACTS=0
}

_env_ir_on() {
  export XKERNEL_DESIGN_SCHEMA=1
  export XKERNEL_WIRING_PLAN=1
  export XKERNEL_TRANSLATION_FACTS=1
}

# ================================================================
# Cell A: bare-baseline (no harness, no IR)
# ================================================================
run_cell_A() {
  local CELL="A_bare_baseline"
  local CELL_ROOT="$ROOT/$CELL"
  local CELL_VERDICT="$CELL_ROOT/VERDICT.txt"
  mkdir -p "$CELL_ROOT"
  echo "CELL A (bare-baseline): cap=1, no-knowledge, skip-reviewer, all gates OFF  $(date -u)" | tee "$CELL_VERDICT"

  _env_clear_all_gates

  for entry in "${KERNELS[@]}"; do
    IFS='|' read -r name ref split <<< "$entry"
    pass_count=0
    cycles_list=""
    fail_reasons=""

    for seed in "${SEEDS[@]}"; do
      OUT="$CELL_ROOT/${name}/seed_${seed}"; mkdir -p "$OUT"
      echo "  [A] [$split] $name seed=$seed $(date +%H:%M)" | tee -a "$CELL_ROOT/sweep.log"

      SINGULARITYENV_XKERNEL_EVAL_SEED="$seed" \
      APPTAINERENV_XKERNEL_EVAL_SEED="$seed" \
      XKERNEL_EVAL_SEED="$seed" \
        bash "$LAUNCHER" --kernel "$name" --output "$OUT" \
          --skip-reviewer --skip-analyse --skip-planner --no-knowledge \
          --reviewer-max-attempts 1 --max-optimize-attempts 0 \
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
      echo "RESULT [$split] $name: $rate pass  cycles=[$cycles_list] ref=$ref" | tee -a "$CELL_VERDICT"
    else
      echo "RESULT [$split] $name: $rate pass  fail_reasons=[$fail_reasons] ref=$ref" | tee -a "$CELL_VERDICT"
    fi
  done
  echo "CELL_A_DONE" | tee -a "$CELL_VERDICT"

  _summarize_cell "$CELL_VERDICT" "A (bare-baseline)"
}

# ================================================================
# Cell B: harness-only (full harness, no IR)
# ================================================================
run_cell_B() {
  local CELL="B_harness_only"
  local CELL_ROOT="$ROOT/$CELL"
  local CELL_VERDICT="$CELL_ROOT/VERDICT.txt"
  mkdir -p "$CELL_ROOT"
  echo "CELL B (harness-only): cap=10, full pipeline, standard gates ON, IR OFF  $(date -u)" | tee "$CELL_VERDICT"

  _env_harness_gates

  for entry in "${KERNELS[@]}"; do
    IFS='|' read -r name ref split <<< "$entry"
    pass_count=0
    cycles_list=""
    fail_reasons=""

    for seed in "${SEEDS[@]}"; do
      OUT="$CELL_ROOT/${name}/seed_${seed}"; mkdir -p "$OUT"
      echo "  [B] [$split] $name seed=$seed $(date +%H:%M)" | tee -a "$CELL_ROOT/sweep.log"

      SINGULARITYENV_XKERNEL_EVAL_SEED="$seed" \
      APPTAINERENV_XKERNEL_EVAL_SEED="$seed" \
      XKERNEL_EVAL_SEED="$seed" \
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
      echo "RESULT [$split] $name: $rate pass  cycles=[$cycles_list] ref=$ref" | tee -a "$CELL_VERDICT"
    else
      echo "RESULT [$split] $name: $rate pass  fail_reasons=[$fail_reasons] ref=$ref" | tee -a "$CELL_VERDICT"
    fi
  done
  echo "CELL_B_DONE" | tee -a "$CELL_VERDICT"

  _summarize_cell "$CELL_VERDICT" "B (harness-only)"
}

# ================================================================
# Cell C: ir-only (no harness, IR ON)
# ================================================================
run_cell_C() {
  local CELL="C_ir_only"
  local CELL_ROOT="$ROOT/$CELL"
  local CELL_VERDICT="$CELL_ROOT/VERDICT.txt"
  mkdir -p "$CELL_ROOT"
  echo "CELL C (ir-only): cap=1, no-knowledge, skip-reviewer, all gates OFF + IR ON  $(date -u)" | tee "$CELL_VERDICT"

  _env_clear_all_gates
  _env_ir_on

  for entry in "${KERNELS[@]}"; do
    IFS='|' read -r name ref split <<< "$entry"
    pass_count=0
    cycles_list=""
    fail_reasons=""

    for seed in "${SEEDS[@]}"; do
      OUT="$CELL_ROOT/${name}/seed_${seed}"; mkdir -p "$OUT"
      echo "  [C] [$split] $name seed=$seed $(date +%H:%M)" | tee -a "$CELL_ROOT/sweep.log"

      SINGULARITYENV_XKERNEL_EVAL_SEED="$seed" \
      APPTAINERENV_XKERNEL_EVAL_SEED="$seed" \
      XKERNEL_EVAL_SEED="$seed" \
        bash "$LAUNCHER" --kernel "$name" --output "$OUT" \
          --skip-reviewer --skip-analyse --skip-planner --no-knowledge \
          --reviewer-max-attempts 1 --max-optimize-attempts 0 \
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
      echo "RESULT [$split] $name: $rate pass  cycles=[$cycles_list] ref=$ref" | tee -a "$CELL_VERDICT"
    else
      echo "RESULT [$split] $name: $rate pass  fail_reasons=[$fail_reasons] ref=$ref" | tee -a "$CELL_VERDICT"
    fi
  done
  echo "CELL_C_DONE" | tee -a "$CELL_VERDICT"

  _summarize_cell "$CELL_VERDICT" "C (ir-only)"
}

# ================================================================
# Cell D: full-stack (full harness + IR)
# ================================================================
run_cell_D() {
  local CELL="D_full_stack"
  local CELL_ROOT="$ROOT/$CELL"
  local CELL_VERDICT="$CELL_ROOT/VERDICT.txt"
  mkdir -p "$CELL_ROOT"
  echo "CELL D (full-stack): cap=10, full pipeline, standard gates + IR ON  $(date -u)" | tee "$CELL_VERDICT"

  _env_harness_gates
  _env_ir_on

  for entry in "${KERNELS[@]}"; do
    IFS='|' read -r name ref split <<< "$entry"
    pass_count=0
    cycles_list=""
    fail_reasons=""

    for seed in "${SEEDS[@]}"; do
      OUT="$CELL_ROOT/${name}/seed_${seed}"; mkdir -p "$OUT"
      echo "  [D] [$split] $name seed=$seed $(date +%H:%M)" | tee -a "$CELL_ROOT/sweep.log"

      SINGULARITYENV_XKERNEL_EVAL_SEED="$seed" \
      APPTAINERENV_XKERNEL_EVAL_SEED="$seed" \
      XKERNEL_EVAL_SEED="$seed" \
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
      echo "RESULT [$split] $name: $rate pass  cycles=[$cycles_list] ref=$ref" | tee -a "$CELL_VERDICT"
    else
      echo "RESULT [$split] $name: $rate pass  fail_reasons=[$fail_reasons] ref=$ref" | tee -a "$CELL_VERDICT"
    fi
  done
  echo "CELL_D_DONE" | tee -a "$CELL_VERDICT"

  _summarize_cell "$CELL_VERDICT" "D (full-stack)"
}

# ---------- per-cell summary ----------
_summarize_cell() {
  local verdict_file="$1"
  local cell_label="$2"
  python3 - "$verdict_file" "$cell_label" <<'PY' | tee -a "$verdict_file"
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
print(f"\n=== CELL {label} SUMMARY ===")
print(f"  Overall: {total_pass}/{total_runs} pass")
print(f"  Robust  ({len(robust)}): {', '.join(robust) or '(none)'}")
print(f"  Fragile ({len(fragile)}): {', '.join(fragile) or '(none)'}")
print(f"  Fail    ({len(fail)}): {', '.join(fail) or '(none)'}")
PY
}

# ================================================================
# Main: parse cell selection, default = all
# ================================================================
CELLS_TO_RUN=("$@")
if [ ${#CELLS_TO_RUN[@]} -eq 0 ]; then
  CELLS_TO_RUN=(A B C D)
fi

echo "IR ABLATION 2x2: cells=[${CELLS_TO_RUN[*]}] seeds=[${SEEDS[*]}] model=$ARGO_MODEL  $TS" | tee "$ROOT/EXPERIMENT.txt"
echo "Root: $ROOT" | tee -a "$ROOT/EXPERIMENT.txt"

for CELL in "${CELLS_TO_RUN[@]}"; do
  case "$CELL" in
    A) run_cell_A ;;
    B) run_cell_B ;;
    C) run_cell_C ;;
    D) run_cell_D ;;
    *) echo "Unknown cell: $CELL (valid: A B C D)" >&2 ;;
  esac
done

# ---------- cross-cell summary ----------
echo ""
echo "========================================"
echo "IR ABLATION 2x2 COMPLETE: $ROOT"
echo "========================================"

python3 - "$ROOT" <<'PY' | tee "$ROOT/SUMMARY.txt"
import sys, re, os

root = sys.argv[1]
cells = {
    "A_bare_baseline": "A (bare)",
    "B_harness_only":  "B (harness)",
    "C_ir_only":       "C (IR)",
    "D_full_stack":    "D (full)",
}

results = {}  # cell -> {kernel -> (pass_count, n_seeds, cycles_list)}
for cell_dir, cell_label in cells.items():
    vf = os.path.join(root, cell_dir, "VERDICT.txt")
    if not os.path.exists(vf):
        continue
    results[cell_label] = {}
    for line in open(vf):
        m = re.match(r"RESULT \[(\w+)\] (\S+): (\d)/(\d) pass", line)
        if not m:
            continue
        split, name, p, n = m.group(1), m.group(2).rstrip(":"), int(m.group(3)), int(m.group(4))
        cm = re.search(r"cycles=\[([^\]]*)\]", line)
        cyc_str = cm.group(1) if cm else ""
        cyc_list = [int(x) for x in cyc_str.strip(",").split(",") if x.strip() not in ("", "-")]
        results[cell_label] = results.get(cell_label, {})
        results[cell_label][name] = (p, n, cyc_list)

if not results:
    print("No results found yet.")
    sys.exit(0)

# Collect all kernel names in order
all_kernels = []
for cell_data in results.values():
    for k in cell_data:
        if k not in all_kernels:
            all_kernels.append(k)

print("\n=== 2x2 FACTORIAL SUMMARY ===\n")

# Pass-rate table
header = f"{'Kernel':<25s}"
cell_labels = sorted(results.keys())
for cl in cell_labels:
    header += f"  {cl:>14s}"
print(header)
print("-" * len(header))

cell_totals = {cl: [0, 0] for cl in cell_labels}
for k in all_kernels:
    row = f"{k:<25s}"
    for cl in cell_labels:
        if k in results.get(cl, {}):
            p, n, _ = results[cl][k]
            row += f"  {f'{p}/{n}':>14s}"
            cell_totals[cl][0] += p
            cell_totals[cl][1] += n
        else:
            row += f"  {'---':>14s}"
    print(row)

print("-" * len(header))
row = f"{'TOTAL':<25s}"
for cl in cell_labels:
    p, n = cell_totals[cl]
    pct = f"{p}/{n} ({100*p/n:.0f}%)" if n > 0 else "---"
    row += f"  {pct:>14s}"
print(row)

# Interaction check
if all(cl in results for cl in ["A (bare)", "B (harness)", "C (IR)", "D (full)"]):
    print("\n=== INTERACTION ANALYSIS ===\n")
    for k in all_kernels:
        a = results["A (bare)"].get(k, (0, 5, []))[0]
        b = results["B (harness)"].get(k, (0, 5, []))[0]
        c = results["C (IR)"].get(k, (0, 5, []))[0]
        d = results["D (full)"].get(k, (0, 5, []))[0]
        harness_effect = b - a
        ir_effect = c - a
        additive = a + harness_effect + ir_effect
        interaction = d - additive
        tag = "SUPER-ADDITIVE" if interaction > 0 else ("SUB-ADDITIVE" if interaction < 0 else "ADDITIVE")
        print(f"  {k:<25s} A={a} B={b} C={c} D={d}  expected_additive={additive}  interaction={interaction:+d}  {tag}")
PY

echo ""
echo "IR_ABLATION_2x2_DONE" | tee -a "$ROOT/EXPERIMENT.txt"
