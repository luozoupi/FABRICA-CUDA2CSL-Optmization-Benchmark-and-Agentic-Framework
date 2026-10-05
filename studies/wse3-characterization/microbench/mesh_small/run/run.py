#!/usr/bin/env cs_python
# MeshGEMM P=4, 8x8 integer instance: same host contract as launch_sim.py, one checked repeat.
import json, numpy as np
from cerebras.sdk.sdk_utils import input_array_to_u32, memcpy_view
from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType, MemcpyOrder
import host_common as hc
P, Mt, Kt, Nt = 4, 2, 2, 2; M = K = N = P * Mt
inst = json.load(open("instance.json"))
X = np.array(inst["X"], dtype=np.float16); W = np.array(inst["W"], dtype=np.float16)
ind = np.zeros((P, P), dtype=int)                       # the host's W pre-skew, exactly as make_inputs builds it
for i in range(P):
    for j in range(P):
        if i == 0: ind[0, j] = j
        elif i == 1: _, ind[1, j] = hc.assignId(ind[0, j], P)
        elif (i - 1) % 2 == 0: _, ind[i, j] = hc.assignId(ind[i - 2, j], P)
        else: ind[i, j], _ = hc.assignId(ind[i - 2, j], P)
Woff = np.zeros((K, N), dtype=np.float16)
for i in range(P):
    for j in range(P):
        t = ind[i, j]; Woff[i * Kt:(i + 1) * Kt, j * Nt:(j + 1) * Nt] = W[t * Kt:(t + 1) * Kt, j * Nt:(j + 1) * Nt]
runner = SdkRuntime("out"); runner.load(); runner.run()
sym_X, sym_W, sym_res = runner.get_id("X"), runner.get_id("W"), runner.get_id("res")
io, order = MemcpyDataType.MEMCPY_16BIT, MemcpyOrder.ROW_MAJOR
runner.memcpy_h2d(sym_X, input_array_to_u32(hc.tile_X(X, P, Mt, Kt), 1, 1), 0, 0, P, P, Mt * Kt, streaming=False, data_type=io, order=order, nonblock=False)
runner.memcpy_h2d(sym_W, input_array_to_u32(hc.tile_W(Woff, P, Kt, Nt), 1, 1), 0, 0, P, P, Kt * Nt, streaming=False, data_type=io, order=order, nonblock=False)
runner.launch("init_task", nonblock=False)
runner.launch("meshgemm_host", np.int16(0), np.int16(1), nonblock=False)
res = np.zeros(M * N, dtype=np.uint32)
runner.memcpy_d2h(res, sym_res, 0, 0, P, P, Mt * Nt, streaming=False, data_type=io, order=order, nonblock=False)
runner.stop()
C = hc.untile_res(memcpy_view(res, np.dtype(np.float16)), P, Mt, Nt).astype(np.float64)
ref = X.astype(np.float64) @ W.astype(np.float64); ok = bool(np.array_equal(C, ref))
json.dump(dict(P=P, Mt=Mt, X=X.astype(int).tolist(), W=W.astype(int).tolist(), W_offset=Woff.astype(int).tolist(), ind=ind.tolist(),
               C_dev=C.astype(int).tolist(), C_ref=ref.astype(int).tolist(), exact=ok), open("result.json", "w"), indent=1)
print("C_dev", C.astype(int).tolist()); assert ok, "C != X W"; print("SUCCESS")
