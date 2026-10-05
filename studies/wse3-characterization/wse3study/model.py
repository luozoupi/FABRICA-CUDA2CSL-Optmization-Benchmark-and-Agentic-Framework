"""Small, dependency-free latency-model fitter.

The implementation intentionally avoids SciPy/NumPy so report generation can
run on ALCF login nodes.  Features are standardized before solving the normal
equations, and the returned coefficients are converted back to physical units
(cycles/hop, cycles/turn, and cycles/wavelet).
"""

from __future__ import annotations

import math
import random
import statistics
from typing import Any, Iterable, Mapping, Sequence

from .schema import EvidenceKind, ValidationError, evidence_record

BASE_FEATURES = (
    "east_hops",
    "west_hops",
    "north_hops",
    "south_hops",
    "turns",
    "payload_wavelets",
    "contention_sources",
    "receiver_delay_cycles",
)
EXTENDED_FEATURES = BASE_FEATURES + (
    "payload_x_contention",
    "hops_x_contention",
)
VALIDATION_HOPS = {8, 128}


def _as_float(value: Any, default: float = 0.0) -> float:
    if value in (None, ""):
        return default
    if isinstance(value, bool):
        return float(value)
    try:
        return float(value)
    except (TypeError, ValueError) as exc:
        raise ValidationError(f"expected a numeric value, got {value!r}") from exc


def _truthy(value: Any) -> bool:
    if isinstance(value, str):
        return value.strip().lower() in {"1", "true", "yes", "validation", "holdout"}
    return bool(value)


def feature_row(row: Mapping[str, Any], features: Sequence[str] = BASE_FEATURES) -> list[float]:
    values = {name: _as_float(row.get(name, 0)) for name in BASE_FEATURES}
    total_hops = sum(values[name] for name in ("east_hops", "west_hops", "north_hops", "south_hops"))
    values["payload_x_contention"] = values["payload_wavelets"] * max(
        0.0, values["contention_sources"] - 1.0
    )
    values["hops_x_contention"] = total_hops * max(0.0, values["contention_sources"] - 1.0)
    return [values[name] for name in features]


def response_value(row: Mapping[str, Any]) -> float:
    for key in ("elapsed_cycles", "cycles", "timestamp_delta"):
        if row.get(key) not in (None, ""):
            return _as_float(row[key])
    raise ValidationError("latency sample has no elapsed_cycles/cycles/timestamp_delta")


def is_validation_sample(row: Mapping[str, Any]) -> bool:
    if _truthy(row.get("validation")) or _truthy(row.get("is_validation")):
        return True
    hops = int(sum(feature_row(row)[:4]))
    if hops in VALIDATION_HOPS:
        return True
    # Calibration generators mark every fifth contention case.  Retain a
    # deterministic fallback for externally supplied rows.
    if _as_float(row.get("contention_sources", 1), 1) > 1:
        case_index = row.get("case_index")
        if case_index not in (None, ""):
            return int(case_index) % 5 == 0
    return False


def _solve(matrix: list[list[float]], vector: list[float]) -> list[float]:
    n = len(vector)
    augmented = [list(matrix[row]) + [vector[row]] for row in range(n)]
    for column in range(n):
        pivot = max(range(column, n), key=lambda row: abs(augmented[row][column]))
        if abs(augmented[pivot][column]) < 1e-12:
            raise ValidationError("latency feature matrix is singular")
        augmented[column], augmented[pivot] = augmented[pivot], augmented[column]
        divisor = augmented[column][column]
        augmented[column] = [value / divisor for value in augmented[column]]
        for row in range(n):
            if row == column:
                continue
            factor = augmented[row][column]
            if factor == 0:
                continue
            augmented[row] = [
                augmented[row][index] - factor * augmented[column][index]
                for index in range(n + 1)
            ]
    return [augmented[row][-1] for row in range(n)]


