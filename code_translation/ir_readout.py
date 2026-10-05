#!/usr/bin/env python3
"""IR/disassembly readout: what the compiler made of the agent's CSL (v2 sparse study).

Inputs are the artifacts `ir_capture.py` leaves under `<bundle>/.xkernel_ir/`: the LLVM
IR `cslc-driver` emitted for the application PE program (`cap/<program>/program.ll`) and
the `csdisasm/1` records of the measured ELF (`disasm/<elf>.json`). Everything here is
line/regex based (there is no LLVM parser for the Cerebras target) and is evidence class
`compiled`: it describes Cerebras's own toolchain output, nothing is emulated.

Facts per target-file function: loops and nesting depth (back-edges), DSD intrinsics by
family (`@llvm.sdr.*`), scalar loads/stores/FP ops inside loops, indexed gathers
(`load` -> `getelementptr` -> `load float`), descriptor setup inside loops, f32 register
reductions (`fadds.rrs1`, `fmacs.rr*`) and their accumulator pattern, `optnone`.
Facts from the disassembly: mnemonic histogram, DSD-operand instructions, scale-and-narrow
shift pairs per FP multiply (FINDINGS section 12c rule M5), and the f32 DSD-reduction HAZARD:
`fadds dN = dM, [...]` with N != M silently returns the last element instead of the sum and is
faster than the correct form (FINDINGS section 10n).

`ir_keys` feed the optimizer's angle matcher next to the silicon model's `model_*` keys and
the structure readout's `struct_*` keys; `format_ir_readout` is the prompt paragraph.
"""
from __future__ import annotations

import json
import os
import re
from collections import Counter
from pathlib import Path
from typing import Dict, List, Optional

SCHEMA = "ir_readout/1"
IR_KEYS = ("ir_no_dsd_ops", "ir_scalar_inner_loop", "ir_indexed_gather", "ir_index_shift_heavy",
           "ir_dsd_setup_in_loop", "ir_f32_reduction_candidate", "ir_f32_reduction_hazard",
           "ir_hot_line_scalar", "ir_branch_heavy")

_DEFINE_RE = re.compile(r"^define\s[^\n]*?@\"?([^\s(\"]+)\"?\(([^\n]*)\{\s*$", re.M)
_LABEL_RE = re.compile(r"^([A-Za-z0-9_.$\"]+):")
_BR_TARGETS_RE = re.compile(r"label\s+%([A-Za-z0-9_.$]+)")
_SDR_RE = re.compile(r"@llvm\.sdr\.([A-Za-z0-9_.]+)")
_DBG_RE = re.compile(r"!dbg\s+!(\d+)")
_SUBPROGRAM_RE = re.compile(r"^!(\d+)\s*=\s*(?:distinct\s+)?!DISubprogram\((.*)\)\s*$", re.M)
_DIFILE_RE = re.compile(r"^!(\d+)\s*=\s*!DIFile\(filename:\s*\"([^\"]*)\"", re.M)
_ATTR_GROUP_RE = re.compile(r"^attributes\s+#(\d+)\s*=\s*\{([^}]*)\}", re.M)
_DESC_TYPE = "<{ i16, i16, i16, i16 }>"
_HAZARD_RE = re.compile(r"^(fadd[sh]|fmac[sh]|fsub[sh])\s+d(\d+)\s*=\s*d(\d+)\s*,\s*\[")
_SHIFT_MNEMONICS = ("sll16", "slr16", "sll32", "slr32", "shl", "shr", "sra16")
_FPMUL_MNEMONICS = ("fmuls", "fmulh", "fmacs", "fmach")


# --------------------------------------------------------------------------------------
# LLVM IR
# --------------------------------------------------------------------------------------
def _family(intrinsic: str) -> str:
    n = intrinsic.lower()
    if n.startswith("fmac"): return "fmac"
    if n.startswith(("fadd", "fsub")): return "fadd"
    if n.startswith("fmul"): return "fmul"
    if n.startswith(("fmov", "imov", "mov")): return "mov"
    if re.match(r"ld.*wds|ldxds|ldsr", n): return "ld_desc"
    if re.match(r"st.*ds", n): return "st_desc"
    if re.match(r"actvt|blk|ublk|.*flush|read|stprng", n): return "control"
    return "other"


