#!/usr/bin/env python3
"""pass@k of a served model (vLLM or SGLang, OpenAI-compatible API) on held-out CSL prompts.

    vllm serve <model> --port 8000          # or: python -m sglang.launch_server --model-path <model> --port 8000
    python -m posttrain.eval_passk --data results/posttrain_<date> --split eval_sparse \
        --base-url http://localhost:8000/v1 --model <served-name> --k 4 [--level run] [--out eval.jsonl]

For every prompt of grpo/{translate,optimize}_prompts.<split>.jsonl the model is sampled k times; every
sample is scored by posttrain.csl_reward (compile + simulate + verify on this machine's SDK).
Reports pass@1 and pass@k (unbiased estimator) per kernel and overall, and the mean reward.
"""
import argparse
import collections
import concurrent.futures as cf
import json
import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))


def pass_at_k(n, c, k):
    if n - c < k:
        return 1.0
    return 1.0 - math.prod((n - c - i) / (n - i) for i in range(k))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--data", required=True)
    ap.add_argument("--split", default="eval_sparse")
    ap.add_argument("--sets", default="translate")
    ap.add_argument("--base-url", required=True)
    ap.add_argument("--model", required=True)
    ap.add_argument("--api-key", default="EMPTY")
    ap.add_argument("--k", type=int, default=4)
    ap.add_argument("--temperature", type=float, default=0.8)
    ap.add_argument("--max-tokens", type=int, default=6144)
    ap.add_argument("--level", default="run", choices=("compile", "run"))
    ap.add_argument("--workers", type=int, default=8)
    ap.add_argument("--limit", type=int, default=0)
    ap.add_argument("--out")
    a = ap.parse_args()
    from openai import OpenAI
    from posttrain.csl_reward import score
    client = OpenAI(base_url=a.base_url, api_key=a.api_key)
    prompts = []
    for s in a.sets.split(","):
        f = Path(a.data) / "grpo" / f"{s}_prompts.{a.split}.jsonl"
        if f.exists():
            prompts += [json.loads(l) for l in open(f)]
    if a.limit:
        prompts = prompts[: a.limit]

    def run(rec):
        resp = client.chat.completions.create(model=a.model, messages=rec["prompt"], n=a.k,
                                              temperature=a.temperature, max_tokens=a.max_tokens)
        outs = []
        for ch in resp.choices:
            r, info = score(ch.message.content or "", rec, level=a.level)
            outs.append({"reward": r, "info": info})
        return rec, outs

    per_kernel = collections.defaultdict(list)
    rows = []
    with cf.ThreadPoolExecutor(max_workers=a.workers) as ex:
        for rec, outs in ex.map(run, prompts):
            c = sum(1 for o in outs if o["reward"] >= 1.0)
            per_kernel[rec["kernel"]].append((len(outs), c, sum(o["reward"] for o in outs) / len(outs)))
            rows.append({"kernel": rec["kernel"], "samples": outs})
    tot = [x for v in per_kernel.values() for x in v]
    for kern, v in sorted(per_kernel.items()):
        print(f"{kern:28s} pass@1 {sum(pass_at_k(n, c, 1) for n, c, _ in v) / len(v):.2f} "
              f"pass@{a.k} {sum(pass_at_k(n, c, a.k) for n, c, _ in v) / len(v):.2f} reward {sum(m for _, _, m in v) / len(v):.2f}")
    print(f"{'ALL':28s} pass@1 {sum(pass_at_k(n, c, 1) for n, c, _ in tot) / len(tot):.3f} "
          f"pass@{a.k} {sum(pass_at_k(n, c, a.k) for n, c, _ in tot) / len(tot):.3f} over {len(tot)} prompts")
    if a.out:
        with open(a.out, "w") as fh:
            for r in rows:
                fh.write(json.dumps(r) + "\n")


if __name__ == "__main__":
    main()
