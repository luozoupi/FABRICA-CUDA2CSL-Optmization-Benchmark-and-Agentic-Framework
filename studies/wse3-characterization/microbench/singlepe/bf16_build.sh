#!/usr/bin/env bash
# BF16 comparison: same C2 suite with the half type spelled `bf16`, which is
# what --fp16-format=bf16 requires (f16 becomes comptime-only under it -- probed).
set -e
export PATH=/software/cerebras/cs_sdk-2.10:$PATH
cd "$(dirname "$0")"
mkdir -p C2bf
# \bf16\b cannot match inside "bf16" (b|f is not a word boundary), so this is safe.
sed -E 's/\bf16\b/bf16/g' C2/pe.csl > C2bf/pe.csl
cp C2/layout.csl C2bf/layout.csl
cp C2/meta.json C2bf/meta.json
rm -rf C2bf/out
cslc C2bf/layout.csl --arch=wse3 --fabric-dims=8,3 --fabric-offsets=4,1 \
  --fp16-format=bf16 -o C2bf/out --memcpy --channels=1 \
  --width-west-buf=0 --width-east-buf=0
cs_python run.py --suite C2bf
