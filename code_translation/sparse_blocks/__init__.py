"""Verified building blocks for the sparse optimization strategies (gate XKERNEL_SPARSE_BLOCKS=1).

Phase 1 of the post-RQ2 plan (2026-10-03). In the optimization runs the format-change and 16-bit-index
strategies were picked often and rarely produced a correct candidate (21 of 23 and 35 of 45 candidates
failed), so the selection was right and the implementation was not. This module gives the optimizer,
for those strategies, a block of CSL that compiled and passed a numerical check on SDK 2.10, together
with what that block measured. The code is cut verbatim from toy/pe.csl (a one-PE toy program with the
tasks' host contract, written for this purpose; no line comes from a task's reference program), and
the numbers come from verified.json (toy/run.py via verify_blocks.py). A block whose toy method failed
verification is never served.

    block_text(angle)    -> text appended to the strategy description in the candidate prompt ("" if none)
    selector_note(angle) -> one-line measured verdict for the selector's strategy list ("" if none)
"""
import json
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
_TOY = os.path.join(HERE, "toy", "pe.csl")
_VERIFIED = os.path.join(HERE, "verified.json")

# strategy -> (toy regions, toy method names that must have verified)
BLOCKS = {
    "vectorise_along_structure": (["vectorise_along_structure"], ["dia_remainder"]),
    "row_dsd_runtime_repoint": (["row_dsd_runtime_repoint"], ["row_dsd"]),
    "index_type_narrowing": (["index_type_narrowing_cast", "index_type_narrowing_shadow"], ["cast16", "shadow16"]),
}


def enabled() -> bool:
    return os.environ.get("XKERNEL_SPARSE_BLOCKS", "0") == "1"


def region(name: str) -> str:
    text = open(_TOY, encoding="utf-8").read()
    m = re.search(rf"// BLOCK {re.escape(name)} BEGIN\n(.*?)// BLOCK {re.escape(name)} END", text, re.S)
    if not m:
        raise KeyError(f"no BLOCK {name} region in {_TOY}")
    return m.group(1).rstrip() + "\n"


def _verified():
    try:
        return json.load(open(_VERIFIED, encoding="utf-8"))["configs"]
    except (OSError, ValueError, KeyError):
        return {}


def _speedups(method: str):
    """{config: {products: speedup over the toy's scalar CSR}} for a method, only if every run of it was correct."""
    out = {}
    for cfg, rec in _verified().items():
        rows = rec.get("methods", [])
        base = {r["products"]: r["cycles"] for r in rows if r["method"] == "scalar_u32"}
        mine = [r for r in rows if r["method"] == method]
        if not mine or not all(r.get("correct") for r in mine):
            return None
        out[cfg] = {r["products"]: base[r["products"]] / r["cycles"] for r in mine if r["products"] in base}
    return out or None


def _measured(angle: str):
    sp = {m: _speedups(m) for m in BLOCKS[angle][1]}
    if any(v is None for v in sp.values()):
        return None
    f = lambda x: f"{x:.2f}x"
    if angle == "vectorise_along_structure":
        a, b = sp["dia_remainder"]["banded_5diag_n128"], sp["dia_remainder"]["banded_25diag_n64"]
        return (f"on a banded toy whose nonzeros lie on 5 diagonals: {f(a[1])} with one product (the conversion "
                f"is charged) and {f(a[10])} with ten; on a toy whose rows spread over 25 diagonals (8 stored as "
                f"diagonals, the rest as remainder): {f(b[10])} with ten. It pays only when a few diagonals hold "
                f"most nonzeros AND the same matrix is multiplied three or more times.")
    if angle == "row_dsd_runtime_repoint":
        a, b = sp["row_dsd"]["banded_5diag_n128"], sp["row_dsd"]["banded_25diag_n64"]
        return (f"{f(a[1])} at 4.5 nonzeros per row and {f(b[1])} at 25: the per-row descriptor setup and the "
                f"scalar sum of the products cost as much as the gather they replace. Expect no gain from this "
                f"form on its own.")
    if angle == "index_type_narrowing":
        c, s = sp["cast16"], sp["shadow16"]
        return (f"narrowing each index after its load: {f(c['banded_5diag_n128'][1])} and {f(c['banded_25diag_n64'][1])}; "
                f"u16 shadow arrays: {f(s['banded_5diag_n128'][1])} with one product and "
                f"{f(s['banded_5diag_n128'][10])}-{f(s['banded_25diag_n64'][10])} with ten. No gain measured: prefer "
                f"other strategies.")
    return None


def selector_note(angle: str) -> str:
    if angle not in BLOCKS:
        return ""
    m = _measured(angle)
    return f"verified block, measured {m}" if m else ""


def block_text(angle: str) -> str:
    if angle not in BLOCKS:
        return ""
    m = _measured(angle)
    if not m:
        return ""
    code = "\n".join(region(r) for r in BLOCKS[angle][0])
    return ("\n\nVERIFIED BUILDING BLOCK for this strategy (a one-PE toy program with the same host contract: "
            "u32 row pointers and column indices, f32 values; it compiled on SDK 2.10 and matched numpy). "
            f"Measured against the toy's textbook scalar CSR loop: {m} Adapt names, sizes and capacities to "
            "this kernel; on a multi-PE kernel the diagonal offset uses the global row (this PE's first row + "
            "local row). Keep the operand forms exactly as shown.\n```csl\n" + code + "```\n")
