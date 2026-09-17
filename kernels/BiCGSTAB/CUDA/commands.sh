#!/usr/bin/env bash
set -e

nvcc -O3 -o bicgstab kernel.cu
./bicgstab 256 500
./bicgstab 512 500
