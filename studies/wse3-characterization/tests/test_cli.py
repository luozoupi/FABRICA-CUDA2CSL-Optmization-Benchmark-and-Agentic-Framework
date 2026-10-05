from __future__ import annotations

import copy
import json
import io
import sys
import tempfile
import unittest
from contextlib import redirect_stderr
from pathlib import Path

STUDY_ROOT = Path(__file__).resolve().parents[1]
REPO_ROOT = STUDY_ROOT.parents[1]
sys.path.insert(0, str(STUDY_ROOT))

from wse3study.cli import (  # noqa: E402
    _freeze_identity,
    _isolate_staged_compile_variant,
    _selected_compile_variant_index,
    _stage_one_bundle,
    _trace_qualification,
    main,
)
from wse3study.campaign import make_suite_requests  # noqa: E402
from wse3study.inventory import (  # noqa: E402
    build_campaign_inventory,
    parse_compile_commands,
)
from wse3study.schema import hash_file  # noqa: E402
from wse3study.trace import TraceWindow  # noqa: E402


class CliTests(unittest.TestCase):
    def test_inventory_bind_replan_preserves_stage_and_request_identity(self) -> None:
        canonical = build_campaign_inventory(
            REPO_ROOT, only=["ReLU-1PE"]
        )["kernels"]["ReLU-1PE"]
        with tempfile.TemporaryDirectory() as directory:
            campaign = Path(directory) / "campaign"
            first_entry, first_stage = _stage_one_bundle(
                "ReLU-1PE",
                canonical,
                repo_root=REPO_ROOT,
                campaign_dir=campaign,
            )
            self.assertIsNotNone(first_entry)

            # Model the hash enrichment performed by a qualified compiler
            # artifact binding: the current source/output hashes change, while
            # the canonical inventory lineage remains explicit.
            bound = copy.deepcopy(canonical)
            original_hashes = dict(canonical["hashes"])
            bound["hashes"].update(
                {
                    "canonical_source_sha256": original_hashes["source_sha256"],
                    "canonical_compile_command_sha256": original_hashes[
                        "compile_command_sha256"
                    ],
                    "canonical_artifacts_sha256": original_hashes[
                        "artifacts_sha256"
                    ],
                    "canonical_inventory_sha256": original_hashes[
                        "inventory_sha256"
                    ],
                    "source_sha256": first_stage["staged_source_hash"],
                    "compile_command_sha256": "retained-compile-command",
                    "artifacts_sha256": "retained-compiler-archive",
                }
            )
            bound["compile"]["artifact_binding"] = {
                "status": "qualified",
                "evidence": "compiled",
            }
            second_entry, second_stage = _stage_one_bundle(
                "ReLU-1PE",
                bound,
                repo_root=REPO_ROOT,
                campaign_dir=campaign,
            )
            self.assertIsNotNone(second_entry)

            first_requests = make_suite_requests(
                [first_entry],
                campaign_id="identity-regression",
                repo_root=REPO_ROOT,
                arms=("simulator", "hardware"),
            )
            second_requests = make_suite_requests(
                [second_entry],
                campaign_id="identity-regression",
                repo_root=REPO_ROOT,
                arms=("simulator", "hardware"),
            )
            self.assertEqual(
                first_stage["canonical_source_hash"],
                second_stage["canonical_source_hash"],
            )
            self.assertEqual(
                first_stage["staged_bundle"], second_stage["staged_bundle"]
            )
            self.assertEqual(
                first_stage["staged_source_hash"],
                second_stage["staged_source_hash"],
            )
            self.assertEqual(
                first_stage["request_compile_hash"],
                second_stage["request_compile_hash"],
            )
            self.assertEqual(
                [request.request_key for request in first_requests],
                [request.request_key for request in second_requests],
            )

    def test_multi_variant_bundle_is_isolated_by_frozen_selection(self) -> None:
        layout = {
            "compile": {
                "selected_variant": 1,
                "selected_variant_selection": {
                    "index": 1,
                    "reason": "active registry target maps to variant 1",
                },
            }
        }
        self.assertEqual(1, _selected_compile_variant_index("FFT", layout, 2))
        with tempfile.TemporaryDirectory() as directory:
            commands = Path(directory) / "commands_wse3.sh"
            commands.write_text(
                "#!/usr/bin/env bash\n"
                "cslc layout.csl --params=DIM:1 -o out-1d\n"
                "cs_python run.py --name out-1d\n"
                "cs_python run.py --inverse --name out-1d\n"
                "cslc layout.csl --params=DIM:2 -o out-2d\n"
                "cs_python run.py --name out-2d\n",
                encoding="utf-8",
            )
            contract = _isolate_staged_compile_variant(commands, selected_index=1)
            variants = parse_compile_commands(commands)
            self.assertEqual(1, len(variants))
            self.assertEqual("out-2d", variants[0]["output"])
            self.assertEqual(["cs_python run.py --name out-2d"], contract["run_commands"])
            self.assertNotIn("out-1d", commands.read_text(encoding="utf-8"))

    def test_multi_variant_selection_fails_closed_without_frozen_index(self) -> None:
        with self.assertRaisesRegex(Exception, "does not identify selected_variant"):
            _selected_compile_variant_index("FFT", {"compile": {}}, 2)

    def test_multi_variant_selection_fails_closed_without_source_contract(self) -> None:
        with self.assertRaisesRegex(Exception, "source-audited selection contract"):
            _selected_compile_variant_index(
                "FFT", {"compile": {"selected_variant": 1}}, 2
            )

    def test_inventory_binding_mode_is_read_only_when_artifact_store_is_empty(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            campaign = Path(directory) / "campaign"
            status = main(
                [
                    "inventory",
                    "--campaign",
                    str(campaign),
                    "--repo-root",
                    str(REPO_ROOT),
                    "--kernel",
                    "ReLU-1PE",
                    "--bind-artifacts",
                    "--no-svg",
                ]
            )
            self.assertEqual(0, status)
            manifest = json.loads((campaign / "campaign.json").read_text())
            self.assertEqual(0, manifest["artifact_binding"]["records_scanned"])
            self.assertEqual(0, manifest["counts"]["campaign_qualified"])

    def test_trace_acceptance_binds_stream_source_compile_layout_and_window(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            trace_dir = Path(directory)
            (trace_dir / "stream0").write_bytes(b"stream")
            (trace_dir / "metadata").write_text("metadata", encoding="utf-8")
            layout = {
                "acceptance_qualification": {"status": "qualified"},
                "hashes": {
                    "source_sha256": "source",
                    "compile_command_sha256": "compile",
                },
            }
            manifest = {
                "source_sha256": "source",
                "compile_command_sha256": "compile",
                "sdk_version": "2.10.1",
                "fabric_dimensions": [762, 1172],
                "stream0_sha256": hash_file(trace_dir / "stream0"),
                "metadata_sha256": hash_file(trace_dir / "metadata"),
                "device_tsc_window": {
                    "start_cycle": 10,
                    "end_cycle": 20,
                    "counter_bits": None,
                },
            }
            (trace_dir / ".wse3study_trace_manifest.json").write_text(
                json.dumps(manifest), encoding="utf-8"
            )
            qualification = _trace_qualification(
                trace_dir, layout, window=TraceWindow(10, 20)
            )
            self.assertEqual("qualified", qualification["status"])
            (trace_dir / "stream0").write_bytes(b"changed")
            qualification = _trace_qualification(
                trace_dir, layout, window=TraceWindow(10, 20)
            )
            self.assertEqual("unqualified", qualification["status"])
            self.assertTrue(any("stream0" in reason for reason in qualification["reasons"]))

    def test_inventory_and_calibration_plan(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            campaign = Path(directory) / "campaign"
            status = main(
                [
                    "inventory",
                    "--campaign",
                    str(campaign),
                    "--repo-root",
                    str(REPO_ROOT),
                    "--kernel",
                    "ReLU-1PE",
                    "--no-svg",
                ]
            )
            self.assertEqual(0, status)
            manifest = json.loads((campaign / "campaign.json").read_text())
            self.assertEqual(1, manifest["counts"]["discovered"])
            self.assertEqual(manifest["freeze_sha256"], _freeze_identity(manifest))
            manifest["freeze_sha256"] = "different-frozen-source"
            (campaign / "campaign.json").write_text(
                json.dumps(manifest), encoding="utf-8"
            )
            with self.assertRaises(SystemExit) as rejected_refresh:
                main(
                    [
                        "inventory",
                        "--campaign",
                        str(campaign),
                        "--repo-root",
                        str(REPO_ROOT),
                        "--kernel",
                        "ReLU-1PE",
                        "--no-svg",
                    ]
                )
            self.assertEqual(2, rejected_refresh.exception.code)
            manifest["freeze_sha256"] = _freeze_identity(manifest)
            (campaign / "campaign.json").write_text(
                json.dumps(manifest), encoding="utf-8"
            )
            status = main(
                [
                    "calibrate",
                    "--campaign",
                    str(campaign),
                    "--family",
                    "straight",
                    "--limit",
                    "3",
                ]
            )
            self.assertEqual(0, status)
            calibration = json.loads((campaign / "calibration" / "requests.json").read_text())
            self.assertEqual(3, calibration["selected_count"])

    def test_calibration_exact_case_selector_is_repeatable_and_precedes_limit(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            campaign = Path(directory) / "campaign"
            campaign.mkdir()
            (campaign / "campaign.json").write_text(
                json.dumps({"campaign_id": "exact-case-test"}), encoding="utf-8"
            )
            status = main(
                [
                    "calibrate",
                    "--campaign",
                    str(campaign),
                    "--case",
                    "contention-s1-distinct-q6-m1-d0-8dbde7e8",
                    "--case",
                    "straight-north-h1-p1,straight-south-h1-p1",
                    "--limit",
                    "2",
                ]
            )
            self.assertEqual(0, status)
            calibration = json.loads(
                (campaign / "calibration" / "requests.json").read_text()
            )
            self.assertEqual(2, calibration["selected_count"])
            selected_ids = [record["case_id"] for record in calibration["selected"]]
            self.assertEqual(
                ["straight-north-h1-p1", "straight-south-h1-p1"], selected_ids
            )

            status = main(
                [
                    "calibrate",
                    "--campaign",
                    str(campaign),
                    "--case",
                    "contention-s1-distinct-q6-m1-d0-8dbde7e8",
                    "--limit",
                    "1",
                ]
            )
            self.assertEqual(0, status)
            calibration = json.loads(
                (campaign / "calibration" / "requests.json").read_text()
            )
            self.assertEqual(
                ["contention-s1-distinct-q6-m1-d0-8dbde7e8"],
                [record["case_id"] for record in calibration["selected"]],
            )

    def test_calibration_exact_case_selector_rejects_unknown_id(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            campaign = Path(directory) / "campaign"
            campaign.mkdir()
            (campaign / "campaign.json").write_text(
                json.dumps({"campaign_id": "unknown-case-test"}), encoding="utf-8"
            )
            stderr = io.StringIO()
            with redirect_stderr(stderr), self.assertRaises(SystemExit) as rejected:
                main(
                    [
                        "calibrate",
                        "--campaign",
                        str(campaign),
                        "--case",
                        "not-a-real-calibration-case",
                    ]
                )
            self.assertEqual(2, rejected.exception.code)
            self.assertIn(
                "unknown calibration case ID(s): not-a-real-calibration-case",
                stderr.getvalue(),
            )


if __name__ == "__main__":
    unittest.main()
