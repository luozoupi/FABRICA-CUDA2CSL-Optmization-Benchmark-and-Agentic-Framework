#!/usr/bin/env python3
"""WS5 — host-loop-bounded run.py linter ("Piece 3j", finally built).

The immune-kernel bug (Power-Method/CG/PCG/BiCGSTAB) was: run.py bracketed the
timed window (f_tic .. f_toc) around a HOST-SIDE Python `for/while` loop issuing
many blocking `simulator.launch(...)` RPCs. The result — cycles_send measured
host<->device sync, not on-device compute — silently made the metric measure the
wrong thing for a whole kernel family (0/158 W2 wins). It took manual forensics
to find. This linter detects the anti-pattern statically so it can never recur
silently.

ANTI-PATTERN (fail):
    runner.launch("f_tic", ...)
    for i in range(max_ite):              # <-- host loop INSIDE the timed window
        runner.launch("f_spmv", ...)      # <-- per-iteration RPC
        ...
    runner.launch("f_toc", ...)

CLEAN (pass): exactly the device entrypoints between tic and toc, no host loop:
    runner.launch("f_tic", ...)
    runner.launch("generate", np.uint16(iters), ...)   # ONE on-device launch
    runner.launch("f_toc", ...)

Usage:
    python check_timing_integrity.py <run.py | kernel_dir | --all>
Exit code 0 = clean, 1 = anti-pattern found (or run.py missing where expected).
Importable: check_run_py(text) -> (ok: bool, reason: str).
"""

from __future__ import annotations

import ast
import os
import re
import sys
from pathlib import Path
from typing import List, Optional, Tuple

REPO_ROOT = Path(__file__).resolve().parents[1]

_LAUNCH_RE = re.compile(r'\.launch\(\s*["\']([A-Za-z_]\w*)["\']')
_TIC_NAMES = ("f_tic",)
_TOC_NAMES = ("f_toc",)


def _launch_name(node: ast.AST) -> Optional[str]:
    """If `node` is an expression statement calling `<x>.launch("name", ...)`,
    return name; else None."""
    call = None
    if isinstance(node, ast.Expr) and isinstance(node.value, ast.Call):
        call = node.value
    elif isinstance(node, ast.Call):
        call = node
    if call is None:
        return None
    func = call.func
    if isinstance(func, ast.Attribute) and func.attr == "launch" and call.args:
        a0 = call.args[0]
        if isinstance(a0, ast.Constant) and isinstance(a0.value, str):
            return a0.value
    return None


def _contains_launch(node: ast.AST) -> bool:
    for sub in ast.walk(node):
        if _launch_name(sub):
            return True
    return False


def check_run_py(text: str) -> Tuple[bool, str]:
    """Return (ok, reason). ok=False if a host loop issuing launch() sits inside
    the f_tic..f_toc timed window, or other timing-integrity problems.

    Strategy: parse the AST, walk statement bodies; track when we are between an
    f_tic launch and an f_toc launch at the same block level; flag any For/While
    in that span that itself contains a `.launch(...)` call.
    """
    try:
        tree = ast.parse(text)
    except SyntaxError as exc:
        return True, f"unparseable run.py (skipped): {exc}"  # don't block on parse failure

    # Only meaningful if the file actually times something.
    if "f_tic" not in text or "f_toc" not in text:
        return True, "no f_tic/f_toc timing window (not a cycle-instrumented runner)"

    problems: List[str] = []

    def scan_block(body: List[ast.stmt]) -> None:
        timing_open = False
        for stmt in body:
            nm = _launch_name(stmt)
            if nm in _TIC_NAMES:
                timing_open = True
                continue
            if nm in _TOC_NAMES:
                timing_open = False
                continue
            if timing_open and isinstance(stmt, (ast.For, ast.While)):
                if _contains_launch(stmt):
                    ln = getattr(stmt, "lineno", "?")
                    problems.append(
                        f"host {'for' if isinstance(stmt, ast.For) else 'while'} "
                        f"loop issuing simulator.launch() INSIDE the f_tic..f_toc "
                        f"window at line {ln} — cycles_send will measure host RPC "
                        f"sync, not on-device compute (immune-kernel bug). Push the "
                        f"iteration loop on-device (single launch in the timed window).")
            # recurse into nested blocks (a tic/toc could be inside main())
            for attr in ("body", "orelse", "finalbody"):
                inner = getattr(stmt, attr, None)
                if isinstance(inner, list) and inner:
                    scan_block(inner)

    scan_block(tree.body)
    if problems:
        return False, "; ".join(problems)
    return True, "clean: timed window brackets device launches, no host loop"


