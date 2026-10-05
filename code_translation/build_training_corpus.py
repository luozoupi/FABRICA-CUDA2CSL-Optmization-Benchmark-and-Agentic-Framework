#!/usr/bin/env python3
"""Build SFT and DPO training corpora from CUDA->CSL translation run artifacts.

Walks all result directories under --results-root, extracts multi-turn LLM
conversations paired with per-attempt outcomes, and emits:
  - SFT corpus  (trl.SFTTrainer compatible JSONL)
  - DPO corpus  (trl.DPOTrainer compatible JSONL)

Usage:
    python build_training_corpus.py \
        --results-root ~/xkernel/results/ \
        --output ~/xkernel/corpus/ \
        --mode both
"""

from __future__ import annotations

import argparse
import hashlib
import json
import logging
import os
import re
import sys
from collections import Counter, defaultdict
from pathlib import Path
from typing import Any

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%H:%M:%S",
)
log = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

# Minimum lines in an assistant response to keep (skip extraction failures)
MIN_RESPONSE_LINES = 20

# Patterns that indicate compute-file leakage in prompts
LEAK_PATTERNS = [
    re.compile(r"@export_symbol\s*\(\s*\"(f_|main)"),  # reference pe.csl export
]

# Code block detection
CODE_BLOCK_RE = re.compile(r"```(?:csl|zig|c)?\s*\n", re.IGNORECASE)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _safe_load_json(path: Path) -> Any | None:
    """Load JSON, returning None on any failure."""
    try:
        with open(path, "r", encoding="utf-8", errors="replace") as f:
            return json.load(f)
    except (json.JSONDecodeError, OSError, UnicodeDecodeError) as exc:
        log.debug("Failed to load %s: %s", path, exc)
        return None


def _extract_messages(raw: Any) -> list[dict] | None:
    """Normalize translation_log.json into a messages list."""
    if isinstance(raw, list):
        return raw
    if isinstance(raw, dict):
        msgs = raw.get("messages")
        if isinstance(msgs, list):
            return msgs
    return None


def _extract_attempts(raw: Any) -> list[dict] | None:
    """Normalize final_result.json into an attempts list."""
    if isinstance(raw, list):
        return raw
    if isinstance(raw, dict):
        atts = raw.get("attempts")
        if isinstance(atts, list):
            return atts
    return None


def _has_code_block(content: str) -> bool:
    """Check whether an assistant response contains a code fence."""
    return bool(CODE_BLOCK_RE.search(content))


def _response_lines(content: str) -> int:
    return content.count("\n") + 1


def _dedup_key(prompt_tail: str, response: str) -> str:
    """Hash-based dedup key from last prompt content + response prefix."""
    blob = (prompt_tail[:500] + "||" + response[:500]).encode("utf-8")
    return hashlib.sha256(blob).hexdigest()


def _check_compute_leak(messages: list[dict], response: str) -> bool:
    """Return True if the prompt+response pair shows signs of compute-file leakage.

    Specifically: if the prompt already contains @export_symbol patterns that
    look like reference pe.csl content AND the response reproduces them.
    """
    # Collect all user/system content as the "prompt" context
    prompt_text = " ".join(
        m.get("content", "") for m in messages if m.get("role") != "assistant"
    )
    for pat in LEAK_PATTERNS:
        prompt_hits = set(pat.findall(prompt_text))
        response_hits = set(pat.findall(response))
        # If both prompt and response have the same export symbols, suspicious
        if prompt_hits and response_hits and prompt_hits & response_hits:
            return True
    return False


def _model_family(model_str: str) -> str:
    """Normalize model string to a family name."""
    if not model_str:
        return "unknown"
    ml = model_str.lower()
    if "claude" in ml or "opus" in ml or "sonnet" in ml or "haiku" in ml:
        return "claude"
    if "gpt" in ml or "openai" in ml:
        return "openai"
    if "gemma" in ml:
        return "gemma"
    if "gemini" in ml:
        return "gemini"
    return model_str


# ---------------------------------------------------------------------------
# Core: discover result directories
# ---------------------------------------------------------------------------


