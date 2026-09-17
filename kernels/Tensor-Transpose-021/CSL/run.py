#!/usr/bin/env cs_python

# Host runner for the single-PE 3D tensor transpose (021). Copies a random
# tensor A to the device, launches `compute` (the permuted copy), reads back B
# and the timer, verifies against numpy A.transpose(0,2,1), and prints the
# canonical `cycles_send = N cycles` line consumed by the benchmark harness.

# pylint: disable=line-too-long,too-many-function-args

import argparse
import json
import math
import os
import struct
import time

import numpy as np

from cerebras.sdk.runtime.sdkruntimepybind import (  # pylint: disable=no-name-in-module
    MemcpyDataType, MemcpyOrder, SdkRuntime,
)


def parse_args():
  parser = argparse.ArgumentParser(description="tensor transpose 021 run parameters")
  parser.add_argument("--name", required=False, default="out", help="prefix of ELF files")
  parser.add_argument("--cmaddr", required=False, default="", help="IP:port for CS system")
  args = parser.parse_args()
  return args


def make_u48(words):
  return words[0] + (words[1] << 16) + (words[2] << 32)


def sub_ts(words):
  return make_u48(words[3:]) - make_u48(words[0:3])


def main():
  args = parse_args()
  name = args.name
  cmaddr = args.cmaddr

  with open(f"{name}/out.json", encoding="utf-8") as json_file:
    compile_data = json.load(json_file)

  ax1 = int(compile_data["params"]["ax1"])
  ax2 = int(compile_data["params"]["ax2"])
  ax3 = int(compile_data["params"]["ax3"])
  width = int(compile_data["params"]["width"])
  height = int(compile_data["params"]["height"])
  N = ax1 * ax2 * ax3
  print(f"ax1={ax1} ax2={ax2} ax3={ax3} N={N} width={width} height={height}")

  start = time.time()
  runner = SdkRuntime(name, cmaddr=cmaddr)

  A_symbol = runner.get_id("A")
  B_symbol = runner.get_id("B")
  symbol_maxmin_time = runner.get_id("maxmin_time")

  runner.load()
  runner.run()

  # Random input tensor, replicated to every PE (single-PE compute on each).
  # INPUT-SPLIT (2026-06-24): seed via XKERNEL_EVAL_SEED so the harness can score
  # correctness on HELD-OUT seeds the agent never saw; the expected transpose is
  # recomputed from the drawn tensor. See docs/SPLIT_AND_LEAKAGE.md (input-level split).
  np.random.seed(int(os.environ.get("XKERNEL_EVAL_SEED", "7")))
  A_mat = (np.random.rand(ax1, ax2, ax3).astype(np.float32) - 0.5)
  A_flat = A_mat.reshape(-1)
  A_data = np.zeros(width * height * N, dtype=np.float32)
  for w in range(width):
    for h in range(height):
      A_data[(h * width + w) * N:(h * width + w) * N + N] = A_flat

  print("Copy A tensor to device...")
  runner.memcpy_h2d(
      A_symbol, A_data, 0, 0, width, height, N,
      streaming=False, data_type=MemcpyDataType.MEMCPY_32BIT,
      order=MemcpyOrder.ROW_MAJOR, nonblock=False,
  )

  print("Launch kernel...")
  runner.call("compute", [], nonblock=False)

  # Read back timestamps.
  data = np.zeros((width * height * 3, 1), dtype=np.uint32)
  runner.memcpy_d2h(
      data, symbol_maxmin_time, 0, 0, width, height, 3,
      streaming=False, data_type=MemcpyDataType.MEMCPY_32BIT,
      order=MemcpyOrder.ROW_MAJOR, nonblock=False,
  )
  maxmin_time_hwl = data.view(np.float32).reshape((height, width, 3))

  # Read back output tensor B.
  data = np.zeros((width * height * N, 1), dtype=np.uint32)
  runner.memcpy_d2h(
      data, B_symbol, 0, 0, width, height, N,
      streaming=False, data_type=MemcpyDataType.MEMCPY_32BIT,
      order=MemcpyOrder.ROW_MAJOR, nonblock=False,
  )
  B_device = data.view(np.float32).reshape((height, width, N))

  runner.stop()
  walltime = time.time() - start

  # Verify against numpy reference on every PE.
  expected = A_mat.transpose(0, 2, 1).reshape(-1)
  for w in range(width):
    for h in range(height):
      np.testing.assert_array_equal(B_device[h, w, :], expected)
  print(f"Real walltime: {walltime}s")

  # Worst-PE cycle count = cycles_send.
  tsc = np.zeros(6).astype(np.uint16)
  min_cycles = math.inf
  max_cycles = 0
  for w in range(width):
    for h in range(height):
      def hx(v):
        return int(struct.unpack("<I", struct.pack("<f", v))[0])
      t0 = hx(maxmin_time_hwl[(h, w, 0)])
      t1 = hx(maxmin_time_hwl[(h, w, 1)])
      t2 = hx(maxmin_time_hwl[(h, w, 2)])
      tsc[0] = t0 & 0x0000FFFF
      tsc[1] = (t0 >> 16) & 0x0000FFFF
      tsc[2] = t1 & 0x0000FFFF
      tsc[3] = (t1 >> 16) & 0x0000FFFF
      tsc[4] = t2 & 0x0000FFFF
      tsc[5] = (t2 >> 16) & 0x0000FFFF
      c = sub_ts(tsc)
      min_cycles = min(min_cycles, c)
      max_cycles = max(max_cycles, c)

  print(f"Min cycles: {min_cycles}")
  print(f"Max cycles: {max_cycles}")
  print(f"cycles_send = {int(max_cycles)} cycles")
  print("SUCCESS!")


if __name__ == "__main__":
  main()
