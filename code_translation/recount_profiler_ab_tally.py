#!/usr/bin/env python3
"""Final corrected tally across all 46 kernels / 740 runs, under both classification rules."""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from recompute_v3 import scan, SWEEPS

ARMS = [("orig28_0708", "Original 28"), ("new14_0717", "New single-PE 14"), ("multipe_0718", "New multi-PE 4")]

def rule_strict(p, u):
    """Cycle compare iff both arms >=2 passes; everything else NoData."""
    pp, up = p.get("real_pass", 0), u.get("real_pass", 0)
    pm, um = p.get("real_med"), u.get("real_med")
    if pp < 2 or up < 2 or pm is None or um is None:
        return "NoData"
    d = 100.0 * (pm - um) / um
    return "Same" if abs(d) < 3 else ("Better" if d < 0 else "Worse")

def rule_inclusive(p, u):
    """Cycle compare iff both arms >=2 passes; else fall back to pass-rate; ties -> NoData."""
    v = rule_strict(p, u)
    if v != "NoData":
        return v
    pp, up = p.get("real_pass", 0), u.get("real_pass", 0)
    if pp == up:
        return "NoData"
    return "Better" if pp > up else "Worse"

grand = {"strict": {}, "inclusive": {}}
runs = {"prof": 0, "unprof": 0, "prof_n": 0, "unprof_n": 0}
rows = []
for key, label in ARMS:
    root, N = SWEEPS[key]
    data = scan(root)
    tS = {"Better": 0, "Worse": 0, "Same": 0, "NoData": 0}
    tI = dict(tS)
    for k, rec in data.items():
        p, u = rec.get("profiled", {}), rec.get("unprofiled", {})
        vs, vi = rule_strict(p, u), rule_inclusive(p, u)
        tS[vs] += 1
        tI[vi] += 1
        rows.append((label, k, p.get("real_pass", 0), p.get("nseed", 0), u.get("real_pass", 0),
                     u.get("nseed", 0), p.get("real_med"), u.get("real_med"), vs, vi))
        runs["prof"] += p.get("real_pass", 0); runs["prof_n"] += p.get("nseed", 0)
        runs["unprof"] += u.get("real_pass", 0); runs["unprof_n"] += u.get("nseed", 0)
    grand["strict"][label] = tS
    grand["inclusive"][label] = tI
    print(f"{label:<20} n={len(data):<3} strict B/W/S/ND = {tS['Better']}/{tS['Worse']}/{tS['Same']}/{tS['NoData']}"
          f"   inclusive = {tI['Better']}/{tI['Worse']}/{tI['Same']}/{tI['NoData']}")

for rule in ("strict", "inclusive"):
    t = {c: sum(grand[rule][l][c] for _, l in ARMS) for c in ("Better", "Worse", "Same", "NoData")}
    print(f"\nTOTAL 46 [{rule}]  Better={t['Better']}  Worse={t['Worse']}  Same={t['Same']}  NoData={t['NoData']}"
          f"  (sum={sum(t.values())})")

print(f"\nPASSING RUNS (correct semantics): profiled {runs['prof']}/{runs['prof_n']} "
      f"({100*runs['prof']/runs['prof_n']:.1f}%)  unprofiled {runs['unprof']}/{runs['unprof_n']} "
      f"({100*runs['unprof']/runs['unprof_n']:.1f}%)  total runs={runs['prof_n']+runs['unprof_n']}")

print("\n--- per-kernel (label, kernel, prof pass, unprof pass, prof med, unprof med, strict, inclusive) ---")
for r in rows:
    print(f"{r[0]:<18} {r[1]:<24} {r[2]}/{r[3]:<4} {r[4]}/{r[5]:<4} {str(r[6]):>12} {str(r[7]):>12}  {r[8]:<8} {r[9]:<8}")
