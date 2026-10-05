"""Generate isolated, device-internal timing adapters for heterogeneous CSL bundles.

This module performs only conservative, auditable transforms.  It never edits a
canonical benchmark bundle and refuses to guess when it cannot identify the
timer variables, the first timed launcher, or a device completion callback.
"""

from __future__ import annotations

import ast
import hashlib
import json
import os
import re
import shlex
import shutil
import tarfile
import tempfile
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any, Iterable, Mapping, Sequence

from .schema import (
    ValidationError,
    atomic_write_json,
    canonical_hash,
    hash_file,
    hash_tree,
    utc_now,
)

_CALL_RE = re.compile(r"\b(?:runner|simulator)\.(?:launch|call)\(\s*['\"]([^'\"]+)['\"]")
_DECL_RE_TEMPLATE = r"\b(?:fn|task)\s+{name}\s*\([^)]*\)(?:\s+[^{{\n]+)?\s*\{{"
_GET_TS_RE = re.compile(r"(?P<alias>[A-Za-z_]\w*)\.get_timestamp\(\s*&(?P<buffer>[A-Za-z_]\w*)\s*\)\s*;")
_UNBLOCK_RE = re.compile(
    r"(?:\b[A-Za-z_]\w*\.unblock_cmd_stream|\bf_callback)\s*\(\s*\)\s*;"
)
_UTILITY_NAMES = {
    "f_tic",
    "f_toc",
    "f_memcpy_timestamps",
    "f_reference_timestamps",
    "f_enable_timer",
    "f_enable_tsc",
    "f_sync",
}

# This list deliberately matches campaign.validated_adapter_manifest.  Generated
# run drivers, compiler output, and retained traces are evidence artifacts, not
# adapter source.  Keeping the manifest itself out of the digest lets the
# manifest contain the digest without a self-reference.
ADAPTER_HASH_EXCLUDES = (
    ".git",
    "__pycache__",
    ".pytest_cache",
    "simfab_traces",
    "out",
    ".wse3study_adapter.json",
    ".wse3study_full_override.json",
    ".wse3study_full_adapter.json",
    ".wse3study_evidence",
)
ADAPTER_SCHEMA_VERSION = "2.0.0"
ADAPTER_GENERATOR_VERSION = "2026.08.18.endpoint-contracts.1"
FULL_ADAPTER_GENERATOR_VERSION = "2026.08.18.full-contracts.1"
PHASES = (
    "sync_reference",
    "compute_start",
    "first_send",
    "first_receive",
    "last_receive",
    "compute_end",
    "exit",
)


@dataclass(frozen=True)
class AdapterResult:
    status: str
    source_hash_before: str
    source_hash_after: str
    launcher: str | None
    timer_alias: str | None
    start_buffer: str | None
    end_buffer: str | None
    start_file: str | None
    end_files: tuple[str, ...]
    completion_functions: tuple[str, ...]
    reason: str | None = None
    mode: str | None = None
    telemetry_levels: tuple[str, ...] = ()


@dataclass(frozen=True)
class TimerProgram:
    """One PE program's local timer/export contract.

    CSL layouts may load multiple programs under one exported entry point (for
    example Cholesky has active and no-op PE programs).  Treating a bundle as
    if it had only the first matching function silently leaves some PEs
    uninstrumented, so the transformer operates on every TimerProgram.
    """

    path: Path
    alias: str
    start_buffer: str
    end_buffer: str
    launcher_open: int
    launcher_end: int


def endpoint_adapter_generator_hash() -> str:
    """Hash the exact adapter and SDK-port implementation used for staging.

    Canonical source hashes do not identify generated instrumentation.  This
    digest is part of the immutable work-copy cache key, so changing an adapter
    creates a new staged bundle and leaves earlier evidence untouched.
    """

    study_file = Path(__file__).resolve()
    repo_root = study_file.parents[3]
    inputs: dict[str, str | None] = {
        "instrumentation.py": hash_file(study_file),
    }
    for relative in (
        Path("code_translation/hardware_submit.py"),
        Path("code_translation/hw_vs_sim.py"),
    ):
        path = repo_root / relative
        inputs[str(relative)] = hash_file(path) if path.is_file() else None
    return canonical_hash(
        {
            "adapter_schema_version": ADAPTER_SCHEMA_VERSION,
            "adapter_generator_version": ADAPTER_GENERATOR_VERSION,
            "inputs": inputs,
        }
    )


def full_telemetry_generator_hash() -> str:
    """Identify the exact source transformer and vendored module inputs."""

    study_root = Path(__file__).resolve().parents[1]
    module_paths = (
        study_root / "instrumentation" / "profile_timestamp.csl",
        study_root / "calibration" / "official_sync" / "layout.csl",
        study_root / "calibration" / "official_sync" / "pe.csl",
    )
    return canonical_hash(
        {
            "generator_version": FULL_ADAPTER_GENERATOR_VERSION,
            "instrumentation_py_sha256": hash_file(Path(__file__).resolve()),
            "module_sha256": {
                str(path.relative_to(study_root)): hash_file(path) if path.is_file() else None
                for path in module_paths
            },
        }
    )


def _function_bounds(text: str, declaration_start: int) -> tuple[int, int]:
    opening = text.find("{", declaration_start)
    if opening < 0:
        raise ValidationError("function declaration has no opening brace")
    depth = 0
    in_string: str | None = None
    in_line_comment = False
    in_block_comment = False
    escaped = False
    for index in range(opening, len(text)):
        character = text[index]
        next_character = text[index + 1] if index + 1 < len(text) else ""
        if in_line_comment:
            if character == "\n":
                in_line_comment = False
            continue
        if in_block_comment:
            if character == "*" and next_character == "/":
                in_block_comment = False
            continue
        if in_string:
            if escaped:
                escaped = False
            elif character == "\\":
                escaped = True
            elif character == in_string:
                in_string = None
            continue
        if character == "/" and next_character == "/":
            in_line_comment = True
            continue
        if character == "/" and next_character == "*":
            in_block_comment = True
            continue
        if character in {'"', "'"}:
            in_string = character
        elif character == "{":
            depth += 1
        elif character == "}":
            depth -= 1
            if depth == 0:
                return opening, index + 1
    raise ValidationError("unterminated CSL function body")


def _find_named_body(text: str, name: str) -> tuple[int, int, int] | None:
    match = re.search(_DECL_RE_TEMPLATE.format(name=re.escape(name)), text)
    if not match:
        return None
    opening, end = _function_bounds(text, match.start())
    return match.start(), opening, end


def _declared_functions(text: str) -> Iterable[tuple[str, int, int, int]]:
    for match in re.finditer(r"\b(?:fn|task)\s+([A-Za-z_]\w*)\s*\([^)]*\)(?:\s+[^\{\n]+)?\s*\{", text):
        try:
            opening, end = _function_bounds(text, match.start())
        except ValidationError:
            continue
        yield match.group(1), match.start(), opening, end


def timed_launch_sequence(run_text: str) -> list[str]:
    calls = [match.group(1) for match in _CALL_RE.finditer(run_text)]
    start_indices = [index for index, name in enumerate(calls) if name == "f_tic"]
    if not start_indices:
        return []
    start = start_indices[0]
    try:
        end = calls.index("f_toc", start + 1)
    except ValueError:
        return []
    return [name for name in calls[start + 1 : end] if name not in _UTILITY_NAMES]


def launched_operations(run_text: str) -> list[str]:
    """Return non-utility device entry points in host order."""

    return [
        match.group(1)
        for match in _CALL_RE.finditer(run_text)
        if match.group(1) not in _UTILITY_NAMES
    ]


def _python_launch_name(node: ast.AST) -> str | None:
    if not isinstance(node, ast.Call) or not isinstance(node.func, ast.Attribute):
        return None
    if node.func.attr not in {"launch", "call"} or not node.args:
        return None
    owner = node.func.value
    if not isinstance(owner, ast.Name) or owner.id not in {"runner", "simulator"}:
        return None
    argument = node.args[0]
    if not isinstance(argument, ast.Constant) or not isinstance(argument.value, str):
        return None
    return argument.value


def _nonutility_launches(nodes: Sequence[ast.stmt]) -> list[str]:
    result: list[str] = []
    for statement in nodes:
        for node in ast.walk(statement):
            name = _python_launch_name(node)
            if name and name not in _UTILITY_NAMES:
                result.append(name)
    return result


def host_operation_contract(run_text: str) -> dict[str, Any] | None:
    """Prove a single launch or one mutually-exclusive two-branch dispatch.

    Merely finding two strings in ``run.py`` is not a multi-operation timing
    window.  FFT, for example, selects exactly one of ``f_fft`` and ``f_ifft``
    with one Python ``if/else``.  This AST audit accepts that narrow shape and
    rejects sequential launches, missing else branches, and nested branches
    that launch more than one operation.
    """

    operations = launched_operations(run_text)
    if len(operations) == 1:
        return {
            "kind": "single",
            "operations": operations,
            "evidence": "compiled_source_audit",
        }
    if len(operations) != 2 or len(set(operations)) != 2:
        return None
    try:
        tree = ast.parse(run_text)
    except SyntaxError:
        return None
    matches: list[dict[str, Any]] = []
    for node in ast.walk(tree):
        if not isinstance(node, ast.If) or not node.orelse:
            continue
        yes = _nonutility_launches(node.body)
        no = _nonutility_launches(node.orelse)
        if len(yes) == 1 and len(no) == 1 and yes[0] != no[0]:
            if sorted((yes[0], no[0])) == sorted(operations):
                matches.append(
                    {
                        "kind": "mutually_exclusive_if_else",
                        "operations": [yes[0], no[0]],
                        "condition": ast.unparse(node.test),
                        "evidence": "compiled_source_audit",
                    }
                )
    return matches[0] if len(matches) == 1 else None


def _selected_tile_programs(root: Path) -> tuple[set[Path] | None, dict[str, Any]]:
    """Resolve literal tile programs for an explicitly staged compile command."""

    commands = root / "commands_wse3.sh"
    if not commands.is_file():
        return None, {"reason": "commands_wse3.sh missing"}
    logical: list[str] = []
    pending = ""
    for raw in commands.read_text(encoding="utf-8", errors="ignore").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if line.endswith("\\"):
            pending += line[:-1].strip() + " "
            continue
        logical.append((pending + line).strip())
        pending = ""
    compile_lines = []
    for line in logical:
        try:
            tokens = shlex.split(line)
        except ValueError:
            continue
        if tokens and Path(tokens[0]).name == "cslc":
            compile_lines.append(tokens)
    if len(compile_lines) != 1:
        return None, {"reason": f"expected one staged compile command, found {len(compile_lines)}"}
    layout_token = next(
        (token for token in compile_lines[0][1:] if token.endswith(".csl") and not token.startswith("--")),
        None,
    )
    if not layout_token:
        return None, {"reason": "compile command has no CSL layout"}
    layout = (root / layout_token).resolve()
    try:
        layout.relative_to(root)
    except ValueError:
        return None, {"reason": "layout escapes staged bundle"}
    if not layout.is_file():
        return None, {"reason": f"layout is missing: {layout_token}"}
    text = layout.read_text(encoding="utf-8", errors="ignore")
    names = sorted(
        set(
            re.findall(
                r"@set_tile_code\s*\([^;]*?[\"']([^\"']+\.csl)[\"']",
                text,
                flags=re.S,
            )
        )
    )
    if not names:
        return None, {
            "layout": str(layout.relative_to(root)),
            "reason": "layout has no literal @set_tile_code program",
        }
    programs = {(layout.parent / name).resolve() for name in names}
    missing = [str(path) for path in sorted(programs) if not path.is_file()]
    if missing:
        return None, {"layout": str(layout.relative_to(root)), "missing": missing}
    return programs, {
        "layout": str(layout.relative_to(root)),
        "programs": [str(path.relative_to(root)) for path in sorted(programs)],
        "evidence": "compiled_source_audit",
    }


def _timer_contract_in_text(text: str) -> tuple[str, str, str] | None:
    hits: dict[str, tuple[str, str]] = {}
    for function_name in ("f_tic", "f_toc"):
        bounds = _find_named_body(text, function_name)
        if not bounds:
            return None
        _, opening, end = bounds
        matches = list(_GET_TS_RE.finditer(text[opening:end]))
        if len(matches) != 1:
            return None
        hits[function_name] = (
            matches[0].group("alias"),
            matches[0].group("buffer"),
        )
    if hits["f_tic"][0] != hits["f_toc"][0]:
        return None
    return hits["f_tic"][0], hits["f_tic"][1], hits["f_toc"][1]


def _timer_programs(csl_files: Iterable[Path], launcher: str) -> tuple[list[TimerProgram], list[Path]]:
    programs: list[TimerProgram] = []
    missing_contract: list[Path] = []
    for path in csl_files:
        text = path.read_text(encoding="utf-8", errors="ignore")
        launcher_bounds = _find_named_body(text, launcher)
        if not launcher_bounds:
            continue
        contract = _timer_contract_in_text(text)
        if contract is None:
            missing_contract.append(path)
            continue
        _, opening, end = launcher_bounds
        programs.append(TimerProgram(path, *contract, opening, end))
    return programs, missing_contract


def _adapter_source_hash(root: Path) -> str:
    generated = tuple(
        path.name
        for pattern in ("cs_*.tar.gz", "_hw_vs_sim_driver_*.py")
        for path in root.glob(pattern)
    )
    return hash_tree(root, exclude_names=(*ADAPTER_HASH_EXCLUDES, *generated))


def adapter_source_hash(bundle: str | Path) -> str:
    """Hash adapter source while excluding known generated runtime artifacts."""

    return _adapter_source_hash(Path(bundle).resolve())


def _host_export_contract(run_text: str) -> tuple[bool, tuple[str, ...]]:
    """Check that the existing timer words reach the host.

    The endpoint transform intentionally reuses the bundle's established
    packing/D2H path.  It must not claim export if the host never launches the
    packing entry point or performs D2H.
    """

    reasons: list[str] = []
    calls = [match.group(1) for match in _CALL_RE.finditer(run_text)]
    if "f_memcpy_timestamps" not in calls:
        reasons.append("host never launches f_memcpy_timestamps")
    if not re.search(r"\.(?:memcpy_d2h|memcpy_d2h_async)\s*\(", run_text):
        reasons.append("host has no timer D2H operation")
    if not re.search(r"\bcycles_send\b", run_text):
        reasons.append("host does not emit cycles_send")
    return not reasons, tuple(reasons)


