#!/usr/bin/env python3
"""Error-family classifier for preserved xkernel runs.

Each translation/optimization attempt (final_result.json -> attempts[]) carries
the benchmark harness transcript (compile / run steps with stderr+stdout), the
harness verdict (status, success_marker, failure_reason, heldout_eval) and the
contract check. `classify_attempt()` maps one attempt to exactly one family
from the ordered table below; `classify_run()` does it for a run directory and
`--corpus` tallies a results tree into docs/data/error_families.csv.

The regex table was built from the normalized first-error lines of 32,309
attempts in code_translation/results (2026-09-08; `--mine` prints the current
unmatched lines so the table can be audited). Families, in match priority:

  gate / harness level (from the verdict, not the transcript)
    sdk_env_blocked        container / cslc-driver / pthread / MPI / module failures
    llm_error              provider failure, no code produced
    no_csl_block           reply carried no ```csl fence
    contract_violation     frozen-function / entry-point contract check failed
    heldout_mismatch       passes the shown seed, fails a held-out seed
    implausible_cycles     dead timer (<100 cycles) rejected by the harness
    missing_success_marker run finished without the SUCCESS line
    compile_only_check     XKERNEL_DRY_CHECK compile-only record (not a failure)
    pass_unverified        legacy: status pass, marker absent, no reason recorded
  compile step
    cslc_internal_crash    compiler assertion / stack dump (agent-triggered)
    bad_import             wrong library path / symbol in @import_module
    layout_error           @set_tile_code coverage, layout block evaluation, directions
    shadow_or_decl         shadowed or duplicate declarations
    unknown_builtin        @builtin that does not exist in CSL
    syntax_error           lexer/parser errors (stray markdown, bad tokens)
    uninitialized_param    a layout param never reached the module (SDK lib error)
    export_mutability      var/const pointer does not match @export_name's mutable flag
    dsr_arity_mismatch     DSR id mismatch between destination and source DSDs
    queue_or_ut_id         input/output queue, task-id or ut_id misuse
    contract_entrypoint    export named in layout not declared in the module
    task_binding           bind_local_task / bind_data_task misuse
    undeclared_identifier
    comptime_misuse        comptime-only builtins, inline loop limits, casts
    dsd_construction       affine-expression / tensor-access / DSD-shape errors
    call_arity             builtin or function argument-count mismatch
    type_mismatch
    link_oom               ran out of PE memory
    other_compile_error
  run step
    runtime_stall          simulator: received length not expected (kernel stall)
    runtime_fatal_ut       ut_instr / input-queue remap fatal (microthread misuse)
    runtime_fatal_hcf      hcf, instruction post check, other PE fatals
    runtime_timeout
    verify_mismatch        AssertionError / residual / max-abs-err checks
    missing_export_symbol  host memcpy on a symbol the module did not export
    runtime_python_error   other Python exceptions in run.py
    runtime_crash          simulator abort/segfault with no diagnostic
    other_runtime_error
  unknown                  nothing matched (should be ~0; see --mine)

Usage:
  python error_family.py --run <kernel_output_dir>            # writes error_families.json
  python error_family.py --corpus code_translation/results --out docs/data/error_families.csv
  python error_family.py --corpus code_translation/results --mine 40
"""
from __future__ import annotations

import argparse
import csv
import json
import re
import sys
from collections import Counter, defaultdict
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Tuple

ANSI = re.compile(r"\x1b\[[0-9;]*m")
NOISE = re.compile(r"Fontconfig error|SINGULARITYENV_|APPTAINERENV_|^\s*\[INFO\]|INFO:\s+Environment variable|"
                   r"SDKR050|SDKR100|^\s*WARNING", re.I)

