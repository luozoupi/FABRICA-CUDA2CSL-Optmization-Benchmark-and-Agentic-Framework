#!/usr/bin/env bash
set -e

nvcc -O3 -o gol kernel.cu
./gol 64 100
./gol 256 100
./gol 1024 50
