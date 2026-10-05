#!/usr/bin/env python3
"""An executable, version-bound model of i16 add-family lowering, and its evaluation.

TWO BOUNDARIES.  `cslc` invokes `clang -cc1 ... -x ir <captured>.ll ... -O2`, so the retained
IR is the input to that pipeline -- but it is NOT a neutral, pre-target form.  It already
carries CSL specialisation and target-specific lowering: the DSD cases arrive with their
descriptor loads, their role-encoding intrinsic (`llvm.sdr.add16.ds0s1` versus
`llvm.sdr.add16.s0s0s1`) and their DSR indices already chosen.  The model is therefore split:

    boundary 1   CSL source form   -> captured IR structure (frontend + target lowering)
    boundary 2   captured IR       -> machine instruction roles (clang -O2 + backend)

WHAT IS NOT CLAIMED.  No pass names and no pass order.  Three channels for obtaining an
intermediate transformation log were tried and all fail on this SDK: stock `opt` rejects the
IR (non-integral address space 0), the `clang` the driver names is not a binary in the
container (it runs in-process inside `cslc-backend`), and `cslc-backend` rejects every LLVM
option including `--print-after-all` and `--debug-pass`.  Only endpoints are observable, so
rules state resulting structure, never the transformation sequence that produced it.

DEFINITION OF A MATCH.  `exact` means the predicted and observed multisets of STATIC
INSTRUCTION ROLE COUNTS over the region contract are equal.  It does not assert identical
instructions, operands, register assignments, numerical results or timing.

SCOPE.  SDK 2.10.0, cslang rel-sdk-2.10.0/202604012315-1813-1394a6ea, `--arch=wse3`, memcpy
layout, 1x1 rectangle, exported `i16[64]` arrays, `-O2`.  Outside this, nothing is claimed.
"""
from __future__ import annotations
import argparse, json, re
from collections import Counter
from pathlib import Path

HERE = Path(__file__).resolve().parent.parent
CASES_PATH = HERE / "microbench" / "addfam" / "cases.json"
ROLES = ["load", "store", "alu", "addr", "ctrl", "desc", "vecop", "actvt", "other"]
RULESET_VERSION = "addfam-v2"
EXACT_DEF = ("equality of the static instruction-role count multiset over the region contract; "
             "not instruction, operand, register-allocation, numerical or timing equivalence")

# ============================================================ observation: roles by dataflow
ADDR_MIN = 0x400        # SRAM addresses in these programs; smaller immediates are values

def classify(instrs):
    taint, out = set(), []
    for ins in instrs:
        t = ins["text"]; pred = bool(re.match(r"^!?cflag\d+ \? ", t))
        body = re.sub(r"^!?cflag\d+ \? ", "", t); mn = body.split()[0]
        lhs, rhs = (body.split("=", 1) + [""])[:2] if "=" in body else (body, "")
        dst = lhs.split()[1] if len(lhs.split()) > 1 else ""
        srcregs = set(re.findall(r"\br\d+\b", rhs))
        imm = [int(x, 16) for x in re.findall(r"0x([0-9a-fA-F]+)", rhs)]
        if mn.startswith("actvt"): role = "actvt"
        elif mn.startswith(("lddwds", "lds0wds", "lds1wds", "ldsr", "ldxds")): role = "desc"
        elif "[dds" in body or "[s0ds" in body or "[s1ds" in body: role = "vecop"
        elif mn.startswith("jmp") or dst.startswith("cflag") or pred: role = "ctrl"
        elif mn.startswith(("ld16", "ld32", "ld16rp")): role = "load"
        elif mn.startswith(("st16", "st32")): role = "store"
        elif mn.startswith("imov16") and dst.startswith("["): role = "store"
        elif mn.startswith("imov16") and "[" in rhs: role = "load"
        elif mn.startswith("movri"): role = "addr" if (imm and imm[0] >= ADDR_MIN) else "alu"
        elif mn.startswith(("sll16", "slr16", "sar16")): role = "addr"
        elif srcregs & taint: role = "addr"
        else: role = "alu"
        if dst.startswith("r"):
            if role == "addr": taint.add(dst)
            elif dst in taint: taint.discard(dst)
        out.append({**ins, "role": role, "mnemonic": mn})
    for i, ins in enumerate(out):      # a shift is addressing only if its result feeds an address
        if ins["mnemonic"].startswith(("sll16", "slr16")) and ins["role"] == "addr":
            d = ins["text"].split("=")[0].split()[-1]
            if d and not re.search(rf"\b{re.escape(d)}\b", " ".join(o["text"] for o in out[i+1:i+6])):
                ins["role"] = "alu"
    return out