def check_compute_csl(text: str) -> Tuple[bool, str]:
    """Static dead-timer guard for a CSL compute file.

    Counterpart to the dynamic _MIN_PLAUSIBLE_CYCLES floor in benchmark_csl.py.
    A kernel that samples the hardware timestamp counter via get_timestamp()
    (the f_tic/f_toc idiom) MUST first enable it with enable_tsc(), normally in
    the startup task. If it doesn't, the TSC stays frozen, get_timestamp() reads
    a dead counter, and time_end-time_start collapses to single digits — the
    kernel then reports an implausibly tiny cycles_send while still passing
    correctness (observed: 7pt-Stencil agent kernel, cycles_send=8 vs 17134
    reference). This is a measurement bug masquerading as a record win.

    Returns (ok, reason). ok=True when the file either doesn't time anything or
    correctly enables the TSC before sampling it.
    """
    if "get_timestamp" not in text:
        return True, "no get_timestamp (not a self-timed compute file)"
    if "enable_tsc" not in text:
        return False, (
            "compute file calls get_timestamp() but never enable_tsc() — the "
            "timestamp counter is never started, so cycles_send will be a "
            "dead-timer artifact (single/double digits) rather than real elapsed "
            "cycles. Enable the TSC in the startup task: "
            "`task startup() void { timestamp.enable_tsc(); ... }`.")
    return True, "clean: get_timestamp paired with enable_tsc"


_DEV_TIC = "f_tic_dev"
_DEV_TOC = "f_toc_dev"


def check_device_window(text: str) -> Tuple[bool, str]:
    """Static check for the device_internal_v2 timing protocol (shared with the
    contract check): f_tic_dev() first in every exported entry point, f_toc_dev()
    immediately before every host unblock outside the helpers."""
    from timing_protocol import uses_protocol, check_device_window_contract
    if not uses_protocol(text):
        if f"fn {_DEV_TIC}" in text or f"fn {_DEV_TOC}" in text:
            return False, "only one of f_tic_dev/f_toc_dev is defined"
        return True, "no device-internal timing helpers (legacy or single-launch kernel)"
    msg = check_device_window_contract(text)
    if msg:
        return False, msg
    return True, "device-internal window: entry points start with f_tic_dev, f_toc_dev precedes every unblock"

_SUCCESS_RE = re.compile(r'\bSUCCESS\b')
# names that constitute an enforced correctness gate (a stub cannot reach the
# SUCCESS print past one of these unless it is actually correct)
_ASSERT_FN_NAMES = (
    "assert_allclose", "assert_almost_equal", "assert_array_almost_equal",
    "assert_array_equal", "assert_equal", "assert_array_less",
)


