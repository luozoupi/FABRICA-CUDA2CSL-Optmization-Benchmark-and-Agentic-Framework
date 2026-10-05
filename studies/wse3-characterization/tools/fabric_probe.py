#!/usr/bin/env python3
"""Static compiler-level fabric extractor for Cerebras WSE ELFs.

Runs cs_readelf over every per-PE ELF of a compiled bundle and merges the
results into one fabric-wide map: per-PE routing (rx/tx per color), switch
configuration, SRAM usage, and per-symbol memory-bank occupancy.

Evidence class: `compiled`. Everything here comes from the compiler's own
output for one specific compilation; nothing is inferred or simulated.
"""
from __future__ import annotations

import argparse, json, os, re, subprocess, sys
from collections import defaultdict
from pathlib import Path

ANSI = re.compile(r"\x1b\[[0-9;]*m")
INFO = re.compile(r"^\x1b?\[?\d*m?\[INFO\]|^\[INFO\]")

RE_COORD   = re.compile(r"^@\((\d+),\s*(\d+)\):\s*(.*)$")
RE_ROUTE   = re.compile(r"^\s*\[(\d+)\]\s*\(([^)]*)\)\s*(?:→|->)\s*\(([^)]*)\)\s*(.*)$")
RE_SWITCH  = re.compile(r"^\s*\[(\d+)\]\s*\[(.*?)\]\s*(.*)$")
RE_SWPOS   = re.compile(r"\s*(\S+)\s*(?:→|->)\s*\(([^)]*)\)")
RE_FS      = re.compile(r"fabric is (\d+)x(\d+)")
RE_MS      = re.compile(r"^\((\d+),\s*(\d+)\):\s*(\d+)\s*bytes")
RE_RECT    = re.compile(r"^(Block|Scatter)\s+#(\d+)\s+(\d+)x(\d+)\s+@\((\d+),(\d+)\)\s+\+(0x[0-9a-f]+)\s+\(\+(0x[0-9a-f]+)w\)\s+(\d+)\s+bytes")
RE_SYM     = re.compile(
    r"^\s*(\d+):\s+([0-9a-fA-F]+)\s+(\d+)\s+([0-7]*)\s+"
    r"(NOTYPE|OBJECT|FUNC|FILE|SECTION|TLS|COMMON)\s+"
    r"(LOCAL|GLOBAL|WEAK)\s+(\S+)\s*(.*?)\s*$")


# Prefer 2.10: that is the SDK the appliance/hardware campaign compiles and runs
# with, so a 2.10 reader is matched to the binaries that actually get measured.
# 1.4.0 remains a fallback for reading legacy locally-built bundles.
SDK_CANDIDATES = (
    "/software/cerebras/cs_sdk-2.10",
    os.path.expanduser("~/cs_sdk-2.10"),
    "/software/cerebras/cs_sdk-1.4.0",
    os.path.expanduser("~/cs_sdk-1.4.0"),
)


def _default_sdk() -> str:
    """First SDK directory that actually contains a cs_readelf wrapper.

    The per-user copy under $HOME is not guaranteed to exist -- it has been
    reclaimed before -- so fall back to the shared site install.
    """
    for candidate in SDK_CANDIDATES:
        if os.path.isfile(os.path.join(candidate, "cs_readelf")):
            return candidate
    return SDK_CANDIDATES[-1]


def clean(text: str) -> list[str]:
    out = []
    for line in text.splitlines():
        line = ANSI.sub("", line)
        if "[INFO]" in line or line.startswith("cs-readelf: Warning"):
            continue
        out.append(line)
    return out


def readelf(elf: Path, *flags: str, sdk: str) -> list[str]:
    env = dict(os.environ, PATH=f"{sdk}:{os.environ.get('PATH','')}")
    try:
        p = subprocess.run(["cs_readelf", *flags, elf.name],
                           cwd=elf.parent, env=env,
                           capture_output=True, text=True, timeout=300)
    except subprocess.TimeoutExpired:
        return []
    return clean(p.stdout + "\n" + p.stderr)


def parse_dirs(s: str) -> list[str]:
    s = s.strip()
    return [d for d in (x.strip() for x in s.split("|")) if d]


