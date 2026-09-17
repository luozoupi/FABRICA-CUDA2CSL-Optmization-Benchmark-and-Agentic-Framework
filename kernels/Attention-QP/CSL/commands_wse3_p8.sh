#!/usr/bin/env bash
# Query-parallel dense attention on an 8x8 PE grid: S=128, d=32 (p8 scaling size).
# Literal --params (P, St_q, S = P*P*St_q, d, causal); the harness and the
# hardware porter both read this line verbatim, so no shell variables here.
set -e
cslc --arch=wse3 ./layout.csl --fabric-dims=15,10 --fabric-offsets=4,1 \
  --params=P:8,St_q:2,S:128,d:32,causal:0 \
  --memcpy --channels=1 -o out
cs_python run.py --name out
