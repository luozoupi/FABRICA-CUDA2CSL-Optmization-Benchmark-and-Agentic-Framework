#!/usr/bin/env python3
"""The layer below CSL: capture the LLVM IR cslc generates, edit it, rebuild the ELF.

cslc (SDK 2.10) is a Python front-end around three container binaries:

    cslc-driver   CSL  -> LLVM IR   writes <tmp>/cslc-*.ll (textual IR, triple
                                    cs_sdr-cerebras-csos, cpu schrodinger)
    cslc-backend  IR   -> object    stdin: "<in.ll>\\n<out.o>\\n<task-table.ld>\\n\\n"
    cslc-linker   obj  -> ELF       stdin: "<in.o>\\n<link.ld>\\n<out.elf>\\n<lib>\\n<lib>\\n"

There is no flag that keeps the IR, but the temp directory is alive while the backend
runs, so binding a wrapper over the cslang bin directory captures everything and stays
transparent (the produced ELF is byte-identical -- checked on every capture).  The
backend and linker run standalone on the captured requests, which makes the IR a real
programming surface: patch attributes (e.g. `optnone` to stop the scheduler reordering
a microbenchmark), add inline Cerebras assembly (`call void asm sideeffect "movri r5 =
0x1234", ""()` -- the backend's integrated assembler accepts the disassembler's syntax),
or write a function by hand, then rebuild and run the ELF on the simulator.

    cslc_ir.py capture -o ir_cap -- ./layout.csl --arch=wse3 ... -o out --memcpy ...
    cslc_ir.py rebuild ir_cap/out_0_0 -o patched.elf --optnone compute
    cslc_ir.py rebuild ir_cap/out_0_0 -o patched.elf --asm-after 'store i16 23040,' 'movri r5 = 0x1234'
    cslc_ir.py rebuild ir_cap/out_0_0 -o same.elf          # no patches: reproduces cslc's ELF

Evidence class of what this exposes: `compiled` (the ELF is Cerebras's own toolchain
output; nothing here is emulated).  Requires singularity and the SDK SIF.
"""
from __future__ import annotations
import argparse, glob, hashlib, json, os, re, shutil, subprocess, sys, tempfile
from pathlib import Path

SIF_GLOBS = (os.environ.get("CS_SDK_SIF", ""), "/software/cerebras/cs_sdk-2.10/*.sif", os.path.expanduser("~/cs_sdk-2.10/*.sif"))

def sif_path():
    for g in SIF_GLOBS:
        for p in glob.glob(g):
            if p.endswith(".sif"): return p
    sys.exit("SDK SIF not found; set CS_SDK_SIF")

def sing(sif, binds, args, **kw):
    # --pwd is explicit: the container's working directory must not be inherited from this
    # process, because `singularity` may be a relay to another host (the SDK is installed on
    # the Cerebras user node, not the login nodes) where the default cwd is the home directory.
    pwd = kw.get("cwd")
    cmd = ["singularity", "exec"] + sum((["-B", b] for b in binds), [])
    if pwd: cmd += [f"--pwd={pwd}"]
    cmd += [sif] + args
    # Over an ssh relay, bursts of short sessions are dropped intermittently (empty output, non-zero
    # exit) and the container image mount can time out ("squashfuse", "container creation failed").
    # Those are transport failures, not tool failures: retry them, with a pause, up to three times.
    import time
    for attempt in range(3):
        r = subprocess.run(cmd, **kw)
        out = ((r.stdout or b"") if isinstance(r.stdout, (bytes, type(None))) else r.stdout) or ""
        err = ((r.stderr or b"") if isinstance(r.stderr, (bytes, type(None))) else r.stderr) or ""
        text = (out if isinstance(out, str) else out.decode(errors="replace")) + (err if isinstance(err, str) else err.decode(errors="replace"))
        transport = r.returncode != 0 and (not text.strip() or any(k in text for k in ("squashfuse", "container creation failed", "ssh_exchange", "Connection closed", "Connection reset", "kex_exchange")))
        if not transport or attempt == 2: return r
        time.sleep(12 * (attempt + 1))                   # the relay's penalty window outlasts a few seconds
    return r

