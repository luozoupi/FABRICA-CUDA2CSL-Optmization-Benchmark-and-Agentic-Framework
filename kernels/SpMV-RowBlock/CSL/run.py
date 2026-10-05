#!/usr/bin/env cs_python
# SpMV-RowBlock host runner (1 x P strip, device-internal timing).
#
# Loads a real sparse matrix from the SuiteSparse Matrix Collection (the size's manifest,
# data/manifest[_<structure_id>].json; XKERNEL_EVAL_SEED selects the train matrix or a
# held-out matrix and draws the values), splits the rows into P consecutive blocks padded
# to the device caps, writes x to PE 0 only (the kernel broadcasts it), and verifies
# y = A @ x against a float64 numpy reference. cycles_send = max(end) - min(start) over
# the strip's device-internal timestamps.

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
nrows_pe = int(params["nrows_pe"])
ncols = int(params["ncols"])
max_nnz_pe = int(params["max_nnz_pe"])
iters = int(params["iters"])
structure_id = int(params.get("structure_id", 0))
print(f"SpMV-RowBlock: P={P}, nrows_pe={nrows_pe}, ncols={ncols}, max_nnz_pe={max_nnz_pe}, iters={iters}, structure_id={structure_id}")

# --- Load the matrix for this seed ---------------------------------------------------
HERE = os.path.dirname(os.path.abspath(__file__))
SEED = si.resolve_eval_seed(7, where=HERE)   # env var, else the harness's .xkernel_eval_env.json, else train seed
print(f"eval_seed = {SEED}")                # echoed so the held-out gate can prove the seed arrived
manifest = "manifest.json" if structure_id == 0 else f"manifest_{structure_id}.json"
csr, entry = si.load_manifest_matrix(os.path.join(HERE, "data", manifest), SEED)
nnz = csr.nnz
print(f"matrix = {entry.get('id', entry.get('file'))} n={csr.n} m={csr.m} nnz={nnz} (index {entry['index']}, {manifest})")
assert csr.n <= P * nrows_pe, f"matrix has {csr.n} rows > P*nrows_pe = {P * nrows_pe}"
assert csr.m <= ncols, f"matrix has {csr.m} columns > ncols = {ncols}"
# Optional wafer-level mapping hook (2026-09-30): a row_order.py next to run.py returns a permutation
# of the rows; the host reorders A's rows before the equal-block split over the PEs and un-permutes y
# before verification. Without the file the mapping is the identity and nothing changes.
perm = None
csr_dev = csr
if os.path.exists(os.path.join(HERE, "row_order.py")):
    sys.path.insert(0, HERE)
    import row_order as _row_order
    perm = np.asarray(_row_order.row_order(csr.row_lengths().tolist(), P, nrows_pe), dtype=np.int64)
    assert perm.shape == (csr.n,) and np.array_equal(np.sort(perm), np.arange(csr.n)), \
        "row_order.row_order(row_nnz, P, nrows_pe) must return a permutation of range(n)"
    _lens = np.diff(csr.row_ptr)[perm]
    _idx = (np.concatenate([np.arange(csr.row_ptr[i], csr.row_ptr[i + 1]) for i in perm])
            if nnz else np.zeros(0, dtype=np.int64))
    csr_dev = si.CSR(csr.n, csr.m, np.concatenate([[0], np.cumsum(_lens)]), csr.col[_idx], csr.val[_idx])
    print("row_order = permutation from row_order.py")
partition = {"scheme": "row_block", "pes": P, "rows_per_pe": nrows_pe}
si.emit_structure_line(si.features(csr_dev, partition=partition if P > 1 else None,
                                   caps={"nrows_pe": nrows_pe, "max_nnz_pe": max_nnz_pe}))

parts = si.partition_row_block(csr_dev, P, nrows_pe)
pads = [si.csr_pad(p, nrows_pe, max_nnz_pe) for p in parts]        # raises if a block exceeds the caps
row_ptr = np.stack([q["row_ptr"] for q in pads])                   # (P, nrows_pe+1) u32
col_idx = np.stack([q["col"] for q in pads])                       # (P, max_nnz_pe)  u32
val = np.stack([q["val"] for q in pads])                           # (P, max_nnz_pe)  f32
print(f"row blocks: nnz per PE {[p.nnz for p in parts]}")

