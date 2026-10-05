#!/usr/bin/env bash
# Build and run the ILP microbench. Usage: ./commands.sh [iters]
set -e
ITERS=${1:-512}
export PATH=/software/cerebras/cs_sdk-2.10:$PATH
cd "$(dirname "$0")"
python3 gen.py
cslc ./layout.csl --arch=wse3 --fabric-dims=8,3 --fabric-offsets=4,1 \
  --params=iters:"$ITERS" \
  -o out --memcpy --channels=1 --width-west-buf=0 --width-east-buf=0
cs_python run.py --name out
