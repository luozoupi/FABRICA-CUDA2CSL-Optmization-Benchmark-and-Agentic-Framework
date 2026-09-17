"""Shared contracts for WSE-3 characterization artifacts.

The study deliberately carries provenance on every scientific value.  A route
read from an ELF is not a silicon observation, and a fitted per-hop delay is not
a hardware trace; the :class:`EvidenceKind` field makes those distinctions
machine-checkable.
"""

from __future__ import annotations

import hashlib
import json
import os
import re
import tempfile
from datetime import datetime, timezone
from enum import Enum
from pathlib import Path
from typing import Any, Iterable, Mapping

SCHEMA_VERSION = "1.0.0"
FABRIC_DIMS_WSE3 = (762, 1172)
DEFAULT_FABRIC_OFFSETS = (4, 1)


class EvidenceKind(str, Enum):
    DOCUMENTED = "documented"
    COMPILED = "compiled"
    SIMULATOR = "simulator"
    SILICON = "silicon"
    INFERRED = "inferred"


PHASES = (
    "sync_reference",
    "compute_start",
    "first_send",
    "first_receive",
    "last_receive",
    "compute_end",
    "exit",
)

MEASUREMENT_FIELDS = (
    "schema_version",
    "campaign_id",
    "kernel",
    "variant",
    "run_id",
    "arm",
    "evidence",
    "telemetry_level",
    "trial",
    "warmup",
    "logical_x",
    "logical_y",
    "fabric_x",
    "fabric_y",
    "pe_role",
    "phase",
    "timestamp_cycles",
    "elapsed_cycles",
    "timer_validated",
    "traffic_sent",
    "traffic_received",
    "perf_counter_0_raw",
    "perf_counter_1_raw",
    "correctness",
    "timing_method",
    "source_hash",
    "artifact_id",
    "job_id",
    "notes",
)

LAYOUT_COUNT_FIELDS = (
    "application_allocated",
    "application_loaded",
    "io_loaded",
    "routing_only",
    "loaded_unique",
    "configured_unique",
    "dynamically_active",
)

WAVELET_NODE_FIELDS = (
    "node_id",
    "cycle",
    "tile_id",
    "coordinates",
    "scope",
    "color",
    "incoming_direction",
    "branch",
    "hop_delay_cycles",
    "backpressure",
    "evidence",
)


class StudyError(RuntimeError):
    """Base error for a scientifically invalid or incomplete campaign step."""


class ValidationError(StudyError):
    """Raised when an artifact would violate the study evidence contract."""


def utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat()


def safe_name(value: str) -> str:
    name = re.sub(r"[^A-Za-z0-9_.-]+", "-", value.strip()).strip("-.")
    return name or "unnamed"


def evidence_value(value: EvidenceKind | str) -> str:
    try:
        return EvidenceKind(value).value
    except ValueError as exc:
        allowed = ", ".join(item.value for item in EvidenceKind)
        raise ValidationError(f"invalid evidence {value!r}; expected one of {allowed}") from exc


def evidence_record(
    value: Any,
    evidence: EvidenceKind | str,
    *,
    source: str,
    uncertainty: str | None = None,
) -> dict[str, Any]:
    record: dict[str, Any] = {
        "value": value,
        "evidence": evidence_value(evidence),
        "source": source,
    }
    if uncertainty:
        record["uncertainty"] = uncertainty
    return record


def canonical_json(value: Any) -> bytes:
    return json.dumps(
        value, sort_keys=True, separators=(",", ":"), ensure_ascii=False
    ).encode("utf-8")


def canonical_hash(value: Any) -> str:
    return hashlib.sha256(canonical_json(value)).hexdigest()


def hash_file(path: str | os.PathLike[str]) -> str:
    digest = hashlib.sha256()
    with Path(path).open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def hash_tree(
    root: str | os.PathLike[str],
    *,
    exclude_names: Iterable[str] = (
        ".git",
        "__pycache__",
        ".pytest_cache",
        "simfab_traces",
        "out",
    ),
) -> str:
    """Hash source inputs deterministically without hashing generated artifacts."""

    base = Path(root).resolve()
    excluded = set(exclude_names)
    digest = hashlib.sha256()
    for path in sorted(base.rglob("*")):
        relative = path.relative_to(base)
        if any(part in excluded for part in relative.parts):
            continue
        if not path.is_file():
            continue
        digest.update(relative.as_posix().encode("utf-8"))
        digest.update(b"\0")
        with path.open("rb") as handle:
            for block in iter(lambda: handle.read(1024 * 1024), b""):
                digest.update(block)
        digest.update(b"\0")
    return digest.hexdigest()


def atomic_write_json(path: str | os.PathLike[str], value: Any) -> Path:
    target = Path(path)
    target.parent.mkdir(parents=True, exist_ok=True)
    fd, temporary = tempfile.mkstemp(prefix=f".{target.name}.", dir=target.parent)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as handle:
            json.dump(value, handle, indent=2, sort_keys=True)
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


def load_json(path: str | os.PathLike[str], default: Any = None) -> Any:
    try:
        with Path(path).open("r", encoding="utf-8") as handle:
            return json.load(handle)
    except FileNotFoundError:
        return default


