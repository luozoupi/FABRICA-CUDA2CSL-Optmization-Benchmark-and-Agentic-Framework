#!/usr/bin/env bash
set -e

cslc ./layout.csl --arch=wse3 --fabric-dims=8,7 --fabric-offsets=4,1 \
  --params=Py:4,n_per_pe:64,n_buckets:16,bucket_size:64 \
  -o=out --memcpy --channels=1 \
  --width-west-buf=0 --width-east-buf=0

cs_python run.py --name out
