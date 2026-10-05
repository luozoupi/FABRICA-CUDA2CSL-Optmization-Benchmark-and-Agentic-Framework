from __future__ import annotations

import hashlib
import json
import shutil
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from wse3study.instrumentation import (  # noqa: E402
    ADAPTER_SCHEMA_VERSION,
    adapter_source_hash,
    endpoint_adapter_generator_hash,
    full_telemetry_override_template,
    is_pristine_full_telemetry_override,
    host_operation_contract,
    materialize_full_telemetry_adapter,
    reinstrument_host_bracketed_bundle,
    timed_launch_sequence,
    validate_full_telemetry_override,
    validate_materialized_full_telemetry_adapter,
    verify_native_device_internal_bundle,
)
from wse3study.campaign import (  # noqa: E402
    _require_full_adapter_execution_evidence,
    validated_full_adapter_manifest,
)
from wse3study.schema import canonical_hash, hash_file, hash_tree  # noqa: E402


def _text_hash(value: str) -> str:
    return hashlib.sha256(value.encode("utf-8")).hexdigest()


def _materialization_fixture(root: Path) -> dict:
    run = '''runner.launch("old_compute")
# telemetry-anchor
# CHECK-START
assert actual == expected
# CHECK-END
'''
    pe = '''const sys_mod = @import_module("<memcpy/memcpy>", memcpy_params);
const PE_IMPORT_ANCHOR: i16 = 1;
fn profiled_entry() void {
  sync_reference_ready();
  compute_is_starting();
  first_word_is_sent();
  first_word_is_received();
  final_word_is_received();
  computation_is_complete();
  counters_are_ready();
  command_is_exiting();
}
comptime {
  @export_symbol(profiled_entry);
}
'''
    layout = '''layout {
  // SYNC_LAYOUT_ANCHOR
  @set_rectangle(1, 1);
}
'''
    (root / "run.py").write_text(run, encoding="utf-8")
    (root / "pe.csl").write_text(pe, encoding="utf-8")
    (root / "layout.csl").write_text(layout, encoding="utf-8")
    spec = full_telemetry_override_template(root)
    symbols = {
        "phase_words": "wse3study_phase_words",
        "phase_valid": "wse3study_phase_valid",
        "raw_perf": "wse3study_raw_perf",
        "sync_reference": "wse3study_sync_reference",
    }
    spec["exports"].update(
        {
            **symbols,
            "host_d2h_verified": True,
            "per_pe_geometry_verified": True,
            "per_pe_record": {
                "coordinate_order": "logical_y_then_x",
                "logical_rectangle": {"x": 0, "y": 0, "width": 1, "height": 1},
                "phase_count": 7,
                "timestamp_words_per_phase": 3,
                "phase_valid_words": 7,
                "raw_perf_words": 6,
                "sync_reference_words": 3,
            },
        }
    )
    anchors = {
        "sync_reference": "sync_reference_ready();",
        "compute_start": "compute_is_starting();",
        "first_send": "first_word_is_sent();",
        "first_receive": "first_word_is_received();",
        "last_receive": "final_word_is_received();",
        "compute_end": "computation_is_complete();",
        "exit": "command_is_exiting();",
    }
    spec["phases"] = {
        phase: [
            {
                "file": "pe.csl",
                "function": "profiled_entry",
                "anchor": anchor,
                "anchor_sha256": _text_hash(anchor),
                "position": "before",
                "profile_alias": "profile",
                **(
                    {"reference_expression": "&sync_mod.tscRefBuffer"}
                    if phase == "sync_reference"
                    else {}
                ),
            }
        ]
        for phase, anchor in anchors.items()
    }
    inventory_snapshot = {
        "layout_sha256": "compiled-layout-hash",
        "qualification_status": "qualified",
        "application_programs": ["pe.csl"],
        "used_resources": {
            "colors": [],
            "input_queues": [],
            "output_queues": [],
            "local_task_ids": [],
        },
        "evidence": "compiled",
    }
    inventory_hash = canonical_hash(inventory_snapshot)
    spec["sync"].update(
        {
            "colors": [10, 11, 12, 13, 14],
            "input_queues": [2, 3, 4],
            "output_queues": [2, 3, 4],
            "local_task_ids": [20, 21, 22, 23],
            "inventory_snapshot": inventory_snapshot,
            "inventory_hash": inventory_hash,
            "collision_check": "passed",
        }
    )
    protected = "# CHECK-START\nassert actual == expected\n# CHECK-END"
    spec["materialization"].update(
        {
            "status": "ready_to_materialize",
            "source_file_sha256": {
                name: hash_file(root / name) for name in ("run.py", "pe.csl", "layout.csl")
            },
            "integration_edits": [
                {
                    "role": "profile_import",
                    "file": "pe.csl",
                    "anchor": 'const sys_mod = @import_module("<memcpy/memcpy>", memcpy_params);',
                    "position": "before",
                    "text": 'const profile = @import_module("wse3study/profile_timestamp.csl", .{ .phase_count = 7 });',
                },
                {
                    "role": "sync_pe_import",
                    "file": "pe.csl",
                    "anchor": "const PE_IMPORT_ANCHOR: i16 = 1;",
                    "position": "after",
                    "text": 'const sync_mod = @import_module("wse3study/sync/pe.csl", sync_params);',
                },
                {
                    "role": "sync_layout_wiring",
                    "file": "layout.csl",
                    "anchor": "// SYNC_LAYOUT_ANCHOR",
                    "position": "after",
                    "text": '  const sync_layout = @import_module("wse3study/sync/layout.csl", .{});',
                },
                {
                    "role": "sync_host_launch",
                    "file": "run.py",
                    "anchor": 'runner.launch("old_compute")',
                    "position": "replace",
                    "text": 'runner.launch("profiled_entry")',
                },
                {
                    "role": "telemetry_csl_export",
                    "file": "pe.csl",
                    "anchor": "comptime {",
                    "position": "before",
                    "text": "\n".join(
                        f"var {symbol} = @zeros([1]u16);" for symbol in symbols.values()
                    ),
                },
                {
                    "role": "telemetry_host_d2h",
                    "file": "run.py",
                    "anchor": "# telemetry-anchor",
                    "position": "before",
                    "text": (
                        "runner.memcpy_d2h(wse3study_phase_words, 0, 0, 21, 1, 1)\n"
                        "runner.memcpy_d2h(wse3study_phase_valid, 0, 0, 7, 1, 1)\n"
                        "runner.memcpy_d2h(wse3study_raw_perf, 0, 0, 6, 1, 1)\n"
                        "runner.memcpy_d2h(wse3study_sync_reference, 0, 0, 3, 1, 1)"
                    ),
                },
            ],
            "counter_sites": [
                {
                    "file": "pe.csl",
                    "function": "profiled_entry",
                    "anchor": "counters_are_ready();",
                    "position": "before",
                    "profile_alias": "profile",
                }
            ],
            "protected_regions": [
                {
                    "file": "run.py",
                    "start_marker": "# CHECK-START",
                    "end_marker": "# CHECK-END",
                    "sha256": _text_hash(protected),
                }
            ],
            "execution_contract": {
                "single_device_entrypoint": "profiled_entry",
                "sync_before_compute": True,
                "host_rpc_inside_timed_window": False,
                "operator_attested": True,
            },
            "program_coverage": {
                "inventory_hash": inventory_hash,
                "required_programs": ["pe.csl"],
                "covered_programs": ["pe.csl"],
                "program_files": {"pe.csl": "pe.csl"},
                "status": "passed",
            },
            "blockers": [],
        }
    )
    spec["raw_performance_counters"]["event_semantics"] = "unknown_raw"
    spec["correctness"]["original_check_preserved"] = True
    return spec


