#!/usr/bin/env bash
set -e

nvcc -O3 -o fft kernel.cu
echo "=== 1D FFT ==="
./fft 1024
./fft 4096
echo "=== 2D FFT ==="
./fft 64 1
./fft 128 1