def cslang_bin(sif):
    r = sing(sif, [], ["sh", "-c", "ls -d /cb/toolchains/cslang/*/*/bin"], capture_output=True, text=True)
    dirs = [l for l in r.stdout.split() if l]
    if not dirs: sys.exit("cannot find cslang bin dir in the container: " + r.stderr[-300:])
    return dirs[-1]

WRAPPER = r'''#!/usr/bin/env python3
# cslc_ir.py capture wrapper for {tool}: record the request, the driver's temp dir and the result; then run the real tool.
import sys, os, json, glob, shutil, subprocess, tempfile
CAP = {cap!r}; os.makedirs(CAP, exist_ok=True)
# Compiler workers run concurrently: a glob count can reuse another worker's name.
fd, request_path = tempfile.mkstemp(prefix="{tool}-", suffix=".request", dir=CAP)
tag = os.path.basename(request_path)[:-len(".request")]
data = sys.stdin.buffer.read()
with os.fdopen(fd, "wb") as request_file: request_file.write(data)
paths = [l for l in data.decode(errors="replace").split("\n") if l.startswith("/")]
tmpdirs = sorted({{os.path.dirname(p) for p in paths if "/tmp/cslc-" in p}})
for d in tmpdirs:
    try: shutil.copytree(d, os.path.join(CAP, tag + "-tmp", os.path.basename(d)), dirs_exist_ok=True)
    except Exception as e: open(os.path.join(CAP, tag + ".err"), "a").write("copy %s: %s\n" % (d, e))
json.dump({{"argv": sys.argv[1:], "cwd": os.getcwd(), "paths": paths}}, open(os.path.join(CAP, tag + ".json"), "w"), indent=1)
r = subprocess.run([os.path.join(os.path.dirname(os.path.abspath(__file__)), "{tool}.real")] + sys.argv[1:], input=data, capture_output=True)
open(os.path.join(CAP, tag + ".stdout"), "wb").write(r.stdout); open(os.path.join(CAP, tag + ".stderr"), "wb").write(r.stderr)
sys.stdout.buffer.write(r.stdout); sys.stderr.buffer.write(r.stderr); sys.exit(r.returncode)
'''

def sha(p): return hashlib.sha256(Path(p).read_bytes()).hexdigest()[:16]

def capture_program_name(elf_path, cwd):
    """Keep routing/application programs distinct, including external shadow outputs."""
    elf = Path(elf_path)
    try:
        rel = str(elf.relative_to(cwd))
    except ValueError:
        # A basename alone aliases application, east and west out_0_0.elf files.
        stem = re.sub(r"[^A-Za-z0-9_.-]+", "_", elf.stem)
        digest = hashlib.sha256(str(elf.resolve()).encode()).hexdigest()[:16]
        return f"external_{stem}_{digest}"
    return re.sub(r"[^A-Za-z0-9_.-]+", "_", rel.replace("/bin/", "/")).replace(".elf", "").strip("_")


