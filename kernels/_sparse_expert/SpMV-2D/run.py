#!/usr/bin/env cs_python
# SpMV-2D host runner (expert headroom variant: 2D partition on a Pr x Pc mesh).
#
# Same matrices, seeds, x and verification as the SpMV-RowBlock task. Host-side preprocessing, outside
# the timed window: optional random permutations (perm=1: fixed independent row and column permutations
# that spread the nonzeros evenly over the blocks; perm=0: natural order), and the split of the matrix into Pr x Pc
# blocks of nr rows and seg = ceil(m/Pc) columns (COO per PE). x is written to PE (0,0) only; y is read
# from column 0.

import json
import os
import sys
import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sparse_inputs as si  # sibling copy of code_translation/sparse_inputs.py

from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType  # pylint: disable=no-name-in-module
from cerebras.sdk.runtime.sdkruntimepybind import MemcpyOrder  # pylint: disable=no-name-in-module

import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--name", help="the test output dir")
parser.add_argument("--cmaddr", help="IP:port for CS system")
args = parser.parse_args()

with open(f"{args.name}/out.json", encoding="utf-8") as f:
    params = json.load(f)["params"]
Pc, Pr = int(params["Pc"]), int(params["Pr"])
nr, ncols, cap = int(params["nr"]), int(params["ncols"]), int(params["max_nnz_pe"])
structure_id, perm = int(params.get("structure_id", 0)), int(params.get("perm", 1))
H = Pc // 2
print(f"SpMV-2D: Pc={Pc}, Pr={Pr}, nr={nr}, ncols={ncols}, max_nnz_pe={cap}, perm={perm}")

