#!/usr/bin/env cs_python
# SpMV-RowBlock on a small integer instance (microbench/sparse_walk). Same host contract as the
# reference run.py: per-PE padded CSR slices, x written to PE 0 only, y read back per PE.
import json, os, sys, argparse, numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sparse_inputs as si
from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType, MemcpyOrder
ap = argparse.ArgumentParser(); ap.add_argument("--name"); ap.add_argument("--cmaddr"); a = ap.parse_args()
params = json.load(open(f"{a.name}/out.json"))["params"]
P, nrows_pe, ncols, max_nnz_pe, iters = (int(params[k]) for k in ("P", "nrows_pe", "ncols", "max_nnz_pe", "iters"))
inst = json.load(open("instance.json"))
csr = si.from_coo(inst["n"], inst["m"], inst["rows"], inst["cols"], inst["vals"])
parts = si.partition_row_block(csr, P, nrows_pe)
pads = [si.csr_pad(p, nrows_pe, max_nnz_pe) for p in parts]
row_ptr = np.stack([q["row_ptr"] for q in pads]); col_idx = np.stack([q["col"] for q in pads]); val = np.stack([q["val"] for q in pads])
x = np.zeros(ncols, dtype=np.float32); x[: csr.m] = np.array(inst["x"], dtype=np.float32)
y_ref = csr.matvec(x[: csr.m].astype(np.float64)).astype(np.float32)
runner = SdkRuntime(a.name, cmaddr=a.cmaddr)
sym = {k: runner.get_id(k) for k in ("row_ptr", "col_idx", "val", "x", "y", "time_buf_u16")}
runner.load(); runner.run()
U32, U16, RM = MemcpyDataType.MEMCPY_32BIT, MemcpyDataType.MEMCPY_16BIT, MemcpyOrder.ROW_MAJOR
def h2d_strip(name, arr2d, count):
    runner.memcpy_h2d(sym[name], np.ascontiguousarray(arr2d, dtype=np.uint32).ravel(), 0, 0, P, 1, count,
                      streaming=False, data_type=U32, order=RM, nonblock=False)
h2d_strip("row_ptr", row_ptr, nrows_pe + 1); h2d_strip("col_idx", col_idx, max_nnz_pe); h2d_strip("val", val.view(np.uint32), max_nnz_pe)
runner.memcpy_h2d(sym["x"], x.view(np.uint32), 0, 0, 1, 1, ncols, streaming=False, data_type=U32, order=RM, nonblock=False)
runner.launch("f_enable_timer", nonblock=False)
runner.launch("main", nonblock=False)
runner.launch("f_memcpy_timestamps", nonblock=False)
y_dev = np.zeros((1, P, nrows_pe), dtype=np.uint32)
runner.memcpy_d2h(y_dev, sym["y"], 0, 0, P, 1, nrows_pe, streaming=False, data_type=U32, order=RM, nonblock=False)
t = np.zeros((1, P, 6), dtype=np.uint32)
runner.memcpy_d2h(t, sym["time_buf_u16"], 0, 0, P, 1, 6, streaming=False, data_type=U16, order=RM, nonblock=False)
runner.stop()
t = t.reshape(P, 6).astype(np.uint16)
tc = lambda w: int(w[0]) | (int(w[1]) << 16) | (int(w[2]) << 32)
win = [[tc(t[c, 0:3]), tc(t[c, 3:6])] for c in range(P)]
y_out = y_dev.reshape(P, nrows_pe).view(np.float32).reshape(-1)[: csr.n]
ok = bool(np.array_equal(y_out, y_ref))
json.dump(dict(kind="spmv", P=P, nrows_pe=nrows_pe, ncols=ncols, max_nnz_pe=max_nnz_pe,
               row_ptr=row_ptr.tolist(), col_idx=col_idx.tolist(), val=val.tolist(), x=x.tolist(),
               y_dev=y_dev.reshape(P, nrows_pe).view(np.float32).tolist(), y_ref=y_ref.tolist(), exact=ok,
               nnz_per_pe=[p.nnz for p in parts], windows=win, cycles_send=int(max(e for _, e in win) - min(s for s, _ in win))),
          open("result.json", "w"), indent=1)
print("y_dev", y_out.tolist()); print("y_ref", y_ref.tolist()); print("cycles_send", max(e for _, e in win) - min(s for s, _ in win))
assert ok, "y != A x"; print("SUCCESS")
