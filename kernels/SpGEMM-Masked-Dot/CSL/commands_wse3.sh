#!/usr/bin/env bash

set -e

cslc ./layout.csl --arch=wse3 --fabric-dims=8,3 --fabric-offsets=4,1 \
--params=n:256,max_nnz:1536,iters:1,structure_id:0 \
-o out --memcpy --channels=1 --width-west-buf=0 --width-east-buf=0
cs_python run.py --name out
