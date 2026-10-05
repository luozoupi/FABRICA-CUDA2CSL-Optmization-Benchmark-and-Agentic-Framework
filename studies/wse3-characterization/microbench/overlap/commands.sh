#!/usr/bin/env bash
set -e
export PATH=/software/cerebras/cs_sdk-2.10:$PATH
cd "$(dirname "$0")"
python3 gen.py
rm -rf out simfab_traces events.jsonl.gz
cslc ./layout.csl --arch=wse3 --fabric-dims=8,3 --fabric-offsets=4,1 -o out --memcpy --channels=1 --width-west-buf=0 --width-east-buf=0
cs_python run.py --name out
# The simulator writes simfab_traces/ through NFS; on a login node the directory can
# take a few seconds to become visible, and decode_trace then reports "no CTF stream0".
sync; for i in $(seq 30); do [ -f simfab_traces/stream0 ] && break; sleep 1; done
python3 ../../tools/decode_trace.py . -o events.jsonl.gz
# csdisasm stages the ELF into TMPDIR; that must be NFS-visible when the container runs
# on another node, so point TMPDIR inside the (shared) study tree rather than /tmp.
TMPDIR=../../.nfstmp python3 ../../tools/csdisasm.py out/bin/out_0_0.elf --json disasm.json > /dev/null
python3 ../../tools/overlap_probe.py