def _fit(rows: Sequence[Mapping[str, Any]], features: Sequence[str]) -> dict[str, Any]:
    if len(rows) < len(features) + 1:
        raise ValidationError(
            f"need at least {len(features) + 1} samples for {len(features)} features, got {len(rows)}"
        )
    raw_x = [feature_row(row, features) for row in rows]
    y = [response_value(row) for row in rows]
    means = [statistics.fmean(column) for column in zip(*raw_x)]
    scales: list[float] = []
    for index, mean in enumerate(means):
        variance = statistics.fmean((values[index] - mean) ** 2 for values in raw_x)
        scales.append(math.sqrt(variance) if variance > 1e-20 else 1.0)
    x = [[1.0] + [(values[i] - means[i]) / scales[i] for i in range(len(features))] for values in raw_x]
    width = len(features) + 1
    xtx = [[0.0 for _ in range(width)] for _ in range(width)]
    xty = [0.0 for _ in range(width)]
    for values, target in zip(x, y):
        for i in range(width):
            xty[i] += values[i] * target
            for j in range(width):
                xtx[i][j] += values[i] * values[j]
    # Tiny ridge on feature diagonals prevents a constant optional feature from
    # making otherwise useful directional fits impossible.
    for i in range(1, width):
        xtx[i][i] += 1e-9
    standardized = _solve(xtx, xty)
    coefficients = {
        name: standardized[index + 1] / scales[index]
        for index, name in enumerate(features)
    }
    intercept = standardized[0] - sum(
        coefficients[name] * means[index] for index, name in enumerate(features)
    )
    return {"intercept": intercept, "coefficients": coefficients, "features": list(features)}


def predict_latency(model: Mapping[str, Any], row: Mapping[str, Any]) -> float:
    features = list(model.get("features") or model.get("coefficients", {}).keys())
    values = feature_row(row, features)
    coefficients = model.get("coefficients", {})
    intercept = model.get("intercept", model.get("endpoint_cycles", 0.0))
    return float(intercept) + sum(
        _as_float(coefficients.get(name, 0.0)) * value for name, value in zip(features, values)
    )


def _metrics(model: Mapping[str, Any], rows: Sequence[Mapping[str, Any]]) -> dict[str, float | int | None]:
    if not rows:
        return {"count": 0, "mape_pct": None, "mae_cycles": None, "r2": None}
    actual = [response_value(row) for row in rows]
    predicted = [predict_latency(model, row) for row in rows]
    absolute = [abs(a - p) for a, p in zip(actual, predicted)]
    percentage = [100.0 * error / abs(a) for error, a in zip(absolute, actual) if a != 0]
    mean_y = statistics.fmean(actual)
    ss_res = sum((a - p) ** 2 for a, p in zip(actual, predicted))
    ss_tot = sum((a - mean_y) ** 2 for a in actual)
    return {
        "count": len(rows),
        "mape_pct": statistics.median(percentage) if percentage else None,
        "mae_cycles": statistics.fmean(absolute),
        "r2": 1.0 - ss_res / ss_tot if ss_tot > 0 else None,
    }


def _residual_rows(
    model: Mapping[str, Any], rows: Sequence[Mapping[str, Any]]
) -> list[dict[str, Any]]:
    residuals: list[dict[str, Any]] = []
    for index, row in enumerate(rows):
        actual = response_value(row)
        predicted = predict_latency(model, row)
        residual = actual - predicted
        residuals.append(
            {
                "case_id": row.get("case_id", row.get("configuration_id", index)),
                "actual_cycles": actual,
                "predicted_cycles": predicted,
                "residual_cycles": residual,
                "absolute_error_cycles": abs(residual),
                "absolute_percentage_error": (
                    100.0 * abs(residual) / abs(actual) if actual != 0 else None
                ),
                "uncontended": _as_float(row.get("contention_sources", 1), 1) <= 1,
            }
        )
    return residuals


