#!/usr/bin/env python3
"""
CSL profiling feedback helpers for the CUDA -> CSL workflow.

This module intentionally starts with low-overhead, always-available signals:
the staged bundle command transcript, compile/run wall times, emitted runtime
markers, and generated SDK artifacts. It does not require GUI access, but it
records enough artifact paths for a human or future agent to launch the SDK GUI
when appropriate.
"""

from __future__ import annotations

import argparse
import json
import os
import shutil
import tempfile
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional

from benchmark_csl import benchmark_translated_compute_file, benchmark_translated_dir
from workflow_common import (
    ensure_directory,
    expand_path,
    load_shell_setup,
    save_json,
    timestamped_output_dir,
)
from workflow_common import default_sdk_root, sdk_sif_path  # noqa: E402


import glob
import logging
import re
import subprocess

REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_OUTPUT = str(Path(__file__).resolve().parent / "results" / "profile_csl")

_SIM_LOG_DIMX_RE = re.compile(r"dimX=(\d+),\s*dimY=(\d+)")
_SIM_LOG_HWTILE_RE = re.compile(r"P(\d+)\.(\d+)\s+\(hwtile\)")
_SIM_LOG_CYCLES_RE = re.compile(r"cycles=(\d+),")
_SIM_LOG_IDLE_RE = re.compile(r"(\d+)\s+cycles since an instruction was executed")
_SIM_LOG_CTF_RE = re.compile(r"CTF Stats:\s+(\w+)\s+=\s+(\d+)")
_CS_READELF_MEM_RE = re.compile(r"\((\d+),\s*(\d+)\):\s+(\d+)\s+bytes")
PE_SRAM_BYTES = 49152  # 48 KB


def _as_float(value: Any) -> Optional[float]:
    if isinstance(value, (int, float)):
        return float(value)
    return None


def _first_run_stdout(transcript: Iterable[Dict[str, Any]]) -> str:
    for entry in transcript:
        if entry.get("step") == "run":
            return str(entry.get("stdout") or "")
    return ""


def _parse_sim_log(sim_log_path: str) -> Optional[Dict[str, Any]]:
    """Parse sim.log for grid dimensions, CTF aggregate stats, and idle cycles.
    Returns a structured dict with a bottleneck classification, or None if
    the file can't be read."""
    try:
        text = Path(sim_log_path).read_text(encoding="utf-8", errors="ignore")
    except OSError:
        return None

    grid = (0, 0)
    hw_tiles = 0
    total_cycles = 0
    idle_at_end = 0
    ctf: Dict[str, int] = {}

    m = _SIM_LOG_DIMX_RE.search(text)
    if m:
        grid = (int(m.group(1)), int(m.group(2)))
    hw_tiles = len(_SIM_LOG_HWTILE_RE.findall(text))
    m = _SIM_LOG_CYCLES_RE.search(text)
    if m:
        total_cycles = int(m.group(1))
    m = _SIM_LOG_IDLE_RE.search(text)
    if m:
        idle_at_end = int(m.group(1))
    for m in _SIM_LOG_CTF_RE.finditer(text):
        ctf[m.group(1)] = int(m.group(2))

    inst_dispatch = ctf.get("num_inst_dispatch", 0)
    stalls = ctf.get("num_stalls_", 0)
    wavelets = ctf.get("num_wavelets", 0)

    stall_ratio = stalls / max(inst_dispatch, 1)
    wavelet_density = wavelets / max(inst_dispatch, 1)

    if stall_ratio > 0.3:
        label = "stall-bound"
    elif wavelet_density > 0.5 and stall_ratio < 0.1:
        label = "fabric-bound"
    else:
        label = "compute-bound"

    return {
        "grid": grid,
        "hw_tiles": hw_tiles,
        "total_cycles": total_cycles,
        "idle_cycles_at_end": idle_at_end,
        "ctf_stats": {
            "num_stalls": stalls,
            "num_wavelets": wavelets,
            "num_inst_dispatch": inst_dispatch,
            "num_inst_pipe": ctf.get("num_inst_pipe", 0),
        },
        "stall_ratio": round(stall_ratio, 4),
        "wavelet_density": round(wavelet_density, 4),
        "bottleneck_label": label,
    }


