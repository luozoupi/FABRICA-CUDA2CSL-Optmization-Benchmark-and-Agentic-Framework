#!/usr/bin/env python3
"""
Bundle-aware CSL benchmark runner for CUDA -> CSL translation outputs.
"""

from __future__ import annotations

import argparse
import difflib
import json
import os
import re
import shlex
import shutil
from pathlib import Path
from typing import Dict, List, Optional, Tuple

from workflow_common import (
    build_sdk_env,
    classify_blocked_reason,
    ensure_directory,
    expand_path,
    load_shell_setup,
    run_subprocess,
    save_json,
    timestamped_output_dir,
)
from workflow_common import default_sdk_root, sdk_sif_path  # noqa: E402


TIMEOUT_LIMIT = 300
REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_OUTPUT = str(Path(__file__).resolve().parent / "results" / "benchmark_csl")


# ---------------------------------------------------------------------------
# Singularity gate (used by explore_csl.py for parallel candidates)
# ---------------------------------------------------------------------------
#
# All CSL kernels in this repo invoke cslc + cs_python via ~/bin/singularity
# (the SSH shim to cer-usn-01). The shim itself is mostly stateless, but
# stress-testing it with N concurrent workers reliably wedges either the
# remote node or the local container runtime. We can't fix the shim from
# here; the cheap mitigation is a file-lock that serialises the actual
# script execution while keeping the rest of the work (staging, parsing,
# cycle extraction) parallel.
#
# Off by default to avoid behaviour change for existing callers. When
# explore_csl.py spawns its worker pool it sets XKERNEL_SINGULARITY_GATE=1
# in the child env before run_staged_bundle. Other callers see no change.
#
# Implementation: optional filelock dep, no-op when missing. The lock file
# lives in /tmp so it never crosses NFS (NFS file locks are notoriously
# unreliable in container settings).

import contextlib  # noqa: E402  (intentional after constants)

_SINGULARITY_LOCK_PATH = "/tmp/xkernel_singularity.lock"


@contextlib.contextmanager
def _singularity_gate(enabled: Optional[bool] = None,
                      timeout: Optional[float] = None):
    """Acquire a process-wide lock around the singularity invocation.

    When ``enabled`` is None we read XKERNEL_SINGULARITY_GATE (default off).
    When the ``filelock`` package is not installed, this is a no-op — we
    accept the contention risk rather than hard-failing the workflow.

    Timeout defaults: when ``timeout`` is None, read
    XKERNEL_SINGULARITY_TIMEOUT (default 1800.0 = 30 min). The original
    600s default proved too tight for 7-way parallel batches — each
    cslc+run cycle takes 30-60s and a candidate at the back of a 6-deep
    queue across multiple rounds can easily wait >600s. 1800s tolerates
    a 30-process queue worst case.
    """
    if timeout is None:
        timeout = float(os.environ.get("XKERNEL_SINGULARITY_TIMEOUT", "1800"))
    if enabled is None:
        enabled = os.environ.get("XKERNEL_SINGULARITY_GATE", "0") == "1"
    if not enabled:
        yield
        return
    try:
        from filelock import FileLock, Timeout  # type: ignore
    except ImportError:
        # No fcntl-based fallback — file-lock primitives differ across
        # platforms enough that a bug here would silently degrade. Pip
        # install filelock when running explore_csl at concurrency > 1.
        yield
        return
    lock = FileLock(_SINGULARITY_LOCK_PATH, timeout=timeout)
    try:
        with lock:
            yield
    except Timeout:
        # Surface as a regular failure instead of hanging forever; the
        # explore orchestrator records the candidate as failed_with_blocked.
        raise RuntimeError(
            f"singularity gate timeout after {timeout}s — another exploration "
            f"candidate is holding the lock at {_SINGULARITY_LOCK_PATH}"
        )


def parse_command_script(script_path: str) -> List[str]:
    commands: List[str] = []
    current = ""
    with open(script_path, "r", encoding="utf-8") as fh:
        for raw_line in fh:
            stripped = raw_line.strip()
            if not stripped or stripped.startswith("#") or stripped == "set -e":
                continue
            line = raw_line.rstrip()
            current = f"{current} {line.lstrip()}".strip() if current else line.strip()
            if current.endswith("\\"):
                current = current[:-1].rstrip()
                continue
            commands.append(current)
            current = ""
    if current:
        commands.append(current)
    return commands


def select_compile_only_commands(commands: List[str]) -> List[str]:
    """Commands to execute for a compile-only (dry) check.

    Keep every command up to and including the last `cslc` step and drop the
    `cs_python` run steps (and anything after them). Non-compile commands that
    precede the compiler -- shell variable assignments such as `P=4` that the
    cslc line expands with `${P}`, exports, `cd` -- must stay: dropping them
    used to leave the runner with an unbound variable under `set -u`, which
    killed it before the first step marker (rc=1 in ~20 ms, no transcript,
    reported as `missing_transcript`; seen on the attention tasks 2026-09-08).
    """
    kinds = [classify_command_step(c) for c in commands]
    if "compile" not in kinds:
        return [c for c, k in zip(commands, kinds) if k != "run"]
    last_compile = max(i for i, k in enumerate(kinds) if k == "compile")
    return [c for c, k in list(zip(commands, kinds))[: last_compile + 1] if k != "run"]


def classify_command_step(command: str) -> str:
    lowered = command.lower()
    if "cslc" in lowered:
        return "compile"
    if "cs_python" in lowered:
        return "run"
    return "other"


