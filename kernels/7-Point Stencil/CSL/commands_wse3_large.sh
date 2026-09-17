#!/usr/bin/env bash
# Phase-2 LARGE size for 7-Point Stencil: MAX_ZDIM / zDim = 60 (was 5).
# Compute-dominant scaling: cycles grow with the z-pencil length (2129 @ zDim=5
# -> 17134 @ zDim=60) on the same 5x5 mesh, no overflow. NOTE: the z size is
# DUAL-SOURCED — the compile --params=MAX_ZDIM and the run.py -k/--zDim MUST
# match. Reference measured in the crossover sweep (cycles_send = 17134, SUCCESS).
set -e

cslc ./src/layout.csl --arch wse3 --fabric-dims=12,7 --fabric-offsets=4,1 \
--params=width:5,height:5,MAX_ZDIM:60 --params=BLOCK_SIZE:2 --params=C0_ID:0 \
--params=C1_ID:1 --params=C2_ID:2 --params=C3_ID:3 --params=C4_ID:4 --params=C5_ID:5 \
--params=C6_ID:6 --params=C7_ID:7 --params=C8_ID:8 -o=out \
--memcpy --channels=1 --width-west-buf=0 --width-east-buf=0
cs_python ./run.py -m=5 -n=5 -k=60 --latestlink out --channels=1 \
--width-west-buf=0 --width-east-buf=0 --zDim=60 --run-only
