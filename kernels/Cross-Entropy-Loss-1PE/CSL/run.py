#!/usr/bin/env cs_python
"""Cross-Entropy-Loss-1PE host runner: single-sample CE loss."""

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
n_classes = int(params["n_classes"])
print(f"Cross-Entropy-Loss-1PE: n_classes={n_classes}")

def float_to_hex(f): return hex(struct.unpack("<I", struct.pack("<f", f))[0])
def make_u48(w): return w[0] | (w[1] << 16) | (w[2] << 32)
def sub_ts(w): return make_u48(w[3:]) - make_u48(w[0:3])

SEED = int(os.environ.get("XKERNEL_EVAL_SEED", "7"))
rng = np.random.default_rng(SEED)
logits = rng.standard_normal(n_classes).astype(np.float32) * 3.0
label = rng.integers(0, n_classes, dtype=np.uint32)

# Reference: stable log-softmax
shifted = logits - np.max(logits)
log_sum_exp = np.log(np.sum(np.exp(shifted)))
ref_loss = -(shifted[label] - log_sum_exp)
ref = np.array([ref_loss], dtype=np.float32)

runner = SdkRuntime(args.name, cmaddr=args.cmaddr)
runner.load()
runner.run()
F32, U32, RM = MemcpyDataType.MEMCPY_32BIT, MemcpyDataType.MEMCPY_32BIT, MemcpyOrder.ROW_MAJOR
runner.memcpy_h2d(runner.get_id("logits"), logits, 0, 0, 1, 1, n_classes, streaming=False, data_type=F32, order=RM, nonblock=False)
runner.memcpy_h2d(runner.get_id("label"), np.array([label], dtype=np.uint32), 0, 0, 1, 1, 1, streaming=False, data_type=U32, order=RM, nonblock=False)
runner.call("compute", [], nonblock=False)
tdata = np.zeros(3, dtype=np.uint32)
runner.memcpy_d2h(tdata, runner.get_id("maxmin_time"), 0, 0, 1, 1, 3, streaming=False, data_type=F32, order=RM, nonblock=False)
result_dev = np.zeros(1, dtype=np.float32)
runner.memcpy_d2h(result_dev, runner.get_id("result"), 0, 0, 1, 1, 1, streaming=False, data_type=F32, order=RM, nonblock=False)
runner.stop()

maxmin = tdata.view(np.float32)
tsc = np.zeros(6, dtype=np.uint16)
for i, h in enumerate([int(float_to_hex(maxmin[j]), 16) for j in range(3)]):
    tsc[2*i] = h & 0xFFFF; tsc[2*i+1] = (h >> 16) & 0xFFFF
cycles = int(sub_ts([int(v) for v in tsc]))
print(f"cycles_send = {cycles} cycles")
print(f"label={label}, loss_dev={result_dev[0]:.4f}, loss_ref={ref[0]:.4f}")
np.testing.assert_allclose(result_dev, ref, rtol=1e-3, atol=1e-4)
print("SUCCESS")
