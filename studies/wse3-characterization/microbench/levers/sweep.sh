#!/usr/bin/env bash
# Compiler levers reachable through cslc, measured.
#
#   1. --fp16-format {f16,cb16,bf16}: does the FP16 encoding change FMA throughput?
#   2. --lomem-reservation-end: reserving low memory shifts every array, which is
#      the alignment control the bank probe lacked -- it could not move arrays
#      relative to the 8 banks, so its positive control came out flat.
#
# The SDK container mounts only the working directory, so each build runs from
# inside its own probe directory rather than referencing one by absolute path.
export PATH=/software/cerebras/cs_sdk-2.10:$PATH
HERE=$(cd "$(dirname "$0")" && pwd)
MB=$(dirname "$HERE")
OUT=$HERE/levers.txt
: > "$OUT"

echo "### fp16-format -- loop-form probe, 4096 f16 FMA elements per variant" >> "$OUT"
cd "$MB/loopform" || exit 1
for FMT in f16 cb16 bf16; do
  rm -rf out_$FMT
  if cslc ./layout.csl --arch=wse3 --fabric-dims=8,3 --fabric-offsets=4,1 \
       --fp16-format=$FMT -o out_$FMT --memcpy --channels=1 \
       --width-west-buf=0 --width-east-buf=0 > /tmp/f_$FMT.log 2>&1; then
    cs_python run.py --name out_$FMT 2>/dev/null | grep -E "^L[0-3] " \
      | awk -v f=$FMT '{printf "  %-5s %-3s cycles=%-8s cyc/elem=%s\n", f, $1, $3, $4}' >> "$OUT"
  else
    echo "  $FMT FAIL: $(grep -iE 'error' /tmp/f_$FMT.log | head -1 | cut -c1-90)" >> "$OUT"
  fi
done

echo "" >> "$OUT"
echo "### lomem-reservation-end -- bank probe, shifts every array" >> "$OUT"
cd "$MB/bank" || exit 1
for R in 0 2 4 8 16; do
  rm -rf out_lm$R
  if cslc ./layout.csl --arch=wse3 --fabric-dims=8,3 --fabric-offsets=4,1 \
       --params=n:2048,reps:64 --lomem-reservation-end=$R -o out_lm$R --memcpy --channels=1 \
       --width-west-buf=0 --width-east-buf=0 > /tmp/lm_$R.log 2>&1; then
    cs_python run.py --name out_lm$R 2>/dev/null \
      | grep -E "rw-off0|rw-off1|ctl-s2a0|ctl-s2a1" \
      | awk -v r=$R '{printf "  reserve=%-3sB %-10s cyc/elem=%s\n", r, $1, $(NF-1)}' >> "$OUT"
  else
    echo "  reserve=$R FAIL: $(grep -iE 'error' /tmp/lm_$R.log | head -1 | cut -c1-90)" >> "$OUT"
  fi
done
echo FIN >> "$OUT"
