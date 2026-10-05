#!/usr/bin/env python3
"""Re-measure reference kernels on the simulator and record new baselines.

Used after a reference bundle changes (e.g. the device_internal_v2 timing
protocol): stages each reference's own compute file through the same harness
the agent uses (benchmark_csl.benchmark_translated_compute_file), runs it
`--num-runs` times (median cycles_send), and

  * writes <out>/rebaseline_<UTC>.json with old vs new cycles per kernel/size,
  * optionally updates kernels/baselines_wse3.json in place (--write), keeping
    the previous value under "prev_baseline" and tagging "timing_protocol",
  * prints the `wse3_reference:` YAML lines to paste into each spec.yaml
    (specs are comment-rich, so they are not rewritten automatically).

Serial by construction (the SDK container is a serial resource).

Usage:
  python rebaseline_references.py --kernels GEMM,Laplacian2D-Halo [--sizes small,large]
      [--num-runs 3] [--write] [--protocol device_internal_v2]
"""
from __future__ import annotations

import argparse
import json
import os
import statistics
import sys
import tempfile
import time
from pathlib import Path
from typing import Any, Dict, List, Optional

sys.path.insert(0, str(Path(__file__).resolve().parent))

from benchmark_csl import benchmark_translated_compute_file  # noqa: E402
from workflow_common import default_sdk_root, expand_path  # noqa: E402

REPO_ROOT = Path(__file__).resolve().parents[1]
KERNELS = REPO_ROOT / "kernels"
BASELINES = KERNELS / "baselines_wse3.json"                 # SDK 1.4 counts (v1 study)
BASELINES_SDK210 = KERNELS / "baselines_wse3_sdk210.json"    # SDK 2.10 counts (v2 sparse study)


def baselines_path(sdk_root: str) -> Path:
    """The baselines file that matches the toolchain: 2.10 counts never mix with 1.4 counts."""
    return BASELINES_SDK210 if "2.10" in str(sdk_root) else BASELINES


def _load_yaml(path: Path) -> Dict[str, Any]:
    try:
        import yaml
        return yaml.safe_load(path.read_text()) or {}
    except Exception:
        return {}


def kernel_dir(name: str) -> Path:
    """Registry-style name (GEMM-Collectives-2D) or directory name (GEMM Collectives 2D)."""
    direct = KERNELS / name
    if direct.is_dir():
        return direct
    alt = KERNELS / name.replace("-", " ")
    if alt.is_dir():
        return alt
    for d in KERNELS.iterdir():
        if d.is_dir() and d.name.replace(" ", "-").lower() == name.replace(" ", "-").lower():
            return d
    raise SystemExit(f"kernel not found: {name}")


