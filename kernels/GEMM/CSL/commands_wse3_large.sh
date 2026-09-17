#!/usr/bin/env bash
# Phase-2 LARGE size for GEMM: 240x240 (P=8, Mt=Kt=Nt=30).
# This problem OVERFLOWS per-PE SRAM on a 4x4 mesh ("ld.lld: ran out of PE
# memory"), so it can only run by decomposing onto a larger (8x8) mesh — this
# is the size at which the benchmark rewards better decomposition. Fabric grown
# to 15x11 to host the 8x8 core + memcpy halo. Reference: 626165 cycles.
set -e

cslc --arch=wse3 ./layout.csl --fabric-dims=15,11 --fabric-offsets=4,1 \
--params=P:8,Mt:30,Kt:30,Nt:30 \
--memcpy --channels=1 -o out
cs_python run.py --name out