def _run_cs_readelf(staged_bundle: str, sdk_root: str = "") -> Optional[Dict[str, Any]]:
    """Run cs_readelf --ms on the first compute ELF to get per-PE SRAM usage.
    Gated by XKERNEL_PROFILE_MEMORY=1 (default off — adds ~1s overhead)."""
    if os.environ.get("XKERNEL_PROFILE_MEMORY", "0") != "1":
        return None

    elf_dir = os.path.join(staged_bundle, "out", "bin")
    elfs = sorted(glob.glob(os.path.join(elf_dir, "out_*_0.elf")))
    if not elfs:
        return None

    sdk_root = os.path.expanduser(sdk_root or default_sdk_root())
    sif = sdk_sif_path(sdk_root) or ""
    if not os.path.isfile(sif):
        return None

    # cs_readelf host wrapper binds only CWD into the container (-C mode).
    # Run from the ELF's directory so the bind mount covers the file.
    cs_readelf_cmd = os.path.join(sdk_root, "cs_readelf")
    if not os.path.isfile(cs_readelf_cmd):
        cs_readelf_cmd = "cs_readelf"
    elf_abs = os.path.abspath(elfs[0])
    elf_dir = os.path.dirname(elf_abs)
    elf_name = os.path.basename(elf_abs)
    try:
        r = subprocess.run(
            [cs_readelf_cmd, "--ms", elf_name],
            capture_output=True, text=True, timeout=30,
            cwd=elf_dir,
        )
        if r.returncode != 0:
            return None
    except Exception:
        return None

    pe_memory: Dict[str, int] = {}
    max_bytes = 0
    for m in _CS_READELF_MEM_RE.finditer(r.stdout):
        x, y, b = int(m.group(1)), int(m.group(2)), int(m.group(3))
        pe_memory[f"({x},{y})"] = b
        max_bytes = max(max_bytes, b)

    if not pe_memory:
        return None

    return {
        "pe_memory": pe_memory,
        "max_bytes": max_bytes,
        "utilization": round(max_bytes / PE_SRAM_BYTES, 4),
        "elf_path": elfs[0],
    }


def _find_artifacts(staged_bundle: Optional[str],
                    cycles_send: Optional[int] = None) -> Dict[str, Any]:
    if not staged_bundle or not os.path.exists(staged_bundle):
        return {
            "staged_bundle": staged_bundle,
            "available": False,
            "reason": "staged bundle was not kept for artifact inspection",
        }

    root = Path(staged_bundle)
    out_dir = root / "out"
    sim_logs = sorted(str(path) for path in root.rglob("sim.log"))
    simfab_dirs = sorted(str(path) for path in root.rglob("simfab_traces") if path.is_dir())
    elf_files = sorted(str(path) for path in root.rglob("*.elf"))
    json_files = sorted(str(path) for path in root.rglob("*.json"))

    sim_log_parsed = None
    if sim_logs:
        sim_log_parsed = _parse_sim_log(sim_logs[0])

    memory_profile = _run_cs_readelf(str(root))

    trace_profile = None
    if os.environ.get("XKERNEL_TRACE_PROFILE", "0") == "1" and simfab_dirs:
        try:
            from ctf_trace_parser import build_trace_report
            stream0 = os.path.join(simfab_dirs[0], "stream0")
            if os.path.isfile(stream0):
                trace_profile = build_trace_report(stream0)
        except Exception:
            pass

    # Silicon-model readout (IPDPS 2027 study). Gate XKERNEL_MODEL_GUIDED=1; the
    # heavier fabric/NoC and lower-bound passes have their own gates. Off by
    # default so the heuristic profile path is unchanged.
    model_readout = None
    if os.environ.get("XKERNEL_MODEL_GUIDED", "0") == "1" and simfab_dirs:
        try:
            import wse3_model
            model_readout = wse3_model.build_readout(
                str(root), simfab_dirs[0], cycles_send,
                want_noc=os.environ.get("XKERNEL_MODEL_NOC", "0") == "1",
                want_runtime=os.environ.get("XKERNEL_MODEL_RUNTIME", "0") == "1",
                sdk_root=os.environ.get("XKERNEL_SDK_ROOT") or default_sdk_root(),
                kernel=root.name,
            )
        except Exception as exc:  # never let the model break a benchmark
            logging.warning("[profile] silicon-model readout failed: %s", exc)

    return {
        "staged_bundle": str(root),
        "available": True,
        "model_readout": model_readout,
        "compile_output_dir": str(out_dir) if out_dir.exists() else None,
        "sim_log_count": len(sim_logs),
        "sim_logs": sim_logs[:10],
        "sim_log_parsed": sim_log_parsed,
        "simfab_trace_dir_count": len(simfab_dirs),
        "simfab_trace_dirs": simfab_dirs[:10],
        "elf_count": len(elf_files),
        "json_count": len(json_files),
        "sample_json_files": json_files[:10],
        "memory_profile": memory_profile,
        "trace_profile": trace_profile,
    }


