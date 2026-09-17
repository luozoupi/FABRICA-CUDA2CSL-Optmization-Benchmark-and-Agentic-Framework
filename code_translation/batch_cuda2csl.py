#!/usr/bin/env python3
"""
Batch CUDA → CSL → Optimized CSL runner.

Inspired by CUDAForge's batch.py: processes multiple kernels sequentially,
resumes from completed runs (skips kernels that already have a passing result),
and prints a summary table at the end.

Usage:
  # Run all tier-1 kernels with claude-sonnet-4-5
  python batch_cuda2csl.py --model claude-sonnet-4-5 \\
    --api-key-file ~/claude-api-key.txt --optimize

  # Run specific kernels only
  python batch_cuda2csl.py --kernels GEMM,GEMV,Cholesky --model gpt-4.1

  # Resume: skip kernels that already passed
  python batch_cuda2csl.py --model claude-sonnet-4-5 --resume

  # Dry run: show what would be run
  python batch_cuda2csl.py --dry-run
"""

from __future__ import annotations

import argparse
import json
import os
from workflow_common import default_sdk_root, sdk_sif_path  # noqa: E402
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, List, Optional

REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_OUTPUT = str(Path(__file__).resolve().parent / "results" / "batch_cuda2csl")

# Kernels ordered by complexity — simpler ones first for faster first results
TIER_1 = [
    "GEMM", "GEMV", "GEMM-Collectives-2D",
    "GEMV-Checkerboard", "GEMV-Collectives-2D",
    "Wide-Multiplication", "Single-Tile-Matvec", "Game-of-Life",
]
TIER_2 = [
    "Cholesky", "Residual", "7pt-Stencil",
]
TIER_3 = [
    "BiCGSTAB", "CG", "Power-Method", "Preconditioned-CG",
]
TIER_COMPLEX = ["Mandelbrot", "FFT-1D-2D"]  # multi-PE-type, harder to translate

ALL_TIERS = TIER_1 + TIER_2 + TIER_3


def find_latest_passing_run(output_root: str, kernel: str) -> Optional[str]:
    """
    CUDAForge resume pattern: find the most recent run directory for this kernel
    that has a passing final result. Returns path or None.
    """
    results_dir = Path(output_root).parent / "cuda2csl"
    if not results_dir.exists():
        return None
    for run_dir in sorted(results_dir.iterdir(), reverse=True):
        kernel_dir = run_dir / kernel
        if not kernel_dir.is_dir():
            continue
        final = kernel_dir / "final_result.json"
        bench = kernel_dir / "benchmark.json"
        if not final.exists() or not bench.exists():
            continue
        try:
            b = json.loads(bench.read_text())
            if b.get("status") == "pass":
                return str(kernel_dir)
        except (json.JSONDecodeError, KeyError):
            pass
    return None


def run_kernel(
    kernel: str,
    model: str,
    api_key_file: str,
    sdk_root: str,
    turns: int,
    optimize: bool,
    rl_bandit: bool,
    analysis_model: Optional[str],
    timeout: int,
    extra_args: List[str],
) -> Dict:
    """Run cuda2csl.py for one kernel. Returns result dict."""
    script = str(Path(__file__).resolve().parent / "cuda2csl.py")
    cmd = [
        sys.executable, script,
        "--kernel", kernel,
        "--model", model,
        "--api-key-file", api_key_file,
        "--sdk-root", sdk_root,
        "--turns", str(turns),
    ]
    if optimize:
        cmd.append("--optimize")
    if rl_bandit:
        cmd.append("--rl-bandit")
    if analysis_model:
        cmd += ["--analysis-model", analysis_model]
    cmd += extra_args

    env = os.environ.copy()

    t0 = time.time()
    try:
        proc = subprocess.run(
            cmd, capture_output=True, text=True, timeout=timeout, env=env,
            cwd=str(Path(__file__).resolve().parent),
        )
        elapsed = round(time.time() - t0, 1)
        # cuda2csl.py prints an indented JSON object as its final output.
        # Parse the last complete {...} block from stdout.
        result_json: Dict = {}
        try:
            result_json = json.loads(proc.stdout.strip())
        except json.JSONDecodeError:
            # Fallback: find last {...} block (handles extra logging on stdout)
            import re
            blocks = re.findall(r'\{[^{}]*\}', proc.stdout, re.DOTALL)
            for block in reversed(blocks):
                try:
                    result_json = json.loads(block)
                    if "status" in result_json:
                        break
                except json.JSONDecodeError:
                    continue
        return {
            "kernel":      kernel,
            "status":      result_json.get("status", "error" if proc.returncode != 0 else "unknown"),
            "run_time_ms": result_json.get("run_time_ms"),
            "output_dir":  result_json.get("output_dir"),
            "failure_reason": result_json.get("failure_reason"),
            "wall_s":      elapsed,
            "returncode":  proc.returncode,
            "stderr_tail": proc.stderr[-500:] if proc.stderr else "",
        }
    except subprocess.TimeoutExpired:
        return {
            "kernel": kernel, "status": "timeout",
            "run_time_ms": None, "output_dir": None,
            "failure_reason": f"wall timeout {timeout}s",
            "wall_s": round(time.time() - t0, 1), "returncode": 124,
            "stderr_tail": "",
        }


