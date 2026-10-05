"""Verified building blocks, version 3 (gate XKERNEL_SPARSE_BLOCKS=3): storage formats.

Storage-format study (2026-10-04). Three blocks come from toy/pe.csl, each verified on SDK 2.10 against
numpy for 1 and 10 products (verified.json, three matrices):
  vectorise_along_structure  DIA + the remainder compacted in place (version 2 kept a second copy of the
                             arrays, which the agent's multi-PE versions could not afford, and its
                             remainder loop then visited every nonzero in every product)
  dense_tile_format          dense column-major tile, one @fmacs per column
  block_sparse_format        4x4 BSR, one @fmacs per block column
The verdict of each block is computed from verified.json: the per-product gain over the scalar CSR loop,
the one-time conversion in products, and the break-even. The per-row-DSD and 16-bit-index blocks are
version 2's (sparse_blocks_v2). The two format strategies are new catalog entries, offered only through
XKERNEL_SPARSE_ANGLES_EXTRA in configuration O1B3.
"""
import json
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
_TOY = os.path.join(HERE, "toy", "pe.csl")
_VERIFIED = os.path.join(HERE, "verified.json")

# strategy -> (toy region, method, verified configuration, description of that matrix)
BLOCKS = {
    "vectorise_along_structure": ("vectorise_along_structure", "dia_compact", "banded",
                                  "a 128 x 128 banded matrix whose nonzeros lie on 5 diagonals"),
    "dense_tile_format": ("dense_tile_format", "dense", "random",
                          "a 64 x 64 random matrix with 24% density"),
    "block_sparse_format": ("block_sparse_format", "bsr4", "block",
                            "a 128 x 128 matrix of 90%-full 4x4 blocks"),
}


def enabled() -> bool:
    return os.environ.get("XKERNEL_SPARSE_BLOCKS", "0") == "3"


def region(name: str) -> str:
    text = open(_TOY, encoding="utf-8").read()
    m = re.search(rf"// BLOCK {re.escape(name)} BEGIN\n(.*?)// BLOCK {re.escape(name)} END", text, re.S)
    if not m:
        raise KeyError(f"no BLOCK {name} region in {_TOY}")
    return m.group(1).rstrip() + "\n"


def _economics(method: str, config: str):
    """(per-product gain over CSR, conversion in products, break-even in products, gain at 10 products)."""
    try:
        cfg = json.load(open(_VERIFIED, encoding="utf-8"))["configs"][config]
    except (OSError, ValueError, KeyError):
        return None
    rows = [r for r in cfg.get("rows", []) if "method" in r]
    if not rows or not all(r.get("correct") for r in rows if r["method"] in (method, "csr")):
        return None
    c = {(r["method"], r["products"]): r["cycles"] for r in rows}
    if not all(k in c for k in ((method, 1), (method, 10), ("csr", 1), ("csr", 10))):
        return None
    sweep = (c[(method, 10)] - c[(method, 1)]) / 9
    conv = c[(method, 1)] - sweep
    csr = c[("csr", 1)]
    gain = csr / sweep
    be = conv / (csr - sweep) if csr > sweep else None
    return gain, conv / csr, be, c[("csr", 10)] / c[(method, 10)]


def _measured(angle: str):
    reg, method, config, matrix = BLOCKS[angle]
    e = _economics(method, config)
    if e is None:
        return None
    gain, conv, be, g10 = e
    be_txt = f"it breaks even after {be:.1f} products" if be else "it never breaks even"
    return (f"on {matrix}: {gain:.2f}x faster than the scalar CSR loop per product once converted; the conversion "
            f"costs {conv:.1f} products, so {be_txt} ({g10:.2f}x over ten products, slower for one). Use it only "
            f"when the matrix matches and the same matrix is multiplied several times per launch (the iters "
            f"parameter).")


# Added 2026-10-04 (17:20Z, before the re-run of every O1B3 seed): in the first O1B3 runs the agent adapted
# the dense and BSR blocks correctly but named the kernel function after the toy (spmv_dense, spmv_bsr), so
# the restored frozen wrapper's call to the task's function did not compile, or it built the format inside
# the wrapper, whose edits the harness discards.
INTEGRATION_RULE = ("The toy's function names are its own: keep this kernel's existing kernel function, the "
                    "one the frozen timing wrapper calls, with its name and signature, and call the conversion "
                    "and the new sweep from inside it. The harness restores the frozen wrapper verbatim, so a "
                    "renamed or re-signed kernel function does not compile and code added to the wrapper is "
                    "discarded.")


def _v2():
    import importlib
    return importlib.import_module("sparse_blocks_v2")


def selector_note(angle: str) -> str:
    if angle not in BLOCKS:
        return _v2().selector_note(angle) if angle in _v2().BLOCKS else ""
    m = _measured(angle)
    return f"verified block, measured {m}" if m else ""


def block_text(angle: str) -> str:
    if angle not in BLOCKS:
        return _v2().block_text(angle) if angle in _v2().BLOCKS else ""
    m = _measured(angle)
    if not m:
        return ""
    return ("\n\nVERIFIED BUILDING BLOCK for this strategy (a one-PE toy program with the same host contract: "
            "u32 row pointers and column indices, f32 values; it compiled on SDK 2.10 and matched numpy for one "
            f"and ten products). Measured {m} Adapt names, sizes and capacities to this kernel. Any one-time "
            "conversion is part of the measured work: do it inside the timed kernel function on the first "
            "product and reuse it afterwards, never before the timing window opens (the contract check rejects "
            "that). Keep the operand forms exactly as shown. " + INTEGRATION_RULE +
            "\n```csl\n" + region(BLOCKS[angle][0]) + "```\n")
