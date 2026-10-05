"""Numeric-correctness gate for explore_csl candidates.

The structural ``contract_check.validate_against_reference`` confirms that an
exploration candidate keeps the frozen timing functions and host-supplied
params intact. It does NOT confirm that the kernel produces the right answer:
a candidate can satisfy the symbol contract and still emit garbage.

For exploration in particular, where the run.py is generated alongside the
CSL (instead of being copied from a hand-curated reference), we need a second
gate that the generated ``run.py`` actually verifies the device output against
a host-side reference. Two simple checks:

1. The file imports ``numpy``.
2. The file calls ``np.testing.assert_allclose`` (or
   ``numpy.testing.assert_allclose``) at least once, AND the call's first
   argument is NOT also its second argument (cheap sanity check against the
   degenerate ``assert_allclose(out, out)`` that always passes).

Failing this gate marks the candidate as ``status="numeric_check_failed"``
even if the bundle compiled and ran. Briefs handed to the implementer for
Mode B/Mode C MUST include an ``acceptance_numerics`` section that names the
reference computation.

The check is deliberately textual — running the script for real is not safe
(it would re-execute the CSL kernel) and AST-based analysis would miss the
common pattern of computing the reference via a helper module. Two regex
checks plus the self-compare guard catches the obvious gaming patterns.
"""

from __future__ import annotations

import ast
import re
from pathlib import Path
from typing import Optional


_ASSERT_ALLCLOSE_RE = re.compile(
    r"\b(?:np|numpy)(?:\.testing)?\.assert_allclose\s*\("
)
_NUMPY_IMPORT_RE = re.compile(
    r"^\s*(?:import\s+numpy(?:\s+as\s+\w+)?|from\s+numpy(?:\.\w+)*\s+import\s+)",
    re.MULTILINE,
)


def _strip_python_comments(src: str) -> str:
    """Drop Python ``#`` line comments so a commented-out check doesn't pass."""
    return re.sub(r"#.*?$", "", src, flags=re.MULTILINE)


def _assert_allclose_first_two_args(src: str) -> Optional[tuple]:
    """Return ``(arg0_text, arg1_text)`` of the first assert_allclose call,
    or ``None`` if parsing fails / no call present. Used by the self-compare
    guard. AST-based so we handle multi-line calls and nested parens.
    """
    try:
        tree = ast.parse(src)
    except SyntaxError:
        return None

    for node in ast.walk(tree):
        if not isinstance(node, ast.Call):
            continue
        # Match np.testing.assert_allclose / numpy.testing.assert_allclose /
        # assert_allclose (when imported directly).
        func = node.func
        name = None
        if isinstance(func, ast.Attribute) and func.attr == "assert_allclose":
            name = "assert_allclose"
        elif isinstance(func, ast.Name) and func.id == "assert_allclose":
            name = "assert_allclose"
        if not name or len(node.args) < 2:
            continue
        try:
            arg0 = ast.unparse(node.args[0])
            arg1 = ast.unparse(node.args[1])
        except Exception:
            return ("", "")
        return (arg0.strip(), arg1.strip())
    return None


def validate_run_py(run_py_text: str) -> Optional[str]:
    """Return ``None`` if ``run_py_text`` looks like it numerically verifies
    the kernel output, else a short string explaining what's missing.
    """
    if not run_py_text or not run_py_text.strip():
        return "run.py is empty"
    stripped = _strip_python_comments(run_py_text)
    if not _NUMPY_IMPORT_RE.search(stripped):
        return "run.py does not import numpy"
    if not _ASSERT_ALLCLOSE_RE.search(stripped):
        return ("run.py contains no numpy.testing.assert_allclose call — "
                "exploration candidates must compute a host-side reference "
                "and assert the device output matches it")
    args = _assert_allclose_first_two_args(run_py_text)
    if args is not None:
        a0, a1 = args
        if a0 and a0 == a1:
            return ("run.py's assert_allclose compares a value to itself "
                    f"(both args are `{a0}`) — this is the degenerate "
                    "self-compare pattern and does not verify correctness")
    return None


def validate_run_py_file(path: str | Path) -> Optional[str]:
    p = Path(path)
    if not p.is_file():
        return f"run.py not found at {p}"
    try:
        text = p.read_text(encoding="utf-8")
    except OSError as exc:
        return f"run.py unreadable: {exc}"
    return validate_run_py(text)


__all__ = ["validate_run_py", "validate_run_py_file"]
