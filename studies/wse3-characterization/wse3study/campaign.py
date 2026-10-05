"""Safe, resumable execution for WSE-3 characterization campaigns.

Nothing in this module submits work merely by being imported.  The public
``run_requests`` entry point is a dry-run unless ``execute=True`` is supplied,
and production runners are loaded lazily so offline inventory/report workflows
do not require the appliance SDK.
"""

from __future__ import annotations

import importlib.metadata
import importlib.util
import json
import os
import platform
import re
import shutil
import subprocess
import sys
import tempfile
import time
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Callable, Iterable, Mapping, Protocol, Sequence

from .artifact_binding import compile_record
from .calibration import CalibrationCase
from .instrumentation import (
    ADAPTER_SCHEMA_VERSION,
    FULL_ADAPTER_MANIFEST,
    adapter_source_hash,
    endpoint_adapter_generator_hash,
    materialize_full_telemetry_adapter,
    validate_materialized_full_telemetry_adapter,
)
from .inventory import parse_compile_commands
from .schema import (
    FABRIC_DIMS_WSE3,
    SCHEMA_VERSION,
    EvidenceKind,
    ValidationError,
    atomic_write_json,
    canonical_hash,
    hash_file,
    hash_tree,
    safe_name,
    utc_now,
)
from .telemetry import DEFAULT_DEAD_TIMER_FLOOR

SUITE_WARMUPS = 3
SUITE_TRIALS = 30
SUPPORTED_SDK_PREFIX = "2.10."
LEDGER_VERSION = "1.0.0"
VALID_ARMS = frozenset(("simulator", "hardware"))
VALID_TELEMETRY_LEVELS = frozenset(("endpoint", "full"))
DEVICE_TIMING_METHODS = frozenset(
    ("device_internal", "device_internal_synchronized")
)
ADAPTER_MANIFEST_NAME = ".wse3study_adapter.json"
FULL_ADAPTER_MANIFEST_NAME = FULL_ADAPTER_MANIFEST
_ADAPTER_HASH_EXCLUDES = (
    ".git",
    "__pycache__",
    ".pytest_cache",
    "simfab_traces",
    "out",
    ADAPTER_MANIFEST_NAME,
    ".wse3study_full_override.json",
    FULL_ADAPTER_MANIFEST_NAME,
    ".wse3study_evidence",
)
_OPERATIONAL_CONFIGURATION_KEYS = frozenset(("artifact_store",))
_EXCEPTION_PROVENANCE_ATTR = "_wse3study_provenance"


def _jsonable_mapping(value: Mapping[str, Any]) -> dict[str, Any]:
    # Round-tripping through canonical JSON both checks serializability and
    # prevents callers from mutating a request through a retained nested dict.
    return json.loads(json.dumps(value, sort_keys=True))


@dataclass(frozen=True)
class RunRequest:
    """A repeatable unit of compilation and measurement.

    ``source_hash`` identifies the frozen source bundle. ``compile_hash``
    identifies compiler inputs (arguments, generated adapter, and source). Both
    participate in ``request_key`` so a changed binary can never resume against
    stale measurements.
    """

    campaign_id: str
    subject: str
    kind: str
    arm: str
    source_hash: str
    compile_hash: str
    configuration: Mapping[str, Any] = field(default_factory=dict)
    variant: str = "reference"
    telemetry_level: str = "endpoint"
    warmups: int = SUITE_WARMUPS
    trials: int = SUITE_TRIALS
    timeout_s: int = 1800

    def __post_init__(self) -> None:
        if not self.campaign_id.strip() or not self.subject.strip() or not self.kind.strip():
            raise ValidationError("campaign_id, subject, and kind must be non-empty")
        if self.arm not in VALID_ARMS:
            raise ValidationError(f"arm must be one of {sorted(VALID_ARMS)}")
        if self.telemetry_level not in VALID_TELEMETRY_LEVELS:
            raise ValidationError(
                f"telemetry_level must be one of {sorted(VALID_TELEMETRY_LEVELS)}"
            )
        if not self.source_hash or not self.compile_hash:
            raise ValidationError("source_hash and compile_hash are required")
        if self.warmups < 0 or self.trials < 1 or self.timeout_s < 1:
            raise ValidationError("warmups >= 0, trials >= 1, and timeout_s >= 1 required")
        object.__setattr__(self, "configuration", _jsonable_mapping(self.configuration))

    @property
    def evidence(self) -> str:
        # An unsupported generated case is a specification/capability result;
        # no simulator or wafer operation occurred.  Labelling it silicon (or
        # simulator) merely because the request has an arm would manufacture
        # provenance that does not exist.
        if self.configuration.get("unsupported"):
            return EvidenceKind.INFERRED.value
        if self.configuration.get("compile_only"):
            return EvidenceKind.COMPILED.value
        return (
            EvidenceKind.SILICON.value
            if self.arm == "hardware"
            else EvidenceKind.SIMULATOR.value
        )

    def identity(self) -> dict[str, Any]:
        """Scientific identity; campaign label is deliberately not included."""

        scientific_configuration = {
            key: value
            for key, value in self.configuration.items()
            if key not in _OPERATIONAL_CONFIGURATION_KEYS
        }
        return {
            "schema_version": SCHEMA_VERSION,
            "subject": self.subject,
            "kind": self.kind,
            "arm": self.arm,
            "source_hash": self.source_hash,
            "compile_hash": self.compile_hash,
            "configuration": scientific_configuration,
            "variant": self.variant,
            "telemetry_level": self.telemetry_level,
            "warmups": self.warmups,
            "trials": self.trials,
            "timeout_s": self.timeout_s,
        }

    @property
    def request_key(self) -> str:
        return canonical_hash(self.identity())

    def event_key(self, *, warmup: bool, trial: int) -> str:
        return canonical_hash(
            {
                "request_key": self.request_key,
                "phase": "warmup" if warmup else "measurement",
                "trial": trial,
            }
        )

    def to_dict(self) -> dict[str, Any]:
        result = {
            "campaign_id": self.campaign_id,
            **self.identity(),
            "request_key": self.request_key,
        }
        # Operational settings are serialized for reproducibility and execution,
        # but do not change the scientific request/event identity. In particular,
        # moving a campaign's artifact store must not resubmit accepted trials.
        result["configuration"] = dict(self.configuration)
        return result


@dataclass(frozen=True)
class ResultValidation:
    accepted: bool
    status: str
    reasons: tuple[str, ...]
    normalized: Mapping[str, Any]


@dataclass(frozen=True)
class PreflightReport:
    ok: bool
    execute: bool
    targets: tuple[str, ...]
    checks: tuple[Mapping[str, str], ...]
    detected: Mapping[str, Any]

    def require_ok(self) -> None:
        if not self.ok:
            errors = [
                check["message"]
                for check in self.checks
                if check.get("status") == "error"
            ]
            raise ValidationError("preflight failed: " + "; ".join(errors))

    def to_dict(self) -> dict[str, Any]:
        return {
            "ok": self.ok,
            "execute": self.execute,
            "targets": list(self.targets),
            "checks": [dict(check) for check in self.checks],
            "detected": dict(self.detected),
        }


@dataclass
class CampaignSummary:
    dry_run: bool
    requests: int
    planned_events: int
    pending_events: int
    executed_events: int = 0
    resumed_events: int = 0
    accepted_events: int = 0
    rejected_events: int = 0
    runner_batch_calls: int = 0
    runner_single_event_calls: int = 0
    batched_events: int = 0
    blocked_requests: list[str] = field(default_factory=list)
    ledger_path: str | None = None

    def to_dict(self) -> dict[str, Any]:
        return {
            "dry_run": self.dry_run,
            "requests": self.requests,
            "planned_events": self.planned_events,
            "pending_events": self.pending_events,
            "executed_events": self.executed_events,
            "resumed_events": self.resumed_events,
            "accepted_events": self.accepted_events,
            "rejected_events": self.rejected_events,
            "runner_batch_calls": self.runner_batch_calls,
            "runner_single_event_calls": self.runner_single_event_calls,
            "batched_events": self.batched_events,
            "blocked_requests": list(self.blocked_requests),
            "ledger_path": self.ledger_path,
        }


class Runner(Protocol):
    def run(
        self, request: RunRequest, *, trial_index: int, warmup: bool
    ) -> Mapping[str, Any]: ...


class BatchRunner(Protocol):
    """Optional runner extension for one runtime serving several events.

    Results are keyed by :meth:`RunRequest.event_key`, so a caller can never
    silently associate a sample with the wrong warmup or trial.  ``run_requests``
    continues to own validation and one-record-per-event checkpointing.
    """

    def run_batch(
        self,
        request: RunRequest,
        *,
        events: Sequence[tuple[bool, int]],
    ) -> Mapping[str, Mapping[str, Any]]: ...


def _distribution_version(name: str) -> str | None:
    try:
        return importlib.metadata.version(name)
    except importlib.metadata.PackageNotFoundError:
        return None


def validated_adapter_manifest(source: str | os.PathLike[str]) -> dict[str, Any]:
    """Return a trusted instrumentation manifest for a staged bundle.

    ``instrumentation.py`` records ``source_hash_after`` immediately before it
    writes the manifest.  The manifest itself is consequently excluded from
    verification; all other staged source remains covered by the hash.
    """

    root = Path(source).resolve()
    manifest_path = root / ADAPTER_MANIFEST_NAME
    try:
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    except FileNotFoundError as exc:
        raise ValidationError(f"missing device adapter manifest: {manifest_path}") from exc
    except json.JSONDecodeError as exc:
        raise ValidationError(f"invalid device adapter manifest: {manifest_path}") from exc
    if not isinstance(manifest, dict) or manifest.get("status") != "instrumented":
        raise ValidationError("device adapter manifest status is not 'instrumented'")
    if manifest.get("adapter_schema_version") != ADAPTER_SCHEMA_VERSION:
        raise ValidationError(
            f"device adapter manifest schema is not {ADAPTER_SCHEMA_VERSION}"
        )
    if manifest.get("adapter_generator_sha256") != endpoint_adapter_generator_hash():
        raise ValidationError(
            "device adapter was produced by a different instrumentation generator"
        )
    telemetry_levels = manifest.get("telemetry_levels")
    if not isinstance(telemetry_levels, list) or "endpoint" not in telemetry_levels:
        raise ValidationError("device adapter does not attest endpoint telemetry")
    timing = manifest.get("timing")
    if (
        not isinstance(timing, Mapping)
        or timing.get("method") != "device_internal"
        or timing.get("host_rpc_inside_window") is not False
    ):
        raise ValidationError("device adapter timing contract is not wholly device-internal")
    correctness = manifest.get("correctness")
    run_path = root / "run.py"
    if (
        not isinstance(correctness, Mapping)
        or correctness.get("run_py_unchanged") is not True
        or not run_path.is_file()
        or correctness.get("run_py_sha256") != hash_file(run_path)
    ):
        raise ValidationError("adapter does not preserve the frozen host correctness program")
    expected = manifest.get("source_hash_after")
    actual = adapter_source_hash(root)
    if not expected or expected != actual:
        raise ValidationError(
            "staged bundle changed after instrumentation: "
            f"manifest hash={expected!r}, current hash={actual!r}"
        )
    d2h = manifest.get("d2h")
    if isinstance(d2h, Mapping) and d2h.get("postlude"):
        postlude = (root / str(d2h["postlude"])).resolve()
        try:
            postlude.relative_to(root)
        except ValueError as exc:
            raise ValidationError("adapter postlude escapes staged bundle") from exc
        if (
            not postlude.is_file()
            or d2h.get("postlude_sha256") != hash_file(postlude)
        ):
            raise ValidationError("adapter postlude is missing or changed")
    return manifest


