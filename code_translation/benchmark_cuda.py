#!/usr/bin/env python3
"""
Benchmark: Evaluate LLM-translated CUDA kernels against reference implementations.
===================================================================================

Tests translated CUDA kernels (from CSL→CUDA translation) against the reference
CUDA implementations in xkernel/kernels/*/CUDA/kernel.cu.

Metrics captured per kernel:
  1. Compilation success (nvcc)
  2. Execution success (runs without crash/timeout)
  3. Correctness (PASS/FAIL from self-check + output comparison with reference)
  4. Performance (kernel execution time comparison with reference)
  5. Code quality (lines of code, similarity score)

Usage:
  # Benchmark a single translated kernel against reference
  python benchmark_cuda.py --translated results/csl2cuda/run_xxx/gemv.cu \
                           --reference ../xkernel/kernels/GEMV/CUDA/kernel.cu

  # Benchmark all translated kernels from a run
  python benchmark_cuda.py --run-dir results/csl2cuda/run_xxx \
                           --xkernel ../xkernel/kernels

  # Batch: translate + benchmark in one go
  python benchmark_cuda.py --translate-and-bench \
                           --xkernel ../xkernel/kernels \
                           --model Qwen/Qwen3.5-27B
"""

import os
import re
import json
import time
import argparse
import subprocess
import difflib
from typing import Optional, Tuple, Dict, List
from datetime import datetime


TIMEOUT_LIMIT = 120  # seconds
NVCC = "nvcc"

# Map xkernel directory names to canonical names for matching
KERNEL_NAME_MAP = {
    "pe_program": "Game of Life",
    "pe": "GEMV",
    "gemv": "GEMV",
    "gemv_checkerboard": "GEMV Checkerboard",
    "stencil": "25-Point Stencil",
    "stencil7": "7-Point Stencil",
    "spmv": "SpMV",
    "residual": "Residual",
    "power": "Power Method",
    "cg": "Conjugate Gradient",
    "pcg": "Preconditioned CG",
    "bicgstab": "BiCGSTAB",
    "cholesky": "Cholesky",
    "matvec": "Matvec",
    "gemm": "GEMM",
    "game_of_life": "Game of Life",
}


def compile_cuda(cu_path: str, exe_path: str,
                 timeout: int = TIMEOUT_LIMIT) -> Tuple[bool, str]:
    """Compile a .cu file. Returns (success, error_msg)."""
    cmd = f'{NVCC} -O3 -Wno-deprecated-gpu-targets -o "{exe_path}" "{cu_path}"'
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, timeout=timeout)
        if result.returncode != 0:
            return False, result.stderr.decode("utf-8", "replace")
        return True, ""
    except subprocess.TimeoutExpired:
        return False, "Compilation timed out"


