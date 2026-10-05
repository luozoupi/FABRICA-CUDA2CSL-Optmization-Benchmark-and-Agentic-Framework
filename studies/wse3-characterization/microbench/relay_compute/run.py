#!/usr/bin/env cs_python
import argparse, json
import numpy as np
from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType, MemcpyOrder
ap = argparse.ArgumentParser(); ap.add_argument("--name", default="out"); ap.add_argument("--cmaddr"); a = ap.parse_args()
B = int(json.load(open(f"{a.name}/out.json"))["params"]["B"])
F32, RM = MemcpyDataType.MEMCPY_32BIT, MemcpyOrder.ROW_MAJOR
buf0 = np.array([1.5 * i - 2.25 for i in range(B)], np.float32)     # what PE0 sends
loc1 = np.array([0.125 * i + 10.0 for i in range(B)], np.float32)   # PE1's local operand
w = lambda x: np.frombuffer(np.asarray(x, np.float32).tobytes(), np.uint32).copy()
r = SdkRuntime(a.name, cmaddr=a.cmaddr); r.load(); r.run()
r.memcpy_h2d(r.get_id("buf"), w(buf0), 0, 0, 1, 1, B, streaming=False, data_type=F32, order=RM, nonblock=False)   # PE (0,0)
r.memcpy_h2d(r.get_id("loc"), w(loc1), 1, 0, 1, 1, B, streaming=False, data_type=F32, order=RM, nonblock=False)   # PE (1,0)
r.call("run", [], nonblock=False)
out = {}
for k in ("buf", "res"):
    o = np.zeros(B, np.uint32); r.memcpy_d2h(o, r.get_id(k), 1, 0, 1, 1, B, streaming=False, data_type=F32, order=RM, nonblock=False)
    out[k] = np.frombuffer(o.tobytes(), np.float32).copy()
r.stop()
exp = (buf0 + loc1).astype(np.float32)
ok_buf = np.array_equal(out["buf"], buf0); ok_res = np.array_equal(out["res"], exp)
print(f"RELAY_COMPUTE B={B} received={'ok' if ok_buf else 'FAIL'} res=buf+loc {'ok' if ok_res else 'FAIL'}  res[:3]={out['res'][:3]} expected {exp[:3]}")
json.dump({"B": B, "received_ok": bool(ok_buf), "res_ok": bool(ok_res), "buf0": buf0.tolist(), "loc1": loc1.tolist(), "res": out["res"].tolist()}, open("result.json", "w"), indent=1)
