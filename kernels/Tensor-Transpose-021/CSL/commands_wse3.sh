#!/usr/bin/env bash

set -e

cslc ./layout.csl --arch wse3 --fabric-dims=9,4 \
--fabric-offsets=4,1 \
--params=width:2,height:2,ax1:8,ax2:8,ax3:8 \
-o out --memcpy --channels=1
cs_python ./run.py --name out
