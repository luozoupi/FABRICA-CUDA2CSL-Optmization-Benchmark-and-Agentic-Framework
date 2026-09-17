#!/usr/bin/env cs_python

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
import os
import numpy as np

from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime     # pylint: disable=no-name-in-module
from cerebras.sdk.runtime.sdkruntimepybind import MemcpyDataType # pylint: disable=no-name-in-module
from cerebras.sdk.runtime.sdkruntimepybind import MemcpyOrder    # pylint: disable=no-name-in-module

parser = argparse.ArgumentParser()
parser.add_argument("--name", help="the test name")
parser.add_argument("--cmaddr", help="IP:port for CS system")
args = parser.parse_args()

# Get params from compile metadata
with open(f"{args.name}/out.json", encoding='utf-8') as json_file:
  compile_data = json.load(json_file)

# Kernel rectangle and per-PE matrix dimensions
P = int(compile_data['params']['P'])
Mt = int(compile_data['params']['Mt'])
Kt = int(compile_data['params']['Kt'])
Nt = int(compile_data['params']['Nt'])

# Full matrix dimensions
# A is M x K, B is K x N, C is M x N
M = Mt * P
K = Kt * P
N = Nt * P

memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
memcpy_order = MemcpyOrder.ROW_MAJOR

# Use a deterministic seed so that CI results are predictable. INPUT-SPLIT
# (2026-06-24): parameterized via XKERNEL_EVAL_SEED so the harness can score
# correctness on HELD-OUT seeds the agent never saw; C=A@B is recomputed from the
# drawn inputs. See docs/SPLIT_AND_LEAKAGE.md (input-level split).
np.random.seed(int(os.environ.get("XKERNEL_EVAL_SEED", "7")))

A = np.random.rand(M, K).astype(np.float32)
B = np.random.rand(K, N).astype(np.float32)

def make_u48(words):
  return words[0] + (words[1] << 16) + (words[2] << 32)

runner = SdkRuntime(args.name, cmaddr=args.cmaddr)

sym_A = runner.get_id("A")
sym_B = runner.get_id("B")
sym_C = runner.get_id("C")
sym_time_buf_u16 = runner.get_id("time_buf_u16")

runner.load()
runner.run()

runner.launch("f_enable_timer", nonblock=True)

w = P # number of columns PEs in the core rectangle
h = P # number of row PEs in the core rectangle

# How to transform a 2-D tensor into a cliff distribution with
# column-major local tensor
#
# Example: w=2, h=2, A is 4-by-4 (lh-by-lw)
# A = |  0  1  2  3 |
#     |  4  5  6  7 |
#     |  8  9 10 11 |
#     | 12 13 14 15 |
# A1 = A.reshape(2,2,2,2) of the form (h,lh,w,lw)
# A1 = | | 0  1|  | 4  5| |
#      | | 2  3|, | 6  7| |
#      |                  |
#      | | 8  9|  |12 13| |
#      | |10 11|, |14 15| |
# A2 = A1.transpose(0, 2, 3, 1) of the form (h, w, lw, lh)
# so the local tensor lh-by-lw is col-major
# A2 = | | 0  4|  | 2  6| |
#      | | 1  5|, | 3  7| |
#      |                  |
#      | | 8 12|  |10 14| |
#      | | 9 13|, |11 15| |
# A3 = A2.reshape(2,2,4)
# A3 = |  0  4  1  5 |
#      |  2  6  3  7 |
#      |  8 12  9 13 |
#      | 10 14 11 15 |
# A3 is h-w-l

A1 = A.reshape(h, Mt, w, Kt)
A2 = A1.transpose(0, 2, 3, 1)
A3 = A2.reshape(h, w, Mt*Kt)
runner.memcpy_h2d(sym_A, A3.ravel(), 0, 0, w, h, Mt*Kt, \
    streaming=False, data_type=memcpy_dtype, order=MemcpyOrder.ROW_MAJOR, nonblock=True)

B1 = B.reshape(h, Kt, w, Nt)
B2 = B1.transpose(0, 2, 3, 1)
B3 = B2.reshape(h, w, Kt*Nt)
runner.memcpy_h2d(sym_B, B3.ravel(), 0, 0, w, h, Kt*Nt, \
    streaming=False, data_type=memcpy_dtype, order=MemcpyOrder.ROW_MAJOR, nonblock=True)

# f_tic is stamped on-device (device_internal_v2); no host launch.
runner.launch("main", nonblock=False)
# f_toc is stamped on-device (device_internal_v2); no host launch.
runner.launch("f_memcpy_timestamps", nonblock=False)

C3_1d_u32 = np.zeros(h*w*Mt*Nt, np.uint32)
runner.memcpy_d2h(C3_1d_u32, sym_C, 0, 0, w, h, Mt*Nt, \
    streaming=False, data_type=memcpy_dtype, order=MemcpyOrder.ROW_MAJOR, nonblock=False)

time_memcpy_hwl_1d = np.zeros(h * w * 6, np.uint32)
runner.memcpy_d2h(
    time_memcpy_hwl_1d,
    sym_time_buf_u16,
    0,
    0,
    w,
    h,
    6,
    streaming=False,
    data_type=MemcpyDataType.MEMCPY_16BIT,
    order=MemcpyOrder.ROW_MAJOR,
    nonblock=False,
)
# C3 is h-by-w-l or
# C3 is of the form (h, w, Nt, Mt) where local tensor Mt-by-Nt is column-major
C3 = C3_1d_u32.reshape((h, w, Nt, Mt))
# C2 is of the form (h, Mt, w, Nt)
C2 = C3.transpose(0, 3, 1, 2)
# C1 is of the form (M, N)
C1 = C2.reshape(M, N)
# C has the correct data type
C = C1.view(np.float32)

runner.stop()

# Decode timestamps: data was sent in row-major order with l=6 per PE,
# so reshape as (h, w, 6).
time_memcpy_hwl = time_memcpy_hwl_1d.reshape(h, w, 6).astype(np.uint16)

time_start = np.zeros((h, w)).astype(int)
time_end = np.zeros((h, w)).astype(int)
word = np.zeros(3).astype(np.uint16)
for hi in range(h):
  for wi in range(w):
    word[0] = time_memcpy_hwl[hi, wi, 0]
    word[1] = time_memcpy_hwl[hi, wi, 1]
    word[2] = time_memcpy_hwl[hi, wi, 2]
    time_start[hi, wi] = make_u48(word)
    word[0] = time_memcpy_hwl[hi, wi, 3]
    word[1] = time_memcpy_hwl[hi, wi, 4]
    word[2] = time_memcpy_hwl[hi, wi, 5]
    time_end[hi, wi] = make_u48(word)

min_time_start = time_start.min()
max_time_end = time_end.max()
cycles_send = max_time_end - min_time_start
time_send = (cycles_send / 0.85) * 1.0e-3
print(f"cycles_send = {cycles_send} cycles")
print(f"time_send = {time_send} us")

# Check the result
C_expected = np.dot(A, B)

# absolute(a - b) <= (atol + rtol * absolute(b))
np.testing.assert_allclose(C_expected, C, rtol=1e-05, atol=1e-06)

print("SUCCESS")
