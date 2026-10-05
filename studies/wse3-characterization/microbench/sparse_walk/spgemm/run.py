#!/usr/bin/env cs_python
# SpGEMM-Masked-Dot on a small integer instance (microbench/sparse_walk). Same host contract as the
# reference run.py: A by column (CSC, padded), C<M> = A'A at the stored positions, zombies counted.
import json, os, sys, struct, argparse, numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sparse_inputs as si
from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType, MemcpyOrder
ap = argparse.ArgumentParser(); ap.add_argument("--name"); ap.add_argument("--cmaddr"); a = ap.parse_args()
params = json.load(open(f"{a.name}/out.json"))["params"]
n, max_nnz, iters = (int(params[k]) for k in ("n", "max_nnz", "iters"))
inst = json.load(open("instance.json"))
csr = si.from_coo(inst["n"], inst["m"], inst["rows"], inst["cols"], inst["vals"]); nnz = csr.nnz
csc = si.csc_pad(csr, n, max_nnz); col_ptr, row_idx, val = csc["col_ptr"], csc["row"], csc["val"]
cols = np.repeat(np.arange(csr.n), np.diff(col_ptr[: csr.n + 1].astype(np.int64))); rows = row_idx[:nnz].astype(np.int64)
c_ref, exists = csr.masked_gram(rows, cols); c_ref = c_ref.astype(np.float32); c_ref[~exists] = 0.0
c_row_ref = np.where(exists, rows, (~rows) & 0xFFFFFFFF).astype(np.uint32); nz_ref = int((~exists).sum())
runner = SdkRuntime(a.name, cmaddr=a.cmaddr)
names = ["col_ptr", "row_idx", "val", "c_val", "c_row", "nzombies"]; sym = {k: runner.get_id(k) for k in names}; sym_t = runner.get_id("maxmin_time")
runner.load(); runner.run()
U32, RM = MemcpyDataType.MEMCPY_32BIT, MemcpyOrder.ROW_MAJOR
def h2d(name, arr, count):
    runner.memcpy_h2d(sym[name], np.ascontiguousarray(arr, dtype=np.uint32), 0, 0, 1, 1, count, streaming=False, data_type=U32, order=RM, nonblock=False)
def d2h(name, count):
    out = np.zeros((count,), dtype=np.uint32)
    runner.memcpy_d2h(out, sym[name], 0, 0, 1, 1, count, streaming=False, data_type=U32, order=RM, nonblock=False); return out
h2d("col_ptr", col_ptr, n + 1); h2d("row_idx", row_idx, max_nnz); h2d("val", val.view(np.uint32), max_nnz)
runner.call("compute", [], nonblock=False)
tdata = np.zeros((3,), dtype=np.uint32)
runner.memcpy_d2h(tdata, sym_t, 0, 0, 1, 1, 3, streaming=False, data_type=U32, order=RM, nonblock=False)
dev = {"c_val": d2h("c_val", max_nnz), "c_row": d2h("c_row", max_nnz), "nzombies": d2h("nzombies", 1)}
runner.stop()
w = [int(v) for v in tdata]; tsc = [w[0] & 0xFFFF, w[0] >> 16, w[1] & 0xFFFF, w[1] >> 16, w[2] & 0xFFFF, w[2] >> 16]
mk = lambda ws: ws[0] | (ws[1] << 16) | (ws[2] << 32); cycles = mk(tsc[3:]) - mk(tsc[0:3])
c_out = dev["c_val"].view(np.float32)[:nnz]; c_row_out = dev["c_row"][:nnz]; nz_out = int(dev["nzombies"][0])
ok = bool(np.array_equal(c_out, c_ref) and np.array_equal(c_row_out, c_row_ref) and nz_out == nz_ref)
json.dump(dict(kind="spgemm", n=n, max_nnz=max_nnz, nnz=nnz, col_ptr=col_ptr.tolist(), row_idx=row_idx.tolist(), val=val.tolist(),
               mask_rows=rows.tolist(), mask_cols=cols.tolist(), c_dev=c_out.tolist(), c_row_dev=[int(v) for v in c_row_out], nzombies_dev=nz_out,
               c_ref=c_ref.tolist(), c_row_ref=[int(v) for v in c_row_ref], nzombies_ref=nz_ref, exact=ok, cycles_send=int(cycles)),
          open("result.json", "w"), indent=1)
print("c_dev", c_out.tolist()); print("zombies", nz_out, nz_ref); print("cycles_send", cycles); assert ok, "C<M> mismatch"; print("SUCCESS")
