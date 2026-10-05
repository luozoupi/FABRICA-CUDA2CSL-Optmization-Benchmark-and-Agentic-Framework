"""Deterministic SDK 2.10 bundle generation for WSE-3 calibration cases.

The matrix in :mod:`wse3study.calibration` states what the study would like to
measure.  This module is the deliberately stricter implementation boundary: a
case is materialized only when the generated CSL actually implements every
parameter that would affect the measurement.  Unsupported cases receive a
machine-readable manifest and no runnable command, so an orchestration layer
cannot accidentally turn a placeholder into silicon evidence.

Generation never compiles, runs, or submits a job.  Canonical xkernel bundles
are neither read nor modified.
"""

from __future__ import annotations

from dataclasses import asdict, dataclass
import hashlib
import json
import os
from pathlib import Path
import shutil
from typing import Any, Iterable, Mapping

from .calibration import CalibrationCase


SCHEMA_VERSION = "1.0.0"
FABRIC_DIMS = (762, 1172)
FABRIC_OFFSETS = (4, 1)
SUPPORTED_DIRECTIONS = ("north", "south", "east", "west")
_DIRECTION_VECTOR = {
    "north": (0, -1),
    "south": (0, 1),
    "east": (1, 0),
    "west": (-1, 0),
}
_OPPOSITE_DIRECTION = {
    "north": "south",
    "south": "north",
    "east": "west",
    "west": "east",
}
_CSL_DIRECTION = {name: name.upper() for name in SUPPORTED_DIRECTIONS}
_MICROTHREAD_ID_COUNT = 8   # WSE-3 exposes ut_id 0..7
_TRAFFIC_COLOR_BASE = 5
_QUEUE_IDS = tuple(range(8))
# ``<memcpy/memcpy>`` initializes these queue resources on every PE in the
# generated rectangle.  Input and output queue namespaces are independent, but
# this generator intentionally uses the same numeric ID for each bidirectional
# traffic/sync pair.  Its safe pool is therefore their intersection, 2..7.
# See docs/WSE3_PORTING.md and the SDK WSE-3 memcpy examples.
_MEMCPY_RESERVED_INPUT_QUEUES = frozenset((0, 1))
_MEMCPY_RESERVED_OUTPUT_QUEUES = frozenset((0,))
_DUPLEX_USER_QUEUE_IDS = tuple(
    queue
    for queue in _QUEUE_IDS
    if queue not in _MEMCPY_RESERVED_INPUT_QUEUES
    and queue not in _MEMCPY_RESERVED_OUTPUT_QUEUES
)
_CONTENTION_DONE_TASK_IDS = (19, 20, 24, 25)

_STUDY_ROOT = Path(__file__).resolve().parents[1]
_OFFICIAL_SYNC = _STUDY_ROOT / "calibration" / "official_sync"


class CalibrationCodegenError(ValueError):
    """A case or destination cannot be materialized safely."""


@dataclass(frozen=True)
class SupportDecision:
    supported: bool
    status: str
    template: str | None
    reason: str | None = None


@dataclass(frozen=True)
class GeneratedCalibrationBundle:
    path: str
    case_id: str
    family: str
    status: str
    supported: bool
    reason: str | None
    manifest_path: str
    bundle_sha256: str


def _case_dict(case: CalibrationCase | Mapping[str, Any]) -> dict[str, Any]:
    if isinstance(case, CalibrationCase):
        value = case.to_dict()
    elif isinstance(case, Mapping):
        value = dict(case)
    else:
        raise CalibrationCodegenError("case must be CalibrationCase or a mapping")
    family = str(value.get("family", "")).strip()
    case_id = str(value.get("case_id", "")).strip()
    parameters = value.get("parameters")
    if not family or not case_id or not isinstance(parameters, Mapping):
        raise CalibrationCodegenError(
            "case requires non-empty family/case_id and mapping parameters"
        )
    return {
        "family": family,
        "case_id": case_id,
        "parameters": dict(parameters),
        "split": str(value.get("split", "characterization")),
        "warmups": int(value.get("warmups", 5)),
        "trials": int(value.get("trials", 100)),
    }


def _positive_int(parameters: Mapping[str, Any], name: str) -> int:
    try:
        value = int(parameters[name])
    except (KeyError, TypeError, ValueError) as exc:
        raise CalibrationCodegenError(f"{name} must be a positive integer") from exc
    if value <= 0:
        raise CalibrationCodegenError(f"{name} must be a positive integer")
    return value


def _single_pe_capability(parameters: Mapping[str, Any]) -> SupportDecision:
    if bool(parameters.get("compile_only")) or "allocation_bytes" in parameters:
        try:
            allocation = int(parameters["allocation_bytes"])
        except (KeyError, TypeError, ValueError):
            return SupportDecision(False, "unsupported", None, "invalid allocation_bytes")
        if allocation <= 0:
            return SupportDecision(False, "unsupported", None, "allocation_bytes must be positive")
        return SupportDecision(True, "compile_only", "single-pe-sram")

    operation = str(parameters.get("operation", ""))
    dtype = str(parameters.get("dtype", ""))
    mode = str(parameters.get("mode", ""))
    if operation not in {"copy", "add", "multiply", "fma", "reduction"}:
        return SupportDecision(False, "unsupported", None, f"unknown operation {operation!r}")
    if dtype not in {"fp16", "fp32", "i16", "i32"}:
        return SupportDecision(False, "unsupported", None, f"unknown dtype {dtype!r}")
    if mode not in {"scalar", "dsd"}:
        return SupportDecision(False, "unsupported", None, f"unknown mode {mode!r}")

    try:
        vector_length = int(parameters.get("vector_length", 0))
        stride = int(parameters.get("stride", 1))
        alignment = int(parameters.get("bank_alignment", 0))
        chains = int(parameters.get("dependency_chains", 1))
        microthreads = int(parameters.get("microthreads", 1))
        queue_id = int(parameters.get("queue_id", 0))
    except (TypeError, ValueError):
        return SupportDecision(False, "unsupported", None, "non-integer single-PE parameter")
    if vector_length <= 0 or stride <= 0 or alignment < 0 or chains <= 0:
        return SupportDecision(False, "unsupported", None, "invalid vector/stride/alignment/chains")
    if microthreads not in {1, 2, 4, 8}:
        return SupportDecision(False, "unsupported", None, "microthreads must be 1, 2, 4, or 8")
    if not 0 <= queue_id <= 7:
        return SupportDecision(False, "unsupported", None, "queue_id must be in 0..7")
    if queue_id != 0:
        return SupportDecision(
            False,
            "unsupported",
            None,
            "local memory DSDs do not consume a fabric queue; a queue sweep needs a dedicated fabric template",
        )
    if mode == "scalar" and microthreads != 1:
        return SupportDecision(False, "unsupported", None, "scalar code has no asynchronous DSD microthread")
    if mode == "dsd" and microthreads > 1 and chains not in {1, microthreads}:
        return SupportDecision(
            False,
            "unsupported",
            None,
            "mixed chain/microthread counts need a batched dependency scheduler; this template never ignores either knob",
        )
    if operation == "fma" and dtype not in {"fp16", "fp32"}:
        return SupportDecision(False, "unsupported", None, "SDK floating FMA has no integer form")
    if mode == "dsd":
        supported = {
            "copy": {"fp16", "fp32", "i16", "i32"},
            "add": {"fp16", "fp32", "i16"},
            "multiply": {"fp16", "fp32"},
            "fma": {"fp16", "fp32"},
            "reduction": {"fp16", "fp32", "i16"},
        }
        if dtype not in supported[operation]:
            return SupportDecision(
                False,
                "unsupported",
                None,
                f"SDK 2.10 exposes no {dtype} DSD primitive for {operation}",
            )
        if operation == "reduction" and (vector_length & (vector_length - 1)):
            return SupportDecision(False, "unsupported", None, "DSD reduction requires a power-of-two vector length")
        if operation == "reduction" and (chains != 1 or microthreads != 1):
            return SupportDecision(False, "unsupported", None, "pairwise DSD reduction is single-chain/single-microthread")
    return SupportDecision(True, "runnable", "single-pe")


def support_for_case(case: CalibrationCase | Mapping[str, Any]) -> SupportDecision:
    value = _case_dict(case)
    family = value["family"]
    parameters = value["parameters"]
    if family == "straight":
        direction = str(parameters.get("direction", ""))
        if direction not in SUPPORTED_DIRECTIONS:
            return SupportDecision(False, "unsupported", None, f"unknown direction {direction!r}")
        try:
            hops = int(parameters.get("hops", 0))
            payload = int(parameters.get("payload_wavelets", 0))
        except (TypeError, ValueError):
            return SupportDecision(False, "unsupported", None, "hops/payload must be integers")
        if hops <= 0 or payload <= 0:
            return SupportDecision(False, "unsupported", None, "hops/payload must be positive")
        max_hops = FABRIC_DIMS[1] - FABRIC_OFFSETS[1] - 2 if direction in {"north", "south"} else FABRIC_DIMS[0] - FABRIC_OFFSETS[0] - 3
        if hops > max_hops:
            return SupportDecision(False, "unsupported", None, "path does not fit the ALCF compile fabric")
        if payload > 4096:
            return SupportDecision(False, "unsupported", None, "payload exceeds calibrated 4096-wavelet template limit")
        return SupportDecision(True, "runnable", "straight")
    if family == "turn":
        return _turn_capability(parameters)
    if family == "multicast":
        return _multicast_capability(parameters)
    if family == "contention":
        return _contention_capability(parameters)
    if family.startswith("single-pe"):
        return _single_pe_capability(parameters)
    return SupportDecision(False, "unsupported", None, f"no code generator for family {family!r}")


def _rectangle_fits(width: int, height: int) -> bool:
    """Apply the same conservative memcpy/fabric margin as straight paths."""

    usable_width = FABRIC_DIMS[0] - FABRIC_OFFSETS[0] - 3
    usable_height = FABRIC_DIMS[1] - FABRIC_OFFSETS[1] - 2
    return 2 <= width <= usable_width and 2 <= height <= usable_height


def _turn_capability(parameters: Mapping[str, Any]) -> SupportDecision:
    first = str(parameters.get("first_direction", ""))
    second = str(parameters.get("second_direction", ""))
    if first not in SUPPORTED_DIRECTIONS or second not in SUPPORTED_DIRECTIONS:
        return SupportDecision(False, "unsupported", None, "turn directions must be north/south/east/west")
    first_vector = _DIRECTION_VECTOR[first]
    second_vector = _DIRECTION_VECTOR[second]
    if first_vector[0] * second_vector[0] + first_vector[1] * second_vector[1] != 0:
        return SupportDecision(False, "unsupported", None, "turn legs must be orthogonal cardinal directions")
    try:
        first_hops = int(parameters.get("first_hops", 0))
        second_hops = int(parameters.get("second_hops", 0))
        payload = int(parameters.get("payload_wavelets", 0))
        turns = int(parameters.get("turns", 1))
    except (TypeError, ValueError):
        return SupportDecision(False, "unsupported", None, "turn hops/payload/turns must be integers")
    if first_hops <= 0 or second_hops <= 0 or payload <= 0:
        return SupportDecision(False, "unsupported", None, "turn hops/payload must be positive")
    if turns != 1:
        return SupportDecision(False, "unsupported", None, "the L-path generator implements exactly one turn")
    if payload > 4096:
        return SupportDecision(False, "unsupported", None, "payload exceeds calibrated 4096-wavelet template limit")
    path = _cardinal_path(((first, first_hops), (second, second_hops)))
    width, height, _, _ = _shift_path_to_rectangle(path)
    if not _rectangle_fits(width, height):
        return SupportDecision(False, "unsupported", None, "turn rectangle does not fit the ALCF compile fabric")
    return SupportDecision(True, "runnable", "turn")


def _multicast_capability(parameters: Mapping[str, Any]) -> SupportDecision:
    direction = str(parameters.get("trunk_direction", ""))
    if direction not in SUPPORTED_DIRECTIONS:
        return SupportDecision(False, "unsupported", None, "multicast trunk_direction must be cardinal")
    try:
        hops = int(parameters.get("trunk_hops", 0))
        fanout = int(parameters.get("fanout", 0))
        payload = int(parameters.get("payload_wavelets", 0))
    except (TypeError, ValueError):
        return SupportDecision(False, "unsupported", None, "multicast hops/fanout/payload must be integers")
    if hops <= 0 or fanout <= 0 or payload <= 0:
        return SupportDecision(False, "unsupported", None, "multicast hops/fanout/payload must be positive")
    if fanout > hops:
        return SupportDecision(False, "unsupported", None, "fanout cannot exceed the number of non-source trunk PEs")
    if payload > 4096:
        return SupportDecision(False, "unsupported", None, "payload exceeds calibrated 4096-wavelet template limit")
    width, height, _, _ = _straight_geometry(direction, hops)
    if not _rectangle_fits(width, height):
        return SupportDecision(False, "unsupported", None, "multicast trunk does not fit the ALCF compile fabric")
    return SupportDecision(True, "runnable", "multicast")


