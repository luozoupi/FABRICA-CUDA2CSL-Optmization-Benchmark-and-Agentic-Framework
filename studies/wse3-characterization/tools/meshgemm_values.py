#!/usr/bin/env python3
"""Real tile values for MeshGEMM, per PE and per step, out of the simulator trace, and two
independent checks that they are what the algorithm says they are.

Every FMACH lane record carries operand values: element m of src1 is X[m,k], src2 is the
broadcast scalar W[k,n], src0 is C[m,n] before the update and dest is C[m,n] after it. A
run of 16 FMACHs sharing src1 is one k; 16 runs are one step; 4 steps are one repeat.
This keeps the LAST repeat on each PE.

Checks:
  arithmetic  C_after is recomputed from C_before, X and W with the fused single rounding
              FMACH uses, in the traced order, and compared bit for bit.
  movement    the X tile a PE uses at step s+1 must be bit-identical to the X tile its
              ring predecessor used at step s (it was shifted), likewise W down columns.
Evidence: values `simulator`; the checks are exact comparisons.
"""
from __future__ import annotations
import collections, gzip, json, struct
from pathlib import Path

P, T = 4, 16
PES = [(px, py) for py in range(P) for px in range(P)]
f16 = lambda u: struct.unpack('<e', struct.pack('<H', u & 0xFFFF))[0]
def rnd(x):
    try: return struct.unpack('<H', struct.pack('<e', x))[0]
    except OverflowError: return 0x7C00 if x > 0 else 0xFC00

