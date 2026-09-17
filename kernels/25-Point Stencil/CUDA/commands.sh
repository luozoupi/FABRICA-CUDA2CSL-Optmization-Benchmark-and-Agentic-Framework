#!/usr/bin/env bash
set -e

nvcc -O3 -o stencil25 kernel.cu
./stencil25 64 10
./stencil25 128 10
