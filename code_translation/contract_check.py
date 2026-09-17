"""Contract validator — rejects optimizer variants that tamper with the
measurement contract (timing functions, host-supplied params, library imports).

Background: the first cycle-optimization smoke (#79) on 7pt-Stencil
"reduced" cycles 2129 -> 87 by (a) making f_tic/f_toc no-ops and moving
the timestamp capture inside f_spmv, and (b) overriding the host-supplied
BLOCK_SIZE to 1. The output was bitwise-correct but the cycle count
measured a tiny fraction of the actual work. The validator catches both
patterns by comparing the variant against the reference at the function
body and param-decl level.

Used by ``CUDA2CSLOrchestrator.optimize()`` immediately after a variant
benchmarks pass — if the variant fails the contract check, it is rejected
regardless of how few cycles it reports.

The set of frozen functions and params is per-kernel. Defaults cover the
patterns we've seen the model game; per-kernel overrides come from
``kernels/<name>/spec.yaml`` via the ``frozen_functions`` and
``frozen_params`` fields (see SPEC_SCHEMA.md).
"""

from __future__ import annotations

import re
from typing import Dict, List, Optional, Sequence, Tuple

# Functions whose body is part of the measurement contract for most kernels
# that use the standard Cerebras run.py / tic-toc pattern. Empirical: every
# benchmark in csl-examples/benchmarks/ that prints cycles_send has at least
# f_tic / f_toc with substantive bodies; some also have memcpy/reference
# timestamp helpers.
DEFAULT_FROZEN_FUNCTIONS = (
    "f_tic",
    "f_toc",
    "f_memcpy_timestamps",
    "f_reference_timestamps",
    "f_tic_dev",
    "f_toc_dev",
)

# Params declared at the top of the compute file and supplied via
# cslc --params=...  Redeclaring (or shadowing with `const NAME_LOCAL = ...`)
# changes the workload, not the kernel implementation.
# Functions whose CALL SITES are frozen as well as their bodies: the
# device-internal timing helpers (protocol device_internal_v2). A variant that
# drops, moves or duplicates a call shrinks or shifts the measured window.
CALLSITE_FROZEN_FUNCTIONS = ("f_tic_dev", "f_toc_dev")

DEFAULT_FROZEN_PARAMS = (
    "BLOCK_SIZE", "MAX_ZDIM", "STARTUP",
    "width", "height", "m", "n", "k",
    "memcpyParams", "reduceParams", "stencilParams",
)


# ---------------------------------------------------------------------------
# Parsing helpers
# ---------------------------------------------------------------------------

def _strip_block_comments(src: str) -> str:
    """Remove /* ... */ blocks. Used before brace-counting so a `{` inside a
    block comment doesn't fool the body extractor."""
    return re.sub(r"/\*.*?\*/", "", src, flags=re.DOTALL)


def _strip_line_comments(src: str) -> str:
    """Drop everything after `//` on each line. Same rationale as above for
    comment normalization at body-compare time."""
    return re.sub(r"//[^\n]*", "", src)


def extract_function_body(src: str, fn_name: str) -> Optional[str]:
    """Return the body of ``fn FN_NAME(...) ... { BODY }`` as raw source
    text between the matching braces, or None if the function isn't defined.

    Brace-balanced, robust to nested blocks. Skips block comments before
    scanning so a `{` inside `/* */` doesn't shift the match. The returned
    body INCLUDES whitespace; normalize with ``normalize_body`` for
    semantic comparison.
    """
    no_block_comments = _strip_block_comments(src)
    # Match: optional `pub`/etc qualifiers, then `fn FN_NAME(`. Token-bounded
    # so f_tic matches f_tic but not f_tick.
    sig_re = re.compile(rf"\bfn\s+{re.escape(fn_name)}\s*\(")
    m = sig_re.search(no_block_comments)
    if not m:
        return None
    # Walk forward from the match to find the opening `{` after the signature.
    i = m.end()
    n = len(no_block_comments)
    while i < n and no_block_comments[i] != "{":
        i += 1
    if i >= n:
        return None
    # Now brace-walk. Track strings/chars so braces inside literals don't
    # confuse the counter.
    depth = 0
    start = None
    j = i
    in_str = False
    in_char = False
    while j < n:
        c = no_block_comments[j]
        if in_str:
            if c == "\\":
                j += 2
                continue
            if c == '"':
                in_str = False
        elif in_char:
            if c == "\\":
                j += 2
                continue
            if c == "'":
                in_char = False
        elif c == '"':
            in_str = True
        elif c == "'":
            in_char = True
        elif c == "{":
            if depth == 0:
                start = j + 1
            depth += 1
        elif c == "}":
            depth -= 1
            if depth == 0:
                return no_block_comments[start:j] if start is not None else ""
        j += 1
    return None


