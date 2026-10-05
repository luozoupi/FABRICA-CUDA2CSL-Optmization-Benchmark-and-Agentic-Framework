#!/usr/bin/env python3
"""Pull verbatim code for each dataflow phase out of the WaferLLM sources, with the file
and line range, so every step of the diagram can be checked against the code that runs.
Nothing here is retyped: a snippet is located by its anchor and cut to its closing brace
(CSL) or to the next top-level definition (Python)."""
import json, re
from pathlib import Path

W = Path.home() / "waferllm"

def csl_fn(path, name):
    lines = (W / path).read_text().split("\n")
    i = next(k for k, l in enumerate(lines) if re.search(rf"\b(fn|task)\s+{re.escape(name)}\s*\(", l))
    depth = 0; j = i
    for j in range(i, len(lines)):
        depth += lines[j].count("{") - lines[j].count("}")
        if depth == 0 and "{" in "".join(lines[i:j + 1]): break
    return i + 1, j + 1, "\n".join(lines[i:j + 1])

def py_fn(path, name):
    lines = (W / path).read_text().split("\n")
    i = next(k for k, l in enumerate(lines) if l.startswith(f"def {name}("))
    j = i + 1
    while j < len(lines) and not lines[j].startswith("def ") and not (lines[j] and not lines[j][0].isspace() and j > i + 1):
        j += 1
    while lines[j - 1].strip() == "": j -= 1
    return i + 1, j, "\n".join(lines[i:j])

def span(path, start_pat, end_pat):
    lines = (W / path).read_text().split("\n")
    i = next(k for k, l in enumerate(lines) if re.search(start_pat, l))
    j = next(k for k in range(i + 1, len(lines)) if re.search(end_pat, lines[k]))
    return i + 1, j + 1, "\n".join(lines[i:j + 1])

SNIP = {
 # ---------- MeshGEMM ----------
 "gemm_inputs":    ("MeshGEMM/host_common.py", py_fn, ("make_inputs",)),
 "gemm_shift":     ("MeshGEMM/src/comm_lib/comm_pe.csl", csl_fn, ("left_matrix_shift",)),
 "gemm_host_load": ("MeshGEMM/launch_sim.py", span, (r"X_u32 = input_array_to_u32", r"runner\.memcpy_h2d\(sym_W")),
 "gemm_host_tile": ("MeshGEMM/host_common.py", py_fn, ("tile_X",)),
 "gemm_host_wofs": ("MeshGEMM/host_common.py", span, (r"tensor_W_offset = np\.zeros", r"return tensor_X, tensor_W, tensor_W_offset")),
 "gemm_skew":      ("MeshGEMM/src/meshgemm.csl", csl_fn, ("left_matrix_shift_callback",)),
 "gemm_step":      ("MeshGEMM/src/meshgemm.csl", csl_fn, ("mm_compute",)),
 "gemm_fma":       ("MeshGEMM/src/meshgemm.csl", csl_fn, ("gemv_static_step_X",)),
 "gemm_comm":      ("MeshGEMM/src/comm_lib/comm_pe.csl", csl_fn, ("two_hop_comm",)),
 "gemm_routes":    ("MeshGEMM/src/layout.csl", span, (r"if \(px % 2 == 0\) \{", r"x_shift_re_tran_color, \.\{ \.routes = \.\{ \.rx = \.\{WEST\}")),
 "gemm_host_read": ("MeshGEMM/launch_sim.py", span, (r"res_1d_u32 = np\.zeros", r"res = hc\.untile_res")),
 # ---------- MeshGEMV ----------
 "gemv_host_load": ("MeshGEMV/host_common.py", py_fn, ("make_inputs",)),
 "gemv_host_h2d":  ("MeshGEMV/launch_sim.py", span, (r"X_u32 = input_array_to_u32", r"runner\.memcpy_h2d\(sym_W")),
 "gemv_host_read": ("MeshGEMV/launch_sim.py", span, (r"res_1d_u32 = np\.zeros", r"time_ref_hwl = np\.reshape")),
 "gemv_fma":       ("MeshGEMV/src/meshgemv.csl", csl_fn, ("gemv_static_step",)),
 "gemv_step":      ("MeshGEMV/src/meshgemv.csl", csl_fn, ("mv_compute",)),
 "gemv_bcast":     ("MeshGEMV/src/layout.csl", span, (r"@set_color_config\(px, py, C_U_B, \.\{ \.routes = \.\{ \.rx = \.\{RAMP\}", r"C_D_B, \.\{ \.routes = \.\{ \.rx = \.\{NORTH\}, \.tx = \.\{RAMP, SOUTH\}")),
}

def main():
    out = {}
    for key, (path, fn, args) in SNIP.items():
        a, b, code = fn(path, *args)
        out[key] = {"file": f"~/waferllm/{path}", "start": a, "end": b, "code": code}
        print(f"  {key:15s} {path}:{a}-{b}  ({b - a + 1} lines)")
    # the allreduce entry point name varies; locate it by search
    comm = (W / "MeshGEMV/src/comm_lib/comm_pe.csl").read_text()
    name = re.search(r"fn\s+(two_tree_allreduce\w*)\s*\(", comm).group(1)
    a, b, code = csl_fn("MeshGEMV/src/comm_lib/comm_pe.csl", name)
    out["gemv_reduce"] = {"file": "~/waferllm/MeshGEMV/src/comm_lib/comm_pe.csl", "start": a, "end": b, "code": code}
    print(f"  {'gemv_reduce':15s} comm_pe.csl:{a}-{b}  ({b - a + 1} lines) [{name}]")
    Path("results/datapath/csl_snippets.json").write_text(json.dumps(out, indent=1))
    print("-> results/datapath/csl_snippets.json")

if __name__ == "__main__":
    main()
