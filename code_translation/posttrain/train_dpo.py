#!/usr/bin/env python3
"""DPO (LoRA) on the preference pairs: passing vs failing translations, faster vs failed/slower candidates.

    python -m posttrain.train_dpo --data results/posttrain_<date> --model <sft-model> --out runs/dpo \
        [--sets translate_pairs] [--exclude-models ...]

Usually run after SFT, from the SFT checkpoint. Written against TRL >= 0.19.
"""
import argparse
import json
from pathlib import Path


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--data", required=True)
    ap.add_argument("--model", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--sets", default="translate_pairs")
    ap.add_argument("--exclude-models", default="")
    ap.add_argument("--beta", type=float, default=0.1)
    ap.add_argument("--lr", type=float, default=5e-6)
    ap.add_argument("--max-length", type=int, default=16384)
    ap.add_argument("--verified", action="store_true", help="use *.train.verified.jsonl")
    a = ap.parse_args()

    from datasets import Dataset
    from peft import LoraConfig
    from trl import DPOConfig, DPOTrainer

    excl = [e.strip().lower() for e in a.exclude_models.split(",") if e.strip()]
    rows = []
    for s in a.sets.split(","):
        f = Path(a.data) / "dpo" / f"{s}.train{'.verified' if a.verified else ''}.jsonl"
        if f.exists():
            for line in open(f):
                r = json.loads(line)
                if any(e in (r.get("meta") or {}).get("source_model", "").lower() for e in excl):
                    continue
                rows.append({"prompt": r["prompt"], "chosen": r["chosen"], "rejected": r["rejected"]})
    print(f"{len(rows)} pairs")
    cfg = DPOConfig(output_dir=a.out, beta=a.beta, learning_rate=a.lr, per_device_train_batch_size=1,
                    gradient_accumulation_steps=16, gradient_checkpointing=True, bf16=True, max_length=a.max_length,
                    num_train_epochs=1, logging_steps=10, save_steps=200, report_to="none")
    trainer = DPOTrainer(model=a.model, args=cfg, train_dataset=Dataset.from_list(rows),
                         peft_config=LoraConfig(r=64, lora_alpha=128, target_modules="all-linear", task_type="CAUSAL_LM"))
    trainer.train()
    trainer.save_model(a.out)


if __name__ == "__main__":
    main()
