"""Generate a provenance-aware Markdown report from campaign artifacts."""

from __future__ import annotations

import csv
import json
from collections import Counter, defaultdict
from pathlib import Path
from typing import Any, Iterable, Mapping

from .model import fit_latency_model
from .schema import (
    SCHEMA_VERSION,
    atomic_write_json,
    canonical_hash,
    hash_file,
    load_json,
    safe_name,
    utc_now,
)
from .telemetry import load_measurements, summarize_cycles, validate_timed_trial


def _kernel_items(campaign: Mapping[str, Any]) -> list[dict[str, Any]]:
    kernels = campaign.get("kernels", [])
    if isinstance(kernels, dict):
        items = []
        for name, payload in kernels.items():
            item = dict(payload) if isinstance(payload, dict) else {}
            item.setdefault("name", name)
            items.append(item)
        return sorted(items, key=lambda item: str(item.get("name", "")))
    return sorted(
        [dict(item) for item in kernels if isinstance(item, dict)],
        key=lambda item: str(item.get("name") or item.get("kernel") or ""),
    )


def _read_jsonl(path: Path) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    if not path.is_file():
        return rows
    with path.open("r", encoding="utf-8") as handle:
        for line in handle:
            line = line.strip()
            if line:
                rows.append(json.loads(line))
    return rows


def _load_latency_samples(campaign_dir: Path) -> list[dict[str, Any]]:
    jsonl = campaign_dir / "calibration" / "latency_samples.jsonl"
    if jsonl.is_file():
        return _read_jsonl(jsonl)
    csv_path = campaign_dir / "calibration" / "latency_samples.csv"
    if csv_path.is_file():
        with csv_path.open("r", newline="", encoding="utf-8") as handle:
            return list(csv.DictReader(handle))
    return []


def _nonnegative_int(value: Any, field: str, reasons: list[str]) -> int | None:
    if isinstance(value, bool) or not isinstance(value, int) or value < 0:
        reasons.append(f"{field} is not a nonnegative integer")
        return None
    return value


