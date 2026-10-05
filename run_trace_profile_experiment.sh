#!/usr/bin/env bash
# Trace profiling experiment: run kernels with CTF trace analysis enabled,
# then validate the best results on real WSE-3 hardware.
set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${XKERNEL_ROOT:-$SCRIPT_DIR}/xkernel_env.sh"
LAUNCHER="$HOME/xkernel/run_cuda2csl_argo.sh"
CAP=20
TS=$(date -u +%Y%m%d_%H%M%S)
ROOT="$HOME/xkernel/code_translation/results/trace_experiment_${TS}"
mkdir -p "$ROOT"
VERDICT="$ROOT/VERDICT.txt"
echo "TRACE EXPERIMENT: cap=$CAP, trace+memory profiling, Opus 4.8  $TS" | tee "$VERDICT"

export XKERNEL_DRY_CHECK=1
export XKERNEL_ERROR_GOTCHA=1
export XKERNEL_HARD_KERNEL_HINTS=1
export XKERNEL_SPLICE_FROZEN=1
export XKERNEL_LIB_BEHAVIORAL=1
export XKERNEL_LAYER_CLEARANCE=1
export XKERNEL_PROFILE_MEMORY=1
export XKERNEL_TRACE_PROFILE=1
export ARGO_MODEL="claude-opus-4-8"
export OMP_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1

# Focus on multi-PE kernels where trace profiling matters most
KERNELS=(
  "Jacobi-2D-5pt|1566|test"
  "Laplacian2D-Halo|1709|test"
  "Game-of-Life|7838|test"
  "Histogram-1PE|6191|test"
  "DFT-1PE|145233|test"
  "Residual|674|test"
)

_passed() { local bj; bj=$(ls -t "$1"/run_*/*/benchmark.json 2>/dev/null | head -1); [ -n "$bj" ] && python3 -c "import json,sys;sys.exit(0 if json.load(open('$bj')).get('status')=='pass' else 1)" 2>/dev/null; }
_cyc() { local bj; bj=$(ls -t "$1"/run_*/*/benchmark.json 2>/dev/null | head -1); [ -n "$bj" ] && python3 -c "import json;print(json.load(open('$bj')).get('cycles_send') or '-')" 2>/dev/null || echo "-"; }
_cleanup() { pkill -u $(whoami) -f "squashfuse_ll" 2>/dev/null || true; sleep 1; }

for entry in "${KERNELS[@]}"; do
  IFS='|' read -r name ref split <<< "$entry"
  OUT="$ROOT/$name"; mkdir -p "$OUT"
  echo "==== [$split] $name (ref=$ref) ====" | tee -a "$ROOT/sweep.log"

  bash "$LAUNCHER" --kernel "$name" --output "$OUT" \
    --auto-optimize --profile-feedback \
    --reviewer-max-attempts "$CAP" \
    --max-optimize-attempts "$CAP" --min-optimize-attempts 4 \
    >>"$OUT/run.log" 2>&1 || true
  _cleanup

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
done
echo "TRACE_EXPERIMENT_DONE" | tee -a "$VERDICT"

# Now validate passing kernels on real hardware
echo "" | tee -a "$VERDICT"
echo "=== HARDWARE VALIDATION ===" | tee -a "$VERDICT"

# Use the appliance SDK for hardware runs
SDK_PYTHON="$HOME/cs_appliance_sdk/bin/python3"
if [ -x "$SDK_PYTHON" ]; then
  for entry in "${KERNELS[@]}"; do
    IFS='|' read -r name ref split <<< "$entry"
    OUT="$ROOT/$name"
    if _passed "$OUT"; then
      sim_cyc=$(_cyc "$OUT")
      echo "  Running $name on hardware..." | tee -a "$VERDICT"

      # Port the reference kernel to SDK 2.10 and run on hardware
      HW_RESULT=$($SDK_PYTHON -c "
import sys, os, json, struct, tempfile, shutil, re
import numpy as np
sys.path.insert(0, '$XKERNEL_ROOT/code_translation')
from hardware_submit import port_kernel_to_sdk210
from cerebras.sdk.client import SdkCompiler, SdkRuntime
from cerebras.appliance.pb.sdk.sdk_common_pb2 import MemcpyDataType, MemcpyOrder

ref_dir = '$XKERNEL_ROOT/kernels/$name/CSL'
if not os.path.isdir(ref_dir):
    ref_dir = '$XKERNEL_ROOT/kernels/$(echo $name | tr '-' ' ')/CSL'
if not os.path.isdir(ref_dir):
    print(json.dumps({'status': 'skip', 'reason': 'kernel dir not found'}))
    exit()

bundle = port_kernel_to_sdk210(ref_dir, tempfile.mkdtemp(prefix='hw_trace_'))
# Find layout and extract cslc args from commands_wse3.sh
layout = 'layout.csl'
for f in ['layout.csl', 'code.csl', 'layout_matvec.csl']:
    if os.path.isfile(os.path.join(bundle, f)):
        layout = f
        break

# Simple compile with hardware fabric dims
try:
    with SdkCompiler(disable_version_check=True) as c:
        art = c.compile(bundle, layout,
            '--arch=wse3 --fabric-dims=762,1172 --fabric-offsets=4,1 --memcpy --channels=1',
            bundle)
    with SdkRuntime(art, simulator=False, disable_version_check=True) as r:
        r.launch('compute', nonblock=False)
        tbuf = np.zeros(3, dtype=np.float32)
        r.memcpy_d2h(tbuf, r.get_id('maxmin_time'), 0, 0, 1, 1, 3,
                     streaming=False, data_type=MemcpyDataType.MEMCPY_32BIT,
                     order=MemcpyOrder.ROW_MAJOR, nonblock=False)
    words = []
    for k in range(3):
        u = struct.unpack('I', struct.pack('f', float(tbuf[k])))[0]
        words.append(u & 0xFFFF)
        words.append((u >> 16) & 0xFFFF)
    hw_cyc = (int(words[3])|(int(words[4])<<16)|(int(words[5])<<32)) - \
             (int(words[0])|(int(words[1])<<16)|(int(words[2])<<32))
    print(json.dumps({'status': 'pass', 'hw_cycles': hw_cyc}))
except Exception as e:
    print(json.dumps({'status': 'fail', 'error': str(e)[:100]}))
" 2>/dev/null | tail -1)

      hw_cyc=$(echo "$HW_RESULT" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('hw_cycles','-'))" 2>/dev/null)
      hw_status=$(echo "$HW_RESULT" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('status','fail'))" 2>/dev/null)
      echo "  HW_RESULT $name: status=$hw_status hw_cycles=$hw_cyc sim_cycles=$sim_cyc" | tee -a "$VERDICT"
    fi
  done
else
  echo "  SDK venv not found — skipping hardware validation" | tee -a "$VERDICT"
fi