# (family, compiled regex) in match priority.  Compile-step table.
COMPILE_TABLE: List[Tuple[str, re.Pattern]] = [
    ("cslc_internal_crash", re.compile(r"cslc-driver: .*Assertion `.*' failed|cslc-driver: .*\.h:\d+: .*Assertion|"
                                       r"PLEASE submit a bug report|Stack dump:")),
    ("bad_import", re.compile(r"Unable to open [^\n]*: no such file|module does not contain the requested symbol|"
                              r"cannot find module|unknown import")),
    ("layout_error", re.compile(r"no @set_tile_code called|failed to evaluate layout block|"
                                r"expected at most \d+ (?:input|output) direction|"
                                r"builtin call must be the initializer of a global variable")),
    ("shadow_or_decl", re.compile(r"declaration shadows another symbol|redefinition of|already declared|"
                                  r"duplicate (?:symbol|declaration)")),
    ("unknown_builtin", re.compile(r"unknown builtin @\w+")),
    ("syntax_error", re.compile(r"Unexpected character at this location|unexpected token|expected '[;,)\]}]'|"
                                r"invalid token|expected expression, got|expected ';'")),
    ("uninitialized_param", re.compile(r"only 'var' and 'extern const' variables may be uninitialized|"
                                       r"expected (?:integer|numeric|type) [^\n]*got: 'void'")),
    ("export_mutability", re.compile(r"exported symbol mutability mismatch|expected name to be (?:im)?mutable")),
    ("dsr_arity_mismatch", re.compile(r"destination DSR Id\(\d+\) does not match first source DSR Id|"
                                      r"DSR Id\(\d+\) does not match")),
    ("queue_or_ut_id", re.compile(r"initialization for this queue has already been set|"
                                  r"expected 'input_queue' expression|expected 'output_queue' expression|"
                                  r"task ID '\d+' bound to more than one task|"
                                  r"expected (?:task|color) ID in the range|maximum (?:input|output) queue is \d+|"
                                  r"config for this color has already been set|"
                                  r"function parameter type is not valid at runtime: '(?:input|output)_queue'|"
                                  r"(?:input|output) queue \d+ .*(?:already|conflict)|ut_id|microthread id")),
    ("contract_entrypoint", re.compile(r"name '[^']*' was not declared during layout evaluation|"
                                       r"no symbol was exported with name|"
                                       r"export(?:ed)? symbol .*not (?:found|declared)|@export_symbol")),
    ("task_binding", re.compile(r"non-task provided as the task argument of bind_(?:local|data|control)_task|"
                                r"bind_(?:local|data|control)_task")),
    ("undeclared_identifier", re.compile(r"use of undeclared identifier")),
    ("comptime_misuse", re.compile(r"comptime evaluation of this expression is only valid|"
                                   r"only comptime-known variables can be used|"
                                   r"exceeded the maximum of \d+ inlined iterations|"
                                   r"comptime pointer cast is not supported|"
                                   r"builtin is only valid during layout evaluation|"
                                   r"expected comptime-known|while-loops not supported|"
                                   r"not comptime-known|comptime")),
    ("dsd_construction", re.compile(r"invalid use of non-loop variable in affine expression|"
                                    r"expression does not yield the address of a variable|"
                                    r"tensor access expression requires|too many dimensions for memory DSD|"
                                    r"base address of a tensor expression must be an array|"
                                    r"DSR operand of type '[^']*' is not allowed|only DSD/DSR operands are allowed|"
                                    r"mem[14]d_dsd|fabin_dsd|fabout_dsd|affine expression")),
    ("call_arity", re.compile(r"builtin requires \d+ argument\(s\), \d+ provided|"
                              r"function expects \d+ arguments?, \d+ provided")),
    ("type_mismatch", re.compile(r"operand types do not match expectations|expected type '[^']*', got|"
                                 r"cannot cast from|expected numeric expression|expected fixed-width integer|"
                                 r"struct has no field named|expected [^\n]* expression, got|"
                                 r"expected integer expression|invalid comparison operation for type|"
                                 r"expected unsigned value for shift amount")),
    ("link_oom", re.compile(r"ran out of PE memory|ld\.lld:.*(?:memory|overflow)|does not fit")),
]

RUN_TABLE: List[Tuple[str, re.Pattern]] = [
    ("runtime_stall", re.compile(r"received length \(\d+ bytes\) is not expected|kernel stall")),
    ("runtime_fatal_ut", re.compile(r"trying to term ut_instr|trying to save into ut_instr|"
                                    r"Attempt to remap input queue|ut_instr\[")),
    ("runtime_fatal_hcf", re.compile(r"hcf \(halt and catch fire\)|instruction post check failed|"
                                     r"Stopping due to fatal error")),
    ("runtime_timeout", re.compile(r"timed out|TimeoutExpired|Timeout after|exceeded .*timeout", re.I)),
    ("verify_mismatch", re.compile(r"AssertionError|Not equal to tolerance|Mismatched elements|"
                                   r"does not reconstruct|residual is >|max abs err|verification failed|"
                                   r"\|[^|\n]*-[^|\n]*\| = |VERIFY FAIL|is not lower-triangular", re.I)),
    ("missing_export_symbol", re.compile(r"memcpy_(?:h2d|d2h)\(\): incompatible function arguments|"
                                         r"get_id\(.*\).*None|KeyError: '[A-Za-z_]\w*'|symbol .*not found")),
    ("runtime_python_error", re.compile(r"^\w+(?:Error|Exception)\b.*$", re.M)),
    ("runtime_python_error", re.compile(r"Traceback \(most recent call last\)")),
]

