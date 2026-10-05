#!/usr/bin/env python3
"""Ask one model every probe item once; write responses.jsonl (item id, group, prompt, reply, usage)."""
from __future__ import annotations

import argparse
import json
import os
import sys
import time
from pathlib import Path

import yaml

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
from workflow_common import create_anthropic_client, create_openai_client, is_anthropic_model, llm_complete  # noqa: E402

SYSTEM = "You are an expert Cerebras CSL programmer. Follow the answer format the question asks for exactly."


def load_items(groups):
    items = []
    for f in sorted((HERE / "items").glob("*.yaml")):
        it = yaml.safe_load(f.read_text())
        if not groups or it["group"] in groups:
            items.append(it)
    return items


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--model", required=True)
    ap.add_argument("--api-key-file", default=os.path.expanduser("~/claude-api-key.txt"))
    ap.add_argument("--base-url", default=None, help="OpenAI-compatible endpoint for non-Anthropic models")
    ap.add_argument("--groups", default="", help="comma list, e.g. A_syntax,D_api (default all)")
    ap.add_argument("--max-tokens", type=int, default=2500)
    ap.add_argument("--out", required=True)
    ap.add_argument("--limit", type=int, default=0)
    a = ap.parse_args()
    groups = {g.strip() for g in a.groups.split(",") if g.strip()}
    items = load_items(groups)
    if a.limit:
        items = items[: a.limit]
    client = create_anthropic_client(a.api_key_file) if is_anthropic_model(a.model) else create_openai_client(a.api_key_file, a.base_url)
    out = Path(a.out); out.mkdir(parents=True, exist_ok=True)
    path = out / "responses.jsonl"
    done = set()
    if path.exists():
        done = {json.loads(l)["id"] for l in path.read_text().splitlines() if l.strip()}
    with open(path, "a", encoding="utf-8") as fh:
        for it in items:
            if it["id"] in done:
                continue
            t0 = time.time()
            reply = llm_complete(client, a.model, [{"role": "system", "content": SYSTEM}, {"role": "user", "content": it["prompt"]}], a.max_tokens)
            fh.write(json.dumps({"id": it["id"], "group": it["group"], "model": a.model, "reply": reply,
                                 "elapsed_s": round(time.time() - t0, 1), "ts": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())}) + "\n")
            fh.flush()
            print(f"{it['id']:22s} {len(reply):6d} chars {time.time() - t0:5.1f}s")
    print("wrote", path)
    return 0


if __name__ == "__main__":
    sys.exit(main())