def require_evidence(records: Iterable[Mapping[str, Any]]) -> None:
    for index, record in enumerate(records):
        if "evidence" not in record:
            raise ValidationError(f"record {index} has no evidence field")
        evidence_value(str(record["evidence"]))


def validate_layout_contract(layout: Mapping[str, Any]) -> list[str]:
    """Validate the stable, evidence-bearing portion of ``layout.json``."""

    errors: list[str] = []
    if layout.get("kind") != "wse3-layout-inventory":
        errors.append("kind is not wse3-layout-inventory")
    if not isinstance(layout.get("kernel"), Mapping) or not layout["kernel"].get("name"):
        errors.append("kernel.name is missing")
    fabric = layout.get("fabric")
    if not isinstance(fabric, Mapping):
        errors.append("fabric record is missing")
    else:
        for key in ("system_dimensions", "dimensions", "offsets"):
            record = fabric.get(key)
            if not isinstance(record, Mapping) or "value" not in record or "evidence" not in record:
                errors.append(f"fabric.{key} is not an evidence record")
            else:
                try:
                    evidence_value(str(record["evidence"]))
                except ValidationError as exc:
                    errors.append(f"fabric.{key}: {exc}")
    counts = layout.get("counts")
    if not isinstance(counts, Mapping):
        errors.append("counts record is missing")
    else:
        for key in LAYOUT_COUNT_FIELDS:
            record = counts.get(key)
            if not isinstance(record, Mapping) or "value" not in record or "evidence" not in record:
                errors.append(f"counts.{key} is not an evidence record")
                continue
            try:
                evidence_value(str(record["evidence"]))
            except ValidationError as exc:
                errors.append(f"counts.{key}: {exc}")
    for index, pe in enumerate(layout.get("pes") or []):
        fabric_coordinate = pe.get("fabric") if isinstance(pe, Mapping) else None
        if not isinstance(fabric_coordinate, Mapping) or not {"x", "y"} <= set(fabric_coordinate):
            errors.append(f"pes[{index}] has no fabric x/y coordinate")
        if not isinstance(pe, Mapping) or not pe.get("role"):
            errors.append(f"pes[{index}] has no role")
        try:
            evidence_value(str(pe.get("evidence")))
        except (AttributeError, ValidationError) as exc:
            errors.append(f"pes[{index}] has invalid evidence: {exc}")
    for index, edge in enumerate(layout.get("route_edges") or []):
        if not isinstance(edge, Mapping):
            errors.append(f"route_edges[{index}] is not an object")
            continue
        source, destination = edge.get("from"), edge.get("to")
        if not isinstance(source, Mapping) or not isinstance(destination, Mapping):
            errors.append(f"route_edges[{index}] has no endpoints")
            continue
        try:
            dx = abs(int(destination["x"]) - int(source["x"]))
            dy = abs(int(destination["y"]) - int(source["y"]))
        except (KeyError, TypeError, ValueError):
            errors.append(f"route_edges[{index}] endpoint coordinates are invalid")
            continue
        direction = str(edge.get("direction") or "").lower()
        if direction == "ramp":
            if dx or dy:
                errors.append(f"route_edges[{index}] RAMP edge is not local")
        elif dx + dy != 1:
            errors.append(f"route_edges[{index}] is not cardinally adjacent")
        try:
            evidence_value(str(edge.get("evidence")))
        except ValidationError as exc:
            errors.append(f"route_edges[{index}] has invalid evidence: {exc}")
    qualification = layout.get("acceptance_qualification")
    if not isinstance(qualification, Mapping) or qualification.get("status") not in {
        "qualified",
        "unqualified",
    }:
        errors.append("acceptance_qualification is missing or invalid")
    return errors


def validate_wavelet_contract(group: Mapping[str, Any]) -> list[str]:
    """Validate one ``wavelets.jsonl.gz`` observed-DAG record."""

    errors: list[str] = []
    if group.get("record_type") != "observed_wavelet_dag":
        errors.append("record_type is not observed_wavelet_dag")
    if group.get("ident") is None:
        errors.append("ident is missing")
    nodes = group.get("nodes")
    if not isinstance(nodes, list):
        return errors + ["nodes is not a list"]
    node_ids: set[str] = set()
    for index, node in enumerate(nodes):
        if not isinstance(node, Mapping):
            errors.append(f"nodes[{index}] is not an object")
            continue
        for field in WAVELET_NODE_FIELDS:
            if field not in node:
                errors.append(f"nodes[{index}].{field} is missing")
        node_id = str(node.get("node_id"))
        if node_id in node_ids:
            errors.append(f"duplicate node_id {node_id}")
        node_ids.add(node_id)
        try:
            evidence_value(str(node.get("evidence")))
        except ValidationError as exc:
            errors.append(f"nodes[{index}] has invalid evidence: {exc}")
    for index, edge in enumerate(group.get("edges") or []):
        if edge.get("source") not in node_ids or edge.get("destination") not in node_ids:
            errors.append(f"edges[{index}] references an unknown node")
        if edge.get("direction") not in {"LOCAL", "NORTH", "SOUTH", "EAST", "WEST"}:
            errors.append(f"edges[{index}] has invalid direction")
        try:
            evidence_value(str(edge.get("evidence")))
        except ValidationError as exc:
            errors.append(f"edges[{index}] has invalid evidence: {exc}")
    return errors
