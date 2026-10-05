#!/usr/bin/env bash
# Disassembly + routes for relay_compute, run after the pcsweep rerun (waited on by pid, not by name).
export PATH=/software/cerebras/cs_sdk-2.10:$PATH
export TMPDIR=/home/USER/xkernel/studies/wse3-characterization/.nfstmp
cd "$(dirname "$0")"
# wait for the pcsweep build only (anchored pattern; launcher shells quoting the name do not count)
while pgrep -f "^python3 (-u )?build.py" > /dev/null; do sleep 10; done
python3 ../../tools/csdisasm.py out/bin/out_0_0.elf --json disasm_pe0.json > /dev/null
python3 ../../tools/csdisasm.py out/bin/out_1_0.elf --json disasm_pe1.json > /dev/null
cslc ./layout.csl --arch=wse3 --fabric-dims=16,3 --fabric-offsets=4,1 --params=B:8 -o out_routes --memcpy --channels=1 --width-west-buf=0 --width-east-buf=0 --out-routes 2>&1 | grep -E "^\||^Total" > routes.txt; rm -rf out_routes
ls -la disasm_pe0.json disasm_pe1.json routes.txt; echo FINISH-DONE
