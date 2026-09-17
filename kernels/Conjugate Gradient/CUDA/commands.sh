#!/usr/bin/env bash
set -e

nvcc -O3 -o cg kernel.cu
./cg 256 500
./cg 512 500
