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


from itertools import product
import argparse
import json
import os
import numpy as np

from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType # pylint: disable=no-name-in-module
from cerebras.sdk.runtime.sdkruntimepybind import MemcpyOrder # pylint: disable=no-name-in-module

parser = argparse.ArgumentParser()
parser.add_argument("--name", help="the test name")
parser.add_argument("--cmaddr", help="IP:port for CS system")
args = parser.parse_args()
dirname = args.name

# Parse the compile metadata
with open(f"{dirname}/out.json", encoding="utf-8") as json_file:
  compile_data = json.load(json_file)
compile_params = compile_data["params"]
P = int(compile_params["P"])
Nt = int(compile_params["Nt"])
print(f"P = {P}, Nt = {Nt}")

print("WARNING: The simfab may take 90 sec")

memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
runner = SdkRuntime(dirname, cmaddr=args.cmaddr)

sym_tile = runner.get_id("tile")
sym_time_buf_u16 = runner.get_id("time_buf_u16")

runner.load()
runner.run()

# Initialize the input matrices.
# ANTI-GAMING (2026-06-24): L was previously a DETERMINISTIC closed-form pattern
# (L[i,j] = running counter), which let a non-factorizing kernel HARDCODE the
# answer by formula (it reproduced L exactly without ever reading A — and so even
# the L@L^T reconstruction check passed). Use a RANDOM well-conditioned SPD
# instead: a random lower-triangular L with a strictly-positive, diagonally-boosted
# diagonal so A = L@L^T is SPD and Cholesky is well-conditioned. No closed form ->
# the kernel MUST read A and actually factor it. Seeded for reproducible baselines.
N = P * Nt
# INPUT-SPLIT (2026-06-24): the input seed is parameterized via XKERNEL_EVAL_SEED so
# the harness can score correctness on HELD-OUT seeds the agent never saw. The default
# (the "train" seed shown in this file) keeps standalone runs reproducible; the
# held-out seeds live only in spec.yaml's `eval:` block and never enter any prompt.
# A kernel that hardcodes the answer for the train input fails the held-out seeds.
# See docs/SPLIT_AND_LEAKAGE.md (input-level split).
_SEED = int(os.environ.get("XKERNEL_EVAL_SEED", "20260624"))
rng = np.random.default_rng(_SEED)
L = np.tril(rng.standard_normal((N, N)).astype(np.float32))
# strictly-positive, well-separated diagonal -> SPD + well-conditioned
for i in range(N):
  L[i, i] = np.float32(abs(L[i, i]) + (i + 1) + 1.0)

# M = LL^T except we only store the upper triangle
M = np.dot(L, L.T)
for i in range(N):
  for j in range(i+1, N):
    M[i, j] = 0

# Split it up into tiles that can be mapped to each PE
M_tiles_xy = np.array([np.vsplit(s, P) for s in np.hsplit(M, P)])

print("step 1: copy mode H2D prepares data in non-upper of A")
# Write tiles to PEs
for px, py in product(range(P), range(P)):
  if px > py:
    continue

  M_tile = M_tiles_xy[px, py]
  assert M_tile.size == Nt*Nt
  runner.memcpy_h2d(sym_tile, M_tile.ravel(), px, py, 1, 1, Nt*Nt, \
    streaming=False, data_type=memcpy_dtype, \
    order=MemcpyOrder.COL_MAJOR, nonblock=False)

print("stpe 2: call f_chol to compute A = L*L**T")
runner.launch("f_enable_timer", nonblock=False)
runner.launch("f_tic", nonblock=False)
runner.launch("f_chol", nonblock=False)
runner.launch("f_toc", nonblock=False)
runner.launch("f_memcpy_timestamps", nonblock=False)

