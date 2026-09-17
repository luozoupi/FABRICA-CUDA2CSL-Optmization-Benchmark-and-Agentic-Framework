#!/usr/bin/env bash
set -e

nvcc -O3 -o gemv_checker kernel.cu
./gemv_checker 512 1024
./gemv_checker 2048 4096