def counts(instrs):
    c = Counter(i["role"] for i in classify(instrs))
    return {r: c[r] for r in ROLES if c.get(r)}

# ============================================================ boundary-2 input: access structure
# Derivable from either the CSL source form or the captured IR's loads/stores/getelementptrs.
# An index is an int (fixed), "R" (a runtime value), or "I" (the induction variable).
A = lambda arr, idx: (arr, idx)
ABS = {
 "base":             dict(stmts=[dict(r=[A("a",0),A("b",0)], w=A("c",0))]),
 "const_one":        dict(stmts=[dict(r=[A("a",0)], imm=True, w=A("c",0))]),
 "const_both":       dict(stmts=[dict(r=[], folded=True, w=A("c",0))]),
 "index_runtime":    dict(idxload=1, ridx=dict(bases=2, narrows=2),
                          stmts=[dict(r=[A("a","R"),A("b","R")], w=A("c",0), rreads=2)]),
 "use_expr_twice":   dict(stmts=[dict(r=[A("a",0),A("b",0)], w=A("c",0)),
                                 dict(r=[A("a",0),A("b",0)], w=A("c",1))]),
 "use_value_twice":  dict(stmts=[dict(r=[A("a",0),A("b",0)], w=A("T",0)),
                                 dict(r=[A("T",0)], w=A("c",0), moveonly=True),
                                 dict(r=[A("T",0),A("b",1)], w=A("c",1))]),
 "operand_shared":   dict(stmts=[dict(r=[A("a",0),A("b",0)], w=A("c",0)),
                                 dict(r=[A("a",0),A("b",1)], w=A("c",1))]),
 "pair_independent": dict(stmts=[dict(r=[A("a",0),A("b",0)], w=A("c",0)),
                                 dict(r=[A("a",1),A("b",1)], w=A("c",1))]),
 "pair_dependent":   dict(stmts=[dict(r=[A("a",0),A("b",0)], w=A("c",0)),
                                 dict(r=[A("c",0),A("b",1)], w=A("c",1))]),
 "inplace":          dict(stmts=[dict(r=[A("a",0),A("b",0)], w=A("a",0))]),
 "select_runtime":   dict(condload=1, arms=2, armreads=2,
                          stmts=[dict(r=[A("a",0),A("b",0)], w=A("c",0))]),
 "loop_comptime":    dict(unroll=16, stmts=[dict(r=[A("a","I"),A("b","I")], w=A("c","I"))]),
 "loop_runtime":     dict(boundload=1, rloop=True, ridx=dict(bases=3, narrows=3),
                          stmts=[dict(r=[A("a","I"),A("b","I")], w=A("c","I"), rreads=2, rwrites=1)]),
 "dsd16":            dict(dsd=dict(desc=3)),
 "W_index_inplace":  dict(idxload=1, ridx=dict(bases=2, narrows=2),
                          stmts=[dict(r=[A("a","R"),A("b","R")], w=A("a","R"), rreads=2, rwrites=1)]),
 "W_const_in_loop":  dict(unroll=8, stmts=[dict(r=[A("a",0)], imm=True, w=A("c","I"))]),
 "W_chain_in_loop":  dict(boundload=1, preload=1, rloop=True, ridx=dict(bases=2, narrows=2),
                          stmts=[dict(r=[A("c","Iprev"),A("b","I")], w=A("c","I"), rreads=1, rwrites=1)]),
 "W_dsd_inplace":    dict(dsd=dict(desc=2)),
}

