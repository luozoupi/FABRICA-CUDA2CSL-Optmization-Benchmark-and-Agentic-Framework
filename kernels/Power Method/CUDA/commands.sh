#!/usr/bin/env bash
set -e

nvcc -O3 -o power kernel.cu
./power 256 100
./power 512 50
