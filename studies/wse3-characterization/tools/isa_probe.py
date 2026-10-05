#!/usr/bin/env python3
"""Instruction-level (ISA) profiler for decoded WSE simulator traces.

Consumes a decoded ``events.jsonl.gz`` and reports what the PE actually
executed: instruction mix, elements per dispatched instruction, microthread
occupancy, task/colour dispatch, and instruction-pointer hot spots.

Evidence class: `simulator`. These are decoded SDK pipeline/dispatch trace
records, not silicon measurements.

NOTE on SIMD width: ``simdi`` on the pipeline trace IS a lane index, but it only
says so when the code actually issues SIMD instructions.  Scalar kernels show
only {0, 255} (255 being the not-applicable sentinel), which reads as a dead
field -- an earlier version of this tool concluded exactly that and was wrong.
WaferLLM's vectorised MeshGEMV shows lanes 0..7, matching the documented SIMD-8.
So: report the observed lane range when lanes appear, and say "no SIMD issued"
when they do not.  ``num_data`` on the dispatch record remains the independent
measure -- elements covered by one dispatched instruction.
"""
from __future__ import annotations

import argparse, collections, gzip, json, sys
from pathlib import Path

MAIN_THREAD_UT_ID = 255      # observed sentinel for "not a microthread"
NUM_DATA_SENTINELS = {0xFFFFFFFF, 0xFFFF}   # "not applicable" on the dispatch record
SIMDI_SENTINEL = 255

# S-suffixed float ops are the DSD/vector-capable family in the WSE ISA.
VECTOR_CAPABLE_SUFFIX = "S"


def _simdi_verdict(simdi: collections.Counter) -> dict:
    """Interpret the pipeline trace's SIMD lane index.

    Lanes only appear if the code issued SIMD instructions; a purely scalar
    kernel shows {0, 255} and tells you nothing about the machine's width.
    """
    lanes = sorted(k for k in simdi if isinstance(k, int) and k != SIMDI_SENTINEL)
    hist = {str(k): v for k, v in sorted(simdi.items(), key=lambda x: str(x[0]))}
    if len(lanes) <= 1:
        return {"histogram": hist, "lanes_observed": lanes, "simd_issued": False,
                "observed_width": None,
                "note": ("only lane %s plus the %d sentinel: this code issued no SIMD "
                         "instructions, so the field says nothing about machine width."
                         % (lanes or "-", SIMDI_SENTINEL))}
    return {"histogram": hist, "lanes_observed": lanes, "simd_issued": True,
            "observed_width": max(lanes) + 1,
            "note": ("lanes %d..%d observed -> SIMD width at least %d, exercised by this code."
                     % (lanes[0], lanes[-1], max(lanes) + 1))}


def load(path: Path, limit: int | None = None):
    opener = gzip.open if str(path).endswith(".gz") else open
    with opener(path, "rt") as fh:
        for i, line in enumerate(fh):
            if limit and i >= limit:
                break
            line = line.strip()
            if line:
                yield json.loads(line)