def _contention_capability(parameters: Mapping[str, Any]) -> SupportDecision:
    try:
        hops = int(parameters.get("path_hops", 0))
        payload = int(parameters.get("payload_wavelets", 0))
        sources = int(parameters.get("sources", 0))
        queue_id = int(parameters.get("queue_id", -1))
        microthreads = int(parameters.get("microthreads", 0))
        receiver_delay = int(parameters.get("receiver_delay_cycles", -1))
    except (TypeError, ValueError):
        return SupportDecision(False, "unsupported", None, "contention parameters must have integer counts")
    color_mode = str(parameters.get("color_mode", ""))
    if color_mode == "same" and sources > 1:
        # A WSE-3 router accepts at most ONE input direction per colour.  Merging
        # several sources onto a single shared colour requires the convergence PE to
        # receive that colour from two directions at once, which the compiler rejects:
        #   "expected at most 1 input direction(s) on 'wse3', got: 2".
        # This is an architectural limit of the fabric, not a gap in this generator.
        # Multi-source contention must therefore use distinct colours per source.
        return SupportDecision(
            False,
            "unsupported",
            None,
            "wse3 routers accept at most one input direction per colour, so "
            f"{sources} sources cannot share one colour; use color_mode='distinct'",
        )
    if hops <= 0 or payload <= 0:
        return SupportDecision(False, "unsupported", None, "path_hops/payload_wavelets must be positive")
    if sources not in {1, 2, 4, 8}:
        return SupportDecision(False, "unsupported", None, "sources must be 1, 2, 4, or 8")
    if color_mode not in {"same", "distinct"}:
        return SupportDecision(False, "unsupported", None, "color_mode must be same or distinct")
    if queue_id not in _QUEUE_IDS:
        return SupportDecision(False, "unsupported", None, "queue_id must be in 0..7")
    if queue_id not in _DUPLEX_USER_QUEUE_IDS:
        return SupportDecision(
            False,
            "unsupported",
            None,
            f"requested queue_id {queue_id} collides with <memcpy>: input queues 0/1 and output queue 0 are reserved; the memcpy-backed generator does not remap a queue sweep",
        )
    if microthreads not in {1, 2, 4, 8}:
        return SupportDecision(False, "unsupported", None, "microthreads must be 1, 2, 4, or 8")
    if receiver_delay < 0:
        return SupportDecision(False, "unsupported", None, "receiver_delay_cycles must be non-negative")
    if payload % microthreads:
        return SupportDecision(False, "unsupported", None, "payload must divide evenly across the requested microthreads")
    if payload > 4096:
        return SupportDecision(False, "unsupported", None, "payload exceeds calibrated 4096-wavelet per-source limit")
    if sources > hops:
        return SupportDecision(False, "unsupported", None, "the equal-hop merge topology requires sources <= path_hops")
    width, height = hops + 1, max(2, sources)
    if not _rectangle_fits(width, height):
        return SupportDecision(False, "unsupported", None, "contention rectangle does not fit the ALCF compile fabric")
    if (sources + 1) * payload * 4 > 32 * 1024:
        return SupportDecision(False, "unsupported", None, "generated source/receive buffers exceed the conservative 32 KiB data budget")
    traffic_count = sources if color_mode == "distinct" else 1
    if traffic_count + 3 > len(_DUPLEX_USER_QUEUE_IDS):
        return SupportDecision(
            False,
            "unsupported",
            None,
            f"{traffic_count} traffic queue(s) plus three official-sync queues exceed the six duplex-safe IDs 2..7 left by <memcpy>",
        )
    traffic_queues = _traffic_queue_ids(queue_id, traffic_count)
    if len(set(_DUPLEX_USER_QUEUE_IDS) - set(traffic_queues)) < 3:
        return SupportDecision(False, "unsupported", None, "no three collision-free official-sync queues remain after traffic allocation")
    if color_mode == "distinct" and sources > len(_CONTENTION_DONE_TASK_IDS):
        return SupportDecision(False, "unsupported", None, "distinct receive completion has only four non-reserved task IDs")
    return SupportDecision(True, "runnable", "contention")


def _sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def _json_bytes(value: Any) -> bytes:
    return (json.dumps(value, indent=2, sort_keys=True, separators=(",", ": ")) + "\n").encode("utf-8")


def _write(path: Path, data: str | bytes, *, executable: bool = False) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    payload = data.encode("utf-8") if isinstance(data, str) else data
    path.write_bytes(payload)
    if executable:
        path.chmod(0o755)


def _file_inventory(root: Path) -> dict[str, str]:
    result: dict[str, str] = {}
    for path in sorted(root.rglob("*")):
        if path.is_file() and path.name != "manifest.json":
            result[path.relative_to(root).as_posix()] = _sha256(path.read_bytes())
    return result


def _safe_destination(destination: str | os.PathLike[str], overwrite: bool) -> Path:
    target = Path(destination).resolve()
    if target.exists():
        if not overwrite:
            raise FileExistsError(f"refusing to overwrite calibration bundle: {target}")
        if not (target / ".wse3-calibration-bundle").is_file():
            raise CalibrationCodegenError(f"refusing to replace unrecognized directory: {target}")
        shutil.rmtree(target)
    target.mkdir(parents=True)
    _write(target / ".wse3-calibration-bundle", "generated by wse3study.calibration_codegen\n")
    return target


def materialize_calibration_bundle(
    case: CalibrationCase | Mapping[str, Any],
    destination: str | os.PathLike[str],
    *,
    overwrite: bool = False,
) -> GeneratedCalibrationBundle:
    """Materialize one isolated bundle without compiling or submitting it."""

    value = _case_dict(case)
    decision = support_for_case(value)
    target = _safe_destination(destination, overwrite)

    if decision.template == "straight":
        generated = _generate_straight(value, target)
    elif decision.template == "turn":
        generated = _generate_turn(value, target)
    elif decision.template == "multicast":
        generated = _generate_multicast(value, target)
    elif decision.template == "contention":
        generated = _generate_contention(value, target)
    elif decision.template == "single-pe":
        generated = _generate_single_pe(value, target)
    elif decision.template == "single-pe-sram":
        generated = _generate_sram_probe(value, target)
    else:
        generated = _generate_unsupported(value, target, decision)

    files = _file_inventory(target)
    bundle_sha = _sha256(_json_bytes(files))
    manifest = {
        "schema_version": SCHEMA_VERSION,
        "kind": "wse3-calibration-bundle",
        "case": value,
        "status": decision.status,
        "support": asdict(decision),
        "sdk": {
            "architecture": "wse3",
            "minimum_version": "2.10",
            "fabric_dims": list(FABRIC_DIMS),
            "fabric_offsets": list(FABRIC_OFFSETS),
        },
        **generated,
        "files": files,
        "bundle_sha256": bundle_sha,
    }
    _write(target / "manifest.json", _json_bytes(manifest))
    return GeneratedCalibrationBundle(
        path=str(target),
        case_id=value["case_id"],
        family=value["family"],
        status=decision.status,
        supported=decision.supported,
        reason=decision.reason,
        manifest_path=str(target / "manifest.json"),
        bundle_sha256=bundle_sha,
    )


def materialize_calibration_bundles(
    cases: Iterable[CalibrationCase | Mapping[str, Any]],
    destination: str | os.PathLike[str],
    *,
    overwrite: bool = False,
) -> list[GeneratedCalibrationBundle]:
    root = Path(destination).resolve()
    root.mkdir(parents=True, exist_ok=True)
    results = []
    seen: set[str] = set()
    for case in cases:
        value = _case_dict(case)
        case_id = value["case_id"]
        if case_id in seen:
            raise CalibrationCodegenError(f"duplicate case ID: {case_id}")
        seen.add(case_id)
        results.append(
            materialize_calibration_bundle(value, root / case_id, overwrite=overwrite)
        )
    return results


generate_calibration_bundle = materialize_calibration_bundle


def _generate_unsupported(
    case: Mapping[str, Any], target: Path, decision: SupportDecision
) -> dict[str, Any]:
    text = (
        "# Unsupported calibration case\n\n"
        f"Case `{case['case_id']}` was not made runnable.\n\n"
        f"Reason: {decision.reason}\n\n"
        "No CSL, compile command, or host launcher is emitted. This prevents "
        "an orchestration layer from misclassifying a placeholder as a measurement.\n"
    )
    _write(target / "UNSUPPORTED.md", text)
    return {
        "compile": {"enabled": False, "argv": None},
        "runtime": {"enabled": False, "argv": None},
        "measurement": {"clock_unit": "cycles", "evidence": None},
    }


_STRAIGHT_LAYOUT = r'''// Generated WSE-3 straight-path calibration layout.
param width: i16;
param height: i16;
param payload: i16;
param direction_code: i16; // north=0, south=1, east=2, west=3

const C0: color = @get_color(0);
const C1: color = @get_color(1);
const C2: color = @get_color(2);
const C3: color = @get_color(3);
const C4: color = @get_color(4);
const TRAFFIC: color = @get_color(5);

const STARTUP: local_task_id = @get_local_task_id(15);
const SYNC_Y: local_task_id = @get_local_task_id(16);
const SYNC_BCAST: local_task_id = @get_local_task_id(17);
const SYNC_EXIT: local_task_id = @get_local_task_id(18);

const memcpy = @import_module("<memcpy/get_params>", .{
  .width = width, .height = height,
});
const sync = @import_module("sync/layout.csl", .{
  .colors = [5]color{C0, C1, C2, C3, C4},
  .entrypoints = [4]local_task_id{STARTUP, SYNC_Y, SYNC_BCAST, SYNC_EXIT},
  .width = width, .height = height,
});

layout {
  @comptime_assert(width >= 2 and height >= 2);
  @comptime_assert(payload > 0 and payload <= 4096);
  @comptime_assert(direction_code >= 0 and direction_code <= 3);
  @set_rectangle(width, height);

  var py: i16 = 0;
  while (py < height) : (py += 1) {
    var px: i16 = 0;
    while (px < width) : (px += 1) {
      const horizontal: bool = direction_code >= 2;
      const on_path: bool = if (horizontal) py == 0 else px == 0;
      const is_source: bool =
        (direction_code == 0 and px == 0 and py == height - 1) or
        (direction_code == 1 and px == 0 and py == 0) or
        (direction_code == 2 and px == 0 and py == 0) or
        (direction_code == 3 and px == width - 1 and py == 0);
      const is_destination: bool =
        (direction_code == 0 and px == 0 and py == 0) or
        (direction_code == 1 and px == 0 and py == height - 1) or
        (direction_code == 2 and px == width - 1 and py == 0) or
        (direction_code == 3 and px == 0 and py == 0);
      @set_tile_code(px, py, "straight_pe.csl", .{
        .memcpy_params = memcpy.get_params(px),
        .sync_params = sync.get_params(px, py),
        .traffic_color = TRAFFIC,
        .payload = payload,
        .direction_code = direction_code,
        .on_path = on_path,
        .is_source = is_source,
        .is_destination = is_destination,
      });
    }
  }

  @export_name("payload_data", [*]f32, true);
  @export_name("telemetry_u16", [*]u16, true);
  @export_name("f_sync", fn()void);
  @export_name("f_run", fn()void);
  @export_name("f_pack", fn()void);
}
'''


