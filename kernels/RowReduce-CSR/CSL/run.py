#!/usr/bin/env cs_python
# RowReduce-CSR host runner.
#
# Loads a real sparse matrix from the SuiteSparse Matrix Collection (data/manifest.json;
# XKERNEL_EVAL_SEED selects the train matrix or one of the held-out matrices, see
# sparse_inputs.seed_to_index), pads it to the device caps, runs the single-PE kernel
# and verifies against a numpy reference recomputed from the loaded matrix (the real
# invariant; no library answer key). Prints cycles_send over the on-device timed window.

import json
import os
import struct
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
nrows = int(params["nrows"])
max_nnz = int(params["max_nnz"])
iters = int(params["iters"])
print(f"RowReduce-CSR: nrows={nrows}, max_nnz={max_nnz}, iters={iters}")


def float_to_hex(f):
    return hex(struct.unpack("<I", struct.pack("<f", f))[0])


def make_u48(words):
    return words[0] | (words[1] << 16) | (words[2] << 32)


def sub_ts(words):
    return make_u48(words[3:]) - make_u48(words[0:3])


# --- Load the matrix for this seed ---------------------------------------------------
# INPUT-SPLIT: the seed picks a matrix of the class (train seed -> train matrix; held-out
# seeds -> other matrices) and draws the numeric values, so the reference answer is
# recomputed from the loaded matrix every run and a hardcoded output fails held-out.
HERE = os.path.dirname(os.path.abspath(__file__))
SEED = si.resolve_eval_seed(7, where=HERE)   # env var, else the harness's .xkernel_eval_env.json, else train seed
print(f"eval_seed = {SEED}")                # echoed so the held-out gate can prove the seed arrived
csr, entry = si.load_manifest_matrix(os.path.join(HERE, "data", "manifest.json"), SEED)
nnz = csr.nnz
print(f"matrix = {entry.get('id', entry.get('file'))} n={csr.n} m={csr.m} nnz={nnz} (index {entry['index']})")
assert csr.n <= nrows and csr.nnz <= max_nnz, f"matrix exceeds device caps nrows={nrows} max_nnz={max_nnz}"
si.emit_structure_line(si.features(csr, caps={"nrows": nrows, "max_nnz": max_nnz}))

pad = si.csr_pad(csr, nrows, max_nnz)
row_ptr = pad["row_ptr"]                       # u32 [nrows+1]
col_idx = pad["col"]                           # u32 [max_nnz]
val = pad["val"]                               # f32 [max_nnz]
d = np.random.default_rng([SEED, 1]).uniform(0.5, 2.0, size=nrows).astype(np.float32)

# numpy reference (the invariant)
rows = csr.rows()
y_ref = np.bincount(rows, weights=val[:nnz].astype(np.float64), minlength=nrows).astype(np.float32)   # float64 row sums
total_ref = np.float32(np.sum(val[:nnz].astype(np.float64)))

# --- Run on device -----------------------------------------------------------------
runner = SdkRuntime(args.name, cmaddr=args.cmaddr)
sym = {name: runner.get_id(name) for name in ['row_ptr', 'val', 'y', 'total']}
sym_time = runner.get_id("maxmin_time")

runner.load()
runner.run()

U32 = MemcpyDataType.MEMCPY_32BIT
RM = MemcpyOrder.ROW_MAJOR


def h2d(name, arr, n):
    runner.memcpy_h2d(sym[name], np.ascontiguousarray(arr, dtype=np.uint32), 0, 0, 1, 1, n, streaming=False,
                      data_type=U32, order=RM, nonblock=False)


def d2h(name, n):
    out = np.zeros((n,), dtype=np.uint32)
    runner.memcpy_d2h(out, sym[name], 0, 0, 1, 1, n, streaming=False,
                      data_type=U32, order=RM, nonblock=False)
    return out


h2d("row_ptr", row_ptr, nrows + 1)
h2d("val", val.view(np.uint32), max_nnz)

runner.call("compute", [], nonblock=False)

# timestamps (3 u32 per PE)
tdata = np.zeros((3,), dtype=np.uint32)
runner.memcpy_d2h(tdata, sym_time, 0, 0, 1, 1, 3, streaming=False,
                  data_type=U32, order=RM, nonblock=False)

dev = {}
dev["y"] = d2h("y", nrows)
dev["total"] = d2h("total", 1)
runner.stop()

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
print(f"cycles_per_nnz = {cycles / max(nnz, 1) / iters:.2f}")

# --- Verify (the real invariant) -----------------------------------------------------
y_out = dev["y"].view(np.float32)
total_out = dev["total"].view(np.float32)[0]
abs_err = float(np.max(np.abs(y_out - y_ref)))
print(f"[verify] row sums max abs err = {abs_err:.3e}; total dev {total_out:.6f} ref {total_ref:.6f}")
np.testing.assert_allclose(y_out, y_ref, rtol=1e-4, atol=1e-5)
np.testing.assert_allclose(total_out, total_ref, rtol=1e-4, atol=1e-5)
print("SUCCESS")