def check_csl_syntax(csl_code: str) -> Dict[str, object]:
    warnings: List[str] = []
    if "@import_module" not in csl_code and "comptime" not in csl_code:
        warnings.append("Missing @import_module or comptime.")
    if "fn " not in csl_code and "task " not in csl_code:
        warnings.append("No function or task definitions found.")
    for pattern in ["__global__", "__device__", "__shared__", "cudaMalloc", "blockIdx", "threadIdx", "<<<"]:
        if pattern in csl_code:
            warnings.append(f"CUDA construct '{pattern}' found in CSL code.")
    has_csl_patterns = any(
        token in csl_code for token in [
            "@import_module", "@set_local_task_id", "comptime",
            "@get_dsd", "mem1d_dsd", "@fmacs", "@fadds"
        ]
    )
    return {
        "syntax_valid": has_csl_patterns and not any("CUDA construct" in warning for warning in warnings),
        "syntax_warnings": warnings,
    }


def code_similarity(code_a: str, code_b: str) -> float:
    return difflib.SequenceMatcher(None, code_a, code_b).ratio()


def stage_reference_bundle(reference_dir: str,
                           work_dir: str,
                           translated_path: str,
                           target_relpath: str) -> Dict[str, str]:
    staged_bundle = os.path.join(work_dir, "bundle")
    if os.path.exists(staged_bundle):
        shutil.rmtree(staged_bundle)
    shutil.copytree(reference_dir, staged_bundle)
    staged_target = os.path.join(staged_bundle, target_relpath)
    ensure_directory(os.path.dirname(staged_target))
    shutil.copyfile(translated_path, staged_target)
    return {
        "staged_bundle": staged_bundle,
        "staged_target": staged_target,
    }


def infer_commands_script(reference_dir: str, arch: str, requested: Optional[str] = None) -> str:
    if requested:
        candidate = os.path.join(reference_dir, requested)
        if os.path.exists(candidate):
            return requested
        raise FileNotFoundError(f"Requested command script '{requested}' does not exist in {reference_dir}.")
    preferred = f"commands_{arch}.sh"
    if os.path.exists(os.path.join(reference_dir, preferred)):
        return preferred
    if os.path.exists(os.path.join(reference_dir, "commands.sh")):
        return "commands.sh"
    raise FileNotFoundError(f"No command script found in {reference_dir}.")


def write_shell_setup_file(staged_bundle: str,
                           shell_setup: Optional[str]) -> Optional[str]:
    if not shell_setup or not shell_setup.strip():
        return None
    setup_path = os.path.join(staged_bundle, ".xkernel_shell_setup.sh")
    with open(setup_path, "w", encoding="utf-8") as fh:
        fh.write("#!/usr/bin/env bash\n")
        fh.write(shell_setup.strip())
        fh.write("\n")
    os.chmod(setup_path, 0o755)
    return setup_path


def write_instrumented_runner(staged_bundle: str,
                              commands: List[str],
                              shell_setup_path: Optional[str],
                              num_runs: int = 1) -> str:
    """Write an instrumented bash runner that emits per-step status markers.

    When num_runs > 1, "run" steps (cs_python invocations) are executed N
    times sequentially; "compile" and "other" steps run once. This is the
    variance-reduction knob: compile is deterministic, but the on-WSE
    cycles_send measurement has run-to-run noise (the progress doc records
    7pt-Stencil producing 1233 / 1076 / 2129 cycles across three identical
    W2 runs). Each repeated run step gets a distinct idx in the transcript
    (e.g. 2.1, 2.2, ...) so downstream parsers can aggregate per-run cycles
    without losing the per-attempt structure."""
    runner_path = os.path.join(staged_bundle, ".xkernel_run_commands.sh")
    num_runs = max(1, int(num_runs))
    lines = [
        "#!/usr/bin/env bash",
        "set -u",
        f"cd {shlex.quote(staged_bundle)}",
    ]
    if shell_setup_path:
        lines.extend([
            f"XKERNEL_SHELL_SETUP_FILE={shlex.quote(shell_setup_path)}",
            'if [ -f "$XKERNEL_SHELL_SETUP_FILE" ]; then',
            '  # shellcheck disable=SC1090',
            '  source "$XKERNEL_SHELL_SETUP_FILE"',
            "fi",
        ])
    lines.extend([
        "now_ms() {",
        '  local value=$(date +%s%3N)',
        '  case "$value" in',
        "    *[!0-9]*|'') python3 -c 'import time; print(time.time_ns() // 1000000)' ;;",
        '    *) printf "%s\\n" "$value" ;;',
        "  esac",
        "}",
        "run_step() {",
        '  local idx=\"$1\"',
        '  local step=\"$2\"',
        '  local command=\"$3\"',
        "  local stdout_file stderr_file start_ms end_ms elapsed_ms rc",
        "  stdout_file=$(mktemp)",
        "  stderr_file=$(mktemp)",
        "  start_ms=$(now_ms)",
        "  set +u  # a command's own unbound variable must fail the STEP, not kill the runner",
        '  if eval "$command" >"$stdout_file" 2>"$stderr_file"; then',
        "    rc=0",
        "  else",
        "    rc=$?",
        "  fi",
        "  set -u",
        "  end_ms=$(now_ms)",
        "  elapsed_ms=$((end_ms - start_ms))",
        "  printf '__XKERNEL_STEP_BEGIN__%s\\t%s\\n' \"$idx\" \"$step\"",
        "  printf '__XKERNEL_COMMAND_BEGIN__%s\\n%s\\n__XKERNEL_COMMAND_END__%s\\n' \"$idx\" \"$command\" \"$idx\"",
        "  printf '__XKERNEL_STDOUT_BEGIN__%s\\n' \"$idx\"",
        "  cat \"$stdout_file\"",
        "  printf '\\n__XKERNEL_STDOUT_END__%s\\n' \"$idx\"",
        "  printf '__XKERNEL_STDERR_BEGIN__%s\\n' \"$idx\"",
        "  cat \"$stderr_file\"",
        "  printf '\\n__XKERNEL_STDERR_END__%s\\n' \"$idx\"",
        "  printf '__XKERNEL_STEP_END__%s\\t%s\\t%s\\n' \"$idx\" \"$rc\" \"$elapsed_ms\"",
        "  rm -f \"$stdout_file\" \"$stderr_file\"",
        '  return "$rc"',
        "}",
    ])
    for idx, command in enumerate(commands, start=1):
        step = classify_command_step(command)
        if step == "run" and num_runs > 1:
            # Repeat run steps N times. Distinct idx per repeat ("idx.r"
            # where r=1..N) so transcript parsing can aggregate per-run.
            for r in range(1, num_runs + 1):
                repeat_idx = f"{idx}.{r}"
                lines.append(
                    f"run_step {shlex.quote(repeat_idx)} {shlex.quote(step)} "
                    f"{shlex.quote(command)} || exit $?"
                )
        else:
            lines.append(f"run_step {idx} {shlex.quote(step)} {shlex.quote(command)} || exit $?")
    with open(runner_path, "w", encoding="utf-8") as fh:
        fh.write("\n".join(lines) + "\n")
    os.chmod(runner_path, 0o755)
    return runner_path