def normalize_body(body: str) -> str:
    """Strip line comments + collapse whitespace so two semantically-equal
    bodies compare equal even if one has different formatting."""
    s = _strip_line_comments(body)
    s = re.sub(r"\s+", " ", s).strip()
    return s


def _find_function_span(src: str, fn_name: str) -> Optional[Tuple[int, int]]:
    """Return (start, end) char offsets of the FULL `fn NAME(...) {...}`
    definition in `src` (signature through the matching closing brace), or None.

    Operates on the ORIGINAL source (offsets are valid for slicing/splicing).
    Tracks block comments, line comments, and string/char literals so a brace
    inside any of them does not confuse the depth counter.
    """
    sig_re = re.compile(rf"\bfn\s+{re.escape(fn_name)}\s*\(")
    m = sig_re.search(src)
    if not m:
        return None
    start = m.start()
    n = len(src)
    i = m.end()
    # advance to the opening brace of the body, skipping comments/strings
    depth = 0
    j = i
    in_str = in_char = in_block = in_line = False
    body_started = False
    while j < n:
        c = src[j]
        nxt = src[j + 1] if j + 1 < n else ""
        if in_line:
            if c == "\n":
                in_line = False
            j += 1
            continue
        if in_block:
            if c == "*" and nxt == "/":
                in_block = False
                j += 2
                continue
            j += 1
            continue
        if in_str:
            if c == "\\":
                j += 2
                continue
            if c == '"':
                in_str = False
            j += 1
            continue
        if in_char:
            if c == "\\":
                j += 2
                continue
            if c == "'":
                in_char = False
            j += 1
            continue
        if c == "/" and nxt == "*":
            in_block = True
            j += 2
            continue
        if c == "/" and nxt == "/":
            in_line = True
            j += 2
            continue
        if c == '"':
            in_str = True
            j += 1
            continue
        if c == "'":
            in_char = True
            j += 1
            continue
        if c == "{":
            depth += 1
            body_started = True
        elif c == "}":
            depth -= 1
            if body_started and depth == 0:
                return (start, j + 1)
        j += 1
    return None


def validate_frozen_callsites(variant_src: str, reference_src: str,
                              fns: Sequence[str] = CALLSITE_FROZEN_FUNCTIONS) -> Optional[str]:
    """Rule 4: when the reference uses the device_internal_v2 timing protocol,
    the variant must satisfy it too: every exported entry point starts with
    f_tic_dev() and every host unblock outside the helpers is immediately
    preceded by f_toc_dev(). Structure-agnostic (an agent program may end in a
    different task than the reference)."""
    from timing_protocol import uses_protocol, check_device_window_contract
    if not uses_protocol(reference_src):
        return None
    msg = check_device_window_contract(variant_src)
    return f"FROZEN timing window: {msg}" if msg else None


def splice_frozen_functions(candidate_src: str, reference_src: str,
                            frozen_functions: Sequence[str]) -> Tuple[str, List[str]]:
    """Overwrite each frozen function's definition in `candidate_src` with the
    reference's verbatim definition. Returns (spliced_src, replaced_names).

    Mechanically enforces the frozen-function contract instead of relying on the
    model to leave timing functions (f_tic/f_toc/f_memcpy_timestamps/
    f_reference_timestamps) untouched — a recurring W2 failure where the model
    regenerates the whole file and perturbs a frozen timing fn, tripping the
    contract gate and killing every optimize candidate. Only functions present
    in BOTH the candidate and the reference are spliced; a frozen fn the
    candidate omitted entirely is left to the validator to reject (that is a
    structural change, not cosmetic drift). Idempotent when bodies already match.
    """
    replaced: List[str] = []
    out = candidate_src
    for fn in frozen_functions:
        ref_span = _find_function_span(reference_src, fn)
        if not ref_span:
            continue  # not a function (e.g. a frozen param) or absent in ref
        ref_text = reference_src[ref_span[0]:ref_span[1]]
        cand_span = _find_function_span(out, fn)
        if not cand_span:
            continue  # candidate dropped it; let the validator flag the omission
        cur_text = out[cand_span[0]:cand_span[1]]
        if normalize_body(cur_text) == normalize_body(ref_text):
            continue  # already identical (modulo formatting); nothing to do
        out = out[:cand_span[0]] + ref_text + out[cand_span[1]:]
        replaced.append(fn)
    return out, replaced


