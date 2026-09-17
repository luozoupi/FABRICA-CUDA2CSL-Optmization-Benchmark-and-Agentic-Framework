#!/usr/bin/env bash
set -e

nvcc -O3 -o wide_mul kernel.cu
./wide_mul 128 1024
./wide_mul 256 512
./wide_mul 512 256
