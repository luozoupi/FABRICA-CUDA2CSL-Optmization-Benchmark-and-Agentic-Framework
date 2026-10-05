#!/usr/bin/env python3
"""CS-3 replay of the NVIDIA node's distributed SpGEMM fixtures (studies/spgemm-scaling-20260924):
each bundle = the frozen case files + the study's compile line + a run.py wrapper around the
unchanged host.py. Appliance simulator and silicon through hw_vs_sim.benchmark_kernel; results
written incrementally. Run under ~/cs_appliance_sdk/bin/python on the usn node."""
import argparse, json, sys, time
from pathlib import Path
REPO = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO / "code_translation"))
from hw_vs_sim import benchmark_kernel

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--bundles", required=True); ap.add_argument("--out", required=True)
    ap.add_argument("--arms", default="sim,hw"); ap.add_argument("--timeout", type=int, default=3600)
    a = ap.parse_args()
    rows = []
    for b in sorted(Path(a.bundles).iterdir()):
        if not (b / "commands_wse3.sh").is_file(): continue
        t0 = time.time(); print("==", b.name, flush=True)
        # One arm at a time so each arm's raw observations.json (per-PE timestamps, hashes)
        # is kept: the frozen host.py always writes the same file name. port=False: the
        # fixtures are 2.10-native and the mechanical port rewrites typed params, which
        # host.py's source-hash check refuses (recorded attempt: hw_spgemm_dist.port_attempt_failed.json).
        r = {"kernel_dir": str(b), "arms": {}}
        for arm in a.arms.split(","):
            one = benchmark_kernel(b, [arm], a.timeout, port=False, repeats=1)
            r["arms"][arm] = one["arms"].get(arm, {})
            for k in ("csl_main", "params", "timing_method", "hw_comparable"):
                r[k] = one.get(k)
            obs = b / "observations.json"
            if obs.is_file():
                obs.rename(b / f"observations.{arm}.json")
        sim, hw = r["arms"].get("sim", {}), r["arms"].get("hw", {})
        if sim.get("cycles_send") and hw.get("cycles_send"):
            r["hw_vs_sim"] = {"sim_cycles": sim["cycles_send"], "hw_cycles": hw["cycles_send"], "ratio": round(hw["cycles_send"] / sim["cycles_send"], 4)}
        r["case"] = b.name; r["wall_s"] = round(time.time() - t0, 1)
        sim, hw = r["arms"].get("sim", {}), r["arms"].get("hw", {})
        print(f"   sim={sim.get('cycles_send')} ({sim.get('status')}) hw={hw.get('cycles_send')} ({hw.get('status')}) ratio={(r.get('hw_vs_sim') or {}).get('ratio')}", flush=True)
        rows.append(r); Path(a.out).write_text(json.dumps(rows, indent=2))
    print("HW_DIST_DONE", flush=True)

if __name__ == "__main__":
    main()
