#!/usr/bin/env python3
"""Export preserved model calls with explicit development-validation verdicts."""
import argparse
import json
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "code_translation"))
from model_artifacts import export_records

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--archive", type=Path, required=True)
    parser.add_argument("--evaluations", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    records = [json.loads(line) for line in args.evaluations.read_text().splitlines() if line]
    print(json.dumps(export_records(args.archive, records, args.out), indent=2))
