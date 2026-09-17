#!/usr/bin/env bash

set -e

# On-device variant (2026-06-18, Workstream A): compile layout_pcg.csl ->
# kernel_pcg.csl, whose f_pcg(size,tol,max_ite) runs the full PCG iteration +
# convergence check on-device. run.py is now the on-device runner (single
# f_pcg launch inside the f_tic..f_toc window), so cycles_send measures device
# compute and W2 edits to the (now actually-compiled) kernel_pcg.csl move it.
cslc ./src/layout_pcg.csl --arch wse3 --fabric-dims=12,7 --fabric-offsets=4,1 \
--params=width:5,height:5,MAX_ZDIM:5 --params=BLOCK_SIZE:2 --params=C0_ID:0 \
--params=C1_ID:1 --params=C2_ID:2 --params=C3_ID:3 --params=C4_ID:4 --params=C5_ID:5 \
--params=C6_ID:6 --params=C7_ID:7 --params=C8_ID:8 -o=out \
--memcpy --channels=1 --width-west-buf=0 --width-east-buf=0
cs_python ./run.py -m=5 -n=5 -k=5 --latestlink out --channels=1 \
--width-west-buf=0 --width-east-buf=0 --zDim=5 --run-only --max-ite=2
