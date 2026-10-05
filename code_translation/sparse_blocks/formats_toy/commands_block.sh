#!/usr/bin/env bash

set -e

cslc ./layout.csl --arch=wse3 --fabric-dims=8,3 --fabric-offsets=4,1 \
--params=N:128,CAP:1536,DENSE:0,NB:128 \
-o out --memcpy --channels=1 --width-west-buf=0 --width-east-buf=0
cs_python run.py --name out --kind block --N 128 --CAP 1536 --dense 0
