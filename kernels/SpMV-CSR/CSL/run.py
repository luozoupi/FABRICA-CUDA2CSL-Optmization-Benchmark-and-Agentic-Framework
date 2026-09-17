#!/usr/bin/env cs_python
# SpMV-CSR (hand-written-compute variant) host runner.
#
# Builds a random sparse matrix in CSR, runs the single-PE CSL SpMV (y = A*x), and
# verifies y against the numpy reference y = A@x (the real invariant — no library
# answer key). Prints cycles_send over the on-device timed window so the kernel is
# speed-scoreable. Input is seeded from XKERNEL_EVAL_SEED so the harness can score
# correctness on HELD-OUT seeds (anti-hardcoding; see docs/SPLIT_AND_LEAKAGE.md).

import json
import os
import struct
import numpy as np

from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType  # pylint: disable=no-name-in-module
from cerebras.sdk.runtime.sdkruntimepybind import MemcpyOrder  # pylint: disable=no-name-in-module

import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--name", help="the test output dir")
parser.add_argument("--cmaddr", help="IP:port for CS system")
args = parser.parse_args()

with open(f"{args.name}/out.json", encoding="utf-8") as f:
    params = json.load(f)["params"]
nrows = int(params["nrows"])
ncols = int(params["ncols"])
max_nnz = int(params["max_nnz"])
iters = int(params["iters"])
print(f"SpMV-CSR: nrows={nrows}, ncols={ncols}, max_nnz={max_nnz}, iters={iters}")


def float_to_hex(f):
    return hex(struct.unpack("<I", struct.pack("<f", f))[0])


def make_u48(words):
    return words[0] | (words[1] << 16) | (words[2] << 32)


def sub_ts(words):
    return make_u48(words[3:]) - make_u48(words[0:3])


# --- Build a random sparse matrix in CSR -------------------------------------------
# INPUT-SPLIT: seed from XKERNEL_EVAL_SEED (default 7). The reference y=A@x is
# recomputed from the drawn matrix every run, so a hardcoded output fails held-out seeds.
SEED = int(os.environ.get("XKERNEL_EVAL_SEED", "7"))
rng = np.random.default_rng(SEED)

# ~density nonzeros per row, capped so total nnz <= max_nnz.
density = 0.25
A = rng.random((nrows, ncols)).astype(np.float32)
mask = rng.random((nrows, ncols)) < density
A = A * mask
# enforce the nnz capacity (trim extra nonzeros deterministically if needed)
nnz_total = int(np.count_nonzero(A))
if nnz_total > max_nnz:
    # keep the first max_nnz nonzeros in row-major order, zero the rest
    flat = A.reshape(-1)
    nz_positions = np.flatnonzero(flat)
    drop = nz_positions[max_nnz:]
    flat[drop] = 0.0
    A = flat.reshape(nrows, ncols)
    nnz_total = int(np.count_nonzero(A))
print(f"generated sparse A: {nnz_total} nonzeros (cap {max_nnz})")

x = rng.random(ncols).astype(np.float32)

# CSR encode
row_ptr = np.zeros(nrows + 1, dtype=np.uint32)
col_idx = np.zeros(max_nnz, dtype=np.uint32)
val = np.zeros(max_nnz, dtype=np.float32)
k = 0
for r in range(nrows):
    row_ptr[r] = k
    cols = np.flatnonzero(A[r])
    for c in cols:
        col_idx[k] = c
        val[k] = A[r, c]
        k += 1
row_ptr[nrows] = k

# numpy reference (the invariant)
y_ref = (A @ x).astype(np.float32)

# --- Run on device -----------------------------------------------------------------
runner = SdkRuntime(args.name, cmaddr=args.cmaddr)
sym_row_ptr = runner.get_id("row_ptr")
sym_col_idx = runner.get_id("col_idx")
sym_val = runner.get_id("val")
sym_x = runner.get_id("x")
sym_y = runner.get_id("y")
sym_time = runner.get_id("maxmin_time")

runner.load()
runner.run()

U32 = MemcpyDataType.MEMCPY_32BIT
RM = MemcpyOrder.ROW_MAJOR


def h2d(sym, arr, n):
    runner.memcpy_h2d(sym, arr, 0, 0, 1, 1, n, streaming=False,
                      data_type=U32, order=RM, nonblock=False)


h2d(sym_row_ptr, row_ptr, nrows + 1)
h2d(sym_col_idx, col_idx, max_nnz)
h2d(sym_val, val.view(np.uint32), max_nnz)
h2d(sym_x, x.view(np.uint32), ncols)

runner.call("compute", [], nonblock=False)

# timestamps (3 u32 per PE)
tdata = np.zeros((3,), dtype=np.uint32)
runner.memcpy_d2h(tdata, sym_time, 0, 0, 1, 1, 3, streaming=False,
                  data_type=U32, order=RM, nonblock=False)

y_dev = np.zeros((nrows,), dtype=np.uint32)
runner.memcpy_d2h(y_dev, sym_y, 0, 0, 1, 1, nrows, streaming=False,
                  data_type=U32, order=RM, nonblock=False)
runner.stop()

y_out = y_dev.view(np.float32)

# --- Cycle count -------------------------------------------------------------------
maxmin = tdata.view(np.float32)
tsc = np.zeros(6, dtype=np.uint16)
h0 = int(float_to_hex(maxmin[0]), 16)
h1 = int(float_to_hex(maxmin[1]), 16)
h2 = int(float_to_hex(maxmin[2]), 16)
tsc[0] = h0 & 0xFFFF
tsc[1] = (h0 >> 16) & 0xFFFF
tsc[2] = h1 & 0xFFFF
tsc[3] = (h1 >> 16) & 0xFFFF
tsc[4] = h2 & 0xFFFF
tsc[5] = (h2 >> 16) & 0xFFFF
cycles = int(sub_ts([int(v) for v in tsc]))
print(f"cycles_send = {cycles} cycles")
print(f"time_send = {(cycles / 0.85) * 1.0e-3:.4f} us")

# --- Verify (the real invariant: y == A@x) -----------------------------------------
abs_err = float(np.max(np.abs(y_out - y_ref)))
scale = float(np.max(np.abs(y_ref))) + 1e-30
print(f"[verify] max abs err = {abs_err:.3e}, rel = {abs_err/scale:.3e}")
np.testing.assert_allclose(y_out, y_ref, rtol=1e-5, atol=1e-5)
print("SUCCESS")
