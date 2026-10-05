"""Project the append-only execution ledger into analysis-friendly artifacts."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any, Iterable, Mapping

from .schema import SCHEMA_VERSION
from .telemetry import write_measurements


_DIRECTION_FIELDS = {
    "east": "east_hops",
    "west": "west_hops",
    "north": "north_hops",
    "south": "south_hops",
}


def _latest_event_records(
    records: Iterable[Mapping[str, Any]],
) -> list[Mapping[str, Any]]:
    """Return the last append-only ledger attempt for each scientific event."""

    latest: dict[str, Mapping[str, Any]] = {}
    anonymous: list[Mapping[str, Any]] = []
    for record in records:
        event_key = record.get("event_key")
        if event_key in (None, ""):
            anonymous.append(record)
        else:
            latest[str(event_key)] = record
    return [*anonymous, *latest.values()]


def _accepted_measurement_records(records: Iterable[Mapping[str, Any]]) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    for record in _latest_event_records(records):
        if not record.get("accepted"):
            continue
        result = dict(record.get("result") or {})
        provenance = dict(record.get("provenance") or {})
        request = dict(record.get("request") or {})
        configuration = dict(request.get("configuration") or {})
        base = {
            "schema_version": SCHEMA_VERSION,
            "campaign_id": record.get("campaign_id"),
            "kernel": record.get("subject"),
            "variant": record.get("variant"),
            "run_id": record.get("event_key"),
            "arm": record.get("arm"),
            "evidence": record.get("evidence"),
            "telemetry_level": record.get("telemetry_level"),
            "trial": record.get("trial"),
            "warmup": record.get("warmup"),
            "phase": "compute_end",
            "elapsed_cycles": result.get("elapsed_cycles"),
            "timer_validated": result.get("timer_validated", False),
            "correctness": result.get("correctness"),
            "timing_method": result.get("timing_method"),
            "source_hash": record.get("source_hash"),
            "artifact_id": provenance.get("artifact_id", result.get("artifact_id")),
            "job_id": provenance.get("job_id", result.get("job_id")),
            "notes": result.get("reason", ""),
        }
        for name in (
            "logical_x",
            "logical_y",
            "fabric_x",
            "fabric_y",
            "pe_role",
            "timestamp_cycles",
            "traffic_sent",
            "traffic_received",
            "perf_counter_0_raw",
            "perf_counter_1_raw",
        ):
            if name in result:
                base[name] = result[name]
        if configuration.get("calibration_case"):
            base["notes"] = f"calibration_case={configuration['calibration_case']}"
        telemetry_rows = result.get("telemetry_rows") or result.get("per_pe_telemetry")
        if isinstance(telemetry_rows, list) and telemetry_rows:
            for raw_telemetry in telemetry_rows:
                if not isinstance(raw_telemetry, Mapping):
                    continue
                row = dict(base)
                for field in (
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
                    "notes",
                ):
                    if field in raw_telemetry:
                        row[field] = raw_telemetry[field]
                rows.append(row)
        else:
            rows.append(base)
    return sorted(rows, key=lambda row: (str(row["kernel"]), str(row["arm"]), bool(row["warmup"]), int(row["trial"] or 0)))


def project_measurements(records: Iterable[Mapping[str, Any]], path: str | Path) -> int:
    return write_measurements(path, _accepted_measurement_records(records))


def _calibration_base(record: Mapping[str, Any]) -> dict[str, Any] | None:
    if not record.get("accepted") or record.get("warmup"):
        return None
    request = dict(record.get("request") or {})
    if request.get("kind") != "calibration":
        return None
    configuration = dict(request.get("configuration") or {})
    result = dict(record.get("result") or {})
    base = {
        **configuration,
        "case_index": record.get("trial", 0),
        "arm": record.get("arm"),
        "evidence": record.get("evidence"),
        "correctness": result.get("correctness", True),
        "elapsed_cycles": result.get("elapsed_cycles"),
        "status": result.get("status", record.get("status")),
        "compile_success": result.get("compile_success"),
        "capacity_failure": result.get("capacity_failure"),
        "compile_probe_valid": result.get("compile_probe_valid"),
        "compile_error": result.get("compile_error"),
        "validation": configuration.get("split") == "validation",
        "request_key": record.get("request_key"),
        "event_key": record.get("event_key"),
    }
    return base


def latency_samples(records: Iterable[Mapping[str, Any]]) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    for record in _latest_event_records(records):
        base = _calibration_base(record)
        if not base:
            continue
        if base.get("arm") != "hardware":
            continue
        family = str(base.get("calibration_family", ""))
        if family not in {"straight", "turn", "contention", "multicast"}:
            continue
        for field in _DIRECTION_FIELDS.values():
            base[field] = 0
        if family == "straight":
            direction = str(base.get("direction", "")).lower()
            if direction in _DIRECTION_FIELDS:
                base[_DIRECTION_FIELDS[direction]] = int(base.get("hops", 0))
            base.setdefault("turns", 0)
            base.setdefault("contention_sources", 1)
        elif family == "turn":
            first, second = str(base.get("first_direction", "")).lower(), str(base.get("second_direction", "")).lower()
            if first in _DIRECTION_FIELDS:
                base[_DIRECTION_FIELDS[first]] += int(base.get("first_hops", 0))
            if second in _DIRECTION_FIELDS:
                base[_DIRECTION_FIELDS[second]] += int(base.get("second_hops", 0))
            base.setdefault("turns", 1)
            base.setdefault("contention_sources", 1)
        elif family == "contention":
            # Contention controls use an eastward canonical path unless their
            # generated bundle records another direction.
            direction = str(base.get("direction", "east")).lower()
            if direction in _DIRECTION_FIELDS:
                base[_DIRECTION_FIELDS[direction]] = int(base.get("path_hops", 0))
            base["contention_sources"] = int(base.get("sources", 1))
            base.setdefault("turns", 0)
        else:  # multicast
            direction = str(base.get("trunk_direction", "")).lower()
            if direction in _DIRECTION_FIELDS:
                base[_DIRECTION_FIELDS[direction]] = int(base.get("trunk_hops", 0))
            base.setdefault("turns", 0)
            base.setdefault("contention_sources", 1)
        base.setdefault("receiver_delay_cycles", 0)
        rows.append(base)
    return sorted(rows, key=lambda row: (str(row.get("calibration_case")), int(row.get("case_index", 0))))


def single_pe_samples(records: Iterable[Mapping[str, Any]]) -> list[dict[str, Any]]:
    rows = []
    for record in _latest_event_records(records):
        base = _calibration_base(record)
        if not base:
            continue
        if not base.get("compile_only") and base.get("arm") != "hardware":
            continue
        if not str(base.get("calibration_family", "")).startswith("single-pe"):
            continue
        base["family"] = base.get("calibration_family")
        rows.append(base)
    return sorted(rows, key=lambda row: (str(row.get("calibration_case")), int(row.get("case_index", 0))))


def write_jsonl(path: str | Path, rows: Iterable[Mapping[str, Any]]) -> int:
    target = Path(path)
    target.parent.mkdir(parents=True, exist_ok=True)
    temporary = target.with_name(f".{target.name}.tmp")
    count = 0
    with temporary.open("w", encoding="utf-8") as handle:
        for row in rows:
            handle.write(json.dumps(dict(row), sort_keys=True, separators=(",", ":")))
            handle.write("\n")
            count += 1
    temporary.replace(target)
    return count
