#!/usr/bin/env bash
# Dense attention reference, single PE: S=64 queries/keys, d=16 (small).
# Literal --params (P, St_q, S = P*P*St_q, d, causal); the harness and the
# hardware porter both read this line verbatim, so no shell variables here.
set -e
cslc --arch=wse3 ./layout.csl --fabric-dims=8,3 --fabric-offsets=4,1 \
  --params=P:1,St_q:64,S:64,d:16,causal:0 \
  --memcpy --channels=1 -o out
cs_python run.py --name out
