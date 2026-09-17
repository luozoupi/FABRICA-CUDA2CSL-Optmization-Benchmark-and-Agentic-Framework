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

# LorenzoPredictor-Tile host runner.
#
#   residual[i,j] = A[i,j] - (A[i-1,j] + A[i,j-1] - A[i-1,j-1])
#
# NOTE on the input: a ramp such as np.arange makes the Lorenzo residual
# identically zero on the whole interior, so an all-zeros kernel would pass.
# We use a seeded pseudo-random field instead so the interior actually
# discriminates, and only the first row/column carry the boundary terms.

import argparse
import json
import os
import numpy as np

from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType, MemcpyOrder


def lorenzo_reference(A):
  M, N = A.shape
  padded = np.zeros((M + 1, N + 1), dtype=np.float64)
  padded[1:, 1:] = A
  return (A - (padded[:-1, 1:] + padded[1:, :-1] - padded[:-1, :-1])).astype(np.float32)


def make_u48(words):
  return int(words[0]) | (int(words[1]) << 16) | (int(words[2]) << 32)


def main():
  parser = argparse.ArgumentParser()
  parser.add_argument("--name")
  parser.add_argument("--cmaddr")
  # INPUT-SPLIT: XKERNEL_EVAL_SEED lets the harness score correctness on
  # held-out seeds the agent never saw; --seed is the explicit override.
  parser.add_argument("--seed", type=int,
                      default=int(os.environ.get("XKERNEL_EVAL_SEED", "0")))
  args = parser.parse_args()

  with open(f"{args.name}/out.json", encoding="utf-8") as f:
    cd = json.load(f)
  Mt = int(cd["params"]["Mt"])
  Nt = int(cd["params"]["Nt"])
  width  = int(cd["params"]["width"])
  height = int(cd["params"]["height"])
  M, N = Mt * height, Nt * width
  print(f"LorenzoPredictor-Tile: M={M}, N={N}, seed={args.seed}")

  rng = np.random.default_rng(args.seed)
  A = rng.uniform(-4.0, 4.0, size=(M, N)).astype(np.float32)

  ref = lorenzo_reference(A)

  A_dist = (A.reshape(height, Mt, width, Nt)
              .transpose(0, 2, 1, 3)
              .reshape(height, width, Mt * Nt))

  dtype = MemcpyDataType.MEMCPY_32BIT
  order = MemcpyOrder.ROW_MAJOR
  runner = SdkRuntime(args.name, cmaddr=args.cmaddr)
  sym_tile = runner.get_id("tile")
  sym_residual = runner.get_id("residual")
  sym_time_buf = runner.get_id("time_buf_u16")
  runner.load()
  runner.run()

  runner.launch("f_enable_timer", nonblock=False)

  runner.memcpy_h2d(sym_tile, A_dist.ravel(), 0, 0, width, height, Mt * Nt,
                    streaming=False, data_type=dtype, order=order, nonblock=False)

  runner.launch("f_tic", nonblock=False)
  runner.launch("step", nonblock=False)
  runner.launch("f_toc", nonblock=False)
  runner.launch("f_memcpy_timestamps", nonblock=False)

  out_flat = np.zeros(width * height * Mt * Nt, dtype=np.float32)
  runner.memcpy_d2h(out_flat, sym_residual, 0, 0, width, height, Mt * Nt,
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

  out = (out_flat.reshape(height, width, Mt, Nt)
                 .transpose(0, 2, 1, 3)
                 .reshape(M, N))

  diff = float(np.max(np.abs(out - ref)))
  print(f"[verify] max abs err = {diff:.3e}")
  if diff < 1e-4:
    print("SUCCESS")
  else:
    print("FAIL")
    print(f"device:\n{out}")
    print(f"reference:\n{ref}")
    raise SystemExit(1)


if __name__ == "__main__":
  main()
