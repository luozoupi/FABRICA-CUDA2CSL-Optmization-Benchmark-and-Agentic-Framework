#!/usr/bin/env python3
"""Verbatim code for each phase of the sparse dataflow page, with file and line range.

Same rule as csl_snippets.py: nothing is retyped. A CSL function is cut from its `fn`/`task`
line to its closing brace; a Python function to the next top-level definition; a span by two
anchors. Sources: the three sparse reference kernels and the expert SpGEMM variant in
~/xkernel/kernels, the shared host helpers (sparse_inputs.py), and this study's traced runners.
Output: results/datapath/sparse_snippets.json
"""
import json, re
from pathlib import Path

K = Path.home() / "xkernel/kernels"
STUDY = Path(__file__).resolve().parents[1]

def lines_of(path): return Path(path).read_text().split("\n")

def csl_fn(path, name):
    L = lines_of(path)
    i = next(k for k, l in enumerate(L) if re.search(rf"\b(fn|task)\s+{re.escape(name)}\s*\(", l))
    depth = 0
    for j in range(i, len(L)):
        depth += L[j].count("{") - L[j].count("}")
        if depth == 0 and "{" in "".join(L[i:j + 1]): break
    return i + 1, j + 1, "\n".join(L[i:j + 1])

def py_fn(path, name):
    L = lines_of(path)
    i = next(k for k, l in enumerate(L) if l.startswith(f"def {name}("))
    j = i + 1
    while j < len(L) and not L[j].startswith("def ") and not (L[j] and not L[j][0].isspace() and j > i + 1): j += 1
    while L[j - 1].strip() == "": j -= 1
    return i + 1, j, "\n".join(L[i:j])

def span(path, a, b):
    L = lines_of(path)
    i = next(k for k, l in enumerate(L) if re.search(a, l))
    j = next(k for k in range(i, len(L)) if re.search(b, L[k]))
    return i + 1, j + 1, "\n".join(L[i:j + 1])

SNIP = {
 # ---------- SpMV-RowBlock: 1 x P strip, x multicast on colour 8 ----------
 "spmv_layout_routes": (K / "SpMV-RowBlock/CSL/layout.csl", span, (r"x broadcast routing", r"@set_color_config\(P - 1, 0, C_X")),
 "spmv_fab_dsds":      (K / "SpMV-RowBlock/CSL/pe.csl", span, (r"x as a stream", r"const fab_x_in")),
 "spmv_main":          (K / "SpMV-RowBlock/CSL/pe.csl", csl_fn, ("main",)),
 "spmv_rows":          (K / "SpMV-RowBlock/CSL/pe.csl", csl_fn, ("spmv_rows",)),
 "spmv_queues":        (K / "SpMV-RowBlock/CSL/pe.csl", span, (r"if \(P > 1 and @is_arch", r"@initialize_queue\(@get_input_queue\(2\)")),
 "spmv_host_h2d":      (K / "SpMV-RowBlock/CSL/run.py", span, (r"def h2d_strip", r"# PE 0 only")),
 "spmv_partition":     (K / "SpMV-RowBlock/CSL/sparse_inputs.py", py_fn, ("partition_row_block",)),
 "spmv_pad":           (K / "SpMV-RowBlock/CSL/sparse_inputs.py", py_fn, ("csr_pad",)),
 # ---------- SpMM-CSR-Dense: P x P mesh, no fabric traffic ----------
 "spmm_tile":          (K / "SpMM-CSR-Dense/CSL/pe.csl", csl_fn, ("spmm_tile",)),
 "spmm_main":          (K / "SpMM-CSR-Dense/CSL/pe.csl", csl_fn, ("main",)),
 "spmm_host_tiles":    (K / "SpMM-CSR-Dense/CSL/run.py", span, (r"per-PE host arrays", r"B_tiles\[py, px\] = ")),
 "spmm_host_h2d":      (K / "SpMM-CSR-Dense/CSL/run.py", span, (r"def h2d_mesh", r'h2d_mesh\("B_tile"')),
 # ---------- SpGEMM-Masked-Dot: one PE, CSC, two-pointer merge ----------
 "spgemm_merge":       (K / "SpGEMM-Masked-Dot/CSL/pe.csl", csl_fn, ("spgemm_masked_dot",)),
 "spgemm_compute":     (K / "SpGEMM-Masked-Dot/CSL/pe.csl", csl_fn, ("compute",)),
 "spgemm_host_csc":    (K / "SpGEMM-Masked-Dot/CSL/run.py", span, (r"csc = si\.csc_pad", r"nzombies_ref = ")),
 "spgemm_csc_pad":     (K / "SpGEMM-Masked-Dot/CSL/sparse_inputs.py", py_fn, ("csc_pad",)),
 "spgemm_accum":       (K / "_sparse_expert/SpGEMM-Masked-Dot/pe_dense_accumulator.csl", csl_fn, ("spgemm_masked_dot",)),
 # ---------- this study's traced instances ----------
 "walk_instance":      (STUDY / "microbench/sparse_walk/capture.py", py_fn, ("instance",)),
}

def main():
    out = {}
    for key, (path, fn, args) in SNIP.items():
        a, b, code = fn(path, *args)
        rel = str(path).replace(str(Path.home()), "~")
        out[key] = {"file": rel, "start": a, "end": b, "code": code}
        print(f"  {key:18s} {rel.split('/')[-1]}:{a}-{b}  ({b - a + 1} lines)")
    Path(STUDY / "results/datapath/sparse_snippets.json").write_text(json.dumps(out, indent=1))
    print("-> results/datapath/sparse_snippets.json")

if __name__ == "__main__":
    main()
