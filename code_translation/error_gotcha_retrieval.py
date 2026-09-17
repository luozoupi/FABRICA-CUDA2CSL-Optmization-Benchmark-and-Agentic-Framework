"""Compile-error → gotcha micro-retrieval.

Maps cslc error patterns to targeted, concise fix hints. When the repair
loop encounters a compile failure, this module scans stderr and returns
the most relevant gotcha(s) so the implementer doesn't waste attempts
re-discovering the same fix.

Env gate: XKERNEL_ERROR_GOTCHA (default "1" = ON).
"""

from __future__ import annotations

import os
import re
from typing import List, Tuple

# Each entry: (compiled regex, short label, fix hint).
# Order matters — first match wins for each error line, but ALL distinct
# matches across the full stderr are collected (deduped by label).
_ERROR_GOTCHA_TABLE: List[Tuple[re.Pattern, str, str]] = [
    (
        re.compile(r"exported symbol mutability mismatch|expected name to be (?:im)?mutable", re.I),
        "export-mutability",
        "The pointer you @export_symbol must match the third argument of the "
        "layout's @export_name(name, type, mutable): `true` needs a `var ptr: [*]T = &arr;`, "
        "`false` needs a `const ptr: [*]T = &arr;`. Do not change the pointee array's "
        "declaration, the pointer's type, or use @ptrcast; only the var/const keyword of "
        "the pointer variable decides mutability.",
    ),
    (
        re.compile(r"initialization for this queue has already been set", re.I),
        "queue-0-1-reserved",
        "The <memcpy/memcpy> library owns input queues 0-1. "
        "User code must use @get_input_queue(2)..@get_input_queue(7) and "
        "@get_output_queue(2)..@get_output_queue(7). Queue indices >7 are "
        "invalid on WSE-3.",
    ),
    (
        re.compile(r"unused entry in module instantiation", re.I),
        "collectives-param-mismatch",
        "Do NOT build c2d_params manually with @concat_structs. "
        "Use the layout-provided c2d_params unchanged. Import "
        "collectives_2d/pe separately for x and y with their own "
        "c2d_params slice.",
    ),
    (
        re.compile(r"not a member of struct|no member named", re.I),
        "struct-field-mismatch",
        "Check the exact field names in layout.csl's struct definitions. "
        "Common trap: collectives_2d uses .dim_params, not .dim_size or "
        ".c2d_params. DSR arrays use [N]u16 not [N]dsr_id.",
    ),
    (
        re.compile(r"undeclared identifier|undefined symbol|not found in scope", re.I),
        "undeclared-symbol",
        "Compare every @export_symbol / @export_name in your pe.csl against "
        "the layout.csl @set_tile_code / @set_external_modules bindings. "
        "Name and type must match exactly (case-sensitive). Check that all "
        "imported modules are spelled correctly.",
    ),
    (
        re.compile(r"expected .*i16.*got.*u16|expected .*u16.*got.*i16|cannot cast.*i16.*u16", re.I),
        "u16-i16-cast",
        "Comptime params are u16; loop indices and DSD offsets need i16. "
        "Use @as(i16, param) for arithmetic and @range(i16, N) for loops.",
    ),
    (
        re.compile(r"arguments do not match any variant|no matching overload", re.I),
        "signature-mismatch",
        "Check function/builtin call arity and argument types against the "
        "SDK reference. Common: @set_dsd_base_addr takes (dsd, ptr) not "
        "(dsd, offset); route config takes (color, .{...}) where the struct "
        "must match the direction (.rx/.tx and .pop_mode/.switch_pos fields).",
    ),
    (
        re.compile(r"@fmacs.*expected.*f32|@fmacs.*expected.*dsd|fmacs.*operand", re.I),
        "fmacs-signature",
        "CSL @fmacs has two forms: (1) @fmacs(dst_dsd, src0_dsd, src1_dsd, f32_scalar) "
        "— multiply-accumulate with a scalar coefficient; (2) @fmacs(dst_dsd, src0_dsd, "
        "src1_dsd) — three-DSD MAC with no scalar. There is NO 4-DSD form. If the "
        "4th arg is a DSD, remove it or replace with a scalar. If the 4th arg is a "
        "scalar but the error says 'expected DSD', you have the wrong overload — "
        "use 3 args instead.",
    ),
    (
        re.compile(r"@activate.*comptime|cannot call.*@activate.*comptime", re.I),
        "activate-in-comptime",
        "Never call @activate() from a comptime block. Use it only inside "
        "task/function bodies.",
    ),
    (
        re.compile(r"task has already been bound|duplicate.*@bind_task", re.I),
        "task-id-reuse",
        "Each task_id can only be bound once. If you need multiple entry "
        "points, allocate separate task IDs via @get_local_task_id(N) with "
        "distinct N values.",
    ),
    (
        re.compile(r"received 0 bytes|D2H.*hang|unblock_cmd_stream", re.I),
        "unblock-cmd-stream",
        "Every PE must call sys_mod.unblock_cmd_stream() after its last "
        "fabric op, including sender-only PEs and corner PEs. Missing this "
        "causes D2H hangs.",
    ),
    (
        re.compile(r"color.*already.*used|fabric color conflict", re.I),
        "color-conflict",
        "Cannot send and receive on the same fabric color with fixed "
        "routing. Use checkerboard coloring or separate colors for "
        "send vs receive.",
    ),
    (
        re.compile(r"@import_module.*not found|cannot find module", re.I),
        "import-path",
        "User module imports use filename only: "
        "@import_module(\"filename.csl\", params) — the file must be in "
        "the SAME directory. SDK libraries use angle brackets: "
        "@import_module(\"<memcpy/memcpy>\", p).",
    ),
    (
        re.compile(r"enable_tsc|timestamp counter|tsc", re.I),
        "enable-tsc",
        "The timestamp counter (TSC) must be enabled with "
        "@enable_local_timestamp_counter() in a comptime block or at "
        "module scope before using @get_timestamp().",
    ),
    (
        re.compile(r"expected at most 1 input direction|multiple.*rx.*direction", re.I),
        "single-source-rx",
        "WSE-3 requires exactly ONE rx source direction per color. "
        "For fan-in (gather from multiple directions), use a separate "
        "color per source direction or a relay chain.",
    ),
    (
        re.compile(r"@get_color\(\d{2,}\).*range|color.*out of range|color.*exceed", re.I),
        "color-id-range",
        "WSE-3 color IDs are in [0, 24). @get_color(24) or higher "
        "is a compile error.",
    ),
    (
        re.compile(r"@set_color_config.*requires.*arg|@set_color_config.*arity", re.I),
        "set-color-config-arity",
        "@set_color_config requires 4 args (color, .rx, .tx, .pop). "
        "For per-PE local routing use @set_local_color_config(color, cfg).",
    ),
    (
        re.compile(r"dest tensor must be one-dimensional|tensor.*dimension.*mismatch", re.I),
        "d2h-shape-mismatch",
        "The host collect() returns wrong-shaped data. If run.py uses "
        "distribution.py for collect()/distribute(), you MUST author your "
        "own distribution.py in a ```python distribution.py block. Your "
        "collect(name, params) must return (cx, cy, cw, ch, elems) matching "
        "where YOUR kernel places the output. The reference distribution.py "
        "is hidden — write your own.",
    ),
    (
        re.compile(r"overwriting ut_instr\[\d+\]", re.I),
        "microthread-reuse",
        "Two async operations reuse the same microthread before the "
        "first completes. Allocate a separate ut_id per concurrent "
        "async operation.",
    ),
    (
        re.compile(r"block comments.*aren.t supported|/\*.*not supported", re.I),
        "no-block-comments",
        "CSL does not support /* */ block comments inside expressions. "
        "Use // line comments instead.",
    ),
]


def retrieve_gotchas(stderr: str, max_hints: int = 3) -> str:
    """Scan cslc stderr and return a block of matched gotcha hints.

    Returns an empty string if no patterns match or if the gate is off.
    """
    if os.environ.get("XKERNEL_ERROR_GOTCHA", "1") == "0":
        return ""
    if not stderr or not stderr.strip():
        return ""

    seen_labels: set = set()
    hints: List[str] = []

    for line in stderr.splitlines():
        for pattern, label, hint in _ERROR_GOTCHA_TABLE:
            if label in seen_labels:
                continue
            if pattern.search(line):
                seen_labels.add(label)
                hints.append(f"- [{label}] {hint}")
                if len(hints) >= max_hints:
                    break
        if len(hints) >= max_hints:
            break

    if not hints:
        return ""

    return (
        "============================================================\n"
        "COMPILE-ERROR GOTCHA HINTS (auto-retrieved from error patterns)\n"
        "============================================================\n"
        + "\n".join(hints)
    )
