#!/usr/bin/env python3
"""Add-family compilation model: one factor changed per case, IR and machine code captured.

For each case this writes a self-contained CSL program, compiles it through
`tools/cslc_ir.py capture` (which retains the driver->backend LLVM IR and rebuilds
byte-identically), disassembles the application PE, and records:

  * the CSL body (the single factor that differs from `base`)
  * the captured IR of @compute, with an opcode histogram
  * the machine instructions of compute(), from the ELF symbol table where available
  * register and DSR usage, and the DSR interference graph when the compiler emits one
  * compile identity: SDK/backend paths, arch, flags, object and ELF hashes

Cases marked `withheld` are excluded from rule construction and used only to test
predictions.  Failed cases are kept with their exact diagnostics.

Evidence class of everything here: `compiled`.
"""
from __future__ import annotations
import argparse, hashlib, json, os, re, shutil, subprocess, sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
STUDY = HERE.parent.parent
SDK = "/software/cerebras/cs_sdk-2.10"
CSLC_ARGS = ["--arch=wse3", "--fabric-dims=8,3", "--fabric-offsets=4,1", "--memcpy",
             "--channels=1", "--width-west-buf=0", "--width-east-buf=0", "--dump-dsr-alloc-graph"]

# (name, factor, withheld, csl body)
CASES = [
 ("base",             "reference",      0, "c[0] = a[0] + b[0];"),
 ("const_one",        "constantness",   0, "c[0] = a[0] + 7;"),
 ("const_both",       "constantness",   0, "c[0] = 3 + 7;"),
 ("index_runtime",    "addressing",     0, "var i: u16 = @as(u16, idx[0]);\n  c[0] = a[i] + b[i];"),
 ("use_expr_twice",   "result use",     0, "c[0] = a[0] + b[0];\n  c[1] = a[0] + b[0];"),
 ("use_value_twice",  "result use",     0, "var t: i16 = a[0] + b[0];\n  c[0] = t;\n  c[1] = t + b[1];"),
 ("operand_shared",   "result use",     0, "c[0] = a[0] + b[0];\n  c[1] = a[0] + b[1];"),
 ("pair_independent", "dependencies",   0, "c[0] = a[0] + b[0];\n  c[1] = a[1] + b[1];"),
 ("pair_dependent",   "dependencies",   0, "c[0] = a[0] + b[0];\n  c[1] = c[0] + b[1];"),
 ("inplace",          "aliasing",       0, "a[0] = a[0] + b[0];"),
 ("select_runtime",   "control",        0, "if (k[0] > 0) { c[0] = a[0] + b[0]; } else { c[0] = a[1] + b[1]; }"),
 ("loop_comptime",    "control",        0, "for (@range(u16, 16)) |i| { c[i] = a[i] + b[i]; }"),
 ("loop_runtime",     "control",        0, "var n: u16 = @as(u16, k[0]);\n  var i: u16 = 0;\n  while (i < n) : (i += 1) { c[i] = a[i] + b[i]; }"),
 ("dsd16",            "execution form", 0, "@add16(cd, ad, bd);"),
 # withheld compositions: never used to build a rule, only to test predictions
 ("W_index_inplace",  "withheld",       1, "var i: u16 = @as(u16, idx[0]);\n  a[i] = a[i] + b[i];"),
 ("W_const_in_loop",  "withheld",       1, "for (@range(u16, 8)) |i| { c[i] = a[0] + 5; }"),
 ("W_chain_in_loop",  "withheld",       1, "var n: u16 = @as(u16, k[0]);\n  var i: u16 = 1;\n  while (i < n) : (i += 1) { c[i] = c[i - 1] + b[i]; }"),
 ("W_dsd_inplace",    "withheld",       1, "@add16(ad, ad, bd);"),
]

LAYOUT = """const memcpy = @import_module("<memcpy/get_params>", .{ .width = 1, .height = 1 });
layout {
  @set_rectangle(1, 1);
  @set_tile_code(0, 0, "pe.csl", .{ .memcpy_params = memcpy.get_params(0) });
  @export_name("a", [*]i16, true); @export_name("b", [*]i16, true); @export_name("c", [*]i16, true);
  @export_name("idx", [*]i16, true); @export_name("k", [*]i16, true);
  @export_name("compute", fn()void);
}
"""

