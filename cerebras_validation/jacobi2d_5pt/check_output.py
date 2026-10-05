"""NumPy reference + correctness checker for jacobi2d_5pt.

Standalone so the same correctness check can be applied to any output array
(simulator, hardware-run, or alternative CSL implementation) without requiring
the live SdkRuntime in scope.

Usage:
    from check_output import jacobi_step_preserved_boundary, check_correctness
    ref = jacobi_step_preserved_boundary(A)
    ok, max_err = check_correctness(out, ref, tolerance=1e-5)

Or as a CLI for post-hoc verification:
    python3 check_output.py input.npy out.npy --iters 1
"""

import argparse
from typing import Tuple
import numpy as np


def jacobi_step_preserved_boundary(A: np.ndarray) -> np.ndarray:
    """One 5-point Jacobi step with PRESERVED-BOUNDARY semantics.

    For 1 <= i <= H-2 and 1 <= j <= W-2:
        B[i,j] = 0.25 * (A[i-1,j] + A[i+1,j] + A[i,j-1] + A[i,j+1])
    On the global boundary (i in {0, H-1} or j in {0, W-1}):
        B[i,j] = A[i,j]

    Returns a fresh array of the same shape/dtype as A.
    """
    if A.ndim != 2:
        raise ValueError(f"expected 2D array, got shape {A.shape}")
    B = A.copy()
    B[1:-1, 1:-1] = 0.25 * (
        A[:-2, 1:-1] +    # up
        A[2:,  1:-1] +    # down
        A[1:-1, :-2] +    # left
        A[1:-1, 2:]       # right
    )
    return B.astype(A.dtype)


def jacobi_n_steps(A: np.ndarray, iters: int) -> np.ndarray:
    """N iterations of the boundary-preserved Jacobi step."""
    out = A
    for _ in range(iters):
        out = jacobi_step_preserved_boundary(out)
    return out


def check_correctness(out: np.ndarray, ref: np.ndarray,
                      tolerance: float = 1e-5) -> Tuple[bool, float]:
    """Return (passed, max_abs_error).

    passed = True iff max abs error < tolerance. Shape mismatches are a
    structural error and raise ValueError rather than silently failing.
    """
    if out.shape != ref.shape:
        raise ValueError(
            f"shape mismatch: out={out.shape}, ref={ref.shape}")
    max_err = float(np.max(np.abs(out.astype(np.float64) - ref.astype(np.float64))))
    return max_err < tolerance, max_err


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("input_npy", help="path to .npy with the initial H x W matrix")
    p.add_argument("output_npy", help="path to .npy with the simulator/hardware output")
    p.add_argument("--iters", type=int, default=1,
                   help="number of Jacobi iterations the simulator was asked to run")
    p.add_argument("--tolerance", type=float, default=1e-5,
                   help="max absolute error tolerance for PASS")
    args = p.parse_args()
    A = np.load(args.input_npy)
    out = np.load(args.output_npy)
    ref = jacobi_n_steps(A, args.iters)
    ok, err = check_correctness(out, ref, args.tolerance)
    print(f"input shape       = {A.shape}, dtype = {A.dtype}")
    print(f"iters             = {args.iters}")
    print(f"tolerance         = {args.tolerance}")
    print(f"max_abs_error     = {err:.3e}")
    print(f"boundary policy   = preserved")
    print("NUMPY_CORRECTNESS_PASS" if ok else "NUMPY_CORRECTNESS_FAIL")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
