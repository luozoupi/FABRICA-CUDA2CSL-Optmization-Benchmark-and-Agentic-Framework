#!/usr/bin/env python3
"""Package a training corpus into a self-contained tarball for Nvidia GPU training.

Creates a tarball containing:
  - corpus/sft_corpus.jsonl
  - corpus/dpo_corpus.jsonl (if exists)
  - train_gemma_sft.py (LoRA fine-tuning script using trl.SFTTrainer)
  - requirements.txt
  - README.md

Usage:
    python export_for_training.py \
        --corpus-dir ~/xkernel/corpus/ \
        --output ~/xkernel/training_package.tar.gz
"""

from __future__ import annotations

import argparse
import os
import sys
import tarfile
import textwrap
from io import BytesIO
from pathlib import Path

# ---------------------------------------------------------------------------
# Embedded training script
# ---------------------------------------------------------------------------

TRAIN_GEMMA_SFT_PY = textwrap.dedent('''\
    #!/usr/bin/env python3
    """Fine-tune Gemma 4 31B on CUDA->CSL translation using LoRA + 4-bit quantization.

    Usage:
        # Single GPU (A100/H100 80GB recommended)
        python train_gemma_sft.py \\
            --corpus corpus/sft_corpus.jsonl \\
            --output-dir ./gemma-csl-lora

        # Multi-GPU with accelerate
        accelerate launch train_gemma_sft.py \\
            --corpus corpus/sft_corpus.jsonl \\
            --output-dir ./gemma-csl-lora

        # Resume from checkpoint
        python train_gemma_sft.py \\
            --corpus corpus/sft_corpus.jsonl \\
            --output-dir ./gemma-csl-lora \\
            --resume-from-checkpoint
    """

    from __future__ import annotations

    import argparse
    import json
    import os

    import torch
    from datasets import load_dataset
    from peft import LoraConfig, TaskType, get_peft_model, prepare_model_for_kbit_training
    from transformers import (
        AutoModelForCausalLM,
        AutoTokenizer,
        BitsAndBytesConfig,
        TrainingArguments,
    )
    from trl import SFTTrainer, SFTConfig


    def build_chat_text(example: dict) -> dict:
        """Convert messages list to a single formatted text for training.

        Uses the tokenizer's chat template if available, otherwise falls back
        to a simple format.
        """
        messages = example.get("messages", [])
        # We return messages as-is; SFTTrainer handles chat template formatting
        return example


    def main() -> None:
        parser = argparse.ArgumentParser(
            description="Fine-tune Gemma 4 31B on CUDA->CSL translation"
        )
        parser.add_argument(
            "--corpus",
            type=str,
            default="corpus/sft_corpus.jsonl",
            help="Path to SFT corpus JSONL file",
        )
        parser.add_argument(
            "--model-name",
            type=str,
            default="google/gemma-3-27b-it",
            help="Base model name or path (default: google/gemma-3-27b-it)",
        )
        parser.add_argument(
            "--output-dir",
            type=str,
            default="./gemma-csl-lora",
            help="Output directory for LoRA adapter weights",
        )
        parser.add_argument(
            "--num-epochs",
            type=int,
            default=3,
            help="Number of training epochs (default: 3)",
        )
        parser.add_argument(
            "--learning-rate",
            type=float,
            default=2e-5,
            help="Learning rate (default: 2e-5)",
        )
        parser.add_argument(
            "--batch-size",
            type=int,
            default=1,
            help="Per-device train batch size (default: 1)",
        )
        parser.add_argument(
            "--gradient-accumulation-steps",
            type=int,
            default=8,
            help="Gradient accumulation steps (default: 8)",
        )
        parser.add_argument(
            "--max-seq-length",
            type=int,
            default=8192,
            help="Maximum sequence length (default: 8192)",
        )
        parser.add_argument(
            "--lora-r",
            type=int,
            default=16,
            help="LoRA rank (default: 16)",
        )
        parser.add_argument(
            "--lora-alpha",
            type=int,
            default=32,
            help="LoRA alpha (default: 32)",
        )
        parser.add_argument(
            "--resume-from-checkpoint",
            action="store_true",
            help="Resume training from the latest checkpoint",
        )
        parser.add_argument(
            "--val-split",
            type=float,
            default=0.05,
            help="Fraction of data to use for validation (default: 0.05)",
        )
        args = parser.parse_args()

        print(f"Loading corpus from {args.corpus}")
        dataset = load_dataset("json", data_files=args.corpus, split="train")
        print(f"Loaded {len(dataset)} samples")

        # Train/val split
        if args.val_split > 0:
            split = dataset.train_test_split(test_size=args.val_split, seed=42)
            train_dataset = split["train"]
            eval_dataset = split["test"]
            print(f"Train: {len(train_dataset)}, Val: {len(eval_dataset)}")
        else:
            train_dataset = dataset
            eval_dataset = None

        # 4-bit quantization config
        bnb_config = BitsAndBytesConfig(
            load_in_4bit=True,
            bnb_4bit_quant_type="nf4",
            bnb_4bit_compute_dtype=torch.bfloat16,
            bnb_4bit_use_double_quant=True,
        )

        print(f"Loading model: {args.model_name}")
        model = AutoModelForCausalLM.from_pretrained(
            args.model_name,
            quantization_config=bnb_config,
            device_map="auto",
            torch_dtype=torch.bfloat16,
            attn_implementation="flash_attention_2",
            trust_remote_code=True,
        )

        tokenizer = AutoTokenizer.from_pretrained(
            args.model_name,
            trust_remote_code=True,
        )
        if tokenizer.pad_token is None:
            tokenizer.pad_token = tokenizer.eos_token

        # Prepare model for k-bit training
        model = prepare_model_for_kbit_training(model)

        # LoRA config
        lora_config = LoraConfig(
            r=args.lora_r,
            lora_alpha=args.lora_alpha,
            target_modules=["q_proj", "k_proj", "v_proj", "o_proj"],
            lora_dropout=0.05,
            bias="none",
            task_type=TaskType.CAUSAL_LM,
        )

        model = get_peft_model(model, lora_config)
        model.print_trainable_parameters()

        # Training config
        training_args = SFTConfig(
            output_dir=args.output_dir,
            num_train_epochs=args.num_epochs,
            per_device_train_batch_size=args.batch_size,
            gradient_accumulation_steps=args.gradient_accumulation_steps,
            learning_rate=args.learning_rate,
            lr_scheduler_type="cosine",
            warmup_ratio=0.05,
            weight_decay=0.01,
            logging_steps=10,
            save_strategy="epoch",
            eval_strategy="epoch" if eval_dataset is not None else "no",
            bf16=True,
            gradient_checkpointing=True,
            gradient_checkpointing_kwargs={"use_reentrant": False},
            max_seq_length=args.max_seq_length,
            packing=False,
            report_to="none",
            seed=42,
            remove_unused_columns=False,
        )

        # Trainer
        trainer = SFTTrainer(
            model=model,
            args=training_args,
            train_dataset=train_dataset,
            eval_dataset=eval_dataset,
            processing_class=tokenizer,
        )

        # Train
        print("Starting training...")
        trainer.train(resume_from_checkpoint=args.resume_from_checkpoint)

        # Save adapter
        print(f"Saving LoRA adapter to {args.output_dir}")
        trainer.save_model(args.output_dir)
        tokenizer.save_pretrained(args.output_dir)

        print("Training complete!")
        print(f"  Adapter saved to: {args.output_dir}")
        print(f"  To merge: use peft.AutoPeftModelForCausalLM.from_pretrained()")


    if __name__ == "__main__":
        main()
''')

