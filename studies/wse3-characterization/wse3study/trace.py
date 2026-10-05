"""Metadata-driven decoding and analysis of Cerebras simulator CTF traces.

The simulator's ``simfab_traces/metadata`` file is the authority for event
payload layouts.  In particular, SDK 1.4 traces describe the final member of
``wavelet_trace_entry`` only as an opaque 32-bit ``fields`` value.  This module
therefore never guesses color/direction bit slices: callers may supply a
source-attributed :class:`VerifiedWaveletFieldMap`, while the raw value is
always retained.

Coordinates have three deliberately distinct spaces:

* simulator coordinates are derived from ``global_simdata.json`` (or supplied
  explicitly for unusual traces);
* application-local coordinates require the compiled application rectangle;
* fabric coordinates additionally require the compiler fabric offset.

All observed records and all derived graph edges carry an evidence tag.
"""

from __future__ import annotations

import gzip
import io
import json
import math
import os
import re
import struct
import tempfile
from bisect import bisect_left, bisect_right
from collections import Counter, defaultdict
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Callable, Iterable, Iterator, Mapping, Sequence

from .schema import (
    EvidenceKind,
    SCHEMA_VERSION,
    ValidationError,
    evidence_value,
    hash_file,
    validate_wavelet_contract,
)


CTF_MAGIC = 0xC1FC1FC1
_PACKET_HEADER_SIZE = 52
_EVENT_HEADER_SIZE = 16


class TraceFormatError(ValidationError):
    """Raised when a trace disagrees with its CTF metadata or is truncated."""


@dataclass(frozen=True)
class CtfField:
    """One integer or string field declared by CTF metadata."""

    name: str
    kind: str
    size_bits: int | None
    align_bits: int
    signed: bool = False


@dataclass(frozen=True)
class CtfEventSchema:
    event_id: int
    name: str
    fields: tuple[CtfField, ...]


@dataclass(frozen=True)
class CtfMetadata:
    """The event subset of a CTF 1.8 metadata document."""

    events: Mapping[int, CtfEventSchema]
    source: str
    sha256: str

    @classmethod
    def from_path(cls, path: str | os.PathLike[str]) -> "CtfMetadata":
        metadata_path = Path(path)
        text = metadata_path.read_text(encoding="utf-8")
        return cls(
            events=_parse_event_schemas(text),
            source=str(metadata_path.resolve()),
            sha256=hash_file(metadata_path),
        )


_EVENT_BLOCK = re.compile(r"\bevent\s*\{(.*?)\n\};", re.DOTALL)
_DECLARATION = re.compile(
    r"\b(integer|string)\s*\{(.*?)\}\s*([A-Za-z_]\w*)\s*;",
    re.DOTALL,
)


def _metadata_int(body: str, key: str, *, required: bool = True) -> int | None:
    match = re.search(rf"\b{re.escape(key)}\s*=\s*(\d+)\s*;", body)
    if match:
        return int(match.group(1))
    if required:
        raise TraceFormatError(f"CTF metadata declaration has no {key!r}")
    return None


def _parse_event_schemas(text: str) -> dict[int, CtfEventSchema]:
    if "/* CTF 1.8 */" not in text and not re.search(
        r"\bmajor\s*=\s*1\s*;.*?\bminor\s*=\s*8\s*;", text, re.DOTALL
    ):
        raise TraceFormatError("only CTF 1.8 metadata is supported")

    schemas: dict[int, CtfEventSchema] = {}
    for block_match in _EVENT_BLOCK.finditer(text):
        block = block_match.group(1)
        event_id = _metadata_int(block, "id")
        name_match = re.search(r'\bname\s*=\s*"([^"]+)"\s*;', block)
        fields_match = re.search(
            r"\bfields\s*:=\s*struct\s*\{(.*?)\}\s*align\s*\(\s*\d+\s*\)\s*;",
            block,
            re.DOTALL,
        )
        if event_id is None or name_match is None or fields_match is None:
            raise TraceFormatError("incomplete event declaration in CTF metadata")

        fields: list[CtfField] = []
        for decl in _DECLARATION.finditer(fields_match.group(1)):
            kind, declaration, field_name = decl.groups()
            if kind == "string":
                fields.append(CtfField(field_name, kind, None, 8, False))
                continue
            size_bits = _metadata_int(declaration, "size")
            align_bits = _metadata_int(declaration, "align")
            signed_match = re.search(r"\bsigned\s*=\s*(true|false)\s*;", declaration)
            if signed_match is None or size_bits is None or align_bits is None:
                raise TraceFormatError(f"incomplete integer declaration for {field_name}")
            if size_bits % 8 or align_bits % 8:
                raise TraceFormatError(
                    f"non-byte-sized CTF field {field_name} is not supported: "
                    f"size={size_bits}, align={align_bits}"
                )
            fields.append(
                CtfField(
                    field_name,
                    kind,
                    size_bits,
                    align_bits,
                    signed_match.group(1) == "true",
                )
            )

        if not fields:
            raise TraceFormatError(f"event {event_id} ({name_match.group(1)}) has no fields")
        if event_id in schemas:
            raise TraceFormatError(f"duplicate CTF event id {event_id}")
        schemas[event_id] = CtfEventSchema(event_id, name_match.group(1), tuple(fields))

    if not schemas:
        raise TraceFormatError("CTF metadata contains no event declarations")
    return schemas


