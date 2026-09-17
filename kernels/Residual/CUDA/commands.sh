#!/usr/bin/env bash
set -e

nvcc -O3 -o residual kernel.cu
./residual 512 512
./residual 2048 2048