# ---------------------------------------------------------------------------
# Embedded DPO training script
# ---------------------------------------------------------------------------

TRAIN_GEMMA_DPO_PY = textwrap.dedent('''\
    #!/usr/bin/env python3
    """Fine-tune Gemma 4 31B with DPO on CUDA->CSL translation pairs.

    Usage:
        python train_gemma_dpo.py \\
            --corpus corpus/dpo_corpus.jsonl \\
            --output-dir ./gemma-csl-dpo-lora
    """

    from __future__ import annotations

    import argparse

    import torch
    from datasets import load_dataset
    from peft import LoraConfig, TaskType, prepare_model_for_kbit_training
    from transformers import (
        AutoModelForCausalLM,
        AutoTokenizer,
        BitsAndBytesConfig,
    )
    from trl import DPOConfig, DPOTrainer


    def main() -> None:
        parser = argparse.ArgumentParser(
            description="DPO fine-tune Gemma on CUDA->CSL translation"
        )
        parser.add_argument("--corpus", type=str, default="corpus/dpo_corpus.jsonl")
        parser.add_argument("--model-name", type=str, default="google/gemma-3-27b-it")
        parser.add_argument("--output-dir", type=str, default="./gemma-csl-dpo-lora")
        parser.add_argument("--num-epochs", type=int, default=1)
        parser.add_argument("--learning-rate", type=float, default=5e-6)
        parser.add_argument("--batch-size", type=int, default=1)
        parser.add_argument("--gradient-accumulation-steps", type=int, default=8)
        parser.add_argument("--max-seq-length", type=int, default=8192)
        parser.add_argument("--beta", type=float, default=0.1, help="DPO beta parameter")
        parser.add_argument("--lora-r", type=int, default=16)
        parser.add_argument("--lora-alpha", type=int, default=32)
        args = parser.parse_args()

        print(f"Loading DPO corpus from {args.corpus}")
        dataset = load_dataset("json", data_files=args.corpus, split="train")
        print(f"Loaded {len(dataset)} preference pairs")

        split = dataset.train_test_split(test_size=0.05, seed=42)
        train_dataset = split["train"]
        eval_dataset = split["test"]

        bnb_config = BitsAndBytesConfig(
            load_in_4bit=True,
            bnb_4bit_quant_type="nf4",
            bnb_4bit_compute_dtype=torch.bfloat16,
            bnb_4bit_use_double_quant=True,
        )

        print(f"Loading model: {args.model_name}")
        model = AutoModelForCausalLM.from_pretrained(
            args.model_name,
            quantization_config=bnb_config,
            device_map="auto",
            torch_dtype=torch.bfloat16,
            attn_implementation="flash_attention_2",
            trust_remote_code=True,
        )
        tokenizer = AutoTokenizer.from_pretrained(args.model_name, trust_remote_code=True)
        if tokenizer.pad_token is None:
            tokenizer.pad_token = tokenizer.eos_token

        model = prepare_model_for_kbit_training(model)

        lora_config = LoraConfig(
            r=args.lora_r,
            lora_alpha=args.lora_alpha,
            target_modules=["q_proj", "k_proj", "v_proj", "o_proj"],
            lora_dropout=0.05,
            bias="none",
            task_type=TaskType.CAUSAL_LM,
        )

        training_args = DPOConfig(
            output_dir=args.output_dir,
            num_train_epochs=args.num_epochs,
            per_device_train_batch_size=args.batch_size,
            gradient_accumulation_steps=args.gradient_accumulation_steps,
            learning_rate=args.learning_rate,
            lr_scheduler_type="cosine",
            warmup_ratio=0.05,
            logging_steps=10,
            save_strategy="epoch",
            eval_strategy="epoch",
            bf16=True,
            gradient_checkpointing=True,
            gradient_checkpointing_kwargs={"use_reentrant": False},
            max_length=args.max_seq_length,
            max_prompt_length=args.max_seq_length // 2,
            beta=args.beta,
            report_to="none",
            seed=42,
            remove_unused_columns=False,
        )

        trainer = DPOTrainer(
            model=model,
            args=training_args,
            train_dataset=train_dataset,
            eval_dataset=eval_dataset,
            processing_class=tokenizer,
            peft_config=lora_config,
        )

        print("Starting DPO training...")
        trainer.train()

        print(f"Saving DPO adapter to {args.output_dir}")
        trainer.save_model(args.output_dir)
        tokenizer.save_pretrained(args.output_dir)
        print("DPO training complete!")


    if __name__ == "__main__":
        main()
''')

