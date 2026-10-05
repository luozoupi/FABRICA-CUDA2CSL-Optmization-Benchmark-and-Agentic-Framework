#!/usr/bin/env python3
"""Hardware replay of the sparse suite's REFERENCE bundles (HW-S0 smoke, HW-S1 references).

`hw_replay.py` replays agent artifacts harvested from a sweep; the sparse study also needs
the reference programs themselves on the CS-3, per size. This driver hands each
`kernels/<Task>/CSL` bundle to `hw_vs_sim.benchmark_kernel` (port to SDK 2.10 once, compile
on the appliance, run the kernel's own run.py through hw_sim_shim on the appliance simulator
and on silicon, `repeats` batched trials). For a size other than `small` the bundle is copied
and its `commands_wse3_<size>.sh` becomes `commands_wse3.sh`, which is what the tool reads.

    ~/cs_appliance_sdk/bin/python code_translation/hw_sparse_refs.py --kernels RowScale-CSR,SpMV-RowBlock \
        --sizes small --arms sim,hw --repeats 3 --out code_translation/results/hw_sparse_smoke_<date>.json

Rows carry the SDK 2.10 local-simulator reference from spec.yaml (`spec_sim_cycles`) next to the
appliance simulator and hardware numbers. Results are written incrementally.
"""
from __future__ import annotations

import argparse
import json
import logging
import shutil
import sys
import tempfile
import time
from pathlib import Path

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger("hw_sparse_refs")
REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO_ROOT / "code_translation"))


def spec_sizes(kernel: str):
    """{size_name: (commands_script, spec_sim_cycles)} from spec.yaml (yaml optional)."""
    p = REPO_ROOT / "kernels" / kernel / "spec.yaml"
    try:
        import yaml
        spec = yaml.safe_load(p.read_text()) or {}
    except Exception:
        return {"small": ("commands_wse3.sh", None)}
    out = {}
    for s in spec.get("sizes") or []:
        ref = (s.get("wse3_reference") or {}).get("cycles_send")
        out[s["name"]] = (s.get("commands_script") or "commands_wse3.sh", ref)
    return out or {"small": ("commands_wse3.sh", None)}


def bundle_for(kernel: str, size: str, script: str, work: Path) -> Path:
    src = REPO_ROOT / "kernels" / kernel / "CSL"
    if script == "commands_wse3.sh":
        return src
    dst = work / f"{kernel}__{size}"
    if dst.exists():
        shutil.rmtree(dst)
    shutil.copytree(src, dst)
    shutil.copyfile(dst / script, dst / "commands_wse3.sh")
    return dst


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--kernels", default=None, help="comma list (default: task set S)")
    ap.add_argument("--sizes", default="small", help="comma list of size names, or 'all'")
    ap.add_argument("--arms", default="sim,hw")
    ap.add_argument("--repeats", type=int, default=3)
    ap.add_argument("--timeout", type=int, default=1800)
    ap.add_argument("--out", default=None)
    ap.add_argument("--workdir", default=None)
    a = ap.parse_args()
    if "cs_appliance_sdk" not in sys.executable:
        logger.warning("not running under the appliance venv (~/cs_appliance_sdk/bin/python)")
    if a.kernels:
        kernels = [k.strip() for k in a.kernels.split(",") if k.strip()]
    else:
        from task_sets import S
        kernels = list(S)
    from hw_vs_sim import benchmark_kernel
    arms = [x.strip() for x in a.arms.split(",") if x.strip()]
    work = Path(a.workdir) if a.workdir else Path(tempfile.mkdtemp(prefix="hwsparse_", dir=str(REPO_ROOT / "code_translation" / "sandbox")))
    work.mkdir(parents=True, exist_ok=True)
    out_path = Path(a.out) if a.out else REPO_ROOT / "code_translation" / "results" / f"hw_sparse_refs_{time.strftime('%Y%m%d_%H%M%S')}.json"
    results = []
    jobs = []
    for k in kernels:
        sizes = spec_sizes(k)
        wanted = list(sizes) if a.sizes == "all" else [s.strip() for s in a.sizes.split(",") if s.strip() in sizes]
        for s in wanted:
            jobs.append((k, s) + sizes[s])
    logger.info("%d bundle(s): %s", len(jobs), [(k, s) for k, s, _, _ in jobs])
    for i, (k, s, script, ref) in enumerate(jobs, 1):
        logger.info("=== [%d/%d] %s [%s] (%s) ===", i, len(jobs), k, s, script)
        t0 = time.time()
        try:
            bundle = bundle_for(k, s, script, work)
            r = benchmark_kernel(bundle, arms, a.timeout, port=True, repeats=max(1, a.repeats))
        except Exception as exc:
            r = {"status": "driver_error", "reason": f"{type(exc).__name__}: {str(exc)[:300]}"}
        r.update({"kernel": k, "size": s, "commands_script": script, "spec_sim_cycles": ref,
                  "pass_kind": "reference", "elapsed_s": round(time.time() - t0, 1)})
        sim = (r.get("arms") or {}).get("sim") or {}
        if ref and sim.get("cycles_send"):
            r["appliance_sim_vs_local_sim"] = round(sim["cycles_send"] / ref, 4)
        results.append(r)
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(json.dumps(results, indent=2), encoding="utf-8")
        hw = (r.get("arms") or {}).get("hw") or {}
        logger.info("    sim(appliance)=%s hw=%s spec_local_sim=%s status=%s %s", sim.get("cycles_send"), hw.get("cycles_send"), ref,
                    r.get("status"), (r.get("reason") or "")[:120])
    logger.info("wrote %s", out_path)
    print(f"\n{'kernel':<20}{'size':<8}{'local_sim':>10}{'sim_2.10':>10}{'hw':>10}{'hw/sim':>8}  status")
    for r in results:
        arms_d = r.get("arms") or {}
        sim_c = (arms_d.get("sim") or {}).get("cycles_send") or "-"; hw_c = (arms_d.get("hw") or {}).get("cycles_send") or "-"
        ratio = f"{hw_c / sim_c:.3f}" if isinstance(sim_c, int) and isinstance(hw_c, int) and sim_c else "-"
        print(f"{r['kernel']:<20}{r['size']:<8}{str(r.get('spec_sim_cycles') or '-'):>10}{str(sim_c):>10}{str(hw_c):>10}{ratio:>8}  {r.get('status')} {(r.get('reason') or '')[:60]}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
