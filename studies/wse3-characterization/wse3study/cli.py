"""Command-line orchestration for the standalone WSE-3 study."""

from __future__ import annotations

import argparse
import copy
import json
import os
import shlex
import shutil
import sys
import tempfile
from dataclasses import replace
from pathlib import Path
from typing import Any, Iterable, Mapping, Sequence

from .artifact_binding import bind_campaign_compile_artifacts
from .calibration import all_calibration_cases, calibration_manifest
from .calibration_codegen import materialize_calibration_bundle, support_for_case
from .campaign import (
    HwVsSimRunner,
    load_ledger,
    make_calibration_requests,
    make_suite_requests,
    preflight,
    run_requests,
    validated_adapter_manifest,
)
from .instrumentation import (
    endpoint_adapter_generator_hash,
    full_telemetry_generator_hash,
    is_pristine_full_telemetry_override,
    materialize_full_telemetry_adapter,
    reinstrument_host_bracketed_bundle,
    stage_bundle,
    validate_full_telemetry_override,
    write_full_telemetry_override_template,
)
from .inventory import (
    SubprocessCsReadelfRunner,
    build_campaign_inventory,
    parse_compile_commands,
    write_inventory,
)
from .projection import (
    latency_samples,
    project_measurements,
    single_pe_samples,
    write_jsonl,
)
from .report import generate_report
from .schema import (
    EvidenceKind,
    ValidationError,
    atomic_write_json,
    canonical_hash,
    evidence_record,
    hash_file,
    hash_tree,
    load_json,
    safe_name,
    utc_now,
)
from .single_pe import analyze_single_pe
from .svg import write_layout_svgs
from .trace import (
    CoordinateMapper,
    Rectangle,
    TraceWindow,
    build_flow_overlay,
    decode_trace,
    write_events_jsonl_gz,
    write_wavelets_jsonl_gz,
)
from .trace_artifacts import (
    discover_simulator_trace_exports,
    ingest_simulator_trace_artifact,
)

STUDY_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_REPO_ROOT = STUDY_ROOT.parents[1]
DEFAULT_CAMPAIGN = STUDY_ROOT / "results" / "wse3-full"
STAGING_GENERATOR_VERSION = "1.1.0"


def _unwrap(record: Any) -> Any:
    return record.get("value") if isinstance(record, dict) and "value" in record else record


def _campaign_path(value: str | os.PathLike[str]) -> Path:
    return Path(value).expanduser().resolve()


def _load_campaign(path: Path) -> dict[str, Any]:
    manifest = load_json(path / "campaign.json")
    if not isinstance(manifest, dict):
        raise ValidationError(f"run inventory first; missing or invalid {path / 'campaign.json'}")
    return manifest


def _kernel_layouts(campaign: Mapping[str, Any], only: Sequence[str] = ()) -> list[tuple[str, dict[str, Any]]]:
    kernels = campaign.get("kernels") or {}
    if not isinstance(kernels, Mapping):
        raise ValidationError("campaign.kernels is not a mapping")
    requested = set(only)
    missing = requested - set(str(name) for name in kernels)
    if missing:
        raise ValidationError(f"kernel(s) not frozen in campaign: {', '.join(sorted(missing))}")
    return [
        (str(name), dict(layout))
        for name, layout in sorted(kernels.items())
        if not requested or str(name) in requested
    ]


def _freeze_identity(campaign: Mapping[str, Any]) -> str:
    kernels = campaign.get("kernels") or {}
    frozen: dict[str, Any] = {}
    if isinstance(kernels, Mapping):
        for name, raw_layout in sorted(kernels.items()):
            layout = raw_layout if isinstance(raw_layout, Mapping) else {}
            frozen[str(name)] = {
                "kernel": layout.get("kernel"),
                "hashes": layout.get("hashes"),
                "compile": layout.get("compile"),
            }
    return canonical_hash(
        {
            "repo_root": campaign.get("repo_root"),
            "kernels": frozen,
        }
    )


def _command_inventory(args: argparse.Namespace) -> int:
    repo_root = Path(args.repo_root).expanduser().resolve()
    campaign_dir = _campaign_path(args.campaign)
    readelf = SubprocessCsReadelfRunner(args.cs_readelf) if args.cs_readelf else None
    campaign = build_campaign_inventory(
        repo_root,
        cs_readelf_runner=readelf,
        only=args.kernel or None,
    )
    campaign["repo_root"] = str(repo_root)
    campaign["freeze_sha256"] = _freeze_identity(campaign)
    existing_path = campaign_dir / "campaign.json"
    existing = load_json(existing_path)
    if isinstance(existing, Mapping):
        existing_freeze = str(existing.get("freeze_sha256") or _freeze_identity(existing))
        changed = existing_freeze != campaign["freeze_sha256"]
        if changed and not args.refresh:
            raise ValidationError(
                "active source/compile freeze differs from the existing campaign; "
                "use --refresh to archive the old manifest and create a new snapshot"
            )
        if changed:
            old_hash = str(existing.get("campaign_sha256") or canonical_hash(existing))
            atomic_write_json(
                campaign_dir / "history" / f"campaign-{old_hash}.json",
                dict(existing),
            )
            campaign["previous_campaign_sha256"] = old_hash
        else:
            campaign["created_at"] = existing.get("created_at") or utc_now()
            campaign["campaign_id"] = (
                args.campaign_id
                or existing.get("campaign_id")
                or campaign_dir.name
            )
    campaign.pop("campaign_sha256", None)
    campaign.update(
        {
            "campaign_id": campaign.get("campaign_id")
            or args.campaign_id
            or campaign_dir.name,
            "created_at": campaign.get("created_at") or utc_now(),
            "repo_root": str(repo_root),
            "study_root": str(STUDY_ROOT),
            "evidence_policy": [item.value for item in EvidenceKind],
            "physical_remap": {
                "status": "out_of_scope",
                "reason": "private Cerebras defect/spare mapping is not exposed by the appliance SDK",
            },
        }
    )
    if args.bind_artifacts:
        campaign = bind_campaign_compile_artifacts(
            campaign,
            campaign_dir,
            artifact_root=(
                Path(args.artifact_root).expanduser().resolve()
                if args.artifact_root
                else campaign_dir / "artifacts"
            ),
            cs_readelf_runner=readelf,
        )
        # The binding operation hashes its result, but the CLI metadata above is
        # part of the final frozen campaign too.
        campaign.pop("campaign_sha256", None)
    campaign["campaign_sha256"] = canonical_hash(campaign)
    written = write_inventory(campaign, campaign_dir, render_svgs=not args.no_svg)
    print(json.dumps({"counts": campaign["counts"], "written": written["campaign"]}, indent=2))
    return 0 if not campaign.get("errors") else 1


