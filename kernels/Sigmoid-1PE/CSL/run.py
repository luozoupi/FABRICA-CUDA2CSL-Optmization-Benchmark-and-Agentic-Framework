#!/usr/bin/env cs_python
"""Sigmoid-1PE host runner: out[i] = 1/(1+exp(-x[i]))."""

import json
import os
import struct
import numpy as np

from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType, MemcpyOrder

import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--name", help="the test output dir")
parser.add_argument("--cmaddr", help="IP:port for CS system")
args = parser.parse_args()

with open(f"{args.name}/out.json", encoding="utf-8") as f:
    params = json.load(f)["params"]
n = int(params["n"])
print(f"Sigmoid-1PE: n={n}")


def float_to_hex(f):
    return hex(struct.unpack("<I", struct.pack("<f", f))[0])


def make_u48(words):
    return words[0] | (words[1] << 16) | (words[2] << 32)


def sub_ts(words):
    return make_u48(words[3:]) - make_u48(words[0:3])


SEED = int(os.environ.get("XKERNEL_EVAL_SEED", "7"))
rng = np.random.default_rng(SEED)
x = rng.standard_normal(n).astype(np.float32) * 3.0
ref = (1.0 / (1.0 + np.exp(-x))).astype(np.float32)

runner = SdkRuntime(args.name, cmaddr=args.cmaddr)
sym_x = runner.get_id("x")
sym_out = runner.get_id("out")
sym_time = runner.get_id("maxmin_time")

runner.load()
runner.run()

F32 = MemcpyDataType.MEMCPY_32BIT
RM = MemcpyOrder.ROW_MAJOR

runner.memcpy_h2d(sym_x, x, 0, 0, 1, 1, n, streaming=False,
                  data_type=F32, order=RM, nonblock=False)

runner.call("compute", [], nonblock=False)

tdata = np.zeros((3,), dtype=np.uint32)
runner.memcpy_d2h(tdata, sym_time, 0, 0, 1, 1, 3, streaming=False,
                  data_type=F32, order=RM, nonblock=False)

out_dev = np.zeros(n, dtype=np.float32)
runner.memcpy_d2h(out_dev, sym_out, 0, 0, 1, 1, n, streaming=False,
                  data_type=F32, order=RM, nonblock=False)
runner.stop()

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

np.testing.assert_allclose(out_dev, ref, rtol=1e-4, atol=1e-6)
print("SUCCESS")
