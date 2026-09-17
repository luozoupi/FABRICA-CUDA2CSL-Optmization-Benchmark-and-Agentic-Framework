#!/usr/bin/env bash
# Scaling axis (2026-09-08): 8x8 PE grid, matrix 64x32. Fabric = cols+7 x rows+3.
set -e
cslc --arch=wse3 ./layout.csl --fabric-dims=15,11 --fabric-offsets=4,1 \
--params=kernel_rows:8,kernel_cols:8,matrix_rows:64,matrix_cols:32 \
--memcpy --channels=1 -o out
cs_python run.py --name out