def _align(offset: int, align_bits: int) -> int:
    align_bytes = max(1, align_bits // 8)
    return (offset + align_bytes - 1) // align_bytes * align_bytes


def _read_field(packet: bytes, offset: int, limit: int, field: CtfField) -> tuple[Any, int]:
    offset = _align(offset, field.align_bits)
    if field.kind == "string":
        end = packet.find(b"\0", offset, limit)
        if end < 0:
            raise TraceFormatError(f"unterminated CTF string field {field.name!r}")
        return packet[offset:end].decode("utf-8", errors="replace"), end + 1

    assert field.size_bits is not None
    width = field.size_bits // 8
    end = offset + width
    if end > limit:
        raise TraceFormatError(f"truncated CTF integer field {field.name!r}")
    return int.from_bytes(packet[offset:end], "little", signed=field.signed), end


class CtfTraceReader:
    """Stream typed event dictionaries from a barectf CTF ``stream0`` file.

    The reader intentionally parses payloads from the adjacent metadata file
    rather than embedding an SDK-specific bit layout.  Packet framing is the
    fixed CTF 1.8/barectf framing used by the stored Cerebras traces.
    """

    def __init__(
        self,
        stream0_path: str | os.PathLike[str],
        metadata_path: str | os.PathLike[str] | None = None,
        *,
        strict: bool = True,
    ) -> None:
        stream_path = Path(stream0_path)
        self.stream0_path = stream_path / "stream0" if stream_path.is_dir() else stream_path
        self.metadata_path = Path(metadata_path) if metadata_path else self.stream0_path.with_name("metadata")
        self.metadata = CtfMetadata.from_path(self.metadata_path)
        self.strict = strict
        self.warnings: list[str] = []
        self.discarded_events_total = 0
        self.discarded_events_by_stream: dict[int, int] = {}
        self._discard_warning_by_stream: dict[int, int] = {}

    def iter_events(self) -> Iterator[dict[str, Any]]:
        file_size = self.stream0_path.stat().st_size
        file_offset = 0
        packet_index = 0
        with self.stream0_path.open("rb") as stream:
            while file_offset < file_size:
                header = stream.read(_PACKET_HEADER_SIZE)
                if not header:
                    break
                if len(header) != _PACKET_HEADER_SIZE:
                    raise TraceFormatError(
                        f"truncated packet header at byte {file_offset}: got {len(header)} bytes"
                    )

                magic, stream_id = struct.unpack_from("<IQ", header, 0)
                if magic != CTF_MAGIC:
                    raise TraceFormatError(
                        f"bad CTF magic 0x{magic:08x} at byte {file_offset}"
                    )
                packet_size_bits, content_size_bits, ts_begin, ts_end, discarded = struct.unpack_from(
                    "<5Q", header, 12
                )
                if packet_size_bits % 8 or content_size_bits % 8:
                    raise TraceFormatError(f"packet {packet_index} has non-byte-aligned size")
                packet_size = packet_size_bits // 8
                content_size = content_size_bits // 8
                if packet_size < _PACKET_HEADER_SIZE or not (
                    _PACKET_HEADER_SIZE <= content_size <= packet_size
                ):
                    raise TraceFormatError(
                        f"packet {packet_index} has invalid packet/content sizes "
                        f"{packet_size}/{content_size}"
                    )
                rest = stream.read(packet_size - _PACKET_HEADER_SIZE)
                if len(rest) != packet_size - _PACKET_HEADER_SIZE:
                    raise TraceFormatError(f"truncated CTF packet {packet_index}")
                packet = header + rest
                previous_discarded = self.discarded_events_by_stream.get(stream_id, 0)
                if discarded < previous_discarded:
                    # A stream reset starts a new cumulative epoch.
                    self.warnings.append(
                        f"packet {packet_index} reset cumulative discarded-event counter "
                        f"for stream {stream_id} from {previous_discarded} to {discarded}"
                    )
                    previous_discarded = 0
                if discarded > previous_discarded:
                    newly_discarded = discarded - previous_discarded
                    self.discarded_events_total += newly_discarded
                    message = (
                        f"stream {stream_id} reports {discarded} cumulative discarded events "
                        f"by packet {packet_index}; exact trace history is incomplete"
                    )
                    warning_index = self._discard_warning_by_stream.get(stream_id)
                    if warning_index is None:
                        self._discard_warning_by_stream[stream_id] = len(self.warnings)
                        self.warnings.append(message)
                    else:
                        self.warnings[warning_index] = message
                self.discarded_events_by_stream[stream_id] = discarded

                event_offset = _PACKET_HEADER_SIZE
                event_in_packet = 0
                while event_offset + _EVENT_HEADER_SIZE <= content_size:
                    event_id, trace_timestamp = struct.unpack_from("<QQ", packet, event_offset)
                    payload_offset = event_offset + _EVENT_HEADER_SIZE
                    schema = self.metadata.events.get(event_id)
                    if schema is None:
                        message = f"packet {packet_index} contains undeclared event id {event_id}"
                        if self.strict:
                            raise TraceFormatError(message)
                        self.warnings.append(message)
                        yield {
                            "schema_version": SCHEMA_VERSION,
                            "event_id": event_id,
                            "event_type": f"unknown_{event_id}",
                            "trace_timestamp": trace_timestamp,
                            "raw_payload_hex": packet[payload_offset:content_size].hex(),
                            "packet_index": packet_index,
                            "event_in_packet": event_in_packet,
                            "evidence": EvidenceKind.SIMULATOR.value,
                        }
                        event_offset = content_size
                        break

                    raw: dict[str, Any] = {}
                    cursor = payload_offset
                    try:
                        for field in schema.fields:
                            raw[field.name], cursor = _read_field(packet, cursor, content_size, field)
                    except TraceFormatError:
                        if self.strict:
                            raise
                        message = f"failed to decode event {event_id} in packet {packet_index}"
                        self.warnings.append(message)
                        event_offset = content_size
                        break

                    event: dict[str, Any] = {
                        "schema_version": SCHEMA_VERSION,
                        "event_id": event_id,
                        "event_type": schema.name,
                        "trace_timestamp": trace_timestamp,
                        "packet_index": packet_index,
                        "event_in_packet": event_in_packet,
                        "stream_id": stream_id,
                        "raw": dict(raw),
                        "evidence": EvidenceKind.SIMULATOR.value,
                        # Compatibility aliases for the original xkernel parser.
                        "_id": event_id,
                        "_type": schema.name,
                        "_timestamp": trace_timestamp,
                    }
                    event.update(raw)
                    if "tile_index" in raw:
                        event["tile_id"] = raw["tile_index"]
                        event["tile"] = raw["tile_index"]
                    event["packet_context"] = {
                        "timestamp_begin": ts_begin,
                        "timestamp_end": ts_end,
                        "events_discarded": discarded,
                    }
                    yield event
                    event_in_packet += 1
                    if cursor <= event_offset:
                        raise TraceFormatError(f"event {event_id} decoder made no progress")
                    event_offset = cursor

                trailing = content_size - event_offset
                if trailing and any(packet[event_offset:content_size]):
                    message = f"packet {packet_index} has {trailing} unparsed nonzero content bytes"
                    if self.strict:
                        raise TraceFormatError(message)
                    self.warnings.append(message)

                file_offset += packet_size
                packet_index += 1

        if file_offset != file_size:
            raise TraceFormatError(
                f"trace ended at packet boundary {file_offset}, file size is {file_size}"
            )


ScopeClassifier = Callable[[int | None, tuple[int, int] | None, Mapping[str, Any]], str | None]


@dataclass(frozen=True)
class Rectangle:
    x: int
    y: int
    width: int
    height: int

    def __post_init__(self) -> None:
        if self.width <= 0 or self.height <= 0:
            raise ValueError("rectangle width and height must be positive")

    def contains(self, coordinate: tuple[int, int]) -> bool:
        x, y = coordinate
        return self.x <= x < self.x + self.width and self.y <= y < self.y + self.height


class CoordinateMapper:
    """Map event tile IDs without conflating simulator, local, and fabric space."""

    def __init__(
        self,
        simulator_width: int,
        simulator_height: int,
        *,
        tile_coordinates: Mapping[int, tuple[int, int]] | None = None,
        application_rect: Rectangle | tuple[int, int, int, int] | None = None,
        fabric_offset: tuple[int, int] | None = None,
        infrastructure_tiles: Iterable[int] = (),
        infrastructure_coordinates: Iterable[tuple[int, int]] = (),
        scope_overrides: Mapping[int, str] | None = None,
        classifier: ScopeClassifier | None = None,
        row_major: bool = True,
        source: str = "global_simdata.json",
    ) -> None:
        if simulator_width <= 0 or simulator_height <= 0:
            raise ValueError("simulator dimensions must be positive")
        self.width = simulator_width
        self.height = simulator_height
        self.tile_coordinates = dict(tile_coordinates or {})
        self.application_rect = (
            application_rect
            if isinstance(application_rect, Rectangle) or application_rect is None
            else Rectangle(*application_rect)
        )
        self.fabric_offset = fabric_offset
        self.infrastructure_tiles = set(infrastructure_tiles)
        self.infrastructure_coordinates = set(infrastructure_coordinates)
        self.scope_overrides = dict(scope_overrides or {})
        self.classifier = classifier
        self.row_major = row_major
        self.source = source

    @classmethod
    def from_global_simdata(
        cls,
        path: str | os.PathLike[str],
        **kwargs: Any,
    ) -> "CoordinateMapper":
        metadata_path = Path(path)
        if metadata_path.is_dir():
            metadata_path = metadata_path / "global_simdata.json"
        document = json.loads(metadata_path.read_text(encoding="utf-8"))
        try:
            width, height = int(document["xsize"]), int(document["ysize"])
        except (KeyError, TypeError, ValueError) as exc:
            raise TraceFormatError(f"{metadata_path} has no valid xsize/ysize") from exc
        return cls(width, height, source=str(metadata_path.resolve()), **kwargs)

    def simulator_coordinate(self, tile_id: int) -> tuple[int, int] | None:
        if tile_id in self.tile_coordinates:
            return self.tile_coordinates[tile_id]
        if self.row_major and 0 <= tile_id < self.width * self.height:
            return tile_id % self.width, tile_id // self.width
        return None

    def annotate(self, event: Mapping[str, Any]) -> dict[str, Any]:
        annotated = dict(event)
        tile_id_raw = event.get("tile_id", event.get("tile_index", event.get("tile")))
        tile_id = int(tile_id_raw) if tile_id_raw is not None else None

        direct_coordinate: tuple[int, int] | None = None
        if "PE_x" in event and "PE_y" in event:
            direct_coordinate = int(event["PE_x"]), int(event["PE_y"])
        coordinate = direct_coordinate
        if coordinate is None and tile_id is not None:
            coordinate = self.simulator_coordinate(tile_id)

        coordinate_records: dict[str, Any] = {}
        if coordinate is not None:
            coordinate_records["simulator"] = {
                "x": coordinate[0],
                "y": coordinate[1],
                "evidence": EvidenceKind.SIMULATOR.value,
                "source": self.source,
            }

        application_coordinate: tuple[int, int] | None = None
        if coordinate is not None and self.application_rect and self.application_rect.contains(coordinate):
            application_coordinate = (
                coordinate[0] - self.application_rect.x,
                coordinate[1] - self.application_rect.y,
            )
            coordinate_records["application"] = {
                "x": application_coordinate[0],
                "y": application_coordinate[1],
                "evidence": EvidenceKind.INFERRED.value,
                "source": "simulator coordinate transformed by compiled application rectangle",
                "basis_evidence": [
                    EvidenceKind.SIMULATOR.value,
                    EvidenceKind.COMPILED.value,
                ],
            }
            if self.fabric_offset is not None:
                coordinate_records["fabric"] = {
                    "x": application_coordinate[0] + self.fabric_offset[0],
                    "y": application_coordinate[1] + self.fabric_offset[1],
                    "evidence": EvidenceKind.INFERRED.value,
                    "source": "simulator coordinate transformed by compiled rectangle and fabric offset",
                    "basis_evidence": [
                        EvidenceKind.SIMULATOR.value,
                        EvidenceKind.COMPILED.value,
                    ],
                }

        scope: str | None = None
        scope_evidence = EvidenceKind.COMPILED.value
        scope_source = "coordinate mapper"
        if self.classifier is not None:
            scope = self.classifier(tile_id, coordinate, event)
            if scope is not None:
                scope_source = "caller classification hook"
                scope_evidence = EvidenceKind.INFERRED.value
        if scope is None and tile_id is not None:
            scope = self.scope_overrides.get(tile_id)
            if scope is not None:
                scope_source = "caller tile scope override"
                scope_evidence = EvidenceKind.INFERRED.value
        if scope is None and application_coordinate is not None:
            scope = "application"
        if scope is None and (
            (tile_id is not None and tile_id in self.infrastructure_tiles)
            or (coordinate is not None and coordinate in self.infrastructure_coordinates)
        ):
            scope = "infrastructure"
        if scope is None:
            scope = "unclassified"
            scope_evidence = EvidenceKind.INFERRED.value
            scope_source = "no application/infrastructure rule matched"

        annotated["coordinates"] = coordinate_records
        annotated["scope"] = scope
        annotated["scope_evidence"] = scope_evidence
        annotated["scope_source"] = scope_source
        if direct_coordinate is not None and tile_id is not None:
            mapped = self.simulator_coordinate(tile_id)
            if mapped is not None and mapped != direct_coordinate:
                annotated["coordinate_warning"] = (
                    f"direct PE coordinate {direct_coordinate} disagrees with tile mapping {mapped}"
                )
        return annotated


@dataclass(frozen=True)
class TraceWindow:
    """Inclusive device-cycle window, optionally modulo a wrapping counter."""

    start_cycle: int
    end_cycle: int
    counter_bits: int | None = None

    def __post_init__(self) -> None:
        if self.start_cycle < 0 or self.end_cycle < 0:
            raise ValueError("trace window cycles must be nonnegative")
        if self.counter_bits is None and self.end_cycle < self.start_cycle:
            raise ValueError("end_cycle precedes start_cycle without a wrapping counter")
        if self.counter_bits is not None:
            if not 1 <= self.counter_bits <= 64:
                raise ValueError("counter_bits must be between 1 and 64")
            modulus = 1 << self.counter_bits
            if self.start_cycle >= modulus or self.end_cycle >= modulus:
                raise ValueError("trace window endpoints do not fit the counter")

    @property
    def duration(self) -> int:
        if self.counter_bits is None:
            return self.end_cycle - self.start_cycle
        modulus = 1 << self.counter_bits
        return (self.end_cycle - self.start_cycle) % modulus

    def contains(self, cycle: int) -> bool:
        if self.counter_bits is None:
            return self.start_cycle <= cycle <= self.end_cycle
        modulus = 1 << self.counter_bits
        return (cycle - self.start_cycle) % modulus <= self.duration


@dataclass(frozen=True)
class CropResult:
    events: tuple[dict[str, Any], ...]
    seen: int
    kept: int
    before: int
    after: int
    timeless: int

    def stats(self) -> dict[str, Any]:
        return {
            "seen": self.seen,
            "kept": self.kept,
            "excluded_before": self.before,
            "excluded_after": self.after,
            "excluded_timeless": self.timeless,
        }


def crop_events(
    events: Iterable[Mapping[str, Any]],
    window: TraceWindow | None,
    *,
    include_timeless: bool = False,
) -> CropResult:
    kept: list[dict[str, Any]] = []
    seen = before = after = timeless = 0
    for event in events:
        seen += 1
        cycle_raw = event.get("cycle")
        if window is None:
            kept.append(dict(event))
            continue
        if cycle_raw is None:
            timeless += 1
            if include_timeless:
                copied = dict(event)
                copied["window_membership"] = "timeless"
                kept.append(copied)
            continue
        cycle = int(cycle_raw)
        if window.contains(cycle):
            kept.append(dict(event))
            continue
        if window.counter_bits is None:
            if cycle < window.start_cycle:
                before += 1
            else:
                after += 1
        else:
            elapsed = (cycle - window.start_cycle) % (1 << window.counter_bits)
            if elapsed > window.duration:
                after += 1
    return CropResult(tuple(kept), seen, len(kept), before, after, timeless)


class VerifiedWaveletFieldMap:
    """Explicit, source-attributed decoding for opaque wavelet ``fields``.

    Keys are exact raw 32-bit values.  No default SDK mapping is bundled because
    the stored CTF metadata does not define the bit slices.
    """

    def __init__(
        self,
        mapping: Mapping[int, Mapping[str, Any]],
        *,
        source: str,
        evidence: EvidenceKind | str = EvidenceKind.DOCUMENTED,
    ) -> None:
        if not source.strip():
            raise ValueError("a verified field mapping requires a source")
        self.mapping = {int(raw): dict(decoded) for raw, decoded in mapping.items()}
        self.source = source
        self.evidence = evidence_value(evidence)

    def decode(self, raw_fields: int) -> dict[str, Any] | None:
        decoded = self.mapping.get(int(raw_fields))
        if decoded is None:
            return None
        return {
            "values": dict(decoded),
            "evidence": self.evidence,
            "source": self.source,
        }


def _sim_coordinate(event: Mapping[str, Any]) -> tuple[int, int] | None:
    record = event.get("coordinates", {}).get("simulator") if event.get("coordinates") else None
    if not record:
        return None
    return int(record["x"]), int(record["y"])


def _direction(source: tuple[int, int], destination: tuple[int, int]) -> str | None:
    dx = destination[0] - source[0]
    dy = destination[1] - source[1]
    return {
        (0, 0): "LOCAL",
        (1, 0): "EAST",
        (-1, 0): "WEST",
        (0, 1): "SOUTH",
        (0, -1): "NORTH",
    }.get((dx, dy))


def _backpressure_index(events: Sequence[Mapping[str, Any]]) -> dict[tuple[int, int], list[dict[str, Any]]]:
    indexed: dict[tuple[int, int], list[dict[str, Any]]] = defaultdict(list)
    for event in events:
        if event.get("event_type") != "backpressure_trace_entry":
            continue
        if "tile_id" not in event or "cycle" not in event:
            continue
        indexed[(int(event["tile_id"]), int(event["cycle"]))].append(
            {
                "link_raw": event.get("link"),
                "back_pressure": event.get("back_pressure"),
                "evidence": EvidenceKind.SIMULATOR.value,
            }
        )
    return indexed


def _backpressure_timeline(
    events: Sequence[Mapping[str, Any]],
) -> dict[int, tuple[list[int], list[dict[str, Any]]]]:
    per_tile: dict[int, list[tuple[int, dict[str, Any]]]] = defaultdict(list)
    for event in events:
        if event.get("event_type") != "backpressure_trace_entry":
            continue
        if "tile_id" not in event or "cycle" not in event:
            continue
        per_tile[int(event["tile_id"])].append(
            (
                int(event["cycle"]),
                {
                    "cycle": int(event["cycle"]),
                    "link_raw": event.get("link"),
                    "back_pressure": event.get("back_pressure"),
                    "evidence": EvidenceKind.SIMULATOR.value,
                },
            )
        )
    timeline: dict[int, tuple[list[int], list[dict[str, Any]]]] = {}
    for tile, samples in per_tile.items():
        samples.sort(key=lambda item: item[0])
        timeline[tile] = ([cycle for cycle, _ in samples], [sample for _, sample in samples])
    return timeline


def _backpressure_between(
    timeline: Mapping[int, tuple[list[int], list[dict[str, Any]]]],
    tile_ids: Iterable[int],
    start_cycle: int,
    end_cycle: int,
) -> list[dict[str, Any]]:
    result: list[dict[str, Any]] = []
    for tile_id in sorted(set(tile_ids)):
        tile_timeline = timeline.get(tile_id)
        if tile_timeline is None:
            continue
        cycles, samples = tile_timeline
        start = bisect_left(cycles, start_cycle)
        end = bisect_right(cycles, end_cycle)
        for sample in samples[start:end]:
            result.append({"tile_id": tile_id, **sample})
    return result


def build_wavelet_groups(
    events: Sequence[Mapping[str, Any]],
    *,
    mapper: CoordinateMapper | None = None,
    field_map: VerifiedWaveletFieldMap | None = None,
) -> list[dict[str, Any]]:
    """Group wavelet observations by ``ident`` into conservative observed DAGs.

    Edges require the same ``ident``, nondecreasing cycle order, and identical or
    cardinally adjacent simulator coordinates.  When multiple predecessor
    candidates are equally recent all candidates are retained and marked
    ambiguous.  Thus multicast is representable without asserting an
    undocumented router-field interpretation.
    """

    annotated_events = [mapper.annotate(event) if mapper else dict(event) for event in events]
    backpressure = _backpressure_index(annotated_events)
    backpressure_timeline = _backpressure_timeline(annotated_events)
    grouped: dict[int, list[tuple[int, Mapping[str, Any]]]] = defaultdict(list)
    for source_index, event in enumerate(annotated_events):
        if event.get("event_type") == "wavelet_trace_entry" and "ident" in event:
            grouped[int(event["ident"])].append((source_index, event))

    results: list[dict[str, Any]] = []
    for ident in sorted(grouped):
        observations = sorted(
            grouped[ident],
            key=lambda item: (
                int(item[1].get("cycle", 0)),
                int(item[1].get("trace_timestamp", 0)),
                item[0],
            ),
        )
        nodes: list[dict[str, Any]] = []
        for ordinal, (source_index, event) in enumerate(observations):
            tile_id = event.get("tile_id", event.get("tile_index"))
            node: dict[str, Any] = {
                "node_id": f"{ident}:{ordinal}",
                "sequence": ordinal,
                "source_event_index": source_index,
                "cycle": int(event["cycle"]),
                "trace_timestamp": int(event.get("trace_timestamp", 0)),
                "tile_id": int(tile_id) if tile_id is not None else None,
                "coordinates": event.get("coordinates", {}),
                "scope": event.get("scope", "unclassified"),
                "scope_evidence": event.get("scope_evidence", EvidenceKind.INFERRED.value),
                "index": event.get("index"),
                "data": event.get("data"),
                "raw_fields": event.get("fields"),
                "color": None,
                "color_evidence": EvidenceKind.INFERRED.value,
                "color_source": "opaque wavelet fields were not decoded",
                "incoming_direction": None,
                "incoming_direction_evidence": EvidenceKind.INFERRED.value,
                "hop_delay_cycles": None,
                "hop_delay_evidence": EvidenceKind.INFERRED.value,
                "backpressure": [],
                "evidence": EvidenceKind.SIMULATOR.value,
            }
            if field_map is not None and event.get("fields") is not None:
                decoded = field_map.decode(int(event["fields"]))
                if decoded is not None:
                    node["decoded_fields"] = decoded
                    values = decoded["values"]
                    if "color" in values:
                        node["color"] = values["color"]
                        node["color_evidence"] = decoded["evidence"]
                        node["color_source"] = decoded["source"]
                    if "incoming_direction" in values:
                        node["incoming_direction"] = values["incoming_direction"]
                        node["incoming_direction_evidence"] = decoded["evidence"]
            if tile_id is not None:
                node["backpressure"] = backpressure.get(
                    (int(tile_id), int(event["cycle"])), []
                )
            nodes.append(node)

        edges: list[dict[str, Any]] = []
        parents: dict[str, list[str]] = defaultdict(list)
        children: dict[str, list[str]] = defaultdict(list)
        for child_index, child in enumerate(nodes):
            child_coordinate = _sim_coordinate(child)
            if child_index == 0 or child_coordinate is None:
                continue
            eligible: list[tuple[int, dict[str, Any], str]] = []
            for parent in nodes[:child_index]:
                parent_coordinate = _sim_coordinate(parent)
                if parent_coordinate is None or parent["cycle"] > child["cycle"]:
                    continue
                direction = _direction(parent_coordinate, child_coordinate)
                if direction is not None:
                    eligible.append((parent["cycle"], parent, direction))
            if not eligible:
                continue
            latest_cycle = max(item[0] for item in eligible)
            candidates = [item for item in eligible if item[0] == latest_cycle]
            ambiguous = len(candidates) > 1
            for _, parent, direction in candidates:
                edge = {
                    "source": parent["node_id"],
                    "destination": child["node_id"],
                    "direction": direction,
                    "direction_evidence": EvidenceKind.INFERRED.value,
                    "delay_cycles": child["cycle"] - parent["cycle"],
                    "delay_evidence": EvidenceKind.SIMULATOR.value,
                    "distance": 0 if direction == "LOCAL" else 1,
                    "ambiguous_predecessor": ambiguous,
                    "evidence": EvidenceKind.INFERRED.value,
                    "source_rule": "same ident plus latest cardinal/local predecessor",
                }
                endpoint_tiles = [
                    tile
                    for tile in (parent.get("tile_id"), child.get("tile_id"))
                    if tile is not None
                ]
                edge["ambient_backpressure"] = _backpressure_between(
                    backpressure_timeline,
                    (int(tile) for tile in endpoint_tiles),
                    int(parent["cycle"]),
                    int(child["cycle"]),
                )
                edge["ambient_backpressure_note"] = (
                    "samples on hop endpoint tiles during the observed interval; association is not causation"
                )
                edges.append(edge)
                parents[child["node_id"]].append(parent["node_id"])
                children[parent["node_id"]].append(child["node_id"])

        by_id = {node["node_id"]: node for node in nodes}
        roots = [node["node_id"] for node in nodes if not parents[node["node_id"]]]
        branch_counter = 0
        assigned: dict[str, int | None] = {}

        def assign_branch(node_id: str, branch: int) -> None:
            nonlocal branch_counter
            if len(parents[node_id]) > 1:
                assigned[node_id] = None
                return
            if node_id in assigned:
                return
            assigned[node_id] = branch
            ordered_children = sorted(
                children[node_id], key=lambda child_id: (by_id[child_id]["cycle"], child_id)
            )
            for position, child_id in enumerate(ordered_children):
                child_branch = branch
                if position:
                    branch_counter += 1
                    child_branch = branch_counter
                assign_branch(child_id, child_branch)

        for root in roots:
            if root in assigned:
                continue
            if assigned:
                branch_counter += 1
            assign_branch(root, branch_counter)

        unique_edge_by_destination = {
            edge["destination"]: edge
            for edge in edges
            if len(parents[edge["destination"]]) == 1
        }
        for node in nodes:
            node["branch"] = assigned.get(node["node_id"])
            node["branch_evidence"] = EvidenceKind.INFERRED.value
            edge = unique_edge_by_destination.get(node["node_id"])
            if edge:
                inferred_direction = edge["direction"]
                node["hop_delay_cycles"] = edge["delay_cycles"]
                node["hop_delay_evidence"] = EvidenceKind.SIMULATOR.value
                if node["incoming_direction"] is None:
                    node["incoming_direction"] = inferred_direction
                    node["incoming_direction_evidence"] = EvidenceKind.INFERRED.value
                elif node["incoming_direction"] != inferred_direction:
                    node["direction_warning"] = (
                        f"decoded {node['incoming_direction']} disagrees with coordinate path "
                        f"{inferred_direction}"
                    )

        leaves = [node["node_id"] for node in nodes if not children[node["node_id"]]]
        ambiguous_nodes = sorted(node_id for node_id, values in parents.items() if len(values) > 1)
        scopes = sorted({str(node.get("scope", "unclassified")) for node in nodes})
        if len(scopes) == 1:
            traffic_class = scopes[0]
        elif "unclassified" in scopes:
            traffic_class = "partially-unclassified"
        else:
            traffic_class = "mixed"
        results.append(
            {
                "schema_version": SCHEMA_VERSION,
                "record_type": "observed_wavelet_dag",
                "ident": ident,
                "nodes": nodes,
                "edges": edges,
                "roots": roots,
                "leaves": leaves,
                "branch_count": len({branch for branch in assigned.values() if branch is not None}),
                "ambiguous_nodes": ambiguous_nodes,
                "scopes": scopes,
                "traffic_class": traffic_class,
                "traffic_class_evidence": EvidenceKind.INFERRED.value,
                "evidence": EvidenceKind.SIMULATOR.value,
                "graph_evidence": EvidenceKind.INFERRED.value,
                "graph_semantics": (
                    "nodes are simulator observations; edges use ident, time, and cardinal/local "
                    "adjacency; opaque router fields are not decoded without an explicit map"
                ),
            }
        )
    return results


def summarize_backpressure(events: Sequence[Mapping[str, Any]]) -> dict[str, Any]:
    buckets: dict[tuple[int, int], list[int]] = defaultdict(list)
    for event in events:
        if event.get("event_type") != "backpressure_trace_entry":
            continue
        if "tile_id" not in event or "link" not in event or "back_pressure" not in event:
            continue
        buckets[(int(event["tile_id"]), int(event["link"]))].append(int(event["back_pressure"]))
    records = []
    for (tile_id, link), samples in sorted(buckets.items()):
        records.append(
            {
                "tile_id": tile_id,
                "link_raw": link,
                "samples": len(samples),
                "nonzero_samples": sum(value > 0 for value in samples),
                "nonzero_fraction": sum(value > 0 for value in samples) / len(samples),
                "maximum": max(samples),
                "evidence": EvidenceKind.SIMULATOR.value,
                "note": "link is intentionally raw until an SDK-verified enum mapping is supplied",
            }
        )
    return {"tile_links": records, "evidence": EvidenceKind.SIMULATOR.value}


def summarize_tasks(events: Sequence[Mapping[str, Any]]) -> dict[str, Any]:
    dispatches: dict[int, list[Mapping[str, Any]]] = defaultdict(list)
    pipes: Counter[int] = Counter()
    pipe_stages: dict[int, Counter[int]] = defaultdict(Counter)
    simd_indices: dict[int, Counter[int]] = defaultdict(Counter)
    for event in events:
        tile_id = event.get("tile_id")
        if tile_id is None:
            continue
        tile = int(tile_id)
        if event.get("event_type") == "hwm_dispatch_trace_entry":
            dispatches[tile].append(event)
        elif event.get("event_type") == "hwm_pipe_trace_entry":
            pipes[tile] += 1
            if event.get("stage") is not None:
                pipe_stages[tile][int(event["stage"])] += 1
            if event.get("simdi") is not None:
                simd_indices[tile][int(event["simdi"])] += 1

    records = []
    for tile in sorted(set(dispatches) | set(pipes)):
        tile_dispatches = dispatches[tile]
        cycles = [int(event["cycle"]) for event in tile_dispatches if "cycle" in event]
        names = Counter(str(event.get("name", "")) for event in tile_dispatches if event.get("name"))
        task_colors = Counter(
            int(event["task_color"]) for event in tile_dispatches if event.get("task_color") is not None
        )
        microthreads = Counter(
            int(event["ut_id"]) for event in tile_dispatches if event.get("ut_id") is not None
        )
        span = max(cycles) - min(cycles) + 1 if cycles else 0
        records.append(
            {
                "tile_id": tile,
                "dispatches": len(tile_dispatches),
                "first_cycle": min(cycles) if cycles else None,
                "last_cycle": max(cycles) if cycles else None,
                "span_cycles": span,
                "dispatch_density": len(tile_dispatches) / span if span else None,
                "dispatch_density_evidence": EvidenceKind.INFERRED.value,
                "instruction_names": dict(sorted(names.items())),
                "task_colors": {str(key): value for key, value in sorted(task_colors.items())},
                "microthread_ids": {str(key): value for key, value in sorted(microthreads.items())},
                "pipeline_events": pipes[tile],
                "pipeline_stages_raw": {
                    str(key): value for key, value in sorted(pipe_stages[tile].items())
                },
                "simd_indices_raw": {
                    str(key): value for key, value in sorted(simd_indices[tile].items())
                },
                "evidence": EvidenceKind.SIMULATOR.value,
            }
        )
    return {"tiles": records, "evidence": EvidenceKind.SIMULATOR.value}


def _percentile_nearest_rank(values: Sequence[int], fraction: float) -> int | None:
    if not values:
        return None
    ordered = sorted(values)
    index = max(0, math.ceil(fraction * len(ordered)) - 1)
    return ordered[index]


def summarize_wavelets(
    groups: Sequence[Mapping[str, Any]],
    events: Sequence[Mapping[str, Any]] = (),
) -> dict[str, Any]:
    delays: list[int] = []
    scope_counts: Counter[str] = Counter()
    for group in groups:
        for node in group.get("nodes", []):
            scope_counts[str(node.get("scope", "unclassified"))] += 1
        for edge in group.get("edges", []):
            if not edge.get("ambiguous_predecessor"):
                delays.append(int(edge["delay_cycles"]))
    landing_by_pe_color: Counter[tuple[int, int, int]] = Counter()
    counter_totals: Counter[str] = Counter()
    counter_records = 0
    for event in events:
        if event.get("event_type") == "wavelet_entry":
            if all(name in event for name in ("PE_x", "PE_y", "color")):
                landing_by_pe_color[
                    (int(event["PE_x"]), int(event["PE_y"]), int(event["color"]))
                ] += 1
        elif event.get("event_type") == "debug_counters_wavelet":
            counter_records += 1
            for name in ("count_w", "count_t", "count_s"):
                if event.get(name) is not None:
                    counter_totals[name] += int(event[name])

    return {
        "groups": len(groups),
        "observations": sum(len(group.get("nodes", [])) for group in groups),
        "edges": sum(len(group.get("edges", [])) for group in groups),
        "branched_groups": sum(int(group.get("branch_count", 0)) > 1 for group in groups),
        "ambiguous_groups": sum(bool(group.get("ambiguous_nodes")) for group in groups),
        "scope_observations": dict(sorted(scope_counts.items())),
        "landing_events": sum(landing_by_pe_color.values()),
        "landing_by_pe_color": [
            {
                "simulator_x": x,
                "simulator_y": y,
                "color": color,
                "count": count,
                "evidence": EvidenceKind.SIMULATOR.value,
            }
            for (x, y, color), count in sorted(landing_by_pe_color.items())
        ],
        "debug_counter_records": counter_records,
        "debug_counter_totals": dict(sorted(counter_totals.items())),
        "hop_delay_cycles": {
            "count": len(delays),
            "minimum": min(delays) if delays else None,
            "median": _percentile_nearest_rank(delays, 0.5),
            "p95": _percentile_nearest_rank(delays, 0.95),
            "maximum": max(delays) if delays else None,
            "evidence": EvidenceKind.SIMULATOR.value,
        },
        "evidence": EvidenceKind.SIMULATOR.value,
    }


def build_flow_overlay(
    groups: Sequence[Mapping[str, Any]],
    events: Sequence[Mapping[str, Any]] = (),
) -> dict[str, Any]:
    """Aggregate trace observations for SVG volume, latency, and hotspot layers.

    The path association is inherited from the conservative wavelet DAG and is
    therefore ``inferred``.  Counts and cycle deltas themselves are simulator
    observations.  No overlay is emitted for nodes lacking a compiled fabric
    coordinate.
    """

    links: dict[tuple[int, int, int, int, str], dict[str, Any]] = {}
    fallback_activity: Counter[tuple[int, int]] = Counter()
    for group in groups:
        nodes = {str(node["node_id"]): node for node in group.get("nodes", [])}
        for node in nodes.values():
            fabric = (node.get("coordinates") or {}).get("fabric") or {}
            if "x" in fabric and "y" in fabric:
                fallback_activity[(int(fabric["x"]), int(fabric["y"]))] += 1
        for edge in group.get("edges", []):
            source = nodes.get(str(edge.get("source")))
            destination = nodes.get(str(edge.get("destination")))
            if not source or not destination or edge.get("direction") == "LOCAL":
                continue
            source_fabric = (source.get("coordinates") or {}).get("fabric") or {}
            target_fabric = (destination.get("coordinates") or {}).get("fabric") or {}
            if not all(key in source_fabric and key in target_fabric for key in ("x", "y")):
                continue
            key = (
                int(source_fabric["x"]),
                int(source_fabric["y"]),
                int(target_fabric["x"]),
                int(target_fabric["y"]),
                str(edge.get("direction") or "UNKNOWN"),
            )
            record = links.setdefault(
                key,
                {
                    "delays": [],
                    "observations": 0,
                    "ambiguous_observations": 0,
                    "nonzero_backpressure_samples": 0,
                },
            )
            record["observations"] += 1
            record["ambiguous_observations"] += int(bool(edge.get("ambiguous_predecessor")))
            if edge.get("delay_cycles") is not None:
                record["delays"].append(int(edge["delay_cycles"]))
            record["nonzero_backpressure_samples"] += sum(
                int(sample.get("back_pressure", 0) or 0) > 0
                for sample in edge.get("ambient_backpressure", [])
            )

    link_records: list[dict[str, Any]] = []
    for (sx, sy, tx, ty, direction), values in sorted(links.items()):
        delays = values.pop("delays")
        link_records.append(
            {
                "from": {"x": sx, "y": sy},
                "to": {"x": tx, "y": ty},
                "direction": direction,
                **values,
                "median_delay_cycles": _percentile_nearest_rank(delays, 0.5),
                "p95_delay_cycles": _percentile_nearest_rank(delays, 0.95),
                "latency_evidence": EvidenceKind.SIMULATOR.value,
                "evidence": EvidenceKind.INFERRED.value,
                "source": "observed wavelet DAG ident/time/cardinal adjacency",
            }
        )

    activity: Counter[tuple[int, int]] = Counter()
    for event in events:
        fabric = (event.get("coordinates") or {}).get("fabric") or {}
        if event.get("scope") == "application" and "x" in fabric and "y" in fabric:
            activity[(int(fabric["x"]), int(fabric["y"]))] += 1
    if not activity:
        activity = fallback_activity
    pe_records = [
        {
            "fabric": {"x": x, "y": y},
            "event_observations": count,
            "evidence": EvidenceKind.SIMULATOR.value,
            "source": "decoded trace events in application scope",
        }
        for (x, y), count in sorted(activity.items())
    ]
    return {
        "record_type": "simulator-flow-overlay",
        "links": link_records,
        "pes": pe_records,
        "evidence": EvidenceKind.INFERRED.value,
        "limitations": (
            "link membership follows inferred wavelet DAG edges; volume is observed-path "
            "count, not a silicon link counter"
        ),
    }


def decode_trace(
    stream0_path: str | os.PathLike[str],
    *,
    metadata_path: str | os.PathLike[str] | None = None,
    mapper: CoordinateMapper | None = None,
    window: TraceWindow | None = None,
    include_timeless: bool = False,
    field_map: VerifiedWaveletFieldMap | None = None,
    window_evidence: EvidenceKind | str = EvidenceKind.SIMULATOR,
    window_source: str = "caller-provided simulator device TSC window",
    strict: bool = True,
) -> dict[str, Any]:
    """Decode, crop, classify, group, and summarize a simulator trace."""

    reader = CtfTraceReader(stream0_path, metadata_path, strict=strict)
    cropped = crop_events(reader.iter_events(), window, include_timeless=include_timeless)
    events = [mapper.annotate(event) if mapper else dict(event) for event in cropped.events]
    groups = build_wavelet_groups(events, field_map=field_map)
    counts = Counter(str(event["event_type"]) for event in events)
    scope_counts: dict[str, Counter[str]] = defaultdict(Counter)
    for event in events:
        scope_counts[str(event.get("event_type", "unknown"))][
            str(event.get("scope", "unclassified"))
        ] += 1
    return {
        "schema_version": SCHEMA_VERSION,
        "record_type": "simulator_trace_report",
        "evidence": EvidenceKind.SIMULATOR.value,
        "source": {
            "stream0": str(reader.stream0_path.resolve()),
            "stream0_sha256": hash_file(reader.stream0_path),
            "metadata": reader.metadata.source,
            "metadata_sha256": reader.metadata.sha256,
        },
        "trace_integrity": {
            "status": "incomplete" if reader.discarded_events_total else "complete",
            "discarded_events": reader.discarded_events_total,
            "discarded_events_by_stream": {
                str(stream): count
                for stream, count in sorted(reader.discarded_events_by_stream.items())
            },
            "evidence": EvidenceKind.SIMULATOR.value,
            "source": "CTF packet events_discarded cumulative counters",
        },
        "window": (
            {
                "start_cycle": window.start_cycle,
                "end_cycle": window.end_cycle,
                "counter_bits": window.counter_bits,
                "duration_cycles": window.duration,
                "evidence": evidence_value(window_evidence),
                "source": window_source,
            }
            if window
            else None
        ),
        "crop": cropped.stats(),
        "event_counts": dict(sorted(counts.items())),
        "event_scope_counts": {
            event_type: dict(sorted(scopes.items()))
            for event_type, scopes in sorted(scope_counts.items())
        },
        "events": events,
        "wavelets": groups,
        "summaries": {
            "wavelets": summarize_wavelets(groups, events),
            "backpressure": summarize_backpressure(events),
            "tasks": summarize_tasks(events),
        },
        "warnings": list(reader.warnings),
        "limitations": [
            "wavelet fields and backpressure link enums remain raw unless an explicit source-attributed map is supplied",
            "observed wavelet DAG edges are inferred from ident/time/cardinal adjacency, not decoded router switch bits",
            "events without a cycle are excluded from a timed window unless include_timeless is enabled",
            "trace window endpoints must be translated into the simulator trace cycle domain before cropping",
        ],
    }


def _write_jsonl_gz(
    path: str | os.PathLike[str], records: Iterable[Mapping[str, Any]]
) -> Path:
    target = Path(path)
    target.parent.mkdir(parents=True, exist_ok=True)
    fd, temporary_name = tempfile.mkstemp(prefix=f".{target.name}.", dir=target.parent)
    try:
        with os.fdopen(fd, "wb") as raw_handle:
            with gzip.GzipFile(fileobj=raw_handle, mode="wb", filename="", mtime=0) as compressed:
                with io.TextIOWrapper(compressed, encoding="utf-8", newline="\n") as text_handle:
                    for record in records:
                        json.dump(record, text_handle, sort_keys=True, separators=(",", ":"))
                        text_handle.write("\n")
        os.replace(temporary_name, target)
    except BaseException:
        try:
            os.unlink(temporary_name)
        except OSError:
            pass
        raise
    return target


def write_wavelets_jsonl_gz(
    path: str | os.PathLike[str], groups: Iterable[Mapping[str, Any]]
) -> Path:
    """Atomically write one observed wavelet DAG per deterministic gzip JSONL line."""

    def checked() -> Iterator[Mapping[str, Any]]:
        for index, group in enumerate(groups):
            errors = validate_wavelet_contract(group)
            if errors:
                raise TraceFormatError(
                    f"wavelet group {index} violates output contract: {'; '.join(errors)}"
                )
            yield group

    return _write_jsonl_gz(path, checked())


def write_events_jsonl_gz(
    path: str | os.PathLike[str], events: Iterable[Mapping[str, Any]]
) -> Path:
    """Persist decoded instruction/router/backpressure records, not only summaries."""

    return _write_jsonl_gz(path, events)


__all__ = [
    "CTF_MAGIC",
    "CoordinateMapper",
    "CropResult",
    "CtfEventSchema",
    "CtfField",
    "CtfMetadata",
    "CtfTraceReader",
    "Rectangle",
    "TraceFormatError",
    "TraceWindow",
    "VerifiedWaveletFieldMap",
    "build_flow_overlay",
    "build_wavelet_groups",
    "crop_events",
    "decode_trace",
    "summarize_backpressure",
    "summarize_tasks",
    "summarize_wavelets",
    "write_events_jsonl_gz",
    "write_wavelets_jsonl_gz",
]
