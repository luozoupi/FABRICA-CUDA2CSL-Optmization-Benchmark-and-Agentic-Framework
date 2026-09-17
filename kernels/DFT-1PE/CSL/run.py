#!/usr/bin/env cs_python
# DFT-1PE (hand-written-compute variant) host runner.
#
# Single PE computes the direct O(N^2) DFT of a real input; verified against
# numpy np.fft.fft (the real invariant — no FFT-library answer key). Twiddle tables
# (cos / -sin) are precomputed here and passed in. Prints cycles_send over the timed
# window. Input is seeded from XKERNEL_EVAL_SEED (anti-hardcoding via held-out seeds).

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
N = int(params["N"])
print(f"DFT-1PE: N={N}")


def float_to_hex(f):
    return hex(struct.unpack("<I", struct.pack("<f", f))[0])


def make_u48(words):
    return words[0] | (words[1] << 16) | (words[2] << 32)


def sub_ts(words):
    return make_u48(words[3:]) - make_u48(words[0:3])


# --- Build random input + twiddle tables ------------------------------------------
SEED = int(os.environ.get("XKERNEL_EVAL_SEED", "7"))
rng = np.random.default_rng(SEED)
x = rng.random(N).astype(np.float32)

# twiddle: angle = 2*pi*k*n/N; cosT = cos(angle), sinT = -sin(angle)
k = np.arange(N).reshape(N, 1)
n = np.arange(N).reshape(1, N)
angle = (2.0 * np.pi * (k * n) / N)
cosT = np.cos(angle).astype(np.float32).reshape(-1)
sinT = (-np.sin(angle)).astype(np.float32).reshape(-1)

# numpy reference (the invariant)
X_ref = np.fft.fft(x)
Xre_ref = X_ref.real.astype(np.float32)
Xim_ref = X_ref.imag.astype(np.float32)

# --- Run on device ----------------------------------------------------------------
runner = SdkRuntime(args.name, cmaddr=args.cmaddr)
sym = {s: runner.get_id(s) for s in ("x", "cosT", "sinT", "Xre", "Xim", "maxmin_time")}

runner.load()
runner.run()

U32 = MemcpyDataType.MEMCPY_32BIT
RM = MemcpyOrder.ROW_MAJOR


def h2d(name, arr, count):
    runner.memcpy_h2d(sym[name], arr.view(np.uint32), 0, 0, 1, 1, count,
                      streaming=False, data_type=U32, order=RM, nonblock=False)


h2d("x", x, N)
h2d("cosT", cosT, N * N)
h2d("sinT", sinT, N * N)

runner.call("compute", [], nonblock=False)

tdata = np.zeros((3,), dtype=np.uint32)
runner.memcpy_d2h(tdata, sym["maxmin_time"], 0, 0, 1, 1, 3, streaming=False,
                  data_type=U32, order=RM, nonblock=False)

Xre_dev = np.zeros((N,), dtype=np.uint32)
Xim_dev = np.zeros((N,), dtype=np.uint32)
runner.memcpy_d2h(Xre_dev, sym["Xre"], 0, 0, 1, 1, N, streaming=False,
                  data_type=U32, order=RM, nonblock=False)
runner.memcpy_d2h(Xim_dev, sym["Xim"], 0, 0, 1, 1, N, streaming=False,
                  data_type=U32, order=RM, nonblock=False)
runner.stop()

Xre = Xre_dev.view(np.float32)
Xim = Xim_dev.view(np.float32)

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

# --- Verify (the real invariant: X == numpy fft) ----------------------------------
# Direct DFT in f32 accumulates rounding over N terms; scale tolerance by N.
scale = float(np.max(np.abs(X_ref))) + 1e-30
re_err = float(np.max(np.abs(Xre - Xre_ref)))
im_err = float(np.max(np.abs(Xim - Xim_ref)))
print(f"[verify] re err = {re_err:.3e}, im err = {im_err:.3e}, signal scale = {scale:.3e}")
atol = 1e-3 * scale
np.testing.assert_allclose(Xre, Xre_ref, rtol=1e-3, atol=atol)
np.testing.assert_allclose(Xim, Xim_ref, rtol=1e-3, atol=atol)
print("SUCCESS")
