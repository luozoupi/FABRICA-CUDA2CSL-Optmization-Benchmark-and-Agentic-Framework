#!/usr/bin/env bash
# Scaling axis (2026-09-08): 2x2 PE grid, matrix 16x8. Fabric = cols+7 x rows+3.
set -e
cslc --arch=wse3 ./layout.csl --fabric-dims=9,5 --fabric-offsets=4,1 \
--params=kernel_rows:2,kernel_cols:2,matrix_rows:16,matrix_cols:8 \
--memcpy --channels=1 -o out
cs_python run.py --name out
