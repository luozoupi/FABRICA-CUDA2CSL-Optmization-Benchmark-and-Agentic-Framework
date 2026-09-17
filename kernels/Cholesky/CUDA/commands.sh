#!/usr/bin/env bash
set -e

nvcc -O3 -o cholesky kernel.cu
./cholesky 128
./cholesky 256
./cholesky 512
