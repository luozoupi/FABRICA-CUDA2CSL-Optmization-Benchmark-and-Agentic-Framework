#!/usr/bin/env bash
set -e

nvcc -O3 -o pcg kernel.cu
./pcg 256 500
./pcg 512 500
