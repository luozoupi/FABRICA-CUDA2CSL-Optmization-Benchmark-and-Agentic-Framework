"""translation_facts — regex-extracted facts block for CUDA→CSL implementer prompts.

Phase 1 of the "translation facts" feasibility plan. Reads ONLY the
layout-visible files (layout.csl, run.py, commands_wse3.sh) for a given
kernel directory and emits a compact YAML block the implementer can treat
as ground truth.

The goal: convert today's repair-loop trial-and-error on field names,
builtin arities, task-ID collisions, and queue reservations into facts
the model reads once.

CRITICAL: never reads pe.csl or any reference compute file. Preserves the
W1 "layout visible, compute hidden" invariant enforced by the compute-leak
canary guard in cuda2csl.py.
"""

from __future__ import annotations

import logging
import re
from pathlib import Path
from typing import Any, Dict, List, Optional, Set, Tuple

import yaml

logger = logging.getLogger(__name__)

# Only these filenames are read by extract_layout_facts. Adding pe.csl
# here would silently leak reference compute into the implementer prompt
# and break the W1 invariant.
_LAYOUT_VISIBLE_FILENAMES: Tuple[str, ...] = (
    "layout.csl",
    "run.py",
    "commands_wse3.sh",
    "commands_wse2.sh",
)

# Hard-coded per-import field schemas. When the implementer sees
# `@import_module("<collectives_2d/pe>", c2d_params)`, this table tells it
# what fields c2d_params must expose. Built from cslc errors in the W1
# resweep — these are exactly the field names the model keeps inventing
# wrong (e.g. .dim_size instead of NUM_PES, .x.dim_size instead of .NUM_PES).
_IMPORT_FIELD_SCHEMAS: Dict[str, Dict[str, Any]] = {
    "<memcpy/memcpy>": {
        "expects_struct_with_fields": ["LOCAL_IN_SZ", "LOCAL_OUT_SZ"],
        "reserves_input_queues_wse3": [0, 1],
        "common_handle_name": "sys_mod",
        "note": "Release the cmd stream via sys_mod.unblock_cmd_stream(), "
                "NOT raw @unblock(0).",
    },
    "<memcpy/get_params>": {
        "expects_struct_with_fields": ["width", "height"],
        "reserves_input_queues_wse3": [0, 1],
        "returned_by": "memcpy.get_params(Px)",
        "note": "Layout creates one per PE column; pe.csl receives it via "
                ".memcpy_params field of the tile-code struct. Reserves "
                "input queues 0 and 1 on WSE-3 -- do NOT @get_input_queue(0|1).",
    },
    "<collectives_2d/pe>": {
        "expects_struct_with_fields": [
            "c2d_params",
            "NUM_PES",
        ],
        "note": "DO NOT reference .dim_size or .x.dim_size — those names "
                "do NOT exist. Use NUM_PES (passed alongside c2d_params).",
    },
    "<collectives_2d/params>": {
        "returns_via": "c2d.get_params(Px, Py, .{...})",
        "build_fields": ["x_colors", "x_entrypoints", "y_colors", "y_entrypoints"],
        "note": "Layout constructs c2d_params; pe.csl imports "
                "<collectives_2d/pe> with .c2d_params = c2d_params.",
    },
    "<time>": {
        "common_handle_name": "timestamp",
        "note": "Provides timestamp.get_timestamp(&buf) used by f_tic/f_toc.",
    },
    "<layout>": {
        "common_handle_name": "layout_mod",
        "note": "Provides layout_mod.get_x_coord() / get_y_coord() — call "
                "inside fn/task bodies, NOT at file top-level (PE coords "
                "are not comptime).",
    },
}

# Cap on YAML output size — keeps prompt budget bounded.
_MAX_YAML_LINES = 30

# Sentinel for missing data so YAML round-trips cleanly.
_NA = "(none observed)"


def _read_visible(kernel_dir: Path, filename: str) -> Optional[str]:
    p = kernel_dir / filename
    if not p.is_file():
        return None
    try:
        return p.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return None


def _extract_declared_task_ids(layout_text: str) -> List[int]:
    """Every @get_local_task_id(N) literal that layout.csl already binds.

    The implementer's compute file must not re-declare these — those IDs
    are owned by layout.csl. (This is the inverse of the W1 verdict's
    "outside legal range" claim — the real constraint is "don't collide
    with what layout already took".)
    """
    matches = re.findall(r"@get_local_task_id\s*\(\s*(\d+)\s*\)", layout_text)
    return sorted({int(m) for m in matches})