x = np.zeros(ncols, dtype=np.float32)
x[: csr.m] = np.random.default_rng([SEED, 1]).uniform(-1.0, 1.0, size=csr.m).astype(np.float32)

# numpy reference (the invariant): float64 y = A @ x
y_ref_full = csr.matvec(x[: csr.m].astype(np.float64)).astype(np.float32)   # [csr.n]

# --- Run on device -----------------------------------------------------------------
runner = SdkRuntime(args.name, cmaddr=args.cmaddr)
sym = {name: runner.get_id(name) for name in ("row_ptr", "col_idx", "val", "x", "y", "time_buf_u16")}

runner.load()
runner.run()

U32 = MemcpyDataType.MEMCPY_32BIT
U16 = MemcpyDataType.MEMCPY_16BIT
RM = MemcpyOrder.ROW_MAJOR


def h2d_strip(name, arr2d, count):
    # ROW_MAJOR layout of a (h=1, w=P, l=count) region: PE-major, count contiguous per PE
    runner.memcpy_h2d(sym[name], np.ascontiguousarray(arr2d, dtype=np.uint32).ravel(), 0, 0, P, 1, count,
                      streaming=False, data_type=U32, order=RM, nonblock=False)


h2d_strip("row_ptr", row_ptr, nrows_pe + 1)
h2d_strip("col_idx", col_idx, max_nnz_pe)
h2d_strip("val", val.view(np.uint32), max_nnz_pe)
runner.memcpy_h2d(sym["x"], x.view(np.uint32), 0, 0, 1, 1, ncols,               # PE 0 only
                  streaming=False, data_type=U32, order=RM, nonblock=False)

runner.launch("f_enable_timer", nonblock=False)
# f_tic is stamped on-device (device_internal_v2); no host launch.
runner.launch("main", nonblock=False)
# f_toc is stamped on-device (device_internal_v2); no host launch.
runner.launch("f_memcpy_timestamps", nonblock=False)

y_dev = np.zeros((1, P, nrows_pe), dtype=np.uint32)
runner.memcpy_d2h(y_dev, sym["y"], 0, 0, P, 1, nrows_pe,
                  streaming=False, data_type=U32, order=RM, nonblock=False)

time_memcpy_hwl = np.zeros((1, P, 6), dtype=np.uint32)
runner.memcpy_d2h(time_memcpy_hwl, sym["time_buf_u16"], 0, 0, P, 1, 6,
                  streaming=False, data_type=U16, order=RM, nonblock=False)
runner.stop()

# --- Cycle count: max(end) - min(start) over the strip -------------------------------
time_hwl = time_memcpy_hwl.reshape(1, P, 6).astype(np.uint16)


def to_cycles(t):
    return int(t[0]) | (int(t[1]) << 16) | (int(t[2]) << 32)


starts = np.array([to_cycles(time_hwl[0, c, 0:3]) for c in range(P)], dtype=np.int64)
ends = np.array([to_cycles(time_hwl[0, c, 3:6]) for c in range(P)], dtype=np.int64)
cycles_send = int(ends.max() - starts.min())
print(f"cycles_send = {cycles_send} cycles")
print(f"time_send = {(cycles_send / 0.85) * 1.0e-3:.4f} us")
print(f"cycles_per_nnz = {cycles_send / max(nnz, 1) / iters:.2f}")
print(f"per-PE windows (cycles): {[int(e - s) for s, e in zip(starts, ends)]}")

# --- Verify (the real invariant: y == A @ x on the real rows) ------------------------
y_out = y_dev.reshape(P, nrows_pe).view(np.float32).reshape(-1)[: csr.n]
if perm is not None:                       # device rows are in permuted order
    _y = np.empty_like(y_out); _y[perm] = y_out; y_out = _y
abs_err = float(np.max(np.abs(y_out - y_ref_full)))
scale = float(np.max(np.abs(y_ref_full))) + 1e-30
print(f"[verify] max abs err = {abs_err:.3e}, rel = {abs_err / scale:.3e}")
np.testing.assert_allclose(y_out, y_ref_full, rtol=1e-4, atol=1e-5)
print("SUCCESS")