def predict_machine(spec):
    """Role counts implied by the boundary-2 rules, computed from the access structure.

    Endpoint statements only. A read is free when the same element is already in a register,
    whether because it was read before (M1) or stored before (M2). A statement whose whole
    expression already exists is free (M1). A comptime loop contributes its body once per
    iteration, except that index-independent work contributes once in total (M3). A
    data-bounded loop keeps its body once plus its control and induction cost (M4). Runtime
    indexing adds its address sequence (M5). A DSD op is its descriptor loads plus one vector
    instruction (M6).
    """
    p = Counter()
    if "dsd" in spec:
        p["desc"] += spec["dsd"]["desc"]; p["vecop"] += 1; p["actvt"] += 1
        return {k: v for k, v in p.items() if v}
    p["load"] += spec.get("idxload", 0) + spec.get("condload", 0) + spec.get("boundload", 0) + spec.get("preload", 0)
    n = spec.get("unroll", 1)
    in_reg, exprs = set(), set()                    # elements already in a register; expressions computed
    for it in range(n):
        for st in spec["stmts"]:
            def key(acc):
                arr, idx = acc
                return (arr, it if idx in ("I", "Iprev") and arr != "T" else idx)
            invariant = all(a[1] not in ("I", "Iprev") for a in st["r"])
            if st.get("moveonly"):
                p["store"] += 1; continue
            reg_dest = st["w"][0] == "T"      # the result stays in a register; no store
            if st.get("folded"):
                p["alu"] += 1; p["store"] += 1; continue
            if invariant and it > 0:
                p["store"] += 1; continue           # M3: index-independent work computed once
            for acc in st["r"]:
                if acc[0] == "T": continue          # a value already in a register, not memory
                if spec.get("arms"): continue       # M7: the arms supply these loads, not the merged statement
                if st.get("rreads"): continue       # runtime-indexed reads are counted with addressing
                k = key(acc)
                if k in in_reg: continue            # M1/M2: already in a register
                p["load"] += 1; in_reg.add(k)
            e = (tuple(sorted(key(x) for x in st["r"])), st.get("imm"))
            if e in exprs and not st.get("rreads"): pass
            else: p["alu"] += 1; exprs.add(e)
            if reg_dest: pass
            elif st.get("rwrites"): p["store"] += 1
            else: p["store"] += 1; in_reg.add(key(st["w"]))
            if st.get("rreads"): p["load"] += st["rreads"]
    r = spec.get("ridx")
    if r: p["addr"] += 1 + 2 * r["bases"] + r["narrows"]      # M5: scale, base+offset per array, narrow per access
    if spec.get("rloop"): p["ctrl"] += 4; p["alu"] += 2       # M4: guard + latch; induction init + increment
    if spec.get("arms"): p["ctrl"] += spec["arms"] + 1; p["load"] += spec["arms"] * spec["armreads"]
    p["actvt"] += 1
    return {k: v for k, v in p.items() if v}

# ============================================================ boundary 1: CSL -> captured IR
IR_SCOPE = {"base", "const_one", "const_both", "inplace", "use_expr_twice", "operand_shared",
            "pair_independent", "pair_dependent", "dsd16", "W_dsd_inplace"}

def predict_ir(name, spec):
    """Predicted captured-IR op multiset, for source forms inside the declared IR scope.

    Straight-line scalar adds lower one-to-one, statement by statement, with no sharing (F1);
    a source constant is already an IR immediate (F2) and two constants are already folded
    (F3); a DSD builtin arrives as descriptor-load intrinsics plus one role-encoding
    arithmetic intrinsic whose arguments are the chosen DSR indices (F4).
    Loops and selects are OUT OF SCOPE at this boundary and return None rather than a guess.
    """
    if name not in IR_SCOPE: return None
    if "dsd" in spec:
        d = spec["dsd"]["desc"]
        return {"call": d + 2, "ret": 1,
                **{f"call:llvm.sdr.{k}": 1 for k in (["lddwds", "lds0wds", "lds1wds"][:d] if d == 3
                                                     else ["lds0wds", "lds1wds"])},
                "call:llvm.sdr.actvt.r": 1,
                "call:llvm.sdr." + ("add16.ds0s1" if d == 3 else "add16.s0s0s1"): 1}
    ld = st = alu = 0
    for s in spec["stmts"]:
        if s.get("folded"): st += 1; continue
        ld += len(s["r"]); st += 1; alu += 1
    out = {"load": ld, "add": alu, "store": st, "call": 1, "ret": 1, "call:llvm.sdr.actvt.r": 1}
    return {k: v for k, v in out.items() if v}

