#!/usr/bin/env python3
"""Which kernels' reference programs pass on this machine's SDK (compile + simulate + verify + held-out)?

    python -m posttrain.reference_check --out results/posttrain_<date>/sdk_reference_check.json

Kernels whose own reference fails cannot give a meaningful reward; build_datasets --sdk-ok drops them.
"""
import argparse, json, sys, time
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from posttrain import common as C, csl_reward as R


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", required=True)
    ap.add_argument("--kernels", default="")
    a = ap.parse_args()
    out = Path(a.out)
    done = json.loads(out.read_text()) if out.exists() else {}
    names = [k for k in (a.kernels.split(",") if a.kernels else sorted(C.registry())) if k]
    for k in names:
        if k in done:
            continue
        reg = C.registry()[k]
        ref = C.REPO / "kernels" / reg["dir"] / "CSL"
        if not (ref / reg["target"]).is_file():
            done[k] = {"reward": None, "status": "no_reference"}
        else:
            t0 = time.time()
            r, info = R.score(C.csl_block((ref / reg["target"]).read_text()),
                              {"kernel": k, "reference_dir": f"kernels/{reg['dir']}/CSL", "target_relpath": reg["target"]}, level="run")
            done[k] = {"reward": r, "status": info.get("status"), "cycles": info.get("cycles"),
                       "reason": info.get("reason"), "heldout": info.get("heldout"), "elapsed_s": round(time.time() - t0, 1)}
        print(k, json.dumps(done[k]), flush=True)
        out.write_text(json.dumps(done, indent=1))
    ok = sorted(k for k, v in done.items() if (v.get("reward") or 0) >= 1.0)
    print(f"REFERENCE_CHECK_DONE {len(ok)}/{len(done)} pass", flush=True)


if __name__ == "__main__":
    main()
