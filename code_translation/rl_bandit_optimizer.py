#!/usr/bin/env python3
"""
Multi-armed bandit optimizer for CSL optimization step selection.

Replaces the fixed-order step loop with Thompson Sampling (Beta-Bernoulli bandit)
that learns which optimization steps consistently improve run_time_ms. State
persists across sessions in ~/.cache/fabrica/rl_data/bandit_stats.json.

Used by cuda2csl.py via --rl-bandit flag.
"""

from __future__ import annotations

import json
import math
import os
import random
from typing import Any, Dict, List, Optional, Tuple

DEFAULT_STATS_PATH = os.path.expanduser("~/.cache/fabrica/rl_data/bandit_stats.json")
MIN_PULLS_BEFORE_EXPLOIT = 3   # cold-start: explore before exploiting


class ThompsonBandit:
    """
    Beta-Bernoulli Thompson Sampling bandit.

    Reward is binarised: 1 if run_time improved vs current best, 0 otherwise.
    Beta(alpha, beta) posterior updated per pull.
    """

    def __init__(self, arms: List[str], stats_path: str = DEFAULT_STATS_PATH) -> None:
        self.arms = arms
        self.stats_path = os.path.expanduser(stats_path)
        # alpha = successes+1, beta = failures+1 (Beta prior = Beta(1,1))
        self.stats: Dict[str, Dict[str, Any]] = {
            arm: {"alpha": 1, "beta": 1, "n": 0, "reward_sum": 0.0} for arm in arms
        }
        self._load()

    # ------------------------------------------------------------------
    # Persistence
    # ------------------------------------------------------------------

    def _load(self) -> None:
        if not os.path.exists(self.stats_path):
            return
        try:
            with open(self.stats_path, encoding="utf-8") as fh:
                saved = json.load(fh)
            for arm in self.arms:
                if arm in saved:
                    self.stats[arm].update(saved[arm])
        except (json.JSONDecodeError, KeyError):
            pass

    def save(self) -> None:
        os.makedirs(os.path.dirname(self.stats_path), exist_ok=True)
        with open(self.stats_path, "w", encoding="utf-8") as fh:
            json.dump(self.stats, fh, indent=2)

    # ------------------------------------------------------------------
    # Bandit interface
    # ------------------------------------------------------------------

    def select(self, exclude: Optional[List[str]] = None) -> str:
        """
        Thompson Sampling: draw from Beta(alpha, beta) per arm, pick argmax.
        Arms in `exclude` (already tried this episode) are skipped.
        """
        candidates = [a for a in self.arms if not exclude or a not in exclude]
        if not candidates:
            candidates = list(self.arms)

        # Cold start: round-robin until each arm has MIN_PULLS_BEFORE_EXPLOIT pulls
        cold = [a for a in candidates if self.stats[a]["n"] < MIN_PULLS_BEFORE_EXPLOIT]
        if cold:
            return min(cold, key=lambda a: self.stats[a]["n"])

        samples = {a: random.betavariate(self.stats[a]["alpha"], self.stats[a]["beta"])
                   for a in candidates}
        return max(samples, key=samples.__getitem__)

    def update(self, arm: str, reward: float) -> None:
        """
        Update arm posterior. Reward binarised at 0.0 threshold.
        Continuous reward stored for logging.
        """
        s = self.stats[arm]
        s["n"] += 1
        s["reward_sum"] = round(s["reward_sum"] + reward, 6)
        if reward > 0.0:
            s["alpha"] += 1   # success
        else:
            s["beta"] += 1    # failure / no improvement
        self.save()

    def ranked_arms(self) -> List[Tuple[str, float]]:
        """Return arms sorted by posterior mean alpha/(alpha+beta)."""
        return sorted(
            [(a, self.stats[a]["alpha"] / (self.stats[a]["alpha"] + self.stats[a]["beta"]))
             for a in self.arms],
            key=lambda x: x[1], reverse=True,
        )

    def summary(self) -> Dict[str, Any]:
        return {
            "arms": {
                arm: {
                    "n":          s["n"],
                    "alpha":      s["alpha"],
                    "beta":       s["beta"],
                    "post_mean":  round(s["alpha"] / (s["alpha"] + s["beta"]), 4),
                    "mean_reward":round(s["reward_sum"] / s["n"], 4) if s["n"] else 0.0,
                }
                for arm, s in self.stats.items()
            },
            "ranked": [(a, round(p, 4)) for a, p in self.ranked_arms()],
        }


