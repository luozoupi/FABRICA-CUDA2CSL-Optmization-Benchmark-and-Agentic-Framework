#!/usr/bin/env cs_python
import argparse, json
import numpy as np
from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType, MemcpyOrder
ap = argparse.ArgumentParser(); ap.add_argument("--name", default="out"); ap.add_argument("--cmaddr"); A = ap.parse_args()
F32, RM = MemcpyDataType.MEMCPY_32BIT, MemcpyOrder.ROW_MAJOR
m = json.load(open("meta.json")); L, S = m["L"], m["S"]
def pack(x): return np.frombuffer(np.asarray(x, np.int16).tobytes(), np.uint32).copy()
def unpack(w, n): return np.frombuffer(np.asarray(w, np.uint32).tobytes(), np.int16)[:n]
def w16(v):
    v = int(v) & 0xFFFF
    return v - 0x10000 if v >= 0x8000 else v
iaL = ((np.arange(L) % 7) - 3).astype(np.int16); ibL = ((np.arange(L) % 5) - 2).astype(np.int16)
ia = (np.arange(64) * 37 - 100).astype(np.int16); ib = (np.arange(64) * -13 + 55).astype(np.int16)
r = SdkRuntime(A.name, cmaddr=A.cmaddr); r.load(); r.run()
for k, v in (("iaL", iaL), ("ibL", ibL), ("ia", ia), ("ib", ib)):
    w = pack(v); r.memcpy_h2d(r.get_id(k), w, 0, 0, 1, 1, len(w), streaming=False, data_type=F32, order=RM, nonblock=False)
for fn in ("region_a", "region_b", "region_c"):
    r.call(fn, [], nonblock=False)
out = {}
for k, n in (("icA", L), ("icC", L), ("outsc", 4)):
    w = np.zeros(n // 2, np.uint32); r.memcpy_d2h(w, r.get_id(k), 0, 0, 1, 1, n // 2, streaming=False, data_type=F32, order=RM, nonblock=False)
    out[k] = unpack(w, n)
r.stop()
icA_e = (iaL.astype(np.int64) + ibL.astype(np.int64)).astype(np.int16)
def sq(seed, k):
    acc = w16(seed)
    for _ in range(S): acc = w16(acc * acc + w16(k))
    return acc
accB_e, accC_e = sq(ia[0], ia[1]), sq(ib[0], ib[1])
checks = {
  "icA all elements": bool(np.array_equal(out["icA"], icA_e)),
  "icC all elements": bool(np.array_equal(out["icC"], icA_e)),
  "accB": [int(out["outsc"][0]), int(accB_e), int(out["outsc"][0]) == int(accB_e)],
  "accC": [int(out["outsc"][1]), int(accC_e), int(out["outsc"][1]) == int(accC_e)],
}
for k, v in checks.items(): print(f"{k:<18} {v}")
ok = checks["icA all elements"] and checks["icC all elements"] and checks["accB"][2] and checks["accC"][2]
print("ALL", "ok" if ok else "FAIL")
json.dump({"L": L, "S": S, "checks": checks, "ok": bool(ok)}, open("results.json", "w"), indent=1)
