#!/usr/bin/env bash
set -e

nvcc -O3 -o gemm_2d kernel.cu
./gemm_2d 256
./gemm_2d 512