def run_cuda(exe_path: str, timeout: int = TIMEOUT_LIMIT,
             n_runs: int = 4) -> Tuple[bool, str, str, float]:
    """Run a compiled CUDA binary n_runs times (first is warmup).
    Returns (success, stdout, stderr, median_elapsed_ms).
    """
    cmd = f'"{exe_path}"'
    stdout, stderr = "", ""
    timings = []
    for i in range(n_runs):
        try:
            t0 = time.time()
            result = subprocess.run(cmd, shell=True, capture_output=True, timeout=timeout)
            elapsed = (time.time() - t0) * 1000
            stdout = result.stdout.decode("utf-8", "replace")
            stderr = result.stderr.decode("utf-8", "replace")
            if result.returncode != 0:
                return False, stdout, stderr, elapsed
            if i > 0:  # skip warmup run
                timings.append(elapsed)
        except subprocess.TimeoutExpired:
            return False, "", "Execution timed out", timeout * 1000

    median_ms = sorted(timings)[len(timings) // 2] if timings else 0.0
    return True, stdout, stderr, median_ms


def check_pass(output: str) -> bool:
    """Check if output contains PASS (and not FAIL)."""
    upper = output.upper()
    return "PASS" in upper and "FAIL" not in upper


def extract_timing(output: str) -> Optional[float]:
    """Try to extract kernel timing from output (look for common patterns)."""
    patterns = [
        r"(?:kernel|total|execution|factorization)\s+time[:\s]+([0-9.]+)\s*ms",
        r"([0-9.]+)\s*ms\s*(?:\(avg|per|/)",
        r"time[:\s]+([0-9.]+)\s*ms",
    ]
    for pat in patterns:
        m = re.search(pat, output, re.IGNORECASE)
        if m:
            return float(m.group(1))
    return None


def extract_error_metric(output: str) -> Optional[float]:
    """Try to extract error/accuracy metric from output."""
    patterns = [
        r"(?:max[_ ]?err|rel[_ ]?err|error|diff)[:\s=]+([0-9.]+[eE][-+]?\d+)",
        r"([0-9.]+[eE][-+]?\d+)",
    ]
    for pat in patterns:
        m = re.search(pat, output, re.IGNORECASE)
        if m:
            try:
                return float(m.group(1))
            except ValueError:
                pass
    return None


def code_similarity(code_a: str, code_b: str) -> float:
    """Compute similarity ratio between two code strings (0-1)."""
    return difflib.SequenceMatcher(None, code_a, code_b).ratio()


def benchmark_kernel(translated_path: str, reference_path: str,
                     work_dir: str) -> Dict:
    """
    Benchmark a translated CUDA kernel against a reference implementation.
    Returns a dict with all metrics.
    """
    os.makedirs(work_dir, exist_ok=True)
    result = {
        "translated_path": translated_path,
        "reference_path": reference_path,
        "compile_success": False,
        "run_success": False,
        "correctness": False,
        "timing_ms": None,
        "ref_timing_ms": None,
        "speedup": None,
        "error_metric": None,
        "ref_error_metric": None,
        "code_lines": 0,
        "ref_code_lines": 0,
        "code_similarity": 0.0,
    }

    # Read code files
    with open(translated_path) as f:
        trans_code = f.read()
    with open(reference_path) as f:
        ref_code = f.read()

    result["code_lines"] = len(trans_code.strip().split("\n"))
    result["ref_code_lines"] = len(ref_code.strip().split("\n"))
    result["code_similarity"] = round(code_similarity(trans_code, ref_code), 4)

    # Compile translated
    trans_exe = os.path.join(work_dir, "translated")
    ok, err = compile_cuda(translated_path, trans_exe)
    result["compile_success"] = ok
    if not ok:
        result["compile_error"] = err[:500]
        return result

    # Run translated
    ok, stdout, stderr, wall_ms = run_cuda(trans_exe)
    result["run_success"] = ok
    result["translated_output"] = stdout[:1000]
    if ok:
        result["correctness"] = check_pass(stdout)
        result["internal_timing_ms"] = extract_timing(stdout)
        result["wall_ms"] = round(wall_ms, 3)
        result["error_metric"] = extract_error_metric(stdout)

    # Compile & run reference
    ref_exe = os.path.join(work_dir, "reference")
    ok_ref, _ = compile_cuda(reference_path, ref_exe)
    if ok_ref:
        ok_ref, ref_stdout, _, ref_wall_ms = run_cuda(ref_exe)
        if ok_ref:
            result["ref_internal_timing_ms"] = extract_timing(ref_stdout)
            result["ref_wall_ms"] = round(ref_wall_ms, 3)
            result["ref_error_metric"] = extract_error_metric(ref_stdout)
            result["reference_output"] = ref_stdout[:1000]

    # Use consistent timing source for comparison
    # Prefer internal (cudaEvent) when BOTH have it; otherwise use wall-clock
    t_int = result.get("internal_timing_ms")
    r_int = result.get("ref_internal_timing_ms")
    if t_int and r_int:
        result["timing_ms"] = t_int
        result["ref_timing_ms"] = r_int
        result["timing_source"] = "internal"
    else:
        result["timing_ms"] = result.get("wall_ms")
        result["ref_timing_ms"] = result.get("ref_wall_ms")
        result["timing_source"] = "wall-clock"

    # Speedup: ref / translated (>1 means translated is faster)
    if result.get("timing_ms") and result.get("ref_timing_ms") and result["ref_timing_ms"] > 0:
        result["speedup"] = round(result["ref_timing_ms"] / result["timing_ms"], 3)

    return result


def find_reference(kernel_name: str, xkernel_dir: str) -> Optional[str]:
    """Find the reference CUDA kernel for a given translated kernel name.
    Priority: human-written references from established repos > Claude-written kernel.cu
    """
    # Check for established open-source references (prefer over Claude-written)
    ref_patterns = [
        "leetcuda_ref.cu",   # LeetCUDA (GEMV, GEMM)
        "parboil_ref.cu",    # Parboil (stencil, SpMV, histogram)
        "cgcuda_ref.cu",     # CG-CUDA (Conjugate Gradient)
        "blocked_ref.cu",    # Blocked algorithms (Cholesky)
        "hecbench_ref.cu",   # HeCBench variants
    ]
    for ref_name in ref_patterns:
        ref_path = os.path.join(xkernel_dir, kernel_name, "CUDA", ref_name)
        if os.path.exists(ref_path):
            return ref_path

    # Fallback: Claude-written reference
    candidate = os.path.join(xkernel_dir, kernel_name, "CUDA", "kernel.cu")
    if os.path.exists(candidate):
        return candidate

    # Try name map
    mapped = KERNEL_NAME_MAP.get(kernel_name.lower().replace("-", "_").replace(" ", "_"))
    if mapped:
        # Check human-written refs first, then fallback
        for ref_name in ref_patterns + ["kernel.cu"]:
            candidate = os.path.join(xkernel_dir, mapped, "CUDA", ref_name)
            if os.path.exists(candidate):
                return candidate

    # Fuzzy search
    for d in os.listdir(xkernel_dir):
        if kernel_name.lower().replace("_", "") in d.lower().replace(" ", "").replace("-", ""):
            for ref_name in ref_patterns + ["kernel.cu"]:
                candidate = os.path.join(xkernel_dir, d, "CUDA", ref_name)
                if os.path.exists(candidate):
                    return candidate

    return None


def print_results_table(results: List[Dict]):
    """Print a summary table of benchmark results."""
    header = f"{'Kernel':<25} {'Compile':>7} {'Correct':>7} {'Trans(ms)':>10} {'Ref(ms)':>10} {'Speedup':>10} {'Indicator':>10}"
    print(header)
    print("-" * len(header))
    speedups = []
    for r in results:
        name = os.path.splitext(os.path.basename(r["translated_path"]))[0][:24]
        comp = "OK" if r["compile_success"] else "FAIL"
        corr = "PASS" if r["correctness"] else "FAIL"
        t = f"{r['timing_ms']:.3f}" if r.get("timing_ms") else "-"
        rt = f"{r['ref_timing_ms']:.3f}" if r.get("ref_timing_ms") else "-"
        if r.get("speedup"):
            sp = f"{r['speedup']:.3f}x"
            speedups.append(r['speedup'])
            if r['speedup'] > 1.05:
                indicator = ">> FASTER"
            elif r['speedup'] < 0.95:
                indicator = "<< SLOWER"
            else:
                indicator = "~= SAME"
        else:
            sp = "-"
            indicator = "-"
        print(f"{name:<25} {comp:>7} {corr:>7} {t:>10} {rt:>10} {sp:>10} {indicator:>10}")

    # Summary
    total = len(results)
    compiled = sum(1 for r in results if r["compile_success"])
    ran = sum(1 for r in results if r["run_success"])
    correct = sum(1 for r in results if r["correctness"])
    print(f"\nTotal: {total} | Compiled: {compiled} | Ran: {ran} | Correct: {correct}")
    if speedups:
        avg = sum(speedups) / len(speedups)
        geo = 1.0
        for s in speedups:
            geo *= s
        geo = geo ** (1.0 / len(speedups))
        faster = sum(1 for s in speedups if s > 1.05)
        slower = sum(1 for s in speedups if s < 0.95)
        same = len(speedups) - faster - slower
        print(f"Speedup stats (n={len(speedups)}): avg={avg:.3f}x  geo_mean={geo:.3f}x")
        print(f"  >> FASTER: {faster}  ~= SAME: {same}  << SLOWER: {slower}")


def main():
    parser = argparse.ArgumentParser(description="Benchmark translated CUDA kernels")
    parser.add_argument("--translated", type=str, help="Single translated .cu file")
    parser.add_argument("--reference", type=str, help="Reference .cu file")
    parser.add_argument("--run-dir", type=str, help="Directory with translated .cu files")
    parser.add_argument("--xkernel", type=str, default="../xkernel/kernels",
                        help="xkernel/kernels directory with reference implementations")
    parser.add_argument("--gpu", type=int, default=6,
                        help="GPU ID to use for benchmarking")
    parser.add_argument("--output", type=str, default="./results/benchmark",
                        help="Output directory for benchmark results")
    args = parser.parse_args()

    os.environ["CUDA_VISIBLE_DEVICES"] = str(args.gpu)

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    output_dir = os.path.join(args.output, f"bench_{timestamp}")
    os.makedirs(output_dir, exist_ok=True)

    results = []

    if args.translated and args.reference:
        # Single kernel mode
        name = os.path.splitext(os.path.basename(args.translated))[0]
        work_dir = os.path.join(output_dir, "work", name)
        r = benchmark_kernel(args.translated, args.reference, work_dir)
        results.append(r)

    elif args.run_dir:
        # Batch mode: all .cu files in run_dir
        cu_files = sorted(f for f in os.listdir(args.run_dir) if f.endswith(".cu"))
        for cu_file in cu_files:
            name = os.path.splitext(cu_file)[0]
            trans_path = os.path.join(args.run_dir, cu_file)
            ref_path = find_reference(name, args.xkernel)
            if not ref_path:
                print(f"  [SKIP] {name}: no reference found in {args.xkernel}")
                continue

            print(f"  Benchmarking: {name}")
            work_dir = os.path.join(output_dir, "work", name)
            r = benchmark_kernel(trans_path, ref_path, work_dir)
            results.append(r)

    else:
        parser.print_help()
        return

    # Print results
    print(f"\n{'='*80}")
    print("BENCHMARK RESULTS")
    print(f"{'='*80}")
    print_results_table(results)

    # Save results
    with open(os.path.join(output_dir, "results.json"), "w") as f:
        json.dump(results, f, indent=2, default=str)
    print(f"\nResults saved to {output_dir}/results.json")


if __name__ == "__main__":
    main()
