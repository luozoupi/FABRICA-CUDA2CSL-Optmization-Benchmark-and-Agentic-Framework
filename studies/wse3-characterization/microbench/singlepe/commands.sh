#!/usr/bin/env bash
# Build and run every suite. Usage: ./commands.sh [suite ...]  (default: all)
set -e
export PATH=/software/cerebras/cs_sdk-2.10:$PATH
cd "$(dirname "$0")"
python3 gen.py
SUITES=${*:-A B C1 C2 D}
for s in $SUITES; do
  rm -rf "$s/out"
  cslc "$s/layout.csl" --arch=wse3 --fabric-dims=8,3 --fabric-offsets=4,1 \
    -o "$s/out" --memcpy --channels=1 --width-west-buf=0 --width-east-buf=0
  cs_python run.py --suite "$s"
done
# BF16 comparison build of C2: same source, different runtime FP16 format.
# Expressible only because no [*]f16 pointer is exported (bf16 forbids those).
rm -rf C2/out_bf16
set +e
cslc C2/layout.csl --arch=wse3 --fabric-dims=8,3 --fabric-offsets=4,1 \
  --fp16-format=bf16 -o C2/out_bf16 --memcpy --channels=1 \
  --width-west-buf=0 --width-east-buf=0
if [ -d C2/out_bf16/bin ]; then
  cs_python run.py --suite C2 --name C2/out_bf16 --tag _bf16
else
  echo "BF16 build failed (captured):"; grep -m2 "error" /dev/null || true
fi
