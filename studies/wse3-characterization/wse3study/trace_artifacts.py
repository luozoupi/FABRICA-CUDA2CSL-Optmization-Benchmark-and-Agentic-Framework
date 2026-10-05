"""Fail-closed ingestion of retained simulator log-export artifacts.

This module never invokes ``csdb`` and never submits an appliance job.  It
only inspects an already retained Cerebras log-export ZIP, its safely
extracted copy, the append-only campaign ledger, and (when present) the text
files produced by the official SDK 2.10 ``csdb wavelet read-trace`` command.

The binding deliberately keeps three concepts separate:

* the compact simulator fabric used by a particular compilation;
* application-local coordinates derived from the compiled rectangle; and
* compiler fabric coordinates in that compact simulated fabric.

``csdb`` output and CTF records are simulator evidence.  They are not, and are
never labelled as, physical WSE hardware traces.
"""

from __future__ import annotations

import hashlib
import os
import re
import shlex
import stat
import zipfile
from collections import Counter
from pathlib import Path, PurePosixPath
from typing import Any, Mapping, Sequence

from .artifact_binding import inspect_compiler_archive
from .campaign import load_ledger
from .schema import (
    EvidenceKind,
    SCHEMA_VERSION,
    ValidationError,
    atomic_write_json,
    canonical_hash,
    hash_file,
    load_json,
    safe_name,
    utc_now,
)
from .telemetry import words_to_u48
from .trace import CtfTraceReader, TraceWindow, crop_events, write_events_jsonl_gz


TRACE_ARTIFACT_SCHEMA_VERSION = "1.0.0"
_JOB_ID = re.compile(r"^wsjob-[a-z0-9]+$")
_EXPORT_NAME = re.compile(
    r"^log-export-(?P<job>wsjob-[a-z0-9]+)-[A-Za-z0-9_.-]+$"
)
_CSDB_LOG = re.compile(r"^wavelet-trace-x(?P<x>\d+)y(?P<y>\d+)\.log$")
_MAX_EXPORT_MEMBERS = 500_000
_MAX_EXPORT_BYTES = 16 * 1024 * 1024 * 1024
_MAX_EXTRACTED_FILES = 500_000
_MAX_EXTRACTED_BYTES = 16 * 1024 * 1024 * 1024
_MAX_CSDB_LOG_BYTES = 2 * 1024 * 1024 * 1024
_MAX_SMALL_METADATA_BYTES = 64 * 1024 * 1024


def _safe_relative_parts(name: str) -> tuple[str, ...]:
    """Validate one archive-style relative path without normalizing it."""

    if not name or "\\" in name or "\x00" in name:
        raise ValidationError(f"unsafe log-export member name: {name!r}")
    value = name.rstrip("/")
    if not value:
        raise ValidationError(f"unsafe log-export member name: {name!r}")
    path = PurePosixPath(value)
    if path.is_absolute() or any(part in {"", ".", ".."} for part in path.parts):
        raise ValidationError(f"unsafe log-export member path: {name!r}")
    return path.parts


def _job_from_export_name(path: Path) -> str:
    name = path.name[:-4] if path.name.endswith(".zip") else path.name
    match = _EXPORT_NAME.fullmatch(name)
    if match is None:
        raise ValidationError(f"unrecognized Cerebras log-export name: {path.name}")
    return match.group("job")


def _zip_member_kind(info: zipfile.ZipInfo) -> str:
    mode = (info.external_attr >> 16) & 0xFFFF
    kind = stat.S_IFMT(mode)
    if info.is_dir() or kind == stat.S_IFDIR:
        return "directory"
    # Some ZIP creators omit POSIX mode bits.  Such non-directory members are
    # still ordinary byte streams, but explicit links/devices are rejected.
    if kind in {0, stat.S_IFREG}:
        return "file"
    raise ValidationError(
        f"log-export contains a link or special member: {info.filename}"
    )


def inspect_log_export_zip(path: str | os.PathLike[str]) -> dict[str, Any]:
    """Inspect a retained log-export ZIP without extracting any member."""

    supplied = Path(path).expanduser()
    if supplied.is_symlink() or not supplied.is_file():
        raise ValidationError(f"log-export ZIP is not a regular file: {supplied}")
    archive = supplied.resolve()
    job_id = _job_from_export_name(archive)
    try:
        with zipfile.ZipFile(archive) as handle:
            infos = handle.infolist()
            if len(infos) > _MAX_EXPORT_MEMBERS:
                raise ValidationError("log-export ZIP has too many members")
            seen: set[str] = set()
            roots: set[str] = set()
            files: set[str] = set()
            total = 0
            for info in infos:
                parts = _safe_relative_parts(info.filename)
                normalized = "/".join(parts)
                if normalized in seen:
                    raise ValidationError(
                        f"duplicate log-export ZIP member: {normalized}"
                    )
                seen.add(normalized)
                roots.add(parts[0])
                kind = _zip_member_kind(info)
                if info.flag_bits & 0x1:
                    raise ValidationError(
                        f"encrypted log-export member is unsupported: {normalized}"
                    )
                if kind == "file":
                    total += int(info.file_size)
                    if total > _MAX_EXPORT_BYTES:
                        raise ValidationError(
                            "log-export ZIP expands beyond the safety limit"
                        )
                    files.add(normalized)
    except (OSError, zipfile.BadZipFile, zipfile.LargeZipFile) as exc:
        raise ValidationError(f"invalid log-export ZIP {archive}: {exc}") from exc

    if len(roots) != 1:
        raise ValidationError("log-export ZIP must have exactly one top-level directory")
    top_level = next(iter(roots))
    if top_level != archive.stem:
        raise ValidationError(
            "log-export ZIP top-level directory differs from its archive name"
        )
    expected_job_yaml = f"{top_level}/{job_id}.yaml"
    if expected_job_yaml not in files:
        raise ValidationError(f"log-export ZIP has no exact {job_id}.yaml job record")
    trace_roots = sorted(
        name[: -len("/simfab_traces/stream0")]
        for name in files
        if name.endswith("/simfab_traces/stream0")
        and name[: -len("/simfab_traces/stream0")] + "/simfab_traces/metadata"
        in files
    )
    return {
        "kind": "cerebras-log-export-zip",
        "path": str(archive),
        "sha256": hash_file(archive),
        "bytes": archive.stat().st_size,
        "job_id": job_id,
        "top_level": top_level,
        "member_count": len(infos),
        "expanded_bytes": total,
        "trace_roots": trace_roots,
        "evidence": EvidenceKind.SIMULATOR.value,
        "inspection": "metadata-only; no ZIP member was extracted",
    }


