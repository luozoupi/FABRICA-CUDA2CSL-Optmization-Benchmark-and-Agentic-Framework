#!/usr/bin/env python3
"""Host driver for GEMV-RowPart: y = A*x, row-partitioned across Py PEs.

Each PE holds rows_per_pe rows of A and the full vector x. The host
distributes A rows via H2D and reads y chunks per PE via D2H — no
distribution module or collectives needed.
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
ROWS_PER_PE = 8
N = 8
M = Py * ROWS_PER_PE  # total rows


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
    A = rng.standard_normal((M, N)).astype(np.float32)
    x = rng.standard_normal(N).astype(np.float32)
    y_ref = A @ x

    memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
    memcpy_order = MemcpyOrder.ROW_MAJOR

    runner = SdkRuntime(args.name, cmaddr=args.cmaddr)

    sym_A = runner.get_id("A")
    sym_x = runner.get_id("x")
    sym_y = runner.get_id("y")
    sym_time = runner.get_id("maxmin_time")

    runner.load()
    runner.run()

    # H2D: distribute A rows — each PE(0, py) gets rows [py*rpp : (py+1)*rpp]
    # memcpy_h2d with width=1, height=Py, elems=rows_per_pe*N distributes
    # in row-major order: first Py*1 tile of rows_per_pe*N f32 each.
    A_col = A.reshape(Py, ROWS_PER_PE * N)
    runner.memcpy_h2d(sym_A, A_col.ravel().astype(np.float32),
                      0, 0, 1, Py, ROWS_PER_PE * N,
                      streaming=False, data_type=memcpy_dtype,
                      order=memcpy_order, nonblock=False)

    # H2D: broadcast x to all PEs — send same x to each PE
    x_broadcast = np.tile(x, Py).astype(np.float32)
    runner.memcpy_h2d(sym_x, x_broadcast,
                      0, 0, 1, Py, N,
                      streaming=False, data_type=memcpy_dtype,
                      order=memcpy_order, nonblock=False)

    # Compute
    runner.launch("compute", nonblock=False)

    # D2H: read y from all PEs
    y_device = np.zeros(M, dtype=np.float32)
    runner.memcpy_d2h(y_device, sym_y,
                      0, 0, 1, Py, ROWS_PER_PE,
                      streaming=False, data_type=memcpy_dtype,
                      order=memcpy_order, nonblock=False)

    # D2H: read timestamps
    time_buf = np.zeros(Py * 3, dtype=np.float32)
    runner.memcpy_d2h(time_buf, sym_time,
                      0, 0, 1, Py, 3,
                      streaming=False, data_type=memcpy_dtype,
                      order=memcpy_order, nonblock=False)

    runner.stop()

    # Reshape y from column order
    y_result = y_device.reshape(Py, ROWS_PER_PE).ravel()

    print(f"y_ref[:8]   = {y_ref[:8]}")
    print(f"y_device[:8]= {y_result[:8]}")

    np.testing.assert_allclose(y_result, y_ref, rtol=1e-4, atol=1e-5)
    print("\nSUCCESS!")

    # Extract cycles from per-PE timestamps
    cycles_list = []
    for py in range(Py):
        raw = time_buf[py * 3: (py + 1) * 3]
        words = np.zeros(6, dtype=np.uint16)
        for k in range(3):
            u = float_to_u32(float(raw[k]))
            words[2 * k] = u & 0xFFFF
            words[2 * k + 1] = (u >> 16) & 0xFFFF
        c = sub_ts(words)
        cycles_list.append(c)
        print(f"  PE(0,{py}): {c} cycles")

    starts = [make_u48(np.zeros(6, dtype=np.uint16)) for _ in range(Py)]
    ends = []
    for py in range(Py):
        raw = time_buf[py * 3: (py + 1) * 3]
        words = np.zeros(6, dtype=np.uint16)
        for k in range(3):
            u = float_to_u32(float(raw[k]))
            words[2 * k] = u & 0xFFFF
            words[2 * k + 1] = (u >> 16) & 0xFFFF
        ends.append(make_u48(words[3:]))
        starts[py] = make_u48(words[:3])

    cycles_send = max(ends) - min(starts)
    print(f"cycles_send = {cycles_send} cycles")


if __name__ == "__main__":
    main()
