#!/usr/bin/env cs_python
# SpMV-RowBlock with distributed x and a halo exchange (expert headroom variant, harness-invisible).
# Same matrices, seeds, values, x and verification as kernels/SpMV-RowBlock/CSL/run.py; differences:
# the host orders the matrix with reverse Cuthill-McKee (rcm=1; a symmetric permutation, applied to
# rows and columns), writes each PE its own x block (mode 0) or its whole x window (mode 1, the
# zero-communication bound), and rewrites column indices relative to the PE's window.

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
P = int(params["P"])
nr = int(params["nrows_pe"])
halo = int(params["halo"])
max_nnz_pe = int(params["max_nnz_pe"])
mode = int(params["mode"])
iters = int(params["iters"])
structure_id = int(params.get("structure_id", 0))
rcm = int(params.get("rcm", 1))
W = (2 * halo + 1) * nr
print(f"SpMV-RowBlock-Halo: P={P}, nrows_pe={nr}, halo={halo}, mode={mode}, rcm={rcm}, max_nnz_pe={max_nnz_pe}")

HERE = os.path.dirname(os.path.abspath(__file__))
SEED = si.resolve_eval_seed(7, where=HERE)
print(f"eval_seed = {SEED}")
manifest = "manifest.json" if structure_id == 0 else f"manifest_{structure_id}.json"
csr, entry = si.load_manifest_matrix(os.path.join(HERE, "data", manifest), SEED)
n, m, nnz = csr.n, csr.m, csr.nnz
print(f"matrix = {entry.get('id', entry.get('file'))} n={n} m={m} nnz={nnz}")
assert n == m, "the halo variant needs a square matrix (x and y share the row partition)"
assert n <= P * nr

x = np.zeros(max(n, 1), dtype=np.float32)
x[:m] = np.random.default_rng([SEED, 1]).uniform(-1.0, 1.0, size=m).astype(np.float32)   # same x as the task
y_ref = csr.matvec(x[:m].astype(np.float64)).astype(np.float32)

# --- Symmetric reordering (host-side preprocessing, outside the timed window) -------------------
if rcm:
    # precomputed outside the container (scipy reverse_cuthill_mckee, symmetric_mode) by make_rcm.py
    with open(os.path.join(HERE, "rcm_perm.json"), encoding="utf-8") as fh:
        q = np.asarray(json.load(fh)[str(entry.get("id", entry.get("file")))], dtype=np.int64)
    assert q.shape == (n,) and np.array_equal(np.sort(q), np.arange(n))
else:
    q = np.arange(n, dtype=np.int64)
qinv = np.empty_like(q); qinv[q] = np.arange(n)
# A' = A[q][:, q]: row i' = original row q[i'], column c -> qinv[c]
rp = np.zeros(n + 1, dtype=np.int64); cols = []; vals = []
for i2, i in enumerate(q):
    a, b = csr.row_ptr[i], csr.row_ptr[i + 1]
    c2 = qinv[csr.col[a:b]]
    order = np.argsort(c2, kind="stable")
    cols.append(c2[order]); vals.append(csr.val[a:b][order]); rp[i2 + 1] = rp[i2] + (b - a)
cols = np.concatenate(cols) if nnz else np.zeros(0, dtype=np.int64)
vals = np.concatenate(vals) if nnz else np.zeros(0, dtype=np.float32)
xq = np.zeros(P * nr, dtype=np.float32); xq[:n] = x[q]

# --- Row blocks, window-relative columns ---------------------------------------------------------
row_ptr = np.zeros((P, nr + 1), dtype=np.uint32)
col_idx = np.zeros((P, max_nnz_pe), dtype=np.uint32)
val = np.zeros((P, max_nnz_pe), dtype=np.float32)
need = 0
nnz_pe = []
for p in range(P):
    r0, r1 = p * nr, min((p + 1) * nr, n)
    if r0 >= n:
        nnz_pe.append(0); continue
    a, b = rp[r0], rp[r1]
    k = b - a
    assert k <= max_nnz_pe, f"PE {p} holds {k} nonzeros > max_nnz_pe {max_nnz_pe}"
    c = cols[a:b]
    if k:
        need = max(need, p - int(c.min()) // nr, int(c.max()) // nr - p)
    rel = c - (p - halo) * nr
    assert k == 0 or (rel.min() >= 0 and rel.max() < W), f"PE {p}: columns outside the halo window (halo {halo} too small)"
    row_ptr[p, : r1 - r0 + 1] = rp[r0:r1 + 1] - a
    row_ptr[p, r1 - r0 + 1:] = k
    col_idx[p, :k] = rel
    val[p, :k] = vals[a:b]
    nnz_pe.append(int(k))
print(f"halo PEs needed = {need} (param {halo})")
print(f"row blocks: nnz per PE {nnz_pe}")

x_own = xq.reshape(P, nr)
x_win = np.zeros((P, W), dtype=np.float32)
for p in range(P):
    for s in range(2 * halo + 1):
        src = p - halo + s
        if 0 <= src < P:
            x_win[p, s * nr:(s + 1) * nr] = x_own[src]

# --- Run on device ---------------------------------------------------------------------------------
runner = SdkRuntime(args.name, cmaddr=args.cmaddr)
sym = {name: runner.get_id(name) for name in ("row_ptr", "col_idx", "val", "x_win", "x_own", "y", "time_buf_u16")}
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
if mode == 1:
    h2d_strip("x_win", x_win, W)          # zero-communication bound: the window is already in place
else:
    h2d_strip("x_own", x_own, nr)         # each PE owns its block, as the previous iteration's y would

runner.launch("f_enable_timer", nonblock=False)
runner.launch("main", nonblock=False)
runner.launch("f_memcpy_timestamps", nonblock=False)

y_dev = np.zeros((1, P, nr), dtype=np.uint32)
runner.memcpy_d2h(y_dev, sym["y"], 0, 0, P, 1, nr, streaming=False, data_type=U32, order=RM, nonblock=False)
time_memcpy_hwl = np.zeros((1, P, 6), dtype=np.uint32)
runner.memcpy_d2h(time_memcpy_hwl, sym["time_buf_u16"], 0, 0, P, 1, 6, streaming=False, data_type=U16, order=RM, nonblock=False)
runner.stop()

time_hwl = time_memcpy_hwl.reshape(1, P, 6).astype(np.uint16)


def to_cycles(t):
    return int(t[0]) | (int(t[1]) << 16) | (int(t[2]) << 32)


starts = np.array([to_cycles(time_hwl[0, c, 0:3]) for c in range(P)], dtype=np.int64)
ends = np.array([to_cycles(time_hwl[0, c, 3:6]) for c in range(P)], dtype=np.int64)
cycles_send = int(ends.max() - starts.min())
print(f"cycles_send = {cycles_send} cycles")
print(f"cycles_per_nnz = {cycles_send / max(nnz, 1) / iters:.2f}")
print(f"per-PE windows (cycles): {[int(e - s) for s, e in zip(starts, ends)]}")

yq = y_dev.reshape(P, nr).view(np.float32).reshape(-1)[:n]
y_out = np.empty(n, dtype=np.float32); y_out[q] = yq        # back to the original order
abs_err = float(np.max(np.abs(y_out - y_ref)))
print(f"[verify] max abs err = {abs_err:.3e}")
np.testing.assert_allclose(y_out, y_ref, rtol=1e-4, atol=1e-5)
print("SUCCESS")
