#!/usr/bin/env bash
set -e

nvcc -O3 -o gemm kernel.cu
./gemm 256 256 256
./gemm 512 512 512
./gemm 1024 1024 1024
