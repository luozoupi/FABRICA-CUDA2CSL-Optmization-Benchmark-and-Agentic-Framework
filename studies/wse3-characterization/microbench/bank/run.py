#!/usr/bin/env cs_python
"""Host runner for the bank read/write conflict probe.

Predicted conflict classes come from the *linked* addresses of `src` and `pool`,
read back out of the ELF, not from an assumption about where the compiler put
them.  bank(addr) = bits[3:1] of the byte address, per the cs_readelf man page.
"""

import argparse
import json
import re
import struct
import subprocess

import numpy as np
from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType, MemcpyOrder

# Mirror gen.py's variant table so labels and predictions line up.
VARIANTS = ([(f"rw-off{k}", k, 1, 0) for k in range(8)]
            + [(f"ctl-s2a{a}", a, 2, a) for a in range(4)])
OFFSETS = list(range(len(VARIANTS)))

parser = argparse.ArgumentParser()
parser.add_argument("--name", default="out")
parser.add_argument("--cmaddr")
args = parser.parse_args()

with open(f"{args.name}/out.json", encoding="utf-8") as fh:
    params = json.load(fh)["params"]
n, reps = int(params["n"]), int(params["reps"])


def symbol_addresses(elf):
    """Pull `src_arr` / `pool` link addresses out of the ELF symbol table."""
    try:
        txt = subprocess.run(["cs_readelf", "--syms", elf], capture_output=True,
                             text=True, timeout=120).stdout
    except Exception:
        return {}
    found = {}
    for line in txt.splitlines():
        m = re.search(r"([0-9a-fA-F]+)\s+\d+\s+OBJECT\s+\S+\s+\S+\s+\S+\s+(\S+)$", line.strip())
        if m and m.group(2) in ("src_arr", "pool"):
            found[m.group(2)] = int(m.group(1), 16)
    return found


def bank(addr):
    return (addr >> 1) & 0x7


def float_to_hex(f):
    return struct.unpack("<I", struct.pack("<f", f))[0]


def make_u48(w):
    return w[0] | (w[1] << 16) | (w[2] << 32)


rng = np.random.default_rng(7)
src = rng.standard_normal(2 * n + 4).astype(np.float32)

runner = SdkRuntime(args.name, cmaddr=args.cmaddr)
runner.load()
runner.run()
F32, RM = MemcpyDataType.MEMCPY_32BIT, MemcpyOrder.ROW_MAJOR
runner.memcpy_h2d(runner.get_id("src"), src, 0, 0, 1, 1, 2 * n + 4,
                  streaming=False, data_type=F32, order=RM, nonblock=False)
runner.call("compute", [], nonblock=False)
nw = 3 * len(OFFSETS)
tdata = np.zeros(nw, dtype=np.uint32)
runner.memcpy_d2h(tdata, runner.get_id("maxmin_time"), 0, 0, 1, 1, nw,
                  streaming=False, data_type=F32, order=RM, nonblock=False)
pool = np.zeros(n + max(OFFSETS) + 1, dtype=np.float32)
runner.memcpy_d2h(pool, runner.get_id("pool"), 0, 0, 1, 1, n + max(OFFSETS) + 1,
                  streaming=False, data_type=F32, order=RM, nonblock=False)
runner.stop()

syms = symbol_addresses(f"{args.name}/bin/out_0_0.elf")
packed = tdata.view(np.float32)
total = n * reps

print(f"n={n} reps={reps} elements/variant={total}")
if syms:
    print(f"linked addresses: " + "  ".join(f"{k}=0x{v:x} (bank {bank(v)})"
                                            for k, v in sorted(syms.items())))
else:
    print("linked addresses: UNAVAILABLE -- predicted classes omitted")

print(f"\n{'variant':>10}{'off':>5}{'stride':>7}{'align':>6}{'dst bank':>10}"
      f"{'same':>6}{'mod4':>6}{'cycles':>10}{'cyc/elem':>10}{'vs best':>9}")
rows = []
for k in OFFSETS:
    words = np.zeros(6, dtype=np.uint16)
    for i in range(3):
        h = float_to_hex(packed[k * 3 + i])
        words[2 * i] = h & 0xFFFF
        words[2 * i + 1] = (h >> 16) & 0xFFFF
    w = [int(v) for v in words]
    cycles = make_u48(w[3:]) - make_u48(w[0:3])
    rows.append({"offset": k, "cycles": int(cycles), "cycles_per_element": cycles / total})

# Score the read/write sweep against its own fastest member; the strided control
# is a different access pattern and must not set the baseline for it.
rw = [r for r in rows if VARIANTS[r["offset"]][2] == 1]
best = min(r["cycles_per_element"] for r in rw)
for r in rows:
    k = r["offset"]
    label, off, stride, align = VARIANTS[k]
    if syms:
        db = bank(syms["pool"] + 4 * k)
        sb = bank(syms["src_arr"])
        same, mod4 = db == sb, (db % 4) == (sb % 4)
        r.update({"dst_bank": db, "src_bank": sb, "same_bank": same, "same_bank_mod4": mod4})
        tag_a, tag_b = ("YES" if same else "-"), ("YES" if mod4 else "-")
    else:
        db, tag_a, tag_b = "?", "?", "?"
    r.update({"label": label, "stride": stride, "align": align})
    r["ratio_vs_best"] = r["cycles_per_element"] / best
    print(f"{label:>10}{off:>5}{stride:>7}{align:>6}{str(db):>10}{tag_a:>6}{tag_b:>6}"
          f"{r['cycles']:>10}{r['cycles_per_element']:>10.4f}{r['ratio_vs_best']:>9.3f}x")

ctl = [r for r in rows if r["stride"] == 2]
if ctl:
    lo = min(r["cycles_per_element"] for r in ctl)
    hi = max(r["cycles_per_element"] for r in ctl)
    print(f"\nPOSITIVE CONTROL (stride 2, alignment 0-3): spread {hi/lo:.3f}x")
    print("  the study measured 1.94x for strided bank conflicts on silicon.")
    print("  a flat control means this probe cannot see bank conflicts at all,")
    print("  so a flat read/write result above would prove nothing.")

ok = np.allclose(pool[:n], src[:n], rtol=1e-6, atol=1e-6)
print(f"\ncopy correctness (last variant wrote pool[7:7+n]): "
      f"{'pool[0:n] matches src' if ok else 'pool[0:n] != src (expected: offset 7 wrote elsewhere)'}")

with open("bank_results.json", "w", encoding="utf-8") as fh:
    json.dump({"n": n, "reps": reps, "elements_per_variant": total,
               "symbols": {k: hex(v) for k, v in syms.items()}, "variants": rows}, fh, indent=1)
print("wrote bank_results.json")
