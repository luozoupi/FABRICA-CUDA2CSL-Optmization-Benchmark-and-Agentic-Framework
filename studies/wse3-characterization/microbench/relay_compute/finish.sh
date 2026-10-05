#!/usr/bin/env bash
# Runs the disassembly and route steps once the pcsweep build has exited: singularity launches
# over the relay must not overlap (concurrent launches time out mounting the image).
export PATH=/software/cerebras/cs_sdk-2.10:$PATH
export TMPDIR=/home/USER/xkernel/studies/wse3-characterization/.nfstmp
cd "$(dirname "$0")"
while pgrep -f "pcsweep/build.py|python3 build.py" > /dev/null; do sleep 15; done
python3 ../../tools/csdisasm.py out/bin/out_0_0.elf --json disasm_pe0.json > /dev/null
python3 ../../tools/csdisasm.py out/bin/out_1_0.elf --json disasm_pe1.json > /dev/null
cslc ./layout.csl --arch=wse3 --fabric-dims=16,3 --fabric-offsets=4,1 --params=B:8 -o out_routes --memcpy --channels=1 --width-west-buf=0 --width-east-buf=0 --out-routes 2>&1 | grep -E "^\||^Total" > routes.txt; rm -rf out_routes
ls -la disasm_pe0.json disasm_pe1.json routes.txt; echo FINISH-DONE
