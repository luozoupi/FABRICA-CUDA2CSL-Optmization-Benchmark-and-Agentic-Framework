#!/usr/bin/env cs_python
# SpMM-CSR-Dense on a small integer instance (microbench/sparse_walk). Same host contract as the
# reference run.py: row tiles replicated along mesh rows, B slices replicated down mesh columns.
import json, os, sys, argparse, numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sparse_inputs as si
from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType, MemcpyOrder
ap = argparse.ArgumentParser(); ap.add_argument("--name"); ap.add_argument("--cmaddr"); a = ap.parse_args()
params = json.load(open(f"{a.name}/out.json"))["params"]
P, Mt, K, Nt, max_nnz_pe, iters = (int(params[k]) for k in ("P", "Mt", "K", "Nt", "max_nnz_pe", "iters")); N = P * Nt
inst = json.load(open("instance.json"))
csr = si.from_coo(inst["n"], inst["m"], inst["rows"], inst["cols"], inst["vals"])
tiles = si.partition_row_block(csr, P, Mt); pads = [si.csr_pad(t_, Mt, max_nnz_pe) for t_ in tiles]
B = np.zeros((K, N), dtype=np.float32); B[: csr.m, :] = np.array(inst["B"], dtype=np.float32)
C_ref = csr.matmat(B[: csr.m, :]).astype(np.float32)
row_ptr = np.zeros((P, P, Mt + 1), dtype=np.uint32); col_idx = np.zeros((P, P, max_nnz_pe), dtype=np.uint32)
val = np.zeros((P, P, max_nnz_pe), dtype=np.float32); B_tiles = np.zeros((P, P, K * Nt), dtype=np.float32)
for py in range(P):
    for px in range(P):
        row_ptr[py, px] = pads[py]["row_ptr"]; col_idx[py, px] = pads[py]["col"]; val[py, px] = pads[py]["val"]
        B_tiles[py, px] = np.ascontiguousarray(B[:, px * Nt:(px + 1) * Nt]).reshape(-1)
runner = SdkRuntime(a.name, cmaddr=a.cmaddr)
sym = {k: runner.get_id(k) for k in ("row_ptr", "col_idx", "val", "B_tile", "C_tile", "time_buf_u16")}
runner.load(); runner.run()
U32, U16, RM = MemcpyDataType.MEMCPY_32BIT, MemcpyDataType.MEMCPY_16BIT, MemcpyOrder.ROW_MAJOR
def h2d_mesh(name, arr3d, count):
    runner.memcpy_h2d(sym[name], np.ascontiguousarray(arr3d, dtype=np.uint32).ravel(), 0, 0, P, P, count,
                      streaming=False, data_type=U32, order=RM, nonblock=False)
h2d_mesh("row_ptr", row_ptr, Mt + 1); h2d_mesh("col_idx", col_idx, max_nnz_pe)
h2d_mesh("val", val.view(np.uint32), max_nnz_pe); h2d_mesh("B_tile", B_tiles.view(np.uint32), K * Nt)
runner.launch("f_enable_timer", nonblock=False); runner.launch("main", nonblock=False); runner.launch("f_memcpy_timestamps", nonblock=False)
C_dev = np.zeros((P, P, Mt * Nt), dtype=np.uint32)
runner.memcpy_d2h(C_dev, sym["C_tile"], 0, 0, P, P, Mt * Nt, streaming=False, data_type=U32, order=RM, nonblock=False)
t = np.zeros((P, P, 6), dtype=np.uint32)
runner.memcpy_d2h(t, sym["time_buf_u16"], 0, 0, P, P, 6, streaming=False, data_type=U16, order=RM, nonblock=False)
runner.stop()
t = t.reshape(P, P, 6).astype(np.uint16)
tc = lambda w: int(w[0]) | (int(w[1]) << 16) | (int(w[2]) << 32)
win = {f"{px},{py}": [tc(t[py, px, 0:3]), tc(t[py, px, 3:6])] for py in range(P) for px in range(P)}
C_out = np.zeros((P * Mt, N), dtype=np.float32)
for py in range(P):
    for px in range(P):
        C_out[py * Mt:(py + 1) * Mt, px * Nt:(px + 1) * Nt] = C_dev[py, px].view(np.float32).reshape(Mt, Nt)
ok = bool(np.array_equal(C_out[: csr.n], C_ref))
json.dump(dict(kind="spmm", P=P, Mt=Mt, K=K, Nt=Nt, max_nnz_pe=max_nnz_pe, row_ptr=row_ptr.tolist(), col_idx=col_idx.tolist(),
               val=val.tolist(), B=B.tolist(), B_tiles=B_tiles.tolist(), C_dev=C_out.tolist(), C_ref=C_ref.tolist(), exact=ok,
               nnz_per_tile=[t_.nnz for t_ in tiles], windows=win,
               cycles_send=int(max(e for _, e in win.values()) - min(s for s, _ in win.values()))), open("result.json", "w"), indent=1)
print("C_dev", C_out[: csr.n].tolist()); print("exact", ok); assert ok, "C != A B"; print("SUCCESS")
