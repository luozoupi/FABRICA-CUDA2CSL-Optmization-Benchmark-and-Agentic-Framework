#!/usr/bin/env python3
"""
Monte Carlo Tree Search optimizer for CSL optimization step sequences.

Models the optimization process as a tree:
  Node: (csl_code_hash, run_time_ms, depth)
  Edge: which optimization step was applied
  Root: baseline translation result

UCT selection, LLM rollout, backpropagation of normalised runtime improvement.
Tree persists across runs in ~/.cache/fabrica/rl_data/mcts_tree.json.
"""

from __future__ import annotations

import hashlib
import json
import math
import os
import random
from typing import Any, Dict, List, Optional, Tuple

DEFAULT_TREE_PATH = os.path.expanduser("~/.cache/fabrica/rl_data/mcts_tree.json")
UCT_C = 1.4     # exploration constant
MAX_DEPTH = 4   # maximum step depth per episode


def _code_hash(code: str) -> str:
    return hashlib.sha1(code.encode()).hexdigest()[:16]


class MCTSNode:
    __slots__ = ("code_hash", "run_ms", "depth", "parent_hash", "action",
                 "n", "q", "children")

    def __init__(self, code_hash: str, run_ms: Optional[float], depth: int,
                 parent_hash: Optional[str], action: Optional[str]) -> None:
        self.code_hash   = code_hash
        self.run_ms      = run_ms
        self.depth       = depth
        self.parent_hash = parent_hash
        self.action      = action      # step that led here
        self.n           = 0           # visit count
        self.q           = 0.0         # cumulative reward
        self.children: List[str] = []  # child code_hashes

    def uct_score(self, parent_n: int) -> float:
        if self.n == 0:
            return float("inf")
        return (self.q / self.n) + UCT_C * math.sqrt(math.log(parent_n) / self.n)

    def to_dict(self) -> Dict[str, Any]:
        return {
            "code_hash":   self.code_hash,
            "run_ms":      self.run_ms,
            "depth":       self.depth,
            "parent_hash": self.parent_hash,
            "action":      self.action,
            "n":           self.n,
            "q":           self.q,
            "children":    self.children,
        }

    @classmethod
    def from_dict(cls, d: Dict[str, Any]) -> "MCTSNode":
        node = cls(d["code_hash"], d["run_ms"], d["depth"],
                   d["parent_hash"], d["action"])
        node.n = d["n"]
        node.q = d["q"]
        node.children = d["children"]
        return node


