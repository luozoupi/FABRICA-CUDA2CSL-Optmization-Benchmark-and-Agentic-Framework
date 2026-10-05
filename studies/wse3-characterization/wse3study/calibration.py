"""Deterministic calibration matrices for the WSE-3 study.

The study needs broad architectural coverage, but a literal Cartesian product
of every knob would require millions of wafer runs.  This module encodes the
approved full path baseline and focused one-factor/interaction sweeps.  It is
pure data generation: importing it never compiles or submits a job.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Iterable, Mapping

from .schema import FABRIC_DIMS_WSE3, canonical_hash

CALIBRATION_WARMUPS = 5
CALIBRATION_TRIALS = 100

DIRECTIONS = ("north", "south", "east", "west")
STRAIGHT_HOPS = (1, 2, 4, 8, 16, 32, 64, 128, 256, 512)
STRAIGHT_PAYLOADS = (1, 8, 64, 512, 4096)
VALIDATION_HOPS = frozenset((8, 128))

VECTOR_LENGTHS = (1, 2, 4, 8, 16, 32, 64, 256, 1024, 2048)
STRIDES = (1, 2, 4, 8)
BANK_ALIGNMENTS = tuple(range(8))
DEPENDENCY_CHAINS = (1, 2, 4, 8)
MICROTHREAD_COUNTS = (1, 2, 4, 8)
QUEUE_IDS = tuple(range(8))

# Integer forms are capability-gated by the generated calibration bundle.  A
# compiler rejection is recorded as an unsupported capability, never silently
# dropped from the campaign.
OPERATION_DTYPES: Mapping[str, tuple[str, ...]] = {
    "copy": ("fp16", "fp32", "i16", "i32"),
    "add": ("fp16", "fp32", "i16", "i32"),
    "multiply": ("fp16", "fp32", "i16", "i32"),
    "fma": ("fp16", "fp32"),
    "reduction": ("fp16", "fp32", "i16", "i32"),
}


@dataclass(frozen=True)
class CalibrationCase:
    """One compile/run configuration in a calibration campaign."""

    family: str
    case_id: str
    parameters: Mapping[str, Any]
    split: str = "characterization"
    warmups: int = CALIBRATION_WARMUPS
    trials: int = CALIBRATION_TRIALS

    def to_dict(self) -> dict[str, Any]:
        return {
            "family": self.family,
            "case_id": self.case_id,
            "parameters": dict(self.parameters),
            "split": self.split,
            "warmups": self.warmups,
            "trials": self.trials,
        }


def _case(
    family: str,
    name: str,
    parameters: Mapping[str, Any],
    *,
    split: str = "characterization",
) -> CalibrationCase:
    return CalibrationCase(
        family=family,
        case_id=f"{family}-{name}",
        parameters=dict(parameters),
        split=split,
    )


def _unique(cases: Iterable[CalibrationCase]) -> list[CalibrationCase]:
    """Keep first occurrence while guarding against accidental ID conflicts."""

    result: list[CalibrationCase] = []
    by_config: set[str] = set()
    by_id: dict[str, str] = {}
    for case in cases:
        config_hash = canonical_hash(
            {"family": case.family, "parameters": case.parameters}
        )
        existing = by_id.get(case.case_id)
        if existing is not None and existing != config_hash:
            raise ValueError(f"calibration case ID collision: {case.case_id}")
        by_id[case.case_id] = config_hash
        if config_hash in by_config:
            continue
        by_config.add(config_hash)
        result.append(case)
    return result


def data_movement_cases(
    *, fabric_dims: tuple[int, int] = FABRIC_DIMS_WSE3
) -> list[CalibrationCase]:
    """Return the approved path, turn, multicast, and contention matrix.

    The straight-path arm is intentionally complete.  The contention arm uses
    one-factor curves plus four targeted interactions instead of multiplying
    sources, colors, queues, microthreads, and delays together.
    """

    if len(fabric_dims) != 2 or min(fabric_dims) <= 0:
        raise ValueError("fabric_dims must be two positive integers")

    cases: list[CalibrationCase] = []

    hops_by_direction = {direction: list(STRAIGHT_HOPS) for direction in DIRECTIONS}
    # The marketed WSE-3 compile fabric is tall enough for 1024 vertical hops,
    # but not 1024 horizontal hops.  Respect custom/simulator bounds as well.
    width, height = fabric_dims
    if height > 1024:
        hops_by_direction["north"].append(1024)
        hops_by_direction["south"].append(1024)
    if width > 1024:
        hops_by_direction["east"].append(1024)
        hops_by_direction["west"].append(1024)

    for direction in DIRECTIONS:
        for hops in hops_by_direction[direction]:
            for payload in STRAIGHT_PAYLOADS:
                split = "validation" if hops in VALIDATION_HOPS else "fit"
                cases.append(
                    _case(
                        "straight",
                        f"{direction}-h{hops}-p{payload}",
                        {
                            "direction": direction,
                            "hops": hops,
                            "payload_wavelets": payload,
                            "turns": 0,
                        },
                        split=split,
                    )
                )

    # Clockwise and counter-clockwise cardinal turns expose orientation-specific
    # costs while holding payload at the approved 512-wavelet baseline.
    turn_pairs = (
        ("north", "east"),
        ("east", "south"),
        ("south", "west"),
        ("west", "north"),
        ("north", "west"),
        ("west", "south"),
        ("south", "east"),
        ("east", "north"),
    )
    for first, second in turn_pairs:
        for leg_hops in (1, 8, 64, 256):
            cases.append(
                _case(
                    "turn",
                    f"{first}-{second}-l{leg_hops}",
                    {
                        "first_direction": first,
                        "second_direction": second,
                        "first_hops": leg_hops,
                        "second_hops": leg_hops,
                        "payload_wavelets": 512,
                        "turns": 1,
                    },
                )
            )

    for direction in DIRECTIONS:
        for fanout in (2, 4, 8, 16):
            cases.append(
                _case(
                    "multicast",
                    f"{direction}-f{fanout}",
                    {
                        "trunk_direction": direction,
                        "trunk_hops": 32,
                        "fanout": fanout,
                        "payload_wavelets": 512,
                    },
                )
            )

    base = {
        "path_hops": 32,
        "payload_wavelets": 512,
        "sources": 1,
        "color_mode": "distinct",
        # Duplex-safe default: <memcpy> reserves input queues 0/1 and output
        # queue 0, so a base of 0 made every one-factor curve (sources,
        # colour, microthread, delay) and every interaction fail closed on an
        # inherited value rather than on the factor under test.  The dedicated
        # queue sweep below still covers 0 and 1 and still reports them as
        # unsupported, which is the real capability limit.
        "queue_id": 2,
        "microthreads": 1,
        "receiver_delay_cycles": 0,
    }
    contention_configs: list[dict[str, Any]] = []

    def vary(**changes: Any) -> None:
        contention_configs.append({**base, **changes})

    # One-factor curves.
    for sources in (1, 2, 4, 8):
        vary(sources=sources)
    for color_mode in ("same", "distinct"):
        vary(sources=4, color_mode=color_mode)
    for queue_id in QUEUE_IDS:
        vary(queue_id=queue_id)
    for microthreads in MICROTHREAD_COUNTS:
        vary(microthreads=microthreads)
    for receiver_delay_cycles in (0, 4, 16, 64):
        vary(receiver_delay_cycles=receiver_delay_cycles)

    # Focused interactions: source/color, source/backpressure, queue/thread,
    # and color/backpressure at saturation.  This is deliberately not the full
    # 4*2*8*4*4 Cartesian product.
    for sources in (2, 4, 8):
        for color_mode in ("same", "distinct"):
            vary(sources=sources, color_mode=color_mode)
    for sources in (2, 4, 8):
        for delay in (16, 64):
            vary(sources=sources, receiver_delay_cycles=delay)
    for queue_id in QUEUE_IDS:
        for microthreads in (1, 8):
            vary(sources=4, queue_id=queue_id, microthreads=microthreads)
    for color_mode in ("same", "distinct"):
        for delay in (16, 64):
            vary(sources=8, color_mode=color_mode, receiver_delay_cycles=delay)

    # Deduplicate overlaps, then reserve exactly ceil(20%) for validation using
    # a stable hash ranking.  This does not change when Python hash seeds do.
    unique_configs: dict[str, dict[str, Any]] = {}
    for config in contention_configs:
        unique_configs.setdefault(canonical_hash(config), config)
    ranked = sorted(unique_configs.items())
    validation_count = (len(ranked) + 4) // 5
    validation_hashes = {key for key, _ in ranked[:validation_count]}
    for config_hash, config in ranked:
        name = (
            f"s{config['sources']}-{config['color_mode']}-q{config['queue_id']}-"
            f"m{config['microthreads']}-d{config['receiver_delay_cycles']}-"
            f"{config_hash[:8]}"
        )
        cases.append(
            _case(
                "contention",
                name,
                config,
                split="validation" if config_hash in validation_hashes else "fit",
            )
        )

    return _unique(cases)


def single_pe_cases() -> list[CalibrationCase]:
    """Return compute/SRAM experiments with focused secondary interactions."""

    cases: list[CalibrationCase] = []

    # Primary throughput curves: operation/type/mode as vector length grows.
    # Secondary knobs remain at their neutral values in this arm.
    for operation, dtypes in OPERATION_DTYPES.items():
        for dtype in dtypes:
            for mode in ("scalar", "dsd"):
                for vector_length in VECTOR_LENGTHS:
                    cases.append(
                        _case(
                            "single-pe-throughput",
                            f"{operation}-{dtype}-{mode}-n{vector_length}",
                            {
                                "operation": operation,
                                "dtype": dtype,
                                "mode": mode,
                                "vector_length": vector_length,
                                "stride": 1,
                                "bank_alignment": 0,
                                "dependency_chains": 1,
                                "microthreads": 1,
                                "queue_id": 0,
                            },
                        )
                    )

    secondary_base = {
        "operation": "fma",
        "dtype": "fp32",
        "mode": "dsd",
        "vector_length": 256,
        "stride": 1,
        "bank_alignment": 0,
        "dependency_chains": 1,
        "microthreads": 1,
        "queue_id": 0,
    }

    def secondary(family: str, name: str, **changes: Any) -> None:
        cases.append(_case(family, name, {**secondary_base, **changes}))

    for stride in STRIDES:
        secondary("single-pe-stride", f"s{stride}", stride=stride)
    for alignment in BANK_ALIGNMENTS:
        secondary("single-pe-bank", f"a{alignment}", bank_alignment=alignment)
    for chains in DEPENDENCY_CHAINS:
        secondary("single-pe-chains", f"c{chains}", dependency_chains=chains)
    for microthreads in MICROTHREAD_COUNTS:
        secondary("single-pe-microthreads", f"m{microthreads}", microthreads=microthreads)
    for queue_id in QUEUE_IDS:
        secondary("single-pe-queue", f"q{queue_id}", queue_id=queue_id)

    # Targeted interactions expose bank/stride, dependency/thread, and
    # queue/thread coupling without building the full secondary Cartesian set.
    for alignment in BANK_ALIGNMENTS:
        for stride in (2, 8):
            secondary(
                "single-pe-bank-stride",
                f"a{alignment}-s{stride}",
                bank_alignment=alignment,
                stride=stride,
            )
    for chains in DEPENDENCY_CHAINS:
        for microthreads in MICROTHREAD_COUNTS:
            secondary(
                "single-pe-chain-thread",
                f"c{chains}-m{microthreads}",
                dependency_chains=chains,
                microthreads=microthreads,
            )
    for queue_id in QUEUE_IDS:
        for microthreads in (4, 8):
            secondary(
                "single-pe-queue-thread",
                f"q{queue_id}-m{microthreads}",
                queue_id=queue_id,
                microthreads=microthreads,
            )

    # Compile-only monotonic probes bracket the documented 48 KiB PE SRAM
    # without assuming how much remains after code, padding, and metadata.
    for allocation_bytes in (
        1024,
        8192,
        16384,
        24576,
        32768,
        36864,
        40960,
        43008,
        45056,
        46080,
        47104,
        48128,
        49152,
        50176,
        51200,
    ):
        cases.append(
            _case(
                "single-pe-sram",
                f"b{allocation_bytes}",
                {
                    "allocation_bytes": allocation_bytes,
                    "compile_only": True,
                    "report_elf_memory": True,
                },
            )
        )

    return _unique(cases)


def all_calibration_cases() -> list[CalibrationCase]:
    return data_movement_cases() + single_pe_cases()


def calibration_manifest() -> dict[str, Any]:
    movement = data_movement_cases()
    single_pe = single_pe_cases()
    manifest = {
        "schema_version": "1.0.0",
        "defaults": {
            "warmups": CALIBRATION_WARMUPS,
            "trials": CALIBRATION_TRIALS,
            "clock_unit": "cycles",
        },
        "data_movement": [case.to_dict() for case in movement],
        "single_pe": [case.to_dict() for case in single_pe],
        "counts": {
            "data_movement": len(movement),
            "single_pe": len(single_pe),
            "total": len(movement) + len(single_pe),
        },
    }
    manifest["manifest_sha256"] = canonical_hash(manifest)
    return manifest
