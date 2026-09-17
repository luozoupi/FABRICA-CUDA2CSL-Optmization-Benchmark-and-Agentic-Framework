"""Silicon-model adapter: turn a staged bundle's simulator trace into the
WSE-3 performance-model readout the optimizer consumes.

The model itself lives in ``code_translation/performance_model`` (constants, cost
models, classifier). This module imports those tools lazily so the study stays
the single source of truth; nothing here copies a constant. If the study is
absent, or the bundle has no trace, every entry point returns ``None`` and the
optimizer falls back to the heuristic profile path it used before.

Pipeline (all CPU-side, no SDK call unless ``want_noc``):

  simfab_traces/{metadata,stream0,global_simdata.json}
      -> decode_events()      events.jsonl.gz  (CtfTraceReader + coordinates)
      -> fp_summary()         per-tile FP elements by precision, FLOP/cycle
      -> isa_probe.profile()  instruction mix, elements/dispatch, microthreads
      -> [runtime_model.analyze()]  lower bound, %bound (want_runtime)
      -> [fabric_probe + noc_model] per-link occupancy, turns (want_noc; cs_readelf)
      -> bottleneck.analyse_docs()  class + fix advice
      -> readout dict + model_keys for the angle matcher + prompt text.
"""
from __future__ import annotations

import glob
import gzip
import hashlib
import json
import logging
import os
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional

REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_STUDY_REL = Path("code_translation") / "performance_model"

# Roofline ceilings, FLOP per cycle per PE: FMA = 2 FLOP per element.
_FLOP_PER_FMA_ELEM = 2.0
_FLOP_PER_OTHER_ELEM = 1.0

# Signature keys the angle catalogue can list under `applicable_bottlenecks`.
MODEL_KEYS = (
    "model_io_dominated",
    "model_stalled",
    "model_overhead_bound",
    "model_arithmetic_bound",
    "model_f32_arith_only",
    "model_narrow_dsd",
    "model_low_ut_occupancy",
    "model_turns_present",
    "model_far_from_bound",
    "model_bank_conflict_risk",
)

_LOG = logging.getLogger(__name__)
_STUDY: Optional[Dict[str, Any]] = None
_STUDY_FAILED = False


# ---------------------------------------------------------------------------
# Study import
# ---------------------------------------------------------------------------
def study_root() -> Path:
    env = os.environ.get("XKERNEL_WSE3_STUDY_ROOT", "").strip()
    return Path(os.path.expanduser(env)) if env else REPO_ROOT / DEFAULT_STUDY_REL


def _import_study() -> Optional[Dict[str, Any]]:
    """Import the study tools once; None when the study is not available."""
    global _STUDY, _STUDY_FAILED
    if _STUDY is not None:
        return _STUDY
    if _STUDY_FAILED:
        return None
    root = study_root()
    tools = root / "tools"
    if not (root / "wse3study" / "trace.py").is_file() or not (tools / "bottleneck.py").is_file():
        _STUDY_FAILED = True
        return None
    for p in (str(root), str(tools)):
        if p not in sys.path:
            sys.path.insert(0, p)
    try:
        import importlib
        mods = {
            "trace": importlib.import_module("wse3study.trace"),
            "isa_probe": importlib.import_module("isa_probe"),
            "bottleneck": importlib.import_module("bottleneck"),
            "noc_model": importlib.import_module("noc_model"),
            "runtime_model": importlib.import_module("runtime_model"),
        }
    except Exception as exc:  # pragma: no cover - environment dependent
        _LOG.warning("wse3_model: study tools unavailable (%s)", exc)
        _STUDY_FAILED = True
        return None
    _STUDY = mods
    return mods


def study_available() -> bool:
    return _import_study() is not None


def _reset_for_tests() -> None:
    global _STUDY, _STUDY_FAILED
    _STUDY, _STUDY_FAILED = None, False