def _qualified_simulator_trace_controls(campaign_dir: Path) -> dict[str, Any]:
    """Discover independently cross-checked simulator controls, fail closed.

    A trace-ingest directory is reportable only when its binding, manifest, and
    official ``csdb`` cross-check agree in both content hashes and scientific
    identity.  Malformed or partially qualified candidates are retained in the
    exclusion list and never contribute values to the qualified table.
    """

    ingest_root = campaign_dir / "artifacts" / "trace-ingest"
    controls: list[dict[str, Any]] = []
    excluded: list[dict[str, Any]] = []
    if not ingest_root.is_dir():
        return {
            "qualified_count": 0,
            "excluded_count": 0,
            "controls": controls,
            "excluded": excluded,
            "evidence": "simulator",
            "limitations": (
                "Trace-ingest controls are simulator-only. Raw csdb Link values "
                "are not decoded as direction or route semantics."
            ),
        }

    artifact_dirs = {
        path.parent
        for name in ("trace_manifest.json", "binding.json", "csdb_crosscheck.json")
        for path in ingest_root.rglob(name)
    }
    for artifact_dir in sorted(artifact_dirs):
        manifest_path = artifact_dir / "trace_manifest.json"
        reasons: list[str] = []
        relative_manifest = str(manifest_path.relative_to(campaign_dir))
        binding_path = artifact_dir / "binding.json"
        crosscheck_path = artifact_dir / "csdb_crosscheck.json"

        for label, path in (
            ("trace manifest", manifest_path),
            ("binding", binding_path),
            ("csdb cross-check", crosscheck_path),
        ):
            try:
                if path.is_symlink() or not path.is_file():
                    reasons.append(f"{label} is missing or is a symbolic link")
            except OSError as exc:
                reasons.append(f"{label} cannot be inspected: {exc}")

        payloads: dict[str, Mapping[str, Any]] = {}
        if not reasons:
            for label, path in (
                ("manifest", manifest_path),
                ("binding", binding_path),
                ("crosscheck", crosscheck_path),
            ):
                try:
                    payload = load_json(path)
                except (OSError, ValueError, TypeError) as exc:
                    reasons.append(f"{label} is not valid JSON: {exc}")
                    continue
                if not isinstance(payload, Mapping):
                    reasons.append(f"{label} is not a JSON object")
                else:
                    payloads[label] = payload

        manifest = payloads.get("manifest", {})
        binding = payloads.get("binding", {})
        crosscheck = payloads.get("crosscheck", {})
        if len(payloads) == 3:
            try:
                binding_file_hash = hash_file(binding_path)
                crosscheck_file_hash = hash_file(crosscheck_path)
            except OSError as exc:
                reasons.append(f"trace-ingest content cannot be hashed: {exc}")
                binding_file_hash = None
                crosscheck_file_hash = None
            if manifest.get("record_type") != "wse3study-bound-simulator-trace-manifest":
                reasons.append("manifest record type is not a bound simulator trace")
            if manifest.get("status") != "qualified":
                reasons.append("manifest status is not qualified")
            if manifest.get("evidence") != "simulator":
                reasons.append("manifest evidence is not simulator")
            if not binding_file_hash or manifest.get("binding_sha256") != binding_file_hash:
                reasons.append("manifest binding hash does not match binding.json")
            if (
                not crosscheck_file_hash
                or manifest.get("csdb_crosscheck_sha256") != crosscheck_file_hash
            ):
                reasons.append(
                    "manifest csdb cross-check hash does not match csdb_crosscheck.json"
                )

            if binding.get("record_type") != "bound-simulator-trace-artifact":
                reasons.append("binding record type is not a simulator trace artifact")
            if binding.get("status") != "qualified":
                reasons.append("binding status is not qualified")
            if binding.get("evidence") != "simulator":
                reasons.append("binding evidence is not simulator")
            binding_without_hash = dict(binding)
            binding_digest = binding_without_hash.pop("binding_sha256", None)
            if not binding_digest or binding_digest != canonical_hash(binding_without_hash):
                reasons.append("binding self-hash is missing or invalid")

            if crosscheck.get("record_type") != "ctf-vs-official-csdb-wavelet-crosscheck":
                reasons.append("cross-check record type is invalid")
            if crosscheck.get("status") != "match":
                reasons.append("csdb/CTF cross-check status is not match")
            if crosscheck.get("evidence") != "simulator":
                reasons.append("cross-check evidence is not simulator")
            qualification = crosscheck.get("acceptance_qualification") or {}
            if (
                not isinstance(qualification, Mapping)
                or qualification.get("status") != "qualified"
            ):
                reasons.append("csdb/CTF cross-check is not acceptance-qualified")
            if crosscheck.get("total_match") is not True:
                reasons.append("csdb/CTF full-session totals do not exactly match")
            if crosscheck.get("per_pe_match") is not True:
                reasons.append("csdb/CTF per-PE counts do not exactly match")
            if crosscheck.get("comparison_scope") != "raw full simulator session; no TSC crop":
                reasons.append("cross-check comparison scope is missing or ambiguous")

            job_id = binding.get("job_id")
            event_key = binding.get("event_key")
            if not isinstance(job_id, str) or not job_id:
                reasons.append("binding job ID is missing")
            if not isinstance(event_key, str) or not event_key:
                reasons.append("binding event key is missing")
            if (
                crosscheck.get("job_id") != job_id
                or crosscheck.get("event_key") != event_key
            ):
                reasons.append("binding and cross-check job/event identities differ")
            if crosscheck.get("binding_sha256") != binding_digest:
                reasons.append("cross-check does not reference the binding self-hash")

            trace = binding.get("trace") or {}
            window = binding.get("device_tsc_window") or {}
            crop_stats = window.get("crop_stats") if isinstance(window, Mapping) else {}
            ctf = crosscheck.get("ctf") or {}
            csdb = crosscheck.get("csdb") or {}
            if not all(
                isinstance(item, Mapping)
                for item in (trace, window, crop_stats, ctf, csdb)
            ):
                reasons.append("trace, TSC window, or cross-check summary is malformed")
                trace, window, crop_stats, ctf, csdb = {}, {}, {}, {}, {}

            raw_events = _nonnegative_int(
                trace.get("raw_event_count"), "binding raw CTF event count", reasons
            )
            discarded = _nonnegative_int(
                trace.get("discarded_event_count"),
                "binding discarded CTF event count",
                reasons,
            )
            window_events = _nonnegative_int(
                window.get("crop_event_count"), "TSC-window event count", reasons
            )
            crop_seen = _nonnegative_int(
                crop_stats.get("seen"), "crop seen count", reasons
            )
            crop_kept = _nonnegative_int(
                crop_stats.get("kept"), "crop kept count", reasons
            )
            exclusions = [
                _nonnegative_int(
                    crop_stats.get(name), f"crop {name.replace('_', ' ')} count", reasons
                )
                for name in ("excluded_before", "excluded_after", "excluded_timeless")
            ]
            if discarded is not None and discarded != 0:
                reasons.append("binding reports discarded CTF events")
            if (
                raw_events is not None
                and crop_seen is not None
                and raw_events != crop_seen
            ):
                reasons.append("raw CTF event count differs from crop seen count")
            if (
                window_events is not None
                and crop_kept is not None
                and window_events != crop_kept
            ):
                reasons.append("TSC-window event count differs from crop kept count")
            if (
                crop_seen is not None
                and crop_kept is not None
                and all(value is not None for value in exclusions)
                and crop_seen
                != crop_kept
                + sum(value for value in exclusions if value is not None)
            ):
                reasons.append("TSC crop accounting does not sum to raw CTF events")
            if manifest.get("device_tsc_window") != window:
                reasons.append("manifest and binding TSC windows differ")

            ctf_wavelets = _nonnegative_int(
                ctf.get("event_count"), "CTF wavelet event count", reasons
            )
            csdb_wavelets = _nonnegative_int(
                csdb.get("event_count"), "csdb wavelet event count", reasons
            )
            csdb_files = _nonnegative_int(
                csdb.get("file_count"), "csdb PE file count", reasons
            )
            ctf_discarded = _nonnegative_int(
                ctf.get("discarded_events"), "cross-check discarded event count", reasons
            )
            if ctf_discarded is not None and ctf_discarded != 0:
                reasons.append("cross-check reports discarded CTF events")
            if (
                ctf_wavelets is not None
                and csdb_wavelets is not None
                and ctf_wavelets != csdb_wavelets
            ):
                reasons.append("CTF and csdb wavelet totals differ")
            if ctf.get("stream0_sha256") != trace.get("stream0_sha256"):
                reasons.append("cross-check stream hash differs from binding")
            if ctf.get("metadata_sha256") != trace.get("metadata_sha256"):
                reasons.append("cross-check metadata hash differs from binding")
            for manifest_field, binding_value in (
                ("source_sha256", binding.get("source_sha256")),
                ("compile_request_sha256", binding.get("compile_request_sha256")),
                ("compile_identity_sha256", binding.get("compile_identity_sha256")),
                ("compiler_artifact_sha256", binding.get("compiler_artifact_sha256")),
                ("stream0_sha256", trace.get("stream0_sha256")),
                ("metadata_sha256", trace.get("metadata_sha256")),
            ):
                if not binding_value or manifest.get(manifest_field) != binding_value:
                    reasons.append(f"manifest {manifest_field} differs from binding")

            per_pe = crosscheck.get("per_pe") or []
            if not isinstance(per_pe, list) or not per_pe:
                reasons.append("cross-check has no per-PE summary")
                per_pe = []
            coordinates: set[tuple[int, int]] = set()
            per_pe_ctf_total = 0
            per_pe_csdb_total = 0
            for index, record in enumerate(per_pe):
                if not isinstance(record, Mapping):
                    reasons.append(f"per-PE row {index} is malformed")
                    continue
                coordinate = record.get("simulator") or {}
                x = coordinate.get("x") if isinstance(coordinate, Mapping) else None
                y = coordinate.get("y") if isinstance(coordinate, Mapping) else None
                if (
                    isinstance(x, bool)
                    or not isinstance(x, int)
                    or isinstance(y, bool)
                    or not isinstance(y, int)
                ):
                    reasons.append(f"per-PE row {index} has no integer simulator coordinate")
                    continue
                if (x, y) in coordinates:
                    reasons.append(
                        f"per-PE row {index} repeats simulator coordinate ({x},{y})"
                    )
                coordinates.add((x, y))
                row_ctf = _nonnegative_int(
                    record.get("ctf_wavelet_events"),
                    f"per-PE row {index} CTF event count",
                    reasons,
                )
                row_csdb = _nonnegative_int(
                    record.get("csdb_wavelet_events"),
                    f"per-PE row {index} csdb event count",
                    reasons,
                )
                if record.get("match") is not True or row_ctf != row_csdb:
                    reasons.append(f"per-PE row {index} is not an exact match")
                if row_ctf is not None:
                    per_pe_ctf_total += row_ctf
                if row_csdb is not None:
                    per_pe_csdb_total += row_csdb
            pe_count = len(coordinates)
            if csdb_files is not None and csdb_files != pe_count:
                reasons.append("csdb file count differs from unique per-PE coordinate count")
            if ctf_wavelets is not None and per_pe_ctf_total != ctf_wavelets:
                reasons.append("per-PE CTF counts do not sum to the CTF total")
            if csdb_wavelets is not None and per_pe_csdb_total != csdb_wavelets:
                reasons.append("per-PE csdb counts do not sum to the csdb total")

            binding_limitations = binding.get("limitations")
            crosscheck_limitations = crosscheck.get("limitations")
            if (
                not isinstance(binding_limitations, str)
                or "silicon" not in binding_limitations.lower()
            ):
                reasons.append("binding does not state its silicon-trace limitation")
            if (
                not isinstance(crosscheck_limitations, str)
                or "link" not in crosscheck_limitations.lower()
            ):
                reasons.append("cross-check does not state that csdb Link is uninterpreted")

            if not reasons:
                controls.append(
                    {
                        "subject": str(binding.get("subject") or "unspecified"),
                        "job_id": job_id,
                        "event_key": event_key,
                        "raw_ctf_events": raw_events,
                        "tsc_window_events": window_events,
                        "ctf_wavelet_events": ctf_wavelets,
                        "csdb_wavelet_events": csdb_wavelets,
                        "pe_count": pe_count,
                        "total_match": True,
                        "per_pe_match": True,
                        "comparison_scope": crosscheck.get("comparison_scope"),
                        "evidence": "simulator",
                        "limitations": [binding_limitations, crosscheck_limitations],
                        "manifest": relative_manifest,
                    }
                )

        if reasons:
            excluded.append(
                {
                    "manifest": relative_manifest,
                    "reasons": sorted(set(reasons)),
                }
            )

    controls.sort(key=lambda item: (str(item["job_id"]), str(item["event_key"])))
    excluded.sort(key=lambda item: str(item["manifest"]))
    return {
        "qualified_count": len(controls),
        "excluded_count": len(excluded),
        "controls": controls,
        "excluded": excluded,
        "evidence": "simulator",
        "limitations": (
            "Trace-ingest controls are simulator-only. Raw csdb Link values are "
            "not decoded as direction or route semantics."
        ),
    }