def _hash_zip_member(path: Path, member_name: str) -> str:
    """Hash one already safety-inspected regular ZIP member in streaming mode."""

    inspection = inspect_log_export_zip(path)
    if not member_name.startswith(str(inspection["top_level"]) + "/"):
        raise ValidationError("requested ZIP member is outside the inspected export root")
    digest = hashlib.sha256()
    try:
        with zipfile.ZipFile(path) as handle:
            info = handle.getinfo(member_name)
            if _zip_member_kind(info) != "file":
                raise ValidationError(f"ZIP member is not a regular file: {member_name}")
            if info.file_size > _MAX_EXPORT_BYTES:
                raise ValidationError(f"ZIP member exceeds safety limit: {member_name}")
            with handle.open(info) as source:
                size = 0
                for block in iter(lambda: source.read(1024 * 1024), b""):
                    size += len(block)
                    if size > info.file_size or size > _MAX_EXPORT_BYTES:
                        raise ValidationError(f"ZIP member exceeds declared size: {member_name}")
                    digest.update(block)
            if size != info.file_size:
                raise ValidationError(f"truncated ZIP member: {member_name}")
    except KeyError as exc:
        raise ValidationError(f"ZIP member is missing: {member_name}") from exc
    except (OSError, RuntimeError, zipfile.BadZipFile) as exc:
        raise ValidationError(f"cannot safely read ZIP member {member_name}: {exc}") from exc
    return digest.hexdigest()


def inspect_extracted_log_export(path: str | os.PathLike[str]) -> dict[str, Any]:
    """Validate an existing extraction without following links or executing files."""

    supplied = Path(path).expanduser()
    if supplied.is_symlink() or not supplied.is_dir():
        raise ValidationError(f"extracted log-export is not a real directory: {supplied}")
    root = supplied.resolve()
    job_id = _job_from_export_name(root)
    file_count = 0
    total = 0
    files: set[str] = set()
    for directory, dirnames, filenames in os.walk(root, followlinks=False):
        base = Path(directory)
        for name in list(dirnames):
            child = base / name
            if child.is_symlink():
                raise ValidationError(f"extracted log-export contains a link: {child}")
        for name in filenames:
            child = base / name
            if child.is_symlink() or not child.is_file():
                raise ValidationError(
                    f"extracted log-export contains a link or special file: {child}"
                )
            try:
                relative = child.resolve(strict=True).relative_to(root).as_posix()
            except ValueError as exc:
                raise ValidationError(
                    f"extracted log-export file escapes its root: {child}"
                ) from exc
            _safe_relative_parts(relative)
            file_count += 1
            total += child.stat().st_size
            if file_count > _MAX_EXTRACTED_FILES or total > _MAX_EXTRACTED_BYTES:
                raise ValidationError("extracted log-export exceeds the safety limit")
            files.add(relative)

    if f"{job_id}.yaml" not in files:
        raise ValidationError(f"extracted log-export has no exact {job_id}.yaml job record")
    job_path = root / f"{job_id}.yaml"
    if job_path.stat().st_size > _MAX_SMALL_METADATA_BYTES:
        raise ValidationError("exported WSJob YAML exceeds the metadata safety limit")
    job_text = job_path.read_text(encoding="utf-8", errors="strict")
    if not re.search(rf"(?m)^  name: {re.escape(job_id)}\s*$", job_text):
        raise ValidationError("exported WSJob YAML does not attest the directory job ID")
    trace_roots = sorted(
        relative[: -len("/simfab_traces/stream0")]
        for relative in files
        if relative.endswith("/simfab_traces/stream0")
        and relative[: -len("/simfab_traces/stream0")] + "/simfab_traces/metadata"
        in files
    )
    return {
        "kind": "extracted-cerebras-log-export",
        "path": str(root),
        "job_id": job_id,
        "file_count": file_count,
        "bytes": total,
        "trace_roots": trace_roots,
        "evidence": EvidenceKind.SIMULATOR.value,
        "inspection": "read-only tree walk; links and special files rejected",
    }


def _ledger_job_id(record: Mapping[str, Any]) -> str | None:
    values = {
        str(value)
        for value in (
            (record.get("provenance") or {}).get("job_id"),
            (record.get("result") or {}).get("job_id"),
        )
        if value
    }
    if len(values) > 1:
        raise ValidationError("ledger provenance/result disagree on simulator job ID")
    return next(iter(values), None)


