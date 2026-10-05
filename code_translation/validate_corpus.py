#!/usr/bin/env python3
"""Validate a training corpus produced by build_training_corpus.py.

Checks:
  - JSONL format validity (each line is valid JSON)
  - No compute-file leakage (canary-like patterns in prompts)
  - Prompt/response length distributions
  - Reward attribution consistency
  - DPO chosen/rejected status consistency
  - Summary statistics

Usage:
    python validate_corpus.py --corpus ~/xkernel/corpus/sft_corpus.jsonl
    python validate_corpus.py --corpus ~/xkernel/corpus/dpo_corpus.jsonl
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from collections import Counter, defaultdict
from pathlib import Path

# Canary-like patterns that should NOT appear in prompts (indicates leaked
# reference compute file content being fed back to the model)
CANARY_PATTERNS = [
    # Reference pe.csl export symbols that would only be in the hidden compute file
    re.compile(r'@export_symbol\s*\(\s*"f_'),
    re.compile(r'@export_symbol\s*\(\s*"main"'),
    # Direct code from reference pe.csl (common compute patterns)
    re.compile(r"fn\s+f_\w+\s*\("),
    # Canary strings used by the firewall
    re.compile(r"CANARY_[A-Z0-9]+"),
]

# Patterns that indicate a response actually contains CSL code
CSL_CODE_RE = re.compile(r"```(?:csl|zig)?\s*\n", re.IGNORECASE)


def _detect_corpus_type(first_record: dict) -> str:
    """Detect whether the corpus is SFT or DPO from the first record."""
    if "messages" in first_record and "metadata" in first_record:
        return "sft"
    if "prompt" in first_record and "chosen" in first_record and "rejected" in first_record:
        return "dpo"
    return "unknown"


def _count_tokens_approx(text: str) -> int:
    """Rough token count (whitespace-split, ~1.3x actual for English/code)."""
    return len(text.split())


def validate_sft(records: list[dict]) -> dict:
    """Validate SFT corpus records."""
    issues = []
    stats = Counter()
    kernel_dist = Counter()
    model_dist = Counter()
    reward_dist = Counter()
    prompt_lengths = []
    response_lengths = []
    prompt_token_counts = []
    response_token_counts = []

    for idx, rec in enumerate(records):
        line_id = f"line {idx + 1}"

        # Structure check
        if "messages" not in rec:
            issues.append(f"{line_id}: missing 'messages' key")
            stats["missing_messages"] += 1
            continue
        if "metadata" not in rec:
            issues.append(f"{line_id}: missing 'metadata' key")
            stats["missing_metadata"] += 1

        messages = rec["messages"]
        metadata = rec.get("metadata", {})

        # Messages structure
        if not isinstance(messages, list) or len(messages) < 2:
            issues.append(f"{line_id}: messages list too short ({len(messages) if isinstance(messages, list) else 'not a list'})")
            stats["short_messages"] += 1
            continue

        # Last message must be assistant
        if messages[-1].get("role") != "assistant":
            issues.append(f"{line_id}: last message is not assistant (got {messages[-1].get('role')})")
            stats["wrong_last_role"] += 1

        # Check all messages have role and content
        for mi, msg in enumerate(messages):
            if "role" not in msg:
                issues.append(f"{line_id}: message[{mi}] missing 'role'")
                stats["missing_role"] += 1
            if "content" not in msg:
                issues.append(f"{line_id}: message[{mi}] missing 'content'")
                stats["missing_content"] += 1

        # Assistant response quality
        response = messages[-1].get("content", "")
        response_lines = response.count("\n") + 1
        if response_lines < 20:
            issues.append(f"{line_id}: response only {response_lines} lines (min 20)")
            stats["short_response"] += 1

        if not CSL_CODE_RE.search(response):
            stats["no_code_block"] += 1

        # Prompt length (all non-assistant messages)
        prompt_text = " ".join(
            m.get("content", "") for m in messages if m.get("role") != "assistant"
        )
        prompt_lengths.append(len(prompt_text))
        response_lengths.append(len(response))
        prompt_token_counts.append(_count_tokens_approx(prompt_text))
        response_token_counts.append(_count_tokens_approx(response))

        # Canary/leak check in prompt
        for pat in CANARY_PATTERNS:
            if pat.search(prompt_text):
                # Only flag if it's in a suspicious position (not in the
                # translation request which legitimately discusses these)
                # The user message containing the translation task has
                # reference contract info, which is legitimate
                stats["potential_leak_in_prompt"] += 1
                break

        # Reward attribution
        reward = metadata.get("reward")
        status = metadata.get("status")
        if reward == 1.0 and status != "pass":
            issues.append(f"{line_id}: reward=1.0 but status='{status}'")
            stats["reward_status_mismatch"] += 1

        if reward is not None:
            reward_dist[str(reward)] += 1

        # Kernel/model distribution
        kernel_dist[metadata.get("kernel", "unknown")] += 1
        model_dist[metadata.get("model", "unknown")] += 1

    # Length statistics
    def _percentiles(values, pcts=(10, 25, 50, 75, 90)):
        if not values:
            return {}
        sv = sorted(values)
        n = len(sv)
        return {f"p{p}": sv[min(int(n * p / 100), n - 1)] for p in pcts}

    return {
        "type": "sft",
        "total_records": len(records),
        "issues": issues[:50],  # Cap for readability
        "issue_count": len(issues),
        "stats": dict(stats),
        "prompt_char_length": {
            "min": min(prompt_lengths) if prompt_lengths else 0,
            "max": max(prompt_lengths) if prompt_lengths else 0,
            "mean": int(sum(prompt_lengths) / len(prompt_lengths)) if prompt_lengths else 0,
            **_percentiles(prompt_lengths),
        },
        "response_char_length": {
            "min": min(response_lengths) if response_lengths else 0,
            "max": max(response_lengths) if response_lengths else 0,
            "mean": int(sum(response_lengths) / len(response_lengths)) if response_lengths else 0,
            **_percentiles(response_lengths),
        },
        "prompt_token_count_approx": {
            "min": min(prompt_token_counts) if prompt_token_counts else 0,
            "max": max(prompt_token_counts) if prompt_token_counts else 0,
            "mean": int(sum(prompt_token_counts) / len(prompt_token_counts)) if prompt_token_counts else 0,
            **_percentiles(prompt_token_counts),
        },
        "response_token_count_approx": {
            "min": min(response_token_counts) if response_token_counts else 0,
            "max": max(response_token_counts) if response_token_counts else 0,
            "mean": int(sum(response_token_counts) / len(response_token_counts)) if response_token_counts else 0,
            **_percentiles(response_token_counts),
        },
        "reward_distribution": dict(reward_dist),
        "kernel_distribution": dict(kernel_dist.most_common(20)),
        "model_distribution": dict(model_dist),
    }


def validate_dpo(records: list[dict]) -> dict:
    """Validate DPO corpus records."""
    issues = []
    stats = Counter()
    kernel_dist = Counter()
    chosen_lengths = []
    rejected_lengths = []

    for idx, rec in enumerate(records):
        line_id = f"line {idx + 1}"

        # Structure check
        for key in ("prompt", "chosen", "rejected"):
            if key not in rec:
                issues.append(f"{line_id}: missing '{key}' key")
                stats[f"missing_{key}"] += 1

        if "prompt" not in rec or "chosen" not in rec or "rejected" not in rec:
            continue

        prompt = rec["prompt"]
        chosen = rec["chosen"]
        rejected = rec["rejected"]
        metadata = rec.get("metadata", {})

        # Prompt structure
        if not isinstance(prompt, list):
            issues.append(f"{line_id}: 'prompt' is not a list")
            stats["prompt_not_list"] += 1
        else:
            for mi, msg in enumerate(prompt):
                if not isinstance(msg, dict) or "role" not in msg:
                    issues.append(f"{line_id}: prompt[{mi}] malformed")
                    stats["prompt_malformed"] += 1
                    break

        # Chosen/rejected must be strings
        if not isinstance(chosen, str):
            issues.append(f"{line_id}: 'chosen' is not a string")
            stats["chosen_not_str"] += 1
        if not isinstance(rejected, str):
            issues.append(f"{line_id}: 'rejected' is not a string")
            stats["rejected_not_str"] += 1

        if isinstance(chosen, str) and isinstance(rejected, str):
            chosen_lengths.append(len(chosen))
            rejected_lengths.append(len(rejected))

            # Chosen should have code
            if not CSL_CODE_RE.search(chosen):
                stats["chosen_no_code"] += 1

            # Verify status alignment
            chosen_status = metadata.get("chosen_status")
            rejected_status = metadata.get("rejected_status")
            if chosen_status and chosen_status != "pass":
                issues.append(f"{line_id}: chosen_status='{chosen_status}' (expected 'pass')")
                stats["chosen_not_pass"] += 1
            if rejected_status and rejected_status != "fail":
                issues.append(f"{line_id}: rejected_status='{rejected_status}' (expected 'fail')")
                stats["rejected_not_fail"] += 1

            # Chosen and rejected should be different
            if chosen == rejected:
                issues.append(f"{line_id}: chosen == rejected")
                stats["chosen_eq_rejected"] += 1

        kernel_dist[metadata.get("kernel", "unknown")] += 1

    def _percentiles(values, pcts=(10, 25, 50, 75, 90)):
        if not values:
            return {}
        sv = sorted(values)
        n = len(sv)
        return {f"p{p}": sv[min(int(n * p / 100), n - 1)] for p in pcts}

    return {
        "type": "dpo",
        "total_records": len(records),
        "issues": issues[:50],
        "issue_count": len(issues),
        "stats": dict(stats),
        "chosen_char_length": {
            "min": min(chosen_lengths) if chosen_lengths else 0,
            "max": max(chosen_lengths) if chosen_lengths else 0,
            "mean": int(sum(chosen_lengths) / len(chosen_lengths)) if chosen_lengths else 0,
            **_percentiles(chosen_lengths),
        },
        "rejected_char_length": {
            "min": min(rejected_lengths) if rejected_lengths else 0,
            "max": max(rejected_lengths) if rejected_lengths else 0,
            "mean": int(sum(rejected_lengths) / len(rejected_lengths)) if rejected_lengths else 0,
            **_percentiles(rejected_lengths),
        },
        "kernel_distribution": dict(kernel_dist.most_common(20)),
    }


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Validate a training corpus JSONL file"
    )
    parser.add_argument(
        "--corpus",
        type=Path,
        required=True,
        help="Path to corpus JSONL file",
    )
    args = parser.parse_args()

    corpus_path = args.corpus
    if not corpus_path.is_file():
        print(f"ERROR: corpus file not found: {corpus_path}", file=sys.stderr)
        sys.exit(1)

    # Phase 1: Parse JSONL
    records = []
    parse_errors = 0
    with open(corpus_path, "r", encoding="utf-8") as f:
        for line_no, line in enumerate(f, 1):
            line = line.strip()
            if not line:
                continue
            try:
                rec = json.loads(line)
                records.append(rec)
            except json.JSONDecodeError as exc:
                parse_errors += 1
                if parse_errors <= 5:
                    print(f"  JSON parse error on line {line_no}: {exc}")

    print(f"\nCorpus: {corpus_path}")
    print(f"Total lines: {len(records) + parse_errors}")
    print(f"Valid JSON:  {len(records)}")
    print(f"Parse errors: {parse_errors}")

    if not records:
        print("ERROR: no valid records found")
        sys.exit(1)

    # Detect type
    corpus_type = _detect_corpus_type(records[0])
    print(f"Detected type: {corpus_type}")

    # Validate
    if corpus_type == "sft":
        report = validate_sft(records)
    elif corpus_type == "dpo":
        report = validate_dpo(records)
    else:
        print(f"ERROR: unknown corpus type. First record keys: {list(records[0].keys())}")
        sys.exit(1)

    # Print report
    print("\n" + "=" * 60)
    print(f"VALIDATION REPORT ({corpus_type.upper()})")
    print("=" * 60)

    print(f"\nTotal records: {report['total_records']}")
    print(f"Issues found:  {report['issue_count']}")

    if report.get("stats"):
        print("\nIssue breakdown:")
        for k, v in sorted(report["stats"].items()):
            print(f"  {k:30s} {v:5d}")

    if corpus_type == "sft":
        print("\nReward distribution:")
        for k, v in sorted(report.get("reward_distribution", {}).items()):
            print(f"  reward={k:6s} count={v}")

        print("\nPrompt length (chars):")
        for k, v in report.get("prompt_char_length", {}).items():
            print(f"  {k:6s} {v:>10,}")

        print("\nResponse length (chars):")
        for k, v in report.get("response_char_length", {}).items():
            print(f"  {k:6s} {v:>10,}")

        print("\nPrompt tokens (approx):")
        for k, v in report.get("prompt_token_count_approx", {}).items():
            print(f"  {k:6s} {v:>10,}")

        print("\nResponse tokens (approx):")
        for k, v in report.get("response_token_count_approx", {}).items():
            print(f"  {k:6s} {v:>10,}")

        print("\nModel distribution:")
        for k, v in report.get("model_distribution", {}).items():
            print(f"  {k:40s} {v:5d}")

    elif corpus_type == "dpo":
        print("\nChosen length (chars):")
        for k, v in report.get("chosen_char_length", {}).items():
            print(f"  {k:6s} {v:>10,}")

        print("\nRejected length (chars):")
        for k, v in report.get("rejected_char_length", {}).items():
            print(f"  {k:6s} {v:>10,}")

    print(f"\nKernel distribution (top-20):")
    for k, v in sorted(
        report.get("kernel_distribution", {}).items(),
        key=lambda x: -x[1],
    )[:20]:
        print(f"  {k:30s} {v:5d}")

    if report["issues"]:
        print(f"\nFirst {min(len(report['issues']), 10)} issues:")
        for issue in report["issues"][:10]:
            print(f"  - {issue}")

    # Overall verdict
    print("\n" + "=" * 60)
    critical = report.get("stats", {}).get("reward_status_mismatch", 0)
    critical += report.get("stats", {}).get("chosen_not_pass", 0)
    critical += report.get("stats", {}).get("rejected_not_fail", 0)
    critical += parse_errors

    if critical == 0 and report["issue_count"] == 0:
        print("VERDICT: PASS (no issues found)")
    elif critical == 0:
        print(f"VERDICT: WARN ({report['issue_count']} non-critical issues)")
    else:
        print(f"VERDICT: FAIL ({critical} critical issues)")
    print("=" * 60)

    sys.exit(1 if critical > 0 else 0)


if __name__ == "__main__":
    main()
