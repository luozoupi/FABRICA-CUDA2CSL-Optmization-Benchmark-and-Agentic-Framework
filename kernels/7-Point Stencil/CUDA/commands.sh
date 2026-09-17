#!/usr/bin/env bash
set -e

nvcc -O3 -o stencil7 kernel.cu
./stencil7 64 10
./stencil7 128 10
./stencil7 256 5
