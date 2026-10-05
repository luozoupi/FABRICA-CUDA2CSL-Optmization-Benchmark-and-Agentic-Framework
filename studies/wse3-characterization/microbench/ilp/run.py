#!/usr/bin/env cs_python
"""Host runner for the ILP microbench.

Reports cycles per FMA at each dependency depth.  Every variant issues the same
number of instructions, so differences are attributable to the dependency
structure alone.
"""

import argparse
import json
import struct

import numpy as np
from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType, MemcpyOrder

VARIANTS = [1, 2, 4, 8]
FMAS_PER_ITER = 8

parser = argparse.ArgumentParser()
parser.add_argument("--name", default="out")
parser.add_argument("--cmaddr")
args = parser.parse_args()

with open(f"{args.name}/out.json", encoding="utf-8") as fh:
    iters = int(json.load(fh)["params"]["iters"])
total_fmas = iters * FMAS_PER_ITER


def float_to_hex(f):
    return struct.unpack("<I", struct.pack("<f", f))[0]


def make_u48(w):
    return w[0] | (w[1] << 16) | (w[2] << 32)


runner = SdkRuntime(args.name, cmaddr=args.cmaddr)
runner.load()
runner.run()
F32, RM = MemcpyDataType.MEMCPY_32BIT, MemcpyOrder.ROW_MAJOR
runner.memcpy_h2d(runner.get_id("coef"), np.array([1.0009765625, 0.5], dtype=np.float32),
                  0, 0, 1, 1, 2, streaming=False, data_type=F32, order=RM, nonblock=False)
runner.call("compute", [], nonblock=False)

n_words = 3 * len(VARIANTS)
tdata = np.zeros(n_words, dtype=np.uint32)
runner.memcpy_d2h(tdata, runner.get_id("maxmin_time"), 0, 0, 1, 1, n_words,
                  streaming=False, data_type=F32, order=RM, nonblock=False)
sink = np.zeros(len(VARIANTS), dtype=np.float32)
runner.memcpy_d2h(sink, runner.get_id("sink"), 0, 0, 1, 1, len(VARIANTS),
                  streaming=False, data_type=F32, order=RM, nonblock=False)
runner.stop()

packed = tdata.view(np.float32)
print(f"iters={iters}  FMAs/iter={FMAS_PER_ITER}  total FMAs/variant={total_fmas}")
print(f"{'chains':>7}{'depth':>7}{'cycles':>10}{'cyc/FMA':>10}   speedup vs k1")
base = None
rows = []
for idx, k in enumerate(VARIANTS):
    words = np.zeros(6, dtype=np.uint16)
    for i in range(3):
        h = float_to_hex(packed[idx * 3 + i])
        words[2 * i] = h & 0xFFFF
        words[2 * i + 1] = (h >> 16) & 0xFFFF
    w = [int(v) for v in words]
    cycles = make_u48(w[3:]) - make_u48(w[0:3])
    per = cycles / total_fmas
    if base is None:
        base = per
    rows.append({"chains": k, "depth": FMAS_PER_ITER // k,
                 "cycles": int(cycles), "cycles_per_fma": round(per, 3),
                 "speedup_vs_k1": round(base / per, 3)})
    print(f"{k:>7}{FMAS_PER_ITER // k:>7}{cycles:>10}{per:>10.3f}   {base / per:>6.2f}x")

# sink is read back purely so the compiler cannot eliminate the loops; a NaN or
# zero here means a variant was optimised away and its timing is meaningless.
print(f"\nsink = {sink}")
if not np.all(np.isfinite(sink)) or np.any(sink == 0):
    print("WARNING: a sink slot is zero/non-finite -- that variant may have been "
          "eliminated; its cycle count is not trustworthy")

with open("ilp_results.json", "w", encoding="utf-8") as fh:
    json.dump({"iters": iters, "fmas_per_iter": FMAS_PER_ITER,
               "total_fmas_per_variant": total_fmas,
               "sink": [float(v) for v in sink], "variants": rows}, fh, indent=1)
print("wrote ilp_results.json")
