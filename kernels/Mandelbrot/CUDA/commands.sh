#!/usr/bin/env bash
set -e

nvcc -O3 -o mandelbrot kernel.cu
./mandelbrot 512 256
./mandelbrot 2048 1000