def _execution_readiness(campaign_dir: Path) -> dict[str, Any]:
    """Summarize planned execution separately from accepted measurements.

    A staged adapter or generated calibration bundle is readiness evidence, not
    simulator or silicon evidence. Keeping this state out of the acceptance
    counters prevents a dry run from looking like an executed campaign while
    still making blocking implementation work visible in the final report.
    """

    suite = load_json(campaign_dir / "suite_requests.json", {})
    suite = suite if isinstance(suite, Mapping) else {}
    stages = suite.get("stages") or {}
    stages = stages if isinstance(stages, Mapping) else {}
    endpoint_modes: Counter[str] = Counter()
    endpoint_errors: dict[str, str] = {}
    endpoint_staged = 0
    for name, raw_stage in stages.items():
        stage = raw_stage if isinstance(raw_stage, Mapping) else {}
        adapter = stage.get("adapter") or {}
        adapter = adapter if isinstance(adapter, Mapping) else {}
        if stage.get("status") == "error":
            endpoint_errors[str(name)] = str(
                stage.get("reason") or "unspecified staging error"
            )
        elif stage.get("staged_bundle") and adapter.get("status") == "instrumented":
            endpoint_staged += 1
            endpoint_modes[str(adapter.get("mode") or "unspecified")] += 1

    full = suite.get("full_telemetry") or {}
    full = full if isinstance(full, Mapping) else {}
    full_per_kernel = full.get("per_kernel") or {}
    full_per_kernel = (
        full_per_kernel if isinstance(full_per_kernel, Mapping) else {}
    )
    full_statuses = Counter(
        str(record.get("status") or "unspecified")
        for record in full_per_kernel.values()
        if isinstance(record, Mapping)
    )
    full_compile_ready = sum(
        count
        for status, count in full_statuses.items()
        if status
        in {
            "ready",
            "ready_for_compile",
            "compiled",
            "validated",
            "ready_for_execution",
        }
    )
    full_execution_ready = sum(
        count
        for status, count in full_statuses.items()
        if status in {"ready", "ready_for_execution"}
    )
    suite_requests = suite.get("requests") or []
    suite_requests = suite_requests if isinstance(suite_requests, list) else []
    suite_planned_events = sum(
        int(record.get("warmups", 0) or 0) + int(record.get("trials", 0) or 0)
        for record in suite_requests
        if isinstance(record, Mapping)
    )

    calibration = load_json(campaign_dir / "calibration" / "requests.json", {})
    calibration = calibration if isinstance(calibration, Mapping) else {}
    calibration_support = calibration.get("support") or {}
    calibration_support = (
        calibration_support if isinstance(calibration_support, Mapping) else {}
    )
    calibration_statuses = Counter(
        str(record.get("status") or "unspecified")
        for record in calibration_support.values()
        if isinstance(record, Mapping)
    )
    # ``calibrate`` has emitted ``run_requests`` since materialized bundles
    # became part of the manifest.  Older study snapshots used ``requests``.
    # Prefer the current key whenever it is present (including an explicitly
    # empty plan) and retain the legacy key solely for report compatibility.
    calibration_requests = (
        calibration.get("run_requests")
        if "run_requests" in calibration
        else calibration.get("requests")
    ) or []
    calibration_requests = (
        calibration_requests if isinstance(calibration_requests, list) else []
    )
    calibration_planned_events = sum(
        int(record.get("warmups", 0) or 0) + int(record.get("trials", 0) or 0)
        for record in calibration_requests
        if isinstance(record, Mapping)
    )

    service_preflight = load_json(campaign_dir / "service-preflight.json", {})
    service_preflight = (
        service_preflight if isinstance(service_preflight, Mapping) else {}
    )
    return {
        "suite_manifest_present": bool(suite),
        "endpoint_staged": endpoint_staged,
        "endpoint_modes": dict(sorted(endpoint_modes.items())),
        "endpoint_errors": dict(sorted(endpoint_errors.items())),
        "full_telemetry_compile_ready": full_compile_ready,
        "full_telemetry_execution_ready": full_execution_ready,
        "full_telemetry_statuses": dict(sorted(full_statuses.items())),
        "suite_arm_requests": len(suite_requests),
        "suite_planned_events": suite_planned_events,
        "calibration_manifest_present": bool(calibration),
        "calibration_cases": len(calibration_support),
        "calibration_statuses": dict(sorted(calibration_statuses.items())),
        "calibration_arm_requests": len(calibration_requests),
        "calibration_planned_events": calibration_planned_events,
        "service_preflight_ok": service_preflight.get("ok"),
        "service_preflight_detected": dict(service_preflight.get("detected") or {}),
    }


def _layout_for(campaign_dir: Path, kernel: Mapping[str, Any]) -> dict[str, Any]:
    name = str(kernel.get("name") or kernel.get("kernel") or "unknown")
    candidates = (
        campaign_dir / "kernels" / safe_name(name) / "layout.json",
        campaign_dir / "layouts" / f"{safe_name(name)}.json",
    )
    for candidate in candidates:
        payload = load_json(candidate)
        if isinstance(payload, dict):
            return payload
    embedded = kernel.get("layout")
    return dict(embedded) if isinstance(embedded, dict) else {}


