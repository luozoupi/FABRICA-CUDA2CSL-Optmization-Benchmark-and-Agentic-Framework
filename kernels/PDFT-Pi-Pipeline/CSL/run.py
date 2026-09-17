#!/usr/bin/env cs_python

# Host runner for the single-PE PDFT on-top pair-density pipeline (program-level).
# Copies mo_grid + cascm2 to the device, launches `compute` (the 3-stage program
# gridkern->buf->Pi), reads back Pi + the timer, verifies against the numpy
# quadratic form Pi[g] = k_g^T W k_g (k_g = outer(mo_g, mo_g)), and prints the
# canonical `cycles_send = N cycles` line.

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
  parser = argparse.ArgumentParser(description="PDFT Pi pipeline run parameters")
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

  ngrid = int(compile_data["params"]["ngrid"])
  ncas = int(compile_data["params"]["ncas"])
  width = int(compile_data["params"]["width"])
  height = int(compile_data["params"]["height"])
  ncas2 = ncas * ncas
  print(f"ngrid={ngrid} ncas={ncas} ncas2={ncas2} width={width} height={height}")

  start = time.time()
  runner = SdkRuntime(name, cmaddr=cmaddr)

  mo_symbol = runner.get_id("mo_grid")
  w_symbol = runner.get_id("cascm2")
  Pi_symbol = runner.get_id("Pi")
  symbol_maxmin_time = runner.get_id("maxmin_time")

  runner.load()
  runner.run()

  # INPUT-SPLIT (2026-06-24): seed via XKERNEL_EVAL_SEED so the harness can score
  # correctness on HELD-OUT seeds the agent never saw; Pi_ref is recomputed from the
  # drawn mo/W every run. See docs/SPLIT_AND_LEAKAGE.md (input-level split).
  np.random.seed(int(os.environ.get("XKERNEL_EVAL_SEED", "11")))
  mo = (np.random.rand(ngrid, ncas).astype(np.float32) - 0.5)
  W = (np.random.rand(ncas2, ncas2).astype(np.float32) - 0.5)

  # Replicate inputs to every PE (single-PE compute on each).
  mo_flat = mo.reshape(-1)
  mo_data = np.zeros(width * height * ngrid * ncas, dtype=np.float32)
  w_flat = W.reshape(-1)
  w_data = np.zeros(width * height * ncas2 * ncas2, dtype=np.float32)
  for wp in range(width):
    for hp in range(height):
      base_mo = (hp * width + wp) * ngrid * ncas
      mo_data[base_mo:base_mo + ngrid * ncas] = mo_flat
      base_w = (hp * width + wp) * ncas2 * ncas2
      w_data[base_w:base_w + ncas2 * ncas2] = w_flat

  print("Copy mo_grid to device...")
  runner.memcpy_h2d(
      mo_symbol, mo_data, 0, 0, width, height, ngrid * ncas,
      streaming=False, data_type=MemcpyDataType.MEMCPY_32BIT,
      order=MemcpyOrder.ROW_MAJOR, nonblock=False,
  )
  print("Copy cascm2 to device...")
  runner.memcpy_h2d(
      w_symbol, w_data, 0, 0, width, height, ncas2 * ncas2,
      streaming=False, data_type=MemcpyDataType.MEMCPY_32BIT,
      order=MemcpyOrder.ROW_MAJOR, nonblock=False,
  )

  print("Launch kernel...")
  runner.call("compute", [], nonblock=False)

  data = np.zeros((width * height * 3, 1), dtype=np.uint32)
  runner.memcpy_d2h(
      data, symbol_maxmin_time, 0, 0, width, height, 3,
      streaming=False, data_type=MemcpyDataType.MEMCPY_32BIT,
      order=MemcpyOrder.ROW_MAJOR, nonblock=False,
  )
  maxmin_time_hwl = data.view(np.float32).reshape((height, width, 3))

  data = np.zeros((width * height * ngrid, 1), dtype=np.uint32)
  runner.memcpy_d2h(
      data, Pi_symbol, 0, 0, width, height, ngrid,
      streaming=False, data_type=MemcpyDataType.MEMCPY_32BIT,
      order=MemcpyOrder.ROW_MAJOR, nonblock=False,
  )
  Pi_device = data.view(np.float32).reshape((height, width, ngrid))

  runner.stop()
  walltime = time.time() - start

  # numpy reference: Pi[g] = k_g^T W k_g, k_g = outer(mo_g, mo_g) flattened.
  K = np.einsum("gj,gk->gjk", mo, mo).reshape(ngrid, ncas2)   # [ngrid][ncas2]
  Pi_ref = np.einsum("ga,ab,gb->g", K, W, K).astype(np.float32)

  print(f"Real walltime: {walltime}s")
  for wp in range(width):
    for hp in range(height):
      np.testing.assert_allclose(Pi_device[hp, wp, :], Pi_ref, atol=1e-4, rtol=1e-4)

  tsc = np.zeros(6).astype(np.uint16)
  min_cycles = math.inf
  max_cycles = 0
  for wp in range(width):
    for hp in range(height):
      def hx(v):
        return int(struct.unpack("<I", struct.pack("<f", v))[0])
      t0 = hx(maxmin_time_hwl[(hp, wp, 0)])
      t1 = hx(maxmin_time_hwl[(hp, wp, 1)])
      t2 = hx(maxmin_time_hwl[(hp, wp, 2)])
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
