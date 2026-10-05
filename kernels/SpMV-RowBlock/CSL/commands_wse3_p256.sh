#!/usr/bin/env bash

set -e

cslc ./layout.csl --arch=wse3 --fabric-dims=263,3 --fabric-offsets=4,1 \
--params=P:256,nrows_pe:7,ncols:2048,max_nnz_pe:64,iters:1,structure_id:2 \
-o out --memcpy --channels=1 --width-west-buf=0 --width-east-buf=0
cs_python run.py --name out
