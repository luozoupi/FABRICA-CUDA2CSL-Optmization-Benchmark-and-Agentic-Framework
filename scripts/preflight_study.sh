#!/usr/bin/env bash
# Preflight for an account that is about to run cells of the model-guided
# optimization study (docs/EXPERIMENT_RUNBOOK.md).
#
# Five checks, cheapest first. The point of the last two is that results from
# two accounts are POOLED: a node whose simulator or model id differs silently
# would corrupt the study, and that must be caught before spending money on
# thousands of LLM calls, not afterwards.
#
#   1. environment   xkernel_env.sh resolves; SDK + micromamba found
#   2. unit tests    CPU only, ~10 s
#   3. task sets     the frozen start programs this account needs all exist
#   4. calibration   compile+run two committed references and require the
#                    EXACT cycle counts in kernels/baselines_wse3.json
#                    (simulator cycles are deterministic, so any difference
#                    means a different SDK, container or reference bundle)
#   5. LLM route     one real request through the configured launcher, and the
#                    model id it reports must match the study's
#
# Usage:
#   bash scripts/preflight_study.sh                       # anthropic launcher (default)
#   XKERNEL_LAUNCHER=$PWD/run_cuda2csl_argo.sh ARGO_MODEL=claude-opus-4-8 \
#     bash scripts/preflight_study.sh --partition B
#   bash scripts/preflight_study.sh --skip-llm            # checks 1-4 only
#
# Exit 0 = this account may start its cells. Any FAIL = do not start.
set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/xkernel_env.sh"

STUDY_MODEL="${STUDY_MODEL:-claude-opus-4-8}"
PARTITION=""
SKIP_LLM=0
while [ $# -gt 0 ]; do
  case "$1" in
    --partition) PARTITION="$2"; shift 2;;
    --skip-llm) SKIP_LLM=1; shift;;
    --model) STUDY_MODEL="$2"; shift 2;;
    -h|--help) sed -n '2,28p' "$0"; exit 0;;
    *) echo "unknown arg $1" >&2; exit 2;;
  esac
done
LAUNCHER="${XKERNEL_LAUNCHER:-$XKERNEL_ROOT/run_cuda2csl_anthropic.sh}"

FAILED=0
pass() { printf '  \033[32mPASS\033[0m  %s\n' "$1"; }
fail() { printf '  \033[31mFAIL\033[0m  %s\n' "$1"; FAILED=$((FAILED+1)); }
info() { printf '        %s\n' "$1"; }

echo "xkernel study preflight   $(date -u +%FT%TZ)"
GIT_BIN="${GIT:-$(command -v git || true)}"
if [ -z "$GIT_BIN" ]; then
  for c in /usr/bin/git "$HOME/micromamba/envs/dev/bin/git"; do [ -x "$c" ] && GIT_BIN="$c" && break; done
fi
if [ -n "$GIT_BIN" ]; then
  COMMIT=$(cd "$XKERNEL_ROOT" && "$GIT_BIN" rev-parse --short HEAD 2>/dev/null || echo unknown)
  BRANCH=$(cd "$XKERNEL_ROOT" && "$GIT_BIN" rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)
else
  COMMIT="unknown (git not on PATH)"; BRANCH="unknown"
fi
echo "  repo      $XKERNEL_ROOT  (branch $BRANCH, commit $COMMIT)"
echo "  launcher  $(basename "$LAUNCHER")"
echo "  model     $STUDY_MODEL"
echo

# ---- 1. environment ----------------------------------------------------------
echo "[1/5] environment"
[ -n "${XKERNEL_SDK_ROOT:-}" ] && [ -d "$XKERNEL_SDK_ROOT" ] \
  && pass "SDK at $XKERNEL_SDK_ROOT" || fail "no SDK: set XKERNEL_SDK_ROOT (see SETUP.md section 3)"
