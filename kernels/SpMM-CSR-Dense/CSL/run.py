#!/usr/bin/env cs_python
# SpMM-CSR-Dense host runner (P x P mesh, device-internal timing).
#
# Loads a real sparse matrix A from the SuiteSparse Matrix Collection (the size's manifest,
# data/manifest[_<structure_id>].json; XKERNEL_EVAL_SEED selects the train matrix or a
# held-out matrix and draws the values), draws a dense B, distributes A's row tiles along
# mesh rows and B's column slices down mesh columns, and verifies C = A @ B against a
# float64 numpy reference. cycles_send = max(end) - min(start) over the mesh.

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
Mt = int(params["Mt"])
K = int(params["K"])
Nt = int(params["Nt"])
max_nnz_pe = int(params["max_nnz_pe"])
iters = int(params["iters"])
structure_id = int(params.get("structure_id", 0))
N = P * Nt
print(f"SpMM-CSR-Dense: P={P}, Mt={Mt}, K={K}, Nt={Nt} (N={N}), max_nnz_pe={max_nnz_pe}, iters={iters}, structure_id={structure_id}")

# --- Load the matrix for this seed ---------------------------------------------------
HERE = os.path.dirname(os.path.abspath(__file__))
SEED = si.resolve_eval_seed(7, where=HERE)   # env var, else the harness's .xkernel_eval_env.json, else train seed
print(f"eval_seed = {SEED}")                # echoed so the held-out gate can prove the seed arrived
manifest = "manifest.json" if structure_id == 0 else f"manifest_{structure_id}.json"
csr, entry = si.load_manifest_matrix(os.path.join(HERE, "data", manifest), SEED)
nnz = csr.nnz
print(f"matrix = {entry.get('id', entry.get('file'))} n={csr.n} m={csr.m} nnz={nnz} (index {entry['index']}, {manifest})")
assert csr.n <= P * Mt, f"matrix has {csr.n} rows > P*Mt = {P * Mt}"
assert csr.m <= K, f"matrix has {csr.m} columns > K = {K}"
partition = {"scheme": "row_tiles", "pes": P, "rows_per_pe": Mt}
si.emit_structure_line(si.features(csr, partition=partition if P > 1 else None,
                                   caps={"Mt": Mt, "max_nnz_pe": max_nnz_pe}))

tiles = si.partition_row_block(csr, P, Mt)                          # one row tile per mesh row
pads = [si.csr_pad(t, Mt, max_nnz_pe) for t in tiles]               # raises if a tile exceeds the caps
print(f"row tiles: nnz per mesh row {[t.nnz for t in tiles]}")

rng = np.random.default_rng([SEED, 1])
B = np.zeros((K, N), dtype=np.float32)
B[: csr.m, :] = rng.uniform(-1.0, 1.0, size=(csr.m, N)).astype(np.float32)

# numpy reference (the invariant): float64 C = A @ B on the real rows
C_ref = csr.matmat(B[: csr.m, :]).astype(np.float32)    # [csr.n, N]

# per-PE host arrays, ROW_MAJOR layout [py][px][l]
row_ptr = np.zeros((P, P, Mt + 1), dtype=np.uint32)
col_idx = np.zeros((P, P, max_nnz_pe), dtype=np.uint32)
val = np.zeros((P, P, max_nnz_pe), dtype=np.float32)
B_tiles = np.zeros((P, P, K * Nt), dtype=np.float32)
for py in range(P):
    for px in range(P):
        row_ptr[py, px] = pads[py]["row_ptr"]
        col_idx[py, px] = pads[py]["col"]
        val[py, px] = pads[py]["val"]
        B_tiles[py, px] = np.ascontiguousarray(B[:, px * Nt:(px + 1) * Nt]).reshape(-1)

# --- Run on device -----------------------------------------------------------------
runner = SdkRuntime(args.name, cmaddr=args.cmaddr)
sym = {name: runner.get_id(name) for name in ("row_ptr", "col_idx", "val", "B_tile", "C_tile", "time_buf_u16")}

runner.load()
runner.run()

U32 = MemcpyDataType.MEMCPY_32BIT
U16 = MemcpyDataType.MEMCPY_16BIT
RM = MemcpyOrder.ROW_MAJOR


def h2d_mesh(name, arr3d, count):
    runner.memcpy_h2d(sym[name], np.ascontiguousarray(arr3d, dtype=np.uint32).ravel(), 0, 0, P, P, count,
                      streaming=False, data_type=U32, order=RM, nonblock=False)


h2d_mesh("row_ptr", row_ptr, Mt + 1)
h2d_mesh("col_idx", col_idx, max_nnz_pe)
h2d_mesh("val", val.view(np.uint32), max_nnz_pe)
h2d_mesh("B_tile", B_tiles.view(np.uint32), K * Nt)

runner.launch("f_enable_timer", nonblock=False)
# f_tic is stamped on-device (device_internal_v2); no host launch.
runner.launch("main", nonblock=False)
# f_toc is stamped on-device (device_internal_v2); no host launch.
runner.launch("f_memcpy_timestamps", nonblock=False)

C_dev = np.zeros((P, P, Mt * Nt), dtype=np.uint32)
runner.memcpy_d2h(C_dev, sym["C_tile"], 0, 0, P, P, Mt * Nt,
                  streaming=False, data_type=U32, order=RM, nonblock=False)
time_memcpy_hwl = np.zeros((P, P, 6), dtype=np.uint32)
runner.memcpy_d2h(time_memcpy_hwl, sym["time_buf_u16"], 0, 0, P, P, 6,
                  streaming=False, data_type=U16, order=RM, nonblock=False)
runner.stop()

# --- Cycle count: max(end) - min(start) over the mesh --------------------------------
time_hwl = time_memcpy_hwl.reshape(P, P, 6).astype(np.uint16)


def to_cycles(t):
    return int(t[0]) | (int(t[1]) << 16) | (int(t[2]) << 32)


starts = np.array([[to_cycles(time_hwl[py, px, 0:3]) for px in range(P)] for py in range(P)], dtype=np.int64)
ends = np.array([[to_cycles(time_hwl[py, px, 3:6]) for px in range(P)] for py in range(P)], dtype=np.int64)
cycles_send = int(ends.max() - starts.min())
print(f"cycles_send = {cycles_send} cycles")
print(f"time_send = {(cycles_send / 0.85) * 1.0e-3:.4f} us")
print(f"cycles_per_nnz = {cycles_send / max(nnz, 1) / iters:.2f}   (x N={N} output columns)")

# --- Verify (the real invariant: C == A @ B on the real rows) ------------------------
C_out = np.zeros((P * Mt, N), dtype=np.float32)
for py in range(P):
    for px in range(P):
        C_out[py * Mt:(py + 1) * Mt, px * Nt:(px + 1) * Nt] = C_dev[py, px].view(np.float32).reshape(Mt, Nt)
C_out = C_out[: csr.n]
abs_err = float(np.max(np.abs(C_out - C_ref)))
scale = float(np.max(np.abs(C_ref))) + 1e-30
print(f"[verify] max abs err = {abs_err:.3e}, rel = {abs_err / scale:.3e}")
np.testing.assert_allclose(C_out, C_ref, rtol=1e-4, atol=1e-5)
print("SUCCESS")
