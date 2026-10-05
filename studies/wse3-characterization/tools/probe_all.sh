#!/bin/bash
# Static compiler-level fabric profile for every kernel with compiled ELFs.
export PATH=$(for d in /software/cerebras/cs_sdk-2.10 /software/cerebras/cs_sdk-1.4.0 $HOME/cs_sdk-1.4.0; do [ -x "$d/cs_readelf" ] && echo "$d" && break; done):$PATH
OUT=${1:-$HOME/xkernel/studies/wse3-characterization/results/fabric-profiles}
mkdir -p "$OUT"
cd "$HOME/xkernel/kernels" || exit 1
n=0
for d in */CSL; do
  [ -d "$d/out/bin" ] || continue
  ls "$d"/out/bin/*.elf >/dev/null 2>&1 || continue
  k=$(dirname "$d")
  safe=$(echo "$k" | tr ' /' '__')
  ( cd "$d" && python3 "$HOME/xkernel/studies/wse3-characterization/tools/fabric_probe.py" \
      out --json "$OUT/$safe.json" --quiet ) 2>>"$OUT/errors.log" \
    && { echo "ok   $k"; n=$((n+1)); } || echo "FAIL $k"
done
echo "profiled $n kernels into $OUT"