def discover_simulator_trace_exports(
    campaign_dir: str | os.PathLike[str],
    *,
    artifact_root: str | os.PathLike[str] | None = None,
) -> dict[str, Any]:
    """Correlate ledger job IDs with retained ZIPs and existing extractions."""

    campaign = Path(campaign_dir).expanduser().resolve()
    supplied_artifacts = (
        Path(artifact_root).expanduser()
        if artifact_root is not None
        else campaign / "artifacts"
    )
    if supplied_artifacts.is_symlink():
        raise ValidationError("artifact_root must not be a symbolic link")
    artifacts = supplied_artifacts.resolve()
    records = load_ledger(campaign / "ledger.jsonl")
    ledger_jobs: dict[str, list[dict[str, Any]]] = {}
    for record in records:
        job_id = _ledger_job_id(record)
        if job_id is None:
            continue
        ledger_jobs.setdefault(job_id, []).append(
            {
                "event_key": record.get("event_key"),
                "request_key": record.get("request_key"),
                "subject": record.get("subject"),
                "arm": record.get("arm"),
                "accepted": record.get("accepted") is True,
                "attempt": record.get("attempt"),
            }
        )

    zip_records: list[dict[str, Any]] = []
    log_export_root = artifacts / "log-export"
    if log_export_root.is_dir() and not log_export_root.is_symlink():
        for path in sorted(log_export_root.glob("log-export-*.zip")):
            try:
                zip_records.append(inspect_log_export_zip(path))
            except ValidationError as exc:
                zip_records.append(
                    {"path": str(path), "status": "invalid", "reason": str(exc)}
                )

    extracted_records: list[dict[str, Any]] = []
    extracted_root = artifacts / "extracted"
    if extracted_root.is_dir() and not extracted_root.is_symlink():
        for path in sorted(extracted_root.glob("log-export-*")):
            try:
                extracted_records.append(inspect_extracted_log_export(path))
            except ValidationError as exc:
                extracted_records.append(
                    {"path": str(path), "status": "invalid", "reason": str(exc)}
                )

    jobs: list[dict[str, Any]] = []
    all_job_ids = set(ledger_jobs)
    all_job_ids.update(str(item["job_id"]) for item in zip_records if item.get("job_id"))
    all_job_ids.update(
        str(item["job_id"]) for item in extracted_records if item.get("job_id")
    )
    for job_id in sorted(all_job_ids):
        zips = [item for item in zip_records if item.get("job_id") == job_id]
        extractions = [
            item for item in extracted_records if item.get("job_id") == job_id
        ]
        simulator_events = [
            item
            for item in ledger_jobs.get(job_id, [])
            if item.get("arm") == "simulator" and item.get("accepted")
        ]
        jobs.append(
            {
                "job_id": job_id,
                "ledger_events": ledger_jobs.get(job_id, []),
                "accepted_simulator_event_count": len(simulator_events),
                "retained_zip_count": len(zips),
                "extracted_count": len(extractions),
                "trace_root_count": sum(
                    len(item.get("trace_roots") or []) for item in extractions
                ),
                "binding_candidate": bool(simulator_events and len(zips) == 1 and len(extractions) == 1),
            }
        )
    return {
        "schema_version": TRACE_ARTIFACT_SCHEMA_VERSION,
        "record_type": "simulator-trace-artifact-discovery",
        "campaign": str(campaign),
        "artifact_root": str(artifacts),
        "ledger_sha256": hash_file(campaign / "ledger.jsonl")
        if (campaign / "ledger.jsonl").is_file()
        else None,
        "jobs": jobs,
        "retained_zips": zip_records,
        "extracted_exports": extracted_records,
        "evidence": EvidenceKind.INFERRED.value,
        "limitations": (
            "Discovery correlates retained simulator artifacts; it does not execute "
            "the simulator, csdb, or hardware, and it performs no archive extraction."
        ),
    }


def _only(items: Sequence[Any], description: str) -> Any:
    if len(items) != 1:
        raise ValidationError(f"expected exactly one {description}, found {len(items)}")
    return items[0]


def _common_value(
    record: Mapping[str, Any], field: str, *, result_field: str | None = None
) -> Any:
    result_name = result_field or field
    values = [
        record.get(field),
        (record.get("provenance") or {}).get(field),
        (record.get("result") or {}).get(result_name),
    ]
    present = [value for value in values if value is not None]
    if not present or any(value != present[0] for value in present[1:]):
        raise ValidationError(f"ledger fields disagree or are absent for {field}")
    return present[0]


def _compiler_tokens_from_ledger(record: Mapping[str, Any]) -> list[str]:
    compiler_args = _common_value(record, "compiler_args")
    try:
        return shlex.split(str(compiler_args), posix=True)
    except ValueError as exc:
        raise ValidationError(f"ledger compiler args have invalid quoting: {exc}") from exc


def _coordinate_contract(
    contract: Mapping[str, Any], request: Mapping[str, Any]
) -> dict[str, Any]:
    dimensions = contract.get("fabric_dims")
    offsets = contract.get("fabric_offsets")
    params = contract.get("params") or {}
    rectangle: dict[str, int] | None = None
    try:
        width = int(params["width"], 0) if isinstance(params.get("width"), str) else int(params["width"])
        height = int(params["height"], 0) if isinstance(params.get("height"), str) else int(params["height"])
        if (
            isinstance(offsets, Sequence)
            and not isinstance(offsets, (str, bytes))
            and len(offsets) == 2
            and width > 0
            and height > 0
        ):
            rectangle = {
                "x": int(offsets[0]),
                "y": int(offsets[1]),
                "width": width,
                "height": height,
            }
    except (KeyError, TypeError, ValueError):
        rectangle = None
    return {
        "simulator_fabric_dimensions": {
            "value": dimensions,
            "evidence": EvidenceKind.COMPILED.value,
            "source": "retained compile_command.sh",
        },
        "fabric_offsets": {
            "value": offsets,
            "evidence": EvidenceKind.COMPILED.value,
            "source": "retained compile_command.sh",
        },
        "application_rectangle": {
            "value": rectangle,
            "evidence": EvidenceKind.COMPILED.value if rectangle else EvidenceKind.INFERRED.value,
            "source": (
                "compiled fabric offsets plus explicit width/height parameters"
                if rectangle
                else "application rectangle was not derivable from exact compiler parameters"
            ),
        },
        "application_local_coordinates": (
            "subtract application_rectangle origin from simulator coordinates"
            if rectangle
            else None
        ),
        "compiler_fabric_coordinates": (
            "simulator x/y in the exact compact compiler fabric plane"
        ),
        "hardware_coordinate_warning": (
            "These are simulator/compiler coordinates. They do not expose private "
            "defect/spare remapping and are not a hardware trace."
        ),
        "request_subject": request.get("subject"),
    }


