#!/usr/bin/env bash

set -e

# SpMV-RowBlock-Iter: ten products of a resident matrix with a per-product recurrence on x
# (each PE feeds 0.25 * its y block back into its own block of its local x copy), so consecutive
# products are not loop-invariant. Same matrices, strip and caps as SpMV-RowBlock small.
cslc ./layout.csl --arch=wse3 --fabric-dims=11,3 --fabric-offsets=4,1 \
--params=P:4,nrows_pe:256,ncols:1024,max_nnz_pe:2560,iters:10,structure_id:0 \
-o out --memcpy --channels=1 --width-west-buf=0 --width-east-buf=0
cs_python run.py --name out
