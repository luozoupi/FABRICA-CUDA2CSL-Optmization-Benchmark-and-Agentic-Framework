#!/usr/bin/env python3
"""Re-benchmark saved CG/PCG artifacts against the updated run.py
(residual-based convergence check) to validate the tolerance fix.

Usage:
    micromamba run -n xkernel-agent python rebenchmark_tolerance.py
"""
import json
import os
import sys
import tempfile

from benchmark_csl import benchmark_translated_compute_file

SWEEP_DIR = os.path.join(
    os.path.dirname(__file__),
    "results/agent_full_sweep_20260624_205754",
)

KERNELS = [
    {
        "name": "CG",
        "artifact": os.path.join(SWEEP_DIR, "CG/run_20260625_053302/CG/src/kernel_cg.csl"),
        "reference_dir": os.path.expanduser("~/xkernel/kernels/Conjugate Gradient/CSL"),
        "target_relpath": "src/kernel_cg.csl",
    },
    {
        "name": "PCG",
        "artifact": os.path.join(SWEEP_DIR, "Preconditioned-CG/run_20260625_061422/Preconditioned-CG/src/kernel_pcg.csl"),
        "reference_dir": os.path.expanduser("~/xkernel/kernels/Preconditioned CG/CSL"),
        "target_relpath": "src/kernel_pcg.csl",
    },
]

SDK_ROOT = os.path.expanduser(default_sdk_root())


def main():
    for k in KERNELS:
        print(f"\n{'='*60}")
        print(f"RE-BENCHMARKING: {k['name']}")
        print(f"  artifact: {k['artifact']}")
        print(f"  reference: {k['reference_dir']}")
        print(f"{'='*60}")

        if not os.path.isfile(k["artifact"]):
            print(f"  SKIP — artifact not found: {k['artifact']}")
            continue

        with tempfile.TemporaryDirectory(prefix=f"rebench_{k['name']}_") as work_dir:
            result = benchmark_translated_compute_file(
                translated_path=k["artifact"],
                reference_dir=k["reference_dir"],
                target_relpath=k["target_relpath"],
                work_dir=work_dir,
                sdk_root=SDK_ROOT,
                arch="wse3",
                timeout=120,
                keep_staged_bundle=False,
                num_runs=1,
            )

        status = result.get("status")
        cycles = result.get("cycles_send")
        failure = result.get("failure_reason", "")
        print(f"\n  STATUS:  {status}")
        print(f"  CYCLES:  {cycles}")
        if status != "pass":
            print(f"  REASON:  {failure}")
            # Print last transcript entry stderr
            transcript = result.get("transcript", [])
            if transcript:
                last = transcript[-1] if isinstance(transcript[-1], dict) else {}
                stderr_tail = (last.get("stderr") or last.get("stdout") or "")[-500:]
                if stderr_tail:
                    print(f"  STDERR (tail):\n{stderr_tail}")

    print(f"\n{'='*60}")
    print("DONE")


if __name__ == "__main__":
    main()
