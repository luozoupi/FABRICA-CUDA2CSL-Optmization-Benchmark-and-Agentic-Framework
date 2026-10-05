#!/usr/bin/env python3
"""
AlphaEvolve-compatible evaluator for CSL compute files.

Mirrors the interface of alphaevolve_evaluator.py (CUDA/GPU version) but
evaluates candidate pe.csl files using the Cerebras SDK simulator.

Usage:
  # Evaluate a single candidate pe.csl against its reference bundle
  python alphaevolve_csl_evaluator.py \
    --pe-csl path/to/candidate_pe.csl \
    --reference-dir ~/xkernel/kernels/GEMV/CSL \
    --sdk-root ~/cs_sdk-1.4.0

  # Evaluate the reference pe.csl itself (should give fitness ~1.0)
  python alphaevolve_csl_evaluator.py \
    --pe-csl ~/xkernel/kernels/GEMV/CSL/pe.csl \
    --reference-dir ~/xkernel/kernels/GEMV/CSL \
    --sdk-root ~/cs_sdk-1.4.0

Contract (mirrors alphaevolve_evaluator.py):
  - exit 0 on success, non-zero on hard error
  - final line on stdout = JSON: {"pass_rate": ..., "geomean_speedup": ..., "fitness": ...}
"""

from __future__ import annotations

import argparse
import json
import math
import os
import sys
import tempfile
from pathlib import Path

# The no-optimization best result from gpt-5.4-pro — used as denominator for speedup
BASELINE_MS = float(os.environ.get("CSL_BASELINE_MS", "2930.0"))


def _add_code_translation_to_path() -> None:
    here = Path(__file__).resolve().parent
    if str(here) not in sys.path:
        sys.path.insert(0, str(here))


_add_code_translation_to_path()

from benchmark_csl import benchmark_translated_compute_file  # noqa: E402
from workflow_common import expand_path                       # noqa: E402
from workflow_common import default_sdk_root, sdk_sif_path  # noqa: E402


_EVAL_WORK_DIR = os.path.expanduser("~/xkernel/rl_data/eval_work")


def eval_csl_candidate(
    pe_csl_path: str,
    reference_dir: str,
    sdk_root: str,
    target_relpath: str = "pe.csl",
    arch: str = "wse3",
    timeout: int = 300,
) -> dict:
    """
    Compile and run one candidate CSL compute file against its reference bundle.
    Returns a dict compatible with the AlphaEvolve evaluator contract.

    Work directory is placed under ~/xkernel/ (NFS-shared) so the singularity
    SSH shim on user-node-1 can bind-mount the staged bundle paths.
    """
    pe_csl_path  = expand_path(pe_csl_path)
    reference_dir = expand_path(reference_dir)
    os.makedirs(_EVAL_WORK_DIR, exist_ok=True)

    with tempfile.TemporaryDirectory(prefix="aevo_csl_", dir=_EVAL_WORK_DIR) as tmp:
        result = benchmark_translated_compute_file(
            translated_path=pe_csl_path,
            reference_dir=reference_dir,
            target_relpath=target_relpath,
            work_dir=tmp,
            sdk_root=sdk_root,
            arch=arch,
            timeout=timeout,
            keep_staged_bundle=False,
            # W2 inner loop: rank candidates by cycles only — skip the held-out gate
            # (it would ~3x cost per candidate). The final pass confirmation in the
            # translate/optimize driver runs held-out. (An explicit
            # XKERNEL_HELDOUT_EVAL=1 still forces it on if a caller wants it.)
            heldout_eval=False,
        )

    status   = result.get("status", "fail")
    run_ms   = result.get("run_time_ms")
    compiled = result.get("compile_time_ms", 0) > 0
    passed   = (status == "pass") and bool(result.get("success_marker"))

    speedup = 0.0
    if passed and run_ms and run_ms > 0:
        speedup = BASELINE_MS / run_ms

    return {
        "compiled":         compiled,
        "passed":           passed,
        "ms":               run_ms,
        "speedup":          round(speedup, 4),
        "status":           status,
        "failure_reason":   result.get("failure_reason"),
        "compile_time_ms":  result.get("compile_time_ms"),
        "code_similarity":  result.get("code_similarity"),
        "transcript_steps": len(result.get("transcript", [])),
    }


def eval_csl_suite(
    candidates: list[tuple[str, str, str]],  # (name, pe_csl_path, reference_dir)
    sdk_root: str,
    target_relpath: str = "pe.csl",
) -> dict:
    """
    Evaluate a suite of CSL candidates. Mirrors eval_golden() from the CUDA evaluator.
    Returns aggregate fitness = pass_rate × geomean_speedup.
    """
    results = []
    passes = 0
    speedups = []

    for name, pe_csl_path, reference_dir in candidates:
        r = eval_csl_candidate(pe_csl_path, reference_dir, sdk_root, target_relpath)
        r["name"] = name
        results.append(r)
        if r["passed"]:
            passes += 1
            if r["speedup"] > 0:
                speedups.append(r["speedup"])

    n = len(candidates)
    pass_rate = passes / n if n else 0.0
    geomean = (
        math.exp(sum(math.log(s) for s in speedups) / len(speedups))
        if speedups else 0.0
    )
    fitness = pass_rate * geomean if speedups else pass_rate

    return {
        "pass_rate":        round(pass_rate, 4),
        "geomean_speedup":  round(geomean, 4),
        "fitness":          round(fitness, 4),
        "results":          results,
    }


def main() -> int:
    ap = argparse.ArgumentParser(description="AlphaEvolve CSL evaluator")
    ap.add_argument("--pe-csl",       required=True, help="Candidate pe.csl path")
    ap.add_argument("--reference-dir",required=True, help="Reference CSL bundle directory")
    ap.add_argument("--sdk-root",     default=default_sdk_root())
    ap.add_argument("--target-relpath", default="pe.csl")
    ap.add_argument("--arch",         default="wse3")
    ap.add_argument("--timeout",      type=int, default=300)
    ap.add_argument("--baseline-ms",  type=float, default=BASELINE_MS,
                    help="Reference run_time_ms for speedup denominator")
    args = ap.parse_args()

    os.environ["CSL_BASELINE_MS"] = str(args.baseline_ms)

    r = eval_csl_candidate(
        pe_csl_path=args.pe_csl,
        reference_dir=args.reference_dir,
        sdk_root=args.sdk_root,
        target_relpath=args.target_relpath,
        arch=args.arch,
        timeout=args.timeout,
    )
    fitness = r["speedup"] if r["passed"] else 0.0
    out = {
        "pass_rate":       1.0 if r["passed"] else 0.0,
        "geomean_speedup": r["speedup"],
        "fitness":         fitness,
        "result":          r,
    }

    # Full details for humans
    print(json.dumps(out, indent=2))
    # Final line = AlphaEvolve summary contract
    summary = {k: out[k] for k in ("pass_rate", "geomean_speedup", "fitness")}
    print(json.dumps(summary))

    return 0 if r["passed"] else 1


if __name__ == "__main__":
    sys.exit(main())
