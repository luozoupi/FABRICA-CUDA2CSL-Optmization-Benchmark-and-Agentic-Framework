#!/usr/bin/env cs_python
# GEMM-1PE (simple hand-written dense matmul) host runner.
#
# Single PE computes C = A*B; verified against numpy A@B (the real invariant — no
# collectives/SUMMA library). Prints cycles_send over the on-device timed window.
# Input is seeded from XKERNEL_EVAL_SEED so the harness can score correctness on
# HELD-OUT seeds (anti-hardcoding; see docs/SPLIT_AND_LEAKAGE.md).

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
M = int(params["M"])
K = int(params["K"])
N = int(params["N"])
print(f"GEMM-1PE: M={M}, K={K}, N={N}")


def float_to_hex(f):
    return hex(struct.unpack("<I", struct.pack("<f", f))[0])


def make_u48(words):
    return words[0] | (words[1] << 16) | (words[2] << 32)


def sub_ts(words):
    return make_u48(words[3:]) - make_u48(words[0:3])


# --- Build random inputs ----------------------------------------------------------
SEED = int(os.environ.get("XKERNEL_EVAL_SEED", "7"))
rng = np.random.default_rng(SEED)
A = rng.random((M, K)).astype(np.float32)
B = rng.random((K, N)).astype(np.float32)
C_ref = (A @ B).astype(np.float32)

# --- Run on device ----------------------------------------------------------------
runner = SdkRuntime(args.name, cmaddr=args.cmaddr)
sym_A = runner.get_id("A")
sym_B = runner.get_id("B")
sym_C = runner.get_id("C")
sym_time = runner.get_id("maxmin_time")

runner.load()
runner.run()

U32 = MemcpyDataType.MEMCPY_32BIT
RM = MemcpyOrder.ROW_MAJOR

runner.memcpy_h2d(sym_A, A.reshape(-1).view(np.uint32), 0, 0, 1, 1, M * K,
                  streaming=False, data_type=U32, order=RM, nonblock=False)
runner.memcpy_h2d(sym_B, B.reshape(-1).view(np.uint32), 0, 0, 1, 1, K * N,
                  streaming=False, data_type=U32, order=RM, nonblock=False)

runner.call("compute", [], nonblock=False)

tdata = np.zeros((3,), dtype=np.uint32)
runner.memcpy_d2h(tdata, sym_time, 0, 0, 1, 1, 3, streaming=False,
                  data_type=U32, order=RM, nonblock=False)

C_dev = np.zeros((M * N,), dtype=np.uint32)
runner.memcpy_d2h(C_dev, sym_C, 0, 0, 1, 1, M * N, streaming=False,
                  data_type=U32, order=RM, nonblock=False)
runner.stop()

C_out = C_dev.view(np.float32).reshape(M, N)

# --- Cycle count ------------------------------------------------------------------
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

# --- Verify (the real invariant: C == A@B) ----------------------------------------
abs_err = float(np.max(np.abs(C_out - C_ref)))
scale = float(np.max(np.abs(C_ref))) + 1e-30
print(f"[verify] max abs err = {abs_err:.3e}, rel = {abs_err/scale:.3e}")
np.testing.assert_allclose(C_out, C_ref, rtol=1e-4, atol=1e-4)
print("SUCCESS")
