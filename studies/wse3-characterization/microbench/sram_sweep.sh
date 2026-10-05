#!/usr/bin/env bash
# Compile every materialized single-pe-sram probe and record where cslc refuses.
# Compile-only: no device is involved, so this costs no appliance time.
export PATH=/software/cerebras/cs_sdk-2.10:$PATH
ROOT=$HOME/xkernel/studies/wse3-characterization
BUNDLES=$ROOT/results/wse3-full/calibration/generated-bundles
OUT=${1:-$ROOT/results/sram_sweep.txt}
: > "$OUT"
for d in $(ls -d "$BUNDLES"/single-pe-sram-b* 2>/dev/null | sort -t b -k3 -n); do
  case_dir=$(ls -d "$d"/*/ 2>/dev/null | head -1)
  [ -n "$case_dir" ] || continue
  bytes=$(basename "$d" | sed 's/.*-b//')
  cd "$case_dir" || continue
  rm -rf out
  if bash commands_wse3.sh > compile.log 2>&1; then
    ms=$(bash inspect_memory.sh 2>/dev/null | head -40)
    echo "### $bytes OK" >> "$OUT"
    echo "$ms" >> "$OUT"
  else
    echo "### $bytes FAIL" >> "$OUT"
    grep -iE "error|exceed|overflow|out of|too large|memory" compile.log | head -5 >> "$OUT"
  fi
done
echo FIN >> "$OUT"
