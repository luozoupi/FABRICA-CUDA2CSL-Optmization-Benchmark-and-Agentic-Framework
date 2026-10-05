#!/usr/bin/env python3
"""Capture the IR, splice the hand-authored body into @spmv_ir, rebuild, run, measure.

The gate test is the splice: only the `define` line and its attribute group survive from the
CSL stub; every instruction, basic block and phi inside @spmv_ir is ours.  If the rebuilt ELF
runs and its output matches numpy, IR authoring is a real emission path and not just a patch
surface.  Per-strategy cycles come from the marker pairs in the trace.
"""
from __future__ import annotations
import gzip, json, os, re, shutil, subprocess, sys, time
from pathlib import Path

HERE = Path(__file__).resolve().parent; STUDY = HERE.parent.parent
SDK = "/software/cerebras/cs_sdk-2.10"; APP_TILE = 12
CSLC = ["./layout.csl", "--arch=wse3", "--fabric-dims=8,3", "--fabric-offsets=4,1", "-o", "out",
        "--memcpy", "--channels=1", "--width-west-buf=0", "--width-east-buf=0"]

def sh(cmd, timeout=1800):
    env = dict(os.environ); env["PATH"] = SDK + ":" + env.get("PATH", ""); env["TMPDIR"] = str(STUDY / ".nfstmp")
    return subprocess.run(cmd, cwd=str(HERE), env=env, capture_output=True, text=True, timeout=timeout)

def resolve_globals(ll: str, body: str):
    """Bind %%name%% placeholders to the real IR symbols.

    CSL does not name every array global after the CSL variable: an array the device code only
    reads is emitted as @"$$csl_base_address$$N$$name", while one it writes keeps @name.  An IR
    emitter therefore needs this lookup; assuming the plain name fails with "use of undefined
    value".  Found by the gate test.
    """
    syms = set(re.findall(r'^(@(?:[\w.$]+|"[^"]+")) = ', ll, re.M))
    bound = {}
    for ph in sorted(set(re.findall(r"%%(\w+)%%", body))):
        cands = [g for g in syms if g == f"@{ph}" or g.endswith(f'$${ph}"')]
        assert cands, f"no IR global for CSL array `{ph}`; globals include {sorted(syms)[:8]}"
        cands.sort(key=lambda g: g != f"@{ph}")          # exact name wins, else the mangled form
        bound[ph] = cands[0]; body = body.replace(f"%%{ph}%%", cands[0])
    return body, bound

def splice(ll: str, body: str) -> str:
    """Replace the whole body of @spmv_ir, keeping its define line and attributes."""
    m = re.search(r"(define [^\n]*@spmv_ir\(\)[^\n]*\{\n)(.*?)(\n\}\n)", ll, re.S)
    assert m, "no @spmv_ir definition in the captured IR"
    old_lines = len(m.group(2).splitlines())
    return ll.replace(m.group(0), m.group(1) + body.rstrip("\n") + m.group(3), 1), old_lines

def measure(meta):
    dis = json.loads((HERE / "disasm.json").read_text()); dis = dis["records"] if isinstance(dis, dict) else dis
    pcs = {r["pc"]: r["instruction"] for r in dis}
    disp = []
    with gzip.open(HERE / "events.jsonl.gz", "rt") as fh:
        for line in fh:
            if '"hwm_dispatch_trace_entry"' not in line: continue
            e = json.loads(line)
            if e.get("tile_index") != APP_TILE or e["cycle"] < 3000: continue
            disp.append((e["cycle"], e.get("inst_ptr")))
    disp.sort()
    seq = [(c, pcs.get(p, "?")) for c, p in disp]
    out = {}
    for name, (a, b) in meta["MARK"].items():
        pat = lambda i: re.compile(rf"movri \S+ = 0x{0x7000 + i:04x}$")
        ia = next((k for k, (c, t) in enumerate(seq) if pat(a).match(t)), None)
        ib = next((k for k, (c, t) in enumerate(seq) if pat(b).match(t)), None)
        if ia is None or ib is None or ib <= ia: out[name] = {"error": "markers not found"}; continue
        span = seq[ia:ib + 1]
        hist = {}
        for _, t in span:
            mn = re.sub(r"^!?cflag\d+ \? ", "", t).split()[0]; hist[mn] = hist.get(mn, 0) + 1
        out[name] = {"cycles": seq[ib][0] - seq[ia][0], "instrs": len(span),
                     "hist": dict(sorted(hist.items(), key=lambda kv: -kv[1])[:10])}
    return out