def capture(a):
    sif = sif_path(); cb = cslang_bin(sif); cwd = Path.cwd().resolve()
    out = Path(a.out).resolve(); out.mkdir(parents=True, exist_ok=True)
    raw = out / "_raw"; shutil.rmtree(raw, ignore_errors=True); raw.mkdir()
    hostbin = out / "_bin"; shutil.rmtree(hostbin, ignore_errors=True); hostbin.mkdir()
    for tool in ("cslc", "cslc-driver", "cslc-backend", "cslc-linker"):
        data = sing(sif, [], ["cat", f"{cb}/{tool}"], capture_output=True).stdout
        dst = hostbin / (tool + (".real" if tool in ("cslc-backend", "cslc-linker") else ""))
        dst.write_bytes(data); dst.chmod(0o755)
    for tool in ("cslc-backend", "cslc-linker"):
        w = hostbin / tool; w.write_text(WRAPPER.format(tool=tool, cap=str(raw))); w.chmod(0o755)
    binds = sorted({str(cwd), str(out)})
    r = sing(sif, binds + [f"{hostbin}:{cb}"], [f"{cb}/cslc"] + a.cslc_args, cwd=str(cwd))
    if r.returncode: sys.exit(f"cslc failed with exit {r.returncode}")
    # pair each linker request with the backend request that produced its object
    programs = []
    for lreq in sorted(raw.glob("cslc-linker-*.request")):
        lp = [l for l in lreq.read_text().split("\n") if l.startswith("/")]
        o_path, ld_path, elf_path = lp[0], lp[1], lp[2]; libs = lp[3:]
        breq = next((b for b in sorted(raw.glob("cslc-backend-*.request")) if o_path in b.read_text()), None)
        if breq is None: continue
        bp = [l for l in breq.read_text().split("\n") if l.startswith("/")]
        ll_path, tt_path = bp[0], bp[2]
        tmpname = Path(ll_path).parent.name
        pre = raw / (breq.stem + "-tmp") / tmpname; post = raw / (lreq.stem + "-tmp") / tmpname
        name = capture_program_name(elf_path, cwd)
        d = out / name; d.mkdir(exist_ok=True)
        shutil.copy(pre / Path(ll_path).name, d / "program.ll")
        shutil.copy(post / Path(o_path).name, d / "program.o"); shutil.copy(post / Path(tt_path).name, d / "task.ld"); shutil.copy(post / Path(ld_path).name, d / "link.ld")
        shutil.copy(breq, d / "backend.request"); shutil.copy(lreq, d / "linker.request")
        meta = {"elf": elf_path, "elf_sha": sha(elf_path) if Path(elf_path).exists() else None, "o_sha": sha(d / "program.o"), "backend_argv": json.loads(breq.with_suffix(".json").read_text())["argv"],
                "paths": {"ll": ll_path, "o": o_path, "task_ld": tt_path, "link_ld": ld_path, "elf": elf_path}, "libs": libs, "cwd": str(cwd), "cslang_bin": cb, "cslc_args": a.cslc_args}
        (d / "meta.json").write_text(json.dumps(meta, indent=1))
        ir = (d / "program.ll").read_text()
        funcs = re.findall(r"^define [^@]*@([^\s(]+)", ir, re.M)
        programs.append((name, len(ir.splitlines()), len(funcs), meta["elf_sha"]))
    if not a.keep_raw: shutil.rmtree(raw); shutil.rmtree(hostbin)
    print(f"{'program':<24} {'IR lines':>8} {'functions':>9}  elf sha")
    for n, l, f, s in programs: print(f"{n:<24} {l:>8} {f:>9}  {s}")
    print("wrote", out)

def patch_ir(ir, optnone, asm_after):
    n_attr = max([int(x) for x in re.findall(r"^attributes #(\d+)", ir, re.M)] + [-1]) + 1
    for fn in optnone:
        pat = re.compile(rf"^(define [^\n]*@{re.escape(fn)}\([^\n]*?\))(\s+#\d+)?([^\n{{]*\{{)", re.M)
        m = pat.search(ir)
        if not m: sys.exit(f"function @{fn} not found")
        if m.group(2):  # extend the existing attribute group
            g = m.group(2).strip()[1:]
            ir = re.sub(rf"^(attributes #{g} = \{{)", r"\1 noinline optnone", ir, count=1, flags=re.M)
        else:
            ir = ir[:m.start()] + m.group(1) + f" #{n_attr}" + m.group(3) + ir[m.end():]
            ir += f"\nattributes #{n_attr} = {{ noinline optnone }}\n"; n_attr += 1
    for regex, asm in asm_after:
        m = re.search(regex, ir)
        if not m: sys.exit(f"--asm-after anchor not found: {regex}")
        eol = ir.index("\n", m.end()) + 1
        ir = ir[:eol] + f'  call void asm sideeffect "{asm}", ""()\n' + ir[eol:]
    return ir

