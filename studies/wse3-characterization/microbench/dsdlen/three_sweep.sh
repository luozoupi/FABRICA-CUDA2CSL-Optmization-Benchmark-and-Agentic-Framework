#!/usr/bin/env bash
export PATH=/software/cerebras/cs_sdk-2.10:$PATH
cd "$(dirname "$0")"
: > three.txt
for n in 7000 7400 7480 7488 7492 7496 7500 7600; do
  rm -rf out3
  if cslc ./three_layout.csl --arch=wse3 --fabric-dims=8,3 --fabric-offsets=4,1 \
     --params=n:$n -o out3 --memcpy --channels=1 --width-west-buf=0 --width-east-buf=0 > t.log 2>&1; then
    ms=$(cs_readelf --ms out3/bin/out_0_0.elf 2>/dev/null | grep -oE '[0-9]+ bytes' | head -1)
    echo "n=$n OK   3*n*2=$((3*n*2))B  elf=${ms:-?}" >> three.txt
  else
    echo "n=$n FAIL 3*n*2=$((3*n*2))B  $(grep -iE 'ran out|error' t.log | head -1 | cut -c1-70)" >> three.txt
  fi
done
echo FIN >> three.txt
