#!/usr/bin/env bash
set -e

nvcc -O3 -o transpose021 kernel.cu
./transpose021 8 8 8
./transpose021 16 12 20