def rebuild(a):
    sif = sif_path(); d = Path(a.program).resolve(); meta = json.loads((d / "meta.json").read_text())
    work = Path(tempfile.mkdtemp(prefix="cslc_ir_", dir=str(d))); out = Path(a.out).resolve()
    ir = Path(a.ll).read_text() if a.ll else (d / "program.ll").read_text()
    ir = patch_ir(ir, a.optnone, [tuple(x) for x in a.asm_after])
    ll = work / "program.ll"; ll.write_text(ir); o = work / "program.o"; tt = work / "task.ld"; ld = work / "link.ld"; elf = work / "program.elf"
    o.write_bytes(b""); tt.write_text("")
    p = meta["paths"]; cb = meta["cslang_bin"]
    breq = (d / "backend.request").read_text().replace(p["ll"], str(ll)).replace(p["o"], str(o)).replace(p["task_ld"], str(tt))
    lreq = (d / "linker.request").read_text().replace(p["o"], str(o)).replace(p["link_ld"], str(ld)).replace(p["elf"], str(elf))
    ld.write_text((d / "link.ld").read_text())
    binds = [str(d)]
    r = sing(sif, binds, [f"{cb}/cslc-backend"] + meta["backend_argv"], input=breq, capture_output=True, text=True)
    if r.returncode or not o.stat().st_size: sys.exit("backend failed:\n" + (r.stderr or r.stdout)[-1500:])
    r = sing(sif, binds, [f"{cb}/cslc-linker", "-v"], input=lreq, capture_output=True, text=True)
    if r.returncode or not elf.exists(): sys.exit("linker failed:\n" + (r.stderr or r.stdout)[-1500:])
    out.parent.mkdir(parents=True, exist_ok=True); shutil.copy(elf, out)
    same = sha(out) == meta["elf_sha"]
    print(f"object {o.stat().st_size} B (captured {Path(d / 'program.o').stat().st_size} B){' identical' if sha(o) == meta['o_sha'] else ''}; ELF {out.stat().st_size} B -> {out}"
          + ("  [byte-identical to cslc's ELF]" if same else "  [differs from cslc's ELF" + (": patched" if (a.optnone or a.asm_after or a.ll) else " -- unexpected") + "]"))
    if not a.keep_work: shutil.rmtree(work)

def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sp = ap.add_subparsers(dest="cmd", required=True)
    c = sp.add_parser("capture", help="run cslc through the interception and save per-program IR"); c.add_argument("-o", "--out", required=True); c.add_argument("--keep-raw", action="store_true")
    c.add_argument("cslc_args", nargs=argparse.REMAINDER, help="everything after -- goes to cslc"); c.set_defaults(fn=capture)
    b = sp.add_parser("rebuild", help="backend + linker on captured (optionally patched) IR"); b.add_argument("program"); b.add_argument("-o", "--out", required=True)
    b.add_argument("--ll", help="use this .ll instead of the captured one"); b.add_argument("--optnone", action="append", default=[], metavar="FUNC", help="add noinline optnone to @FUNC")
    b.add_argument("--asm-after", action="append", nargs=2, default=[], metavar=("REGEX", "ASM"), help="insert inline asm after the first IR line matching REGEX"); b.add_argument("--keep-work", action="store_true"); b.set_defaults(fn=rebuild)
    a = ap.parse_args()
    if a.cmd == "capture" and a.cslc_args and a.cslc_args[0] == "--": a.cslc_args = a.cslc_args[1:]
    a.fn(a)

if __name__ == "__main__":
    main()
