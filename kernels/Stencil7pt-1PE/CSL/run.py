#!/usr/bin/env cs_python
# Stencil7pt-1PE (hand-written-compute variant) host runner.
#
# Single PE computes the 3D 7-point stencil y = A*x; verified against the numpy
# reference (the real invariant — no stencil-library answer key). Prints cycles_send
# over the on-device timed window. Input is seeded from XKERNEL_EVAL_SEED so the
# harness can score correctness on HELD-OUT seeds (anti-hardcoding).

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
Nx = int(params["Nx"])
Ny = int(params["Ny"])
Nz = int(params["Nz"])
N = Nx * Ny * Nz
print(f"Stencil7pt-1PE: Nx={Nx}, Ny={Ny}, Nz={Nz} (N={N})")

# Coefficients — MUST match pe.csl.
CC, CW, CE, CS, CN, CB, CT = 6.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0


def float_to_hex(f):
    return hex(struct.unpack("<I", struct.pack("<f", f))[0])


def make_u48(words):
    return words[0] | (words[1] << 16) | (words[2] << 32)


def sub_ts(words):
    return make_u48(words[3:]) - make_u48(words[0:3])


# --- Build random input field -----------------------------------------------------
SEED = int(os.environ.get("XKERNEL_EVAL_SEED", "7"))
rng = np.random.default_rng(SEED)
# x stored as [iz][iy][ix] flattened idx = iz*Ny*Nx + iy*Nx + ix
x3 = rng.random((Nz, Ny, Nx)).astype(np.float32)

# numpy reference: 7-point stencil with Dirichlet (zero) boundary.
y3 = (CC * x3).astype(np.float32)
y3[:, :, 1:]  += (CW * x3[:, :, :-1]).astype(np.float32)   # west:  ix-1 contributes to ix
y3[:, :, :-1] += (CE * x3[:, :, 1:]).astype(np.float32)    # east:  ix+1
y3[:, 1:, :]  += (CS * x3[:, :-1, :]).astype(np.float32)   # south: iy-1
y3[:, :-1, :] += (CN * x3[:, 1:, :]).astype(np.float32)    # north: iy+1
y3[1:, :, :]  += (CB * x3[:-1, :, :]).astype(np.float32)   # bottom:iz-1
y3[:-1, :, :] += (CT * x3[1:, :, :]).astype(np.float32)    # top:   iz+1
y_ref = y3.reshape(-1).astype(np.float32)
x_flat = x3.reshape(-1).astype(np.float32)

# --- Run on device ----------------------------------------------------------------
runner = SdkRuntime(args.name, cmaddr=args.cmaddr)
sym_x = runner.get_id("x")
sym_y = runner.get_id("y")
sym_time = runner.get_id("maxmin_time")

runner.load()
runner.run()

U32 = MemcpyDataType.MEMCPY_32BIT
RM = MemcpyOrder.ROW_MAJOR

runner.memcpy_h2d(sym_x, x_flat.view(np.uint32), 0, 0, 1, 1, N, streaming=False,
                  data_type=U32, order=RM, nonblock=False)

runner.call("compute", [], nonblock=False)

tdata = np.zeros((3,), dtype=np.uint32)
runner.memcpy_d2h(tdata, sym_time, 0, 0, 1, 1, 3, streaming=False,
                  data_type=U32, order=RM, nonblock=False)

y_dev = np.zeros((N,), dtype=np.uint32)
runner.memcpy_d2h(y_dev, sym_y, 0, 0, 1, 1, N, streaming=False,
                  data_type=U32, order=RM, nonblock=False)
runner.stop()

y_out = y_dev.view(np.float32)

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

# --- Verify (the real invariant: y == 7-point stencil of x) -----------------------
abs_err = float(np.max(np.abs(y_out - y_ref)))
scale = float(np.max(np.abs(y_ref))) + 1e-30
print(f"[verify] max abs err = {abs_err:.3e}, rel = {abs_err/scale:.3e}")
np.testing.assert_allclose(y_out, y_ref, rtol=1e-5, atol=1e-5)
print("SUCCESS")