def check_success_gated(text: str) -> Tuple[bool, str]:
    """Static anti-gaming guard: a SUCCESS marker must be GATED by an enforced check.

    Counterpart to the dead-timer floor and the per-kernel verifier hardening
    (2026-06-24). A run.py that prints a "SUCCESS" marker — which the benchmark
    harness scrapes as the pass signal — but contains NO enforcement primitive on
    its verification path lets an incorrect kernel be scored a pass. The observed
    case was SpMV / SpMV-Hypersparse, whose verify_result() only PRINTED
    "PASS"/"FAIL" and never raised, so any output reached SUCCESS.

    Heuristic (file-level, conservative to avoid false positives): if the file
    prints a SUCCESS marker, it must also contain at least ONE of:
      - an `assert` statement,
      - a `raise` statement,
      - a `numpy.testing.assert_*` call,
      - a `sys.exit(<nonzero>)` / `exit(<nonzero>)` / `raise SystemExit(<nonzero>)`.
    A file that times/prints SUCCESS with none of these is flagged.

    Returns (ok, reason). ok=True when the file prints no SUCCESS marker, or it
    does and at least one enforcement primitive is present.
    """
    if not _SUCCESS_RE.search(text):
        return True, "no SUCCESS marker (not a pass-signalling runner)"
    try:
        tree = ast.parse(text)
    except SyntaxError as exc:
        return True, f"unparseable run.py (skipped): {exc}"

    has_gate = False

    def _exit_nonzero(call: ast.Call) -> bool:
        # sys.exit(1) / exit(1) / SystemExit(1) with a truthy/nonzero/str arg
        if not call.args:
            return False
        a0 = call.args[0]
        if isinstance(a0, ast.Constant):
            return bool(a0.value)  # 0/None/"" -> not a failure exit
        return True  # non-constant arg: assume it can be nonzero

    for node in ast.walk(tree):
        if isinstance(node, (ast.Assert, ast.Raise)):
            # `raise SystemExit(0)` is not a gate, but bare `raise`/`raise X` is.
            if isinstance(node, ast.Raise) and isinstance(node.exc, ast.Call):
                f = node.exc.func
                nm = getattr(f, "id", None) or getattr(f, "attr", None)
                if nm in ("SystemExit", "exit") and not _exit_nonzero(node.exc):
                    continue
            has_gate = True
            break
        if isinstance(node, ast.Call):
            f = node.func
            attr = getattr(f, "attr", None)
            name = getattr(f, "id", None)
            if attr in _ASSERT_FN_NAMES:
                has_gate = True
                break
            if (attr in ("exit",) or name in ("exit",)) and _exit_nonzero(node):
                has_gate = True
                break
            if attr == "exit" and isinstance(getattr(f, "value", None), ast.Name) \
                    and f.value.id == "sys" and _exit_nonzero(node):
                has_gate = True
                break

    if has_gate:
        return True, "clean: SUCCESS marker is gated by an enforced check"
    return False, (
        "run.py prints a SUCCESS marker but has NO enforcement primitive "
        "(assert / raise / np.testing.assert_* / nonzero exit) anywhere — an "
        "incorrect kernel could be scored a pass (SpMV ungated-verifier bug). "
        "Make the verification RAISE on mismatch before SUCCESS is printed.")


def _find_compute_csl(target: str) -> List[Path]:
    """Find candidate compute .csl files under a kernel dir (best-effort)."""
    p = Path(target)
    if p.is_file() and p.suffix == ".csl":
        return [p]
    out: List[Path] = []
    for base in (p, p / "CSL", p / "CSL" / "src"):
        if base.is_dir():
            out.extend(sorted(base.glob("*.csl")))
    return out


def _find_run_py(target: str) -> Optional[Path]:
    p = Path(target)
    if p.is_file():
        return p
    for cand in (p / "run.py", p / "CSL" / "run.py"):
        if cand.is_file():
            return cand
    return None


def check_target(target: str) -> Tuple[str, bool, str]:
    rp = _find_run_py(target)
    if rp is None:
        return target, False, "run.py not found"
    text = rp.read_text(encoding="utf-8", errors="ignore")
    ok_timing, reason_timing = check_run_py(text)
    ok_gate, reason_gate = check_success_gated(text)
    # device_internal_v2 kernels: the window is stamped in the compute file
    dev_reasons: List[str] = []
    for csl in _find_compute_csl(target):
        csl_text = csl.read_text(encoding="utf-8", errors="ignore")
        if f"fn {_DEV_TIC}" in csl_text:
            ok_dev, reason_dev = check_device_window(csl_text)
            if not ok_dev:
                return str(csl), False, reason_dev
            dev_reasons.append(f"{csl.name}: {reason_dev}")
    # Surface a real problem (not the benign "no timing window" skip) first.
    if not ok_gate:
        return str(rp), False, reason_gate
    if not ok_timing:
        return str(rp), False, reason_timing
    extra = ("; " + "; ".join(dev_reasons)) if dev_reasons else ""
    return str(rp), True, f"{reason_timing}; {reason_gate}{extra}"


def main() -> int:
    args = sys.argv[1:]
    if not args:
        print(__doc__)
        return 2
    targets: List[str]
    if args[0] == "--all":
        targets = [str(d) for d in sorted((REPO_ROOT / "kernels").iterdir())
                   if d.is_dir() and (d / "CSL" / "run.py").is_file()]
    else:
        targets = args
    any_bad = False
    for t in targets:
        path, ok, reason = check_target(t)
        status = "OK  " if ok else "FAIL"
        if not ok and "not a cycle-instrumented" not in reason:
            any_bad = True
        print(f"[{status}] {path}\n        {reason}")
    return 1 if any_bad else 0


if __name__ == "__main__":
    sys.exit(main())
