#!/usr/bin/env python3
"""Turn the measured single-PE SRAM budget into usable matrix shapes.

The budget is not a datasheet number.  `microbench/capacity/` bisects the largest
allocation `cslc` will link, to the word:

    22,488 u16 words  -> 49,152 bytes total  -> links
    22,496 u16 words  -> "ld.lld: ran out of PE memory"

so the PE holds exactly 48 KiB and a minimal `<memcpy>` kernel costs 4,176 bytes
of it, leaving 44,976 bytes for application data.  A kernel with real code costs
more: MeshGEMM's application PE occupies 8,336 bytes total against 2,560 bytes of
named tiles, i.e. ~5,776 bytes of code and runtime.  Both budgets are reported,
because quoting only the minimal one would overstate what a real kernel can hold.

Evidence: `compiled`.  These are link-time limits, not runtime measurements.
"""

from __future__ import annotations

import argparse
import json
import math

PE_SRAM_BYTES = 49_152          # measured, exact
MINIMAL_OVERHEAD = 4_176        # measured: constant across the whole sweep
MESHGEMM_OVERHEAD = 5_776       # 8,336 B app PE - 2,560 B of named tiles

DTYPES = {"f16": 2, "f32": 4}


def square_gemv(budget_elems: int) -> int:
    """W[n*n] + x[n] + y[n] <= budget."""
    n = int((math.sqrt(1 + budget_elems) - 1))
    while (n + 1) ** 2 + 2 * (n + 1) <= budget_elems:
        n += 1
    while n > 0 and n * n + 2 * n > budget_elems:
        n -= 1
    return n


def square_gemm(budget_elems: int) -> int:
    """A[n*n] + B[n*n] + C[n*n] <= budget."""
    n = int(math.sqrt(budget_elems / 3))
    while 3 * (n + 1) ** 2 <= budget_elems:
        n += 1
    while n > 0 and 3 * n * n > budget_elems:
        n -= 1
    return n


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--json", help="write the table here")
    a = ap.parse_args()

    print(f"PE SRAM                 {PE_SRAM_BYTES:,} bytes (48 KiB, measured to the byte)")
    print(f"minimal kernel overhead {MINIMAL_OVERHEAD:,} bytes")
    print(f"MeshGEMM-like overhead  {MESHGEMM_OVERHEAD:,} bytes\n")

    out = {"pe_sram_bytes": PE_SRAM_BYTES, "evidence": "compiled", "budgets": {}}
    print(f"{'kernel shape':<26}{'dtype':>6}{'minimal':>12}{'realistic':>12}")
    for label, overhead in (("minimal", MINIMAL_OVERHEAD), ("realistic", MESHGEMM_OVERHEAD)):
        out["budgets"][label] = {"overhead_bytes": overhead,
                                 "application_bytes": PE_SRAM_BYTES - overhead}
    for dt, size in DTYPES.items():
        b_min = (PE_SRAM_BYTES - MINIMAL_OVERHEAD) // size
        b_real = (PE_SRAM_BYTES - MESHGEMM_OVERHEAD) // size
        rows = [("dense vector (n)", b_min, b_real),
                ("square GEMV (n x n)", square_gemv(b_min), square_gemv(b_real)),
                ("square GEMM (n x n x n)", square_gemm(b_min), square_gemm(b_real))]
        for name, v1, v2 in rows:
            print(f"{name:<26}{dt:>6}{v1:>12,}{v2:>12,}")
            out.setdefault("shapes", {}).setdefault(dt, {})[name] = {
                "minimal": v1, "realistic": v2}
        print()

    # "How many elements at once" has three different answers; conflating them
    # is the easy mistake, so all three are printed with their binding constraint.
    print("Largest single dispatch (one instruction, hardware-looped):")
    print(f"  {'operands':<34}{'f16':>10}{'f32':>10}   binding constraint")
    for label, k in (("1 (fill, e.g. @fmovh)", 1), ("2 (e.g. @fmulh)", 2),
                     ("3 (FMA, e.g. @fmach)", 3)):
        f16 = (PE_SRAM_BYTES - MINIMAL_OVERHEAD) // (k * 2)
        f32 = (PE_SRAM_BYTES - MINIMAL_OVERHEAD) // (k * 4)
        print(f"  {label:<34}{f16:>10,}{f32:>10,}   PE memory, not DSD extent")
    print("  measured: 3-operand f16 FMA links at n=7,492 and fails at n=7,496")
    print("  the DSD extent field is NOT the limit -- cslc accepts 262,143 and does")
    print("  not bounds-check extent against the backing array; memory binds first.\n")
    print("Peak rate (elements retired per cycle, from the fitted cost model):")
    print("  f16 FMA  4.00 simulator / 2.92 silicon      f32 FMA  0.50 both")
    print("  SIMD lanes 0-7 observed in the pipe trace's simdi field.\n")

    out["single_dispatch"] = {
        "note": "bounded by PE memory, not by the DSD extent field",
        "f16_1_operand": (PE_SRAM_BYTES - MINIMAL_OVERHEAD) // 2,
        "f16_3_operand_measured": 7492,
        "dsd_extent_compiles_to": 262143,
        "dsd_extent_bounds_checked": False}

    print("Wafer:")
    print("  cslc does NOT validate --fabric-dims: 762x1172, 1024x1024, 1500x1500 and")
    print("  2048x2048 all link. The fabric size is a declared canvas, not a checked")
    print("  hardware bound, so a wafer capacity figure cannot be derived from the")
    print("  compiler. It needs an appliance run -- not established here.")
    print(f"  PE overhead tax: a 1-PE kernel occupies 24 PEs, 23 of them <memcpy> plumbing.")
    out["wafer"] = {"cslc_validates_fabric_dims": False,
                    "largest_tested_ok": "2048x2048",
                    "documented_compiler_fabric": "762x1172",
                    "pes_per_1pe_kernel": 24,
                    "note": "real wafer bound requires an appliance run; not established"}

    if a.json:
        with open(a.json, "w", encoding="utf-8") as fh:
            json.dump(out, fh, indent=1)
        print(f"\nwrote {a.json}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