def _extract_color_ids(layout_text: str) -> List[int]:
    matches = re.findall(r"@get_color\s*\(\s*(\d+)\s*\)", layout_text)
    return sorted({int(m) for m in matches})


def _extract_imports(layout_text: str) -> List[Tuple[str, Optional[str]]]:
    """List of (import_path, handle_name) pairs from layout.csl.

    Captures both `const x = @import_module("<...>", ...)` and the bare
    `@import_module("<...>")` form.
    """
    out: List[Tuple[str, Optional[str]]] = []
    # const NAME = @import_module("<path>", ...)
    for m in re.finditer(
        r'(?:const|var)\s+([A-Za-z_][A-Za-z0-9_]*)\s*=\s*'
        r'@import_module\s*\(\s*"([^"]+)"',
        layout_text,
    ):
        out.append((m.group(2), m.group(1)))
    return out


def _extract_set_tile_code_fields(layout_text: str) -> List[str]:
    """Field names passed to @set_tile_code's params struct.

    These are the EXACT field names pe.csl will receive as @param decls.
    Example: layout passes `.memcpy_params = ..., .c2d_params = ..., .Mt = ...`
    → pe.csl must declare `param memcpy_params : ...`, `param c2d_params : ...`,
    `param Mt : u16`.
    """
    fields: Set[str] = set()
    for body in re.findall(
        r'@set_tile_code\s*\([^)]*?,\s*"[^"]+"\s*,\s*\.\{([^}]*)\}',
        layout_text,
        flags=re.DOTALL,
    ):
        # Match .field_name = ...
        for fm in re.finditer(r'\.\s*([A-Za-z_][A-Za-z0-9_]*)\s*=', body):
            fields.add(fm.group(1))
    return sorted(fields)


def _extract_export_names(layout_text: str) -> List[Tuple[str, str]]:
    """Every (name, type-shape) exported by layout.csl @export_name calls.

    The implementer's pe.csl must define matching symbols. We parse the
    full argument list by tracking nested parens so that types like
    `fn() void` (which contain commas inside) survive intact.
    """
    out: List[Tuple[str, str]] = []
    for m in re.finditer(r'@export_name\s*\(', layout_text):
        # Walk forward from m.end() collecting the balanced (...) body.
        i = m.end()
        depth = 1
        start = i
        while i < len(layout_text) and depth > 0:
            c = layout_text[i]
            if c == "(":
                depth += 1
            elif c == ")":
                depth -= 1
            i += 1
        body = layout_text[start:i - 1]
        # Split top-level args by comma (respecting nested parens).
        args: List[str] = []
        buf: List[str] = []
        d = 0
        for ch in body:
            if ch == "(":
                d += 1
            elif ch == ")":
                d -= 1
            if ch == "," and d == 0:
                args.append("".join(buf).strip())
                buf = []
            else:
                buf.append(ch)
        if buf:
            args.append("".join(buf).strip())
        if len(args) < 2:
            continue
        name = args[0].strip().strip('"')
        typ = args[1].strip()
        out.append((name, typ))
    return out


def _extract_host_launch_sequence(run_py_text: str) -> List[str]:
    """Ordered f_* names the host launches via runner.launch(...)."""
    out: List[str] = []
    for m in re.finditer(
        r'(?:runner|run)\.launch\s*\(\s*"([^"]+)"',
        run_py_text,
    ):
        out.append(m.group(1))
    return out


def _detect_wse3_arch(commands_text: Optional[str]) -> bool:
    if not commands_text:
        return True  # default assumption (corpus is WSE-3)
    return "wse3" in commands_text.lower() or "arch=wse3" in commands_text.lower()


