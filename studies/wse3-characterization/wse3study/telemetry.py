"""Host-side decoding and validation for device timestamp telemetry."""

from __future__ import annotations

import csv
import math
import statistics
from pathlib import Path
from typing import Any, Iterable, Mapping, Sequence

from .schema import MEASUREMENT_FIELDS, SCHEMA_VERSION, ValidationError, evidence_value

U48_MODULUS = 1 << 48
U48_MASK = U48_MODULUS - 1
DEFAULT_DEAD_TIMER_FLOOR = 100


def words_to_u48(words: Sequence[int]) -> int:
    if len(words) != 3:
        raise ValidationError(f"a WSE timestamp requires three u16 words, got {len(words)}")
    checked = []
    for word in words:
        if not isinstance(word, int) or not 0 <= word <= 0xFFFF:
            raise ValidationError(f"timestamp word is not u16: {word!r}")
        checked.append(word)
    return checked[0] | (checked[1] << 16) | (checked[2] << 32)


def u48_to_words(value: int) -> tuple[int, int, int]:
    if not isinstance(value, int) or not 0 <= value < U48_MODULUS:
        raise ValidationError(f"timestamp is outside unsigned 48-bit range: {value!r}")
    return value & 0xFFFF, (value >> 16) & 0xFFFF, (value >> 32) & 0xFFFF


def elapsed_u48(start: int, end: int, *, allow_wrap: bool = True) -> int:
    if not 0 <= start < U48_MODULUS or not 0 <= end < U48_MODULUS:
        raise ValidationError("start/end must be unsigned 48-bit timestamps")
    if end >= start:
        return end - start
    if not allow_wrap:
        raise ValidationError("timestamp wrapped while allow_wrap=False")
    return (end - start) & U48_MASK


def synchronized_cycle(timestamp: int, reference: int, hop_correction: int = 0) -> int:
    """Normalize a PE TSC against its measured synchronization reference.

    ``hop_correction`` is explicit because the official bandwidth-test sync
    propagates its reference wavelet across the rectangle.  No correction is
    silently inferred from coordinates.
    """

    return elapsed_u48(reference, timestamp) - int(hop_correction)


def validate_timed_trial(
    trial: Mapping[str, Any], *, dead_timer_floor: int = DEFAULT_DEAD_TIMER_FLOOR
) -> list[str]:
    errors: list[str] = []
    cycles = trial.get("elapsed_cycles")
    if not isinstance(cycles, int):
        errors.append("elapsed_cycles is missing or not an integer")
    elif cycles <= 0:
        errors.append(f"elapsed_cycles={cycles} is not positive")
    elif cycles < dead_timer_floor and trial.get("timer_validated") not in {
        True,
        "true",
        "True",
        "1",
    }:
        errors.append(f"elapsed_cycles={cycles} is below dead-timer floor {dead_timer_floor}")
    if trial.get("timing_method") not in {"device_internal", "device_internal_synchronized"}:
        errors.append("timed region is not wholly device-internal")
    if trial.get("arm") == "hardware" and trial.get("evidence") != "silicon":
        errors.append("hardware trial must carry silicon evidence")
    if trial.get("correctness") not in {True, "true", "True", "pass", "PASS"}:
        errors.append("correctness did not pass")
    return errors


def percentile(values: Sequence[float], percentile_value: float) -> float:
    if not values:
        raise ValidationError("cannot compute a percentile of an empty sequence")
    if not 0 <= percentile_value <= 100:
        raise ValidationError("percentile must be in [0, 100]")
    ordered = sorted(float(value) for value in values)
    if len(ordered) == 1:
        return ordered[0]
    position = (len(ordered) - 1) * percentile_value / 100.0
    lower = math.floor(position)
    upper = math.ceil(position)
    if lower == upper:
        return ordered[lower]
    fraction = position - lower
    return ordered[lower] * (1.0 - fraction) + ordered[upper] * fraction


def summarize_cycles(values: Sequence[int | float]) -> dict[str, float | int]:
    if not values:
        return {"count": 0}
    data = [float(value) for value in values]
    median = statistics.median(data)
    mad = statistics.median(abs(value - median) for value in data)
    result: dict[str, float | int] = {
        "count": len(data),
        "min": min(data),
        "median": median,
        "p95": percentile(data, 95),
        "max": max(data),
        "mean": statistics.fmean(data),
        "stdev": statistics.stdev(data) if len(data) > 1 else 0.0,
        "mad": mad,
    }
    return result


def telemetry_overhead_pct(low_intrusion: Sequence[int], full: Sequence[int]) -> float:
    low = summarize_cycles(low_intrusion)
    detailed = summarize_cycles(full)
    baseline = float(low.get("median", 0.0))
    if baseline <= 0:
        raise ValidationError("low-intrusion median must be positive")
    return 100.0 * (float(detailed.get("median", 0.0)) / baseline - 1.0)


def normalize_measurement(row: Mapping[str, Any]) -> dict[str, Any]:
    normalized = {field: row.get(field, "") for field in MEASUREMENT_FIELDS}
    normalized["schema_version"] = row.get("schema_version") or SCHEMA_VERSION
    normalized["evidence"] = evidence_value(str(row.get("evidence", "inferred")))
    return normalized


def append_measurements(path: str | Path, rows: Iterable[Mapping[str, Any]]) -> int:
    target = Path(path)
    target.parent.mkdir(parents=True, exist_ok=True)
    exists = target.exists() and target.stat().st_size > 0
    count = 0
    with target.open("a", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=MEASUREMENT_FIELDS, extrasaction="ignore")
        if not exists:
            writer.writeheader()
        for row in rows:
            writer.writerow(normalize_measurement(row))
            count += 1
    return count


def write_measurements(path: str | Path, rows: Iterable[Mapping[str, Any]]) -> int:
    """Replace a measurement table deterministically.

    Campaign ledgers are append-only; regenerating this projection prevents a
    resumed campaign from duplicating previously accepted rows.
    """

    target = Path(path)
    target.parent.mkdir(parents=True, exist_ok=True)
    temporary = target.with_name(f".{target.name}.tmp")
    count = 0
    with temporary.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=MEASUREMENT_FIELDS, extrasaction="ignore")
        writer.writeheader()
        for row in rows:
            writer.writerow(normalize_measurement(row))
            count += 1
    temporary.replace(target)
    return count


def load_measurements(path: str | Path) -> list[dict[str, str]]:
    with Path(path).open("r", newline="", encoding="utf-8") as handle:
        return list(csv.DictReader(handle))
