#!/usr/bin/env bash

set -e

# second matrix class (hb_n144): rows 2.5x longer than the small class, so each merge is ~6x more steps
cslc ./layout.csl --arch=wse3 --fabric-dims=8,3 --fabric-offsets=4,1 \
--params=n:144,max_nnz:1536,iters:1,structure_id:1 \
-o out --memcpy --channels=1 --width-west-buf=0 --width-east-buf=0
cs_python run.py --name out
