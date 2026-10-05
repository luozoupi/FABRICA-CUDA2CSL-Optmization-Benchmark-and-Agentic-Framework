#!/usr/bin/env python3
"""Compiled-code artifacts for the optimizer's IR/disassembly feedback channel (v2 sparse study).

After a benchmark has PASSED, this module can (a) disassemble the measured PE ELF(s) with
`studies/wse3-characterization/tools/csdisasm.py` and (b) re-compile the staged bundle
through `tools/cslc_ir.py capture`, which intercepts `cslc-backend` and keeps the LLVM IR of
every PE program. The measured compile is never touched: the shadow compile writes to a
scratch output and its ELF hash is compared with the benchmarked ELF
(`elf_matches_benchmark`), so cycles are unaffected by construction.

Modes (`XKERNEL_IR_CAPTURE`):
  0       nothing (default)
  disasm  disassembly of the measured ELF only (works with any SDK; the 2.10 elf2am reads 1.4 ELFs)
  best    disassembly + IR capture (the optimizer requests it for the baseline and accepted winners)
  all     disassembly + IR capture for every passing candidate (hazard census)

Everything lands under `<staged_bundle>/.xkernel_ir/` where `profile_csl._find_artifacts`
picks it up through `ir_readout.build_ir_readout`. Failures never fail the benchmark: the
result carries `status: failed` and a reason. Container jobs are serial on a node; callers
hold `benchmark_csl._singularity_gate()` around this module.
"""
from __future__ import annotations

import hashlib
import json
import os
import re
import shlex
import shutil
import subprocess
import sys
import time
from pathlib import Path
from typing import Dict, List, Optional

MODES = ("0", "disasm", "best", "all")
IR_DIR = ".xkernel_ir"
REPO_ROOT = Path(__file__).resolve().parents[1]
STUDY_TOOLS = REPO_ROOT / "studies" / "wse3-characterization" / "tools"
_SHELL_META = re.compile(r"[;&|`$<>]")


def mode_from_env(default: str = "0") -> str:
    m = os.environ.get("XKERNEL_IR_CAPTURE", default).strip().lower() or "0"
    return m if m in MODES else "0"


def wants_ir(mode: str) -> bool:
    return mode in ("best", "all")


def study_root() -> Path:
    env = os.environ.get("XKERNEL_WSE3_STUDY_ROOT")
    return Path(env) if env else REPO_ROOT / "studies" / "wse3-characterization"


def compile_argv_from_transcript(transcript: List[Dict[str, object]], shadow_out: str) -> Optional[List[str]]:
    """The measured `cslc` command line, as argv without the leading `cslc`, with its `-o`
    redirected to `shadow_out`. None when there is not exactly one plain compile step."""
    cmds = []
    for entry in transcript or []:
        cmd = str(entry.get("command") or "")
        step = str(entry.get("step") or "")
        if step.startswith("compile") or re.match(r"^\s*cslc(\s|$)", cmd):
            cmds.append(cmd)
    if len(cmds) != 1 or _SHELL_META.search(cmds[0]):
        return None
    argv = shlex.split(cmds[0])
    if not argv or Path(argv[0]).name != "cslc":
        return None
    argv = argv[1:]
    if "-o" not in argv:
        return None
    i = argv.index("-o")
    if i + 1 >= len(argv):
        return None
    argv[i + 1] = shadow_out
    return argv


def elf_sha16(path) -> str:
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()[:16]


def application_elfs(staged_bundle: str, out_dir: str = "out", limit: int = 2) -> List[Path]:
    """The PE program ELFs of the measured build (`out/bin/*.elf`), smallest PE coordinates
    first, at most `limit` of them (PE 0 and its neighbour cover source and receiver roles)."""
    bin_dir = Path(staged_bundle) / out_dir / "bin"
    elfs = sorted(bin_dir.glob("*.elf"), key=lambda p: [int(x) for x in re.findall(r"\d+", p.stem)] or [0])
    return elfs[:limit]


def _run(cmd: List[str], cwd: str, env: Dict[str, str], timeout: int) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, cwd=cwd, env=env, capture_output=True, text=True, timeout=timeout)


def disassemble(elf: Path, out_json: Path, sdk_root: str, env: Dict[str, str], timeout: int) -> Dict[str, object]:
    tool = study_root() / "tools" / "csdisasm.py"
    if not tool.is_file():
        return {"status": "skipped", "reason": f"no csdisasm.py at {tool}"}
    out_json.parent.mkdir(parents=True, exist_ok=True)
    cmd = [sys.executable, str(tool), str(elf), "--json", str(out_json), "--no-source"]
    if sdk_root and ("2.10" in str(sdk_root) or
                     str(env.get("XKERNEL_TARGET_SDK", "")).startswith("2.10")):
        cmd += ["--sdk", str(sdk_root)]
    t0 = time.time()
    try:
        r = _run(cmd, cwd=str(elf.parent), env=env, timeout=timeout)
    except subprocess.TimeoutExpired:
        return {"status": "failed", "reason": "csdisasm timeout", "elf": str(elf)}
    if r.returncode != 0 or not out_json.is_file():
        return {"status": "failed", "reason": (r.stderr or r.stdout or "")[-400:], "elf": str(elf)}
    try:
        n = len(json.loads(out_json.read_text()).get("records", []))
    except ValueError:
        n = None
    return {"status": "ok", "elf": str(elf), "json": str(out_json), "records": n, "elapsed_s": round(time.time() - t0, 1)}


