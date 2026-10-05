#!/usr/bin/env cs_python
"""Matmul traversal probe: cycles per MAC for all six loop orders, with the
numerical result of every variant checked against a host reference.

A timing comparison between traversals is only meaningful if they computed the
same thing, so each variant's C is copied to its own slot and verified here. A
variant that fails its check is reported as FAIL and its timing is not used.
"""
import argparse
import json
import struct
import numpy as np
from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType, MemcpyOrder

meta = json.load(open("meta.json", encoding="utf-8"))
V = meta["variants"]
M, N, K, MACS = meta["M"], meta["N"], meta["K"], meta["macs"]

ap = argparse.ArgumentParser()
ap.add_argument("--name", default="out")
ap.add_argument("--cmaddr")
a = ap.parse_args()

f2h = lambda f: struct.unpack("<I", struct.pack("<f", f))[0]
u48 = lambda w: w[0] | (w[1] << 16) | (w[2] << 32)

# Small magnitudes keep the f16 accumulation well away from overflow so a
# mismatch means a wrong traversal, not saturation.
rng = np.random.default_rng(20260921)
A = (rng.integers(-8, 9, size=(M, K)) / 16.0).astype(np.float16)
B = (rng.integers(-8, 9, size=(K, N)) / 16.0).astype(np.float16)
REF = (A.astype(np.float32) @ B.astype(np.float32))

r = SdkRuntime(a.name, cmaddr=a.cmaddr)
r.load(); r.run()
Bt = np.ascontiguousarray(B.T)
for sym, arr in (("A", A), ("B", B), ("Bt", Bt)):
    r.memcpy_h2d(r.get_id(sym), arr.flatten().view(np.uint16).astype(np.uint32),
                 0, 0, 1, 1, arr.size, streaming=False,
                 data_type=MemcpyDataType.MEMCPY_16BIT,
                 order=MemcpyOrder.ROW_MAJOR, nonblock=False)
r.call("compute", [], nonblock=False)

nw = 3 * len(V)
t = np.zeros(nw, dtype=np.uint32)
r.memcpy_d2h(t, r.get_id("cycles"), 0, 0, 1, 1, nw, streaming=False,
             data_type=MemcpyDataType.MEMCPY_32BIT,
             order=MemcpyOrder.ROW_MAJOR, nonblock=False)
SIG = 4 * N + M
co = np.zeros(len(V) * SIG, dtype=np.uint32)
r.memcpy_d2h(co, r.get_id("Cout"), 0, 0, 1, 1, len(V) * SIG, streaming=False,
             data_type=MemcpyDataType.MEMCPY_16BIT,
             order=MemcpyOrder.ROW_MAJOR, nonblock=False)
r.stop()

Cout = co.astype(np.uint16).view(np.float16).reshape(len(V), SIG)
REF_SIG = np.concatenate([REF[:4].reshape(-1), REF.sum(axis=1)]).astype(np.float32)
packed = t.view(np.float32)

print(f"C = A*B, {M}x{N}x{K} f16, {MACS} MACs per variant\n")
print(f"{'order':<7}{'inner':<9}{'cycles':>9}{'cyc/MAC':>10}{'MAC/cyc':>9}"
      f"{'vs best':>9}  {'max abs err':>12}  check")
INNER = {"ikj": "j (row)", "kij": "j (row)", "jki": "i (col)",
         "kji": "i (col)", "ijk": "k (dot)", "jik": "k (dot)",
         "ikj_map": "j (map)", "ijk_scalar": "k (scal)",
         "ijk_bt": "k (B^T)", "ikj_map_blk": "j (blk8)",
         "ijk_tree": "k (tree)", "kij_map": "j (o-map)", "outer_tile4": "j (tile4)",
         "outer_tile4b": "j (tile4b)", "outer_tile4c": "j (tile4c)"}
rows = []
for i, v in enumerate(V):
    w = np.zeros(6, dtype=np.uint16)
    for j in range(3):
        h = f2h(packed[i * 3 + j])
        w[2 * j] = h & 0xFFFF
        w[2 * j + 1] = (h >> 16) & 0xFFFF
    ww = [int(x) for x in w]
    cyc = u48(ww[3:]) - u48(ww[0:3])
    got = Cout[i].astype(np.float32)
    err = float(np.max(np.abs(got - REF_SIG)))
    ok = err < 0.05 * max(1.0, float(np.max(np.abs(REF))))
    # If a variant failed, test the specific hypothesis that its reduction kept
    # only the LAST product instead of accumulating -- the dest!=src0 signature.
    hyp = None
    if not ok:
        lastm = (A[:, K - 1].astype(np.float32).reshape(M, 1)
                 * B[K - 1, :].astype(np.float32).reshape(1, N))
        last = np.concatenate([lastm[:4].reshape(-1), lastm.sum(axis=1)])
        d = float(np.max(np.abs(got - last)))
        hyp = {"last_product_only_max_err": d,
               "matches_last_product": bool(d < 1e-3)}
    rows.append({"order": v, "inner": INNER[v], "cycles": int(cyc),
                 "cycles_per_mac": round(cyc / MACS, 5),
                 "macs_per_cycle": round(MACS / cyc, 3),
                 "max_abs_err": err, "passed": bool(ok), "failure_hypothesis": hyp})

good = [x for x in rows if x["passed"]]
best = min((x["cycles"] for x in good), default=None)
for x in rows:
    x["vs_best"] = round(x["cycles"] / best, 2) if best else None
    print(f"{x['order']:<7}{x['inner']:<9}{x['cycles']:>9}{x['cycles_per_mac']:>10.5f}"
          f"{x['macs_per_cycle']:>9.2f}{(str(x['vs_best'])+'x'):>9}"
          f"  {x['max_abs_err']:>12.5f}  {'ok' if x['passed'] else 'FAIL'}")

json.dump({"M": M, "N": N, "K": K, "macs": MACS,
           "ref_max_abs": float(np.max(np.abs(REF))),
           "signature": "first 4 rows verbatim + all 32 row sums",
           "variants": rows},
          open("matmulorder_results.json", "w", encoding="utf-8"), indent=1)
for x in rows:
    h = x.get("failure_hypothesis")
    if h:
        print(f"\n{x['order']}: failed. tested 'kept only the last product':"
              f" max err {h['last_product_only_max_err']:.6f}"
              f" -> {'CONFIRMED' if h['matches_last_product'] else 'not that'}")
print("\nwrote matmulorder_results.json")
