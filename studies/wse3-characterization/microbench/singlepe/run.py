#!/usr/bin/env cs_python
"""Shared runner for the single-PE roofline suites."""
import argparse
import json
import struct

import numpy as np
from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType, MemcpyOrder

parser = argparse.ArgumentParser()
parser.add_argument("--suite", required=True, help="suite directory (A, B, C1, C2, D)")
parser.add_argument("--name", default=None, help="compiled out dir (default <suite>/out)")
parser.add_argument("--tag", default="", help="suffix for the results file")
parser.add_argument("--cmaddr")
args = parser.parse_args()

meta = json.load(open(f"{args.suite}/meta.json", encoding="utf-8"))
V = meta["variants"]
out_dir = args.name or f"{args.suite}/out"


def f2h(f):
    return struct.unpack("<I", struct.pack("<f", f))[0]


def u48(w):
    return w[0] | (w[1] << 16) | (w[2] << 32)


import verify
inp = verify.inputs(meta["suite"], meta)

def pack_words(arr, dtype):
    """f16/i16/i8 arrays -> packed u32 words for the 32-bit memcpy path."""
    if dtype == "f16":
        b = np.asarray(arr, dtype=np.float16).tobytes()
    elif dtype == "i16":
        b = np.asarray(arr, dtype=np.int16).tobytes()
    else:
        b = np.asarray(arr, dtype=np.int8).tobytes()
    return np.frombuffer(b, dtype=np.uint32).copy()

def unpack_words(words, dtype, n):
    b = np.asarray(words, dtype=np.uint32).tobytes()
    if dtype == "f16":
        return np.frombuffer(b, dtype=np.float16)[:n].astype(np.float64)
    if dtype == "i16":
        return np.frombuffer(b, dtype=np.int16)[:n]
    return np.frombuffer(b, dtype=np.int8)[:n]

runner = SdkRuntime(out_dir, cmaddr=args.cmaddr)
runner.load()
runner.run()
F32, RM = MemcpyDataType.MEMCPY_32BIT, MemcpyOrder.ROW_MAJOR
for e in meta["exports"]:
    w = pack_words(inp[e["name"]], e["dtype"])
    runner.memcpy_h2d(runner.get_id(e["name"]), w, 0, 0, 1, 1, len(w),
                      streaming=False, data_type=F32, order=RM, nonblock=False)
runner.call("compute", [], nonblock=False)
nw = 3 * len(V)
t = np.zeros(nw, dtype=np.uint32)
runner.memcpy_d2h(t, runner.get_id("maxmin_time"), 0, 0, 1, 1, nw,
                  streaming=False, data_type=F32, order=RM, nonblock=False)
sink = np.zeros(len(V), dtype=np.float32)
runner.memcpy_d2h(sink, runner.get_id("sink"), 0, 0, 1, 1, len(V),
                  streaming=False, data_type=F32, order=RM, nonblock=False)
got_arrays = {}
for e in meta["exports"]:
    nwords = (len(pack_words(inp[e["name"]], e["dtype"])))
    w = np.zeros(nwords, dtype=np.uint32)
    runner.memcpy_d2h(w, runner.get_id(e["name"]), 0, 0, 1, 1, nwords,
                      streaming=False, data_type=F32, order=RM, nonblock=False)
    got_arrays[e["name"]] = unpack_words(w, e["dtype"], e["len"])
runner.stop()

packed = t.view(np.float32)
rows = []
print(f"suite {meta['suite']}{args.tag}")
print(f"{'variant':<16}{'family':<10}{'elems':>7}{'reps':>6}{'cycles':>10}"
      f"{'cyc/elem':>10}{'elem/cyc':>10}")
for i, v in enumerate(V):
    w = np.zeros(6, dtype=np.uint16)
    for j in range(3):
        h = f2h(packed[i * 3 + j])
        w[2 * j] = h & 0xFFFF
        w[2 * j + 1] = (h >> 16) & 0xFFFF
    ww = [int(x) for x in w]
    cyc = u48(ww[3:]) - u48(ww[0:3])
    total = v["elems"] * v["reps"]
    cpe = cyc / total
    rows.append({**v, "cycles": int(cyc), "total_elems": total,
                 "t_start": int(u48(ww[0:3])), "t_end": int(u48(ww[3:])),
                 "cyc_per_elem": round(cpe, 5),
                 "elem_per_cyc": round(1 / cpe, 4) if cpe else None,
                 "sink": float(sink[i])})
    print(f"{v['name']:<16}{v['family']:<10}{v['elems']:>7}{v['reps']:>6}{cyc:>10}"
          f"{cpe:>10.4f}{1/cpe:>10.3f}")

ok, report = verify.check(meta["suite"], meta, inp, got_arrays, {r["name"]: r["sink"] for r in rows})
print(f"\nVERIFICATION {'PASS' if ok else 'FAIL'}  (f16 tolerance {verify.ULP_TOL} ulp; copies and integers bit-exact)")
for name, msg, good in report:
    print(f"  {'ok  ' if good else 'FAIL'} {name:<14} {msg}")

out = f"{args.suite}/results{args.tag}.json"
json.dump({"suite": meta["suite"], "tag": args.tag, "rows": rows,
           "verification": {"pass": bool(ok), "report": [{"item": n, "detail": m, "ok": bool(g)} for n, m, g in report]}},
          open(out, "w", encoding="utf-8"), indent=1)
print(f"wrote {out}")