[ -x "$XKERNEL_MICROMAMBA" ] && pass "micromamba at $XKERNEL_MICROMAMBA" || fail "micromamba not executable: $XKERNEL_MICROMAMBA"
if "$XKERNEL_MICROMAMBA" run -n "$XKERNEL_ENV" python -c "import anthropic, yaml, numpy" 2>/dev/null; then
  pass "environment '$XKERNEL_ENV' has the agent's imports"
else
  fail "environment '$XKERNEL_ENV' incomplete: micromamba create -f code_translation/environment.micromamba.yml"
fi
case "$XKERNEL_ROOT" in
  /tmp/*) fail "the repo is under /tmp: the SDK container cannot bind it, clone under \$HOME";;
  *) pass "repo location can be bound into the SDK container";;
esac
# The study lives on v2_0; the default branch lacks this tooling entirely.
# Tested by file presence, not by branch name, so a rename cannot break it.
if [ -f "$XKERNEL_ROOT/docs/EXPERIMENT_RUNBOOK.md" ] && [ -f "$XKERNEL_ROOT/code_translation/task_sets.py" ]; then
  pass "checkout carries the study tooling (branch $BRANCH)"
else
  fail "this checkout lacks the study tooling: git checkout v2_0 && git pull (see SETUP.md section 2)"
fi

# ---- 2. unit tests -----------------------------------------------------------
echo "[2/5] unit tests (CPU)"
# Some test modules print to stdout, so scan the whole output for unittest's own
# verdict lines rather than assuming they are the last thing printed.
TEST_OUT=$( cd "$XKERNEL_ROOT/code_translation" && "$XKERNEL_MICROMAMBA" run -n "$XKERNEL_ENV" \
            python -m unittest discover -p 'test_*.py' 2>&1 )
TEST_RAN=$(echo "$TEST_OUT" | grep -E '^Ran [0-9]+ test' | tail -1)
if echo "$TEST_OUT" | grep -qE '^OK( \(|$)'; then
  pass "${TEST_RAN:-unit tests green}"
else
  fail "unit tests not green"
  info "${TEST_RAN:-(no 'Ran N tests' line: the run did not finish)}"
  echo "$TEST_OUT" | grep -E '^(FAILED|FAIL:|ERROR:)' | head -5 | sed 's/^/        /'
fi

# ---- 3. task sets and frozen start programs ----------------------------------
echo "[3/5] task sets and frozen start programs"
TS_OUT=$( cd "$XKERNEL_ROOT/code_translation" && "$XKERNEL_MICROMAMBA" run -n "$XKERNEL_ENV" \
          python task_sets.py --verify 2>&1 )
if echo "$TS_OUT" | grep -q "^OK"; then pass "$TS_OUT"; else fail "task sets disagree with the repository"; info "$TS_OUT"; fi
if [ -n "$PARTITION" ]; then
  MINE=$( cd "$XKERNEL_ROOT/code_translation" && "$XKERNEL_MICROMAMBA" run -n "$XKERNEL_ENV" \
          python task_sets.py --partition "$PARTITION" 2>/dev/null )
  if [ -n "$MINE" ]; then
    n=$(echo "$MINE" | tr ',' '\n' | wc -l)
    pass "partition $PARTITION owns $n kernels"
    info "$MINE"
  else
    fail "unknown partition '$PARTITION'"
  fi
fi

# ---- 4. simulator calibration (the poolability check) ------------------------
echo "[4/5] simulator calibration against the committed baselines"
CAL_OUT=$( cd "$XKERNEL_ROOT" && "$XKERNEL_MICROMAMBA" run -n "$XKERNEL_ENV" \
           python "$XKERNEL_ROOT/scripts/preflight_calibrate.py" 2>&1 )
echo "$CAL_OUT" | sed 's/^/        /'
if echo "$CAL_OUT" | grep -q "CALIBRATION_OK"; then
  pass "reference cycles reproduce the committed baselines exactly"
else
  fail "simulator does not reproduce the committed reference cycles -- results from this node are NOT poolable"
fi

# ---- 5. LLM route ------------------------------------------------------------
# ---- 5. held-out gate integrity ---------------------------------------------
# The login-node relay forwards no environment. The v2 sparse runners also take the seed
# from a file in the bundle and echo it back, so they are safe either way; the legacy
# (v1) runners read only the environment, and a container that does not see XKERNEL_*
# would silently re-run the TRAIN input on every held-out check (found 2026-09-16).
echo "[5/6] held-out gate integrity (environment reaches the container)"
PROBE_VAL="xk$$_$(date +%s)"
PROBE_OUT=$( cd "$XKERNEL_ROOT" && \
  SINGULARITYENV_XKERNEL_ENV_PROBE="$PROBE_VAL" \
  APPTAINERENV_XKERNEL_ENV_PROBE="$PROBE_VAL" \
  XKERNEL_ENV_PROBE="$PROBE_VAL" \
  timeout 600 "$XKERNEL_SDK_ROOT/cs_python" -c \
  'import os; print("XKERNEL_ENV_PROBE=" + str(os.environ.get("XKERNEL_ENV_PROBE")))' 2>&1 )
if echo "$PROBE_OUT" | grep -q "XKERNEL_ENV_PROBE=$PROBE_VAL"; then
  pass "XKERNEL_* reaches the container -- the held-out gate can drive the input"
elif echo "$PROBE_OUT" | grep -q "XKERNEL_ENV_PROBE=None"; then
  fail "the container does not see XKERNEL_* -- legacy runners would re-use the TRAIN seed on every held-out re-run"
  info "your \`singularity\` drops the environment; on the login nodes it is an ssh relay."
  info "fix:  cp ~/bin/singularity ~/bin/singularity.bak \\"
  info "      && cp $XKERNEL_ROOT/scripts/singularity_relay_env.sh ~/bin/singularity"
  info "then re-run this preflight (set XKERNEL_RELAY_HOST to your SDK node first)."
else
  fail "could not probe the container environment (cs_python did not run)"
  info "$(echo "$PROBE_OUT" | tail -3)"
fi

# ---- 6. LLM route ------------------------------------------------------------
if [ "$SKIP_LLM" = "1" ]; then
  echo "[6/6] LLM route: skipped (--skip-llm)"
else
  echo "[6/6] LLM route"
  ENV_OUT=$( cd "$XKERNEL_ROOT" && timeout 600 bash "$LAUNCHER" --check-env 2>&1 )
  if echo "$ENV_OUT" | grep -q '"overall_status": *"ready"'; then
    pass "launcher reports overall_status ready (SDK + LLM reachable)"
  else
    fail "launcher --check-env not ready"
    info "$(echo "$ENV_OUT" | grep -E '"(overall_status|llm|cslc_launch|cs_python_launch)"' | head -6)"
  fi
  REPORTED=$(echo "$ENV_OUT" | "$XKERNEL_MICROMAMBA" run -n "$XKERNEL_ENV" python -c '
import json, re, sys
raw = sys.stdin.read()
m = re.search(r"\{.*\}", raw, re.S)
try:
    d = json.loads(m.group(0)) if m else {}
except ValueError:
    d = {}
llm = d.get("llm") or {}
print(llm.get("model") or llm.get("model_id") or "")' 2>/dev/null)
  if [ -z "$REPORTED" ]; then
    info "launcher did not report a model id; confirm it by hand before the sweep"
  elif [ "$REPORTED" = "$STUDY_MODEL" ]; then
    pass "model id is the study's ($REPORTED)"
  else
    fail "model id is '$REPORTED', the study uses '$STUDY_MODEL' -- set ARGO_MODEL/XKERNEL_MODEL"
  fi
fi

echo
if [ "$FAILED" -eq 0 ]; then
  echo "PREFLIGHT OK -- this account may start its cells (docs/EXPERIMENT_RUNBOOK.md step 4)"
  exit 0
fi
echo "PREFLIGHT FAILED ($FAILED check(s)) -- do not start a sweep; fix the FAILs above"
exit 1
