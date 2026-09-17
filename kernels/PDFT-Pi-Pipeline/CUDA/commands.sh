#!/usr/bin/env bash
set -e

nvcc -O3 -o pdft_pi kernel.cu
./pdft_pi 16 4
./pdft_pi 64 4