# Fix #2 (audit task #34): cslc warnings explode across PE coordinate
# expansions — the Mandelbrot run had 168 'unused entry in module
# instantiation' lines that collapsed to 14 unique source-line offenders,
# each duplicated ~12x. Deduping BEFORE the formatter clips lets all 14
# unique warnings fit inside the prompt budget. The dedupe key is the
# 'source.csl:LINE:COL' prefix on each block; duplicates collapse with an
# 'x{N}' multiplier so the LLM still sees that the warning was hot.
_WARN_LINE_RE = __import__("re").compile(r"^([A-Za-z0-9_./\-]+\.csl:\d+:\d+:)\s*(.*)$")


def _dedupe_cslc_warnings(stderr: str) -> str:
    """Collapse repeated cslc warning blocks (same file:line:col prefix) to
    a single occurrence with a multiplier. Preserves the stderr's overall
    ordering. No-op if stderr has < 6 lines (cheap kernels don't need it).

    Splits on a forward-look at lines starting with 'foo.csl:N:M:' which is
    the cslc warning/error prefix. Each block is keyed by (file:line:col,
    first-line-message-prefix) so different warnings at the same location
    are kept distinct.
    """
    if not stderr or stderr.count("\n") < 6:
        return stderr
    import re as _re
    # Split into blocks: a block starts at a 'foo.csl:N:M:' line and runs
    # until the next such line (or end of stderr).
    blocks: List[Tuple[Optional[str], str]] = []
    cur_key: Optional[str] = None
    cur_lines: List[str] = []
    for ln in stderr.split("\n"):
        m = _WARN_LINE_RE.match(ln)
        if m:
            if cur_lines:
                blocks.append((cur_key, "\n".join(cur_lines)))
            cur_key = m.group(1) + "|" + (m.group(2) or "").split(":", 1)[-1].strip()[:60]
            cur_lines = [ln]
        else:
            cur_lines.append(ln)
    if cur_lines:
        blocks.append((cur_key, "\n".join(cur_lines)))

    # Walk blocks; if we see the same key again, increment multiplier on
    # the first occurrence and skip the duplicate.
    out_blocks: List[str] = []
    first_idx: Dict[str, int] = {}
    multiplier: Dict[str, int] = {}
    for key, body in blocks:
        if key is None:
            out_blocks.append(body)
            continue
        if key in first_idx:
            multiplier[key] = multiplier.get(key, 1) + 1
        else:
            first_idx[key] = len(out_blocks)
            out_blocks.append(body)
    # Annotate first occurrences with multipliers.
    for key, n in multiplier.items():
        idx = first_idx[key]
        suffix = f"  [×{n} occurrences elided]"
        out_blocks[idx] = out_blocks[idx] + suffix
    return "\n".join(out_blocks)


def parse_instrumented_stdout(stdout: str) -> List[Dict[str, object]]:
    # idx can now be either a pure integer ("3") or a repeat-tagged form
    # ("3.1", "3.2") emitted by num_runs>1 in write_instrumented_runner.
    # The regex must escape the literal dot in the backreference matches —
    # which works automatically since the backreference matches the literal
    # text captured by the first group.
    pattern = re.compile(
        r"__XKERNEL_STEP_BEGIN__([\d.]+)\t([^\n]+)\n"
        r"__XKERNEL_COMMAND_BEGIN__\1\n(.*?)\n__XKERNEL_COMMAND_END__\1\n"
        r"__XKERNEL_STDOUT_BEGIN__\1\n(.*?)\n__XKERNEL_STDOUT_END__\1\n"
        r"__XKERNEL_STDERR_BEGIN__\1\n(.*?)\n__XKERNEL_STDERR_END__\1\n"
        r"__XKERNEL_STEP_END__\1\t(-?\d+)\t(\d+)",
        re.DOTALL,
    )
    transcript: List[Dict[str, object]] = []
    for match in pattern.finditer(stdout):
        command = match.group(3)
        step_stdout = match.group(4).rstrip("\n")
        step_stderr = match.group(5).rstrip("\n")
        # Fix #2: dedupe before storing so on-disk JSON snapshots also
        # benefit (smaller files + same dedupe applied to debugger view).
        step_stderr = _dedupe_cslc_warnings(step_stderr)
        returncode = int(match.group(6))
        elapsed_ms = float(match.group(7))
        blocked_reason = classify_blocked_reason(step_stdout, step_stderr)
        status = "pass"
        if returncode != 0:
            status = "blocked" if blocked_reason else "fail"
        transcript.append({
            "step": match.group(2),
            "command": command,
            "status": status,
            "returncode": returncode,
            "elapsed_ms": round(elapsed_ms, 3),
            "blocked_reason": blocked_reason,
            "stdout": step_stdout,
            "stderr": step_stderr,
            "idx": match.group(1),  # "3" or "3.2" — for num_runs>1 aggregation
        })
    return transcript