def measure(kdir: Path, size: Optional[Dict[str, Any]], num_runs: int, sdk_root: str,
            work_root: Path) -> Dict[str, Any]:
    csl_dir = kdir / "CSL"
    spec = _load_yaml(kdir / "spec.yaml")
    target_relpath = None
    for cand in ("pe.csl", "src/kernel.csl"):
        if (csl_dir / cand).is_file():
            target_relpath = cand
            break
    if spec.get("compute_file"):
        target_relpath = spec["compute_file"]
    if not target_relpath:
        return {"status": "no_compute_file"}
    commands_script = (size or {}).get("commands_script") or "commands_wse3.sh"
    work = tempfile.mkdtemp(prefix=f"{kdir.name.replace(' ', '_').lower()}_rebase_", dir=str(work_root))
    t0 = time.time()
    result = benchmark_translated_compute_file(
        translated_path=str(csl_dir / target_relpath),
        reference_dir=str(csl_dir),
        target_relpath=target_relpath,
        work_dir=work,
        sdk_root=sdk_root,
        commands_script=commands_script,
        num_runs=num_runs,
        keep_staged_bundle=False,
    )
    runs = result.get("cycles_send_runs") or ([result.get("cycles_send")] if result.get("cycles_send") else [])
    he = result.get("heldout_eval")
    heldout = None
    if isinstance(he, dict):
        heldout = {"passed": he.get("passed"), "reason": he.get("reason"),
                   "seeds": [[p.get("seed"), p.get("seed_echo")] for p in (he.get("per_seed") or [])]}
    return {
        "heldout_eval": heldout,
        "status": result.get("status"),
        "success_marker": result.get("success_marker"),
        "cycles_send": result.get("cycles_send"),
        "cycles_send_runs": runs,
        "cycles_median": int(statistics.median(runs)) if runs else None,
        "time_send_us": result.get("time_send_us"),
        "failure_reason": result.get("failure_reason"),
        "commands_script": commands_script,
        "target_relpath": target_relpath,
        "elapsed_s": round(time.time() - t0, 1),
    }


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--kernels", required=True, help="comma-separated kernel names")
    ap.add_argument("--sizes", default=None, help="comma-separated size names (default: all sizes in spec, else the single legacy size)")
    ap.add_argument("--num-runs", type=int, default=3)
    ap.add_argument("--sdk-root", default=default_sdk_root())
    ap.add_argument("--protocol", default="device_internal_v2")
    ap.add_argument("--write", action="store_true", help="update kernels/baselines_wse3.json in place")
    ap.add_argument("--out", default=str(REPO_ROOT / "code_translation" / "results" / "rebaseline"))
    ap.add_argument("--work-root", default=str(REPO_ROOT / "code_translation" / "sandbox" / "rebaseline"))
    a = ap.parse_args()

    out_dir = Path(expand_path(a.out)); out_dir.mkdir(parents=True, exist_ok=True)
    work_root = Path(expand_path(a.work_root)); work_root.mkdir(parents=True, exist_ok=True)
    baselines_file = baselines_path(a.sdk_root)
    baselines = json.loads(baselines_file.read_text()) if baselines_file.is_file() else {"baselines": {}}
    baselines.setdefault("_meta", {}).update({"sdk_version": "2.10" if baselines_file == BASELINES_SDK210 else "1.4.0"})
    report: Dict[str, Any] = {"protocol": a.protocol, "num_runs": a.num_runs, "sdk_root": a.sdk_root,
                              "measured_on": time.strftime("%Y-%m-%d"), "kernels": {}}
    yaml_lines: List[str] = []
    for name in [k.strip() for k in a.kernels.split(",") if k.strip()]:
        kdir = kernel_dir(name)
        spec = _load_yaml(kdir / "spec.yaml")
        reg_name = spec.get("kernel_id") or kdir.name.replace(" ", "-")
        sizes = spec.get("sizes") or []
        wanted = [s.strip() for s in a.sizes.split(",")] if a.sizes else None
        targets = [s for s in sizes if isinstance(s, dict) and (not wanted or s.get("name") in wanted)]
        # Sizes that exist only as a build script (kernels without a spec, or
        # scripts not yet registered): commands_wse3_<size>.sh.
        for name_ in (wanted or []):
            if not any(isinstance(s, dict) and s.get("name") == name_ for s in targets):
                script = f"commands_wse3_{name_}.sh" if name_ != "small" else "commands_wse3.sh"
                if (kdir / "CSL" / script).is_file():
                    targets.append({"name": name_, "commands_script": script})
        targets = targets or [None]
        report["kernels"][reg_name] = {}
        for size in targets:
            sname = (size or {}).get("name") or "default"
            old = None
            if size and isinstance(size.get("wse3_reference"), dict):
                old = size["wse3_reference"].get("cycles_send")
            elif isinstance(spec.get("wse3_reference"), dict):
                old = spec["wse3_reference"].get("cycles_send")
            if old is None:
                old = ((baselines.get("baselines") or {}).get(reg_name) or {}).get("cycles_send")
            print(f"== {reg_name} [{sname}] old={old} ...", flush=True)
            m = measure(kdir, size, a.num_runs, a.sdk_root, work_root)
            m["old_cycles_send"] = old
            new = m.get("cycles_median")
            m["delta_pct"] = round(100.0 * (new - old) / old, 2) if (new and old) else None
            report["kernels"][reg_name][sname] = m
            print(f"   status={m['status']} marker={m['success_marker']} runs={m['cycles_send_runs']} "
                  f"median={new} old={old} delta={m['delta_pct']}%  ({m['elapsed_s']}s)", flush=True)
            he = m.get("heldout_eval")
            if he:
                print(f"   heldout passed={he.get('passed')} seeds(requested, echoed)={he.get('seeds')} {str(he.get('reason'))[:80]}", flush=True)
            if new and m["status"] == "pass" and m["success_marker"]:
                yaml_lines.append(f"# {reg_name} [{sname}]: wse3_reference: {{cycles_send: {new}, time_send_us: {m.get('time_send_us')}}}  # was {old}")
                if a.write and sname in ("default", "small"):
                    entry = (baselines.setdefault("baselines", {})).setdefault(reg_name, {})
                    entry["prev_baseline"] = {"cycles_send": entry.get("cycles_send"), "time_send_us": entry.get("time_send_us"),
                                              "timing_protocol": entry.get("timing_protocol", "host_launched_tic_toc")}
                    entry["cycles_send"] = new
                    if m.get("time_send_us") is not None:
                        entry["time_send_us"] = m["time_send_us"]
                    entry["timing_protocol"] = a.protocol
                    entry["measured_on"] = report["measured_on"]
                    entry["sdk_root"] = a.sdk_root
    stamp = time.strftime("%Y%m%d_%H%M%S", time.gmtime())
    rep_path = out_dir / f"rebaseline_{stamp}.json"
    rep_path.write_text(json.dumps(report, indent=2))
    print(f"\nreport: {rep_path}")
    if yaml_lines:
        print("\nspec.yaml lines (paste into each kernel's sizes[]/wse3_reference):")
        print("\n".join(yaml_lines))
    if a.write:
        baselines_file.write_text(json.dumps(baselines, indent=2) + "\n")
        print(f"updated {baselines_file}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
