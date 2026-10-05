#!/usr/bin/env bash

set -e

# strong scaling on the small size's class (hb_n1024): 8 PEs, same matrices, half the rows per PE
cslc ./layout.csl --arch=wse3 --fabric-dims=15,3 --fabric-offsets=4,1 \
--params=P:8,nrows_pe:128,ncols:1024,max_nnz_pe:1536,iters:1,structure_id:0 \
-o out --memcpy --channels=1 --width-west-buf=0 --width-east-buf=0
cs_python run.py --name out