def pe_src(body: str) -> str:
    return f"""param memcpy_params;
const EXIT: local_task_id = @get_local_task_id(9);
const sys_mod = @import_module("<memcpy/memcpy>", memcpy_params);

// every array is exported, so its stores are externally visible and the intended work stays live
var a = @zeros([64]i16); var b = @zeros([64]i16); var c = @zeros([64]i16);
var idx = @zeros([4]i16); var k = @zeros([4]i16);
var p_a: [*]i16 = &a; var p_b: [*]i16 = &b; var p_c: [*]i16 = &c;
var p_idx: [*]i16 = &idx; var p_k: [*]i16 = &k;

const ad = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{16}} -> a[i] }});
const bd = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{16}} -> b[i] }});
const cd = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{16}} -> c[i] }});

fn compute() void {{
  {body}
  @activate(EXIT);
}}

task f_exit() void {{ sys_mod.unblock_cmd_stream(); }}

comptime {{
  @bind_local_task(f_exit, EXIT);
  @export_symbol(p_a, "a"); @export_symbol(p_b, "b"); @export_symbol(p_c, "c");
  @export_symbol(p_idx, "idx"); @export_symbol(p_k, "k");
  @export_symbol(compute);
}}
"""

def sh(cmd, cwd=None, timeout=900):
    env = dict(os.environ); env["PATH"] = SDK + ":" + env.get("PATH", "")
    env["TMPDIR"] = str(STUDY / ".nfstmp")
    return subprocess.run(cmd, cwd=cwd, env=env, capture_output=True, text=True, timeout=timeout)

def ir_of(ll_text: str, fn: str = "compute"):
    m = re.search(rf"define [^\n]*@{fn}\(\)[^\n]*\{{\n(.*?)\n\}}\n", ll_text, re.S)
    if not m: return None, {}
    body = m.group(1)
    ops = re.findall(r"^\s+(?:%\S+ = )?(?:tail )?(\w+)", body, re.M)
    intr = re.findall(r"@(llvm\.[\w.]+)", body)
    hist = {}
    for o in ops: hist[o] = hist.get(o, 0) + 1
    for i in intr: hist["call:" + i] = hist.get("call:" + i, 0) + 1
    return body, hist

def symbol_range(elf: Path, name: str):
    """(addr, size) of a function symbol, from cs_readelf --syms."""
    r = sh(["cs_readelf", "--syms", str(elf.name)], cwd=str(elf.parent))
    for line in (r.stdout + r.stderr).splitlines():
        if re.search(rf"\b{re.escape(name)}\b", line):
            nums = re.findall(r"0x[0-9a-fA-F]+|\b\d+\b", line)
            if len(nums) >= 2:
                try: return int(nums[0], 0), int(nums[1], 0)
                except ValueError: pass
    return None, None

MEM = lambda tok: tok.startswith("[")

def mnemonic(text: str) -> str:
    """First token, ignoring a `cflagN ?` predicate prefix."""
    t = re.sub(r"^!?cflag\d+ \? ", "", text.strip())
    return t.split()[0] if t else "?"

def defs_uses(text: str):
    """Register definitions and uses. Memory destinations define nothing but use their address."""
    t = re.sub(r"^(!?cflag\d+) \? ", "", text.strip())
    pred = re.match(r"^(!?cflag\d+) \? ", text.strip())
    d, u = set(), set()
    if pred: u.add(pred.group(1).lstrip("!"))
    reg = r"\b(?:r\d+|d\d+|cflag\d+|sp)\b"
    if "=" in t:
        lhs, rhs = t.split("=", 1)
        lhs_toks = lhs.split()[1:] if len(lhs.split()) > 1 else []
        for tok in " ".join(lhs_toks).split(","):
            tok = tok.strip()
            if not tok: continue
            if MEM(tok): u.update(re.findall(reg, tok))      # store through an address register
            else: d.update(re.findall(reg, tok))
        u.update(re.findall(reg, rhs))
    else:
        u.update(re.findall(reg, t))
    return d, u

def pulled_rows(pulled, allrows):
    by_pc = {r["pc"]: r for r in allrows}
    return [by_pc[p["pc"]] for p in pulled if p["pc"] in by_pc]

