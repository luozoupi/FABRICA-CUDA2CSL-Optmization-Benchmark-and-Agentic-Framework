"""device_internal_v2 timing protocol: shared instrumenter and contract check.

The measured window starts with `f_tic_dev()` as the FIRST statement of every
host-launched entry point (an exported `fn` that is not a timing helper) and
ends with `f_toc_dev()` IMMEDIATELY before every `sys_mod.unblock_cmd_stream()`
that lets the host continue, outside the timing helpers. Both helpers' bodies
are frozen by the contract check; this module checks the call structure without
assuming anything about the program's task decomposition, so an agent program
that ends its computation in a different task than the reference still passes.
"""
from __future__ import annotations

import re
from typing import List, Optional, Tuple

TIC, TOC = "f_tic_dev", "f_toc_dev"
HELPER_FNS = ("f_enable_timer", "f_tic", "f_toc", "f_memcpy_timestamps", "f_reference_timestamps", TIC, TOC)

_DEF_RE = re.compile(r"\b(fn|task)\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(")
# @export_symbol(name) or @export_symbol(name, "alias") -- the first argument is the CSL symbol
_EXPORT_RE = re.compile(r"@export_symbol\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*(?:,[^)]*)?\)")
_UNBLOCK_RE = re.compile(r"(?m)^([ \t]*)(?:sys_mod|[A-Za-z_][A-Za-z0-9_]*)\.unblock_cmd_stream\(\)\s*;")
_TOC_BEFORE_RE = re.compile(rf"{TOC}\(\)\s*;\s*(?://[^\n]*\s*)*$")


def strip_comments(src: str) -> str:
    src = re.sub(r"/\*.*?\*/", lambda m: " " * len(m.group(0)), src, flags=re.S)
    return re.sub(r"//[^\n]*", lambda m: " " * len(m.group(0)), src)


def _body_span(src: str, open_brace: int) -> int:
    """Index just past the brace matching the one at open_brace (comment-free src)."""
    depth = 0
    i = open_brace
    in_str = False
    while i < len(src):
        c = src[i]
        if in_str:
            if c == "\\":
                i += 2; continue
            if c == '"':
                in_str = False
        elif c == '"':
            in_str = True
        elif c == "{":
            depth += 1
        elif c == "}":
            depth -= 1
            if depth == 0:
                return i + 1
        i += 1
    return len(src)


def definitions(src: str) -> List[Tuple[str, str, int, int]]:
    """(kind, name, start, end) of every fn/task definition, on comment-free text."""
    out = []
    for m in _DEF_RE.finditer(src):
        brace = src.find("{", m.end())
        if brace < 0:
            continue
        out.append((m.group(1), m.group(2), m.start(), _body_span(src, brace)))
    return out


def uses_protocol(src: str) -> bool:
    clean = strip_comments(src)
    return bool(re.search(rf"\bfn\s+{TIC}\s*\(", clean)) and bool(re.search(rf"\bfn\s+{TOC}\s*\(", clean))


def exported_entry_points(src: str) -> List[str]:
    clean = strip_comments(src)
    fn_names = {name for kind, name, _, _ in definitions(clean) if kind == "fn"}
    return [n for n in _EXPORT_RE.findall(clean) if n in fn_names and n not in HELPER_FNS]


def check_device_window_contract(src: str) -> Optional[str]:
    """None when the variant satisfies the protocol, else a violation message."""
    clean = strip_comments(src)
    if not uses_protocol(clean):
        return f"device_internal_v2: {TIC}/{TOC} helpers missing"
    defs = definitions(clean)
    problems: List[str] = []
    for kind, name, start, end in defs:
        if name in HELPER_FNS:
            continue
        body = clean[start:end]
        if kind == "fn" and name in exported_entry_points(src):
            brace = body.find("{")
            first = body[brace + 1:].lstrip()
            if not first.startswith(f"{TIC}("):
                problems.append(f"entry point '{name}' must start with {TIC}()")
        for m in _UNBLOCK_RE.finditer(body):
            before = body[:m.start()]
            if not _TOC_BEFORE_RE.search(before):
                problems.append(f"unblock_cmd_stream() in '{name}' is not immediately preceded by {TOC}()")
    if not exported_entry_points(src):
        problems.append("no exported entry point found")
    return "; ".join(problems) if problems else None


def instrument_device_window(src: str, time_module: Optional[str] = None,
                             start_buf: Optional[str] = None, end_buf: Optional[str] = None) -> str:
    """Add the v2 stamps to a program written for the host-launched protocol:
    helper definitions before `fn f_tic()`, f_tic_dev() first in every exported
    entry point, f_toc_dev() before every unblock outside the helpers. Idempotent."""
    if uses_protocol(src):
        return src
    clean = strip_comments(src)
    mod = time_module or (re.search(r"const\s+(\w+)\s*=\s*@import_module\(\"<time>\"\)", clean) or [None, "timestamp"])[1]
    m_tic = re.search(r"fn\s+f_tic\s*\(\)\s*void\s*\{[^}]*get_timestamp\(&(\w+)\)", clean, re.S)
    m_toc = re.search(r"fn\s+f_toc\s*\(\)\s*void\s*\{[^}]*get_timestamp\(&(\w+)\)", clean, re.S)
    sbuf = start_buf or (m_tic.group(1) if m_tic else "tscStartBuffer")
    ebuf = end_buf or (m_toc.group(1) if m_toc else "tscEndBuffer")
    helpers = (
        "// Device-internal timing window (protocol device_internal_v2): start stamp at\n"
        "// entry-point start, end stamp immediately before the host is unblocked.\n"
        "var tsc_window_open: bool = false;\n"
        f"fn {TIC}() void {{\n  if (!tsc_window_open) {{\n    tsc_window_open = true;\n"
        f"    {mod}.get_timestamp(&{sbuf});\n  }}\n}}\n"
        f"fn {TOC}() void {{\n  {mod}.get_timestamp(&{ebuf});\n}}\n\n")
    out = src
    # 1) end stamps: walk definitions on the ORIGINAL text via comment-free spans (same offsets)
    edits: List[Tuple[int, str]] = []
    for kind, name, start, end in definitions(clean):
        if name in HELPER_FNS:
            continue
        body = clean[start:end]
        for m in _UNBLOCK_RE.finditer(body):
            if _TOC_BEFORE_RE.search(body[:m.start()]):
                continue
            indent = m.group(1)
            edits.append((start + m.start(), f"{indent}{TOC}();\n"))
    # 2) start stamps
    entries = exported_entry_points(src)
    for kind, name, start, end in definitions(clean):
        if kind == "fn" and name in entries:
            brace = clean.find("{", start)
            nl = clean.find("\n", brace)
            edits.append((nl + 1, f"  {TIC}();\n"))
    for pos, text in sorted(edits, key=lambda e: -e[0]):
        out = out[:pos] + text + out[pos:]
    # 3) helper definitions before fn f_tic (else before the comptime block / at end)
    anchor = re.search(r"(?m)^fn\s+f_tic\s*\(", out)
    if anchor:
        out = out[:anchor.start()] + helpers + out[anchor.start():]
    else:
        cm = re.search(r"(?m)^comptime\s*\{", out)
        out = (out[:cm.start()] + helpers + out[cm.start():]) if cm else out + "\n" + helpers
    return out