def bind_simulator_trace_artifact(
    campaign_dir: str | os.PathLike[str],
    *,
    job_id: str,
    event_key: str | None = None,
    artifact_root: str | os.PathLike[str] | None = None,
) -> dict[str, Any]:
    """Bind one extracted simulator trace to one accepted campaign event.

    Ambiguous jobs (for example, one batched simulator job containing multiple
    trial windows) require an explicit ``event_key``.  Missing source, compile,
    artifact, fabric, SDK, or TSC evidence is a hard error rather than an
    inferred association.
    """

    if _JOB_ID.fullmatch(job_id) is None:
        raise ValidationError(f"invalid Cerebras job ID: {job_id!r}")
    campaign = Path(campaign_dir).expanduser().resolve()
    supplied_artifacts = (
        Path(artifact_root).expanduser()
        if artifact_root is not None
        else campaign / "artifacts"
    )
    if supplied_artifacts.is_symlink() or not supplied_artifacts.is_dir():
        raise ValidationError("artifact_root is missing or is a symbolic link")
    artifacts = supplied_artifacts.resolve()
    records = []
    for record in load_ledger(campaign / "ledger.jsonl"):
        if _ledger_job_id(record) != job_id:
            continue
        if record.get("arm") != "simulator" or record.get("accepted") is not True:
            continue
        if event_key is not None and record.get("event_key") != event_key:
            continue
        records.append(record)
    record = _only(records, f"accepted simulator ledger event for {job_id}")
    if event_key is None:
        event_key = str(record.get("event_key") or "")
    if not event_key:
        raise ValidationError("bound simulator ledger event has no event_key")

    request = record.get("request") or {}
    if not isinstance(request, Mapping):
        raise ValidationError("bound ledger event has no request object")
    for field in ("request_key", "source_hash", "compile_hash", "subject", "arm"):
        expected = request.get(field)
        actual = record.get(field)
        if expected is None or expected != actual:
            raise ValidationError(f"ledger request and event disagree on {field}")
    if request.get("arm") != "simulator":
        raise ValidationError("bound request is not a simulator request")
    source_hash = str(_common_value(record, "source_hash", result_field="source_hash_verified"))
    if (record.get("provenance") or {}).get("source_hash_verified") != source_hash:
        raise ValidationError("runner did not attest the exact requested source hash")
    compile_hash = str(record.get("compile_hash") or "")
    if not compile_hash:
        raise ValidationError("ledger compile_hash is absent")
    compile_identity = str(_common_value(record, "compile_identity_hash"))
    compiled_bundle_hash = str(_common_value(record, "compiled_bundle_hash"))
    artifact_sha256 = str(_common_value(record, "artifact_sha256"))
    artifact_bytes = int(_common_value(record, "artifact_bytes"))
    compiler_tokens = _compiler_tokens_from_ledger(record)

    provenance = record.get("provenance") or {}
    for field in ("sdk_version", "client_version", "cerebras_appliance_version"):
        value = str(provenance.get(field) or "")
        if not value.startswith("2.10."):
            raise ValidationError(f"ledger {field} is absent or is not SDK 2.10.x")

    supplied_preserved = Path(
        str(provenance.get("artifact_preserved") or "")
    ).expanduser()
    if supplied_preserved.is_symlink() or not supplied_preserved.is_file():
        raise ValidationError("preserved compiler artifact is missing or is a link")
    preserved = supplied_preserved.resolve()
    try:
        preserved.relative_to(artifacts)
    except ValueError as exc:
        raise ValidationError("preserved compiler artifact is outside artifact_root") from exc
    if preserved.stat().st_size != artifact_bytes or hash_file(preserved) != artifact_sha256:
        raise ValidationError("preserved compiler artifact differs from the ledger")
    sidecar_path = preserved.parent / "compile.json"
    if sidecar_path.is_symlink() or not sidecar_path.is_file():
        raise ValidationError("preserved compiler artifact has no safe compile.json sidecar")
    if sidecar_path.stat().st_size > _MAX_SMALL_METADATA_BYTES:
        raise ValidationError("compile.json exceeds the metadata safety limit")
    sidecar = load_json(sidecar_path)
    if not isinstance(sidecar, Mapping):
        raise ValidationError("preserved compiler artifact has no compile.json sidecar")
    sidecar_fields = {
        "request_key": record.get("request_key"),
        "subject": record.get("subject"),
        "arm": "simulator",
        "source_hash": source_hash,
        "compile_identity_hash": compile_identity,
        "compiled_bundle_hash": compiled_bundle_hash,
        "compiler_args": str(_common_value(record, "compiler_args")),
        "artifact_sha256": artifact_sha256,
        "artifact_bytes": artifact_bytes,
    }
    for field, expected in sidecar_fields.items():
        if sidecar.get(field) != expected:
            raise ValidationError(f"compile sidecar does not bind ledger field {field}")
    sidecar_compile_hash = sidecar.get("declared_compile_hash", sidecar.get("compile_hash"))
    if sidecar_compile_hash != compile_hash:
        raise ValidationError("compile sidecar does not bind the request compile_hash")

    zip_matches = []
    log_export_root = artifacts / "log-export"
    if log_export_root.is_dir() and not log_export_root.is_symlink():
        for candidate in sorted(log_export_root.glob(f"log-export-{job_id}-*.zip")):
            inspection = inspect_log_export_zip(candidate)
            if inspection["job_id"] == job_id:
                zip_matches.append(inspection)
    zip_record = _only(zip_matches, f"retained log-export ZIP for {job_id}")
    zip_path = Path(str(zip_record["path"]))

    extracted_matches = []
    extracted_root = artifacts / "extracted"
    if extracted_root.is_dir() and not extracted_root.is_symlink():
        for candidate in sorted(extracted_root.glob(f"log-export-{job_id}-*")):
            inspection = inspect_extracted_log_export(candidate)
            if inspection["job_id"] == job_id:
                extracted_matches.append(inspection)
    extracted_record = _only(extracted_matches, f"safe extracted log-export for {job_id}")
    export_root = Path(str(extracted_record["path"]))

    artifact_name = str((record.get("provenance") or {}).get("artifact_id") or preserved.name)
    if artifact_name != preserved.name:
        raise ValidationError("ledger artifact_id differs from preserved artifact name")
    workdirs = []
    for relative in extracted_record.get("trace_roots") or []:
        candidate = export_root / str(relative)
        nested = candidate / artifact_name
        if nested.is_file() and not nested.is_symlink():
            workdirs.append(candidate)
    workdir = _only(workdirs, "trace workdir containing the exact compiler artifact")
    nested_artifact = workdir / artifact_name
    if nested_artifact.stat().st_size != artifact_bytes or hash_file(nested_artifact) != artifact_sha256:
        raise ValidationError("trace workdir compiler artifact differs from the ledger")

    archive_description = inspect_compiler_archive(nested_artifact)
    if archive_description["artifact_sha256"] != artifact_sha256:
        raise ValidationError("compiler archive inspection disagrees with the ledger hash")
    if archive_description["compiler_arg_tokens"] != compiler_tokens:
        raise ValidationError("trace compile command differs from ledger compiler args")
    contract = archive_description.get("contract") or {}
    if str(contract.get("arch") or "").lower() != "wse3":
        raise ValidationError("trace compiler contract is not --arch=wse3")
    fabric_dims = _common_value(record, "fabric_dims")
    if contract.get("fabric_dims") != fabric_dims:
        raise ValidationError("trace compiler fabric dimensions differ from the ledger")

    simdata_path = workdir / "simfab_traces" / "global_simdata.json"
    if simdata_path.stat().st_size > _MAX_SMALL_METADATA_BYTES:
        raise ValidationError("global_simdata.json exceeds the metadata safety limit")
    simdata = load_json(simdata_path)
    if not isinstance(simdata, Mapping):
        raise ValidationError("trace has no valid global_simdata.json")
    observed_dimensions = [int(simdata.get("xsize", 0)), int(simdata.get("ysize", 0))]
    if observed_dimensions != fabric_dims:
        raise ValidationError("simulator trace plane differs from compiled fabric dimensions")

    relative_workdir = workdir.relative_to(export_root).as_posix()
    zip_workdir = f"{zip_record['top_level']}/{relative_workdir}"
    job_yaml_hash = hash_file(export_root / f"{job_id}.yaml")
    zip_job_yaml_hash = _hash_zip_member(
        zip_path, f"{zip_record['top_level']}/{job_id}.yaml"
    )
    if job_yaml_hash != zip_job_yaml_hash:
        raise ValidationError("extracted WSJob YAML differs from the retained ZIP")
    core_files = (
        "compile_command.sh",
        artifact_name,
        "simfab_traces/global_simdata.json",
        "simfab_traces/metadata",
        "simfab_traces/stream0",
    )
    zip_core_hashes: dict[str, str] = {}
    extracted_core_hashes: dict[str, str] = {}
    for relative in core_files:
        extracted_file = workdir / relative
        if extracted_file.is_symlink() or not extracted_file.is_file():
            raise ValidationError(f"trace workdir core file is missing: {relative}")
        zip_hash = _hash_zip_member(zip_path, f"{zip_workdir}/{relative}")
        extracted_hash = hash_file(extracted_file)
        if zip_hash != extracted_hash:
            raise ValidationError(
                f"extracted trace core file differs from retained ZIP: {relative}"
            )
        zip_core_hashes[relative] = zip_hash
        extracted_core_hashes[relative] = extracted_hash

    result = record.get("result") or {}
    start_words = result.get("start_words_u16")
    end_words = result.get("end_words_u16")
    if not isinstance(start_words, Sequence) or isinstance(start_words, (str, bytes)):
        raise ValidationError("ledger result has no raw start_words_u16")
    if not isinstance(end_words, Sequence) or isinstance(end_words, (str, bytes)):
        raise ValidationError("ledger result has no raw end_words_u16")
    start_cycle = words_to_u48(list(start_words))
    end_cycle = words_to_u48(list(end_words))
    if result.get("timing_method") not in {
        "device_internal",
        "device_internal_synchronized",
    }:
        raise ValidationError("ledger TSC window is not wholly device-internal")
    if result.get("timer_validated") is not True or result.get("correctness") is not True:
        raise ValidationError("ledger TSC window did not pass timer/correctness validation")
    # The device counter is 48-bit, but a non-wrapping interval should retain
    # ordinary before/after diagnostics.  Modulo membership is needed only
    # when the recorded endpoint actually crossed the counter wrap.
    window = TraceWindow(
        start_cycle,
        end_cycle,
        counter_bits=48 if end_cycle < start_cycle else None,
    )
    reader = CtfTraceReader(workdir / "simfab_traces" / "stream0")
    ctf_events = list(reader.iter_events())
    if reader.discarded_events_total:
        raise ValidationError("CTF reports discarded events; exact trace is incomplete")
    crop = crop_events(ctf_events, window)
    if not crop.events:
        raise ValidationError("recorded device TSC window contains no CTF events")

    coordinate_contract = _coordinate_contract(contract, request)
    binding = {
        "schema_version": TRACE_ARTIFACT_SCHEMA_VERSION,
        "record_type": "bound-simulator-trace-artifact",
        "status": "qualified",
        "qualified_at": utc_now(),
        "campaign": str(campaign),
        "job_id": job_id,
        "event_key": event_key,
        "request_key": record.get("request_key"),
        "subject": record.get("subject"),
        "kind": record.get("kind"),
        "trial": record.get("trial"),
        "warmup": record.get("warmup"),
        "source_sha256": source_hash,
        "compile_request_sha256": compile_hash,
        "compile_identity_sha256": compile_identity,
        "compiled_bundle_sha256": compiled_bundle_hash,
        "compiler_artifact_sha256": artifact_sha256,
        "compiler_artifact_bytes": artifact_bytes,
        "compiler_args": str(_common_value(record, "compiler_args")),
        "compiler_contract": contract,
        "coordinate_contract": coordinate_contract,
        "device_tsc_window": {
            "start_cycle": start_cycle,
            "end_cycle": end_cycle,
            "counter_bits": 48,
            "start_words_u16": list(start_words),
            "end_words_u16": list(end_words),
            "source_application_local": result.get("source_pe"),
            "destination_application_local": result.get("destination_pe"),
            "elapsed_cycles_synchronized": result.get("elapsed_cycles"),
            "crop_event_count": len(crop.events),
            "crop_stats": crop.stats(),
            "evidence": EvidenceKind.SIMULATOR.value,
            "note": (
                "Cropping uses the raw endpoint TSC values. The separately reported "
                "elapsed_cycles may include explicit cross-PE synchronization correction."
            ),
        },
        "sdk": {
            "sdk_version": provenance.get("sdk_version"),
            "client_version": provenance.get("client_version"),
            "appliance_version": provenance.get("cerebras_appliance_version"),
            "evidence": EvidenceKind.SIMULATOR.value,
        },
        "ledger": {
            "path": str(campaign / "ledger.jsonl"),
            "sha256": hash_file(campaign / "ledger.jsonl"),
        },
        "compile_sidecar": {
            "path": str(sidecar_path),
            "sha256": hash_file(sidecar_path),
        },
        "retained_compiler_artifact": str(preserved),
        "retained_log_export": zip_record,
        "extracted_log_export": extracted_record,
        "workdir": str(workdir),
        "trace_dir": str(workdir / "simfab_traces"),
        "trace": {
            "stream0_sha256": extracted_core_hashes["simfab_traces/stream0"],
            "metadata_sha256": extracted_core_hashes["simfab_traces/metadata"],
            "global_simdata_sha256": extracted_core_hashes[
                "simfab_traces/global_simdata.json"
            ],
            "raw_event_count": len(ctf_events),
            "discarded_event_count": reader.discarded_events_total,
            "retained_zip_core_sha256": zip_core_hashes,
            "wsjob_yaml_sha256": job_yaml_hash,
        },
        "evidence": EvidenceKind.SIMULATOR.value,
        "limitations": (
            "This qualifies an exact SDK simulator artifact and official debug-tool "
            "cross-check input. It is not a silicon wavelet trace and does not reveal "
            "private physical defect/spare remapping."
        ),
    }
    binding["binding_sha256"] = canonical_hash(binding)
    return binding


