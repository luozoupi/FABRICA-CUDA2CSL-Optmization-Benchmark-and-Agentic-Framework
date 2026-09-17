#!/usr/bin/env cs_python

# Copyright 2026 Cerebras Systems.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Drive the Laplacian2D-Halo CSL kernel and compare to a NumPy reference.

5-point 2D Laplacian with zero boundary on a 2x2 PE mesh; each PE owns an
Mt x Nt tile. The host:
  1. builds a deterministic M x N input,
  2. computes the NumPy reference for `iters` iterations of the stencil,
  3. cliff-distributes the input across the 2x2 mesh and memcpy's it to `tile`,
  4. launches `step(iters)` once,
  5. reads `new_tile` back, undoes the cliff distribution, and compares.

The "cliff distribution" mirrors Residual's row-major variant: a global M x N
matrix becomes a (height, width, Mt*Nt) tensor where each (py, px) chunk holds
that PE's row-major Mt x Nt tile.
"""

import argparse
import json
import os
import numpy as np

from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType, MemcpyOrder


def laplacian_step(A):
  """One 5-point Laplacian step with zero boundary, on a 2D numpy array."""
  padded = np.pad(A, 1, mode='constant', constant_values=0.0)
  return (0.25 * (padded[:-2, 1:-1] + padded[2:, 1:-1] +
                  padded[1:-1, :-2] + padded[1:-1, 2:])).astype(np.float32)


def main():
  parser = argparse.ArgumentParser()
  parser.add_argument("--name", help="compiled artifact directory")
  parser.add_argument("--cmaddr", help="IP:port for CS system (omit for simulator)")
  parser.add_argument("--iters", type=int, default=1, help="number of stencil iterations")
  args = parser.parse_args()

  with open(f"{args.name}/out.json", encoding="utf-8") as f:
    compile_data = json.load(f)
  Mt = int(compile_data["params"]["Mt"])
  Nt = int(compile_data["params"]["Nt"])
  width  = int(compile_data["params"]["width"])
  height = int(compile_data["params"]["height"])

  M = Mt * height
  N = Nt * width
  iters = args.iters
  print(f"Laplacian2D-Halo: M={M}, N={N}, mesh={width}x{height}, "
        f"tile={Mt}x{Nt}, iters={iters}")

  # INPUT-SPLIT (2026-06-24): input was a DETERMINISTIC np.arange (i*N+j) pattern,
  # which lets a kernel hardcode the stencil output without computing it. Draw A from
  # a seeded RNG (XKERNEL_EVAL_SEED) so the harness can score correctness on HELD-OUT
  # seeds the agent never saw; the numpy reference is recomputed from A every run.
  # Kept at the same ~O(M*N) magnitude the arange input had. See SPLIT_AND_LEAKAGE.md.
  _rng = np.random.default_rng(int(os.environ.get("XKERNEL_EVAL_SEED", "0")))
  A = (_rng.random((M, N)).astype(np.float32) * np.float32(M * N))

  # NumPy reference.
  ref = A.copy()
  for _ in range(iters):
    ref = laplacian_step(ref)

  # Cliff distribute A -> (height, width, Mt*Nt). Row-major local tile.
  A_dist = (A
            .reshape(height, Mt, width, Nt)
            .transpose(0, 2, 1, 3)             # (height, width, Mt, Nt)
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

  # f_tic is stamped on-device (device_internal_v2); no host launch.
  runner.launch("step", np.uint16(iters), nonblock=False)
  # f_toc is stamped on-device (device_internal_v2); no host launch.
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

  # Compute cycles_send from the timestamp buffer.
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
  time_send = (cycles_send / 0.85) * 1.0e-3
  print(f"cycles_send = {cycles_send} cycles")
  print(f"time_send = {time_send} us")

  # Undo the cliff distribution.
  out = (out_flat
         .reshape(height, width, Mt, Nt)
         .transpose(0, 2, 1, 3)
         .reshape(M, N))

  diff = float(np.max(np.abs(out - ref)))
  print(f"max abs diff = {diff:.3e}")
  if diff < 1e-5:
    print("SUCCESS!")
  else:
    print("FAIL")
    print(f"out:\n{out}")
    print(f"ref:\n{ref}")
    raise SystemExit(1)


if __name__ == "__main__":
  main()
