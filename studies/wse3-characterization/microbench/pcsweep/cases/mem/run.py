#!/usr/bin/env cs_python
"""Run one pcsweep class program and check every pair's result."""
import argparse, json
import numpy as np
from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType, MemcpyOrder
ap = argparse.ArgumentParser(); ap.add_argument("--name", default="out"); ap.add_argument("--cls", required=True); ap.add_argument("--cmaddr"); A = ap.parse_args()
F32, RM = MemcpyDataType.MEMCPY_32BIT, MemcpyOrder.ROW_MAJOR
meta = json.load(open("meta.json")); NP = meta["pairs"] if meta["expect"] != "dsr" else meta["pairs"]
w16 = lambda v: int(np.int16(int(v) & 0xFFFF))
r16 = lambda x: float(np.float16(x))
a = np.array([w16(3 * i - 7) for i in range(8)], np.int16); b = np.array([w16(11 - 2 * i) for i in range(8)], np.int16); g = np.array([w16(5 * i + 1) for i in range(8)], np.int16)
a[1] = 9; b[1] = 3; a[3] = 20; b[3] = -4; a[5] = 7; b[5] = 0; a[7] = 1; b[7] = -1     # make odd pairs take the else arm
af = np.array([0.5 * i - 1.75 for i in range(8)], np.float16); bf = np.array([0.25 * i + 0.5 for i in range(8)], np.float16); gf = np.array([1.5 - 0.125 * i for i in range(8)], np.float16)
def pack(x, dt): return np.frombuffer(np.asarray(x, dt).tobytes(), np.uint32).copy()
def unpack(w, dt, n): return np.frombuffer(np.asarray(w, np.uint32).tobytes(), dt)[:n]
r = SdkRuntime(A.name, cmaddr=A.cmaddr); r.load(); r.run()
for k, v, dt in (("a", a, np.int16), ("b", b, np.int16), ("g", g, np.int16), ("af", af, np.float16), ("bf", bf, np.float16), ("gf", gf, np.float16)):
    w = pack(v, dt); r.memcpy_h2d(r.get_id(k), w, 0, 0, 1, 1, len(w), streaming=False, data_type=F32, order=RM, nonblock=False)
r.call("compute", [], nonblock=False)
out = {}
for k, dt, n in (("c", np.int16, 80), ("d", np.int16, 8), ("cf", np.float16, 16), ("mark", np.int16, 16)):
    w = np.zeros(n // 2, np.uint32); r.memcpy_d2h(w, r.get_id(k), 0, 0, 1, 1, n // 2, streaming=False, data_type=F32, order=RM, nonblock=False); out[k] = unpack(w, dt, n)
r.stop()
A_, B_, G_ = [int(x) for x in a], [int(x) for x in b], [int(x) for x in g]
exp = {}
if meta["expect"] == "dsr":
    for i in range(meta["pairs"] - (1 if meta.get("prepared_pair") is not None else 0)):   # the prepared pair rewrites the last slice
        for j in range(8): exp[("c", 8 * i + j)] = w16(A_[j] + B_[j])
elif meta["expect"] == "gpr":
    for i in range(NP): exp[("c", i)] = w16(A_[i] + B_[i])
elif meta["expect"] == "f16dep":
    for i in range(NP): exp[("cf", i)] = r16(r16(float(af[i]) * float(bf[i])) + float(gf[i]))
elif meta["expect"] == "i16dep":
    for i in range(NP): exp[("c", i)] = w16(w16(A_[i] + B_[i]) + G_[i])
elif meta["expect"] == "cflag":
    for i in range(NP): exp[("c", i)] = 11 if A_[i] < B_[i] else 22
elif meta["expect"] == "mem":
    for i in range(NP): exp[("c", i)] = w16(A_[i] + B_[i]); exp[("d", i)] = w16(w16(A_[i] + B_[i]) + G_[i])
elif meta["expect"] == "none":
    pass                                   # timing-only class: no stored result to check
elif meta["expect"] == "reduce":
    acc = 0.0
    for v in af: acc = r16(acc + float(v))
    for i in range(NP): exp[("cf", i)] = acc
bad = {f"{arr}[{i}]": (float(out[arr][i]), e) for (arr, i), e in exp.items() if float(out[arr][i]) != float(e)}
marks = [int(x) for x in out["mark"][:meta["pairs"] + 1]]
mark_ok = marks == [0x6000 + i for i in range(meta["pairs"] + 1)]          # pairs 0..P-1 then the END marker at index P
res = {"cls": A.cls, "checked": len(exp), "mismatches": bad, "markers": marks, "ok": not bad and mark_ok}
json.dump(res, open("verify.json", "w"), indent=1)
print(f"{A.cls:<12} {'ok  ' if res['ok'] else 'FAIL'} checked {len(exp)} values, markers {marks[:4]}...{'' if mark_ok else ' MARKERS WRONG'}{'' if not bad else ' ' + str(list(bad.items())[:3])}")