def _function_files(ll: str) -> Dict[str, str]:
    """subprogram metadata id -> source file basename."""
    files = {m.group(1): os.path.basename(m.group(2)) for m in _DIFILE_RE.finditer(ll)}
    out = {}
    for m in _SUBPROGRAM_RE.finditer(ll):
        fm = re.search(r"file:\s*!(\d+)", m.group(2))
        if fm and fm.group(1) in files:
            out[m.group(1)] = files[fm.group(1)]
    return out


def _attr_groups(ll: str) -> Dict[str, str]:
    return {m.group(1): m.group(2) for m in _ATTR_GROUP_RE.finditer(ll)}


def _loops(lines: List[str]):
    """Back-edges as (target_line_index, br_line_index) on the function body lines."""
    label_at = {}
    for i, l in enumerate(lines):
        m = _LABEL_RE.match(l)
        if m:
            label_at[m.group(1).strip('"')] = i
    edges = []
    for i, l in enumerate(lines):
        s = l.strip()
        if not s.startswith("br "):
            continue
        for tgt in _BR_TARGETS_RE.findall(s):
            t = label_at.get(tgt)
            if t is not None and t <= i:
                edges.append((t, i))
    return edges


def _in_loop(idx: int, edges) -> bool:
    return any(t <= idx <= b for t, b in edges)


def _depth(edges) -> int:
    best = 0
    for t, b in edges:
        d = 1 + sum(1 for t2, b2 in edges if (t2, b2) != (t, b) and t2 <= t and b2 >= b)
        best = max(best, d)
    return best


def parse_function(name: str, body: str, attrs: str, attr_groups: Dict[str, str]) -> Dict[str, object]:
    lines = body.splitlines()
    edges = _loops(lines)
    f: Dict[str, object] = {"name": name, "ir_lines": len(lines), "loops": len(edges), "max_loop_depth": _depth(edges),
                            "dsd_intrinsics": Counter(), "scalar_loads_in_loop": 0, "scalar_stores_in_loop": 0,
                            "scalar_fp_ops_in_loop": 0, "indexed_gathers_in_loop": 0, "dsd_setup_in_loop": 0,
                            "reductions": [], "optnone": False}
    loaded_ints, derived, gather_ptrs = set(), set(), set()
    global_loads = {}     # ssa value -> global name (for the accumulator pattern)
    stored_globals = set()
    for i, raw in enumerate(lines):
        s = raw.strip()
        inloop = _in_loop(i, edges)
        m = re.match(r"(%[\w.]+)\s*=\s*(\w+)", s)
        lhs, op = (m.group(1), m.group(2)) if m else (None, s.split(" ", 1)[0] if s else "")
        for intr in _SDR_RE.findall(s):
            f["dsd_intrinsics"][_family(intr)] += 1
            if _family(intr) == "ld_desc" and inloop:
                f["dsd_setup_in_loop"] += 1
            if re.match(r"f(add|mac)[sh]\.rr", intr):
                args = s[s.index("(") + 1:] if "(" in s else ""
                first = re.search(r"\(\s*(?:float|half)\s+(%[\w.]+|[-\d.e+]+)", s)
                acc_ssa = first.group(1) if first else None
                acc_global = global_loads.get(acc_ssa) if acc_ssa else None
                runtime_len = bool(re.search(r"i16\s+%[\w.]+", args))
                f["reductions"].append({"intrinsic": "llvm.sdr." + intr, "in_loop": inloop, "runtime_length": runtime_len,
                                        "accumulator_global": acc_global, "accumulator_pattern": None, "line": i, "f32": intr.split(".")[0].endswith("s")})
            continue
        if op == "load":
            ptr = re.search(r",\s*[^,]*\*\s*(@\"?[\w$.]+\"?|%[\w.]+)", s)
            typ = re.search(r"load\s+([\w<>{}\s,]+?),", s)
            tname = typ.group(1).strip() if typ else ""
            if ptr and ptr.group(1).startswith("@"):
                global_loads[lhs] = ptr.group(1)
            if inloop and _DESC_TYPE not in s:
                f["scalar_loads_in_loop"] += 1
                if tname in ("i16", "i32", "i8", "i64") and lhs:
                    loaded_ints.add(lhs)
                if tname in ("float", "half") and ptr and ptr.group(1) in gather_ptrs:
                    f["indexed_gathers_in_loop"] += 1
        elif op == "store":
            tgt = re.search(r",\s*[^,]*\*\s*(@\"?[\w$.]+\"?)", s)
            if tgt:
                stored_globals.add(tgt.group(1))
            if inloop:
                if _DESC_TYPE in s:
                    f["dsd_setup_in_loop"] += 1
                else:
                    f["scalar_stores_in_loop"] += 1
        elif op in ("zext", "sext", "trunc", "add", "sub", "mul", "shl") and lhs:
            if any(v in loaded_ints or v in derived for v in re.findall(r"%[\w.]+", s)[1:]):
                derived.add(lhs)
        elif op == "getelementptr" and lhs:
            idx_vals = re.findall(r"%[\w.]+", s)[1:]
            if any(v in loaded_ints or v in derived for v in idx_vals):
                gather_ptrs.add(lhs)
        elif op in ("fmul", "fadd", "fsub") and inloop:
            f["scalar_fp_ops_in_loop"] += 1
    for r in f["reductions"]:
        r["accumulator_pattern"] = bool(r["accumulator_global"] and r["accumulator_global"] in stored_globals)
    grp = re.search(r"#(\d+)", attrs)
    f["optnone"] = bool(grp and "optnone" in attr_groups.get(grp.group(1), ""))
    f["dsd_intrinsics"] = dict(f["dsd_intrinsics"])
    f["dsd_compute_ops"] = sum(f["dsd_intrinsics"].get(k, 0) for k in ("fmac", "fadd", "fmul", "mov"))
    return f


