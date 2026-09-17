#!/usr/bin/env python3
"""Paired hardware-vs-simulator benchmark for xkernel-bench CSL kernels.

WHY THIS EXISTS
---------------
Every cycle number in the benchmark (baselines_wse3.json, every sweep,
every agentic result) comes from the SDK 1.4.0 appliance SIMULATOR. A
July 2026 attempt to add hardware numbers produced
`results/hardware_validation/*.json`, but most of those are not usable:

    Tensor-Transpose-021   hw=12     vs sim=6183     -> below the 100-cycle floor
    GEMM-1PE               hw=19     vs sim=119197   -> below the 100-cycle floor
    PDFT-Pi-Pipeline       hw=27     vs sim=128308   -> below the 100-cycle floor
    Single Tile Matvec     hw=63     vs sim=780      -> below the 100-cycle floor
    DFT-1PE                hw=8607   vs sim=145233   -> 17x, implausible
    Stencil7pt-1PE         hw=3579   vs sim=40497    -> 11x, implausible

Sub-100-cycle readings are the dead-timer signature this repo already
guards against in benchmark_csl.py (`_MIN_PLAUSIBLE_CYCLES`): a kernel
that never calls timestamp.enable_tsc() reads a frozen counter. Those runs
used ad-hoc host code (hardware_submit.py's run_fn is still a TODO), so the
enable-timer launch was simply missing.

The three credible prior numbers (Histogram-1PE, Histogram-Inline,
GEMV-RowPart) had a second problem: they compare hardware against the SDK
*1.4.0* simulator baseline, while the hardware run goes through the SDK 2.10
port. That conflates three variables at once -- hardware vs simulator, SDK
1.4.0 vs 2.10, and the mechanical port.

WHAT THIS DOES DIFFERENTLY
--------------------------
One bundle, ported once, compiled and run BOTH ways through the SAME SDK
2.10 appliance client, driven by the kernel's OWN run.py (via hw_sim_shim)
so the host sequence -- including the f_enable_timer launch -- is identical
on both arms. The only variable left is the target. Both arms are checked
for the SUCCESS marker and screened against the same plausibility floor.

USAGE
    ~/cs_appliance_sdk/bin/python hw_vs_sim.py --kernel Histogram-1PE
    ~/cs_appliance_sdk/bin/python hw_vs_sim.py --kernel-dir kernels/X/CSL --arms sim,hw
"""

from __future__ import annotations

import argparse
import json
import logging
import os
import re
import shlex
import subprocess
import sys
import tempfile
import time
from pathlib import Path
from typing import Dict, List, Optional

