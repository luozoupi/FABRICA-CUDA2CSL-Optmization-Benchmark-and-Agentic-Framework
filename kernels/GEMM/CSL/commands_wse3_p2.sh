#!/usr/bin/env bash
# Scaling axis (2026-09-08): P=2 mesh, Mt=Kt=Nt=14 (28x28). Fabric = P+7 x P+3.
set -e
cslc --arch=wse3 ./layout.csl --fabric-dims=9,5 --fabric-offsets=4,1 \
--params=P:2,Mt:14,Kt:14,Nt:14 \
--memcpy --channels=1 -o out
cs_python run.py --name out