# ---------------------------------------------------------------------------
# Trace discovery and decoding
# ---------------------------------------------------------------------------
def find_simfab_dir(bundle: str | os.PathLike[str]) -> Optional[Path]:
    """Locate simfab_traces/ with a stream0 under a staged bundle (newest wins)."""
    base = Path(bundle)
    hits = [Path(p).parent for p in glob.glob(str(base / "**" / "simfab_traces" / "stream0"), recursive=True)]
    if not hits:
        return None
    hits.sort(key=lambda p: p.stat().st_mtime, reverse=True)
    return hits[0]


def find_out_dir(simfab_dir: Path) -> Optional[Path]:
    """The compiled bundle (contains bin/*.elf) that produced this trace: the
    trace's parent when cslc wrote traces into out/, else an out*/ sibling."""
    simfab = Path(simfab_dir)
    candidates = [simfab.parent] + sorted(simfab.parent.glob("out*"))
    for c in candidates:
        if c.is_dir() and any(c.glob("bin/*.elf")):
            return c
    return None


def fabric_width(simfab_dir: Path) -> Optional[int]:
    simdata = Path(simfab_dir) / "global_simdata.json"
    if not simdata.is_file():
        return None
    try:
        return int(json.loads(simdata.read_text())["xsize"])
    except (ValueError, KeyError, TypeError):
        return None


def decode_events(simfab_dir: str | os.PathLike[str], out_path: str | os.PathLike[str]) -> Optional[Path]:
    """CTF stream -> events.jsonl.gz with simulator coordinates (as tools/decode_trace.py)."""
    mods = _import_study()
    if mods is None:
        return None
    simfab = Path(simfab_dir)
    if not (simfab / "stream0").is_file():
        return None
    width = fabric_width(simfab)
    out = Path(out_path)
    out.parent.mkdir(parents=True, exist_ok=True)
    reader = mods["trace"].CtfTraceReader(simfab, strict=False)
    with gzip.open(out, "wt") as fh:
        for event in reader.iter_events():
            tile = event.get("tile_index")
            if tile is not None and width:
                event["coordinates"] = {"simulator": {"x": tile % width, "y": tile // width,
                                                      "evidence": "simulator"}}
            fh.write(json.dumps(event) + "\n")
    return out


def iter_events(events_gz: str | os.PathLike[str]) -> Iterable[Dict[str, Any]]:
    with gzip.open(events_gz, "rt") as fh:
        for line in fh:
            line = line.strip()
            if line:
                yield json.loads(line)


# ---------------------------------------------------------------------------
# Floating-point work summary (roofline numerator)
# ---------------------------------------------------------------------------
def _is_float_arith(name: str) -> bool:
    base = str(name or "").upper().split(".")[0]
    return base.startswith("F") and not base.startswith("FMOV") and "2" not in base


def fp_summary(events: Iterable[Dict[str, Any]]) -> Dict[str, Any]:
    """Per-tile FP elements by precision and FLOP; identifies the hot application PE.

    FMA-type mnemonics (FMAC*) count 2 FLOP per element, other F-arith 1 FLOP.
    num_data sentinels (>= 65535) count as one element, as in the study tools.
    """
    fma16: Dict[Any, float] = {}
    fma32: Dict[Any, float] = {}
    oth16: Dict[Any, float] = {}
    oth32: Dict[Any, float] = {}
    disp: Dict[Any, int] = {}
    uts: Dict[Any, set] = {}
    lo = hi = None
    for e in events:
        if e.get("event_type") != "hwm_dispatch_trace_entry":
            continue
        c = e.get("cycle")
        if isinstance(c, int):
            lo = c if lo is None else min(lo, c)
            hi = c if hi is None else max(hi, c)
        tile = e.get("tile_index")
        disp[tile] = disp.get(tile, 0) + 1
        ut = e.get("ut_id")
        if ut is not None and ut != 255:
            uts.setdefault(tile, set()).add(ut)
        name = str(e.get("name") or "")
        if not _is_float_arith(name):
            continue
        nd = e.get("num_data")
        nd = nd if isinstance(nd, int) and 0 < nd < 65535 else 1
        base = name.upper().split(".")[0]
        half = base.endswith("H")
        if base.startswith("FMAC"):
            tgt = fma16 if half else fma32
        else:
            tgt = oth16 if half else oth32
        tgt[tile] = tgt.get(tile, 0.0) + nd
    tiles = set(fma16) | set(fma32) | set(oth16) | set(oth32)

    def flop(t: Any) -> float:
        return (_FLOP_PER_FMA_ELEM * (fma16.get(t, 0.0) + fma32.get(t, 0.0))
                + _FLOP_PER_OTHER_ELEM * (oth16.get(t, 0.0) + oth32.get(t, 0.0)))

    hot = max(tiles, key=flop) if tiles else None
    f16_elems = (fma16.get(hot, 0.0) + oth16.get(hot, 0.0)) if hot is not None else 0.0
    f32_elems = (fma32.get(hot, 0.0) + oth32.get(hot, 0.0)) if hot is not None else 0.0
    return {
        "hot_tile": hot,
        "hot_flop": flop(hot) if hot is not None else 0.0,
        "hot_f16_elems": f16_elems,
        "hot_f32_elems": f32_elems,
        "dispatch_span": (hi - lo) if (lo is not None and hi is not None) else None,
        "busiest_tile_dispatches": max(disp.values()) if disp else 0,
        "hot_tile_ut_ids": sorted(uts.get(hot, set())) if hot is not None else [],
    }