def _sdk_profile_notes(target_sdk: str, arch: str) -> List[Dict[str, str]]:
    notes: List[Dict[str, str]] = []
    if arch.lower() == "wse3" and target_sdk.startswith("1.4"):
        notes.append({
            "category": "sdk_capability",
            "severity": "info",
            "finding": (
                "SDK 1.4.0 release notes mark SDK GUI instruction traces as "
                "unsupported on WSE-3."
            ),
            "recommendation": (
                "Use wall-clock timing, command transcripts, CSL timers, and "
                "wavelet/router logs for automated feedback on this node. Treat "
                "GUI instruction timelines as a future SDK-upgrade feature."
            ),
        })
    return notes


def _classify_bottlenecks(benchmark: Dict[str, Any],
                          artifacts: Dict[str, Any],
                          target_sdk: str,
                          arch: str) -> List[Dict[str, str]]:
    insights: List[Dict[str, str]] = []
    status = str(benchmark.get("status") or "unknown")
    compile_ms = _as_float(benchmark.get("compile_time_ms"))
    run_ms = _as_float(benchmark.get("run_time_ms"))
    transcript = benchmark.get("transcript") or []
    run_stdout = _first_run_stdout(transcript if isinstance(transcript, list) else [])

    if status != "pass":
        insights.append({
            "category": "correctness_gate",
            "severity": "blocker",
            "finding": (
                f"Profiling is limited because the staged bundle status is {status} "
                f"({benchmark.get('failure_reason')})."
            ),
            "recommendation": (
                "Repair compile/runtime correctness before making performance-guided "
                "CSL changes."
            ),
        })
        return insights + _sdk_profile_notes(target_sdk, arch)

    # Silicon-model readout first: measured facts about THIS candidate's trace,
    # scored against WSE-3 silicon ceilings (see wse3_model.py).
    readout = artifacts.get("model_readout") or {}
    if readout:
        text = str(readout.get("readout_text") or "")
        facts, _, fix = text.partition("Recommended: ")
        rf = readout.get("roofline_fraction_f16")
        insights.append({
            "category": "silicon_model",
            "severity": "warning" if isinstance(rf, (int, float)) and rf < 0.05 else "info",
            "finding": facts.strip(),
            "recommendation": (fix or str(readout.get("recommended_fix") or "")).strip(),
        })

    # Phase 1a hook: surface per-run cycle variance when num_runs > 1.
    # Tells the optimizer "this measurement was stable" vs "this measurement
    # had 40% variance so the median may be unreliable". Cheap insight that
    # works today without simfab parsing.
    cycles_runs = benchmark.get("cycles_send_runs") or []
    if isinstance(cycles_runs, list) and len(cycles_runs) >= 2:
        c_min = min(cycles_runs)
        c_max = max(cycles_runs)
        if c_min > 0:
            spread_pct = round(100.0 * (c_max - c_min) / c_min, 1)
            severity = "warning" if spread_pct > 20.0 else "info"
            insights.append({
                "category": "measurement_variance",
                "severity": severity,
                "finding": (
                    f"cycles_send across {len(cycles_runs)} runs: "
                    f"{cycles_runs} (min={c_min}, max={c_max}, "
                    f"spread={spread_pct}%)."
                ),
                "recommendation": (
                    "High variance (>20%) means a single-run cycles_send "
                    "can mislead the optimizer; the median is the accept "
                    "signal, but treat small improvements (<5%) as noise."
                    if severity == "warning"
                    else "Measurement is stable; trust the median."
                ),
            })

    if compile_ms is not None and run_ms is not None:
        if compile_ms > max(run_ms * 2.0, 1000.0):
            insights.append({
                "category": "compile_overhead",
                "severity": "info",
                "finding": (
                    f"Compile time ({compile_ms:.1f} ms) dominates run time "
                    f"({run_ms:.1f} ms) in this small smoke benchmark."
                ),
                "recommendation": (
                    "Do not overfit optimization decisions to compile wall-clock for "
                    "tiny GEMV; use run time and correctness as the primary POC metric."
                ),
            })
        elif run_ms > max(compile_ms * 1.5, 1000.0):
            insights.append({
                "category": "runtime_overhead",
                "severity": "warning",
                "finding": (
                    f"Run time ({run_ms:.1f} ms) dominates compile time "
                    f"({compile_ms:.1f} ms)."
                ),
                "recommendation": (
                    "Inspect host transfer/kernel boundaries and consider adding CSL "
                    "timer instrumentation to separate memcpy, launch, and compute cost."
                ),
            })
        else:
            insights.append({
                "category": "balanced_smoke",
                "severity": "info",
                "finding": (
                    f"Compile ({compile_ms:.1f} ms) and run ({run_ms:.1f} ms) are "
                    "both visible in the smoke profile."
                ),
                "recommendation": (
                    "Use this as a sanity profile; deeper bottleneck attribution needs "
                    "CSL timers or simulator trace logs."
                ),
            })

    if "Copying data" in run_stdout and "Launching kernel" in run_stdout:
        insights.append({
            "category": "host_runtime_markers",
            "severity": "info",
            "finding": (
                "The host runner exposes copy and kernel launch phases in stdout, "
                "but the current transcript only times the whole cs_python step."
            ),
            "recommendation": (
                "Future feedback passes should optionally instrument run.py with "
                "phase timers or parse SdkRuntime trace logs to distinguish H2D, "
                "kernel, D2H, and runner overhead."
            ),
        })

    if artifacts.get("available"):
        slp = artifacts.get("sim_log_parsed")
        if slp:
            label = slp.get("bottleneck_label", "unknown")
            ctf = slp.get("ctf_stats", {})
            grid = slp.get("grid", (0, 0))
            _advice = {
                "compute-bound": "Focus on compute-loop optimization (fmac_bulk, dsd_offset_chaining, comptime_hoist).",
                "fabric-bound": "Overlap communication with compute (async_detach_overlap), reduce wavelet volume.",
                "stall-bound": "Fix wavelet ordering or deadlock; PEs are idle waiting on fabric data.",
            }
            insights.append({
                "category": "arch_profile",
                "severity": "info",
                "finding": (
                    f"Grid: {grid[0]}x{grid[1]} ({slp.get('hw_tiles', 0)} hw tiles), "
                    f"Total cycles: {slp.get('total_cycles', 0)}. "
                    f"Inst dispatches: {ctf.get('num_inst_dispatch', 0)}, "
                    f"Wavelets: {ctf.get('num_wavelets', 0)}, "
                    f"Stalls: {ctf.get('num_stalls', 0)}. "
                    f"Bottleneck: {label} "
                    f"(stall_ratio={slp.get('stall_ratio', 0)}, "
                    f"wavelet_density={slp.get('wavelet_density', 0)})."
                ),
                "recommendation": _advice.get(label, "Inspect sim.log for details."),
            })
        elif artifacts.get("sim_log_count") or artifacts.get("simfab_trace_dir_count"):
            insights.append({
                "category": "trace_artifacts",
                "severity": "info",
                "finding": "Simulator traces present but could not be parsed.",
                "recommendation": "Check sim.log format manually.",
            })

        tp = artifacts.get("trace_profile")
        if tp:
            lines = [
                f"Events: {tp.get('total_events', 0)}. "
                f"PE utilization: min={tp.get('util_stats', {}).get('min', 0):.0%} "
                f"max={tp.get('util_stats', {}).get('max', 0):.0%} "
                f"mean={tp.get('util_stats', {}).get('mean', 0):.0%}. "
                f"Bottleneck: {tp.get('bottleneck', '?')} — {tp.get('bottleneck_reason', '')}."
            ]
            if tp.get("congested_count", 0) > 0:
                lines.append(f"Back-pressure detected on {tp['congested_count']} tile-link pairs.")
            insights.append({
                "category": "trace_profile",
                "severity": "info",
                "finding": " ".join(lines),
                "recommendation": {
                    "compute-bound": "Focus on compute-loop optimization.",
                    "fabric-bound": "Overlap communication with compute (async).",
                    "stall-bound": "Fix wavelet ordering; PEs are idle waiting on data.",
                }.get(tp.get("bottleneck", ""), "Inspect traces."),
            })

        mem = artifacts.get("memory_profile")
        if mem:
            util_pct = round(mem["utilization"] * 100, 1)
            severity = "warning" if util_pct > 85 else "info"
            if util_pct > 85:
                rec = f"WARNING: {util_pct}% SRAM used — near 48KB ceiling. Reduce tile size or move data off-PE."
            else:
                rec = f"Memory headroom OK ({round(100 - util_pct, 1)}% free)."
            insights.append({
                "category": "memory_profile",
                "severity": severity,
                "finding": f"Max PE SRAM: {mem['max_bytes']} / {PE_SRAM_BYTES} bytes ({util_pct}%).",
                "recommendation": rec,
            })

    insights.extend(_sdk_profile_notes(target_sdk, arch))
    return insights