def machine_of(disasm_path: Path, elf: Path):
    """The instructions of compute(), bounded exactly.

    cslc emits no `compute` symbol, so the boundary comes from the source instead: every case
    ends with `@activate(EXIT)`, which is the only `actvt` in application code. compute() is
    therefore the pe.csl-sourced instructions up to and including that `actvt`; whatever pe.csl
    code follows belongs to the exit task and is counted separately rather than discarded.
    """
    rows = json.loads(disasm_path.read_text()); rows = rows["records"] if isinstance(rows, dict) else rows
    app = sorted([r for r in rows if (r.get("source_file") or "").split("/")[-1] == "pe.csl"], key=lambda r: r["pc"])
    cut = next((i for i, r in enumerate(app) if r["instruction"].startswith("actvt")), len(app) - 1)
    sel, after = app[:cut + 1], app[cut + 1:]
    # ---- REGION CONTRACT ------------------------------------------------------------
    # Debug attribution is not a region boundary. A value the body needs can be materialised
    # by an instruction the compiler tagged with a neighbouring source file: the folded
    # constant of `const_both` (`movri r5 = 0xa`, tagged memcpy.csl) and the induction
    # variable of `loop_runtime` (`movri r5 = 0x0`, likewise) are both the case's own work
    # sitting outside its debug-attributed range.
    #
    # The region is therefore defined as:
    #    body           pe.csl-attributed instructions up to and including @activate(EXIT)
    #  + init_closure   for each register the body reads before defining, the nearest
    #                   preceding definition anywhere in the instruction stream
    #
    # and reported with its entry state, so what is counted and what is assumed on entry are
    # both explicit. A live-in with no definition within `max_back` is reported as unresolved
    # rather than silently dropped.
    allrows = sorted(rows, key=lambda r: r["pc"])
    max_back = 40
    def live_in_of(rows_):
        defined, live = set(), []
        for r in rows_:
            d, u = defs_uses(r["instruction"])
            for x in sorted(u - defined):
                if x not in live: live.append(x)
            defined |= d
        return live
    # transitive closure: a pulled-in definition has live-ins of its own, and they must be
    # resolved too, or the closure stops one instruction short of the value's real origin
    init, unresolved, ext = {}, set(), list(sel)
    for _ in range(8):
        start = min(r["pc"] for r in ext)
        before = [r for r in allrows if r["pc"] < start][-max_back:]
        added = False
        for reg in live_in_of(ext):
            hit = next((r for r in reversed(before) if reg in defs_uses(r["instruction"])[0]), None)
            if hit is None: unresolved.add(reg); continue
            e = init.setdefault(hit["pc"], {"pc": hit["pc"], "text": hit["instruction"],
                                            "source_file": (hit.get("source_file") or "").split("/")[-1],
                                            "defines": []})
            if reg not in e["defines"]: e["defines"].append(reg)
            added = True
        if not added: break
        ext = pulled_rows([init[k] for k in sorted(init)], allrows) + sel
    pulled = [init[k] for k in sorted(init)]
    livein = live_in_of(sel)
    unresolved = sorted(unresolved - {p_ for e in pulled for p_ in e["defines"]})
    sel = pulled_rows(pulled, allrows) + sel
    instrs = [{"pc": r["pc"], "text": r["instruction"]} for r in sel]
    hist = {}
    for i in instrs:
        m = mnemonic(i["text"])
        hist[m] = hist.get(m, 0) + 1
    regs = sorted(set(re.findall(r"\br(?:\d+)\b", " ".join(i["text"] for i in instrs))))
    dsrs = sorted(set(re.findall(r"\b(?:dds|s0ds|s1ds)\d+\b", " ".join(i["text"] for i in instrs))))
    return {"n": len(instrs), "instrs": instrs, "hist": hist, "gprs": regs, "dsrs": dsrs,
            "n_after_activate": len(after), "pulled_in": pulled,
            "contract": {"body_rule": "pe.csl-attributed instructions up to and including @activate(EXIT)",
                         "init_rule": f"nearest preceding definition of each register the body reads before defining (searched back {max_back} instructions)",
                         "entry_live_in": livein, "init_closure": pulled, "unresolved_live_in": unresolved,
                         "n_body": len(instrs) - len(pulled), "n_init": len(pulled), "n_total": len(instrs)},
            "attributed_by": "explicit region contract: debug-attributed body plus the init closure of its live-in registers"}

def dsr_graph(case_dir: Path):
    out = {}
    for dot in sorted(case_dir.glob("out/bin/*.dot")):
        txt = dot.read_text()
        nodes = re.findall(r'label=<<b>([^<]*)</b>.*?Assigned color = (\d+)(.*?)>\]', txt, re.S)
        out[dot.name] = {"nodes": [{"operand": n[0], "dsr": int(n[1]),
                                    "explicit": "Explicit DSR" in n[2],
                                    "failed": "COLORING FAILED" in n[2]} for n in nodes],
                         "edges": len(re.findall(r"^\s*\d+ -- \d+", txt, re.M))}
    return out