def _mapper_from_layout(trace_dir: Path, layout: Mapping[str, Any]) -> CoordinateMapper:
    rectangle_value = _unwrap((layout.get("application") or {}).get("rectangle"))
    offsets_value = _unwrap((layout.get("fabric") or {}).get("offsets"))
    rectangle = None
    fabric_offset = None
    if isinstance(rectangle_value, Mapping) and isinstance(offsets_value, Mapping):
        width = int(rectangle_value.get("width", 0))
        height = int(rectangle_value.get("height", 0))
        ox, oy = int(offsets_value.get("x", 0)), int(offsets_value.get("y", 0))
        if width > 0 and height > 0:
            rectangle = Rectangle(ox, oy, width, height)
            fabric_offset = (ox, oy)
    infrastructure = []
    for pe in layout.get("pes") or []:
        if pe.get("role") == "application":
            continue
        fabric = pe.get("fabric")
        if isinstance(fabric, Mapping) and "x" in fabric and "y" in fabric:
            infrastructure.append((int(fabric["x"]), int(fabric["y"])))
    return CoordinateMapper.from_global_simdata(
        trace_dir,
        application_rect=rectangle,
        fabric_offset=fabric_offset,
        infrastructure_coordinates=infrastructure,
    )


def _trace_qualification(
    trace_dir: Path,
    layout: Mapping[str, Any],
    *,
    window: TraceWindow | None,
    discarded_events: int = 0,
) -> dict[str, Any]:
    """Bind a decoded trace to frozen source/compiler inputs when evidence exists."""

    manifest_path = trace_dir / ".wse3study_trace_manifest.json"
    manifest = load_json(manifest_path)
    reasons: list[str] = []
    if not isinstance(manifest, Mapping):
        reasons.append("no source/compile-bound trace manifest accompanies the retained stream")
        manifest = {}
    layout_qualification = layout.get("acceptance_qualification") or {}
    if not isinstance(layout_qualification, Mapping) or layout_qualification.get("status") != "qualified":
        reasons.append("the associated compiler layout is not campaign-qualified")
    hashes = layout.get("hashes") or {}
    expected_source = str(hashes.get("source_sha256") or "")
    expected_compile = str(hashes.get("compile_command_sha256") or "")
    if not expected_source or str(manifest.get("source_sha256") or "") != expected_source:
        reasons.append("trace source hash is absent or does not match the frozen bundle")
    if not expected_compile or str(manifest.get("compile_command_sha256") or "") != expected_compile:
        reasons.append("trace compile hash is absent or does not match the frozen command")
    sdk_version = str(manifest.get("sdk_version") or "")
    if not sdk_version.startswith("2.10"):
        reasons.append("trace SDK version is absent or is not 2.10.x")
    dimensions = manifest.get("fabric_dimensions")
    if dimensions not in ([762, 1172], {"width": 762, "height": 1172}):
        reasons.append("trace manifest does not record the ALCF 762x1172 fabric setting")
    for filename, field in (("stream0", "stream0_sha256"), ("metadata", "metadata_sha256")):
        artifact = trace_dir / filename
        expected = str(manifest.get(field) or "")
        if not artifact.is_file() or not expected or hash_file(artifact) != expected:
            reasons.append(f"trace manifest {field} is absent or does not match {filename}")
    if window is None and not manifest.get("device_tsc_window"):
        reasons.append("trace is not cropped to a recorded device TSC window")
    if window is not None and manifest.get("device_tsc_window"):
        recorded_window = manifest["device_tsc_window"]
        expected_window = {
            "start_cycle": window.start_cycle,
            "end_cycle": window.end_cycle,
            "counter_bits": window.counter_bits,
        }
        if not isinstance(recorded_window, Mapping) or any(
            recorded_window.get(key) != value for key, value in expected_window.items()
        ):
            reasons.append("caller trace window does not match the recorded device TSC window")
    if discarded_events:
        reasons.append(f"CTF reports {discarded_events} discarded simulator events")
    return {
        "status": "qualified" if not reasons else "unqualified",
        "reasons": reasons,
        "manifest": str(manifest_path) if manifest_path.is_file() else None,
        "manifest_sha256": hash_file(manifest_path) if manifest_path.is_file() else None,
        "evidence": EvidenceKind.INFERRED.value,
        "required_for_campaign_trace_acceptance": True,
    }


