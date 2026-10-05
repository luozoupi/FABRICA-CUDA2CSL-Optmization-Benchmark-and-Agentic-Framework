#!/usr/bin/env cs_python
import argparse, json
import numpy as np
from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType, MemcpyOrder
ap = argparse.ArgumentParser(); ap.add_argument("--name", default="out"); ap.add_argument("--cmaddr"); A = ap.parse_args()
F32, RM = MemcpyDataType.MEMCPY_32BIT, MemcpyOrder.ROW_MAJOR
def pack(x, dt): return np.frombuffer(np.asarray(x, dt).tobytes(), dtype=np.uint32).copy()
def unpack(w, dt, n): return np.frombuffer(np.asarray(w, np.uint32).tobytes(), dtype=dt)[:n]
r16 = lambda x: np.asarray(x, np.float64).astype(np.float16).astype(np.float64)
inp = {
  "ai": np.array([1234, -7, 5, 9], np.int16), "bi": np.array([-4321, 2, 9, 5], np.int16),
  "af": np.array([1.5, 0.75, 0, 0], np.float16), "bf": np.array([-0.25, 2.0, 0, 0], np.float16),
  "a": (np.arange(16) * 0.125 - 1.0).astype(np.float16), "b": ((np.arange(16) * 7 % 11) * 0.25 - 1.0).astype(np.float16),
  "a32": (np.arange(8) * 0.3125 + 1.5).astype(np.float32), "b32": (np.arange(8) * -0.1875 + 2.25).astype(np.float32),
  "ia8": (np.arange(8) * 37 - 100).astype(np.int16), "ib8": (np.arange(8) * -13 + 60).astype(np.int16),
}
dts = {"ai": np.int16, "bi": np.int16, "af": np.float16, "bf": np.float16, "a": np.float16, "b": np.float16, "a32": np.float32, "b32": np.float32, "ia8": np.int16, "ib8": np.int16}
r = SdkRuntime(A.name, cmaddr=A.cmaddr); r.load(); r.run()
for k, v in inp.items():
    w = pack(v, dts[k]); r.memcpy_h2d(r.get_id(k), w, 0, 0, 1, 1, len(w), streaming=False, data_type=F32, order=RM, nonblock=False)
r.call("compute", [], nonblock=False)
outs = {}
for k, dt, n in (("ci", np.int16, 16), ("cf", np.float16, 16), ("c", np.float16, 64), ("c32", np.float32, 16), ("ic8", np.int16, 8), ("mark", np.int16, 32)):
    nw = n if dt == np.float32 else n // 2
    w = np.zeros(nw, np.uint32); r.memcpy_d2h(w, r.get_id(k), 0, 0, 1, 1, nw, streaming=False, data_type=F32, order=RM, nonblock=False)
    outs[k] = unpack(w, dt, n)
r.stop()
ai, bi, af, bf, a, b, a32, b32, ia8, ib8 = (inp[k] for k in ("ai", "bi", "af", "bf", "a", "b", "a32", "b32", "ia8", "ib8"))
i16 = lambda x: int(np.int16(int(x) & 0xFFFF))
f64 = lambda x: float(np.float64(x))
exp = {
  "sub_i16": ("ci", 0, i16(int(ai[0]) - int(bi[0]))), "mul_i16": ("ci", 1, i16(int(ai[0]) * int(bi[0]))),
  "mul_f16": ("cf", 0, float(r16(f64(af[0]) * f64(bf[0])))), "fma_f16": ("cf", 1, float(r16(f64(af[0]) * f64(bf[0]) + f64(af[1])))),
  "and_i16": ("ci", 2, i16(int(ai[0]) & int(bi[0]))), "or_i16": ("ci", 3, i16(int(ai[0]) | int(bi[0]))),
  "xor_i16": ("ci", 4, i16(int(ai[0]) ^ int(bi[0]))), "shl_i16": ("ci", 5, i16(int(ai[0]) << 3)), "shr_i16": ("ci", 6, i16(int(ai[0]) >> 2)),
  "br_taken": ("ci", 7, 11 if ai[2] < bi[2] else 22), "br_not": ("ci", 8, 11 if ai[3] < bi[3] else 22),
  "loop2": ("ci", 9, i16(sum(int(ai[k]) for k in range(int(bi[1]))))),
  "f16_to_f32": ("c32", 0, f64(af[0])), "f32_to_f16": ("cf", 2, float(r16(f64(a32[0])))),
  "dsd_fill8": ("c", slice(0, 8), [1.5] * 8), "dsd_copy8": ("c", slice(8, 16), list(a[:8].astype(float))),
  "dsd_stride2": ("c", slice(16, 24), list(a[0:16:2].astype(float))),
  "dsd_reduce8": ("cf", 3, None),   # filled below (sequential f16 accumulate)
  "dsd_mulh8": ("c", slice(24, 32), list(r16(a[:8].astype(np.float64) * b[:8].astype(np.float64)))),
  "dsd_fmach8": ("c", slice(32, 40), list(r16(a[:8].astype(np.float64) + b[:8].astype(np.float64) * 0.5))),
  "dsd_add16x8": ("ic8", slice(0, 8), [i16(int(x) + int(y)) for x, y in zip(ia8, ib8)]),
  "dsd_fadds8": ("c32", slice(8, 16), list((a32[:8].astype(np.float64) + b32[:8].astype(np.float64)).astype(np.float32).astype(np.float64))),
}
acc = 0.0
for v in a[:8]: acc = float(r16(acc + f64(v)))
exp["dsd_reduce8"] = ("cf", 3, acc)
meta = json.load(open("meta.json")); rows = []
for f in meta:
    arr, idx, e = exp[f["name"]]
    got = outs[arr][idx]
    if isinstance(idx, slice):
        got_l = [float(x) for x in got]; ok = np.allclose(got_l, e, rtol=1e-6, atol=1e-6)
        rows.append({**f, "got": got_l, "expected": [float(x) for x in e], "ok": bool(ok)})
    else:
        g = float(got); ok = abs(g - float(e)) <= 1e-6 * max(1.0, abs(float(e)))
        rows.append({**f, "got": g, "expected": float(e), "ok": bool(ok)})
    print(f"{f['name']:<12} {'ok ' if rows[-1]['ok'] else 'FAIL'}  got={rows[-1]['got'] if not isinstance(idx, slice) else rows[-1]['got'][:3]}  expected={rows[-1]['expected'] if not isinstance(idx, slice) else rows[-1]['expected'][:3]}")
print("markers read back:", [int(m) for m in outs["mark"][:len(meta) + 1]])
json.dump({"rows": rows, "inputs": {k: [float(x) for x in v] for k, v in inp.items()}}, open("results.json", "w"), indent=1)
