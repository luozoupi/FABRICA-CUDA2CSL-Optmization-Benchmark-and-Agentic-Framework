from __future__ import annotations

import json
import re
from pathlib import Path
import sys
import tempfile
import unittest

_STUDY_ROOT = Path(__file__).resolve().parents[1]
if str(_STUDY_ROOT) not in sys.path:
    sys.path.insert(0, str(_STUDY_ROOT))

from wse3study.calibration import CalibrationCase, data_movement_cases
from wse3study.calibration_codegen import (
    CalibrationCodegenError,
    materialize_calibration_bundle,
    support_for_case,
)


def case(family: str, case_id: str, **parameters) -> CalibrationCase:
    return CalibrationCase(family=family, case_id=case_id, parameters=parameters)


class CalibrationCodegenTests(unittest.TestCase):
    def test_straight_routes_are_cardinal_and_endpoint_exact(self) -> None:
        expected = {
            "north": ((0, 3), (0, 0), "NORTH", "SOUTH"),
            "south": ((0, 0), (0, 3), "SOUTH", "NORTH"),
            "east": ((0, 0), (3, 0), "EAST", "WEST"),
            "west": ((3, 0), (0, 0), "WEST", "EAST"),
        }
        with tempfile.TemporaryDirectory() as temporary:
            for direction, (source, destination, forward, reverse) in expected.items():
                generated = materialize_calibration_bundle(
                    case(
                        "straight", f"straight-{direction}", direction=direction,
                        hops=3, payload_wavelets=8, turns=0,
                    ),
                    Path(temporary) / direction,
                )
                manifest = json.loads(Path(generated.manifest_path).read_text())
                measurement = manifest["measurement"]
                self.assertEqual(list(source), measurement["source"])
                self.assertEqual(list(destination), measurement["destination"])
                routes = measurement["route_entries"]
                self.assertEqual(4, len(routes))
                self.assertEqual("RAMP", routes[0]["rx"])
                self.assertEqual(forward, routes[0]["tx"])
                self.assertEqual(reverse, routes[-1]["rx"])
                self.assertEqual("RAMP", routes[-1]["tx"])
                self.assertTrue(all(route["color"] == 5 for route in routes))
                source_text = (Path(generated.path) / "straight_pe.csl").read_text()
                self.assertIn("timestamp.get_timestamp(&tsc_start)", source_text)
                self.assertIn("timestamp.get_timestamp(&tsc_end)", source_text)
                self.assertIn('sync_mod = @import_module("sync/pe.csl"', source_text)

    def test_straight_bundle_is_deterministic_and_vendors_official_sync(self) -> None:
        calibration = case(
            "straight", "straight-east-h8-p64", direction="east", hops=8,
            payload_wavelets=64, turns=0,
        )
        with tempfile.TemporaryDirectory() as temporary:
            first = materialize_calibration_bundle(calibration, Path(temporary) / "a")
            second = materialize_calibration_bundle(calibration, Path(temporary) / "b")
            self.assertEqual(first.bundle_sha256, second.bundle_sha256)
            first_manifest = json.loads(Path(first.manifest_path).read_text())
            second_manifest = json.loads(Path(second.manifest_path).read_text())
            self.assertEqual(first_manifest["files"], second_manifest["files"])
            self.assertTrue((Path(first.path) / "sync/layout.csl").is_file())
            self.assertTrue((Path(first.path) / "sync/pe.csl").is_file())
            command = (Path(first.path) / "commands_wse3.sh").read_text()
            self.assertNotIn("\n+", command)
            self.assertIn("--fabric-dims=762,1172", command)
            self.assertIn("--fabric-offsets=4,1", command)
            self.assertIn("cs_python ./run.py --name out", command)
            host = (Path(first.path) / "run.py").read_text()
            self.assertIn('parser.add_argument("--event-plan", type=Path)', host)
            self.assertIn('row["event_key"] = event["event_key"]', host)
            self.assertIn('"warmup": bool(event["warmup"])', host)
            self.assertIn('output.open("a", encoding="utf-8")', host)

    def test_turn_routes_cover_both_legs_and_exact_corner(self) -> None:
        pairs = (
            ("north", "east"), ("east", "south"),
            ("south", "west"), ("west", "north"),
            ("north", "west"), ("west", "south"),
            ("south", "east"), ("east", "north"),
        )
        with tempfile.TemporaryDirectory() as temporary:
            for first, second in pairs:
                generated = materialize_calibration_bundle(
                    case(
                        "turn", f"turn-{first}-{second}",
                        first_direction=first, second_direction=second,
                        first_hops=3, second_hops=5,
                        payload_wavelets=64, turns=1,
                    ),
                    Path(temporary) / f"{first}-{second}",
                )
                manifest = json.loads(Path(generated.manifest_path).read_text())
                measurement = manifest["measurement"]
                self.assertEqual(8, len(measurement["directed_route_edges"]))
                self.assertEqual(9, len(measurement["route_entries"]))
                self.assertEqual(measurement["route_entries"][3]["pe"], measurement["turn_coordinate"])
                for edge in measurement["directed_route_edges"]:
                    source, destination = edge["from"], edge["to"]
                    self.assertEqual(1, abs(source[0] - destination[0]) + abs(source[1] - destination[1]))
                turn_route = measurement["route_entries"][3]
                self.assertNotIn("RAMP", turn_route["rx"])
                self.assertNotIn("RAMP", turn_route["tx"])
                layout = (Path(generated.path) / "layout.csl").read_text()
                command = (Path(generated.path) / "commands_wse3.sh").read_text()
                self.assertNotIn("\n+", command)
                self.assertIn("cslc \\\n  ./layout.csl", command)
                self.assertEqual(first, measurement["first_direction"])
                self.assertIn("@set_color_config", layout)
                self.assertNotIn("@set_local_color_config", (Path(generated.path) / "network_pe.csl").read_text())

    def test_multicast_taps_replicate_to_ramp_and_continue(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            for direction in ("north", "south", "east", "west"):
                for fanout in (2, 4, 8, 16):
                    generated = materialize_calibration_bundle(
                        case(
                            "multicast", f"multicast-{direction}-{fanout}",
                            trunk_direction=direction, trunk_hops=32,
                            fanout=fanout, payload_wavelets=512,
                        ),
                        Path(temporary) / f"{direction}-{fanout}",
                    )
                    measurement = json.loads(Path(generated.manifest_path).read_text())["measurement"]
                    self.assertEqual(fanout, len(measurement["destinations"]))
                    self.assertEqual(fanout, len(set(map(tuple, measurement["destinations"]))))
                    self.assertEqual(32, len(measurement["directed_route_edges"]))
                    routes = {tuple(entry["pe"]): entry for entry in measurement["route_entries"]}
                    for index, destination in enumerate(measurement["destinations"]):
                        route = routes[tuple(destination)]
                        self.assertIn("RAMP", route["tx"])
                        if index + 1 < fanout:
                            self.assertEqual(2, len(route["tx"]))
                        else:
                            self.assertEqual(["RAMP"], route["tx"])
                    host = (Path(generated.path) / "run.py").read_text()
                    self.assertIn("for destination in destinations", host)
                    self.assertIn("payload correctness failed", host)

    def test_same_colour_multisource_is_fail_closed_on_wse3(self) -> None:
        """Merging several sources onto ONE colour needs two rx directions at the
        convergence PE.  A WSE-3 router permits at most one, and cslc rejects it with
        "expected at most 1 input direction(s) on 'wse3', got: 2".  This previously
        generated a plausible-looking manifest that only failed at compile time."""
        decision = support_for_case(
            case(
                "contention", "contention-s4-same", path_hops=32,
                payload_wavelets=512, sources=4, color_mode="same",
                queue_id=7, microthreads=8, receiver_delay_cycles=64,
            )
        )
        self.assertFalse(decision.supported)
        self.assertEqual("unsupported", decision.status)
        self.assertIn("one input direction per colour", decision.reason)

    def test_contention_paths_are_equal_hop_and_share_bottleneck(self) -> None:
        calibration = case(
            "contention", "contention-s2-distinct", path_hops=32,
            payload_wavelets=512, sources=2, color_mode="distinct",
            queue_id=2, microthreads=1, receiver_delay_cycles=64,
        )
        with tempfile.TemporaryDirectory() as temporary:
            generated = materialize_calibration_bundle(calibration, Path(temporary) / "contention")
            root = Path(generated.path)
            measurement = json.loads(Path(generated.manifest_path).read_text())["measurement"]
            self.assertEqual([[0, 0], [1, 1]], measurement["sources"])
            self.assertEqual([[32, 0]], measurement["destinations"])
            self.assertTrue(all(len(path) == 33 for path in measurement["source_paths"]))
            self.assertTrue(all(path[-1] == [32, 0] for path in measurement["source_paths"]))
            for edge in measurement["directed_route_edges"]:
                source, destination = edge["from"], edge["to"]
                self.assertEqual(1, abs(source[0] - destination[0]) + abs(source[1] - destination[1]))
            # Every configured colour must present at most ONE rx direction per PE.
            for entry in measurement["route_entries"]:
                self.assertLessEqual(
                    len(entry["rx"]), 1,
                    f"PE {entry['pe']} has {entry['rx']} on one colour; wse3 allows one",
                )
            self.assertTrue(set(measurement["traffic_queue_ids"]).isdisjoint(measurement["sync_queue_ids"]))
            source = (root / "network_pe.csl").read_text()
            # Concurrent async receives must hold distinct microthread ids.
            receives = re.findall(r"@fmovs\(receive_\d+_dsd.*?@get_ut_id\((\d+)\)", source)
            self.assertEqual(len(receives), len(set(receives)), f"ut_id reuse across {receives}")
            self.assertIn("while (delay_elapsed < 64)", source)
            self.assertIn("timestamp.get_timestamp(&delay_start)", source)

    def test_failed_s4_q6_smoke_case_is_now_fail_closed(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            generated = materialize_calibration_bundle(
                case(
                    "contention", "contention-s4-distinct-q6-m1-d0-00fdcecc", path_hops=32,
                    payload_wavelets=512, sources=4, color_mode="distinct",
                    queue_id=6, microthreads=1, receiver_delay_cycles=0,
                ),
                Path(temporary) / "failed-smoke",
            )
            root = Path(generated.path)
            manifest = json.loads(Path(generated.manifest_path).read_text())
            self.assertEqual("unsupported", generated.status)
            self.assertFalse(manifest["compile"]["enabled"])
            self.assertFalse((root / "layout.csl").exists())
            self.assertFalse((root / "network_pe.csl").exists())
            self.assertIn("six duplex-safe IDs 2..7", manifest["support"]["reason"])

    def test_safe_distinct_contention_honors_resource_ledger(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            generated = materialize_calibration_bundle(
                case(
                    "contention", "contention-s2-distinct-q6", path_hops=32,
                    payload_wavelets=512, sources=2, color_mode="distinct",
                    queue_id=6, microthreads=1, receiver_delay_cycles=0,
                ),
                Path(temporary) / "safe-distinct",
            )
            root = Path(generated.path)
            measurement = json.loads(Path(generated.manifest_path).read_text())["measurement"]
            self.assertEqual([6, 7], measurement["traffic_queue_ids"])
            self.assertEqual([2, 3, 4], measurement["sync_queue_ids"])
            self.assertEqual([5, 6], measurement["traffic_colors"])
            ledger = measurement["queue_resource_ledger"]
            self.assertEqual([0, 1], ledger["memcpy_reserved_input_queue_ids"])
            self.assertEqual([0], ledger["memcpy_reserved_output_queue_ids"])
            self.assertEqual([2, 3, 4, 5, 6, 7], ledger["duplex_safe_user_queue_ids"])
            generated_ids = set(ledger["traffic_input_queue_ids"] + ledger["sync_input_queue_ids"])
            self.assertTrue(generated_ids.isdisjoint(ledger["memcpy_reserved_input_queue_ids"]))
            self.assertTrue(set(ledger["traffic_output_queue_ids"] + ledger["sync_output_queue_ids"]).isdisjoint(ledger["memcpy_reserved_output_queue_ids"]))
            source = (root / "network_pe.csl").read_text()
            for task_id in (19, 20):
                self.assertIn(f"@get_local_task_id({task_id})", source)
            self.assertEqual(2, source.count(".activate = RECEIVE_DONE_"))
            self.assertIn("received_data[512 + i]", source)

    def test_memcpy_reserved_queue_zero_and_one_sweeps_are_unsupported(self) -> None:
        for queue_id in (0, 1):
            calibration = case(
                "contention", f"contention-reserved-q{queue_id}", path_hops=32,
                payload_wavelets=512, sources=1, color_mode="distinct",
                queue_id=queue_id, microthreads=1, receiver_delay_cycles=0,
            )
            decision = support_for_case(calibration)
            self.assertFalse(decision.supported)
            self.assertIn("input queues 0/1", decision.reason or "")
            self.assertIn("does not remap", decision.reason or "")

    def test_only_scientifically_unavailable_contention_cases_fail_closed(self) -> None:
        movement = data_movement_cases()
        route_cases = [value for value in movement if value.family in {"turn", "multicast", "contention"}]
        unsupported = [value for value in route_cases if not support_for_case(value).supported]
        self.assertEqual(28, len(unsupported))
        self.assertTrue(all(value.family == "contention" for value in unsupported))
        runnable_contention = [
            value for value in route_cases
            if value.family == "contention" and support_for_case(value).supported
        ]
        self.assertEqual(15, len(runnable_contention))
        self.assertEqual({2, 3, 4, 5, 6, 7}, {value.parameters["queue_id"] for value in runnable_contention})
        # The contention base binds a duplex-safe queue, so the one-factor curves
        # exercise the factor under test instead of failing closed on an inherited
        # reserved queue.  These are the columns the latency model needs.
        # Only 1 and 2 sources are reachable on wse3 today.  Same-colour merge needs
        # two rx directions on one colour (illegal); distinct-colour needs one queue
        # per source, and <memcpy> plus the three official-sync queues leave only three
        # duplex-safe ids, so 4- and 8-source cases cannot be expressed.  Dropping the
        # sync module would free three queues and unlock 4 sources.
        self.assertEqual({1, 2}, {value.parameters["sources"] for value in runnable_contention})
        self.assertEqual(
            {0, 4, 16, 64},
            {value.parameters["receiver_delay_cycles"] for value in runnable_contention},
        )
        # Every unsupported case must cite one of the three real limits, not a gap in
        # this generator: a <memcpy>-reserved queue, the duplex-safe queue budget, or
        # the wse3 one-rx-direction-per-colour routing rule.
        for value in unsupported:
            reason = support_for_case(value).reason or ""
            self.assertTrue(
                ("collides with <memcpy>" in reason)
                or ("duplex-safe" in reason)
                or ("one input direction per colour" in reason),
                f"{value.case_id} fails for an unclassified reason: {reason!r}",
            )
        with tempfile.TemporaryDirectory() as temporary:
            generated = materialize_calibration_bundle(unsupported[0], Path(temporary) / "unsupported")
            root = Path(generated.path)
            self.assertTrue((root / "UNSUPPORTED.md").is_file())
            self.assertFalse((root / "layout.csl").exists())
            manifest = json.loads((root / "manifest.json").read_text())
            self.assertFalse(manifest["compile"]["enabled"])
            self.assertTrue(
                "<memcpy>" in manifest["support"]["reason"]
                or "official-sync" in manifest["support"]["reason"]
            )

    def test_every_runnable_matrix_bundle_avoids_memcpy_and_sync_collisions(self) -> None:
        cases = [
            value for value in data_movement_cases()
            if value.family == "contention" and support_for_case(value).supported
        ]
        with tempfile.TemporaryDirectory() as temporary:
            for calibration in cases:
                generated = materialize_calibration_bundle(
                    calibration, Path(temporary) / calibration.case_id
                )
                measurement = json.loads(Path(generated.manifest_path).read_text())["measurement"]
                ledger = measurement["queue_resource_ledger"]
                traffic = set(measurement["traffic_queue_ids"])
                sync = set(measurement["sync_queue_ids"])
                self.assertTrue(traffic.isdisjoint(sync))
                self.assertTrue((traffic | sync).issubset(set(ledger["duplex_safe_user_queue_ids"])))
                self.assertTrue((traffic | sync).isdisjoint(ledger["memcpy_reserved_input_queue_ids"]))
                self.assertTrue((traffic | sync).isdisjoint(ledger["memcpy_reserved_output_queue_ids"]))

    def test_network_host_supports_resumable_event_plan_contract(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            generated = materialize_calibration_bundle(
                case(
                    "turn", "turn-event-plan", first_direction="north",
                    second_direction="east", first_hops=1, second_hops=1,
                    payload_wavelets=8, turns=1,
                ),
                Path(temporary) / "event-plan",
            )
            host = (Path(generated.path) / "run.py").read_text()
            self.assertIn('parser.add_argument("--event-plan", type=Path)', host)
            self.assertIn('row["event_key"] = event["event_key"]', host)
            self.assertIn('with args.output.open("a", encoding="utf-8")', host)
            self.assertNotIn('args.output.write_text("".join', host)
            self.assertIn('"start_words_u16": start_words[critical_source_index]', host)
            self.assertIn('"end_words_u16": end_words[critical_destination_index]', host)

    def test_single_pe_scalar_and_dsd_operations_emit_real_work(self) -> None:
        expected_builtin = {
            "copy": "@fmovs", "add": "@fadds", "multiply": "@fmuls",
            "fma": "@fmacs", "reduction": "@fadds",
        }
        with tempfile.TemporaryDirectory() as temporary:
            for operation, builtin in expected_builtin.items():
                for mode in ("scalar", "dsd"):
                    calibration = case(
                        "single-pe-throughput", f"{operation}-{mode}",
                        operation=operation, dtype="fp32", mode=mode,
                        vector_length=8, stride=1, bank_alignment=0,
                        dependency_chains=1, microthreads=1, queue_id=0,
                    )
                    generated = materialize_calibration_bundle(
                        calibration, Path(temporary) / f"{operation}-{mode}"
                    )
                    source = (Path(generated.path) / "single_pe.csl").read_text()
                    self.assertIn("timestamp.get_timestamp(&tsc_start)", source)
                    self.assertIn("timestamp.get_timestamp(&tsc_end)", source)
                    if mode == "dsd":
                        self.assertIn(builtin, source)
                    else:
                        self.assertIn("while (i < 8)", source)
                    host = (Path(generated.path) / "run.py").read_text()
                    self.assertIn("WSE3STUDY_RESULT=", host)
                    self.assertIn('print("SUCCESS")', host)
                    self.assertIn('parser.add_argument("--event-plan", type=Path)', host)
                    self.assertIn('row["event_key"] = event["event_key"]', host)
                    self.assertNotIn("from cerebras.sdk.sdk_utils import", host)
                    self.assertIn("def to_transport(values):", host)
                    self.assertIn("def from_transport(container, dtype):", host)
                    self.assertIn("raw_time_u32 = np.zeros(6, dtype=np.uint32)", host)
                    self.assertIn("runner.memcpy_h2d(a_symbol, a_u32", host)
                    self.assertIn("runner.memcpy_d2h(raw_time_u32", host)
                    self.assertIn("runner.memcpy_d2h(result_u32", host)

    def test_integer_dsd_capability_is_never_substituted(self) -> None:
        unsupported = case(
            "single-pe-throughput", "i32-dsd-add", operation="add", dtype="i32",
            mode="dsd", vector_length=8, stride=1, bank_alignment=0,
            dependency_chains=1, microthreads=1, queue_id=0,
        )
        self.assertFalse(support_for_case(unsupported).supported)
        supported = case(
            "single-pe-throughput", "i16-dsd-add", operation="add", dtype="i16",
            mode="dsd", vector_length=8, stride=1, bank_alignment=0,
            dependency_chains=1, microthreads=1, queue_id=0,
        )
        self.assertTrue(support_for_case(supported).supported)

    def test_queue_sweep_is_not_faked_by_local_memory_template(self) -> None:
        calibration = case(
            "single-pe-queue", "queue-3", operation="fma", dtype="fp32",
            mode="dsd", vector_length=256, stride=1, bank_alignment=0,
            dependency_chains=1, microthreads=1, queue_id=3,
        )
        decision = support_for_case(calibration)
        self.assertFalse(decision.supported)
        self.assertIn("do not consume a fabric queue", decision.reason or "")

    def test_sram_probe_is_compile_only_and_exact_in_words(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            generated = materialize_calibration_bundle(
                case(
                    "single-pe-sram", "sram-49152", allocation_bytes=49152,
                    compile_only=True, report_elf_memory=True,
                ),
                Path(temporary) / "probe",
            )
            manifest = json.loads(Path(generated.manifest_path).read_text())
            self.assertEqual("compile_only", generated.status)
            self.assertEqual(24576, manifest["compile"]["params"]["allocation_words"])
            self.assertEqual(49152, manifest["measurement"]["generated_allocation_bytes"])
            self.assertFalse(manifest["runtime"]["enabled"])
            self.assertIn("cs_readelf --ms", (Path(generated.path) / "inspect_memory.sh").read_text())

    def test_overwrite_requires_our_marker(self) -> None:
        calibration = case(
            "straight", "straight-east", direction="east", hops=1,
            payload_wavelets=1,
        )
        with tempfile.TemporaryDirectory() as temporary:
            target = Path(temporary) / "bundle"
            target.mkdir()
            (target / "user.txt").write_text("preserve")
            with self.assertRaises(CalibrationCodegenError):
                materialize_calibration_bundle(calibration, target, overwrite=True)


if __name__ == "__main__":
    unittest.main()