# ---------------------------------------------------------------------------
# Optional fabric / NoC inputs
# ---------------------------------------------------------------------------
def _sha1_of_paths(paths: List[Path]) -> str:
    h = hashlib.sha1()
    for p in paths:
        if p.is_file():
            h.update(p.name.encode())
            h.update(p.read_bytes())
    return h.hexdigest()


def fabric_profile(out_dir: str | os.PathLike[str], sdk_root: Optional[str] = None,
                   cache_dir: Optional[str | os.PathLike[str]] = None,
                   layout_files: Optional[List[Path]] = None,
                   timeout: int = 300) -> Optional[Path]:
    """Run tools/fabric_probe.py over a compiled out/ dir (needs cs_readelf in the
    SDK container); the JSON is cached by the hash of the layout sources."""
    mods = _import_study()
    if mods is None:
        return None
    out = Path(out_dir)
    if not out.is_dir():
        return None
    cache_root = Path(cache_dir) if cache_dir else REPO_ROOT / "code_translation" / "results" / "model_cache"
    cache_root.mkdir(parents=True, exist_ok=True)
    key = _sha1_of_paths(layout_files or []) if layout_files else _sha1_of_paths(sorted(out.glob("bin/*.elf"))[:4])
    target = cache_root / f"fabric_{key}.json"
    if target.is_file():
        return target
    probe = study_root() / "tools" / "fabric_probe.py"
    env = dict(os.environ)
    if sdk_root:
        env["PATH"] = f"{os.path.expanduser(sdk_root)}:{env.get('PATH', '')}"
    # cs_readelf binds only the working directory into the SDK container, so the
    # bundle must be addressed relatively from inside it.
    cmd = [sys.executable, str(probe), ".", "--json", str(target), "--quiet"]
    if sdk_root:
        cmd += ["--sdk", os.path.expanduser(sdk_root)]
    try:
        r = subprocess.run(cmd, cwd=str(out), env=env, capture_output=True, text=True, timeout=timeout)
    except (OSError, subprocess.TimeoutExpired) as exc:
        _LOG.warning("wse3_model: fabric_probe failed (%s)", exc)
        return None
    if r.returncode != 0 or not target.is_file():
        _LOG.warning("wse3_model: fabric_probe rc=%s: %s", r.returncode, (r.stderr or "")[-300:])
        return None
    return target


def noc_occupancy(events_gz: Path, fabric_json: Path, xsize: int) -> Optional[Dict[str, Any]]:
    mods = _import_study()
    if mods is None:
        return None
    try:
        return mods["noc_model"].analyse(str(events_gz), str(fabric_json), int(xsize), str(study_root()))
    except Exception as exc:  # pragma: no cover
        _LOG.warning("wse3_model: noc_model failed (%s)", exc)
        return None


