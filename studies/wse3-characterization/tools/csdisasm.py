#!/usr/bin/env python3
"""Static Cerebras disassembler front-end.

The public SDK ships no working `llvm-objdump` for the Cerebras target, so
`elf2lst`'s code dump always fails. But `elf2am` links
`libLLVMCerebrasDisassembler` and `libLLVMCerebrasInstPrinter` **in process** and
does disassemble -- it just writes a binary ".am" (address map) rather than text.

This tool runs `elf2am` on a PE ELF and parses that binary into a readable
listing: address, decoded instruction, and the CSL source line it came from.

Evidence class: `compiled`. Every instruction here is decoded from the ELF's own
bytes by Cerebras's disassembler, not inferred.

.am record format (little-endian), verified against `od` output:
    u32   pc          byte address
    u64   path_len
    bytes path        source file
    u64   text_len
    bytes text        "<source line text> (<disassembled instruction>)"
    u32   trailer
"""
from __future__ import annotations

import argparse
import json
import os
import shutil
import re
import struct
import subprocess
import tempfile
import sys
from pathlib import Path

SIF_CANDIDATES = (
    "/software/cerebras/cs_sdk-2.10",
    os.path.expanduser("~/cs_sdk-2.10"),
)
ELF2AM_GLOB = "/cb/toolchains/llvm/cerebras/*/bin/elf2am"

# "<source> (<instruction>)" -- the instruction is the LAST parenthesised group,
# because source lines legitimately contain their own parentheses.
INSTR_RE = re.compile(r"\(([^()]*)\)\s*$")


class DisasmError(RuntimeError):
    pass


def _sdk_dir() -> str:
    for cand in SIF_CANDIDATES:
        if os.path.isfile(os.path.join(cand, "cs_python")):
            return cand
    raise DisasmError("no SDK directory with cs_python found")


def run_elf2am(elf: Path, out_am: Path, sdk: str | None = None) -> None:
    """Invoke elf2am inside the SDK container.

    The container mounts only the working directory, so elf2am can see neither an
    absolute path nor anything above cwd.  Rather than make that the caller's
    problem, stage the ELF into a scratch dir under bare basenames, run there, and
    copy the .am back out.
    """
    sdk = sdk or _sdk_dir()
    env = dict(os.environ, PATH=f"{sdk}:{os.environ.get('PATH','')}")
    with tempfile.TemporaryDirectory(prefix="csdisasm_") as work:
        workdir = Path(work)
        staged = workdir / elf.name
        shutil.copyfile(elf, staged)
        produced = workdir / out_am.name
        script = (
            "import glob,subprocess,sys\n"
            f"c=glob.glob({ELF2AM_GLOB!r})\n"
            "if not c: sys.exit('elf2am not found in container')\n"
            f"p=subprocess.run([c[0], '-o={produced.name}', {staged.name!r}],"
            " capture_output=True, text=True)\n"
            "sys.stdout.write(p.stdout + p.stderr)\n"
            "sys.exit(p.returncode)\n"
        )
        proc = subprocess.run(["cs_python", "-c", script], cwd=workdir,
                              env=env, capture_output=True, text=True, timeout=600)
        if proc.returncode != 0 or not produced.exists():
            raise DisasmError(f"elf2am failed: {(proc.stdout + proc.stderr)[:400]}")
        out_am.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(produced, out_am)


def parse_am(path: Path) -> list[dict]:
    """Parse the .am binary into records. Tolerates a truncated tail."""
    data = path.read_bytes()
    out: list[dict] = []
    off, n = 0, len(data)
    while off + 12 <= n:
        try:
            (pc,) = struct.unpack_from("<I", data, off); off += 4
            (plen,) = struct.unpack_from("<Q", data, off); off += 8
            if plen > n - off:
                break
            src_path = data[off:off + plen].decode("utf-8", "replace"); off += plen
            (tlen,) = struct.unpack_from("<Q", data, off); off += 8
            if tlen > n - off:
                break
            text = data[off:off + tlen].decode("utf-8", "replace"); off += tlen
            off += 4                                    # trailer
        except struct.error:
            break
        m = INSTR_RE.search(text.rstrip())
        instr = m.group(1).strip() if m else None
        source = text[:m.start()].strip() if m else text.strip()
        if source.startswith("<cannot obtain source line>"):
            source = ""
        out.append({"pc": pc, "instruction": instr, "source": source,
                    "source_file": src_path, "raw": text})
    return out


def mnemonic_of(instr: str | None) -> str | None:
    if not instr:
        return None
    tok = instr.split()
    if not tok:
        return None
    # predicated forms print as "cflag0 ? jmp 0x4c"
    if len(tok) >= 3 and tok[1] == "?":
        tok = tok[2:]
    return tok[0]


def render(records: list[dict], show_source: bool = True) -> str:
    lines = [f"{'addr':>8}  {'instruction':<44}{'source' if show_source else ''}",
             "-" * (56 + (30 if show_source else 0))]
    last_src = None
    for r in records:
        if r["instruction"] is None:
            continue
        src = ""
        if show_source and r["source"] and r["source"] != last_src:
            src = r["source"][:80]
            last_src = r["source"]
        lines.append(f"  0x{r['pc']:04x}  {r['instruction']:<44}{src}")
    return "\n".join(lines)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("target", help="a PE .elf, or an existing .am file")
    ap.add_argument("--json", help="write records as JSON here")
    ap.add_argument("--no-source", action="store_true", help="omit CSL source lines")
    ap.add_argument("--summary", action="store_true", help="print a mnemonic histogram")
    ap.add_argument("--sdk", default=None)
    a = ap.parse_args()

    target = Path(a.target).expanduser().resolve()
    if target.suffix == ".am":
        am = target
    else:
        am = target.parent / (target.stem + ".am")
        run_elf2am(target, am, a.sdk)

    records = parse_am(am)
    decoded = [r for r in records if r["instruction"]]
    if a.json:
        Path(a.json).parent.mkdir(parents=True, exist_ok=True)
        Path(a.json).write_text(json.dumps(
            {"schema": "csdisasm/1", "evidence": "compiled",
             "source_elf": str(target), "records": records}, indent=2))

    if a.summary:
        import collections
        hist = collections.Counter(mnemonic_of(r["instruction"]) for r in decoded)
        print(f"records: {len(records)}   decoded instructions: {len(decoded)}   "
              f"distinct mnemonics: {len(hist)}")
        for name, count in hist.most_common():
            print(f"  {name:<16}{count:>7}")
    else:
        print(render(records, show_source=not a.no_source))
    return 0


if __name__ == "__main__":
    sys.exit(main())