def _enumerate_param_decls(src: str) -> List[str]:
    """Return param names declared at top level via `param NAME: TYPE;`.

    Used by the frozen-param check to detect introduction of a NEW param
    that the host didn't supply (which would shadow the host-supplied one).
    """
    no_block_comments = _strip_block_comments(src)
    no_line_comments = _strip_line_comments(no_block_comments)
    return re.findall(r"\bparam\s+([A-Za-z_][A-Za-z0-9_]*)\s*:", no_line_comments)


def _find_local_overrides_for_param(src: str, param_name: str) -> List[str]:
    """Find local declarations that look like they're shadowing a host-
    supplied param. Matches patterns like:
      const BLOCK_SIZE = 1;
      const BLOCK_SIZE: i16 = 1;
      const BLOCK_SIZE_LOCAL: i16 = 1;
      var BLOCK_SIZE = 1;

    For each frozen param, ANY local `const`/`var` declaration whose name
    starts with the param name and ends in `_LOCAL` / `_OVERRIDE` / `_TMP`
    OR exactly equals the param name (rare but worth catching) is flagged.
    """
    no_block_comments = _strip_block_comments(src)
    no_line_comments = _strip_line_comments(no_block_comments)
    hits: List[str] = []
    # Exact-name re-declaration as const/var (shadowing the param)
    pat_exact = re.compile(
        rf"\b(?:const|var)\s+{re.escape(param_name)}\s*(?::|=)"
    )
    if pat_exact.search(no_line_comments):
        hits.append(f"local const/var named '{param_name}' shadows host-supplied param")
    # Name-pattern variants: <param>_LOCAL, <param>_OVERRIDE, <param>_TMP
    pat_variant = re.compile(
        rf"\b(?:const|var)\s+({re.escape(param_name)}_(?:LOCAL|OVERRIDE|TMP|FIXED))\b"
    )
    for m in pat_variant.finditer(no_line_comments):
        hits.append(f"local '{m.group(1)}' looks like an override of host-supplied '{param_name}'")
    return hits


def _array_extents_by_param(src: str) -> Dict[str, List[str]]:
    """Map each backing-store array name -> list of its first-dim extent tokens
    from `var NAME = @zeros([EXTENT]...)`. EXTENT is captured verbatim (could be
    a param name like `MAX_ZDIM`, an expr, or a numeric literal).
    """
    no_block = _strip_block_comments(src)
    no_line = _strip_line_comments(no_block)
    out: Dict[str, List[str]] = {}
    # var x = @zeros([MAX_ZDIM]f32);   /   var y = @zeros([N*M]f32);
    for m in re.finditer(
            r"\bvar\s+([A-Za-z_]\w*)\s*=\s*@zeros\(\s*\[\s*([^\]]+?)\s*\]", no_line):
        out.setdefault(m.group(1), []).append(m.group(2).strip())
    return out


def _problem_size_shrunk(variant_src: str, reference_src: str,
                         ref_params: set, frozen_params: Sequence[str]) -> Optional[str]:
    """Flag a cycle-gaming shrink: a backing array whose extent in the reference
    is a FROZEN PARAM (or contains one) but in the variant became a strictly
    smaller NUMERIC LITERAL. Conservative — only fires on the param->smaller-int
    case, where intent to shrink the problem is unambiguous.
    """
    ref_arrays = _array_extents_by_param(reference_src)
    var_arrays = _array_extents_by_param(variant_src)
    frozen = set(frozen_params)
    for name, ref_extents in ref_arrays.items():
        var_extents = var_arrays.get(name)
        if not var_extents:
            continue
        for ref_ext, var_ext in zip(ref_extents, var_extents):
            ref_has_frozen = any(re.search(rf"\b{re.escape(p)}\b", ref_ext) for p in frozen)
            if not ref_has_frozen:
                continue
            # ref extent is param-sized; if variant made it a bare smaller int -> shrink
            if re.fullmatch(r"\d+", var_ext) and not re.fullmatch(r"\d+", ref_ext):
                return (f"PROBLEM-SIZE shrink: array '{name}' extent was "
                        f"'{ref_ext}' (param-sized) in the reference but a fixed "
                        f"literal '{var_ext}' in the variant — shrinking the "
                        f"problem to lower cycles is not a valid win")
    return None