class UCB1Bandit:
    """
    UCB1 bandit (alternative to Thompson).
    Action = argmax( mean_reward + sqrt(2 ln t / n_pulls) ).
    """

    def __init__(self, arms: List[str], stats_path: str = DEFAULT_STATS_PATH) -> None:
        self.arms = arms
        self.stats_path = os.path.expanduser(stats_path + ".ucb1")
        self.stats: Dict[str, Dict[str, Any]] = {
            arm: {"n": 0, "reward_sum": 0.0} for arm in arms
        }
        self.t = 0
        self._load()

    def _load(self) -> None:
        if not os.path.exists(self.stats_path):
            return
        try:
            with open(self.stats_path, encoding="utf-8") as fh:
                saved = json.load(fh)
            self.t = saved.get("t", 0)
            for arm in self.arms:
                if arm in saved.get("arms", {}):
                    self.stats[arm].update(saved["arms"][arm])
        except (json.JSONDecodeError, KeyError):
            pass

    def save(self) -> None:
        os.makedirs(os.path.dirname(self.stats_path), exist_ok=True)
        with open(self.stats_path, "w", encoding="utf-8") as fh:
            json.dump({"t": self.t, "arms": self.stats}, fh, indent=2)

    def select(self, exclude: Optional[List[str]] = None) -> str:
        candidates = [a for a in self.arms if not exclude or a not in exclude]
        if not candidates:
            candidates = list(self.arms)
        # Pull unpulled arms first
        unpulled = [a for a in candidates if self.stats[a]["n"] == 0]
        if unpulled:
            return unpulled[0]
        self.t += 1
        ucb = {
            a: (self.stats[a]["reward_sum"] / self.stats[a]["n"]
                + math.sqrt(2 * math.log(self.t) / self.stats[a]["n"]))
            for a in candidates
        }
        return max(ucb, key=ucb.__getitem__)

    def update(self, arm: str, reward: float) -> None:
        self.stats[arm]["n"] += 1
        self.stats[arm]["reward_sum"] += reward
        self.save()


# ---------------------------------------------------------------------------
# Bandit-driven optimization loop
# ---------------------------------------------------------------------------

