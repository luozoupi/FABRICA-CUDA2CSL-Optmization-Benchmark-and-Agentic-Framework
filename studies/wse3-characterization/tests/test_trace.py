from __future__ import annotations

import gzip
import json
import struct
import sys
import tempfile
import unittest
from itertools import islice
from pathlib import Path


STUDY_ROOT = Path(__file__).resolve().parents[1]
REPOSITORY_ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(STUDY_ROOT))

from wse3study.trace import (  # noqa: E402
    CTF_MAGIC,
    CoordinateMapper,
    CtfMetadata,
    CtfTraceReader,
    Rectangle,
    TraceWindow,
    VerifiedWaveletFieldMap,
    build_flow_overlay,
    build_wavelet_groups,
    crop_events,
    decode_trace,
    summarize_backpressure,
    summarize_tasks,
    summarize_wavelets,
    write_events_jsonl_gz,
    write_wavelets_jsonl_gz,
)


MINIMAL_METADATA = r'''/* CTF 1.8 */
trace {
  major = 1;
  minor = 8;
  byte_order = le;
};
event {
  stream_id = 0;
  id = 6;
  name = "wavelet_trace_entry";
  fields := struct {
    integer { signed = false; size = 64; align = 64; } cycle;
    integer { signed = false; size = 64; align = 64; } ident;
    integer { signed = false; size = 32; align = 32; } tile_index;
    integer { signed = false; size = 16; align = 16; } index;
    integer { signed = false; size = 16; align = 16; } data;
    integer { signed = false; size = 32; align = 32; } fields;
  } align(1);
};
'''


def _wavelet_packet(
    *, cycle: int, ident: int, tile: int, index: int, data: int, fields: int,
    discarded: int = 0,
) -> bytes:
    # The event header ends at byte 68.  The first u64 payload member aligns to
    # byte 72, exactly as declared by the metadata above.
    packet = bytearray(72)
    struct.pack_into("<IQ", packet, 0, CTF_MAGIC, 0)
    struct.pack_into("<QQ", packet, 52, 6, 123456789)
    packet.extend(struct.pack("<QQIHHI", cycle, ident, tile, index, data, fields))
    content_size = len(packet)
    struct.pack_into(
        "<5Q",
        packet,
        12,
        content_size * 8,
        content_size * 8,
        123456700,
        123456800,
        discarded,
    )
    return bytes(packet)


def _event(event_type: str, cycle: int | None = None, **values: object) -> dict[str, object]:
    event: dict[str, object] = {"event_type": event_type, "evidence": "simulator"}
    if cycle is not None:
        event["cycle"] = cycle
    event.update(values)
    return event