def main():
    reuse = "--reuse-ir" in sys.argv
    print("=== gen"); print("   ", sh([sys.executable, "gen.py"]).stdout.strip())
    elf = HERE / "out" / "bin" / "out_0_0.elf"
    if not (reuse and (HERE / "ir").exists()):
        print("=== capture")
        r = sh([sys.executable, str(STUDY / "tools" / "cslc_ir.py"), "capture", "-o", "ir", "--"] + CSLC)
        if r.returncode: sys.exit("capture failed:\n" + (r.stdout + r.stderr)[-1500:])
        print("   ", r.stdout.strip().splitlines()[-1] if r.stdout.strip() else "")
        shutil.copy(elf, HERE / "out_0_0.orig.elf")
    prog = next(p for p in (HERE / "ir").iterdir() if p.is_dir() and (p / "program.ll").exists() and "east" not in p.name and "west" not in p.name)
    ll = (prog / "program.ll").read_text()
    body_tmpl = (HERE / "spmv_ir_body.ll").read_text()
    body_bound, bound = resolve_globals(ll, body_tmpl)
    print("=== resolved array symbols")
    for k, v in bound.items(): print(f"    {k:<10} -> {v}")
    patched, old_lines = splice(ll, body_bound)
    (HERE / "patched.ll").write_text(patched)
    print(f"=== splice: @spmv_ir body {old_lines} lines (from CSL) -> {len(body_bound.splitlines())} lines (hand-authored)")
    ok = False
    for attempt in range(4):
        time.sleep(6 if attempt == 0 else 20)
        r = sh([sys.executable, str(STUDY / "tools" / "cslc_ir.py"), "rebuild", str(prog), "-o", str(elf),
                "--ll", str(HERE / "patched.ll")])
        if r.returncode == 0 and elf.stat().st_size and (HERE / "out_0_0.orig.elf").read_bytes() != elf.read_bytes():
            ok = True; print("   ", r.stdout.strip().splitlines()[-1]); break
        print(f"    rebuild attempt {attempt + 1}: {(r.stdout + r.stderr).strip()[-260:] or 'no output'}")
    if not ok: sys.exit("REBUILD FAILED: the hand-authored IR was not accepted (see above)")
    print("=== run"); shutil.rmtree(HERE / "simfab_traces", ignore_errors=True)
    r = sh(["cs_python", "run.py", "--name", "out"])
    for line in r.stdout.splitlines():
        if line.strip().startswith(("scalar", "ir", "blk", "dia", "probe", "nnz")): print("   ", line.strip())
    if not (HERE / "result.json").exists(): sys.exit("run produced no result.json:\n" + (r.stdout + r.stderr)[-1200:])
    for _ in range(24):
        if (HERE / "simfab_traces" / "stream0").exists(): break
        time.sleep(5)
    sh([sys.executable, str(STUDY / "tools" / "decode_trace.py"), ".", "-o", "events.jsonl.gz"])
    sh([sys.executable, str(STUDY / "tools" / "csdisasm.py"), "out/bin/out_0_0.elf", "--json", "disasm.json"])
    meta = json.loads((HERE / "meta.json").read_text()); res = json.loads((HERE / "result.json").read_text())
    if not (HERE / "events.jsonl.gz").exists() or not (HERE / "disasm.json").exists(): sys.exit("no trace/disasm")
    per = measure(meta); nnz, dense = res["nnz"], res["dense_elems"]
    print(f"\n=== per-strategy cost on one PE (nnz={nnz})")
    print(f"  {'strategy':<9} {'verified':>8} {'cycles':>7} {'instrs':>7} {'cyc/nonzero':>12}   top mnemonics")
    for name in ("scalar", "ir", "blk", "dia", "blk_dsdred", "probe", "probe_const"):
        p = per.get(name, {}); v = res["strategies"].get(name, {}).get("ok", res.get("probe", {}).get("accumulated"))
        if "error" in p: print(f"  {name:<9} {str(v):>8}  {p['error']}"); continue
        n = 1 if name.startswith("probe") else nnz
        print(f"  {name:<9} {str(v):>8} {p['cycles']:>7} {p['instrs']:>7} {p['cycles']/n:>12.2f}   {', '.join(f'{k}x{c}' for k, c in list(p['hist'].items())[:5])}")
    (HERE / "measured.json").write_text(json.dumps({"per_strategy": per, "result": res}, indent=1))
    print("wrote", HERE / "measured.json")

if __name__ == "__main__":
    main()