def _stage_benchmark_libs(staged_bundle: str) -> Optional[str]:
    """
    Copy benchmark-libs next to the staged bundle so that relative imports like
    '../../benchmark-libs/...' resolve correctly from staged_bundle/src/.
    Returns the work_dir (parent of staged_bundle) if benchmark-libs was staged.

    Path maths:
      staged_bundle = work_dir/bundle/
      from staged_bundle/src/ : ../../benchmark-libs/ = work_dir/benchmark-libs/
    """
    benchmark_libs_src = REPO_ROOT / "kernels" / "benchmark-libs"
    if not benchmark_libs_src.exists():
        return None
    work_dir = os.path.dirname(staged_bundle)
    dst = os.path.join(work_dir, "benchmark-libs")
    if not os.path.exists(dst):
        shutil.copytree(str(benchmark_libs_src), dst)
    return work_dir


def run_staged_bundle(staged_bundle: str,
                     commands_script: str,
                     sdk_root: str,
                     shell_setup: Optional[str] = None,
                     timeout: int = TIMEOUT_LIMIT,
                     num_runs: int = 1,
                     compile_only: bool = False) -> Dict[str, object]:
    env = build_sdk_env(sdk_root)
    # Stage benchmark-libs alongside the bundle so relative imports (../../benchmark-libs/)
    # resolve correctly. Also bind work_dir into the container via CSL_IMPORT_PATH.
    work_dir = _stage_benchmark_libs(staged_bundle)
    if work_dir:
        existing = env.get("CSL_IMPORT_PATH", "")
        env["CSL_IMPORT_PATH"] = f"{work_dir}:{existing}" if existing else work_dir
    script_path = os.path.join(staged_bundle, commands_script)
    commands = parse_command_script(script_path)
    if compile_only:
        commands = select_compile_only_commands(commands)
    shell_setup_path = write_shell_setup_file(staged_bundle, shell_setup)
    runner_path = write_instrumented_runner(
        staged_bundle=staged_bundle,
        commands=commands,
        shell_setup_path=shell_setup_path,
        num_runs=num_runs,
    )
    with _singularity_gate():
        runner_result = run_subprocess(
            f"bash {shlex.quote(runner_path)}",
            cwd=staged_bundle,
            env=env,
            timeout=timeout,
        )
    transcript = parse_instrumented_stdout(runner_result.stdout)
    compile_time_ms = round(
        sum(float(entry["elapsed_ms"]) for entry in transcript if entry["step"] == "compile"),
        3,
    )
    run_time_ms = round(
        sum(float(entry["elapsed_ms"]) for entry in transcript if entry["step"] == "run"),
        3,
    )
    overall_status = "pass"
    failure_reason = None
    success_marker = False

    for entry in transcript:
        combined = "\n".join([str(entry["stdout"]), str(entry["stderr"])]).upper()
        if entry["step"] == "run":
            success_marker = success_marker or "SUCCESS" in combined
        if entry["status"] != "pass":
            overall_status = str(entry["status"])
            failure_reason = str(entry.get("blocked_reason") or "command_failed")
            break

    if not transcript:
        overall_status = "blocked" if runner_result.blocked_reason else "fail"
        failure_reason = runner_result.blocked_reason or "missing_transcript"
        stderr_text = runner_result.stderr or ""
        if not stderr_text.strip() and not (runner_result.stdout or "").strip():
            stderr_text = ("[harness] the instrumented runner exited before emitting any step marker "
                           f"(rc={runner_result.returncode}, {runner_result.elapsed_ms} ms): a shell error "
                           "before the first command (unbound variable, unreadable script, bad shell setup). "
                           f"Commands parsed: {len(commands)}. This is an environment/harness failure, not a "
                           "property of the kernel code.")
        transcript = [{
            "step": "script",
            "command": f"bash {commands_script}",
            "status": overall_status,
            "returncode": runner_result.returncode,
            "elapsed_ms": runner_result.elapsed_ms,
            "blocked_reason": runner_result.blocked_reason,
            "stdout": runner_result.stdout,
            "stderr": stderr_text,
        }]

    if overall_status == "pass" and not success_marker and not compile_only:
        overall_status = "fail"
        failure_reason = "missing_success_marker"

    cycles_send, time_send_us, cycles_runs, time_runs, per_fn_cycles = _extract_kernel_cycles(transcript)
    cycles_min = min(cycles_runs) if cycles_runs else None
    cycles_max = max(cycles_runs) if cycles_runs else None

    # ANTI-GAMING: dead-timer / empty-window guard. A kernel that prints SUCCESS
    # (correctness ok) but reports an implausibly tiny cycles_send has almost
    # certainly broken its own measurement — e.g. it never called
    # timestamp.enable_tsc() (so get_timestamp() reads a frozen counter and
    # time_end-time_start collapses to single digits), or it emptied the
    # f_tic..f_toc window. No real cross-PE WSE kernel completes a timed compute
    # in fewer than ~_MIN_PLAUSIBLE_CYCLES cycles (RPC + sync + memcpy plumbing
    # alone exceeds that; the smallest real reference here is >1000). Without
    # this, such a kernel would be accepted as a record-smashing "win" (observed:
    # 7pt-Stencil agent kernel reported cycles_send=8 vs the 17134 reference).
    # See check_timing_integrity.check_compute_csl for the static counterpart.
    if (overall_status == "pass" and isinstance(cycles_send, int)
            and 0 <= cycles_send < _MIN_PLAUSIBLE_CYCLES):
        overall_status = "fail"
        failure_reason = (
            f"implausible_cycles_send={cycles_send} (<{_MIN_PLAUSIBLE_CYCLES}): "
            f"dead timer or empty timed window — likely missing enable_tsc() or "
            f"compute outside f_tic..f_toc. Measurement rejected (anti-gaming).")

    return {
        "status": overall_status,
        "failure_reason": failure_reason,
        "compile_time_ms": compile_time_ms,
        "run_time_ms": run_time_ms,
        # cycles_send is the median across `num_runs` repeated cs_python
        # invocations (single value when num_runs=1, matching old behavior).
        # Use this as the optimizer's accept signal — robust to ~20-30%
        # simulator noise. The per-run list and min/max are available for
        # variance characterization.
        "cycles_send": cycles_send,
        "time_send_us": time_send_us,
        "cycles_send_runs": cycles_runs,
        "cycles_send_min": cycles_min,
        "cycles_send_max": cycles_max,
        "time_send_us_runs": time_runs,
        "num_runs": max(1, int(num_runs)),
        "per_fn_cycles": per_fn_cycles if per_fn_cycles else None,
        "success_marker": success_marker,
        "transcript": transcript,
        "script_command": f"bash {commands_script}",
        "shell_setup_applied": bool(shell_setup and shell_setup.strip()),
        "script_elapsed_ms": runner_result.elapsed_ms,
    }