def _command_trace(args: argparse.Namespace) -> int:
    campaign_dir = _campaign_path(args.campaign)
    if args.discover_artifacts:
        if args.job_id or args.event_key:
            raise ValidationError(
                "--job-id/--event-key select ingestion, not artifact discovery"
            )
        discovery = discover_simulator_trace_exports(
            campaign_dir,
            artifact_root=args.artifact_root,
        )
        output = (
            Path(args.output_dir).expanduser().resolve()
            if args.output_dir
            else campaign_dir / "artifacts"
        ) / "trace-discovery.json"
        atomic_write_json(output, discovery)
        invalid = sum(
            item.get("status") == "invalid"
            for collection in (
                discovery["retained_zips"],
                discovery["extracted_exports"],
            )
            for item in collection
        )
        print(
            json.dumps(
                {
                    "jobs": len(discovery["jobs"]),
                    "binding_candidates": sum(
                        bool(item.get("binding_candidate"))
                        for item in discovery["jobs"]
                    ),
                    "invalid_artifacts": invalid,
                    "output": str(output),
                },
                indent=2,
            )
        )
        return 0 if invalid == 0 else 1
    if args.ingest_artifacts:
        if not args.job_id:
            raise ValidationError("--ingest-artifacts requires --job-id")
        if args.kernel or args.start_cycle is not None or args.end_cycle is not None:
            raise ValidationError(
                "artifact ingestion takes its exact subject/TSC window from the ledger; "
                "do not combine it with --kernel or caller cycle bounds"
            )
        result = ingest_simulator_trace_artifact(
            campaign_dir,
            job_id=args.job_id,
            event_key=args.event_key,
            artifact_root=args.artifact_root,
            output_dir=args.output_dir,
        )
        print(json.dumps(result, indent=2))
        return 0 if result["status"] == "qualified" else 1
    if args.job_id or args.event_key or args.artifact_root or args.output_dir:
        raise ValidationError(
            "artifact-only options require --discover-artifacts or --ingest-artifacts"
        )
    campaign = _load_campaign(campaign_dir)
    repo_root = Path(campaign.get("repo_root") or args.repo_root).expanduser().resolve()
    window = None
    if args.start_cycle is not None or args.end_cycle is not None:
        if args.start_cycle is None or args.end_cycle is None:
            raise ValidationError("--start-cycle and --end-cycle must be supplied together")
        window = TraceWindow(args.start_cycle, args.end_cycle, counter_bits=args.counter_bits)
    statuses: dict[str, Any] = {}
    failures = 0
    for name, embedded_layout in _kernel_layouts(campaign, args.kernel or ()):
        layout_path = campaign_dir / "kernels" / safe_name(name) / "layout.json"
        layout = load_json(layout_path, embedded_layout)
        csl_dir = ((layout.get("kernel") or {}).get("csl_dir"))
        trace_dir = repo_root / str(csl_dir) / "simfab_traces" if csl_dir else Path()
        output_dir = campaign_dir / "kernels" / safe_name(name)
        if not csl_dir or not (trace_dir / "stream0").is_file():
            status = {
                "status": "missing",
                "reason": "no retained simfab_traces/stream0; simulator trace run remains required",
                "evidence": EvidenceKind.SIMULATOR.value,
            }
            atomic_write_json(output_dir / "trace_summary.json", status)
            statuses[name] = status
            failures += 1
            continue
        try:
            mapper = _mapper_from_layout(trace_dir, layout)
            decoded = decode_trace(
                trace_dir,
                mapper=mapper,
                window=window,
                include_timeless=args.include_timeless,
                strict=not args.lenient,
                window_source=args.window_source,
            )
            wavelets_path = write_wavelets_jsonl_gz(
                output_dir / "wavelets.jsonl.gz", decoded["wavelets"]
            )
            events_path = write_events_jsonl_gz(
                output_dir / "events.jsonl.gz", decoded["events"]
            )
            active = {
                (int(coords["fabric"]["x"]), int(coords["fabric"]["y"]))
                for event in decoded["events"]
                if event.get("scope") == "application"
                for coords in [event.get("coordinates") or {}]
                if isinstance(coords.get("fabric"), Mapping)
            }
            layout.setdefault("counts", {})["dynamically_active"] = evidence_record(
                len(active),
                EvidenceKind.SIMULATOR,
                source=str(trace_dir / "stream0"),
                uncertainty=(
                    None if window else "full host session; provide a device-cycle window for timed-region activity"
                ),
            )
            layout["flow_overlay"] = build_flow_overlay(
                decoded["wavelets"], decoded["events"]
            )
            layout["flow_overlay"]["timing_scope"] = evidence_record(
                "device_tsc_window" if window else "full_host_session",
                EvidenceKind.SIMULATOR if window else EvidenceKind.INFERRED,
                source=args.window_source if window else str(trace_dir / "stream0"),
                uncertainty=(
                    None
                    if window
                    else "Hotspots include setup, memcpy/system activity, and teardown; they are diagnostic only."
                ),
            )
            atomic_write_json(layout_path, layout)
            write_layout_svgs(layout, output_dir)
            summary = {key: value for key, value in decoded.items() if key not in {"events", "wavelets"}}
            summary.update(
                {
                    "status": "decoded",
                    "kernel": name,
                    "wavelet_group_count": len(decoded["wavelets"]),
                    "dynamic_application_pe_count": len(active),
                    "wavelets_path": str(wavelets_path),
                    "wavelets_sha256": hash_file(wavelets_path),
                    "events_path": str(events_path),
                    "events_sha256": hash_file(events_path),
                    "source_sha256": (layout.get("hashes") or {}).get("source_sha256"),
                    "compile_command_sha256": (layout.get("hashes") or {}).get(
                        "compile_command_sha256"
                    ),
                    "layout_inventory_sha256": (layout.get("hashes") or {}).get(
                        "inventory_sha256"
                    ),
                    "acceptance_qualification": _trace_qualification(
                        trace_dir,
                        layout,
                        window=window,
                        discarded_events=int(
                            (decoded.get("trace_integrity") or {}).get(
                                "discarded_events", 0
                            )
                        ),
                    ),
                }
            )
            atomic_write_json(output_dir / "trace_summary.json", summary)
            statuses[name] = {
                "status": "decoded",
                "events": sum(summary.get("event_counts", {}).values()),
                "wavelet_groups": len(decoded["wavelets"]),
                "dynamic_application_pes": len(active),
                "acceptance_qualification": summary["acceptance_qualification"]["status"],
            }
        except Exception as exc:
            status = {
                "status": "error",
                "reason": f"{type(exc).__name__}: {exc}",
                "evidence": EvidenceKind.SIMULATOR.value,
            }
            atomic_write_json(output_dir / "trace_summary.json", status)
            statuses[name] = status
            failures += 1
    campaign["trace_status"] = statuses
    campaign["trace_updated_at"] = utc_now()
    campaign.pop("campaign_sha256", None)
    campaign["campaign_sha256"] = canonical_hash(campaign)
    atomic_write_json(campaign_dir / "campaign.json", campaign)
    print(json.dumps({"decoded": len(statuses) - failures, "incomplete": failures}, indent=2))
    return 0 if failures == 0 else 1


def _add_code_translation_path(repo_root: Path) -> None:
    code_dir = repo_root / "code_translation"
    if str(code_dir) not in sys.path:
        sys.path.insert(0, str(code_dir))


def _selected_compile_variant_index(
    name: str, layout: Mapping[str, Any], variant_count: int
) -> int:
    compile_record = layout.get("compile") or {}
    selected = (
        compile_record.get("selected_variant")
        if isinstance(compile_record, Mapping)
        else None
    )
    selected = _unwrap(selected)
    if selected is None:
        if variant_count == 1:
            return 0
        raise ValidationError(
            f"{name} has {variant_count} compile variants and the frozen campaign "
            "does not identify selected_variant"
        )
    try:
        index = int(selected)
    except (TypeError, ValueError) as exc:
        raise ValidationError(f"{name} has invalid selected_variant={selected!r}") from exc
    if not 0 <= index < variant_count:
        raise ValidationError(
            f"{name} selected_variant={index} is outside 0..{variant_count - 1}"
        )
    if variant_count > 1:
        selection = (
            compile_record.get("selected_variant_selection")
            if isinstance(compile_record, Mapping)
            else None
        )
        if not isinstance(selection, Mapping):
            raise ValidationError(
                f"{name} has {variant_count} compile variants but its frozen "
                "selected_variant has no source-audited selection contract"
            )
        if selection.get("index") != index or not selection.get("reason"):
            raise ValidationError(
                f"{name} compile variant selection contract does not attest "
                f"selected_variant={index}"
            )
    return index


