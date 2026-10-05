"""Dependency-free SVG renderers for evidence-labelled WSE-3 layouts."""

from __future__ import annotations

import html
import math
from pathlib import Path
from typing import Any, Mapping, Sequence


_PE_COLORS = {
    "application": "#2563eb",
    "io-west": "#ea580c",
    "io-east": "#f97316",
    "routing-only": "#7c3aed",
}
_EDGE_COLORS = {
    "application": "#0f766e",
    "system": "#c2410c",
}


def _value(record: Any) -> Any:
    if isinstance(record, Mapping) and "value" in record:
        return record["value"]
    return record


def _fabric_dimensions(layout: Mapping[str, Any], *, full_system: bool = False) -> tuple[int, int]:
    fabric = layout.get("fabric") or {}
    dimensions = _value(
        fabric.get("system_dimensions") if full_system else fabric.get("dimensions")
    ) or {}
    if full_system and not dimensions:
        dimensions = _value(fabric.get("dimensions")) or {}
    try:
        width = int(dimensions.get("width"))
        height = int(dimensions.get("height"))
    except (AttributeError, TypeError, ValueError):
        return (1, 1)
    return (max(width, 1), max(height, 1))


def _kernel_name(layout: Mapping[str, Any]) -> str:
    kernel = layout.get("kernel") or {}
    return str(kernel.get("name") or "unnamed kernel")


def _coordinate_bounds(
    layout: Mapping[str, Any], mode: str
) -> tuple[float, float, float, float]:
    fabric_width, fabric_height = _fabric_dimensions(
        layout, full_system=(mode == "fabric")
    )
    if mode == "fabric":
        return (0.0, 0.0, float(fabric_width), float(fabric_height))

    coordinates: list[tuple[float, float]] = []
    for pe in layout.get("pes") or []:
        fabric = pe.get("fabric") or {}
        if "x" in fabric and "y" in fabric:
            coordinates.append((float(fabric["x"]), float(fabric["y"])))
    for edge in layout.get("route_edges") or []:
        for endpoint in (edge.get("from") or {}, edge.get("to") or {}):
            if "x" in endpoint and "y" in endpoint:
                coordinates.append((float(endpoint["x"]), float(endpoint["y"])))

    if not coordinates:
        rectangle = _value((layout.get("application") or {}).get("rectangle")) or {}
        offsets = _value((layout.get("fabric") or {}).get("offsets")) or {}
        if rectangle and offsets:
            x0, y0 = float(offsets.get("x", 0)), float(offsets.get("y", 0))
            x1 = x0 + float(rectangle.get("width", 1))
            y1 = y0 + float(rectangle.get("height", 1))
            coordinates.extend([(x0, y0), (x1 - 1, y1 - 1)])
        else:
            return (0.0, 0.0, float(fabric_width), float(fabric_height))

    x_values = [item[0] for item in coordinates]
    y_values = [item[1] for item in coordinates]
    x0 = max(0.0, min(x_values) - 1.0)
    y0 = max(0.0, min(y_values) - 1.0)
    x1 = min(float(fabric_width), max(x_values) + 2.0)
    y1 = min(float(fabric_height), max(y_values) + 2.0)
    if x1 <= x0:
        x1 = x0 + 1.0
    if y1 <= y0:
        y1 = y0 + 1.0
    return (x0, y0, x1, y1)


def _display_size(bounds: Sequence[float]) -> tuple[int, int]:
    width = max(bounds[2] - bounds[0], 1.0)
    height = max(bounds[3] - bounds[1], 1.0)
    aspect = width / height
    if aspect >= 1:
        display_width = 1100
        display_height = max(260, min(900, round(display_width / aspect)))
    else:
        display_height = 900
        display_width = max(360, min(1100, round(display_height * aspect)))
    return display_width, display_height