def run_case(name, factor, withheld, body, keep_ir):
    d = HERE / "cases" / name
    shutil.rmtree(d, ignore_errors=True); d.mkdir(parents=True)
    (d / "layout.csl").write_text(LAYOUT); (d / "pe.csl").write_text(pe_src(body))
    (d / "FACTOR.txt").write_text(f"{factor}\n\nthe single factor changed relative to `base`:\n{body}\n")
    rec = {"name": name, "factor": factor, "withheld": bool(withheld), "csl": body, "ok": False}
    r = sh([sys.executable, str(STUDY / "tools" / "cslc_ir.py"), "capture", "-o", "ir", "--",
            "./layout.csl"] + CSLC_ARGS + ["-o", "out"], cwd=str(d))
    if r.returncode != 0:
        rec["error"] = "capture failed"; rec["diagnostics"] = (r.stdout + r.stderr)[-1500:]; return rec
    prog = next((p for p in (d / "ir").iterdir() if p.is_dir() and (p / "program.ll").exists()
                 and "east" not in p.name and "west" not in p.name), None)
    if prog is None:
        rec["error"] = "no captured IR for the application PE"; rec["diagnostics"] = (r.stdout + r.stderr)[-800:]; return rec
    meta = json.loads((prog / "meta.json").read_text())
    ll = (prog / "program.ll").read_text()
    ir_body, ir_hist = ir_of(ll)
    elf = d / "out" / "bin" / "out_0_0.elf"
    dr = sh([sys.executable, str(STUDY / "tools" / "csdisasm.py"), str(elf), "--json", "disasm.json"], cwd=str(d))
    if not (d / "disasm.json").exists():
        rec["error"] = "disassembly failed"; rec["diagnostics"] = (dr.stdout + dr.stderr)[-1200:]; return rec
    rec.update({
        "ok": True,
        "identity": {"cslang_bin": meta["cslang_bin"], "backend_argv": meta["backend_argv"],
                     "cslc_args": meta["cslc_args"], "libs": meta["libs"],
                     "elf_sha": meta["elf_sha"], "o_sha": meta["o_sha"],
                     "ll_sha": hashlib.sha256(ll.encode()).hexdigest()[:16]},
        "ir": {"n_lines": len(ir_body.splitlines()) if ir_body else 0, "hist": ir_hist,
               "body": ir_body if keep_ir else None},
        "machine": machine_of(d / "disasm.json", elf),
        "dsr_graph": dsr_graph(d),
    })
    if not keep_ir: rec["ir"]["body"] = ir_body   # always keep: it is the primary evidence
    return rec

def reextract(name, factor, withheld, body):
    """Rebuild a case record from artifacts already on disk (no compile)."""
    d = HERE / "cases" / name
    rec = {"name": name, "factor": factor, "withheld": bool(withheld), "csl": body, "ok": False}
    prog = next((p for p in (d / "ir").iterdir() if p.is_dir() and (p / "program.ll").exists()
                 and "east" not in p.name and "west" not in p.name), None) if (d / "ir").exists() else None
    if prog is None or not (d / "disasm.json").exists():
        rec["error"] = "no retained artifacts for this case"; return rec
    meta = json.loads((prog / "meta.json").read_text()); ll = (prog / "program.ll").read_text()
    ir_body, ir_hist = ir_of(ll)
    rec.update({"ok": True,
        "identity": {"cslang_bin": meta["cslang_bin"], "backend_argv": meta["backend_argv"],
                     "cslc_args": meta["cslc_args"], "libs": meta["libs"],
                     "elf_sha": meta["elf_sha"], "o_sha": meta["o_sha"],
                     "ll_sha": hashlib.sha256(ll.encode()).hexdigest()[:16]},
        "ir": {"n_lines": len(ir_body.splitlines()) if ir_body else 0, "hist": ir_hist, "body": ir_body},
        "machine": machine_of(d / "disasm.json", d / "out" / "bin" / "out_0_0.elf"),
        "dsr_graph": dsr_graph(d)})
    return rec

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--only", nargs="*", help="run just these case names")
    ap.add_argument("--no-ir-body", action="store_true")
    ap.add_argument("--reextract", action="store_true", help="re-read existing case dirs; do not recompile")
    a = ap.parse_args()
    cases = [c for c in CASES if not a.only or c[0] in a.only]
    out = []
    for name, factor, wh, body in cases:
        rec = reextract(name, factor, wh, body) if a.reextract else run_case(name, factor, wh, body, not a.no_ir_body)
        out.append(rec)
        m = rec.get("machine", {})
        print(f"{name:<18} {factor:<15} {'WITHHELD' if wh else '        '} "
              f"{'ok' if rec['ok'] else 'FAIL: ' + rec.get('error','?'):<12} "
              f"IR {rec.get('ir',{}).get('n_lines','-'):>4} lines  machine {m.get('n','-'):>3} instr  "
              f"{'' if rec['ok'] else rec.get('diagnostics','')[:120]}")
    p = HERE / "cases.json"
    prev = json.loads(p.read_text())["cases"] if p.exists() and a.only else []
    byname = {c["name"]: c for c in prev}
    for c in out: byname[c["name"]] = c
    order = [c[0] for c in CASES]
    merged = [byname[n] for n in order if n in byname]
    p.write_text(json.dumps({"cases": merged}, indent=1))
    print(f"\n{sum(1 for c in merged if c['ok'])}/{len(merged)} cases ok -> {p}")

if __name__ == "__main__":
    main()