def _isolate_staged_compile_variant(
    commands_path: Path, *, selected_index: int
) -> dict[str, Any]:
    """Rewrite a work copy to one frozen compile variant and its host runs.

    The canonical script remains untouched.  Run lines are associated with the
    most recent ``cslc`` command, which is the command-bundle convention used
    by the active sweep.  The runner can then retain its fail-closed rule that
    an executable bundle contains exactly one compile command.
    """

    text = commands_path.read_text(encoding="utf-8", errors="ignore")
    logical: list[str] = []
    pending = ""
    for raw in text.splitlines():
        stripped = raw.strip()
        if stripped.endswith("\\"):
            pending += stripped[:-1].strip() + " "
            continue
        line = (pending + stripped).strip()
        pending = ""
        if line:
            logical.append(line)
    compile_index = -1
    selected_compile: str | None = None
    selected_runs: list[str] = []
    for line in logical:
        try:
            tokens = shlex.split(line)
        except ValueError:
            continue
        if tokens and Path(tokens[0]).name == "cslc":
            compile_index += 1
            if compile_index == selected_index:
                selected_compile = line
            continue
        if (
            compile_index == selected_index
            and tokens
            and Path(tokens[0]).name == "cs_python"
            and len(tokens) >= 2
            and Path(tokens[1]).name == "run.py"
        ):
            selected_runs.append(line)
    if selected_compile is None:
        raise ValidationError(
            f"cannot isolate compile variant {selected_index} in {commands_path}"
        )
    if not selected_runs:
        raise ValidationError(
            f"compile variant {selected_index} in {commands_path} has no associated run.py"
        )
    isolated = "#!/usr/bin/env bash\nset -e\n" + selected_compile + "\n" + "\n".join(selected_runs) + "\n"
    commands_path.write_text(isolated, encoding="utf-8")
    return {
        "selected_index": selected_index,
        "compile_command": selected_compile,
        "run_commands": selected_runs,
        "isolated_script_sha256": hash_file(commands_path),
    }