def _count_record(layout: Mapping[str, Any], name: str) -> Any:
    counts = layout.get("counts", {})
    aliases = {
        "application": "application_allocated",
        "io_infrastructure": "io_loaded",
        "dynamically_active": "dynamically_active",
    }
    key = aliases.get(name, name)
    if isinstance(counts, dict) and key in counts:
        return counts[key]
    return layout.get(name)


def _display_scientific(record: Any) -> str:
    if isinstance(record, Mapping) and "value" in record:
        value = record.get("value")
        evidence = record.get("evidence", "unlabelled")
        rendered = "—" if value is None else str(value)
        return f"{rendered} ({evidence})"
    if record is None:
        return "— (unavailable)"
    return f"{record} (unlabelled)"


def _measurement_summary(rows: Iterable[Mapping[str, Any]]) -> dict[str, Any]:
    """Summarize unique trials without counting per-PE/phase rows as trials."""

    grouped: dict[tuple[str, str, str, str], list[dict[str, Any]]] = defaultdict(list)
    rejected: dict[tuple[str, str], list[str]] = defaultdict(list)
    arms = Counter()
    for row in rows:
        kernel = str(row.get("kernel") or "unknown")
        arm = str(row.get("arm") or "unknown")
        arms[arm] += 1
        if str(row.get("warmup", "")).lower() in {"1", "true", "yes"}:
            continue
        converted = dict(row)
        try:
            converted["elapsed_cycles"] = int(row.get("elapsed_cycles", ""))
        except (TypeError, ValueError):
            pass
        telemetry = str(row.get("telemetry_level") or "unspecified")
        identity = str(row.get("run_id") or "")
        if not identity:
            trial = row.get("trial")
            identity = f"trial:{trial}" if trial not in (None, "") else "missing-trial-identity"
        grouped[(kernel, arm, telemetry, identity)].append(converted)

    accepted: dict[tuple[str, str, str], list[tuple[str, int, bool]]] = defaultdict(list)
    accepted_meta: dict[
        tuple[str, str, str], list[tuple[str, int, str]]
    ] = defaultdict(list)
    for (kernel, arm, telemetry, identity), candidates in grouped.items():
        # A full telemetry export may contain many PE/phase rows.  Only the
        # device-internal compute endpoint is a headline trial observation.
        endpoints = [
            row
            for row in candidates
            if str(row.get("phase") or "compute_end") == "compute_end"
            and row.get("elapsed_cycles") not in (None, "")
        ]
        if not endpoints:
            rejected[(kernel, arm)].append(f"{identity}: no compute_end elapsed-cycle row")
            continue
        per_pe: dict[tuple[Any, ...], list[dict[str, Any]]] = defaultdict(list)
        for row in endpoints:
            pe_key = tuple(
                row.get(field)
                for field in (
                    "fabric_x",
                    "fabric_y",
                    "logical_x",
                    "logical_y",
                    "pe_role",
                )
            )
            per_pe[pe_key].append(row)
        unique_endpoints: list[dict[str, Any]] = []
        conflicting = False
        for pe_rows in per_pe.values():
            signatures = {
                (
                    row.get("elapsed_cycles"),
                    row.get("timing_method"),
                    str(row.get("correctness")),
                )
                for row in pe_rows
            }
            if len(signatures) != 1:
                conflicting = True
                break
            unique_endpoints.append(pe_rows[0])
        if conflicting:
            rejected[(kernel, arm)].append(f"{identity}: conflicting duplicate endpoint rows")
            continue
        errors = [
            error
            for row in unique_endpoints
            for error in validate_timed_trial(row)
        ]
        if errors:
            rejected[(kernel, arm)].extend(f"{identity}: {error}" for error in errors)
            continue
        critical = max(
            unique_endpoints, key=lambda item: int(item["elapsed_cycles"])
        )
        cycles = [int(row["elapsed_cycles"]) for row in unique_endpoints]
        provenance_complete = bool(critical.get("source_hash")) and (
            arm != "hardware"
            or (bool(critical.get("job_id")) and bool(critical.get("artifact_id")))
        )
        accepted[(kernel, arm, telemetry)].append(
            (identity, max(cycles), provenance_complete)
        )
        fabric_x, fabric_y = critical.get("fabric_x"), critical.get("fabric_y")
        logical_x, logical_y = critical.get("logical_x"), critical.get("logical_y")
        if fabric_x not in (None, "") and fabric_y not in (None, ""):
            critical_label = f"fabric({fabric_x},{fabric_y})"
        elif logical_x not in (None, "") and logical_y not in (None, ""):
            critical_label = f"logical({logical_x},{logical_y})"
        else:
            critical_label = "unresolved"
        accepted_meta[(kernel, arm, telemetry)].append(
            (identity, max(cycles) - min(cycles), critical_label)
        )

    summaries: dict[str, Any] = {}
    grouped_modes: dict[tuple[str, str], dict[str, list[tuple[str, int, bool]]]] = defaultdict(dict)
    for (kernel, arm, telemetry), values in accepted.items():
        grouped_modes[(kernel, arm)][telemetry] = values
    for (kernel, arm), modes in grouped_modes.items():
        # Endpoint is the low-intrusion headline.  Older imported tables may
        # have omitted the level; retain them as "unspecified" but label it.
        selected_level = next(
            (level for level in ("endpoint", "low_intrusion", "unspecified") if level in modes),
            sorted(modes)[0],
        )
        selected = modes[selected_level]
        stats = summarize_cycles([cycles for _, cycles, _ in selected])
        stats.update(
            {
                "telemetry_level": selected_level,
                "unique_trial_count": len({identity for identity, _, _ in selected}),
                "provenance_complete_count": sum(complete for _, _, complete in selected),
                "available_telemetry_levels": sorted(modes),
            }
        )
        selected_meta = accepted_meta.get((kernel, arm, selected_level), [])
        if selected_meta:
            skew = summarize_cycles([value for _, value, _ in selected_meta])
            critical_counts = Counter(label for _, _, label in selected_meta)
            stats.update(
                {
                    "per_pe_skew_cycles": skew,
                    "critical_pe": critical_counts.most_common(1)[0][0],
                    "critical_pe_counts": dict(sorted(critical_counts.items())),
                }
            )
        if "endpoint" in modes and "full" in modes:
            endpoint_stats = summarize_cycles([value[1] for value in modes["endpoint"]])
            full_stats = summarize_cycles([value[1] for value in modes["full"]])
            baseline = float(endpoint_stats.get("median", 0))
            stats["full_telemetry_overhead_pct"] = (
                100.0 * (float(full_stats.get("median", 0)) / baseline - 1.0)
                if baseline > 0
                else None
            )
        summaries[f"{kernel}\0{arm}"] = stats
    return {
        "accepted": summaries,
        "rejected": {
            f"{kernel}\0{arm}": sorted(set(errors))
            for (kernel, arm), errors in rejected.items()
        },
        "arms": dict(arms),
    }