def main():
    path = "results/wse3-full/kernels/WaferLLM-MeshGEMM/events.jsonl.gz"
    # pass 1: FMACH dispatch cycles per kernel PE, to find the last repeat
    cyc = collections.defaultdict(list)
    with gzip.open(path, "rt") as f:
        for line in f:
            if '"FMACH"' not in line: continue
            e = json.loads(line)
            if e.get("_type") != "hwm_dispatch_trace_entry" or e.get("ut_id") != 255: continue
            s = e["coordinates"]["simulator"]; pe = (s["x"] - 4, s["y"] - 1)
            if pe in PES: cyc[pe].append(e["cycle"])
    per_rep = P * T * T
    # Repeat 1 is the run the host reads back (memcpy_d2h res) and checks against X.W.
    srt = {pe: sorted(v) for pe, v in cyc.items()}
    lo = {pe: v[0] for pe, v in srt.items()}
    hi = {pe: v[per_rep - 1] for pe, v in srt.items()}
    reps = {pe: len(v) / per_rep for pe, v in cyc.items()}
    print("FMACHs per PE / per repeat:", sorted(set(reps.values())), "repeats")
    # pass 2: lane records of the last repeat's FMACHs
    disp = {}; lanes = collections.defaultdict(dict)
    with gzip.open(path, "rt") as f:
        for line in f:
            if '"hwm_' not in line: continue
            e = json.loads(line); s = (e.get("coordinates") or {}).get("simulator")
            if not s: continue
            pe = (s["x"] - 4, s["y"] - 1)
            if pe not in lo or e["cycle"] < lo[pe] - 10 or e["cycle"] > hi[pe] + 60: continue
            if e["_type"] == "hwm_dispatch_trace_entry":
                if e["name"] == "FMACH" and e.get("ut_id") == 255 and lo[pe] <= e["cycle"] <= hi[pe]:
                    disp[(pe, e["uid"])] = e["cycle"]
            elif e["_type"] == "hwm_pipe_trace_entry" and e.get("simdi") not in (None, 255):
                k = (pe, e["uid"])
                if k in disp:
                    lanes[k][e["data"]] = (e["src0"] & 0xFFFF, e["src1"] & 0xFFFF,
                                           e["src2"] & 0xFFFF, e["dest"] & 0xFFFF)
    tiles = {}
    arith_ok = arith_n = 0
    for pe in PES:
        seq = sorted((c, k) for k, c in disp.items() if k[0] == pe)
        assert len(seq) == per_rep, (pe, len(seq))
        for s in range(P):
            X = [[0] * T for _ in range(T)]; W = [[0] * T for _ in range(T)]
            C0 = [[0] * T for _ in range(T)]; C1 = [[0] * T for _ in range(T)]
            block = seq[s * T * T:(s + 1) * T * T]
            cur = [[None] * T for _ in range(T)]       # running C (bits) for recompute
            for kk in range(T):
                for n in range(T):
                    rec = lanes[block[kk * T + n][1]]
                    assert len(rec) == T, (pe, s, kk, n, len(rec))
                    W[kk][n] = rec[0][2]
                    for m in range(T):
                        s0, s1, s2, d = rec[m]
                        X[m][kk] = s1
                        if kk == 0: C0[m][n] = s0
                        if kk == T - 1: C1[m][n] = d
                        prev = C0[m][n] if kk == 0 else cur[m][n]
                        cur[m][n] = rnd(f16(prev) + f16(s1) * f16(s2))   # fused: one rounding
                        arith_n += 1; arith_ok += (cur[m][n] == d)
            tiles[f"{pe[0]},{pe[1]},{s}"] = {"X": X, "W": W, "C0": C0, "C1": C1}
    # movement check: X shifts along the row ring, W along the column ring
    send = json.loads(Path("results/datapath/meshgemm_steps.json").read_text())["ring_successor"]
    mx = mw = mt = 0
    for (px, py) in PES:
        for s in range(P - 1):
            a = tiles[f"{px},{py},{s}"]
            mt += 1
            mx += tiles[f"{send[px]},{py},{s+1}"]["X"] == a["X"]
            mw += tiles[f"{px},{send[py]},{s+1}"]["W"] == a["W"]
    print(f"arithmetic: {arith_ok}/{arith_n} FMA results reproduced bit for bit (fused rounding)")
    print(f"movement:   X tile arrives unchanged at the row successor     {mx}/{mt}")
    print(f"            W tile arrives unchanged at the column successor  {mw}/{mt}")
    # label check: the block indices the diagram shows (from the verified reconstruction)
    # must name the same data wherever they appear, and C must equal X.W globally
    steps = json.loads(Path("results/datapath/meshgemm_steps.json").read_text())["steps"]
    Xblk, Wblk, lab_ok, lab_n = {}, {}, 0, 0
    for (px, py) in PES:
        for s_ in range(P):
            q = steps[s_][f"{px},{py}"]; t = tiles[f"{px},{py},{s_}"]
            for key, blk, val in ((tuple(q["x"]), Xblk, t["X"]), (tuple(q["w"]), Wblk, t["W"])):
                lab_n += 1
                if key in blk: lab_ok += blk[key] == val
                else: blk[key] = val; lab_ok += 1
    gmax = 0.0; gn = 0
    for (px, py) in PES:
        Cf = tiles[f"{px},{py},{P-1}"]["C1"]
        for m in range(T):
            for n in range(T):
                ref = sum(f16(Xblk[(py, k)][m][kk]) * f16(Wblk[(k, px)][kk][n])
                          for k in range(P) for kk in range(T))
                gmax = max(gmax, abs(f16(Cf[m][n]) - ref) / max(1.0, abs(ref))); gn += 1
    print(f"labels:     block labels consistent with the data  {lab_ok}/{lab_n}; "
          f"{len(Xblk)} distinct X blocks, {len(Wblk)} distinct W blocks")
    print(f"global:     C vs X.W rebuilt from traced tiles, {gn} elements, max relative error {gmax:.2e} (f16)")
    zero = all(v == 0 for pe in PES for r in tiles[f"{pe[0]},{pe[1]},0"]["C0"] for v in r)
    print(f"C is zero before step 1 on every PE: {zero}")
    out = {"P": P, "T": T, "repeat": "1 of " + str(int(max(reps.values()))) + " (the run the host checks)",
           "encoding": "IEEE f16 bit patterns", "checks": {
               "arithmetic": [arith_ok, arith_n], "x_movement": [mx, mt], "w_movement": [mw, mt],
               "c_zero_at_start": zero, "labels": [lab_ok, lab_n],
               "global_max_rel_err": gmax, "global_elements": gn}, "tiles": tiles}
    Path("results/datapath/meshgemm_values.json").write_text(json.dumps(out))
    print("-> results/datapath/meshgemm_values.json",
          round(Path("results/datapath/meshgemm_values.json").stat().st_size / 1e6, 2), "MB")

if __name__ == "__main__":
    main()
