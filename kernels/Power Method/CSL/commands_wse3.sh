#!/usr/bin/env bash

set -e

cslc ./src/layout_power.csl --arch wse3 --fabric-dims=12,7 --fabric-offsets=4,1 \
--params=width:5,height:5,MAX_ZDIM:5 --params=BLOCK_SIZE:2 --params=C0_ID:0 \
--params=C1_ID:1 --params=C2_ID:2 --params=C3_ID:3 --params=C4_ID:4 --params=C5_ID:5 \
--params=C6_ID:6 --params=C7_ID:7 --params=C8_ID:8 -o=out \
--memcpy --channels=1 --width-west-buf=0 --width-east-buf=0
# --max-ite raised 1 → 10 (2026-06-04). Initial bump to 20 caused
# assert_allclose(rtol=1e-5) failures because 20 iterations of Power Method
# at 5×5×5 problem size accumulate ~1.2e-5 numerical drift vs the numpy
# reference, which exceeds the host-side tolerance. 10 iters is enough to
# amortize launch+reduce overhead in cycles_send while staying inside the
# original tolerance band. (If we ever want 20+ iters here we'd also need
# to loosen rtol in run.py, which changes the verification contract.)
cs_python ./run.py -m=5 -n=5 -k=5 --latestlink out --channels=1 \
--width-west-buf=0 --width-east-buf=0 --zDim=5 --run-only --max-ite=10
