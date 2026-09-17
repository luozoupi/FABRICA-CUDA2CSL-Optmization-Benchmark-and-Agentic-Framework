#!/usr/bin/env cs_python
# Copyright 2025 Cerebras Systems. Apache-2.0.
#
# WS2 logical-contract run.py (2026-06-20). The harness owns the LOGICAL problem
# (build A,x,b; reference y = A@x+b; verify; read worst-PE cycles). The PHYSICAL
# distribution onto the PE grid is dependency-injected via distribution.py, which
# the agent generates per its chosen decomposition. The only contract is the
# fixed symbol names (A,x,b,y,time_buf_u16) + launch entrypoints — NOT the PE
# mapping. WS5: correctness is checked across N random seeds (not one baked-in
# case); timing is taken on seed 0 (single timed `main` launch).
import argparse
import importlib.util
import json
import os
import numpy as np

from cerebras.sdk.runtime.sdkruntimepybind import (  # pylint: disable=no-name-in-module
    SdkRuntime, MemcpyDataType, MemcpyOrder,
)

parser = argparse.ArgumentParser()
parser.add_argument("--name", help="the test name")
parser.add_argument("--cmaddr", help="IP:port for CS system")
parser.add_argument("--seed", type=int, default=7,
                    help="single random seed (WS5 multi-seed runs this script N "
                         "times with different --seed; main() is launched once "
                         "per program load — re-launching collectives in one "
                         "session is invalid, so multi-seed is per-process).")
args = parser.parse_args()

with open(f"{args.name}/out.json", encoding="utf-8") as fh:
    params = json.load(fh)["params"]
matrix_rows = int(params["matrix_rows"])
matrix_cols = int(params["matrix_cols"])

# Dependency-inject the physical distribution. Prefer a bundle-local
# distribution.py (the agent's, or the reference's); this is what decouples the
# logical contract from the PE mapping.
_dist_path = os.path.join(args.name, "distribution.py")
if not os.path.isfile(_dist_path):
    _dist_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "distribution.py")
_spec = importlib.util.spec_from_file_location("distribution", _dist_path)
dist = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(dist)

runner = SdkRuntime(args.name, cmaddr=args.cmaddr)
sym = {n: runner.get_id(n) for n in ("A", "x", "b", "y", "time_buf_u16")}
runner.load()
runner.run()

cycles_send = None


def run_once(seed: int, take_time: bool):
    """h2d (via adapter) -> timed main -> d2h (via adapter) -> return y."""
    global cycles_send
    np.random.seed(seed)
    A = np.random.rand(matrix_rows, matrix_cols).astype(np.float32)
    X = np.random.rand(matrix_cols).astype(np.float32)
    B = np.random.rand(matrix_rows).astype(np.float32)
    y_expected = (A @ X) + B
    for nm, arr in (("A", A), ("x", X), ("b", B)):
        flat, w, h, elems, x0, y0 = dist.distribute(nm, arr, params)
        runner.memcpy_h2d(sym[nm], flat, x0, y0, w, h, elems,
                          streaming=False, data_type=dist.DTYPE, nonblock=False, order=dist.ORDER)
    if take_time:
        runner.launch("f_enable_timer", nonblock=False)
        runner.launch("f_tic", nonblock=False)
    runner.launch("main", nonblock=False)
    if take_time:
        runner.launch("f_toc", nonblock=False)
        runner.launch("f_memcpy_timestamps", nonblock=False)
    cx, cy, cw, ch, cel = dist.collect("y", params)
    y = np.zeros(matrix_rows, dtype=np.float32)
    runner.memcpy_d2h(y, sym["y"], cx, cy, cw, ch, cel,
                      streaming=False, data_type=dist.DTYPE, nonblock=False, order=dist.ORDER)
    if take_time:
        kc, kr = dist.grid(params)
        t = np.zeros((kr, kc, 6), dtype=np.uint32)
        runner.memcpy_d2h(t, sym["time_buf_u16"], 0, 0, kc, kr, 6,
                          streaming=False, data_type=MemcpyDataType.MEMCPY_16BIT,
                          nonblock=False, order=MemcpyOrder.ROW_MAJOR)
        th = t.astype(np.uint16)
        def cyc(a): return int(a[0]) | (int(a[1]) << 16) | (int(a[2]) << 32)
        starts = [cyc(th[r, c, 0:3]) for r in range(kr) for c in range(kc)]
        ends = [cyc(th[r, c, 3:6]) for r in range(kr) for c in range(kc)]
        cycles_send = max(ends) - min(starts)
    return y, y_expected


# One timed launch for this seed (main() is non-idempotent for collective
# kernels — must not be re-launched in the same program load). Multi-seed
# coverage = run this script with several --seed values (see commands script).
y, y_exp = run_once(seed=args.seed, take_time=True)
runner.stop()

if cycles_send is not None:
    print(f"cycles_send = {cycles_send} cycles")
    print(f"time_send = {(cycles_send / 0.85) * 1.0e-3} us")
np.testing.assert_allclose(y, y_exp, atol=0.01, rtol=0)
print("SUCCESS")
