#!/usr/bin/env python3
"""Replay already-generated agent artifacts on real WSE-3 hardware.

The agentic sweeps preserve the agent's final CSL compute file next to the
benchmark.json that scored it (e.g.
results/full_template_sweep_*/ReLU-1PE/run_*/ReLU-1PE/pe.csl). Combined with
the reference bundle -- which supplies layout.csl, run.py and
commands_wse3.sh -- that is a complete, runnable program.

So there is no need to re-run the agent to get hardware numbers: reconstruct
each bundle from the artifact the sweep already produced, then execute it on
both targets. Same source, two targets.

    bundle = copy(reference CSL dir) with agent's file overlaid at target_relpath

Each reconstructed bundle is handed to hw_vs_sim.benchmark_kernel(), which
ports it to SDK 2.10 once and then compiles+runs it BOTH ways through the same
appliance client, driven by the kernel's own run.py. The recorded sweep cycle
count is carried through as `sweep_sim_cycles` so three numbers are available
per kernel:

    sweep_sim_cycles  SDK 1.4.0 local simulator (what the paper reports)
    sim_cycles        SDK 2.10 appliance simulator, same bundle
    hw_cycles         real WSE-3 silicon, same bundle

sim_cycles vs hw_cycles isolates hardware-vs-simulator. sweep_sim_cycles vs
sim_cycles isolates the SDK-version + mechanical-port delta. Reporting only
hw vs sweep_sim -- which is what the July 2026 attempt did -- conflates them.

USAGE
    ~/cs_appliance_sdk/bin/python hw_replay.py --sweep results/full_template_sweep_20260722_192305
    ~/cs_appliance_sdk/bin/python hw_replay.py --sweep <dir> --only ReLU-1PE,SAXPY-1PE
"""

from __future__ import annotations

import argparse
import json
import logging
import shutil
import sys
import time
from pathlib import Path
from typing import Dict, List, Optional