# ---------------------------------------------------------------------------
# Embedded requirements.txt
# ---------------------------------------------------------------------------

REQUIREMENTS_TXT = textwrap.dedent("""\
    torch>=2.2.0
    transformers>=4.45.0
    trl>=0.12.0
    peft>=0.13.0
    datasets>=3.0.0
    bitsandbytes>=0.44.0
    accelerate>=1.0.0
    flash-attn>=2.6.0
    scipy
    sentencepiece
""")

# ---------------------------------------------------------------------------
# Embedded README
# ---------------------------------------------------------------------------

README_MD = textwrap.dedent("""\
    # CUDA-to-CSL Translation Fine-Tuning Package

    Fine-tune Gemma 4 31B (or compatible model) on CUDA-to-CSL (Cerebras SDK
    Language) translation using LoRA adapters with 4-bit quantization.

    ## Quick Start

    ### 1. Install dependencies

    ```bash
    pip install -r requirements.txt
    ```

    ### 2. SFT (Supervised Fine-Tuning)

    ```bash
    # Single GPU (A100/H100 80GB)
    python train_gemma_sft.py \\
        --corpus corpus/sft_corpus.jsonl \\
        --output-dir ./gemma-csl-lora

    # Multi-GPU
    accelerate launch train_gemma_sft.py \\
        --corpus corpus/sft_corpus.jsonl \\
        --output-dir ./gemma-csl-lora
    ```

    ### 3. DPO (Direct Preference Optimization) — optional

    Run after SFT to further align the model using fail/pass preference pairs:

    ```bash
    python train_gemma_dpo.py \\
        --corpus corpus/dpo_corpus.jsonl \\
        --model-name ./gemma-csl-lora \\
        --output-dir ./gemma-csl-dpo-lora
    ```

    ### 4. Inference with the adapter

    ```python
    from peft import AutoPeftModelForCausalLM
    from transformers import AutoTokenizer

    model = AutoPeftModelForCausalLM.from_pretrained(
        "./gemma-csl-lora",
        device_map="auto",
        torch_dtype="auto",
    )
    tokenizer = AutoTokenizer.from_pretrained("./gemma-csl-lora")

    messages = [
        {"role": "system", "content": "You are an expert CUDA-to-CSL translator."},
        {"role": "user", "content": "Translate this CUDA kernel to CSL: ..."},
    ]
    inputs = tokenizer.apply_chat_template(messages, return_tensors="pt").to(model.device)
    outputs = model.generate(inputs, max_new_tokens=4096, temperature=0.2)
    print(tokenizer.decode(outputs[0], skip_special_tokens=True))
    ```

    ## Corpus Format

    ### SFT (`sft_corpus.jsonl`)

    Each line is a JSON object:
    ```json
    {
      "messages": [
        {"role": "system", "content": "..."},
        {"role": "user", "content": "..."},
        {"role": "assistant", "content": "..."}
      ],
      "metadata": {
        "kernel": "GEMV",
        "model": "claude-opus-4-8",
        "attempt_index": 3,
        "status": "pass",
        "cycles_send": 4007,
        "is_repair": true,
        "reward": 1.0
      }
    }
    ```

    ### DPO (`dpo_corpus.jsonl`)

    Each line is a JSON object:
    ```json
    {
      "prompt": [
        {"role": "system", "content": "..."},
        {"role": "user", "content": "..."}
      ],
      "chosen": "...passing CSL code response...",
      "rejected": "...failing CSL code response..."
    }
    ```

    ## Training Configuration

    | Parameter | SFT Default | DPO Default |
    |-----------|-------------|-------------|
    | LoRA rank (r) | 16 | 16 |
    | LoRA alpha | 32 | 32 |
    | Target modules | q,k,v,o_proj | q,k,v,o_proj |
    | Quantization | 4-bit NF4 | 4-bit NF4 |
    | Learning rate | 2e-5 | 5e-6 |
    | Batch size | 1 | 1 |
    | Grad accum | 8 | 8 |
    | Epochs | 3 | 1 |
    | Max seq length | 8192 | 8192 |

    ## Hardware Requirements

    - Minimum: 1x A100 80GB (4-bit quantization)
    - Recommended: 2x H100 80GB (faster training, larger batch)
    - Training time estimate: ~2-4 hours for 1000 SFT samples on 1x H100

    ## Merge Adapter (optional)

    To create a standalone model (no PEFT dependency at inference):

    ```python
    from peft import AutoPeftModelForCausalLM

    model = AutoPeftModelForCausalLM.from_pretrained(
        "./gemma-csl-lora",
        device_map="auto",
        torch_dtype="auto",
    )
    merged = model.merge_and_unload()
    merged.save_pretrained("./gemma-csl-merged")
    ```
""")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------


