"""Analyze single-PE compute, SRAM-bank, queue, and microthread ceilings."""

from __future__ import annotations

from collections import defaultdict
from typing import Any, Iterable, Mapping

from .schema import EvidenceKind, ValidationError
from .telemetry import summarize_cycles

DTYPE_BYTES = {"fp16": 2, "f16": 2, "i16": 2, "fp32": 4, "f32": 4, "i32": 4}
OPS_PER_ELEMENT = {"copy": 0, "add": 1, "multiply": 1, "fma": 2, "reduction": 1}
MEMORY_ACCESSES = {
    "copy": (1, 1),
    "add": (2, 1),
    "multiply": (2, 1),
    "fma": (3, 1),
    "reduction": (1, 0),
}
CONFIGURATION_FIELDS = (
    "stride",
    "bank_alignment",
    "dependency_chains",
    "microthreads",
    "queue_id",
)


def _number(value: Any, default: float = 0.0) -> float:
    if value in (None, ""):
        return default
    try:
        return float(value)
    except (TypeError, ValueError) as exc:
        raise ValidationError(f"single-PE metric is not numeric: {value!r}") from exc


def enrich_trial(row: Mapping[str, Any]) -> dict[str, Any]:
    result = dict(row)
    cycles = _number(row.get("elapsed_cycles", row.get("cycles")))
    length = _number(row.get("vector_length"), 1.0)
    effective_elements = _number(row.get("effective_elements"), length)
    operation = str(row.get("operation", "unknown"))
    dtype = str(row.get("dtype", "fp32"))
    if cycles <= 0 or length <= 0 or effective_elements <= 0:
        raise ValidationError("cycles, vector_length, and effective_elements must be positive")
    reads, writes = MEMORY_ACCESSES.get(operation, (0, 0))
    bytes_per_element = (reads + writes) * DTYPE_BYTES.get(dtype, 0)
    operations = OPS_PER_ELEMENT.get(operation, 0) * effective_elements
    result.update(
        {
            "effective_elements": effective_elements,
            "cycles_per_element": cycles / effective_elements,
            "operations_per_cycle": operations / cycles,
            "bytes_per_cycle": bytes_per_element * effective_elements / cycles,
            "metric_evidence": EvidenceKind.INFERRED.value,
            "metric_source": str(row.get("evidence", "silicon")),
        }
    )
    return result