logging.basicConfig(level=logging.INFO,
                    format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger("hw_replay")

REPO_ROOT = Path(__file__).resolve().parents[1]


def _kernel_name(bj: Path, sweep_dir: Path) -> str:
    """bundle_metadata.json's kernel when present, else the first path component."""
    meta = bj.parent / "bundle_metadata.json"
    try:
        k = json.loads(meta.read_text(encoding="utf-8")).get("kernel")
        if k:
            return str(k)
    except Exception:
        pass
    rel = bj.relative_to(sweep_dir).parts
    return rel[0] if rel else bj.parent.name


def _label(bj: Path, sweep_dir: Path) -> str:
    """Arm/seed path between the sweep root and the run dir (e.g. 'O1/seed_3'), '' for flat sweeps."""
    parts = list(bj.parent.relative_to(sweep_dir).parts)
    # drop kernel dir (first), run_* dir and the trailing kernel dir
    inner = [q for q in parts[1:] if not q.startswith("run_")]
    if inner and inner[-1] == parts[-1]:
        inner = inner[:-1]
    return "/".join(inner)


def harvest(sweep_dir: Path, versions: bool = False, include_failed: bool = False) -> List[Dict]:
    """Find every passing agent artifact in a sweep results tree.

    Handles both layouts, <sweep>/<kernel>/run_*/<kernel>/benchmark.json and
    <sweep>/<kernel>/<arm>/seed_<n>/run_*/<kernel>/benchmark.json. With
    ``versions`` every retained optimizer candidate under candidates/*/meta.json
    is added as its own entry (version = candidate label); by default only
    candidates that passed on the simulator are included.
    """
    found: List[Dict] = []
    for bj in sorted(sweep_dir.rglob("benchmark.json")):
        if "candidates" in bj.parts:
            continue
        try:
            d = json.loads(bj.read_text(encoding="utf-8"))
        except Exception:
            continue
        target = d.get("target_relpath")
        ref_dir = d.get("reference_dir")
        if not target or not ref_dir:
            continue
        kernel = _kernel_name(bj, sweep_dir)
        label = _label(bj, sweep_dir)
        passing = (d.get("status") == "pass" and d.get("success_marker")
                   and isinstance(d.get("cycles_send"), int))
        artifact = bj.parent / target
        if passing and artifact.is_file():
            found.append({
                "kernel": kernel, "label": label, "version": "final",
                "artifact": artifact, "target_relpath": target,
                "reference_dir": Path(ref_dir), "sweep_sim_cycles": d["cycles_send"],
                "commands_script": d.get("commands_script", "commands_wse3.sh"),
            })
        if versions:
            for mj in sorted((bj.parent / "candidates").glob("*/meta.json")):
                try:
                    m = json.loads(mj.read_text(encoding="utf-8"))
                except Exception:
                    continue
                code = mj.parent / (m.get("target_relpath") or target)
                if not code.is_file():
                    continue
                if not include_failed and (m.get("status") != "pass" or m.get("contract_violation")):
                    continue
                found.append({
                    "kernel": kernel, "label": label, "version": mj.parent.name,
                    "artifact": code, "target_relpath": m.get("target_relpath") or target,
                    "reference_dir": Path(m.get("reference_dir") or ref_dir),
                    "sweep_sim_cycles": m.get("cycles_send"),
                    "commands_script": m.get("commands_script") or d.get("commands_script", "commands_wse3.sh"),
                    "accepted": bool(m.get("accepted")), "attempt": m.get("attempt"), "angle": m.get("angle"),
                    # silicon-model prediction recorded at benchmark time (fidelity study)
                    "predicted_cycles": m.get("predicted_cycles"), "model_class": m.get("model_class"),
                })
    return found


def reconstruct_bundle(entry: Dict, dest_root: Path) -> Optional[Path]:
    """reference bundle + agent's compute file overlaid at target_relpath."""
    ref = entry["reference_dir"]
    if not ref.is_dir():
        logger.warning("[%s] reference dir missing: %s", entry["kernel"], ref)
        return None

    suffix = "__".join(x for x in (entry.get("label", ""), entry.get("version", "")) if x and x != "final")
    dest = dest_root / (entry["kernel"] + (f"__{suffix.replace('/', '_')}" if suffix else ""))
    if dest.exists():
        shutil.rmtree(dest)
    # Skip prior build output; the appliance compiler produces its own.
    shutil.copytree(ref, dest,
                    ignore=shutil.ignore_patterns("out", "out_*", "*.elf",
                                                  "simfab_traces", "sim.log",
                                                  "bin", "wsjob-*.json"))

    tgt = dest / entry["target_relpath"]
    tgt.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(entry["artifact"], tgt)
    logger.info("[%s] bundle at %s (agent file -> %s)",
                entry["kernel"], dest, entry["target_relpath"])
    return dest


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--sweep", required=True, help="sweep results directory")
    ap.add_argument("--only", help="comma-separated kernel allowlist")
    ap.add_argument("--arms", default="sim,hw")
    ap.add_argument("--timeout", type=int, default=1800)
    ap.add_argument("--out", help="write aggregate JSON here")
    ap.add_argument("--workdir", default=None,
                    help="where to build bundles (default: a temp dir)")
    ap.add_argument("--list", action="store_true",
                    help="only list what would be replayed, then exit")
    ap.add_argument("--repeats", type=int, default=1,
                    help="run each compiled bundle this many times on hardware "
                         "(median reported; per-run values kept)")
    ap.add_argument("--versions", action="store_true",
                    help="also replay every retained optimizer candidate "
                         "(candidates/*/meta.json written under XKERNEL_KEEP_CANDIDATES)")
    ap.add_argument("--include-failed", action="store_true",
                    help="with --versions, include candidates that failed on the simulator")
    ap.add_argument("--reference", action="store_true",
                    help="replay the UNMODIFIED reference bundles instead of the "
                         "agent artifacts. Needed to state a beats-expert ratio "
                         "on hardware: the recorded speedups divide agent cycles "
                         "by a SIMULATOR reference, so both halves have to be "
                         "measured on the same target before the ratio means "
                         "anything on silicon.")
    args = ap.parse_args()

    if "cs_appliance_sdk" not in sys.executable and not args.list:
        logger.warning("not running under the appliance venv; expected "
                       "~/cs_appliance_sdk/bin/python")

    sys.path.insert(0, str(REPO_ROOT / "code_translation"))

    sweep = Path(args.sweep)
    if not sweep.is_absolute():
        sweep = REPO_ROOT / "code_translation" / "results" / sweep.name \
            if not sweep.exists() else sweep.resolve()

    entries = harvest(sweep, versions=args.versions, include_failed=args.include_failed)
    if args.only:
        allow = {k.strip() for k in args.only.split(",")}
        entries = [e for e in entries if e["kernel"] in allow]

    logger.info("harvested %d passing agent artifacts from %s", len(entries), sweep)
    if args.list:
        for e in entries:
            print(f"{e['kernel']:<26} {e.get('label', ''):<14} {e.get('version', 'final'):<28} "
                  f"sweep_sim={str(e['sweep_sim_cycles']):<9} target={e['target_relpath']}")
        return 0
    if not entries:
        logger.error("nothing to replay")
        return 1

    import tempfile
    from hw_vs_sim import benchmark_kernel

    work = Path(args.workdir) if args.workdir else Path(tempfile.mkdtemp(prefix="hwreplay_"))
    work.mkdir(parents=True, exist_ok=True)
    arms = [a.strip() for a in args.arms.split(",") if a.strip()]

    out_path = Path(args.out) if args.out else \
        (REPO_ROOT / "code_translation" / "results" /
         f"hw_replay_{time.strftime('%Y%m%d_%H%M%S')}.json")
    results: List[Dict] = []

    for i, entry in enumerate(entries, 1):
        logger.info("=== [%d/%d] %s%s ===", i, len(entries), entry["kernel"],
                    " (reference)" if args.reference else "")
        if args.reference:
            # Reference arm: the human-written bundle, untouched. Same kernel
            # set and same two targets, so the numbers line up 1:1 with the
            # agent-artifact pass.
            bundle = entry["reference_dir"] if entry["reference_dir"].is_dir() else None
        else:
            bundle = reconstruct_bundle(entry, work)
        if bundle is None:
            results.append({"kernel": entry["kernel"], "status": "skip",
                            "reason": "reference bundle missing"})
        else:
            try:
                r = benchmark_kernel(bundle, arms, args.timeout, port=True,
                                     repeats=max(1, int(args.repeats)))
            except Exception as exc:
                r = {"status": "driver_error",
                     "reason": f"{type(exc).__name__}: {str(exc)[:300]}"}
            r["kernel"] = entry["kernel"]
            r["label"] = entry.get("label", "")
            r["version"] = entry.get("version", "final")
            for extra in ("accepted", "attempt", "angle", "predicted_cycles", "model_class"):
                if extra in entry:
                    r[extra] = entry[extra]
            r["sweep_sim_cycles"] = entry["sweep_sim_cycles"]
            r["agent_artifact"] = str(entry["artifact"])

            # sweep_sim_cycles is the AGENT's recorded number. Comparing it to
            # this pass's simulator result is only a port delta when this pass
            # ran the agent's bundle. On the reference pass the two sides are
            # different programs, so the quotient is the speedup, not a port
            # delta -- computing it here would mislabel it.
            sim = (r.get("arms") or {}).get("sim", {})
            if (not args.reference and sim.get("status") == "pass"
                    and sim.get("cycles_send") and entry.get("sweep_sim_cycles")):
                ratio = sim["cycles_send"] / entry["sweep_sim_cycles"]
                r["sdk210_vs_sdk140"] = {"ratio": round(ratio, 4),
                                         "delta_pct": round(100 * (ratio - 1), 2)}
            r["pass_kind"] = "reference" if args.reference else "agent_artifact"
            results.append(r)

        # Write incrementally: a long cluster run should not lose everything
        # if it is interrupted partway.
        out_path.write_text(json.dumps(results, indent=2), encoding="utf-8")

    logger.info("wrote %s", out_path)

    print("\n" + "=" * 92)
    print(f"{'kernel':<26}{'sweep_sim':>10}{'sim_2.10':>10}{'hw':>10}"
          f"{'hw/sim':>9}  status")
    print("=" * 92)
    for r in results:
        k = r.get("kernel", "?")
        sweep_c = r.get("sweep_sim_cycles", "-")
        arms_d = r.get("arms") or {}
        sim_c = (arms_d.get("sim") or {}).get("cycles_send") or "-"
        hw_c = (arms_d.get("hw") or {}).get("cycles_send") or "-"
        cmp_ = r.get("hw_vs_sim") or {}
        ratio = f"{cmp_['ratio']:.3f}" if cmp_ else "-"
        st = []
        for a in ("sim", "hw"):
            s = (arms_d.get(a) or {}).get("status")
            if s and s != "pass":
                st.append(f"{a}:{s}")
        print(f"{k:<26}{str(sweep_c):>10}{str(sim_c):>10}{str(hw_c):>10}"
              f"{ratio:>9}  {','.join(st) or 'ok'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
