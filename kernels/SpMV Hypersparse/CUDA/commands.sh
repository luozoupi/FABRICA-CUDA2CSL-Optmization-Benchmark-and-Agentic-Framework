#!/usr/bin/env bash
set -e

nvcc -O3 -o spmv_hyper kernel.cu
./spmv_hyper 4096 0.001
./spmv_hyper 8192 0.0005