class MCTSTree:
    def __init__(self, tree_path: str = DEFAULT_TREE_PATH) -> None:
        self.tree_path = os.path.expanduser(tree_path)
        self.nodes: Dict[str, MCTSNode] = {}
        # code_hash → actual CSL code (session-only, not persisted to save space)
        self._code_cache: Dict[str, str] = {}
        self._load()

    # ------------------------------------------------------------------
    # Persistence (node stats only, not code text)
    # ------------------------------------------------------------------

    def _load(self) -> None:
        if not os.path.exists(self.tree_path):
            return
        try:
            with open(self.tree_path, encoding="utf-8") as fh:
                data = json.load(fh)
            for h, d in data.items():
                self.nodes[h] = MCTSNode.from_dict(d)
        except (json.JSONDecodeError, KeyError):
            pass

    def save(self) -> None:
        os.makedirs(os.path.dirname(self.tree_path), exist_ok=True)
        with open(self.tree_path, "w", encoding="utf-8") as fh:
            json.dump({h: n.to_dict() for h, n in self.nodes.items()}, fh, indent=2)

    # ------------------------------------------------------------------
    # Tree operations
    # ------------------------------------------------------------------

    def add_node(self, code: str, run_ms: Optional[float], depth: int,
                 parent_hash: Optional[str], action: Optional[str]) -> MCTSNode:
        h = _code_hash(code)
        self._code_cache[h] = code
        if h not in self.nodes:
            self.nodes[h] = MCTSNode(h, run_ms, depth, parent_hash, action)
        if parent_hash and h not in self.nodes[parent_hash].children:
            self.nodes[parent_hash].children.append(h)
        return self.nodes[h]

    def get_code(self, h: str) -> Optional[str]:
        return self._code_cache.get(h)

    def backpropagate(self, path: List[str], reward: float) -> None:
        for h in reversed(path):
            if h in self.nodes:
                self.nodes[h].n += 1
                self.nodes[h].q += reward

    def select_child(self, node: MCTSNode, tried_actions: List[str],
                     all_steps: List[str]) -> Optional[str]:
        """
        UCT selection among children. Returns child code_hash or None if
        unexplored actions remain (forcing expansion).
        """
        tried_in_children = {
            self.nodes[c].action for c in node.children if c in self.nodes
        }
        unexplored = [s for s in all_steps if s not in tried_in_children
                      and s not in tried_actions]
        if unexplored:
            return None  # expand
        if not node.children:
            return None
        return max(
            (c for c in node.children if c in self.nodes),
            key=lambda c: self.nodes[c].uct_score(node.n + 1),
            default=None,
        )

    def summary(self) -> Dict[str, Any]:
        if not self.nodes:
            return {"nodes": 0}
        visits = [n.n for n in self.nodes.values()]
        best = min(
            (n for n in self.nodes.values() if n.run_ms),
            key=lambda n: n.run_ms or float("inf"),
            default=None,
        )
        return {
            "nodes":        len(self.nodes),
            "total_visits": sum(visits),
            "best_ms":      best.run_ms if best else None,
            "best_action":  best.action if best else None,
            "best_depth":   best.depth if best else None,
        }


# ---------------------------------------------------------------------------
# MCTS optimization loop
# ---------------------------------------------------------------------------

