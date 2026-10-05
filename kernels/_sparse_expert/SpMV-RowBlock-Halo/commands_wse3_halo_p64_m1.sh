#!/usr/bin/env bash

set -e

cslc ./layout.csl --arch=wse3 --fabric-dims=71,3 --fabric-offsets=4,1 \
--params=P:64,nrows_pe:27,halo:8,max_nnz_pe:256,mode:1,iters:1,structure_id:2,rcm:1 \
-o out --memcpy --channels=1 --width-west-buf=0 --width-east-buf=0
cs_python run.py --name out