def discover_run_dirs(results_root: Path) -> list[Path]:
    """Find all directories containing both translation_log.json and final_result.json."""
    run_dirs = []
    for dirpath, _dirnames, filenames in os.walk(results_root):
        if "translation_log.json" in filenames and "final_result.json" in filenames:
            run_dirs.append(Path(dirpath))
    log.info("Discovered %d run directories under %s", len(run_dirs), results_root)
    return sorted(run_dirs)


# ---------------------------------------------------------------------------
# Core: process a single run
# ---------------------------------------------------------------------------


def process_run(
    run_dir: Path,
) -> dict[str, Any] | None:
    """Process one run directory, returning a structured record or None.

    Returns dict with keys:
        kernel, model, messages, code_turns (list of dicts with
        turn_index, attempt, prompt_messages, response, status,
        failure_reason, cycles_send, is_repair, reviewer_verdict).
    """
    tl_raw = _safe_load_json(run_dir / "translation_log.json")
    fr_raw = _safe_load_json(run_dir / "final_result.json")
    if tl_raw is None or fr_raw is None:
        return None

    messages = _extract_messages(tl_raw)
    attempts = _extract_attempts(fr_raw)
    if not messages or not attempts:
        return None

    # Load optional metadata
    bm_raw = _safe_load_json(run_dir / "bundle_metadata.json") or {}
    kernel = bm_raw.get("kernel", run_dir.name)
    model = bm_raw.get("model", "unknown")

    # Identify code-producing assistant turns
    code_turn_indices = []
    for i, msg in enumerate(messages):
        if msg.get("role") == "assistant" and _has_code_block(msg.get("content", "")):
            code_turn_indices.append(i)

    if not code_turn_indices:
        return None

    # Align code turns with translate-phase attempts (first N attempts)
    # Optimization-phase attempts come after and have no conversation turn
    n_translate = min(len(code_turn_indices), len(attempts))

    code_turns = []
    for seq_idx in range(n_translate):
        turn_idx = code_turn_indices[seq_idx]
        attempt = attempts[seq_idx]

        # Build prompt = all messages up to (not including) this assistant turn
        prompt_messages = messages[:turn_idx]
        response = messages[turn_idx].get("content", "")

        status = attempt.get("status", "fail")
        failure_reason = attempt.get("failure_reason")
        cycles_send = attempt.get("cycles_send")
        reviewer_verdict = attempt.get("reviewer_verdict")

        # is_repair = True if this is not the first code-producing turn
        is_repair = seq_idx > 0

        code_turns.append(
            {
                "turn_index": turn_idx,
                "attempt_index": seq_idx,
                "prompt_messages": prompt_messages,
                "response": response,
                "status": status,
                "failure_reason": failure_reason,
                "cycles_send": cycles_send,
                "is_repair": is_repair,
                "reviewer_verdict": reviewer_verdict,
            }
        )

    return {
        "kernel": kernel,
        "model": model,
        "run_dir": str(run_dir),
        "messages": messages,
        "attempts": attempts,
        "code_turns": code_turns,
    }


# ---------------------------------------------------------------------------
# Core: compute rewards
# ---------------------------------------------------------------------------


def compute_rewards(code_turns: list[dict]) -> list[float]:
    """Assign reward to each code turn in a trajectory.

    - pass       -> 1.0
    - fail but trajectory eventually passes -> 0.0
    - fail with no subsequent pass          -> -1.0
    """
    trajectory_passes = any(t["status"] == "pass" for t in code_turns)
    rewards = []
    for t in code_turns:
        if t["status"] == "pass":
            rewards.append(1.0)
        elif trajectory_passes:
            rewards.append(0.0)
        else:
            rewards.append(-1.0)
    return rewards


# ---------------------------------------------------------------------------
# Core: build SFT samples
# ---------------------------------------------------------------------------


