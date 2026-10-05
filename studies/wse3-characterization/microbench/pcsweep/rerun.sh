#!/usr/bin/env bash
# Rerun the transport-failed classes plus the two asm chain classes, then batch D. Sequential: one
# container job at a time.
cd "$(dirname "$0")"
while pgrep -f "finish.sh" > /dev/null; do sleep 10; done
python3 -u build.py --only cflag_jmp dsr_dlast dsr_s1last mem reduce f16chain_asm i16chain_asm
echo "=== sweep rerun done $(date)"
../../external/run_d.sh
