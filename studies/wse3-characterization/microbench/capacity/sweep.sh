#!/usr/bin/env bash
# Find the largest single-PE u16 allocation cslc accepts, and report the ELF's
# own memory figure at each step.  Compile-only: no device time.
export PATH=/software/cerebras/cs_sdk-2.10:$PATH
cd "$(dirname "$0")"
OUT=${1:-sweep.txt}
: > "$OUT"
for w in "$@"; do :; done
for w in 20992 21504 22016 22272 22400 22464 22480 22488 22496 22512; do
  rm -rf out
  if cslc ./layout.csl --arch=wse3 --fabric-dims=8,3 --fabric-offsets=4,1 \
       --params=words:"$w" -o out --memcpy --channels=1 \
       --width-west-buf=0 --width-east-buf=0 > compile.log 2>&1; then
    ms=$(cs_readelf --ms out/bin/out_0_0.elf 2>/dev/null | grep -oE '[0-9]+ bytes' | head -1)
    echo "$w OK ${ms:-?}" >> "$OUT"
  else
    err=$(grep -iE "error" compile.log | head -2 | tr '\n' ' ')
    echo "$w FAIL ${err:0:150}" >> "$OUT"
  fi
done
echo FIN >> "$OUT"
