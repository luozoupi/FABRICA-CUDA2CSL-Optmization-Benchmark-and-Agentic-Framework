from __future__ import annotations

import sys
import tempfile
import unittest
import json
import subprocess
from collections import Counter
from pathlib import Path

_STUDY_ROOT = Path(__file__).resolve().parents[1]
if str(_STUDY_ROOT) not in sys.path:
    sys.path.insert(0, str(_STUDY_ROOT))

from wse3study.calibration import (
    CALIBRATION_TRIALS,
    CALIBRATION_WARMUPS,
    CalibrationCase,
    calibration_manifest,
    data_movement_cases,
    single_pe_cases,
)
from wse3study.campaign import (
    SUITE_TRIALS,
    SUITE_WARMUPS,
    HwVsSimRunner,
    RunRequest,
    _atomic_verified_artifact_copy,
    load_ledger,
    make_calibration_requests,
    make_suite_requests,
    preflight,
    run_requests,
    save_ledger,
    validated_adapter_manifest,
    validate_result,
)
from wse3study.instrumentation import (
    ADAPTER_SCHEMA_VERSION,
    endpoint_adapter_generator_hash,
)
from wse3study.schema import EvidenceKind, ValidationError, hash_file, hash_tree


def request(**overrides):
    values = {
        "campaign_id": "campaign-a",
        "subject": "ParReduce-Sum",
        "kind": "suite",
        "arm": "hardware",
        "source_hash": "source-abc",
        "compile_hash": "compile-def",
        "configuration": {"kernel_dir": "/frozen/bundle", "width": 8},
        "warmups": 2,
        "trials": 3,
    }
    values.update(overrides)
    return RunRequest(**values)


class FakeRunner:
    def __init__(self, result=None):
        self.calls = []
        self.result = result or {
            "status": "pass",
            "elapsed_cycles": 1000,
            "timing_method": "device_internal_synchronized",
            "correctness": True,
            "job_id": "wsjob-fake",
            "sdk_version": "2.10.0",
        }
        self.provenance = {"runner": "fake", "client_version": "2.10.0"}

    def run(self, run_request, *, trial_index, warmup):
        self.calls.append((run_request.request_key, warmup, trial_index))
        return {**self.result, "trial_from_runner": trial_index}


class FakeBatchRunner(FakeRunner):
    def __init__(self, result=None, *, limit=None):
        super().__init__(result=result)
        self.batch_calls = []
        self.limit = limit

    def run_batch(self, run_request, *, events):
        self.batch_calls.append((run_request.request_key, tuple(events)))
        selected = events if self.limit is None else events[: self.limit]
        return {
            run_request.event_key(warmup=warmup, trial=trial): {
                **self.result,
                "warmup": warmup,
                "trial": trial,
                "batch_id": "batch-fake",
                "batch_size": len(events),
                "batch_ordinal": ordinal,
                "batch_completed": self.limit is None,
            }
            for ordinal, (warmup, trial) in enumerate(selected)
        }


