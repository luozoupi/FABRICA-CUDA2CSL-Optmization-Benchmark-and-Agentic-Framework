#!/usr/bin/env bash
# Build & run the CUDA reference for Laplacian2D-Halo. Requires an NVIDIA GPU
# and CUDA toolkit. Not needed for the CSL build path (the xkernel agent only
# reads kernel.cu as input source).
set -e
nvcc -O2 -arch=sm_70 kernel.cu -o laplacian2d_halo
./laplacian2d_halo 8 8 1
./laplacian2d_halo 8 8 3