def parse_routing(lines):
    cur, out = None, {}
    for ln in lines:
        m = RE_COORD.match(ln)
        if m:
            cur = (int(m.group(1)), int(m.group(2)))
            if "no data" in m.group(3):
                cur = None
            else:
                out.setdefault(cur, {})
            continue
        if cur is None:
            continue
        m = RE_ROUTE.match(ln)
        if m:
            color, rx, tx, extra = int(m.group(1)), m.group(2), m.group(3), m.group(4)
            rxl, txl = parse_dirs(rx), parse_dirs(tx)
            if not rxl and not txl:
                continue                      # unconfigured color
            out[cur][color] = {
                "rx": rxl, "tx": txl,
                "teardown": "teardown" in extra,
                "flags": extra.strip(", ") or None,
            }
    return out


def parse_switching(lines):
    cur, out = None, {}
    for ln in lines:
        m = RE_COORD.match(ln)
        if m:
            cur = (int(m.group(1)), int(m.group(2)))
            if "no data" in m.group(3):
                cur = None
            else:
                out.setdefault(cur, {})
            continue
        if cur is None:
            continue
        m = RE_SWITCH.match(ln)
        if m:
            color, body, extra = int(m.group(1)), m.group(2), m.group(3)
            positions = []
            for pm in RE_SWPOS.finditer(body):
                src, dst = pm.group(1), parse_dirs(pm.group(2))
                if src == "INVALID" and not dst:
                    positions.append(None)
                else:
                    positions.append({"src": src, "tx": dst})
            if all(p is None for p in positions) and not extra.strip():
                continue
            out[cur][color] = {
                "positions": positions,
                "ring_mode": "ring mode" in extra,
                "extra": extra.strip(", ") or None,
            }
    return out


def parse_symbols(lines):
    syms = []
    for ln in lines:
        m = RE_SYM.match(ln)
        if not m:
            continue
        name = m.group(8).strip()
        if not name:
            continue
        banks = sorted({int(c) for c in m.group(4)})
        syms.append({
            "name": name,
            "addr": int(m.group(2), 16),
            "size": int(m.group(3)),
            "banks": banks,
            "type": m.group(5),
            "bind": m.group(6),
            "section": m.group(7),
        })
    return syms


def parse_ms(lines):
    out = {}
    for ln in lines:
        m = RE_MS.match(ln.strip())
        if m:
            out[(int(m.group(1)), int(m.group(2)))] = int(m.group(3))
    return out


def parse_rect(lines):
    segs = []
    for ln in lines:
        m = RE_RECT.match(ln.strip())
        if m:
            segs.append({
                "kind": m.group(1), "index": int(m.group(2)),
                "width": int(m.group(3)), "height": int(m.group(4)),
                "x": int(m.group(5)), "y": int(m.group(6)),
                "offset": int(m.group(7), 16), "bytes": int(m.group(9)),
            })
    return segs