ENV_RE = re.compile(r"pthread_create failed|Resource temporarily unavailable|cslc-driver: .*Program\.inc|"
                    r"Local abort before MPI_INIT|ModuleNotFoundError|No module named|squashfuse|"
                    r"FATAL:\s+container|could not open image|singularity.*(?:error|failed)|apptainer.*(?:error|failed)|"
                    r"Disk quota exceeded|No space left on device|OSError: \[Errno", re.I)
CRASH_RCS = {"139", "134", "135", "132", "136", "-11", "-6", "-9", "137"}
FOLLOW_ON = re.compile(r"requested here|imported here|^\s*note:|referenced here|instantiated here", re.I)


def _text(step: Dict[str, Any]) -> str:
    return ANSI.sub("", (step.get("stderr") or "") + "\n" + (step.get("stdout") or ""))


def _first_error_line(text: str) -> str:
    for ln in text.splitlines():
        if NOISE.search(ln):
            continue
        if re.search(r"\berror\b|Error|ERROR|panic|Traceback|Assertion|what\(\):|fatal", ln):
            return ln.strip()
    return ""


def classify_text(text: str, step: str, returncode: Any = None) -> Tuple[str, str]:
    """Classify a transcript step's combined stderr+stdout. Returns (family, evidence)."""
    text = "\n".join(ln for ln in text.splitlines() if not NOISE.search(ln))
    if ENV_RE.search(text):
        m = ENV_RE.search(text)
        return "sdk_env_blocked", text[max(0, m.start() - 40): m.end() + 60].strip()
    table = COMPILE_TABLE if step == "compile" else RUN_TABLE
    # Primary diagnostics first: cslc prints follow-on notes ("requested here",
    # "imported here") after the real error, and a whole-text search would let an
    # earlier table entry win on such a secondary line.
    primary = [ln for ln in text.splitlines()
               if re.search(r"\berror\b|Error|ERROR|panic|Assertion|what\(\):|fatal", ln)
               and not FOLLOW_ON.search(ln)]
    for ln in primary[:1]:
        for fam, rx in table:
            if rx.search(ln):
                return fam, ln.strip()[:240]
    for fam, rx in table:
        m = rx.search(text)
        if m:
            line_start = text.rfind("\n", 0, m.start()) + 1
            line_end = text.find("\n", m.end())
            return fam, text[line_start: line_end if line_end > 0 else None].strip()[:240]
    if step == "compile":
        if re.search(r"\berror\b", text):
            return "other_compile_error", _first_error_line(text)[:240]
        return "other_compile_error", (_first_error_line(text) or f"rc={returncode}")[:240]
    if str(returncode) in CRASH_RCS or "terminate called" in text or "malloc.c" in text:
        return "runtime_crash", (_first_error_line(text) or f"rc={returncode}")[:240]
    return "other_runtime_error", (_first_error_line(text) or f"rc={returncode}")[:240]


def classify_attempt(attempt: Dict[str, Any]) -> Dict[str, Any]:
    """Map one attempt record to {family, step, evidence}."""
    status = attempt.get("status")
    marker = bool(attempt.get("success_marker"))
    reason = str(attempt.get("failure_reason") or "")
    if status == "pass" and marker:
        return {"family": "pass", "step": None, "evidence": ""}
    if status == "blocked" or attempt.get("blocked_reason") or reason.startswith("blocked"):
        return {"family": "sdk_env_blocked", "step": None, "evidence": reason or str(attempt.get("blocked_reason"))}
    if attempt.get("llm_error") or reason.startswith("llm") or status == "llm_error":
        return {"family": "llm_error", "step": None, "evidence": reason[:240]}
    if reason.startswith("no_csl") or reason == "no_code" or attempt.get("no_csl_block"):
        return {"family": "no_csl_block", "step": None, "evidence": reason[:240]}
    if reason.startswith("contract") or attempt.get("contract_violation"):
        return {"family": "contract_violation", "step": None,
                "evidence": (reason or str(attempt.get("contract_violation")))[:240]}
    if reason.startswith("heldout_seed_mismatch"):
        return {"family": "heldout_mismatch", "step": "heldout", "evidence": reason[:120]}
    # evaluate_heldout's schema is {"passed", "failing_seed", "per_seed", "reason"};
    # there is no "status" key. The harness also rewrites failure_reason above.
    he = attempt.get("heldout_eval")
    if isinstance(he, dict) and he.get("passed") is False:
        return {"family": "heldout_mismatch", "step": "heldout", "evidence": str(he.get("reason") or "")[:120]}
    if reason.startswith("implausible_cycles"):
        return {"family": "implausible_cycles", "step": "measure", "evidence": reason[:120]}
    if reason == "missing_success_marker":
        return {"family": "missing_success_marker", "step": "run", "evidence": reason}
    # transcript-driven: first failing step
    for step in attempt.get("transcript") or []:
        if step.get("status") == "pass":
            continue
        fam, ev = classify_text(_text(step), str(step.get("step") or ""), step.get("returncode"))
        return {"family": fam, "step": step.get("step"), "evidence": ev}
    if status == "pass" and not marker and not reason:
        steps = [str(t.get("step")) for t in attempt.get("transcript") or []]
        if steps and "run" not in steps and attempt.get("cycles_send") is None:
            return {"family": "compile_only_check", "step": "compile",
                    "evidence": "dry check: compile-only record, no run step"}
        return {"family": "pass_unverified", "step": None, "evidence": "legacy record without success marker"}
    if reason:
        fam, ev = classify_text(reason, "run")
        return {"family": fam if fam != "other_runtime_error" else "unknown", "step": None, "evidence": reason[:240]}
    return {"family": "unknown", "step": None, "evidence": f"status={status}"}


