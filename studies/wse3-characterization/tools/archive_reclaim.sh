#!/bin/bash
# Archive regenerable / duplicated campaign artifacts, then reclaim their inodes.
#
# KEPT in place (provenance chain):
#   ledger.jsonl, measurements.csv, report.*, campaign.json
#   artifacts/**/cs_*.tar.gz  (compile artifacts)  and compile.json
#   kernels/ (layouts, traces, SVGs), models/, calibration/*.jsonl
#
# ARCHIVED then removed:
#   artifacts/**/events/          duplicates ledger.jsonl (verified: same subject/trial/cycles)
#   work/bundles/                 staged compile copies, regenerable
#   calibration/generated-bundles/ deterministic from `study.py calibrate --materialize`
set -uo pipefail
S=$HOME/xkernel/studies/wse3-characterization/results/wse3-full
OUT=${1:-$HOME/wse3_archive}
mkdir -p "$OUT"
ts=$(date -u +%Y%m%dT%H%M%SZ)

before=$(quota -s 2>/dev/null | tail -1 | awk '{print $5}')
echo "inodes before: $before"

echo "== archiving artifacts/**/events =="
find "$S/artifacts" -type d -name events -print0 2>/dev/null \
  | tar --null -czf "$OUT/events-$ts.tar.gz" --files-from=- 2>/dev/null \
  && echo "   -> $OUT/events-$ts.tar.gz ($(du -h "$OUT/events-$ts.tar.gz" | cut -f1))"

echo "== archiving work/bundles =="
tar -czf "$OUT/work-bundles-$ts.tar.gz" -C "$S" work/bundles 2>/dev/null \
  && echo "   -> $OUT/work-bundles-$ts.tar.gz ($(du -h "$OUT/work-bundles-$ts.tar.gz" | cut -f1))"

echo "== archiving calibration/generated-bundles =="
tar -czf "$OUT/generated-bundles-$ts.tar.gz" -C "$S" calibration/generated-bundles 2>/dev/null \
  && echo "   -> $OUT/generated-bundles-$ts.tar.gz ($(du -h "$OUT/generated-bundles-$ts.tar.gz" | cut -f1))"

# only remove what archived successfully
for pair in "events-$ts.tar.gz:EVENTS" "work-bundles-$ts.tar.gz:WORK" "generated-bundles-$ts.tar.gz:GEN"; do
  f="${pair%%:*}"; tag="${pair##*:}"
  [ -s "$OUT/$f" ] || { echo "!! $tag archive missing/empty - NOT removing originals"; continue; }
  case "$tag" in
    EVENTS) find "$S/artifacts" -type d -name events -exec rm -rf {} + 2>/dev/null ;;
    WORK)   rm -rf "$S/work/bundles" ;;
    GEN)    rm -rf "$S/calibration/generated-bundles" ;;
  esac
  echo "   removed originals for $tag"
done

after=$(quota -s 2>/dev/null | tail -1 | awk '{print $5}')
echo "inodes after: $after"
echo "archives in $OUT:"; ls -la "$OUT"
