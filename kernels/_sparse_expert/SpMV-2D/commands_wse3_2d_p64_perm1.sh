#!/usr/bin/env bash

set -e

cslc ./layout.csl --arch=wse3 --fabric-dims=15,10 --fabric-offsets=4,1 \
--params=Pc:8,Pr:8,nr:216,ncols:2048,max_nnz_pe:1024,structure_id:2,perm:1 \
-o out --memcpy --channels=1 --width-west-buf=0 --width-east-buf=0
cs_python run.py --name out
