#!/usr/bin/env python3
"""Convert the GRPO prompt files to veRL's parquet schema (rollouts with SGLang or vLLM).

    python -m posttrain.to_verl --data results/posttrain_<date> --out results/posttrain_<date>/verl \
        [--level run] [--sets translate,optimize]

Each row: data_source, prompt (chat messages), ability, reward_model {style, ground_truth}, extra_info
(everything posttrain.csl_reward.verl_compute_score needs: kernel, reference_dir, target_relpath,
commands_script, base_cycles, base_code, reward_level, heldout). Requires pandas + pyarrow.
"""
import argparse
import json
from pathlib import Path


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--data", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--sets", default="translate,optimize")
    ap.add_argument("--level", default="run", choices=("compile", "run"))
    ap.add_argument("--no-heldout", action="store_true")
    a = ap.parse_args()
    import pandas as pd
    out = Path(a.out); out.mkdir(parents=True, exist_ok=True)
    for split in ("train", "eval_sparse", "eval_general"):
        rows = []
        for s in a.sets.split(","):
            f = Path(a.data) / "grpo" / f"{s}_prompts.{split}.jsonl"
            if not f.exists():
                continue
            for line in open(f):
                r = json.loads(line)
                rows.append({"data_source": f"csl_{s}", "prompt": r["prompt"], "ability": "csl_code",
                             "reward_model": {"style": "rule", "ground_truth": r["kernel"]},
                             "extra_info": {"kernel": r["kernel"], "reference_dir": r["reference_dir"],
                                            "target_relpath": r["target_relpath"], "commands_script": r["commands_script"],
                                            "base_cycles": r.get("base_cycles"), "base_code": r.get("base_code") or "",
                                            "reward_level": a.level, "heldout": not a.no_heldout}})
        if rows:
            pd.DataFrame(rows).to_parquet(out / f"{split}.parquet")
            print(f"{split}: {len(rows)} rows")


if __name__ == "__main__":
    main()
