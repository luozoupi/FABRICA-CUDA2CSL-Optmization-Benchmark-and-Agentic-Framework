#!/usr/bin/env python3
"""Host driver for Histogram-Inline: multi-PE histogram with host-side
accumulation. No tally module, no fabric reduction.

Each PE bins n_per_pe input elements. The host reads each PE's local
histogram and sums them — all coordination is explicit.
"""

import argparse
import numpy as np
import os
import struct

from cerebras.sdk.runtime.sdkruntimepybind import (
    SdkRuntime, MemcpyDataType, MemcpyOrder,
)

SEED = int(os.environ.get("XKERNEL_EVAL_SEED", "42"))

Py = 4
N_PER_PE = 64
N_BUCKETS = 16
BUCKET_SIZE = 64
N_TOTAL = Py * N_PER_PE


def float_to_u32(f):
    return struct.unpack("I", struct.pack("f", f))[0]


def make_u48(w):
    return int(w[0]) | (int(w[1]) << 16) | (int(w[2]) << 32)


def sub_ts(w):
    return make_u48(w[3:]) - make_u48(w[0:3])


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--name", required=True)
    parser.add_argument("--cmaddr", default=None)
    args = parser.parse_args()

    rng = np.random.default_rng(SEED)
    max_val = N_BUCKETS * BUCKET_SIZE
    input_data = rng.integers(0, max_val, size=N_TOTAL, dtype=np.uint32)

    hist_ref = np.bincount(
        (input_data // BUCKET_SIZE) % N_BUCKETS,
        minlength=N_BUCKETS,
    ).astype(np.uint32)

    memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
    memcpy_order = MemcpyOrder.ROW_MAJOR

    runner = SdkRuntime(args.name, cmaddr=args.cmaddr)

    sym_input = runner.get_id("input")
    sym_hist = runner.get_id("hist")
    sym_time = runner.get_id("maxmin_time")

    runner.load()
    runner.run()

    # H2D: distribute input — each PE(0, py) gets n_per_pe elements
    input_col = input_data.reshape(Py, N_PER_PE)
    runner.memcpy_h2d(sym_input, input_col.ravel().astype(np.uint32),
                      0, 0, 1, Py, N_PER_PE,
                      streaming=False, data_type=memcpy_dtype,
                      order=memcpy_order, nonblock=False)

    # Compute on all PEs
    runner.launch("compute", nonblock=False)

    # D2H: read hist from ALL PEs, then sum on host
    hist_all = np.zeros(Py * N_BUCKETS, dtype=np.uint32)
    runner.memcpy_d2h(hist_all, sym_hist,
                      0, 0, 1, Py, N_BUCKETS,
                      streaming=False, data_type=memcpy_dtype,
                      order=memcpy_order, nonblock=False)

    # D2H: timestamps from all PEs
    time_buf = np.zeros(Py * 3, dtype=np.float32)
    runner.memcpy_d2h(time_buf, sym_time,
                      0, 0, 1, Py, 3,
                      streaming=False, data_type=memcpy_dtype,
                      order=memcpy_order, nonblock=False)

    runner.stop()

    # Sum partial histograms from all PEs
    hist_device = hist_all.reshape(Py, N_BUCKETS).sum(axis=0).astype(np.uint32)

    print(f"hist_ref    = {hist_ref}")
    print(f"hist_device = {hist_device}")

    np.testing.assert_array_equal(hist_device, hist_ref)
    print("\nSUCCESS!")

    # Extract cycles
    starts = []
    ends = []
    for py in range(Py):
        raw = time_buf[py * 3: (py + 1) * 3]
        words = np.zeros(6, dtype=np.uint16)
        for k in range(3):
            u = float_to_u32(float(raw[k]))
            words[2 * k] = u & 0xFFFF
            words[2 * k + 1] = (u >> 16) & 0xFFFF
        starts.append(make_u48(words[:3]))
        ends.append(make_u48(words[3:]))
        c = sub_ts(words)
        print(f"  PE(0,{py}): {c} cycles")

    cycles_send = max(ends) - min(starts)
    print(f"cycles_send = {cycles_send} cycles")


if __name__ == "__main__":
    main()
