#!/usr/bin/env bash
set -e
export PATH=/software/cerebras/cs_sdk-2.10:$PATH
cd "$(dirname "$0")"
python3 gen.py
rm -rf out simfab_traces
cslc ./layout.csl --arch=wse3 --fabric-dims=8,3 --fabric-offsets=4,1 -o out --memcpy --channels=1 --width-west-buf=0 --width-east-buf=0
cs_python run.py --name out
python3 ../../tools/decode_trace.py . -o events.jsonl.gz
python3 ../../tools/csdisasm.py out/bin/out_0_0.elf --json disasm.json > /dev/null