def _manifest_contract(
    *,
    root: Path,
    result: AdapterResult,
    program_sites: Sequence[Mapping[str, Any]],
    run_hash: str,
) -> dict[str, Any]:
    phases = {
        phase: {
            "status": "recorded" if phase in {"compute_start", "compute_end"} else "needs_override",
            "evidence": "inferred" if phase in {"compute_start", "compute_end"} else "documented",
        }
        for phase in PHASES
    }
    phases["sync_reference"]["reason"] = (
        "endpoint adapter does not add the bandwidth-test synchronization routes"
    )
    phases["first_send"]["reason"] = "exact first send requires a kernel-specific fabric site"
    phases["first_receive"]["reason"] = "exact first receive requires a kernel-specific fabric site"
    phases["last_receive"]["reason"] = "exact last receive requires a kernel-specific fabric site"
    phases["exit"]["reason"] = "endpoint adapter records immediately before exit/unblock as compute_end"
    return {
        **asdict(result),
        "adapter_schema_version": ADAPTER_SCHEMA_VERSION,
        "adapter_generator_version": ADAPTER_GENERATOR_VERSION,
        "adapter_generator_sha256": endpoint_adapter_generator_hash(),
        "generated_at": utc_now(),
        "bundle": str(root),
        "mode": result.mode,
        "telemetry_levels": list(result.telemetry_levels),
        "timing": {
            "method": "device_internal",
            "clock_domain": "per_pe_tsc",
            "official_cross_pe_sync": False,
            "program_sites": [dict(site) for site in program_sites],
            "host_rpc_inside_window": False,
        },
        "phases": phases,
        "raw_performance_counters": {
            "status": "needs_override",
            "ids": [0, 1],
            "semantics": "unknown_raw",
            "reason": "endpoint transform does not insert counter reads",
        },
        "d2h": {
            "status": "existing_timer_export_preserved",
            "packing_entrypoint": "f_memcpy_timestamps",
        },
        "correctness": {
            "run_py_unchanged": True,
            "run_py_sha256": run_hash,
            "original_check_required": True,
        },
        "headline_policy": {
            "endpoint": "eligible after compile, correctness, and live-timer validation",
            "full": "not_supported_without_kernel_specific_override",
            "intrusion_threshold_percent": 5,
        },
    }


def _activation_predecessors(
    text: str,
    declarations: Sequence[tuple[str, int, int, int]],
    completion_name: str,
) -> list[tuple[str, str, int]]:
    """Return (function, body, trigger offset) sites that activate completion."""

    binding = re.search(
        rf"@bind_local_task\s*\(\s*{re.escape(completion_name)}\s*,\s*([A-Za-z_]\w*)\s*\)",
        text,
    )
    if not binding:
        return []
    task_id = binding.group(1)
    trigger = re.compile(
        rf"@activate\s*\(\s*{re.escape(task_id)}\s*\)"
        rf"|\.(?:activate|unblock)\s*=\s*{re.escape(task_id)}\b"
    )
    result: list[tuple[str, str, int]] = []
    for name, _, opening, end in declarations:
        if name in _UTILITY_NAMES:
            continue
        body = text[opening:end]
        for match in trigger.finditer(body):
            result.append((name, body, match.start()))
    return result


def _native_program_site(
    path: Path,
    text: str,
    launcher: str,
) -> tuple[dict[str, Any] | None, str | None]:
    launcher_bounds = _find_named_body(text, launcher)
    if not launcher_bounds:
        return None, None
    _, launcher_open, launcher_end = launcher_bounds
    launcher_body = text[launcher_open:launcher_end]
    timestamps = list(_GET_TS_RE.finditer(launcher_body))
    if not timestamps:
        return None, "launcher does not capture compute_start"
    first = timestamps[0]
    enable = re.search(
        rf"\b{re.escape(first.group('alias'))}\.enable_tsc\s*\(\s*\)",
        launcher_body,
    )
    if enable is None or enable.start() > first.start():
        return None, "launcher does not enable the TSC before compute_start"
    alias = first.group("alias")
    start_buffer = first.group("buffer")

    declarations = list(_declared_functions(text))
    nonutility_timestamp_sites: list[tuple[str, str, int]] = []
    for name, _, opening, end in declarations:
        if name in _UTILITY_NAMES:
            continue
        body = text[opening:end]
        for match in _GET_TS_RE.finditer(body):
            if match.group("alias") == alias and match.group("buffer") != start_buffer:
                nonutility_timestamp_sites.append((name, match.group("buffer"), match.start()))
    end_buffers = sorted({buffer for _, buffer, _ in nonutility_timestamp_sites})
    if len(end_buffers) != 1:
        return None, f"expected one compute_end buffer, found {end_buffers}"
    end_buffer = end_buffers[0]

    completion_functions: list[str] = []
    for name, _, opening, end in declarations:
        if name in _UTILITY_NAMES:
            continue
        body = text[opening:end]
        unblock = _UNBLOCK_RE.search(body)
        if unblock is None:
            continue
        completion_functions.append(name)
        direct_end = [
            match
            for match in _GET_TS_RE.finditer(body[: unblock.start()])
            if match.group("alias") == alias and match.group("buffer") == end_buffer
        ]
        if direct_end:
            continue
        predecessors = _activation_predecessors(text, declarations, name)
        if not predecessors:
            return None, f"cannot prove that completion {name} follows compute_end"
        for predecessor, predecessor_body, trigger_offset in predecessors:
            prior_end = [
                match
                for match in _GET_TS_RE.finditer(predecessor_body[:trigger_offset])
                if match.group("alias") == alias and match.group("buffer") == end_buffer
            ]
            if not prior_end:
                return None, (
                    f"completion {name} can be activated by {predecessor} without a prior compute_end sample"
                )
    if not completion_functions:
        return None, "no host-visible completion callback"
    # A declaration plus a sample alone is insufficient: the existing bundle
    # must also pack/copy both timestamps into its exported timer payload.
    if text.count(start_buffer) < 4 or text.count(end_buffer) < 4:
        return None, "timestamp buffers are not demonstrably packed for D2H"
    return {
        "file": str(path),
        "launcher": launcher,
        "timer_alias": alias,
        "start_buffer": start_buffer,
        "end_buffer": end_buffer,
        "completion_functions": sorted(set(completion_functions)),
        "native_source_audit": True,
    }, None


def _ordered_markers(text: str, markers: Sequence[str]) -> bool:
    cursor = -1
    for marker in markers:
        cursor = text.find(marker, cursor + 1)
        if cursor < 0:
            return False
    return True


def _write_stream_native_manifest(
    root: Path,
    *,
    before: str,
    launcher: str,
    mode: str,
    site: Mapping[str, Any],
    operation_contract: Mapping[str, Any],
    phase_updates: Mapping[str, Mapping[str, Any]],
    d2h: Mapping[str, Any],
    program_selection: Mapping[str, Any],
) -> AdapterResult:
    result = AdapterResult(
        "instrumented",
        before,
        before,
        launcher,
        str(site["timer_alias"]),
        str(site["start_buffer"]),
        str(site["end_buffer"]),
        str(site["file"]),
        (str(site["file"]),),
        tuple(str(value) for value in site.get("completion_functions", ())),
        mode=mode,
        telemetry_levels=("endpoint",),
    )
    run_path = root / "run.py"
    manifest = _manifest_contract(
        root=root,
        result=result,
        program_sites=[site],
        run_hash=hash_file(run_path),
    )
    manifest["operation_contract"] = dict(operation_contract)
    manifest["program_selection"] = dict(program_selection)
    manifest["d2h"] = dict(d2h)
    for phase, update in phase_updates.items():
        manifest["phases"][phase].update(dict(update))
    atomic_write_json(root / ".wse3study_adapter.json", manifest)
    return result


def _verify_known_stream_native_bundle(
    root: Path, before: str, run_text: str
) -> AdapterResult | None:
    """Audit known task/stream entry contracts that have no synchronous RPC.

    These are deliberately structural bundle contracts, not name-only
    exceptions.  Every accepted contract proves the receive/task trigger,
    timestamp sites, timestamp packing, blocking completion D2H, and the exact
    timer readback role used by the unchanged host correctness program.
    """

    pe = root / "pe.csl"
    layout = root / "layout.csl"
    if pe.is_file() and layout.is_file() and not launched_operations(run_text):
        pe_text = pe.read_text(encoding="utf-8", errors="ignore")
        layout_text = layout.read_text(encoding="utf-8", errors="ignore")
        task = _find_named_body(pe_text, "fmac_task")
        reduction = _find_named_body(pe_text, "reduce_task")
        gemv_markers = (
            "@bind_data_task(fmac_task",
            "num_recv_x == 0",
            "timestamp.enable_tsc();",
            "timestamp.get_timestamp(&tsc_start_buf);",
            "num_recv_x >= X_local_dim_x",
            "timestamp.get_timestamp(&tsc_end_buf);",
            "pack_timestamps();",
            "@activate(REDUCE);",
        )
        host_markers = (
            "streaming=True",
            'runner.get_id("maxmin_time")',
            "cycles_send",
        )
        if task and reduction and all(marker in pe_text for marker in gemv_markers):
            _, task_open, task_end = task
            task_body = pe_text[task_open:task_end]
            _, reduce_open, reduce_end = reduction
            reduce_body = pe_text[reduce_open:reduce_end]
            if (
                _ordered_markers(
                    task_body,
                    (
                        "num_recv_x == 0",
                        "timestamp.enable_tsc();",
                        "timestamp.get_timestamp(&tsc_start_buf);",
                        "num_recv_x >= X_local_dim_x",
                        "timestamp.get_timestamp(&tsc_end_buf);",
                        "pack_timestamps();",
                        "@activate(REDUCE);",
                    ),
                )
                and ".async = true" in reduce_body
                and all(marker in run_text for marker in host_markers)
                and "@set_tile_code" in layout_text
                and '"pe.csl"' in layout_text
                and '@export_name("maxmin_time"' in layout_text
            ):
                site = {
                    "file": "pe.csl",
                    "launcher": "stream:MEMCPYH2D_DATA_1",
                    "timer_alias": "timestamp",
                    "start_buffer": "tsc_start_buf",
                    "end_buffer": "tsc_end_buf",
                    "completion_functions": ["fmac_task", "reduce_task"],
                    "native_source_audit": True,
                    "trigger": "fmac_task data task on the first x_in wavelet",
                    "end_site": "last local x wavelet before REDUCE activation",
                    "source_sha256": hash_file(pe),
                }
                return _write_stream_native_manifest(
                    root,
                    before=before,
                    launcher="stream:MEMCPYH2D_DATA_1",
                    mode="verified_stream_task_native",
                    site=site,
                    operation_contract={
                        "kind": "stream_triggered",
                        "source": "blocking H2D/D2H sequence plus CSL data-task binding",
                        "operation": "local_checkerboard_matvec",
                        "scope": "one measured last-column PE; not the full eastward reduction",
                        "evidence": "compiled_source_audit",
                    },
                    phase_updates={
                        "first_receive": {
                            "status": "recorded",
                            "evidence": "compiled",
                            "reason": "compute_start is sampled in fmac_task on its first x_in wavelet",
                        },
                    },
                    d2h={
                        "status": "existing_packed_timestamp_export_preserved",
                        "symbol": "maxmin_time",
                        "coordinates": "last column, row 0 as expressed by unchanged run.py",
                        "completion": "blocking streaming result D2H precedes timer D2H",
                    },
                    program_selection={
                        "layout": "layout.csl",
                        "programs": ["pe.csl"],
                        "evidence": "compiled_source_audit",
                    },
                )

    middle = root / "middle.csl"
    left = root / "left.csl"
    code = root / "code.csl"
    if all(path.is_file() for path in (middle, left, code)):
        middle_text = middle.read_text(encoding="utf-8", errors="ignore")
        left_text = left.read_text(encoding="utf-8", errors="ignore")
        layout_text = code.read_text(encoding="utf-8", errors="ignore")
        process = _find_named_body(middle_text, "process")
        launch = _find_named_body(middle_text, "f_mandelbrot")
        recv = _find_named_body(middle_text, "recv")
        if process and launch and recv and launched_operations(run_text) == ["f_mandelbrot"]:
            _, process_open, process_end = process
            _, launch_open, launch_end = launch
            _, recv_open, recv_end = recv
            process_body = middle_text[process_open:process_end]
            launch_body = middle_text[launch_open:launch_end]
            recv_body = middle_text[recv_open:recv_end]
            host_result = run_text.find("streaming=True")
            host_timer = run_text.find('get_id("maxmin_time")')
            layout_role = re.search(
                r"if\s*\(x\s*==\s*0\)\s*\{[^}]*[\"']left\.csl[\"'][^}]*\}\s*else\s*\{[^}]*[\"']middle\.csl[\"']",
                layout_text,
                flags=re.S,
            )
            if (
                _ordered_markers(
                    launch_body,
                    ("timestamp.enable_tsc();", "@activate(recv_task_id)", "sys_mod.unblock_cmd_stream();"),
                )
                and ".activate = process_task_id" in recv_body
                and _ordered_markers(
                    process_body,
                    (
                        "pixels_done == 0",
                        "timestamp.get_timestamp(&tsc_start_buf);",
                        "pixels_done += 1",
                        "pixels_done == total_pixels",
                        "timestamp.get_timestamp(&tsc_end_buf);",
                        "pack_timestamps();",
                    ),
                )
                and ".fabric_color = sys_mod.MEMCPYD2H_1" in process_body
                and host_result >= 0
                and host_timer > host_result
                and "cycles_send" in run_text
                and layout_role is not None
                and '@export_name("maxmin_time"' in layout_text
                and "maxmin_time" in left_text
            ):
                site = {
                    "file": "middle.csl",
                    "launcher": "f_mandelbrot",
                    "timer_alias": "timestamp",
                    "start_buffer": "tsc_start_buf",
                    "end_buffer": "tsc_end_buf",
                    "completion_functions": ["recv", "process"],
                    "native_source_audit": True,
                    "trigger": "f_mandelbrot -> recv -> process",
                    "end_site": "process receives its total_pixels-th wavelet",
                    "measured_role": "middle.csl at host-selected (3,0)",
                    "excluded_role": "left.csl at x=0 is a pipeline source and is not read for timing",
                    "source_sha256": hash_file(middle),
                }
                return _write_stream_native_manifest(
                    root,
                    before=before,
                    launcher="f_mandelbrot",
                    mode="verified_async_task_native",
                    site=site,
                    operation_contract={
                        "kind": "asynchronous_task_chain",
                        "operation": "per-PE middle-stage pixel processing",
                        "scope": "host-selected last-column PE (3,0), not global pipeline latency",
                        "entry_path": ["f_mandelbrot", "recv", "process"],
                        "evidence": "compiled_source_audit",
                    },
                    phase_updates={
                        "first_receive": {
                            "status": "recorded",
                            "evidence": "compiled",
                            "reason": "compute_start is sampled by process on its first received pixel",
                        },
                        "last_receive": {
                            "status": "recorded",
                            "evidence": "compiled",
                            "reason": "compute_end is sampled on total_pixels-th process invocation",
                        },
                    },
                    d2h={
                        "status": "existing_packed_timestamp_export_preserved",
                        "symbol": "maxmin_time",
                        "coordinates": [3, 0],
                        "completion": "blocking last-column streaming result D2H precedes timer D2H",
                    },
                    program_selection={
                        "layout": "code.csl",
                        "programs": ["left.csl", "middle.csl"],
                        "measured_programs": ["middle.csl"],
                        "excluded_programs": {
                            "left.csl": "layout maps it only to x=0; unchanged host reads timer at x=3"
                        },
                        "evidence": "compiled_source_audit",
                    },
                )
    return None


