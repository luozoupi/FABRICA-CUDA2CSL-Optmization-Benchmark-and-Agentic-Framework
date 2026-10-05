#!/usr/bin/env cs_python
"""Loop-form probe runner: cycles per FP element at each nesting depth."""
import argparse
import json
import struct
import numpy as np
from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType, MemcpyOrder

meta = json.load(open("meta.json", encoding="utf-8"))
V, TOTAL = meta["variants"], meta["total_elements"]

parser = argparse.ArgumentParser()
parser.add_argument("--name", default="out")
parser.add_argument("--cmaddr")
args = parser.parse_args()


def float_to_hex(f):
    return struct.unpack("<I", struct.pack("<f", f))[0]


def make_u48(w):
    return w[0] | (w[1] << 16) | (w[2] << 32)


runner = SdkRuntime(args.name, cmaddr=args.cmaddr)
runner.load()
runner.run()
runner.call("compute", [], nonblock=False)
nw = 3 * len(V)
t = np.zeros(nw, dtype=np.uint32)
runner.memcpy_d2h(t, runner.get_id("maxmin_time"), 0, 0, 1, 1, nw,
                  streaming=False, data_type=MemcpyDataType.MEMCPY_32BIT,
                  order=MemcpyOrder.ROW_MAJOR, nonblock=False)
runner.stop()

packed = t.view(np.float32)
print(f"{TOTAL} f16 FMA elements per variant\n")
print(f"{'form':<6}{'software loops':>16}{'cycles':>10}{'cyc/FP elem':>14}{'vs L0':>9}")
rows, base = [], None
DESC = {"L0": 0, "L1": 1, "L2": 2, "L3": 3}
for i, v in enumerate(V):
    w = np.zeros(6, dtype=np.uint16)
    for j in range(3):
        h = float_to_hex(packed[i * 3 + j])
        w[2 * j] = h & 0xFFFF
        w[2 * j + 1] = (h >> 16) & 0xFFFF
    ww = [int(x) for x in w]
    cyc = make_u48(ww[3:]) - make_u48(ww[0:3])
    per = cyc / TOTAL
    if base is None:
        base = per
    rows.append({"form": v, "software_loops": DESC[v], "cycles": int(cyc),
                 "cycles_per_element": round(per, 4), "vs_L0": round(per / base, 2)})
    print(f"{v:<6}{DESC[v]:>16}{cyc:>10}{per:>14.4f}{per/base:>8.2f}x")

json.dump({"total_elements": TOTAL, "variants": rows},
          open("loopform_results.json", "w", encoding="utf-8"), indent=1)
print("\nwrote loopform_results.json")
