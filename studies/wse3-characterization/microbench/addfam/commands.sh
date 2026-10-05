#!/usr/bin/env bash
# Add-family compilation model: 18 cases, one factor changed each, IR + machine code captured.
# Needs the Cerebras SDK (a container runtime, or the singularity relay if run from a login node).
set -e
cd "$(dirname "$0")"
python3 build.py                     # compile + capture IR + disassemble every case -> cases.json
python3 ../../tools/addfam_model.py --json model_eval.json    # rules, fit, withheld prediction