def render_layout_svg(
    layout: Mapping[str, Any],
    *,
    mode: str = "zoom",
    title: str | None = None,
) -> str:
    """Render a full-fabric or occupied-region map.

    Coordinates use the CSL convention directly: increasing ``y`` is drawn
    downward, so a compiled NORTH route points toward decreasing ``y``.
    """

    if mode not in {"zoom", "fabric"}:
        raise ValueError("mode must be 'zoom' or 'fabric'")
    bounds = _coordinate_bounds(layout, mode)
    x0, y0, x1, y1 = bounds
    content_width, content_height = x1 - x0, y1 - y0
    margin = max(content_width, content_height) * 0.055 + 0.8
    legend_height = max(1.5, content_height * 0.08)
    view_x = x0 - margin
    view_y = y0 - margin - legend_height
    view_width = content_width + 2 * margin
    view_height = content_height + 2 * margin + legend_height
    display_width, display_height = _display_size(bounds)
    units_per_pixel = max(content_width / display_width, content_height / display_height)
    label = title or f"{_kernel_name(layout)} — {'full fabric' if mode == 'fabric' else 'layout zoom'}"
    escaped_label = html.escape(label)

    elements: list[str] = [
        '<?xml version="1.0" encoding="UTF-8"?>',
        (
            f'<svg xmlns="http://www.w3.org/2000/svg" width="{display_width}" '
            f'height="{display_height}" viewBox="{view_x:.4f} {view_y:.4f} '
            f'{view_width:.4f} {view_height:.4f}" role="img" '
            f'aria-label="{escaped_label}">'
        ),
        "<defs>",
        (
            '<marker id="route-arrow" markerWidth="4" markerHeight="4" '
            'refX="3.5" refY="2" orient="auto" markerUnits="strokeWidth">'
            '<path d="M0,0 L4,2 L0,4 z" fill="context-stroke"/></marker>'
        ),
        "</defs>",
        f"<title>{escaped_label}</title>",
        (
            f'<rect x="{x0:.4f}" y="{y0:.4f}" width="{content_width:.4f}" '
            f'height="{content_height:.4f}" fill="#f8fafc" stroke="#334155" '
            f'stroke-width="{max(min(content_width, content_height) * 0.006, 0.025):.4f}"/>'
        ),
    ]

    # Grid lines are useful on application-sized maps but pathological on a
    # 762x1172 full-wafer view.  Keep the full view lightweight and scalable.
    if content_width <= 64 and content_height <= 64:
        grid_width = max(min(content_width, content_height) * 0.0025, 0.012)
        for x in range(int(x0) + 1, int(x1)):
            elements.append(
                f'<line x1="{x}" y1="{y0}" x2="{x}" y2="{y1}" stroke="#e2e8f0" stroke-width="{grid_width:.4f}"/>'
            )
        for y in range(int(y0) + 1, int(y1)):
            elements.append(
                f'<line x1="{x0}" y1="{y}" x2="{x1}" y2="{y}" stroke="#e2e8f0" stroke-width="{grid_width:.4f}"/>'
            )

    route_width = max(units_per_pixel * 0.72, 0.035)
    route_inset = 0.28
    for edge in sorted(
        layout.get("route_edges") or [],
        key=lambda item: (
            item.get("from", {}).get("y", 0),
            item.get("from", {}).get("x", 0),
            item.get("color", 0),
            item.get("direction", ""),
        ),
    ):
        if edge.get("direction") == "ramp":
            continue
        source, target = edge.get("from") or {}, edge.get("to") or {}
        try:
            sx, sy = float(source["x"]) + 0.5, float(source["y"]) + 0.5
            tx, ty = float(target["x"]) + 0.5, float(target["y"]) + 0.5
        except (KeyError, TypeError, ValueError):
            continue
        dx, dy = tx - sx, ty - sy
        length = max((dx * dx + dy * dy) ** 0.5, 1.0)
        sx += dx / length * route_inset
        sy += dy / length * route_inset
        tx -= dx / length * route_inset
        ty -= dy / length * route_inset
        color = _EDGE_COLORS.get(str(edge.get("traffic_class")), "#475569")
        opacity = "0.88" if edge.get("destination_validation") != "unobserved" else "0.55"
        elements.append(
            f'<line x1="{sx:.4f}" y1="{sy:.4f}" x2="{tx:.4f}" y2="{ty:.4f}" '
            f'stroke="{color}" stroke-width="{route_width:.4f}" opacity="{opacity}" '
            f'marker-end="url(#route-arrow)"><title>color {html.escape(str(edge.get("color")))} '
            f'{html.escape(str(edge.get("direction")))}, {html.escape(str(edge.get("traffic_class")))}</title></line>'
        )

    # Full-wafer cells are subpixel at 762x1172.  Enlarge their glyphs just
    # enough to remain visible while retaining their exact coordinate centers;
    # the zoom map keeps the true tile-sized glyph.
    pe_size = max(0.72, units_per_pixel * 2.6 if mode == "fabric" else 0.72)
    pe_inset = (1.0 - pe_size) / 2.0
    label_pes = len(layout.get("pes") or []) <= 64 and content_width <= 32 and content_height <= 32
    for pe in sorted(
        layout.get("pes") or [],
        key=lambda item: (
            item.get("fabric", {}).get("y", 0),
            item.get("fabric", {}).get("x", 0),
            item.get("role", ""),
        ),
    ):
        coordinate = pe.get("fabric") or {}
        try:
            x, y = float(coordinate["x"]), float(coordinate["y"])
        except (KeyError, TypeError, ValueError):
            continue
        role = str(pe.get("role") or "unknown")
        color = _PE_COLORS.get(role, "#64748b")
        opacity = "1" if pe.get("evidence") == "compiled" else "0.48"
        artifact = html.escape(str(pe.get("artifact") or "no artifact"))
        program = html.escape(str(pe.get("program") or "unknown program"))
        elements.append(
            f'<rect x="{x + pe_inset:.4f}" y="{y + pe_inset:.4f}" '
            f'width="{pe_size:.4f}" height="{pe_size:.4f}" rx="0.08" '
            f'fill="{color}" opacity="{opacity}" stroke="#0f172a" stroke-width="0.025">'
            f'<title>fabric ({int(x)},{int(y)}), {html.escape(role)}, {program}; {artifact}</title></rect>'
        )
        if label_pes:
            font_size = 0.17
            elements.append(
                f'<text x="{x + 0.5:.4f}" y="{y + 0.56:.4f}" text-anchor="middle" '
                f'font-family="monospace" font-size="{font_size}" fill="white">'
                f'{int(x)},{int(y)}</text>'
            )

    # Trace-derived link volume/latency and PE hotspots are intentionally a
    # separate overlay.  They are never synthesized from the static route
    # table, and their provenance is included in each SVG tooltip.
    overlay = layout.get("flow_overlay") or {}
    overlay_links = overlay.get("links") if isinstance(overlay, Mapping) else []
    overlay_pes = overlay.get("pes") if isinstance(overlay, Mapping) else []
    timing_scope_record = overlay.get("timing_scope") if isinstance(overlay, Mapping) else None
    timing_scope = _value(timing_scope_record) or "unspecified trace window"
    max_volume = max(
        (int(item.get("observations", 0)) for item in (overlay_links or [])),
        default=0,
    )
    for link in overlay_links or []:
        source, target = link.get("from") or {}, link.get("to") or {}
        try:
            sx, sy = float(source["x"]) + 0.5, float(source["y"]) + 0.5
            tx, ty = float(target["x"]) + 0.5, float(target["y"]) + 0.5
            volume = int(link.get("observations", 0))
        except (KeyError, TypeError, ValueError):
            continue
        width_scale = 1.0 + (math.log1p(volume) / math.log1p(max_volume) if max_volume else 0.0) * 3.0
        delay = link.get("median_delay_cycles")
        pressure = int(link.get("nonzero_backpressure_samples", 0) or 0)
        evidence = html.escape(str(link.get("evidence") or "inferred"))
        source_label = html.escape(str(link.get("source") or "trace-derived overlay"))
        elements.append(
            f'<line x1="{sx:.4f}" y1="{sy:.4f}" x2="{tx:.4f}" y2="{ty:.4f}" '
            f'stroke="#dc2626" stroke-width="{route_width * width_scale:.4f}" opacity="0.72" '
            f'marker-end="url(#route-arrow)"><title>observed-path volume {volume}; '
            f'median delta {html.escape(str(delay))} cycles; nonzero backpressure samples {pressure}; '
            f'evidence {evidence}; {source_label}</title></line>'
        )

    max_activity = max(
        (int(item.get("event_observations", 0)) for item in (overlay_pes or [])),
        default=0,
    )
    for hotspot in overlay_pes or []:
        coordinate = hotspot.get("fabric") or {}
        try:
            x, y = float(coordinate["x"]) + 0.5, float(coordinate["y"]) + 0.5
            activity = int(hotspot.get("event_observations", 0))
        except (KeyError, TypeError, ValueError):
            continue
        fraction = activity / max_activity if max_activity else 0.0
        radius = max(pe_size * (0.58 + 0.55 * fraction), units_per_pixel * 1.3)
        elements.append(
            f'<circle cx="{x:.4f}" cy="{y:.4f}" r="{radius:.4f}" fill="none" '
            f'stroke="#dc2626" stroke-width="{max(route_width * 0.7, 0.035):.4f}" '
            f'opacity="{0.30 + 0.55 * fraction:.3f}"><title>trace hotspot: {activity} event '
            f'observations; scope {html.escape(str(timing_scope))}; evidence '
            f'{html.escape(str(hotspot.get("evidence") or "simulator"))}</title></circle>'
        )

    font_size = max(min(content_width, content_height) * 0.035, 0.23)
    title_y = y0 - margin * 0.5
    elements.append(
        f'<text x="{x0:.4f}" y="{title_y:.4f}" font-family="sans-serif" '
        f'font-size="{font_size:.4f}" font-weight="600" fill="#0f172a">{escaped_label}</text>'
    )
    qualification = layout.get("acceptance_qualification") or {}
    qualification_status = (
        str(qualification.get("status"))
        if isinstance(qualification, Mapping)
        else "unqualified"
    )
    qualification_reasons = (
        "; ".join(str(reason) for reason in qualification.get("reasons") or [])
        if isinstance(qualification, Mapping)
        else "no campaign qualification record"
    )
    elements.append(
        f'<text x="{x0:.4f}" y="{title_y + font_size * 0.72:.4f}" '
        f'font-family="sans-serif" font-size="{font_size * 0.48:.4f}" '
        f'fill="{"#166534" if qualification_status == "qualified" else "#991b1b"}">'
        f'campaign evidence: {html.escape(qualification_status)}'
        f'<title>{html.escape(qualification_reasons or "all acceptance predicates passed")}</title></text>'
    )
    legend_y = y1 + margin * 0.48
    legend_x = x0
    unit = max(content_width / 5.5, 1.1)
    legend_items = (
        ("application PE", _PE_COLORS["application"]),
        ("memcpy I/O", _PE_COLORS["io-west"]),
        ("route-only", _PE_COLORS["routing-only"]),
        ("application route", _EDGE_COLORS["application"]),
        ("system route", _EDGE_COLORS["system"]),
    )
    for index, (legend_label, color) in enumerate(legend_items):
        lx = legend_x + index * unit
        elements.append(
            f'<rect x="{lx:.4f}" y="{legend_y - font_size * 0.65:.4f}" '
            f'width="{font_size * 0.55:.4f}" height="{font_size * 0.55:.4f}" fill="{color}"/>'
        )
        elements.append(
            f'<text x="{lx + font_size * 0.72:.4f}" y="{legend_y - font_size * 0.13:.4f}" '
            f'font-family="sans-serif" font-size="{font_size * 0.52:.4f}" fill="#334155">'
            f'{html.escape(legend_label)}</text>'
        )

    if overlay_links or overlay_pes:
        elements.append(
            f'<text x="{x0:.4f}" y="{legend_y + font_size * 0.72:.4f}" '
            f'font-family="sans-serif" font-size="{font_size * 0.50:.4f}" fill="#991b1b">'
            'red overlay = trace observations/path inference; see tooltips for evidence</text>'
        )
    else:
        elements.append(
            f'<text x="{x0:.4f}" y="{legend_y + font_size * 0.72:.4f}" '
            f'font-family="sans-serif" font-size="{font_size * 0.50:.4f}" fill="#64748b">'
            'no trace-derived volume, latency, or hotspot overlay available</text>'
        )

    elements.append("</svg>")
    return "\n".join(elements) + "\n"


def render_full_fabric_svg(layout: Mapping[str, Any], *, title: str | None = None) -> str:
    return render_layout_svg(layout, mode="fabric", title=title)


def render_zoom_svg(layout: Mapping[str, Any], *, title: str | None = None) -> str:
    return render_layout_svg(layout, mode="zoom", title=title)


def write_layout_svgs(
    layout: Mapping[str, Any], output_dir: str | Path
) -> dict[str, str]:
    """Write deterministic full-fabric and zoom SVGs for one layout."""

    directory = Path(output_dir)
    directory.mkdir(parents=True, exist_ok=True)
    # These names are part of the study's documented output contract.
    full_path = directory / "wafer.svg"
    zoom_path = directory / "layout.svg"
    full_path.write_text(render_full_fabric_svg(layout), encoding="utf-8")
    zoom_path.write_text(render_zoom_svg(layout), encoding="utf-8")
    return {"svg_full_fabric": str(full_path), "svg_zoom": str(zoom_path)}


__all__ = [
    "render_full_fabric_svg",
    "render_layout_svg",
    "render_zoom_svg",
    "write_layout_svgs",
]