def create_tarball(
    corpus_dir: Path,
    output_path: Path,
) -> None:
    """Create a self-contained training tarball."""
    sft_path = corpus_dir / "sft_corpus.jsonl"
    dpo_path = corpus_dir / "dpo_corpus.jsonl"
    summary_path = corpus_dir / "corpus_summary.json"

    if not sft_path.is_file() and not dpo_path.is_file():
        print(f"ERROR: no corpus files found in {corpus_dir}", file=sys.stderr)
        print(f"  Expected: {sft_path} and/or {dpo_path}", file=sys.stderr)
        sys.exit(1)

    output_path.parent.mkdir(parents=True, exist_ok=True)

    with tarfile.open(output_path, "w:gz") as tar:
        # Add corpus files
        if sft_path.is_file():
            tar.add(sft_path, arcname="corpus/sft_corpus.jsonl")
            print(f"  Added corpus/sft_corpus.jsonl ({sft_path.stat().st_size / 1024 / 1024:.1f} MB)")

        if dpo_path.is_file():
            tar.add(dpo_path, arcname="corpus/dpo_corpus.jsonl")
            print(f"  Added corpus/dpo_corpus.jsonl ({dpo_path.stat().st_size / 1024 / 1024:.1f} MB)")

        if summary_path.is_file():
            tar.add(summary_path, arcname="corpus/corpus_summary.json")
            print("  Added corpus/corpus_summary.json")

        # Add embedded files
        def _add_text(content: str, arcname: str) -> None:
            data = content.encode("utf-8")
            info = tarfile.TarInfo(name=arcname)
            info.size = len(data)
            tar.addfile(info, BytesIO(data))
            print(f"  Added {arcname} ({len(data)} bytes)")

        _add_text(TRAIN_GEMMA_SFT_PY, "train_gemma_sft.py")
        _add_text(TRAIN_GEMMA_DPO_PY, "train_gemma_dpo.py")
        _add_text(REQUIREMENTS_TXT, "requirements.txt")
        _add_text(README_MD, "README.md")

    size_mb = output_path.stat().st_size / 1024 / 1024
    print(f"\nPackage created: {output_path} ({size_mb:.1f} MB)")
    print("Transfer to your GPU node and extract with:")
    print(f"  tar xzf {output_path.name}")
    print(f"  cd {output_path.stem.replace('.tar', '')}")
    print(f"  pip install -r requirements.txt")
    print(f"  python train_gemma_sft.py --corpus corpus/sft_corpus.jsonl")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Package training corpus into a self-contained tarball"
    )
    parser.add_argument(
        "--corpus-dir",
        type=Path,
        required=True,
        help="Directory containing corpus JSONL files",
    )
    parser.add_argument(
        "--output",
        type=Path,
        required=True,
        help="Output tarball path (e.g., training_package.tar.gz)",
    )
    args = parser.parse_args()

    if not args.corpus_dir.is_dir():
        print(f"ERROR: corpus directory not found: {args.corpus_dir}", file=sys.stderr)
        sys.exit(1)

    create_tarball(args.corpus_dir, args.output)


if __name__ == "__main__":
    main()
