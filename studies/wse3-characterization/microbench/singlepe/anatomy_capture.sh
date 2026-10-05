#!/usr/bin/env bash
set -e
export PATH=/software/cerebras/cs_sdk-2.10:$PATH
cd "$(dirname "$0")"
python3 gen.py
for s in ${*:-A B C1 C2 D}; do
  rm -rf "$s/out" simfab_traces
  cslc "$s/layout.csl" --arch=wse3 --fabric-dims=8,3 --fabric-offsets=4,1 \
    -o "$s/out" --memcpy --channels=1 --width-west-buf=0 --width-east-buf=0
  cs_python run.py --suite "$s"
  case $s in A|B|C2) python3 ../../tools/decode_trace.py . -o "$s/events.jsonl.gz";; esac
done