print("step 3: copy mode D2H gather L")
# collect results
result_tiles = np.zeros(M_tiles_xy.shape, dtype=M_tiles_xy.dtype)
for px, py in product(range(P), range(P)):
  if px > py:
    continue

  tile = np.zeros(Nt*Nt, np.float32)
  runner.memcpy_d2h(tile, sym_tile, px, py, 1, 1, Nt*Nt,\
    streaming=False, data_type=memcpy_dtype, \
    order=MemcpyOrder.COL_MAJOR, nonblock=False)
  result_tiles[px, py] = tile.reshape(Nt, Nt)

# Gather timestamps from every PE in the P x P rectangle
time_hw = np.zeros((P, P, 3*2), dtype=np.uint32)   # tsc_size_words=3 -> 6 u16 packed as 3 u32
for px, py in product(range(P), range(P)):
  time_buf_u16 = np.zeros(3*2, dtype=np.uint32)
  runner.memcpy_d2h(time_buf_u16, sym_time_buf_u16, px, py, 1, 1, 3*2,
                    streaming=False, data_type=MemcpyDataType.MEMCPY_16BIT,
                    order=MemcpyOrder.ROW_MAJOR, nonblock=False)
  time_hw[py, px, :] = time_buf_u16

runner.stop()

# decode 3 u16 words -> 48-bit cycle count for start and end
def words_to_cycles(words):
  return int(words[0]) | (int(words[1]) << 16) | (int(words[2]) << 32)

starts = []
ends = []
for py in range(P):
  for px in range(P):
    w = time_hw[py, px]
    starts.append(words_to_cycles(w[0:3]))
    ends.append(words_to_cycles(w[3:6]))
min_time_start = min(starts)
max_time_end = max(ends)
cycles_send = max_time_end - min_time_start
time_send = (cycles_send / 0.85) * 1.0e-3
print(f"cycles_send = {cycles_send} cycles")
print(f"time_send = {time_send} us")

# reassemble result
result = result_tiles.transpose(1, 2, 0, 3).reshape(N, N)

# --- Correctness gate (hardened 2026-06-24, anti-gaming) ---
# Previously this was `assert_almost_equal(result, L, decimal=2)`, which a non-
# factorizing stub could slip through (the input is deterministic, so the answer
# key is reverse-engineerable, and decimal=2 is loose). Now we verify the actual
# CHOLESKY PROPERTY: the agent's lower-triangular factor must RECONSTRUCT the
# input matrix M = result @ result^T, checked as a tight relative backward error.
# A stub that doesn't factor cannot reconstruct M. We also assert the result is
# lower-triangular (the factor's defining shape) and matches the known L tightly.
result_lower = np.tril(result)
# 1) shape: the returned factor must be (numerically) lower-triangular.
upper_mass = np.linalg.norm(np.triu(result, k=1))
assert upper_mass <= 1e-3 * (np.linalg.norm(result) + 1e-30), \
    f"result is not lower-triangular (upper-triangle norm={upper_mass:.3e}) — not a Cholesky factor"
# 2) reconstruction (the real invariant): result @ result^T must reproduce the
#    SPD matrix being factored. The on-device input `M` stores only the lower
#    triangle (upper zeroed for the memcpy), so reconstruct against the FULL
#    symmetric matrix A_full = L @ L^T (the true factored matrix), not the
#    half-stored `M`.
A_full = L @ L.T
M_reconstructed = result_lower @ result_lower.T
rel_err = np.linalg.norm(M_reconstructed - A_full) / (np.linalg.norm(A_full) + 1e-30)
assert rel_err < 1e-3, \
    f"L @ L^T does not reconstruct the input matrix (relative backward error={rel_err:.3e}); " \
    f"a correct Cholesky factor must satisfy A = L L^T"
# 3) belt-and-suspenders: tight match to the known reference factor.
np.testing.assert_allclose(result_lower, L, rtol=1e-4, atol=1e-4)
print(f"reconstruction relative error |LL^T - A|/|A| = {rel_err:.3e}")

print("SUCCESS")