def _coordinate_records(
    x: int, y: int, coordinate_contract: Mapping[str, Any], source: str
) -> tuple[dict[str, Any], str]:
    dimensions = (
        (coordinate_contract.get("simulator_fabric_dimensions") or {}).get("value")
    )
    if not (
        isinstance(dimensions, Sequence)
        and not isinstance(dimensions, (str, bytes))
        and len(dimensions) == 2
        and 0 <= x < int(dimensions[0])
        and 0 <= y < int(dimensions[1])
    ):
        raise ValidationError(f"csdb coordinate ({x},{y}) is outside compiled fabric")
    coordinates: dict[str, Any] = {
        "simulator": {
            "x": x,
            "y": y,
            "evidence": EvidenceKind.SIMULATOR.value,
            "source": source,
        },
        "fabric": {
            "x": x,
            "y": y,
            "evidence": EvidenceKind.INFERRED.value,
            "source": "csdb coordinate placed in exact compiled simulator fabric plane",
            "basis_evidence": [
                EvidenceKind.SIMULATOR.value,
                EvidenceKind.COMPILED.value,
            ],
        },
    }
    rectangle = (coordinate_contract.get("application_rectangle") or {}).get("value")
    scope = "infrastructure_or_route_only"
    if isinstance(rectangle, Mapping) and all(
        field in rectangle for field in ("x", "y", "width", "height")
    ):
        ox, oy = int(rectangle["x"]), int(rectangle["y"])
        width, height = int(rectangle["width"]), int(rectangle["height"])
        if ox <= x < ox + width and oy <= y < oy + height:
            coordinates["application"] = {
                "x": x - ox,
                "y": y - oy,
                "evidence": EvidenceKind.INFERRED.value,
                "source": "csdb coordinate transformed by compiled application rectangle",
                "basis_evidence": [
                    EvidenceKind.SIMULATOR.value,
                    EvidenceKind.COMPILED.value,
                ],
            }
            scope = "application"
    return coordinates, scope