def _run_step_command(staged_bundle: str,
                      command: str,
                      sdk_root: str,
                      extra_env: Optional[Dict[str, str]] = None,
                      shell_setup: Optional[str] = None,
                      timeout: int = TIMEOUT_LIMIT) -> Dict[str, object]:
    """Run a SINGLE already-parsed command line in the staged bundle, returning a
    small status dict {ok, returncode, stdout, stderr, success_marker}.

    Used by the held-out input-split gate to re-invoke ONLY the `cs_python run.py`
    step (no recompile) with a different XKERNEL_EVAL_SEED. Mirrors run_staged_bundle's
    env/import-path/singularity-gate plumbing so the re-run is identical except for the
    injected seed env var.
    """
    env = build_sdk_env(sdk_root)
    work_dir = _stage_benchmark_libs(staged_bundle)
    if work_dir:
        existing = env.get("CSL_IMPORT_PATH", "")
        env["CSL_IMPORT_PATH"] = f"{work_dir}:{existing}" if existing else work_dir
    if extra_env:
        env.update({str(k): str(v) for k, v in extra_env.items()})
    with _singularity_gate():
        res = run_subprocess(
            command,
            cwd=staged_bundle,
            env=env,
            shell_setup=shell_setup,
            timeout=timeout,
        )
    combined = "\n".join([res.stdout or "", res.stderr or ""]).upper()
    return {
        "ok": res.returncode == 0 and "SUCCESS" in combined,
        "returncode": res.returncode,
        "stdout": res.stdout,
        "stderr": res.stderr,
        "success_marker": "SUCCESS" in combined,
    }


def _heldout_eval_for_reference(reference_dir: str) -> Optional[Dict[str, object]]:
    """Read the `eval:` block from the kernel's spec.yaml (one level above the
    reference CSL dir). Returns {train_seed, heldout_seeds, seed_env} or None.

    Self-contained (does not import cuda2csl) to avoid a circular import — the
    spec lives at kernels/<name>/spec.yaml, the reference_dir is kernels/<name>/CSL.
    Mirrors cuda2csl.resolve_eval(); kept in sync by test_no_compute_leak.py.
    """
    spec_path = os.path.join(os.path.dirname(reference_dir.rstrip("/")), "spec.yaml")
    if not os.path.isfile(spec_path):
        alt = os.path.join(reference_dir, "..", "spec.yaml")
        spec_path = alt if os.path.isfile(alt) else spec_path
    if not os.path.isfile(spec_path):
        return None
    try:
        import yaml  # type: ignore
        with open(spec_path, "r", encoding="utf-8") as fh:
            spec = yaml.safe_load(fh)
    except Exception:
        return None
    if not isinstance(spec, dict):
        return None
    ev = spec.get("eval")
    if not isinstance(ev, dict):
        return None
    heldout = ev.get("heldout_seeds") or []
    if not isinstance(heldout, list):
        heldout = []
    return {
        "train_seed": ev.get("train_seed"),
        "heldout_seeds": [int(s) for s in heldout],
        "seed_env": str(ev.get("seed_env") or "XKERNEL_EVAL_SEED"),
    }


