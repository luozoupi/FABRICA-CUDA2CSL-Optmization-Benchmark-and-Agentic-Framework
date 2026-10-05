#!/usr/bin/env cs_python
"""Verified blocks v3: CSR (gather), CSC (scatter-add), dense column-major tile, 4x4 BSR and DIA with the
remainder compacted in place, each converted on the PE from the CSR input; checked against numpy for 1
and 10 products."""
import argparse, json, struct
import numpy as np
from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType, MemcpyOrder

ap = argparse.ArgumentParser(); ap.add_argument("--name", default="out"); ap.add_argument("--cmaddr")
ap.add_argument("--kind", default="banded"); ap.add_argument("--N", type=int, default=128)
ap.add_argument("--CAP", type=int, default=1024); ap.add_argument("--dense", type=int, default=0)
ap.add_argument("--bsr", type=int, default=1)
a = ap.parse_args()
N, CAP = a.N, a.CAP
rng = np.random.default_rng(2026)
A = np.zeros((N, N), np.float32)
if a.kind == "banded":                  # band -2..+2, 15% holes, N/6 off-band entries, one empty row
    for r in range(N):
        for off in range(-2, 3):
            if 0 <= r + off < N and rng.random() > 0.15:
                A[r, r + off] = rng.uniform(-1, 1)
    for _ in range(N // 6):
        r, c = rng.integers(0, N, 2); A[r, c] = rng.uniform(-1, 1)
    A[N // 2, :] = 0.0
elif a.kind == "random":                # uniform random, 25% density (the SpMV-CSR task's class)
    mask = rng.random((N, N)) < 0.25
    A[mask] = rng.uniform(-1, 1, mask.sum())
elif a.kind == "block":                 # 4x4 blocks on the block tridiagonal, 90% filled
    for br in range(N // 4):
        for bc in (br - 1, br, br + 1):
            if 0 <= bc < N // 4:
                blk = rng.uniform(-1, 1, (4, 4)).astype(np.float32) * (rng.random((4, 4)) < 0.9)
                A[br * 4:br * 4 + 4, bc * 4:bc * 4 + 4] = blk
rows, cols = np.nonzero(A); nnz = len(rows)
assert nnz <= CAP, (nnz, CAP)
rp = np.zeros(N + 1, np.uint32); np.add.at(rp, rows + 1, 1); rp = np.cumsum(rp).astype(np.uint32)
ci = np.zeros(CAP, np.uint32); ci[:nnz] = cols
va = np.zeros(CAP, np.float32); va[:nnz] = A[rows, cols]
x = rng.uniform(-1, 1, N).astype(np.float32)
y_ref = (A.astype(np.float64) @ x.astype(np.float64)).astype(np.float32)
nblocks = len({(r // 4, c // 4) for r, c in zip(rows, cols)})
print(json.dumps({"kind": a.kind, "N": N, "nnz": int(nnz), "density": round(nnz / N / N, 4), "bsr_blocks": nblocks}))

U32, RM = MemcpyDataType.MEMCPY_32BIT, MemcpyOrder.ROW_MAJOR
r_ = SdkRuntime(a.name, cmaddr=a.cmaddr)
sym = {k: r_.get_id(k) for k in ("rp", "ci", "va", "xv", "yv", "ctl", "tbuf")}
r_.load(); r_.run()
h2d = lambda k, arr: r_.memcpy_h2d(sym[k], np.ascontiguousarray(arr).view(np.uint32), 0, 0, 1, 1, len(arr),
                                  streaming=False, data_type=U32, order=RM, nonblock=False)
def d2h(k, n):
    out = np.zeros(n, np.uint32)
    r_.memcpy_d2h(out, sym[k], 0, 0, 1, 1, n, streaming=False, data_type=U32, order=RM, nonblock=False)
    return out
h2d("rp", rp); h2d("ci", ci); h2d("va", va); h2d("xv", x)

def cycles(t):
    w = []
    for f in t.view(np.float32):
        h = struct.unpack("<I", struct.pack("<f", f))[0]; w += [h & 0xFFFF, h >> 16]
    u48 = lambda q: q[0] | (q[1] << 16) | (q[2] << 32)
    return u48(w[3:]) - u48(w[:3])

names = {0: "csr", 1: "csc", 2: "dense", 3: "bsr4", 4: "dia_compact"}
ok = True
for m in (0, 1, 2, 3, 4):
    if (m == 2 and not a.dense) or (m == 3 and not a.bsr):
        continue
    for k in (1, 10):
        h2d("rp", rp); h2d("ci", ci); h2d("va", va)          # DIA compaction rewrites ci/va in place
        h2d("ctl", np.array([m, k], np.uint32))
        r_.call("compute", [], nonblock=False)
        y = d2h("yv", N).view(np.float32)
        good = bool(np.allclose(y, y_ref, rtol=1e-4, atol=1e-5)); ok &= good
        print(json.dumps({"method": names[m], "products": k, "cycles": int(cycles(d2h("tbuf", 3))), "nnz": int(nnz),
                          "correct": good, "max_abs_err": float(np.max(np.abs(y - y_ref)))}), flush=True)
r_.stop()
print("BLOCKS_OK" if ok else "BLOCKS_FAIL")
if ok:
    print("SUCCESS")