def parse_ir(ll_text: str, target_files=("pe.csl",)) -> Dict[str, object]:
    """Per-function facts for the functions defined in the target CSL file(s). Functions
    without debug attribution are kept unless they come from the SDK's library paths."""
    files = _function_files(ll_text)
    attr_groups = _attr_groups(ll_text)
    out = {"functions": [], "target_files": list(target_files)}
    for m in _DEFINE_RE.finditer(ll_text):
        name, head = m.group(1), m.group(2)
        dbg = _DBG_RE.search(head)
        fname = files.get(dbg.group(1)) if dbg else None
        if fname is not None and not any(fname.endswith(t) for t in target_files):
            continue
        if name.startswith(".") or (fname is None and re.search(r"memcpy|\$\$csl|_sys_|rpc_", name)):
            continue                                   # compiler-internal helpers and SDK library code
        end = ll_text.find("\n}", m.end())
        body = ll_text[m.end():end if end >= 0 else len(ll_text)]
        fn = parse_function(name, body, head, attr_groups)
        fn["file"] = fname
        out["functions"].append(fn)
    return out


# --------------------------------------------------------------------------------------
# Disassembly (csdisasm/1 records)
# --------------------------------------------------------------------------------------
def mnemonic_of(instr: Optional[str]) -> Optional[str]:
    if not instr:
        return None
    tok = instr.split()
    if len(tok) >= 3 and tok[1] == "?":
        tok = tok[2:]
    return tok[0] if tok else None


_BRANCH_MNEMONICS = {"jmp", "jnz", "jz", "jne", "jeq", "jlt", "jgt", "br", "call", "ret"}


