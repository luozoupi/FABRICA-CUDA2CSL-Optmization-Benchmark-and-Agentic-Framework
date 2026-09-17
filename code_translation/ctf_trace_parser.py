#!/usr/bin/env python3
"""CTF trace parser for Cerebras simfab_traces.

Parses the barectf v3.0.1 CTF binary stream (simfab_traces/stream0) into
structured per-PE profiling data: instruction dispatch timelines, back-pressure
maps, wavelet flow latency. Produces a bottleneck report that tells the
optimizer WHERE cycles are spent and WHY.

No babeltrace2 dependency — uses struct.unpack directly on the known binary layout.

Gate: XKERNEL_TRACE_PROFILE=1 (default off — adds ~1-2s overhead).
"""

from __future__ import annotations

import struct
from collections import defaultdict
from pathlib import Path
from typing import Dict, Iterator, List, Optional, Tuple

CTF_MAGIC = 0xC1FC1FC1

EVENT_NAMES = {
    0: "backpressure",
    1: "debug_counters_wavelet",
    2: "dispatch",
    3: "pipe",
    4: "switch_pos",
    5: "wavelet_entry",
    6: "wavelet_trace",
}


def _align(offset: int, align_bits: int, pkt_start: int) -> int:
    align_bytes = max(1, align_bits // 8)
    remainder = (offset - pkt_start) % align_bytes
    if remainder:
        return offset + (align_bytes - remainder)
    return offset


class CtfTraceReader:
    """Parse barectf CTF binary stream into typed event dicts."""

    def __init__(self, stream0_path: str):
        self.data = Path(stream0_path).read_bytes()

    def iter_events(self) -> Iterator[Dict]:
        data = self.data
        size = len(data)
        offset = 0

        while offset + 52 < size:
            pkt_start = offset
            magic = struct.unpack_from("<I", data, offset)[0]
            if magic != CTF_MAGIC:
                break
            _, pkt_size_bits, cont_size_bits = struct.unpack_from("<Q Q", data, offset + 4)[:2], \
                struct.unpack_from("<Q", data, offset + 12)[0], \
                struct.unpack_from("<Q", data, offset + 20)[0]

            # Re-parse cleanly
            magic, stream_id = struct.unpack_from("<IQ", data, offset)
            pkt_size_bits, cont_size_bits, ts_begin, ts_end, evts_disc = \
                struct.unpack_from("<5Q", data, offset + 12)

            pkt_bytes = pkt_size_bits // 8
            content_end = pkt_start + cont_size_bits // 8

            eoff = pkt_start + 52
            while eoff + 16 <= content_end:
                evt_id, evt_ts = struct.unpack_from("<QQ", data, eoff)
                eoff += 16

                evt, consumed = self._parse_payload(int(evt_id), data, eoff, pkt_start)
                if evt is not None:
                    evt["_type"] = EVENT_NAMES.get(int(evt_id), f"unknown_{evt_id}")
                    evt["_id"] = int(evt_id)
                    evt["_timestamp"] = int(evt_ts)
                    yield evt
                eoff += consumed
                break  # one event per packet

            offset += pkt_bytes

    def _parse_payload(self, evt_id: int, data: bytes, offset: int, pkt_start: int) -> Tuple[Optional[Dict], int]:
        start = offset

        if evt_id == 0:  # backpressure_trace_entry
            off = _align(offset, 64, pkt_start)
            cycle = struct.unpack_from("<Q", data, off)[0]; off += 8
            tile = struct.unpack_from("<I", data, off)[0]; off += 4
            bp = struct.unpack_from("<I", data, off)[0]; off += 4
            link = data[off]; off += 1
            return {"cycle": cycle, "tile": tile, "back_pressure": bp, "link": link}, off - start

        if evt_id == 1:  # debug_counters_wavelet
            off = _align(offset, 32, pkt_start)
            px = struct.unpack_from("<I", data, off)[0]; off += 4
            py = struct.unpack_from("<I", data, off)[0]; off += 4
            color = struct.unpack_from("<I", data, off)[0]; off += 4
            off = _align(off, 64, pkt_start)
            cw = struct.unpack_from("<Q", data, off)[0]; off += 8
            ct = struct.unpack_from("<Q", data, off)[0]; off += 8
            cs = struct.unpack_from("<Q", data, off)[0]; off += 8
            return {"PE_x": px, "PE_y": py, "color": color, "count_w": cw, "count_t": ct, "count_s": cs}, off - start

        if evt_id == 2:  # hwm_dispatch_trace_entry
            off = _align(offset, 64, pkt_start)
            cycle = struct.unpack_from("<Q", data, off)[0]; off += 8
            tile = struct.unpack_from("<I", data, off)[0]; off += 4
            uid = struct.unpack_from("<I", data, off)[0]; off += 4
            inst = struct.unpack_from("<I", data, off)[0]; off += 4
            ndata = struct.unpack_from("<I", data, off)[0]; off += 4
            ctx = struct.unpack_from("<I", data, off)[0]; off += 4
            iptr = struct.unpack_from("<H", data, off)[0]; off += 2
            tc = data[off]; off += 1
            utid = data[off]; off += 1
            term = struct.unpack_from("<b", data, off)[0]; off += 1
            # null-terminated string
            end = data.index(0, off)
            name = data[off:end].decode("utf-8", errors="replace")
            off = end + 1
            return {"cycle": cycle, "tile": tile, "uid": uid, "inst_bin": inst,
                    "name": name, "task_color": tc, "ut_id": utid, "inst_ptr": iptr}, off - start

        if evt_id == 3:  # hwm_pipe_trace_entry
            off = _align(offset, 64, pkt_start)
            cycle = struct.unpack_from("<Q", data, off)[0]; off += 8
            tile = struct.unpack_from("<I", data, off)[0]; off += 4
            uid = struct.unpack_from("<I", data, off)[0]; off += 4
            d, dest, s0, s1, s2 = struct.unpack_from("<5I", data, off); off += 20
            stage, imm, cflag, xcptn, simdi = struct.unpack_from("<5B", data, off); off += 5
            return {"cycle": cycle, "tile": tile, "uid": uid, "data": d,
                    "dest": dest, "src0": s0, "src1": s1, "src2": s2, "stage": stage}, off - start

        if evt_id == 4:  # switch_pos_trace_entry
            off = _align(offset, 64, pkt_start)
            cycle = struct.unpack_from("<Q", data, off)[0]; off += 8
            tile = struct.unpack_from("<I", data, off)[0]; off += 4
            color, inp, imask, outp, omask = struct.unpack_from("<5B", data, off); off += 5
            return {"cycle": cycle, "tile": tile, "color": color}, off - start

        if evt_id == 5:  # wavelet_entry
            off = _align(offset, 16, pkt_start)
            px, py, color = struct.unpack_from("<3H", data, off); off += 6
            ctrl, half = struct.unpack_from("<2b", data, off); off += 2
            off = _align(off, 64, pkt_start)
            ts = struct.unpack_from("<Q", data, off)[0]; off += 8
            wcnt, widx, wdata, etype = struct.unpack_from("<4H", data, off); off += 8
            return {"PE_x": px, "PE_y": py, "color": color, "timestamp": ts,
                    "event_type": etype}, off - start

        if evt_id == 6:  # wavelet_trace_entry
            off = _align(offset, 64, pkt_start)
            cycle = struct.unpack_from("<Q", data, off)[0]; off += 8
            ident = struct.unpack_from("<Q", data, off)[0]; off += 8
            tile = struct.unpack_from("<I", data, off)[0]; off += 4
            idx, wdata = struct.unpack_from("<2H", data, off); off += 4
            fields = struct.unpack_from("<I", data, off)[0]; off += 4
            return {"cycle": cycle, "ident": ident, "tile": tile, "index": idx,
                    "data": wdata, "fields": fields}, off - start

        return None, 0


# ---------------------------------------------------------------------------
# Profiling Aggregators
# ---------------------------------------------------------------------------

def compute_pe_utilization(events: List[Dict], total_cycles: int = 0) -> Dict[int, Dict]:
    """From dispatch events, compute per-PE utilization."""
    pe_dispatches: Dict[int, int] = defaultdict(int)
    pe_last_cycle: Dict[int, int] = defaultdict(int)
    pe_first_cycle: Dict[int, int] = {}
    pe_opcodes: Dict[int, Dict[str, int]] = defaultdict(lambda: defaultdict(int))

    for evt in events:
        if evt.get("_id") != 2:
            continue
        tile = evt["tile"]
        cycle = evt["cycle"]
        pe_dispatches[tile] += 1
        pe_last_cycle[tile] = max(pe_last_cycle[tile], cycle)
        if tile not in pe_first_cycle:
            pe_first_cycle[tile] = cycle
        name = evt.get("name", "")
        if name:
            pe_opcodes[tile][name] += 1

    result = {}
    for tile in pe_dispatches:
        span = pe_last_cycle[tile] - pe_first_cycle.get(tile, 0) + 1
        dispatches = pe_dispatches[tile]
        utilization = min(1.0, dispatches / max(span, 1))
        dominant = max(pe_opcodes[tile].items(), key=lambda x: x[1])[0] if pe_opcodes[tile] else ""
        result[tile] = {
            "dispatches": dispatches,
            "span_cycles": span,
            "utilization": round(utilization, 4),
            "dominant_op": dominant,
        }
    return result


def compute_backpressure_map(events: List[Dict]) -> Dict[Tuple[int, int], float]:
    """From backpressure events, compute per-(tile, color) congestion count."""
    bp_counts: Dict[Tuple[int, int], int] = defaultdict(int)
    bp_total: Dict[Tuple[int, int], int] = defaultdict(int)

    for evt in events:
        if evt.get("_id") != 0:
            continue
        key = (evt["tile"], evt.get("link", 0))
        bp_total[key] += 1
        if evt["back_pressure"] > 0:
            bp_counts[key] += 1

    return {k: round(bp_counts[k] / max(bp_total[k], 1), 4) for k in bp_total}


def compute_wavelet_summary(events: List[Dict]) -> Dict:
    """From wavelet events, compute traffic summary."""
    total_wavelets = 0
    pe_wavelets: Dict[Tuple[int, int], int] = defaultdict(int)

    for evt in events:
        if evt.get("_id") == 5:
            total_wavelets += 1
            pe_wavelets[(evt["PE_x"], evt["PE_y"])] += 1
        elif evt.get("_id") == 1:
            total_wavelets += evt.get("count_w", 0)

    return {
        "total_wavelets": total_wavelets,
        "pe_wavelet_counts": dict(pe_wavelets),
    }


def build_trace_report(stream0_path: str) -> Optional[Dict]:
    """Parse a CTF stream0 file and produce a structured profiling report."""
    try:
        reader = CtfTraceReader(stream0_path)
    except Exception:
        return None

    events = list(reader.iter_events())
    if not events:
        return None

    event_counts: Dict[str, int] = defaultdict(int)
    for evt in events:
        event_counts[evt["_type"]] += 1

    utilization = compute_pe_utilization(events)
    backpressure = compute_backpressure_map(events)
    wavelet_summary = compute_wavelet_summary(events)

    # Overall utilization stats
    utils = [v["utilization"] for v in utilization.values()] if utilization else [0]
    min_util_tile = min(utilization.items(), key=lambda x: x[1]["utilization"])[0] if utilization else -1
    max_util_tile = max(utilization.items(), key=lambda x: x[1]["utilization"])[0] if utilization else -1

    # Congested colors
    congested = {k: v for k, v in backpressure.items() if v > 0.1}

    # Bottleneck classification from traces
    mean_util = sum(utils) / len(utils) if utils else 0
    has_bp = len(congested) > 0
    if has_bp and mean_util < 0.5:
        bottleneck = "fabric-bound"
        reason = f"{len(congested)} tile-link pairs congested (>10% back-pressure)"
    elif mean_util < 0.3:
        bottleneck = "stall-bound"
        reason = f"mean utilization {mean_util:.0%} — PEs mostly idle"
    else:
        bottleneck = "compute-bound"
        reason = f"mean utilization {mean_util:.0%}"

    return {
        "event_counts": dict(event_counts),
        "total_events": len(events),
        "pe_utilization": {str(k): v for k, v in utilization.items()},
        "util_stats": {
            "min": round(min(utils), 4),
            "max": round(max(utils), 4),
            "mean": round(mean_util, 4),
            "min_tile": min_util_tile,
            "max_tile": max_util_tile,
        },
        "backpressure": {str(k): v for k, v in backpressure.items()},
        "congested_count": len(congested),
        "wavelet_summary": wavelet_summary,
        "bottleneck": bottleneck,
        "bottleneck_reason": reason,
    }


def format_trace_profile(report: Dict, max_chars: int = 1500) -> str:
    """Format a trace report into a prompt block for the optimizer."""
    if not report:
        return ""

    us = report.get("util_stats", {})
    lines = [
        "TRACE PROFILE (per-PE instruction analysis):",
        f"  Events parsed: {report.get('total_events', 0)} "
        f"({', '.join(f'{k}={v}' for k, v in report.get('event_counts', {}).items())})",
        f"  PE utilization: min={us.get('min', 0):.0%} (tile {us.get('min_tile', '?')}) "
        f"max={us.get('max', 0):.0%} (tile {us.get('max_tile', '?')}) "
        f"mean={us.get('mean', 0):.0%}",
    ]

    if report.get("congested_count", 0) > 0:
        lines.append(f"  Back-pressure: {report['congested_count']} tile-link pairs congested (>10%)")
    else:
        lines.append("  Back-pressure: none detected")

    lines.append(f"  Bottleneck: {report.get('bottleneck', '?')} — {report.get('bottleneck_reason', '')}")

    advice = {
        "compute-bound": "Focus on compute-loop optimization (fmac_bulk, DSD chaining).",
        "fabric-bound": "Overlap communication with compute (async), reduce wavelet volume.",
        "stall-bound": "Fix wavelet ordering or deadlock; PEs are idle waiting on data.",
    }
    lines.append(f"  → {advice.get(report.get('bottleneck', ''), 'Inspect traces.')}")

    text = "\n".join(lines)
    return text[:max_chars] if len(text) > max_chars else text


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    import json
    import sys

    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <simfab_traces_dir_or_stream0>")
        sys.exit(1)

    path = sys.argv[1]
    if Path(path).is_dir():
        path = str(Path(path) / "stream0")

    report = build_trace_report(path)
    if report:
        print(json.dumps(report, indent=2, default=str))
        print()
        print(format_trace_profile(report))
    else:
        print("Failed to parse trace")
