#!/usr/bin/env bash
# Sweep stages N and payload B on the simulator.
export PATH=/software/cerebras/cs_sdk-2.10:$PATH
cd "$(dirname "$0")"
python3 gen.py
: > sweep.txt
for B in 64 512; do for N in 1 2 4 8; do
  rm -rf out
  if cslc ./layout.csl --arch=wse3 --fabric-dims=16,3 --fabric-offsets=4,1 \
       --params=N:$N,B:$B -o out --memcpy --channels=1 --width-west-buf=0 --width-east-buf=0 > c.log 2>&1; then
    cs_python run.py --name out 2>&1 | grep RELAY >> sweep.txt || echo "N=$N B=$B RUN-FAIL" >> sweep.txt
  else
    echo "N=$N B=$B COMPILE-FAIL $(grep -m1 error: c.log | cut -c1-120)" >> sweep.txt
  fi
done; done
echo FIN >> sweep.txt
