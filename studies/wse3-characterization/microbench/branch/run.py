#!/usr/bin/env cs_python
import argparse, json, struct
import numpy as np
from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType, MemcpyOrder
ap = argparse.ArgumentParser(); ap.add_argument("--name", default="out"); ap.add_argument("--cmaddr"); a = ap.parse_args()
meta = json.load(open("meta.json")); N, REPS, V = meta["N"], meta["REPS"], meta["variants"]
ia = ((np.arange(N) * 7) % 23 - 11).astype(np.int16)
flags = {"f_true": np.ones(N, np.int16), "f_false": np.zeros(N, np.int16), "f_alt": (np.arange(N) & 1).astype(np.int16)}
def words(x): return np.frombuffer(np.asarray(x, np.int16).tobytes(), dtype=np.uint32).copy()
r = SdkRuntime(a.name, cmaddr=a.cmaddr); r.load(); r.run()
F32, RM = MemcpyDataType.MEMCPY_32BIT, MemcpyOrder.ROW_MAJOR
for name, arr in [("ia", ia)] + list(flags.items()):
    w = words(arr); r.memcpy_h2d(r.get_id(name), w, 0, 0, 1, 1, len(w), streaming=False, data_type=F32, order=RM, nonblock=False)
r.call("compute", [], nonblock=False)
t = np.zeros(15, np.uint32); r.memcpy_d2h(t, r.get_id("maxmin_time"), 0, 0, 1, 1, 15, streaming=False, data_type=F32, order=RM, nonblock=False)
sk = np.zeros(5, np.float32); r.memcpy_d2h(sk, r.get_id("sink"), 0, 0, 1, 1, 5, streaming=False, data_type=F32, order=RM, nonblock=False)
r.stop()
# expected sums (int16 wrap), replaying exactly
def run_model(kind):
    s = np.int16(0)
    for _ in range(REPS):
        for i in range(N):
            if kind in ("straight", "loop"):
                s = np.int16((int(s) + int(ia[i])) & 0xFFFF)
            else:
                if flags[kind][i] != 0:
                    s = np.int16((int(s) + int(ia[i])) & 0xFFFF); s = np.int16((int(s) ^ ((int(s) << 1) & 0xFFFF)) & 0xFFFF); s = np.int16((int(s) + 3) & 0xFFFF)
    return int(s)
f = t.view(np.float32)
def f2h(x): return struct.unpack("<I", struct.pack("<f", x))[0]
def u48(w): return w[0] | (w[1] << 16) | (w[2] << 32)
out = []
print(f"{'variant':<10}{'cycles':>9}{'cyc/iter':>10}{'sum got':>9}{'expected':>9}  verify   (N={N}, reps={REPS})")
for i, v in enumerate(V):
    ws = []
    for j in range(3):
        h = f2h(f[i*3+j]); ws += [h & 0xFFFF, (h >> 16) & 0xFFFF]
    cyc = u48(ws[3:]) - u48(ws[0:3])
    exp = run_model("f_" + v if v in ("true", "false", "alt") else v)
    got = int(np.int16(int(sk[i])))
    ok = got == exp
    print(f"{v:<10}{cyc:>9}{cyc/(N*REPS):>10.3f}{got:>9}{exp:>9}  {'ok' if ok else 'FAIL'}")
    out.append({"variant": v, "cycles": int(cyc), "cyc_per_iter": cyc/(N*REPS), "sum": got, "expected": exp, "ok": ok, "t_start": int(u48(ws[0:3])), "t_end": int(u48(ws[3:]))})
json.dump(out, open("results.json", "w"), indent=1)
