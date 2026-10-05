#!/usr/bin/env python3
"""GRPO with a verifiable SDK reward (compile + simulate + verify), TRL GRPOTrainer with vLLM rollouts.

    # one GPU: vLLM runs inside the trainer process and shares the GPU
    python -m posttrain.train_grpo --data results/posttrain_<date> --model <sft-merged-or-base> \
        --out runs/grpo --vllm-mode colocate --level compile          # stage 1: compile reward
    python -m posttrain.train_grpo ... --level run                     # stage 2: full reward
    # two GPUs: start `trl vllm-serve --model <model>` on GPU 1, then --vllm-mode server on GPU 0

The prompts are grpo/{translate,optimize}_prompts.train.jsonl; their kernel / reference_dir /
target_relpath / commands_script / base_cycles / base_code columns reach the reward as keyword
arguments. Every reward call shells out to the Cerebras SDK (XKERNEL_SDK_ROOT), so wall time is set by
compile (~5-30 s) and simulation (~2-60 s) per completion, parallelised over --reward-workers threads;
use the compile level first. Written against TRL >= 0.19; check argument names against your version.
"""
import argparse
import json
from pathlib import Path


def load(data: Path, sets, split="train"):
    rows = []
    for s in sets:
        f = data / "grpo" / f"{s}_prompts.{split}.jsonl"
        if not f.exists():
            continue
        for line in open(f):
            r = json.loads(line)
            rows.append({"prompt": r["prompt"], "kernel": r["kernel"], "reference_dir": r["reference_dir"],
                         "target_relpath": r["target_relpath"], "commands_script": r["commands_script"],
                         "base_cycles": r.get("base_cycles"), "base_code": r.get("base_code")})
    return rows


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--data", required=True)
    ap.add_argument("--model", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--sets", default="translate,optimize")
    ap.add_argument("--level", default="compile", choices=("compile", "run"))
    ap.add_argument("--no-heldout", action="store_true", help="skip the held-out inputs in the run reward")
    ap.add_argument("--reward-workers", type=int, default=8)
    ap.add_argument("--num-generations", type=int, default=8)
    ap.add_argument("--max-completion-length", type=int, default=4096)
    ap.add_argument("--max-prompt-length", type=int, default=12288)
    ap.add_argument("--lr", type=float, default=1e-6)
    ap.add_argument("--beta", type=float, default=0.0)
    ap.add_argument("--vllm-mode", default="colocate", choices=("colocate", "server"))
    ap.add_argument("--vllm-gpu-memory-utilization", type=float, default=0.35)
    ap.add_argument("--lora-r", type=int, default=0, help="0 = full fine-tuning; >0 = LoRA rank")
    ap.add_argument("--max-steps", type=int, default=500)
    a = ap.parse_args()

    from datasets import Dataset
    from trl import GRPOConfig, GRPOTrainer
    from posttrain.csl_reward import make_trl_reward

    train = load(Path(a.data), a.sets.split(","))
    print(f"{len(train)} prompts")
    cfg = GRPOConfig(output_dir=a.out, learning_rate=a.lr, beta=a.beta, num_generations=a.num_generations,
                     per_device_train_batch_size=a.num_generations, gradient_accumulation_steps=4,
                     max_prompt_length=a.max_prompt_length, max_completion_length=a.max_completion_length,
                     temperature=0.8, use_vllm=True, vllm_mode=a.vllm_mode,
                     vllm_gpu_memory_utilization=a.vllm_gpu_memory_utilization, bf16=True,
                     gradient_checkpointing=True, max_steps=a.max_steps, logging_steps=1, save_steps=50,
                     report_to="none", log_completions=True)
    peft = None
    if a.lora_r:
        from peft import LoraConfig
        peft = LoraConfig(r=a.lora_r, lora_alpha=2 * a.lora_r, target_modules="all-linear", task_type="CAUSAL_LM")
    trainer = GRPOTrainer(model=a.model, args=cfg, train_dataset=Dataset.from_list(train), peft_config=peft,
                          reward_funcs=[make_trl_reward(level=a.level, heldout=not a.no_heldout,
                                                        workers=a.reward_workers)])
    trainer.train()
    trainer.save_model(a.out)


if __name__ == "__main__":
    main()
