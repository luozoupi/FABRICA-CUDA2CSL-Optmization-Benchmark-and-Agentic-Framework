#!/usr/bin/env python3
"""Hardware submission for CSL kernels via the Cerebras cluster.

Uses the cerebras.sdk.client API (SdkCompiler + SdkRuntime) to compile
and run CSL kernels on real WSE-3 hardware via the ALCF Cerebras cluster.

Setup: pip install cerebras_appliance==2.10.0 cerebras_sdk==2.10.0
       into ~/cs_appliance_sdk venv (see docs.alcf.anl.gov/ai-testbed/cerebras/csl/)

Usage:
    python hardware_submit.py --kernel-dir kernels/Histogram-1PE/CSL \\
        --layout layout.csl --cslc-args "--params=n:256,n_buckets:16,bucket_size:64"
"""

from __future__ import annotations

import json
import logging
import os
import re
import shutil
from pathlib import Path
from typing import Dict, Optional

logging.basicConfig(level=logging.INFO,
                    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s")
logger = logging.getLogger("hardware_submit")

REPO_ROOT = Path(__file__).resolve().parents[1]
SDK_VENV = os.path.expanduser("~/cs_appliance_sdk")

# Fabric dimensions: simulator uses small dims, hardware uses full WSE-3
FABRIC_DIMS_SIM = "8,3"
FABRIC_DIMS_HW = "762,1172"


# ---------------------------------------------------------------------------
# SDK 2.10 Porter
# ---------------------------------------------------------------------------

_COMPTIME_STRUCT_PARAM = re.compile(r":\s*comptime_struct\s*;")
_COMPTIME_STRUCT_CONST = re.compile(r":\s*comptime_struct\s*=")
_COMPTIME_STRUCT_FN_RET = re.compile(r"\)\s*comptime_struct\s*\{")
_UNINIT_TYPED_PARAM = re.compile(r"^(param\s+\w+)\s*:\s*[iu](?:8|16|32|64)\s*;", re.MULTILINE)
# @concat_structs(A, B) — inline both struct literals into one
_CONCAT_STRUCTS = re.compile(r"@concat_structs\s*\(\s*(\w+)\s*,\s*(\w+)\s*\)")


def _extract_struct_fields(text: str, var_name: str) -> Optional[str]:
    """Extract the field list from `const var_name = .{ ... };` in CSL source."""
    pattern = re.compile(
        rf"const\s+{re.escape(var_name)}\s*=\s*\.{{\s*(.*?)\s*}}\s*;",
        re.DOTALL,
    )
    m = pattern.search(text)
    if m:
        return m.group(1).strip().rstrip(",")
    return None


def _inline_concat_structs(text: str) -> str:
    """Replace @concat_structs(A, B) with a merged struct literal.

    Finds the const definitions for A and B, extracts their fields,
    and replaces the call with .{ <A fields>, <B fields> }.
    Falls back to the original text if extraction fails.
    """
    for m in list(_CONCAT_STRUCTS.finditer(text)):
        a_name, b_name = m.group(1), m.group(2)
        a_fields = _extract_struct_fields(text, a_name)
        b_fields = _extract_struct_fields(text, b_name)
        if a_fields is not None and b_fields is not None:
            merged = f".{{ {a_fields}, {b_fields} }}"
            text = text[:m.start()] + merged + text[m.end():]
            logger.info("[port] inlined @concat_structs(%s, %s)", a_name, b_name)
        else:
            logger.warning("[port] could not inline @concat_structs(%s, %s) — "
                           "field extraction failed", a_name, b_name)
    return text


def port_kernel_to_sdk210(kernel_dir: str, output_dir: str) -> str:
    """Mechanically port a SDK 1.4.0 kernel to 2.10 syntax."""
    src = Path(kernel_dir)
    dst = Path(output_dir)
    if dst.exists():
        shutil.rmtree(dst)
    shutil.copytree(src, dst)

    changes = 0
    for csl_file in dst.rglob("*.csl"):
        text = csl_file.read_text(encoding="utf-8")
        original = text
        # 1. Remove comptime_struct type annotations
        text = _COMPTIME_STRUCT_PARAM.sub(";", text)
        text = _COMPTIME_STRUCT_CONST.sub(" =", text)
        text = _COMPTIME_STRUCT_FN_RET.sub(") anytype {", text)
        # 2. Layout files: add default = 1 for uninitialized typed params
        is_layout = "layout" in csl_file.name.lower() or "code" in csl_file.name.lower()
        if is_layout:
            text = _UNINIT_TYPED_PARAM.sub(r"\1 = 1;", text)
            # 3. Inline @concat_structs(A, B) by finding const A and B definitions
            #    and merging their fields into a single struct literal.
            text = _inline_concat_structs(text)
        else:
            text = _UNINIT_TYPED_PARAM.sub(r"\1;", text)
        if text != original:
            csl_file.write_text(text, encoding="utf-8")
            changes += 1
            logger.info("[port] %s: ported to SDK 2.10", csl_file.name)

    logger.info("[port] ported %d files in %s", changes, dst)
    return str(dst)


# ---------------------------------------------------------------------------
# Appliance Compile + Run
# ---------------------------------------------------------------------------

def appliance_compile(app_path: str, csl_main: str = "layout.csl",
                      cslc_args: str = "", simulator: bool = True) -> str:
    """Compile CSL kernel via the cluster's SdkCompiler.
    Returns the artifact path (tar.gz)."""
    from cerebras.sdk.client import SdkCompiler

    fabric = FABRIC_DIMS_SIM if simulator else FABRIC_DIMS_HW
    # Replace fabric dims in cslc_args if present
    args = re.sub(r"--fabric-dims=\S+", f"--fabric-dims={fabric}", cslc_args)
    if "--fabric-dims" not in args:
        args = f"--arch=wse3 --fabric-dims={fabric} --fabric-offsets=4,1 {args}"

    logger.info("[compile] %s %s (simulator=%s)", csl_main, args, simulator)

    with SdkCompiler(disable_version_check=True) as compiler:
        artifact_path = compiler.compile(app_path, csl_main, args, app_path)

    logger.info("[compile] artifact: %s", artifact_path)
    return artifact_path


def appliance_run(artifact_path: str, run_fn, simulator: bool = True) -> Dict:
    """Run a compiled CSL kernel via the cluster's SdkRuntime.

    run_fn(runner) is called with the SdkRuntime instance and should
    perform H2D, launch, D2H, and return a result dict.
    """
    from cerebras.sdk.client import SdkRuntime

    logger.info("[run] artifact=%s simulator=%s", artifact_path, simulator)

    with SdkRuntime(artifact_path, simulator=simulator,
                    disable_version_check=True) as runner:
        result = run_fn(runner)

    return result


def benchmark_on_hardware(kernel_dir: str, csl_main: str = "layout.csl",
                          cslc_args: str = "",
                          run_fn=None, port_to_210: bool = True,
                          simulator: bool = False) -> Dict:
    """Full pipeline: port → compile on cluster → run on hardware."""
    import tempfile

    work_dir = tempfile.mkdtemp(prefix="hw_")

    if port_to_210:
        bundle = port_kernel_to_sdk210(kernel_dir, os.path.join(work_dir, "bundle"))
    else:
        bundle = kernel_dir

    artifact = appliance_compile(bundle, csl_main, cslc_args, simulator=simulator)

    if run_fn:
        result = appliance_run(artifact, run_fn, simulator=simulator)
    else:
        result = {"artifact": artifact, "status": "compiled_only"}

    result["work_dir"] = work_dir
    result["bundle"] = bundle
    result["artifact_path"] = artifact
    result["simulator"] = simulator
    return result


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    import argparse
    import sys

    # Ensure we're using the SDK venv
    if "cs_appliance_sdk" not in sys.executable:
        print(f"WARNING: Not using SDK venv. Run with: {SDK_VENV}/bin/python {__file__}")

    parser = argparse.ArgumentParser(description="Submit CSL kernel to Cerebras cluster")
    parser.add_argument("--kernel-dir", required=True)
    parser.add_argument("--layout", default="layout.csl")
    parser.add_argument("--cslc-args", default="--memcpy --channels=1")
    parser.add_argument("--no-port", action="store_true")
    parser.add_argument("--simulator", action="store_true", default=False)
    parser.add_argument("--compile-only", action="store_true")
    args = parser.parse_args()

    result = benchmark_on_hardware(
        args.kernel_dir, args.layout, args.cslc_args,
        run_fn=None if args.compile_only else None,  # TODO: generic run_fn
        port_to_210=not args.no_port,
        simulator=args.simulator,
    )
    print(json.dumps({k: str(v) for k, v in result.items()}, indent=2))
