#!/usr/bin/env bash
# Find the DSD extent field's own ceiling, independent of memory: the backing
# array stays at 1024 while the declared extent grows. Literals are used rather
# than a param because `param x: i16` caps at 32767.
export PATH=/software/cerebras/cs_sdk-2.10:$PATH
cd "$(dirname "$0")"
: > extent_limit.txt
for L in 32767 32768 49152 65534 65535 65536 131071 262143; do
  sed "s/|i|{dsdlen}/|i|{$L}/" pe.csl > pe_lit.csl
  sed 's/"pe.csl"/"pe_lit.csl"/' layout.csl > layout_lit.csl
  rm -rf outl
  if cslc ./layout_lit.csl --arch=wse3 --fabric-dims=8,3 --fabric-offsets=4,1 \
     --params=dsdlen:1024 -o outl --memcpy --channels=1 \
     --width-west-buf=0 --width-east-buf=0 > ll.log 2>&1; then
    echo "$L OK" >> extent_limit.txt
  else
    echo "$L FAIL $(grep -iE 'error' ll.log | head -1 | cut -c1-100)" >> extent_limit.txt
  fi
done
echo FIN >> extent_limit.txt