def verify_native_device_internal_bundle(bundle: str | Path) -> AdapterResult:
    """Conservatively attest an existing one-launch device timer.

    Absence of ``f_tic`` is not itself evidence of device-internal timing.  We
    require a single host-launched compute entry point, per-program TSC enable
    and start capture, a distinct end capture on every statically visible exit
    path, timestamp packing, D2H, and the existing cycle output.
    """

    root = Path(bundle).resolve()
    before = _adapter_source_hash(root)
    run_path = root / "run.py"
    if not run_path.is_file():
        return AdapterResult(
            "needs_override", before, before, None, None, None, None, None, (), (),
            "run.py missing",
        )
    run_text = run_path.read_text(encoding="utf-8", errors="ignore")
    streamed = _verify_known_stream_native_bundle(root, before, run_text)
    if streamed is not None:
        return streamed
    operation_contract = host_operation_contract(run_text)
    if operation_contract is None:
        operations = launched_operations(run_text)
        return AdapterResult(
            "needs_override", before, before, None, None, None, None, None, (), (),
            "native timer audit requires one operation or a proven mutually-exclusive "
            f"host dispatch, found {operations}",
        )
    operations = list(operation_contract["operations"])
    export_ok, export_reasons = _host_export_contract_native(run_text)
    if not export_ok:
        return AdapterResult(
            "needs_override", before, before, "|".join(operations), None, None, None, None, (), (),
            "; ".join(export_reasons),
        )
    launcher = operations[0] if len(operations) == 1 else "|".join(sorted(operations))
    selected_programs, selection_contract = _selected_tile_programs(root)
    program_sites: list[dict[str, Any]] = []
    errors: list[str] = []
    csl_paths = sorted(selected_programs or set(root.rglob("*.csl")))
    for path in csl_paths:
        text = path.read_text(encoding="utf-8", errors="ignore")
        for operation in operations:
            if not _find_named_body(text, operation):
                continue
            site, reason = _native_program_site(path, text, operation)
            if reason:
                errors.append(f"{path.relative_to(root)}:{operation}: {reason}")
            elif site:
                site["file"] = str(path.relative_to(root))
                site["operation"] = operation
                program_sites.append(site)
    if errors or not program_sites:
        reason = "; ".join(errors) if errors else f"launcher contract {launcher!r} not found in CSL"
        return AdapterResult(
            "needs_override", before, before, launcher, None, None, None, None, (), (), reason,
        )
    missing_operations = sorted(
        set(operations) - {str(site["operation"]) for site in program_sites}
    )
    if missing_operations:
        return AdapterResult(
            "needs_override", before, before, launcher, None, None, None, None, (), (),
            "selected PE programs do not implement operation(s): " + ", ".join(missing_operations),
        )
    aliases = sorted({str(site["timer_alias"]) for site in program_sites})
    starts = sorted({str(site["start_buffer"]) for site in program_sites})
    ends = sorted({str(site["end_buffer"]) for site in program_sites})
    completion_functions = sorted(
        {
            str(name)
            for site in program_sites
            for name in site["completion_functions"]
        }
    )
    result = AdapterResult(
        "instrumented",
        before,
        before,
        launcher,
        aliases[0] if len(aliases) == 1 else "per_program",
        starts[0] if len(starts) == 1 else "per_program",
        ends[0] if len(ends) == 1 else "per_program",
        str(program_sites[0]["file"]),
        tuple(sorted(str(site["file"]) for site in program_sites)),
        tuple(completion_functions),
        mode="verified_native",
        telemetry_levels=("endpoint",),
    )
    manifest = _manifest_contract(
            root=root,
            result=result,
            program_sites=program_sites,
            run_hash=hash_file(run_path),
        )
    manifest["operation_contract"] = operation_contract
    manifest["program_selection"] = selection_contract
    if "maxmin_time" in run_text:
        manifest["d2h"] = {
            "status": "existing_packed_timestamp_export_preserved",
            "symbol": "maxmin_time",
            "host_readback_proven": True,
        }
    atomic_write_json(root / ".wse3study_adapter.json", manifest)
    return result


def _host_export_contract_native(run_text: str) -> tuple[bool, tuple[str, ...]]:
    reasons: list[str] = []
    if not re.search(r"\.(?:memcpy_d2h|memcpy_d2h_async)\s*\(", run_text):
        reasons.append("host has no timer D2H operation")
    if not re.search(r"\bcycles_send\b", run_text):
        reasons.append("host does not emit cycles_send")
    return not reasons, tuple(reasons)


def _inject_after_open(text: str, opening: int, statement: str) -> str:
    indentation = "  "
    line_end = text.find("\n", opening)
    if line_end < 0:
        line_end = opening + 1
    return text[: line_end + 1] + indentation + statement + "\n" + text[line_end + 1 :]


def _inject_before_unblock(text: str, body_start: int, body_end: int, statement: str) -> tuple[str, bool]:
    body = text[body_start:body_end]
    matches = list(_UNBLOCK_RE.finditer(body))
    if not matches:
        return text, False
    match = matches[-1]
    absolute = body_start + match.start()
    line_start = text.rfind("\n", 0, absolute) + 1
    indentation = re.match(r"\s*", text[line_start:absolute]).group(0)  # type: ignore[union-attr]
    insertion = f"{indentation}{statement}\n"
    return text[:line_start] + insertion + text[line_start:], True


def _disable_host_toc_sample(text: str, alias: str, end_buffer: str) -> tuple[str, bool]:
    bounds = _find_named_body(text, "f_toc")
    if not bounds:
        return text, False
    _, opening, end = bounds
    body = text[opening:end]
    matches = [
        match
        for match in _GET_TS_RE.finditer(body)
        if match.group("alias") == alias and match.group("buffer") == end_buffer
    ]
    if len(matches) != 1:
        return text, False
    match = matches[0]
    absolute_start = opening + match.start()
    absolute_end = opening + match.end()
    replacement = (
        "// WSE3STUDY host f_toc sample disabled; device completion owns "
        f"{end_buffer};"
    )
    return text[:absolute_start] + replacement + text[absolute_end:], True


def _completion_sites(
    text: str,
    *,
    alias: str,
    end_buffer: str,
) -> tuple[str, list[str], bool]:
    """Insert end samples only in the PE program that owns the timer.

    Imported libraries often call ``f_callback()`` but do not own the parent
    program's timestamp alias or buffers.  Injecting into every CSL file (the
    former behavior) creates unresolved names and, worse, can timestamp an
    internal callback that is not the host-visible completion point.
    """

    completion_functions: list[str] = []
    changed = False
    declarations = list(_declared_functions(text))
    for name, _, opening, end in reversed(declarations):
        if name in _UTILITY_NAMES:
            continue
        body = text[opening:end]
        if not _UNBLOCK_RE.search(body):
            continue
        marker = f"{alias}.get_timestamp(&{end_buffer}); // WSE3STUDY device-internal end"
        if marker in body:
            completion_functions.append(name)
            continue
        text, inserted = _inject_before_unblock(text, opening, end, marker)
        if inserted:
            changed = True
            completion_functions.append(name)
    return text, completion_functions, changed


def _statement_bounds(text: str, declaration_pattern: str) -> tuple[int, int] | None:
    match = re.search(declaration_pattern, text)
    if not match:
        return None
    depths = {"(": 0, "{": 0, "[": 0}
    closes = {")": "(", "}": "{", "]": "["}
    in_string: str | None = None
    escaped = False
    for index in range(match.start(), len(text)):
        character = text[index]
        if in_string:
            if escaped:
                escaped = False
            elif character == "\\":
                escaped = True
            elif character == in_string:
                in_string = None
            continue
        if character in {'"', "'"}:
            in_string = character
        elif character in depths:
            depths[character] += 1
        elif character in closes:
            opener = closes[character]
            depths[opener] = max(0, depths[opener] - 1)
        elif character == ";" and not any(depths.values()):
            return match.start(), index + 1
    return None


def _needs_override(
    before: str, launcher: str | None, reason: str, *, mode: str | None = None
) -> AdapterResult:
    return AdapterResult(
        "needs_override", before, before, launcher, None, None, None, None, (), (),
        reason, mode=mode,
    )


def _instrument_imported_callback_endpoint(
    root: Path,
    *,
    before: str,
    run_text: str,
    sequence: Sequence[str],
) -> AdapterResult | None:
    if list(sequence) != ["f_spmv"]:
        return None
    candidates = []
    for path in root.rglob("*.csl"):
        text = path.read_text(encoding="utf-8", errors="ignore")
        if _find_named_body(text, "f_spmv") and "const stencil_mod = @import_module" in text:
            candidates.append((path, text))
    if len(candidates) != 1:
        return _needs_override(
            before, "f_spmv",
            f"imported callback adapter expected one stencil PE program, found {len(candidates)}",
            mode="imported_callback_relocated",
        )
    path, original = candidates[0]
    contract = _timer_contract_in_text(original)
    if contract is None:
        return _needs_override(
            before, "f_spmv", "stencil PE has no unambiguous f_tic/f_toc timer contract",
            mode="imported_callback_relocated",
        )
    alias, start_buffer, end_buffer = contract
    import_bounds = _statement_bounds(
        original, r"\bconst\s+stencil_mod\s*=\s*@import_module\b"
    )
    launcher_bounds = _find_named_body(original, "f_spmv")
    if not import_bounds or not launcher_bounds:
        return _needs_override(
            before, "f_spmv", "cannot resolve stencil module/launcher bounds",
            mode="imported_callback_relocated",
        )
    import_text = original[import_bounds[0] : import_bounds[1]]
    binding = f".f_callback = {alias if alias != 'timestamp' else 'sys_mod'}.unblock_cmd_stream"
    # The timestamp alias is normally ``timestamp`` while the callback owner is
    # ``sys_mod``.  Resolve the actual owner from the module initializer rather
    # than assuming that spelling.
    callback_match = re.search(
        r"\.f_callback\s*=\s*([A-Za-z_]\w*)\.unblock_cmd_stream\b",
        import_text,
    )
    if callback_match is None or len(re.findall(r"\.f_callback\s*=", import_text)) != 1:
        return _needs_override(
            before, "f_spmv", "stencil module has no unique direct unblock callback binding",
            mode="imported_callback_relocated",
        )
    callback_owner = callback_match.group(1)
    launcher_body = original[launcher_bounds[1] : launcher_bounds[2]]
    if len(re.findall(r"\bstencil_mod\.spmv\s*\(", launcher_body)) != 1:
        return _needs_override(
            before, "f_spmv", "f_spmv does not call stencil_mod.spmv exactly once",
            mode="imported_callback_relocated",
        )
    export_ok, export_reasons = _host_export_contract(run_text)
    if not export_ok:
        return _needs_override(
            before, "f_spmv", "; ".join(export_reasons), mode="imported_callback_relocated"
        )

    wrapper_source = root / "benchmark-libs" / "stencil_3d_7pts" / "pe.csl"
    terminal_source = root / "benchmark-libs" / "stencil_3d_7pts" / "wse3" / "pe.csl"
    if not wrapper_source.is_file() or not terminal_source.is_file():
        return _needs_override(
            before, "f_spmv", "vendored WSE-3 stencil callback sources are missing",
            mode="imported_callback_relocated",
        )
    wrapper_text = wrapper_source.read_text(encoding="utf-8", errors="ignore")
    terminal_text = terminal_source.read_text(encoding="utf-8", errors="ignore")
    if not (
        "param f_callback" in wrapper_text
        and ".f_callback = f_callback" in wrapper_text
        and "stencil_mod.spmv" in wrapper_text
        and "param f_callback" in terminal_text
        and "task f_comm" in terminal_text
        and "laplacian_z();" in terminal_text
        and "f_callback();" in terminal_text
        and _ordered_markers(terminal_text, ("task f_comm", "laplacian_z();", "f_callback();"))
    ):
        return _needs_override(
            before, "f_spmv", "vendored stencil sources do not prove the terminal callback chain",
            mode="imported_callback_relocated",
        )

    callback_name = "wse3study_f_spmv_complete"
    import_replacement = re.sub(
        r"(\.f_callback\s*=\s*)[A-Za-z_]\w*\.unblock_cmd_stream\b",
        rf"\g<1>{callback_name}",
        import_text,
        count=1,
    )
    transformed = original[: import_bounds[0]] + import_replacement + original[import_bounds[1] :]
    launcher_bounds = _find_named_body(transformed, "f_spmv")
    assert launcher_bounds is not None
    start_marker = f"{alias}.get_timestamp(&{start_buffer}); // WSE3STUDY device-internal start"
    transformed = _inject_after_open(transformed, launcher_bounds[1], start_marker)
    launcher_decl = _find_named_body(transformed, "f_spmv")
    assert launcher_decl is not None
    callback_fn = (
        f"fn {callback_name}() void {{\n"
        f"  {alias}.get_timestamp(&{end_buffer}); // WSE3STUDY device-internal end\n"
        f"  {callback_owner}.unblock_cmd_stream();\n"
        "}\n\n"
    )
    transformed = transformed[: launcher_decl[0]] + callback_fn + transformed[launcher_decl[0] :]
    transformed, disabled = _disable_host_toc_sample(transformed, alias, end_buffer)
    if not disabled:
        return _needs_override(
            before, "f_spmv", "could not disable overwriting f_toc sample",
            mode="imported_callback_relocated",
        )
    path.write_text(transformed, encoding="utf-8")
    relative = str(path.relative_to(root))
    result = AdapterResult(
        "instrumented", before, _adapter_source_hash(root), "f_spmv", alias,
        start_buffer, end_buffer, relative, (relative,), (callback_name,),
        mode="imported_callback_relocated", telemetry_levels=("endpoint",),
    )
    manifest = _manifest_contract(
        root=root,
        result=result,
        program_sites=[{
            "file": relative,
            "launcher": "f_spmv",
            "timer_alias": alias,
            "start_buffer": start_buffer,
            "end_buffer": end_buffer,
            "completion_functions": [callback_name],
        }],
        run_hash=hash_file(root / "run.py"),
    )
    manifest["timed_sequence"] = list(sequence)
    manifest["operation_contract"] = {
        "kind": "imported_asynchronous_callback",
        "operation": "f_spmv",
        "entry_path": ["f_spmv", "stencil_mod.spmv", "COMM/SEND/RECV tasks"],
        "completion_path": ["f_comm", "laplacian_z", callback_name],
        "scope": "per-PE stencil start through the module's terminal completion callback",
        "evidence": "compiled_source_audit",
    }
    manifest["callback_contract"] = {
        "binding_file": relative,
        "module": "stencil_mod",
        "entry": "spmv",
        "generated_callback": callback_name,
        "terminal_path": [
            str(wrapper_source.relative_to(root)),
            str(terminal_source.relative_to(root)),
            "task f_comm -> laplacian_z -> f_callback",
        ],
        "source_sha256": {
            str(wrapper_source.relative_to(root)): hash_file(wrapper_source),
            str(terminal_source.relative_to(root)): hash_file(terminal_source),
        },
        "evidence": "compiled_source_audit",
    }
    atomic_write_json(root / ".wse3study_adapter.json", manifest)
    return result