# ============================================================ rules
RULES = [
 dict(id="F1", boundary="CSL -> captured IR", name="straight-line statements lower one-to-one",
      when="any straight-line add over array elements",
      result="each statement contributes its own loads, add and store; nothing is shared between statements",
      cases=["base", "use_expr_twice", "operand_shared", "pair_independent"],
      tested="verified for one to two statements over i16[64] arrays",
      untested="statement counts beyond two, and types other than i16", evidence="compiled"),
 dict(id="F2", boundary="CSL -> captured IR", name="a constant operand is already an IR immediate",
      when="exactly one operand is a source-level constant",
      result="`add i16 %x, 7`; the backend emits `add16.nf rD = rS, 0x7` with no load and no `movri`",
      cases=["const_one"], tested="verified for the constant 7",
      untested="the immediate encoding boundary: no constant near the field width has been tried",
      evidence="compiled"),
 dict(id="F3", boundary="CSL -> captured IR", name="source constants are folded before capture",
      when="both operands are source-level constants",
      result="no `add` in the captured IR; the folded value appears in the `store`, and the backend materialises it with one `movri`",
      cases=["const_both"], tested="verified for 3 + 7",
      untested="overflow behaviour at the i16 boundary", evidence="compiled"),
 dict(id="F4", boundary="CSL -> captured IR", name="DSD form, descriptor sharing and DSR indices are all chosen before capture",
      when="the add is written as `@add16` over `mem1d_dsd` operands",
      result="the captured IR holds the descriptor-load intrinsics and one arithmetic intrinsic whose NAME encodes the operand roles and whose ARGUMENTS are the DSR indices: "
             "`llvm.sdr.add16.ds0s1(1, 1, 1)` with three descriptor loads, against `llvm.sdr.add16.s0s0s1(0, 0, 1)` with two",
      cases=["dsd16", "W_dsd_inplace"],
      tested="verified for a 16-element mem1d_dsd add, and for the same DSD value passed as both destination and source-0",
      untested="two separately constructed DSDs describing equivalent accesses; a destination aliasing source-1 rather than source-0",
      evidence="compiled",
      note="corrects an earlier version of this model, which placed descriptor elision and DSR assignment after the capture boundary and "
           "presented the two-descriptor form as a machine-code counterexample. It is visible in the IR."),
 dict(id="F5", boundary="CSL -> captured IR", name="loops and named locals survive as structure",
      when="a `var` local, or a loop of any kind",
      result="a named local appears as an `alloca` with a store and reload; a loop appears as `br` and `phi`, never unrolled",
      cases=["use_value_twice", "index_runtime", "loop_comptime", "loop_runtime"],
      tested="verified for comptime `@range` and data-bounded `while`",
      untested="nested loops", evidence="compiled"),
 dict(id="M1", boundary="captured IR -> machine", name="a repeated read or expression costs nothing extra",
      when="the same element is read again, or the same expression recomputed, with no intervening write to it",
      result="one load and one add in total",
      cases=["use_expr_twice", "operand_shared"],
      tested="verified within a single basic block",
      untested="across basic blocks", evidence="compiled",
      note="counterexample: pair_independent reads four distinct elements and keeps four loads"),
 dict(id="M2", boundary="captured IR -> machine", name="a value just stored is not reloaded",
      when="an add reads an element a preceding statement stored",
      result="no load; the stored register is reused. Also holds across iterations of a data-bounded loop, where only the initial element is loaded before the loop",
      cases=["pair_dependent", "W_chain_in_loop"],
      tested="verified within a block and across iterations of one loop",
      untested="whether an aliasing runtime index defeats it", evidence="compiled"),
 dict(id="M3", boundary="captured IR -> machine", name="index-independent work in a comptime loop is computed once",
      when="the body of a comptime-range loop does not depend on the induction variable",
      result="the invariant load and add appear once; only the stores repeat. The observed endpoints do not distinguish hoisting-then-unrolling from unrolling-then-redundancy-elimination, and no order is claimed",
      cases=["W_const_in_loop"], tested="verified at trip count 8 with a single-statement body",
      untested="other trip counts and body sizes", evidence="compiled"),
 dict(id="M4", boundary="captured IR -> machine", name="a comptime loop is fully unrolled; a data-bounded loop is not",
      when="the trip count is a comptime `@range`, or a runtime value",
      result="comptime: N copies of the body, no loop control at all. Data-bounded: the body once, plus 4 ctrl (guard compare and branch, latch compare and branch) and 2 alu (induction variable materialised and incremented), with the array bases hoisted out of the body",
      cases=["loop_comptime", "loop_runtime", "W_chain_in_loop"],
      tested="verified at comptime trip counts 8 and 16, and for two data-bounded loops",
      untested="the unrolling policy at other trip counts or body sizes -- the threshold is unknown, so no trip count outside {8, 16} is predicted",
      evidence="compiled"),
 dict(id="M5", boundary="captured IR -> machine", name="runtime indexing costs a fixed address sequence",
      when="an element is addressed by a runtime value (a `getelementptr` with a non-constant index)",
      result="1 index scale, then per array base a `movri` and a base+offset `add`, then one address narrow per access; a read and a write of the same element share one address register",
      cases=["index_runtime", "loop_runtime", "W_index_inplace"],
      tested="verified for two and three array bases",
      untested="more bases than three, and indices wider than u16", evidence="compiled",
      note="the scale-then-narrow pair is an addressing-mode artifact: the index is scaled to bytes to add to the base, then narrowed back to words for the indirect access"),
 dict(id="M6", boundary="captured IR -> machine", name="a DSD intrinsic becomes its descriptor loads and one vector instruction",
      when="the captured IR contains `llvm.sdr.add16.*`",
      result="one machine instruction per descriptor-load intrinsic plus one vector op, independent of element count",
      cases=["dsd16", "W_dsd_inplace"], tested="verified for 16 elements",
      untested="element counts requiring more than one descriptor group", evidence="compiled"),
 dict(id="M7", boundary="captured IR -> machine", name="a runtime if/else over the same operation is tail-merged",
      when="both arms perform the same add and store to the same destination",
      result="a compare, a conditional jump and a jump; per-arm loads only; then ONE add and ONE store shared by both paths",
      cases=["select_runtime"], tested="verified for two arms differing only in which elements they read",
      untested="arms performing different operations, and more than two arms", evidence="compiled",
      note="differs from the atomic-ops if/else, whose arms stored constants and became full predication with no jump"),
 dict(id="X1", boundary="captured IR -> machine", name="OPEN: register-to-register copies are not modelled",
      when="a data-bounded loop whose induction variable is copied between registers",
      result="`loop_runtime` contains one `fmov16.nf r0 = r5` that no rule accounts for; `W_chain_in_loop`, the other data-bounded loop, has no such copy. Register allocation is outside this model, so M4 under-predicts loop_runtime by one alu",
      cases=["loop_runtime"], tested="observed in one of two data-bounded loops",
      untested="what determines whether the copy appears", evidence="compiled", open=True),
]