class MetadataAndReaderTests(unittest.TestCase):
    def test_metadata_drives_payload_and_preserves_opaque_fields(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            trace_dir = Path(directory)
            (trace_dir / "metadata").write_text(MINIMAL_METADATA, encoding="utf-8")
            (trace_dir / "stream0").write_bytes(
                _wavelet_packet(cycle=19, ident=77, tile=12, index=3, data=4, fields=0xA5A5)
            )

            metadata = CtfMetadata.from_path(trace_dir / "metadata")
            self.assertEqual(metadata.events[6].name, "wavelet_trace_entry")
            self.assertEqual(
                [field.name for field in metadata.events[6].fields],
                ["cycle", "ident", "tile_index", "index", "data", "fields"],
            )

            events = list(CtfTraceReader(trace_dir / "stream0").iter_events())
            self.assertEqual(len(events), 1)
            event = events[0]
            self.assertEqual(event["cycle"], 19)
            self.assertEqual(event["tile_id"], 12)
            self.assertEqual(event["fields"], 0xA5A5)
            self.assertEqual(event["raw"]["fields"], 0xA5A5)
            self.assertEqual(event["evidence"], "simulator")
            self.assertNotIn("color", event)
            self.assertNotIn("direction", event)

    def test_decode_trace_end_to_end(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            trace_dir = Path(directory)
            (trace_dir / "metadata").write_text(MINIMAL_METADATA, encoding="utf-8")
            (trace_dir / "stream0").write_bytes(
                _wavelet_packet(cycle=19, ident=77, tile=6, index=3, data=4, fields=0xA5A5)
            )
            mapper = CoordinateMapper(
                5,
                5,
                application_rect=(1, 1, 2, 2),
                fabric_offset=(4, 1),
            )
            report = decode_trace(trace_dir, mapper=mapper, window=TraceWindow(10, 20))

            self.assertEqual(report["event_counts"], {"wavelet_trace_entry": 1})
            self.assertEqual(report["summaries"]["wavelets"]["groups"], 1)
            node = report["wavelets"][0]["nodes"][0]
            self.assertEqual(node["coordinates"]["application"]["x"], 0)
            self.assertEqual(node["coordinates"]["fabric"], {
                "x": 4,
                "y": 1,
                "evidence": "inferred",
                "source": "simulator coordinate transformed by compiled rectangle and fabric offset",
                "basis_evidence": ["simulator", "compiled"],
            })
            self.assertIsNone(node["color"])
            self.assertIsNone(node["incoming_direction"])
            self.assertIsNone(node["hop_delay_cycles"])

    def test_cumulative_discard_counter_is_compact_and_marks_trace_incomplete(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            trace_dir = Path(directory)
            (trace_dir / "metadata").write_text(MINIMAL_METADATA, encoding="utf-8")
            (trace_dir / "stream0").write_bytes(
                _wavelet_packet(
                    cycle=1, ident=1, tile=0, index=0, data=0, fields=0, discarded=3
                )
                + _wavelet_packet(
                    cycle=2, ident=2, tile=0, index=0, data=0, fields=0, discarded=3
                )
            )
            report = decode_trace(trace_dir)
            self.assertEqual(3, report["trace_integrity"]["discarded_events"])
            self.assertEqual("incomplete", report["trace_integrity"]["status"])
            self.assertEqual(1, len(report["warnings"]))
            self.assertTrue(report["source"]["stream0_sha256"])


class CoordinateAndWindowTests(unittest.TestCase):
    def test_coordinate_spaces_and_classification_hooks_are_separate(self) -> None:
        def classifier(tile_id, coordinate, event):
            if event.get("force_infrastructure"):
                return "infrastructure"
            return None

        mapper = CoordinateMapper(
            5,
            4,
            application_rect=Rectangle(1, 1, 2, 2),
            fabric_offset=(4, 1),
            infrastructure_tiles={0},
            classifier=classifier,
        )
        application = mapper.annotate({"tile_id": 6})
        self.assertEqual(application["coordinates"]["simulator"]["x"], 1)
        self.assertEqual(application["coordinates"]["application"]["x"], 0)
        self.assertEqual(application["coordinates"]["fabric"]["x"], 4)
        self.assertEqual(application["scope"], "application")

        infrastructure = mapper.annotate({"tile_id": 0})
        self.assertEqual(infrastructure["scope"], "infrastructure")
        forced = mapper.annotate({"tile_id": 6, "force_infrastructure": True})
        self.assertEqual(forced["scope"], "infrastructure")
        self.assertEqual(forced["scope_evidence"], "inferred")
        outside_plane = mapper.annotate({"tile_id": 99})
        self.assertEqual(outside_plane["coordinates"], {})
        self.assertEqual(outside_plane["scope"], "unclassified")

    def test_explicit_tile_coordinates_override_row_major(self) -> None:
        mapper = CoordinateMapper(3, 3, tile_coordinates={1: (8, 9)})
        self.assertEqual(mapper.simulator_coordinate(1), (8, 9))
        self.assertEqual(mapper.simulator_coordinate(2), (2, 0))

    def test_linear_timed_window_drops_before_after_and_timeless(self) -> None:
        events = [
            _event("x", 9),
            _event("x", 10),
            _event("x", 15),
            _event("x", 20),
            _event("x", 21),
            _event("counter"),
        ]
        result = crop_events(events, TraceWindow(10, 20))
        self.assertEqual([event["cycle"] for event in result.events], [10, 15, 20])
        self.assertEqual(
            result.stats(),
            {"seen": 6, "kept": 3, "excluded_before": 1, "excluded_after": 1, "excluded_timeless": 1},
        )

    def test_wrapping_window_uses_counter_modulus(self) -> None:
        window = TraceWindow(250, 5, counter_bits=8)
        self.assertEqual(window.duration, 11)
        result = crop_events([_event("x", 251), _event("x", 2), _event("x", 100)], window)
        self.assertEqual([event["cycle"] for event in result.events], [251, 2])


class WaveletGraphTests(unittest.TestCase):
    def setUp(self) -> None:
        self.mapper = CoordinateMapper(
            5,
            5,
            application_rect=(1, 1, 3, 3),
            fabric_offset=(4, 1),
        )

    def test_multicast_fork_produces_branches_and_observed_delays(self) -> None:
        events = [
            _event("wavelet_trace_entry", 10, ident=77, tile_id=12, index=0, data=9, fields=1),
            _event("wavelet_trace_entry", 12, ident=77, tile_id=11, index=0, data=9, fields=2),
            _event("wavelet_trace_entry", 12, ident=77, tile_id=13, index=0, data=9, fields=2),
            _event("backpressure_trace_entry", 12, tile_id=13, link=4, back_pressure=3),
        ]
        field_map = VerifiedWaveletFieldMap(
            {2: {"color": 8}}, source="SDK enum audit test fixture", evidence="documented"
        )
        groups = build_wavelet_groups(events, mapper=self.mapper, field_map=field_map)

        self.assertEqual(len(groups), 1)
        group = groups[0]
        self.assertEqual(group["branch_count"], 2)
        self.assertEqual({edge["direction"] for edge in group["edges"]}, {"EAST", "WEST"})
        self.assertEqual({edge["delay_cycles"] for edge in group["edges"]}, {2})
        self.assertTrue(all(edge["evidence"] == "inferred" for edge in group["edges"]))
        east_edge = next(edge for edge in group["edges"] if edge["direction"] == "EAST")
        self.assertEqual(east_edge["ambient_backpressure"][0]["back_pressure"], 3)
        east_node = next(node for node in group["nodes"] if node["tile_id"] == 13)
        self.assertEqual(east_node["color"], 8)
        self.assertEqual(east_node["decoded_fields"]["source"], "SDK enum audit test fixture")
        self.assertEqual(east_node["backpressure"][0]["link_raw"], 4)
        root = next(node for node in group["nodes"] if node["tile_id"] == 12)
        self.assertNotIn("decoded_fields", root)

    def test_equally_recent_predecessors_remain_explicitly_ambiguous(self) -> None:
        events = [
            _event("wavelet_trace_entry", 10, ident=91, tile_id=11, index=0, data=1, fields=0),
            _event("wavelet_trace_entry", 10, ident=91, tile_id=13, index=0, data=1, fields=0),
            _event("wavelet_trace_entry", 12, ident=91, tile_id=12, index=0, data=1, fields=0),
        ]
        group = build_wavelet_groups(events, mapper=self.mapper)[0]
        child = next(node for node in group["nodes"] if node["tile_id"] == 12)
        self.assertEqual(group["ambiguous_nodes"], [child["node_id"]])
        self.assertEqual(len(group["edges"]), 2)
        self.assertTrue(all(edge["ambiguous_predecessor"] for edge in group["edges"]))
        self.assertIsNone(child["branch"])

    def test_gzip_jsonl_writer_is_deterministic(self) -> None:
        groups = build_wavelet_groups(
            [_event("wavelet_trace_entry", 1, ident=7, tile_id=6, index=0, data=2, fields=3)],
            mapper=self.mapper,
        )
        with tempfile.TemporaryDirectory() as directory:
            first = Path(directory) / "first.jsonl.gz"
            second = Path(directory) / "second.jsonl.gz"
            write_wavelets_jsonl_gz(first, groups)
            write_wavelets_jsonl_gz(second, groups)
            self.assertEqual(first.read_bytes(), second.read_bytes())
            with gzip.open(first, "rt", encoding="utf-8") as handle:
                records = [json.loads(line) for line in handle]
            self.assertEqual(records[0]["ident"], 7)
            self.assertEqual(records[0]["record_type"], "observed_wavelet_dag")

            events_path = Path(directory) / "events.jsonl.gz"
            write_events_jsonl_gz(events_path, [{"event_type": "hwm_pipe", "cycle": 1}])
            with gzip.open(events_path, "rt", encoding="utf-8") as handle:
                self.assertEqual(json.loads(handle.readline())["cycle"], 1)

    def test_flow_overlay_labels_path_association_as_inferred(self) -> None:
        events = [
            _event("wavelet_trace_entry", 10, ident=77, tile_id=6, fields=0),
            _event("wavelet_trace_entry", 13, ident=77, tile_id=7, fields=0),
            _event("backpressure_trace_entry", 12, tile_id=7, link=1, back_pressure=2),
        ]
        groups = build_wavelet_groups(events, mapper=self.mapper)
        annotated = [self.mapper.annotate(event) for event in events]
        overlay = build_flow_overlay(groups, annotated)
        self.assertEqual(1, len(overlay["links"]))
        link = overlay["links"][0]
        self.assertEqual("inferred", link["evidence"])
        self.assertEqual("simulator", link["latency_evidence"])
        self.assertEqual(3, link["median_delay_cycles"])
        self.assertEqual(1, link["nonzero_backpressure_samples"])
        self.assertTrue(overlay["pes"])


class SummaryTests(unittest.TestCase):
    def test_backpressure_keeps_link_raw(self) -> None:
        summary = summarize_backpressure(
            [
                _event("backpressure_trace_entry", 1, tile_id=4, link=2, back_pressure=0),
                _event("backpressure_trace_entry", 2, tile_id=4, link=2, back_pressure=5),
            ]
        )
        record = summary["tile_links"][0]
        self.assertEqual(record["link_raw"], 2)
        self.assertEqual(record["nonzero_fraction"], 0.5)
        self.assertIn("raw", record["note"])

    def test_task_summary_includes_task_microthread_and_pipeline_fields(self) -> None:
        summary = summarize_tasks(
            [
                _event(
                    "hwm_dispatch_trace_entry",
                    10,
                    tile_id=4,
                    name="FMAC",
                    task_color=8,
                    ut_id=2,
                ),
                _event(
                    "hwm_dispatch_trace_entry",
                    11,
                    tile_id=4,
                    name="FMAC",
                    task_color=8,
                    ut_id=2,
                ),
                _event("hwm_pipe_trace_entry", 11, tile_id=4, stage=3, simdi=7),
            ]
        )
        tile = summary["tiles"][0]
        self.assertEqual(tile["dispatches"], 2)
        self.assertEqual(tile["instruction_names"], {"FMAC": 2})
        self.assertEqual(tile["microthread_ids"], {"2": 2})
        self.assertEqual(tile["simd_indices_raw"], {"7": 1})
        self.assertEqual(tile["dispatch_density_evidence"], "inferred")

    def test_wavelet_summary_excludes_ambiguous_edges_from_latency(self) -> None:
        mapper = CoordinateMapper(5, 5)
        group = build_wavelet_groups(
            [
                _event("wavelet_trace_entry", 10, ident=91, tile_id=11, fields=0),
                _event("wavelet_trace_entry", 10, ident=91, tile_id=13, fields=0),
                _event("wavelet_trace_entry", 12, ident=91, tile_id=12, fields=0),
            ],
            mapper=mapper,
        )
        summary = summarize_wavelets(group)
        self.assertEqual(summary["ambiguous_groups"], 1)
        self.assertEqual(summary["hop_delay_cycles"]["count"], 0)

    def test_wavelet_summary_retains_landing_and_counter_observations(self) -> None:
        summary = summarize_wavelets(
            [],
            [
                _event("wavelet_entry", PE_x=2, PE_y=3, color=8),
                _event(
                    "debug_counters_wavelet",
                    PE_x=2,
                    PE_y=3,
                    color=8,
                    count_w=10,
                    count_t=4,
                    count_s=1,
                ),
            ],
        )
        self.assertEqual(summary["landing_events"], 1)
        self.assertEqual(summary["landing_by_pe_color"][0]["color"], 8)
        self.assertEqual(summary["debug_counter_totals"], {"count_s": 1, "count_t": 4, "count_w": 10})


REAL_TRACE_DIR = REPOSITORY_ROOT / "kernels" / "ParBroadcast-Scale" / "CSL" / "simfab_traces"
REAL_DIRECTION_CASES = {
    "ParBroadcast-Scale": ((4, 1, 4, 1), {"EAST"}),
    "ParReduce-Sum": ((4, 1, 4, 1), {"WEST"}),
    "Jacobi-2D-5pt": ((4, 1, 2, 2), {"NORTH", "SOUTH", "EAST", "WEST"}),
    "Laplacian2D-Halo": ((4, 1, 2, 2), {"NORTH", "SOUTH", "EAST", "WEST"}),
}


@unittest.skipUnless(
    (REAL_TRACE_DIR / "stream0").is_file()
    and (REAL_TRACE_DIR / "metadata").is_file()
    and (REAL_TRACE_DIR / "global_simdata.json").is_file(),
    "stored xkernel simulator trace is not present",
)
class StoredTraceSmokeTests(unittest.TestCase):
    def test_actual_metadata_and_stream_decode_without_bitfield_assumptions(self) -> None:
        reader = CtfTraceReader(REAL_TRACE_DIR / "stream0")
        events = list(islice(reader.iter_events(), 3))
        self.assertEqual(len(reader.metadata.events), 7)
        self.assertEqual([event["event_type"] for event in events], ["wavelet_trace_entry"] * 3)
        self.assertTrue(all("fields" in event["raw"] for event in events))
        self.assertTrue(all("color" not in event for event in events))

        mapper = CoordinateMapper.from_global_simdata(REAL_TRACE_DIR)
        tile_zero = mapper.annotate(events[0])
        self.assertEqual(
            (tile_zero["coordinates"]["simulator"]["x"], tile_zero["coordinates"]["simulator"]["y"]),
            (0, 0),
        )
        tile_eleven = mapper.annotate(events[2])
        self.assertEqual(
            (tile_eleven["coordinates"]["simulator"]["x"], tile_eleven["coordinates"]["simulator"]["y"]),
            (0, 1),
        )

    def test_stored_collective_and_halo_traces_recover_expected_directions(self) -> None:
        for kernel, (application_rect, expected_directions) in REAL_DIRECTION_CASES.items():
            with self.subTest(kernel=kernel):
                trace_dir = REPOSITORY_ROOT / "kernels" / kernel / "CSL" / "simfab_traces"
                if not all((trace_dir / name).is_file() for name in ("stream0", "metadata", "global_simdata.json")):
                    self.skipTest(f"stored trace for {kernel} is not present")
                events = list(CtfTraceReader(trace_dir).iter_events())
                mapper = CoordinateMapper.from_global_simdata(
                    trace_dir,
                    application_rect=application_rect,
                    fabric_offset=(4, 1),
                )
                groups = build_wavelet_groups(events, mapper=mapper)
                observed: set[str] = set()
                for group in groups:
                    nodes = {node["node_id"]: node for node in group["nodes"]}
                    for edge in group["edges"]:
                        if (
                            nodes[edge["source"]]["scope"] == "application"
                            and nodes[edge["destination"]]["scope"] == "application"
                        ):
                            observed.add(edge["direction"])
                self.assertTrue(groups, "the formerly zero-wavelet result must not recur")
                self.assertTrue(
                    expected_directions.issubset(observed),
                    f"expected {expected_directions}, observed {observed}",
                )


if __name__ == "__main__":
    unittest.main()