def runtime_bound(events_gz: Path) -> Optional[Dict[str, Any]]:
    mods = _import_study()
    if mods is None:
        return None
    try:
        return mods["runtime_model"].analyze(Path(events_gz))
    except Exception as exc:  # pragma: no cover
        _LOG.warning("wse3_model: runtime_model failed (%s)", exc)
        return None


def _fitted_prediction(runtime_doc: Dict[str, Any]) -> Optional[float]:
    """T_pred = roof + k*D + c with the study's fitted k, c (runtime_fit.json)."""
    summ = study_root() / "runtime_fit.json"
    if not summ.is_file():
        return None
    try:
        s = json.loads(summ.read_text())
        k, c = float(s["k_fitted"]), float(s["c_fitted"])
        return float(runtime_doc.get("roof", 0.0)) + k * float(runtime_doc.get("D", 0)) + c
    except (KeyError, ValueError, TypeError):
        return None


# ---------------------------------------------------------------------------
# Classification and readout
# ---------------------------------------------------------------------------
def classify(isa_doc: Dict[str, Any], fp: Optional[Dict[str, Any]] = None,
             cycles_send: Optional[int] = None, noc_doc: Optional[Dict[str, Any]] = None,
             runtime_doc: Optional[Dict[str, Any]] = None, kernel: str = "") -> Optional[Dict[str, Any]]:
    """Silicon-model readout for one benchmarked candidate."""
    mods = _import_study()
    if mods is None:
        return None
    bn = mods["bottleneck"]
    app_pes = None
    pct_bound = runtime_doc.get("pct_of_bound") if runtime_doc else None
    base = bn.analyse_docs(isa_doc, app_pes=app_pes, pct_bound=pct_bound, kernel=kernel)

    fp = fp or {}
    denom = None
    if isinstance(cycles_send, (int, float)) and cycles_send and cycles_send > 0:
        denom = float(cycles_send)
        denom_src = "cycles_send"
    elif fp.get("dispatch_span"):
        denom = float(fp["dispatch_span"])
        denom_src = "dispatch_span"
    else:
        denom_src = "none"
    hot_flop = float(fp.get("hot_flop", 0.0))
    flop_per_cycle = (hot_flop / denom) if denom else None
    f16_ceiling = _FLOP_PER_FMA_ELEM * float(bn.FP16_FMA_ELEM_PER_CYC)
    f32_ceiling = _FLOP_PER_FMA_ELEM * float(bn.FP32_FMA_ELEM_PER_CYC)

    micro = (isa_doc.get("microthreads") or {})
    # Microthreads on the hot application PE; the trace-wide count includes the
    # memcpy plumbing PEs, which always run several async streams.
    hot_uts = fp.get("hot_tile_ut_ids")
    distinct_ut = len(hot_uts) if hot_uts is not None and fp.get("hot_tile") is not None \
        else len(micro.get("distinct_microthread_ids") or [])
    simd = (isa_doc.get("simdi_field") or {})

    readout: Dict[str, Any] = dict(base)
    readout.update({
        "schema": "wse3_model/1",
        "cycles_denominator": denom_src,
        "flop_per_cycle": round(flop_per_cycle, 4) if flop_per_cycle is not None else None,
        "roofline_fraction_f16": round(flop_per_cycle / f16_ceiling, 4) if flop_per_cycle is not None else None,
        "roofline_fraction_f32": round(flop_per_cycle / f32_ceiling, 4) if flop_per_cycle is not None else None,
        "hot_f16_elems": fp.get("hot_f16_elems"),
        "hot_f32_elems": fp.get("hot_f32_elems"),
        "distinct_ut_ids": distinct_ut,
        "simd_lanes": simd.get("distinct") if isinstance(simd, dict) else None,
    })
    if noc_doc:
        readout.update({
            "turns": noc_doc.get("turns"), "hops": noc_doc.get("hops"),
            "busiest_link_wavelets": noc_doc.get("busiest_link"),
            "wavelets_total": noc_doc.get("wavelets_total"),
            "predict_link_cycles": noc_doc.get("predict_link"),
        })
        if denom and noc_doc.get("busiest_link"):
            readout["busiest_link_occupancy"] = round(
                float(bn_wavelet_cycles(bn) * noc_doc["busiest_link"]) / denom, 4)
    if runtime_doc:
        terms = {"busiest_link": runtime_doc.get("C", 0), "fabric": runtime_doc.get("fabric_term", 0),
                 "compute_floor": runtime_doc.get("lb_compute", 0)}
        readout.update({
            "lower_bound": runtime_doc.get("lower_bound"),
            "pct_of_bound": runtime_doc.get("pct_of_bound"),
            "bound_term": max(terms, key=lambda k: float(terms[k] or 0)),
            "predicted_cycles": _fitted_prediction(runtime_doc),
        })
    readout["model_keys"] = model_keys(readout)
    return readout


