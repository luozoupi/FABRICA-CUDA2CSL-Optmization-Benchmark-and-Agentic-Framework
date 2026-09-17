#!/usr/bin/env python3
"""
Append-only JSONL store for RL transitions from the CSL optimization pipeline.

Every benchmark attempt (translation or optimization step) is recorded as a
(state_features, action, reward, outcome) tuple. Accumulates across sessions
and seeds future reward model training or LLM fine-tuning.
"""

from __future__ import annotations

import hashlib
import json
import os
import re
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, Optional

DEFAULT_STORE = os.path.expanduser("~/.cache/fabrica/rl_data/experience.jsonl")

# Baseline run_time_ms from gpt-5.4-pro no-optimization run — used for speedup calc
BASELINE_MS = 2930.0


# ---------------------------------------------------------------------------
# CSL feature extractor
# ---------------------------------------------------------------------------

def extract_csl_features(code: str) -> Dict[str, Any]:
    """Regex-based structural features of a CSL compute file."""
    return {
        "code_lines":    len(code.strip().splitlines()),
        "fmacs_count":   len(re.findall(r"@fmacs", code)),
        "fadds_count":   len(re.findall(r"@fadds", code)),
        "fmovs_count":   len(re.findall(r"@fmovs", code)),
        "dsd_count":     len(re.findall(r"@get_dsd", code)),
        "dsd_offset":    len(re.findall(r"@increment_dsd_offset", code)),
        "loop_count":    len(re.findall(r"for\s+\(", code)),
        "task_count":    len(re.findall(r"\btask\s+\w+\s*\(", code)),
        "activate_count":len(re.findall(r"@activate", code)),
        "comptime_vars": len(re.findall(r"\bcomptime\b", code)),
        "async_ops":     len(re.findall(r"\.async\s*=\s*true", code)),
        "import_count":  len(re.findall(r"@import_module", code)),
        "code_hash":     hashlib.sha1(code.encode()).hexdigest()[:12],
    }


# ---------------------------------------------------------------------------
# Reward computation
# ---------------------------------------------------------------------------

def compute_reward(baseline_ms: Optional[float],
                   candidate_ms: Optional[float],
                   status: str) -> float:
    """
    Normalised improvement reward in [-0.1, 1.0].
    - Compile/run failure → -0.1
    - Pass with no improvement → 0.0
    - Pass with improvement → fraction of baseline saved
    """
    if status != "pass" or candidate_ms is None:
        return -0.1
    if baseline_ms is None or baseline_ms <= 0:
        return 0.0
    return max(0.0, (baseline_ms - candidate_ms) / baseline_ms)


# ---------------------------------------------------------------------------
# Store writer
# ---------------------------------------------------------------------------

class ExperienceStore:
    def __init__(self, path: str = DEFAULT_STORE) -> None:
        self.path = os.path.expanduser(path)
        os.makedirs(os.path.dirname(self.path), exist_ok=True)

    def record(self,
               *,
               model: str,
               kernel: str,
               phase: str,               # "translation" | "optimization"
               step: str,                # optimization step name or "translate"
               code_before: str,
               code_after: str,
               benchmark_result: Dict[str, Any],
               baseline_ms: Optional[float] = None) -> Dict[str, Any]:
        """Write one transition record and return it."""
        status = str(benchmark_result.get("status", "unknown"))
        run_ms = benchmark_result.get("run_time_ms")
        candidate_ms = float(run_ms) if isinstance(run_ms, (int, float)) and run_ms else None
        reward = compute_reward(baseline_ms, candidate_ms, status)

        record: Dict[str, Any] = {
            "timestamp":      datetime.now(timezone.utc).isoformat(),
            "model":          model,
            "kernel":         kernel,
            "phase":          phase,
            "action":         step,
            "state_features": extract_csl_features(code_before),
            "next_features":  extract_csl_features(code_after),
            "baseline_ms":    baseline_ms,
            "run_time_ms":    candidate_ms,
            "reward":         round(reward, 6),
            "compile_success": benchmark_result.get("compile_time_ms", 0) > 0,
            "status":         status,
            "failure_reason": benchmark_result.get("failure_reason"),
            "code_similarity":benchmark_result.get("code_similarity"),
            "success_marker": benchmark_result.get("success_marker"),
        }
        with open(self.path, "a", encoding="utf-8") as fh:
            fh.write(json.dumps(record) + "\n")
        return record

    def load_all(self) -> list:
        if not os.path.exists(self.path):
            return []
        records = []
        with open(self.path, encoding="utf-8") as fh:
            for line in fh:
                line = line.strip()
                if line:
                    try:
                        records.append(json.loads(line))
                    except json.JSONDecodeError:
                        pass
        return records

    def summary(self) -> Dict[str, Any]:
        records = self.load_all()
        if not records:
            return {"total": 0}
        statuses = [r["status"] for r in records]
        rewards = [r["reward"] for r in records]
        runtimes = [r["run_time_ms"] for r in records if r["run_time_ms"]]
        steps = {}
        for r in records:
            a = r["action"]
            steps.setdefault(a, {"n": 0, "reward_sum": 0.0, "pass": 0})
            steps[a]["n"] += 1
            steps[a]["reward_sum"] += r["reward"]
            if r["status"] == "pass":
                steps[a]["pass"] += 1
        for v in steps.values():
            v["mean_reward"] = round(v["reward_sum"] / v["n"], 4) if v["n"] else 0.0
        return {
            "total":        len(records),
            "pass":         statuses.count("pass"),
            "fail":         statuses.count("fail"),
            "blocked":      statuses.count("blocked"),
            "mean_reward":  round(sum(rewards) / len(rewards), 4),
            "best_ms":      min(runtimes) if runtimes else None,
            "worst_ms":     max(runtimes) if runtimes else None,
            "by_step":      steps,
        }


# ---------------------------------------------------------------------------
# CLI for inspection
# ---------------------------------------------------------------------------

def main() -> None:
    import argparse
    ap = argparse.ArgumentParser(description="Inspect the RL experience store")
    ap.add_argument("--store", default=DEFAULT_STORE)
    ap.add_argument("--tail", type=int, default=0, help="Show last N records")
    ap.add_argument("--summary", action="store_true")
    args = ap.parse_args()

    store = ExperienceStore(args.store)
    if args.summary or not args.tail:
        print(json.dumps(store.summary(), indent=2))
    if args.tail:
        records = store.load_all()
        for r in records[-args.tail:]:
            print(json.dumps(r, indent=2))


if __name__ == "__main__":
    main()
