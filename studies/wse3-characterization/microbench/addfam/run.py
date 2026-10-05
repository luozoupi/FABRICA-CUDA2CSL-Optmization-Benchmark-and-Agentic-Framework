#!/usr/bin/env cs_python
"""Execute one add-family case and check its numerical result.

The compilation model says nothing about values, so correctness is a SEPARATE acceptance
check: the same inputs go to the device and to a Python model of the case's CSL body, and
the exported arrays are compared element by element in wrapped int16.
"""
import argparse, json
import numpy as np
from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType, MemcpyOrder
ap = argparse.ArgumentParser(); ap.add_argument("--name", required=True); ap.add_argument("--dir", default=".")
ap.add_argument("--cmaddr"); A = ap.parse_args()
F32, RM = MemcpyDataType.MEMCPY_32BIT, MemcpyOrder.ROW_MAJOR
N = 64
def w(v):
    v = int(v) & 0xFFFF
    return v - 0x10000 if v >= 0x8000 else v
a = np.array([w(i * 3 - 20) for i in range(N)], np.int16)
b = np.array([w(7 - i * 2) for i in range(N)], np.int16)
idx = np.array([5, 0, 0, 0], np.int16)
k = np.array([6, 0, 0, 0], np.int16)
IDX, K = int(idx[0]), int(k[0])
AA, BB = [int(x) for x in a], [int(x) for x in b]
def chain():
    c = [0] * N
    for i in range(1, K): c[i] = w(c[i - 1] + BB[i])
    return {i: c[i] for i in range(1, K)}
EXPECT = {
 "base":             ("c", {0: w(AA[0] + BB[0])}),
 "const_one":        ("c", {0: w(AA[0] + 7)}),
 "const_both":       ("c", {0: 10}),
 "index_runtime":    ("c", {0: w(AA[IDX] + BB[IDX])}),
 "use_expr_twice":   ("c", {0: w(AA[0] + BB[0]), 1: w(AA[0] + BB[0])}),
 "use_value_twice":  ("c", {0: w(AA[0] + BB[0]), 1: w(AA[0] + BB[0] + BB[1])}),
 "operand_shared":   ("c", {0: w(AA[0] + BB[0]), 1: w(AA[0] + BB[1])}),
 "pair_independent": ("c", {0: w(AA[0] + BB[0]), 1: w(AA[1] + BB[1])}),
 "pair_dependent":   ("c", {0: w(AA[0] + BB[0]), 1: w(AA[0] + BB[0] + BB[1])}),
 "inplace":          ("a", {0: w(AA[0] + BB[0])}),
 "select_runtime":   ("c", {0: w(AA[0] + BB[0]) if K > 0 else w(AA[1] + BB[1])}),
 "loop_comptime":    ("c", {i: w(AA[i] + BB[i]) for i in range(16)}),
 "loop_runtime":     ("c", {i: w(AA[i] + BB[i]) for i in range(K)}),
 "dsd16":            ("c", {i: w(AA[i] + BB[i]) for i in range(16)}),
 "W_index_inplace":  ("a", {IDX: w(AA[IDX] + BB[IDX])}),
 "W_const_in_loop":  ("c", {i: w(AA[0] + 5) for i in range(8)}),
 "W_chain_in_loop":  ("c", chain()),
 "W_dsd_inplace":    ("a", {i: w(AA[i] + BB[i]) for i in range(16)}),
}
pack = lambda x: np.frombuffer(np.asarray(x, np.int16).tobytes(), np.uint32).copy()
r = SdkRuntime(f"{A.dir}/out", cmaddr=A.cmaddr); r.load(); r.run()
for nm, v in (("a", a), ("b", b), ("idx", idx), ("k", k)):
    wd = pack(v); r.memcpy_h2d(r.get_id(nm), wd, 0, 0, 1, 1, len(wd), streaming=False, data_type=F32, order=RM, nonblock=False)
r.call("compute", [], nonblock=False)
out = {}
for nm in ("a", "c"):
    wd = np.zeros(N // 2, np.uint32)
    r.memcpy_d2h(wd, r.get_id(nm), 0, 0, 1, 1, N // 2, streaming=False, data_type=F32, order=RM, nonblock=False)
    out[nm] = np.frombuffer(wd.tobytes(), np.int16)[:N]
r.stop()
arr, exp = EXPECT[A.name]
got = {i: int(out[arr][i]) for i in exp}
bad = {i: (got[i], e) for i, e in exp.items() if got[i] != e}
# untouched elements of the checked array must still hold their input (or zero for c)
base = {i: int(a[i]) for i in range(N)} if arr == "a" else {i: 0 for i in range(N)}
stray = {i: int(out[arr][i]) for i in range(N) if i not in exp and int(out[arr][i]) != base[i]}
res = {"case": A.name, "array": arr, "inputs": {"a[0:4]": AA[:4], "b[0:4]": BB[:4], "idx[0]": IDX, "k[0]": K},
       "expected": {str(i): v for i, v in exp.items()}, "observed": {str(i): v for i, v in got.items()},
       "mismatches": {str(i): v for i, v in bad.items()}, "stray_writes": {str(i): v for i, v in stray.items()},
       "ok": not bad and not stray}
json.dump(res, open(f"{A.dir}/verify.json", "w"), indent=1)
print(f"{A.name:<18} {'ok  ' if res['ok'] else 'FAIL'} checked {len(exp)} element(s)"
      + ("" if res["ok"] else f"  mismatches={bad} stray={stray}"))