logging.basicConfig(level=logging.INFO,
                    format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger("hw_vs_sim")

REPO_ROOT = Path(__file__).resolve().parents[1]

# Same floor benchmark_csl.py uses. A timed WSE kernel cannot legitimately
# complete in double-digit cycles; anything under this is a broken timer.
MIN_PLAUSIBLE_CYCLES = int(os.environ.get("XKERNEL_MIN_PLAUSIBLE_CYCLES", "100"))

FABRIC_DIMS_HW = "762,1172"

_CYCLES_RE = re.compile(r"cycles_send\s*=\s*(\d+)")
_SUCCESS_RE = re.compile(r"\bSUCCESS\b")

# A run.py that starts and stops the device timer with SEPARATE host launches
#
#     runner.launch("f_tic");  runner.launch("step");  runner.launch("f_toc")
#
# leaves the device TSC running across two host<->device round trips. On the
# local simulator that costs ~nothing. On the appliance each launch is a real
# network RPC (measured here at ~488us, i.e. ~415k cycles), so the "timed
# window" is dominated by host latency and is NOT a measure of device speed.
#
# Observed directly: Laplacian2D-Halo and GEMM -- unrelated kernels -- both
# land at ~829,400 cycles on hardware (~976us), because what is being measured
# in both cases is two RPCs, not the kernel.
#
# Their SIMULATOR numbers are unaffected, so published simulator results and
# speedups stand. Only the hardware comparison is invalid, and only for these.
_HOST_TIMER_RE = re.compile(r"""launch\(\s*['"]f_tic['"]""")


def host_launched_timer(bundle: Path) -> bool:
    """True if run.py brackets the timed region with separate host launches."""
    rp = bundle / "run.py"
    if not rp.is_file():
        return False
    return bool(_HOST_TIMER_RE.search(rp.read_text(encoding="utf-8", errors="ignore")))


# ---------------------------------------------------------------------------
# Bundle discovery
# ---------------------------------------------------------------------------

def parse_commands_script(script: Path) -> Dict[str, object]:
    """Pull the cslc invocation and the run.py invocations out of a
    commands_wse3.sh. Returns {csl_main, cslc_args, params, runs}."""
    text = script.read_text(encoding="utf-8")
    # Join line continuations so a multi-line cslc call parses as one command.
    text = re.sub(r"\\\s*\n\s*", " ", text)

    csl_main, cslc_args, params = "layout.csl", "", {}
    runs: List[List[str]] = []

    for raw in text.splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if line.startswith("cslc"):
            toks = shlex.split(line)[1:]
            keep: List[str] = []
            drop_next = False
            for t in toks:
                if drop_next:
                    # the value of a separated -o / --output
                    drop_next = False
                    continue
                if t.endswith(".csl"):
                    # Keep the path RELATIVE TO THE BUNDLE ROOT, not the
                    # basename: bundles like 7pt-Stencil / BiCGSTAB / CG /
                    # Preconditioned-CG keep their main at src/layout.csl, and
                    # the appliance compiler resolves csl_main against app_path.
                    # Reducing it to "layout.csl" makes the cluster compile fail
                    # with "Unable to open .../layout.csl: no such file".
                    csl_main = t[2:] if t.startswith("./") else t
                elif t.startswith("--params="):
                    for kv in t.split("=", 1)[1].split(","):
                        if ":" in kv:
                            k, v = kv.split(":", 1)
                            params[k] = v
                    keep.append(t)
                elif t in ("-o", "--output"):
                    # separated form: also drop the directory name that follows,
                    # otherwise it survives as a stray positional in the args
                    # handed to the appliance compiler (which sets out_path itself)
                    drop_next = True
                elif t.startswith("-o=") or t.startswith("--output="):
                    continue
                else:
                    keep.append(t)
            cslc_args = " ".join(keep)
        elif line.startswith("cs_python"):
            runs.append(shlex.split(line)[1:])

    return {"csl_main": csl_main, "cslc_args": cslc_args,
            "params": params, "runs": runs}


# ---------------------------------------------------------------------------
# Arm execution
# ---------------------------------------------------------------------------

_DRIVER_TEMPLATE = '''
import json, os, runpy, sys
sys.path.insert(0, {code_dir!r})
import hw_sim_shim
hw_sim_shim.install_shim({artifact!r}, simulator={simulator!r})
os.chdir({workdir!r})
sys.argv = ["run.py"] + {argv!r}
runpy.run_path({runpy_path!r}, run_name="__main__")
'''


_BENCHLIB_IMPORT = re.compile(r'(?:\.\./)+benchmark-libs/')


def vendor_benchmark_libs(bundle: Path) -> bool:
    """Copy kernels/benchmark-libs into the bundle and re-anchor its imports.

    Solver and stencil bundles import the shared library with a path that
    escapes their own directory, e.g. from src/layout.csl:

        @import_module("../../benchmark-libs/stencil_3d_7pts/layout.csl")

    Locally that resolves against the kernels/ tree. The appliance compiler
    only uploads the app directory, so anything above the bundle root is
    simply absent and the compile dies with
    "Unable to open csl/src/../../benchmark-libs/...: no such file".

    Fix: vendor the library at the bundle root, then rewrite each importing
    file's prefix to however many "../" hops that file actually needs to get
    back to the root. Returns True if anything was vendored.
    """
    csl_files = list(bundle.rglob("*.csl"))
    if not any(_BENCHLIB_IMPORT.search(f.read_text(encoding="utf-8", errors="ignore"))
               for f in csl_files):
        return False

    src_lib = REPO_ROOT / "kernels" / "benchmark-libs"
    if not src_lib.is_dir():
        logger.warning("[vendor] %s not found; imports will stay broken", src_lib)
        return False

    dst_lib = bundle / "benchmark-libs"
    if not dst_lib.exists():
        # Port the library as it is copied. The bundle was already ported before
        # this runs, so a plain copytree would drop unported SDK 1.4.0 library
        # sources into an otherwise-2.10 bundle -- and they fail with
        # "failed to evaluate function return type" on
        # `fn get_params(..) comptime_struct {`, which 2.10 spells `anytype`.
        from hardware_submit import port_kernel_to_sdk210
        port_kernel_to_sdk210(str(src_lib), str(dst_lib))
    logger.info("[vendor] benchmark-libs -> %s (ported to SDK 2.10)", dst_lib)

    for f in csl_files:
        text = f.read_text(encoding="utf-8", errors="ignore")
        if not _BENCHLIB_IMPORT.search(text):
            continue
        depth = len(f.relative_to(bundle).parts) - 1  # dirs between file and root
        prefix = "../" * depth + "benchmark-libs/"
        new = _BENCHLIB_IMPORT.sub(prefix, text)
        if new != text:
            f.write_text(new, encoding="utf-8")
            logger.info("[vendor] re-anchored imports in %s -> %s",
                        f.relative_to(bundle), prefix)
    return True


def compile_arm(bundle: Path, csl_main: str, cslc_args: str,
                simulator: bool) -> str:
    """Compile the bundle on the cluster for one arm. Returns artifact path."""
    from cerebras.sdk.client import SdkCompiler

    args = cslc_args
    if not simulator:
        # Hardware needs the real fabric extent; the kernel's own dims are
        # sized for the simulator.
        args = re.sub(r"--fabric-dims=\S+", f"--fabric-dims={FABRIC_DIMS_HW}", args)
        if "--fabric-dims" not in args:
            args = f"--fabric-dims={FABRIC_DIMS_HW} {args}"

    logger.info("[compile] simulator=%s main=%s args=%s", simulator, csl_main, args)
    t0 = time.time()
    with SdkCompiler(disable_version_check=True) as compiler:
        artifact = compiler.compile(str(bundle), csl_main, args, str(bundle))
    logger.info("[compile] artifact=%s (%.0fs)", artifact, time.time() - t0)
    return artifact


def run_arm(bundle: Path, artifact: str, simulator: bool,
            run_argv: List[str], timeout_s: int, repeats: int = 1) -> Dict:
    """Execute the kernel's own run.py against `artifact` in a subprocess.

    With repeats > 1 the compiled artifact is executed that many times (new
    runtime session each time); cycles_send is then the median and the per-run
    values are kept in cycles_send_runs (min/max flag hardware noise).
    """
    if repeats > 1:
        runs = [run_arm(bundle, artifact, simulator, run_argv, timeout_s, repeats=1)
                for _ in range(repeats)]
        first = dict(runs[0])
        cyc = [r.get("cycles_send") for r in runs if isinstance(r.get("cycles_send"), int)]
        first["cycles_send_runs"] = cyc
        first["repeats"] = repeats
        first["wall_s"] = round(sum(r.get("wall_s") or 0 for r in runs), 1)
        if cyc:
            cyc_sorted = sorted(cyc)
            first["cycles_send"] = cyc_sorted[len(cyc_sorted) // 2]
            first["cycles_send_min"] = cyc_sorted[0]
            first["cycles_send_max"] = cyc_sorted[-1]
            first["spread"] = round(cyc_sorted[-1] / cyc_sorted[0], 4) if cyc_sorted[0] else None
        statuses = [r.get("status") for r in runs]
        if any(s != "pass" for s in statuses):
            first["status"] = next(s for s in statuses if s != "pass")
            first["reason"] = f"{statuses.count('pass')}/{repeats} repeats passed"
        return first
    driver = bundle / f"_hw_vs_sim_driver_{'sim' if simulator else 'hw'}.py"
    driver.write_text(_DRIVER_TEMPLATE.format(
        code_dir=str(REPO_ROOT / "code_translation"),
        artifact=artifact,
        simulator=simulator,
        workdir=str(bundle),
        argv=run_argv,
        runpy_path=str(bundle / "run.py"),
    ), encoding="utf-8")

    t0 = time.time()
    try:
        proc = subprocess.run([sys.executable, str(driver)],
                              cwd=str(bundle), capture_output=True,
                              text=True, timeout=timeout_s)
        out, err, rc = proc.stdout, proc.stderr, proc.returncode
    except subprocess.TimeoutExpired as exc:
        out = exc.stdout.decode() if isinstance(exc.stdout, bytes) else (exc.stdout or "")
        err = "TIMEOUT"
        rc = -1
    elapsed = time.time() - t0

    blob = out + "\n" + err
    m = _CYCLES_RE.search(blob)
    cycles = int(m.group(1)) if m else None
    success = bool(_SUCCESS_RE.search(out)) and rc == 0

    status = "pass"
    reason = None
    if rc != 0:
        status, reason = "fail", f"run.py exited {rc}"
    elif not success:
        status, reason = "fail", "no SUCCESS marker"
    elif cycles is None:
        status, reason = "correctness_only", "no cycles_send printed"
    elif cycles < MIN_PLAUSIBLE_CYCLES:
        # Same anti-gaming rule as benchmark_csl.py: a sub-floor reading means
        # the timer never ran, not that the kernel is fast.
        status = "rejected_dead_timer"
        reason = (f"cycles_send={cycles} < {MIN_PLAUSIBLE_CYCLES}; "
                  "frozen TSC (missing enable_tsc) or empty timed window")

    return {"status": status, "cycles_send": cycles, "success_marker": success,
            "returncode": rc, "wall_s": round(elapsed, 1), "reason": reason,
            "stdout_tail": out[-1500:], "stderr_tail": err[-1500:]}


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------

def benchmark_kernel(kernel_dir: Path, arms: List[str], timeout_s: int,
                     port: bool = True, repeats: int = 1) -> Dict:
    from hardware_submit import port_kernel_to_sdk210

    commands = kernel_dir / "commands_wse3.sh"
    if not commands.is_file():
        return {"status": "skip", "reason": "no commands_wse3.sh"}
    spec = parse_commands_script(commands)
    if not spec["runs"]:
        return {"status": "skip", "reason": "commands_wse3.sh launches no run.py"}

    work = Path(tempfile.mkdtemp(prefix="hwsim_"))
    bundle = Path(port_kernel_to_sdk210(str(kernel_dir), str(work / "bundle"))) \
        if port else kernel_dir
    vendor_benchmark_libs(bundle)

    # Several run.py files read "<name>/out.json" for the compile params. The
    # appliance compiler returns a tar.gz, not that directory, so synthesize it.
    run_argv = list(spec["runs"][0])
    # commands_wse3.sh lines look like `cs_python run.py --name out`, so the
    # parsed tokens still lead with the script name (sometimes `./run.py`).
    # The driver supplies argv[0] itself; leaving it here makes it an
    # unrecognized positional and argparse exits 2.
    if run_argv and run_argv[0].endswith(".py"):
        run_argv = run_argv[1:]
    name = "out"
    for i, tok in enumerate(run_argv):
        if tok in ("--name", "-n") and i + 1 < len(run_argv):
            name = run_argv[i + 1]
        elif tok.startswith("--name="):
            name = tok.split("=", 1)[1]
    for candidate in (bundle / name, bundle / f"{name}_code"):
        candidate.mkdir(parents=True, exist_ok=True)
        (candidate / "out.json").write_text(
            json.dumps({"params": spec["params"], "colors": {}}), encoding="utf-8")

    result: Dict[str, object] = {
        "kernel_dir": str(kernel_dir), "csl_main": spec["csl_main"],
        "params": spec["params"], "arms": {},
    }

    for arm in arms:
        simulator = (arm == "sim")
        try:
            artifact = compile_arm(bundle, spec["csl_main"],
                                   str(spec["cslc_args"]), simulator)
        except Exception as exc:  # cluster compile is the usual failure point
            result["arms"][arm] = {"status": "compile_fail",
                                   "reason": f"{type(exc).__name__}: {str(exc)[:300]}"}
            continue
        try:
            result["arms"][arm] = run_arm(bundle, artifact, simulator,
                                          run_argv, timeout_s,
                                          repeats=(repeats if not simulator else 1))
        except Exception as exc:
            result["arms"][arm] = {"status": "run_fail",
                                   "reason": f"{type(exc).__name__}: {str(exc)[:300]}"}

    # Record HOW the kernel was timed. A hardware number from a host-bracketed
    # timer measures RPC latency, not the device, so the aggregate must not
    # pool it with cleanly-timed kernels.
    contaminated = host_launched_timer(bundle)
    result["timing_method"] = "host_launched_tic_toc" if contaminated \
        else "device_internal"
    result["hw_comparable"] = not contaminated

    sim, hw = result["arms"].get("sim", {}), result["arms"].get("hw", {})
    if sim.get("status") == "pass" and hw.get("status") == "pass" \
            and sim.get("cycles_send") and hw.get("cycles_send"):
        ratio = hw["cycles_send"] / sim["cycles_send"]
        result["hw_vs_sim"] = {
            "sim_cycles": sim["cycles_send"], "hw_cycles": hw["cycles_send"],
            "ratio": round(ratio, 4), "delta_pct": round(100 * (ratio - 1), 2),
            "comparable": not contaminated,
            "caveat": None if not contaminated else (
                "timed window spans separate host launches (f_tic/f_toc); on the "
                "appliance this includes ~2 host RPCs (~488us each), so the "
                "hardware figure measures host latency rather than device time. "
                "The simulator figure is unaffected."),
        }
    return result


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--kernel", help="KERNEL_REGISTRY name")
    ap.add_argument("--kernel-dir", help="path to a CSL bundle directory")
    ap.add_argument("--arms", default="sim,hw",
                    help="comma-separated subset of sim,hw (default both)")
    ap.add_argument("--timeout", type=int, default=1800)
    ap.add_argument("--out", help="write the result JSON here")
    ap.add_argument("--no-port", action="store_true",
                    help="skip the SDK 2.10 mechanical port")
    args = ap.parse_args()

    if "cs_appliance_sdk" not in sys.executable:
        logger.warning("not running under the appliance venv; expected "
                       "~/cs_appliance_sdk/bin/python")

    sys.path.insert(0, str(REPO_ROOT / "code_translation"))

    if args.kernel_dir:
        kdir = Path(args.kernel_dir)
    elif args.kernel:
        import re as _re
        src = (REPO_ROOT / "code_translation" / "cuda2csl.py").read_text(encoding="utf-8")
        blk = src[src.index("KERNEL_REGISTRY = {"):]
        m = _re.search(rf'^\s{{4}}"{_re.escape(args.kernel)}":\s*_k\(\s*"([^"]+)"',
                       blk, _re.M)
        if not m:
            logger.error("kernel %s not found in KERNEL_REGISTRY", args.kernel)
            return 2
        kdir = REPO_ROOT / "kernels" / m.group(1) / "CSL"
    else:
        ap.error("one of --kernel or --kernel-dir is required")

    result = benchmark_kernel(kdir, [a.strip() for a in args.arms.split(",") if a.strip()],
                              args.timeout, port=not args.no_port)
    result["kernel"] = args.kernel or kdir.name

    text = json.dumps(result, indent=2)
    print(text)
    if args.out:
        Path(args.out).write_text(text, encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