def format_profile_for_prompt(profile: Dict[str, Any], max_chars: int = 3500) -> str:
    """Return a compact profiler feedback block for optimization prompts."""
    benchmark = profile.get("benchmark", {})
    artifacts = profile.get("artifacts", {})
    # cycles_send / time_send_us are the optimization-relevant metrics. Lead
    # with them so the optimizer sees the cycle target at the top of the block.
    cyc = benchmark.get("cycles_send")
    tus = benchmark.get("time_send_us")
    cycle_line = (
        f"- cycles_send: {cyc} cycles ({tus:.2f} us)" if (isinstance(cyc, int) and isinstance(tus, float))
        else f"- cycles_send: {cyc}  time_send_us: {tus}"
        if cyc is not None
        else "- cycles_send: (not reported by run.py — kernel has no tic()/toc() instrumentation)"
    )
    readout = artifacts.get("model_readout") or {}
    model_line = None
    if readout:
        rf = readout.get("roofline_fraction_f16")
        roof = f"roofline {100.0 * rf:.2f}% of the f16 FMA ceiling, " if isinstance(rf, (int, float)) else ""
        model_line = (f"- silicon model: class={readout.get('bottleneck')}, {roof}"
                      f"{readout.get('elements_per_dispatch')} elements/dispatch, "
                      f"f16 share {readout.get('f16_arith_pct')}%, IPC {readout.get('ipc')}")
        if max_chars < 4500:
            max_chars = 4500  # never let the readout be the part that is truncated
    lines = [
        "Profiler feedback:",
        cycle_line,
        *([model_line] if model_line else []),
        f"- profile_status: {profile.get('profile_status')}",
        f"- target_sdk: {profile.get('target_sdk')}",
        f"- arch: {profile.get('arch')}",
        f"- benchmark_status: {benchmark.get('status')}",
        f"- compile_time_ms: {benchmark.get('compile_time_ms')}",
        f"- run_time_ms (wall-clock, INCLUDES sim startup + memcpy + Python verify): {benchmark.get('run_time_ms')}",
        f"- success_marker: {benchmark.get('success_marker')}",
        f"- staged_artifacts_available: {artifacts.get('available')}",
        f"- elf_count: {artifacts.get('elf_count')}",
        f"- sim_log_count: {artifacts.get('sim_log_count')}",
        f"- simfab_trace_dir_count: {artifacts.get('simfab_trace_dir_count')}",
        f"- bottleneck_label: {(artifacts.get('sim_log_parsed') or {}).get('bottleneck_label', 'n/a')}",
        "",
        "NOTE: cycles_send is what the optimizer is targeting. run_time_ms is "
        "dominated by simulator startup + memcpy + Python verification (~3 s "
        "overhead) and is NOT useful for cycle reduction; ignore it for "
        "optimization purposes.",
        "",
        "Insights for the optimization agent:",
    ]
    for item in profile.get("insights", []):
        lines.append(
            "- [{severity}] {category}: {finding} Recommendation: {recommendation}".format(
                severity=item.get("severity", "info"),
                category=item.get("category", "profile"),
                finding=item.get("finding", ""),
                recommendation=item.get("recommendation", ""),
            )
        )
    text = "\n".join(lines).strip()
    if len(text) > max_chars:
        return text[:max_chars] + "\n... (profiler feedback truncated)"
    return text


