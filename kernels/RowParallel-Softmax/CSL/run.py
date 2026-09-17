#!/usr/bin/env cs_python
"""RowParallel-Softmax host runner: distributed softmax across 4 PEs."""

import json, os, struct
import numpy as np
from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType, MemcpyOrder
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--name", help="the test output dir")
parser.add_argument("--cmaddr", help="IP:port for CS system")
args = parser.parse_args()

with open(f"{args.name}/out.json", encoding="utf-8") as f:
    params = json.load(f)["params"]
n_per_pe = int(params["n_per_pe"])
width = int(params.get("width", 4))
N = n_per_pe * width
print(f"RowParallel-Softmax: n_per_pe={n_per_pe}, PEs={width}, N={N}")

def float_to_hex(f): return hex(struct.unpack("<I", struct.pack("<f", f))[0])
def make_u48(w): return w[0] | (w[1] << 16) | (w[2] << 32)
def sub_ts(w): return make_u48(w[3:]) - make_u48(w[0:3])

SEED = int(os.environ.get("XKERNEL_EVAL_SEED", "7"))
rng = np.random.default_rng(SEED)
x_all = rng.standard_normal(N).astype(np.float32) * 3.0
shifted = x_all - np.max(x_all)
exp_x = np.exp(shifted)
ref = (exp_x / np.sum(exp_x)).astype(np.float32)

runner = SdkRuntime(args.name, cmaddr=args.cmaddr)
runner.load()
runner.run()

F32 = MemcpyDataType.MEMCPY_32BIT
RM = MemcpyOrder.ROW_MAJOR

runner.memcpy_h2d(runner.get_id("x"), x_all, 0, 0, width, 1, n_per_pe,
                  streaming=False, data_type=F32, order=RM, nonblock=False)

runner.launch("compute", nonblock=False)

tdata = np.zeros(3, dtype=np.uint32)
runner.memcpy_d2h(tdata, runner.get_id("maxmin_time"), 0, 0, 1, 1, 3,
                  streaming=False, data_type=F32, order=RM, nonblock=False)

out_dev = np.zeros(N, dtype=np.float32)
runner.memcpy_d2h(out_dev, runner.get_id("out"), 0, 0, width, 1, n_per_pe,
                  streaming=False, data_type=F32, order=RM, nonblock=False)
runner.stop()

maxmin = tdata.view(np.float32)
tsc = np.zeros(6, dtype=np.uint16)
for i, h in enumerate([int(float_to_hex(maxmin[j]), 16) for j in range(3)]):
    tsc[2*i] = h & 0xFFFF; tsc[2*i+1] = (h >> 16) & 0xFFFF
cycles = int(sub_ts([int(v) for v in tsc]))
print(f"cycles_send = {cycles} cycles")
print(f"sum(out) = {out_dev.sum():.6f} (should be ~1.0)")

np.testing.assert_allclose(out_dev, ref, rtol=1e-3, atol=1e-5)
print("SUCCESS")
