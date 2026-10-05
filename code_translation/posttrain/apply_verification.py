#!/usr/bin/env python3
"""Propagate SDK re-verification of sft/translate records to every file that uses the same programs.

    python -m posttrain.apply_verification --data results/posttrain_<date> --verified a.verified.jsonl [b.verified.jsonl ...]

A program passes when posttrain.csl_reward --check gave it reward >= 1.0. Writes, next to each training
file, <name>.verified.jsonl with only the records whose target program passed (translate,
translate_compact, trajectories: the final assistant program; dpo/translate_pairs: the chosen program),
and records the counts in verification.json.
"""
import argparse, json, sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from posttrain import common as C


def prog(content: str) -> str:
    return C.sha((C.first_csl(content) or "").strip())


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--data", required=True)
    ap.add_argument("--verified", nargs="+", required=True)
    a = ap.parse_args()
    d = Path(a.data)
    ok, seen = set(), 0
    for f in a.verified:
        for line in open(f):
            r = json.loads(line); seen += 1
            if (r["meta"].get("verified_reward") or 0) >= 1.0:
                ok.add(prog(r["messages"][-1]["content"]))
    report = {"checked": seen, "passed_programs": len(ok), "files": {}}
    for name, get in (("sft/translate", lambda r: r["messages"][-1]["content"]),
                      ("sft/translate_compact", lambda r: r["messages"][-1]["content"]),
                      ("sft/trajectories", lambda r: r["messages"][-1]["content"]),
                      ("dpo/translate_pairs", lambda r: r["chosen"][-1]["content"])):
        src = d / f"{name}.train.jsonl"
        if not src.exists():
            continue
        rows = [json.loads(l) for l in open(src)]
        keep = [r for r in rows if prog(get(r)) in ok]
        C.write_jsonl(d / f"{name}.train.verified.jsonl", keep)
        report["files"][name] = {"records": len(rows), "verified": len(keep)}
    (d / "verification.json").write_text(json.dumps(report, indent=2))
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
