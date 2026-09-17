#!/usr/bin/env cs_python

# Copyright 2025 Cerebras Systems.
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

""" Compute |b-A*x| using a 2-by-2 PE rectangle """

import argparse
import json
import os
import numpy as np

from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType # pylint: disable=no-name-in-module
from cerebras.sdk.runtime.sdkruntimepybind import MemcpyOrder # pylint: disable=no-name-in-module

def main():
  """Main method to run the example code."""

  parser = argparse.ArgumentParser()
  parser.add_argument("--name", help="the test name")
  parser.add_argument("--cmaddr", help="IP:port for CS system")
  args = parser.parse_args()

  with open(f"{args.name}/out.json", encoding='utf-8') as json_file:
    compile_data = json.load(json_file)

  LOCAL_OUT_SZ = int(compile_data['params']['LOCAL_OUT_SZ'])
  LOCAL_IN_SZ = int(compile_data['params']['LOCAL_IN_SZ'])

  width = 2
  height = 2

  M = LOCAL_OUT_SZ * height
  N = LOCAL_IN_SZ * width

  print(f"M = {M}, N = {N}, width = {width}, height = {height}")

  # INPUT-SPLIT (2026-06-24): inputs were a DETERMINISTIC np.arange pattern, which lets
  # a kernel hardcode the |b-A*x| answer without computing it. Draw A/x/b from a seeded
  # RNG (XKERNEL_EVAL_SEED) so the harness can score correctness on HELD-OUT seeds the
  # agent never saw; the reference nrm_r is recomputed from the drawn inputs every run.
  # Held-out seeds live only in spec.yaml's `eval:` block. See docs/SPLIT_AND_LEAKAGE.md.
  # The 1e-5 check below is a RELATIVE tolerance (scale-invariant); we keep inputs at
  # modest magnitudes to avoid fp32 dynamic-range loss while exercising real compute.
  _SEED = int(os.environ.get("XKERNEL_EVAL_SEED", "2"))
  _rng = np.random.default_rng(_SEED)
  A = (_rng.random((M, N)).astype(np.float32) * np.float32(10.0))
  x = (_rng.random((N, 1)).astype(np.float32) * np.float32(10.0) + np.float32(1.0))
  b = (_rng.random((M, 1)).astype(np.float32) * np.float32(10.0) + np.float32(1.0))

  Ax = np.matmul(A, x)
  r = b - Ax
  nrm_r = np.linalg.norm(r, np.inf)

  print(f"nrm_r = |b - A*x| = {nrm_r}")

  memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
  memcpy_order = MemcpyOrder.ROW_MAJOR
  runner = SdkRuntime(args.name, cmaddr=args.cmaddr)

  sym_A = runner.get_id("A")
  sym_x = runner.get_id("x")
  sym_y = runner.get_id("y")
  sym_nrm = runner.get_id("nrm")
  sym_time = runner.get_id("time_buf_u16")

  runner.load()
  runner.run()

  A1 = A.reshape(height, LOCAL_OUT_SZ, width, LOCAL_IN_SZ)
  A2 = A1.transpose(0, 2, 3, 1)
  A3 = A2.reshape(height, width, LOCAL_OUT_SZ*LOCAL_IN_SZ)
  runner.memcpy_h2d(sym_A, A3.ravel(), 0, 0, width, height, LOCAL_OUT_SZ*LOCAL_IN_SZ,
                    streaming=False, data_type=memcpy_dtype,
                    order=memcpy_order, nonblock=False)

  runner.memcpy_h2d(sym_x, x.ravel(), 0, 0, width, 1, LOCAL_IN_SZ,
                    streaming=False, data_type=memcpy_dtype,
                    order=memcpy_order, nonblock=False)

  runner.memcpy_h2d(sym_y, b.ravel(), 0, 0, 1, height, LOCAL_OUT_SZ,
                    streaming=False, data_type=memcpy_dtype,
                    order=memcpy_order, nonblock=False)

  # Enable timer, tic, run workload, toc
  runner.launch("f_enable_timer", nonblock=False)
  runner.launch("f_tic", nonblock=False)
  runner.launch("bcast_x", nonblock=False)
  runner.launch("f_toc", nonblock=False)
  runner.launch("f_memcpy_timestamps", nonblock=False)

  # Read timestamps from every PE in the rectangle
  time_memcpy_hwl = np.zeros((height, width, 6), dtype=np.uint32)
  runner.memcpy_d2h(time_memcpy_hwl, sym_time, 0, 0, width, height, 6,
                    streaming=False, data_type=MemcpyDataType.MEMCPY_16BIT,
                    nonblock=False, order=MemcpyOrder.ROW_MAJOR)

  # receive |b-A*x| from P1.0
  nrm_r_cs = np.zeros(1, np.float32)
  runner.memcpy_d2h(nrm_r_cs, sym_nrm, 1, 0, 1, 1, 1,
                    streaming=False, data_type=memcpy_dtype,
                    order=memcpy_order, nonblock=False)

  runner.stop()

  print(f"`nrm_r`     from CPU:\n{nrm_r}")
  print(f"`nrm_r_cs`  from CS:\n{nrm_r_cs}")

  dr = abs(nrm_r - nrm_r_cs[0])
  print(f"|nrm_r - nrm_r_cs| = {dr}")

  assert np.allclose(nrm_r, nrm_r_cs[0], 1.e-5)
  print("\nSUCCESS!")

  # Decode timestamps
  time_hwl = time_memcpy_hwl.reshape(height, width, 6).astype(np.uint16)

  def to_cycles(t):
    return int(t[0]) | (int(t[1]) << 16) | (int(t[2]) << 32)

  starts = np.zeros((height, width), dtype=np.uint64)
  ends = np.zeros((height, width), dtype=np.uint64)
  for hi in range(height):
    for wi in range(width):
      starts[hi, wi] = to_cycles(time_hwl[hi, wi, 0:3])
      ends[hi, wi] = to_cycles(time_hwl[hi, wi, 3:6])

  min_start = int(starts.min())
  max_end = int(ends.max())
  cycles_send = max_end - min_start
  time_send = (cycles_send / 0.85) * 1.0e-3
  print(f"cycles_send = {cycles_send} cycles")
  print(f"time_send = {time_send} us")

if __name__ == "__main__":
  main()
