#!/usr/bin/env bash

set -e

cslc ./layout.csl --arch=wse3 --fabric-dims=8,3 --fabric-offsets=4,1 \
--params=N:64,CAP:1280,DENSE:1,NB:4 \
-o out --memcpy --channels=1 --width-west-buf=0 --width-east-buf=0
cs_python run.py --name out --kind random --N 64 --CAP 1280 --dense 1 --bsr 0
