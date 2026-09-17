#!/usr/bin/env bash
set -e

nvcc -O3 -o matvec kernel.cu
./matvec 64
./matvec 256
./matvec 512