def _bootstrap_intervals(
    rows: Sequence[Mapping[str, Any]],
    features: Sequence[str],
    *,
    iterations: int,
    seed: int,
) -> dict[str, dict[str, float]]:
    if iterations <= 0:
        return {}
    rng = random.Random(seed)
    values: dict[str, list[float]] = {"endpoint_cycles": []}
    values.update({name: [] for name in features})
    for _ in range(iterations):
        sample = [rows[rng.randrange(len(rows))] for _ in rows]
        try:
            fitted = _fit(sample, features)
        except ValidationError:
            continue
        values["endpoint_cycles"].append(float(fitted["intercept"]))
        for name in features:
            values[name].append(float(fitted["coefficients"][name]))

    def quantile(items: Sequence[float], fraction: float) -> float:
        ordered = sorted(items)
        if not ordered:
            return math.nan
        index = (len(ordered) - 1) * fraction
        low, high = math.floor(index), math.ceil(index)
        if low == high:
            return ordered[low]
        return ordered[low] + (ordered[high] - ordered[low]) * (index - low)

    return {
        name: {"low_95": quantile(items, 0.025), "high_95": quantile(items, 0.975)}
        for name, items in values.items()
        if items
    }


def fit_latency_model(
    samples: Iterable[Mapping[str, Any]], *, bootstrap_iterations: int = 200, seed: int = 0
) -> dict[str, Any]:
    rows = [
        row
        for row in samples
        if row.get("evidence", "silicon") == "silicon"
        and row.get("correctness", True) in (True, "pass", "PASS", "true", "True", "")
    ]
    training = [row for row in rows if not is_validation_sample(row)]
    validation = [row for row in rows if is_validation_sample(row)]
    uncontended_validation = [
        row
        for row in validation
        if _as_float(row.get("contention_sources", 1), 1) <= 1
    ]
    base = _fit(training, BASE_FEATURES)
    selected = base
    model_kind = "base"
    base_validation = _metrics(base, validation)
    base_target_metrics = _metrics(base, uncontended_validation)
    if uncontended_validation and (base_target_metrics["mape_pct"] or 0.0) > 10.0:
        try:
            extended = _fit(training, EXTENDED_FEATURES)
        except ValidationError:
            extended = None
        if extended is not None:
            extended_target = _metrics(extended, uncontended_validation)
            if (extended_target["mape_pct"] or math.inf) < (
                base_target_metrics["mape_pct"] or math.inf
            ):
                selected = extended
                model_kind = "extended_interactions"
    coefficients = dict(selected["coefficients"])
    payload_cost = coefficients.get("payload_wavelets", 0.0)
    result = {
        "schema": "wse3-latency-model-v1",
        "evidence": EvidenceKind.INFERRED.value,
        "trained_from": EvidenceKind.SILICON.value,
        "model_kind": model_kind,
        "formula": (
            "endpoint + sum(direction_hops * direction_cost) + turns * turn_cost + "
            "payload_wavelets * payload_cost + contention/backpressure terms"
        ),
        "features": selected["features"],
        "endpoint_cycles": selected["intercept"],
        "coefficients": coefficients,
        "wavelets_per_cycle": 1.0 / payload_cost if payload_cost > 0 else None,
        "training_metrics": _metrics(selected, training),
        "validation_metrics": _metrics(selected, validation),
        "uncontended_validation_metrics": _metrics(
            selected, uncontended_validation
        ),
        "validation_target_mape_pct": 10.0,
        "validation_target_met": (
            (_metrics(selected, uncontended_validation)["mape_pct"] or math.inf)
            <= 10.0
            if uncontended_validation
            else None
        ),
        "validation_residuals": _residual_rows(selected, validation),
        "confidence_intervals": _bootstrap_intervals(
            training,
            selected["features"],
            iterations=bootstrap_iterations,
            seed=seed,
        ),
        "sample_counts": {
            "total": len(rows),
            "training": len(training),
            "validation": len(validation),
            "uncontended_validation": len(uncontended_validation),
        },
    }
    result["endpoint"] = evidence_record(
        selected["intercept"],
        EvidenceKind.INFERRED,
        source="ordinary least squares over silicon TSC samples",
        uncertainty="see confidence_intervals.endpoint_cycles",
    )
    return result
