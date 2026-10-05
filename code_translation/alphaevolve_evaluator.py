#!/usr/bin/env python3
"""
AlphaEvolve evaluator for xkernel CUDA kernels.

Usage:
  # Single kernel
  python alphaevolve_evaluator.py --kernel /abs/path/to/kernel.cu [--gpu 6]

  # Golden 6 (pipeline-level)
  python alphaevolve_evaluator.py --golden [--xkernel-root /home/USER/xkernel]

Contract for AlphaEvolve:
  - exit 0 on success, non-zero on hard error
  - final line on stdout = JSON: {"pass_rate": ..., "geomean_speedup": ..., "fitness": ...}
  - per-candidate wall-clock budget: <600 s (configurable)
"""
import argparse
import json
import math
import os
import re
import subprocess
import sys
import tempfile
import time
from pathlib import Path

GOLDEN_6 = [
    ("7-Point Stencil", "7-Point Stencil/CUDA/kernel.cu", []),
    ("SpMV",            "SpMV/CUDA/kernel.cu",            []),
    ("GEMM",            "GEMM/CUDA/kernel.cu",            []),
    ("Conjugate Gradient", "Conjugate Gradient/CUDA/kernel.cu", []),
    ("BFS",             "BFS/CUDA/kernel.cu",             ["20000", "0.001"]),
    ("SageAttention",   "SageAttention/CUDA/kernel.cu",   ["256", "64"]),
]

NVCC = os.environ.get("NVCC", "nvcc")
NVCC_FLAGS = ["-O3", "-std=c++17", "--expt-relaxed-constexpr"]
COMPILE_TIMEOUT = 120
RUN_TIMEOUT = 300

MS_REGEX = re.compile(r"(\d+(?:\.\d+)?)\s*ms")
PASS_REGEX = re.compile(r"\bPASS\b")
FAIL_REGEX = re.compile(r"\bFAIL\b")


def compile_one(src: Path, workdir: Path) -> tuple[bool, Path, str]:
    """Return (ok, exe_path, log)."""
    exe = workdir / (src.stem + ".exe")
    cmd = [NVCC, *NVCC_FLAGS, str(src), "-o", str(exe)]
    try:
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=COMPILE_TIMEOUT)
        ok = (r.returncode == 0) and exe.exists()
        log = (r.stderr or "") + (r.stdout or "")
        return ok, exe, log
    except subprocess.TimeoutExpired:
        return False, exe, f"compile timeout after {COMPILE_TIMEOUT}s"


def run_one(exe: Path, args: list[str], gpu: int) -> tuple[bool, float | None, str]:
    """Return (passed, elapsed_ms_from_stdout, log)."""
    env = os.environ.copy()
    env["CUDA_VISIBLE_DEVICES"] = str(gpu)
    cmd = [str(exe), *args]
    try:
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=RUN_TIMEOUT, env=env)
        out = (r.stdout or "") + (r.stderr or "")
        if r.returncode != 0:
            return False, None, out
        passed = bool(PASS_REGEX.search(out)) and not bool(FAIL_REGEX.search(out))
        # First ms number on a line that also mentions PASS/FAIL/time
        ms = None
        for m in MS_REGEX.finditer(out):
            ms = float(m.group(1))
            break
        return passed, ms, out
    except subprocess.TimeoutExpired:
        return False, None, f"run timeout after {RUN_TIMEOUT}s"


def eval_candidate(src: Path, args: list[str], gpu: int, ref_ms: float | None = None) -> dict:
    with tempfile.TemporaryDirectory(prefix="aevo_") as tmp:
        work = Path(tmp)
        ok, exe, clog = compile_one(src, work)
        if not ok:
            return {"compiled": False, "passed": False, "ms": None, "speedup": 0.0,
                    "compile_log": clog[-2000:]}
        passed, ms, rlog = run_one(exe, args, gpu)
        speedup = 0.0
        if passed and ms and ref_ms:
            speedup = ref_ms / ms if ms > 0 else 0.0
        return {"compiled": True, "passed": passed, "ms": ms, "speedup": speedup,
                "run_log_tail": rlog[-2000:]}


def eval_golden(xroot: Path, gpu: int) -> dict:
    results = []
    passes = 0
    speedups = []
    t0 = time.time()
    for name, relpath, args in GOLDEN_6:
        src = xroot / "kernels" / relpath
        if not src.exists():
            results.append({"name": name, "error": f"missing {src}"})
            continue
        r = eval_candidate(src, args, gpu)
        r["name"] = name
        results.append(r)
        if r["passed"]:
            passes += 1
            # No reference kernel comparison in this first cut; speedup = 1.0 if pass
            if r["ms"] and r["ms"] > 0:
                speedups.append(1.0)
    wall = time.time() - t0
    pass_rate = passes / len(GOLDEN_6)
    geomean = math.exp(sum(math.log(s) for s in speedups) / len(speedups)) if speedups else 0.0
    fitness = pass_rate * geomean if speedups else pass_rate
    return {
        "pass_rate": pass_rate,
        "geomean_speedup": geomean,
        "fitness": fitness,
        "wall_clock_s": wall,
        "results": results,
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--kernel", type=Path, help="single .cu to evaluate")
    ap.add_argument("--args", nargs="*", default=[], help="runtime args for the single kernel")
    ap.add_argument("--ref-ms", type=float, default=None, help="reference ms for speedup")
    ap.add_argument("--golden", action="store_true", help="evaluate the golden-6 set")
    ap.add_argument("--xkernel-root", type=Path, default=Path("/home/USER/xkernel"))
    ap.add_argument("--gpu", type=int, default=int(os.environ.get("AEVO_GPU", "6")))
    args = ap.parse_args()

    if args.golden:
        out = eval_golden(args.xkernel_root, args.gpu)
    elif args.kernel:
        r = eval_candidate(args.kernel, args.args, args.gpu, ref_ms=args.ref_ms)
        fitness = r["speedup"] if r["passed"] else 0.0
        out = {
            "pass_rate": 1.0 if r["passed"] else 0.0,
            "geomean_speedup": r["speedup"],
            "fitness": fitness,
            "result": r,
        }
    else:
        ap.error("need --golden or --kernel")

    # Summary JSON on the last line for AlphaEvolve to parse
    summary = {k: out[k] for k in ("pass_rate", "geomean_speedup", "fitness")}
    # Full details dumped above the summary for humans
    print(json.dumps(out, indent=2, default=str))
    print(json.dumps(summary))
    return 0 if out["pass_rate"] > 0 else 1


if __name__ == "__main__":
    sys.exit(main())