def _instrument_stream_task_endpoint(
    root: Path, *, before: str, run_text: str
) -> AdapterResult | None:
    pe = root / "pe.csl"
    if not pe.is_file() or launched_operations(run_text) != ["f_run"]:
        return None
    original = pe.read_text(encoding="utf-8", errors="ignore")
    if not all(name in original for name in ("task multiply", "task recv_task", "fn f_tic", "fn f_toc")):
        return None
    multiply = _find_named_body(original, "multiply")
    recv = _find_named_body(original, "recv_task")
    contract = _timer_contract_in_text(original)
    if not multiply or not recv or contract is None:
        return _needs_override(
            before, "multiply", "wide-multiply stream task/timer contract is incomplete",
            mode="stream_task_relocated",
        )
    alias, start_buffer, end_buffer = contract
    _, multiply_open, multiply_end = multiply
    _, recv_open, recv_end = recv
    multiply_body = original[multiply_open:multiply_end]
    recv_body = original[recv_open:recv_end]
    host_order = (
        'launch("f_tic"', "memcpy_h2d(", "memcpy_d2h(", 'launch("f_toc"'
    )
    if not (
        _ordered_markers(run_text, host_order)
        and "recv_wvlts == num_wvlts" in recv_body
        and "@activate(multiply_task_id)" in recv_body
        and "@mov16" in multiply_body
        and ".fabric_color = sys_mod.MEMCPYD2H_1" in multiply_body
        and "f_memcpy_timestamps" in run_text
        and "cycles_send" in run_text
    ):
        return _needs_override(
            before, "multiply", "cannot prove H2D -> multiply -> blocking D2H completion chain",
            mode="stream_task_relocated",
        )
    transformed = _inject_after_open(
        original,
        multiply_open,
        f"{alias}.get_timestamp(&{start_buffer}); // WSE3STUDY device-internal start",
    )
    multiply = _find_named_body(transformed, "multiply")
    assert multiply is not None
    body = transformed[multiply[1]:multiply[2]]
    send_match = re.search(r"^(?P<indent>[ \t]*)@mov16\s*\(", body, flags=re.M)
    if not send_match:
        return _needs_override(
            before, "multiply", "multiply has no unique output send site",
            mode="stream_task_relocated",
        )
    absolute = multiply[1] + send_match.start()
    line_start = transformed.rfind("\n", 0, absolute) + 1
    indentation = send_match.group("indent")
    transformed = (
        transformed[:line_start]
        + f"{indentation}{alias}.get_timestamp(&{end_buffer}); // WSE3STUDY device-internal end\n"
        + transformed[line_start:]
    )
    transformed, disabled = _disable_host_toc_sample(transformed, alias, end_buffer)
    if not disabled:
        return _needs_override(
            before, "multiply", "could not disable overwriting host f_toc",
            mode="stream_task_relocated",
        )
    pe.write_text(transformed, encoding="utf-8")
    result = AdapterResult(
        "instrumented", before, _adapter_source_hash(root), "stream:multiply", alias,
        start_buffer, end_buffer, "pe.csl", ("pe.csl",), ("multiply",),
        mode="stream_task_relocated", telemetry_levels=("endpoint",),
    )
    manifest = _manifest_contract(
        root=root,
        result=result,
        program_sites=[{
            "file": "pe.csl",
            "launcher": "stream:multiply",
            "timer_alias": alias,
            "start_buffer": start_buffer,
            "end_buffer": end_buffer,
            "completion_functions": ["multiply"],
            "trigger": "recv_task activates multiply_task_id after num_wvlts",
            "end_site": "immediately before asynchronous MEMCPYD2H_1 injection",
        }],
        run_hash=hash_file(root / "run.py"),
    )
    manifest["operation_contract"] = {
        "kind": "stream_triggered",
        "entry_path": ["MEMCPYH2D_1", "recv_task", "multiply"],
        "completion": "blocking streaming MEMCPYD2H_1 consumes multiply output",
        "scope": "multiply task through output-send issue; H2D transfer excluded",
        "evidence": "compiled_source_audit",
    }
    manifest["phases"]["first_send"].update({
        "status": "recorded",
        "evidence": "compiled",
        "reason": "compute_end is sampled immediately before the sole result @mov16",
    })
    atomic_write_json(root / ".wse3study_adapter.json", manifest)
    return result


def _instrument_histogram_endpoint(
    root: Path, *, before: str, run_text: str
) -> AdapterResult | None:
    pe = root / "histogram.csl"
    layout = root / "code.csl"
    if not pe.is_file() or not layout.is_file() or launched_operations(run_text) != ["f_run"]:
        return None
    original = pe.read_text(encoding="utf-8", errors="ignore")
    layout_original = layout.read_text(encoding="utf-8", errors="ignore")
    if not all(
        marker in original
        for marker in (
            "const tally = @import_module",
            ".callback = TALLY_EXIT",
            "task f_tally_exit",
            "fn f_run",
            ".fabric_color = sys_mod.MEMCPYD2H_1",
        )
    ):
        return None
    if re.search(r"\bcycles_send\b", run_text):
        return None
    tally_exit = _find_named_body(original, "f_tally_exit")
    launcher = _find_named_body(original, "f_run")
    if not tally_exit or not launcher:
        return _needs_override(
            before, "f_run", "histogram completion/launcher functions are ambiguous",
            mode="generated_stream_completion_endpoint",
        )
    tally_body = original[tally_exit[1]:tally_exit[2]]
    launch_body = original[launcher[1]:launcher[2]]
    result_d2h = run_text.find("streaming=True")
    buckets_d2h = run_text.find("sym_buckets", result_d2h + 1)
    if not (
        _ordered_markers(
            launch_body,
            ("@activate(START)", "@activate(SENDER_NS)", "@activate(SENDER_WE)", "sys_mod.unblock_cmd_stream()"),
        )
        and "output_buf[0] = tally.local_tally" in tally_body
        and "@mov32" in tally_body
        and ".async = true" in tally_body
        and result_d2h >= 0
        and buckets_d2h > result_d2h
        and 'runner.launch("f_run"' in run_text
        and 'np.testing.assert_equal(result_tensor' in run_text
        and "assert (ans == o).all()" in run_text
        and '"histogram.csl"' in layout_original
    ):
        return _needs_override(
            before, "f_run", "cannot prove histogram TALLY_EXIT and blocking D2H correctness chain",
            mode="generated_stream_completion_endpoint",
        )

    commands_text = (root / "commands_wse3.sh").read_text(encoding="utf-8", errors="ignore")
    width_match = re.search(r"(?:^|,)HIST_WIDTH:(\d+)(?:,|\s|$)", commands_text)
    if not width_match:
        return _needs_override(
            before, "f_run", "compile command does not pin HIST_WIDTH for timer readback",
            mode="generated_stream_completion_endpoint",
        )
    timer_x = int(width_match.group(1)) - 1
    if timer_x < 0:
        return _needs_override(
            before, "f_run", "invalid HIST_WIDTH for timer readback",
            mode="generated_stream_completion_endpoint",
        )

    timer_declarations = '''
// WSE3STUDY device-internal global histogram endpoint.
const timestamp = @import_module("<time>");
var wse3study_tsc_start = @zeros([timestamp.tsc_size_words]u16);
var wse3study_tsc_end = @zeros([timestamp.tsc_size_words]u16);
var wse3study_timer_buf = @zeros([3]f32);
var wse3study_ptr_timer_buf: [*]f32 = &wse3study_timer_buf;

fn wse3study_pack_timestamps() void {
  var lo_: u16 = wse3study_tsc_start[0];
  var hi_: u16 = wse3study_tsc_start[1];
  wse3study_timer_buf[0] = @bitcast(f32, (@as(u32, hi_) << @as(u16, 16)) | @as(u32, lo_));
  lo_ = wse3study_tsc_start[2]; hi_ = wse3study_tsc_end[0];
  wse3study_timer_buf[1] = @bitcast(f32, (@as(u32, hi_) << @as(u16, 16)) | @as(u32, lo_));
  lo_ = wse3study_tsc_end[1]; hi_ = wse3study_tsc_end[2];
  wse3study_timer_buf[2] = @bitcast(f32, (@as(u32, hi_) << @as(u16, 16)) | @as(u32, lo_));
}
'''
    sys_import = re.search(
        r"const\s+sys_mod\s*=\s*@import_module\s*\([^;]+;", original, flags=re.S
    )
    if not sys_import:
        return _needs_override(
            before, "f_run", "cannot find histogram memcpy module declaration",
            mode="generated_stream_completion_endpoint",
        )
    transformed = original[:sys_import.end()] + timer_declarations + original[sys_import.end():]
    launcher = _find_named_body(transformed, "f_run")
    assert launcher is not None
    transformed = _inject_after_open(
        transformed,
        launcher[1],
        "timestamp.enable_tsc();\n  timestamp.get_timestamp(&wse3study_tsc_start); // WSE3STUDY device-internal start",
    )
    tally_exit = _find_named_body(transformed, "f_tally_exit")
    assert tally_exit is not None
    transformed = _inject_after_open(
        transformed,
        tally_exit[1],
        "timestamp.get_timestamp(&wse3study_tsc_end); // WSE3STUDY device-internal end\n  timestamp.disable_tsc();\n  wse3study_pack_timestamps();",
    )
    export_anchor = '@export_symbol(ptr_buckets, "buckets");'
    if transformed.count(export_anchor) != 1:
        return _needs_override(
            before, "f_run", "cannot identify histogram export block",
            mode="generated_stream_completion_endpoint",
        )
    transformed = transformed.replace(
        export_anchor,
        export_anchor + '\n  @export_symbol(wse3study_ptr_timer_buf, "maxmin_time");',
        1,
    )
    layout_anchor = '@export_name("buckets", [*]u32, true);'
    if layout_original.count(layout_anchor) != 1:
        return _needs_override(
            before, "f_run", "cannot identify histogram layout export block",
            mode="generated_stream_completion_endpoint",
        )
    layout_transformed = layout_original.replace(
        layout_anchor,
        layout_anchor + '\n  @export_name("maxmin_time", [*]f32, true);',
        1,
    )

    postlude = root / ".wse3study_endpoint_postlude.py"
    postlude_text = f'''# Generated by wse3study; executed after the unchanged run.py.
import numpy as np
import struct
from cerebras.sdk.runtime.sdkruntimepybind import MemcpyDataType, MemcpyOrder

_symbol = runner.get_id("maxmin_time")
_packed = np.zeros(3, dtype=np.uint32)
runner.memcpy_d2h(
    _packed, _symbol, {timer_x}, 0, 1, 1, 3,
    streaming=False,
    data_type=MemcpyDataType.MEMCPY_32BIT,
    order=MemcpyOrder.ROW_MAJOR,
    nonblock=False,
)
_bits = [struct.unpack("<I", struct.pack("<f", float(value)))[0] for value in _packed.view(np.float32)]
_words = [
    _bits[0] & 0xFFFF, (_bits[0] >> 16) & 0xFFFF,
    _bits[1] & 0xFFFF, (_bits[1] >> 16) & 0xFFFF,
    _bits[2] & 0xFFFF, (_bits[2] >> 16) & 0xFFFF,
]
_start = int(_words[0]) | (int(_words[1]) << 16) | (int(_words[2]) << 32)
_end = int(_words[3]) | (int(_words[4]) << 16) | (int(_words[5]) << 32)
print(f"cycles_send = {{(_end - _start) & ((1 << 48) - 1)}} cycles")
'''

    # Install only after every proof and transformation above succeeds.
    pe.write_text(transformed, encoding="utf-8")
    layout.write_text(layout_transformed, encoding="utf-8")
    postlude.write_text(postlude_text, encoding="utf-8")
    result = AdapterResult(
        "instrumented", before, _adapter_source_hash(root), "f_run", "timestamp",
        "wse3study_tsc_start", "wse3study_tsc_end", "histogram.csl",
        ("histogram.csl",), ("f_tally_exit",),
        mode="generated_stream_completion_endpoint", telemetry_levels=("endpoint",),
    )
    manifest = _manifest_contract(
        root=root,
        result=result,
        program_sites=[{
            "file": "histogram.csl",
            "launcher": "f_run",
            "timer_alias": "timestamp",
            "start_buffer": "wse3study_tsc_start",
            "end_buffer": "wse3study_tsc_end",
            "completion_functions": ["f_tally_exit"],
            "completion_scope": "global tally root at (HIST_WIDTH-1,0)",
        }],
        run_hash=hash_file(root / "run.py"),
    )
    manifest["operation_contract"] = {
        "kind": "asynchronous_global_completion",
        "entry_path": ["f_run", "process_inputs", "tally.signal_completion"],
        "completion_path": ["tally callback TALLY_EXIT", "f_tally_exit", "MEMCPYD2H_1"],
        "scope": "root-PE start to global tally completion",
        "evidence": "compiled_source_audit",
    }
    manifest["d2h"] = {
        "status": "generated_postlude_after_frozen_correctness_host",
        "symbol": "maxmin_time",
        "coordinates": [timer_x, 0],
        "postlude": str(postlude.relative_to(root)),
        "postlude_sha256": hash_file(postlude),
        "runtime_requirement": "campaign shared runtime defers run.py stop until postlude completes",
    }
    manifest["phases"]["last_receive"].update({
        "status": "recorded",
        "evidence": "compiled",
        "reason": "TALLY_EXIT is activated only after the configured global tally completes",
    })
    manifest["correctness"]["postlude_after_original_check"] = True
    atomic_write_json(root / ".wse3study_adapter.json", manifest)
    return result


