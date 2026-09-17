#!/usr/bin/env bash
set -e

nvcc -O3 -o histogram kernel.cu
./histogram 1048576 256 16
./histogram 4194304 512 8