def analyze_single_pe(
    trials: Iterable[Mapping[str, Any]],
    *,
    instruction_events: Iterable[Mapping[str, Any]] = (),
) -> dict[str, Any]:
    accepted: list[dict[str, Any]] = []
    sram_probes: list[Mapping[str, Any]] = []
    for row in trials:
        if row.get("family") == "single-pe-sram":
            sram_probes.append(row)
            continue
        if row.get("correctness", True) not in (True, "true", "True", "pass", "PASS", ""):
            continue
        try:
            accepted.append(enrich_trial(row))
        except ValidationError:
            continue

    grouped_cycles: dict[
        tuple[str, str, str, int, int, int, int, int, int], list[dict[str, Any]]
    ] = defaultdict(list)
    best: dict[tuple[str, str, str], dict[str, Any]] = {}
    for row in accepted:
        key = (
            str(row.get("operation")),
            str(row.get("dtype")),
            str(row.get("mode")),
            int(_number(row.get("vector_length"), 1)),
            int(_number(row.get("stride"), 1)),
            int(_number(row.get("bank_alignment"), 0)),
            int(_number(row.get("dependency_chains"), 1)),
            int(_number(row.get("microthreads"), 1)),
            int(_number(row.get("queue_id"), 0)),
        )
        grouped_cycles[key].append(row)
        throughput_key = key[:3]
        current = best.get(throughput_key)
        if current is None or row["operations_per_cycle"] > current["operations_per_cycle"]:
            best[throughput_key] = row

    throughput_curves = []
    for key, rows in sorted(grouped_cycles.items()):
        operation, dtype, mode, length, stride, alignment, chains, microthreads, queue_id = key
        cycles = [_number(row.get("elapsed_cycles", row.get("cycles"))) for row in rows]
        stats = summarize_cycles(cycles)
        median = float(stats["median"])
        effective_elements = _number(rows[0].get("effective_elements"), length)
        reads, writes = MEMORY_ACCESSES.get(operation, (0, 0))
        throughput_curves.append(
            {
                "operation": operation,
                "dtype": dtype,
                "mode": mode,
                "vector_length": length,
                "effective_elements": effective_elements,
                "stride": stride,
                "bank_alignment": alignment,
                "dependency_chains": chains,
                "microthreads": microthreads,
                "queue_id": queue_id,
                "cycle_statistics": stats,
                "cycles_per_element": median / effective_elements,
                "operations_per_cycle": OPS_PER_ELEMENT.get(operation, 0) * effective_elements / median,
                "bytes_per_cycle": (reads + writes) * DTYPE_BYTES.get(dtype, 0) * effective_elements / median,
                "evidence": EvidenceKind.INFERRED.value,
                "trained_from": EvidenceKind.SILICON.value,
            }
        )

    simd_widths: dict[str, set[int]] = defaultdict(set)
    for event in instruction_events:
        # ``simdi`` in the SDK pipeline trace is retained as a raw SIMD-index
        # field; it is not documented as an instruction width.  Only an
        # explicitly decoded ``simd_width`` observation may support a width
        # conclusion.
        width = event.get("simd_width")
        if width in (None, ""):
            continue
        try:
            parsed = int(width)
        except (TypeError, ValueError):
            continue
        operation = str(event.get("operation") or event.get("opcode") or event.get("name") or "unknown")
        simd_widths[operation].add(parsed)

    successful_allocations = sorted(
        int(_number(row.get("allocation_bytes")))
        for row in sram_probes
        if row.get("status") in {"pass", "compiled", "success", "compile_pass", True}
        or row.get("compile_success") is True
    )
    failed_allocations = sorted(
        int(_number(row.get("allocation_bytes")))
        for row in sram_probes
        if row.get("status")
        in {"fail", "compile_fail", "compile_capacity_fail", "unsupported", False}
        or row.get("capacity_failure") is True
    )
    sram_ceiling = {
        "largest_compiling_allocation_bytes": max(successful_allocations) if successful_allocations else None,
        "first_failing_allocation_bytes": min(failed_allocations) if failed_allocations else None,
        "evidence": EvidenceKind.COMPILED.value,
        "note": "PE code and data share 48 KiB; allocation ceiling is bundle-specific",
    }
    if successful_allocations:
        largest = max(
            (
                row
                for row in sram_probes
                if int(_number(row.get("allocation_bytes")))
                == successful_allocations[-1]
            ),
            key=lambda row: int(_number(row.get("allocation_bytes"))),
        )
        sram_ceiling["largest_compiling_breakdown"] = {
            field: largest.get(field)
            for field in (
                "code_bytes",
                "data_bytes",
                "padding_bytes",
                "bank_occupation",
                "elf_symbols",
            )
            if largest.get(field) is not None
        }

    vectorized_speedups = []
    by_operation_dtype_length = defaultdict(dict)
    for curve in throughput_curves:
        key = (
            curve["operation"],
            curve["dtype"],
            curve["vector_length"],
            *(curve[field] for field in CONFIGURATION_FIELDS),
        )
        by_operation_dtype_length[key][curve["mode"]] = curve
    for key, modes in sorted(by_operation_dtype_length.items()):
        if "scalar" not in modes or "dsd" not in modes:
            continue
        scalar = float(modes["scalar"]["cycle_statistics"]["median"])
        dsd = float(modes["dsd"]["cycle_statistics"]["median"])
        vectorized_speedups.append(
            {
                "operation": key[0],
                "dtype": key[1],
                "vector_length": key[2],
                "scalar_over_dsd": scalar / dsd if dsd > 0 else None,
                "evidence": EvidenceKind.INFERRED.value,
            }
        )

    def cycle_penalties(field: str, baseline: int) -> list[dict[str, Any]]:
        grouped: dict[tuple[Any, ...], dict[int, dict[str, Any]]] = defaultdict(dict)
        for curve in throughput_curves:
            key = tuple(
                curve[name]
                for name in (
                    "operation",
                    "dtype",
                    "mode",
                    "vector_length",
                    *[name for name in CONFIGURATION_FIELDS if name != field],
                )
            )
            grouped[key][int(curve[field])] = curve
        penalties: list[dict[str, Any]] = []
        for modes in grouped.values():
            if baseline not in modes:
                continue
            baseline_cycles = float(modes[baseline]["cycle_statistics"]["median"])
            for value, curve in sorted(modes.items()):
                cycles = float(curve["cycle_statistics"]["median"])
                penalties.append(
                    {
                        "operation": curve["operation"],
                        "dtype": curve["dtype"],
                        "mode": curve["mode"],
                        "vector_length": curve["vector_length"],
                        field: value,
                        "baseline": baseline,
                        "cycles_over_baseline": cycles / baseline_cycles
                        if baseline_cycles > 0
                        else None,
                        "throughput_speedup": baseline_cycles / cycles
                        if cycles > 0
                        else None,
                        "evidence": EvidenceKind.INFERRED.value,
                    }
                )
        return penalties

    activation_and_saturation = []
    baseline_curves: dict[tuple[str, str, str], list[dict[str, Any]]] = defaultdict(list)
    for curve in throughput_curves:
        if all(
            int(curve[field]) == default
            for field, default in (
                ("stride", 1),
                ("bank_alignment", 0),
                ("dependency_chains", 1),
                ("microthreads", 1),
                ("queue_id", 0),
            )
        ):
            baseline_curves[(curve["operation"], curve["dtype"], curve["mode"])].append(curve)
    for key, curves in sorted(baseline_curves.items()):
        if len(curves) < 2:
            continue
        xs = [float(curve["effective_elements"]) for curve in curves]
        ys = [float(curve["cycle_statistics"]["median"]) for curve in curves]
        mean_x = sum(xs) / len(xs)
        mean_y = sum(ys) / len(ys)
        denominator = sum((value - mean_x) ** 2 for value in xs)
        slope = (
            sum((x - mean_x) * (y - mean_y) for x, y in zip(xs, ys)) / denominator
            if denominator > 0
            else None
        )
        intercept = mean_y - slope * mean_x if slope is not None else None
        peak = max(float(curve["operations_per_cycle"]) for curve in curves)
        saturated = sorted(
            (
                curve
                for curve in curves
                if peak == 0
                or float(curve["operations_per_cycle"]) >= 0.95 * peak
            ),
            key=lambda curve: int(curve["vector_length"]),
        )
        activation_and_saturation.append(
            {
                "operation": key[0],
                "dtype": key[1],
                "mode": key[2],
                "activation_overhead_cycles": intercept,
                "steady_state_cycles_per_element": slope,
                "peak_operations_per_cycle": peak,
                "saturation_vector_length": (
                    saturated[0]["vector_length"] if saturated else None
                ),
                "evidence": EvidenceKind.INFERRED.value,
            }
        )

    return {
        "schema": "wse3-single-pe-model-v1",
        "execution_model": {
            "inter_pe": "spatial MIMD",
            "intra_pe": "DSD/SIMD with event-driven tasks and asynchronous microthreads",
            "is_cuda_simt": False,
            "evidence": EvidenceKind.DOCUMENTED.value,
        },
        "trial_count": len(accepted),
        "throughput_curves": throughput_curves,
        "best_observed": [
            {
                "operation": key[0],
                "dtype": key[1],
                "mode": key[2],
                **{
                    field: row.get(field)
                    for field in (
                        "vector_length",
                        "operations_per_cycle",
                        "bytes_per_cycle",
                        "cycles_per_element",
                        "microthreads",
                        "queue_id",
                        "bank_alignment",
                    )
                },
                "evidence": EvidenceKind.INFERRED.value,
            }
            for key, row in sorted(best.items())
        ],
        "vectorized_speedups": vectorized_speedups,
        "activation_and_saturation": activation_and_saturation,
        "bank_alignment_penalties": cycle_penalties("bank_alignment", 0),
        "stride_penalties": cycle_penalties("stride", 1),
        "dependency_chain_scaling": cycle_penalties("dependency_chains", 1),
        "microthread_scaling": cycle_penalties("microthreads", 1),
        "queue_scaling": cycle_penalties("queue_id", 0),
        "bottleneck_classification": {
            "status": "requires calibrated compute/SRAM/fabric reference ceilings",
            "evidence": EvidenceKind.INFERRED.value,
            "regimes": [],
        },
        "observed_simd_widths": {
            operation: sorted(widths) for operation, widths in sorted(simd_widths.items())
        },
        "simd_width_evidence": EvidenceKind.SIMULATOR.value,
        "sram_ceiling": sram_ceiling,
        "limitations": [
            "hardware throughput does not by itself prove SIMD width",
            "microthread contexts are asynchronous execution contexts, not SIMD lanes",
            "raw performance-counter slots remain unlabeled",
        ],
    }
