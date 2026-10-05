#!/usr/bin/env bash

set -e

cslc ./layout.csl --arch=wse3 --fabric-dims=8,3 --fabric-offsets=4,1 \
--params=P:1,nrows_pe:512,ncols:512,max_nnz_pe:2304,iters:1,structure_id:1 \
-o out --memcpy --channels=1 --width-west-buf=0 --width-east-buf=0
cs_python run.py --name out
