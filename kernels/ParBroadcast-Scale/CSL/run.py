#!/usr/bin/env cs_python
"""ParBroadcast-Scale host runner: PE0 broadcasts alpha, all PEs scale."""

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
print(f"ParBroadcast-Scale: n_per_pe={n_per_pe}, PEs={width}, N={N}")

def float_to_hex(f): return hex(struct.unpack("<I", struct.pack("<f", f))[0])
def make_u48(w): return w[0] | (w[1] << 16) | (w[2] << 32)
def sub_ts(w): return make_u48(w[3:]) - make_u48(w[0:3])

SEED = int(os.environ.get("XKERNEL_EVAL_SEED", "7"))
rng = np.random.default_rng(SEED)
alpha = np.float32(2.5)
x_all = rng.standard_normal(N).astype(np.float32)
ref = (alpha * x_all).astype(np.float32)

runner = SdkRuntime(args.name, cmaddr=args.cmaddr)
runner.load()
runner.run()

F32 = MemcpyDataType.MEMCPY_32BIT
RM = MemcpyOrder.ROW_MAJOR

runner.memcpy_h2d(runner.get_id("x"), x_all, 0, 0, width, 1, n_per_pe,
                  streaming=False, data_type=F32, order=RM, nonblock=False)
# Send alpha only to PE(0,0)
runner.memcpy_h2d(runner.get_id("alpha"), np.array([alpha], dtype=np.float32),
                  0, 0, 1, 1, 1, streaming=False, data_type=F32, order=RM, nonblock=False)

runner.launch("compute", nonblock=False)

# Read timer from PE(0,0)
tdata = np.zeros(3, dtype=np.uint32)
runner.memcpy_d2h(tdata, runner.get_id("maxmin_time"), 0, 0, 1, 1, 3,
                  streaming=False, data_type=F32, order=RM, nonblock=False)

# Read output from all PEs
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

np.testing.assert_allclose(out_dev, ref, rtol=1e-5, atol=1e-6)
print("SUCCESS")