def build_sft_samples(
    run_record: dict,
    min_reward: float,
    check_leaks: bool = True,
) -> list[dict]:
    """Build SFT training samples from a single run record.

    Returns list of dicts with 'messages' and 'metadata' keys.
    """
    code_turns = run_record["code_turns"]
    if not code_turns:
        return []

    rewards = compute_rewards(code_turns)
    trajectory_passes = any(t["status"] == "pass" for t in code_turns)

    # SFT: only include turns from trajectories that eventually pass
    if not trajectory_passes and min_reward >= 0.0:
        return []

    samples = []
    for turn, reward in zip(code_turns, rewards):
        if reward < min_reward:
            continue

        response = turn["response"]

        # Min lines filter
        if _response_lines(response) < MIN_RESPONSE_LINES:
            continue

        # Leak check
        if check_leaks and _check_compute_leak(turn["prompt_messages"], response):
            log.debug(
                "Skipping leaked sample: kernel=%s attempt=%d",
                run_record["kernel"],
                turn["attempt_index"],
            )
            continue

        # Handle bucket-A respin: mark pre-respin attempts as orphaned
        rv = turn.get("reviewer_verdict")
        if isinstance(rv, dict) and rv.get("bucket") == "A":
            # Bucket-A means architectural redesign → exclude from SFT
            continue

        # Build the messages list for trl.SFTTrainer
        sft_messages = []
        for m in turn["prompt_messages"]:
            sft_messages.append(
                {"role": m["role"], "content": m.get("content", "")}
            )
        sft_messages.append({"role": "assistant", "content": response})

        metadata = {
            "kernel": run_record["kernel"],
            "model": run_record["model"],
            "attempt_index": turn["attempt_index"],
            "status": turn["status"],
            "cycles_send": turn["cycles_send"],
            "is_repair": turn["is_repair"],
            "reward": reward,
            "run_dir": run_record["run_dir"],
        }

        samples.append({"messages": sft_messages, "metadata": metadata})

    return samples


# ---------------------------------------------------------------------------
# Core: build DPO pairs
# ---------------------------------------------------------------------------


def build_dpo_pairs(
    run_record: dict,
    check_leaks: bool = True,
) -> list[dict]:
    """Build DPO training pairs from a single run record.

    Finds fail->pass transitions: consecutive attempts where i fails and i+1
    passes. Also includes bucket-A orphaned attempts as rejected samples
    paired against the next passing attempt.
    """
    code_turns = run_record["code_turns"]
    if len(code_turns) < 2:
        return []

    pairs = []
    for i in range(len(code_turns) - 1):
        rejected_turn = code_turns[i]
        chosen_turn = code_turns[i + 1]

        # Standard DPO: fail -> pass transition
        if rejected_turn["status"] == "fail" and chosen_turn["status"] == "pass":
            pass  # proceed to build pair
        # Bucket-A orphan -> next pass
        elif (
            isinstance(rejected_turn.get("reviewer_verdict"), dict)
            and rejected_turn["reviewer_verdict"].get("bucket") == "A"
            and chosen_turn["status"] == "pass"
        ):
            pass  # proceed
        else:
            continue

        rejected_response = rejected_turn["response"]
        chosen_response = chosen_turn["response"]

        # Skip if chosen == rejected (identical responses despite different status)
        if chosen_response == rejected_response:
            continue

        # Min lines filter
        if (
            _response_lines(rejected_response) < MIN_RESPONSE_LINES
            or _response_lines(chosen_response) < MIN_RESPONSE_LINES
        ):
            continue

        # Leak check on chosen
        if check_leaks and _check_compute_leak(
            chosen_turn["prompt_messages"], chosen_response
        ):
            continue

        # The prompt for DPO is everything up to the rejected turn
        # (since both rejected and chosen follow the same prefix in practice,
        # we use the rejected turn's prompt which is the shared conversation
        # prefix up to the point of divergence)
        prompt_messages = [
            {"role": m["role"], "content": m.get("content", "")}
            for m in rejected_turn["prompt_messages"]
        ]

        pairs.append(
            {
                "prompt": prompt_messages,
                "chosen": chosen_response,
                "rejected": rejected_response,
                "metadata": {
                    "kernel": run_record["kernel"],
                    "model": run_record["model"],
                    "chosen_status": chosen_turn["status"],
                    "rejected_status": rejected_turn["status"],
                    "chosen_cycles": chosen_turn["cycles_send"],
                    "rejected_cycles": rejected_turn["cycles_send"],
                    "run_dir": run_record["run_dir"],
                },
            }
        )

    return pairs