class CampaignExecutionTests(unittest.TestCase):
    def test_suite_batch_driver_runs_endpoint_postlude_inside_shared_runtime(self):
        with tempfile.TemporaryDirectory() as temporary:
            bundle = Path(temporary)
            (bundle / "run.py").write_text("print('SUCCESS')\n", encoding="utf-8")
            postlude = bundle / ".wse3study_endpoint_postlude.py"
            postlude.write_text("print('cycles_send = 123 cycles')\n", encoding="utf-8")
            (bundle / ".wse3study_adapter.json").write_text(
                json.dumps({"d2h": {"postlude": postlude.name}}),
                encoding="utf-8",
            )
            source = HwVsSimRunner._suite_batch_driver_source(
                artifact="artifact",
                simulator=True,
                bundle=bundle,
                run_argv=(),
                events=(("event", False, 0),),
            )
            self.assertIn(str(postlude), source)
            self.assertIn('init_globals={"runner": shared}', source)
            self.assertLess(source.index("runpy.run_path(RUNPY_PATH"), source.index("POSTLUDE_PATH,"))

    def test_runner_rejects_implicit_selection_of_multiple_compile_variants(self):
        with tempfile.TemporaryDirectory() as temporary:
            commands = Path(temporary) / "commands_wse3.sh"
            commands.write_text(
                "cslc layout.csl --arch=wse3 -o out-a\n"
                "cslc layout.csl --arch=wse3 -o out-b\n",
                encoding="utf-8",
            )
            with self.assertRaisesRegex(ValidationError, "2 active cslc commands"):
                HwVsSimRunner._single_compile_variant(commands, "FFT-1D-2D")

    def test_calibration_runner_forces_one_sample_per_ledger_event(self):
        argv = HwVsSimRunner._calibration_run_argv(
            [
                "--name",
                "out",
                "--warmups=5",
                "--trials",
                "100",
                "--output",
                "old.jsonl",
            ],
            output_path=Path("event.jsonl"),
        )
        self.assertEqual(
            argv,
            [
                "--name",
                "out",
                "--warmups",
                "0",
                "--trials",
                "1",
                "--output",
                "event.jsonl",
            ],
        )
        simulator_argv = HwVsSimRunner._calibration_run_argv(
            ["--name", "out"],
            output_path=Path("event.jsonl"),
            simulator=True,
        )
        self.assertIn("--simulator", simulator_argv)
        compact = HwVsSimRunner._effective_cslc_args(
            "--arch=wse3 --fabric-dims=762,1172 --fabric-offsets=4,1",
            simulator=True,
            simulator_fabric_dims=(9, 4),
        )
        self.assertIn("--fabric-dims=9,4", compact)
        hardware = HwVsSimRunner._effective_cslc_args(
            "--fabric-dims=9,4", simulator=False
        )
        self.assertIn("--fabric-dims=762,1172", hardware)

        batch = HwVsSimRunner._calibration_batch_run_argv(
            [
                "--name",
                "out",
                "--warmups=5",
                "--trials",
                "100",
                "--output=old.jsonl",
                "--event-plan",
                "old-events.json",
            ],
            output_path=Path("batch.jsonl"),
            event_plan_path=Path("batch-events.json"),
            simulator=True,
        )
        self.assertEqual(
            batch,
            [
                "--name",
                "out",
                "--event-plan",
                "batch-events.json",
                "--output",
                "batch.jsonl",
                "--simulator",
            ],
        )

    def test_batch_runner_uses_one_call_and_checkpoints_every_event(self):
        with tempfile.TemporaryDirectory() as temporary:
            ledger = Path(temporary) / "ledger.jsonl"
            run_request = request()
            runner = FakeBatchRunner()
            summary = run_requests(
                [run_request], runner, ledger, execute=True
            )

            self.assertEqual(len(runner.batch_calls), 1)
            self.assertEqual(len(runner.batch_calls[0][1]), 5)
            self.assertEqual(runner.calls, [])
            self.assertEqual(summary.executed_events, 5)
            self.assertEqual(summary.accepted_events, 5)
            self.assertEqual(summary.pending_events, 0)
            self.assertEqual(summary.runner_batch_calls, 1)
            self.assertEqual(summary.runner_single_event_calls, 0)
            self.assertEqual(summary.batched_events, 5)
            records = load_ledger(ledger)
            self.assertEqual(len(records), 5)
            self.assertEqual(
                {(row["warmup"], row["trial"]) for row in records},
                {(True, 0), (True, 1), (False, 0), (False, 1), (False, 2)},
            )
            self.assertTrue(
                all(row["provenance"]["batch_id"] == "batch-fake" for row in records)
            )

    def test_batch_partial_output_checkpoints_prefix_and_resume_retries_open_events(self):
        with tempfile.TemporaryDirectory() as temporary:
            ledger = Path(temporary) / "ledger.jsonl"
            run_request = request(warmups=1, trials=4)
            partial = FakeBatchRunner(limit=2)
            first = run_requests(
                [run_request], partial, ledger, execute=True
            )
            self.assertEqual(first.accepted_events, 2)
            self.assertEqual(first.rejected_events, 1)
            self.assertEqual(first.executed_events, 3)
            self.assertEqual(first.pending_events, 3)

            resumed_runner = FakeBatchRunner()
            resumed = run_requests(
                [run_request], resumed_runner, ledger, execute=True, resume=True
            )
            self.assertEqual(resumed.resumed_events, 2)
            self.assertEqual(len(resumed_runner.batch_calls), 1)
            self.assertEqual(len(resumed_runner.batch_calls[0][1]), 3)
            self.assertEqual(resumed.pending_events, 0)

            missing_key = run_request.event_key(warmup=False, trial=1)
            attempts = [
                row["attempt"]
                for row in load_ledger(ledger)
                if row["event_key"] == missing_key
            ]
            self.assertEqual(attempts, [1, 2])

    def test_batch_runner_single_pending_event_uses_legacy_api(self):
        with tempfile.TemporaryDirectory() as temporary:
            ledger = Path(temporary) / "ledger.jsonl"
            run_request = request(warmups=0, trials=1)
            runner = FakeBatchRunner()
            summary = run_requests(
                [run_request], runner, ledger, execute=True
            )
            self.assertEqual(summary.accepted_events, 1)
            self.assertEqual(runner.batch_calls, [])
            self.assertEqual(len(runner.calls), 1)
            self.assertEqual(summary.runner_batch_calls, 0)
            self.assertEqual(summary.runner_single_event_calls, 1)

    def test_suite_batch_driver_reuses_one_runtime_and_is_valid_python(self):
        run_request = request()
        source = HwVsSimRunner._suite_batch_driver_source(
            artifact="/tmp/wsjob-fake.tar.gz",
            simulator=False,
            bundle=Path("/tmp/frozen-bundle"),
            run_argv=["--name", "out"],
            events=[
                (
                    run_request.event_key(warmup=True, trial=0),
                    True,
                    0,
                ),
                (
                    run_request.event_key(warmup=False, trial=0),
                    False,
                    0,
                ),
            ],
        )
        compile(source, "<suite-batch-driver>", "exec")
        self.assertEqual(source.count("ApplianceRuntime("), 1)
        self.assertIn("class SharedRuntime", source)
        self.assertIn("WSE3STUDY_BATCH_EVENT=", source)

    def test_suite_batch_driver_executes_two_hosts_on_one_runtime(self):
        with tempfile.TemporaryDirectory() as temporary:
            bundle = Path(temporary)
            client = bundle / "cerebras" / "sdk" / "client.py"
            client.parent.mkdir(parents=True)
            (bundle / "cerebras" / "__init__.py").write_text("")
            (bundle / "cerebras" / "sdk" / "__init__.py").write_text("")
            client.write_text(
                "class SdkRuntime:\n"
                "    def __init__(self, *args, **kwargs): print('APPLIANCE_INIT')\n"
                "    def __enter__(self): print('APPLIANCE_ENTER'); return self\n"
                "    def __exit__(self, *args): print('APPLIANCE_EXIT')\n"
                "    def get_id(self, name): return name\n"
                "    def launch(self, *args, **kwargs): return None\n"
            )
            (bundle / "run.py").write_text(
                "from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime\n"
                "runner = SdkRuntime('ignored')\n"
                "runner.load(); runner.run(); runner.launch('compute')\n"
                "print('cycles_send = 123 cycles')\n"
                "print('SUCCESS')\n"
                "runner.stop()\n"
            )
            run_request = request()
            events = [
                (
                    run_request.event_key(warmup=True, trial=0),
                    True,
                    0,
                ),
                (
                    run_request.event_key(warmup=False, trial=0),
                    False,
                    0,
                ),
            ]
            source = HwVsSimRunner._suite_batch_driver_source(
                artifact=str(bundle / "artifact.tar.gz"),
                simulator=True,
                bundle=bundle,
                run_argv=[],
                events=events,
            )
            driver = bundle / "driver.py"
            driver.write_text(source)
            completed = subprocess.run(
                [sys.executable, str(driver)],
                cwd=bundle,
                capture_output=True,
                text=True,
                check=False,
            )
            self.assertEqual(completed.returncode, 0, completed.stderr)
            self.assertEqual(completed.stdout.count("APPLIANCE_INIT"), 1)
            self.assertEqual(completed.stdout.count("APPLIANCE_ENTER"), 1)
            self.assertEqual(completed.stdout.count("APPLIANCE_EXIT"), 1)
            matches = HwVsSimRunner._BATCH_EVENT_RE.findall(completed.stdout)
            self.assertEqual(len(matches), 2)
            decoded = [json.loads(value) for value in matches]
            self.assertTrue(all(row["cycles_send"] == 123 for row in decoded))
            self.assertTrue(all(row["success_marker"] for row in decoded))

    def test_calibration_batch_maps_streamed_rows_to_exact_events(self):
        class FakeHwVsSim:
            def __init__(self):
                self.calls = []

            def run_arm(self, bundle, artifact, simulator, argv, timeout_s):
                self.calls.append((bundle, artifact, simulator, argv, timeout_s))
                output = Path(argv[argv.index("--output") + 1])
                plan_path = Path(argv[argv.index("--event-plan") + 1])
                rows = []
                for ordinal, event in enumerate(json.loads(plan_path.read_text())):
                    rows.append(
                        {
                            **event,
                            "status": "pass",
                            "elapsed_cycles": 37 + ordinal,
                            "correctness": True,
                            "timer_enabled": True,
                            "start_words_u16": [100 + ordinal, 0, 0],
                            "end_words_u16": [137 + 2 * ordinal, 0, 0],
                            "synchronization_protocol": "sdk-bandwidth-test",
                            "evidence": "simulator" if simulator else "silicon",
                        }
                    )
                output.write_text(
                    "".join(json.dumps(row) + "\n" for row in rows),
                    encoding="utf-8",
                )
                return {
                    "status": "rejected_dead_timer",
                    "returncode": 0,
                    "success_marker": True,
                    "reason": "generic legacy floor",
                    "stdout_tail": "SUCCESS",
                    "stderr_tail": "runtime wsjob-REDACTED",
                }

        fake = FakeHwVsSim()

        class OfflineRunner(HwVsSimRunner):
            @staticmethod
            def _helpers():
                return object(), fake

        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            run_request = request(
                kind="calibration",
                arm="simulator",
                warmups=2,
                trials=3,
            )
            context = {
                "bundle": root,
                "artifact": str(root / "artifact.tar.gz"),
                "artifact_original": str(root / "artifact.tar.gz"),
                "artifact_preserved": None,
                "artifact_sha256": "artifact-hash",
                "artifact_bytes": 123,
                "simulator": True,
                "run_argv": ["--name", "out", "--warmups", "5", "--trials=100"],
                "compiler_args": "--arch=wse3",
                "fabric_dims": [9, 4],
                "source_hash_verified": run_request.source_hash,
                "compiled_bundle_hash": "bundle-hash",
                "compile_identity_hash": "compile-identity",
                "adapter_manifest": None,
                "generated_manifest": {"status": "runnable"},
            }
            events = tuple(
                [(True, 0), (True, 1), (False, 0), (False, 1), (False, 2)]
            )
            results = OfflineRunner()._run_calibration_batch(
                run_request, context, events, conditioning_warmups=2
            )

            self.assertEqual(len(fake.calls), 1)
            self.assertEqual(len(results), 5)
            plan_path = Path(
                fake.calls[0][3][fake.calls[0][3].index("--event-plan") + 1]
            )
            plan = json.loads(plan_path.read_text())
            self.assertEqual(len(plan), 7)
            self.assertTrue(all(row["conditioning"] for row in plan[:2]))
            for warmup, trial in events:
                row = results[
                    run_request.event_key(warmup=warmup, trial=trial)
                ]
                self.assertEqual(row["warmup"], warmup)
                self.assertEqual(row["trial"], trial)
                self.assertEqual(row["status"], "pass")
                self.assertEqual(row["job_id"], "wsjob-REDACTED")
                self.assertTrue(row["batch_completed"])
                self.assertEqual(row["batch_conditioning_warmups"], 2)
                self.assertEqual(row["batch_runtime_iterations"], 7)

    def test_calibration_batch_attributes_empty_structured_output_to_first_event(self):
        class FakeHwVsSim:
            def run_arm(self, bundle, artifact, simulator, argv, timeout_s):
                return {
                    "status": "fail",
                    "returncode": 1,
                    "success_marker": False,
                    "reason": "generated host exited before telemetry export",
                    "stdout_tail": "",
                    "stderr_tail": "runtime failure wsjob-REDACTED",
                    "artifact_path": artifact,
                }

        fake = FakeHwVsSim()

        class OfflineRunner(HwVsSimRunner):
            @staticmethod
            def _helpers():
                return object(), fake

        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            run_request = request(
                kind="calibration",
                arm="simulator",
                warmups=1,
                trials=2,
            )
            context = {
                "bundle": root,
                "artifact": str(root / "artifact.tar.gz"),
                "artifact_original": str(root / "artifact.tar.gz"),
                "artifact_preserved": None,
                "artifact_sha256": "artifact-hash",
                "artifact_bytes": 123,
                "simulator": True,
                "run_argv": ["--name", "out"],
                "compiler_args": "--arch=wse3 --fabric-dims=9,4",
                "fabric_dims": [9, 4],
                "source_hash_verified": run_request.source_hash,
                "compiled_bundle_hash": "bundle-hash",
                "compile_identity_hash": "compile-identity",
                "adapter_manifest": None,
                "generated_manifest": {"status": "runnable"},
            }
            events = ((True, 0), (False, 0), (False, 1))
            results = OfflineRunner()._run_calibration_batch(
                run_request, context, events, conditioning_warmups=2
            )

            first_key = run_request.event_key(warmup=True, trial=0)
            self.assertEqual(set(results), {first_key})
            failure = results[first_key]
            self.assertEqual(failure["status"], "runner_error")
            self.assertEqual(failure["job_id"], "wsjob-REDACTED")
            self.assertEqual(failure["compiler_args"], context["compiler_args"])
            self.assertEqual(failure["fabric_dims"], [9, 4])
            self.assertEqual(failure["batch_size"], 3)
            self.assertEqual(failure["batch_runtime_ordinal"], 2)
            self.assertEqual(failure["batch_runtime_iterations"], 5)
            self.assertEqual(failure["batch_structured_rows"], 0)
            self.assertFalse(failure["batch_completed"])
            self.assertEqual(failure["returncode"], 1)

    def test_compile_exception_ledger_keeps_effective_simulator_fabric(self):
        from wse3study.calibration_codegen import materialize_calibration_bundle

        calibration = CalibrationCase(
            family="straight",
            case_id="straight-north-compile-failure",
            parameters={
                "direction": "north",
                "hops": 1,
                "payload_wavelets": 1,
                "turns": 0,
            },
            warmups=0,
            trials=1,
        )

        class FailingCompiler:
            def __init__(self):
                self.calls = []

            @staticmethod
            def vendor_benchmark_libs(bundle):
                return None

            @staticmethod
            def parse_commands_script(commands):
                return {
                    "csl_main": "layout.csl",
                    "cslc_args": (
                        "--arch=wse3 --fabric-dims=762,1172 "
                        "--fabric-offsets=4,1 -o out"
                    ),
                    "runs": [["run.py", "--name", "out"]],
                    "params": {},
                }

            def compile_arm(self, bundle, csl_main, cslc_args, simulator):
                self.calls.append((bundle, csl_main, cslc_args, simulator))
                raise RuntimeError("synthetic compile failure")

        compiler = FailingCompiler()

        class OfflineRunner(HwVsSimRunner):
            requires_service_preflight = False

            @staticmethod
            def _helpers():
                return object(), compiler

        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            preview = materialize_calibration_bundle(calibration, root / "preview")
            generated_manifest = json.loads(
                Path(preview.manifest_path).read_text(encoding="utf-8")
            )
            expected_dims = generated_manifest["compile"][
                "simulator_fabric_dims"
            ]
            run_request = request(
                subject=calibration.case_id,
                kind="calibration",
                arm="simulator",
                variant="straight",
                source_hash=preview.bundle_sha256,
                compile_hash="generated-compile-identity",
                configuration={
                    "generated_source": True,
                    "calibration_case_spec": calibration.to_dict(),
                    "expected_generated_bundle_sha256": preview.bundle_sha256,
                },
                warmups=0,
                trials=1,
            )
            ledger = root / "ledger.jsonl"
            summary = run_requests(
                [run_request], OfflineRunner(), ledger, execute=True
            )

            self.assertEqual(summary.rejected_events, 1)
            self.assertEqual(len(compiler.calls), 1)
            effective_args = compiler.calls[0][2]
            self.assertIn(
                f"--fabric-dims={expected_dims[0]},{expected_dims[1]}",
                effective_args,
            )
            [record] = load_ledger(ledger)
            self.assertEqual(record["status"], "runner_error")
            self.assertEqual(record["provenance"]["fabric_dims"], expected_dims)
            self.assertEqual(
                record["provenance"]["compiler_args"], effective_args
            )
            self.assertEqual(record["result"]["fabric_dims"], expected_dims)
            self.assertEqual(record["result"]["compile_stage"], "compile_arm")

    def test_production_resume_replays_missing_conditioning_warmups(self):
        class CaptureRunner(HwVsSimRunner):
            def __init__(self):
                super().__init__()
                self.conditioning = None

            def _prepare(self, run_request):
                return {}

            def _run_suite_batch(
                self,
                run_request,
                context,
                events,
                *,
                conditioning_warmups=0,
            ):
                self.conditioning = conditioning_warmups
                return {}

        run_request = request(warmups=3, trials=2)
        runner = CaptureRunner()
        runner.run_batch(run_request, events=((False, 1),))
        self.assertEqual(runner.conditioning, 3)
        runner.run_batch(run_request, events=((True, 2), (False, 0)))
        self.assertEqual(runner.conditioning, 2)

    def test_request_identity_is_hash_keyed_and_campaign_label_independent(self):
        first = request()
        renamed = request(campaign_id="campaign-renamed")
        stored = request(
            configuration={
                "kernel_dir": "/frozen/bundle",
                "width": 8,
                "artifact_store": "/campaign-a/artifacts",
            }
        )
        moved_store = request(
            configuration={
                "kernel_dir": "/frozen/bundle",
                "width": 8,
                "artifact_store": "/campaign-b/artifacts",
            }
        )
        changed_source = request(source_hash="source-changed")
        changed_config = request(
            configuration={"kernel_dir": "/frozen/bundle", "width": 9}
        )
        self.assertEqual(first.request_key, renamed.request_key)
        self.assertEqual(first.request_key, stored.request_key)
        self.assertEqual(stored.request_key, moved_store.request_key)
        self.assertEqual(
            stored.to_dict()["configuration"]["artifact_store"],
            "/campaign-a/artifacts",
        )
        self.assertNotEqual(first.request_key, changed_source.request_key)
        self.assertNotEqual(first.request_key, changed_config.request_key)
        self.assertNotEqual(
            first.event_key(warmup=True, trial=0),
            first.event_key(warmup=False, trial=0),
        )

    def test_artifact_copy_is_atomic_verified_and_repairs_corruption(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            source = root / "compiler" / "artifact.tar.gz"
            destination = root / "retained" / "artifact.tar.gz"
            source.parent.mkdir()
            source.write_bytes((b"compiler-archive\0" * 1024) + b"tail")

            first = _atomic_verified_artifact_copy(source, destination)
            self.assertEqual(destination.read_bytes(), source.read_bytes())
            self.assertEqual(first["artifact_sha256"], hash_file(source))
            self.assertEqual(first["artifact_bytes"], source.stat().st_size)

            destination.write_bytes(b"partial")
            repaired = _atomic_verified_artifact_copy(source, destination)
            self.assertEqual(destination.read_bytes(), source.read_bytes())
            self.assertEqual(repaired, first)
            self.assertEqual(
                list(destination.parent.glob(f".{destination.name}.*")), []
            )

    def test_compile_probe_persists_event_in_operational_artifact_store(self):
        class OfflineRunner(HwVsSimRunner):
            @staticmethod
            def _helpers():
                return object(), object()

        with tempfile.TemporaryDirectory() as temporary:
            artifact_store = Path(temporary) / "artifacts"
            probe = request(
                kind="calibration",
                configuration={
                    "compile_only": True,
                    "allocation_bytes": 50176,
                    "artifact_store": str(artifact_store),
                },
                warmups=0,
                trials=1,
            )
            runner = OfflineRunner()
            runner._prepared[probe.request_key] = {
                "compile_probe": True,
                "compile_success": True,
                "capacity_failure": False,
                "compiler_args": "--arch=wse3",
                "source_hash_verified": probe.source_hash,
                "compiled_bundle_hash": "bundle-hash",
                "compile_identity_hash": "identity-hash",
                "artifact": "/retained/artifact.tar.gz",
                "artifact_original": "/temporary/artifact.tar.gz",
                "artifact_preserved": "/retained/artifact.tar.gz",
                "artifact_sha256": "archive-sha256",
                "artifact_bytes": 1234,
            }

            result = runner.run(probe, trial_index=0, warmup=False)
            self.assertEqual(result["status"], "compile_pass")
            events = list(artifact_store.rglob("events/*.json"))
            self.assertEqual(len(events), 1)
            persisted = json.loads(events[0].read_text(encoding="utf-8"))
            self.assertEqual(persisted["result"]["artifact_sha256"], "archive-sha256")
            self.assertEqual(persisted["result"]["artifact_bytes"], 1234)
            self.assertEqual(
                persisted["request"]["configuration"]["artifact_store"],
                str(artifact_store),
            )

    def test_dry_run_is_default_and_has_no_side_effects(self):
        with tempfile.TemporaryDirectory() as temporary:
            ledger = Path(temporary) / "ledger.jsonl"
            runner = FakeRunner()
            summary = run_requests([request()], runner, ledger)
            self.assertTrue(summary.dry_run)
            self.assertEqual(summary.planned_events, 5)
            self.assertEqual(summary.pending_events, 5)
            self.assertEqual(runner.calls, [])
            self.assertFalse(ledger.exists())

    def test_execute_checkpoints_each_event_and_resume_calls_nothing(self):
        with tempfile.TemporaryDirectory() as temporary:
            ledger = Path(temporary) / "ledger.jsonl"
            runner = FakeRunner()
            run_request = request()
            first = run_requests([run_request], runner, ledger, execute=True)
            self.assertEqual(first.executed_events, 5)
            self.assertEqual(first.accepted_events, 5)
            self.assertEqual(first.pending_events, 0)
            self.assertEqual(len(runner.calls), 5)

            records = load_ledger(ledger)
            self.assertEqual(len(records), 5)
            self.assertTrue(all(record["accepted"] for record in records))
            self.assertTrue(all(record["source_hash"] == "source-abc" for record in records))
            self.assertTrue(all(record["compile_hash"] == "compile-def" for record in records))
            self.assertTrue(
                all(record["provenance"]["job_id"] == "wsjob-fake" for record in records)
            )
            self.assertTrue(
                all(record["provenance"]["sdk_version"] == "2.10.0" for record in records)
            )

            runner.calls.clear()
            resumed = run_requests(
                [run_request], runner, ledger, execute=True, resume=True
            )
            self.assertEqual(resumed.executed_events, 0)
            self.assertEqual(resumed.resumed_events, 5)
            self.assertEqual(resumed.pending_events, 0)
            self.assertEqual(runner.calls, [])

    def test_no_resume_replays_but_preserves_append_only_attempt_numbering(self):
        with tempfile.TemporaryDirectory() as temporary:
            ledger = Path(temporary) / "ledger.jsonl"
            run_request = request(warmups=0, trials=1)
            runner = FakeRunner()
            first = run_requests([run_request], runner, ledger, execute=True)
            replay = run_requests(
                [run_request], runner, ledger, execute=True, resume=False
            )

            self.assertEqual(first.accepted_events, 1)
            self.assertEqual(replay.executed_events, 1)
            self.assertEqual(replay.resumed_events, 0)
            records = load_ledger(ledger)
            self.assertEqual([record["attempt"] for record in records], [1, 2])

    def test_invalid_timing_or_correctness_is_rejected(self):
        cases = (
            (
                {
                    "status": "pass",
                    "elapsed_cycles": 99,
                    "timing_method": "device_internal",
                    "correctness": True,
                },
                "rejected_dead_timer",
            ),
            (
                {
                    "status": "pass",
                    "elapsed_cycles": 1000,
                    "timing_method": "host_launched_tic_toc",
                    "correctness": True,
                },
                "rejected_host_bracketed",
            ),
            (
                {
                    "status": "pass",
                    "elapsed_cycles": 1000,
                    "timing_method": "device_internal",
                    "correctness": False,
                },
                "rejected",
            ),
        )
        for bad_result, expected_status in cases:
            with self.subTest(expected_status=expected_status):
                checked = validate_result(request(), bad_result)
                self.assertFalse(checked.accepted)
                self.assertEqual(checked.status, expected_status)

        calibrated_short_path = validate_result(
            request(kind="calibration"),
            {
                "status": "pass",
                "elapsed_cycles": 37,
                "timing_method": "device_internal_synchronized",
                "correctness": True,
                "timer_enabled": True,
                "start_words_u16": [1671, 0, 0],
                "end_words_u16": [1700, 0, 0],
            },
        )
        self.assertTrue(calibrated_short_path.accepted)
        self.assertTrue(calibrated_short_path.normalized["timer_validated"])

    def test_sram_capacity_failure_is_an_accepted_compiled_observation(self):
        probe = request(
            kind="calibration",
            configuration={"compile_only": True, "allocation_bytes": 50176},
        )
        self.assertEqual(probe.evidence, "compiled")
        checked = validate_result(
            probe,
            {
                "status": "compile_capacity_fail",
                "compile_success": False,
                "capacity_failure": True,
                "compile_probe_valid": True,
            },
        )
        self.assertTrue(checked.accepted)
        self.assertEqual(checked.status, "compile_capacity_fail")

        unrelated = validate_result(
            probe,
            {
                "status": "compile_fail",
                "compile_success": False,
                "capacity_failure": False,
                "compile_probe_valid": False,
            },
        )
        self.assertFalse(unrelated.accepted)

    def test_rejection_blocks_request_and_resume_retries_exact_event(self):
        with tempfile.TemporaryDirectory() as temporary:
            ledger = Path(temporary) / "ledger.jsonl"
            run_request = request(warmups=1, trials=2)
            bad = FakeRunner(
                {
                    "status": "pass",
                    "elapsed_cycles": 12,
                    "timing_method": "device_internal",
                    "correctness": True,
                }
            )
            first = run_requests([run_request], bad, ledger, execute=True)
            self.assertEqual(first.executed_events, 1)
            self.assertEqual(first.rejected_events, 1)
            self.assertEqual(first.pending_events, 3)

            second = run_requests(
                [run_request], FakeRunner(), ledger, execute=True, resume=True
            )
            self.assertEqual(second.executed_events, 3)
            self.assertEqual(second.pending_events, 0)
            records = load_ledger(ledger)
            first_event = run_request.event_key(warmup=True, trial=0)
            attempts = [r for r in records if r["event_key"] == first_event]
            self.assertEqual([record["attempt"] for record in attempts], [1, 2])
            self.assertTrue(attempts[-1]["accepted"])

    def test_save_and_load_ledger_are_jsonl_and_atomic(self):
        with tempfile.TemporaryDirectory() as temporary:
            target = Path(temporary) / "ledger.jsonl"
            records = [
                {"event_key": "one", "accepted": True},
                {"event_key": "two", "accepted": False},
            ]
            save_ledger(target, records)
            self.assertEqual(load_ledger(target), records)
            with self.assertRaises(ValidationError):
                save_ledger(target, [{"accepted": True}])

    def test_instrumented_host_bracket_adapter_is_hash_verified(self):
        with tempfile.TemporaryDirectory() as temporary:
            bundle = Path(temporary)
            source = bundle / "run.py"
            source.write_text('runner.launch("f_tic")\n', encoding="utf-8")
            source_hash = hash_tree(bundle)
            (bundle / ".wse3study_adapter.json").write_text(
                json.dumps(
                    {
                        "status": "instrumented",
                        "adapter_schema_version": ADAPTER_SCHEMA_VERSION,
                        "adapter_generator_sha256": endpoint_adapter_generator_hash(),
                        "source_hash_after": source_hash,
                        "telemetry_levels": ["endpoint"],
                        "timing": {
                            "method": "device_internal",
                            "host_rpc_inside_window": False,
                        },
                        "correctness": {
                            "run_py_unchanged": True,
                            "run_py_sha256": hash_file(source),
                        },
                    }
                ),
                encoding="utf-8",
            )
            manifest = validated_adapter_manifest(bundle)
            self.assertEqual(manifest["source_hash_after"], source_hash)

            source.write_text('runner.launch("f_tic")\n# changed\n', encoding="utf-8")
            with self.assertRaises(ValidationError):
                validated_adapter_manifest(bundle)


class PreflightTests(unittest.TestCase):
    def test_preflight_is_injectable_and_strict_only_for_execution(self):
        good = preflight(
            targets=("simulator", "hardware"),
            execute=True,
            executable=sys.executable,
            which=lambda name: f"/usr/local/bin/{name}",
            version_getter=lambda _: "2.10.7",
            module_finder=lambda _: object(),
            service_probe=lambda: True,
        )
        self.assertTrue(good.ok)

        dry = preflight(
            execute=False,
            executable="/missing/python",
            which=lambda _: None,
            version_getter=lambda _: None,
            module_finder=lambda _: None,
        )
        self.assertTrue(dry.ok)
        self.assertTrue(any(check["status"] == "warning" for check in dry.checks))

        bad = preflight(
            execute=True,
            executable="/missing/python",
            which=lambda _: None,
            version_getter=lambda _: "1.4.0",
            module_finder=lambda _: None,
        )
        self.assertFalse(bad.ok)
        with self.assertRaises(ValidationError):
            bad.require_ok()


class CalibrationMatrixTests(unittest.TestCase):
    def test_calibration_manifest_is_hash_frozen(self):
        first = calibration_manifest()
        second = calibration_manifest()
        self.assertEqual(first["manifest_sha256"], second["manifest_sha256"])
        self.assertEqual(first["counts"]["total"], 752)

    def test_data_movement_matrix_has_full_baseline_and_focused_contention(self):
        cases = data_movement_cases()
        self.assertEqual(
            Counter(case.family for case in cases),
            {"straight": 210, "turn": 32, "multicast": 16, "contention": 43},
        )
        straight = [case for case in cases if case.family == "straight"]
        self.assertEqual(
            {case.parameters["direction"] for case in straight},
            {"north", "south", "east", "west"},
        )
        self.assertTrue(
            all(
                case.parameters["direction"] in {"north", "south"}
                for case in straight
                if case.parameters["hops"] == 1024
            )
        )
        self.assertEqual(
            {case.parameters["payload_wavelets"] for case in straight},
            {1, 8, 64, 512, 4096},
        )
        self.assertTrue(
            all(
                case.split == "validation"
                for case in straight
                if case.parameters["hops"] in {8, 128}
            )
        )

        contention = [case for case in cases if case.family == "contention"]
        self.assertEqual(sum(case.split == "validation" for case in contention), 9)
        self.assertLess(len(contention), 100)
        self.assertEqual(
            {case.parameters["queue_id"] for case in contention}, set(range(8))
        )
        self.assertEqual(
            {case.parameters["microthreads"] for case in contention}, {1, 2, 4, 8}
        )

    def test_single_pe_matrix_covers_curves_and_focused_interactions(self):
        cases = single_pe_cases()
        counts = Counter(case.family for case in cases)
        self.assertEqual(counts["single-pe-throughput"], 360)
        self.assertEqual(counts["single-pe-bank-stride"], 16)
        self.assertEqual(counts["single-pe-chain-thread"], 16)
        self.assertEqual(counts["single-pe-queue-thread"], 16)
        self.assertEqual(counts["single-pe-sram"], 15)
        self.assertEqual(len(cases), 451)
        self.assertTrue(all(case.warmups == CALIBRATION_WARMUPS for case in cases))
        self.assertTrue(all(case.trials == CALIBRATION_TRIALS for case in cases))

        throughput = [case for case in cases if case.family == "single-pe-throughput"]
        self.assertEqual(
            {case.parameters["mode"] for case in throughput}, {"scalar", "dsd"}
        )
        self.assertEqual(
            {case.parameters["vector_length"] for case in throughput},
            {1, 2, 4, 8, 16, 32, 64, 256, 1024, 2048},
        )

    def test_request_builders_apply_approved_counts_and_case_hashes(self):
        suite = make_suite_requests(
            [
                {
                    "kernel": "ReLU-1PE",
                    "source_hash": "source",
                    "compile_hash": "compile",
                    "kernel_dir": "/frozen/relu",
                }
            ],
            campaign_id="study",
        )
        self.assertEqual(len(suite), 1)
        self.assertEqual(suite[0].warmups, SUITE_WARMUPS)
        self.assertEqual(suite[0].trials, SUITE_TRIALS)

        regular = CalibrationCase("straight", "straight-n1", {"hops": 1})
        compile_only = CalibrationCase(
            "single-pe-sram",
            "single-pe-sram-b49152",
            {"allocation_bytes": 49152, "compile_only": True},
        )
        calibration = make_calibration_requests(
            [regular, compile_only],
            campaign_id="study",
            template_source_hash="template-source",
            template_compile_hash="template-compile",
            arms=("hardware",),
        )
        self.assertEqual(calibration[0].warmups, CALIBRATION_WARMUPS)
        self.assertEqual(calibration[0].trials, CALIBRATION_TRIALS)
        self.assertEqual(calibration[1].warmups, 0)
        self.assertEqual(calibration[1].trials, 1)
        self.assertNotEqual(calibration[0].compile_hash, calibration[1].compile_hash)
        self.assertEqual(
            calibration[0].configuration["source_hash_kind"],
            "case_specification",
        )

        materialized = make_calibration_requests(
            [regular],
            campaign_id="study",
            template_source_hash="template-source",
            template_compile_hash="template-compile",
            materialized={
                regular.case_id: {
                    "bundle_sha256": "actual-generated-bytes",
                    "status": "runnable",
                    "manifest_path": "/frozen/manifest.json",
                    "compile": {"argv": ["cslc", "layout.csl"]},
                    "sdk": {"architecture": "wse3"},
                }
            },
            arms=("hardware",),
        )
        self.assertEqual(materialized[0].source_hash, "actual-generated-bytes")
        self.assertEqual(
            materialized[0].configuration["source_hash_kind"], "bundle_sha256"
        )

        unsupported = make_calibration_requests(
            [regular],
            campaign_id="study",
            template_source_hash="template-source",
            template_compile_hash="template-compile",
            materialized={
                regular.case_id: {
                    "bundle_sha256": "unsupported-generated-bytes",
                    "status": "unsupported",
                    "reason": "no collision-free queue assignment",
                    "manifest_path": "/frozen/unsupported.json",
                }
            },
            arms=("simulator", "hardware"),
        )
        self.assertEqual(len(unsupported), 2)
        self.assertTrue(all(item.warmups == 0 for item in unsupported))
        self.assertTrue(all(item.trials == 1 for item in unsupported))
        self.assertTrue(all(item.configuration["unsupported"] for item in unsupported))
        self.assertTrue(
            all(item.evidence == EvidenceKind.INFERRED.value for item in unsupported)
        )
        accepted_unsupported = validate_result(
            unsupported[0],
            {"status": "unsupported", "reason": "no collision-free queue assignment"},
        )
        self.assertTrue(accepted_unsupported.accepted)
        self.assertEqual(accepted_unsupported.status, "unsupported")
        self.assertIsNone(accepted_unsupported.normalized["elapsed_cycles"])

    def test_suite_builder_accepts_nested_inventory_records(self):
        suite = make_suite_requests(
            [
                {
                    "kernel": {
                        "name": "ParBroadcast-Scale",
                        "csl_dir": "kernels/ParBroadcast-Scale/CSL",
                    },
                    "hashes": {
                        "source_sha256": "nested-source",
                        "compile_command_sha256": "nested-compile",
                    },
                }
            ],
            campaign_id="nested",
            repo_root="/repo",
        )
        self.assertEqual(suite[0].subject, "ParBroadcast-Scale")
        self.assertEqual(suite[0].source_hash, "nested-source")
        self.assertEqual(suite[0].compile_hash, "nested-compile")
        self.assertEqual(
            suite[0].configuration["kernel_dir"],
            "/repo/kernels/ParBroadcast-Scale/CSL",
        )


if __name__ == "__main__":
    unittest.main(verbosity=2)
