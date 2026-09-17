"""GEMV physical-distribution adapter (WS2).

This is the REFERENCE decomposition, extracted from the original run.py so the
logical-contract run.py is decoupled from the physical PE mapping. The W1 agent
does NOT see this file (it writes its own distribution.py for its chosen
decomposition); it is the reference's decomposition, hidden like the reference
pe.csl. run.py imports distribute()/collect() and never hard-codes the reshuffle.

Decomposition: classic cliff/cliff — A split into kernel_rows × kernel_cols
row-major submatrices, one per PE; x,b seeded on PE(0,0) and scattered by the
kernel's collectives; y collected from the bottom-right PE.
"""
from __future__ import annotations
import numpy as np
from cerebras.sdk.runtime.sdkruntimepybind import MemcpyDataType, MemcpyOrder

DTYPE = MemcpyDataType.MEMCPY_32BIT
ORDER = MemcpyOrder.ROW_MAJOR


def grid(params: dict) -> tuple:
    """(w, h) = (kernel_cols, kernel_rows) — the PE rectangle this decomposition uses."""
    return int(params["kernel_cols"]), int(params["kernel_rows"])


def distribute(name: str, arr: np.ndarray, params: dict):
    """Map a logical tensor to (flat_payload, w, h, elems_per_pe, x, y) for h2d.

    `name` is one of the host-visible symbols ('A','x','b'). Returns the memcpy
    geometry for THIS decomposition. The logical-contract run.py calls this and
    issues runner.memcpy_h2d(symbol, flat, x, y, w, h, elems, ...).
    """
    kr = int(params["kernel_rows"]); kc = int(params["kernel_cols"])
    mr = int(params["matrix_rows"]); mc = int(params["matrix_cols"])
    if name == "A":
        per_pe_rows = mr // kr
        per_pe_cols = mc // kc
        flat = np.stack(np.split(np.stack(np.split(arr, kc, axis=1)), kr, axis=1)).ravel()
        return flat, kc, kr, per_pe_rows * per_pe_cols, 0, 0
    if name == "x":
        return arr, 1, 1, mc, 0, 0          # seed on PE(0,0); kernel scatters
    if name == "b":
        return arr, 1, 1, mr, 0, 0
    raise KeyError(name)


def collect(name: str, params: dict):
    """Return (x, y, w, h, elems) for the result d2h. y lives on bottom-right PE."""
    kr = int(params["kernel_rows"]); kc = int(params["kernel_cols"])
    mr = int(params["matrix_rows"])
    if name == "y":
        return kc - 1, kr - 1, 1, 1, mr
    raise KeyError(name)