def profile(path: Path, limit: int | None = None) -> dict:
    inst = collections.Counter()
    elems_by_inst = collections.defaultdict(collections.Counter)
    ut = collections.Counter()
    ut_by_inst = collections.defaultdict(collections.Counter)
    color = collections.Counter()
    iptr = collections.Counter()
    simdi = collections.Counter()
    encoding = {}
    per_tile = collections.Counter()
    cycles = []
    n_disp = n_pipe = n_wav = 0

    for e in load(path, limit):
        t = e.get("event_type")
        if t == "hwm_dispatch_trace_entry":
            n_disp += 1
            name = e.get("name") or "?"
            nd = e.get("num_data")
            u = e.get("ut_id")
            inst[name] += 1
            elems_by_inst[name][nd] += 1
            ut[u] += 1
            ut_by_inst[name][u] += 1
            color[e.get("task_color")] += 1
            if e.get("inst_ptr") is not None:
                iptr[e["inst_ptr"]] += 1
            encoding.setdefault(name, e.get("inst_bin"))
            per_tile[e.get("tile_index")] += 1
            if e.get("cycle") is not None:
                cycles.append(e["cycle"])
        elif t == "hwm_pipe_trace_entry":
            n_pipe += 1
            if e.get("simdi") is not None:
                simdi[e["simdi"]] += 1
        elif t == "wavelet_trace_entry":
            n_wav += 1

    def real(nd):
        return isinstance(nd, int) and nd not in NUM_DATA_SENTINELS

    total = sum(inst.values()) or 1
    elements = sum(nd * c for name in elems_by_inst
                   for nd, c in elems_by_inst[name].items() if real(nd))
    counted = sum(c for name in elems_by_inst
                  for nd, c in elems_by_inst[name].items() if real(nd))
    multi = {}
    for n, d in elems_by_inst.items():
        vals = sorted(k for k in d if real(k) and k > 1)
        if not vals:
            continue
        multi[n] = {"min": vals[0], "max": vals[-1],
                    "distinct": len(vals),
                    "dispatches": sum(d[k] for k in vals),
                    "elements": sum(k * d[k] for k in vals)}
    micro = {n: dict(sorted((k, v) for k, v in d.items() if k != MAIN_THREAD_UT_ID))
             for n, d in ut_by_inst.items()
             if any(k != MAIN_THREAD_UT_ID for k in d)}

    return {
        "schema": "isa_probe/1",
        "evidence": "simulator",
        "source": str(path),
        "counts": {"dispatch": n_disp, "pipe": n_pipe, "wavelet": n_wav},
        "cycle_span": [min(cycles), max(cycles)] if cycles else None,
        "distinct_instructions": len(inst),
        "instruction_mix": [
            {"name": n, "count": c, "pct": round(100 * c / total, 3),
             "inst_bin": encoding.get(n)}
            for n, c in inst.most_common()
        ],
        "elements_per_dispatch": {
            "total_elements": elements,
            "dispatches_with_real_num_data": counted,
            "mean_elements_per_dispatch": round(elements / max(counted, 1), 4),
            "num_data_sentinels_excluded": sorted(NUM_DATA_SENTINELS),
            "instructions_covering_multiple_elements": multi,
        },
        "microthreads": {
            "histogram": {str(k): v for k, v in sorted(ut.items(), key=lambda x: str(x[0]))},
            "main_thread_id": MAIN_THREAD_UT_ID,
            "distinct_microthread_ids": sorted(
                k for k in ut if k != MAIN_THREAD_UT_ID and k is not None),
            "instructions_issued_on_microthreads": micro,
        },
        "task_colors": {str(k): v for k, v in sorted(color.items(), key=lambda x: str(x[0]))},
        "simdi_field": _simdi_verdict(simdi),
        "hot_instruction_pointers": [
            {"inst_ptr": p, "dispatches": c} for p, c in iptr.most_common(15)
        ],
        "tiles": {str(k): v for k, v in per_tile.most_common(10)},
    }


def render(doc: dict, top: int = 20) -> str:
    L = []
    c = doc["counts"]
    L.append(f"source: {doc['source']}")
    L.append(f"events: dispatch={c['dispatch']}  pipe={c['pipe']}  wavelet={c['wavelet']}"
             f"   distinct instructions: {doc['distinct_instructions']}")
    if doc["cycle_span"]:
        lo, hi = doc["cycle_span"]
        L.append(f"cycle span: {lo}..{hi}  ({hi - lo} cycles)")
    L.append("")
    L.append(f"{'instruction':<14}{'count':>9}{'pct':>8}   encoding")
    for row in doc["instruction_mix"][:top]:
        b = row["inst_bin"]
        L.append(f"  {row['name']:<12}{row['count']:>9}{row['pct']:>7.2f}%   "
                 f"{('0x%08x' % b) if isinstance(b, int) else ''}")
    e = doc["elements_per_dispatch"]
    L.append("")
    L.append(f"elements/dispatch: mean={e['mean_elements_per_dispatch']} "
             f"({e['total_elements']} elements / {e['dispatches_with_real_num_data']} dispatches)")
    if e["instructions_covering_multiple_elements"]:
        L.append("  instructions covering >1 element per dispatch:")
        for n, d in sorted(e["instructions_covering_multiple_elements"].items()):
            L.append(f"    {n:<12} num_data {d['min']}..{d['max']}  "
                     f"({d['dispatches']} dispatches, {d['elements']} elements)")
    else:
        L.append("  (none — every dispatch covered exactly one element)")
    m = doc["microthreads"]
    L.append("")
    L.append(f"microthreads: ids in use {m['distinct_microthread_ids']} "
             f"(255 = main thread)")
    L.append(f"  histogram {m['histogram']}")
    L.append("")
    L.append(f"task colors: {doc['task_colors']}")
    sf = doc["simdi_field"]
    L.append(f"simdi lanes: {sf['lanes_observed']}  simd_issued={sf['simd_issued']}"
             + (f"  observed width={sf['observed_width']}" if sf["observed_width"] else ""))
    L.append(f"  {sf['note']}")
    return "\n".join(L)