def extract_layout_facts(kernel_dir: str | Path) -> Dict[str, Any]:
    """Build the facts dict from a kernel's layout-visible files.

    Returns a dict with stable top-level keys. Missing data is represented
    by empty lists / None — never by raising. The dict is intended for
    direct YAML serialization via format_facts_yaml().
    """
    kdir = Path(kernel_dir)
    if not kdir.is_dir():
        raise FileNotFoundError(f"not a directory: {kdir}")

    # Resolve the actual layout-visible directory: some kernels have
    # CSL/ as a subdir, others have layout.csl directly in kdir.
    if (kdir / "layout.csl").is_file():
        visible_dir = kdir
    elif (kdir / "CSL" / "layout.csl").is_file():
        visible_dir = kdir / "CSL"
    else:
        raise FileNotFoundError(
            f"no layout.csl under {kdir} or {kdir}/CSL"
        )

    layout_text = _read_visible(visible_dir, "layout.csl") or ""
    run_py_text = _read_visible(visible_dir, "run.py") or ""
    commands_text = (_read_visible(visible_dir, "commands_wse3.sh")
                     or _read_visible(visible_dir, "commands_wse2.sh"))

    task_ids = _extract_declared_task_ids(layout_text)
    color_ids = _extract_color_ids(layout_text)
    imports = _extract_imports(layout_text)
    tile_fields = _extract_set_tile_code_fields(layout_text)
    exports = _extract_export_names(layout_text)
    launches = _extract_host_launch_sequence(run_py_text)
    is_wse3 = _detect_wse3_arch(commands_text)

    # Per-import: pair each detected import with its hard-coded schema
    # (when known). Unknown imports get a stub so the implementer sees
    # at least that the import exists.
    imports_summary: List[Dict[str, Any]] = []
    for import_path, handle in imports:
        schema = _IMPORT_FIELD_SCHEMAS.get(import_path, {})
        entry: Dict[str, Any] = {
            "path": import_path,
            "handle": handle or _NA,
        }
        for k in ("expects_struct_with_fields",
                  "reserves_input_queues_wse3",
                  "build_fields",
                  "note"):
            if k in schema:
                entry[k] = schema[k]
        imports_summary.append(entry)

    # memcpy queue reservation — surface this as its own top-level key
    # since it's the single most common DSR/queue collision in the W1 logs.
    memcpy_reserved_queues: List[int] = []
    if is_wse3:
        for ip, _h in imports:
            sch = _IMPORT_FIELD_SCHEMAS.get(ip, {})
            for q in sch.get("reserves_input_queues_wse3", []) or []:
                if q not in memcpy_reserved_queues:
                    memcpy_reserved_queues.append(q)

    facts: Dict[str, Any] = {
        "arch": "wse3" if is_wse3 else "wse2",
        "task_ids_owned_by_layout": task_ids or _NA,
        "color_ids_owned_by_layout": color_ids or _NA,
        "memcpy_reserved_input_queues": memcpy_reserved_queues or _NA,
        "tile_code_params_pe_must_declare": tile_fields or _NA,
        "exported_symbols_pe_must_define": [
            f"{n}  ({t})" for n, t in exports
        ] or _NA,
        "host_launch_sequence": launches or _NA,
        "imports": imports_summary or _NA,
    }
    return facts


def _yaml_lines(d: Dict[str, Any]) -> List[str]:
    text = yaml.safe_dump(d, sort_keys=False, default_flow_style=False,
                          width=110, allow_unicode=False)
    return [ln for ln in text.splitlines() if ln.strip() != ""]


def format_facts_yaml(facts: Dict[str, Any]) -> str:
    """Render facts to YAML capped at _MAX_YAML_LINES.

    Truncation order, lowest leverage first:
      1) drop type signatures from exported_symbols (names alone suffice)
      2) shorten imports to {path, handle, note} (drop schema fields)
      3) if still over, hard-cap with a clear truncation marker

    The high-leverage keys (task_ids_owned_by_layout,
    memcpy_reserved_input_queues, tile_code_params_pe_must_declare,
    host_launch_sequence) are never trimmed — those are exactly the facts
    the W1 logs show the model getting wrong.
    """
    lines = _yaml_lines(facts)
    if len(lines) <= _MAX_YAML_LINES:
        return "\n".join(lines)

    original_len = len(lines)
    trimmed = dict(facts)

    # 1) Drop type signatures from exported_symbols.
    syms = trimmed.get("exported_symbols_pe_must_define")
    if isinstance(syms, list):
        trimmed["exported_symbols_pe_must_define"] = [
            s.split("  (")[0].strip() if isinstance(s, str) else s
            for s in syms
        ]
    lines = _yaml_lines(trimmed)
    if len(lines) <= _MAX_YAML_LINES:
        return "\n".join(lines)

    # 2) Shorten imports to {path, handle, note}.
    if isinstance(trimmed.get("imports"), list):
        slim_imports = []
        for entry in trimmed["imports"]:
            slim: Dict[str, Any] = {"path": entry.get("path"),
                                    "handle": entry.get("handle")}
            if "note" in entry:
                slim["note"] = entry["note"]
            slim_imports.append(slim)
        trimmed["imports"] = slim_imports
    lines = _yaml_lines(trimmed)
    if len(lines) <= _MAX_YAML_LINES:
        return "\n".join(lines)

    # 3) Reorder so high-leverage keys render first, then truncate from the
    # tail. host_launch_sequence and import paths matter more than the long
    # list of f_* exported symbols.
    # NOTE: `imports` ranks ABOVE `host_launch_sequence`. The import-schema
    # notes (e.g. the <collectives_2d/*> NUM_PES rule) are the facts W1 most
    # often gets wrong, whereas the launch sequence is mostly instrumentation
    # boilerplate (f_enable_timer/f_tic/f_toc/f_memcpy_timestamps) once a
    # kernel is cycle-instrumented. Keeping imports first prevents timing
    # boilerplate from evicting the collectives note under the line cap.
    HIGH_LEVERAGE = [
        "arch",
        "task_ids_owned_by_layout",
        "color_ids_owned_by_layout",
        "memcpy_reserved_input_queues",
        "tile_code_params_pe_must_declare",
        "imports",
        "host_launch_sequence",
        "exported_symbols_pe_must_define",
    ]
    reordered: Dict[str, Any] = {}
    for k in HIGH_LEVERAGE:
        if k in trimmed:
            reordered[k] = trimmed[k]
    for k, v in trimmed.items():
        if k not in reordered:
            reordered[k] = v
    lines = _yaml_lines(reordered)
    if len(lines) <= _MAX_YAML_LINES:
        return "\n".join(lines)

    # 4) Last resort: hard-cap with a marker.
    kept = lines[:_MAX_YAML_LINES - 1]
    kept.append(f"# ... truncated to {_MAX_YAML_LINES} lines "
                f"(original had {original_len})")
    logger.warning("translation_facts: truncated YAML from %d to %d lines",
                   original_len, _MAX_YAML_LINES)
    return "\n".join(kept)


