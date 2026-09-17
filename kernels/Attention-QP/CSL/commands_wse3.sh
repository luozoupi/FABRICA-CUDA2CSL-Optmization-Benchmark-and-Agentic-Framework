#!/usr/bin/env bash
# Query-parallel dense attention on a 4x4 PE grid: S=64, d=32 (small).
# Literal --params (P, St_q, S = P*P*St_q, d, causal); the harness and the
# hardware porter both read this line verbatim, so no shell variables here.
set -e
cslc --arch=wse3 ./layout.csl --fabric-dims=11,6 --fabric-offsets=4,1 \
  --params=P:4,St_q:4,S:64,d:32,causal:0 \
  --memcpy --channels=1 -o out
cs_python run.py --name out