def listing(path: Path, limit: int | None = None) -> str:
    """Address-ordered execution listing reconstructed from the dispatch trace.

    The public SDK ships no Cerebras-target disassembler binary (elf2lst exists and
    the Cerebras disassembler/InstPrinter libraries are present, but the bundled
    llvm-objdump registers only x86 targets). The dispatch trace is the available
    substitute: it names every instruction the core actually issued, with its 32-bit
    encoding, its instruction pointer, the owning task colour and microthread, and
    the number of elements it covered.

    This is a dynamic listing: only executed addresses appear, and each carries its
    execution count -- which a static disassembly would not give you.
    """
    by_ptr: dict[int, dict] = {}
    for e in load(path, limit):
        if e.get("event_type") != "hwm_dispatch_trace_entry":
            continue
        ptr = e.get("inst_ptr")
        if ptr is None:
            continue
        row = by_ptr.setdefault(ptr, {"name": e.get("name"), "bin": e.get("inst_bin"),
                                      "n": 0, "colors": set(), "ut": set(), "nd": set()})
        row["n"] += 1
        row["colors"].add(e.get("task_color"))
        row["ut"].add(e.get("ut_id"))
        nd = e.get("num_data")
        if isinstance(nd, int) and nd not in NUM_DATA_SENTINELS:
            row["nd"].add(nd)
    out = [f"{'addr':>8}  {'encoding':<12}{'mnemonic':<13}{'exec':>9}  {'elems':<10}{'ut':<10}colors",
           "-" * 88]
    for ptr in sorted(by_ptr):
        r = by_ptr[ptr]
        b = r["bin"]
        enc = f"0x{b:08x}" if isinstance(b, int) else ""
        nd = sorted(r["nd"])
        nds = "-" if not nd else (str(nd[0]) if len(nd) == 1 else f"{nd[0]}..{nd[-1]}")
        ut = sorted(x for x in r["ut"] if x is not None)
        uts = "main" if ut == [MAIN_THREAD_UT_ID] else ",".join(
            "main" if u == MAIN_THREAD_UT_ID else str(u) for u in ut)
        cols = ",".join(str(c) for c in sorted(x for x in r["colors"] if x is not None))
        out.append(f"{ptr:>8}  {enc:<12}{r['name'] or '?':<13}{r['n']:>9}  "
                   f"{nds:<10}{uts:<10}{cols}")
    return "\n".join(out)


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("events", help="decoded events.jsonl.gz")
    ap.add_argument("--json", help="write JSON here")
    ap.add_argument("--limit", type=int, default=None)
    ap.add_argument("--top", type=int, default=20)
    ap.add_argument("--listing", action="store_true",
                    help="emit an address-ordered execution listing instead of the summary")
    a = ap.parse_args()
    if a.listing:
        print(listing(Path(a.events), a.limit))
        return 0
    doc = profile(Path(a.events), a.limit)
    if a.json:
        Path(a.json).parent.mkdir(parents=True, exist_ok=True)
        Path(a.json).write_text(json.dumps(doc, indent=2))
    print(render(doc, a.top))
    return 0


if __name__ == "__main__":
    sys.exit(main())
