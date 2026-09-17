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

# Laplacian2D-Reduce host runner.
#
#   new[i,j] = 0.25 * (old[i-1,j] + old[i+1,j] + old[i,j-1] + old[i,j+1])
#   nrm      = max over all cells of |new[i,j] - old[i,j]|
#
# The device computes per-PE partial maxima, reduces them north along each
# column onto the py=0 row, and the host takes the max across the two columns.
# Timed with the on-device TSC over the step() window (same idiom as the
# sibling Laplacian2D-Halo reference).

import argparse
import json
import os
import numpy as np

from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType, MemcpyOrder


def laplacian_step(A):
  padded = np.pad(A, 1, mode='constant', constant_values=0.0)
  return (0.25 * (padded[:-2, 1:-1] + padded[2:, 1:-1] +
                  padded[1:-1, :-2] + padded[1:-1, 2:])).astype(np.float32)


def make_u48(words):
  return int(words[0]) | (int(words[1]) << 16) | (int(words[2]) << 32)


def main():
  parser = argparse.ArgumentParser()
  parser.add_argument("--name")
  parser.add_argument("--cmaddr")
  parser.add_argument("--iters", type=int, default=1)
  args = parser.parse_args()

  with open(f"{args.name}/out.json", encoding="utf-8") as f:
    compile_data = json.load(f)
  Mt = int(compile_data["params"]["Mt"])
  Nt = int(compile_data["params"]["Nt"])
  width = int(compile_data["params"]["width"])
  height = int(compile_data["params"]["height"])
  M, N = Mt * height, Nt * width
  iters = args.iters
  print(f"Laplacian2D-Reduce: M={M}, N={N}, iters={iters}")

  # INPUT-SPLIT: draw A from a seeded RNG (XKERNEL_EVAL_SEED) rather than a
  # deterministic ramp, so the harness can score correctness on held-out seeds
  # the agent never saw. The numpy reference is recomputed from A every run.
  _seed = int(os.environ.get("XKERNEL_EVAL_SEED", "0"))
  A = np.random.default_rng(_seed).uniform(-4.0, 4.0, size=(M, N)).astype(np.float32)

  # Host reference: nrm is the max abs change produced by the LAST iteration.
  prev = A.copy()
  curr = laplacian_step(prev)
  for _ in range(iters - 1):
    prev = curr
    curr = laplacian_step(prev)
  ref_nrm = float(np.max(np.abs(curr - prev)))

  A_dist = (A.reshape(height, Mt, width, Nt)
              .transpose(0, 2, 1, 3)
              .reshape(height, width, Mt * Nt))

  dtype = MemcpyDataType.MEMCPY_32BIT
  order = MemcpyOrder.ROW_MAJOR
  runner = SdkRuntime(args.name, cmaddr=args.cmaddr)
  sym_tile = runner.get_id("tile")
  sym_nrm = runner.get_id("nrm")
  sym_time_buf = runner.get_id("time_buf_u16")
  runner.load()
  runner.run()

  runner.launch("f_enable_timer", nonblock=False)

  runner.memcpy_h2d(sym_tile, A_dist.ravel(), 0, 0, width, height, Mt * Nt,
                    streaming=False, data_type=dtype, order=order, nonblock=False)

  runner.launch("f_tic", nonblock=False)
  runner.launch("step", np.uint16(iters), nonblock=False)
  runner.launch("f_toc", nonblock=False)
  runner.launch("f_memcpy_timestamps", nonblock=False)

  nrm_per_col = np.zeros(width, dtype=np.float32)
  # py=0 (north row) PEs hold the per-column maxes.
  runner.memcpy_d2h(nrm_per_col, sym_nrm, 0, 0, width, 1, 1,
                    streaming=False, data_type=dtype, order=order, nonblock=False)

  time_buf = np.zeros(width * height * 6, dtype=np.uint32)
  runner.memcpy_d2h(time_buf, sym_time_buf, 0, 0, width, height, 6,
                    streaming=False, data_type=MemcpyDataType.MEMCPY_16BIT,
                    order=MemcpyOrder.ROW_MAJOR, nonblock=False)

  runner.stop()

  time_hwl = time_buf.reshape(height, width, 6).astype(np.uint16)
  starts, ends = [], []
  for py_i in range(height):
    for px_i in range(width):
      starts.append(make_u48(time_hwl[py_i, px_i, 0:3]))
      ends.append(make_u48(time_hwl[py_i, px_i, 3:6]))
  cycles_send = max(ends) - min(starts)
  time_send = (cycles_send / 0.85) * 1.0e-3
  print(f"cycles_send = {cycles_send} cycles")
  print(f"time_send = {time_send} us")

  device_nrm = float(np.max(nrm_per_col))
  diff = abs(device_nrm - ref_nrm)
  print(f"device nrm = {device_nrm} (per-column {nrm_per_col}), ref nrm = {ref_nrm}")
  print(f"[verify] abs err = {diff:.3e}")
  rtol = 1e-5 * max(1.0, abs(ref_nrm))
  if diff <= max(1e-4, rtol):
    print("SUCCESS")
  else:
    print("FAIL")
    raise SystemExit(1)


if __name__ == "__main__":
  main()
