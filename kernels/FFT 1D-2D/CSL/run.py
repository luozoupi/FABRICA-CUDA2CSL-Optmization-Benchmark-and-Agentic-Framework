# Copyright 2025 Cerebras Systems.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


import argparse
import json
import numpy as np

from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType  # pylint: disable=no-name-in-module
from cerebras.sdk.runtime.sdkruntimepybind import MemcpyOrder  # pylint: disable=no-name-in-module
from cerebras.sdk import sdk_utils  # pylint: disable=no-name-in-module


def arguments():
  parser = argparse.ArgumentParser(description="FFT parameters.")
  parser.add_argument(
      "-no_check",
      "--no_check_outcome",
      action="store_true",
      help="Do not validate outcome against NumPy implementation",
  )
  parser.add_argument(
      "-v",
      "--verbose",
      action="store_true",
      help="Add verbose output, with sim log files per PE.",
  )
  parser.add_argument(
      "-n",
      "--name",
      required=True,
      default="out",
      help="Output/input file name prefix.",
  )
  parser.add_argument(
      "-i",
      "--inverse",
      action="store_true",
      help="Compute the inverse FFT.",
      default=False,
  )
  parser.add_argument("--cmaddr", help="IP:port for CS system")
  return parser.parse_args()

args = arguments()

# Parse the compile metadata
with open(f"{args.name}/out.json", encoding="utf-8") as json_file:
  compile_data = json.load(json_file)
compile_colors = compile_data["colors"]
compile_params = compile_data["params"]

DIM = int(compile_params["DIM"])
Nz = int(compile_params["Nz"])
FP = int(compile_params["FP"])
assert DIM in [1, 2], "only 1D and 2D supported"
assert (DIM == 1 and Nz >= 2) or (DIM == 2 and Nz >= 4), \
    f"Minimum problem size Nz for DIM={DIM} is not met"
assert Nz & (Nz-1) == 0, "Nz must be a power of 2"
assert FP in [1, 2]
assert FP == 1 or DIM == 1, "2D does not support FP2"

width = 1 if DIM == 1 else Nz
is_2D = (width > 1)
Nx = Nz if is_2D else width
height = 1
Ny = height
precision_type = np.dtype(np.float16 if FP == 1 else np.float32)

Nh = Nz >> 1
Tx = Nx // width
Ty = Ny // height
Tz = Tx

print(f"Nx:{Nx}, Ny:{Ny}, Nz:{Nz}, width:{width}, height:{height}, 2D:{is_2D}")
print(f"Tx:{Tx}, Ty:{Ty}, Tz:{Tz}")

ELEM_SIZE = 2
BRICK_ELEM = Tx * Ty * Tz
BRICK_LEN = BRICK_ELEM * ELEM_SIZE
depth = Nz // Tz
LOCAL_TENSOR_ELEM = BRICK_ELEM * depth
LOCAL_TENSOR_LEN = LOCAL_TENSOR_ELEM * ELEM_SIZE

GLOBAL_TENSOR_ELEM = Nx * Ny * Nz
GLOBAL_TENSOR_LEN = GLOBAL_TENSOR_ELEM * ELEM_SIZE

CHECK_RES = not args.no_check_outcome

f_twiddle_container = np.zeros(Nz, dtype=np.uint32)
f_twiddle = sdk_utils.memcpy_view(f_twiddle_container, precision_type)

exponent = np.pi * np.arange(Nh) / Nh
fI = np.sin(exponent).astype(precision_type)
fR = np.cos(exponent).astype(precision_type)
f_twiddle[0::2] = fR
f_twiddle[1::2] = fI

# Set the seed so that CI results are deterministic
np.random.seed(seed=7)

# Create Random array if CHECK_RES set, or a fixed array if not
if CHECK_RES:
  random_array = np.random.random(GLOBAL_TENSOR_ELEM).astype(precision_type)
else:
  random_array = np.arange(GLOBAL_TENSOR_ELEM).astype(precision_type)

X_pre = random_array.reshape((Ny, Nx, Nz))

X_container = np.zeros((height, width, LOCAL_TENSOR_LEN), dtype=np.uint32)
X_res_container = np.zeros((height, width, LOCAL_TENSOR_LEN), dtype=np.uint32)
X = sdk_utils.memcpy_view(X_container, precision_type)
X_res = sdk_utils.memcpy_view(X_res_container, precision_type)

