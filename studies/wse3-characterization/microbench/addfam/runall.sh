#!/usr/bin/env bash
# Execute every case and check its numerical result. Compilation and correctness are separate
# acceptance checks: this one says nothing about instruction counts.
export PATH=/software/cerebras/cs_sdk-2.10:$PATH
cd "$(dirname "$0")"
for d in cases/*/; do
  n=$(basename "$d")
  cs_python run.py --name "$n" --dir "$d" 2>&1 | grep -vE "^\[INFO|^.\[34m|Terminating|Timeouts|background" || true
done
