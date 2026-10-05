#!/usr/bin/env python3
"""Recompute profiler A/B with CORRECT pass semantics (success_marker) vs the
sweep's as-published semantics (cycles_send present in newest benchmark.json)."""
import json, glob, os, statistics, sys
from collections import OrderedDict

BASE = "/home/USER/xkernel/code_translation/results"
SWEEPS = {
    "orig28_0708": (f"{BASE}/profiler_ab_full_20260708_214657", 10),
    "orig28_0706": (f"{BASE}/profiler_ab_full_20260706_172841", 10),
    "new14_0717":  (f"{BASE}/new_kernels_ab_20260717_213018", 5),
    "new14_0716":  (f"{BASE}/new_kernels_ab_20260716_040724", 5),
    "multipe_0718":(f"{BASE}/multi_pe_ab_20260718_225502", 5),
}

def seed_metrics(seed_dir):
    """Return dict with:
       real_pass   : any attempt with success_marker True
       real_cycles : min cycles among success_marker-True attempts
       pub_cycles  : cycles_send from newest run_*/*/benchmark.json (what the sweep logged)
    """
    out = {"real_pass": False, "real_cycles": None, "pub_cycles": None}
    # as-published extraction, mirroring _cyc() in run_profiler_ab_full.sh
    bjs = sorted(glob.glob(os.path.join(seed_dir, "run_*", "*", "benchmark.json")),
                 key=lambda p: os.path.getmtime(p), reverse=True)
    if bjs:
        try:
            c = json.load(open(bjs[0])).get("cycles_send")
            if isinstance(c, int):
                out["pub_cycles"] = c
        except Exception:
            pass
    for fr in glob.glob(os.path.join(seed_dir, "**", "final_result.json"), recursive=True):
        try:
            d = json.load(open(fr))
        except Exception:
            continue
        for a in d.get("attempts", []):
            if a.get("success_marker") is True and a.get("status") == "pass":
                out["real_pass"] = True
                c = a.get("cycles_send")
                if isinstance(c, int) and (out["real_cycles"] is None or c < out["real_cycles"]):
                    out["real_cycles"] = c
    return out

def scan(root):
    res = OrderedDict()
    for k in sorted(os.listdir(root)):
        kd = os.path.join(root, k)
        if not os.path.isdir(kd):
            continue
        rec = {}
        for arm in ("profiled", "unprofiled"):
            ad = os.path.join(kd, arm)
            if not os.path.isdir(ad):
                continue
            real_vals, pub_vals, nseed = [], [], 0
            for s in sorted(os.listdir(ad)):
                sd = os.path.join(ad, s)
                if not os.path.isdir(sd):
                    continue
                nseed += 1
                m = seed_metrics(sd)
                if m["real_pass"] and m["real_cycles"] is not None:
                    real_vals.append(m["real_cycles"])
                elif m["real_pass"]:
                    real_vals.append(None)          # passed but no cycle number
                if m["pub_cycles"] is not None:
                    pub_vals.append(m["pub_cycles"])
            rv = [v for v in real_vals if v is not None]
            rec[arm] = dict(nseed=nseed,
                            real_pass=len(real_vals), real_vals=sorted(rv),
                            real_med=(statistics.median(rv) if rv else None),
                            pub_pass=len(pub_vals), pub_vals=sorted(pub_vals),
                            pub_med=(statistics.median(pub_vals) if pub_vals else None))
        if rec:
            res[k] = rec
    return res

def verdict(pmed, umed, ppass, upass, minpass=2):
    if ppass < minpass or upass < minpass or pmed is None or umed is None:
        return "NoData", None
    d = 100.0 * (pmed - umed) / umed
    if abs(d) < 3:
        return "Same", d
    return ("Better" if d < 0 else "Worse"), d

if __name__ == "__main__":
    for name in (sys.argv[1:] or list(SWEEPS)):
        root, N = SWEEPS[name]
        data = scan(root)
        print(f"\n{'='*118}\n{name}  N={N}  ({os.path.basename(root)})\n{'='*118}")
        print(f"{'kernel':<24} | {'REAL pass p/u':<14} {'REAL med p/u':<22} {'verdict':<8} | "
              f"{'PUB pass p/u':<14} {'PUB med p/u':<22} {'verdict':<8}")
        tR = {"Better":0,"Worse":0,"Same":0,"NoData":0}
        tP = {"Better":0,"Worse":0,"Same":0,"NoData":0}
        for k, rec in data.items():
            p, u = rec.get("profiled", {}), rec.get("unprofiled", {})
            vr, dr = verdict(p.get("real_med"), u.get("real_med"), p.get("real_pass",0), u.get("real_pass",0))
            vp, dp = verdict(p.get("pub_med"),  u.get("pub_med"),  p.get("pub_pass",0),  u.get("pub_pass",0))
            tR[vr]+=1; tP[vp]+=1
            fmt = lambda a,b: f"{a}/{b}"
            print(f"{k:<24} | "
                  f"{fmt(p.get('real_pass'),u.get('real_pass')):<14} "
                  f"{str(p.get('real_med'))+' / '+str(u.get('real_med')):<22} {vr:<8} | "
                  f"{fmt(p.get('pub_pass'),u.get('pub_pass')):<14} "
                  f"{str(p.get('pub_med'))+' / '+str(u.get('pub_med')):<22} {vp:<8}")
        print(f"\n  n={len(data)}")
        print(f"  REAL (success_marker): B={tR['Better']} W={tR['Worse']} S={tR['Same']} ND={tR['NoData']}")
        print(f"  PUB  (cycles present): B={tP['Better']} W={tP['Worse']} S={tP['Same']} ND={tP['NoData']}")
        tot_real_p = sum(r.get('profiled',{}).get('real_pass',0) for r in data.values())
        tot_real_u = sum(r.get('unprofiled',{}).get('real_pass',0) for r in data.values())
        tot_pub_p  = sum(r.get('profiled',{}).get('pub_pass',0) for r in data.values())
        tot_pub_u  = sum(r.get('unprofiled',{}).get('pub_pass',0) for r in data.values())
        print(f"  TOTAL passing runs  REAL prof={tot_real_p} unprof={tot_real_u} | PUB prof={tot_pub_p} unprof={tot_pub_u}")
