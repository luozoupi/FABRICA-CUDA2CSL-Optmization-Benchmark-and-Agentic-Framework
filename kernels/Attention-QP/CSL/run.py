#!/usr/bin/env cs_python
# Host driver for the query-parallel dense attention reference.
#
# Query-parallel layout on a P x P grid: PE (px,py) owns query block
# (py*P + px) -> global rows [b*St_q, (b+1)*St_q); K and V are replicated to
# every PE; softmax is fully local. Benchmark conventions: the input seed comes
# from XKERNEL_EVAL_SEED (never from the command line, so the held-out gate can
# re-run with hidden seeds); cycles_send is max(finish) - min(start) over all
# PEs' device-internal timestamps taken inside the single `compute` launch.
import argparse
import json
import os
import numpy as np

from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType, MemcpyOrder  # pylint: disable=no-name-in-module

parser = argparse.ArgumentParser()
parser.add_argument('--name', default='out')
parser.add_argument('--cmaddr')
args = parser.parse_args()

with open(f"{args.name}/out.json", encoding='utf-8') as f:
  cp = json.load(f)['params']
P = int(cp['P']); St_q = int(cp['St_q']); S = int(cp['S']); d = int(cp['d'])
causal = int(cp['causal'])
assert S == P * P * St_q, f"S({S}) must equal P*P*St_q ({P*P*St_q})"

SEED = int(os.environ.get("XKERNEL_EVAL_SEED", "7"))
rng = np.random.default_rng(SEED)
Q = rng.standard_normal((S, d)).astype(np.float32)
K = rng.standard_normal((S, d)).astype(np.float32)
V = rng.standard_normal((S, d)).astype(np.float32)


def attention_ref(Q, K, V, causal):
  Qd, Kd, Vd = Q.astype(np.float64), K.astype(np.float64), V.astype(np.float64)
  sc = (Qd @ Kd.T) / np.sqrt(Qd.shape[1])
  if causal:
    r = np.arange(sc.shape[0])[:, None]; c = np.arange(sc.shape[1])[None, :]
    sc = np.where(c <= r, sc, -np.inf)
  sc = sc - sc.max(1, keepdims=True)
  Pm = np.exp(sc); Pm /= Pm.sum(1, keepdims=True)
  return (Pm @ Vd).astype(np.float32)


O_expected = attention_ref(Q, K, V, bool(causal))

runner = SdkRuntime(args.name, cmaddr=args.cmaddr)
sym_Q = runner.get_id('Q'); sym_K = runner.get_id('K'); sym_V = runner.get_id('V')
sym_O = runner.get_id('O')
sym_s = runner.get_id('start_ts'); sym_f = runner.get_id('finish_ts')
runner.load(); runner.run()

u32 = MemcpyDataType.MEMCPY_32BIT
u16 = MemcpyDataType.MEMCPY_16BIT
RM = MemcpyOrder.ROW_MAJOR

# Q: block (py*P+px) to PE (px,py): [P(py), P(px), St_q*d]
Q_blocks = Q.reshape(P, P, St_q * d)
runner.memcpy_h2d(sym_Q, Q_blocks.ravel(), 0, 0, P, P, St_q * d,
                  streaming=False, data_type=u32, order=RM, nonblock=True)
# K, V: replicate the full [S,d] to every PE
K_rep = np.broadcast_to(K.ravel(), (P, P, S * d)).copy()
V_rep = np.broadcast_to(V.ravel(), (P, P, S * d)).copy()
runner.memcpy_h2d(sym_K, K_rep.ravel(), 0, 0, P, P, S * d,
                  streaming=False, data_type=u32, order=RM, nonblock=True)
runner.memcpy_h2d(sym_V, V_rep.ravel(), 0, 0, P, P, S * d,
                  streaming=False, data_type=u32, order=RM, nonblock=True)

runner.launch('compute', nonblock=False)

# O: gather [P(py), P(px), St_q*d] -> [S, d]
O_1d = np.zeros(P * P * St_q * d, np.uint32)
runner.memcpy_d2h(O_1d, sym_O, 0, 0, P, P, St_q * d,
                  streaming=False, data_type=u32, order=RM, nonblock=False)
O_device = O_1d.view(np.float32).reshape(P, P, St_q, d).reshape(S, d)

# Timestamps from EVERY PE (3 x u16 words each, one per u32 slot with MEMCPY_16BIT).
s_buf = np.zeros(P * P * 3, np.uint32); f_buf = np.zeros(P * P * 3, np.uint32)
runner.memcpy_d2h(s_buf, sym_s, 0, 0, P, P, 3, streaming=False,
                  data_type=u16, order=RM, nonblock=False)
runner.memcpy_d2h(f_buf, sym_f, 0, 0, P, P, 3, streaming=False,
                  data_type=u16, order=RM, nonblock=False)
runner.stop()


def make_u48(w):
  return int(w[0]) + (int(w[1]) << 16) + (int(w[2]) << 32)


starts = [make_u48(w) for w in (s_buf & 0xFFFF).reshape(P * P, 3)]
ends = [make_u48(w) for w in (f_buf & 0xFFFF).reshape(P * P, 3)]
cycles = max(ends) - min(starts)
time_send = (cycles / 0.85) * 1.0e-3
flops = 4.0 * S * S * d * (0.5 if causal else 1.0)

print(f"[attention] P={P} S={S} d={d} St_q={St_q} causal={causal} seed={SEED}")
print(f"cycles_send = {cycles} cycles")
print(f"time_send = {time_send:.3f} us")
print(f"nominal_flop = {flops:.0f}")
err = float(np.max(np.abs(O_device - O_expected)))
print(f"max_abs_err = {err:.3e}")
np.testing.assert_allclose(O_device, O_expected, atol=1e-4, rtol=1e-4)
print("SUCCESS")