def _trace_state(paths: Iterable[Path]) -> tuple[bool, bool, list[str]]:
    """Return decoded, campaign-qualified, and qualification reasons."""

    for path in paths:
        payload = load_json(path)
        if not isinstance(payload, dict):
            continue
        if payload.get("status") in {"decoded", "complete", "pass"}:
            qualification = payload.get("acceptance_qualification") or {}
            reasons = list(
                qualification.get("reasons") or []
                if isinstance(qualification, Mapping)
                else ["decoded trace has no acceptance qualification"]
            )
            if not isinstance(qualification, Mapping) or qualification.get("status") != "qualified":
                reasons.append("decoded trace is not source/compile/window qualified")
            integrity = payload.get("trace_integrity") or {}
            if not isinstance(integrity, Mapping) or integrity.get("status") != "complete":
                reasons.append("trace integrity is not complete")
            if int(integrity.get("discarded_events", 0) or 0):
                reasons.append("CTF reports discarded events")
            source = payload.get("source") or {}
            if not isinstance(source, Mapping) or not source.get("stream0_sha256") or not source.get(
                "metadata_sha256"
            ):
                reasons.append("trace source stream/metadata hashes are missing")
            if sum(int(value) for value in (payload.get("event_counts") or {}).values()) <= 0:
                reasons.append("decoded trace contains no events")
            events_path = path.parent / "events.jsonl.gz"
            expected_events_hash = str(payload.get("events_sha256") or "")
            if not events_path.is_file() or not expected_events_hash:
                reasons.append("decoded event history artifact/hash is missing")
            elif hash_file(events_path) != expected_events_hash:
                reasons.append("decoded event history hash does not match trace summary")
            return True, not reasons, sorted(set(str(reason) for reason in reasons))
    return False, False, ["no decoded trace artifact"]


def _layout_is_compiled(layout: Mapping[str, Any]) -> bool:
    validation = layout.get("validation")
    return bool(
        layout
        and isinstance(validation, Mapping)
        and validation.get("status") == "ok"
    )


def _layout_is_qualified(layout: Mapping[str, Any]) -> bool:
    qualification = layout.get("acceptance_qualification") or {}
    return _layout_is_compiled(layout) and isinstance(qualification, Mapping) and (
        qualification.get("status") == "qualified"
    )


def _flow_atlas_row(name: str, layout: Mapping[str, Any]) -> str:
    overlay = layout.get("flow_overlay") or {}
    pes = overlay.get("pes") if isinstance(overlay, Mapping) else []
    links = overlay.get("links") if isinstance(overlay, Mapping) else []
    timing_scope = _display_scientific(
        overlay.get("timing_scope") if isinstance(overlay, Mapping) else None
    )
    hottest_pe = max(
        (item for item in (pes or []) if isinstance(item, Mapping)),
        key=lambda item: int(item.get("event_observations", 0)),
        default=None,
    )
    hottest_link = max(
        (item for item in (links or []) if isinstance(item, Mapping)),
        key=lambda item: int(item.get("observations", 0)),
        default=None,
    )
    if hottest_pe:
        coordinate = hottest_pe.get("fabric") or {}
        pe_label = f"({coordinate.get('x')},{coordinate.get('y')}) (simulator; {timing_scope})"
        pe_events = str(hottest_pe.get("event_observations", "—"))
    else:
        pe_label, pe_events = "—", "—"
    if hottest_link:
        source, destination = hottest_link.get("from") or {}, hottest_link.get("to") or {}
        link_label = (
            f"({source.get('x')},{source.get('y')})→"
            f"({destination.get('x')},{destination.get('y')}) (inferred)"
        )
        volume = str(hottest_link.get("observations", "—"))
        delay = str(hottest_link.get("median_delay_cycles", "—"))
        pressure = str(hottest_link.get("nonzero_backpressure_samples", "—"))
    else:
        link_label = volume = delay = pressure = "—"
    escaped_name = name.replace("|", "\\|")
    return (
        f"| {escaped_name} | {pe_label} | {pe_events} | {link_label} | "
        f"{volume} | {delay} | {pressure} |"
    )