_STRAIGHT_PE = r'''// Generated endpoint program for exact cardinal routing.
param memcpy_params;
param sync_params;
param traffic_color: color;
param payload: i16;
param direction_code: i16;
param on_path: bool;
param is_source: bool;
param is_destination: bool;

const timestamp = @import_module("<time>");
const sys_mod = @import_module("<memcpy/memcpy>", memcpy_params);
const sync_mod = @import_module("sync/pe.csl", .{
  .sync_params = sync_params,
  .f_callback = sys_mod.unblock_cmd_stream,
  .input_queues = [3]u16{2, 3, 4},
  .output_queues = [3]u16{2, 3, 4},
});

const traffic_iq: input_queue = @get_input_queue(5);
const traffic_oq: output_queue = @get_output_queue(5);
const DONE: local_task_id = @get_local_task_id(19);

var payload_data = @zeros([payload]f32);
var payload_ptr: [*]f32 = &payload_data;
const payload_dsd = @get_dsd(mem1d_dsd, .{
  .tensor_access = |i|{payload} -> payload_data[i]
});
const fabric_in = @get_dsd(fabin_dsd, .{
  .extent = payload, .input_queue = traffic_iq
});
const fabric_out = @get_dsd(fabout_dsd, .{
  .extent = payload, .output_queue = traffic_oq
});

var tsc_start = @zeros([timestamp.tsc_size_words]u16);
var tsc_end = @zeros([timestamp.tsc_size_words]u16);
var telemetry_u16 = @zeros([9]u16);
var telemetry_ptr: [*]u16 = &telemetry_u16;

fn f_sync() void {
  sync_mod.f_sync();
}

fn f_run() void {
  if (is_source) {
    timestamp.get_timestamp(&tsc_start);
    @fmovs(fabric_out, payload_dsd, .{ .async = true, .activate = DONE });
  } else if (is_destination) {
    @fmovs(payload_dsd, fabric_in, .{ .async = true, .activate = DONE });
  } else {
    sys_mod.unblock_cmd_stream();
  }
}

task f_done() void {
  if (is_destination) {
    timestamp.get_timestamp(&tsc_end);
  }
  sys_mod.unblock_cmd_stream();
}

fn f_pack() void {
  telemetry_u16[0] = tsc_start[0];
  telemetry_u16[1] = tsc_start[1];
  telemetry_u16[2] = tsc_start[2];
  telemetry_u16[3] = tsc_end[0];
  telemetry_u16[4] = tsc_end[1];
  telemetry_u16[5] = tsc_end[2];
  telemetry_u16[6] = sync_mod.tscRefBuffer[0];
  telemetry_u16[7] = sync_mod.tscRefBuffer[1];
  telemetry_u16[8] = sync_mod.tscRefBuffer[2];
  sys_mod.unblock_cmd_stream();
}

comptime {
  @bind_local_task(f_done, DONE);
  @initialize_queue(traffic_iq, .{ .color = traffic_color });
  @initialize_queue(traffic_oq, .{ .color = traffic_color });

  if (on_path) {
    if (direction_code == 0) {
      if (is_source) {
        @set_local_color_config(traffic_color, .{ .routes = .{ .rx = .{RAMP}, .tx = .{NORTH} } });
      } else if (is_destination) {
        @set_local_color_config(traffic_color, .{ .routes = .{ .rx = .{SOUTH}, .tx = .{RAMP} } });
      } else {
        @set_local_color_config(traffic_color, .{ .routes = .{ .rx = .{SOUTH}, .tx = .{NORTH} } });
      }
    } else if (direction_code == 1) {
      if (is_source) {
        @set_local_color_config(traffic_color, .{ .routes = .{ .rx = .{RAMP}, .tx = .{SOUTH} } });
      } else if (is_destination) {
        @set_local_color_config(traffic_color, .{ .routes = .{ .rx = .{NORTH}, .tx = .{RAMP} } });
      } else {
        @set_local_color_config(traffic_color, .{ .routes = .{ .rx = .{NORTH}, .tx = .{SOUTH} } });
      }
    } else if (direction_code == 2) {
      if (is_source) {
        @set_local_color_config(traffic_color, .{ .routes = .{ .rx = .{RAMP}, .tx = .{EAST} } });
      } else if (is_destination) {
        @set_local_color_config(traffic_color, .{ .routes = .{ .rx = .{WEST}, .tx = .{RAMP} } });
      } else {
        @set_local_color_config(traffic_color, .{ .routes = .{ .rx = .{WEST}, .tx = .{EAST} } });
      }
    } else {
      if (is_source) {
        @set_local_color_config(traffic_color, .{ .routes = .{ .rx = .{RAMP}, .tx = .{WEST} } });
      } else if (is_destination) {
        @set_local_color_config(traffic_color, .{ .routes = .{ .rx = .{EAST}, .tx = .{RAMP} } });
      } else {
        @set_local_color_config(traffic_color, .{ .routes = .{ .rx = .{EAST}, .tx = .{WEST} } });
      }
    }
  }

  @export_symbol(payload_ptr, "payload_data");
  @export_symbol(telemetry_ptr, "telemetry_u16");
  @export_symbol(f_sync);
  @export_symbol(f_run);
  @export_symbol(f_pack);
}
'''


_STRAIGHT_HOST = r'''#!/usr/bin/env python3
"""Run one generated straight-path case; all reported time is device TSC time."""
import argparse
import json
from pathlib import Path
import numpy as np

MOD48 = 1 << 48

def u48(words):
    return int(words[0]) | (int(words[1]) << 16) | (int(words[2]) << 32)

def launch(runner, name):
    if hasattr(runner, "launch"):
        runner.launch(name, nonblock=False)
    else:
        runner.call(name, [], nonblock=False)

def event_plan(args):
    if args.event_plan:
        values = json.loads(args.event_plan.read_text())
        if not isinstance(values, list) or not values:
            raise RuntimeError("event plan must be a non-empty JSON array")
        result = []
        for value in values:
            if (not isinstance(value, dict)
                    or not isinstance(value.get("event_key"), str)
                    or not value["event_key"]
                    or not isinstance(value.get("warmup"), bool)
                    or isinstance(value.get("trial"), bool)
                    or not isinstance(value.get("trial"), int)
                    or value["trial"] < 0):
                raise RuntimeError("event plan contains an invalid event")
            result.append(value)
        return result
    return ([{"warmup": True, "trial": trial}
             for trial in range(args.warmups)]
            + [{"warmup": False, "trial": trial}
               for trial in range(args.trials)])

def emit_row(args, rows, row):
    rows.append(row)
    print("cycles_send = %d cycles" % row["elapsed_cycles"])
    print("WSE3STUDY_RESULT=" + json.dumps(row, sort_keys=True, separators=(",", ":")))
    if args.output:
        with args.output.open("a", encoding="utf-8") as output:
            output.write(json.dumps(row, sort_keys=True) + "\n")
            output.flush()

def execute(runner, dtype_enum, order_enum, args, manifest):
    p = manifest["case"]["parameters"]
    m = manifest["measurement"]
    width, height = m["rectangle"]
    sx, sy = m["source"]
    dx, dy = m["destination"]
    payload = int(p["payload_wavelets"])
    data_symbol = runner.get_id("payload_data")
    telemetry_symbol = runner.get_id("telemetry_u16")
    source = np.arange(payload, dtype=np.float32) + np.float32(0.25)
    runner.memcpy_h2d(data_symbol, source, sx, sy, 1, 1, payload,
                      streaming=False, data_type=dtype_enum.MEMCPY_32BIT,
                      order=order_enum.ROW_MAJOR, nonblock=False)
    rows = []
    for event in event_plan(args):
        launch(runner, "f_sync")
        launch(runner, "f_run")
        launch(runner, "f_pack")
        raw = np.zeros(width * height * 9, dtype=np.uint32)
        runner.memcpy_d2h(raw, telemetry_symbol, 0, 0, width, height, 9,
                          streaming=False, data_type=dtype_enum.MEMCPY_16BIT,
                          order=order_enum.ROW_MAJOR, nonblock=False)
        telemetry = raw.astype(np.uint16).reshape(height, width, 9)
        start_words = telemetry[sy, sx, 0:3]
        end_words = telemetry[dy, dx, 3:6]
        source_ref_words = telemetry[sy, sx, 6:9]
        destination_ref_words = telemetry[dy, dx, 6:9]
        # The official sync broadcast reaches (x,y) x+y cycles after PE(0,0).
        source_ref = (u48(source_ref_words) - sx - sy) % MOD48
        destination_ref = (u48(destination_ref_words) - dx - dy) % MOD48
        normalized_start = (u48(start_words) - source_ref) % MOD48
        normalized_end = (u48(end_words) - destination_ref) % MOD48
        elapsed = (normalized_end - normalized_start) % MOD48
        if elapsed <= 0 or elapsed >= MOD48 // 2:
            raise RuntimeError(f"invalid 48-bit elapsed cycle count: {elapsed}")
        received = np.zeros(payload, dtype=np.float32)
        runner.memcpy_d2h(received, data_symbol, dx, dy, 1, 1, payload,
                          streaming=False, data_type=dtype_enum.MEMCPY_32BIT,
                          order=order_enum.ROW_MAJOR, nonblock=False)
        correct = bool(np.array_equal(received, source))
        if not correct:
            raise RuntimeError("destination payload differs from source")
        if args.event_plan or not event["warmup"]:
            row = {
                "status": "pass", "case_id": manifest["case"]["case_id"],
                "family": "straight", "trial": int(event["trial"]),
                "warmup": bool(event["warmup"]),
                "elapsed_cycles": int(elapsed), "clock_unit": "cycles",
                "direction": p["direction"], "hops": int(p["hops"]),
                "payload_wavelets": payload, "source_pe": [sx, sy],
                "destination_pe": [dx, dy],
                "start_words_u16": [int(v) for v in start_words],
                "end_words_u16": [int(v) for v in end_words],
                "source_reference_words_u16": [int(v) for v in source_ref_words],
                "destination_reference_words_u16": [int(v) for v in destination_ref_words],
                "timer_enabled": True,
                "synchronization_protocol": "sdk-bandwidth-test",
                "correctness": True,
                "evidence": "simulator" if args.simulator else "silicon",
            }
            if args.event_plan:
                row["event_key"] = event["event_key"]
            emit_row(args, rows, row)
    return rows

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--name", required=True, help="local out directory or appliance artifact")
    parser.add_argument("--cmaddr")
    parser.add_argument("--simulator", action="store_true")
    parser.add_argument("--warmups", type=int, default=5)
    parser.add_argument("--trials", type=int, default=100)
    parser.add_argument("--output", type=Path)
    parser.add_argument("--event-plan", type=Path)
    args = parser.parse_args()
    if args.warmups < 0 or args.trials <= 0:
        parser.error("warmups must be non-negative and trials must be positive")
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text("")
    manifest = json.loads(Path(__file__).with_name("manifest.json").read_text())
    try:
        from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType, MemcpyOrder
        runner = SdkRuntime(args.name, cmaddr=args.cmaddr)
        runner.load(); runner.run()
        try:
            rows = execute(runner, MemcpyDataType, MemcpyOrder, args, manifest)
        finally:
            runner.stop()
    except ImportError:
        from cerebras.appliance.pb.sdk.sdk_common_pb2 import MemcpyDataType, MemcpyOrder
        from cerebras.sdk.client import SdkRuntime
        with SdkRuntime(args.name, simulator=args.simulator,
                        disable_version_check=True) as runner:
            rows = execute(runner, MemcpyDataType, MemcpyOrder, args, manifest)
    print("SUCCESS")

if __name__ == "__main__":
    main()
'''


def _straight_geometry(direction: str, hops: int) -> tuple[int, int, tuple[int, int], tuple[int, int]]:
    if direction == "north":
        return 2, hops + 1, (0, hops), (0, 0)
    if direction == "south":
        return 2, hops + 1, (0, 0), (0, hops)
    if direction == "east":
        return hops + 1, 2, (0, 0), (hops, 0)
    return hops + 1, 2, (hops, 0), (0, 0)


def _route_entries(direction: str, hops: int) -> list[dict[str, Any]]:
    width, height, source, destination = _straight_geometry(direction, hops)
    entries = []
    for index in range(hops + 1):
        if direction == "north":
            coord, rx, tx = (0, hops - index), ("RAMP" if index == 0 else "SOUTH"), ("RAMP" if index == hops else "NORTH")
        elif direction == "south":
            coord, rx, tx = (0, index), ("RAMP" if index == 0 else "NORTH"), ("RAMP" if index == hops else "SOUTH")
        elif direction == "east":
            coord, rx, tx = (index, 0), ("RAMP" if index == 0 else "WEST"), ("RAMP" if index == hops else "EAST")
        else:
            coord, rx, tx = (hops - index, 0), ("RAMP" if index == 0 else "EAST"), ("RAMP" if index == hops else "WEST")
        entries.append({"pe": list(coord), "rx": rx, "tx": tx, "color": 5})
    assert entries[0]["pe"] == list(source) and entries[-1]["pe"] == list(destination)
    return entries