_FACTS_HEADER = (
    "## TRANSLATION FACTS (machine-extracted from this kernel's layout.csl "
    "+ run.py — these are GROUND TRUTH; if your CSL contradicts a fact "
    "here, the compile will fail)"
)


def render_facts_block(kernel_dir: str | Path) -> str:
    """End-to-end: read, extract, format, wrap with the GROUND TRUTH header.

    Returns the full block ready to drop into a prompt's
    {translation_facts} slot. Never raises — on any error returns the
    header alone with an error note (so the implementer still sees that
    facts WERE attempted, even if extraction broke).
    """
    try:
        facts = extract_layout_facts(kernel_dir)
        body = format_facts_yaml(facts)
    except Exception as exc:  # noqa: BLE001 — never break the prompt
        logger.warning("translation_facts: extraction failed for %s: %s",
                       kernel_dir, exc)
        body = f"# (facts extraction failed: {str(exc)[:120]})"
    return f"{_FACTS_HEADER}\n```yaml\n{body}\n```"


# ---- builtins yaml lookup -------------------------------------------------

_BUILTINS_CACHE: Optional[Dict[str, Any]] = None


def _builtins_path() -> Path:
    return Path(__file__).resolve().parent / "csl_builtins.yaml"


def load_csl_builtins() -> Dict[str, Any]:
    """Lazy-load csl_builtins.yaml. Cached after first call."""
    global _BUILTINS_CACHE
    if _BUILTINS_CACHE is None:
        with open(_builtins_path(), "r", encoding="utf-8") as f:
            _BUILTINS_CACHE = yaml.safe_load(f) or {}
    return _BUILTINS_CACHE


def builtin_arity(name: str) -> Optional[int]:
    """Return the declared arity of a builtin, or None if unknown/variadic."""
    b = load_csl_builtins().get(name)
    if not b:
        return None
    a = b.get("arity")
    return a if isinstance(a, int) else None


def validate_facts_against_builtins(facts: Dict[str, Any]) -> List[str]:
    """Cross-check facts against the builtins YAML; return human-readable warnings.

    Examples of what this catches:
    - task IDs that are larger than what cslc accepts on this arch
      (not currently enforced — cslc range is per-arch and we don't have
      a reliable bound; left as a stub)
    - memcpy reservation listed but no <memcpy/*> import detected
      (would indicate the extractor invented a reservation)
    """
    warnings: List[str] = []
    imports = facts.get("imports") or []
    has_memcpy = any(
        isinstance(e, dict) and "memcpy" in (e.get("path") or "")
        for e in imports
    )
    reserved = facts.get("memcpy_reserved_input_queues")
    if reserved and reserved != _NA and not has_memcpy:
        warnings.append(
            "memcpy_reserved_input_queues set but no memcpy import detected"
        )
    return warnings
