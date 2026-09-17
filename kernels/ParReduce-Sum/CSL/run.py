#!/usr/bin/env cs_python
"""ParReduce-Sum host runner: parallel tree reduction across 4 PEs."""

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
height = int(params.get("height", 1))
N = n_per_pe * width * height
print(f"ParReduce-Sum: n_per_pe={n_per_pe}, PEs={width}x{height}, N={N}")

def float_to_hex(f): return hex(struct.unpack("<I", struct.pack("<f", f))[0])
def make_u48(w): return w[0] | (w[1] << 16) | (w[2] << 32)
def sub_ts(w): return make_u48(w[3:]) - make_u48(w[0:3])

SEED = int(os.environ.get("XKERNEL_EVAL_SEED", "7"))
rng = np.random.default_rng(SEED)
x_all = rng.standard_normal(N).astype(np.float32)
ref_sum = np.sum(x_all).astype(np.float32)

runner = SdkRuntime(args.name, cmaddr=args.cmaddr)
sym_x = runner.get_id("x")
sym_result = runner.get_id("result")
sym_time = runner.get_id("maxmin_time")

runner.load()
runner.run()

F32 = MemcpyDataType.MEMCPY_32BIT
RM = MemcpyOrder.ROW_MAJOR

# Send n_per_pe elements to each PE (column-major: each PE gets a contiguous chunk)
runner.memcpy_h2d(sym_x, x_all, 0, 0, width, height, n_per_pe, streaming=False,
                  data_type=F32, order=RM, nonblock=False)

runner.launch("compute", nonblock=False)

# Read timer from PE(0,0) — the root of the reduction tree
tdata = np.zeros(3, dtype=np.uint32)
runner.memcpy_d2h(tdata, sym_time, 0, 0, 1, 1, 3, streaming=False,
                  data_type=F32, order=RM, nonblock=False)

# Read result from PE(0,0)
result_dev = np.zeros(1, dtype=np.float32)
runner.memcpy_d2h(result_dev, sym_result, 0, 0, 1, 1, 1, streaming=False,
                  data_type=F32, order=RM, nonblock=False)
runner.stop()

maxmin = tdata.view(np.float32)
tsc = np.zeros(6, dtype=np.uint16)
for i, h in enumerate([int(float_to_hex(maxmin[j]), 16) for j in range(3)]):
    tsc[2*i] = h & 0xFFFF; tsc[2*i+1] = (h >> 16) & 0xFFFF
cycles = int(sub_ts([int(v) for v in tsc]))
print(f"cycles_send = {cycles} cycles")
print(f"result_dev = {result_dev[0]:.4f}, ref = {ref_sum:.4f}")

np.testing.assert_allclose(result_dev[0], ref_sum, rtol=1e-2, atol=1e-1)
print("SUCCESS")
