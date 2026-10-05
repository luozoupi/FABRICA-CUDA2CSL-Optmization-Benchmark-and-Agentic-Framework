#!/usr/bin/env bash
# Frozen fixture strong-m16-k16-n16-p4-d3-full (studies/spgemm-scaling-20260924); the compile line is the study's own.
set -e
cslc layout.csl --arch=wse3 --fabric-dims=9,4 --fabric-offsets=4,1 --memcpy --channels=1 --width-west-buf=0 --width-east-buf=0 --params=S:2,N:16,K:16,R:4,AC:32,BC:48,OC:36,W:16 -o out
cs_python run.py --name out