# ============================================================ evaluation
def main():
    ap = argparse.ArgumentParser(); ap.add_argument("--json"); a = ap.parse_args()
    cases = json.load(open(CASES_PATH))["cases"]
    rows = []
    for c in cases:
        spec = ABS[c["name"]]
        obs_m = counts(c["machine"]["instrs"]); pre_m = predict_machine(spec)
        obs_i = {k: v for k, v in c["ir"]["hist"].items()}; pre_i = predict_ir(c["name"], spec)
        rows.append({"name": c["name"], "factor": c["factor"], "withheld": c["withheld"], "csl": c["csl"],
                     "machine_observed": obs_m, "machine_predicted": pre_m, "machine_exact": obs_m == pre_m,
                     "ir_observed": obs_i, "ir_predicted": pre_i,
                     "ir_exact": (pre_i is not None and obs_i == pre_i), "ir_in_scope": pre_i is not None,
                     "n_body": c["machine"]["contract"]["n_body"], "n_init": c["machine"]["contract"]["n_init"],
                     "n_total": c["machine"]["contract"]["n_total"]})
    f = [r for r in rows if not r["withheld"]]; w = [r for r in rows if r["withheld"]]
    print(f"rule set {RULESET_VERSION}   `exact` = {EXACT_DEF}\n")
    print(f"{'case':<18} {'body+init':<10} {'boundary 1 (IR)':<17} {'boundary 2 (machine)':<21}")
    for grp, title in ((f, "RULE-BUILDING"), (w, "WITHHELD (now regression cases)")):
        print(f"-- {title}")
        for r in grp:
            b1 = "exact" if r["ir_exact"] else ("out of scope" if not r["ir_in_scope"] else "DIFFERS")
            b2 = "exact" if r["machine_exact"] else "DIFFERS"
            print(f"{r['name']:<18} {r['n_body']:>3}+{r['n_init']:<6} {b1:<17} {b2:<21}"
                  + ("" if r["machine_exact"] else f"\n{'':<18} predicted {r['machine_predicted']}\n{'':<18} observed  {r['machine_observed']}"))
    ir_in = [r for r in rows if r["ir_in_scope"]]
    print(f"\nboundary 1  CSL -> captured IR:      {sum(r['ir_exact'] for r in ir_in)}/{len(ir_in)} exact "
          f"({len(rows) - len(ir_in)} source forms declared out of scope)")
    print(f"boundary 2  captured IR -> machine:  {sum(r['machine_exact'] for r in rows)}/{len(rows)} exact")
    for r in rows:
        if not r["machine_exact"]:
            miss = {k: r['machine_observed'].get(k, 0) - r['machine_predicted'].get(k, 0)
                    for k in set(r['machine_observed']) | set(r['machine_predicted'])}
            print(f"  {r['name']}: {({k: v for k, v in miss.items() if v})} -> see rule "
                  + ", ".join(x["id"] for x in RULES if r["name"] in x["cases"] and x.get("open")))
    print(f"\n{len(RULES)} rules ({sum(1 for r in RULES if r.get('open'))} open)")
    if a.json:
        Path(a.json).write_text(json.dumps({"ruleset_version": RULESET_VERSION, "exact_definition": EXACT_DEF,
                                            "rows": rows, "rules": RULES}, indent=1))
        print("wrote", a.json)

if __name__ == "__main__":
    main()
