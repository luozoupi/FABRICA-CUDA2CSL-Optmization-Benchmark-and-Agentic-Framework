#!/usr/bin/env bash
# Phase-2 LARGE size for GEMV: 512x256 on an 8x8 mesh.
# This matrix OVERFLOWS a 4x4 mesh (the small-size mesh) and only runs by
# decomposing onto 8x8 — a decomposition-forcing config. Fabric grown to 15x11
# to host the 8x8 core + memcpy halo. Reference: 10309 cycles.
set -e

cslc --arch=wse3 ./layout.csl --fabric-dims=15,11 --fabric-offsets=4,1 \
--params=kernel_rows:8,kernel_cols:8,matrix_rows:512,matrix_cols:256 \
--memcpy --channels=1 -o out
cs_python run.py --name out