HERE = os.path.dirname(os.path.abspath(__file__))
SEED = si.resolve_eval_seed(7, where=HERE)
print(f"eval_seed = {SEED}")
manifest = "manifest.json" if structure_id == 0 else f"manifest_{structure_id}.json"
csr, entry = si.load_manifest_matrix(os.path.join(HERE, "data", manifest), SEED)
n, m, nnz = csr.n, csr.m, csr.nnz
print(f"matrix = {entry.get('id', entry.get('file'))} n={n} m={m} nnz={nnz}")
assert n == m and n <= Pr * nr
seg = -(-m // Pc)
assert Pc * seg <= ncols, f"x needs {Pc * seg} entries > ncols {ncols}"

x = np.zeros(ncols, dtype=np.float32)
x[:m] = np.random.default_rng([SEED, 1]).uniform(-1.0, 1.0, size=m).astype(np.float32)   # same x as the task
y_ref = csr.matvec(x[:m].astype(np.float64)).astype(np.float32)

# perm=1: independent random row and column permutations (A' = P A Q^T). A symmetric permutation keeps
# every diagonal entry in a diagonal block; on 8 x 8 those 8 PEs held ~270 nonzeros against ~70.
p_r = np.random.default_rng(20261004).permutation(n) if perm else np.arange(n)
q = np.random.default_rng(20261005).permutation(n) if perm else np.arange(n)
pinv = np.empty_like(p_r); pinv[p_r] = np.arange(n)
qinv = np.empty_like(q); qinv[q] = np.arange(n)
rows = csr.rows()
ri = pinv[rows]                     # permuted row of each nonzero
ci = qinv[csr.col]                  # permuted column of each nonzero
bi, br = ri // nr, ri % nr
bj, bc = ci // seg, ci % seg
RR = np.zeros((Pr, Pc, cap), dtype=np.uint32)
CC = np.zeros((Pr, Pc, cap), dtype=np.uint32)
VV = np.zeros((Pr, Pc, cap), dtype=np.float32)
INFO = np.zeros((Pr, Pc, 4), dtype=np.uint32)
cnt = np.zeros((Pr, Pc), dtype=np.int64)
for k in range(nnz):
    i, j = bi[k], bj[k]
    t = cnt[i, j]
    assert t < cap, f"PE ({i},{j}) holds more than max_nnz_pe = {cap} nonzeros"
    RR[i, j, t], CC[i, j, t], VV[i, j, t] = br[k], bc[k], csr.val[k]
    cnt[i, j] += 1
for i in range(Pr):
    for j in range(Pc):
        xoff = j * seg if (i == 0 and j < H) else ((j - H) * seg if (i == 1 and j >= H) else 0)
        INFO[i, j] = (cnt[i, j], xoff, seg, 0)
print(f"nonzeros per PE: max {cnt.max()}, mean {cnt.mean():.1f}, min {cnt.min()}")

xq = np.zeros(ncols, dtype=np.float32); xq[:n] = x[q]

runner = SdkRuntime(args.name, cmaddr=args.cmaddr)
sym = {k: runner.get_id(k) for k in ("rr", "cc", "vv", "info", "x", "y", "time_buf_u16", "dbg")}
runner.load()
runner.run()
U32 = MemcpyDataType.MEMCPY_32BIT
U16 = MemcpyDataType.MEMCPY_16BIT
RM = MemcpyOrder.ROW_MAJOR


def h2d_mesh(name, arr3d):
    runner.memcpy_h2d(sym[name], np.ascontiguousarray(arr3d).view(np.uint32).ravel(), 0, 0, Pc, Pr, arr3d.shape[2],
                      streaming=False, data_type=U32, order=RM, nonblock=False)


h2d_mesh("rr", RR)
h2d_mesh("cc", CC)
h2d_mesh("vv", VV)
h2d_mesh("info", INFO)
runner.memcpy_h2d(sym["x"], xq.view(np.uint32), 0, 0, 1, 1, ncols, streaming=False, data_type=U32, order=RM,
                  nonblock=False)                                                      # PE (0,0) only

runner.launch("f_enable_timer", nonblock=False)
runner.launch("main", nonblock=False)
runner.launch("f_memcpy_timestamps", nonblock=False)

y_dev = np.zeros(Pr * nr, dtype=np.uint32)
runner.memcpy_d2h(y_dev, sym["y"], 0, 0, 1, Pr, nr, streaming=False, data_type=U32, order=RM, nonblock=False)
tm = np.zeros(Pr * Pc * 6, dtype=np.uint32)
runner.memcpy_d2h(tm, sym["time_buf_u16"], 0, 0, Pc, Pr, 6, streaming=False, data_type=U16, order=RM, nonblock=False)
dbg = np.zeros(Pr * Pc * 12, dtype=np.uint32)
runner.memcpy_d2h(dbg, sym["dbg"], 0, 0, Pc, Pr, 12, streaming=False, data_type=U16, order=RM, nonblock=False)
runner.stop()

t = tm.reshape(Pr, Pc, 6).astype(np.uint16)
to_cycles = lambda w: int(w[0]) | (int(w[1]) << 16) | (int(w[2]) << 32)
starts = np.array([[to_cycles(t[i, j, 0:3]) for j in range(Pc)] for i in range(Pr)], dtype=np.int64)
ends = np.array([[to_cycles(t[i, j, 3:6]) for j in range(Pc)] for i in range(Pr)], dtype=np.int64)
cycles_send = int(ends.max() - starts.min())
print(f"cycles_send = {cycles_send} cycles")
print(f"cycles_per_nnz = {cycles_send / max(nnz, 1):.2f}")
print(f"per-PE windows (cycles): {[int(v) for v in (ends - starts).ravel()]}")

d = dbg.reshape(Pr, Pc, 12).astype(np.uint16)
ms = np.array([[[to_cycles(d[i, j, 3 * s:3 * s + 3]) for s in range(4)] for j in range(Pc)] for i in range(Pr)], dtype=np.int64)
t0 = ms[:, :, 0].min()
for s, name in ((0, "start"), (1, "segment"), (2, "product"), (3, "end")):
    print(f"milestone {name} (cycles after the first start), rows x cols:")
    print((ms[:, :, s] - t0).tolist())
yq = y_dev.view(np.float32)[:n]
y_out = np.empty(n, dtype=np.float32); y_out[p_r] = yq
abs_err = float(np.max(np.abs(y_out - y_ref)))
print(f"[verify] max abs err = {abs_err:.3e}")
np.testing.assert_allclose(y_out, y_ref, rtol=1e-4, atol=1e-5)
print("SUCCESS")