def reinstrument_host_bracketed_bundle(bundle: str | Path) -> AdapterResult:
    root = Path(bundle).resolve()
    before = _adapter_source_hash(root)
    run_path = root / "run.py"
    if not run_path.is_file():
        return AdapterResult(
            "needs_override", before, before, None, None, None, None, None, (), (),
            "run.py missing; timing and correctness export cannot be verified",
        )
    run_text = run_path.read_text(encoding="utf-8", errors="ignore")
    run_hash = hash_file(run_path)
    sequence = timed_launch_sequence(run_text)
    histogram = _instrument_histogram_endpoint(
        root, before=before, run_text=run_text
    )
    if histogram is not None:
        return histogram
    stream_task = _instrument_stream_task_endpoint(
        root, before=before, run_text=run_text
    )
    if stream_task is not None:
        return stream_task
    imported_callback = _instrument_imported_callback_endpoint(
        root, before=before, run_text=run_text, sequence=sequence
    )
    if imported_callback is not None:
        return imported_callback
    if not sequence:
        return verify_native_device_internal_bundle(root)
    if len(sequence) != 1:
        return AdapterResult(
            "needs_override", before, before, None, None, None, None, None, (), (),
            f"host timer encloses {len(sequence)} operations {sequence}; a single compute entry point is required",
        )
    launcher = sequence[0]
    csl_files = sorted(root.rglob("*.csl"))
    programs, missing_contract = _timer_programs(csl_files, launcher)
    if missing_contract:
        return AdapterResult(
            "needs_override", before, before, launcher, None, None, None, None, (), (),
            "launcher exists in PE program(s) without an unambiguous local f_tic/f_toc contract: "
            + ", ".join(str(path.relative_to(root)) for path in missing_contract),
        )
    if not programs:
        return AdapterResult(
            "needs_override", before, before, launcher, None, None, None, None, (), (),
            f"launcher {launcher!r} was not found in any timer-owning CSL PE program",
        )
    export_ok, export_reasons = _host_export_contract(run_text)
    if not export_ok:
        return AdapterResult(
            "needs_override", before, before, launcher, None, None, None, None, (), (),
            "; ".join(export_reasons),
        )

    # Analyze and transform entirely in memory.  A failed program therefore
    # leaves the staged bundle byte-for-byte untouched.
    transformed: dict[Path, str] = {}
    completion_functions: list[str] = []
    end_files: list[str] = []
    program_sites: list[dict[str, Any]] = []
    for program in programs:
        text = program.path.read_text(encoding="utf-8", errors="ignore")
        launcher_bounds = _find_named_body(text, launcher)
        assert launcher_bounds is not None
        _, opening, _ = launcher_bounds
        start_marker = (
            f"{program.alias}.get_timestamp(&{program.start_buffer}); "
            "// WSE3STUDY device-internal start"
        )
        if start_marker not in text[opening:]:
            text = _inject_after_open(text, opening, start_marker)
        # Bounds changed after the start insertion, so discover them afresh.
        text, local_completions, _ = _completion_sites(
            text, alias=program.alias, end_buffer=program.end_buffer
        )
        if not local_completions:
            return AdapterResult(
                "needs_override", before, before, launcher, program.alias,
                program.start_buffer, program.end_buffer,
                str(program.path.relative_to(root)), (), (),
                "PE program has no host-visible completion callback: "
                + str(program.path.relative_to(root)),
            )
        text, disabled = _disable_host_toc_sample(
            text, program.alias, program.end_buffer
        )
        if not disabled:
            return AdapterResult(
                "needs_override", before, before, launcher, program.alias,
                program.start_buffer, program.end_buffer,
                str(program.path.relative_to(root)), (), (),
                "could not disable the host f_toc write that would overwrite compute_end",
            )
        transformed[program.path] = text
        relative = str(program.path.relative_to(root))
        completion_functions.extend(local_completions)
        end_files.append(relative)
        program_sites.append(
            {
                "file": relative,
                "launcher": launcher,
                "timer_alias": program.alias,
                "start_buffer": program.start_buffer,
                "end_buffer": program.end_buffer,
                "completion_functions": sorted(set(local_completions)),
            }
        )

    for path, text in transformed.items():
        path.write_text(text, encoding="utf-8")

    aliases = sorted({program.alias for program in programs})
    starts = sorted({program.start_buffer for program in programs})
    ends = sorted({program.end_buffer for program in programs})
    result = AdapterResult(
        "instrumented",
        before,
        _adapter_source_hash(root),
        launcher,
        aliases[0] if len(aliases) == 1 else "per_program",
        starts[0] if len(starts) == 1 else "per_program",
        ends[0] if len(ends) == 1 else "per_program",
        str(programs[0].path.relative_to(root)),
        tuple(sorted(set(end_files))),
        tuple(sorted(set(completion_functions))),
        mode="host_bracket_relocated",
        telemetry_levels=("endpoint",),
    )
    atomic_write_json(
        root / ".wse3study_adapter.json",
        {
            **_manifest_contract(
                root=root,
                result=result,
                program_sites=program_sites,
                run_hash=run_hash,
            ),
            "timed_sequence": sequence,
        },
    )
    return result


def stage_bundle(source: str | Path, destination: str | Path, *, sdk210_port: bool = True) -> Path:
    source_path = Path(source).resolve()
    target = Path(destination).resolve()
    if target.exists():
        raise FileExistsError(f"refusing to overwrite staged bundle: {target}")
    target.parent.mkdir(parents=True, exist_ok=True)
    if sdk210_port:
        try:
            from hardware_submit import port_kernel_to_sdk210  # type: ignore
        except ImportError as exc:
            raise RuntimeError("add xkernel/code_translation to PYTHONPATH to port SDK 1.4 bundles") from exc
        port_kernel_to_sdk210(str(source_path), str(target))
    else:
        shutil.copytree(source_path, target)
    return target


def vendor_official_sync_module(sdk_extras_tar: str | Path, destination: str | Path) -> dict[str, Any]:
    """Extract only the official bandwidth-test sync module into a staged bundle."""

    archive = Path(sdk_extras_tar)
    destination_path = Path(destination)
    suffixes = ("/examples/benchmarks/bandwidth-test/src/sync/layout.csl", "/examples/benchmarks/bandwidth-test/src/sync/pe.csl")
    extracted: dict[str, str] = {}
    with tarfile.open(archive, "r:gz") as handle:
        members = [member for member in handle.getmembers() if member.name.endswith(suffixes)]
        if len(members) != 2:
            raise ValidationError(f"expected two bandwidth-test sync files in {archive}, found {len(members)}")
        for member in members:
            leaf = Path(member.name).name
            output = destination_path / "sync" / leaf
            output.parent.mkdir(parents=True, exist_ok=True)
            source = handle.extractfile(member)
            if source is None:
                raise ValidationError(f"could not read {member.name}")
            output.write_bytes(source.read())
            extracted[str(output)] = hash_file(output)
    return {"archive": str(archive), "files": extracted, "evidence": "documented"}


def _official_sync_reference() -> dict[str, str]:
    directory = Path(__file__).resolve().parents[1] / "calibration" / "official_sync"
    files = (directory / "layout.csl", directory / "pe.csl")
    if not all(path.is_file() for path in files):
        raise ValidationError(f"vendored SDK 2.10 sync reference is missing from {directory}")
    return {path.name: hash_file(path) for path in files}


def full_telemetry_inventory_snapshot(layout: Mapping[str, Any]) -> dict[str, Any]:
    """Freeze only the compiled-layout fields needed for adapter collision checks."""

    resources = layout.get("resources")
    resources = resources if isinstance(resources, Mapping) else {}

    def values(name: str) -> Any:
        record = resources.get(name)
        return record.get("value") if isinstance(record, Mapping) else None

    def evidence(name: str) -> Any:
        record = resources.get(name)
        return record.get("evidence") if isinstance(record, Mapping) else None

    application_programs = sorted(
        {
            str(pe.get("program"))
            for pe in (layout.get("pes") or [])
            if isinstance(pe, Mapping)
            and pe.get("role") == "application"
            and pe.get("program")
        }
    )
    qualification = layout.get("acceptance_qualification")
    qualification = qualification if isinstance(qualification, Mapping) else {}
    return {
        "layout_sha256": canonical_hash(layout),
        "qualification_status": qualification.get("status"),
        "application_programs": application_programs,
        "used_resources": {
            "colors": values("color_ids"),
            "input_queues": values("input_queue_ids"),
            "output_queues": values("output_queue_ids"),
            "local_task_ids": values("task_ids"),
        },
        "resource_evidence": {
            "colors": evidence("color_ids"),
            "input_queues": evidence("input_queue_ids"),
            "output_queues": evidence("output_queue_ids"),
            "local_task_ids": evidence("task_ids"),
        },
        "evidence": "inferred",
        "uncertainty": (
            "Collision freedom is computed from the frozen inventory identifiers; "
            "each resource retains its compiled/source-inferred evidence label."
        ),
    }


def full_telemetry_override_template(
    bundle: str | Path,
    *,
    compiled_inventory: Mapping[str, Any] | None = None,
) -> dict[str, Any]:
    """Build a fail-closed per-kernel full-telemetry work item.

    The template is intentionally not executable.  Exact fabric send/receive
    sites and collision-free sync resources cannot be inferred from names such
    as ``@mov32`` alone.  A kernel override becomes eligible for compilation
    only after :func:`validate_full_telemetry_override` proves every source and
    export site.
    """

    root = Path(bundle).resolve()
    run_path = root / "run.py"
    endpoint_path = root / ".wse3study_adapter.json"
    endpoint: dict[str, Any] | None = None
    if endpoint_path.is_file():
        try:
            endpoint = json.loads(endpoint_path.read_text(encoding="utf-8"))
        except json.JSONDecodeError:
            endpoint = None
    inventory_snapshot = (
        full_telemetry_inventory_snapshot(compiled_inventory)
        if isinstance(compiled_inventory, Mapping)
        else None
    )
    return {
        "schema_version": "1.0.0",
        "status": "needs_override",
        "telemetry_level": "full",
        "bundle": str(root),
        "bundle_source_hash": _adapter_source_hash(root),
        "endpoint_adapter_mode": (endpoint or {}).get("mode"),
        "run_py_sha256": hash_file(run_path) if run_path.is_file() else None,
        "phases": {phase: [] for phase in PHASES},
        "omitted_phases": {},
        "site_format": {
            "file": "path relative to bundle",
            "function": "CSL fn/task containing the mark",
            "anchor": "unique literal source text inside the function",
            "position": "before or after the anchor",
            "profile_alias": "explicit CSL import alias (normally profile)",
            "reference_expression": "required only for sync_reference",
            "sequence": "required unique integer when several marks share one boundary",
            "marker": "// WSE3STUDY phase=<phase>",
        },
        "sync": {
            "protocol": "sdk_2.10_bandwidth_test",
            "reference_hashes": _official_sync_reference(),
            "vendored_files": {"layout.csl": None, "pe.csl": None},
            "colors": [],
            "input_queues": [],
            "output_queues": [],
            "local_task_ids": [],
            "inventory_snapshot": inventory_snapshot,
            "inventory_hash": canonical_hash(inventory_snapshot) if inventory_snapshot else None,
            "collision_check": "pending",
        },
        "exports": {
            "phase_words": "wse3study_phase_words",
            "phase_valid": "wse3study_phase_valid",
            "raw_perf": "wse3study_raw_perf",
            "sync_reference": "wse3study_sync_reference",
            "host_d2h_verified": False,
            "per_pe_geometry_verified": False,
            "per_pe_record": {
                "coordinate_order": None,
                "logical_rectangle": {"x": None, "y": None, "width": None, "height": None},
                "phase_count": 7,
                "timestamp_words_per_phase": 3,
                "phase_valid_words": 7,
                "raw_perf_words": 6,
                "sync_reference_words": 3,
            },
        },
        "raw_performance_counters": {
            "ids": [0, 1],
            "names": ["perf_counter_0_raw", "perf_counter_1_raw"],
            "event_semantics": None,
        },
        "correctness": {
            "original_run_py_sha256": hash_file(run_path) if run_path.is_file() else None,
            "original_check_preserved": False,
        },
        "intrusion_comparison": {
            "endpoint_cycles": None,
            "full_cycles": None,
            "delta_percent": None,
            "headline_threshold_percent": 5,
        },
        "materialization": {
            "status": "blocked",
            "destination": None,
            "source_file_sha256": {},
            "integration_edits": [],
            "integration_edit_format": {
                "role": "one required layout/PE/host integration role",
                "file": "path relative to bundle",
                "function": "optional CSL fn/task scope",
                "anchor": "unique literal pre-edit source text",
                "anchor_sha256": "optional SHA-256 of the literal anchor",
                "position": "before, after, or exact-anchor replace",
                "text": "literal layout-specific source to insert",
            },
            "counter_sites": [],
            "protected_regions": [],
            "program_coverage": {
                "inventory_hash": None,
                "required_programs": [],
                "covered_programs": [],
                "program_files": {},
                "omitted_phases": {},
                "status": "pending",
            },
            "required_integration_roles": [
                "profile_import",
                "sync_layout_wiring",
                "sync_pe_import",
                "sync_host_launch",
                "telemetry_csl_export",
                "telemetry_host_d2h",
            ],
            "execution_contract": {
                "single_device_entrypoint": None,
                "sync_before_compute": False,
                "host_rpc_inside_timed_window": None,
                "operator_attested": False,
            },
            "blockers": [
                "exact insertion anchors and pre-edit file hashes are not supplied",
                "layout-specific SDK sync imports/routes/tasks are not supplied",
                "per-PE D2H geometry and original correctness region are not supplied",
            ],
        },
        "evidence": "inferred",
    }


def write_full_telemetry_override_template(
    bundle: str | Path,
    destination: str | Path,
    *,
    compiled_inventory: Mapping[str, Any] | None = None,
) -> Path:
    target = Path(destination)
    atomic_write_json(
        target,
        full_telemetry_override_template(bundle, compiled_inventory=compiled_inventory),
    )
    return target


def is_pristine_full_telemetry_override(value: Mapping[str, Any]) -> bool:
    """Return true only for an untouched generated blocker template."""

    phases = value.get("phases")
    sync = value.get("sync")
    exports = value.get("exports")
    correctness = value.get("correctness")
    materialization = value.get("materialization")
    if value.get("status") != "needs_override" or not isinstance(phases, Mapping):
        return False
    if any(phases.get(phase) for phase in PHASES):
        return False
    if not isinstance(sync, Mapping) or any(
        sync.get(field) for field in ("colors", "input_queues", "output_queues", "local_task_ids")
    ):
        return False
    if sync.get("collision_check") not in (None, "pending"):
        return False
    if not isinstance(exports, Mapping) or exports.get("host_d2h_verified") is True:
        return False
    if isinstance(correctness, Mapping) and correctness.get("original_check_preserved") is True:
        return False
    if materialization is not None:
        if not isinstance(materialization, Mapping):
            return False
        if materialization.get("status") not in (None, "blocked"):
            return False
        if materialization.get("integration_edits") or materialization.get("counter_sites"):
            return False
    return True


def _load_override(value: Mapping[str, Any] | str | Path) -> dict[str, Any]:
    if isinstance(value, Mapping):
        return json.loads(json.dumps(value))
    path = Path(value)
    try:
        loaded = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise ValidationError(f"cannot read full telemetry override {path}: {exc}") from exc
    if not isinstance(loaded, dict):
        raise ValidationError("full telemetry override must be a JSON object")
    return loaded


