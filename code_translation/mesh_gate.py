"""Parse-time mesh gate for explore_csl candidates.

The exploration LLM is free to pick any @set_rectangle(W, H) in its
emitted layout.csl. Without a gate it tends to collapse hard-tier seeds
(matmul_summa_2d, stencil_5pt_2d) onto a single PE because that's the
shortest path to passing the assert_allclose. We block that collapse
BEFORE we burn cslc on the bundle: parse the rectangle, resolve its
values against the bundle's commands_wse3.sh --params, and reject if
W*H < min_pe_count.

The parser is intentionally narrow:
  - handles ``@set_rectangle(LITERAL, LITERAL)``
  - handles ``@set_rectangle(IDENT, IDENT)`` where IDENT is a top-level
    ``const NAME: TYPE = INT;`` declaration or a ``param NAME: TYPE;``
    bound by the bundle's commands_wse3.sh via --params=NAME:INT,...
  - handles trivial arithmetic like ``@set_rectangle(P, P)`` or
    ``@set_rectangle(@as(u16, P), Q)``
  - everything else is reported as ``unknown`` so the caller can decide
    to pass or fail-open

This is NOT a full CSL evaluator. We accept some false-negatives
(``unknown``) over inventing a wrong PE count.
"""

from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Optional, Tuple


_SET_RECT_RE = re.compile(
    r"@set_rectangle\s*\(\s*([^,]+?)\s*,\s*([^)]+?)\s*\)"
)
_CONST_RE = re.compile(
    r"\bconst\s+([A-Za-z_][A-Za-z0-9_]*)\s*(?::\s*[A-Za-z0-9_]+\s*)?=\s*"
    r"(\d+)\s*;"
)
_PARAM_RE = re.compile(
    r"\bparam\s+([A-Za-z_][A-Za-z0-9_]*)\s*:\s*[A-Za-z0-9_]+\s*;"
)


@dataclass
class MeshShape:
    width: Optional[int]
    height: Optional[int]
    raw_w: str
    raw_h: str
    confidence: str   # "exact" | "params-resolved" | "unknown"

    @property
    def pe_count(self) -> Optional[int]:
        if self.width is None or self.height is None:
            return None
        return int(self.width) * int(self.height)


def _strip_line_comments(src: str) -> str:
    return re.sub(r"//[^\n]*", "", src)


def _try_int(s: str) -> Optional[int]:
    s = s.strip()
    try:
        return int(s)
    except ValueError:
        return None


def _resolve_token(token: str,
                   consts: Dict[str, int],
                   params: Dict[str, int]) -> Optional[int]:
    """Resolve a single rectangle-arg token to an int. Handles literals,
    bare identifiers, ``@as(TYPE, IDENT)`` casts, and trivial products."""
    t = token.strip()
    # @as(TYPE, EXPR) -> recurse on EXPR
    m = re.match(r"@as\s*\(\s*[A-Za-z0-9_]+\s*,\s*(.+?)\s*\)\s*$", t)
    if m:
        return _resolve_token(m.group(1), consts, params)
    # Bare integer literal
    lit = _try_int(t)
    if lit is not None:
        return lit
    # Trivial product A*B
    if "*" in t and "(" not in t:
        parts = [p.strip() for p in t.split("*")]
        if all(parts):
            sub = [_resolve_token(p, consts, params) for p in parts]
            if all(x is not None for x in sub):
                product = 1
                for x in sub:
                    product *= int(x)
                return product
    # Bare identifier -> const or param
    m = re.match(r"^([A-Za-z_][A-Za-z0-9_]*)$", t)
    if m:
        name = m.group(1)
        if name in consts:
            return consts[name]
        if name in params:
            return params[name]
    return None


def parse_layout_consts(layout_text: str) -> Dict[str, int]:
    """Pull ``const NAME = INT;`` declarations from layout.csl."""
    if not layout_text:
        return {}
    src = _strip_line_comments(layout_text)
    return {m.group(1): int(m.group(2)) for m in _CONST_RE.finditer(src)}


def parse_layout_params(layout_text: str) -> set:
    """Return the set of param names declared at top level of layout.csl."""
    if not layout_text:
        return set()
    src = _strip_line_comments(layout_text)
    return {m.group(1) for m in _PARAM_RE.finditer(src)}


_CSLC_PARAMS_RE = re.compile(r"--params[= ]([A-Za-z0-9_:,.\-]+)")