def evaluate_heldout(staged_bundle: str,
                     commands_script: str,
                     heldout_seeds: List[int],
                     sdk_root: str,
                     seed_env: str = "XKERNEL_EVAL_SEED",
                     shell_setup: Optional[str] = None,
                     timeout: int = TIMEOUT_LIMIT) -> Dict[str, object]:
    """Input-level train/test split gate (anti-hardcoding).

    After a kernel has PASSED on the train seed, re-run ONLY its `cs_python run.py`
    step once per held-out seed (compiled `out/` is reused — no recompile), each time
    setting `env[seed_env]=seed`. A correct kernel recomputes the reference from the
    drawn input and passes every seed; a kernel that HARDCODED the train-seed answer
    fails the held-out seeds. The held-out seed VALUES are passed only via the
    environment here — they never enter any agent prompt (see docs/SPLIT_AND_LEAKAGE.md).

    Returns {passed: bool, failing_seed: int|None, per_seed: [...], reason: str}.
    No-op pass when heldout_seeds is empty (back-compat).
    """
    result: Dict[str, object] = {
        "passed": True, "failing_seed": None, "per_seed": [], "reason": ""}
    if not heldout_seeds:
        result["reason"] = "no_heldout_seeds (input-split not configured for this kernel)"
        return result
    script_path = os.path.join(staged_bundle, commands_script)
    if not os.path.isfile(script_path):
        result["passed"] = False
        result["reason"] = f"commands_script not found: {commands_script}"
        return result
    # Pick the run step(s) — the cs_python invocation(s) — from the build script.
    run_cmds = [c for c in parse_command_script(script_path)
                if classify_command_step(c) == "run"]
    if not run_cmds:
        result["passed"] = False
        result["reason"] = "no cs_python run step in commands_script"
        return result
    # FOOTGUN GUARD: if a run command passes an explicit `--seed` on the CLI, it
    # OVERRIDES the env-driven held-out seed and the gate would silently re-run the
    # train seed (false assurance). Refuse rather than pretend to have tested
    # held-out inputs. (GEMV's build does this and is deliberately excluded from the
    # input split — see kernels/GEMV/spec.yaml.)
    import re as _re
    for c in run_cmds:
        if _re.search(r"(?:^|\s)--seed(?:[=\s]\S+)?", c):
            result["passed"] = False
            result["reason"] = (
                "heldout_eval_unsupported: a run step hardcodes --seed on the CLI, "
                "which overrides XKERNEL_EVAL_SEED — the held-out gate cannot drive "
                "the input. Remove the CLI --seed (let run.py read the env var) or "
                "exclude this kernel from the input split.")
            return result
    for seed in heldout_seeds:
        seed_ok = True
        step_info = {"seed": seed, "steps": []}
        # cs_python runs `singularity exec -C` (contain), which STRIPS host env
        # vars at the container boundary — a plain XKERNEL_EVAL_SEED never reaches
        # run.py inside the SIF. Singularity/Apptainer only forwards host vars
        # prefixed SINGULARITYENV_/APPTAINERENV_ (it strips the prefix inside). So
        # we set all three forms: the prefixed pair (to cross the boundary) and the
        # plain name (harmless, covers any non-container runner).
        seed_env_map = {
            seed_env: str(seed),
            f"SINGULARITYENV_{seed_env}": str(seed),
            f"APPTAINERENV_{seed_env}": str(seed),
        }
        for cmd in run_cmds:
            step = _run_step_command(
                staged_bundle, cmd, sdk_root,
                extra_env=seed_env_map,
                shell_setup=shell_setup, timeout=timeout)
            step_info["steps"].append(
                {"command": cmd, "ok": step["ok"], "returncode": step["returncode"]})
            if not step["ok"]:
                seed_ok = False
                # keep stderr tail for diagnosis (bounded)
                step_info["stderr_tail"] = (step["stderr"] or "")[-800:]
                break
        result["per_seed"].append(step_info)
        if not seed_ok:
            result["passed"] = False
            result["failing_seed"] = seed
            result["reason"] = (
                f"heldout_seed_mismatch seed={seed}: kernel passes the train seed but "
                f"FAILS this held-out seed — output is hardcoded/under-computed for the "
                f"shown input, not actually computed (input-split anti-gaming gate). "
                f"See docs/SPLIT_AND_LEAKAGE.md (input-level split).")
            return result
    result["reason"] = f"passed all {len(heldout_seeds)} held-out seeds"
    return result


# Match Cerebras's standard kernel-timing prints emitted by reference run.py
# scripts after a tic()/toc() interval:
#   cycles_send = 2129 cycles
#   time_send = 2.5047... us
# These are the **on-WSE kernel cycle count** — the only metric the optimizer
# can target. Wall-clock run_time_ms is dominated by simulator startup +
# memcpy + Python verification and is not useful for cycle reduction.
_CYCLES_SEND_RE = __import__("re").compile(r"cycles_send\s*=\s*(\d+)")
_TIME_SEND_RE   = __import__("re").compile(r"time_send\s*=\s*([\d.]+)")
_PER_FN_CYCLES_RE = __import__("re").compile(r"fn_cycles_(\w+)\s*=\s*(\d+)")

# Anti-gaming floor: the smallest cycles_send a real timed WSE kernel can
# plausibly report. Set well below the smallest real reference in the suite
# (>1000) but far above dead-timer artifacts (single/double digits from a TSC
# that was never enabled, or an empty f_tic..f_toc window). A correct kernel that
# reports fewer than this has broken its own measurement, not set a record.
# Override via XKERNEL_MIN_PLAUSIBLE_CYCLES for kernels with genuinely tiny
# timed regions (none in the current suite).
_MIN_PLAUSIBLE_CYCLES = int(os.environ.get("XKERNEL_MIN_PLAUSIBLE_CYCLES", "100"))


def _extract_kernel_cycles(transcript) -> tuple:
    """Return (cycles_send, time_send_us, cycles_send_runs, time_send_us_runs).

    cycles_send is the MEDIAN across all run steps (not the last). This is
    the primary value the optimizer compares against — median is robust
    against the 20-30% run-to-run noise observed on the simulator (per the
    progress doc: 7pt-Stencil W2 produced 1233 / 1076 / 2129 across three
    identical runs).

    cycles_send_runs is the full list of per-run integers, in transcript
    order. When num_runs=1 the list has length 1 and median == sole value,
    matching the pre-Phase-1a single-sample behavior exactly.

    Backwards compat: if a run.py doesn't print cycles_send (correctness-only
    kernels), all fields are None / empty lists.
    """
    cycles_runs: List[int] = []
    time_runs: List[float] = []
    for entry in transcript:
        if entry.get("step") != "run":
            continue
        out = str(entry.get("stdout", "")) + "\n" + str(entry.get("stderr", ""))
        m_c = _CYCLES_SEND_RE.search(out)
        m_t = _TIME_SEND_RE.search(out)
        if m_c:
            try:
                cycles_runs.append(int(m_c.group(1)))
            except (ValueError, TypeError):
                pass
        if m_t:
            try:
                time_runs.append(float(m_t.group(1)))
            except (ValueError, TypeError):
                pass
    # Per-function cycle breakdown: scan for fn_cycles_<name> = <N> markers.
    per_fn_cycles: Dict[str, int] = {}
    for entry in transcript:
        if entry.get("step") != "run":
            continue
        out = str(entry.get("stdout", "")) + "\n" + str(entry.get("stderr", ""))
        for m_fn in _PER_FN_CYCLES_RE.finditer(out):
            try:
                per_fn_cycles[m_fn.group(1)] = int(m_fn.group(2))
            except (ValueError, TypeError):
                pass

    cycles_send = None
    time_send_us = None
    if cycles_runs:
        import statistics as _stats
        med = _stats.median(cycles_runs)
        cycles_send = int(med) if isinstance(med, float) else med
    if time_runs:
        import statistics as _stats
        time_send_us = float(_stats.median(time_runs))
    return cycles_send, time_send_us, cycles_runs, time_runs, per_fn_cycles