def validate_full_telemetry_override(
    bundle: str | Path,
    override: Mapping[str, Any] | str | Path,
) -> dict[str, Any]:
    """Validate a manually completed full adapter without inventing sites.

    Passing this source audit means "ready to compile", not "measured".  The
    campaign must still compile the exact source, compare endpoint/full
    overhead on silicon, and retain the original correctness result.
    """

    root = Path(bundle).resolve()
    spec = _load_override(override)
    errors: list[str] = []
    if spec.get("schema_version") != "1.0.0":
        errors.append("schema_version must be 1.0.0")
    if spec.get("status") != "ready_for_compile":
        errors.append("status must be ready_for_compile")
    if spec.get("telemetry_level") != "full":
        errors.append("telemetry_level must be full")
    if spec.get("bundle_source_hash") != _adapter_source_hash(root):
        errors.append("bundle_source_hash does not identify the current staged source")

    phases = spec.get("phases")
    omissions = spec.get("omitted_phases")
    if not isinstance(phases, Mapping) or not isinstance(omissions, Mapping):
        errors.append("phases and omitted_phases must be objects")
        phases, omissions = {}, {}
    omittable = {"first_send", "first_receive", "last_receive"}
    for index, phase in enumerate(PHASES):
        sites = phases.get(phase) if isinstance(phases, Mapping) else None
        omitted = omissions.get(phase) if isinstance(omissions, Mapping) else None
        if not sites:
            if phase not in omittable:
                errors.append(f"required phase {phase} has no source site")
            elif not isinstance(omitted, str) or not omitted.strip():
                errors.append(f"omitted phase {phase} requires a non-empty rationale")
            continue
        if not isinstance(sites, list):
            errors.append(f"phase {phase} sites must be a list")
            continue
        for site_number, site in enumerate(sites):
            if not isinstance(site, Mapping):
                errors.append(f"phase {phase} site {site_number} is not an object")
                continue
            relative = Path(str(site.get("file") or ""))
            if relative.is_absolute() or ".." in relative.parts:
                errors.append(f"phase {phase} site escapes the staged bundle")
                continue
            path = root / relative
            if not path.is_file():
                errors.append(f"phase {phase} file does not exist: {relative}")
                continue
            text = path.read_text(encoding="utf-8", errors="ignore")
            function = str(site.get("function") or "")
            bounds = _find_named_body(text, function) if function else None
            if not bounds:
                errors.append(f"phase {phase} function {function!r} missing in {relative}")
                continue
            _, opening, end = bounds
            body = text[opening:end]
            marker = f"// WSE3STUDY phase={phase}"
            expected_call = (
                "mark_sync_reference"
                if phase == "sync_reference"
                else f"mark({index})"
            )
            if marker not in body or expected_call not in body:
                errors.append(
                    f"phase {phase} site {relative}:{function} lacks {marker!r} and {expected_call!r}"
                )

    sync = spec.get("sync")
    if not isinstance(sync, Mapping):
        errors.append("sync must be an object")
        sync = {}
    if sync.get("protocol") != "sdk_2.10_bandwidth_test":
        errors.append("sync protocol must be sdk_2.10_bandwidth_test")
    if sync.get("collision_check") != "passed" or not sync.get("inventory_hash"):
        errors.append("sync resources require a passed route/queue/color collision check and inventory_hash")
    expected_sync = _official_sync_reference()
    vendored = sync.get("vendored_files")
    if not isinstance(vendored, Mapping):
        errors.append("sync.vendored_files must map layout.csl and pe.csl")
        vendored = {}
    for leaf, expected_hash in expected_sync.items():
        relative_value = vendored.get(leaf) if isinstance(vendored, Mapping) else None
        if not relative_value:
            errors.append(f"sync.vendored_files.{leaf} is missing")
            continue
        relative = Path(str(relative_value))
        path = root / relative
        if relative.is_absolute() or ".." in relative.parts or not path.is_file():
            errors.append(f"vendored sync file is invalid: {relative}")
        elif hash_file(path) != expected_hash:
            errors.append(f"vendored sync file differs from SDK 2.10 reference: {relative}")

    exports = spec.get("exports")
    if not isinstance(exports, Mapping) or exports.get("host_d2h_verified") is not True:
        errors.append("all full telemetry exports must be verified through host D2H")
    else:
        source = "\n".join(
            path.read_text(encoding="utf-8", errors="ignore")
            for path in root.rglob("*.csl")
        )
        host = (root / "run.py").read_text(encoding="utf-8", errors="ignore") if (root / "run.py").is_file() else ""
        for key in ("phase_words", "phase_valid", "raw_perf", "sync_reference"):
            symbol = str(exports.get(key) or "")
            if not symbol or symbol not in source or symbol not in host:
                errors.append(f"export {key} symbol is not present in both CSL and host code")
        if not re.search(r"\.(?:memcpy_d2h|memcpy_d2h_async)\s*\(", host):
            errors.append("run.py contains no D2H operation")

    counters = spec.get("raw_performance_counters")
    if not isinstance(counters, Mapping) or counters.get("ids") != [0, 1]:
        errors.append("raw performance counter IDs must remain [0, 1]")
    elif counters.get("event_semantics") not in (None, "unknown_raw"):
        errors.append("performance counter event semantics are undocumented and must remain unknown_raw")

    correctness = spec.get("correctness")
    run_path = root / "run.py"
    run_hash = hash_file(run_path) if run_path.is_file() else None
    if not isinstance(correctness, Mapping):
        errors.append("correctness must be an object")
    else:
        if correctness.get("original_run_py_sha256") != run_hash:
            errors.append("original run.py/correctness hash changed")
        if correctness.get("original_check_preserved") is not True:
            errors.append("original correctness check is not attested as preserved")

    return {
        "status": "ready_for_compile" if not errors else "needs_override",
        "errors": errors,
        "bundle_source_hash": _adapter_source_hash(root),
        "telemetry_level": "full",
        "evidence": "inferred",
        "compile_required": True,
        "silicon_overhead_comparison_required": True,
    }


FULL_ADAPTER_MANIFEST = ".wse3study_full_adapter.json"
_FULL_REQUIRED_ROLES = {
    "profile_import",
    "sync_layout_wiring",
    "sync_pe_import",
    "sync_host_launch",
    "telemetry_csl_export",
    "telemetry_host_d2h",
}


def _text_sha256(value: str) -> str:
    return hashlib.sha256(value.encode("utf-8")).hexdigest()


def _csl_without_comments(value: str) -> str:
    value = re.sub(r"/\*.*?\*/", "", value, flags=re.DOTALL)
    return re.sub(r"//[^\n]*", "", value)


def _python_source_contract(value: str) -> tuple[set[str], list[str], int]:
    """Return code-bearing identifiers/strings, launch names, and D2H calls."""

    try:
        tree = ast.parse(value)
    except SyntaxError as exc:
        raise ValidationError(f"materialized run.py is not valid Python: {exc}") from exc
    tokens: set[str] = set()
    launches: list[str] = []
    d2h_calls = 0
    for node in ast.walk(tree):
        if isinstance(node, ast.Name):
            tokens.add(node.id)
        elif isinstance(node, ast.Constant) and isinstance(node.value, str):
            tokens.add(node.value)
        if not isinstance(node, ast.Call) or not isinstance(node.func, ast.Attribute):
            continue
        if node.func.attr in {"memcpy_d2h", "memcpy_d2h_async"}:
            d2h_calls += 1
        if node.func.attr in {"launch", "call"} and node.args:
            first = node.args[0]
            if isinstance(first, ast.Constant) and isinstance(first.value, str):
                launches.append(first.value)
    return tokens, launches, d2h_calls


def _safe_relative_path(root: Path, value: Any, *, label: str) -> tuple[Path, str]:
    relative = Path(str(value or ""))
    if not relative.parts or relative.is_absolute() or ".." in relative.parts:
        raise ValidationError(f"{label} must be a non-empty path relative to the bundle")
    path = root / relative
    try:
        path.resolve().relative_to(root.resolve())
    except ValueError as exc:
        raise ValidationError(f"{label} escapes the bundle: {relative}") from exc
    return path, relative.as_posix()


def _anchor_span(
    text: str,
    edit: Mapping[str, Any],
    *,
    label: str,
) -> tuple[int, int]:
    anchor = edit.get("anchor")
    if not isinstance(anchor, str) or not anchor:
        raise ValidationError(f"{label}.anchor must be non-empty literal source text")
    declared_anchor_hash = edit.get("anchor_sha256")
    if declared_anchor_hash is not None and declared_anchor_hash != _text_sha256(anchor):
        raise ValidationError(f"{label}.anchor_sha256 does not identify its literal anchor")

    scope_start = 0
    scope_end = len(text)
    function = edit.get("function")
    if function is not None:
        if not isinstance(function, str) or not function:
            raise ValidationError(f"{label}.function must be a non-empty CSL fn/task name")
        bounds = _find_named_body(text, function)
        if not bounds:
            raise ValidationError(f"{label} function {function!r} is absent")
        _, scope_start, scope_end = bounds
    positions: list[int] = []
    cursor = scope_start
    while True:
        position = text.find(anchor, cursor, scope_end)
        if position < 0:
            break
        positions.append(position)
        cursor = position + max(1, len(anchor))
    if len(positions) != 1:
        scope = f"function {function!r}" if function else "file"
        raise ValidationError(
            f"{label}.anchor must occur exactly once in its {scope}; found {len(positions)}"
        )
    return positions[0], positions[0] + len(anchor)


def _line_insertion_offset(text: str, span: tuple[int, int], position: Any, *, label: str) -> int:
    if position not in {"before", "after"}:
        raise ValidationError(f"{label}.position must be before or after")
    start, end = span
    if position == "before":
        return text.rfind("\n", 0, start) + 1
    line_end = text.find("\n", end)
    return len(text) if line_end < 0 else line_end + 1


def _line_indentation(text: str, span: tuple[int, int]) -> str:
    line_start = text.rfind("\n", 0, span[0]) + 1
    return re.match(r"[ \t]*", text[line_start:span[0]]).group(0)  # type: ignore[union-attr]


def _protected_region(
    root: Path,
    record: Mapping[str, Any],
    *,
    label: str,
) -> tuple[str, int, int, str]:
    path, relative = _safe_relative_path(root, record.get("file"), label=f"{label}.file")
    if not path.is_file():
        raise ValidationError(f"{label} file does not exist: {relative}")
    text = path.read_text(encoding="utf-8")
    start_marker = record.get("start_marker")
    end_marker = record.get("end_marker")
    if not isinstance(start_marker, str) or not start_marker:
        raise ValidationError(f"{label}.start_marker must be non-empty")
    if not isinstance(end_marker, str) or not end_marker:
        raise ValidationError(f"{label}.end_marker must be non-empty")
    if text.count(start_marker) != 1 or text.count(end_marker) != 1:
        raise ValidationError(f"{label} markers must each occur exactly once")
    start = text.index(start_marker)
    end = text.index(end_marker, start) + len(end_marker)
    if end <= start:
        raise ValidationError(f"{label} end marker does not follow its start marker")
    region = text[start:end]
    if record.get("sha256") != _text_sha256(region):
        raise ValidationError(f"{label}.sha256 does not identify the protected correctness text")
    return relative, start, end, region


def _validate_sync_materialization_contract(spec: Mapping[str, Any]) -> None:
    sync = spec.get("sync")
    if not isinstance(sync, Mapping):
        raise ValidationError("sync must be an object")
    if sync.get("protocol") != "sdk_2.10_bandwidth_test":
        raise ValidationError("sync protocol must be sdk_2.10_bandwidth_test")
    if sync.get("reference_hashes") != _official_sync_reference():
        raise ValidationError("sync reference hashes do not identify the vendored SDK 2.10 module")
    snapshot = sync.get("inventory_snapshot")
    if (
        sync.get("collision_check") != "passed"
        or not isinstance(snapshot, Mapping)
        or sync.get("inventory_hash") != canonical_hash(snapshot)
    ):
        raise ValidationError("sync resources need a passed collision check and compiled inventory hash")
    if snapshot.get("qualification_status") != "qualified":
        raise ValidationError("sync collision checking requires a campaign-qualified compiled layout")
    used = snapshot.get("used_resources")
    if not isinstance(used, Mapping):
        raise ValidationError("compiled inventory snapshot has no resource ledger")
    expected_counts = {
        "colors": 5,
        "input_queues": 3,
        "output_queues": 3,
        "local_task_ids": 4,
    }
    for field, expected_count in expected_counts.items():
        values = sync.get(field)
        if not isinstance(values, list) or len(values) != expected_count:
            raise ValidationError(f"sync.{field} must contain exactly {expected_count} reserved values")
        if len({json.dumps(item, sort_keys=True) for item in values}) != len(values):
            raise ValidationError(f"sync.{field} contains duplicate reserved values")
        used_values = used.get(field)
        if not isinstance(used_values, list):
            raise ValidationError(f"compiled inventory does not resolve used {field}")
        reserved_keys = {json.dumps(item, sort_keys=True) for item in values}
        used_keys = {json.dumps(item, sort_keys=True) for item in used_values}
        overlap = sorted(reserved_keys & used_keys)
        if overlap:
            raise ValidationError(f"sync.{field} collides with compiled resources: {overlap}")
    for field in ("input_queues", "output_queues"):
        if any(not isinstance(value, int) or isinstance(value, bool) or not 0 <= value <= 7 for value in sync[field]):
            raise ValidationError(f"sync.{field} values must be physical queue IDs 0-7")
    for field in ("colors", "local_task_ids"):
        if any(
            not isinstance(value, int) or isinstance(value, bool) or value < 0
            for value in sync[field]
        ):
            raise ValidationError(
                f"sync.{field} must contain resolved non-negative compiler IDs, not symbolic names"
            )


def _validate_execution_materialization_contract(materialization: Mapping[str, Any]) -> None:
    contract = materialization.get("execution_contract")
    if not isinstance(contract, Mapping):
        raise ValidationError("materialization.execution_contract must be an object")
    entrypoint = contract.get("single_device_entrypoint")
    if not isinstance(entrypoint, str) or not entrypoint:
        raise ValidationError("execution_contract.single_device_entrypoint is required")
    if contract.get("sync_before_compute") is not True:
        raise ValidationError("execution_contract must attest sync_before_compute")
    if contract.get("host_rpc_inside_timed_window") is not False:
        raise ValidationError("execution_contract must attest no host RPC inside the timed window")
    if contract.get("operator_attested") is not True:
        raise ValidationError("execution_contract.operator_attested must be true")
    coverage = materialization.get("program_coverage")
    if not isinstance(coverage, Mapping) or coverage.get("status") != "passed":
        raise ValidationError("materialization.program_coverage must pass against compiled inventory")
    required = coverage.get("required_programs")
    covered = coverage.get("covered_programs")
    program_files = coverage.get("program_files")
    if (
        not isinstance(required, list)
        or not required
        or not isinstance(covered, list)
        or sorted(str(value) for value in required) != sorted(str(value) for value in covered)
    ):
        raise ValidationError("every required PE program must be explicitly covered")
    if (
        not isinstance(program_files, Mapping)
        or {str(key) for key in program_files} != {str(value) for value in required}
    ):
        raise ValidationError("program_coverage.program_files must map every compiled program")


def _validate_export_materialization_contract(spec: Mapping[str, Any]) -> None:
    exports = spec.get("exports")
    if not isinstance(exports, Mapping):
        raise ValidationError("exports must be an object")
    for key in ("phase_words", "phase_valid", "raw_perf", "sync_reference"):
        value = exports.get(key)
        if not isinstance(value, str) or not re.fullmatch(r"[A-Za-z_]\w*", value):
            raise ValidationError(f"exports.{key} must be an explicit host/CSL symbol")
    if exports.get("host_d2h_verified") is not True or exports.get("per_pe_geometry_verified") is not True:
        raise ValidationError("exports must attest host D2H and exact per-PE geometry")
    record = exports.get("per_pe_record")
    if not isinstance(record, Mapping):
        raise ValidationError("exports.per_pe_record must describe the exact D2H shape")
    expected = {
        "phase_count": 7,
        "timestamp_words_per_phase": 3,
        "phase_valid_words": 7,
        "raw_perf_words": 6,
        "sync_reference_words": 3,
    }
    for key, value in expected.items():
        if record.get(key) != value:
            raise ValidationError(f"exports.per_pe_record.{key} must be {value}")
    if not isinstance(record.get("coordinate_order"), str) or not record.get("coordinate_order"):
        raise ValidationError("exports.per_pe_record.coordinate_order is required")
    rectangle = record.get("logical_rectangle")
    if not isinstance(rectangle, Mapping) or any(
        rectangle.get(key) is None or rectangle.get(key) == ""
        for key in ("x", "y", "width", "height")
    ):
        raise ValidationError("exports.per_pe_record.logical_rectangle must define x/y/width/height")