def build_profile_report(benchmark: Dict[str, Any],
                         target_sdk: str = "1.4.0",
                         arch: str = "wse3",
                         stage_label: str = "benchmark") -> Dict[str, Any]:
    artifacts = _find_artifacts(str(benchmark.get("staged_bundle") or ""),
                                cycles_send=benchmark.get("cycles_send"))
    profile: Dict[str, Any] = {
        "stage_label": stage_label,
        "profile_status": benchmark.get("status"),
        "target_sdk": target_sdk,
        "arch": arch,
        "benchmark": {
            "status": benchmark.get("status"),
            "failure_reason": benchmark.get("failure_reason"),
            "compile_time_ms": benchmark.get("compile_time_ms"),
            "run_time_ms": benchmark.get("run_time_ms"),
            "cycles_send": benchmark.get("cycles_send"),
            "time_send_us": benchmark.get("time_send_us"),
            "success_marker": benchmark.get("success_marker"),
            "script_elapsed_ms": benchmark.get("script_elapsed_ms"),
            "transcript_steps": len(benchmark.get("transcript") or []),
        },
        "artifacts": artifacts,
        "insights": [],
    }
    profile["insights"] = _classify_bottlenecks(benchmark, artifacts, target_sdk, arch)
    profile["agent_feedback"] = format_profile_for_prompt(profile)
    return profile


