#!/usr/bin/env bash

set -e

cslc ./layout.csl --arch=wse3 --fabric-dims=23,18 --fabric-offsets=4,1 \
--params=Pc:16,Pr:16,nr:108,ncols:2048,max_nnz_pe:512,structure_id:2,perm:0 \
-o out --memcpy --channels=1 --width-west-buf=0 --width-east-buf=0
cs_python run.py --name out