def validated_full_adapter_manifest(source: str | os.PathLike[str]) -> dict[str, Any]:
    """Validate a full-telemetry copy without weakening endpoint rules.

    The full adapter necessarily changes the host program to launch the
    synchronized entry point and export spatial telemetry.  It therefore uses
    its own manifest and remains bound to the independently valid endpoint
    parent, retained override, exact generated source, and protected numerical
    correctness region.
    """

    root = Path(source).resolve()
    audit = validate_materialized_full_telemetry_adapter(root)
    if audit.get("status") != "ready_for_compile":
        raise ValidationError(
            "invalid full telemetry adapter: "
            + "; ".join(str(item) for item in audit.get("errors") or ["source audit failed"])
        )
    if audit.get("telemetry_level") != "full":
        raise ValidationError("full adapter does not attest full telemetry")
    parent_value = audit.get("source_bundle")
    if not isinstance(parent_value, str) or not parent_value:
        raise ValidationError("full adapter has no endpoint parent")
    parent = Path(parent_value).resolve()
    if parent == root or parent in root.parents or root in parent.parents:
        raise ValidationError("full adapter parent and output must be separate sibling bundles")
    endpoint = validated_adapter_manifest(parent)
    parent_hash = str(endpoint.get("source_hash_after") or "")
    if not parent_hash or audit.get("source_bundle_sha256") != parent_hash:
        raise ValidationError("full adapter is not bound to the current endpoint parent hash")
    parent_run = parent / "run.py"
    full_run = root / "run.py"
    correctness = audit.get("correctness")
    if (
        not isinstance(correctness, Mapping)
        or not parent_run.is_file()
        or correctness.get("original_run_py_sha256") != hash_file(parent_run)
        or not full_run.is_file()
        or correctness.get("materialized_run_py_sha256") != hash_file(full_run)
        or correctness.get("protected_correctness_regions_unchanged") is not True
    ):
        raise ValidationError("full adapter correctness/run.py binding is invalid")
    if audit.get("source_hash_after") != adapter_source_hash(root):
        raise ValidationError("full adapter staged source hash is invalid")
    override_file = audit.get("override_file")
    if not isinstance(override_file, str):
        raise ValidationError("full adapter does not retain its exact override")
    override_path = root / override_file
    try:
        override = json.loads(override_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise ValidationError(f"full adapter override cannot be read: {exc}") from exc
    if canonical_hash(override) != audit.get("override_sha256"):
        raise ValidationError("full adapter override hash is invalid")
    if override.get("bundle_source_hash") != parent_hash:
        raise ValidationError("retained full override is not bound to the endpoint parent")
    insertions = audit.get("insertions")
    roles = {
        str(record.get("role"))
        for record in insertions or []
        if isinstance(record, Mapping) and record.get("kind") == "integration"
    }
    required_roles = {
        "profile_import",
        "sync_layout_wiring",
        "sync_pe_import",
        "sync_host_launch",
        "telemetry_csl_export",
        "telemetry_host_d2h",
    }
    if roles != required_roles:
        raise ValidationError("full adapter integration-role binding is incomplete or ambiguous")
    if Path(str(audit.get("bundle") or "")).resolve() != root:
        raise ValidationError("full adapter manifest is bound to another destination")

    # The full manifest is intentionally mutable to admit later compile and
    # correctness evidence. Replaying the retained exact-anchor override from
    # the independently validated endpoint parent proves that coordinated
    # edits to source plus manifest cannot manufacture a new ready source.
    with tempfile.TemporaryDirectory(prefix="wse3study_full_verify_") as directory:
        expected_root = Path(directory) / "full"
        expected = materialize_full_telemetry_adapter(parent, override, expected_root)
        for field in (
            "source_bundle_sha256",
            "source_hash_after",
            "override_sha256",
            "generator_sha256",
            "input_file_sha256",
            "output_file_sha256",
            "insertions",
            "protected_regions",
            "program_coverage",
            "phases",
            "sync",
            "exports",
            "raw_performance_counters",
        ):
            if canonical_hash(audit.get(field)) != canonical_hash(expected.get(field)):
                raise ValidationError(
                    f"full adapter {field} differs from deterministic override replay"
                )
    return audit


def _require_full_adapter_execution_evidence(manifest: Mapping[str, Any]) -> None:
    """Keep physical/simulator execution closed until independent gates pass."""

    binding = manifest.get("campaign_binding")
    if not isinstance(binding, Mapping) or binding.get("status") != "ready_for_execution":
        raise ValidationError(
            "full telemetry source is ready only for compilation; compile, original numerical "
            "correctness, and D2H schema validation evidence are still required"
        )
    source_hash = manifest.get("source_hash_after")
    bundle = Path(str(manifest.get("bundle") or "")).resolve()
    gates = {
        "compile_validation": ("artifact_sha256",),
        "correctness_validation": ("result_sha256",),
        "d2h_schema_validation": ("schema_sha256",),
    }
    for gate, required_fields in gates.items():
        record = binding.get(gate)
        if not isinstance(record, Mapping) or record.get("status") != "passed":
            raise ValidationError(f"full telemetry execution gate {gate} has not passed")
        if record.get("source_hash") != source_hash:
            raise ValidationError(f"full telemetry execution gate {gate} targets another source hash")
        if any(not record.get(field) for field in required_fields):
            raise ValidationError(f"full telemetry execution gate {gate} lacks retained evidence hash")
        evidence_value = record.get("evidence_file")
        evidence_relative = Path(str(evidence_value or ""))
        if (
            not evidence_relative.parts
            or evidence_relative.is_absolute()
            or ".." in evidence_relative.parts
            or evidence_relative.parts[0] != ".wse3study_evidence"
        ):
            raise ValidationError(f"full telemetry execution gate {gate} has an unsafe evidence path")
        evidence_path = bundle / evidence_relative
        if not evidence_path.is_file() or hash_file(evidence_path) != record.get("evidence_sha256"):
            raise ValidationError(f"full telemetry execution gate {gate} evidence file is absent or changed")
        try:
            evidence = json.loads(evidence_path.read_text(encoding="utf-8"))
        except json.JSONDecodeError as exc:
            raise ValidationError(f"full telemetry execution gate {gate} evidence is invalid JSON") from exc
        if (
            not isinstance(evidence, Mapping)
            or evidence.get("status") != "passed"
            or evidence.get("source_hash") != source_hash
            or any(evidence.get(field) != record.get(field) for field in required_fields)
        ):
            raise ValidationError(f"full telemetry execution gate {gate} evidence content is unbound")


def preflight(
    *,
    targets: Sequence[str] = ("hardware",),
    execute: bool = False,
    executable: str | None = None,
    which: Callable[[str], str | None] = shutil.which,
    version_getter: Callable[[str], str | None] = _distribution_version,
    module_finder: Callable[[str], Any] = importlib.util.find_spec,
    service_probe: Callable[[], bool] | None = None,
) -> PreflightReport:
    """Check SDK 2.10 and ALCF service prerequisites without submitting work.

    Missing execution dependencies are warnings during dry-run planning and
    errors only when execution is explicitly requested. ``service_probe`` is
    injectable so a CLI may perform an authenticated read-only cluster probe;
    this library never makes that network call on its own.
    """

    normalized_targets = tuple(dict.fromkeys(targets))
    invalid = set(normalized_targets) - VALID_ARMS
    if invalid:
        raise ValidationError(f"unsupported target(s): {sorted(invalid)}")

    checks: list[dict[str, str]] = []

    def add(code: str, condition: bool, success: str, failure: str) -> None:
        status = "pass" if condition else ("error" if execute else "warning")
        checks.append(
            {"code": code, "status": status, "message": success if condition else failure}
        )

    python_path = executable or sys.executable
    python_exists = bool(python_path) and Path(python_path).is_file()
    add(
        "python_executable",
        python_exists,
        f"Python executable available: {python_path}",
        f"Python executable is unavailable: {python_path}",
    )

    versions = {
        "cerebras-appliance": version_getter("cerebras-appliance"),
        "cerebras-sdk": version_getter("cerebras-sdk"),
    }
    for package, version in versions.items():
        supported = bool(version and version.startswith(SUPPORTED_SDK_PREFIX))
        add(
            f"{package}_version",
            supported,
            f"{package} {version} is supported",
            f"{package} must be 2.10.x (detected {version or 'not installed'})",
        )

    try:
        client_importable = module_finder("cerebras.sdk.client") is not None
    except (ImportError, ModuleNotFoundError, AttributeError):
        client_importable = False
    add(
        "appliance_client_import",
        client_importable,
        "cerebras.sdk.client is importable",
        "cerebras.sdk.client is not importable",
    )

    csctl_path = which("csctl")
    if "hardware" in normalized_targets:
        add(
            "alcf_service_context",
            csctl_path is not None,
            f"ALCF csctl found at {csctl_path}",
            "csctl is not on PATH; run from an ALCF Cerebras user/service node",
        )
        if service_probe is not None:
            try:
                reachable = bool(service_probe())
            except Exception:
                reachable = False
            add(
                "service_probe",
                reachable,
                "authenticated Cerebras service probe succeeded",
                "authenticated Cerebras service probe failed",
            )

    report = PreflightReport(
        ok=not any(check["status"] == "error" for check in checks),
        execute=execute,
        targets=normalized_targets,
        checks=tuple(checks),
        detected={
            "python": python_path,
            "hostname": platform.node(),
            "platform": platform.platform(),
            "versions": versions,
            "csctl": csctl_path,
            "fabric_dims": list(FABRIC_DIMS_WSE3),
        },
    )
    return report


def load_ledger(path: str | os.PathLike[str]) -> list[dict[str, Any]]:
    """Load an append-only JSONL ledger, rejecting corrupt partial records."""

    target = Path(path)
    if not target.exists():
        return []
    records: list[dict[str, Any]] = []
    with target.open("r", encoding="utf-8") as handle:
        for line_number, line in enumerate(handle, 1):
            if not line.strip():
                continue
            try:
                record = json.loads(line)
            except json.JSONDecodeError as exc:
                raise ValidationError(
                    f"invalid ledger JSON at {target}:{line_number}: {exc.msg}"
                ) from exc
            if not isinstance(record, dict) or not record.get("event_key"):
                raise ValidationError(
                    f"invalid ledger record at {target}:{line_number}"
                )
            records.append(record)
    return records


def save_ledger(
    path: str | os.PathLike[str], records: Iterable[Mapping[str, Any]]
) -> Path:
    """Atomically replace a ledger with validated JSONL records."""

    target = Path(path)
    target.parent.mkdir(parents=True, exist_ok=True)
    fd, temporary = tempfile.mkstemp(prefix=f".{target.name}.", dir=target.parent)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as handle:
            for record in records:
                if not isinstance(record, Mapping) or not record.get("event_key"):
                    raise ValidationError("every ledger record requires event_key")
                handle.write(json.dumps(record, sort_keys=True, separators=(",", ":")))
                handle.write("\n")
            handle.flush()
            os.fsync(handle.fileno())
        os.replace(temporary, target)
    except BaseException:
        try:
            os.unlink(temporary)
        except OSError:
            pass
        raise
    return target


def _append_ledger(path: Path, record: Mapping[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    # One pre-joined write: records exceed the default 8 KiB text buffer (largest
    # observed 8651 bytes), so two writes could split a record across two write(2)
    # calls and interleave with a concurrent appender, corrupting the ledger.
    # Buffering is disabled so the single write reaches the fd as one O_APPEND call.
    payload = json.dumps(record, sort_keys=True, separators=(",", ":")) + "\n"
    encoded = payload.encode("utf-8")
    with path.open("ab", buffering=0) as handle:
        handle.write(encoded)
        os.fsync(handle.fileno())


def validate_result(
    request: RunRequest,
    result: Mapping[str, Any],
    *,
    dead_timer_floor: int = DEFAULT_DEAD_TIMER_FLOOR,
) -> ResultValidation:
    """Normalize a runner result and enforce scientific timing integrity."""

    normalized = dict(result)
    reasons: list[str] = []
    compile_only = bool(request.configuration.get("compile_only"))
    unsupported = bool(request.configuration.get("unsupported"))

    if unsupported:
        status = str(normalized.get("status", ""))
        if status != "unsupported":
            reasons.append(
                f"unsupported calibration case returned status {status!r}, not 'unsupported'"
            )
        normalized["evidence"] = EvidenceKind.INFERRED.value
        normalized["elapsed_cycles"] = None
        return ResultValidation(
            not reasons,
            "unsupported" if not reasons else "rejected",
            tuple(reasons),
            normalized,
        )

    status = str(normalized.get("status", "pass"))
    if compile_only:
        compile_success = normalized.get(
            "compile_success", status in {"pass", "compile_pass"}
        )
        capacity_failure = bool(normalized.get("capacity_failure"))
        probe_valid = bool(normalized.get("compile_probe_valid"))
        if not compile_success and not (capacity_failure and probe_valid):
            reasons.append(
                "compile-only SRAM probe failed for a reason not classified as "
                "a memory-capacity limit"
            )
        normalized["compile_success"] = bool(compile_success)
        normalized["evidence"] = request.evidence
        final_status = (
            "compile_pass"
            if compile_success and not reasons
            else ("compile_capacity_fail" if not reasons else "compile_fail")
        )
        return ResultValidation(not reasons, final_status, tuple(reasons), normalized)

    if status != "pass":
        reasons.append(f"runner status is {status!r}, not 'pass'")

    cycles = normalized.get("elapsed_cycles")
    if cycles is None:
        cycles = normalized.get("cycles_send", normalized.get("cycles"))
    raw_start = normalized.get("start_words_u16")
    raw_end = normalized.get("end_words_u16")
    timer_validated = bool(
        normalized.get("timer_enabled") is True
        and isinstance(raw_start, (list, tuple))
        and isinstance(raw_end, (list, tuple))
        and len(raw_start) == 3
        and len(raw_end) == 3
        and all(isinstance(word, int) and 0 <= word <= 0xFFFF for word in (*raw_start, *raw_end))
        and tuple(raw_start) != tuple(raw_end)
    )
    normalized["timer_validated"] = timer_validated
    if isinstance(cycles, bool) or not isinstance(cycles, int):
        reasons.append("device elapsed cycles are missing or not an integer")
    elif cycles <= 0:
        reasons.append(f"elapsed cycles {cycles} are not positive")
    elif cycles < dead_timer_floor and not timer_validated:
        reasons.append(
            f"elapsed cycles {cycles} are below dead-timer floor {dead_timer_floor}"
        )
    normalized["elapsed_cycles"] = cycles

    timing_method = normalized.get("timing_method")
    contaminated = (
        timing_method not in DEVICE_TIMING_METHODS
        or normalized.get("hw_comparable") is False
        or normalized.get("host_bracketed") is True
    )
    if contaminated:
        reasons.append("timed window is host-bracketed or not wholly device-internal")

    correctness = normalized.get("correctness")
    if correctness is None:
        correctness = normalized.get("success_marker", normalized.get("success"))
    if correctness not in {True, "pass", "PASS"}:
        reasons.append("correctness did not pass")
    normalized["correctness"] = correctness

    supplied_evidence = normalized.get("evidence")
    if supplied_evidence is not None and supplied_evidence != request.evidence:
        reasons.append(
            f"result evidence {supplied_evidence!r} does not match {request.evidence!r} arm"
        )
    normalized["evidence"] = request.evidence
    normalized["telemetry_level"] = request.telemetry_level

    if reasons:
        if any("dead-timer" in reason for reason in reasons):
            final_status = "rejected_dead_timer"
        elif contaminated:
            final_status = "rejected_host_bracketed"
        else:
            final_status = "rejected"
    else:
        final_status = "pass"
    return ResultValidation(not reasons, final_status, tuple(reasons), normalized)


def _latest_by_event(records: Iterable[Mapping[str, Any]]) -> dict[str, Mapping[str, Any]]:
    latest: dict[str, Mapping[str, Any]] = {}
    for record in records:
        latest[str(record["event_key"])] = record
    return latest


def _attempt_counts(records: Iterable[Mapping[str, Any]]) -> dict[str, int]:
    counts: dict[str, int] = {}
    for record in records:
        key = str(record["event_key"])
        counts[key] = counts.get(key, 0) + 1
    return counts


def _runner_provenance(runner: Any, result: Mapping[str, Any]) -> dict[str, Any]:
    supplied = getattr(runner, "provenance", {})
    provenance = dict(supplied() if callable(supplied) else supplied)
    for key in (
        "job_id",
        "artifact_id",
        "artifact_path",
        "artifact_original",
        "artifact_preserved",
        "artifact_sha256",
        "artifact_bytes",
        "sdk_version",
        "client_version",
        "service",
        "compiler_args",
        "source_hash_verified",
        "compiled_bundle_hash",
        "compile_identity_hash",
        "fabric_dims",
        "batch_id",
        "batch_size",
        "batch_ordinal",
        "batch_completed",
    ):
        if result.get(key) is not None:
            provenance[key] = result[key]
    provenance.setdefault("hostname", platform.node())
    provenance.setdefault("python", sys.executable)
    return provenance


def _runner_error_result(exc: Exception) -> dict[str, Any]:
    """Preserve safely attributable provenance carried by a runner error.

    Preparation can fail after the effective compile command has been
    resolved but before an artifact exists. Attaching that provisional
    context to the exception prevents the runner's full-wafer defaults from
    being mistaken for the compiler invocation that actually failed.
    """

    result: dict[str, Any] = {}
    provisional = getattr(exc, _EXCEPTION_PROVENANCE_ATTR, None)
    if isinstance(provisional, Mapping):
        result.update(_jsonable_mapping(provisional))
    # Exception-carried context is provenance only and can never turn an
    # execution exception into an accepted result.
    result["status"] = "runner_error"
    result["reason"] = f"{type(exc).__name__}: {str(exc)[:500]}"
    return result


def _events(request: RunRequest) -> Iterable[tuple[bool, int]]:
    for index in range(request.warmups):
        yield True, index
    for index in range(request.trials):
        yield False, index


def run_requests(
    requests: Iterable[RunRequest],
    runner: Runner | BatchRunner | Callable[..., Mapping[str, Any]] | None,
    ledger_path: str | os.PathLike[str],
    *,
    execute: bool = False,
    resume: bool = True,
    preflight_report: PreflightReport | None = None,
) -> CampaignSummary:
    """Run requests sequentially, checkpointing one record per trial.

    Only an accepted event is resumed. A rejected/dead/failed event remains
    open and is retried on the next invocation. A runner with ``run_batch``
    may amortize one runtime over all pending events, but results remain keyed,
    validated, fsynced, and resumed independently. A batch-level failure or
    missing sample stops attribution at the first unknown event. Legacy
    single-event runners retain first-failure blocking. Subsequent requests
    always proceed and are therefore never silently skipped.
    """

    request_list = list(requests)
    keys = [request.request_key for request in request_list]
    if len(set(keys)) != len(keys):
        raise ValidationError("duplicate RunRequest identities in campaign")

    target = Path(ledger_path)
    # Even a deliberate replay remains part of the same append-only audit
    # history. ``resume`` controls whether accepted events are skipped; it must
    # not reset attempt numbering or hide prior provenance.
    prior = load_ledger(target)
    latest = _latest_by_event(prior)
    attempts = _attempt_counts(prior)
    planned = sum(request.warmups + request.trials for request in request_list)
    already_accepted = (
        sum(
            1
            for request in request_list
            for warmup, trial in _events(request)
            if (latest.get(request.event_key(warmup=warmup, trial=trial)) or {}).get(
                "accepted"
            )
        )
        if resume
        else 0
    )
    summary = CampaignSummary(
        dry_run=not execute,
        requests=len(request_list),
        planned_events=planned,
        pending_events=planned - already_accepted,
        resumed_events=already_accepted,
        ledger_path=str(target),
    )

    # Dry-run is intentionally side-effect-free: it neither calls the runner
    # nor creates an empty ledger file.
    if not execute:
        return summary
    if runner is None:
        raise ValidationError("runner is required when execute=True")
    if preflight_report is not None:
        preflight_report.require_ok()
    elif getattr(runner, "requires_service_preflight", False):
        preflight(targets=tuple(dict.fromkeys(r.arm for r in request_list)), execute=True).require_ok()

    invoke = (
        runner.run
        if hasattr(runner, "run")
        else (runner if callable(runner) else None)
    )
    invoke_batch = getattr(runner, "run_batch", None)
    if invoke is None and not callable(invoke_batch):
        raise ValidationError("runner exposes neither run nor run_batch")

    def checkpoint(
        request: RunRequest,
        *,
        warmup: bool,
        trial_index: int,
        raw_result: Mapping[str, Any],
        validation: ResultValidation,
    ) -> None:
        event_key = request.event_key(warmup=warmup, trial=trial_index)
        attempt = attempts.get(event_key, 0) + 1
        attempts[event_key] = attempt
        record = {
            "ledger_version": LEDGER_VERSION,
            "recorded_at": utc_now(),
            "campaign_id": request.campaign_id,
            "request_key": request.request_key,
            "event_key": event_key,
            "attempt": attempt,
            "subject": request.subject,
            "kind": request.kind,
            "variant": request.variant,
            "arm": request.arm,
            "evidence": request.evidence,
            "telemetry_level": request.telemetry_level,
            "source_hash": request.source_hash,
            "compile_hash": request.compile_hash,
            "warmup": warmup,
            "trial": trial_index,
            "status": validation.status,
            "accepted": validation.accepted,
            "validation_errors": list(validation.reasons),
            "result": dict(validation.normalized),
            "provenance": _runner_provenance(runner, raw_result),
            "request": request.to_dict(),
        }
        _append_ledger(target, record)
        latest[event_key] = record
        summary.executed_events += 1
        if validation.accepted:
            summary.accepted_events += 1
        else:
            summary.rejected_events += 1

    for request in request_list:
        pending = [
            (warmup, trial_index)
            for warmup, trial_index in _events(request)
            if not (
                resume
                and (
                    latest.get(
                        request.event_key(warmup=warmup, trial=trial_index)
                    )
                    or {}
                ).get("accepted")
            )
        ]
        # A singleton stays on the established single-event API.  This is
        # useful for tiny controls and means legacy subclasses can implement a
        # specialized batch method without changing one-event behavior.
        if callable(invoke_batch) and (
            len(pending) > 1
            or invoke is None
            or bool(getattr(runner, "batch_singletons", False))
        ):
            summary.runner_batch_calls += 1
            summary.batched_events += len(pending)
            try:
                batch_results = invoke_batch(request, events=tuple(pending))
                if not isinstance(batch_results, Mapping):
                    raise TypeError("batch runner result must be a mapping")
                expected_keys = {
                    request.event_key(warmup=warmup, trial=trial_index)
                    for warmup, trial_index in pending
                }
                unexpected = set(str(key) for key in batch_results) - expected_keys
                if unexpected:
                    raise ValidationError(
                        "batch runner returned unknown event key(s): "
                        + ", ".join(sorted(unexpected)[:3])
                    )
            except Exception as exc:
                # No result can be safely attributed after a batch-level API
                # failure. Checkpoint one open event and leave the remainder
                # untouched for the next resume.
                warmup, trial_index = pending[0]
                raw_result = _runner_error_result(exc)
                validation = ResultValidation(
                    accepted=False,
                    status="runner_error",
                    reasons=(str(raw_result["reason"]),),
                    normalized=raw_result,
                )
                checkpoint(
                    request,
                    warmup=warmup,
                    trial_index=trial_index,
                    raw_result=raw_result,
                    validation=validation,
                )
                summary.blocked_requests.append(request.request_key)
                continue

            batch_rejected = False
            for warmup, trial_index in pending:
                event_key = request.event_key(
                    warmup=warmup, trial=trial_index
                )
                raw_result = batch_results.get(event_key)
                if raw_result is None:
                    # Partial batch output is still useful: all prior samples
                    # have already been checkpointed. Stop at the first missing
                    # sample so later, potentially ambiguous output is retried.
                    missing = {
                        "status": "runner_error",
                        "reason": "batch runner emitted no result for event",
                    }
                    validation = ResultValidation(
                        accepted=False,
                        status="runner_error",
                        reasons=(str(missing["reason"]),),
                        normalized=missing,
                    )
                    checkpoint(
                        request,
                        warmup=warmup,
                        trial_index=trial_index,
                        raw_result=missing,
                        validation=validation,
                    )
                    batch_rejected = True
                    break
                if not isinstance(raw_result, Mapping):
                    raw_result = {
                        "status": "runner_error",
                        "reason": "batch event result must be a mapping",
                    }
                    validation = ResultValidation(
                        accepted=False,
                        status="runner_error",
                        reasons=(str(raw_result["reason"]),),
                        normalized=raw_result,
                    )
                elif (
                    raw_result.get("warmup") is not None
                    and bool(raw_result.get("warmup")) != warmup
                ) or (
                    raw_result.get("trial") is not None
                    and raw_result.get("trial") != trial_index
                ):
                    raw_result = dict(raw_result)
                    raw_result["status"] = "runner_error"
                    raw_result["reason"] = (
                        "batch result warmup/trial identity does not match event key"
                    )
                    validation = ResultValidation(
                        accepted=False,
                        status="runner_error",
                        reasons=(str(raw_result["reason"]),),
                        normalized=raw_result,
                    )
                else:
                    validation = validate_result(request, raw_result)
                checkpoint(
                    request,
                    warmup=warmup,
                    trial_index=trial_index,
                    raw_result=raw_result,
                    validation=validation,
                )
                batch_rejected = batch_rejected or not validation.accepted
            if batch_rejected:
                summary.blocked_requests.append(request.request_key)
            continue

        blocked = False
        for warmup, trial_index in _events(request):
            event_key = request.event_key(warmup=warmup, trial=trial_index)
            prior_event = latest.get(event_key)
            if resume and prior_event and prior_event.get("accepted"):
                continue
            try:
                summary.runner_single_event_calls += 1
                assert invoke is not None
                raw_result = invoke(
                    request, trial_index=trial_index, warmup=warmup
                )
                if not isinstance(raw_result, Mapping):
                    raise TypeError("runner result must be a mapping")
                validation = validate_result(request, raw_result)
            except Exception as exc:
                raw_result = _runner_error_result(exc)
                validation = ResultValidation(
                    accepted=False,
                    status="runner_error",
                    reasons=(str(raw_result["reason"]),),
                    normalized=raw_result,
                )

            checkpoint(
                request,
                warmup=warmup,
                trial_index=trial_index,
                raw_result=raw_result,
                validation=validation,
            )
            if not validation.accepted:
                summary.blocked_requests.append(request.request_key)
                blocked = True
                break
        if blocked:
            continue

    # Pending means work still required after this invocation, including a
    # rejected event and all downstream trials in its request.
    final_records = load_ledger(target)
    final_latest = _latest_by_event(final_records)
    completed = sum(
        1
        for request in request_list
        for warmup, trial in _events(request)
        if (final_latest.get(request.event_key(warmup=warmup, trial=trial)) or {}).get(
            "accepted"
        )
    )
    summary.pending_events = planned - completed
    return summary


def make_suite_requests(
    entries: Iterable[Mapping[str, Any]],
    *,
    campaign_id: str,
    repo_root: str | os.PathLike[str] | None = None,
    arms: Sequence[str] = ("hardware",),
    telemetry_levels: Sequence[str] = ("endpoint",),
    warmups: int = SUITE_WARMUPS,
    trials: int = SUITE_TRIALS,
) -> list[RunRequest]:
    """Convert frozen campaign kernel entries into suite requests."""

    result: list[RunRequest] = []
    for entry in entries:
        kernel_record = entry.get("kernel")
        kernel_metadata = kernel_record if isinstance(kernel_record, Mapping) else {}
        hashes = entry.get("hashes")
        hash_metadata = hashes if isinstance(hashes, Mapping) else {}
        subject = str(
            kernel_metadata.get("name")
            or (kernel_record if isinstance(kernel_record, str) else None)
            or entry.get("name")
            or entry.get("id")
            or ""
        )
        source_hash = str(
            entry.get("source_hash")
            or hash_metadata.get("source_sha256")
            or ""
        )
        compile_hash = str(
            entry.get("compile_hash")
            or entry.get("artifact_hash")
            or entry.get("bundle_hash")
            or hash_metadata.get("artifacts_sha256")
            or hash_metadata.get("compile_command_sha256")
            or ""
        )
        kernel_dir = (
            entry.get("kernel_dir")
            or entry.get("reference_csl_dir")
            or kernel_metadata.get("csl_dir")
        )
        configuration = dict(entry.get("configuration") or {})
        if kernel_dir:
            kernel_path = Path(str(kernel_dir))
            if not kernel_path.is_absolute():
                base = (
                    Path(repo_root).resolve()
                    if repo_root is not None
                    else Path(__file__).resolve().parents[3]
                )
                kernel_path = base / kernel_path
            configuration.setdefault("kernel_dir", str(kernel_path))
        for arm in arms:
            for telemetry_level in telemetry_levels:
                result.append(
                    RunRequest(
                        campaign_id=campaign_id,
                        subject=subject,
                        kind="suite",
                        arm=arm,
                        source_hash=source_hash,
                        compile_hash=compile_hash,
                        configuration=configuration,
                        variant=str(entry.get("variant") or "reference"),
                        telemetry_level=telemetry_level,
                        warmups=warmups,
                        trials=trials,
                    )
                )
    return result


def make_calibration_requests(
    cases: Iterable[CalibrationCase],
    *,
    campaign_id: str,
    template_source_hash: str,
    template_compile_hash: str,
    bundle_dir: str | os.PathLike[str] | None = None,
    materialized: Mapping[str, Mapping[str, Any]] | None = None,
    arms: Sequence[str] = ("simulator", "hardware"),
) -> list[RunRequest]:
    """Bind calibration cases to execution requests and case-specific hashes."""

    result: list[RunRequest] = []
    for case in cases:
        bundle_record = dict((materialized or {}).get(case.case_id) or {})
        bundle_sha256 = str(bundle_record.get("bundle_sha256") or "")
        if bundle_sha256:
            # This is the byte-derived digest emitted by calibration_codegen,
            # not a hash of the case description.  Execution requires it so a
            # changed generator/template cannot resume against stale trials.
            generated_source_hash = bundle_sha256
            compile_hash = canonical_hash(
                {
                    "template_compile_hash": template_compile_hash,
                    "bundle_sha256": bundle_sha256,
                    "compile": bundle_record.get("compile"),
                    "sdk": bundle_record.get("sdk"),
                }
            )
        else:
            # Planning without materialization remains deterministic, but is
            # explicitly marked as a specification hash and cannot execute.
            generated_source_hash = canonical_hash(
                {
                    "template_source_hash": template_source_hash,
                    "case": case.to_dict(),
                }
            )
            compile_hash = canonical_hash(
                {
                    "template_compile_hash": template_compile_hash,
                    "family": case.family,
                    "parameters": case.parameters,
                }
            )
        configuration = {
            "calibration_family": case.family,
            "calibration_case": case.case_id,
            "calibration_case_spec": case.to_dict(),
            "generated_source": True,
            "source_hash_kind": "bundle_sha256" if bundle_sha256 else "case_specification",
            "split": case.split,
            **dict(case.parameters),
        }
        if bundle_sha256:
            configuration.update(
                {
                    "expected_generated_bundle_sha256": bundle_sha256,
                    "materialized_status": bundle_record.get("status"),
                    "materialized_manifest": bundle_record.get("manifest_path"),
                }
            )
        if bundle_dir is not None:
            configuration["calibration_bundle_root"] = str(bundle_dir)
        compile_only = bool(case.parameters.get("compile_only"))
        materialized_status = str(bundle_record.get("status") or "")
        unsupported = materialized_status == "unsupported"
        if unsupported:
            configuration.update(
                {
                    "unsupported": True,
                    "unsupported_reason": bundle_record.get("reason"),
                }
            )
        for arm in arms:
            result.append(
                RunRequest(
                    campaign_id=campaign_id,
                    subject=case.case_id,
                    kind="calibration",
                    arm=arm,
                    source_hash=generated_source_hash,
                    compile_hash=compile_hash,
                    configuration=configuration,
                    variant=case.family,
                    telemetry_level="endpoint",
                    # Compile probes and unsupported capability records are
                    # terminal one-shot outcomes, not performance trials.
                    warmups=0 if (compile_only or unsupported) else case.warmups,
                    trials=1 if (compile_only or unsupported) else case.trials,
                )
            )
    return result


def _atomic_verified_artifact_copy(
    source: str | os.PathLike[str], destination: str | os.PathLike[str]
) -> dict[str, Any]:
    """Atomically retain a compiler archive and verify its exact bytes."""

    source_path = Path(source)
    destination_path = Path(destination)
    if not source_path.is_file():
        raise ValidationError(f"compiler artifact is not a file: {source_path}")

    source_bytes = source_path.stat().st_size
    source_sha256 = hash_file(source_path)
    destination_path.parent.mkdir(parents=True, exist_ok=True)

    if source_path.absolute() == destination_path.absolute():
        return {
            "artifact_sha256": source_sha256,
            "artifact_bytes": source_bytes,
        }

    if destination_path.exists() and not destination_path.is_file():
        raise ValidationError(
            f"artifact destination exists and is not a file: {destination_path}"
        )
    if (
        destination_path.is_file()
        and not destination_path.is_symlink()
        and destination_path.stat().st_size == source_bytes
        and hash_file(destination_path) == source_sha256
    ):
        return {
            "artifact_sha256": source_sha256,
            "artifact_bytes": source_bytes,
        }

    fd, temporary_name = tempfile.mkstemp(
        prefix=f".{destination_path.name}.", dir=destination_path.parent
    )
    temporary_path = Path(temporary_name)
    try:
        with source_path.open("rb") as source_handle, os.fdopen(
            fd, "wb"
        ) as destination_handle:
            shutil.copyfileobj(source_handle, destination_handle)
            destination_handle.flush()
            os.fsync(destination_handle.fileno())
        copied_bytes = temporary_path.stat().st_size
        copied_sha256 = hash_file(temporary_path)
        if copied_bytes != source_bytes or copied_sha256 != source_sha256:
            raise ValidationError(
                "retained compiler artifact failed pre-install integrity verification"
            )
        os.replace(temporary_path, destination_path)
    except BaseException:
        try:
            temporary_path.unlink()
        except FileNotFoundError:
            pass
        raise

    retained_bytes = destination_path.stat().st_size
    retained_sha256 = hash_file(destination_path)
    if retained_bytes != source_bytes or retained_sha256 != source_sha256:
        raise ValidationError(
            "retained compiler artifact failed post-install integrity verification"
        )
    return {
        "artifact_sha256": retained_sha256,
        "artifact_bytes": retained_bytes,
    }


class HwVsSimRunner:
    """Prepared, sequential adapter around xkernel's proven SDK 2.10 helpers.

    One bundle/artifact is prepared per request and reused for all warmups and
    trials.  The adapter refuses host-launched ``f_tic``/``f_toc`` bundles
    before compilation. It is never instantiated by default and never submits
    work until ``run_requests(..., execute=True)`` invokes ``run``.
    """

    requires_service_preflight = True
    # Even a singleton resume needs the batch path so a fresh runtime can
    # replay conditioning warmups before the one still-open measurement.
    batch_singletons = True
    _JOB_RE = re.compile(r"\bwsjob-[a-z0-9]+\b")
    _CALIBRATION_RESULT_RE = re.compile(r"^WSE3STUDY_RESULT=(\{.*\})$", re.MULTILINE)
    _BATCH_EVENT_RE = re.compile(
        r"^WSE3STUDY_BATCH_EVENT=(\{.*\})$", re.MULTILINE
    )
    _CYCLES_RE = re.compile(r"cycles_send\s*=\s*(\d+)")
    _SUCCESS_RE = re.compile(r"\bSUCCESS\b")
    _MEMORY_CAPACITY_RE = re.compile(
        r"(?:out of (?:pe )?memory|memory (?:capacity|overflow|exceeded)|"
        r"exceeds? (?:the )?(?:available )?(?:sram|memory)|"
        r"insufficient (?:sram|memory)|section .* will not fit|"
        r"allocation .* too (?:large|big)|too much (?:sram|memory))",
        re.IGNORECASE,
    )

    def __init__(self, *, port_to_sdk210: bool = False) -> None:
        self.port_to_sdk210 = port_to_sdk210
        self._prepared: dict[str, dict[str, Any]] = {}
        self._temporaries: list[tempfile.TemporaryDirectory[str]] = []

    @property
    def provenance(self) -> dict[str, Any]:
        appliance_version = _distribution_version("cerebras-appliance")
        sdk_version = _distribution_version("cerebras-sdk")
        return {
            "runner": f"{type(self).__module__}.{type(self).__name__}",
            "client_version": appliance_version,
            "sdk_version": sdk_version,
            "cerebras_appliance_version": appliance_version,
            "cerebras_sdk_version": sdk_version,
            "csctl": shutil.which("csctl"),
            "fabric_dims": list(FABRIC_DIMS_WSE3),
        }

    @staticmethod
    def _helpers() -> tuple[Any, Any]:
        repo_root = Path(__file__).resolve().parents[3]
        code_dir = repo_root / "code_translation"
        if str(code_dir) not in sys.path:
            sys.path.insert(0, str(code_dir))
        import hardware_submit  # type: ignore
        import hw_vs_sim  # type: ignore

        return hardware_submit, hw_vs_sim

    @staticmethod
    def _run_argv(spec: Mapping[str, Any]) -> list[str]:
        runs = spec.get("runs") or []
        if not runs:
            raise ValidationError("commands_wse3.sh launches no run.py")
        argv = list(runs[0])
        if argv and str(argv[0]).endswith(".py"):
            argv = argv[1:]
        return [str(item) for item in argv]

    @staticmethod
    def _single_compile_variant(commands: Path, subject: str) -> dict[str, Any]:
        """Select only an unambiguous compile command.

        The legacy command parser returns the last ``cslc`` line.  Silently
        applying that rule would mislabel multi-variant kernels, so execution
        stops until the caller has staged one explicit variant per bundle.
        """

        variants = parse_compile_commands(commands)
        if len(variants) != 1:
            raise ValidationError(
                f"{subject} has {len(variants)} active cslc commands; "
                "compile variants must be staged and requested separately before execution"
            )
        return variants[0]

    @staticmethod
    def _synthesize_out_json(
        bundle: Path, spec: Mapping[str, Any], run_argv: Sequence[str]
    ) -> None:
        name = "out"
        for index, token in enumerate(run_argv):
            if token in ("--name", "-n") and index + 1 < len(run_argv):
                name = run_argv[index + 1]
            elif token.startswith("--name="):
                name = token.split("=", 1)[1]
        for candidate in (bundle / name, bundle / f"{name}_code"):
            candidate.mkdir(parents=True, exist_ok=True)
            (candidate / "out.json").write_text(
                json.dumps({"params": spec.get("params", {}), "colors": {}}),
                encoding="utf-8",
            )

    @staticmethod
    def _effective_cslc_args(
        cslc_args: str,
        *,
        simulator: bool,
        simulator_fabric_dims: Sequence[int] | None = None,
    ) -> str:
        if simulator:
            if simulator_fabric_dims is None:
                return cslc_args
            if len(simulator_fabric_dims) != 2 or min(
                int(value) for value in simulator_fabric_dims
            ) <= 0:
                raise ValidationError("simulator_fabric_dims must contain two positive integers")
            fabric = f"{int(simulator_fabric_dims[0])},{int(simulator_fabric_dims[1])}"
        else:
            fabric = f"{FABRIC_DIMS_WSE3[0]},{FABRIC_DIMS_WSE3[1]}"
        effective = re.sub(r"--fabric-dims=\S+", f"--fabric-dims={fabric}", cslc_args)
        if "--fabric-dims" not in effective:
            effective = f"--fabric-dims={fabric} {effective}"
        return effective.strip()

    @staticmethod
    def _fabric_dims_from_args(cslc_args: str) -> list[int] | None:
        match = re.search(r"--fabric-dims(?:=|\s+)(\d+)\s*,\s*(\d+)", cslc_args)
        if not match:
            return None
        return [int(match.group(1)), int(match.group(2))]

    @staticmethod
    def _calibration_run_argv(
        base_argv: Sequence[str], *, output_path: Path, simulator: bool = False
    ) -> list[str]:
        """Force one device-internal sample for one resumable ledger event."""

        result: list[str] = []
        skip_value = False
        for token in base_argv:
            if skip_value:
                skip_value = False
                continue
            if token in {"--warmups", "--trials", "--output"}:
                skip_value = True
                continue
            if token.startswith(("--warmups=", "--trials=", "--output=")):
                continue
            result.append(token)
        result.extend(
            ["--warmups", "0", "--trials", "1", "--output", str(output_path)]
        )
        if simulator and "--simulator" not in result:
            result.append("--simulator")
        return result

    @staticmethod
    def _calibration_batch_run_argv(
        base_argv: Sequence[str],
        *,
        output_path: Path,
        event_plan_path: Path,
        simulator: bool = False,
    ) -> list[str]:
        """Run an exact set of calibration events inside one SDK runtime."""

        result: list[str] = []
        skip_value = False
        for token in base_argv:
            if skip_value:
                skip_value = False
                continue
            if token in {"--warmups", "--trials", "--output", "--event-plan"}:
                skip_value = True
                continue
            if token.startswith(
                ("--warmups=", "--trials=", "--output=", "--event-plan=")
            ):
                continue
            result.append(token)
        result.extend(
            [
                "--event-plan",
                str(event_plan_path),
                "--output",
                str(output_path),
            ]
        )
        if simulator and "--simulator" not in result:
            result.append("--simulator")
        return result

    @staticmethod
    def _persist_event_artifact(
        request: RunRequest,
        result: Mapping[str, Any],
        *,
        trial_index: int,
        warmup: bool,
    ) -> Path | None:
        artifact_store = request.configuration.get("artifact_store")
        if not artifact_store:
            return None
        event_store = (
            Path(str(artifact_store)).resolve()
            / safe_name(request.subject)
            / request.arm
            / request.request_key[:16]
            / "events"
        )
        event_name = (
            f"{'warmup' if warmup else 'trial'}-{trial_index:03d}-"
            f"{request.event_key(warmup=warmup, trial=trial_index)[:12]}.json"
        )
        return atomic_write_json(
            event_store / event_name,
            {
                "request": request.to_dict(),
                "result": dict(result),
                "recorded_at": utc_now(),
            },
        )

    def _prepare(self, request: RunRequest) -> dict[str, Any]:
        if request.request_key in self._prepared:
            return self._prepared[request.request_key]
        hardware_submit, hw_vs_sim = self._helpers()
        temporary = tempfile.TemporaryDirectory(prefix="wse3study_")
        self._temporaries.append(temporary)
        work = Path(temporary.name)
        generated = bool(request.configuration.get("generated_source"))
        generated_manifest: dict[str, Any] | None = None
        adapter_manifest: dict[str, Any] | None = None

        if generated:
            case_spec = request.configuration.get("calibration_case_spec")
            if not isinstance(case_spec, Mapping):
                raise ValidationError("generated calibration request has no case spec")
            from .calibration_codegen import materialize_calibration_bundle

            generated_bundle = materialize_calibration_bundle(
                case_spec, work / "bundle", overwrite=False
            )
            bundle = Path(generated_bundle.path).resolve()
            generated_manifest = json.loads(
                Path(generated_bundle.manifest_path).read_text(encoding="utf-8")
            )
            if generated_manifest.get("status") != generated_bundle.status:
                raise ValidationError("generated calibration manifest/status mismatch")
            if generated_bundle.case_id != request.subject:
                raise ValidationError("generated calibration case/request mismatch")
            if generated_bundle.family != request.variant:
                raise ValidationError("generated calibration family/request mismatch")
            manifest_hash = generated_manifest.get("bundle_sha256")
            if manifest_hash and manifest_hash != generated_bundle.bundle_sha256:
                raise ValidationError("generated calibration bundle hash mismatch")
            expects_compile_only = bool(request.configuration.get("compile_only"))
            if (generated_bundle.status == "compile_only") != expects_compile_only:
                raise ValidationError("generated calibration compile-only contract mismatch")
            actual_source_hash = str(generated_bundle.bundle_sha256)
            expected_bundle_hash = request.configuration.get(
                "expected_generated_bundle_sha256"
            )
            if not expected_bundle_hash:
                raise ValidationError(
                    "generated calibration execution requires a materialized "
                    "bundle hash; plan with calibrate --materialize first"
                )
            if expected_bundle_hash != actual_source_hash:
                raise ValidationError(
                    "generated calibration source changed since materialization: "
                    f"expected={expected_bundle_hash!r}, actual={actual_source_hash!r}"
                )
            if request.source_hash != actual_source_hash:
                raise ValidationError(
                    "RunRequest source_hash does not identify the generated bundle: "
                    f"request={request.source_hash!r}, generated={actual_source_hash!r}"
                )
            if generated_bundle.status == "unsupported":
                context = {
                    "unsupported": True,
                    "reason": generated_bundle.reason,
                    "generated_manifest": generated_manifest,
                    "source_hash_verified": actual_source_hash,
                }
                self._prepared[request.request_key] = context
                return context
        else:
            source_value = request.configuration.get("kernel_dir")
            if not source_value:
                raise ValidationError("HwVsSimRunner requires configuration.kernel_dir")
            source = Path(str(source_value)).resolve()
            commands = source / "commands_wse3.sh"
            if not commands.is_file():
                raise ValidationError(f"missing {commands}")
            host_bracketed = hw_vs_sim.host_launched_timer(source)
            manifest_path = source / ADAPTER_MANIFEST_NAME
            full_manifest_path = source / FULL_ADAPTER_MANIFEST_NAME
            if request.telemetry_level == "full":
                if not full_manifest_path.is_file():
                    raise ValidationError(
                        f"full telemetry request has no {FULL_ADAPTER_MANIFEST_NAME}"
                    )
                try:
                    adapter_manifest = validated_full_adapter_manifest(source)
                    _require_full_adapter_execution_evidence(adapter_manifest)
                except ValidationError as exc:
                    raise ValidationError(
                        f"bundle has an invalid or execution-blocked full telemetry adapter: {exc}"
                    ) from exc
            elif manifest_path.is_file():
                try:
                    adapter_manifest = validated_adapter_manifest(source)
                except ValidationError as exc:
                    raise ValidationError(
                        f"bundle has an invalid device timing adapter: {exc}"
                    ) from exc
            elif host_bracketed:
                raise ValidationError(
                    "bundle uses host-launched f_tic/f_toc without a current device-internal adapter"
                )
            else:
                raise ValidationError(
                    "native bundle has no conservative device-timing attestation manifest"
                )
            assert adapter_manifest is not None
            supported_levels = adapter_manifest.get("telemetry_levels") or []
            if request.telemetry_level not in supported_levels:
                raise ValidationError(
                    f"adapter supports {supported_levels}, not requested {request.telemetry_level!r} telemetry"
                )
            actual_source_hash = (
                str(adapter_manifest["source_hash_after"])
            )
            if request.source_hash != actual_source_hash:
                raise ValidationError(
                    "RunRequest source_hash does not identify the staged bundle: "
                    f"request={request.source_hash!r}, staged={actual_source_hash!r}"
                )

            if self.port_to_sdk210:
                if adapter_manifest is not None:
                    raise ValidationError(
                        "instrumented bundles must already be staged/ported; "
                        "porting again would invalidate the adapter source hash"
                    )
                bundle = Path(
                    hardware_submit.port_kernel_to_sdk210(
                        str(source), str(work / "bundle")
                    )
                )
            else:
                # Helpers create run drivers/out.json, so copy even an already-
                # 2.10 source and leave canonical/staged inputs unchanged.
                shutil.copytree(source, work / "bundle")
                bundle = work / "bundle"
            hw_vs_sim.vendor_benchmark_libs(bundle)

        commands = bundle / "commands_wse3.sh"
        if not commands.is_file():
            raise ValidationError(f"missing {commands}")

        compile_variant = self._single_compile_variant(commands, request.subject)
        compile_variants = [compile_variant]
        spec = hw_vs_sim.parse_commands_script(commands)
        compile_only = bool(request.configuration.get("compile_only"))
        run_argv = [] if compile_only else self._run_argv(spec)
        self._synthesize_out_json(bundle, spec, run_argv)
        compiled_bundle_hash = hash_tree(bundle, exclude_names=_ADAPTER_HASH_EXCLUDES)
        arm_name = "sim" if request.arm == "simulator" else "hw"
        simulator = request.arm == "simulator"
        generated_compile = (
            generated_manifest.get("compile", {})
            if isinstance(generated_manifest, Mapping)
            else {}
        )
        simulator_fabric_dims = (
            generated_compile.get("simulator_fabric_dims")
            if isinstance(generated_compile, Mapping)
            else None
        )
        effective_compiler_args = self._effective_cslc_args(
            str(spec["cslc_args"]),
            simulator=simulator,
            simulator_fabric_dims=simulator_fabric_dims,
        )
        effective_fabric_dims = self._fabric_dims_from_args(effective_compiler_args)
        sdk_version = _distribution_version("cerebras-sdk")
        client_version = _distribution_version("cerebras-appliance")
        compile_identity_hash = canonical_hash(
            {
                "compiled_bundle_hash": compiled_bundle_hash,
                "csl_main": str(spec["csl_main"]),
                "compiler_args": effective_compiler_args,
                "fabric_dims": effective_fabric_dims,
                "arm": request.arm,
                "sdk_version": sdk_version,
                "client_version": client_version,
                "variant": request.variant,
                "variant_index": 0,
            }
        )
        try:
            artifact = hw_vs_sim.compile_arm(
                bundle,
                str(spec["csl_main"]),
                effective_compiler_args,
                simulator,
            )
        except Exception as exc:
            if not compile_only:
                # Compilation has already resolved an arm-specific command at
                # this point. Carry it through the exception so the ledger
                # records the compact simulator fabric (or the effective
                # hardware fabric), not HwVsSimRunner.provenance's generic
                # full-wafer default.
                setattr(
                    exc,
                    _EXCEPTION_PROVENANCE_ATTR,
                    {
                        "compiler_args": effective_compiler_args,
                        "fabric_dims": effective_fabric_dims,
                        "source_hash_verified": actual_source_hash,
                        "compiled_bundle_hash": compiled_bundle_hash,
                        "compile_identity_hash": compile_identity_hash,
                        "compile_stage": "compile_arm",
                    },
                )
                raise
            compile_error = f"{type(exc).__name__}: {exc}"
            capacity_failure = bool(self._MEMORY_CAPACITY_RE.search(compile_error))
            context = {
                "compile_probe": True,
                "compile_success": False,
                "capacity_failure": capacity_failure,
                "compile_error": compile_error[:4000],
                "bundle": bundle,
                "simulator": simulator,
                "arm_name": arm_name,
                "compiler_args": effective_compiler_args,
                "fabric_dims": effective_fabric_dims,
                "adapter_manifest": adapter_manifest,
                "generated_manifest": generated_manifest,
                "source_hash_verified": actual_source_hash,
                "compiled_bundle_hash": compiled_bundle_hash,
                "compile_identity_hash": compile_identity_hash,
            }
            self._prepared[request.request_key] = context
            return context
        original_artifact = str(artifact)
        preserved_artifact: str | None = None
        artifact_sha256: str | None = None
        artifact_bytes: int | None = None
        artifact_store = request.configuration.get("artifact_store")
        if artifact_store:
            source_artifact = Path(original_artifact)
            compile_store = (
                Path(str(artifact_store)).resolve()
                / safe_name(request.subject)
                / request.arm
                / request.request_key[:16]
            )
            destination = compile_store / source_artifact.name
            retained = _atomic_verified_artifact_copy(source_artifact, destination)
            preserved_artifact = str(destination)
            artifact_sha256 = str(retained["artifact_sha256"])
            artifact_bytes = int(retained["artifact_bytes"])
            sidecar = compile_record(
                request=request.to_dict(),
                compiler_archive=destination,
                artifact_original=original_artifact,
                compiler_args=effective_compiler_args,
                csl_main=str(spec["csl_main"]),
                compiled_bundle_hash=compiled_bundle_hash,
                compile_identity_hash=compile_identity_hash,
                source_hash_verified=actual_source_hash,
                sdk_version=sdk_version,
                client_version=client_version,
                compile_variant_count=len(compile_variants),
                compile_variant_index=0,
                compile_variant_command_sha256=canonical_hash(
                    compile_variant["command"]
                ),
            )
            atomic_write_json(
                compile_store / "compile.json",
                sidecar,
            )
        elif Path(original_artifact).is_file():
            artifact_sha256 = hash_file(original_artifact)
            artifact_bytes = Path(original_artifact).stat().st_size
        context = {
            "bundle": bundle,
            "artifact": preserved_artifact or original_artifact,
            "artifact_original": original_artifact,
            "artifact_preserved": preserved_artifact,
            "artifact_sha256": artifact_sha256,
            "artifact_bytes": artifact_bytes,
            "simulator": simulator,
            "arm_name": arm_name,
            "run_argv": run_argv,
            "compiler_args": effective_compiler_args,
            "fabric_dims": effective_fabric_dims,
            "adapter_manifest": adapter_manifest,
            "generated_manifest": generated_manifest,
            "source_hash_verified": actual_source_hash,
            "compiled_bundle_hash": compiled_bundle_hash,
            "compile_identity_hash": compile_identity_hash,
            "compile_probe": compile_only,
            "compile_success": True,
            "capacity_failure": False,
        }
        self._prepared[request.request_key] = context
        return context

    @staticmethod
    def _batch_id(
        request: RunRequest, events: Sequence[tuple[bool, int]]
    ) -> str:
        return canonical_hash(
            {
                "request_key": request.request_key,
                "events": [
                    {"warmup": warmup, "trial": trial}
                    for warmup, trial in events
                ],
            }
        )

    @staticmethod
    def _runtime_common(
        request: RunRequest, context: Mapping[str, Any]
    ) -> dict[str, Any]:
        artifact = str(context["artifact"])
        job_matches = HwVsSimRunner._JOB_RE.findall(artifact)
        return {
            "artifact_path": artifact,
            "artifact_id": Path(artifact).name,
            "artifact_original": context.get("artifact_original"),
            "artifact_preserved": context.get("artifact_preserved"),
            "artifact_sha256": context.get("artifact_sha256"),
            "artifact_bytes": context.get("artifact_bytes"),
            "job_id": job_matches[-1] if job_matches else None,
            "compiler_args": context["compiler_args"],
            "fabric_dims": context.get("fabric_dims"),
            "source_hash_verified": context["source_hash_verified"],
            "compiled_bundle_hash": context["compiled_bundle_hash"],
            "compile_identity_hash": context["compile_identity_hash"],
            "timing_method": (
                "device_internal_synchronized"
                if context.get("adapter_manifest")
                and (context["adapter_manifest"].get("timing") or {}).get(
                    "official_cross_pe_sync"
                )
                is True
                else "device_internal"
            ),
            "evidence": request.evidence,
            "adapter_status": (
                context["adapter_manifest"].get("status")
                if context.get("adapter_manifest")
                else (
                    "generated_device_internal"
                    if context.get("generated_manifest")
                    else "native_device_internal"
                )
            ),
        }

    @staticmethod
    def _suite_batch_driver_source(
        *,
        artifact: str,
        simulator: bool,
        bundle: Path,
        run_argv: Sequence[str],
        events: Sequence[tuple[str, bool, int]],
    ) -> str:
        """Create a subprocess driver with one shared appliance runtime.

        Each original ``run.py`` invocation gets a fresh Python global scope,
        while ``SdkRuntime.stop`` is deferred until every requested event has
        run. The original frozen host file is not edited.
        """

        code_dir = Path(__file__).resolve().parents[3] / "code_translation"
        postlude_path: Path | None = None
        adapter_path = bundle / ADAPTER_MANIFEST_NAME
        if adapter_path.is_file():
            adapter = json.loads(adapter_path.read_text(encoding="utf-8"))
            d2h = adapter.get("d2h") if isinstance(adapter, Mapping) else None
            postlude_name = d2h.get("postlude") if isinstance(d2h, Mapping) else None
            if postlude_name:
                candidate = (bundle / str(postlude_name)).resolve()
                try:
                    candidate.relative_to(bundle.resolve())
                except ValueError as exc:
                    raise ValidationError("endpoint postlude escapes prepared bundle") from exc
                if not candidate.is_file():
                    raise ValidationError("endpoint postlude is missing from prepared bundle")
                postlude_path = candidate
        template = r'''import contextlib
import io
import json
import os
import re
import runpy
import sys
import time
import traceback

CODE_DIR = __CODE_DIR__
ARTIFACT = __ARTIFACT__
SIMULATOR = __SIMULATOR__
WORKDIR = __WORKDIR__
RUNPY_PATH = __RUNPY_PATH__
POSTLUDE_PATH = __POSTLUDE_PATH__
RUN_ARGV = json.loads(__RUN_ARGV_JSON__)
EVENTS = json.loads(__EVENTS_JSON__)

sys.path.insert(0, CODE_DIR)
import hw_sim_shim
from cerebras.sdk.client import SdkRuntime as ApplianceRuntime

shared = ApplianceRuntime(
    ARTIFACT, simulator=SIMULATOR, disable_version_check=True
)
shared.__enter__()

class SharedRuntime:
    def __init__(self, *args, **kwargs):
        self._impl = shared
    def load(self):
        return None
    def run(self):
        return None
    def start(self):
        return None
    def stop(self):
        return None
    def __enter__(self):
        return self
    def __exit__(self, *exc):
        return False
    def __getattr__(self, name):
        return getattr(self._impl, name)

hw_sim_shim.install_shim(ARTIFACT, simulator=SIMULATOR)
sys.modules["cerebras.sdk.runtime.sdkruntimepybind"].SdkRuntime = SharedRuntime

try:
    for event in EVENTS:
        captured_out = io.StringIO()
        captured_err = io.StringIO()
        returncode = 0
        started = time.monotonic()
        try:
            os.chdir(WORKDIR)
            sys.argv = ["run.py"] + list(RUN_ARGV)
            with contextlib.redirect_stdout(captured_out), contextlib.redirect_stderr(captured_err):
                runpy.run_path(RUNPY_PATH, run_name="__main__")
                if POSTLUDE_PATH is not None:
                    runpy.run_path(
                        POSTLUDE_PATH,
                        init_globals={"runner": shared},
                        run_name="__wse3study_endpoint_postlude__",
                    )
        except SystemExit as exc:
            if exc.code is None:
                returncode = 0
            elif isinstance(exc.code, int):
                returncode = exc.code
            else:
                returncode = 1
                captured_err.write(str(exc.code))
        except BaseException:
            returncode = 1
            traceback.print_exc(file=captured_err)
        stdout = captured_out.getvalue()
        stderr = captured_err.getvalue()
        matches = re.findall(r"cycles_send\s*=\s*(\d+)", stdout + "\n" + stderr)
        payload = {
            "event_key": event["event_key"],
            "warmup": bool(event["warmup"]),
            "trial": int(event["trial"]),
            "returncode": returncode,
            "wall_s": round(time.monotonic() - started, 3),
            "cycles_send": int(matches[-1]) if matches else None,
            "success_marker": bool(re.search(r"\bSUCCESS\b", stdout)) and returncode == 0,
            "stdout_tail": stdout[-4000:],
            "stderr_tail": stderr[-4000:],
        }
        print(
            "WSE3STUDY_BATCH_EVENT="
            + json.dumps(payload, sort_keys=True, separators=(",", ":")),
            flush=True,
        )
        if returncode != 0:
            break
finally:
    shared.__exit__(None, None, None)
'''
        replacements = {
            "__CODE_DIR__": repr(str(code_dir)),
            "__ARTIFACT__": repr(artifact),
            "__SIMULATOR__": repr(bool(simulator)),
            "__WORKDIR__": repr(str(bundle)),
            "__RUNPY_PATH__": repr(str(bundle / "run.py")),
            "__POSTLUDE_PATH__": repr(str(postlude_path)) if postlude_path else "None",
            "__RUN_ARGV_JSON__": repr(json.dumps(list(run_argv))),
            "__EVENTS_JSON__": repr(
                json.dumps(
                    [
                        {
                            "event_key": event_key,
                            "warmup": warmup,
                            "trial": trial,
                        }
                        for event_key, warmup, trial in events
                    ]
                )
            ),
        }
        for marker, value in replacements.items():
            template = template.replace(marker, value)
        return template

    def _run_suite_batch(
        self,
        request: RunRequest,
        context: Mapping[str, Any],
        events: Sequence[tuple[bool, int]],
        *,
        conditioning_warmups: int = 0,
    ) -> Mapping[str, Mapping[str, Any]]:
        batch_id = self._batch_id(request, events)
        bundle = Path(context["bundle"])
        driver = bundle / f"_wse3study_batch_{batch_id[:16]}.py"
        conditioning_events = [
            (
                canonical_hash(
                    {
                        "batch_id": batch_id,
                        "conditioning_warmup": ordinal,
                    }
                ),
                True,
                ordinal,
                False,
            )
            for ordinal in range(conditioning_warmups)
        ]
        identified_events = conditioning_events + [
            (
                request.event_key(warmup=warmup, trial=trial),
                warmup,
                trial,
                True,
            )
            for warmup, trial in events
        ]
        driver.write_text(
            self._suite_batch_driver_source(
                artifact=str(context["artifact"]),
                simulator=bool(context["simulator"]),
                bundle=bundle,
                run_argv=list(context["run_argv"]),
                events=[value[:3] for value in identified_events],
            ),
            encoding="utf-8",
        )
        started = time.monotonic()
        try:
            process = subprocess.run(
                [sys.executable, str(driver)],
                cwd=str(bundle),
                capture_output=True,
                text=True,
                timeout=request.timeout_s,
            )
            stdout, stderr, returncode = (
                process.stdout,
                process.stderr,
                process.returncode,
            )
        except subprocess.TimeoutExpired as exc:
            stdout = (
                exc.stdout.decode()
                if isinstance(exc.stdout, bytes)
                else (exc.stdout or "")
            )
            stderr = (
                exc.stderr.decode()
                if isinstance(exc.stderr, bytes)
                else (exc.stderr or "")
            )
            stderr += "\nTIMEOUT"
            returncode = -1
        batch_wall_s = round(time.monotonic() - started, 3)
        decoded: dict[str, dict[str, Any]] = {}
        for match in self._BATCH_EVENT_RE.finditer(stdout):
            try:
                row = json.loads(match.group(1))
            except json.JSONDecodeError:
                continue
            event_key = str(row.get("event_key") or "")
            if not event_key:
                continue
            if event_key in decoded:
                decoded[event_key] = {
                    "event_key": event_key,
                    "status": "runner_error",
                    "reason": "suite batch emitted duplicate event result",
                }
            else:
                decoded[event_key] = row

        common = self._runtime_common(request, context)
        job_matches = self._JOB_RE.findall(
            "\n".join((str(context["artifact"]), stdout, stderr))
        )
        if job_matches:
            common["job_id"] = job_matches[-1]
        expected_event_keys = {value[0] for value in identified_events}
        unexpected_event_keys = sorted(set(decoded) - expected_event_keys)
        batch_completed = (
            returncode == 0 and set(decoded) == expected_event_keys
        )
        results: dict[str, Mapping[str, Any]] = {}
        recorded_ordinal = 0
        for runtime_ordinal, (
            event_key,
            warmup,
            trial,
            record_event,
        ) in enumerate(identified_events):
            row = decoded.get(event_key)
            if row is None:
                continue
            if not record_event:
                continue
            row_returncode = row.get("returncode")
            cycles = row.get("cycles_send")
            success = row.get("success_marker") is True
            status = "pass"
            reason: str | None = None
            if row.get("status") == "runner_error":
                status = "runner_error"
                reason = str(row.get("reason"))
            elif row_returncode != 0:
                status, reason = "fail", f"run.py exited {row_returncode}"
            elif not success:
                status, reason = "fail", "no SUCCESS marker"
            elif isinstance(cycles, bool) or not isinstance(cycles, int):
                status, reason = "correctness_only", "no cycles_send printed"
            elif cycles < DEFAULT_DEAD_TIMER_FLOOR:
                status = "rejected_dead_timer"
                reason = (
                    f"cycles_send={cycles} < {DEFAULT_DEAD_TIMER_FLOOR}; "
                    "frozen TSC or empty timed window"
                )
            final_result = {
                **row,
                **common,
                "status": status,
                "reason": reason,
                "correctness": success,
                "elapsed_cycles": cycles,
                "hw_comparable": True,
                "warmup": warmup,
                "trial": trial,
                "batch_id": batch_id,
                "batch_size": len(events),
                "batch_ordinal": recorded_ordinal,
                "batch_runtime_ordinal": runtime_ordinal,
                "batch_runtime_iterations": len(identified_events),
                "batch_conditioning_warmups": conditioning_warmups,
                "batch_completed": batch_completed,
                "batch_wall_s": batch_wall_s,
                "batch_process_returncode": returncode,
                "batch_unexpected_event_keys": unexpected_event_keys,
                "batch_stdout_tail": stdout[-1500:],
                "batch_stderr_tail": stderr[-1500:],
            }
            self._persist_event_artifact(
                request,
                final_result,
                trial_index=trial,
                warmup=warmup,
            )
            results[event_key] = final_result
            recorded_ordinal += 1
        return results

    def _run_calibration_batch(
        self,
        request: RunRequest,
        context: Mapping[str, Any],
        events: Sequence[tuple[bool, int]],
        *,
        conditioning_warmups: int = 0,
    ) -> Mapping[str, Mapping[str, Any]]:
        _, hw_vs_sim = self._helpers()
        batch_id = self._batch_id(request, events)
        bundle = Path(context["bundle"])
        result_root = bundle / "_wse3study_results"
        result_root.mkdir(parents=True, exist_ok=True)
        output_path = result_root / f"batch-{batch_id[:20]}.jsonl"
        event_plan_path = result_root / f"batch-{batch_id[:20]}-events.json"
        try:
            output_path.unlink()
        except FileNotFoundError:
            pass
        event_plan = [
            {
                "event_key": canonical_hash(
                    {
                        "batch_id": batch_id,
                        "conditioning_warmup": ordinal,
                    }
                ),
                "warmup": True,
                "trial": ordinal,
                "conditioning": True,
            }
            for ordinal in range(conditioning_warmups)
        ] + [
            {
                "event_key": request.event_key(warmup=warmup, trial=trial),
                "warmup": warmup,
                "trial": trial,
                "conditioning": False,
            }
            for warmup, trial in events
        ]
        atomic_write_json(event_plan_path, event_plan)
        run_argv = self._calibration_batch_run_argv(
            list(context["run_argv"]),
            output_path=output_path,
            event_plan_path=event_plan_path,
            simulator=bool(context["simulator"]),
        )
        arm_result = dict(
            hw_vs_sim.run_arm(
                bundle,
                str(context["artifact"]),
                bool(context["simulator"]),
                run_argv,
                request.timeout_s,
            )
        )
        rows: dict[str, dict[str, Any]] = {}
        if output_path.is_file():
            for line in output_path.read_text(encoding="utf-8").splitlines():
                if not line.strip():
                    continue
                try:
                    row = json.loads(line)
                except json.JSONDecodeError:
                    continue
                event_key = str(row.get("event_key") or "")
                if not event_key:
                    continue
                if event_key in rows:
                    rows[event_key] = {
                        "event_key": event_key,
                        "status": "runner_error",
                        "reason": "calibration batch emitted duplicate event result",
                    }
                else:
                    rows[event_key] = row

        common = self._runtime_common(request, context)
        blob = "\n".join(
            str(arm_result.get(key) or "")
            for key in ("stdout_tail", "stderr_tail", "artifact_path")
        )
        discovered_jobs = self._JOB_RE.findall(blob)
        if discovered_jobs:
            common["job_id"] = discovered_jobs[-1]
        expected_event_keys = {
            str(planned["event_key"]) for planned in event_plan
        }
        unexpected_event_keys = sorted(set(rows) - expected_event_keys)
        batch_completed = (
            arm_result.get("returncode") == 0
            and set(rows) == expected_event_keys
        )
        results: dict[str, Mapping[str, Any]] = {}
        if not rows:
            # A failed generated host may return useful appliance diagnostics
            # (including a service job ID) without ever reaching its JSONL
            # emission point. Attribute that batch failure to exactly the
            # first requested event. ``run_requests`` will leave every event
            # unaccepted and resume the remaining work on the next invocation.
            first_warmup, first_trial = events[0]
            first_event_key = request.event_key(
                warmup=first_warmup, trial=first_trial
            )
            screening_reason = arm_result.get("reason")
            failure_result = {
                **arm_result,
                **common,
                "status": "runner_error",
                "runner_screening_status": arm_result.get("status"),
                "runner_screening_reason": screening_reason,
                "reason": screening_reason
                or "calibration batch emitted no structured event results",
                "correctness": arm_result.get("success_marker"),
                "elapsed_cycles": None,
                "hw_comparable": True,
                "warmup": first_warmup,
                "trial": first_trial,
                "batch_id": batch_id,
                "batch_size": len(events),
                "batch_ordinal": 0,
                "batch_runtime_ordinal": conditioning_warmups,
                "batch_runtime_iterations": len(event_plan),
                "batch_conditioning_warmups": conditioning_warmups,
                "batch_completed": False,
                "batch_unexpected_event_keys": unexpected_event_keys,
                "batch_structured_rows": 0,
            }
            self._persist_event_artifact(
                request,
                failure_result,
                trial_index=first_trial,
                warmup=first_warmup,
            )
            return {first_event_key: failure_result}
        recorded_ordinal = 0
        for runtime_ordinal, planned in enumerate(event_plan):
            event_key = str(planned["event_key"])
            row = rows.get(event_key)
            if row is None:
                continue
            if planned.get("conditioning"):
                continue
            warmup = bool(planned["warmup"])
            trial = int(planned["trial"])
            structured_status = str(row.get("status", "fail"))
            final_result = {
                **arm_result,
                **row,
                **common,
                "status": structured_status,
                "runner_screening_status": arm_result.get("status"),
                "runner_screening_reason": arm_result.get("reason"),
                "reason": (
                    None
                    if structured_status == "pass"
                    else row.get("reason") or arm_result.get("reason")
                ),
                "correctness": row.get("correctness"),
                "elapsed_cycles": row.get("elapsed_cycles"),
                "timing_method": (
                    "device_internal_synchronized"
                    if row.get("synchronization_protocol")
                    == "sdk-bandwidth-test"
                    else "device_internal"
                ),
                "hw_comparable": True,
                "warmup": warmup,
                "trial": trial,
                "batch_id": batch_id,
                "batch_size": len(events),
                "batch_ordinal": recorded_ordinal,
                "batch_runtime_ordinal": runtime_ordinal,
                "batch_runtime_iterations": len(event_plan),
                "batch_conditioning_warmups": conditioning_warmups,
                "batch_completed": batch_completed,
                "batch_unexpected_event_keys": unexpected_event_keys,
            }
            self._persist_event_artifact(
                request,
                final_result,
                trial_index=trial,
                warmup=warmup,
            )
            results[event_key] = final_result
            recorded_ordinal += 1
        return results

    def run_batch(
        self,
        request: RunRequest,
        *,
        events: Sequence[tuple[bool, int]],
    ) -> Mapping[str, Mapping[str, Any]]:
        """Execute pending events with at most one appliance runtime.

        The returned map remains per-event; the campaign ledger therefore
        retains its existing resume and attempt semantics even though runtime
        setup is amortized over a whole request.
        """

        if not events:
            return {}
        if len(set(events)) != len(events):
            raise ValidationError("batch event list contains duplicates")
        for warmup, trial in events:
            if (
                not isinstance(warmup, bool)
                or isinstance(trial, bool)
                or not isinstance(trial, int)
                or trial < 0
            ):
                raise ValidationError("invalid batch warmup/trial identity")
        context = self._prepare(request)
        if context.get("unsupported") or context.get("compile_probe"):
            return {
                request.event_key(warmup=warmup, trial=trial): self.run(
                    request, trial_index=trial, warmup=warmup
                )
                for warmup, trial in events
            }
        pending_warmups = sum(1 for warmup, _ in events if warmup)
        conditioning_warmups = max(0, request.warmups - pending_warmups)
        if request.kind == "calibration":
            return self._run_calibration_batch(
                request,
                context,
                events,
                conditioning_warmups=conditioning_warmups,
            )
        return self._run_suite_batch(
            request,
            context,
            events,
            conditioning_warmups=conditioning_warmups,
        )

    def run(
        self, request: RunRequest, *, trial_index: int, warmup: bool
    ) -> Mapping[str, Any]:
        _, hw_vs_sim = self._helpers()
        context = self._prepare(request)
        if context.get("unsupported"):
            unsupported_result = {
                "status": "unsupported",
                "reason": context.get("reason") or "calibration case unsupported",
                "evidence": request.evidence,
                "source_hash_verified": context.get("source_hash_verified"),
            }
            self._persist_event_artifact(
                request,
                unsupported_result,
                trial_index=trial_index,
                warmup=warmup,
            )
            return unsupported_result
        if context.get("compile_probe"):
            common_probe = {
                "compiler_args": context.get("compiler_args"),
                "fabric_dims": context.get("fabric_dims"),
                "source_hash_verified": context.get("source_hash_verified"),
                "compiled_bundle_hash": context.get("compiled_bundle_hash"),
                "compile_identity_hash": context.get("compile_identity_hash"),
                "artifact_path": context.get("artifact"),
                "artifact_original": context.get("artifact_original"),
                "artifact_preserved": context.get("artifact_preserved"),
                "artifact_sha256": context.get("artifact_sha256"),
                "artifact_bytes": context.get("artifact_bytes"),
                "evidence": request.evidence,
                "compile_success": bool(context.get("compile_success")),
                "capacity_failure": bool(context.get("capacity_failure")),
                "compile_probe_valid": bool(
                    context.get("compile_success") or context.get("capacity_failure")
                ),
                "compile_error": context.get("compile_error"),
                "requested_allocation_bytes": request.configuration.get(
                    "allocation_bytes"
                ),
            }
            probe_result = {
                **common_probe,
                "status": (
                    "compile_pass"
                    if common_probe["compile_success"]
                    else (
                        "compile_capacity_fail"
                        if common_probe["capacity_failure"]
                        else "compile_fail"
                    )
                ),
            }
            self._persist_event_artifact(
                request,
                probe_result,
                trial_index=trial_index,
                warmup=warmup,
            )
            return probe_result
        artifact = str(context["artifact"])
        job_matches = self._JOB_RE.findall(artifact)
        common = {
            "artifact_path": artifact,
            "artifact_id": Path(artifact).name,
            "artifact_original": context.get("artifact_original"),
            "artifact_preserved": context.get("artifact_preserved"),
            "artifact_sha256": context.get("artifact_sha256"),
            "artifact_bytes": context.get("artifact_bytes"),
            "job_id": job_matches[-1] if job_matches else None,
            "compiler_args": context["compiler_args"],
            "fabric_dims": context.get("fabric_dims"),
            "source_hash_verified": context["source_hash_verified"],
            "compiled_bundle_hash": context["compiled_bundle_hash"],
            "compile_identity_hash": context["compile_identity_hash"],
            "timing_method": (
                "device_internal_synchronized"
                if context.get("adapter_manifest")
                and (context["adapter_manifest"].get("timing") or {}).get(
                    "official_cross_pe_sync"
                ) is True
                else "device_internal"
            ),
            "evidence": request.evidence,
            "adapter_status": (
                context["adapter_manifest"].get("status")
                if context.get("adapter_manifest")
                else (
                    "generated_device_internal"
                    if context.get("generated_manifest")
                    else "native_device_internal"
                )
            ),
            "warmup": warmup,
            "trial": trial_index,
        }
        run_argv = list(context["run_argv"])
        calibration_output: Path | None = None
        if request.kind == "calibration":
            calibration_output = (
                Path(context["bundle"])
                / "_wse3study_results"
                / f"{request.event_key(warmup=warmup, trial=trial_index)}.jsonl"
            )
            calibration_output.parent.mkdir(parents=True, exist_ok=True)
            run_argv = self._calibration_run_argv(
                run_argv,
                output_path=calibration_output,
                simulator=bool(context["simulator"]),
            )
        result = dict(
            hw_vs_sim.run_arm(
                context["bundle"],
                artifact,
                bool(context["simulator"]),
                run_argv,
                request.timeout_s,
            )
        )
        blob = "\n".join(
            str(result.get(key) or "")
            for key in ("stdout_tail", "stderr_tail", "artifact_path")
        )
        discovered_jobs = self._JOB_RE.findall(blob)
        if discovered_jobs:
            common["job_id"] = discovered_jobs[-1]
        calibration_result: dict[str, Any] = {}
        if calibration_output is not None and calibration_output.is_file():
            lines = [
                line
                for line in calibration_output.read_text(encoding="utf-8").splitlines()
                if line.strip()
            ]
            if len(lines) != 1:
                result["status"] = "fail"
                result["reason"] = (
                    f"expected one calibration result, found {len(lines)}"
                )
            else:
                try:
                    calibration_result = json.loads(lines[0])
                except json.JSONDecodeError:
                    result["status"] = "fail"
                    result["reason"] = "invalid calibration JSONL result"
        elif request.kind == "calibration":
            match = self._CALIBRATION_RESULT_RE.search(
                str(result.get("stdout_tail") or "")
            )
            if match:
                try:
                    calibration_result = json.loads(match.group(1))
                except json.JSONDecodeError:
                    pass
            if not calibration_result:
                result["status"] = "fail"
                result["reason"] = "calibration run emitted no structured result"
        screening_status = str(result.get("status", "fail"))
        final_status = screening_status
        if (
            calibration_result
            and result.get("returncode") == 0
            and result.get("success_marker") is True
        ):
            # hw_vs_sim's generic 100-cycle screen protects legacy suite
            # bundles.  Generated controls carry raw live-TSC proof and may
            # legitimately measure shorter paths; validate_result performs the
            # stricter structured check below.
            final_status = str(calibration_result.get("status", "pass"))
        structured_evidence = calibration_result.get("evidence", common["evidence"])
        synchronized = (
            calibration_result.get("synchronization_protocol")
            == "sdk-bandwidth-test"
        )
        final_result = {
            **result,
            **calibration_result,
            **common,
            "status": final_status,
            "runner_screening_status": screening_status,
            "runner_screening_reason": result.get("reason"),
            "reason": None if final_status == "pass" else result.get("reason"),
            "evidence": structured_evidence,
            "correctness": calibration_result.get(
                "correctness", result.get("success_marker")
            ),
            "elapsed_cycles": calibration_result.get(
                "elapsed_cycles", result.get("cycles_send")
            ),
            "timing_method": (
                "device_internal_synchronized"
                if synchronized
                else "device_internal"
            ),
            "hw_comparable": True,
        }
        self._persist_event_artifact(
            request,
            final_result,
            trial_index=trial_index,
            warmup=warmup,
        )
        return final_result

    def close(self) -> None:
        while self._temporaries:
            self._temporaries.pop().cleanup()
        self._prepared.clear()

    def __enter__(self) -> "HwVsSimRunner":
        return self

    def __exit__(self, *_: Any) -> None:
        self.close()