# ---------------------------------------------------------------------------
# Main pipeline
# ---------------------------------------------------------------------------


def build_corpus(
    results_root: Path,
    output_dir: Path,
    mode: str,
    min_reward: float,
    max_per_kernel: int,
    source_model: str | None,
) -> dict[str, Any]:
    """Main entry point: discover, process, filter, deduplicate, write."""
    output_dir.mkdir(parents=True, exist_ok=True)

    run_dirs = discover_run_dirs(results_root)
    if not run_dirs:
        log.error("No run directories found under %s", results_root)
        return {"error": "no runs found"}

    # Phase 1: Process all runs
    all_sft: list[dict] = []
    all_dpo: list[dict] = []
    stats = Counter()
    kernel_counts: dict[str, int] = defaultdict(int)

    for run_dir in run_dirs:
        record = process_run(run_dir)
        if record is None:
            stats["runs_skipped"] += 1
            continue

        stats["runs_processed"] += 1

        # Optional model filter
        if source_model:
            family = _model_family(record["model"])
            if family != source_model and record["model"] != source_model:
                stats["runs_model_filtered"] += 1
                continue

        if mode in ("sft", "both"):
            sft_samples = build_sft_samples(record, min_reward=min_reward)
            all_sft.extend(sft_samples)

        if mode in ("dpo", "both"):
            dpo_pairs = build_dpo_pairs(record)
            all_dpo.extend(dpo_pairs)

    log.info(
        "Phase 1 complete: %d runs processed, %d skipped",
        stats["runs_processed"],
        stats["runs_skipped"],
    )

    # Phase 2: Deduplicate SFT samples
    if all_sft:
        seen_hashes = set()
        deduped_sft = []
        for sample in all_sft:
            msgs = sample["messages"]
            # Use last user message + assistant response for dedup
            last_user = ""
            for m in reversed(msgs):
                if m["role"] == "user":
                    last_user = m["content"]
                    break
            assistant_resp = msgs[-1]["content"] if msgs else ""
            h = _dedup_key(last_user, assistant_resp)
            if h not in seen_hashes:
                seen_hashes.add(h)
                deduped_sft.append(sample)
            else:
                stats["sft_deduped"] += 1
        all_sft = deduped_sft

    # Phase 2b: Deduplicate DPO pairs
    if all_dpo:
        seen_hashes = set()
        deduped_dpo = []
        for pair in all_dpo:
            h = _dedup_key(pair["chosen"][:500], pair["rejected"][:500])
            if h not in seen_hashes:
                seen_hashes.add(h)
                deduped_dpo.append(pair)
            else:
                stats["dpo_deduped"] += 1
        all_dpo = deduped_dpo

    # Phase 3: Cap per-kernel
    if all_sft and max_per_kernel > 0:
        kernel_sft_counts: dict[str, int] = defaultdict(int)
        capped_sft = []
        for sample in all_sft:
            k = sample["metadata"]["kernel"]
            if kernel_sft_counts[k] < max_per_kernel:
                capped_sft.append(sample)
                kernel_sft_counts[k] += 1
            else:
                stats["sft_kernel_capped"] += 1
        all_sft = capped_sft

    if all_dpo and max_per_kernel > 0:
        kernel_dpo_counts: dict[str, int] = defaultdict(int)
        capped_dpo = []
        for pair in all_dpo:
            k = pair["metadata"]["kernel"]
            if kernel_dpo_counts[k] < max_per_kernel:
                capped_dpo.append(pair)
                kernel_dpo_counts[k] += 1
            else:
                stats["dpo_kernel_capped"] += 1
        all_dpo = capped_dpo

    # Phase 4: Write output
    sft_path = output_dir / "sft_corpus.jsonl"
    dpo_path = output_dir / "dpo_corpus.jsonl"

    if all_sft:
        with open(sft_path, "w", encoding="utf-8") as f:
            for sample in all_sft:
                f.write(json.dumps(sample, ensure_ascii=False) + "\n")
        log.info("Wrote %d SFT samples to %s", len(all_sft), sft_path)

        # Compute per-kernel stats
        for s in all_sft:
            kernel_counts[s["metadata"]["kernel"]] += 1

    if all_dpo:
        with open(dpo_path, "w", encoding="utf-8") as f:
            for pair in all_dpo:
                f.write(json.dumps(pair, ensure_ascii=False) + "\n")
        log.info("Wrote %d DPO pairs to %s", len(all_dpo), dpo_path)

    # Summary
    stats["sft_total"] = len(all_sft)
    stats["dpo_total"] = len(all_dpo)

    summary = {
        "results_root": str(results_root),
        "output_dir": str(output_dir),
        "mode": mode,
        "min_reward": min_reward,
        "max_per_kernel": max_per_kernel,
        "source_model": source_model,
        "stats": dict(stats),
        "kernel_distribution": dict(kernel_counts),
    }

    # Write summary
    summary_path = output_dir / "corpus_summary.json"
    with open(summary_path, "w", encoding="utf-8") as f:
        json.dump(summary, f, indent=2, ensure_ascii=False)
    log.info("Summary written to %s", summary_path)

    # Print summary
    print("\n" + "=" * 60)
    print("CORPUS BUILD SUMMARY")
    print("=" * 60)
    print(f"Results root:      {results_root}")
    print(f"Output directory:  {output_dir}")
    print(f"Mode:              {mode}")
    print(f"Min reward:        {min_reward}")
    print(f"Max per kernel:    {max_per_kernel}")
    print(f"Source model:      {source_model or 'all'}")
    print(f"Runs processed:    {stats['runs_processed']}")
    print(f"Runs skipped:      {stats['runs_skipped']}")
    if source_model:
        print(f"Runs model-filt:   {stats.get('runs_model_filtered', 0)}")
    print(f"SFT samples:       {stats['sft_total']}")
    print(f"  deduped:         {stats.get('sft_deduped', 0)}")
    print(f"  kernel-capped:   {stats.get('sft_kernel_capped', 0)}")
    print(f"DPO pairs:         {stats['dpo_total']}")
    print(f"  deduped:         {stats.get('dpo_deduped', 0)}")
    print(f"  kernel-capped:   {stats.get('dpo_kernel_capped', 0)}")
    if kernel_counts:
        print(f"\nKernel distribution (SFT, top-15):")
        for k, v in sorted(kernel_counts.items(), key=lambda x: -x[1])[:15]:
            print(f"  {k:30s} {v:5d}")
    print("=" * 60)

    return summary


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Build SFT/DPO training corpus from CUDA->CSL translation runs"
    )
    parser.add_argument(
        "--results-root",
        type=Path,
        required=True,
        help="Root directory containing result subdirectories",
    )
    parser.add_argument(
        "--output",
        type=Path,
        required=True,
        help="Output directory for corpus files",
    )
    parser.add_argument(
        "--mode",
        choices=["sft", "dpo", "both"],
        default="both",
        help="Which corpus to build (default: both)",
    )
    parser.add_argument(
        "--min-reward",
        type=float,
        default=0.0,
        help="Minimum reward threshold for SFT samples (default: 0.0)",
    )
    parser.add_argument(
        "--max-per-kernel",
        type=int,
        default=200,
        help="Maximum SFT/DPO samples per kernel (default: 200)",
    )
    parser.add_argument(
        "--source-model",
        type=str,
        default=None,
        help="Filter to specific model family (e.g., 'claude', 'openai')",
    )
    args = parser.parse_args()

    if not args.results_root.is_dir():
        log.error("Results root does not exist: %s", args.results_root)
        sys.exit(1)

    build_corpus(
        results_root=args.results_root,
        output_dir=args.output,
        mode=args.mode,
        min_reward=args.min_reward,
        max_per_kernel=args.max_per_kernel,
        source_model=args.source_model,
    )


if __name__ == "__main__":
    main()
