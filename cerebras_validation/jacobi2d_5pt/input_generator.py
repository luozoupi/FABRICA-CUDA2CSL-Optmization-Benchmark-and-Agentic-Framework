"""Deterministic input generator for the jacobi2d_5pt validation bundle.

Standalone so the same input can be reproduced by anyone (or by an external
hardware-run harness) without invoking cs_python.

Usage:
    from input_generator import make_input
    A = make_input(H=8, W=8, seed=7)

Or as a CLI:
    python3 input_generator.py 8 8 input.npy
"""

import sys
import numpy as np


def make_input(H: int = 8, W: int = 8, seed: int = 7) -> np.ndarray:
    """Build a deterministic H x W float32 input matrix.

    Uses np.random.seed(seed) + uniform[0, 1) — matches the seed convention
    used across this repo's other halo-exchange benchmarks (Laplacian2D-Halo,
    GEMV, etc.) and the CUDA reference at kernels/Jacobi-2D-5pt/CUDA/kernel.cu.
    """
    rng = np.random.RandomState(seed)
    return rng.rand(H, W).astype(np.float32)


if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("usage: input_generator.py H W output.npy", file=sys.stderr)
        raise SystemExit(2)
    h, w, path = int(sys.argv[1]), int(sys.argv[2]), sys.argv[3]
    arr = make_input(h, w)
    np.save(path, arr)
    print(f"wrote {arr.shape} {arr.dtype} input to {path}")
