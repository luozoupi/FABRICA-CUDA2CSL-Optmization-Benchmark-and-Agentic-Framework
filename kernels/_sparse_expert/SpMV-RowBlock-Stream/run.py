#!/usr/bin/env cs_python
# SpMV-RowBlock-Stream host runner (expert headroom variant: compute while x arrives).
#
# Same matrices, seeds, x, verification and timing as the reference runner (run.py of SpMV-RowBlock).
# Host-side preprocessing, outside the timed window: optional reverse Cuthill-McKee order (rcm=1, a
# symmetric permutation, as in the halo variant), the rows of each PE block ordered by the largest
# column they read (row_need) with row_id mapping each slot back to its local row, and x filled with a
# NaN sentinel on PEs 1..P-1 (PE 0 gets the real x and broadcasts it, as in the reference).

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
P = int(params["P"]); nr = int(params["nrows_pe"]); ncols = int(params["ncols"])
max_nnz_pe = int(params["max_nnz_pe"]); iters = int(params["iters"])
structure_id = int(params.get("structure_id", 0)); rcm = int(params.get("rcm", 0))
print(f"SpMV-RowBlock-Stream: P={P}, nrows_pe={nr}, ncols={ncols}, max_nnz_pe={max_nnz_pe}, rcm={rcm}")

HERE = os.path.dirname(os.path.abspath(__file__))
SEED = si.resolve_eval_seed(7, where=HERE)
print(f"eval_seed = {SEED}")
manifest = "manifest.json" if structure_id == 0 else f"manifest_{structure_id}.json"
csr, entry = si.load_manifest_matrix(os.path.join(HERE, "data", manifest), SEED)
n, m, nnz = csr.n, csr.m, csr.nnz
print(f"matrix = {entry.get('id', entry.get('file'))} n={n} m={m} nnz={nnz}")
assert n == m and n <= P * nr and m <= ncols

x = np.zeros(ncols, dtype=np.float32)
x[:m] = np.random.default_rng([SEED, 1]).uniform(-1.0, 1.0, size=m).astype(np.float32)   # same x as the task
y_ref = csr.matvec(x[:m].astype(np.float64)).astype(np.float32)

# --- optional symmetric reordering (host-side preprocessing, outside the timed window) ------------
if rcm:
    with open(os.path.join(HERE, "rcm_perm.json"), encoding="utf-8") as fh:
        q = np.asarray(json.load(fh)[str(entry.get("id", entry.get("file")))], dtype=np.int64)
    assert q.shape == (n,) and np.array_equal(np.sort(q), np.arange(n))
else:
    q = np.arange(n, dtype=np.int64)
qinv = np.empty_like(q); qinv[q] = np.arange(n)
rows_cols, rows_vals = [], []
for i in q:                                    # row i' = original row q[i'], column c -> qinv[c]
    a, b = csr.row_ptr[i], csr.row_ptr[i + 1]
    rows_cols.append(qinv[csr.col[a:b]]); rows_vals.append(csr.val[a:b])
xq = np.zeros(ncols, dtype=np.float32); xq[:n] = x[q]

# --- row blocks, rows of each block ordered by the largest column they read ----------------------
row_ptr = np.zeros((P, nr + 1), dtype=np.uint32)
col_idx = np.zeros((P, max_nnz_pe), dtype=np.uint32)
val = np.zeros((P, max_nnz_pe), dtype=np.float32)
row_id = np.zeros((P, nr), dtype=np.uint32)
row_need = np.zeros((P, nr), dtype=np.uint32)
nnz_pe = []
for p in range(P):
    rows = list(range(p * nr, min((p + 1) * nr, n)))
    need = [int(rows_cols[i].max()) if len(rows_cols[i]) else 0 for i in rows]
    order = sorted(range(len(rows)), key=lambda k: need[k])
    k = 0
    for slot, li in enumerate(order):
        i = rows[li]
        c, v = rows_cols[i], rows_vals[i]
        row_ptr[p, slot] = k
        col_idx[p, k:k + len(c)] = c; val[p, k:k + len(c)] = v
        row_id[p, slot] = li; row_need[p, slot] = need[li]
        k += len(c)
    assert k <= max_nnz_pe, f"PE {p} holds {k} nonzeros > max_nnz_pe {max_nnz_pe}"
    row_ptr[p, len(rows):] = k
    for slot in range(len(rows), nr):          # padding rows: empty, write their own slot, wait for x[0]
        row_id[p, slot] = slot
    nnz_pe.append(k)
print(f"row blocks: nnz per PE {nnz_pe}")

SENT = np.uint32(0x7FC0DEAD)
x_all = np.full((P, ncols), SENT, dtype=np.uint32)
x_all[0] = xq.view(np.uint32)

runner = SdkRuntime(args.name, cmaddr=args.cmaddr)
sym = {k: runner.get_id(k) for k in ("row_ptr", "col_idx", "val", "x", "y", "row_id", "row_need", "time_buf_u16")}
runner.load()
runner.run()
U32 = MemcpyDataType.MEMCPY_32BIT
U16 = MemcpyDataType.MEMCPY_16BIT
RM = MemcpyOrder.ROW_MAJOR


def h2d_strip(name, arr2d, count):
    runner.memcpy_h2d(sym[name], np.ascontiguousarray(arr2d).view(np.uint32).ravel(), 0, 0, P, 1, count,
                      streaming=False, data_type=U32, order=RM, nonblock=False)


h2d_strip("row_ptr", row_ptr, nr + 1)
h2d_strip("col_idx", col_idx, max_nnz_pe)
h2d_strip("val", val, max_nnz_pe)
h2d_strip("row_id", row_id, nr)
h2d_strip("row_need", row_need, nr)
h2d_strip("x", x_all, ncols)

runner.launch("f_enable_timer", nonblock=False)
runner.launch("main", nonblock=False)
runner.launch("f_memcpy_timestamps", nonblock=False)

y_dev = np.zeros((1, P, nr), dtype=np.uint32)
runner.memcpy_d2h(y_dev, sym["y"], 0, 0, P, 1, nr, streaming=False, data_type=U32, order=RM, nonblock=False)
time_memcpy_hwl = np.zeros((1, P, 6), dtype=np.uint32)
runner.memcpy_d2h(time_memcpy_hwl, sym["time_buf_u16"], 0, 0, P, 1, 6, streaming=False, data_type=U16, order=RM,
                  nonblock=False)
runner.stop()

time_hwl = time_memcpy_hwl.reshape(1, P, 6).astype(np.uint16)
to_cycles = lambda t: int(t[0]) | (int(t[1]) << 16) | (int(t[2]) << 32)
starts = np.array([to_cycles(time_hwl[0, c, 0:3]) for c in range(P)], dtype=np.int64)
ends = np.array([to_cycles(time_hwl[0, c, 3:6]) for c in range(P)], dtype=np.int64)
cycles_send = int(ends.max() - starts.min())
print(f"cycles_send = {cycles_send} cycles")
print(f"cycles_per_nnz = {cycles_send / max(nnz, 1) / iters:.2f}")
print(f"per-PE windows (cycles): {[int(e - s) for s, e in zip(starts, ends)]}")

yq = y_dev.reshape(P, nr).view(np.float32).reshape(-1)[:n]
y_out = np.empty(n, dtype=np.float32); y_out[q] = yq
abs_err = float(np.max(np.abs(y_out - y_ref)))
print(f"[verify] max abs err = {abs_err:.3e}")
np.testing.assert_allclose(y_out, y_ref, rtol=1e-4, atol=1e-5)
print("SUCCESS")