# ---------------------------------------------------------------------------
# Public validator
# ---------------------------------------------------------------------------

def validate_against_reference(
    variant_src: str,
    reference_src: str,
    frozen_functions: Sequence[str] = DEFAULT_FROZEN_FUNCTIONS,
    frozen_params: Sequence[str] = DEFAULT_FROZEN_PARAMS,
) -> Optional[str]:
    """Validate a variant against the reference compute file.

    Returns ``None`` if the variant respects the contract; otherwise a short
    string explaining what was violated (suitable for logging + showing the
    LLM as a reject reason on the next attempt).

    Checks performed:

    1. **Frozen-function bodies** — for each frozen function NAME present in
       the reference, the variant's body of NAME (after stripping comments
       and collapsing whitespace) must equal the reference's body. Missing
       entirely from the variant = violation. Body differs = violation.

    2. **Frozen-param shadowing** — for each frozen param NAME present in the
       reference's `param NAME: TYPE;` decls, the variant must NOT introduce
       a local `const`/`var` named NAME or NAME_LOCAL / NAME_OVERRIDE /
       NAME_TMP / NAME_FIXED that would override the host-supplied value.

    The check is intentionally one-way: extra functions/params in the variant
    are fine. The contract is "don't touch the frozen stuff", not "match
    the reference exactly".
    """
    if not variant_src or not reference_src:
        return None  # nothing to compare; let the benchmark step decide

    violations: List[str] = []

    # 1) Frozen-function bodies
    for fn in frozen_functions:
        ref_body = extract_function_body(reference_src, fn)
        if ref_body is None:
            # Reference doesn't define this fn; nothing to compare for it.
            continue
        var_body = extract_function_body(variant_src, fn)
        if var_body is None:
            violations.append(
                f"FROZEN function '{fn}' is missing from the variant "
                f"(reference defines it; you must keep it intact)"
            )
            continue
        if normalize_body(var_body) != normalize_body(ref_body):
            violations.append(
                f"FROZEN function '{fn}' body changed vs reference "
                f"(timing fns must capture the timestamp exactly as the reference does)"
            )

    # 2) Frozen-param shadowing
    ref_params = set(_enumerate_param_decls(reference_src))
    for p in frozen_params:
        if p not in ref_params:
            continue  # reference doesn't declare this param; nothing to defend
        for h in _find_local_overrides_for_param(variant_src, p):
            violations.append(f"FROZEN param '{p}': {h}")

    # 3) Problem-size guard (WS5, 2026-06-20) — the variant must not WIN by
    #    quietly shrinking the problem. Compare @zeros([...]) backing-store
    #    extents that are sized by a frozen param: if the variant replaces a
    #    frozen-param-sized extent with a smaller numeric literal, that's a
    #    cycle-gaming shrink. Conservative: only flags a frozen-param dim that
    #    became a strictly smaller integer constant.
    size_violation = _problem_size_shrunk(variant_src, reference_src, ref_params, frozen_params)
    if size_violation:
        violations.append(size_violation)

    # 4) Frozen call sites (device-internal timing helpers, 2026-09-08): the
    #    stamps must stay where the reference put them.
    callsite_violation = validate_frozen_callsites(variant_src, reference_src)
    if callsite_violation:
        violations.append(callsite_violation)

    if violations:
        # Cap message length so log lines stay grep-friendly.
        msg = "; ".join(violations)
        return msg if len(msg) <= 600 else msg[:597] + "..."
    return None


# ---------------------------------------------------------------------------
# Spec loader: pull per-kernel overrides from spec.yaml
# ---------------------------------------------------------------------------

def spec_frozen_lists(spec: Optional[Dict[str, object]]) -> Tuple[Sequence[str], Sequence[str]]:
    """Return (frozen_functions, frozen_params) for a spec.yaml dict, falling
    back to defaults when fields are absent or spec is None."""
    if not spec or not isinstance(spec, dict):
        return DEFAULT_FROZEN_FUNCTIONS, DEFAULT_FROZEN_PARAMS
    ff = spec.get("frozen_functions")
    fp = spec.get("frozen_params")
    return (
        tuple(ff) if isinstance(ff, list) and ff else DEFAULT_FROZEN_FUNCTIONS,
        tuple(fp) if isinstance(fp, list) and fp else DEFAULT_FROZEN_PARAMS,
    )