def parse_disasm(records: List[Dict[str, object]], target_file: str = "pe.csl") -> Dict[str, object]:
    decoded = [r for r in records if r.get("instruction")]
    target = [r for r in decoded if str(r.get("source_file") or "").endswith(target_file)]
    scope = target if target else decoded
    hist = Counter(mnemonic_of(r["instruction"]) for r in scope)
    dsd_ops = sum(1 for r in scope if re.search(r"\[[sd]\d", str(r["instruction"])))
    shifts = sum(v for k, v in hist.items() if k and k.split(".")[0] in _SHIFT_MNEMONICS)
    fpmul = sum(v for k, v in hist.items() if k and k.split(".")[0] in _FPMUL_MNEMONICS)
    # Branch cost is 9-10 cycles on this in-order core (FINDINGS 10h), so a body that is mostly
    # compare-and-jump is deciding rather than computing -- the shape of a two-pointer merge.
    branches = sum(v for k, v in hist.items() if k and k.split(".")[0] in _BRANCH_MNEMONICS)
    hazards = []
    for r in decoded:
        m = _HAZARD_RE.match(str(r["instruction"]).strip())
        if m and m.group(2) != m.group(3):
            hazards.append({"kind": "f32_reduction_dest_ne_src0" if m.group(1).endswith("s") else "f16_reduction_dest_ne_src0",
                            "pc": r.get("pc"), "instruction": r["instruction"], "source": (r.get("source") or "")[:80],
                            "f32": m.group(1).endswith("s")})
    return {"records_total": len(records), "records_decoded": len(decoded), "records_target": len(target),
            "scope": "target_file" if target else "all", "mnemonics": dict(hist.most_common(24)),
            "dsd_ops": dsd_ops, "shifts": shifts, "fp_muls": fpmul, "branches": branches,
            "branch_share": round(branches / len(scope), 3) if scope else None,
            "branch_per_fp_mul": round(branches / fpmul, 1) if fpmul else None,
            "shift_per_fp_mul": round(shifts / fpmul, 2) if fpmul else None, "hazards": hazards}


# --------------------------------------------------------------------------------------
# Keys, text, assembly
# --------------------------------------------------------------------------------------
def ir_keys(readout: Dict[str, object]) -> List[str]:
    fns = readout.get("functions") or []
    dis = readout.get("disasm") or {}
    keys = []
    total_dsd_compute = sum(int(f.get("dsd_compute_ops", 0)) for f in fns)
    if fns and total_dsd_compute == 0 and (dis.get("dsd_ops", 0) == 0):
        keys.append("ir_no_dsd_ops")
    if any(f.get("max_loop_depth", 0) >= 2 and f.get("scalar_fp_ops_in_loop", 0) > 0 and f.get("dsd_compute_ops", 0) == 0 for f in fns):
        keys.append("ir_scalar_inner_loop")
    if any(f.get("indexed_gathers_in_loop", 0) > 0 for f in fns):
        keys.append("ir_indexed_gather")
    spm = dis.get("shift_per_fp_mul")
    if spm is not None and spm >= 2.0:
        keys.append("ir_index_shift_heavy")
    if any(f.get("dsd_setup_in_loop", 0) >= 4 for f in fns):
        keys.append("ir_dsd_setup_in_loop")
    reds = [r for f in fns for r in f.get("reductions", [])]
    if any(r.get("f32") for r in reds):
        keys.append("ir_f32_reduction_candidate")
    if any(h.get("severity") == "error" for h in readout.get("hazards", [])):
        keys.append("ir_f32_reduction_hazard")
    # Branches per floating-point multiply separates a body that DECIDES from one that COMPUTES:
    # a branch costs 9-10 cycles (FINDINGS 10h) against ~1 for the rest. Calibrated on this suite's
    # own disassembly, 2026-09-20: masked SpGEMM's two-pointer merge 10-11, scalar CSR SpMV 6-7,
    # the SpMM reference's arithmetic inner loop 1.0. Threshold 4 separates them.
    bpf = dis.get("branch_per_fp_mul")
    if bpf is not None and bpf >= 4.0:
        keys.append("ir_branch_heavy")
    return keys


