#!/usr/bin/env cs_python
# SpGEMM-Masked-Dot host runner.
#
# Loads a real sparse matrix A from the SuiteSparse Matrix Collection (data/manifest.json;
# XKERNEL_EVAL_SEED selects the train matrix or a held-out matrix and draws the values),
# stores it by column (CSC), and asks the single-PE kernel for C<M> = A'A at every stored
# position of A (M = pattern of A). Verifies values, row codes (incl. zombies) and the
# zombie count against a numpy reference recomputed from the loaded matrix.

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
n = int(params["n"])
max_nnz = int(params["max_nnz"])
iters = int(params["iters"])
print(f"SpGEMM-Masked-Dot: n={n}, max_nnz={max_nnz}, iters={iters}")


def float_to_hex(f):
    return hex(struct.unpack("<I", struct.pack("<f", f))[0])


def make_u48(words):
    return words[0] | (words[1] << 16) | (words[2] << 32)


def sub_ts(words):
    return make_u48(words[3:]) - make_u48(words[0:3])


# --- Load the matrix for this seed ---------------------------------------------------
HERE = os.path.dirname(os.path.abspath(__file__))
SEED = si.resolve_eval_seed(7, where=HERE)   # env var, else the harness's .xkernel_eval_env.json, else train seed
print(f"eval_seed = {SEED}")                # echoed so the held-out gate can prove the seed arrived
structure_id = int(params.get("structure_id", 0))
manifest = "manifest.json" if structure_id == 0 else f"manifest_{structure_id}.json"
csr, entry = si.load_manifest_matrix(os.path.join(HERE, "data", manifest), SEED)
nnz = csr.nnz
print(f"matrix = {entry.get('id', entry.get('file'))} n={csr.n} m={csr.m} nnz={nnz} (index {entry['index']})")
assert csr.n == csr.m, "square matrices only"
assert csr.n <= n and csr.nnz <= max_nnz, f"matrix exceeds device caps n={n} max_nnz={max_nnz}"
si.emit_structure_line(si.features(csr, caps={"n": n, "max_nnz": max_nnz}))

csc = si.csc_pad(csr, n, max_nnz)            # column pointers, sorted row indices, values (padded)
col_ptr = csc["col_ptr"]                     # u32 [n+1]
row_idx = csc["row"]                         # u32 [max_nnz]
val = csc["val"]                             # f32 [max_nnz]

# numpy reference (the invariant): C(i,j) = A(:,i).A(:,j) at each stored position; zombie when the
# two columns share no row.
cols = np.repeat(np.arange(csr.n), np.diff(col_ptr[: csr.n + 1].astype(np.int64)))
rows = row_idx[:nnz].astype(np.int64)
c_ref, exists = csr.masked_gram(rows, cols)
c_ref = c_ref.astype(np.float32)
c_ref[~exists] = 0.0
c_row_ref = np.where(exists, rows, (~rows) & 0xFFFFFFFF).astype(np.uint32)
nzombies_ref = int((~exists).sum())
print(f"reference: {nnz} mask entries, {nzombies_ref} zombies, mean nonzero product {float(np.abs(c_ref[exists]).mean()) if exists.any() else 0.0:.4f}")

# --- Run on device -----------------------------------------------------------------
runner = SdkRuntime(args.name, cmaddr=args.cmaddr)
names = ["col_ptr", "row_idx", "val", "c_val", "c_row", "nzombies"]
sym = {name: runner.get_id(name) for name in names}
sym_time = runner.get_id("maxmin_time")

runner.load()
runner.run()

U32 = MemcpyDataType.MEMCPY_32BIT
RM = MemcpyOrder.ROW_MAJOR


def h2d(name, arr, count):
    runner.memcpy_h2d(sym[name], np.ascontiguousarray(arr, dtype=np.uint32), 0, 0, 1, 1, count, streaming=False,
                      data_type=U32, order=RM, nonblock=False)


def d2h(name, count):
    out = np.zeros((count,), dtype=np.uint32)
    runner.memcpy_d2h(out, sym[name], 0, 0, 1, 1, count, streaming=False,
                      data_type=U32, order=RM, nonblock=False)
    return out


h2d("col_ptr", col_ptr, n + 1)
h2d("row_idx", row_idx, max_nnz)
h2d("val", val.view(np.uint32), max_nnz)

runner.call("compute", [], nonblock=False)

tdata = np.zeros((3,), dtype=np.uint32)
runner.memcpy_d2h(tdata, sym_time, 0, 0, 1, 1, 3, streaming=False,
                  data_type=U32, order=RM, nonblock=False)
dev = {"c_val": d2h("c_val", max_nnz), "c_row": d2h("c_row", max_nnz), "nzombies": d2h("nzombies", 1)}
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
c_out = dev["c_val"].view(np.float32)[:nnz]
c_row_out = dev["c_row"][:nnz]
nz_out = int(dev["nzombies"][0])
abs_err = float(np.max(np.abs(c_out - c_ref))) if nnz else 0.0
print(f"[verify] max abs err = {abs_err:.3e}; zombies dev {nz_out} ref {nzombies_ref}")
np.testing.assert_allclose(c_out, c_ref, rtol=1e-5, atol=1e-6)
np.testing.assert_array_equal(c_row_out, c_row_ref)
assert nz_out == nzombies_ref, f"zombie count {nz_out} != {nzombies_ref}"
print("SUCCESS")
