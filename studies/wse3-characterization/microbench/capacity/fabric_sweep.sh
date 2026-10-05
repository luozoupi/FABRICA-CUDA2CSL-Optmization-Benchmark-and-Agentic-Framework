#!/usr/bin/env bash
# Largest --fabric-dims cslc accepts. Compile-only; a trivial 1-PE kernel is used
# so the only thing being tested is the fabric bound itself.
export PATH=/software/cerebras/cs_sdk-2.10:$PATH
cd "$(dirname "$0")"
OUT=${1:-fabric.txt}
: > "$OUT"
for dims in 8,3 100,100 512,512 762,1172 763,1172 762,1173 763,1173 1024,1024 1500,1500 2048,2048; do
  rm -rf outf
  if cslc ./layout.csl --arch=wse3 --fabric-dims="$dims" --fabric-offsets=4,1 \
       --params=words:512 -o outf --memcpy --channels=1 \
       --width-west-buf=0 --width-east-buf=0 > fab.log 2>&1; then
    echo "$dims OK" >> "$OUT"
  else
    err=$(grep -iE "error" fab.log | head -1)
    echo "$dims FAIL ${err:0:140}" >> "$OUT"
  fi
done
echo FIN >> "$OUT"