def benchmark_translated_compute_file(translated_path: str,
                                      reference_dir: str,
                                      target_relpath: str,
                                      work_dir: str,
                                      sdk_root: str,
                                      shell_setup: Optional[str] = None,
                                      commands_script: Optional[str] = None,
                                      arch: str = "wse3",
                                      timeout: int = TIMEOUT_LIMIT,
                                      keep_staged_bundle: bool = False,
                                      num_runs: int = 1,
                                      extra_overlays: Optional[Dict[str, str]] = None,
                                      heldout_eval: Optional[bool] = None,
                                      compile_only: bool = False) -> Dict[str, object]:
    translated_path = expand_path(translated_path)
    reference_dir = expand_path(reference_dir)
    target_relpath = target_relpath
    reference_path = os.path.join(reference_dir, target_relpath)

    with open(translated_path, "r", encoding="utf-8") as fh:
        translated_code = fh.read()
    with open(reference_path, "r", encoding="utf-8") as fh:
        reference_code = fh.read()

    syntax_report = check_csl_syntax(translated_code)
    script_name = infer_commands_script(reference_dir, arch, commands_script)
    stage_info = stage_reference_bundle(reference_dir, work_dir, translated_path, target_relpath)
    # Co-design mode (XKERNEL_CODESIGN_LAYOUT): the agent also authored layout.csl
    # (and possibly other files). Overlay them onto the staged bundle AFTER the
    # reference copytree, so the agent's versions win. The build script compiles
    # `./layout.csl` (which @set_tile_code-includes the compute), so an agent
    # layout is picked up automatically. Each path is bundle-relative.
    if extra_overlays:
        for rel, body in extra_overlays.items():
            if body is None:
                continue
            dest = os.path.join(stage_info["staged_bundle"], rel)
            ensure_directory(os.path.dirname(dest))
            with open(dest, "w", encoding="utf-8") as fh:
                fh.write(body)
    staged_result = run_staged_bundle(
        staged_bundle=stage_info["staged_bundle"],
        commands_script=script_name,
        sdk_root=sdk_root,
        shell_setup=shell_setup,
        timeout=timeout,
        num_runs=num_runs,
        compile_only=compile_only,
    )

    result = {
        "translated_path": translated_path,
        "reference_dir": reference_dir,
        "reference_path": reference_path,
        "target_relpath": target_relpath,
        "commands_script": script_name,
        "overridden_file_path": stage_info["staged_target"],
        "code_lines": len(translated_code.strip().splitlines()),
        "ref_code_lines": len(reference_code.strip().splitlines()),
        "code_similarity": round(code_similarity(translated_code, reference_code), 4),
        "syntax_valid": syntax_report["syntax_valid"],
        "syntax_warnings": syntax_report["syntax_warnings"],
        "status": staged_result["status"],
        "failure_reason": staged_result["failure_reason"],
        "compile_time_ms": staged_result["compile_time_ms"],
        "run_time_ms": staged_result["run_time_ms"],
        "cycles_send": staged_result.get("cycles_send"),
        "time_send_us": staged_result.get("time_send_us"),
        "cycles_send_runs": staged_result.get("cycles_send_runs"),
        "cycles_send_min": staged_result.get("cycles_send_min"),
        "cycles_send_max": staged_result.get("cycles_send_max"),
        "time_send_us_runs": staged_result.get("time_send_us_runs"),
        "num_runs": staged_result.get("num_runs"),
        "success_marker": staged_result["success_marker"],
        "transcript": staged_result["transcript"],
        "script_command": staged_result["script_command"],
        "script_elapsed_ms": staged_result["script_elapsed_ms"],
        "shell_setup_applied": staged_result["shell_setup_applied"],
        "staged_bundle": stage_info["staged_bundle"],
    }

    # Input-level train/test split gate (anti-hardcoding). If the kernel PASSED on
    # the train seed and its spec.yaml declares held-out seeds, re-score correctness
    # on those seeds (compiled out/ reused — no recompile). A kernel that hardcoded
    # the train-seed answer fails here and is flipped to a fail.
    #
    # This is an INTEGRITY GATE (like the dead-timer floor / frozen-fn splice), so it
    # is DEFAULT-ON for the scoring path — but only acts on kernels that opted in via
    # an `eval:` block (full back-compat for the rest). The W2 optimizer INNER LOOP
    # passes heldout_eval=False to skip it (it ranks candidates by cycles; running
    # held-out on every candidate would ~3x the optimize cost — the final pass
    # confirmation catches gaming). Override with XKERNEL_HELDOUT_EVAL=0/1.
    # See docs/SPLIT_AND_LEAKAGE.md (input-level split).
    _env_gate = os.environ.get("XKERNEL_HELDOUT_EVAL")
    if _env_gate is not None:
        _do_heldout = (_env_gate == "1")
    elif heldout_eval is not None:
        _do_heldout = heldout_eval
    else:
        _do_heldout = True  # default-on integrity gate
    if _do_heldout and result["status"] == "pass":
        heldout = _heldout_eval_for_reference(reference_dir)
        if heldout and heldout.get("heldout_seeds"):
            ho = evaluate_heldout(
                staged_bundle=stage_info["staged_bundle"],
                commands_script=script_name,
                heldout_seeds=list(heldout["heldout_seeds"]),
                sdk_root=sdk_root,
                seed_env=str(heldout.get("seed_env") or "XKERNEL_EVAL_SEED"),
                shell_setup=shell_setup,
                timeout=timeout,
            )
            result["heldout_eval"] = ho
            if not ho.get("passed"):
                result["status"] = "fail"
                result["failure_reason"] = str(ho.get("reason") or "heldout_seed_mismatch")

    if not keep_staged_bundle and os.path.exists(stage_info["staged_bundle"]):
        shutil.rmtree(stage_info["staged_bundle"], ignore_errors=True)

    return result