def _generate_straight(case: Mapping[str, Any], target: Path) -> dict[str, Any]:
    p = case["parameters"]
    direction = str(p["direction"])
    hops = _positive_int(p, "hops")
    payload = _positive_int(p, "payload_wavelets")
    width, height, source, destination = _straight_geometry(direction, hops)
    direction_code = SUPPORTED_DIRECTIONS.index(direction)
    params = f"width:{width},height:{height},payload:{payload},direction_code:{direction_code}"
    argv = [
        "cslc", "./layout.csl", "--arch=wse3",
        f"--fabric-dims={FABRIC_DIMS[0]},{FABRIC_DIMS[1]}",
        f"--fabric-offsets={FABRIC_OFFSETS[0]},{FABRIC_OFFSETS[1]}",
        f"--params={params}", "-o=out", "--memcpy", "--channels=1",
        "--width-west-buf=0", "--width-east-buf=0",
    ]
    _write(target / "layout.csl", _STRAIGHT_LAYOUT)
    _write(target / "straight_pe.csl", _STRAIGHT_PE)
    (target / "sync").mkdir(parents=True, exist_ok=True)
    for name in ("layout.csl", "pe.csl"):
        shutil.copyfile(_OFFICIAL_SYNC / name, target / "sync" / name)
    command = (
        "#!/usr/bin/env bash\nset -euo pipefail\n"
        + " \\\n  ".join(argv)
        + "\ncs_python ./run.py --name out --warmups 5 --trials 100\n"
    )
    _write(target / "commands_wse3.sh", command, executable=True)
    _write(target / "run.py", _STRAIGHT_HOST, executable=True)
    return {
        "compile": {
            "enabled": True, "argv": argv, "entrypoint": "layout.csl",
            "output": "out", "params": {
                "width": width, "height": height, "payload": payload,
                "direction_code": direction_code,
            },
            "hardware_fabric_dims": list(FABRIC_DIMS),
            "simulator_fabric_dims": [width + 7, height + 2],
        },
        "runtime": {
            "enabled": True,
            "argv": ["python3", "run.py", "--name", "out", "--warmups", "5", "--trials", "100"],
            "submits_job": False,
            "result_prefix": "WSE3STUDY_RESULT=",
        },
        "measurement": {
            "clock_unit": "cycles", "timestamp_bits": 48,
            "evidence_after_execution": ["simulator", "silicon"],
            "rectangle": [width, height], "source": list(source),
            "destination": list(destination), "traffic_color": 5,
            "traffic_input_queue": 5, "traffic_output_queue": 5,
            "sync_colors": [0, 1, 2, 3, 4],
            "queue_resource_ledger": _queue_resource_ledger((5,), (2, 3, 4)),
            "sync_module": "SDK 2.10 csl-extras bandwidth-test/src/sync",
            "reference_correction_cycles": "x+y from PE(0,0), per official example",
            "route_entries": _route_entries(direction, hops),
            "timed_region": "source get_timestamp through destination receive completion",
            "host_time_included": False,
        },
    }


def _edge_direction(source: tuple[int, int], destination: tuple[int, int]) -> str:
    delta = (destination[0] - source[0], destination[1] - source[1])
    for name, vector in _DIRECTION_VECTOR.items():
        if delta == vector:
            return name
    raise CalibrationCodegenError(f"non-cardinal or non-adjacent route edge: {source} -> {destination}")


def _cardinal_path(legs: Iterable[tuple[str, int]]) -> list[tuple[int, int]]:
    path = [(0, 0)]
    for direction, hops in legs:
        if direction not in _DIRECTION_VECTOR or hops <= 0:
            raise CalibrationCodegenError("cardinal path legs require a known direction and positive hops")
        dx, dy = _DIRECTION_VECTOR[direction]
        for _ in range(hops):
            x, y = path[-1]
            path.append((x + dx, y + dy))
    return path


def _shift_path_to_rectangle(
    path: Iterable[tuple[int, int]],
) -> tuple[int, int, list[tuple[int, int]], tuple[int, int]]:
    raw = list(path)
    if not raw:
        raise CalibrationCodegenError("route path cannot be empty")
    min_x = min(x for x, _ in raw)
    min_y = min(y for _, y in raw)
    shifted = [(x - min_x, y - min_y) for x, y in raw]
    width = max(x for x, _ in shifted) + 1
    height = max(y for _, y in shifted) + 1
    # The official synchronization module requires a genuine 2-D rectangle.
    return max(2, width), max(2, height), shifted, (-min_x, -min_y)


def _path_route_entries(
    path: list[tuple[int, int]],
    *,
    color: int,
    ramp_taps: Iterable[tuple[int, int]] = (),
) -> list[dict[str, Any]]:
    taps = set(ramp_taps)
    entries: list[dict[str, Any]] = []
    for index, coordinate in enumerate(path):
        if index == 0:
            rx = ["RAMP"]
        else:
            rx = [_CSL_DIRECTION[_OPPOSITE_DIRECTION[_edge_direction(path[index - 1], coordinate)]]]
        tx: list[str] = []
        if coordinate in taps:
            tx.append("RAMP")
        if index + 1 < len(path):
            tx.append(_CSL_DIRECTION[_edge_direction(coordinate, path[index + 1])])
        elif "RAMP" not in tx:
            tx.append("RAMP")
        entries.append({"pe": list(coordinate), "rx": rx, "tx": tx, "color": color})
    return entries


def _path_edges(
    path: list[tuple[int, int]], *, color: int, source_index: int = 0
) -> list[dict[str, Any]]:
    return [
        {
            "source_index": source_index,
            "color": color,
            "from": list(source),
            "to": list(destination),
            "direction": _edge_direction(source, destination),
        }
        for source, destination in zip(path, path[1:])
    ]


def _traffic_queue_ids(base: int, count: int) -> tuple[int, ...]:
    if base not in _DUPLEX_USER_QUEUE_IDS:
        raise CalibrationCodegenError(
            f"traffic queue {base} collides with a <memcpy>-reserved input/output queue"
        )
    if not 1 <= count <= len(_DUPLEX_USER_QUEUE_IDS):
        raise CalibrationCodegenError("traffic queue allocation exceeds duplex-safe IDs 2..7")
    start = _DUPLEX_USER_QUEUE_IDS.index(base)
    return tuple(
        _DUPLEX_USER_QUEUE_IDS[(start + index) % len(_DUPLEX_USER_QUEUE_IDS)]
        for index in range(count)
    )


def _sync_queue_ids(traffic: Iterable[int]) -> tuple[int, int, int]:
    traffic_set = set(traffic)
    if not traffic_set.issubset(_DUPLEX_USER_QUEUE_IDS):
        raise CalibrationCodegenError("traffic allocation includes a non-duplex-safe queue")
    available = [queue for queue in _DUPLEX_USER_QUEUE_IDS if queue not in traffic_set]
    if len(available) < 3:
        raise CalibrationCodegenError(
            "official sync needs three duplex-safe queues disjoint from traffic and <memcpy>"
        )
    return available[0], available[1], available[2]


def _queue_resource_ledger(
    traffic: Iterable[int], sync: Iterable[int]
) -> dict[str, Any]:
    traffic_ids = tuple(traffic)
    sync_ids = tuple(sync)
    if set(traffic_ids) & set(sync_ids):
        raise CalibrationCodegenError("traffic and sync queues collide")
    if not (set(traffic_ids) | set(sync_ids)).issubset(_DUPLEX_USER_QUEUE_IDS):
        raise CalibrationCodegenError("generated queues collide with <memcpy>")
    return {
        "all_input_queue_ids": list(_QUEUE_IDS),
        "all_output_queue_ids": list(_QUEUE_IDS),
        "memcpy_reserved_input_queue_ids": sorted(_MEMCPY_RESERVED_INPUT_QUEUES),
        "memcpy_reserved_output_queue_ids": sorted(_MEMCPY_RESERVED_OUTPUT_QUEUES),
        "duplex_safe_user_queue_ids": list(_DUPLEX_USER_QUEUE_IDS),
        "traffic_input_queue_ids": list(traffic_ids),
        "traffic_output_queue_ids": list(traffic_ids),
        "sync_input_queue_ids": list(sync_ids),
        "sync_output_queue_ids": list(sync_ids),
        "namespace_semantics": "input and output queue ID spaces are independent; generated traffic/sync pairs deliberately use their collision-free numeric intersection",
    }


def _merge_path_routes(
    paths: Iterable[tuple[int, list[tuple[int, int]], int]],
) -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
    """Merge source paths by (color, PE), retaining every injected RAMP."""

    configs: dict[tuple[int, tuple[int, int]], dict[str, set[str]]] = {}
    edges: list[dict[str, Any]] = []
    for color, path, source_index in paths:
        edges.extend(_path_edges(path, color=color, source_index=source_index))
        for index, coordinate in enumerate(path):
            route = configs.setdefault((color, coordinate), {"rx": set(), "tx": set()})
            if index == 0:
                route["rx"].add("RAMP")
            else:
                incoming = _edge_direction(path[index - 1], coordinate)
                route["rx"].add(_CSL_DIRECTION[_OPPOSITE_DIRECTION[incoming]])
            if index + 1 == len(path):
                route["tx"].add("RAMP")
            else:
                route["tx"].add(_CSL_DIRECTION[_edge_direction(coordinate, path[index + 1])])
    direction_order = {"RAMP": 0, "NORTH": 1, "SOUTH": 2, "EAST": 3, "WEST": 4}
    entries = [
        {
            "pe": list(coordinate),
            "color": color,
            "rx": sorted(route["rx"], key=direction_order.__getitem__),
            "tx": sorted(route["tx"], key=direction_order.__getitem__),
        }
        for (color, coordinate), route in sorted(
            configs.items(), key=lambda item: (item[0][0], item[0][1][1], item[0][1][0])
        )
    ]
    return entries, edges


def _csl_tuple(values: Iterable[str]) -> str:
    return ".{" + ", ".join(values) + "}"


def _render_route_calls(entries: Iterable[Mapping[str, Any]]) -> str:
    calls = []
    for entry in entries:
        x, y = entry["pe"]
        color = int(entry["color"])
        rx = _csl_tuple(str(value) for value in entry["rx"])
        tx = _csl_tuple(str(value) for value in entry["tx"])
        calls.append(
            f"  @set_color_config({x}, {y}, TRAFFIC_{color - _TRAFFIC_COLOR_BASE}, "
            f".{{ .routes = .{{ .rx = {rx}, .tx = {tx} }} }});"
        )
    return "\n".join(calls)


def _coordinate_condition(coordinates: Iterable[tuple[int, int]]) -> str:
    terms = [f"(px == {x} and py == {y})" for x, y in coordinates]
    return " or ".join(terms) if terms else "false"


def _source_index_expression(sources: list[tuple[int, int]]) -> str:
    expression = "-1"
    for index in reversed(range(len(sources))):
        x, y = sources[index]
        expression = f"if (px == {x} and py == {y}) {index} else {expression}"
    return expression


def _render_network_layout(
    *,
    width: int,
    height: int,
    sources: list[tuple[int, int]],
    destinations: list[tuple[int, int]],
    color_count: int,
    route_entries: list[dict[str, Any]],
) -> str:
    colors = "\n".join(
        f"const TRAFFIC_{index}: color = @get_color({_TRAFFIC_COLOR_BASE + index});"
        for index in range(color_count)
    )
    destination_condition = _coordinate_condition(destinations)
    source_expression = _source_index_expression(sources)
    route_calls = _render_route_calls(route_entries)
    return f'''// Generated WSE-3 topology-specific network calibration layout.
const WIDTH: i16 = {width};
const HEIGHT: i16 = {height};
const C0: color = @get_color(0);
const C1: color = @get_color(1);
const C2: color = @get_color(2);
const C3: color = @get_color(3);
const C4: color = @get_color(4);
{colors}

const STARTUP: local_task_id = @get_local_task_id(15);
const SYNC_Y: local_task_id = @get_local_task_id(16);
const SYNC_BCAST: local_task_id = @get_local_task_id(17);
const SYNC_EXIT: local_task_id = @get_local_task_id(18);

const memcpy = @import_module("<memcpy/get_params>", .{{ .width = WIDTH, .height = HEIGHT }});
const sync = @import_module("sync/layout.csl", .{{
  .colors = [5]color{{C0, C1, C2, C3, C4}},
  .entrypoints = [4]local_task_id{{STARTUP, SYNC_Y, SYNC_BCAST, SYNC_EXIT}},
  .width = WIDTH, .height = HEIGHT,
}});

layout {{
  @comptime_assert(WIDTH >= 2 and HEIGHT >= 2);
  @set_rectangle(WIDTH, HEIGHT);
  var py: i16 = 0;
  while (py < HEIGHT) : (py += 1) {{
    var px: i16 = 0;
    while (px < WIDTH) : (px += 1) {{
      const source_index: i16 = {source_expression};
      const is_destination: bool = {destination_condition};
      @set_tile_code(px, py, "network_pe.csl", .{{
        .memcpy_params = memcpy.get_params(px),
        .sync_params = sync.get_params(px, py),
        .source_index = source_index,
        .is_destination = is_destination,
      }});
    }}
  }}

{route_calls}

  @export_name("payload_data", [*]f32, true);
  @export_name("received_data", [*]f32, true);
  @export_name("telemetry_u16", [*]u16, true);
  @export_name("f_sync", fn()void);
  @export_name("f_run", fn()void);
  @export_name("f_pack", fn()void);
}}
'''


