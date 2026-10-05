#!/usr/bin/env bash

set -e

cslc ./layout.csl --arch=wse3 --fabric-dims=11,6 --fabric-offsets=4,1 \
--params=P:4,Mt:128,K:512,Nt:8,max_nnz_pe:1024,iters:1,structure_id:2 \
-o out --memcpy --channels=1 --width-west-buf=0 --width-east-buf=0
cs_python run.py --name out