def benchmark_translated_dir(translated_dir: str,
                             sdk_root: str,
                             work_dir: str,
                             shell_setup: Optional[str] = None,
                             arch: str = "wse3",
                             commands_script: Optional[str] = None,
                             timeout: int = TIMEOUT_LIMIT) -> Dict[str, object]:
    metadata_path = os.path.join(translated_dir, "bundle_metadata.json")
    if not os.path.exists(metadata_path):
        raise FileNotFoundError(
            f"{translated_dir} does not contain bundle_metadata.json. "
            "Pass --translated and --reference for legacy mode instead."
        )
    with open(metadata_path, "r", encoding="utf-8") as fh:
        metadata = json.load(fh)
    target_relpath = metadata["target_relpath"]
    translated_path = os.path.join(translated_dir, target_relpath)
    reference_dir = metadata["reference_dir"]
    effective_shell_setup = shell_setup if shell_setup is not None else metadata.get("shell_setup")
    return benchmark_translated_compute_file(
        translated_path=translated_path,
        reference_dir=reference_dir,
        target_relpath=target_relpath,
        work_dir=work_dir,
        sdk_root=sdk_root,
        shell_setup=effective_shell_setup,
        commands_script=commands_script or metadata.get("commands_script"),
        arch=arch or metadata.get("arch", "wse3"),
        timeout=timeout,
        keep_staged_bundle=False,
    )


def print_results_table(results: List[Dict[str, object]]) -> None:
    header = f"{'Kernel':<20} {'Status':>8} {'Compile ms':>12} {'Run ms':>10} {'Syntax':>8} {'Similarity':>10}"
    print(header)
    print("-" * len(header))
    for result in results:
        name = os.path.basename(str(result.get("translated_path", "")))[:20]
        print(
            f"{name:<20} {str(result.get('status', 'n/a')):>8} "
            f"{str(result.get('compile_time_ms', '')):>12} "
            f"{str(result.get('run_time_ms', '')):>10} "
            f"{('OK' if result.get('syntax_valid') else 'FAIL'):>8} "
            f"{result.get('code_similarity', 0.0):>10.2f}"
        )


def main() -> None:
    parser = argparse.ArgumentParser(description="Bundle-aware CSL benchmark runner")
    parser.add_argument("--translated", type=str, help="Single translated compute file (legacy mode)")
    parser.add_argument("--reference", type=str, help="Reference compute file path for --translated")
    parser.add_argument("--translated-dir", type=str, help="One kernel output directory from cuda2csl.py")
    parser.add_argument("--run-dir", type=str, help="A cuda2csl run directory containing per-kernel outputs")
    parser.add_argument("--xkernel", type=str, default=str(REPO_ROOT / "kernels"))
    parser.add_argument("--sdk-root", type=str, default=default_sdk_root())
    parser.add_argument("--arch", type=str, default="wse3")
    parser.add_argument("--commands-script", type=str, default=None)
    parser.add_argument("--shell-setup", type=str, default=None,
                        help="Shell commands to run before the staged bundle commands.")
    parser.add_argument("--shell-setup-file", type=str, default=None,
                        help="Path to a bash snippet to source before the staged bundle commands.")
    parser.add_argument("--timeout", type=int, default=TIMEOUT_LIMIT)
    parser.add_argument("--output", type=str, default=DEFAULT_OUTPUT)
    args = parser.parse_args()

    shell_setup = load_shell_setup(args.shell_setup, args.shell_setup_file)
    output_dir = timestamped_output_dir(expand_path(args.output), "bench")
    results: List[Dict[str, object]] = []

    if args.translated_dir:
        name = os.path.basename(os.path.abspath(args.translated_dir))
        work_dir = ensure_directory(os.path.join(output_dir, "work", name))
        results.append(
            benchmark_translated_dir(
                translated_dir=expand_path(args.translated_dir),
                sdk_root=args.sdk_root,
                work_dir=work_dir,
                shell_setup=shell_setup,
                arch=args.arch,
                commands_script=args.commands_script,
                timeout=args.timeout,
            )
        )
    elif args.translated and args.reference:
        translated = expand_path(args.translated)
        reference = expand_path(args.reference)
        reference_dir = os.path.dirname(reference)
        target_relpath = os.path.relpath(reference, reference_dir)
        name = os.path.splitext(os.path.basename(translated))[0]
        work_dir = ensure_directory(os.path.join(output_dir, "work", name))
        results.append(
            benchmark_translated_compute_file(
                translated_path=translated,
                reference_dir=reference_dir,
                target_relpath=target_relpath,
                work_dir=work_dir,
                sdk_root=args.sdk_root,
                shell_setup=shell_setup,
                commands_script=args.commands_script,
                arch=args.arch,
                timeout=args.timeout,
                keep_staged_bundle=False,
            )
        )
    elif args.run_dir:
        for entry in sorted(os.listdir(args.run_dir)):
            translated_dir = os.path.join(args.run_dir, entry)
            if not os.path.isdir(translated_dir):
                continue
            metadata_path = os.path.join(translated_dir, "bundle_metadata.json")
            if not os.path.exists(metadata_path):
                continue
            work_dir = ensure_directory(os.path.join(output_dir, "work", entry))
            results.append(
                benchmark_translated_dir(
                    translated_dir=translated_dir,
                    sdk_root=args.sdk_root,
                    work_dir=work_dir,
                    shell_setup=shell_setup,
                    arch=args.arch,
                    commands_script=args.commands_script,
                    timeout=args.timeout,
                )
            )
    else:
        parser.print_help()
        return

    print_results_table(results)
    save_json({"results": results}, os.path.join(output_dir, "results.json"))
    print(f"\nResults saved to {output_dir}/results.json")


if __name__ == "__main__":
    main()