def _render_network_pe(
    *,
    family: str,
    payload: int,
    source_count: int,
    color_mode: str,
    traffic_queues: tuple[int, ...],
    sync_queues: tuple[int, int, int],
    microthreads: int,
    receiver_delay: int,
) -> str:
    color_count = source_count if color_mode == "distinct" else 1
    receive_elements = payload * source_count if family == "contention" else payload
    colors = "\n".join(
        f"const TRAFFIC_{index}: color = @get_color({_TRAFFIC_COLOR_BASE + index});"
        for index in range(color_count)
    )
    queue_declarations = "\n".join(
        f"const traffic_{index}_iq: input_queue = @get_input_queue({traffic_queues[index]});\n"
        f"const traffic_{index}_oq: output_queue = @get_output_queue({traffic_queues[index]});"
        for index in range(color_count)
    )
    queue_initializers = "\n".join(
        f"  @initialize_queue(traffic_{index}_iq, .{{ .color = TRAFFIC_{index} }});\n"
        f"  @initialize_queue(traffic_{index}_oq, .{{ .color = TRAFFIC_{index} }});"
        for index in range(color_count)
    )

    chunk = payload // microthreads
    send_declarations: list[str] = []
    send_branches: list[str] = []
    for source_index in range(source_count):
        color_index = source_index if color_mode == "distinct" else 0
        calls = []
        for thread in range(microthreads):
            offset = thread * chunk
            send_declarations.extend(
                [
                    f"const source_{source_index}_{thread}_dsd = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{chunk}}} -> payload_data[{offset} + i] }});",
                    f"const fabric_out_{source_index}_{thread} = @get_dsd(fabout_dsd, .{{ .extent = {chunk}, .output_queue = traffic_{color_index}_oq }});",
                ]
            )
            calls.append(
                f"    @fmovs(fabric_out_{source_index}_{thread}, source_{source_index}_{thread}_dsd, "
                f".{{ .async = true, .ut_id = @get_ut_id({thread}) }});"
            )
        prefix = "if" if source_index == 0 else "else if"
        send_branches.append(
            f"  {prefix} (source_index == {source_index}) {{\n"
            "    timestamp.get_timestamp(&tsc_start);\n"
            + "\n".join(calls)
            + "\n    // The destination keeps the global RPC open until all receive DSDs complete.\n"
            "    sys_mod.unblock_cmd_stream();\n  }"
        )

    receive_declarations: list[str] = []
    receive_calls: list[str] = []
    completion_tasks: list[str] = []
    completion_bindings: list[str] = []
    for color_index in range(color_count):
        if color_mode == "distinct":
            extent = payload
            offset = color_index * payload
        else:
            extent = receive_elements
            offset = 0
        receive_declarations.extend(
            [
                f"const receive_{color_index}_dsd = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{extent}}} -> received_data[{offset} + i] }});",
                f"const fabric_in_{color_index} = @get_dsd(fabin_dsd, .{{ .extent = {extent}, .input_queue = traffic_{color_index}_iq }});",
            ]
        )
        task_id = _CONTENTION_DONE_TASK_IDS[color_index]
        completion_tasks.append(
            f"const RECEIVE_DONE_{color_index}: local_task_id = @get_local_task_id({task_id});\n"
            f"task receive_done_{color_index}() void {{ mark_receive_done(); }}"
        )
        completion_bindings.append(f"  @bind_local_task(receive_done_{color_index}, RECEIVE_DONE_{color_index});")
        # Every receive is issued before any completes, so concurrent receives must
        # hold DISTINCT microthread ids.  Using ``color_index % microthreads`` made
        # them all collapse onto ut_id 0 whenever microthreads == 1 (the default for
        # most contention cases): the second async receive then clobbered the first's
        # context and the destination payload came back wrong, which is why every
        # multi-source contention case failed its correctness check.  The
        # ``microthreads`` sweep partitions a single transfer and is applied on the
        # send side; it must not be used to index concurrent receives.
        if color_index >= _MICROTHREAD_ID_COUNT:
            raise CalibrationCodegenError(
                f"receive on color index {color_index} exceeds the {_MICROTHREAD_ID_COUNT} "
                "available WSE-3 microthread ids"
            )
        receive_calls.append(
            f"    @fmovs(receive_{color_index}_dsd, fabric_in_{color_index}, "
            f".{{ .async = true, .ut_id = @get_ut_id({color_index}), .activate = RECEIVE_DONE_{color_index} }});"
        )

    if family == "contention":
        delay_logic = f'''    timestamp.get_timestamp(&delay_start);
    timestamp.get_timestamp(&delay_end);
    var delay_elapsed: u32 = receiver_delay_delta();
    while (delay_elapsed < {receiver_delay}) {{
      timestamp.get_timestamp(&delay_end);
      delay_elapsed = receiver_delay_delta();
    }}'''
    else:
        delay_logic = ""

    return f'''// Generated {family} network endpoint; routing is fixed in layout.csl.
param memcpy_params;
param sync_params;
param source_index: i16;
param is_destination: bool;

const PAYLOAD: i16 = {payload};
const RECEIVE_ELEMENTS: i16 = {receive_elements};
const RECEIVE_OPERATIONS: u16 = {color_count};
{colors}

const timestamp = @import_module("<time>");
const sys_mod = @import_module("<memcpy/memcpy>", memcpy_params);
const sync_mod = @import_module("sync/pe.csl", .{{
  .sync_params = sync_params,
  .f_callback = sys_mod.unblock_cmd_stream,
  .input_queues = [3]u16{{{sync_queues[0]}, {sync_queues[1]}, {sync_queues[2]}}},
  .output_queues = [3]u16{{{sync_queues[0]}, {sync_queues[1]}, {sync_queues[2]}}},
}});

{queue_declarations}

var payload_data = @zeros([PAYLOAD]f32);
var received_data = @zeros([RECEIVE_ELEMENTS]f32);
var payload_ptr: [*]f32 = &payload_data;
var received_ptr: [*]f32 = &received_data;
var tsc_start = @zeros([timestamp.tsc_size_words]u16);
var tsc_end = @zeros([timestamp.tsc_size_words]u16);
var delay_start = @zeros([timestamp.tsc_size_words]u16);
var delay_end = @zeros([timestamp.tsc_size_words]u16);
var telemetry_u16 = @zeros([15]u16);
var telemetry_ptr: [*]u16 = &telemetry_u16;
var receives_completed: u16 = 0;

{chr(10).join(send_declarations)}
{chr(10).join(receive_declarations)}

fn receiver_delay_delta() u32 {{
  const delay_now_lo: u32 = @as(u32, delay_end[0]);
  const delay_start_lo: u32 = @as(u32, delay_start[0]);
  return if (delay_now_lo >= delay_start_lo)
    delay_now_lo - delay_start_lo
  else
    delay_now_lo + 65536 - delay_start_lo;
}}

fn mark_receive_done() void {{
  receives_completed += 1;
  if (receives_completed == RECEIVE_OPERATIONS) {{
    timestamp.get_timestamp(&tsc_end);
    sys_mod.unblock_cmd_stream();
  }}
}}

{chr(10).join(completion_tasks)}

fn f_sync() void {{ sync_mod.f_sync(); }}

fn f_run() void {{
{chr(10).join(send_branches)}
  else if (is_destination) {{
    receives_completed = 0;
{delay_logic}
{chr(10).join(receive_calls)}
  }} else {{
    sys_mod.unblock_cmd_stream();
  }}
}}

fn f_pack() void {{
  telemetry_u16[0] = tsc_start[0]; telemetry_u16[1] = tsc_start[1]; telemetry_u16[2] = tsc_start[2];
  telemetry_u16[3] = tsc_end[0]; telemetry_u16[4] = tsc_end[1]; telemetry_u16[5] = tsc_end[2];
  telemetry_u16[6] = sync_mod.tscRefBuffer[0]; telemetry_u16[7] = sync_mod.tscRefBuffer[1]; telemetry_u16[8] = sync_mod.tscRefBuffer[2];
  telemetry_u16[9] = delay_start[0]; telemetry_u16[10] = delay_start[1]; telemetry_u16[11] = delay_start[2];
  telemetry_u16[12] = delay_end[0]; telemetry_u16[13] = delay_end[1]; telemetry_u16[14] = delay_end[2];
  sys_mod.unblock_cmd_stream();
}}

comptime {{
{chr(10).join(completion_bindings)}
{queue_initializers}
  @export_symbol(payload_ptr, "payload_data");
  @export_symbol(received_ptr, "received_data");
  @export_symbol(telemetry_ptr, "telemetry_u16");
  @export_symbol(f_sync);
  @export_symbol(f_run);
  @export_symbol(f_pack);
}}
'''