def profile_translated_compute_file(translated_path: str,
                                    reference_dir: str,
                                    target_relpath: str,
                                    work_dir: str,
                                    sdk_root: str,
                                    target_sdk: str = "1.4.0",
                                    arch: str = "wse3",
                                    shell_setup: Optional[str] = None,
                                    commands_script: Optional[str] = None,
                                    timeout: int = 300,
                                    keep_staged_bundle: bool = False) -> Dict[str, Any]:
    benchmark = benchmark_translated_compute_file(
        translated_path=translated_path,
        reference_dir=reference_dir,
        target_relpath=target_relpath,
        work_dir=work_dir,
        sdk_root=sdk_root,
        shell_setup=shell_setup,
        commands_script=commands_script,
        arch=arch,
        timeout=timeout,
        keep_staged_bundle=True,
    )
    profile = build_profile_report(
        benchmark=benchmark,
        target_sdk=target_sdk,
        arch=arch,
        stage_label="profile_run",
    )
    profile["source"] = {
        "translated_path": expand_path(translated_path),
        "reference_dir": expand_path(reference_dir),
        "target_relpath": target_relpath,
        "commands_script": commands_script,
    }
    profile["benchmark_result"] = benchmark

    staged_bundle = benchmark.get("staged_bundle")
    if not keep_staged_bundle and staged_bundle and os.path.exists(str(staged_bundle)):
        shutil.rmtree(str(staged_bundle), ignore_errors=True)
    return profile