def _stage_one_bundle(
    name: str,
    layout: Mapping[str, Any],
    *,
    repo_root: Path,
    campaign_dir: Path,
) -> tuple[dict[str, Any] | None, dict[str, Any]]:
    kernel = dict(layout.get("kernel") or {})
    csl_rel = kernel.get("csl_dir")
    if not csl_rel:
        return None, {"kernel": name, "status": "error", "reason": "inventory has no csl_dir"}
    source = (repo_root / str(csl_rel)).resolve()
    canonical_variants = parse_compile_commands(source / "commands_wse3.sh")
    selected_variant_index = _selected_compile_variant_index(
        name, layout, len(canonical_variants)
    )
    canonical_variant = canonical_variants[selected_variant_index]
    compile_record = layout.get("compile") or {}
    selection_contract = (
        dict(compile_record.get("selected_variant_selection") or {})
        if isinstance(compile_record, Mapping)
        else {}
    )
    layout_hashes = dict(layout.get("hashes") or {})
    is_artifact_bound = isinstance(compile_record, Mapping) and isinstance(
        compile_record.get("artifact_binding"), Mapping
    )
    # A bound layout contains two different source identities: the immutable
    # canonical SDK-1.4 bundle and the exact staged SDK-2.10 source that was
    # compiled.  Only the former may select the stage directory.  Treating the
    # latter as canonical recursively ports the generated bundle and changes
    # both source_hash and request_key after ``inventory --bind-artifacts``.
    if is_artifact_bound and (
        "canonical_source_sha256" not in layout_hashes
        or "canonical_artifacts_sha256" not in layout_hashes
    ):
        raise ValidationError(
            f"{name} bound layout predates canonical hash-lineage metadata; "
            "rerun inventory --bind-artifacts before replanning the suite"
        )
    inventory_hash = str(
        layout_hashes.get("canonical_source_sha256")
        or layout_hashes.get("source_sha256")
        or hash_tree(source)
    )
    adapter_generator_hash = endpoint_adapter_generator_hash()
    staging_generator_hash = canonical_hash(
        {
            "staging_generator_version": STAGING_GENERATOR_VERSION,
            "adapter_generator_sha256": adapter_generator_hash,
            "compile_variant_isolation": "source-audited-frozen-selection-v2",
        }
    )
    target = (
        campaign_dir
        / "work"
        / "bundles"
        / safe_name(name)
        / f"{inventory_hash[:16]}-{staging_generator_hash[:16]}-v{selected_variant_index}"
    )
    stage_metadata_path = campaign_dir / "work" / "stages" / f"{safe_name(name)}.json"
    adapter = None
    if target.exists():
        adapter = validated_adapter_manifest(target)
        staged_hash = str(adapter["source_hash_after"])
    else:
        target.parent.mkdir(parents=True, exist_ok=True)
        temporary_parent = Path(tempfile.mkdtemp(prefix=f".{safe_name(name)}-", dir=target.parent))
        temporary = temporary_parent / "bundle"
        try:
            _add_code_translation_path(repo_root)
            staged = stage_bundle(source, temporary, sdk210_port=True)
            variant_contract = _isolate_staged_compile_variant(
                staged / "commands_wse3.sh", selected_index=selected_variant_index
            )
            variant_contract.update(
                {
                    "canonical_variant_count": len(canonical_variants),
                    "selection": "source_audited_frozen_campaign_variant",
                    "selection_contract": selection_contract,
                    "canonical_compile_command_sha256": canonical_hash(
                        canonical_variant["command"]
                    ),
                }
            )
            atomic_write_json(
                staged / ".wse3study_compile_variant.json", variant_contract
            )
            # Appliance uploads only the bundle, so vendor any ../benchmark-libs
            # dependency before hashing and instrumentation.
            import hw_vs_sim  # type: ignore

            hw_vs_sim.vendor_benchmark_libs(staged)
            adapter_result = reinstrument_host_bracketed_bundle(staged)
            if adapter_result.status == "needs_override":
                raise ValidationError(
                    f"device-internal adapter needs override for launcher "
                    f"{adapter_result.launcher!r}: {adapter_result.reason}"
                )
            staged_hash = adapter_result.source_hash_after
            adapter = load_json(staged / ".wse3study_adapter.json")
            staged.rename(target)
        except BaseException:
            shutil.rmtree(temporary_parent, ignore_errors=True)
            raise
        else:
            shutil.rmtree(temporary_parent, ignore_errors=True)
    staged_variants = parse_compile_commands(target / "commands_wse3.sh")
    if len(staged_variants) != 1:
        raise ValidationError(
            f"staged {name} has {len(staged_variants)} active cslc commands; "
            "variant selection is ambiguous"
        )
    variant_manifest_path = target / ".wse3study_compile_variant.json"
    variant_contract = load_json(variant_manifest_path)
    if not isinstance(variant_contract, Mapping):
        raise ValidationError(f"staged {name} has no compile variant contract")
    staged_compile_command_hash = canonical_hash(staged_variants[0]["command"])
    canonical_artifacts_hash = (
        layout_hashes.get("canonical_artifacts_sha256")
        if is_artifact_bound
        else layout_hashes.get("artifacts_sha256")
    )
    # Existing campaigns used the frozen canonical compiler-artifact digest as
    # their compile seed.  Preserve that real, recorded value across evidence
    # enrichment.  Bundles without frozen artifacts instead use an explicit
    # hash of the staged source and selected compiler command.
    if canonical_artifacts_hash:
        request_compile_hash = str(canonical_artifacts_hash)
        request_compile_hash_basis = "canonical_compiler_artifacts_sha256"
    else:
        request_compile_hash = canonical_hash(
            {
                "staged_source_sha256": staged_hash,
                "staged_compile_command_sha256": staged_compile_command_hash,
                "compile_variant_index": selected_variant_index,
                "sdk_target": "2.10.x",
            }
        )
        request_compile_hash_basis = "staged_compiler_inputs_sha256"
    stage_metadata = {
        "kernel": name,
        "canonical_bundle": str(source),
        "canonical_source_hash": inventory_hash,
        "staged_bundle": str(target),
        "staged_source_hash": staged_hash,
        "adapter_generator_sha256": adapter_generator_hash,
        "staging_generator_version": STAGING_GENERATOR_VERSION,
        "staging_generator_sha256": staging_generator_hash,
        "canonical_compile_variant_count": len(canonical_variants),
        "compile_variant_count": 1,
        "compile_variant_index": selected_variant_index,
        "compile_variant_selection": "source_audited_frozen_campaign_variant",
        "compile_variant_selection_contract": selection_contract,
        "compile_variant_manifest": str(variant_manifest_path),
        "compile_variant_manifest_sha256": hash_file(variant_manifest_path),
        "staged_compile_command_sha256": staged_compile_command_hash,
        "canonical_compile_command_sha256": canonical_hash(
            canonical_variant["command"]
        ),
        "canonical_artifacts_sha256": canonical_artifacts_hash,
        "request_compile_hash": request_compile_hash,
        "request_compile_hash_basis": request_compile_hash_basis,
        "adapter": adapter or {"status": "native_device_internal"},
        "sdk_target": "2.10.x",
        "generated_at": utc_now(),
    }
    prior_stage = load_json(stage_metadata_path)
    if (
        isinstance(prior_stage, Mapping)
        and prior_stage.get("staged_bundle")
        and prior_stage.get("staged_bundle") != stage_metadata["staged_bundle"]
    ):
        prior_identity = canonical_hash(
            {
                "staged_bundle": prior_stage.get("staged_bundle"),
                "canonical_source_hash": prior_stage.get("canonical_source_hash"),
                "staging_generator_sha256": prior_stage.get(
                    "staging_generator_sha256"
                ),
                "compile_variant_index": prior_stage.get("compile_variant_index"),
            }
        )
        history_path = (
            stage_metadata_path.parent
            / "history"
            / safe_name(name)
            / f"{prior_identity[:24]}.json"
        )
        if not history_path.exists():
            atomic_write_json(history_path, prior_stage)
    atomic_write_json(stage_metadata_path, stage_metadata)
    entry = copy.deepcopy(dict(layout))
    entry.setdefault("kernel", {})["csl_dir"] = str(target)
    entry["variant"] = str(
        canonical_variant.get("output") or f"compile-{selected_variant_index}"
    )
    entry.setdefault("hashes", {})["source_sha256"] = staged_hash
    entry["hashes"]["staged_compile_command_sha256"] = staged_compile_command_hash
    entry["hashes"]["compile_request_sha256"] = request_compile_hash
    # Explicit request fields prevent bound compiler-output hashes from being
    # mistaken for the next request's source or compile identity.
    entry["source_hash"] = staged_hash
    entry["compile_hash"] = request_compile_hash
    entry["configuration"] = {
        "kernel_dir": str(target),
        "stage_manifest": str(stage_metadata_path),
        "compile_variant_index": selected_variant_index,
        "artifact_store": str(campaign_dir / "artifacts"),
    }
    return entry, stage_metadata


def _parse_csv_option(values: Sequence[str] | str) -> tuple[str, ...]:
    if isinstance(values, str):
        values = [values]
    result = []
    for value in values:
        result.extend(item.strip() for item in value.split(",") if item.strip())
    return tuple(dict.fromkeys(result))