def bn_wavelet_cycles(bn_module: Any) -> float:
    return float(getattr(bn_module, "FABRIC_CYC_PER_WAVELET", 1.0))


def model_keys(readout: Dict[str, Any]) -> List[str]:
    """Bottleneck-signature keys consumed by the optimizer's angle matcher."""
    keys: List[str] = []
    cls = readout.get("bottleneck")
    if cls == "io_dominated":
        keys.append("model_io_dominated")
    elif cls == "stalled":
        keys.append("model_stalled")
    elif cls == "overhead_bound":
        keys.append("model_overhead_bound")
    elif cls == "arithmetic_bound":
        keys.append("model_arithmetic_bound")
    f16 = readout.get("f16_arith_pct")
    has_fp = (readout.get("float_pct") or 0) > 0 or (readout.get("hot_f16_elems") or readout.get("hot_f32_elems"))
    if has_fp and isinstance(f16, (int, float)) and f16 < 50.0:
        keys.append("model_f32_arith_only")
    epd = readout.get("elements_per_dispatch")
    if isinstance(epd, (int, float)) and epd < 4.0 and has_fp:
        keys.append("model_narrow_dsd")
    ipc = readout.get("ipc")
    if (readout.get("distinct_ut_ids") or 0) <= 2 and isinstance(ipc, (int, float)) and ipc < 0.6:
        keys.append("model_low_ut_occupancy")
    # The launch/memcpy harness itself contributes 6 turns on every multi-PE
    # kernel (FINDINGS §7: colour signature {0:3, 1:2, 3:1}, identical for Jacobi
    # and WaferLLM); only turns beyond that floor are application routing.
    if (readout.get("turns") or 0) > 6:
        keys.append("model_turns_present")
    pct = readout.get("pct_of_bound")
    if isinstance(pct, (int, float)) and pct < 10.0:
        keys.append("model_far_from_bound")
    if readout.get("bank_conflict_risk"):
        keys.append("model_bank_conflict_risk")
    return keys


def format_readout(readout: Dict[str, Any], max_chars: int = 900) -> str:
    """Prompt paragraph: measured facts first, then the recommended class of fix."""
    if not readout:
        return ""
    parts: List[str] = []
    cls = str(readout.get("bottleneck", "unknown")).replace("_", " ")
    parts.append(f"Silicon-model readout (traces: simulator; costs: WSE-3 silicon): class={cls}")
    ipc = readout.get("ipc")
    if ipc is not None:
        parts.append(f"IPC on busiest PE {ipc:.3f} (issue ceiling 1.0)")
    fl = readout.get("float_pct")
    if fl is not None:
        parts.append(f"float dispatches {fl:.1f}%")
    epd = readout.get("elements_per_dispatch")
    if epd is not None:
        parts.append(f"{epd:.2f} elements/dispatch")
    f16 = readout.get("f16_arith_pct")
    if f16 is not None:
        parts.append(f"f16 share of FP arithmetic {f16:.0f}%")
    rf = readout.get("roofline_fraction_f16")
    if rf is not None:
        parts.append(f"roofline {100.0 * rf:.2f}% of the f16 FMA ceiling "
                     f"({100.0 * (readout.get('roofline_fraction_f32') or 0):.1f}% of f32)")
    ut = readout.get("distinct_ut_ids")
    if ut is not None:
        parts.append(f"microthreads in use {ut} (ids 0-7 available)")
    if readout.get("turns") is not None:
        parts.append(f"route turns {readout['turns']} (~20 cyc each), hops {readout.get('hops')}")
    occ = readout.get("busiest_link_occupancy")
    if occ is not None:
        parts.append(f"busiest link occupied {100.0 * occ:.1f}% of runtime")
    pct = readout.get("pct_of_bound")
    if pct is not None:
        parts.append(f"model lower bound reached {pct:.1f}% (dominated by {readout.get('bound_term')})")
    pred = readout.get("predicted_cycles")
    if pred:
        parts.append(f"model-predicted cycles {pred:.0f}")
    text = "; ".join(parts) + ". "
    fix = str(readout.get("recommended_fix") or "").strip()
    if fix:
        text += "Recommended: " + fix
    if len(text) > max_chars:
        text = text[: max_chars - 3].rstrip() + "..."
    return text