def profile_translated_output_dir(translated_dir: str,
                                  sdk_root: str,
                                  work_dir: str,
                                  target_sdk: str = "1.4.0",
                                  arch: str = "wse3",
                                  shell_setup: Optional[str] = None,
                                  commands_script: Optional[str] = None,
                                  timeout: int = 300,
                                  keep_staged_bundle: bool = False) -> Dict[str, Any]:
    benchmark = benchmark_translated_dir(
        translated_dir=translated_dir,
        sdk_root=sdk_root,
        work_dir=work_dir,
        shell_setup=shell_setup,
        arch=arch,
        commands_script=commands_script,
        timeout=timeout,
    )
    # benchmark_translated_dir cleans its staged bundle, so rerun through the
    # explicit file path if artifact inspection is requested.
    if keep_staged_bundle:
        metadata_path = os.path.join(translated_dir, "bundle_metadata.json")
        with open(metadata_path, "r", encoding="utf-8") as fh:
            metadata = json.load(fh)
        return profile_translated_compute_file(
            translated_path=os.path.join(translated_dir, metadata["target_relpath"]),
            reference_dir=metadata["reference_dir"],
            target_relpath=metadata["target_relpath"],
            work_dir=work_dir,
            sdk_root=sdk_root,
            target_sdk=target_sdk,
            arch=arch or metadata.get("arch", "wse3"),
            shell_setup=shell_setup if shell_setup is not None else metadata.get("shell_setup"),
            commands_script=commands_script or metadata.get("commands_script"),
            timeout=timeout,
            keep_staged_bundle=True,
        )
    return build_profile_report(
        benchmark=benchmark,
        target_sdk=target_sdk,
        arch=arch,
        stage_label="translated_dir_profile",
    )


def main() -> None:
    parser = argparse.ArgumentParser(description="Profile a staged CSL translation output")
    parser.add_argument("--translated", type=str, help="Single translated compute file")
    parser.add_argument("--reference-dir", type=str, help="Reference CSL bundle directory")
    parser.add_argument("--target-relpath", type=str, default="pe.csl")
    parser.add_argument("--translated-dir", type=str, help="cuda2csl.py kernel output directory")
    parser.add_argument("--sdk-root", type=str, default=default_sdk_root())
    parser.add_argument("--target-sdk", type=str, default=os.getenv("XKERNEL_TARGET_SDK", "1.4.0"))
    parser.add_argument("--arch", type=str, default="wse3")
    parser.add_argument("--commands-script", type=str, default=None)
    parser.add_argument("--shell-setup", type=str, default=None)
    parser.add_argument("--shell-setup-file", type=str, default=None)
    parser.add_argument("--timeout", type=int, default=300)
    parser.add_argument("--keep-staged-bundle", action="store_true")
    parser.add_argument("--output", type=str, default=DEFAULT_OUTPUT)
    args = parser.parse_args()

    shell_setup = load_shell_setup(args.shell_setup, args.shell_setup_file)
    output_dir = timestamped_output_dir(expand_path(args.output), "profile")
    work_dir = ensure_directory(os.path.join(output_dir, "work"))

    if args.translated_dir:
        profile = profile_translated_output_dir(
            translated_dir=expand_path(args.translated_dir),
            sdk_root=args.sdk_root,
            work_dir=work_dir,
            target_sdk=args.target_sdk,
            arch=args.arch,
            shell_setup=shell_setup,
            commands_script=args.commands_script,
            timeout=args.timeout,
            keep_staged_bundle=args.keep_staged_bundle,
        )
    elif args.translated and args.reference_dir:
        profile = profile_translated_compute_file(
            translated_path=expand_path(args.translated),
            reference_dir=expand_path(args.reference_dir),
            target_relpath=args.target_relpath,
            work_dir=work_dir,
            sdk_root=args.sdk_root,
            target_sdk=args.target_sdk,
            arch=args.arch,
            shell_setup=shell_setup,
            commands_script=args.commands_script,
            timeout=args.timeout,
            keep_staged_bundle=args.keep_staged_bundle,
        )
    else:
        parser.error("Provide either --translated-dir or both --translated and --reference-dir.")
        return

    save_json(profile, os.path.join(output_dir, "profile.json"))
    with open(os.path.join(output_dir, "agent_feedback.txt"), "w", encoding="utf-8") as fh:
        fh.write(str(profile.get("agent_feedback") or "").strip() + "\n")
    print(json.dumps({
        "output_dir": output_dir,
        "profile_status": profile.get("profile_status"),
        "compile_time_ms": profile.get("benchmark", {}).get("compile_time_ms"),
        "run_time_ms": profile.get("benchmark", {}).get("run_time_ms"),
        "insights": len(profile.get("insights", [])),
    }, indent=2))


if __name__ == "__main__":
    main()