def capture_ir(staged_bundle: str, argv: List[str], sdk_root: str, env: Dict[str, str], timeout: int) -> Dict[str, object]:
    tool = study_root() / "tools" / "cslc_ir.py"
    if not tool.is_file():
        return {"status": "skipped", "reason": f"no cslc_ir.py at {tool}"}
    cap = Path(staged_bundle) / IR_DIR / "cap"
    shutil.rmtree(cap, ignore_errors=True)
    env = dict(env)
    if "CS_SDK_SIF" not in env:
        try:
            from workflow_common import sdk_sif_path
            sif = sdk_sif_path(sdk_root)
            if sif:
                env["CS_SDK_SIF"] = str(sif)
        except Exception:                                      # the tool falls back to its own globs
            pass
    cmd = [sys.executable, str(tool), "capture", "-o", str(cap), "--"] + list(argv)
    t0 = time.time()
    try:
        r = _run(cmd, cwd=staged_bundle, env=env, timeout=timeout)
    except subprocess.TimeoutExpired:
        return {"status": "failed", "reason": "cslc_ir capture timeout"}
    if r.returncode != 0:
        return {"status": "failed", "reason": (r.stderr or r.stdout or "")[-600:]}
    programs = []
    for meta_path in sorted(cap.glob("*/meta.json")):
        meta = json.loads(meta_path.read_text())
        programs.append({"name": meta_path.parent.name, "dir": str(meta_path.parent), "ll": str(meta_path.parent / "program.ll"),
                         "elf": meta.get("elf"), "elf_sha": meta.get("elf_sha")})
    return {"status": "ok" if programs else "failed", "programs": programs, "elapsed_s": round(time.time() - t0, 1),
            "reason": "" if programs else "capture produced no program"}


def capture_ir_artifacts(staged_bundle: str, transcript: List[Dict[str, object]], sdk_root: str,
                         mode: str, env: Optional[Dict[str, str]] = None, timeout: int = 600) -> Dict[str, object]:
    """Disassemble the measured ELF(s) and, in `best`/`all` mode, capture the LLVM IR by a
    shadow compile. Returns a status dict; never raises."""
    t0 = time.time()
    out: Dict[str, object] = {"schema": "ir_artifacts/1", "mode": mode, "status": "skipped", "reason": "", "disasm": [], "programs": [],
                              "elf_matches_benchmark": None}
    if mode not in MODES or mode == "0":
        return out
    try:
        bundle = Path(staged_bundle)
        ir_dir = bundle / IR_DIR
        ir_dir.mkdir(exist_ok=True)
        env = dict(env or os.environ)
        env["TMPDIR"] = str(ir_dir / "tmp"); (ir_dir / "tmp").mkdir(exist_ok=True)   # container-visible scratch
        elfs = application_elfs(staged_bundle)
        if not elfs:
            out.update(status="failed", reason="no out/bin/*.elf in the staged bundle"); return out
        for elf in elfs:
            out["disasm"].append(disassemble(elf, ir_dir / "disasm" / (elf.stem + ".json"), sdk_root, env, timeout))
        if wants_ir(mode):
            shadow = ir_dir / "shadow_out"
            argv = compile_argv_from_transcript(transcript, str(shadow))
            if argv is None:
                out["ir"] = {"status": "skipped", "reason": "no single plain cslc compile step in the transcript"}
            else:
                cap = capture_ir(staged_bundle, argv, sdk_root, env, timeout)
                out["ir"] = cap
                out["programs"] = cap.get("programs", [])
                if cap.get("status") == "ok":
                    measured = {p.name: elf_sha16(p) for p in application_elfs(staged_bundle, limit=64)}
                    matches = []
                    for prog in out["programs"]:
                        name = Path(str(prog.get("elf") or "")).name
                        if name in measured:
                            matches.append(measured[name] == prog.get("elf_sha"))
                    out["elf_matches_benchmark"] = (all(matches) if matches else None)
                shutil.rmtree(shadow, ignore_errors=True)                 # keep _find_artifacts' elf_count unchanged
        ok_disasm = any(d.get("status") == "ok" for d in out["disasm"])
        ok_ir = (not wants_ir(mode)) or (out.get("ir", {}).get("status") == "ok")
        out["status"] = "ok" if (ok_disasm and ok_ir) else ("partial" if (ok_disasm or ok_ir) else "failed")
        if out["status"] != "ok" and not out["reason"]:
            out["reason"] = "; ".join(str(d.get("reason") or "") for d in out["disasm"] if d.get("status") != "ok") or str(out.get("ir", {}).get("reason") or "")
    except Exception as exc:                                                   # never fail the benchmark
        out.update(status="failed", reason=f"{type(exc).__name__}: {exc}")
    out["elapsed_s"] = round(time.time() - t0, 1)
    return out