def parse_params_from_commands(commands_sh: str) -> Dict[str, int]:
    """Extract ``--params=NAME:INT,NAME:INT`` from the commands script.

    Non-int values are skipped (we only care about params that contribute
    to a rectangle dimension).
    """
    if not commands_sh:
        return {}
    out: Dict[str, int] = {}
    for m in _CSLC_PARAMS_RE.finditer(commands_sh):
        payload = m.group(1)
        for pair in payload.split(","):
            if ":" not in pair:
                continue
            name, value = pair.split(":", 1)
            try:
                out[name.strip()] = int(value.strip())
            except ValueError:
                continue
    return out


def parse_set_rectangle(layout_text: str,
                        commands_sh: str = "") -> Optional[MeshShape]:
    """Return the resolved MeshShape from the first @set_rectangle call
    in ``layout_text``, or None if no call is present.
    """
    if not layout_text:
        return None
    src = _strip_line_comments(layout_text)
    m = _SET_RECT_RE.search(src)
    if not m:
        return None
    raw_w, raw_h = m.group(1), m.group(2)
    consts = parse_layout_consts(layout_text)
    params = parse_params_from_commands(commands_sh)
    w = _resolve_token(raw_w, consts, params)
    h = _resolve_token(raw_h, consts, params)
    if w is not None and h is not None:
        # Distinguish "all literals/consts" from "needed --params" so the
        # gate's reject message can say which knob to inspect. A token is
        # "params-resolved" if its identifier appears in the --params
        # bindings AND is NOT shadowed by a local `const NAME = INT;`.
        idents = set(re.findall(r"[A-Za-z_]\w*", raw_w + " " + raw_h))
        param_idents = idents & set(params) - set(consts)
        confidence = "params-resolved" if param_idents else "exact"
        return MeshShape(width=int(w), height=int(h),
                         raw_w=raw_w.strip(), raw_h=raw_h.strip(),
                         confidence=confidence)
    return MeshShape(width=None, height=None,
                     raw_w=raw_w.strip(), raw_h=raw_h.strip(),
                     confidence="unknown")


# ---------------------------------------------------------------------------
# Gate
# ---------------------------------------------------------------------------

@dataclass
class GateResult:
    passed: bool
    mesh: Optional[MeshShape]
    reason: Optional[str]


def check_mesh_gate(layout_text: str,
                    commands_sh: str,
                    *,
                    min_pe_count: int,
                    fail_on_unknown: bool = False) -> GateResult:
    """Return whether this bundle's mesh satisfies the seed's PE floor.

    ``fail_on_unknown`` controls behaviour when the rectangle can't be
    resolved (e.g. arithmetic the narrow parser doesn't cover): default
    False = pass through to cslc, True = treat as a violation. Default
    is conservative — we don't want to false-reject legitimate kernels
    just because of a parser limit; the cslc compile itself will catch
    structural mistakes.
    """
    if min_pe_count <= 1:
        # No floor to enforce — single-PE allowed.
        return GateResult(passed=True, mesh=parse_set_rectangle(
            layout_text, commands_sh), reason=None)
    mesh = parse_set_rectangle(layout_text, commands_sh)
    if mesh is None:
        # No @set_rectangle in the layout — likely an invalid layout.csl;
        # let cslc surface the real error. Don't treat as gate violation.
        return GateResult(passed=True, mesh=None, reason=None)
    if mesh.confidence == "unknown":
        if fail_on_unknown:
            return GateResult(
                passed=False, mesh=mesh,
                reason=(f"mesh dimensions could not be resolved "
                        f"(raw=({mesh.raw_w}, {mesh.raw_h})); explicit "
                        f"--require-mesh-resolved mode active"))
        return GateResult(passed=True, mesh=mesh, reason=None)
    pe = mesh.pe_count or 0
    if pe < min_pe_count:
        return GateResult(
            passed=False, mesh=mesh,
            reason=(f"mesh_too_small: @set_rectangle({mesh.raw_w}, "
                    f"{mesh.raw_h}) resolves to {mesh.width}*"
                    f"{mesh.height}={pe} PEs but the seed requires "
                    f">= {min_pe_count} PEs. Single-PE collapses are "
                    f"forbidden for this difficulty tier — re-emit the "
                    f"bundle with a multi-PE layout."))
    return GateResult(passed=True, mesh=mesh, reason=None)


__all__ = [
    "MeshShape",
    "GateResult",
    "parse_set_rectangle",
    "parse_layout_consts",
    "parse_layout_params",
    "parse_params_from_commands",
    "check_mesh_gate",
]