def bandit_optimize(
    orchestrator: Any,
    kernel_name: str,
    reference_dir: str,
    target_relpath: str,
    reference_contract: str,
    reference_compute_file: str,
    baseline_result: Dict[str, Any],
    all_steps: List[str],
    n_rounds: int = 6,
    experience_store: Any = None,
    model: str = "unknown",
    stats_path: str = DEFAULT_STATS_PATH,
) -> Tuple[str, Dict[str, Any], Dict[str, Any]]:
    """
    Drop-in replacement for CUDA2CSLOrchestrator.optimize() that uses
    Thompson Sampling bandit to select steps instead of fixed order.

    n_rounds: how many steps to attempt per run (can exceed len(all_steps)
              to allow revisiting arms).
    """
    from experience_store import ExperienceStore, compute_reward
    from prompt_cuda2csl import (
        CSL_OPTIMIZATION_STEPS,
        Instruction_system_csl_optimization,
        default_frozen_callout_block,
        q_optimize_csl_compute,
    )
    import csl_knowledge_base
    from workflow_common import extract_code_block, format_command_transcript

    bandit = ThompsonBandit(arms=all_steps, stats_path=stats_path)
    exp = experience_store or ExperienceStore()

    summary: Dict[str, Any] = {
        "mode":             "bandit_thompson",
        "baseline":         {"status": baseline_result.get("status"),
                             "run_time_ms": baseline_result.get("run_time_ms")},
        "steps":            [],
        "selected_variant": "baseline",
        "bandit_summary":   None,
    }

    if baseline_result.get("status") != "pass":
        summary["skipped"] = "Baseline did not pass; optimization skipped."
        return orchestrator.current_code, baseline_result, summary

    best_code = orchestrator.current_code
    best_result = baseline_result
    tried: List[str] = []

    for _ in range(n_rounds):
        step_name = bandit.select(exclude=None)  # allow revisits for learning
        tried.append(step_name)
        description = CSL_OPTIMIZATION_STEPS.get(step_name, step_name)

        from cuda2csl import benchmark_summary_text
        prompt = q_optimize_csl_compute.format(
            optimization_name=step_name,
            optimization_description=description,
            frozen_callout_block=default_frozen_callout_block(
                getattr(orchestrator, "kernel_spec", None)
            ),
            knowledge_base=csl_knowledge_base.for_optimization(),
            reference_contract=reference_contract,
            current_code=best_code,
            benchmark_summary=benchmark_summary_text(best_result),
            profiler_feedback=getattr(
                orchestrator,
                "latest_profiler_feedback",
                "(profiler feedback not collected)",
            ),
        )
        messages = [
            {"role": "system", "content": Instruction_system_csl_optimization},
            {"role": "user",   "content": prompt},
        ]
        reply = orchestrator._llm_call(messages)
        candidate = extract_code_block(reply, "csl")

        if not candidate:
            reward = -0.1
            bandit.update(step_name, reward)
            summary["steps"].append({"step": step_name, "status": "failed",
                                     "reason": "no CSL code block", "reward": reward})
            continue

        bench = orchestrator._benchmark_current_code(
            kernel_name=kernel_name,
            current_code=candidate,
            reference_dir=reference_dir,
            target_relpath=target_relpath,
        )
        baseline_ms = best_result.get("run_time_ms")
        candidate_ms = bench.get("run_time_ms")
        reward = compute_reward(baseline_ms, candidate_ms, str(bench.get("status", "fail")))
        bandit.update(step_name, reward)

        # Record to experience store
        exp.record(
            model=model, kernel=kernel_name, phase="bandit_optimization",
            step=step_name, code_before=best_code, code_after=candidate,
            benchmark_result=bench, baseline_ms=baseline_ms,
        )

        step_record: Dict[str, Any] = {
            "step":           step_name,
            "status":         bench.get("status"),
            "failure_reason": bench.get("failure_reason"),
            "run_time_ms":    bench.get("run_time_ms"),
            "reward":         round(reward, 4),
        }
        if bench.get("status") == "pass":
            current_best = best_result.get("run_time_ms")
            if (current_best is None or
                    (isinstance(candidate_ms, (int, float)) and
                     isinstance(current_best, (int, float)) and
                     candidate_ms < current_best)):
                best_code = candidate
                best_result = bench
                summary["selected_variant"] = step_name
                step_record["selected"] = True
        summary["steps"].append(step_record)

    orchestrator.current_code = best_code
    summary["final_status"] = best_result.get("status")
    summary["final_run_time_ms"] = best_result.get("run_time_ms")
    summary["bandit_summary"] = bandit.summary()
    return best_code, best_result, summary


# ---------------------------------------------------------------------------
# CLI for inspecting bandit state
# ---------------------------------------------------------------------------

def main() -> None:
    import argparse
    ap = argparse.ArgumentParser(description="Inspect or reset bandit stats")
    ap.add_argument("--stats", default=DEFAULT_STATS_PATH)
    ap.add_argument("--reset", action="store_true", help="Delete stats file")
    args = ap.parse_args()

    if args.reset:
        if os.path.exists(args.stats):
            os.remove(args.stats)
            print(f"Deleted {args.stats}")
        return

    from prompt_cuda2csl import DEFAULT_CSL_OPT_STEPS
    bandit = ThompsonBandit(arms=DEFAULT_CSL_OPT_STEPS, stats_path=args.stats)
    print(json.dumps(bandit.summary(), indent=2))


if __name__ == "__main__":
    main()