_NETWORK_HOST = r'''#!/usr/bin/env python3
"""Execute a generated network topology with synchronized raw 48-bit TSCs."""
import argparse
import json
from pathlib import Path
import numpy as np

MOD48 = 1 << 48

def u48(words):
    return int(words[0]) | (int(words[1]) << 16) | (int(words[2]) << 32)

def launch(runner, name):
    if hasattr(runner, "launch"):
        runner.launch(name, nonblock=False)
    else:
        runner.call(name, [], nonblock=False)

def event_plan(args):
    if args.event_plan:
        values = json.loads(args.event_plan.read_text())
        if not isinstance(values, list) or not values:
            raise RuntimeError("event plan must be a non-empty JSON array")
        result = []
        for value in values:
            if (not isinstance(value, dict)
                    or not isinstance(value.get("event_key"), str)
                    or not value["event_key"]
                    or not isinstance(value.get("warmup"), bool)
                    or isinstance(value.get("trial"), bool)
                    or not isinstance(value.get("trial"), int)
                    or value["trial"] < 0):
                raise RuntimeError("event plan contains an invalid event")
            result.append(value)
        return result
    return ([{"warmup": True, "trial": trial}
             for trial in range(args.warmups)]
            + [{"warmup": False, "trial": trial}
               for trial in range(args.trials)])

def emit_row(args, rows, row):
    rows.append(row)
    print("cycles_send = %d cycles" % row["elapsed_cycles"])
    print("WSE3STUDY_RESULT=" + json.dumps(row, sort_keys=True, separators=(",", ":")))
    if args.output:
        with args.output.open("a", encoding="utf-8") as output:
            output.write(json.dumps(row, sort_keys=True) + "\n")
            output.flush()

def corrected_timestamp(words, reference_words, coordinate):
    reference = (u48(reference_words) - int(coordinate[0]) - int(coordinate[1])) % MOD48
    return (u48(words) - reference) % MOD48

def execute(runner, dtype_enum, order_enum, args, manifest):
    case = manifest["case"]
    p = case["parameters"]
    m = manifest["measurement"]
    width, height = m["rectangle"]
    sources = [tuple(value) for value in m["sources"]]
    destinations = [tuple(value) for value in m["destinations"]]
    payload = int(m["payload_wavelets"])
    receive_elements = int(m["receive_elements"])
    data_symbol = runner.get_id("payload_data")
    received_symbol = runner.get_id("received_data")
    telemetry_symbol = runner.get_id("telemetry_u16")

    source_data = []
    for index, (sx, sy) in enumerate(sources):
        if case["family"] == "contention":
            values = np.full(payload, np.float32(index + 1), dtype=np.float32)
        else:
            values = np.arange(payload, dtype=np.float32) + np.float32(0.25)
        source_data.append(values)
        runner.memcpy_h2d(data_symbol, values, sx, sy, 1, 1, payload,
                          streaming=False, data_type=dtype_enum.MEMCPY_32BIT,
                          order=order_enum.ROW_MAJOR, nonblock=False)

    rows = []
    for event in event_plan(args):
        zeros = np.zeros(receive_elements, dtype=np.float32)
        for dx, dy in destinations:
            runner.memcpy_h2d(received_symbol, zeros, dx, dy, 1, 1, receive_elements,
                              streaming=False, data_type=dtype_enum.MEMCPY_32BIT,
                              order=order_enum.ROW_MAJOR, nonblock=False)
        launch(runner, "f_sync")
        launch(runner, "f_run")
        launch(runner, "f_pack")
        raw = np.zeros(width * height * 15, dtype=np.uint32)
        runner.memcpy_d2h(raw, telemetry_symbol, 0, 0, width, height, 15,
                          streaming=False, data_type=dtype_enum.MEMCPY_16BIT,
                          order=order_enum.ROW_MAJOR, nonblock=False)
        telemetry = raw.astype(np.uint16).reshape(height, width, 15)

        normalized_starts = []
        start_words = []
        source_reference_words = []
        for coordinate in sources:
            sx, sy = coordinate
            words = telemetry[sy, sx, 0:3]
            reference = telemetry[sy, sx, 6:9]
            start_words.append([int(v) for v in words])
            source_reference_words.append([int(v) for v in reference])
            normalized_starts.append(corrected_timestamp(words, reference, coordinate))
        normalized_ends = []
        end_words = []
        destination_reference_words = []
        observed_delays = []
        for coordinate in destinations:
            dx, dy = coordinate
            words = telemetry[dy, dx, 3:6]
            reference = telemetry[dy, dx, 6:9]
            end_words.append([int(v) for v in words])
            destination_reference_words.append([int(v) for v in reference])
            normalized_ends.append(corrected_timestamp(words, reference, coordinate))
            if case["family"] == "contention":
                observed_delays.append((u48(telemetry[dy, dx, 12:15]) - u48(telemetry[dy, dx, 9:12])) % MOD48)
        critical_source_index = min(range(len(normalized_starts)), key=normalized_starts.__getitem__)
        first_start = normalized_starts[critical_source_index]
        elapsed_values = [(value - first_start) % MOD48 for value in normalized_ends]
        critical_destination_index = max(range(len(elapsed_values)), key=elapsed_values.__getitem__)
        elapsed = elapsed_values[critical_destination_index]
        if elapsed <= 0 or elapsed >= MOD48 // 2:
            raise RuntimeError(f"invalid 48-bit elapsed cycle count: {elapsed}")

        for destination in destinations:
            dx, dy = destination
            received = np.zeros(receive_elements, dtype=np.float32)
            runner.memcpy_d2h(received, received_symbol, dx, dy, 1, 1, receive_elements,
                              streaming=False, data_type=dtype_enum.MEMCPY_32BIT,
                              order=order_enum.ROW_MAJOR, nonblock=False)
            if case["family"] != "contention":
                correct = bool(np.array_equal(received, source_data[0]))
            elif p["color_mode"] == "distinct":
                correct = all(np.array_equal(
                    received[index * payload:(index + 1) * payload], source_data[index]
                ) for index in range(len(sources)))
            else:
                correct = all(
                    int(np.count_nonzero(received == np.float32(index + 1))) == payload
                    for index in range(len(sources))
                )
            if not correct:
                raise RuntimeError(f"payload correctness failed at destination {destination}")

        if args.event_plan or not event["warmup"]:
            row = {
                "status": "pass", "case_id": case["case_id"],
                "family": case["family"], "trial": int(event["trial"]),
                "warmup": bool(event["warmup"]),
                "elapsed_cycles": int(elapsed), "clock_unit": "cycles",
                "payload_wavelets": payload, "source_pes": [list(v) for v in sources],
                "destination_pes": [list(v) for v in destinations],
                # The flat critical pair preserves the campaign validator's
                # raw-live-timer contract. Full spatial endpoint words remain
                # alongside it under explicit plural fields.
                "start_words_u16": start_words[critical_source_index],
                "end_words_u16": end_words[critical_destination_index],
                "source_reference_words_u16": source_reference_words[critical_source_index],
                "destination_reference_words_u16": destination_reference_words[critical_destination_index],
                "all_source_start_words_u16": start_words,
                "all_destination_end_words_u16": end_words,
                "all_source_reference_words_u16": source_reference_words,
                "all_destination_reference_words_u16": destination_reference_words,
                "critical_source_index": int(critical_source_index),
                "critical_destination_index": int(critical_destination_index),
                "source_start_skew_cycles": int(max((v - first_start) % MOD48 for v in normalized_starts)),
                "timer_enabled": True, "synchronization_protocol": "sdk-bandwidth-test",
                "correctness": True,
                "evidence": "simulator" if args.simulator else "silicon",
            }
            if case["family"] == "turn":
                row.update({"turns": 1, "first_direction": p["first_direction"],
                            "second_direction": p["second_direction"]})
            elif case["family"] == "multicast":
                row.update({"fanout": int(p["fanout"]), "trunk_direction": p["trunk_direction"]})
            else:
                row.update({
                    "sources": int(p["sources"]), "color_mode": p["color_mode"],
                    "queue_id": int(p["queue_id"]), "microthreads": int(p["microthreads"]),
                    "receiver_delay_cycles": int(p["receiver_delay_cycles"]),
                    "observed_receiver_delay_cycles": int(max(observed_delays)),
                })
            if args.event_plan:
                row["event_key"] = event["event_key"]
            emit_row(args, rows, row)
    return rows

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--name", required=True)
    parser.add_argument("--cmaddr")
    parser.add_argument("--simulator", action="store_true")
    parser.add_argument("--warmups", type=int, default=5)
    parser.add_argument("--trials", type=int, default=100)
    parser.add_argument("--output", type=Path)
    parser.add_argument("--event-plan", type=Path)
    args = parser.parse_args()
    if args.warmups < 0 or args.trials <= 0:
        parser.error("warmups must be non-negative and trials must be positive")
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text("")
    manifest = json.loads(Path(__file__).with_name("manifest.json").read_text())
    try:
        from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType, MemcpyOrder
        runner = SdkRuntime(args.name, cmaddr=args.cmaddr)
        runner.load(); runner.run()
        try:
            rows = execute(runner, MemcpyDataType, MemcpyOrder, args, manifest)
        finally:
            runner.stop()
    except ImportError:
        from cerebras.appliance.pb.sdk.sdk_common_pb2 import MemcpyDataType, MemcpyOrder
        from cerebras.sdk.client import SdkRuntime
        with SdkRuntime(args.name, simulator=args.simulator, disable_version_check=True) as runner:
            rows = execute(runner, MemcpyDataType, MemcpyOrder, args, manifest)
    print("SUCCESS")

if __name__ == "__main__":
    main()
'''


def _network_bundle_common(
    case: Mapping[str, Any],
    target: Path,
    *,
    width: int,
    height: int,
    sources: list[tuple[int, int]],
    destinations: list[tuple[int, int]],
    route_entries: list[dict[str, Any]],
    route_edges: list[dict[str, Any]],
    payload: int,
    color_mode: str,
    traffic_queues: tuple[int, ...],
    sync_queues: tuple[int, int, int],
    microthreads: int = 1,
    receiver_delay: int = 0,
) -> dict[str, Any]:
    family = str(case["family"])
    color_count = len(sources) if color_mode == "distinct" else 1
    receive_elements = payload * len(sources) if family == "contention" else payload
    layout = _render_network_layout(
        width=width, height=height, sources=sources, destinations=destinations,
        color_count=color_count, route_entries=route_entries,
    )
    pe = _render_network_pe(
        family=family, payload=payload, source_count=len(sources),
        color_mode=color_mode, traffic_queues=traffic_queues,
        sync_queues=sync_queues, microthreads=microthreads,
        receiver_delay=receiver_delay,
    )
    argv = [
        "cslc", "./layout.csl", "--arch=wse3",
        f"--fabric-dims={FABRIC_DIMS[0]},{FABRIC_DIMS[1]}",
        f"--fabric-offsets={FABRIC_OFFSETS[0]},{FABRIC_OFFSETS[1]}",
        "-o=out", "--memcpy", "--channels=1",
        "--width-west-buf=0", "--width-east-buf=0",
    ]
    _write(target / "layout.csl", layout)
    _write(target / "network_pe.csl", pe)
    (target / "sync").mkdir(parents=True, exist_ok=True)
    for name in ("layout.csl", "pe.csl"):
        shutil.copyfile(_OFFICIAL_SYNC / name, target / "sync" / name)
    _write(target / "run.py", _NETWORK_HOST, executable=True)
    _write(
        target / "commands_wse3.sh",
        "#!/usr/bin/env bash\nset -euo pipefail\n"
        + " \\\n  ".join(argv)
        + "\ncs_python ./run.py --name out --warmups 5 --trials 100\n",
        executable=True,
    )
    return {
        "compile": {
            "enabled": True, "argv": argv, "entrypoint": "layout.csl", "output": "out",
            "params": {}, "hardware_fabric_dims": list(FABRIC_DIMS),
            "simulator_fabric_dims": [width + 7, height + 2],
        },
        "runtime": {
            "enabled": True,
            "argv": ["python3", "run.py", "--name", "out", "--warmups", "5", "--trials", "100"],
            "submits_job": False, "result_prefix": "WSE3STUDY_RESULT=",
        },
        "measurement": {
            "clock_unit": "cycles", "timestamp_bits": 48,
            "evidence_after_execution": ["simulator", "silicon"],
            "rectangle": [width, height], "sources": [list(v) for v in sources],
            "destinations": [list(v) for v in destinations],
            "payload_wavelets": payload, "receive_elements": receive_elements,
            "traffic_colors": list(range(_TRAFFIC_COLOR_BASE, _TRAFFIC_COLOR_BASE + color_count)),
            "traffic_queue_ids": list(traffic_queues), "sync_queue_ids": list(sync_queues),
            "queue_resource_ledger": _queue_resource_ledger(traffic_queues, sync_queues),
            "sync_colors": [0, 1, 2, 3, 4],
            "sync_module": "SDK 2.10 csl-extras bandwidth-test/src/sync",
            "reference_correction_cycles": "x+y from PE(0,0), per official example",
            "route_entries": route_entries, "directed_route_edges": route_edges,
            "timed_region": "minimum synchronized source timestamp through last destination receive completion",
            "host_time_included": False,
        },
    }


def _generate_turn(case: Mapping[str, Any], target: Path) -> dict[str, Any]:
    p = case["parameters"]
    first = str(p["first_direction"]); second = str(p["second_direction"])
    first_hops = _positive_int(p, "first_hops"); second_hops = _positive_int(p, "second_hops")
    payload = _positive_int(p, "payload_wavelets")
    raw_path = _cardinal_path(((first, first_hops), (second, second_hops)))
    width, height, path, _ = _shift_path_to_rectangle(raw_path)
    entries = _path_route_entries(path, color=_TRAFFIC_COLOR_BASE)
    edges = _path_edges(path, color=_TRAFFIC_COLOR_BASE)
    result = _network_bundle_common(
        case, target, width=width, height=height, sources=[path[0]],
        destinations=[path[-1]], route_entries=entries, route_edges=edges,
        payload=payload, color_mode="same", traffic_queues=(5,),
        sync_queues=(2, 3, 4),
    )
    result["measurement"].update({
        "topology": "single L-shaped unicast path", "turn_coordinate": list(path[first_hops]),
        "first_direction": first, "second_direction": second,
        "first_hops": first_hops, "second_hops": second_hops, "turns": 1,
    })
    return result