def _attest_endpoint_parent(root: Path) -> None:
    (root / ".wse3study_adapter.json").write_text(
        json.dumps(
            {
                "status": "instrumented",
                "adapter_schema_version": ADAPTER_SCHEMA_VERSION,
                "adapter_generator_sha256": endpoint_adapter_generator_hash(),
                "telemetry_levels": ["endpoint"],
                "timing": {
                    "method": "device_internal",
                    "host_rpc_inside_window": False,
                },
                "correctness": {
                    "run_py_unchanged": True,
                    "run_py_sha256": hash_file(root / "run.py"),
                },
                "source_hash_after": adapter_source_hash(root),
            }
        ),
        encoding="utf-8",
    )


class InstrumentationTests(unittest.TestCase):
    def test_host_operation_contract_accepts_only_mutually_exclusive_dispatch(self) -> None:
        conditional = '''if args.inverse:
  runner.launch("f_ifft", nonblock=False)
else:
  runner.launch("f_fft", nonblock=False)
'''
        contract = host_operation_contract(conditional)
        self.assertIsNotNone(contract)
        self.assertEqual("mutually_exclusive_if_else", contract["kind"])
        sequential = 'runner.launch("f_ifft")\nrunner.launch("f_fft")\n'
        self.assertIsNone(host_operation_contract(sequential))

    def test_all_active_endpoint_failure_bundles_have_a_proven_adapter(self) -> None:
        """Regression-test the seven formerly fail-closed active bundles.

        Every source is copied to an isolated directory.  The test deliberately
        runs the real bundle contracts (including the imported stencil callback
        chain), while proving that canonical ``run.py`` files remain unchanged.
        """

        repo = Path(__file__).resolve().parents[3]
        sources = {
            "7pt-Stencil": repo / "kernels" / "7-Point Stencil" / "CSL",
            "FFT-1D-2D": repo / "kernels" / "FFT 1D-2D" / "CSL",
            "GEMV-Checkerboard": repo / "kernels" / "GEMV Checkerboard" / "CSL",
            "Histogram": repo / "kernels" / "Histogram" / "CSL",
            "Mandelbrot": repo / "kernels" / "Mandelbrot" / "CSL",
            "ParReduce-Sum": repo / "kernels" / "ParReduce-Sum" / "CSL",
            "Wide-Multiplication": repo / "kernels" / "Wide Multiplication" / "CSL",
        }
        expected_modes = {
            "7pt-Stencil": "imported_callback_relocated",
            "FFT-1D-2D": "verified_native",
            "GEMV-Checkerboard": "verified_stream_task_native",
            "Histogram": "generated_stream_completion_endpoint",
            "Mandelbrot": "verified_async_task_native",
            "ParReduce-Sum": "verified_native",
            "Wide-Multiplication": "stream_task_relocated",
        }
        with tempfile.TemporaryDirectory() as directory:
            base = Path(directory)
            for name, source in sources.items():
                with self.subTest(name):
                    target = base / name
                    shutil.copytree(
                        source,
                        target,
                        ignore=shutil.ignore_patterns(
                            "out", "out-*", "out2", "out_comm", "out_noop",
                            "simfab_traces", "wio_flows_tmpdir.*", "*.tar.gz",
                        ),
                    )
                    if name == "7pt-Stencil":
                        shutil.copytree(
                            repo / "kernels" / "benchmark-libs" / "stencil_3d_7pts",
                            target / "benchmark-libs" / "stencil_3d_7pts",
                        )
                    run_hash = hash_file(target / "run.py")
                    result = reinstrument_host_bracketed_bundle(target)
                    self.assertEqual("instrumented", result.status, result.reason)
                    self.assertEqual(expected_modes[name], result.mode)
                    self.assertEqual(run_hash, hash_file(target / "run.py"))
                    manifest = json.loads(
                        (target / ".wse3study_adapter.json").read_text(encoding="utf-8")
                    )
                    self.assertEqual(
                        endpoint_adapter_generator_hash(),
                        manifest["adapter_generator_sha256"],
                    )
                    self.assertFalse(manifest["timing"]["host_rpc_inside_window"])
                    self.assertTrue(manifest["correctness"]["run_py_unchanged"])
                    if name == "Histogram":
                        postlude = target / manifest["d2h"]["postlude"]
                        self.assertTrue(postlude.is_file())
                        self.assertEqual(hash_file(postlude), manifest["d2h"]["postlude_sha256"])

    def test_detects_timed_sequence(self) -> None:
        source = '''runner.launch("f_tic")\nrunner.launch("step")\nrunner.launch("f_toc")'''
        self.assertEqual(["step"], timed_launch_sequence(source))

    def test_moves_timer_endpoints_inside_device_callbacks(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "run.py").write_text(
                '''runner.launch("f_tic")
runner.launch("step")
runner.launch("f_toc")
runner.launch("f_memcpy_timestamps")
runner.memcpy_d2h(timer, 0, 0, 6, 1, 1)
cycles_send = 123
''',
                encoding="utf-8",
            )
            source = '''
const timestamp = @import_module("<time>");
const sys_mod = @import_module("<memcpy/memcpy>", memcpy_params);
var tscStartBuffer = @zeros([3]u16);
var tscEndBuffer = @zeros([3]u16);
fn f_tic() void { timestamp.get_timestamp(&tscStartBuffer); sys_mod.unblock_cmd_stream(); }
fn f_toc() void { timestamp.get_timestamp(&tscEndBuffer); sys_mod.unblock_cmd_stream(); }
fn step() void { @activate(EXIT); }
task f_exit() void { sys_mod.unblock_cmd_stream(); }
'''
            path = root / "pe.csl"
            path.write_text(source, encoding="utf-8")
            result = reinstrument_host_bracketed_bundle(root)
            self.assertEqual("instrumented", result.status)
            transformed = path.read_text(encoding="utf-8")
            self.assertIn("WSE3STUDY device-internal start", transformed)
            self.assertIn("WSE3STUDY device-internal end", transformed)
            toc = transformed[transformed.index("fn f_toc"):transformed.index("fn step")]
            self.assertNotIn("get_timestamp", toc)
            self.assertTrue((root / ".wse3study_adapter.json").is_file())
            manifest = json.loads((root / ".wse3study_adapter.json").read_text())
            self.assertEqual("step", manifest["launcher"])
            self.assertEqual("host_bracket_relocated", manifest["mode"])
            self.assertFalse(manifest["timing"]["official_cross_pe_sync"])
            self.assertEqual(["endpoint"], manifest["telemetry_levels"])

    def test_instruments_every_pe_program_and_not_imported_callbacks(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "run.py").write_text(
                '''runner.launch("f_tic")
runner.launch("step")
runner.launch("f_toc")
runner.launch("f_memcpy_timestamps")
runner.memcpy_d2h(timer, 0, 0, 6, 2, 1)
cycles_send = 999
''', encoding="utf-8")
            for name in ("active.csl", "noop.csl"):
                (root / name).write_text('''
const timestamp = @import_module("<time>");
var t0 = @zeros([3]u16); var t1 = @zeros([3]u16);
fn f_tic() void { timestamp.get_timestamp(&t0); sys.unblock_cmd_stream(); }
fn f_toc() void { timestamp.get_timestamp(&t1); sys.unblock_cmd_stream(); }
fn f_memcpy_timestamps() void { sys.unblock_cmd_stream(); }
fn step() void { sys.unblock_cmd_stream(); }
''', encoding="utf-8")
            (root / "library.csl").write_text(
                "fn done() void { f_callback(); }\n", encoding="utf-8"
            )
            result = reinstrument_host_bracketed_bundle(root)
            self.assertEqual("instrumented", result.status)
            for name in ("active.csl", "noop.csl"):
                source = (root / name).read_text(encoding="utf-8")
                self.assertIn("device-internal start", source)
                self.assertIn("device-internal end", source)
            self.assertNotIn(
                "get_timestamp", (root / "library.csl").read_text(encoding="utf-8")
            )
            manifest = json.loads((root / ".wse3study_adapter.json").read_text())
            self.assertEqual(2, len(manifest["timing"]["program_sites"]))

    def test_failure_is_transactional_and_does_not_fake_native_timing(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            run = 'runner.launch("f_tic")\nrunner.launch("step")\nrunner.launch("f_toc")\n'
            source = '''
const timestamp = @import_module("<time>");
var t0 = @zeros([3]u16); var t1 = @zeros([3]u16);
fn f_tic() void { timestamp.get_timestamp(&t0); sys.unblock_cmd_stream(); }
fn f_toc() void { timestamp.get_timestamp(&t1); sys.unblock_cmd_stream(); }
fn step() void { sys.unblock_cmd_stream(); }
'''
            (root / "run.py").write_text(run, encoding="utf-8")
            (root / "pe.csl").write_text(source, encoding="utf-8")
            result = reinstrument_host_bracketed_bundle(root)
            self.assertEqual("needs_override", result.status)
            self.assertEqual(source, (root / "pe.csl").read_text(encoding="utf-8"))
            self.assertFalse((root / ".wse3study_adapter.json").exists())

            (root / "run.py").write_text(
                'runner.launch("compute")\ncycles_send = 1\n', encoding="utf-8"
            )
            result = verify_native_device_internal_bundle(root)
            self.assertEqual("needs_override", result.status)

    def test_verifies_a_provable_native_endpoint_timer(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "run.py").write_text(
                '''runner.launch("compute")
runner.memcpy_d2h(timer, 0, 0, 3, 1, 1)
cycles_send = 321
''', encoding="utf-8")
            (root / "pe.csl").write_text('''
const timestamp = @import_module("<time>");
const EXIT: local_task_id = @get_local_task_id(9);
var t0 = @zeros([3]u16); var t1 = @zeros([3]u16); var packed = @zeros([3]u16);
fn compute() void {
  timestamp.enable_tsc(); timestamp.get_timestamp(&t0);
  packed[0] = t0[0]; packed[1] = t0[1];
  timestamp.get_timestamp(&t1);
  packed[2] = t1[0]; packed[0] = t1[1];
  @activate(EXIT);
}
task finish() void { sys.unblock_cmd_stream(); }
comptime { @bind_local_task(finish, EXIT); }
''', encoding="utf-8")
            result = verify_native_device_internal_bundle(root)
            self.assertEqual("instrumented", result.status)
            self.assertEqual("verified_native", result.mode)
            manifest = json.loads((root / ".wse3study_adapter.json").read_text())
            self.assertEqual("verified_native", manifest["mode"])

    def test_full_telemetry_template_is_fail_closed(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "run.py").write_text("# original correctness\n", encoding="utf-8")
            template = full_telemetry_override_template(root)
            self.assertEqual("needs_override", template["status"])
            self.assertTrue(is_pristine_full_telemetry_override(template))
            self.assertEqual([], template["phases"]["first_send"])
            changed = json.loads(json.dumps(template))
            changed["phases"]["first_send"] = [{"file": "pe.csl"}]
            self.assertFalse(is_pristine_full_telemetry_override(changed))
            template["status"] = "ready_for_compile"
            audit = validate_full_telemetry_override(root, template)
            self.assertEqual("needs_override", audit["status"])
            self.assertIn("required phase sync_reference has no source site", audit["errors"])

    def test_validates_explicit_full_telemetry_source_contract(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            sync = root / "sync"
            sync.mkdir()
            reference = Path(__file__).resolve().parents[1] / "calibration" / "official_sync"
            shutil.copyfile(reference / "layout.csl", sync / "layout.csl")
            shutil.copyfile(reference / "pe.csl", sync / "pe.csl")
            phases = (
                "sync_reference", "compute_start", "first_send", "first_receive",
                "last_receive", "compute_end", "exit",
            )
            marks = []
            for index, phase in enumerate(phases):
                call = "profile.mark_sync_reference(&reference);" if index == 0 else f"profile.mark({index});"
                marks.append(f"  {call} // WSE3STUDY phase={phase}")
            symbols = (
                "wse3study_phase_words wse3study_phase_valid "
                "wse3study_raw_perf wse3study_sync_reference"
            )
            (root / "pe.csl").write_text(
                "fn profiled() void {\n" + "\n".join(marks) + "\n}\n// " + symbols + "\n",
                encoding="utf-8",
            )
            (root / "run.py").write_text(
                "# " + symbols + "\nrunner.memcpy_d2h(buf, 0, 0, 1, 1, 1)\n# correctness SUCCESS\n",
                encoding="utf-8",
            )
            spec = full_telemetry_override_template(root)
            spec["status"] = "ready_for_compile"
            spec["bundle_source_hash"] = hash_tree(
                root,
                exclude_names=(
                    ".git", "__pycache__", ".pytest_cache", "simfab_traces", "out",
                    ".wse3study_adapter.json", ".wse3study_full_override.json",
                ),
            )
            spec["phases"] = {
                phase: [{"file": "pe.csl", "function": "profiled"}]
                for phase in phases
            }
            spec["sync"].update(
                {
                    "vendored_files": {"layout.csl": "sync/layout.csl", "pe.csl": "sync/pe.csl"},
                    "inventory_hash": "compiled-route-inventory-hash",
                    "collision_check": "passed",
                }
            )
            spec["exports"]["host_d2h_verified"] = True
            spec["raw_performance_counters"]["event_semantics"] = "unknown_raw"
            spec["correctness"].update(
                {
                    "original_run_py_sha256": hash_file(root / "run.py"),
                    "original_check_preserved": True,
                }
            )
            audit = validate_full_telemetry_override(root, spec)
            self.assertEqual([], audit["errors"])
            self.assertEqual("ready_for_compile", audit["status"])

    def test_materializes_atomic_full_telemetry_study_copy(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            base = Path(directory)
            source = base / "endpoint"
            source.mkdir()
            spec = _materialization_fixture(source)
            before = hash_tree(source)
            target = base / "full" / spec["bundle_source_hash"][:12]

            result = materialize_full_telemetry_adapter(source, spec, target)

            self.assertEqual("ready_for_compile", result["status"])
            self.assertEqual([], result["errors"])
            self.assertEqual(before, hash_tree(source), "endpoint source must remain byte-identical")
            self.assertTrue((target / "wse3study" / "sync" / "layout.csl").is_file())
            self.assertTrue((target / "wse3study" / "sync" / "pe.csl").is_file())
            self.assertTrue((target / "wse3study" / "profile_timestamp.csl").is_file())
            pe = (target / "pe.csl").read_text(encoding="utf-8")
            self.assertIn("profile.mark_sync_reference(&sync_mod.tscRefBuffer)", pe)
            self.assertIn("profile.mark(6); // WSE3STUDY phase=exit", pe)
            self.assertIn("raw_perf_slots=0,1 semantics=unknown_raw", pe)
            host = (target / "run.py").read_text(encoding="utf-8")
            self.assertNotIn('runner.launch("old_compute")', host)
            self.assertEqual(1, host.count('runner.launch("profiled_entry")'))
            self.assertIn("# CHECK-START\nassert actual == expected\n# CHECK-END", host)
            self.assertEqual("unknown_raw", result["raw_performance_counters"]["event_semantics"])
            self.assertEqual(
                "wse3study/sync/layout.csl", result["sync"]["vendored_files"]["layout.csl"]
            )

            # Repeating the exact request is idempotent and does not rewrite it.
            manifest_hash = hash_file(target / ".wse3study_full_adapter.json")
            repeated = materialize_full_telemetry_adapter(source, spec, target)
            self.assertEqual("ready_for_compile", repeated["status"])
            self.assertEqual(manifest_hash, hash_file(target / ".wse3study_full_adapter.json"))

    def test_full_materializer_fails_closed_before_publishing(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            base = Path(directory)
            source = base / "endpoint"
            source.mkdir()
            spec = _materialization_fixture(source)
            spec["phases"]["compute_start"][0]["anchor"] = "not-present();"
            spec["phases"]["compute_start"][0]["anchor_sha256"] = _text_hash("not-present();")
            target = base / "full"
            before = hash_tree(source)

            with self.assertRaisesRegex(Exception, "occur exactly once"):
                materialize_full_telemetry_adapter(source, spec, target)

            self.assertFalse(target.exists())
            self.assertEqual(before, hash_tree(source))

    def test_full_materializer_rejects_stale_source_hashes(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            base = Path(directory)
            source = base / "endpoint"
            source.mkdir()
            spec = _materialization_fixture(source)
            with (source / "pe.csl").open("a", encoding="utf-8") as handle:
                handle.write("// source changed after override\n")
            target = base / "full"
            with self.assertRaisesRegex(Exception, "bundle_source_hash"):
                materialize_full_telemetry_adapter(source, spec, target)
            self.assertFalse(target.exists())

    def test_full_materializer_does_not_accept_comment_only_exports(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            base = Path(directory)
            source = base / "endpoint"
            source.mkdir()
            spec = _materialization_fixture(source)
            symbols = " ".join(
                spec["exports"][key]
                for key in ("phase_words", "phase_valid", "raw_perf", "sync_reference")
            )
            for edit in spec["materialization"]["integration_edits"]:
                if edit["role"] == "telemetry_csl_export":
                    edit["text"] = "// " + symbols
                elif edit["role"] == "telemetry_host_d2h":
                    edit["text"] = "# " + symbols + " memcpy_d2h"
            target = base / "full"
            with self.assertRaisesRegex(Exception, "failed self-audit"):
                materialize_full_telemetry_adapter(source, spec, target)
            self.assertFalse(target.exists())

    def test_full_materializer_independently_rejects_resource_collision(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            base = Path(directory)
            source = base / "endpoint"
            source.mkdir()
            spec = _materialization_fixture(source)
            snapshot = spec["sync"]["inventory_snapshot"]
            snapshot["used_resources"]["colors"] = [10]
            inventory_hash = canonical_hash(snapshot)
            spec["sync"]["inventory_hash"] = inventory_hash
            spec["materialization"]["program_coverage"]["inventory_hash"] = inventory_hash
            target = base / "full"
            with self.assertRaisesRegex(Exception, "collides with compiled resources"):
                materialize_full_telemetry_adapter(source, spec, target)
            self.assertFalse(target.exists())

    def test_full_materializer_orders_explicit_shared_callback_sites(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            base = Path(directory)
            source = base / "endpoint"
            source.mkdir()
            spec = _materialization_fixture(source)
            anchor = "command_is_exiting();"
            for phase, sequence in (("compute_end", 0), ("exit", 2)):
                site = spec["phases"][phase][0]
                site["anchor"] = anchor
                site["anchor_sha256"] = _text_hash(anchor)
                site["sequence"] = sequence
            counter = spec["materialization"]["counter_sites"][0]
            counter["anchor"] = anchor
            counter["sequence"] = 1
            target = base / "full"

            materialize_full_telemetry_adapter(source, spec, target)

            text = (target / "pe.csl").read_text(encoding="utf-8")
            self.assertLess(text.index("profile.mark(5)"), text.index("sample_raw_perf_counters"))
            self.assertLess(text.index("sample_raw_perf_counters"), text.index("profile.mark(6)"))
            self.assertLess(text.index("profile.mark(6)"), text.index(anchor))

    def test_full_materializer_rejects_tampered_idempotent_target(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            base = Path(directory)
            source = base / "endpoint"
            source.mkdir()
            spec = _materialization_fixture(source)
            target = base / "full"
            materialize_full_telemetry_adapter(source, spec, target)
            with (target / "pe.csl").open("a", encoding="utf-8") as handle:
                handle.write("// tampered\n")
            audit = validate_materialized_full_telemetry_adapter(target)
            self.assertEqual("needs_override", audit["status"])
            with self.assertRaisesRegex(Exception, "refusing to overwrite"):
                materialize_full_telemetry_adapter(source, spec, target)

    def test_campaign_full_validator_binds_parent_override_and_generated_files(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            base = Path(directory)
            source = base / "endpoint"
            source.mkdir()
            spec = _materialization_fixture(source)
            _attest_endpoint_parent(source)
            target = base / "full"
            materialize_full_telemetry_adapter(source, spec, target)

            manifest = validated_full_adapter_manifest(target)

            self.assertEqual("ready_for_compile", manifest["status"])
            self.assertEqual("full", manifest["telemetry_level"])
            self.assertEqual(
                "blocked_until_compile_correctness_and_d2h_schema",
                manifest["campaign_binding"]["status"],
            )
            with self.assertRaisesRegex(Exception, "ready only for compilation"):
                _require_full_adapter_execution_evidence(manifest)

    def test_campaign_full_validator_rejects_tampered_run_manifest_and_parent(self) -> None:
        for tamper in ("run", "manifest", "parent"):
            with self.subTest(tamper=tamper), tempfile.TemporaryDirectory() as directory:
                base = Path(directory)
                source = base / "endpoint"
                source.mkdir()
                spec = _materialization_fixture(source)
                _attest_endpoint_parent(source)
                target = base / "full"
                materialize_full_telemetry_adapter(source, spec, target)
                if tamper == "run":
                    with (target / "run.py").open("a", encoding="utf-8") as handle:
                        handle.write("# changed host\n")
                elif tamper == "manifest":
                    path = target / ".wse3study_full_adapter.json"
                    value = json.loads(path.read_text(encoding="utf-8"))
                    value["override_sha256"] = "0" * 64
                    path.write_text(json.dumps(value), encoding="utf-8")
                else:
                    with (source / "pe.csl").open("a", encoding="utf-8") as handle:
                        handle.write("// changed endpoint parent\n")
                with self.assertRaises(Exception):
                    validated_full_adapter_manifest(target)


if __name__ == "__main__":
    unittest.main()