# ---------------------------------------------------------------------------
# One-call entry point for the optimizer
# ---------------------------------------------------------------------------
def build_readout(bundle_dir: str | os.PathLike[str], simfab_dir: Optional[str | os.PathLike[str]] = None,
                  cycles_send: Optional[int] = None, *, want_noc: bool = False, want_runtime: bool = False,
                  sdk_root: Optional[str] = None, keep_events: bool = False,
                  kernel: str = "") -> Optional[Dict[str, Any]]:
    """Decode the bundle's trace and return the readout dict (None if unavailable)."""
    if not study_available():
        return None
    bundle = Path(bundle_dir)
    simfab = Path(simfab_dir) if simfab_dir else find_simfab_dir(bundle)
    if simfab is None or not (simfab / "stream0").is_file():
        return None
    work = bundle / ".xkernel_model"
    events = decode_events(simfab, work / "events.jsonl.gz")
    if events is None:
        return None
    try:
        mods = _import_study()
        assert mods is not None
        fp = fp_summary(iter_events(events))
        isa_doc = mods["isa_probe"].profile(Path(events))
        runtime_doc = runtime_bound(events) if want_runtime else None
        noc_doc = None
        if want_noc:
            out_dir = find_out_dir(simfab)
            fab = fabric_profile(out_dir, sdk_root=sdk_root) if out_dir else None
            width = fabric_width(simfab)
            if fab and width:
                noc_doc = noc_occupancy(events, fab, width)
        readout = classify(isa_doc, fp, cycles_send=cycles_send, noc_doc=noc_doc,
                           runtime_doc=runtime_doc, kernel=kernel or bundle.name)
        if readout is not None:
            readout["trace_events"] = isa_doc.get("counts")
            readout["readout_text"] = format_readout(readout)
        return readout
    finally:
        if not keep_events:
            shutil.rmtree(work, ignore_errors=True)


def main() -> int:  # pragma: no cover - CLI convenience
    import argparse
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("bundle", help="staged bundle or kernel CSL dir containing simfab_traces/")
    ap.add_argument("--cycles", type=int, default=None, help="measured cycles_send (denominator)")
    ap.add_argument("--noc", action="store_true", help="also run fabric_probe + per-link NoC model (needs cs_readelf)")
    ap.add_argument("--runtime", action="store_true", help="also run the runtime lower-bound model")
    ap.add_argument("--sdk-root", default=None)
    ap.add_argument("--json", default=None)
    a = ap.parse_args()
    r = build_readout(a.bundle, cycles_send=a.cycles, want_noc=a.noc, want_runtime=a.runtime, sdk_root=a.sdk_root)
    if r is None:
        print("no readout (study or trace unavailable)")
        return 1
    print(r["readout_text"])
    print("model_keys:", r["model_keys"])
    if a.json:
        Path(a.json).write_text(json.dumps(r, indent=1, default=str))
    return 0


if __name__ == "__main__":
    sys.exit(main())