def _generate_multicast(case: Mapping[str, Any], target: Path) -> dict[str, Any]:
    p = case["parameters"]
    direction = str(p["trunk_direction"]); hops = _positive_int(p, "trunk_hops")
    fanout = _positive_int(p, "fanout"); payload = _positive_int(p, "payload_wavelets")
    width, height, source, _ = _straight_geometry(direction, hops)
    path = [source]
    dx, dy = _DIRECTION_VECTOR[direction]
    for _ in range(hops):
        x, y = path[-1]
        path.append((x + dx, y + dy))
    destination_indices = [(index * hops) // fanout for index in range(1, fanout + 1)]
    destinations = [path[index] for index in destination_indices]
    entries = _path_route_entries(path, color=_TRAFFIC_COLOR_BASE, ramp_taps=destinations)
    edges = _path_edges(path, color=_TRAFFIC_COLOR_BASE)
    result = _network_bundle_common(
        case, target, width=width, height=height, sources=[source],
        destinations=destinations, route_entries=entries, route_edges=edges,
        payload=payload, color_mode="same", traffic_queues=(5,),
        sync_queues=(2, 3, 4),
    )
    result["measurement"].update({
        "topology": "cardinal trunk with local RAMP taps",
        "trunk_direction": direction, "trunk_hops": hops, "fanout": fanout,
        "destination_hop_indices": destination_indices,
        "multicast_semantics": "each tap transmits to RAMP and continues along the trunk; the last tap terminates at RAMP",
    })
    return result


def _contention_paths(path_hops: int, source_count: int) -> tuple[list[tuple[int, int]], tuple[int, int], list[list[tuple[int, int]]]]:
    destination = (path_hops, 0)
    sources: list[tuple[int, int]] = []
    paths: list[list[tuple[int, int]]] = []
    for index in range(source_count):
        source = (index, index)
        path = [source]
        for y in range(index - 1, -1, -1):
            path.append((index, y))
        for x in range(index + 1, path_hops + 1):
            path.append((x, 0))
        if len(path) - 1 != path_hops or path[-1] != destination:
            raise CalibrationCodegenError("internal equal-hop contention topology error")
        sources.append(source)
        paths.append(path)
    return sources, destination, paths


def _generate_contention(case: Mapping[str, Any], target: Path) -> dict[str, Any]:
    p = case["parameters"]
    hops = _positive_int(p, "path_hops"); payload = _positive_int(p, "payload_wavelets")
    sources_count = _positive_int(p, "sources"); queue_id = int(p["queue_id"])
    microthreads = _positive_int(p, "microthreads"); receiver_delay = int(p["receiver_delay_cycles"])
    color_mode = str(p["color_mode"])
    sources, destination, paths = _contention_paths(hops, sources_count)
    color_count = sources_count if color_mode == "distinct" else 1
    traffic_queues = _traffic_queue_ids(queue_id, color_count)
    sync_queues = _sync_queue_ids(traffic_queues)
    routed_paths = [
        (_TRAFFIC_COLOR_BASE + (index if color_mode == "distinct" else 0), path, index)
        for index, path in enumerate(paths)
    ]
    entries, edges = _merge_path_routes(routed_paths)
    result = _network_bundle_common(
        case, target, width=hops + 1, height=max(2, sources_count), sources=sources,
        destinations=[destination], route_entries=entries, route_edges=edges,
        payload=payload, color_mode=color_mode, traffic_queues=traffic_queues,
        sync_queues=sync_queues, microthreads=microthreads,
        receiver_delay=receiver_delay,
    )
    result["measurement"].update({
        "topology": "equal-hop descending merge into one eastbound bottleneck",
        "path_hops": hops, "sources_count": sources_count, "color_mode": color_mode,
        "requested_queue_id": queue_id,
        "queue_assignment_semantics": "requested queue is the first traffic queue; distinct colors rotate through subsequent physical queues modulo eight",
        "microthreads": microthreads,
        "microthread_semantics": "each source partitions its fixed payload evenly across actual asynchronous WSE-3 ut_id values 0..microthreads-1",
        "receiver_delay_requested_minimum_cycles": receiver_delay,
        "receiver_delay_semantics": "destination polls its local raw TSC before arming fabric input; telemetry reports the observed delay including polling overshoot",
        "correctness_semantics": "distinct colors preserve per-source slices; same-color arbitration is validated as an exact per-source value multiset",
        "source_paths": [[list(coordinate) for coordinate in path] for path in paths],
    })
    return result


_SINGLE_PE_LAYOUT = r'''// Generated single-PE compute calibration layout.
const memcpy = @import_module("<memcpy/get_params>", .{ .width = 1, .height = 1 });
layout {
  @set_rectangle(1, 1);
  @set_tile_code(0, 0, "single_pe.csl", .{
    .memcpy_params = memcpy.get_params(0),
  });
  @export_name("input_a", [*]__CSL_TYPE__, true);
  @export_name("input_b", [*]__CSL_TYPE__, true);
  @export_name("output", [*]__CSL_TYPE__, true);
  @export_name("telemetry_u16", [*]u16, true);
  @export_name("f_enable_timer", fn()void);
  @export_name("f_run", fn()void);
}
'''


_SINGLE_PE_HOST = r'''#!/usr/bin/env python3
"""Run one generated single-PE case using device-internal 48-bit timestamps."""
import argparse
import json
from pathlib import Path
import numpy as np

MOD48 = 1 << 48

def u48(words):
    return int(words[0]) | (int(words[1]) << 16) | (int(words[2]) << 32)

def launch(runner, name):
    if hasattr(runner, "launch"):
        runner.launch(name, nonblock=False)
    else:
        runner.call(name, [], nonblock=False)

def event_plan(args):
    if args.event_plan:
        values = json.loads(args.event_plan.read_text())
        if not isinstance(values, list) or not values:
            raise RuntimeError("event plan must be a non-empty JSON array")
        result = []
        for value in values:
            if (not isinstance(value, dict)
                    or not isinstance(value.get("event_key"), str)
                    or not value["event_key"]
                    or not isinstance(value.get("warmup"), bool)
                    or isinstance(value.get("trial"), bool)
                    or not isinstance(value.get("trial"), int)
                    or value["trial"] < 0):
                raise RuntimeError("event plan contains an invalid event")
            result.append(value)
        return result
    return ([{"warmup": True, "trial": trial}
             for trial in range(args.warmups)]
            + [{"warmup": False, "trial": trial}
               for trial in range(args.trials)])

def emit_row(args, rows, row):
    rows.append(row)
    print("cycles_send = %d cycles" % row["elapsed_cycles"])
    print("WSE3STUDY_RESULT=" + json.dumps(row, sort_keys=True, separators=(",", ":")))
    if args.output:
        with args.output.open("a", encoding="utf-8") as output:
            output.write(json.dumps(row, sort_keys=True) + "\n")
            output.flush()

def to_transport(values):
    """Encode one logical element per SDK-required uint32 host element."""
    if values.dtype.itemsize == 2:
        return values.view(np.uint16).astype(np.uint32)
    if values.dtype.itemsize == 4:
        return values.view(np.uint32).copy()
    raise RuntimeError(f"unsupported transport element width: {values.dtype}")

def from_transport(container, dtype):
    """Decode the low 16 bits or full 32 bits returned per host element."""
    if dtype.itemsize == 2:
        return (container & np.uint32(0xffff)).astype(np.uint16).view(dtype)
    if dtype.itemsize == 4:
        return container.view(dtype)
    raise RuntimeError(f"unsupported transport element width: {dtype}")

def execute(runner, dtype_enum, order_enum, args, manifest):
    p = manifest["case"]["parameters"]
    m = manifest["measurement"]
    dtype = np.dtype(m["numpy_dtype"])
    word_type = dtype_enum.MEMCPY_16BIT if dtype.itemsize == 2 else dtype_enum.MEMCPY_32BIT
    n = int(p["vector_length"]); stride = int(p.get("stride", 1))
    alignment = int(p.get("bank_alignment", 0)); lanes = int(m["work_lanes"])
    storage = int(m["storage_elements_per_lane"]); total = storage * lanes
    a = np.zeros(total, dtype=dtype)
    b = np.zeros(total, dtype=dtype)
    expected = np.zeros(total, dtype=dtype)
    for lane in range(lanes):
        base = lane * storage + alignment
        idx = base + np.arange(n) * stride
        av = ((np.arange(n) % 7) + 1).astype(dtype)
        bv = ((np.arange(n) % 5) + 2).astype(dtype)
        a[idx] = av; b[idx] = bv
        op = p["operation"]
        if op == "copy": expected[idx] = av
        elif op == "add": expected[idx] = av + bv
        elif op == "multiply": expected[idx] = av * bv
        elif op == "fma": expected[idx] = av + bv * dtype.type(2)
    if p["operation"] == "reduction":
        expected = np.zeros(total, dtype=dtype)
        expected[0] = np.sum(a[alignment:alignment + n * stride:stride], dtype=dtype)
    a_u32 = to_transport(a)
    b_u32 = to_transport(b)

    a_symbol = runner.get_id("input_a"); b_symbol = runner.get_id("input_b")
    out_symbol = runner.get_id("output"); time_symbol = runner.get_id("telemetry_u16")
    launch(runner, "f_enable_timer")
    rows = []
    for event in event_plan(args):
        runner.memcpy_h2d(a_symbol, a_u32, 0, 0, 1, 1, total, streaming=False,
                          data_type=word_type, order=order_enum.ROW_MAJOR, nonblock=False)
        runner.memcpy_h2d(b_symbol, b_u32, 0, 0, 1, 1, total, streaming=False,
                          data_type=word_type, order=order_enum.ROW_MAJOR, nonblock=False)
        launch(runner, "f_run")
        raw_time_u32 = np.zeros(6, dtype=np.uint32)
        runner.memcpy_d2h(raw_time_u32, time_symbol, 0, 0, 1, 1, 6, streaming=False,
                          data_type=dtype_enum.MEMCPY_16BIT,
                          order=order_enum.ROW_MAJOR, nonblock=False)
        words = raw_time_u32.astype(np.uint16)
        elapsed = (u48(words[3:6]) - u48(words[0:3])) % MOD48
        if elapsed <= 0 or elapsed >= MOD48 // 2:
            raise RuntimeError(f"invalid 48-bit elapsed cycle count: {elapsed}")
        result_u32 = np.zeros(total, dtype=np.uint32)
        runner.memcpy_d2h(result_u32, out_symbol, 0, 0, 1, 1, total, streaming=False,
                          data_type=word_type, order=order_enum.ROW_MAJOR, nonblock=False)
        result = from_transport(result_u32, dtype)
        if dtype.kind == "f":
            correct = bool(np.allclose(result, expected, rtol=1e-3, atol=1e-3))
        else:
            correct = bool(np.array_equal(result, expected))
        if not correct:
            raise RuntimeError("single-PE result failed correctness validation")
        if args.event_plan or not event["warmup"]:
            row = {
                "status": "pass", "case_id": manifest["case"]["case_id"],
                "family": manifest["case"]["family"], "trial": int(event["trial"]),
                "warmup": bool(event["warmup"]),
                "elapsed_cycles": int(elapsed), "clock_unit": "cycles",
                "operation": p["operation"], "dtype": p["dtype"], "mode": p["mode"],
                "vector_length": n, "effective_elements": n * lanes,
                "work_lanes": lanes, "stride": stride, "bank_alignment": alignment,
                "dependency_chains": int(p.get("dependency_chains", 1)),
                "microthreads": int(p.get("microthreads", 1)),
                "queue_id": int(p.get("queue_id", 0)),
                "start_words_u16": [int(v) for v in words[0:3]],
                "end_words_u16": [int(v) for v in words[3:6]],
                "timer_enabled": True,
                "correctness": True,
                "evidence": "simulator" if args.simulator else "silicon",
            }
            if args.event_plan:
                row["event_key"] = event["event_key"]
            emit_row(args, rows, row)
    return rows

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--name", required=True)
    parser.add_argument("--cmaddr")
    parser.add_argument("--simulator", action="store_true")
    parser.add_argument("--warmups", type=int, default=5)
    parser.add_argument("--trials", type=int, default=100)
    parser.add_argument("--output", type=Path)
    parser.add_argument("--event-plan", type=Path)
    args = parser.parse_args()
    if args.warmups < 0 or args.trials <= 0:
        parser.error("warmups must be non-negative and trials must be positive")
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text("")
    manifest = json.loads(Path(__file__).with_name("manifest.json").read_text())
    try:
        from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType, MemcpyOrder
        runner = SdkRuntime(args.name, cmaddr=args.cmaddr)
        runner.load(); runner.run()
        try:
            rows = execute(runner, MemcpyDataType, MemcpyOrder, args, manifest)
        finally:
            runner.stop()
    except ImportError:
        from cerebras.appliance.pb.sdk.sdk_common_pb2 import MemcpyDataType, MemcpyOrder
        from cerebras.sdk.client import SdkRuntime
        with SdkRuntime(args.name, simulator=args.simulator,
                        disable_version_check=True) as runner:
            rows = execute(runner, MemcpyDataType, MemcpyOrder, args, manifest)
    print("SUCCESS")

if __name__ == "__main__":
    main()
'''


_CSL_TYPES = {"fp16": "f16", "fp32": "f32", "i16": "i16", "i32": "i32"}
_NUMPY_TYPES = {"fp16": "float16", "fp32": "float32", "i16": "int16", "i32": "int32"}
_DSD_BUILTINS = {
    "copy": {"fp16": "fmovh", "fp32": "fmovs", "i16": "mov16", "i32": "mov32"},
    "add": {"fp16": "faddh", "fp32": "fadds", "i16": "add16"},
    "multiply": {"fp16": "fmulh", "fp32": "fmuls"},
    "fma": {"fp16": "fmach", "fp32": "fmacs"},
    "reduction": {"fp16": "faddh", "fp32": "fadds", "i16": "add16"},
}


def _scalar_body(operation: str, csl_type: str, n: int, stride: int, alignment: int, lanes: int, storage: int) -> str:
    lines: list[str] = []
    if operation == "reduction":
        zero = "@as(f16, 0.0)" if csl_type == "f16" else ("0.0" if csl_type == "f32" else "0")
        lines.extend([f"  var acc: {csl_type} = {zero};", "  var i: i16 = 0;", f"  while (i < {n}) : (i += 1) {{", f"    acc = acc + input_a[{alignment} + i * {stride}];", "  }", "  output[0] = acc;"])
        return "\n".join(lines)
    operator = {"copy": None, "add": "+", "multiply": "*", "fma": None}[operation]
    factor = "@as(f16, 2.0)" if csl_type == "f16" else "2.0"
    for lane in range(lanes):
        base = lane * storage + alignment
        lines.extend(["  var i: i16 = 0;", f"  while (i < {n}) : (i += 1) {{"])
        idx = f"{base} + i * {stride}"
        if operation == "copy":
            expression = f"input_a[{idx}]"
        elif operation == "fma":
            expression = f"input_a[{idx}] + input_b[{idx}] * {factor}"
        else:
            expression = f"input_a[{idx}] {operator} input_b[{idx}]"
        lines.extend([f"    output[{idx}] = {expression};", "  }"])
    return "\n".join(lines)


def _dsd_declarations(n: int, stride: int, alignment: int, lanes: int, storage: int) -> str:
    declarations = []
    for lane in range(lanes):
        base = lane * storage + alignment
        for name in ("a", "b", "out"):
            array = {"a": "input_a", "b": "input_b", "out": "output"}[name]
            declarations.append(
                f"const {name}_{lane}_dsd = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{n}}} -> {array}[{base} + i * {stride}] }});"
            )
    return "\n".join(declarations)


def _dsd_call(operation: str, dtype: str, lane: int, config: str = "") -> str:
    builtin = _DSD_BUILTINS[operation][dtype]
    suffix = f", {config}" if config else ""
    if operation == "copy":
        args = f"out_{lane}_dsd, a_{lane}_dsd{suffix}"
    elif operation in {"add", "multiply"}:
        args = f"out_{lane}_dsd, a_{lane}_dsd, b_{lane}_dsd{suffix}"
    elif operation == "fma":
        scalar = "@as(f16, 2.0)" if dtype == "fp16" else "2.0"
        args = f"out_{lane}_dsd, a_{lane}_dsd, b_{lane}_dsd, {scalar}{suffix}"
    else:
        raise AssertionError(operation)
    return f"@{builtin}({args});"


def _reduction_dsd(dtype: str, csl_type: str, n: int, stride: int, alignment: int) -> tuple[str, str]:
    declarations: list[str] = []
    calls: list[str] = []
    extent = n
    stage = 0
    builtin = _DSD_BUILTINS["reduction"][dtype]
    while extent > 1:
        half = extent // 2
        declarations.append(
            f"const reduce_dst_{stage} = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{half}}} -> input_a[{alignment} + i * {stride}] }});"
        )
        declarations.append(
            f"const reduce_src_{stage} = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{half}}} -> input_a[{alignment + half * stride} + i * {stride}] }});"
        )
        calls.append(f"  @{builtin}(reduce_dst_{stage}, reduce_dst_{stage}, reduce_src_{stage});")
        extent = half
        stage += 1
    calls.append(f"  output[0] = input_a[{alignment}];")
    return "\n".join(declarations), "\n".join(calls)


def _single_pe_source(parameters: Mapping[str, Any]) -> tuple[str, dict[str, int]]:
    operation = str(parameters["operation"]); dtype = str(parameters["dtype"])
    mode = str(parameters["mode"]); csl_type = _CSL_TYPES[dtype]
    n = int(parameters["vector_length"]); stride = int(parameters.get("stride", 1))
    alignment = int(parameters.get("bank_alignment", 0))
    chains = int(parameters.get("dependency_chains", 1)); microthreads = int(parameters.get("microthreads", 1))
    storage = alignment + (n - 1) * stride + 1
    lanes = microthreads if microthreads > 1 else chains
    total = storage * lanes

    declarations = ""
    completion = ""
    if mode == "scalar":
        body = _scalar_body(operation, csl_type, n, stride, alignment, lanes, storage)
        run_body = f"  timestamp.get_timestamp(&tsc_start);\n{body}\n  timestamp.get_timestamp(&tsc_end);\n  pack_telemetry();\n  sys_mod.unblock_cmd_stream();"
    elif operation == "reduction":
        declarations, body = _reduction_dsd(dtype, csl_type, n, stride, alignment)
        run_body = f"  timestamp.get_timestamp(&tsc_start);\n{body}\n  timestamp.get_timestamp(&tsc_end);\n  pack_telemetry();\n  sys_mod.unblock_cmd_stream();"
    else:
        declarations = _dsd_declarations(n, stride, alignment, lanes, storage)
        if microthreads > 1:
            task_ids = [f"const DONE_{i}: local_task_id = @get_local_task_id({8 + i});" for i in range(lanes)]
            done_tasks = [f"task done_{i}() void {{ mark_done(); }}" for i in range(lanes)]
            bindings = [f"  @bind_local_task(done_{i}, DONE_{i});" for i in range(lanes)]
            calls = []
            for i in range(lanes):
                calls.append(f"  {_dsd_call(operation, dtype, i, f'.{{ .async = true, .ut_id = @get_ut_id({i}), .activate = DONE_{i} }}')}")
            completion = "\n".join(task_ids) + "\nvar completed: i16 = 0;\nfn mark_done() void {\n  completed += 1;\n  if (completed == WORK_LANES) {\n    timestamp.get_timestamp(&tsc_end);\n    pack_telemetry();\n    sys_mod.unblock_cmd_stream();\n  }\n}\n" + "\n".join(done_tasks) + "\n"
            run_body = "  completed = 0;\n  timestamp.get_timestamp(&tsc_start);\n" + "\n".join(calls)
            bind_code = "\n".join(bindings)
        else:
            calls = [f"  {_dsd_call(operation, dtype, i)}" for i in range(lanes)]
            run_body = "  timestamp.get_timestamp(&tsc_start);\n" + "\n".join(calls) + "\n  timestamp.get_timestamp(&tsc_end);\n  pack_telemetry();\n  sys_mod.unblock_cmd_stream();"
            bind_code = ""
    if not (mode == "dsd" and operation != "reduction" and microthreads > 1):
        bind_code = ""

    source = f'''// Generated single-PE {operation}/{dtype}/{mode} calibration.
param memcpy_params;
const sys_mod = @import_module("<memcpy/memcpy>", memcpy_params);
const timestamp = @import_module("<time>");
const N: i16 = {n};
const STORAGE: i16 = {storage};
const WORK_LANES: i16 = {lanes};
const TOTAL: i16 = {total};

var input_a = @zeros([TOTAL]{csl_type});
var input_b = @zeros([TOTAL]{csl_type});
var output = @zeros([TOTAL]{csl_type});
var input_a_ptr: [*]{csl_type} = &input_a;
var input_b_ptr: [*]{csl_type} = &input_b;
var output_ptr: [*]{csl_type} = &output;
var tsc_start = @zeros([timestamp.tsc_size_words]u16);
var tsc_end = @zeros([timestamp.tsc_size_words]u16);
var telemetry_u16 = @zeros([6]u16);
var telemetry_ptr: [*]u16 = &telemetry_u16;

{declarations}
fn pack_telemetry() void {{
  telemetry_u16[0] = tsc_start[0]; telemetry_u16[1] = tsc_start[1]; telemetry_u16[2] = tsc_start[2];
  telemetry_u16[3] = tsc_end[0]; telemetry_u16[4] = tsc_end[1]; telemetry_u16[5] = tsc_end[2];
}}

{completion}
fn f_enable_timer() void {{
  timestamp.enable_tsc();
  sys_mod.unblock_cmd_stream();
}}

fn f_run() void {{
{run_body}
}}

comptime {{
{bind_code}
  @export_symbol(input_a_ptr, "input_a");
  @export_symbol(input_b_ptr, "input_b");
  @export_symbol(output_ptr, "output");
  @export_symbol(telemetry_ptr, "telemetry_u16");
  @export_symbol(f_enable_timer);
  @export_symbol(f_run);
}}
'''
    return source, {"storage": storage, "lanes": lanes, "total": total}


def _generate_single_pe(case: Mapping[str, Any], target: Path) -> dict[str, Any]:
    p = case["parameters"]
    dtype = str(p["dtype"])
    source, sizing = _single_pe_source(p)
    layout = _SINGLE_PE_LAYOUT.replace("__CSL_TYPE__", _CSL_TYPES[dtype])
    argv = [
        "cslc", "./layout.csl", "--arch=wse3",
        f"--fabric-dims={FABRIC_DIMS[0]},{FABRIC_DIMS[1]}",
        f"--fabric-offsets={FABRIC_OFFSETS[0]},{FABRIC_OFFSETS[1]}",
        "-o=out", "--memcpy", "--channels=1",
        "--width-west-buf=0", "--width-east-buf=0",
    ]
    _write(target / "layout.csl", layout)
    _write(target / "single_pe.csl", source)
    _write(
        target / "commands_wse3.sh",
        "#!/usr/bin/env bash\nset -euo pipefail\n"
        + " \\\n  ".join(argv)
        + "\ncs_python ./run.py --name out --warmups 5 --trials 100\n",
        executable=True,
    )
    _write(target / "run.py", _SINGLE_PE_HOST, executable=True)
    return {
        "compile": {
            "enabled": True, "argv": argv, "entrypoint": "layout.csl",
            "output": "out", "params": {},
            "hardware_fabric_dims": list(FABRIC_DIMS),
            "simulator_fabric_dims": [8, 3],
        },
        "runtime": {
            "enabled": True,
            "argv": ["python3", "run.py", "--name", "out", "--warmups", "5", "--trials", "100"],
            "submits_job": False, "result_prefix": "WSE3STUDY_RESULT=",
        },
        "measurement": {
            "clock_unit": "cycles", "timestamp_bits": 48,
            "evidence_after_execution": ["simulator", "silicon"],
            "timed_region": "one f_run device entrypoint", "host_time_included": False,
            "csl_type": _CSL_TYPES[dtype], "numpy_dtype": _NUMPY_TYPES[dtype],
            "storage_elements_per_lane": sizing["storage"],
            "work_lanes": sizing["lanes"], "total_storage_elements": sizing["total"],
            "effective_elements": sizing["lanes"] * int(p["vector_length"]),
            "bank_alignment_semantics": "element offset within each generated array; verify absolute bank with cs_readelf",
            "queue_semantics": "no fabric queue is consumed; only queue_id=0 neutral cases are runnable",
        },
    }


_SRAM_LAYOUT = r'''param allocation_words: i16;
const memcpy = @import_module("<memcpy/get_params>", .{ .width = 1, .height = 1 });
layout {
  @set_rectangle(1, 1);
  @set_tile_code(0, 0, "allocation_probe.csl", .{
    .memcpy_params = memcpy.get_params(0), .allocation_words = allocation_words,
  });
  @export_name("allocation", [*]u16, true);
}
'''


_SRAM_PE = r'''param memcpy_params;
param allocation_words: i16;
var allocation = @zeros([allocation_words]u16);
var allocation_ptr: [*]u16 = &allocation;
comptime { @export_symbol(allocation_ptr, "allocation"); }
'''


def _generate_sram_probe(case: Mapping[str, Any], target: Path) -> dict[str, Any]:
    allocation_bytes = _positive_int(case["parameters"], "allocation_bytes")
    allocation_words = (allocation_bytes + 1) // 2
    argv = [
        "cslc", "./layout.csl", "--arch=wse3",
        f"--fabric-dims={FABRIC_DIMS[0]},{FABRIC_DIMS[1]}",
        f"--fabric-offsets={FABRIC_OFFSETS[0]},{FABRIC_OFFSETS[1]}",
        f"--params=allocation_words:{allocation_words}", "-o=out", "--memcpy", "--channels=1",
        "--width-west-buf=0", "--width-east-buf=0",
    ]
    _write(target / "layout.csl", _SRAM_LAYOUT)
    _write(target / "allocation_probe.csl", _SRAM_PE)
    _write(target / "commands_wse3.sh", "#!/usr/bin/env bash\nset -euo pipefail\n" + " \\\n  ".join(argv) + "\n", executable=True)
    _write(target / "inspect_memory.sh", "#!/usr/bin/env bash\nset -euo pipefail\ncs_readelf --ms out/bin/out_0_0.elf\n", executable=True)
    _write(target / "run.py", "#!/usr/bin/env python3\nraise SystemExit('compile-only SRAM probe; run commands_wse3.sh then inspect_memory.sh')\n", executable=True)
    return {
        "compile": {
            "enabled": True, "argv": argv, "entrypoint": "layout.csl", "output": "out",
            "params": {"allocation_words": allocation_words},
            "hardware_fabric_dims": list(FABRIC_DIMS),
            "simulator_fabric_dims": [8, 3],
            "expected_outcome": "success or compiler memory-capacity rejection",
        },
        "runtime": {"enabled": False, "argv": None, "submits_job": False},
        "measurement": {
            "clock_unit": "cycles", "evidence_after_compile": "compiled",
            "requested_allocation_bytes": allocation_bytes,
            "generated_allocation_bytes": allocation_words * 2,
            "memory_report_command": ["cs_readelf", "--ms", "out/out_0_0.elf"],
        },
    }


__all__ = [
    "CalibrationCodegenError", "SupportDecision", "GeneratedCalibrationBundle",
    "support_for_case", "materialize_calibration_bundle",
    "materialize_calibration_bundles", "generate_calibration_bundle",
]
