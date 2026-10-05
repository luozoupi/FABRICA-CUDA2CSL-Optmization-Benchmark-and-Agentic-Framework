#!/usr/bin/env bash
export PATH=/software/cerebras/cs_sdk-2.10:$PATH
cd "$(dirname "$0")"
: > probes.txt
for f in p_*.csl; do
  python3 wrap.py "$f"
  rm -rf out
  if cslc ./layout.csl --arch=wse3 --fabric-dims=8,3 --fabric-offsets=4,1 \
       -o out --memcpy --channels=1 --width-west-buf=0 --width-east-buf=0 > c.log 2>&1; then
    echo "${f%.csl} OK" >> probes.txt
  else
    echo "${f%.csl} FAIL $(grep -m1 -E 'error:' c.log | cut -c1-130)" >> probes.txt
  fi
done
echo FIN >> probes.txt