def mcts_optimize(
    orchestrator: Any,
    kernel_name: str,
    reference_dir: str,
    target_relpath: str,
    reference_contract: str,
    reference_compute_file: str,
    baseline_result: Dict[str, Any],
    all_steps: List[str],
    budget: int = 20,
    experience_store: Any = None,
    model: str = "unknown",
    tree_path: str = DEFAULT_TREE_PATH,
) -> Tuple[str, Dict[str, Any], Dict[str, Any]]:
    """
    MCTS-driven optimization. Explores the tree of (code, step) sequences
    up to `budget` node evaluations.
    """
    from cuda2csl import benchmark_summary_text as _bst  # noqa: F401 (used via local var)
    from experience_store import ExperienceStore, compute_reward
    from prompt_cuda2csl import (
        CSL_OPTIMIZATION_STEPS,
        Instruction_system_csl_optimization,
        default_frozen_callout_block,
        q_optimize_csl_compute,
    )
    import csl_knowledge_base
    from workflow_common import extract_code_block

    tree = MCTSTree(tree_path=tree_path)
    exp = experience_store or ExperienceStore()

    summary: Dict[str, Any] = {
        "mode":             "mcts",
        "baseline":         {"status": baseline_result.get("status"),
                             "run_time_ms": baseline_result.get("run_time_ms")},
        "budget":           budget,
        "nodes_explored":   0,
        "steps":            [],
        "selected_variant": "baseline",
    }

    if baseline_result.get("status") != "pass":
        summary["skipped"] = "Baseline did not pass; optimization skipped."
        return orchestrator.current_code, baseline_result, summary

    baseline_ms = float(baseline_result.get("run_time_ms") or 0)
    baseline_code = orchestrator.current_code
    root = tree.add_node(baseline_code, baseline_ms, depth=0,
                         parent_hash=None, action=None)

    best_code = baseline_code
    best_result = baseline_result
    nodes_explored = 0

    def _benchmark_summary(result: Dict) -> str:
        return json.dumps({
            "status":           result.get("status"),
            "failure_reason":   result.get("failure_reason"),
            "compile_time_ms":  result.get("compile_time_ms"),
            "run_time_ms":      result.get("run_time_ms"),
            "success_marker":   result.get("success_marker"),
        }, indent=2)

    for _iteration in range(budget):
        if nodes_explored >= budget:
            break

        # --- Selection: walk tree from root using UCT ---
        path: List[str] = [root.code_hash]
        node = root
        tried_actions: List[str] = []

        while node.depth < MAX_DEPTH:
            child_hash = tree.select_child(node, tried_actions, all_steps)
            if child_hash is None:
                break   # need to expand
            tried_actions.append(tree.nodes[child_hash].action or "")
            node = tree.nodes[child_hash]
            path.append(node.code_hash)
            if not tree.get_code(node.code_hash):
                break   # code evicted from cache, can't continue

        if node.depth >= MAX_DEPTH:
            continue

        # --- Expansion: choose an unexplored step from this node ---
        tried_in_children = {
            tree.nodes[c].action for c in node.children if c in tree.nodes
        }
        untried = [s for s in all_steps if s not in tried_in_children]
        if not untried:
            untried = all_steps   # all tried — allow revisit
        step_name = random.choice(untried)

        current_code = tree.get_code(node.code_hash)
        if not current_code:
            continue    # cache miss — skip

        description = CSL_OPTIMIZATION_STEPS.get(step_name, step_name)
        prompt = q_optimize_csl_compute.format(
            optimization_name=step_name,
            optimization_description=description,
            frozen_callout_block=default_frozen_callout_block(
                getattr(orchestrator, "kernel_spec", None)
            ),
            knowledge_base=csl_knowledge_base.for_optimization(),
            reference_contract=reference_contract,
            current_code=current_code,
            benchmark_summary=_benchmark_summary(
                best_result if node.code_hash == root.code_hash else
                {"status": "pass", "run_time_ms": node.run_ms,
                 "compile_time_ms": 4000, "failure_reason": None,
                 "success_marker": True}
            ),
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
            tree.backpropagate(path, -0.1)
            summary["steps"].append({"step": step_name, "status": "failed",
                                     "reason": "no code block", "reward": -0.1})
            continue

        # --- Simulation: benchmark the candidate ---
        bench = orchestrator._benchmark_current_code(
            kernel_name=kernel_name,
            current_code=candidate,
            reference_dir=reference_dir,
            target_relpath=target_relpath,
        )
        nodes_explored += 1
        candidate_ms = bench.get("run_time_ms")
        reward = compute_reward(
            node.run_ms, candidate_ms, str(bench.get("status", "fail"))
        )

        # --- Backpropagation ---
        child_node = tree.add_node(
            candidate,
            float(candidate_ms) if candidate_ms else None,
            depth=node.depth + 1,
            parent_hash=node.code_hash,
            action=step_name,
        )
        path.append(child_node.code_hash)
        tree.backpropagate(path, reward)
        tree.save()

        # Record experience
        exp.record(
            model=model, kernel=kernel_name, phase="mcts_optimization",
            step=step_name, code_before=current_code, code_after=candidate,
            benchmark_result=bench, baseline_ms=baseline_ms,
        )

        step_record: Dict[str, Any] = {
            "step":           step_name,
            "status":         bench.get("status"),
            "failure_reason": bench.get("failure_reason"),
            "run_time_ms":    candidate_ms,
            "depth":          child_node.depth,
            "reward":         round(reward, 4),
            "node_visits":    child_node.n,
        }
        if bench.get("status") == "pass":
            current_best_ms = best_result.get("run_time_ms")
            if (current_best_ms is None or
                    (isinstance(candidate_ms, (int, float)) and
                     isinstance(current_best_ms, (int, float)) and
                     candidate_ms < current_best_ms)):
                best_code = candidate
                best_result = bench
                summary["selected_variant"] = f"{step_name}@depth{child_node.depth}"
                step_record["selected"] = True
        summary["steps"].append(step_record)

    orchestrator.current_code = best_code
    summary["nodes_explored"]   = nodes_explored
    summary["final_status"]     = best_result.get("status")
    summary["final_run_time_ms"]= best_result.get("run_time_ms")
    summary["tree_summary"]     = tree.summary()
    return best_code, best_result, summary
