from __future__ import annotations

import json
import gzip
import hashlib
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from wse3study.report import _measurement_summary, generate_report  # noqa: E402
from wse3study.schema import canonical_hash, hash_file  # noqa: E402
from wse3study.telemetry import append_measurements  # noqa: E402


def _write_qualified_trace(kernel_dir: Path) -> None:
    events = kernel_dir / "events.jsonl.gz"
    events.write_bytes(gzip.compress(b'{"event_type":"hwm_pipe_trace_entry"}\n', mtime=0))
    digest = hashlib.sha256(events.read_bytes()).hexdigest()
    (kernel_dir / "trace_summary.json").write_text(
        json.dumps(
            {
                "status": "decoded",
                "acceptance_qualification": {"status": "qualified", "reasons": []},
                "trace_integrity": {"status": "complete", "discarded_events": 0},
                "source": {"stream0_sha256": "stream", "metadata_sha256": "metadata"},
                "event_counts": {"hwm_pipe_trace_entry": 1},
                "events_sha256": digest,
            }
        ),
        encoding="utf-8",
    )


def _write_qualified_trace_ingest_control(
    root: Path,
    *,
    raw_events: int,
    window_events: int,
    wavelet_events: int,
    pe_count: int,
) -> Path:
    job_id = "wsjob-dynamic-control"
    event_key = "event-dynamic-0123456789"
    target = root / "artifacts" / "trace-ingest" / job_id / "event-dynamic"
    target.mkdir(parents=True)
    window = {
        "start_cycle": 100,
        "end_cycle": 200,
        "crop_event_count": window_events,
        "crop_stats": {
            "seen": raw_events,
            "kept": window_events,
            "excluded_before": raw_events - window_events,
            "excluded_after": 0,
            "excluded_timeless": 0,
        },
        "evidence": "simulator",
    }
    binding = {
        "schema_version": "1.0.0",
        "record_type": "bound-simulator-trace-artifact",
        "status": "qualified",
        "job_id": job_id,
        "event_key": event_key,
        "subject": "dynamic-control",
        "source_sha256": "source-hash",
        "compile_request_sha256": "compile-request-hash",
        "compile_identity_sha256": "compile-identity-hash",
        "compiler_artifact_sha256": "compiler-artifact-hash",
        "device_tsc_window": window,
        "trace": {
            "raw_event_count": raw_events,
            "discarded_event_count": 0,
            "stream0_sha256": "stream-hash",
            "metadata_sha256": "metadata-hash",
        },
        "evidence": "simulator",
        "limitations": "This simulator artifact is not a silicon wavelet trace.",
    }
    binding["binding_sha256"] = canonical_hash(binding)
    binding_path = target / "binding.json"
    binding_path.write_text(json.dumps(binding), encoding="utf-8")

    counts = [wavelet_events // pe_count] * pe_count
    for index in range(wavelet_events % pe_count):
        counts[index] += 1
    per_pe = [
        {
            "simulator": {"x": index, "y": 0},
            "ctf_wavelet_events": count,
            "csdb_wavelet_events": count,
            "match": True,
            "evidence": "simulator",
        }
        for index, count in enumerate(counts)
    ]
    crosscheck = {
        "schema_version": "1.0.0",
        "record_type": "ctf-vs-official-csdb-wavelet-crosscheck",
        "status": "match",
        "binding_sha256": binding["binding_sha256"],
        "job_id": job_id,
        "event_key": event_key,
        "comparison_scope": "raw full simulator session; no TSC crop",
        "ctf": {
            "event_count": wavelet_events,
            "discarded_events": 0,
            "stream0_sha256": "stream-hash",
            "metadata_sha256": "metadata-hash",
            "evidence": "simulator",
        },
        "csdb": {
            "event_count": wavelet_events,
            "file_count": pe_count,
            "evidence": "simulator",
        },
        "total_match": True,
        "per_pe_match": True,
        "per_pe": per_pe,
        "evidence": "simulator",
        "acceptance_qualification": {"status": "qualified", "reasons": []},
        "limitations": "The simulator csdb Link column remains a raw uninterpreted field.",
    }
    crosscheck_path = target / "csdb_crosscheck.json"
    crosscheck_path.write_text(json.dumps(crosscheck), encoding="utf-8")
    manifest = {
        "schema_version": "1.0.0",
        "record_type": "wse3study-bound-simulator-trace-manifest",
        "status": "qualified",
        "binding": str(binding_path),
        "binding_sha256": hash_file(binding_path),
        "csdb_crosscheck": str(crosscheck_path),
        "csdb_crosscheck_sha256": hash_file(crosscheck_path),
        "source_sha256": binding["source_sha256"],
        "compile_request_sha256": binding["compile_request_sha256"],
        "compile_identity_sha256": binding["compile_identity_sha256"],
        "compiler_artifact_sha256": binding["compiler_artifact_sha256"],
        "stream0_sha256": binding["trace"]["stream0_sha256"],
        "metadata_sha256": binding["trace"]["metadata_sha256"],
        "device_tsc_window": window,
        "evidence": "simulator",
        "limitations": binding["limitations"],
    }
    manifest_path = target / "trace_manifest.json"
    manifest_path.write_text(json.dumps(manifest), encoding="utf-8")
    return target


class ReportTests(unittest.TestCase):
    def test_report_summarizes_qualified_trace_ingest_control_from_artifacts(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "campaign.json").write_text(
                json.dumps({"campaign_id": "test", "kernels": []}),
                encoding="utf-8",
            )
            _write_qualified_trace_ingest_control(
                root,
                raw_events=137,
                window_events=11,
                wavelet_events=23,
                pe_count=4,
            )

            text = generate_report(root).read_text(encoding="utf-8")
            self.assertIn("## Qualified simulator trace-ingest controls", text)
            self.assertIn("`wsjob-dynamic-control`", text)
            self.assertIn("`event-dynamic-0123456789`", text)
            self.assertIn("| 137 | 11 | 23 | 23 | 4 | exact total + per-PE |", text)
            self.assertIn("simulator evidence only, not silicon traces", text)
            self.assertIn("`Link` column remains raw", text)

            payload = json.loads((root / "report.json").read_text())
            summary = payload["simulator_trace_controls"]
            self.assertEqual(1, summary["qualified_count"])
            self.assertEqual(0, summary["excluded_count"])
            control = summary["controls"][0]
            self.assertEqual(137, control["raw_ctf_events"])
            self.assertEqual(11, control["tsc_window_events"])
            self.assertEqual(23, control["ctf_wavelet_events"])
            self.assertEqual(23, control["csdb_wavelet_events"])
            self.assertEqual(4, control["pe_count"])
            self.assertEqual("simulator", control["evidence"])
            self.assertTrue(control["total_match"])
            self.assertTrue(control["per_pe_match"])
            self.assertIn("Link", " ".join(control["limitations"]))

    def test_report_excludes_trace_control_when_crosscheck_is_inconsistent(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "campaign.json").write_text(
                json.dumps({"campaign_id": "test", "kernels": []}),
                encoding="utf-8",
            )
            target = _write_qualified_trace_ingest_control(
                root,
                raw_events=50,
                window_events=5,
                wavelet_events=8,
                pe_count=2,
            )
            crosscheck_path = target / "csdb_crosscheck.json"
            crosscheck = json.loads(crosscheck_path.read_text())
            crosscheck["per_pe"][0]["csdb_wavelet_events"] += 1
            crosscheck_path.write_text(json.dumps(crosscheck), encoding="utf-8")
            manifest_path = target / "trace_manifest.json"
            manifest = json.loads(manifest_path.read_text())
            manifest["csdb_crosscheck_sha256"] = hash_file(crosscheck_path)
            manifest_path.write_text(json.dumps(manifest), encoding="utf-8")

            text = generate_report(root).read_text(encoding="utf-8")
            payload = json.loads((root / "report.json").read_text())
            summary = payload["simulator_trace_controls"]
            self.assertEqual(0, summary["qualified_count"])
            self.assertEqual(1, summary["excluded_count"])
            self.assertEqual([], summary["controls"])
            reasons = " ".join(summary["excluded"][0]["reasons"])
            self.assertIn("not an exact match", reasons)
            self.assertIn("fail-closed exclusions: **1**", text)

    def test_per_pe_endpoints_report_skew_and_critical_pe(self) -> None:
        summary = _measurement_summary(
            [
                {
                    "kernel": "Kernel-A",
                    "arm": "hardware",
                    "evidence": "silicon",
                    "run_id": "run-0",
                    "telemetry_level": "endpoint",
                    "phase": "compute_end",
                    "fabric_x": x,
                    "fabric_y": 0,
                    "elapsed_cycles": cycles,
                    "timing_method": "device_internal_synchronized",
                    "correctness": True,
                    "source_hash": "source",
                    "job_id": "job",
                    "artifact_id": "artifact",
                }
                for x, cycles in ((0, 100), (1, 125))
            ]
        )
        stats = summary["accepted"]["Kernel-A\0hardware"]
        self.assertEqual(125, stats["median"])
        self.assertEqual(25, stats["per_pe_skew_cycles"]["median"])
        self.assertEqual("fabric(1,0)", stats["critical_pe"])

    def test_report_keeps_evidence_completeness_visible(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "campaign.json").write_text(
                json.dumps({"campaign_id": "test", "kernels": [{"name": "Kernel-A"}]}),
                encoding="utf-8",
            )
            kernel_dir = root / "kernels" / "Kernel-A"
            kernel_dir.mkdir(parents=True)
            (kernel_dir / "layout.json").write_text(
                json.dumps(
                    {
                        "validation": {"status": "ok"},
                        "acceptance_qualification": {"status": "qualified", "reasons": []},
                        "counts": {
                            "application_allocated": {"value": 4, "evidence": "compiled"},
                            "io_loaded": {"value": 2, "evidence": "compiled"},
                            "dynamically_active": {"value": 4, "evidence": "simulator"},
                        },
                        "route_edges": [{"evidence": "compiled"}, {"evidence": "compiled"}],
                    }
                ),
                encoding="utf-8",
            )
            _write_qualified_trace(kernel_dir)
            append_measurements(
                root / "measurements.csv",
                [
                    {
                        "kernel": "Kernel-A",
                        "arm": "hardware",
                        "evidence": "silicon",
                        "trial": trial,
                        "warmup": False,
                        "elapsed_cycles": 1000 + trial,
                        "timing_method": "device_internal",
                        "correctness": True,
                        "telemetry_level": "endpoint",
                        "run_id": f"run-{trial}",
                        "source_hash": "abc123",
                        "job_id": "job-42",
                        "artifact_id": "artifact-42",
                    }
                    for trial in range(30)
                ]
                + [
                    {
                        "kernel": "Kernel-A",
                        "arm": "simulator",
                        "evidence": "simulator",
                        "trial": trial,
                        "warmup": False,
                        "elapsed_cycles": 900 + trial,
                        "timing_method": "device_internal",
                        "correctness": True,
                        "telemetry_level": "endpoint",
                        "run_id": f"sim-run-{trial}",
                        "source_hash": "abc123",
                    }
                    for trial in range(30)
                ],
            )
            report = generate_report(root)
            text = report.read_text(encoding="utf-8")
            self.assertIn("1/1", text)
            self.assertIn("Kernel-A", text)
            self.assertIn("spatial MIMD", text)
            self.assertIn("SDK 2.10/full-fabric campaign-qualified layouts: **1/1**", text)
            self.assertIn("Source/compile/window-qualified detailed traces: **1/1**", text)
            self.assertIn("source-bound aggregate simulator trials: **1/1**", text)
            self.assertIn("4 (compiled)", text)

    def test_missing_trace_and_simulator_trials_do_not_satisfy_hardware(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "campaign.json").write_text(
                json.dumps({"campaign_id": "test", "kernels": [{"name": "Kernel-A"}]}),
                encoding="utf-8",
            )
            kernel_dir = root / "kernels" / "Kernel-A"
            kernel_dir.mkdir(parents=True)
            (kernel_dir / "layout.json").write_text(
                json.dumps({"validation": {"status": "partial"}, "counts": {}}),
                encoding="utf-8",
            )
            (kernel_dir / "trace_summary.json").write_text(
                json.dumps({"status": "missing"}), encoding="utf-8"
            )
            append_measurements(
                root / "measurements.csv",
                [
                    {
                        "kernel": "Kernel-A",
                        "arm": "simulator",
                        "evidence": "simulator",
                        "trial": trial,
                        "warmup": False,
                        "elapsed_cycles": 1000 + trial,
                        "timing_method": "device_internal",
                        "correctness": True,
                    }
                    for trial in range(30)
                ],
            )
            report = generate_report(root)
            text = report.read_text(encoding="utf-8")
            self.assertIn("SDK 2.10/full-fabric campaign-qualified layouts: **0/1**", text)
            self.assertIn("Source/compile/window-qualified detailed traces: **0/1**", text)
            self.assertIn("At least 30 unique, provenance-complete silicon trials: **0/1**", text)

    def test_duplicate_phase_rows_cannot_inflate_unique_hardware_trials(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "campaign.json").write_text(
                json.dumps({"campaign_id": "test", "kernels": [{"name": "Kernel-A"}]}),
                encoding="utf-8",
            )
            kernel_dir = root / "kernels" / "Kernel-A"
            kernel_dir.mkdir(parents=True)
            (kernel_dir / "layout.json").write_text(
                json.dumps(
                    {
                        "validation": {"status": "ok"},
                        "acceptance_qualification": {"status": "qualified", "reasons": []},
                        "counts": {},
                        "route_edges": [],
                    }
                ),
                encoding="utf-8",
            )
            _write_qualified_trace(kernel_dir)
            append_measurements(
                root / "measurements.csv",
                [
                    {
                        "kernel": "Kernel-A",
                        "arm": "hardware",
                        "evidence": "silicon",
                        "trial": 0,
                        "run_id": "only-one-run",
                        "phase": "compute_end",
                        "warmup": False,
                        "elapsed_cycles": 1000,
                        "timing_method": "device_internal",
                        "correctness": True,
                        "telemetry_level": "endpoint",
                        "source_hash": "abc123",
                        "job_id": "job-42",
                        "artifact_id": "artifact-42",
                    }
                    for _ in range(30)
                ],
            )
            text = generate_report(root).read_text(encoding="utf-8")
            self.assertIn("| 1 | 1 | 1000", text)
            self.assertIn("silicon trials: **0/1**", text)

    def test_calibration_control_is_reported_outside_kernel_acceptance(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "campaign.json").write_text(
                json.dumps({"campaign_id": "test", "kernels": [{"name": "Kernel-A"}]}),
                encoding="utf-8",
            )
            append_measurements(
                root / "measurements.csv",
                [
                    {
                        "kernel": "straight-north-h1-p1",
                        "arm": arm,
                        "evidence": evidence,
                        "trial": 0,
                        "run_id": f"{arm}-0",
                        "warmup": False,
                        "elapsed_cycles": cycles,
                        "timer_validated": True,
                        "timing_method": "device_internal_synchronized",
                        "correctness": True,
                        "telemetry_level": "endpoint",
                        "source_hash": "same-source",
                        "job_id": "job" if arm == "hardware" else "",
                        "artifact_id": "artifact" if arm == "hardware" else "",
                    }
                    for arm, evidence, cycles in (
                        ("simulator", "simulator", 37),
                        ("hardware", "silicon", 46),
                    )
                ],
            )
            text = generate_report(root).read_text(encoding="utf-8")
            self.assertIn("## Calibration control measurements", text)
            self.assertIn("| straight-north-h1-p1 | 1 | 1 | 37.0 | 46.0 |", text)
            report_json = json.loads((root / "report.json").read_text())
            self.assertEqual(1, len(report_json["calibration_controls"]))

    def test_report_separates_execution_readiness_from_accepted_evidence(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "campaign.json").write_text(
                json.dumps(
                    {
                        "campaign_id": "test",
                        "kernels": [{"name": "Ready"}, {"name": "Blocked"}],
                    }
                ),
                encoding="utf-8",
            )
            (root / "suite_requests.json").write_text(
                json.dumps(
                    {
                        "stages": {
                            "Ready": {
                                "staged_bundle": "/study/ready",
                                "adapter": {
                                    "status": "instrumented",
                                    "mode": "verified_native",
                                },
                            },
                            "Blocked": {"status": "error", "reason": "ambiguous timer"},
                        },
                        "full_telemetry": {
                            "per_kernel": {
                                "Ready": {"status": "ready_for_compile"},
                                "Blocked": {"status": "needs_override"},
                            }
                        },
                        "requests": [
                            {"warmups": 3, "trials": 30},
                            {"warmups": 3, "trials": 30},
                        ],
                    }
                ),
                encoding="utf-8",
            )
            calibration_dir = root / "calibration"
            calibration_dir.mkdir()
            (calibration_dir / "requests.json").write_text(
                json.dumps(
                    {
                        "support": {
                            "run": {"status": "runnable"},
                            "probe": {"status": "compile_only"},
                            "blocked": {"status": "unsupported"},
                        },
                        "requests": [{"warmups": 5, "trials": 100}],
                    }
                ),
                encoding="utf-8",
            )
            (root / "service-preflight.json").write_text(
                json.dumps(
                    {
                        "ok": True,
                        "detected": {
                            "fabric_dims": [762, 1172],
                            "versions": {
                                "cerebras-sdk": "2.10.0",
                                "cerebras-appliance": "2.10.0",
                            },
                        },
                    }
                ),
                encoding="utf-8",
            )

            text = generate_report(root).read_text(encoding="utf-8")
            self.assertIn("## Execution readiness", text)
            self.assertIn("endpoint adapters staged: **1/2**", text)
            self.assertIn("sources compile-ready: **1/2**", text)
            self.assertIn("execution-ready after compile", text)
            self.assertIn("gates: **0/2**", text)
            self.assertIn("| Blocked | ambiguous timer |", text)
            self.assertIn("No paired endpoint/full telemetry observations", text)
            payload = json.loads((root / "report.json").read_text())
            self.assertEqual(1, payload["execution_readiness"]["endpoint_staged"])
            self.assertEqual(
                1,
                payload["execution_readiness"]["full_telemetry_compile_ready"],
            )
            self.assertEqual(
                0,
                payload["execution_readiness"]["full_telemetry_execution_ready"],
            )
            self.assertEqual(66, payload["execution_readiness"]["suite_planned_events"])
            self.assertEqual(
                {"compile_only": 1, "runnable": 1, "unsupported": 1},
                payload["execution_readiness"]["calibration_statuses"],
            )

    def test_report_reads_current_calibration_run_requests_schema(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "campaign.json").write_text(
                json.dumps({"campaign_id": "test", "kernels": []}),
                encoding="utf-8",
            )
            calibration_dir = root / "calibration"
            calibration_dir.mkdir()
            support = {
                **{
                    f"run-{index}": {"status": "runnable"}
                    for index in range(633)
                },
                **{
                    f"probe-{index}": {"status": "compile_only"}
                    for index in range(15)
                },
                **{
                    f"blocked-{index}": {"status": "unsupported"}
                    for index in range(104)
                },
            }
            # Each runnable case has two 5-warmup/100-trial arms.  Compile-only
            # and unsupported cases have two one-event arms, matching the
            # frozen 752-case characterization campaign.
            run_requests = [
                {"warmups": 5, "trials": 100} for _ in range(633 * 2)
            ] + [{"warmups": 0, "trials": 1} for _ in range((15 + 104) * 2)]
            (calibration_dir / "requests.json").write_text(
                json.dumps(
                    {
                        "support": support,
                        "run_requests": run_requests,
                        # A stale legacy field must not override the current
                        # manifest schema.
                        "requests": [],
                    }
                ),
                encoding="utf-8",
            )

            text = generate_report(root).read_text(encoding="utf-8")
            self.assertIn(
                "Calibration plan: **752** cases, statuses "
                "`{\"compile_only\": 15, \"runnable\": 633, "
                "\"unsupported\": 104}`, **1504** arm requests, and "
                "**133168** planned events.",
                text,
            )
            payload = json.loads((root / "report.json").read_text())
            readiness = payload["execution_readiness"]
            self.assertEqual(1504, readiness["calibration_arm_requests"])
            self.assertEqual(133168, readiness["calibration_planned_events"])


if __name__ == "__main__":
    unittest.main()
