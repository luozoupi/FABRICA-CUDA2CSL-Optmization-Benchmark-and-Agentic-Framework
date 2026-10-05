#!/usr/bin/env python3
"""Does this node's simulator reproduce the committed reference cycles exactly?

Two accounts pool their sweep results, so their simulators must agree. Device
cycle counts from the SDK simulator are deterministic: the same bundle on the
same SDK gives the same `cycles_send` every run (verified repeatedly, e.g.
Attention-QP p2 measured 21,089 three times). Any difference therefore means a
different SDK build, a different container, or a modified reference bundle --
and results from that node cannot be pooled with the others.

Two cheap references are checked (~1 min total): a multi-PE collectives kernel
and a halo stencil, both carrying the device-internal timing protocol, so the
check exercises the collectives libraries, the timing helpers and the memcpy
harness rather than just a single-PE loop.

Prints one line per kernel and CALIBRATION_OK / CALIBRATION_FAILED. Exit code
mirrors that verdict, so a preflight can branch on it.

Usage: python scripts/preflight_calibrate.py [--kernels GEMV-Collectives-2D,Laplacian2D-Halo]
"""
from __future__ import annotations

import argparse
import json
import statistics
import sys
import tempfile
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO_ROOT / "code_translation"))

from benchmark_csl import benchmark_translated_compute_file  # noqa: E402
from rebaseline_references import kernel_dir, _load_yaml  # noqa: E402
from workflow_common import default_sdk_root  # noqa: E402

# Cheap, deterministic, and between them they cover collectives + halo exchange
# + the device-internal timing helpers. Values come from kernels/baselines_wse3.json.
DEFAULT_KERNELS = ["GEMV-Collectives-2D", "Laplacian2D-Halo"]              # SDK 1.4 (v1 study)
DEFAULT_KERNELS_SDK210 = ["RowScale-CSR", "SpMV-RowBlock"]                  # SDK 2.10 (v2 sparse study): one 1-PE task, one 4-PE strip


def expected_cycles(name: str, sdk_root: str = "") -> int | None:
    """The committed baseline for this toolchain: SDK 2.10 nodes compare against
    kernels/baselines_wse3_sdk210.json, SDK 1.4 nodes against baselines_wse3.json."""
    fname = "baselines_wse3_sdk210.json" if "2.10" in str(sdk_root) else "baselines_wse3.json"
    path = REPO_ROOT / "kernels" / fname
    if not path.is_file():
        return None
    baselines = json.loads(path.read_text())
    entry = (baselines.get("baselines") or {}).get(name) or {}
    return entry.get("cycles_send")


def check(name: str, num_runs: int, sdk_root: str) -> bool:
    kdir = kernel_dir(name)
    spec = _load_yaml(kdir / "spec.yaml")
    target = spec.get("compute_file") or "pe.csl"
    if not (kdir / "CSL" / target).is_file():
        print(f"  {name:24s} SKIP  no {target} in the reference bundle")
        return True
    want = expected_cycles(name, sdk_root)
    if not want:
        print(f"  {name:24s} SKIP  no committed baseline to compare against")
        return True
    with tempfile.TemporaryDirectory(prefix="preflight_cal_", dir=str(REPO_ROOT / "code_translation" / "sandbox")) as work:
        r = benchmark_translated_compute_file(
            translated_path=str(kdir / "CSL" / target),
            reference_dir=str(kdir / "CSL"),
            target_relpath=target,
            work_dir=work,
            sdk_root=sdk_root,
            commands_script="commands_wse3.sh",
            num_runs=num_runs,
        )
    runs = r.get("cycles_send_runs") or ([r["cycles_send"]] if r.get("cycles_send") else [])
    got = int(statistics.median(runs)) if runs else None
    if r.get("status") != "pass" or not r.get("success_marker"):
        print(f"  {name:24s} FAIL  reference did not pass here: status={r.get('status')} "
              f"reason={str(r.get('failure_reason'))[:70]}")
        return False
    if got != want:
        delta = 100.0 * (got - want) / want
        print(f"  {name:24s} FAIL  {got} cycles, committed baseline {want} ({delta:+.2f}%)")
        return False
    print(f"  {name:24s} ok    {got} cycles == committed baseline")
    return True


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--kernels", default=None, help="default: the toolchain's calibration kernels")
    ap.add_argument("--num-runs", type=int, default=1, help="simulator cycles are deterministic; 1 is enough")
    ap.add_argument("--sdk-root", default=default_sdk_root())
    a = ap.parse_args()
    (REPO_ROOT / "code_translation" / "sandbox").mkdir(parents=True, exist_ok=True)
    ok = True
    kernels = a.kernels or ",".join(DEFAULT_KERNELS_SDK210 if "2.10" in str(a.sdk_root) else DEFAULT_KERNELS)
    for name in [k.strip() for k in kernels.split(",") if k.strip()]:
        try:
            ok = check(name, a.num_runs, a.sdk_root) and ok
        except Exception as exc:                      # a broken SDK must fail the check, not crash it
            print(f"  {name:24s} FAIL  {type(exc).__name__}: {str(exc)[:120]}")
            ok = False
    print("CALIBRATION_OK" if ok else "CALIBRATION_FAILED")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
