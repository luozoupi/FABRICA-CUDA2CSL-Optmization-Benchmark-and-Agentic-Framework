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


# --- Template protocol -------------------------------------------------------
# The scaffold that the template-completion translation route emits calls the
# host-visible helpers ON DEVICE instead of defining f_tic_dev/f_toc_dev: f_tic()
# is the first statement of every exported entry point, f_toc() is the last
# statement before the completion signal (`@activate(EXIT)` or the host unblock),
# and the task bound to that signal does nothing but unblock the host. A program
# that merely EXPORTS f_tic/f_toc for the host to launch (the legacy protocol)
# does not use it. Checked structurally, like the v2 protocol above: a variant
# may end its computation in a different task than the start program.
TIC_T, TOC_T = "f_tic", "f_toc"
_ACTIVATE_RE = re.compile(r"@activate\(\s*([^()]+?)\s*\)\s*;")
_BIND_RE = re.compile(r"@bind_local_task\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*,\s*([^()]+?)\s*\)")
_ONLY_SIGNALS_RE = re.compile(r"^(?:\s*(?:@activate\(\s*[^()]+?\s*\)\s*;|[A-Za-z_][A-Za-z0-9_]*\.unblock_cmd_stream\(\)\s*;|\}))*\s*$")
_ONLY_UNBLOCK_RE = re.compile(r"^\s*(?:[A-Za-z_][A-Za-z0-9_]*\.unblock_cmd_stream\(\)\s*;\s*)+$")
# formatting-independent (the v2 regex above anchors at a line start because the instrumenter reuses its indentation)
_UNBLOCK_ANY_RE = re.compile(r"\b[A-Za-z_][A-Za-z0-9_]*\.unblock_cmd_stream\(\)\s*;")


def _defines(clean: str, name: str) -> bool:
    return bool(re.search(rf"\bfn\s+{name}\s*\(", clean))


def uses_template_protocol(src: str) -> bool:
    clean = strip_comments(src)
    if uses_protocol(clean) or not (_defines(clean, TIC_T) and _defines(clean, TOC_T)):
        return False
    call = re.compile(rf"\b{TIC_T}\(\)\s*;")
    return any(call.search(clean[start:end]) for kind, name, start, end in definitions(clean) if name not in HELPER_FNS)


def check_template_window_contract(src: str) -> Optional[str]:
    """None when the variant keeps the template window intact, else the violations.

    The window is `f_tic()` as the first statement of every exported entry point and
    `f_toc()` followed by nothing but completion signals; the tasks those signals
    reach only unblock the host, and nothing else activates them or unblocks the host.
    """
    clean = strip_comments(src)
    if not uses_template_protocol(clean):
        return f"template window: {TIC_T}/{TOC_T} not defined and called on device"
    defs = [d for d in definitions(clean) if d[1] not in HELPER_FNS]
    entries = set(exported_entry_points(src))
    problems: List[str] = []
    tic_call = re.compile(rf"\b{TIC_T}\(\)\s*;")
    toc_call = re.compile(rf"\b{TOC_T}\(\)\s*;")
    binds = {name: ident for name, ident in _BIND_RE.findall(clean)}
    completion_ids: set = set()
    toc_calls = 0
    for kind, name, start, end in defs:
        body = clean[start:end]
        brace = body.find("{")
        inner = body[brace + 1:]
        starts_with_tic = inner.lstrip().startswith(f"{TIC_T}(")
        if kind == "fn" and name in entries and not starts_with_tic:
            problems.append(f"entry point '{name}' must start with {TIC_T}()")
        n_tic = len(tic_call.findall(body))
        if n_tic > (1 if (kind == "fn" and name in entries and starts_with_tic) else 0):
            problems.append(f"{TIC_T}() called in '{name}' other than as an entry point's first statement")
        for m in toc_call.finditer(body):
            toc_calls += 1
            ok, ids = _post_stamp_path(body[m.end():])
            if not ok:
                problems.append(f"work after {TOC_T}() in '{name}'")
            completion_ids.update(ids)
    if toc_calls == 0:
        problems.append(f"{TOC_T}() is never called")
    if not entries:
        problems.append("no exported entry point found")
    completion_tasks = {name for name, ident in binds.items() if ident.strip() in completion_ids}
    for kind, name, start, end in defs:
        body = clean[start:end]
        brace = body.find("{")
        inner = body[brace + 1:body.rfind("}")]
        if name in completion_tasks and not _ONLY_UNBLOCK_RE.match(inner):
            problems.append(f"completion task '{name}' must only unblock the host")
        for m in _ACTIVATE_RE.finditer(body):
            if m.group(1).strip() in completion_ids and not _TOC_T_BEFORE_RE.search(body[:m.start()]):
                problems.append(f"@activate({m.group(1).strip()}) in '{name}' is not immediately preceded by {TOC_T}()")
        if name in completion_tasks:
            continue
        for m in _UNBLOCK_ANY_RE.finditer(body):
            if not _TOC_T_BEFORE_RE.search(body[:m.start()]):
                problems.append(f"unblock_cmd_stream() in '{name}' is not immediately preceded by {TOC_T}()")
    return "; ".join(problems) if problems else None


_TOC_T_BEFORE_RE = re.compile(rf"{TOC_T}\(\)\s*;\s*$")
_SIGNAL_RE = re.compile(r"\s*(?:@activate\(\s*([^()]+?)\s*\)\s*;|[A-Za-z_][A-Za-z0-9_]*\.unblock_cmd_stream\(\)\s*;|return\s*;)")


def _skip_balanced(text: str, i: int, open_ch: str, close_ch: str) -> int:
    """Index just past the group that opens at text[i] (text[i] == open_ch)."""
    depth = 0
    while i < len(text):
        if text[i] == open_ch:
            depth += 1
        elif text[i] == close_ch:
            depth -= 1
            if depth == 0:
                return i + 1
        i += 1
    return len(text)


def _post_stamp_path(tail: str) -> Tuple[bool, set]:
    """Follow the control-flow path from the end stamp to the end of its definition.

    Only completion signals (@activate, unblock, return) may execute after the stamp; a
    block may close, and an `else` (or `else if`) branch that follows a closing brace is a
    different path and is skipped whole. Returns (ok, ids activated on the path)."""
    ids: set = set()
    i = 0
    n = len(tail)
    while i < n:
        m = re.compile(r"\s*").match(tail, i)
        i = m.end()
        if i >= n:
            break
        sig = _SIGNAL_RE.match(tail, i)
        if sig:
            if sig.group(1):
                ids.add(sig.group(1).strip())
            i = sig.end()
            continue
        if tail[i] == "}":
            i += 1
            while True:
                m = re.compile(r"\s*else\b").match(tail, i)
                if not m:
                    break
                i = m.end()
                m = re.compile(r"\s*if\s*\(").match(tail, i)
                if m:
                    i = _skip_balanced(tail, m.end() - 1, "(", ")")
                m = re.compile(r"\s*\{").match(tail, i)
                if not m:
                    return False, ids
                i = _skip_balanced(tail, m.end() - 1, "{", "}")
            continue
        return False, ids
    return True, ids


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