def format_ir_readout(readout: Dict[str, object], max_chars: int = 600) -> str:
    fns = readout.get("functions") or []
    dis = readout.get("disasm") or {}
    parts = [f"IR/disasm readout (compiled; {readout.get('target_file', 'pe.csl')})"]
    for f in fns[:3]:
        d = f.get("dsd_intrinsics", {})
        dsd = ", ".join(f"{k} {v}" for k, v in d.items() if k in ("fmac", "fadd", "fmul", "mov") and v)
        parts.append(f"{f['name']}: {f['loops']} loop(s) depth {f['max_loop_depth']}, DSD ops {dsd or 'none'}, "
                     f"{f['scalar_loads_in_loop']} scalar loads + {f['scalar_fp_ops_in_loop']} scalar FP ops in loops"
                     + (f", {f['indexed_gathers_in_loop']} indexed gather(s)" if f.get("indexed_gathers_in_loop") else "")
                     + (f", {f['dsd_setup_in_loop']} descriptor setups in loops" if f.get("dsd_setup_in_loop") else ""))
    if dis:
        top = ", ".join(f"{k} {v}" for k, v in list(dis.get("mnemonics", {}).items())[:6])
        spm = dis.get("shift_per_fp_mul")
        parts.append(f"disasm ({dis.get('scope')}): {dis.get('records_decoded')} instrs; {top}; DSD-operand instrs {dis.get('dsd_ops')}"
                     + (f"; {spm} shifts per FP multiply (u32 index arithmetic)" if spm is not None else ""))
    hz = readout.get("hazards") or []
    parts.append("hazards: " + ("; ".join(f"{h['kind']} at pc {hex(int(h['pc']))} `{h['instruction']}` [{h.get('severity')}]" for h in hz[:2]) if hz else "none"))
    text = "; ".join(parts)
    return text if len(text) <= max_chars else text[: max_chars - 3] + "..."


def build_ir_readout(bundle_dir, target_relpath: str = "pe.csl") -> Optional[Dict[str, object]]:
    """Assemble the readout from `<bundle>/.xkernel_ir/`; None when nothing usable is there."""
    ir_dir = Path(bundle_dir) / ".xkernel_ir"
    if not ir_dir.is_dir():
        return None
    target_file = os.path.basename(target_relpath)
    readout: Dict[str, object] = {"schema": SCHEMA, "evidence": "compiled", "target_file": target_file,
                                  "functions": [], "disasm": None, "hazards": [], "programs": []}
    # IR: prefer application PE programs (out_out_*), never the memcpy plumbing (out_east_/out_west_)
    lls = sorted(ir_dir.glob("cap/*/program.ll"))
    app = [p for p in lls if not re.search(r"out_(east|west)_", p.parent.name)] or lls
    for ll in app[:1]:
        parsed = parse_ir(ll.read_text(errors="replace"), (target_file,))
        readout["functions"] = parsed["functions"]
        readout["programs"].append(ll.parent.name)
    # disassembly of the measured ELF(s)
    hist_all: Counter = Counter(); dis_all = None
    for js in sorted(ir_dir.glob("disasm/*.json"))[:2]:
        try:
            recs = json.loads(js.read_text()).get("records", [])
        except ValueError:
            continue
        d = parse_disasm(recs, target_file)
        if dis_all is None:
            dis_all = d
        else:
            dis_all["hazards"] = dis_all["hazards"] + d["hazards"]
    if dis_all:
        readout["disasm"] = {k: v for k, v in dis_all.items() if k != "hazards"}
        acc_pattern = any(r.get("accumulator_pattern") for f in readout["functions"] for r in f.get("reductions", []))
        for h in dis_all["hazards"]:
            h["severity"] = "error" if (h.get("f32") and acc_pattern) else "warning"
            readout["hazards"].append(h)
    if not readout["functions"] and not readout["disasm"]:
        return None
    readout["ir_keys"] = ir_keys(readout)
    readout["readout_text"] = format_ir_readout(readout)
    return readout


if __name__ == "__main__":
    import argparse, sys
    ap = argparse.ArgumentParser(description="IR/disassembly readout of a staged bundle")
    ap.add_argument("bundle"); ap.add_argument("--target", default="pe.csl")
    a = ap.parse_args()
    r = build_ir_readout(a.bundle, a.target)
    print(json.dumps(r, indent=1, default=str) if r else "no artifacts")
