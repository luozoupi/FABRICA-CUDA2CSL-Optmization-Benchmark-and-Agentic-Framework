#!/usr/bin/env bash
# Scaling axis (2026-09-08): P=8 mesh, Mt=Kt=Nt=14 (112x112). Fabric = P+7 x P+3.
set -e
cslc --arch=wse3 ./layout.csl --fabric-dims=15,11 --fabric-offsets=4,1 \
--params=P:8,Mt:14,Kt:14,Nt:14 \
--memcpy --channels=1 -o out
cs_python run.py --name out