def _command_run_suite(args: argparse.Namespace) -> int:
    campaign_dir = _campaign_path(args.campaign)
    campaign = _load_campaign(campaign_dir)
    repo_root = Path(campaign.get("repo_root") or args.repo_root).expanduser().resolve()
    arms = _parse_csv_option(args.arms)
    if args.execute and "hardware" in arms and not args.confirm_hardware:
        raise ValidationError("hardware execution requires --confirm-hardware")
    staged_entries = []
    stages: dict[str, Any] = {}
    for name, layout in _kernel_layouts(campaign, args.kernel or ()):
        try:
            entry, stage = _stage_one_bundle(
                name, layout, repo_root=repo_root, campaign_dir=campaign_dir
            )
        except Exception as exc:
            entry, stage = None, {
                "kernel": name,
                "status": "error",
                "reason": f"{type(exc).__name__}: {exc}",
            }
        stages[name] = stage
        if entry is not None:
            staged_entries.append(entry)
    requests = make_suite_requests(
        staged_entries,
        campaign_id=str(campaign.get("campaign_id") or campaign_dir.name),
        repo_root=repo_root,
        arms=arms,
        telemetry_levels=("endpoint",),
    )
    full_telemetry: dict[str, Any] = {}
    full_entries: list[dict[str, Any]] = []
    override_root = campaign_dir / "work" / "full-telemetry-overrides"
    for entry in staged_entries:
        kernel = dict(entry.get("kernel") or {})
        staged_name = str(kernel.get("name") or "unknown")
        bundle = Path(str(kernel.get("csl_dir"))).resolve()
        override_path = override_root / f"{safe_name(staged_name)}.json"
        if not override_path.is_file():
            write_full_telemetry_override_template(
                bundle, override_path, compiled_inventory=entry
            )
        override = load_json(override_path)
        if (
            isinstance(override, Mapping)
            and override.get("bundle_source_hash") != str(
                (entry.get("hashes") or {}).get("source_sha256") or ""
            )
            and is_pristine_full_telemetry_override(override)
        ):
            history = (
                override_root
                / "history"
                / f"{safe_name(staged_name)}-{canonical_hash(override)[:16]}.json"
            )
            if not history.is_file():
                atomic_write_json(history, override)
            write_full_telemetry_override_template(
                bundle, override_path, compiled_inventory=entry
            )
            override = load_json(override_path)
        materialization = (
            override.get("materialization") if isinstance(override, Mapping) else None
        )
        if (
            isinstance(override, Mapping)
            and isinstance(materialization, Mapping)
            and materialization.get("status") == "ready_to_materialize"
        ):
            override_hash = canonical_hash(override)
            generator_hash = full_telemetry_generator_hash()
            parent_hash = str((entry.get("hashes") or {}).get("source_sha256") or "")
            full_bundle = (
                campaign_dir
                / "work"
                / "full-telemetry-bundles"
                / safe_name(staged_name)
                / f"{parent_hash[:16]}-{override_hash[:16]}-{generator_hash[:12]}"
            )
            try:
                audit = materialize_full_telemetry_adapter(bundle, override, full_bundle)
            except Exception as exc:
                audit = {
                    "status": "needs_override",
                    "errors": [f"{type(exc).__name__}: {exc}"],
                    "telemetry_level": "full",
                    "evidence": "inferred",
                    "compile_required": True,
                }
            if audit.get("status") == "ready_for_compile":
                full_entry = copy.deepcopy(entry)
                full_entry.setdefault("kernel", {})["csl_dir"] = str(full_bundle)
                full_entry.setdefault("hashes", {})["source_sha256"] = str(
                    audit["source_hash_after"]
                )
                full_entry["hashes"]["compile_command_sha256"] = canonical_hash(
                    {
                        "staged_source_hash": audit["source_hash_after"],
                        "compile": full_entry.get("compile"),
                        "sdk": "2.10.x",
                        "telemetry_level": "full",
                        "override_sha256": audit["override_sha256"],
                        "generator_sha256": audit["generator_sha256"],
                    }
                )
                full_stage_path = (
                    campaign_dir
                    / "work"
                    / "full-telemetry-stages"
                    / f"{safe_name(staged_name)}-{override_hash[:16]}-{generator_hash[:12]}.json"
                )
                atomic_write_json(
                    full_stage_path,
                    {
                        "kernel": staged_name,
                        "telemetry_level": "full",
                        "endpoint_parent": str(bundle),
                        "endpoint_source_hash": parent_hash,
                        "full_bundle": str(full_bundle),
                        "full_source_hash": audit["source_hash_after"],
                        "override": str(override_path),
                        "override_sha256": audit["override_sha256"],
                        "generator_sha256": audit["generator_sha256"],
                        "compile_command_sha256": full_entry["hashes"][
                            "compile_command_sha256"
                        ],
                        "adapter_manifest": str(
                            full_bundle / ".wse3study_full_adapter.json"
                        ),
                        "status": "ready_for_compile",
                        "generated_at": utc_now(),
                    },
                )
                full_entry["configuration"] = {
                    **dict(full_entry.get("configuration") or {}),
                    "kernel_dir": str(full_bundle),
                    "stage_manifest": str(full_stage_path),
                    "endpoint_parent": str(bundle),
                    "full_adapter_manifest": str(
                        full_bundle / ".wse3study_full_adapter.json"
                    ),
                    "full_override_sha256": audit["override_sha256"],
                    "full_generator_sha256": audit["generator_sha256"],
                }
                full_entries.append(full_entry)
        else:
            audit = validate_full_telemetry_override(bundle, override_path)
        full_telemetry[staged_name] = {
            **audit,
            "override": str(override_path),
        }
    requests.extend(
        make_suite_requests(
            full_entries,
            campaign_id=str(campaign.get("campaign_id") or campaign_dir.name),
            repo_root=repo_root,
            arms=arms,
            telemetry_levels=("full",),
        )
    )
    atomic_write_json(
        campaign_dir / "suite_requests.json",
        {
            "generated_at": utc_now(),
            "arms": list(arms),
            "requests": [request.to_dict() for request in requests],
            "stages": stages,
            "full_telemetry": {
                "status": (
                    "ready_for_compile"
                    if full_telemetry
                    and all(record["status"] == "ready_for_compile" for record in full_telemetry.values())
                    else "needs_override"
                ),
                "per_kernel": full_telemetry,
                "materialized_request_count": len(full_entries),
                "reason": (
                    "full telemetry uses a separately hashed request after every explicit phase, "
                    "SDK sync resource, export, and correctness contract passes source audit; "
                    "execution remains gated on compile, numerical correctness, and D2H schema evidence"
                ),
            },
        },
    )
    report = preflight(targets=arms, execute=args.execute)
    atomic_write_json(campaign_dir / "preflight.json", report.to_dict())
    if args.execute:
        report.require_ok()
        with HwVsSimRunner(port_to_sdk210=False) as runner:
            summary = run_requests(
                requests,
                runner,
                campaign_dir / "ledger.jsonl",
                execute=True,
                resume=not args.no_resume,
                preflight_report=report,
            )
    else:
        summary = run_requests(
            requests,
            None,
            campaign_dir / "ledger.jsonl",
            execute=False,
            resume=not args.no_resume,
            preflight_report=report,
        )
    if (campaign_dir / "ledger.jsonl").is_file():
        project_measurements(load_ledger(campaign_dir / "ledger.jsonl"), campaign_dir / "measurements.csv")
    output = summary.to_dict()
    output["staged"] = len(staged_entries)
    output["stage_failures"] = len(stages) - len(staged_entries)
    output["full_telemetry_compile_ready"] = len(full_entries)
    output["full_telemetry_source_failures"] = len(staged_entries) - len(full_entries)
    print(json.dumps(output, indent=2))
    # A partially staged endpoint or full-telemetry sweep is an open campaign
    # failure, even for a dry run. Failure records remain in
    # suite_requests.json; a schedulable subset is never reported as the full
    # active suite.
    return (
        0
        if staged_entries
        and output["stage_failures"] == 0
        and output["full_telemetry_source_failures"] == 0
        and not (args.execute and summary.rejected_events)
        else 1
    )


