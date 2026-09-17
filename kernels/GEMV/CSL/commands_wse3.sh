#!/usr/bin/env bash

set -e

cslc --arch=wse3 ./layout.csl --fabric-dims=11,6 --fabric-offsets=4,1 \
--params=kernel_rows:4,kernel_cols:4,matrix_rows:32,matrix_cols:16 \
--memcpy --channels=1 -o out
# WS2/WS5: timed run + 2 extra seeds for multi-input correctness. Per-process
# (fresh load per seed): main() is non-idempotent for collective kernels, so
# re-launching it in one program session yields garbage — multi-seed must
# re-run the whole program. (Caught by the WS5 multi-seed discipline 2026-06-20.)
cs_python run.py --name out --seed 7
cs_python run.py --name out --seed 8
cs_python run.py --name out --seed 9
