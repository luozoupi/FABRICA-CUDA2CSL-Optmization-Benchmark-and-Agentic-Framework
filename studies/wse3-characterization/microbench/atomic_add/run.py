#!/usr/bin/env cs_python
import argparse, json, struct
import numpy as np
from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType, MemcpyOrder
ap = argparse.ArgumentParser(); ap.add_argument("--name", default="out"); ap.add_argument("--cmaddr"); a_ = ap.parse_args()
F32, RM = MemcpyDataType.MEMCPY_32BIT, MemcpyOrder.ROW_MAJOR
def w16(x, dt): return np.frombuffer(np.asarray(x, dt).tobytes(), dtype=np.uint32).copy()
def r16(w, dt, n): return np.frombuffer(np.asarray(w, np.uint32).tobytes(), dtype=dt)[:n]
ai = np.array([1234, 0], np.int16); bi = np.array([-4321, 0], np.int16)
af = np.array([1.5, 0], np.float16); bf = np.array([-0.25, 0], np.float16)
a = (np.arange(64) * 0.125 - 3.0).astype(np.float16); b = ((np.arange(64) * 7 % 11) * 0.25 - 1.0).astype(np.float16)
r = SdkRuntime(a_.name, cmaddr=a_.cmaddr); r.load(); r.run()
for name, arr, dt in (("ai", ai, np.int16), ("bi", bi, np.int16), ("af", af, np.float16), ("bf", bf, np.float16), ("a", a, np.float16), ("b", b, np.float16)):
    w = w16(arr, dt); r.memcpy_h2d(r.get_id(name), w, 0, 0, 1, 1, len(w), streaming=False, data_type=F32, order=RM, nonblock=False)
r.call("compute", [], nonblock=False)
t = np.zeros(15, np.uint32); r.memcpy_d2h(t, r.get_id("maxmin_time"), 0, 0, 1, 1, 15, streaming=False, data_type=F32, order=RM, nonblock=False)
out = {}
for name, dt, n in (("ci", np.int16, 2), ("cf", np.float16, 2), ("c", np.float16, 64)):
    w = np.zeros(max(1, n // 2), np.uint32); r.memcpy_d2h(w, r.get_id(name), 0, 0, 1, 1, len(w), streaming=False, data_type=F32, order=RM, nonblock=False)
    out[name] = r16(w, dt, n)
r.stop()
f = t.view(np.float32)
def f2h(x): return struct.unpack("<I", struct.pack("<f", x))[0]
def u48(ws): return ws[0] | (ws[1] << 16) | (ws[2] << 32)
names = ["scalar_i16", "scalar_f16", "dsd8", "dsd16", "dsd64"]
rows = []
for i, nm in enumerate(names):
    ws = []
    for j in range(3):
        h = f2h(f[i*3+j]); ws += [h & 0xFFFF, (h >> 16) & 0xFFFF]
    rows.append({"variant": nm, "cycles": int(u48(ws[3:]) - u48(ws[0:3])), "t_start": int(u48(ws[0:3])), "t_end": int(u48(ws[3:]))})
exp_ci = np.int16((int(ai[0]) + int(bi[0])) & 0xFFFF); exp_cf = np.float16(np.float64(af[0]) + np.float64(bf[0]))
exp_c = (a.astype(np.float64) + b.astype(np.float64)).astype(np.float16)
checks = {"scalar_i16": bool(out["ci"][0] == exp_ci), "scalar_f16": bool(out["cf"][0] == exp_cf),
          "dsd8": bool(np.array_equal(out["c"][:8], exp_c[:8])), "dsd16": bool(np.array_equal(out["c"][:16], exp_c[:16])),
          "dsd64": bool(np.array_equal(out["c"], exp_c))}
for rw in rows:
    rw["verified"] = checks[rw["variant"]]
    print(f"{rw['variant']:<11} {rw['cycles']:>6} cycles   verified={rw['verified']}")
print(f"ci={int(out['ci'][0])} (expected {int(exp_ci)})  cf={float(out['cf'][0])} (expected {float(exp_cf)})  c[0..4]={out['c'][:4]}")
json.dump({"rows": rows, "inputs": {"ai": int(ai[0]), "bi": int(bi[0]), "af": float(af[0]), "bf": float(bf[0]), "a0": float(a[0]), "b0": float(b[0])},
           "outputs": {"ci": int(out["ci"][0]), "cf": float(out["cf"][0]), "c0": float(out["c"][0])}}, open("results.json", "w"), indent=1)