def _plan_full_telemetry_insertions(
    root: Path,
    spec: Mapping[str, Any],
) -> tuple[dict[str, list[dict[str, Any]]], list[dict[str, Any]], list[dict[str, Any]]]:
    """Validate and plan exact-anchor edits against the unmodified source."""

    materialization = spec.get("materialization")
    if not isinstance(materialization, Mapping):
        raise ValidationError("materialization must be an object")
    if materialization.get("status") != "ready_to_materialize":
        raise ValidationError("materialization.status must be ready_to_materialize")
    _validate_execution_materialization_contract(materialization)
    _validate_sync_materialization_contract(spec)
    _validate_export_materialization_contract(spec)
    if (materialization.get("program_coverage") or {}).get("inventory_hash") != (
        spec.get("sync") or {}
    ).get("inventory_hash"):
        raise ValidationError("program coverage and sync collision audit must use the same inventory hash")
    snapshot_programs = sorted(
        str(value)
        for value in ((spec.get("sync") or {}).get("inventory_snapshot") or {}).get(
            "application_programs", []
        )
    )
    covered_programs = sorted(
        str(value)
        for value in (materialization.get("program_coverage") or {}).get(
            "required_programs", []
        )
    )
    if not snapshot_programs or snapshot_programs != covered_programs:
        raise ValidationError(
            "program coverage does not exactly match compiled application PE programs"
        )
    run_path = root / "run.py"
    if not run_path.is_file() or spec.get("run_py_sha256") != hash_file(run_path):
        raise ValidationError("run_py_sha256 does not identify the unmodified host program")
    correctness = spec.get("correctness")
    if (
        not isinstance(correctness, Mapping)
        or correctness.get("original_run_py_sha256") != hash_file(run_path)
        or correctness.get("original_check_preserved") is not True
    ):
        raise ValidationError(
            "correctness must bind run.py and attest that protected regions cover the original check"
        )

    source_hashes = materialization.get("source_file_sha256")
    if not isinstance(source_hashes, Mapping) or not source_hashes:
        raise ValidationError("materialization.source_file_sha256 must identify every edited file")
    normalized_hashes: dict[str, str] = {}
    for relative_value, expected_hash in source_hashes.items():
        path, relative = _safe_relative_path(root, relative_value, label="source_file_sha256 key")
        if not path.is_file():
            raise ValidationError(f"source_file_sha256 file is absent: {relative}")
        if expected_hash != hash_file(path):
            raise ValidationError(f"source file hash changed before materialization: {relative}")
        normalized_hashes[relative] = str(expected_hash)

    protected_raw = materialization.get("protected_regions")
    if not isinstance(protected_raw, list) or not protected_raw:
        raise ValidationError("at least one exact protected correctness region is required")
    protected: list[dict[str, Any]] = []
    for index, raw in enumerate(protected_raw):
        if not isinstance(raw, Mapping):
            raise ValidationError(f"protected_regions[{index}] is not an object")
        relative, start, end, region = _protected_region(
            root, raw, label=f"protected_regions[{index}]"
        )
        protected.append(
            {
                "file": relative,
                "start": start,
                "end": end,
                "sha256": _text_sha256(region),
                "start_marker": raw["start_marker"],
                "end_marker": raw["end_marker"],
            }
        )
    if not any(record["file"] == "run.py" for record in protected):
        raise ValidationError("a run.py correctness region must be protected")

    planned: dict[str, list[dict[str, Any]]] = {}
    audit_sites: list[dict[str, Any]] = []
    roles: set[str] = set()

    def plan(
        raw: Mapping[str, Any],
        *,
        label: str,
        insertion: str,
        kind: str,
        metadata: Mapping[str, Any] | None = None,
        allow_replace: bool = False,
    ) -> None:
        path, relative = _safe_relative_path(root, raw.get("file"), label=f"{label}.file")
        if relative not in normalized_hashes:
            raise ValidationError(f"{label} edits {relative} without a source_file_sha256 entry")
        text = path.read_text(encoding="utf-8")
        span = _anchor_span(text, raw, label=label)
        position = raw.get("position")
        if position == "replace":
            if not allow_replace:
                raise ValidationError(f"{label} may not replace source text")
            offset, end_offset = span
        else:
            offset = _line_insertion_offset(text, span, position, label=label)
            end_offset = offset
        if any(
            region["file"] == relative
            and not (end_offset < region["start"] or offset > region["end"])
            for region in protected
        ):
            raise ValidationError(f"{label} would edit a protected correctness region")
        if not insertion.endswith("\n"):
            insertion += "\n"
        record = {
            "file": relative,
            "function": raw.get("function"),
            "anchor": raw.get("anchor"),
            "anchor_sha256": _text_sha256(str(raw.get("anchor"))),
            "position": raw.get("position"),
            "offset": offset,
            "end_offset": end_offset,
            "sequence": raw.get("sequence"),
            "removed_sha256": _text_sha256(text[offset:end_offset]),
            "inserted_sha256": _text_sha256(insertion),
            "inserted_text": insertion,
            "kind": kind,
            **dict(metadata or {}),
        }
        planned.setdefault(relative, []).append(record)
        audit_sites.append(record)

    integration = materialization.get("integration_edits")
    if not isinstance(integration, list):
        raise ValidationError("materialization.integration_edits must be a list")
    for index, raw in enumerate(integration):
        if not isinstance(raw, Mapping):
            raise ValidationError(f"integration_edits[{index}] is not an object")
        role = raw.get("role")
        if role not in _FULL_REQUIRED_ROLES:
            raise ValidationError(
                f"integration_edits[{index}].role must be one of {sorted(_FULL_REQUIRED_ROLES)}"
            )
        text = raw.get("text")
        if not isinstance(text, str) or not text.strip():
            raise ValidationError(f"integration_edits[{index}].text must be non-empty")
        role_requirements = {
            "profile_import": ("wse3study/profile_timestamp.csl",),
            "sync_layout_wiring": ("wse3study/sync/layout.csl",),
            "sync_pe_import": ("wse3study/sync/pe.csl",),
            "sync_host_launch": (
                str((materialization.get("execution_contract") or {}).get("single_device_entrypoint") or ""),
            ),
            "telemetry_csl_export": tuple(
                str((spec.get("exports") or {}).get(key) or "")
                for key in ("phase_words", "phase_valid", "raw_perf", "sync_reference")
            ),
            "telemetry_host_d2h": tuple(
                str((spec.get("exports") or {}).get(key) or "")
                for key in ("phase_words", "phase_valid", "raw_perf", "sync_reference")
            ) + ("memcpy_d2h",),
        }
        missing_tokens = [
            token for token in role_requirements.get(str(role), ()) if not token or token not in text
        ]
        if missing_tokens:
            raise ValidationError(
                f"integration_edits[{index}] role {role} lacks required literal token(s): {missing_tokens}"
            )
        if role == "sync_host_launch" and not re.search(r"\.(?:launch|call)\s*\(", text):
            raise ValidationError(
                f"integration_edits[{index}] sync_host_launch has no explicit appliance launch/call"
            )
        roles.add(str(role))
        plan(
            raw,
            label=f"integration_edits[{index}]",
            insertion=text,
            kind="integration",
            metadata={"role": role},
            allow_replace=True,
        )
    missing_roles = _FULL_REQUIRED_ROLES - roles
    if missing_roles:
        raise ValidationError(f"missing explicit integration edit roles: {sorted(missing_roles)}")

    phases = spec.get("phases")
    omissions = spec.get("omitted_phases")
    if not isinstance(phases, Mapping) or not isinstance(omissions, Mapping):
        raise ValidationError("phases and omitted_phases must be objects")
    omittable = {"first_send", "first_receive", "last_receive"}
    for phase_index, phase in enumerate(PHASES):
        sites = phases.get(phase)
        if not sites:
            rationale = omissions.get(phase)
            if phase not in omittable or not isinstance(rationale, str) or not rationale.strip():
                raise ValidationError(f"phase {phase} needs an exact site or a permitted rationale")
            continue
        if not isinstance(sites, list):
            raise ValidationError(f"phase {phase} sites must be a list")
        for site_index, raw in enumerate(sites):
            if not isinstance(raw, Mapping):
                raise ValidationError(f"phase {phase} site {site_index} is not an object")
            alias = raw.get("profile_alias")
            if not isinstance(alias, str) or not re.fullmatch(r"[A-Za-z_]\w*", alias):
                raise ValidationError(f"phase {phase} site {site_index} needs an explicit profile_alias")
            if phase == "sync_reference":
                reference = raw.get("reference_expression")
                if not isinstance(reference, str) or not reference.strip() or "\n" in reference:
                    raise ValidationError("sync_reference site needs a one-line reference_expression")
                call = f"{alias}.mark_sync_reference({reference});"
            else:
                call = f"{alias}.mark({phase_index});"
            phase_path, _ = _safe_relative_path(
                root, raw.get("file"), label=f"phase {phase} site {site_index}.file"
            )
            phase_text = phase_path.read_text(encoding="utf-8")
            indentation = _line_indentation(
                phase_text,
                _anchor_span(
                    phase_text,
                    raw,
                    label=f"phase {phase} site {site_index}",
                ),
            )
            insertion = f"{indentation}{call} // WSE3STUDY phase={phase}\n"
            plan(
                raw,
                label=f"phase {phase} site {site_index}",
                insertion=insertion,
                kind="phase",
                metadata={"phase": phase, "phase_index": phase_index, "expected_call": call},
            )

    counters = materialization.get("counter_sites")
    if not isinstance(counters, list) or not counters:
        raise ValidationError("materialization.counter_sites needs at least one exact sampling site")
    for index, raw in enumerate(counters):
        if not isinstance(raw, Mapping):
            raise ValidationError(f"counter_sites[{index}] is not an object")
        alias = raw.get("profile_alias")
        if not isinstance(alias, str) or not re.fullmatch(r"[A-Za-z_]\w*", alias):
            raise ValidationError(f"counter_sites[{index}] needs an explicit profile_alias")
        path, _ = _safe_relative_path(root, raw.get("file"), label=f"counter_sites[{index}].file")
        original = path.read_text(encoding="utf-8")
        span = _anchor_span(original, raw, label=f"counter_sites[{index}]")
        insertion = (
            f"{_line_indentation(original, span)}{alias}.sample_raw_perf_counters(); "
            "// WSE3STUDY raw_perf_slots=0,1 semantics=unknown_raw\n"
        )
        plan(raw, label=f"counter_sites[{index}]", insertion=insertion, kind="raw_perf")

    coverage = materialization.get("program_coverage") or {}
    program_files = coverage.get("program_files") or {}
    program_omissions = coverage.get("omitted_phases") or {}
    if not isinstance(program_omissions, Mapping):
        raise ValidationError("program_coverage.omitted_phases must be an object")
    required_phases = {
        phase for phase in PHASES if not ((not phases.get(phase)) and phase in omissions)
    }
    for program, relative_value in program_files.items():
        _, relative = _safe_relative_path(
            root, relative_value, label=f"program_coverage.program_files[{program!r}]"
        )
        observed_phases = {
            str(site.get("phase"))
            for site in audit_sites
            if site.get("kind") == "phase" and site.get("file") == relative
        }
        missing_phases = sorted(required_phases - observed_phases)
        omission_record = program_omissions.get(program) or {}
        if not isinstance(omission_record, Mapping):
            raise ValidationError(
                f"program_coverage.omitted_phases[{program!r}] must be an object"
            )
        unjustified = [
            phase
            for phase in missing_phases
            if phase not in {"first_send", "first_receive", "last_receive"}
            or not isinstance(omission_record.get(phase), str)
            or not str(omission_record.get(phase)).strip()
        ]
        if unjustified:
            raise ValidationError(
                f"compiled PE program {program!r} lacks phase sites {unjustified} in {relative}"
            )
        if not any(
            site.get("kind") == "raw_perf" and site.get("file") == relative
            for site in audit_sites
        ):
            raise ValidationError(
                f"compiled PE program {program!r} has no raw counter site in {relative}"
            )
        program_roles = {
            str(site.get("role"))
            for site in audit_sites
            if site.get("kind") == "integration" and site.get("file") == relative
        }
        missing_program_roles = {
            "profile_import", "sync_pe_import", "telemetry_csl_export"
        } - program_roles
        if missing_program_roles:
            raise ValidationError(
                f"compiled PE program {program!r} lacks integration roles "
                f"{sorted(missing_program_roles)} in {relative}"
            )

    for relative, edits in planned.items():
        intervals = sorted(
            (
                (int(edit["offset"]), int(edit["end_offset"]), edit)
                for edit in edits
            ),
            key=lambda item: (item[0], item[1]),
        )
        for index, prior in enumerate(intervals):
            for current in intervals[index + 1 :]:
                if current[0] > prior[1]:
                    break
                same_boundary = (
                    prior[0] == prior[1] == current[0] == current[1]
                )
                if same_boundary:
                    sequences = (prior[2].get("sequence"), current[2].get("sequence"))
                    if (
                        all(isinstance(value, int) and not isinstance(value, bool) for value in sequences)
                        and sequences[0] != sequences[1]
                    ):
                        continue
                raise ValidationError(
                    f"edits overlap or ambiguously share a boundary in {relative}; "
                    "use distinct anchors or unique integer sequence values"
                )
    return planned, audit_sites, protected


def _apply_planned_insertions(root: Path, planned: Mapping[str, Sequence[Mapping[str, Any]]]) -> None:
    for relative, edits in planned.items():
        path = root / relative
        text = path.read_text(encoding="utf-8")
        for edit in sorted(
            edits,
            key=lambda item: (
                int(item["offset"]),
                int(item.get("sequence")) if isinstance(item.get("sequence"), int) else 0,
            ),
            reverse=True,
        ):
            offset = int(edit["offset"])
            end_offset = int(edit["end_offset"])
            text = text[:offset] + str(edit["inserted_text"]) + text[end_offset:]
        path.write_text(text, encoding="utf-8")


def _copy_full_telemetry_modules(root: Path) -> dict[str, Any]:
    study_root = Path(__file__).resolve().parents[1]
    sources = {
        "wse3study/profile_timestamp.csl": study_root / "instrumentation" / "profile_timestamp.csl",
        "wse3study/sync/layout.csl": study_root / "calibration" / "official_sync" / "layout.csl",
        "wse3study/sync/pe.csl": study_root / "calibration" / "official_sync" / "pe.csl",
    }
    copied: dict[str, dict[str, str]] = {}
    for relative, source in sources.items():
        if not source.is_file():
            raise ValidationError(f"required study module is missing: {source}")
        destination = root / relative
        if destination.exists():
            raise ValidationError(f"refusing to overwrite pre-existing telemetry module: {relative}")
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, destination)
        copied[relative] = {
            "sha256": hash_file(destination),
            "source": str(source),
            "evidence": "documented" if "/sync/" in relative else "compiled",
        }
    return copied


