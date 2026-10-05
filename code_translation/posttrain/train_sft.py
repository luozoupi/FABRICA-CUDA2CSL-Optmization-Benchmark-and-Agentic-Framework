#!/usr/bin/env python3
"""Supervised fine-tuning (LoRA) on the CSL datasets with TRL. Single GPU (e.g. RTX Pro 6000, 96 GB).

    python -m posttrain.train_sft --data results/posttrain_<date> --model <hf-id-or-path> \
        --out runs/sft_lora [--sets translate,repair] [--exclude-models claude,gpt-4,gpt-5] [--epochs 2]

Records are converted to TRL's conversational prompt-completion format (prompt = every message but
the last, completion = the final assistant message), so the loss falls on the completion only.
Written against TRL >= 0.19 / PEFT >= 0.15; check argument names against the installed versions
(older TRL calls `max_length` `max_seq_length`). See docs/POSTTRAINING.md for model sizes and memory.
"""
import argparse
import json
from pathlib import Path


def load(data: Path, sets, exclude, split="train", verified=False):
    rows = []
    for s in sets:
        f = data / "sft" / f"{s}.{split}{'.verified' if verified else ''}.jsonl"
        if not f.exists():
            if verified:
                f = data / "sft" / f"{s}.{split}.jsonl"   # sets without a verified file (e.g. repair)
            if not f.exists():
                continue
        for line in open(f):
            r = json.loads(line)
            model = (r.get("meta") or {}).get("source_model", "").lower()
            if any(e in model for e in exclude):
                continue
            msgs = r["messages"]
            rows.append({"prompt": msgs[:-1], "completion": [msgs[-1]]})
    return rows


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--data", required=True)
    ap.add_argument("--model", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--sets", default="translate,repair")
    ap.add_argument("--exclude-models", default="")
    ap.add_argument("--epochs", type=float, default=2.0)
    ap.add_argument("--lr", type=float, default=1e-4)
    ap.add_argument("--max-length", type=int, default=16384)
    ap.add_argument("--lora-r", type=int, default=64)
    ap.add_argument("--load-in-4bit", action="store_true", help="QLoRA, for models above ~30B parameters")
    ap.add_argument("--verified", action="store_true", help="use *.train.verified.jsonl (programs re-checked on this SDK)")
    a = ap.parse_args()

    from datasets import Dataset
    from peft import LoraConfig
    from trl import SFTConfig, SFTTrainer

    exclude = [e.strip().lower() for e in a.exclude_models.split(",") if e.strip()]
    train = load(Path(a.data), a.sets.split(","), exclude, "train", verified=a.verified)
    evalset = load(Path(a.data), a.sets.split(","), exclude, "eval_general")[:200]
    print(f"train {len(train)} records, eval {len(evalset)}")
    model_kwargs = {"torch_dtype": "bfloat16", "attn_implementation": "sdpa"}
    if a.load_in_4bit:
        from transformers import BitsAndBytesConfig
        model_kwargs["quantization_config"] = BitsAndBytesConfig(load_in_4bit=True, bnb_4bit_quant_type="nf4",
                                                                 bnb_4bit_compute_dtype="bfloat16")
    cfg = SFTConfig(output_dir=a.out, num_train_epochs=a.epochs, learning_rate=a.lr, lr_scheduler_type="cosine",
                    warmup_ratio=0.03, per_device_train_batch_size=1, gradient_accumulation_steps=16,
                    gradient_checkpointing=True, bf16=True, max_length=a.max_length, packing=False,
                    logging_steps=10, save_steps=200, eval_strategy="steps" if evalset else "no", eval_steps=200,
                    report_to="none", model_init_kwargs=model_kwargs)
    peft = LoraConfig(r=a.lora_r, lora_alpha=2 * a.lora_r, lora_dropout=0.05, target_modules="all-linear",
                      task_type="CAUSAL_LM")
    trainer = SFTTrainer(model=a.model, args=cfg, train_dataset=Dataset.from_list(train),
                         eval_dataset=Dataset.from_list(evalset) if evalset else None, peft_config=peft)
    trainer.train()
    trainer.save_model(a.out)


if __name__ == "__main__":
    main()