def _selected_calibration_cases(args: argparse.Namespace):
    cases = all_calibration_cases()
    requested_case_ids = _parse_csv_option(getattr(args, "case", None) or ())
    if requested_case_ids:
        available_case_ids = {case.case_id for case in cases}
        unknown_case_ids = sorted(set(requested_case_ids) - available_case_ids)
        if unknown_case_ids:
            raise ValidationError(
                "unknown calibration case ID(s): " + ", ".join(unknown_case_ids)
            )
        requested_case_id_set = set(requested_case_ids)
        cases = [case for case in cases if case.case_id in requested_case_id_set]
    families = set(_parse_csv_option(args.family or ()))
    if families:
        cases = [case for case in cases if case.family in families]
    if args.limit is not None:
        cases = cases[: args.limit]
    if getattr(args, "warmups", None) is not None:
        if args.warmups < 0:
            raise ValidationError("--warmups must be non-negative")
        cases = [replace(case, warmups=args.warmups) for case in cases]
    if getattr(args, "trials", None) is not None:
        if args.trials < 1:
            raise ValidationError("--trials must be positive")
        cases = [replace(case, trials=args.trials) for case in cases]
    return cases


def _command_calibrate(args: argparse.Namespace) -> int:
    campaign_dir = _campaign_path(args.campaign)
    campaign = _load_campaign(campaign_dir)
    cases = _selected_calibration_cases(args)
    arms = _parse_csv_option(args.arms)
    if args.execute and "hardware" in arms and not args.confirm_hardware:
        raise ValidationError("hardware execution requires --confirm-hardware")

    should_materialize = bool(args.materialize or args.execute)
    materialized: dict[str, dict[str, Any]] = {}
    support: dict[str, dict[str, Any]] = {}
    bundle_root = campaign_dir / "calibration" / "generated-bundles"
    for case in cases:
        decision = support_for_case(case)
        support[case.case_id] = {
            "supported": decision.supported,
            "status": decision.status,
            "template": decision.template,
            "reason": decision.reason,
        }
        if not should_materialize:
            continue
        bundle_root.mkdir(parents=True, exist_ok=True)
        staging_parent = Path(
            tempfile.mkdtemp(prefix=f".{safe_name(case.case_id)}-", dir=bundle_root)
        )
        staging_bundle = staging_parent / "bundle"
        try:
            generated = materialize_calibration_bundle(case, staging_bundle)
            target = (
                bundle_root
                / safe_name(case.case_id)
                / generated.bundle_sha256[:16]
            )
            if target.exists():
                existing = load_json(target / "manifest.json")
                if not isinstance(existing, Mapping) or existing.get(
                    "bundle_sha256"
                ) != generated.bundle_sha256:
                    raise ValidationError(
                        f"generated bundle hash collision or corrupt target: {target}"
                    )
            else:
                target.parent.mkdir(parents=True, exist_ok=True)
                staging_bundle.rename(target)
            generated_manifest = load_json(target / "manifest.json")
        finally:
            shutil.rmtree(staging_parent, ignore_errors=True)
        if not isinstance(generated_manifest, Mapping):
            raise ValidationError(f"invalid generated manifest: {target / 'manifest.json'}")
        materialized[case.case_id] = {
            "path": str(target),
            "case_id": generated.case_id,
            "family": generated.family,
            "status": generated.status,
            "supported": generated.supported,
            "reason": generated.reason,
            "manifest_path": str(target / "manifest.json"),
            "bundle_sha256": generated.bundle_sha256,
            "compile": generated_manifest.get("compile"),
            "sdk": generated_manifest.get("sdk"),
        }

    generator_path = Path(__file__).with_name("calibration_codegen.py")
    template_source_hash = hash_file(generator_path)
    template_compile_hash = canonical_hash(
        {
            "generator_sha256": template_source_hash,
            "architecture": "wse3",
            "sdk": "2.10.x",
        }
    )
    requests = make_calibration_requests(
        cases,
        campaign_id=str(campaign.get("campaign_id") or campaign_dir.name),
        template_source_hash=template_source_hash,
        template_compile_hash=template_compile_hash,
        bundle_dir=bundle_root if should_materialize else None,
        materialized=materialized or None,
        arms=arms,
    )
    requests = [
        replace(
            request,
            configuration={
                **dict(request.configuration),
                "artifact_store": str(campaign_dir / "artifacts"),
            },
        )
        for request in requests
    ]
    manifest = calibration_manifest()
    manifest["selected"] = [case.to_dict() for case in cases]
    manifest["selected_count"] = len(cases)
    manifest["generated_at"] = utc_now()
    manifest["arms"] = list(arms)
    manifest["generator_sha256"] = template_source_hash
    manifest["support"] = support
    manifest["materialized"] = materialized
    manifest["run_requests"] = [request.to_dict() for request in requests]
    atomic_write_json(campaign_dir / "calibration" / "requests.json", manifest)

    preflight_report = preflight(targets=arms, execute=args.execute)
    atomic_write_json(
        campaign_dir / "calibration" / "preflight.json",
        preflight_report.to_dict(),
    )
    if args.execute:
        preflight_report.require_ok()
        with HwVsSimRunner(port_to_sdk210=False) as runner:
            summary = run_requests(
                requests,
                runner,
                campaign_dir / "ledger.jsonl",
                execute=True,
                resume=not args.no_resume,
                preflight_report=preflight_report,
            )
    else:
        summary = run_requests(
            requests,
            None,
            campaign_dir / "ledger.jsonl",
            execute=False,
            resume=not args.no_resume,
            preflight_report=preflight_report,
        )
    if (campaign_dir / "ledger.jsonl").is_file():
        project_measurements(
            load_ledger(campaign_dir / "ledger.jsonl"),
            campaign_dir / "measurements.csv",
        )
    output = summary.to_dict()
    output.update(
        {
            "selected_cases": len(cases),
            "materialized_cases": len(materialized),
            "runnable_cases": sum(record["status"] == "runnable" for record in support.values()),
            "compile_only_cases": sum(record["status"] == "compile_only" for record in support.values()),
            "unsupported_cases": sum(record["status"] == "unsupported" for record in support.values()),
            "manifest": str(campaign_dir / "calibration" / "requests.json"),
        }
    )
    print(json.dumps(output, indent=2))
    return 0 if not (args.execute and summary.rejected_events) else 1