def _check_protected_regions(root: Path, protected: Sequence[Mapping[str, Any]]) -> list[str]:
    errors: list[str] = []
    for index, record in enumerate(protected):
        try:
            _, _, _, region = _protected_region(root, record, label=f"protected_regions[{index}]")
        except ValidationError as exc:
            errors.append(str(exc))
            continue
        if _text_sha256(region) != record.get("sha256"):
            errors.append(f"protected correctness region {index} changed")
    return errors


def validate_materialized_full_telemetry_adapter(bundle: str | Path) -> dict[str, Any]:
    """Re-audit a generated full adapter without trusting its ready status."""

    root = Path(bundle).resolve()
    path = root / FULL_ADAPTER_MANIFEST
    try:
        manifest = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        return {"status": "needs_override", "errors": [f"cannot read {path}: {exc}"]}
    errors: list[str] = []
    if not isinstance(manifest, Mapping):
        return {"status": "needs_override", "errors": ["full adapter manifest is not an object"]}
    if manifest.get("schema_version") != "1.0.0":
        errors.append("full adapter manifest schema is not 1.0.0")
    if manifest.get("telemetry_level") != "full":
        errors.append("full adapter telemetry_level is not full")
    if manifest.get("generator_sha256") != full_telemetry_generator_hash():
        errors.append("full adapter was produced by a different materializer generator")
    if manifest.get("source_hash_after") != _adapter_source_hash(root):
        errors.append("materialized source hash no longer matches the manifest")
    override_file = manifest.get("override_file")
    try:
        override_path, _ = _safe_relative_path(root, override_file, label="override_file")
        override_value = json.loads(override_path.read_text(encoding="utf-8"))
    except (ValidationError, OSError, json.JSONDecodeError) as exc:
        errors.append(f"retained override is absent or invalid: {exc}")
    else:
        if manifest.get("override_sha256") != canonical_hash(override_value):
            errors.append("retained override hash no longer matches the manifest")
    modules = manifest.get("vendored_modules")
    if not isinstance(modules, Mapping):
        errors.append("vendored module inventory is absent")
    else:
        for relative, record in modules.items():
            module_path, normalized = _safe_relative_path(root, relative, label="vendored module")
            expected = record.get("sha256") if isinstance(record, Mapping) else None
            if normalized != relative or not module_path.is_file() or hash_file(module_path) != expected:
                errors.append(f"vendored module changed or is absent: {relative}")
    output_hashes = manifest.get("output_file_sha256")
    if not isinstance(output_hashes, Mapping):
        errors.append("output file hashes are absent")
    else:
        for relative, expected in output_hashes.items():
            output_path, normalized = _safe_relative_path(root, relative, label="output file")
            if normalized != relative or not output_path.is_file() or hash_file(output_path) != expected:
                errors.append(f"materialized output file changed or is absent: {relative}")

    sites = manifest.get("insertions")
    if not isinstance(sites, list):
        errors.append("insertion audit is absent")
        sites = []
    for index, record in enumerate(sites):
        if not isinstance(record, Mapping):
            errors.append(f"insertion {index} is not an object")
            continue
        insertion = record.get("inserted_text")
        relative = record.get("file")
        try:
            output_path, _ = _safe_relative_path(root, relative, label=f"insertion {index} file")
            text = output_path.read_text(encoding="utf-8")
        except (ValidationError, OSError) as exc:
            errors.append(str(exc))
            continue
        if not isinstance(insertion, str) or record.get("inserted_sha256") != _text_sha256(insertion):
            errors.append(f"insertion {index} text hash is invalid")
        elif text.count(insertion) != 1:
            errors.append(f"insertion {index} is not present exactly once in {relative}")

    protected = manifest.get("protected_regions")
    if not isinstance(protected, list):
        errors.append("protected correctness regions are absent")
    else:
        errors.extend(_check_protected_regions(root, protected))

    exports = manifest.get("exports")
    host_path = root / "run.py"
    host = host_path.read_text(encoding="utf-8") if host_path.is_file() else ""
    csl = "\n".join(
        candidate.read_text(encoding="utf-8", errors="ignore")
        for candidate in root.rglob("*.csl")
    )
    csl_code = _csl_without_comments(csl)
    try:
        host_tokens, launches, d2h_calls = _python_source_contract(host)
    except ValidationError as exc:
        errors.append(str(exc))
        host_tokens, launches, d2h_calls = set(), [], 0
    if not isinstance(exports, Mapping):
        errors.append("telemetry export contract is absent")
    else:
        try:
            _validate_export_materialization_contract({"exports": exports})
        except ValidationError as exc:
            errors.append(str(exc))
        for key in ("phase_words", "phase_valid", "raw_perf", "sync_reference"):
            symbol = exports.get(key)
            if (
                not isinstance(symbol, str)
                or not symbol
                or symbol not in csl_code
                or symbol not in host_tokens
            ):
                errors.append(f"export {key} is not named in both CSL and host source")
        if d2h_calls == 0:
            errors.append("materialized host source has no D2H operation")

    for module in (
        "wse3study/profile_timestamp.csl",
        "wse3study/sync/layout.csl",
        "wse3study/sync/pe.csl",
    ):
        if module not in csl_code:
            errors.append(f"materialized CSL does not code-import/wire {module}")
    if (
        "raw_perf_slots=0,1 semantics=unknown_raw" not in csl
        or ".sample_raw_perf_counters()" not in csl_code
    ):
        errors.append("raw performance counter sampling marker is absent")
    for index, phase in enumerate(PHASES):
        phase_contract = (manifest.get("phases") or {}).get(phase)
        if isinstance(phase_contract, Mapping) and phase_contract.get("status") == "omitted":
            continue
        marker = f"// WSE3STUDY phase={phase}"
        expected = "mark_sync_reference" if index == 0 else f"mark({index})"
        if marker not in csl or expected not in csl_code:
            errors.append(f"materialized phase {phase} mark is absent")
    timing = manifest.get("timing")
    execution = timing.get("execution_contract") if isinstance(timing, Mapping) else None
    entrypoint = execution.get("single_device_entrypoint") if isinstance(execution, Mapping) else None
    if not isinstance(entrypoint, str) or launches.count(entrypoint) != 1:
        errors.append("host must launch the attested single full-telemetry entrypoint exactly once")

    return {
        **dict(manifest),
        "status": "ready_for_compile" if not errors else "needs_override",
        "errors": errors,
        "compile_required": True,
        "correctness_run_required": True,
        "silicon_overhead_comparison_required": True,
    }


def _fsync_materialized_tree(root: Path) -> None:
    for path in sorted(root.rglob("*")):
        if path.is_file():
            with path.open("rb") as handle:
                os.fsync(handle.fileno())
    directory_fd = os.open(root, os.O_RDONLY)
    try:
        os.fsync(directory_fd)
    finally:
        os.close(directory_fd)


def materialize_full_telemetry_adapter(
    bundle: str | Path,
    override: Mapping[str, Any] | str | Path,
    destination: str | Path,
) -> dict[str, Any]:
    """Create an isolated, exact-anchor full-telemetry study bundle.

    No route, task, callback, phase, or host-buffer site is inferred.  The
    override must identify every edit by a unique literal anchor and must hash
    every touched input file.  Materialization happens in a sibling temporary
    tree and becomes visible with one rename; the input bundle is never edited.
    """

    source = Path(bundle).resolve()
    target_input = Path(destination).expanduser()
    if target_input.is_symlink():
        raise ValidationError("full telemetry destination may not be a symbolic link")
    target = target_input.resolve()
    if not source.is_dir():
        raise ValidationError(f"source bundle is not a directory: {source}")
    if source == target or source in target.parents or target in source.parents:
        raise ValidationError("full telemetry destination must be a separate sibling study copy")
    spec = _load_override(override)
    if spec.get("schema_version") != "1.0.0":
        raise ValidationError("full telemetry materializer requires override schema 1.0.0")
    if spec.get("telemetry_level") != "full":
        raise ValidationError("telemetry_level must be full")
    source_hash = _adapter_source_hash(source)
    if spec.get("bundle_source_hash") != source_hash:
        raise ValidationError("bundle_source_hash does not identify the input bundle")
    materialization = spec.get("materialization")
    if not isinstance(materialization, Mapping):
        raise ValidationError("materialization must be an object")
    declared_destination = materialization.get("destination")
    if declared_destination not in (None, ""):
        raise ValidationError(
            "materialization.destination must remain null; the campaign derives a versioned path "
            "from endpoint and override hashes"
        )

    override_hash = canonical_hash(spec)
    if target.exists() or target.is_symlink():
        audit = validate_materialized_full_telemetry_adapter(target)
        if (
            audit.get("status") == "ready_for_compile"
            and audit.get("source_bundle_sha256") == source_hash
            and audit.get("override_sha256") == override_hash
            and audit.get("generator_sha256") == full_telemetry_generator_hash()
        ):
            return audit
        raise ValidationError(
            f"refusing to overwrite existing full telemetry destination {target}: "
            + "; ".join(audit.get("errors") or ["identity differs from this override"])
        )

    planned, insertion_audit, protected = _plan_full_telemetry_insertions(source, spec)
    target.parent.mkdir(parents=True, exist_ok=True)
    temporary_parent = Path(tempfile.mkdtemp(prefix=f".{target.name}-", dir=target.parent))
    temporary = temporary_parent / "bundle"
    try:
        shutil.copytree(source, temporary)
        modules = _copy_full_telemetry_modules(temporary)
        _apply_planned_insertions(temporary, planned)

        # Re-express protected regions without positional offsets: insertion
        # before a region may move it, but its exact marker-bounded bytes must
        # remain unchanged.
        protected_manifest = [
            {
                "file": record["file"],
                "start_marker": record["start_marker"],
                "end_marker": record["end_marker"],
                "sha256": record["sha256"],
            }
            for record in protected
        ]
        protected_errors = _check_protected_regions(temporary, protected_manifest)
        if protected_errors:
            raise ValidationError("; ".join(protected_errors))

        exports = spec.get("exports")
        if not isinstance(exports, Mapping):
            raise ValidationError("exports must be an object")
        if exports.get("host_d2h_verified") is not True or exports.get("per_pe_geometry_verified") is not True:
            raise ValidationError("exports must attest host D2H and exact per-PE geometry")
        counters = spec.get("raw_performance_counters")
        if not isinstance(counters, Mapping) or counters.get("ids") != [0, 1]:
            raise ValidationError("raw performance counter IDs must be exactly [0, 1]")
        if counters.get("event_semantics") not in (None, "unknown_raw"):
            raise ValidationError("raw performance counter semantics must remain unknown_raw")

        output_files = sorted({*planned, *modules})
        output_hashes = {relative: hash_file(temporary / relative) for relative in output_files}
        phase_manifest: dict[str, Any] = {}
        omissions = spec.get("omitted_phases") or {}
        for phase in PHASES:
            sites = (spec.get("phases") or {}).get(phase) or []
            if sites:
                phase_manifest[phase] = {
                    "status": "source_instrumented",
                    "sites": [
                        {
                            "file": site.get("file"),
                            "function": site.get("function"),
                            "marker": f"// WSE3STUDY phase={phase}",
                        }
                        for site in sites
                    ],
                    "evidence": "inferred",
                }
            else:
                phase_manifest[phase] = {
                    "status": "omitted",
                    "reason": omissions.get(phase),
                    "evidence": "inferred",
                }

        run_path = temporary / "run.py"
        override_relative = ".wse3study_full_override.json"
        atomic_write_json(temporary / override_relative, spec)
        sync_manifest = dict(spec.get("sync") or {})
        sync_manifest["vendored_files"] = {
            "layout.csl": "wse3study/sync/layout.csl",
            "pe.csl": "wse3study/sync/pe.csl",
        }
        manifest = {
            "schema_version": "1.0.0",
            "status": "ready_for_compile",
            "telemetry_level": "full",
            "telemetry_levels": ["full"],
            "generated_at": utc_now(),
            "bundle": str(target),
            "source_bundle": str(source),
            "source_bundle_sha256": source_hash,
            "source_hash_after": _adapter_source_hash(temporary),
            "override_sha256": override_hash,
            "override_file": override_relative,
            "generator_version": FULL_ADAPTER_GENERATOR_VERSION,
            "generator_sha256": full_telemetry_generator_hash(),
            "input_file_sha256": dict(materialization.get("source_file_sha256") or {}),
            "output_file_sha256": output_hashes,
            "vendored_modules": modules,
            "insertions": insertion_audit,
            "phases": phase_manifest,
            "sync": sync_manifest,
            "exports": dict(exports),
            "raw_performance_counters": {
                "ids": [0, 1],
                "names": ["perf_counter_0_raw", "perf_counter_1_raw"],
                "event_semantics": "unknown_raw",
                "evidence": "documented",
            },
            "protected_regions": protected_manifest,
            "program_coverage": dict(materialization.get("program_coverage") or {}),
            "correctness": {
                "original_run_py_sha256": spec.get("run_py_sha256"),
                "materialized_run_py_sha256": hash_file(run_path) if run_path.is_file() else None,
                "protected_correctness_regions_unchanged": True,
                "original_check_required": True,
                "status": "requires_execution",
            },
            "timing": {
                "method": "device_internal",
                "official_cross_pe_sync": True,
                "host_rpc_inside_window": False,
                "execution_contract": dict(materialization.get("execution_contract") or {}),
            },
            "compile_required": True,
            "correctness_run_required": True,
            "silicon_overhead_comparison_required": True,
            "headline_threshold_percent": 5,
            "campaign_binding": {
                "status": "blocked_until_compile_correctness_and_d2h_schema",
                "reason": (
                    "source audit is inferred evidence; the materialized layout-specific adapter "
                    "must compile and preserve the original numerical check before scheduling"
                ),
                "compile_validation": {"status": "pending"},
                "correctness_validation": {"status": "pending"},
                "d2h_schema_validation": {"status": "pending"},
            },
            "evidence": "inferred",
        }
        atomic_write_json(temporary / FULL_ADAPTER_MANIFEST, manifest)
        audit = validate_materialized_full_telemetry_adapter(temporary)
        if audit.get("status") != "ready_for_compile":
            raise ValidationError("materialized full adapter failed self-audit: " + "; ".join(audit["errors"]))
        _fsync_materialized_tree(temporary)
        temporary.rename(target)
        parent_fd = os.open(target.parent, os.O_RDONLY)
        try:
            os.fsync(parent_fd)
        finally:
            os.close(parent_fd)
    except BaseException:
        shutil.rmtree(temporary_parent, ignore_errors=True)
        raise
    else:
        shutil.rmtree(temporary_parent, ignore_errors=True)
    return validate_materialized_full_telemetry_adapter(target)