def parse_csdb_wavelet_logs(
    workdir: str | os.PathLike[str],
    *,
    coordinate_contract: Mapping[str, Any],
) -> dict[str, Any]:
    """Parse official ``csdb wavelet read-trace`` per-PE text logs."""

    supplied = Path(workdir).expanduser()
    if supplied.is_symlink() or not supplied.is_dir():
        raise ValidationError(f"csdb workdir is not a real directory: {supplied}")
    root = supplied.resolve()
    files: dict[tuple[int, int], Path] = {}
    for path in sorted(root.glob("wavelet-trace-x*y*.log")):
        match = _CSDB_LOG.fullmatch(path.name)
        if match is None:
            continue
        if path.is_symlink() or not path.is_file():
            raise ValidationError(f"csdb output is a link or special file: {path}")
        if path.stat().st_size > _MAX_CSDB_LOG_BYTES:
            raise ValidationError(f"csdb output exceeds safety limit: {path}")
        coordinate = (int(match.group("x")), int(match.group("y")))
        if coordinate in files:
            raise ValidationError(f"duplicate csdb PE log for {coordinate}")
        files[coordinate] = path
    if not files:
        raise ValidationError(f"no official csdb wavelet-trace logs in {root}")

    dimensions = (
        (coordinate_contract.get("simulator_fabric_dimensions") or {}).get("value")
    )
    if not (
        isinstance(dimensions, Sequence)
        and not isinstance(dimensions, (str, bytes))
        and len(dimensions) == 2
    ):
        raise ValidationError("binding has no exact simulator fabric dimensions")
    expected = {
        (x, y)
        for y in range(int(dimensions[1]))
        for x in range(int(dimensions[0]))
    }
    missing = sorted(expected - set(files))
    extra = sorted(set(files) - expected)

    records: list[dict[str, Any]] = []
    file_records: list[dict[str, Any]] = []
    for coordinate, path in sorted(files.items(), key=lambda item: (item[0][1], item[0][0])):
        x, y = coordinate
        source = f"official csdb wavelet read-trace: {path}"
        before = len(records)
        with path.open("r", encoding="utf-8", errors="strict") as handle:
            header = handle.readline()
            separator = handle.readline()
            if header.split() != [
                "Cycle",
                "Color",
                "Ctrl",
                "Link",
                "Index",
                "Data",
            ]:
                raise ValidationError(f"unexpected csdb wavelet header: {path}")
            separator_pieces = separator.split()
            if len(separator_pieces) != 6 or any(
                not piece or set(piece) != {"-"} for piece in separator_pieces
            ):
                raise ValidationError(f"unexpected csdb wavelet header separator: {path}")
            for line_number, line in enumerate(handle, 3):
                if not line.strip():
                    continue
                pieces = line.split()
                if len(pieces) != 6:
                    raise ValidationError(
                        f"invalid csdb wavelet row at {path}:{line_number}"
                    )
                try:
                    cycle = int(pieces[0], 0)
                    color = int(pieces[1], 0)
                    ctrl = int(pieces[2], 0)
                    index = int(pieces[4], 0)
                    data = int(pieces[5], 0)
                except ValueError as exc:
                    raise ValidationError(
                        f"invalid numeric csdb field at {path}:{line_number}"
                    ) from exc
                link = pieces[3]
                if link not in {"N", "S", "E", "W", "R"}:
                    raise ValidationError(
                        f"unknown raw csdb Link value {link!r} at {path}:{line_number}"
                    )
                coordinates, scope = _coordinate_records(
                    x, y, coordinate_contract, source
                )
                records.append(
                    {
                        "schema_version": SCHEMA_VERSION,
                        "record_type": "csdb_wavelet_trace_row",
                        "cycle": cycle,
                        "color": color,
                        "ctrl_raw": ctrl,
                        "link_raw": link,
                        "index": index,
                        "data": data,
                        "coordinates": coordinates,
                        "scope": scope,
                        "source_file": str(path),
                        "source_line": line_number,
                        "evidence": EvidenceKind.SIMULATOR.value,
                        "tool": "official SDK csdb wavelet read-trace",
                        "limitations": (
                            "Link is retained as the raw csdb column; this simulator "
                            "row is not a hardware wavelet observation."
                        ),
                    }
                )
        file_records.append(
            {
                "simulator": {"x": x, "y": y},
                "path": str(path),
                "sha256": hash_file(path),
                "events": len(records) - before,
                "evidence": EvidenceKind.SIMULATOR.value,
            }
        )
    return {
        "schema_version": TRACE_ARTIFACT_SCHEMA_VERSION,
        "record_type": "official-csdb-wavelet-trace",
        "status": "complete" if not missing and not extra else "incomplete",
        "records": records,
        "event_count": len(records),
        "file_count": len(files),
        "expected_file_count": len(expected),
        "missing_coordinates": [{"x": x, "y": y} for x, y in missing],
        "extra_coordinates": [{"x": x, "y": y} for x, y in extra],
        "files": file_records,
        "files_sha256": canonical_hash(
            [{"name": Path(item["path"]).name, "sha256": item["sha256"]} for item in file_records]
        ),
        "evidence": EvidenceKind.SIMULATOR.value,
        "limitations": (
            "Parsed from official csdb text emitted for a simulator CTF. This is "
            "an independent decoder cross-check, not a physical WSE trace."
        ),
    }


