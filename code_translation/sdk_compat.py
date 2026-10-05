#!/usr/bin/env python3
"""Mechanical CSL syntax compatibility between Cerebras SDK 1.4 and 2.10.

SDK 2.10 removed the `comptime_struct` type annotation and the `@concat_structs`
builtin (studies/wse3-characterization/FINDINGS.md section 12d). Everything the
agent is taught (scaffolds, retrieved examples, most reference bundles) is written
in 1.4 syntax, so a 2.10 target needs a deterministic fix-up of generated and staged
CSL before it reaches `cslc`. The 2.10-native forms compile on both SDKs (verified
16 Sep 2026 on SpMV-CSR: 6,927 cycles on 1.4, 7,429 on 2.10), so the fix-up is safe
to apply whenever the target is 2.x and is a no-op text-wise for files already in
that form.

Gates: `XKERNEL_TARGET_SDK` (the agent's target, "1.4.0" default) decides whether
scaffolds and prompt blocks use the 2.x forms; `XKERNEL_SDK210_FIXUP=1` applies
`fixup_csl_for_sdk` to every staged `*.csl` and to candidate text in the harness.
`hardware_submit.port_kernel_to_sdk210` keeps its own, wider rewrite for the
appliance path.
"""
from __future__ import annotations

import os
import re
from typing import Optional, Tuple

_COMPTIME_STRUCT_PARAM = re.compile(r":\s*comptime_struct\s*;")
_COMPTIME_STRUCT_CONST = re.compile(r":\s*comptime_struct\s*=")
_COMPTIME_STRUCT_FN_RET = re.compile(r"\)\s*comptime_struct\s*\{")
_CONCAT_STRUCTS = re.compile(r"@concat_structs\s*\(\s*(\w+)\s*,\s*(\w+)\s*\)")

SDK210_SYNTAX_NOTE = """
### SDK 2.10 syntax (target SDK is 2.x)
- The `comptime_struct` type annotation was removed: declare struct-valued params
  untyped, `param memcpy_params;` and `param c2d_params;` (never annotate them).
- `@concat_structs` was removed: build one struct literal with all fields, e.g.
  `.{ .width = W, .height = H, .memcpy_params = memcpy.get_params(px) }`.
- Everything else (DSDs, tasks, colors, queues, `@export_symbol`, `@initialize_queue`) is unchanged.
"""


def target_sdk(default: str = "1.4.0") -> str:
    return os.environ.get("XKERNEL_TARGET_SDK", default).strip() or default


def is_sdk2(sdk: Optional[str] = None) -> bool:
    sdk = target_sdk() if sdk is None else sdk
    return sdk.split(".")[0].strip().lstrip("v") in ("2", "3")


def fixup_enabled() -> bool:
    return os.environ.get("XKERNEL_SDK210_FIXUP", "0") == "1"


def _extract_struct_fields(text: str, var_name: str) -> Optional[str]:
    m = re.compile(rf"const\s+{re.escape(var_name)}\s*=\s*\.{{\s*(.*?)\s*}}\s*;", re.DOTALL).search(text)
    return m.group(1).strip().rstrip(",") if m else None


def _inline_concat_structs(text: str) -> str:
    def repl(m):
        a, b = _extract_struct_fields(text, m.group(1)), _extract_struct_fields(text, m.group(2))
        if a is None or b is None:
            return m.group(0)          # cannot resolve statically: leave it for the compiler to report
        return ".{ " + a + ", " + b + " }"
    return _CONCAT_STRUCTS.sub(repl, text)


def fixup_csl_for_sdk(text: str, sdk: Optional[str] = None, is_layout: bool = False) -> Tuple[str, int]:
    """Return (text, number_of_edits). Identity for 1.x targets and for text already in
    2.x form. Only the removed constructs are touched; typed scalar params stay as they
    are (they compile on 2.10)."""
    if not is_sdk2(sdk):
        return text, 0
    edits = 0
    for rx, rep in ((_COMPTIME_STRUCT_PARAM, ";"), (_COMPTIME_STRUCT_CONST, " ="), (_COMPTIME_STRUCT_FN_RET, ") anytype {")):
        text, n = rx.subn(rep, text); edits += n
    if is_layout or "@concat_structs" in text:
        new = _inline_concat_structs(text)
        if new != text:
            edits += 1; text = new
    return text, edits


def fixup_bundle(bundle_dir, sdk: Optional[str] = None) -> int:
    """Fix every *.csl under bundle_dir in place; returns the number of files changed."""
    from pathlib import Path
    changed = 0
    for f in sorted(Path(bundle_dir).rglob("*.csl")):
        old = f.read_text(encoding="utf-8", errors="replace")
        new, n = fixup_csl_for_sdk(old, sdk, is_layout="layout" in f.name.lower())
        if n and new != old:
            f.write_text(new, encoding="utf-8"); changed += 1
    return changed
