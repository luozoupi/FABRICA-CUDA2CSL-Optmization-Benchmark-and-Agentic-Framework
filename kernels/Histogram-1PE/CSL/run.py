#!/usr/bin/env cs_python
# Histogram-1PE (hand-written-compute variant) host runner.
#
# Single PE bins a random input array into a local histogram; verified against the
# numpy reference (the real invariant — no tally-library answer key). Prints
# cycles_send over the on-device timed window. Input is seeded from XKERNEL_EVAL_SEED
# so the harness can score correctness on HELD-OUT seeds (anti-hardcoding).

import json
import os
import struct
import numpy as np

from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType  # pylint: disable=no-name-in-module
from cerebras.sdk.runtime.sdkruntimepybind import MemcpyOrder  # pylint: disable=no-name-in-module

import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--name", help="the test output dir")
parser.add_argument("--cmaddr", help="IP:port for CS system")
args = parser.parse_args()

with open(f"{args.name}/out.json", encoding="utf-8") as f:
    params = json.load(f)["params"]
n = int(params["n"])
n_buckets = int(params["n_buckets"])
bucket_size = int(params["bucket_size"])
print(f"Histogram-1PE: n={n}, n_buckets={n_buckets}, bucket_size={bucket_size}")


def float_to_hex(f):
    return hex(struct.unpack("<I", struct.pack("<f", f))[0])


def make_u48(words):
    return words[0] | (words[1] << 16) | (words[2] << 32)


def sub_ts(words):
    return make_u48(words[3:]) - make_u48(words[0:3])


# --- Build random input -----------------------------------------------------------
# INPUT-SPLIT: seed from XKERNEL_EVAL_SEED (default 7). Values in [0, n_buckets*
# bucket_size) so every element maps to a valid bucket; reference recomputed each run.
SEED = int(os.environ.get("XKERNEL_EVAL_SEED", "7"))
rng = np.random.default_rng(SEED)
max_val = n_buckets * bucket_size
inputs = rng.integers(0, max_val, size=n, dtype=np.uint32)

# numpy reference: hist[(v//bucket_size) % n_buckets] += 1
buckets = (inputs // bucket_size) % n_buckets
hist_ref = np.bincount(buckets, minlength=n_buckets).astype(np.uint32)

# --- Run on device ----------------------------------------------------------------
runner = SdkRuntime(args.name, cmaddr=args.cmaddr)
sym_input = runner.get_id("input")
sym_hist = runner.get_id("hist")
sym_time = runner.get_id("maxmin_time")

runner.load()
runner.run()

U32 = MemcpyDataType.MEMCPY_32BIT
RM = MemcpyOrder.ROW_MAJOR

runner.memcpy_h2d(sym_input, inputs, 0, 0, 1, 1, n, streaming=False,
                  data_type=U32, order=RM, nonblock=False)

runner.call("compute", [], nonblock=False)

tdata = np.zeros((3,), dtype=np.uint32)
runner.memcpy_d2h(tdata, sym_time, 0, 0, 1, 1, 3, streaming=False,
                  data_type=U32, order=RM, nonblock=False)

hist_dev = np.zeros((n_buckets,), dtype=np.uint32)
runner.memcpy_d2h(hist_dev, sym_hist, 0, 0, 1, 1, n_buckets, streaming=False,
                  data_type=U32, order=RM, nonblock=False)
runner.stop()

# --- Cycle count ------------------------------------------------------------------
maxmin = tdata.view(np.float32)
tsc = np.zeros(6, dtype=np.uint16)
h0 = int(float_to_hex(maxmin[0]), 16)
h1 = int(float_to_hex(maxmin[1]), 16)
h2 = int(float_to_hex(maxmin[2]), 16)
tsc[0] = h0 & 0xFFFF
tsc[1] = (h0 >> 16) & 0xFFFF
tsc[2] = h1 & 0xFFFF
tsc[3] = (h1 >> 16) & 0xFFFF
tsc[4] = h2 & 0xFFFF
tsc[5] = (h2 >> 16) & 0xFFFF
cycles = int(sub_ts([int(v) for v in tsc]))
print(f"cycles_send = {cycles} cycles")
print(f"time_send = {(cycles / 0.85) * 1.0e-3:.4f} us")

# --- Verify (the real invariant: hist == numpy bincount) --------------------------
print(f"[verify] device total = {int(hist_dev.sum())}, expected total = {n}")
np.testing.assert_array_equal(hist_dev, hist_ref)
print("SUCCESS")
