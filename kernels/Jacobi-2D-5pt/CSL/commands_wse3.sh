#!/usr/bin/env bash
# Build and run the manual jacobi2d_5pt CSL kernel on the WSE-3 simulator.
set -e

cslc ./layout.csl --arch=wse3 --fabric-dims=9,4 --fabric-offsets=4,1 \
  --params=width:2,height:2 --params=Mt:4,Nt:4 \
  -o=out --memcpy --channels=1 \
  --width-west-buf=0 --width-east-buf=0

cs_python run.py --name out --iters 1