def probe(out_dir: Path, sdk: str) -> dict:
    elfs = sorted(out_dir.rglob("*.elf"))
    fabric, pes = None, defaultdict(lambda: {
        "routes": {}, "switches": {}, "symbols": [], "sram_bytes": None,
        "sram_by_elf": {}, "segments": [], "elfs": []})

    for elf in elfs:
        rel = str(elf.relative_to(out_dir))
        fs = readelf(elf, "--fs", sdk=sdk)
        for ln in fs:
            m = RE_FS.search(ln)
            if m and fabric is None:
                fabric = [int(m.group(1)), int(m.group(2))]

        for coord, r in parse_routing(readelf(elf, "--routing", sdk=sdk)).items():
            pes[coord]["routes"].update({str(k): v for k, v in r.items()})
            if rel not in pes[coord]["elfs"]:
                pes[coord]["elfs"].append(rel)
        for coord, s in parse_switching(readelf(elf, "--switching", sdk=sdk)).items():
            pes[coord]["switches"].update({str(k): v for k, v in s.items()})
        for coord, b in parse_ms(readelf(elf, "--ms", sdk=sdk)).items():
            pes[coord]["sram_by_elf"][rel] = b
            # headline SRAM = the application ELF (out/bin/out_*.elf) when present
            if rel.startswith("bin/out_") or pes[coord]["sram_bytes"] is None:
                if rel.startswith("bin/out_") or not any(
                        k.startswith("bin/out_") for k in pes[coord]["sram_by_elf"]):
                    pes[coord]["sram_bytes"] = b
            if rel not in pes[coord]["elfs"]:
                pes[coord]["elfs"].append(rel)
        segs = parse_rect(readelf(elf, "--rect", sdk=sdk))
        syms = parse_symbols(readelf(elf, "--sym", sdk=sdk))
        # rect/sym are per-ELF; attribute to the coordinate(s) the ELF loads to
        targets = {(s["x"], s["y"]) for s in segs} or set(pes.keys())
        for t in targets:
            pes[t]["segments"].extend(segs)
            if syms and not pes[t]["symbols"]:
                pes[t]["symbols"] = syms
            if rel not in pes[t]["elfs"]:
                pes[t]["elfs"].append(rel)

    for coord, pe in pes.items():
        app = any(e.startswith("bin/out_") for e in pe["elfs"])
        colors = {int(c) for c in pe["routes"]}
        pe["role"] = ("application" if app else
                      "memcpy_infrastructure" if colors and colors <= {21, 22, 23} else
                      "support")
        pe["user_colors"] = sorted(c for c in colors if c < 21)
        pe["memcpy_colors"] = sorted(c for c in colors if c >= 21)
    return {
        "schema": "fabric_probe/1",
        "evidence": "compiled",
        "out_dir": str(out_dir),
        "fabric_dims": fabric,
        "pes": {f"{x},{y}": v for (x, y), v in sorted(pes.items())},
    }


DIR_ARROW = {"NORTH": "↑", "SOUTH": "↓", "EAST": "→", "WEST": "←", "RAMP": "•"}


def render_map(doc: dict) -> str:
    pes = {tuple(int(c) for c in k.split(",")): v for k, v in doc["pes"].items()}
    if not pes:
        return "(no PEs with compiler data)"
    xs = [p[0] for p in pes]; ys = [p[1] for p in pes]
    lines = []
    lines.append(f"fabric {doc['fabric_dims']}   occupied x:{min(xs)}..{max(xs)} y:{min(ys)}..{max(ys)}")
    lines.append("")
    for y in range(min(ys), max(ys) + 1):
        row = []
        for x in range(min(xs), max(xs) + 1):
            pe = pes.get((x, y))
            if not pe:
                row.append("  .   ")
                continue
            tx = set()
            for c, r in pe["routes"].items():
                tx.update(r["tx"])
            cell = "".join(DIR_ARROW.get(d, "") for d in ("WEST", "NORTH", "RAMP", "SOUTH", "EAST") if d in tx)
            row.append(f"{cell or '·':^6}")
        lines.append(f"y={y:<3}" + "".join(row))
    lines.append("")
    lines.append("per-PE colors (rx → tx):")
    for (x, y), pe in sorted(pes.items()):
        if not pe["routes"]:
            continue
        lines.append(f"  PE({x},{y})  sram={pe['sram_bytes']}B")
        for c in sorted(pe["routes"], key=int):
            r = pe["routes"][c]
            td = "  [teardown]" if r["teardown"] else ""
            lines.append(f"      color {c:>2}: {'|'.join(r['rx']) or '-':<12} → {'|'.join(r['tx']) or '-':<12}{td}")
    return "\n".join(lines)


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("out_dir")
    ap.add_argument("--sdk", default=_default_sdk(),
                    help="directory holding the cs_readelf wrapper")
    ap.add_argument("--json", help="write JSON here")
    ap.add_argument("--quiet", action="store_true")
    a = ap.parse_args()
    doc = probe(Path(a.out_dir), a.sdk)
    if a.json:
        Path(a.json).parent.mkdir(parents=True, exist_ok=True)
        Path(a.json).write_text(json.dumps(doc, indent=2))
    if not a.quiet:
        print(render_map(doc))
    return 0


if __name__ == "__main__":
    sys.exit(main())
