#!/usr/bin/env cs_python
import argparse, json, struct
import numpy as np
from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType, MemcpyOrder
ap = argparse.ArgumentParser(); ap.add_argument("--name", default="out"); ap.add_argument("--cmaddr")
a = ap.parse_args()
params = json.load(open(f"{a.name}/out.json"))["params"]
N, B = int(params["N"]), int(params["B"])
r = SdkRuntime(a.name, cmaddr=a.cmaddr); r.load(); r.run()
r.call("run", [], nonblock=False)
t = np.zeros((N + 1) * 2, dtype=np.uint32)
r.memcpy_d2h(t, r.get_id("timer"), 0, 0, N + 1, 1, 2, streaming=False,
             data_type=MemcpyDataType.MEMCPY_32BIT, order=MemcpyOrder.ROW_MAJOR, nonblock=False)
r.stop()
f = t.view(np.float32)
def u48(i):
    lo = struct.unpack("<I", struct.pack("<f", f[2*i]))[0]; hi = struct.unpack("<I", struct.pack("<f", f[2*i+1]))[0]
    return lo | (hi << 32)
T = u48(N) - u48(0)
print(f"RELAY N={N} B={B} cycles={T}")
json.dump({"N": N, "B": B, "cycles": int(T)}, open(f"result_N{N}_B{B}.json", "w"))
