#!/usr/bin/env python3
"""Per-case reconstruction manifest: every artifact, its full SHA-256, and the exact commands.

A case is reconstructable from its manifest alone: the sources, the captured IR, the backend
and linker requests, the scripts, the object, the ELF, the disassembly and the verification
result, each with a full hash and a named algorithm.
"""
import hashlib, json, subprocess
from pathlib import Path
HERE = Path(__file__).resolve().parent
ALGO = "sha256"

def h(p: Path):
    return {"algorithm": ALGO, "hex": hashlib.sha256(p.read_bytes()).hexdigest(), "bytes": p.stat().st_size}

def main():
    cases = {}
    for d in sorted(p for p in (HERE / "cases").iterdir() if p.is_dir()):
        prog = next((q for q in (d / "ir").iterdir() if q.is_dir() and (q / "program.ll").exists()
                     and "east" not in q.name and "west" not in q.name), None)
        if prog is None: continue
        meta = json.loads((prog / "meta.json").read_text())
        files = {}
        for label, rel in (("layout.csl", d / "layout.csl"), ("pe.csl", d / "pe.csl"),
                           ("factor", d / "FACTOR.txt"), ("captured_ir", prog / "program.ll"),
                           ("object", prog / "program.o"), ("task_table", prog / "task.ld"),
                           ("link_script", prog / "link.ld"), ("backend_request", prog / "backend.request"),
                           ("linker_request", prog / "linker.request"), ("elf", d / "out" / "bin" / "out_0_0.elf"),
                           ("disassembly", d / "disasm.json"), ("verification", d / "verify.json")):
            if rel.exists(): files[label] = {"path": str(rel.relative_to(HERE)), **h(rel)}
        v = json.loads((d / "verify.json").read_text()) if (d / "verify.json").exists() else None
        cases[d.name] = {
            "factor": (d / "FACTOR.txt").read_text().splitlines()[0] if (d / "FACTOR.txt").exists() else None,
            "compile_command": "cslc " + " ".join(meta["cslc_args"]),
            "backend_command": "cslc-backend " + " ".join(meta["backend_argv"]) + "   (request on stdin)",
            "linker_command": "cslc-linker -v   (request on stdin)",
            "toolchain": {"cslang_bin": meta["cslang_bin"], "target_cpu": meta["backend_argv"][0],
                          "triple": meta["backend_argv"][1], "runtime_libraries": meta["libs"]},
            "files": files,
            "correctness": None if v is None else {"array": v["array"], "inputs": v["inputs"],
                                                   "expected": v["expected"], "observed": v["observed"], "ok": v["ok"]},
        }
    sdk = "/software/cerebras/cs_sdk-2.10"
    sif = sorted(Path(sdk).glob("*.sif"))
    out = {"hash_algorithm": ALGO,
           "sdk": {"root": sdk, "container": sif[0].name if sif else None},
           "capture_tool": {"path": "tools/cslc_ir.py",
                            **h(HERE.parent.parent / "tools" / "cslc_ir.py")},
           "harness": {"build": h(HERE / "build.py"), "run": h(HERE / "run.py")},
           "note": "An unmodified `cslc_ir.py rebuild <case>/ir/<program> -o x.elf` reproduces the ELF "
                   "byte-for-byte; that is the control for every differential result here.",
           "cases": cases}
    (HERE / "MANIFEST.json").write_text(json.dumps(out, indent=1))
    ok = sum(1 for c in cases.values() if (c["correctness"] or {}).get("ok"))
    nf = sum(len(c["files"]) for c in cases.values())
    print(f"{len(cases)} cases, {nf} artifacts hashed ({ALGO}), {ok} with a passing correctness check")
    print("wrote", HERE / "MANIFEST.json")

if __name__ == "__main__":
    main()