def _command_preflight(args: argparse.Namespace) -> int:
    targets = _parse_csv_option(args.targets)
    report = preflight(targets=targets, execute=args.execute)
    if args.output:
        atomic_write_json(Path(args.output).expanduser().resolve(), report.to_dict())
    print(json.dumps(report.to_dict(), indent=2))
    return 0 if report.ok else 1


def _command_report(args: argparse.Namespace) -> int:
    campaign_dir = _campaign_path(args.campaign)
    ledger_path = campaign_dir / "ledger.jsonl"
    if ledger_path.is_file():
        records = load_ledger(ledger_path)
        project_measurements(records, campaign_dir / "measurements.csv")
        movement = latency_samples(records)
        single = single_pe_samples(records)
        write_jsonl(campaign_dir / "calibration" / "latency_samples.jsonl", movement)
        write_jsonl(campaign_dir / "calibration" / "single_pe_samples.jsonl", single)
        atomic_write_json(campaign_dir / "models" / "single_pe_model.json", analyze_single_pe(single))
    report = generate_report(campaign_dir, args.output)
    print(report)
    return 0


def _add_common(subparser: argparse.ArgumentParser, *, repo: bool = True) -> None:
    subparser.add_argument("--campaign", default=str(DEFAULT_CAMPAIGN))
    if repo:
        subparser.add_argument("--repo-root", default=str(DEFAULT_REPO_ROOT))


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="wse3study",
        description="Evidence-labelled WSE-3 spatial and data-movement characterization",
    )
    commands = parser.add_subparsers(dest="command", required=True)

    from .gemm_viz import command as gemm_viz_command
    viz = commands.add_parser("viz-export", help="export a tiny GEMM numerical/dataflow viewer bundle")
    viz.add_argument("--scene", choices=("all", "g0", "g1", "g2"), default="all")
    viz.add_argument("--captures", type=Path, help="directory containing completed g0/g1/g2 history/control captures")
    viz.add_argument("--out", type=Path, required=True)
    viz.set_defaults(handler=gemm_viz_command)

    inventory = commands.add_parser("inventory", help="freeze active kernels and compiled layouts")
    _add_common(inventory)
    inventory.add_argument("--campaign-id")
    inventory.add_argument("--kernel", action="append", help="limit to an active kernel; repeatable")
    inventory.add_argument("--cs-readelf", help="opt-in cs_readelf executable for symbol/bank enrichment")
    inventory.add_argument(
        "--bind-artifacts",
        action="store_true",
        help="safely bind retained compiler archives to frozen suite requests",
    )
    inventory.add_argument(
        "--artifact-root",
        help="retained artifact store (default: <campaign>/artifacts)",
    )
    inventory.add_argument(
        "--refresh",
        action="store_true",
        help="archive and replace the freeze only when source/compile identity changed",
    )
    inventory.add_argument("--no-svg", action="store_true")
    inventory.set_defaults(handler=_command_inventory)

    trace = commands.add_parser("trace", help="decode retained simulator CTF artifacts")
    _add_common(trace)
    artifact_mode = trace.add_mutually_exclusive_group()
    artifact_mode.add_argument(
        "--discover-artifacts",
        action="store_true",
        help="safely correlate retained log-export ZIPs/extractions with ledger job IDs",
    )
    artifact_mode.add_argument(
        "--ingest-artifacts",
        action="store_true",
        help="bind one accepted simulator artifact and cross-check CTF against official csdb logs",
    )
    trace.add_argument("--job-id", help="exact simulator wsjob ID for artifact ingestion")
    trace.add_argument(
        "--event-key",
        help="required when one batched simulator job contains multiple TSC windows",
    )
    trace.add_argument(
        "--artifact-root",
        help="retained artifact store (default: <campaign>/artifacts)",
    )
    trace.add_argument(
        "--output-dir",
        help="artifact-ingestion output directory (or discovery parent directory)",
    )
    trace.add_argument("--all", action="store_true", help="explicit alias for the default all-kernel selection")
    trace.add_argument("--kernel", action="append")
    trace.add_argument("--start-cycle", type=int)
    trace.add_argument("--end-cycle", type=int)
    trace.add_argument("--counter-bits", type=int)
    trace.add_argument("--window-source", default="caller-provided simulator device TSC window")
    trace.add_argument("--include-timeless", action="store_true")
    trace.add_argument("--lenient", action="store_true")
    trace.set_defaults(handler=_command_trace)

    calibrate = commands.add_parser("calibrate", help="plan or run architectural calibration cases")
    _add_common(calibrate, repo=False)
    calibrate.add_argument(
        "--case",
        action="append",
        help=(
            "select an exact calibration case ID; repeat the option or use a "
            "comma-separated list"
        ),
    )
    calibrate.add_argument("--family", action="append")
    calibrate.add_argument("--limit", type=int)
    calibrate.add_argument("--warmups", type=int, help="override the default 5 for explicit controls")
    calibrate.add_argument("--trials", type=int, help="override the default 100 for explicit controls")
    calibrate.add_argument("--materialize", action="store_true")
    calibrate.add_argument("--arms", default="simulator,hardware")
    calibrate.add_argument("--execute", action="store_true")
    calibrate.add_argument("--confirm-hardware", action="store_true")
    calibrate.add_argument("--no-resume", action="store_true")
    calibrate.set_defaults(handler=_command_calibrate)

    suite = commands.add_parser("run-suite", help="stage and run all frozen kernels")
    _add_common(suite)
    suite.add_argument("--kernel", action="append")
    suite.add_argument("--arms", default="simulator,hardware")
    suite.add_argument("--execute", action="store_true")
    suite.add_argument("--confirm-hardware", action="store_true")
    suite.add_argument("--no-resume", action="store_true")
    suite.set_defaults(handler=_command_run_suite)

    report = commands.add_parser("report", help="fit models and generate the technical report")
    _add_common(report, repo=False)
    report.add_argument("--output")
    report.set_defaults(handler=_command_report)

    check = commands.add_parser("preflight", help="inspect simulator/hardware execution prerequisites")
    check.add_argument("--targets", default="simulator,hardware")
    check.add_argument("--execute", action="store_true", help="treat missing requirements as errors")
    check.add_argument("--output", help="write the preflight report as JSON")
    check.set_defaults(handler=_command_preflight)
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    try:
        return int(args.handler(args))
    except (ValidationError, FileNotFoundError, ValueError) as exc:
        parser.exit(2, f"error: {exc}\n")


__all__ = ["build_parser", "main"]
