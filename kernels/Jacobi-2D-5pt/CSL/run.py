#!/usr/bin/env cs_python
"""Drive the manual Jacobi 2D 5-point CSL kernel; compare to a NumPy reference.

5-point 2D Jacobi PDE step with PRESERVED-BOUNDARY semantics on a 2x2 PE mesh;
each PE owns an Mt x Nt tile.

For 1 <= i <= H-2, 1 <= j <= W-2:
    B[i,j] = 0.25 * (A[i-1,j] + A[i+1,j] + A[i,j-1] + A[i,j+1])
At the global boundary (i in {0, H-1} or j in {0, W-1}):
    B[i,j] = A[i,j]   (preserved verbatim)

The host:
  1. builds a deterministic H x W input,
  2. computes the NumPy reference for `iters` iterations of the step,
  3. cliff-distributes the input across the 2x2 mesh and memcpy's it to `tile`,
  4. launches `step(iters)` once,
  5. reads `new_tile` back, undoes the cliff distribution, and compares element-
     wise to the reference.

Prints SUCCESS / FAIL plus cycles_send and max abs error.
"""

import argparse
import json
import numpy as np

from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType, MemcpyOrder


def jacobi_step_preserved_boundary(A):
  """One 5-point Jacobi step on a 2D numpy array. Boundary cells preserved."""
  B = A.copy()
  B[1:-1, 1:-1] = 0.25 * (
      A[:-2, 1:-1] +    # up
      A[2:,  1:-1] +    # down
      A[1:-1, :-2] +    # left
      A[1:-1, 2:]       # right
  )
  return B.astype(np.float32)


def main():
  parser = argparse.ArgumentParser()
  parser.add_argument("--name", help="compiled artifact directory")
  parser.add_argument("--cmaddr", help="IP:port for CS system (omit for simulator)")
  parser.add_argument("--iters", type=int, default=1, help="number of stencil iterations")
  parser.add_argument("--tolerance", type=float, default=1e-5,
                      help="max absolute error tolerance for SUCCESS")
  args = parser.parse_args()

  with open(f"{args.name}/out.json", encoding="utf-8") as f:
    compile_data = json.load(f)
  Mt = int(compile_data["params"]["Mt"])
  Nt = int(compile_data["params"]["Nt"])
  width  = int(compile_data["params"]["width"])
  height = int(compile_data["params"]["height"])

  H = Mt * height
  W = Nt * width
  iters = args.iters
  print(f"Jacobi-2D-5pt: H={H}, W={W}, mesh={width}x{height}, "
        f"tile={Mt}x{Nt}, iters={iters}, boundary=preserved")

  # Deterministic input: same generator as the CUDA reference (numpy seed=7).
  np.random.seed(7)
  A = np.random.rand(H, W).astype(np.float32)

  # NumPy reference.
  ref = A.copy()
  for _ in range(iters):
    ref = jacobi_step_preserved_boundary(ref)

  # Cliff distribute A -> (height, width, Mt*Nt) row-major.
  A_dist = (A
            .reshape(height, Mt, width, Nt)
            .transpose(0, 2, 1, 3)
            .reshape(height, width, Mt * Nt))

  memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
  memcpy_order = MemcpyOrder.ROW_MAJOR

  runner = SdkRuntime(args.name, cmaddr=args.cmaddr)
  sym_tile     = runner.get_id("tile")
  sym_new_tile = runner.get_id("new_tile")
  sym_time_buf = runner.get_id("time_buf_u16")
  runner.load()
  runner.run()

  runner.launch("f_enable_timer", nonblock=False)

  runner.memcpy_h2d(sym_tile, A_dist.ravel(), 0, 0, width, height, Mt * Nt,
                    streaming=False, data_type=memcpy_dtype,
                    order=memcpy_order, nonblock=False)

  runner.launch("f_tic", nonblock=False)
  runner.launch("step", np.uint16(iters), nonblock=False)
  runner.launch("f_toc", nonblock=False)
  runner.launch("f_memcpy_timestamps", nonblock=False)

  out_flat = np.zeros(width * height * Mt * Nt, dtype=np.float32)
  runner.memcpy_d2h(out_flat, sym_new_tile, 0, 0, width, height, Mt * Nt,
                    streaming=False, data_type=memcpy_dtype,
                    order=memcpy_order, nonblock=False)

  time_buf = np.zeros(width * height * 6, dtype=np.uint32)
  runner.memcpy_d2h(time_buf, sym_time_buf, 0, 0, width, height, 6,
                    streaming=False, data_type=MemcpyDataType.MEMCPY_16BIT,
                    order=MemcpyOrder.ROW_MAJOR, nonblock=False)

  runner.stop()

  # cycles_send from the timestamp buffer.
  time_hwl = time_buf.reshape(height, width, 6).astype(np.uint16)

  def make_u48(words):
    return int(words[0]) | (int(words[1]) << 16) | (int(words[2]) << 32)

  starts = []
  ends = []
  for py_i in range(height):
    for px_i in range(width):
      starts.append(make_u48(time_hwl[py_i, px_i, 0:3]))
      ends.append(make_u48(time_hwl[py_i, px_i, 3:6]))
  cycles_send = max(ends) - min(starts)
  time_send_us = (cycles_send / 0.85) * 1.0e-3
  print(f"cycles_send = {cycles_send} cycles")
  print(f"time_send = {time_send_us:.4f} us")

  # Undo the cliff distribution.
  out = (out_flat
         .reshape(height, width, Mt, Nt)
         .transpose(0, 2, 1, 3)
         .reshape(H, W))

  max_abs_err = float(np.max(np.abs(out - ref)))
  # Anti-gaming (2026-06-24): tolerance was a free CLI arg that the harness/agent
  # could relax (e.g. --tolerance 1.0) to accept any error. Hard-clamp it to the
  # strict floor so SUCCESS can never be bought by loosening the gate.
  _STRICT_TOL = 1e-5
  eff_tolerance = min(args.tolerance, _STRICT_TOL)
  print(f"input dtype       = {A.dtype}, shape = {A.shape}")
  print(f"tolerance         = {eff_tolerance} (clamped to <= {_STRICT_TOL})")
  print(f"max_abs_error     = {max_abs_err:.3e}")
  print(f"boundary policy   = preserved (Dirichlet)")
  if max_abs_err < eff_tolerance:
    print("SUCCESS!")
  else:
    print("FAIL")
    print(f"out:\n{out}")
    print(f"ref:\n{ref}")
    raise SystemExit(1)


if __name__ == "__main__":
  main()
