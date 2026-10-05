#!/usr/bin/env bash
export PATH=/software/cerebras/cs_sdk-2.10:$PATH
cd "$(dirname "$0")"
: > shape.txt
for n in 80 84 85 86 87 88 90; do
  rm -rf outs
  if cslc ./shape_layout.csl --arch=wse3 --fabric-dims=8,3 --fabric-offsets=4,1 \
       --params=n:"$n" -o outs --memcpy --channels=1 \
       --width-west-buf=0 --width-east-buf=0 > shape.log 2>&1; then
    ms=$(cs_readelf --ms outs/bin/out_0_0.elf 2>/dev/null | grep -oE '[0-9]+ bytes' | head -1)
    echo "n=$n OK  3n^2*2=$((3*n*n*2))B  elf=${ms:-?}" >> shape.txt
  else
    echo "n=$n FAIL 3n^2*2=$((3*n*n*2))B  $(grep -iE 'ran out|error' shape.log | head -1 | cut -c1-90)" >> shape.txt
  fi
done
echo FIN >> shape.txt
