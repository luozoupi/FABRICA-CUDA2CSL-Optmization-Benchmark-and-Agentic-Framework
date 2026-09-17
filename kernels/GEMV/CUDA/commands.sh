#!/usr/bin/env bash
set -e

nvcc -O3 -o gemv kernel.cu
./gemv 512 1024
./gemv 2048 4096