def generate_report(campaign_dir: str | Path, output: str | Path | None = None) -> Path:
    root = Path(campaign_dir).resolve()
    campaign = load_json(root / "campaign.json", {})
    if not isinstance(campaign, dict):
        raise ValueError(f"invalid campaign manifest: {root / 'campaign.json'}")
    kernels = _kernel_items(campaign)
    measurement_path = root / "measurements.csv"
    measurements = load_measurements(measurement_path) if measurement_path.is_file() else []
    measured = _measurement_summary(measurements)
    readiness = _execution_readiness(root)
    simulator_trace_controls = _qualified_simulator_trace_controls(root)

    latency_samples = _load_latency_samples(root)
    latency_model: dict[str, Any] | None = None
    model_error: str | None = None
    if latency_samples:
        try:
            latency_model = fit_latency_model(latency_samples)
            atomic_write_json(root / "models" / "latency_model.json", latency_model)
        except Exception as exc:  # report incompleteness without concealing it
            model_error = f"{type(exc).__name__}: {exc}"
    single_pe_model = load_json(root / "models" / "single_pe_model.json")
    if not isinstance(single_pe_model, Mapping):
        single_pe_model = None

    trace_decoded = 0
    trace_complete = 0
    simulator_aggregate_complete = 0
    hardware_complete = 0
    layout_parsed = 0
    layout_complete = 0
    atlas_rows: list[str] = []
    flow_rows: list[str] = []
    failure_rows: list[str] = []
    diagnostic_rows: list[str] = []
    paired_telemetry_count = 0
    simulator_hardware_error_pct: list[float] = []
    active_kernel_names = {
        str(kernel.get("name") or kernel.get("kernel") or "unknown")
        for kernel in kernels
    }
    for kernel in kernels:
        name = str(kernel.get("name") or kernel.get("kernel") or "unknown")
        layout = _layout_for(root, kernel)
        flow_rows.append(_flow_atlas_row(name, layout))
        has_parsed_layout = _layout_is_compiled(layout)
        has_layout = _layout_is_qualified(layout)
        layout_parsed += int(has_parsed_layout)
        layout_complete += int(has_layout)
        trace_candidates = (
            root / "kernels" / safe_name(name) / "trace_summary.json",
            root / "traces" / safe_name(name) / "trace_summary.json",
            root / "traces" / f"{safe_name(name)}.json",
        )
        decoded_trace, has_trace, trace_reasons = _trace_state(trace_candidates)
        trace_decoded += int(decoded_trace)
        trace_complete += int(has_trace)
        silicon_key = f"{name}\0hardware"
        stats = measured["accepted"].get(silicon_key, {})
        valid_trials = int(stats.get("unique_trial_count", stats.get("count", 0))) if stats else 0
        provenance_trials = int(stats.get("provenance_complete_count", 0)) if stats else 0
        is_hw_complete = valid_trials >= 30 and provenance_trials >= 30
        hardware_complete += int(is_hw_complete)
        simulator_key = f"{name}\0simulator"
        simulator_stats = measured["accepted"].get(simulator_key, {})
        simulator_trials = int(
            simulator_stats.get("unique_trial_count", simulator_stats.get("count", 0))
        ) if simulator_stats else 0
        simulator_provenance = int(
            simulator_stats.get("provenance_complete_count", 0)
        ) if simulator_stats else 0
        is_simulator_complete = simulator_trials >= 30 and simulator_provenance >= 30
        simulator_aggregate_complete += int(is_simulator_complete)
        ratio = "—"
        if stats and simulator_stats and float(stats.get("median", 0)) > 0:
            ratio_value = float(simulator_stats.get("median", 0)) / float(stats["median"])
            ratio = f"{ratio_value:.4g}"
            simulator_hardware_error_pct.append(100.0 * (ratio_value - 1.0))
        status = (
            "complete"
            if has_layout and has_trace and is_simulator_complete and is_hw_complete
            else "incomplete"
        )
        escaped_name = name.replace("|", "\\|")
        kernel_artifact_dir = root / "kernels" / safe_name(name)
        if (kernel_artifact_dir / "layout.svg").is_file():
            atlas_name = (
                f"[{escaped_name}](kernels/{safe_name(name)}/layout.svg) "
                f"([wafer](kernels/{safe_name(name)}/wafer.svg))"
            )
        else:
            atlas_name = escaped_name
        atlas_rows.append(
            "| {name} | {app} | {support} | {active} | {routes} | {sim_trials} | "
            "{trials} | {provenance} | {minimum} | {median} | {p95} | {mad} | "
            "{skew} | {critical_pe} | {ratio} | {status} |".format(
                name=atlas_name,
                app=_display_scientific(_count_record(layout, "application")),
                support=_display_scientific(_count_record(layout, "io_infrastructure")),
                active=_display_scientific(_count_record(layout, "dynamically_active")),
                routes=(
                    f"{len(layout.get('route_edges', []))} (compiled)"
                    if has_parsed_layout and isinstance(layout.get("route_edges"), list)
                    else "— (unavailable)"
                ),
                sim_trials=simulator_trials,
                trials=valid_trials,
                provenance=provenance_trials,
                median=stats.get("median", "—") if stats else "—",
                minimum=stats.get("min", "—") if stats else "—",
                p95=stats.get("p95", "—") if stats else "—",
                mad=stats.get("mad", "—") if stats else "—",
                skew=(stats.get("per_pe_skew_cycles") or {}).get("median", "—")
                if stats
                else "—",
                critical_pe=stats.get("critical_pe", "—") if stats else "—",
                ratio=ratio,
                status=status,
            )
        )
        reasons = list(measured["rejected"].get(silicon_key, []))
        qualification = layout.get("acceptance_qualification") or {}
        if not has_layout and isinstance(qualification, Mapping):
            reasons.extend(str(reason) for reason in qualification.get("reasons") or [])
        if decoded_trace and not has_trace:
            reasons.extend(str(reason) for reason in trace_reasons)
        if valid_trials >= 30 and provenance_trials < 30:
            reasons.append(
                f"only {provenance_trials}/30 hardware trials retain source hash, job ID, and artifact ID"
            )
        if simulator_trials >= 30 and simulator_provenance < 30:
            reasons.append(
                f"only {simulator_provenance}/30 simulator trials retain their frozen source hash"
            )
        overhead = stats.get("full_telemetry_overhead_pct") if stats else None
        if overhead is not None:
            paired_telemetry_count += 1
            if float(overhead) > 5.0:
                diagnostic_rows.append(
                    f"- **{name}:** full spatial telemetry adds `{float(overhead):.4g}%`; "
                    "endpoint timing remains the headline and the full run is diagnostic."
                )
        for key, present in (("campaign-qualified layout", has_layout), ("campaign-qualified detailed trace", has_trace), ("30 source-bound aggregate simulator trials", is_simulator_complete), ("30 provenance-complete hardware trials", is_hw_complete)):
            if not present:
                reasons.append(f"missing {key}")
        if reasons:
            failure_rows.append(f"- **{name}:** " + "; ".join(sorted(set(reasons))))

    calibration_controls: list[dict[str, Any]] = []
    measured_subjects = {
        key.split("\0", 1)[0] for key in measured["accepted"]
    }
    for subject in sorted(measured_subjects - active_kernel_names):
        simulator_stats = measured["accepted"].get(f"{subject}\0simulator", {})
        hardware_stats = measured["accepted"].get(f"{subject}\0hardware", {})
        simulator_median = simulator_stats.get("median")
        hardware_median = hardware_stats.get("median")
        ratio = (
            float(simulator_median) / float(hardware_median)
            if simulator_median is not None
            and hardware_median is not None
            and float(hardware_median) > 0
            else None
        )
        calibration_controls.append(
            {
                "subject": subject,
                "simulator_trials": int(simulator_stats.get("unique_trial_count", 0)),
                "hardware_trials": int(hardware_stats.get("unique_trial_count", 0)),
                "simulator_median_cycles": simulator_median,
                "hardware_median_cycles": hardware_median,
                "simulator_over_hardware": ratio,
                "evidence": "inferred comparison of simulator and silicon medians",
            }
        )

    total = len(kernels)
    readiness_rows = ["## Execution readiness", ""]
    if readiness["service_preflight_ok"] is True:
        detected = readiness["service_preflight_detected"]
        versions = detected.get("versions") or {}
        readiness_rows.append(
            "- ALCF service-node execution preflight: **pass** "
            f"(`cerebras-sdk {versions.get('cerebras-sdk', 'unknown')}`, "
            f"`cerebras-appliance {versions.get('cerebras-appliance', 'unknown')}`, "
            f"fabric `{detected.get('fabric_dims', [762, 1172])}`)."
        )
    elif readiness["service_preflight_ok"] is False:
        readiness_rows.append("- ALCF service-node execution preflight: **failed**.")
    else:
        readiness_rows.append("- ALCF service-node execution preflight: **not recorded**.")
    if readiness["suite_manifest_present"]:
        modes = ", ".join(
            f"{name}={count}" for name, count in readiness["endpoint_modes"].items()
        ) or "none"
        readiness_rows.extend(
            [
                f"- Conservative endpoint adapters staged: **{readiness['endpoint_staged']}/{total}** "
                f"({modes}); explicit staging failures: **{len(readiness['endpoint_errors'])}**.",
                f"- Full synchronized spatial-telemetry sources compile-ready: "
                f"**{readiness['full_telemetry_compile_ready']}/{total}**; "
                f"execution-ready after compile, original-correctness, and D2H-schema gates: "
                f"**{readiness['full_telemetry_execution_ready']}/{total}**; statuses: "
                f"`{json.dumps(readiness['full_telemetry_statuses'], sort_keys=True)}`.",
                f"- Suite plan: **{readiness['suite_arm_requests']}** simulator/hardware arm "
                f"requests and **{readiness['suite_planned_events']}** checkpointed "
                "warmup/trial events.",
            ]
        )
    else:
        readiness_rows.append("- Suite execution plan: **not materialized**.")
    if readiness["calibration_manifest_present"]:
        readiness_rows.append(
            f"- Calibration plan: **{readiness['calibration_cases']}** cases, statuses "
            f"`{json.dumps(readiness['calibration_statuses'], sort_keys=True)}`, "
            f"**{readiness['calibration_arm_requests']}** arm requests, and "
            f"**{readiness['calibration_planned_events']}** planned events."
        )
    else:
        readiness_rows.append("- Calibration execution plan: **not materialized**.")
    if readiness["endpoint_errors"]:
        readiness_rows.extend(
            [
                "",
                "Endpoint adapter staging failures (these kernels are not silently skipped):",
                "",
                "| Kernel | Blocking reason |",
                "|---|---|",
            ]
        )
        for name, reason in readiness["endpoint_errors"].items():
            escaped_name = name.replace("|", "\\|")
            escaped_reason = reason.replace("|", "\\|")
            readiness_rows.append(f"| {escaped_name} | {escaped_reason} |")
    readiness_rows.append("")

    lines = [
        "# WSE-3 Spatial and Data-Movement Characterization",
        "",
        f"Generated: `{utc_now()}`  ",
        f"Campaign: `{campaign.get('campaign_id', root.name)}`  ",
        f"Schema: `{SCHEMA_VERSION}`",
        "",
        "## Scientific interpretation",
        "",
        "The WSE executes independent, event-driven programs across a two-dimensional PE mesh "
        "(spatial MIMD). Within a WSE-3 PE, DSD operations use SIMD execution and up to eight "
        "asynchronous microthread contexts; those contexts are not CUDA warp lanes "
        "([documented evidence: Computing with Cerebras](https://sdk.cerebras.ai/computing-with-cerebras), "
        "[WSE-3 microthreads](https://sdk.cerebras.ai/csl/language/microthreads_wse3)).",
        "",
        "This report separates compiled placement, deterministic simulator traces, silicon "
        "timestamps, and inferred models. It does not claim access to Cerebras's private "
        "defect/spare remapping or to a cycle-by-cycle hardware wavelet trace.",
        "",
        "## Campaign completeness",
        "",
        f"- Active kernels frozen: **{total}**",
        f"- Retained compiled layouts decoded: **{layout_parsed}/{total}**",
        f"- SDK 2.10/full-fabric campaign-qualified layouts: **{layout_complete}/{total}**",
        f"- Retained simulator traces decoded: **{trace_decoded}/{total}**",
        f"- Source/compile/window-qualified detailed traces: **{trace_complete}/{total}**",
        f"- At least 30 unique, source-bound aggregate simulator trials: **{simulator_aggregate_complete}/{total}**",
        f"- At least 30 unique, provenance-complete silicon trials: **{hardware_complete}/{total}**",
        "",
        "A retained SDK 1.4/small-fabric artifact is useful decoder-validation evidence, but it "
        "does not satisfy the SDK 2.10/full-fabric campaign acceptance gate. A kernel is complete "
        "only when the layout, detailed trace, aggregate simulator, and silicon gates pass. Missing or invalid results "
        "remain visible below; they are never silently skipped.",
        "",
        *readiness_rows,
        "## Kernel PE and timing atlas",
        "",
        "| Kernel | Application PEs | I/O/support PEs | Dynamically active PEs | Route edges | Unique sim trials | Unique HW trials | Provenance-complete HW trials | Minimum HW cycles | Median HW cycles | p95 HW cycles | HW MAD | Median per-PE skew | Critical silicon PE | Sim/HW median | Status |",
        "|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|---:|---|",
        *atlas_rows,
        "",
        "## Simulator spatial-flow hotspots",
        "",
        "Hottest-PE counts are simulator event observations. Hottest-link membership is inferred "
        "from wavelet identifier/time/cardinal adjacency; it is not a silicon link counter.",
        "",
        "| Kernel | Critical fabric PE | Event observations | Hottest directed link | Link observations | Median hop delta (cycles) | Nonzero backpressure samples |",
        "|---|---|---:|---|---:|---:|---:|",
        *flow_rows,
        "",
        "## Simulator/hardware agreement",
        "",
    ]
    if simulator_hardware_error_pct:
        agreement = summarize_cycles(simulator_hardware_error_pct)
        absolute_agreement = summarize_cycles(
            [abs(value) for value in simulator_hardware_error_pct]
        )
        lines.extend(
            [
                "Per-kernel values compare aggregate simulator and silicon medians; they are "
                "inferred comparisons, not paired cycle-by-cycle hardware traces.",
                "",
                f"- Kernels with both arms: `{agreement['count']}`",
                f"- Median signed simulator error: `{agreement['median']}`%",
                f"- p95 signed simulator error: `{agreement['p95']}`%",
                f"- Median/p95 absolute simulator error: `{absolute_agreement['median']}`% / `{absolute_agreement['p95']}`%",
                f"- Minimum/maximum signed error: `{agreement['min']}`% / `{agreement['max']}`%",
                "",
            ]
        )
    else:
        lines.extend(["No source-bound simulator/silicon pairs are available yet.", ""])
    lines.extend(
        [
            "## Calibration control measurements",
            "",
            "These controls are outside the 49-kernel acceptance count. Cycle values are "
            "device-internal observations; the arm-to-arm ratio is inferred.",
            "",
            "| Control | Sim trials | HW trials | Sim median cycles | HW median cycles | Sim/HW |",
            "|---|---:|---:|---:|---:|---:|",
            *(
                [
                    "| {subject} | {simulator_trials} | {hardware_trials} | "
                    "{simulator_median_cycles} | {hardware_median_cycles} | {ratio} |".format(
                        **control,
                        ratio=(
                            f"{control['simulator_over_hardware']:.6g}"
                            if control["simulator_over_hardware"] is not None
                            else "—"
                        ),
                    )
                    for control in calibration_controls
                ]
                or ["| — | 0 | 0 | — | — | — |"]
            ),
            "",
        ]
    )
    trace_control_rows = [
        "| {subject} | `{job_id}` | `{event_key}` | {raw_ctf_events} | "
        "{tsc_window_events} | {ctf_wavelet_events} | {csdb_wavelet_events} | "
        "{pe_count} | exact total + per-PE |".format(
            **{**control, "subject": str(control["subject"]).replace("|", "\\|")},
        )
        for control in simulator_trace_controls["controls"]
    ]
    lines.extend(
        [
            "## Qualified simulator trace-ingest controls",
            "",
            "These controls are outside kernel acceptance and are simulator evidence only, "
            "not silicon traces. The official SDK `csdb` comparison covers raw full-session "
            "wavelet totals and per-PE tile decoding; its `Link` column remains raw and is "
            "not interpreted as a direction or route.",
            "",
            "| Control | Job | Event | Raw CTF events | Events in device TSC window | "
            "CTF wavelets | csdb wavelets | PE coordinates | Cross-check |",
            "|---|---|---|---:|---:|---:|---:|---:|---|",
            *(trace_control_rows or ["| — | — | — | 0 | 0 | 0 | 0 | 0 | — |"]),
            "",
            f"Qualified controls: **{simulator_trace_controls['qualified_count']}**; "
            f"fail-closed exclusions: **{simulator_trace_controls['excluded_count']}**.",
            "",
        ]
    )
    lines.extend(
        [
        "## Directional silicon latency model",
        "",
        ]
    )
    if latency_model:
        intervals = latency_model.get("confidence_intervals") or {}
        endpoint_interval = intervals.get("endpoint_cycles") or {}
        uncontended_metrics = latency_model.get("uncontended_validation_metrics") or {}
        lines.extend(
            [
                f"Model form: `{latency_model['model_kind']}` (evidence: inferred from silicon TSC samples).",
                "",
                (
                    f"- Endpoint cost: `{latency_model['endpoint_cycles']:.4g}` cycles "
                    f"(bootstrap 95% CI `{endpoint_interval.get('low_95', '—')}` to "
                    f"`{endpoint_interval.get('high_95', '—')}`)"
                ),
                *[
                    f"- `{name}`: `{value:.4g}` cycles per unit "
                    f"(bootstrap 95% CI `{(intervals.get(name) or {}).get('low_95', '—')}` to "
                    f"`{(intervals.get(name) or {}).get('high_95', '—')}`)"
                    for name, value in latency_model["coefficients"].items()
                ],
                f"- All validation median absolute percentage error: `{latency_model['validation_metrics']['mape_pct']}`",
                f"- Validation mean absolute error: `{latency_model['validation_metrics']['mae_cycles']}` cycles",
                f"- Uncontended validation median absolute percentage error: `{uncontended_metrics.get('mape_pct')}`",
                f"- 10% uncontended validation target met: `{latency_model['validation_target_met']}`",
                "",
            ]
        )
        if latency_model.get("validation_target_met") is False:
            residuals = sorted(
                latency_model.get("validation_residuals") or [],
                key=lambda row: float(row.get("absolute_error_cycles", 0)),
                reverse=True,
            )
            lines.extend(
                [
                    "The linear target was not met. Largest held-out residuals are reported "
                    "instead of treating the fit as authoritative:",
                    "",
                    "| Case | Actual cycles | Predicted cycles | Residual cycles | Absolute error % | Uncontended |",
                    "|---|---:|---:|---:|---:|---|",
                    *[
                        "| {case_id} | {actual_cycles:.6g} | {predicted_cycles:.6g} | "
                        "{residual_cycles:.6g} | {absolute_percentage_error} | {uncontended} |".format(
                            **row
                        )
                        for row in residuals[:20]
                    ],
                    "",
                ]
            )
    elif model_error:
        lines.extend([f"Model fitting failed and remains open: `{model_error}`", ""])
    else:
        lines.extend(["No silicon calibration samples have been recorded yet.", ""])

    lines.extend(
        [
            "## Single-PE execution limits",
            "",
        ]
    )
    if single_pe_model and int(single_pe_model.get("trial_count", 0)) > 0:
        widths = single_pe_model.get("observed_simd_widths") or {}
        ceiling = (single_pe_model.get("sram_ceiling") or {}).get(
            "largest_compiling_allocation_bytes"
        )
        lines.extend(
            [
                f"Accepted silicon single-PE observations: **{single_pe_model.get('trial_count')}**.",
                "",
                f"- Explicitly decoded simulator instruction SIMD widths: `{json.dumps(widths, sort_keys=True)}`",
                f"- Largest compiling generated allocation: `{ceiling}` bytes",
                "- Hardware throughput metrics are inferred from device TSC cycles; instruction width is accepted only from simulator instruction evidence.",
                "",
            ]
        )
    else:
        lines.extend(
            [
                "No accepted scalar/DSD silicon sweep is available. Single-PE conclusions remain open; "
                "hardware throughput alone cannot prove instruction SIMD width.",
                "",
            ]
        )
    lines.extend(
        [
            "## Telemetry perturbation diagnostics",
            "",
            *(
                diagnostic_rows
                if diagnostic_rows
                else (
                    [
                        f"- {paired_telemetry_count} endpoint/full telemetry pair(s) are "
                        "available; none exceeds the 5% diagnostic threshold."
                    ]
                    if paired_telemetry_count
                    else ["- No paired endpoint/full telemetry observations are available yet."]
                )
            ),
            "",
            "## Open failures and exclusions",
            "",
            *(failure_rows or ["- None."]),
            "",
            "## Evidence boundary",
            "",
            "- **documented:** Cerebras/ALCF architectural material.",
            "- **compiled:** layout parameters, ELFs, symbols, memory banks, and route tables.",
            "- **simulator:** exact instruction/wavelet/backpressure events from simfab artifacts.",
            "- **silicon:** device-internal TSC telemetry and explicit D2H counters.",
            "- **inferred:** fitted costs or path timing derived from the preceding evidence.",
            "",
            "Primary timing units are cycles. Nanoseconds must not be emitted until the allocated "
            "system clock is independently confirmed.",
            "",
        ]
    )
    destination = Path(output) if output else root / "report.md"
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_text("\n".join(lines), encoding="utf-8")
    atomic_write_json(
        root / "report.json",
        {
            "schema_version": SCHEMA_VERSION,
            "generated_at": utc_now(),
            "campaign_id": campaign.get("campaign_id", root.name),
            "kernel_count": total,
            "layout_parsed": layout_parsed,
            "layout_complete": layout_complete,
            "trace_decoded": trace_decoded,
            "trace_complete": trace_complete,
            "simulator_aggregate_complete": simulator_aggregate_complete,
            "hardware_complete": hardware_complete,
            "simulator_hardware_signed_error_pct": (
                summarize_cycles(simulator_hardware_error_pct)
                if simulator_hardware_error_pct
                else {"count": 0}
            ),
            "simulator_hardware_absolute_error_pct": (
                summarize_cycles([abs(value) for value in simulator_hardware_error_pct])
                if simulator_hardware_error_pct
                else {"count": 0}
            ),
            "calibration_controls": calibration_controls,
            "simulator_trace_controls": simulator_trace_controls,
            "latency_model": latency_model,
            "latency_model_error": model_error,
            "execution_readiness": readiness,
            "paired_telemetry_count": paired_telemetry_count,
            "open_failures": len(failure_rows),
        },
    )
    return destination