def compare_csdb_to_ctf(
    binding: Mapping[str, Any], csdb: Mapping[str, Any]
) -> dict[str, Any]:
    """Compare full-session raw wavelet counts per simulator coordinate."""

    if binding.get("status") != "qualified":
        raise ValidationError("simulator trace binding is not qualified")
    if csdb.get("status") != "complete":
        raise ValidationError("csdb PE log plane is incomplete")
    trace_dir = Path(str(binding.get("trace_dir") or ""))
    reader = CtfTraceReader(trace_dir / "stream0")
    ctf_counts: Counter[tuple[int, int]] = Counter()
    ctf_total = 0
    dimensions = (
        ((binding.get("coordinate_contract") or {}).get("simulator_fabric_dimensions") or {}).get("value")
    )
    if not (
        isinstance(dimensions, Sequence)
        and not isinstance(dimensions, (str, bytes))
        and len(dimensions) == 2
    ):
        raise ValidationError("binding has no simulator dimensions for CTF tile decoding")
    width, height = int(dimensions[0]), int(dimensions[1])
    for event in reader.iter_events():
        if event.get("event_type") != "wavelet_trace_entry":
            continue
        tile = event.get("tile_id")
        if not isinstance(tile, int) or not 0 <= tile < width * height:
            raise ValidationError(f"CTF wavelet has unmappable tile ID: {tile!r}")
        ctf_counts[(tile % width, tile // width)] += 1
        ctf_total += 1
    csdb_counts: Counter[tuple[int, int]] = Counter()
    for record in csdb.get("records") or []:
        simulator = (record.get("coordinates") or {}).get("simulator") or {}
        if "x" not in simulator or "y" not in simulator:
            raise ValidationError("csdb record has no simulator coordinate")
        csdb_counts[(int(simulator["x"]), int(simulator["y"]))] += 1

    coordinates = [(x, y) for y in range(height) for x in range(width)]
    per_pe = [
        {
            "simulator": {"x": x, "y": y},
            "ctf_wavelet_events": ctf_counts[(x, y)],
            "csdb_wavelet_events": csdb_counts[(x, y)],
            "match": ctf_counts[(x, y)] == csdb_counts[(x, y)],
            "evidence": EvidenceKind.SIMULATOR.value,
        }
        for x, y in coordinates
    ]
    total_match = ctf_total == int(csdb.get("event_count", -1))
    per_pe_match = all(item["match"] for item in per_pe)
    discarded = reader.discarded_events_total
    match = total_match and per_pe_match and not discarded
    return {
        "schema_version": TRACE_ARTIFACT_SCHEMA_VERSION,
        "record_type": "ctf-vs-official-csdb-wavelet-crosscheck",
        "status": "match" if match else "mismatch",
        "binding_sha256": binding.get("binding_sha256"),
        "job_id": binding.get("job_id"),
        "event_key": binding.get("event_key"),
        "comparison_scope": "raw full simulator session; no TSC crop",
        "ctf": {
            "event_type": "wavelet_trace_entry",
            "event_count": ctf_total,
            "stream0_sha256": hash_file(trace_dir / "stream0"),
            "metadata_sha256": hash_file(trace_dir / "metadata"),
            "discarded_events": discarded,
            "evidence": EvidenceKind.SIMULATOR.value,
        },
        "csdb": {
            "event_count": csdb.get("event_count"),
            "file_count": csdb.get("file_count"),
            "files_sha256": csdb.get("files_sha256"),
            "tool": "official SDK csdb wavelet read-trace",
            "evidence": EvidenceKind.SIMULATOR.value,
        },
        "total_match": total_match,
        "per_pe_match": per_pe_match,
        "ctf_tile_coordinate_mapping": {
            "method": "tile_id % xsize, tile_id // xsize",
            "source": "global_simdata.json dimensions",
            "evidence": EvidenceKind.INFERRED.value,
            "validation": (
                "exact per-PE agreement with official csdb coordinates"
                if per_pe_match
                else "not validated; per-PE counts disagree"
            ),
        },
        "per_pe": per_pe,
        "evidence": EvidenceKind.SIMULATOR.value,
        "acceptance_qualification": {
            "status": "qualified" if match else "unqualified",
            "reasons": []
            if match
            else [
                reason
                for condition, reason in (
                    (not total_match, "CTF and csdb raw wavelet totals differ"),
                    (not per_pe_match, "CTF and csdb per-PE wavelet counts differ"),
                    (bool(discarded), "CTF reports discarded simulator events"),
                )
                if condition
            ],
        },
        "limitations": (
            "Agreement validates our CTF wavelet event count and tile-coordinate "
            "decoding against the official simulator debug tool. It neither validates "
            "hardware traffic nor converts raw csdb Link values into route semantics."
        ),
    }


def ingest_simulator_trace_artifact(
    campaign_dir: str | os.PathLike[str],
    *,
    job_id: str,
    event_key: str | None = None,
    artifact_root: str | os.PathLike[str] | None = None,
    output_dir: str | os.PathLike[str] | None = None,
) -> dict[str, Any]:
    """Bind, parse, cross-check, and persist one offline simulator artifact."""

    campaign = Path(campaign_dir).expanduser().resolve()
    binding = bind_simulator_trace_artifact(
        campaign,
        job_id=job_id,
        event_key=event_key,
        artifact_root=artifact_root,
    )
    csdb = parse_csdb_wavelet_logs(
        str(binding["workdir"]),
        coordinate_contract=binding["coordinate_contract"],
    )
    crosscheck = compare_csdb_to_ctf(binding, csdb)
    target = (
        Path(output_dir).expanduser().resolve()
        if output_dir is not None
        else campaign
        / "artifacts"
        / "trace-ingest"
        / safe_name(job_id)
        / str(binding["event_key"])[:16]
    )
    binding_path = atomic_write_json(target / "binding.json", binding)
    records_path = write_events_jsonl_gz(
        target / "csdb_wavelets.jsonl.gz", csdb["records"]
    )
    csdb_summary = {key: value for key, value in csdb.items() if key != "records"}
    csdb_summary["records_path"] = str(records_path)
    csdb_summary["records_sha256"] = hash_file(records_path)
    csdb_path = atomic_write_json(target / "csdb_summary.json", csdb_summary)
    crosscheck_path = atomic_write_json(target / "csdb_crosscheck.json", crosscheck)
    manifest = {
        "schema_version": TRACE_ARTIFACT_SCHEMA_VERSION,
        "record_type": "wse3study-bound-simulator-trace-manifest",
        "binding": str(binding_path),
        "binding_sha256": hash_file(binding_path),
        "csdb_summary": str(csdb_path),
        "csdb_summary_sha256": hash_file(csdb_path),
        "csdb_crosscheck": str(crosscheck_path),
        "csdb_crosscheck_sha256": hash_file(crosscheck_path),
        "source_sha256": binding["source_sha256"],
        "compile_request_sha256": binding["compile_request_sha256"],
        "compile_identity_sha256": binding["compile_identity_sha256"],
        "compiler_artifact_sha256": binding["compiler_artifact_sha256"],
        "stream0_sha256": binding["trace"]["stream0_sha256"],
        "metadata_sha256": binding["trace"]["metadata_sha256"],
        "device_tsc_window": binding["device_tsc_window"],
        "status": "qualified" if crosscheck["status"] == "match" else "unqualified",
        "evidence": EvidenceKind.SIMULATOR.value,
        "limitations": binding["limitations"],
    }
    manifest_path = atomic_write_json(target / "trace_manifest.json", manifest)
    return {
        "status": manifest["status"],
        "job_id": job_id,
        "event_key": binding["event_key"],
        "ctf_wavelet_events": crosscheck["ctf"]["event_count"],
        "csdb_wavelet_events": crosscheck["csdb"]["event_count"],
        "per_pe_match": crosscheck["per_pe_match"],
        "output_dir": str(target),
        "binding": str(binding_path),
        "csdb_records": str(records_path),
        "crosscheck": str(crosscheck_path),
        "manifest": str(manifest_path),
        "evidence": EvidenceKind.SIMULATOR.value,
        "limitations": manifest["limitations"],
    }


__all__ = [
    "TRACE_ARTIFACT_SCHEMA_VERSION",
    "bind_simulator_trace_artifact",
    "compare_csdb_to_ctf",
    "discover_simulator_trace_exports",
    "ingest_simulator_trace_artifact",
    "inspect_extracted_log_export",
    "inspect_log_export_zip",
    "parse_csdb_wavelet_logs",
]