def classify_run(run_dir: Path) -> Dict[str, Any]:
    fr = run_dir / "final_result.json"
    attempts: List[Dict[str, Any]] = []
    try:
        attempts = json.loads(fr.read_text()).get("attempts") or []
    except (OSError, ValueError):
        pass
    per = [dict(idx=i + 1, **classify_attempt(a)) for i, a in enumerate(attempts)]
    fams = Counter(p["family"] for p in per)
    final = per[-1]["family"] if per else "no_attempts"
    return {"schema": "error_families/1", "run_dir": str(run_dir), "n_attempts": len(per),
            "final_family": final, "counts": dict(fams), "attempts": per}


def iter_runs(root: Path) -> Iterable[Path]:
    for fr in sorted(root.rglob("final_result.json")):
        yield fr.parent


def _sweep_of(run_dir: Path, root: Path) -> str:
    try:
        rel = run_dir.relative_to(root)
        return rel.parts[0] if rel.parts else root.name
    except ValueError:
        return run_dir.parent.name


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--run", help="one kernel output dir: write error_families.json next to final_result.json")
    ap.add_argument("--corpus", help="results root to tally (recursive)")
    ap.add_argument("--out", help="CSV path for --corpus (per sweep x family counts)")
    ap.add_argument("--mine", type=int, default=0, metavar="N",
                    help="print the N most common normalized evidence lines of unknown/other families")
    ap.add_argument("--by-kernel", action="store_true", help="also print the per-kernel final-family table")
    a = ap.parse_args()
    if a.run:
        rd = Path(a.run)
        res = classify_run(rd)
        (rd / "error_families.json").write_text(json.dumps(res, indent=2))
        print(json.dumps({k: v for k, v in res.items() if k != "attempts"}, indent=2))
        return 0
    if not a.corpus:
        ap.error("--run or --corpus required")
    root = Path(a.corpus)
    by_sweep: Dict[str, Counter] = defaultdict(Counter)
    final_by_kernel: Dict[str, Counter] = defaultdict(Counter)
    unmatched: Counter = Counter()
    total = Counter()
    n_runs = 0
    for rd in iter_runs(root):
        n_runs += 1
        res = classify_run(rd)
        sw = _sweep_of(rd, root)
        for p in res["attempts"]:
            by_sweep[sw][p["family"]] += 1
            total[p["family"]] += 1
            if p["family"] in ("unknown", "other_compile_error", "other_runtime_error", "runtime_python_error"):
                ev = re.sub(r"\b\d+\b", "N", re.sub(r"/[^\s:]+/", "<path>/", p["evidence"]))
                unmatched[(p["family"], ev[:150])] += 1
        final_by_kernel[rd.name][res["final_family"]] += 1
    fams = sorted(total.keys(), key=lambda f: -total[f])
    print(f"runs {n_runs}, attempts {sum(total.values())}")
    for f in fams:
        print(f"  {f:24s} {total[f]:7d}  {100 * total[f] / max(1, sum(total.values())):5.1f}%")
    if a.out:
        out = Path(a.out); out.parent.mkdir(parents=True, exist_ok=True)
        with open(out, "w", newline="") as fh:
            w = csv.writer(fh)
            w.writerow(["sweep", "attempts"] + fams)
            for sw in sorted(by_sweep):
                row = by_sweep[sw]
                w.writerow([sw, sum(row.values())] + [row.get(f, 0) for f in fams])
            w.writerow(["ALL", sum(total.values())] + [total[f] for f in fams])
        print(f"wrote {out}")
    if a.by_kernel:
        print("\nfinal family per kernel (runs):")
        for k in sorted(final_by_kernel):
            print(f"  {k:28s} " + ", ".join(f"{f}={c}" for f, c in final_by_kernel[k].most_common()))
    if a.mine:
        print(f"\ntop {a.mine} evidence lines in the residual families (audit the regex table):")
        for (fam, ev), c in unmatched.most_common(a.mine):
            print(f"  {c:6d} [{fam}] {ev}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
