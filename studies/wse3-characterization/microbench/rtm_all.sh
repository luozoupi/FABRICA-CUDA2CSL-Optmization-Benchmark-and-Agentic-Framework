#!/usr/bin/env bash
# Extract runtime-model components for every traced kernel.
cd "$(dirname "$0")/.."
OUT=results/runtime_model
mkdir -p "$OUT"
: > "$OUT/run.log"
for f in results/wse3-full/kernels/*/events.jsonl.gz; do
  k=$(basename "$(dirname "$f")")
  [ -s "$OUT/$k.json" ] && { echo "skip $k" >> "$OUT/run.log"; continue; }
  echo "== $k" >> "$OUT/run.log"
  python3 tools/runtime_model.py "$f" --json "$OUT/$k.json" >> "$OUT/run.log" 2>&1 || echo "FAIL $k" >> "$OUT/run.log"
done
echo FIN >> "$OUT/run.log"