def print_summary(results: List[Dict]) -> None:
    print(f"\n{'Kernel':<25} {'Status':>8} {'Run ms':>9} {'Wall s':>7}  Output")
    print("-" * 80)
    for r in results:
        ms = str(r["run_time_ms"]) if r["run_time_ms"] else "—"
        out = (r["output_dir"] or "")[-40:] if r["output_dir"] else r.get("failure_reason", "")
        status = r["status"]
        print(f"{r['kernel']:<25} {status:>8} {ms:>9} {r['wall_s']:>7}s  {out}")
    total = len(results)
    passed = sum(1 for r in results if r["status"] == "pass")
    print(f"\n{passed}/{total} kernels passed")


def main() -> None:
    ap = argparse.ArgumentParser(description="Batch CUDA→CSL translation + optimization")
    ap.add_argument("--kernels", type=str, default=None,
                    help="Comma-separated kernel names (default: all tier 1+2+3)")
    ap.add_argument("--tiers", type=str, default="1,2,3",
                    help="Tiers to run: 1,2,3 or 1,2,3,complex (default: 1,2,3)")
    ap.add_argument("--model", type=str, default=os.getenv("OPENAI_MODEL", "gpt-4.1"))
    ap.add_argument("--analysis-model", type=str, default=None,
                    help="Cheaper model for analysis phase (CUDAForge pattern)")
    ap.add_argument("--api-key-file", type=str, default="~/codex-api-key.txt")
    ap.add_argument("--sdk-root", type=str, default=default_sdk_root())
    ap.add_argument("--turns", type=int, default=4)
    ap.add_argument("--optimize", action="store_true")
    ap.add_argument("--rl-bandit", action="store_true")
    ap.add_argument("--resume", action="store_true",
                    help="Skip kernels that already have a passing result")
    ap.add_argument("--output", type=str, default=DEFAULT_OUTPUT)
    ap.add_argument("--timeout", type=int, default=1800,
                    help="Per-kernel wall timeout in seconds (default 1800 = 30 min)")
    ap.add_argument("--inter-kernel-delay", type=int, default=30,
                    help="Seconds to sleep between kernels to avoid API rate limits (default 30)")
    ap.add_argument("--dry-run", action="store_true",
                    help="Print what would be run without executing")
    ap.add_argument("--start-from", type=str, default=None,
                    help="Start batch from this kernel name (skip earlier ones)")
    args, extra_args = ap.parse_known_args()

    # Resolve kernel list
    if args.kernels:
        kernels = [k.strip() for k in args.kernels.split(",") if k.strip()]
    else:
        kernels = list(ALL_TIERS)
        if "complex" in args.tiers:
            kernels += TIER_COMPLEX

    # Apply --start-from
    if args.start_from and args.start_from in kernels:
        idx = kernels.index(args.start_from)
        kernels = kernels[idx:]

    timestamp = datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S")
    batch_output = os.path.join(os.path.expanduser(args.output), f"batch_{timestamp}")
    os.makedirs(batch_output, exist_ok=True)

    print(f"Batch run: {len(kernels)} kernels | model={args.model} | optimize={args.optimize}")
    print(f"Output: {batch_output}\n")

    results: List[Dict] = []
    for i, kernel in enumerate(kernels, 1):
        print(f"[{i}/{len(kernels)}] {kernel}", end="", flush=True)

        # CUDAForge resume: skip if already passing
        if args.resume:
            existing = find_latest_passing_run(args.output, kernel)
            if existing:
                print(f" → SKIPPED (existing pass: {existing})")
                results.append({
                    "kernel": kernel, "status": "skipped",
                    "run_time_ms": None, "output_dir": existing,
                    "failure_reason": "resumed", "wall_s": 0,
                    "returncode": 0, "stderr_tail": "",
                })
                continue

        if args.dry_run:
            print(f" → DRY RUN")
            continue

        print(" → running...", flush=True)
        result = run_kernel(
            kernel=kernel,
            model=args.model,
            api_key_file=args.api_key_file,
            sdk_root=args.sdk_root,
            turns=args.turns,
            optimize=args.optimize,
            rl_bandit=args.rl_bandit,
            analysis_model=args.analysis_model,
            timeout=args.timeout,
            extra_args=extra_args,
        )
        results.append(result)
        status_str = f"{result['status']} {result.get('run_time_ms') or ''}ms"
        print(f"   {status_str} ({result['wall_s']}s)")

        if i < len(kernels) and args.inter_kernel_delay > 0:
            import time
            print(f"   (cooling down {args.inter_kernel_delay}s before next kernel...)")
            time.sleep(args.inter_kernel_delay)

        # Save incremental results after each kernel (CUDAForge pattern)
        summary_path = os.path.join(batch_output, "results.json")
        with open(summary_path, "w") as f:
            json.dump({"model": args.model, "results": results}, f, indent=2)

    if not args.dry_run:
        print_summary(results)
        print(f"\nFull results: {os.path.join(batch_output, 'results.json')}")


if __name__ == "__main__":
    main()
