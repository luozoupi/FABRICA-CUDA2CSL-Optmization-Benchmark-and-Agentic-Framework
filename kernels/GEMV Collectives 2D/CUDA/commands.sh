#!/usr/bin/env bash
set -e

nvcc -O3 -o gemv_2d kernel.cu
./gemv_2d 512 1024
./gemv_2d 2048 4096