for y in range(Ny):
  for x in range(Nx):
    for z in range(Nz):
      offset = x % Tx + z * Tz
      X[y][x // Tx][offset*2] = X_pre[y][x][z]
      X[y][x // Tx][offset*2+1] = 0

print(f"X.shape: {X.shape}, X.dtype = {X.dtype}")
print(f"X = {X}")
print(f"f_twiddle = {f_twiddle}")

#########################################
dirname = f"{args.name}"
memcpy_dtype = MemcpyDataType.MEMCPY_32BIT if precision_type == np.float32\
  else MemcpyDataType.MEMCPY_16BIT
memcpy_order = MemcpyOrder.ROW_MAJOR

runner = SdkRuntime(dirname, cmaddr=args.cmaddr)
runner.load()
runner.run()

symbol_X = runner.get_id("X")
symbol_f_twiddle = runner.get_id("f_twiddle")

runner.memcpy_h2d(symbol_X, X_container.ravel(), 0, 0, width, height, LOCAL_TENSOR_LEN,
                  streaming=False, data_type=memcpy_dtype,
                  order=memcpy_order, nonblock=False)

# Write 'f' to every PE.
f_twiddle_fill = np.full((height, width, Nz), f_twiddle_container, dtype=np.uint32)
runner.memcpy_h2d(symbol_f_twiddle, f_twiddle_fill.ravel(), 0, 0, width, height, Nz,
                  streaming=False, data_type=memcpy_dtype,
                  order=memcpy_order, nonblock=False)

# Run the computation on a simulated wafer or "simfabric"
if args.inverse:
  runner.launch("f_ifft", nonblock=False)
else:
  runner.launch("f_fft", nonblock=False)

runner.memcpy_d2h(X_res_container.ravel(), symbol_X, 0, 0, width, height, LOCAL_TENSOR_LEN,
                  streaming=False, data_type=memcpy_dtype,
                  order=memcpy_order, nonblock=False)

# On-device timing readback (2026-06-24): the synchronous butterfly mod.fft() window was
# measured per-PE; read the packed timestamp from PE (0,0) and report cycles_send.
_sym_time = runner.get_id("maxmin_time")
_tdata = np.zeros(3, dtype=np.uint32)
runner.memcpy_d2h(_tdata, _sym_time, 0, 0, 1, 1, 3,
                  streaming=False, data_type=MemcpyDataType.MEMCPY_32BIT,
                  order=MemcpyOrder.ROW_MAJOR, nonblock=False)
runner.stop()

import struct as _struct
_tm = _tdata.view(np.float32)
_w = np.zeros(6, dtype=np.uint16)
_hh = [_struct.unpack("<I", _struct.pack("<f", float(_tm[i])))[0] for i in range(3)]
_w[0] = _hh[0] & 0xFFFF; _w[1] = (_hh[0] >> 16) & 0xFFFF
_w[2] = _hh[1] & 0xFFFF; _w[3] = (_hh[1] >> 16) & 0xFFFF
_w[4] = _hh[2] & 0xFFFF; _w[5] = (_hh[2] >> 16) & 0xFFFF
_start = int(_w[0]) | (int(_w[1]) << 16) | (int(_w[2]) << 32)
_end = int(_w[3]) | (int(_w[4]) << 16) | (int(_w[5]) << 32)
_cycles = _end - _start
print(f"cycles_send = {_cycles} cycles")
print(f"time_send = {(_cycles / 0.85) * 1.0e-3:.4f} us")
# Create result arrays
result_array_pre = np.zeros((height, width, LOCAL_TENSOR_ELEM), dtype=complex)
result_array = np.zeros((Ny, Nx, Nz), dtype=complex)

# Create Complex array out of Real and Imaginary parts
for row in range(height):
  for i in range(width):
    for j in range(LOCAL_TENSOR_ELEM):
      result_array_pre[row][i][j] = complex(
          X_res[row][i][j * 2], X_res[row][i][j * 2 + 1])

for y in range(Ny):
  for x in range(Nx):
    for z in range(Nz):
      offset = x % Tx + z * Tz
      result_array[y][x][z] = result_array_pre[y][x // Tx][offset]

# Transpose the array if needed and get the FFT result with the NumPy Reference
random_array_sq = random_array.reshape((Ny, Nx, Nz))
if is_2D:
  result_array[0] = result_array[0].T
  #result_array_transposed = result_array
  if args.inverse:
    reference_array = np.fft.ifft2(random_array_sq)
  else:
    reference_array = np.fft.fft2(random_array_sq)
else:  # 1D FFT
  #result_array_transposed = result_array
  if args.inverse:
    reference_array = np.fft.ifft(random_array_sq)
  else:
    reference_array = np.fft.fft(random_array_sq)

# Compare the Simfabric and NumPy results
print("\nResult array")
print(result_array)
print("\nRef array")
print(reference_array)

if CHECK_RES:
  # Anti-gaming (2026-06-24): rtol=0.25 (25% relative error) was far too loose —
  # garbage output could pass. The looseness came from atol=0 making near-zero FFT
  # bins blow up the relative metric. Fix: a tight relative tolerance combined with
  # an absolute floor scaled to the signal magnitude, so small bins are judged by
  # atol and large bins by rtol. Tightened to the level the legitimate
  # ucode-FFT reference actually achieves on this size.
  _scale = float(np.max(np.abs(reference_array))) + 1e-30
  _abs_err = float(np.max(np.abs(result_array - reference_array)))
  print(f"[verify] max abs err = {_abs_err:.3e}, signal scale = {_scale:.3e}, "
        f"rel = {_abs_err/_scale:.3e}")
  np.testing.assert_allclose(
      result_array, reference_array, rtol=1e-2, atol=1e-3 * _scale)
  print("\nSUCCESS!")
