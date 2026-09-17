#!/usr/bin/env bash
# Phase-2 LARGE size for Laplacian2D-Halo: Mt=Nt=16 per-PE tile (was 4) on the
# 2x2 mesh. Largest tile that runs clean on 2x2 (Mt>=32 fails at runtime —
# the fixed-mesh kernel can't hold/route a bigger halo, which is itself the
# decomposition signal: scaling beyond this REQUIRES a larger mesh). 15x cycle
# growth (1709 -> 25627). Crossover measured 2026-06-20 (crossover_report).
# FUTURE stronger config: Mt=32 on a 4x4+ mesh (decomposition-forcing) once the
# halo kernel is generalized past the hard-coded 2x2 assumptions.
set -e

cslc ./layout.csl --arch=wse3 --fabric-dims=9,4 --fabric-offsets=4,1 \
  --params=width:2,height:2 --params=Mt:16,Nt:16 \
  -o=out --memcpy --channels=1 \
  --width-west-buf=0 --width-east-buf=0

cs_python run.py --name out --iters 1
