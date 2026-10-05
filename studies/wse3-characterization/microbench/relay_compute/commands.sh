#!/usr/bin/env bash
set -e
export PATH=/software/cerebras/cs_sdk-2.10:$PATH
export TMPDIR=/home/USER/xkernel/studies/wse3-characterization/.nfstmp   # csdisasm stages ELFs here; /tmp is not visible to the container host
cd "$(dirname "$0")"
python3 gen.py
rm -rf out simfab_traces
cslc ./layout.csl --arch=wse3 --fabric-dims=16,3 --fabric-offsets=4,1 --params=B:8 -o out --memcpy --channels=1 --width-west-buf=0 --width-east-buf=0
cs_python run.py --name out
for i in 1 2 3 4 5 6 7 8 9 10 11 12; do [ -e simfab_traces/stream0 ] && break; sleep 5; done
python3 ../../tools/decode_trace.py . -o events.jsonl.gz
python3 ../../tools/csdisasm.py out/bin/out_0_0.elf --json disasm_pe0.json > /dev/null
python3 ../../tools/csdisasm.py out/bin/out_1_0.elf --json disasm_pe1.json > /dev/null
cslc ./layout.csl --arch=wse3 --fabric-dims=16,3 --fabric-offsets=4,1 --params=B:8 -o out_routes --memcpy --channels=1 --width-west-buf=0 --width-east-buf=0 --out-routes 2>&1 | grep -E "^\||^Total" > routes.txt; rm -rf out_routes
echo DONE
