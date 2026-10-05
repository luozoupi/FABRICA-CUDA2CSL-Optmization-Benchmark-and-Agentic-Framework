#!/usr/bin/env bash

set -e

cslc ./layout.csl --arch=wse3 --fabric-dims=8,3 --fabric-offsets=4,1 \
--params=P:1,Mt:144,K:144,Nt:16,max_nnz_pe:1536,iters:1,structure_id:1 \
-o out --memcpy --channels=1 --width-west-buf=0 --width-east-buf=0
cs_python run.py --name out
