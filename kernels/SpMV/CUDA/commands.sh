#!/usr/bin/env bash
set -e

nvcc -O3 -o spmv kernel.cu
./spmv 4096 0.01
./spmv 8192 0.005
