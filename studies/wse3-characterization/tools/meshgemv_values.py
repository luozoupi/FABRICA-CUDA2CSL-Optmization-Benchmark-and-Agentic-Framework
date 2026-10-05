#!/usr/bin/env python3
"""Real values for MeshGEMV's first run, per PE, and checks that the reduce and the
broadcast carry exactly what the algorithm says.

Per PE: 16 FMACHs, FMACH k computing y += W[k,:] * x[k] (src1 = W row k, src2 = x[k]).
After them, rows 1 and 3 run FADDH with a fabric operand (the stage-1 and stage-2
reduce), and the other rows receive the final y (the broadcast).

Checks:
  arithmetic  every FMACH and FADDH result recomputed bit for bit (single rounding)
  reduce      the operand each FADDH receives equals, bit for bit, the partial its
              neighbour produced
  broadcast   the value every row ends with equals row 3's final sum
  global      y against x.W rebuilt from the traced W tiles and x slices
Evidence: values `simulator`; the checks are exact comparisons.
"""
import collections, gzip, json, struct
from pathlib import Path

P, T = 4, 16
f16 = lambda u: struct.unpack('<e', struct.pack('<H', u & 0xFFFF))[0]
def rnd(x):
    try: return struct.unpack('<H', struct.pack('<e', x))[0]
    except OverflowError: return 0x7C00 if x > 0 else 0xFC00

def main():
    path = "results/wse3-full/kernels/WaferLLM-MeshGEMV/events.jsonl.gz"
    ev = collections.defaultdict(list)            # pe -> [(cycle, uid, name, nd)]
    lanes = collections.defaultdict(dict)         # (pe, uid) -> {elem: (s0,s1,s2,d)}
    with gzip.open(path, "rt") as f:
        for line in f:
            if '"hwm_' not in line: continue
            e = json.loads(line); s = (e.get("coordinates") or {}).get("simulator")
            if not s: continue
            pe = (s["x"] - 4, s["y"] - 1)
            if not (0 <= pe[0] < P and 0 <= pe[1] < P) or e["cycle"] > 9000: continue
            if e["_type"] == "hwm_dispatch_trace_entry":
                ev[pe].append((e["cycle"], e["uid"], e["name"], e.get("num_data"), e.get("ut_id")))
            elif e["_type"] == "hwm_pipe_trace_entry" and e.get("simdi") not in (None, 255):
                lanes[(pe, e["uid"])][e["data"]] = (e["src0"] & 0xFFFF, e["src1"] & 0xFFFF,
                                                    e["src2"] & 0xFFFF, e["dest"] & 0xFFFF)
    res = {}; ar_ok = ar_n = 0
    for pe, seq in ev.items():
        seq.sort()
        fm = [x for x in seq if x[2] == "FMACH" and x[4] == 255]
        run, nxt = fm[:T], (fm[T][0] if len(fm) > T else 10**9)
        W = []; x = []; y = [0] * T
        for i, (c, uid, _, _, _) in enumerate(run):
            rec = lanes[(pe, uid)]
            W.append([rec[m][1] for m in range(T)]); x.append(rec[0][2])
            for m in range(T):
                s0, s1, s2, d = rec[m]
                ar_n += 1; ar_ok += rnd(f16(s0) + f16(s1) * f16(s2)) == d
                y[m] = d
        adds = []
        for (c, uid, name, nd, ut) in seq:
            if run[-1][0] < c < nxt and name == "FADDH":
                rec = lanes.get((pe, uid), {})
                if len(rec) == T:
                    # FADDH takes the fabric operand in src0 and the PE's own vector in src1
                    adds.append({"cycle": c, "received": [rec[m][0] for m in range(T)],
                                 "own": [rec[m][1] for m in range(T)],
                                 "sum": [rec[m][3] for m in range(T)]})
                    for m in range(T):
                        ar_n += 1; ar_ok += rnd(f16(rec[m][0]) + f16(rec[m][1])) == rec[m][3]
        res[pe] = {"W": W, "x": x, "partial": y, "adds": adds, "end": run[-1][0], "next": nxt}
    # reduce / broadcast checks, column by column
    red_ok = red_n = 0; bc = {}
    for px in range(P):
        c = {py: res[(px, py)] for py in range(P)}
        # stage 1: row 1 receives row 0's partial; row 3 receives row 2's partial
        # stage 2: row 3 receives row 1's stage-1 sum
        exp = [(1, 0, lambda: c[0]["partial"]), (3, 0, lambda: c[2]["partial"]),
               (3, 1, lambda: c[1]["adds"][0]["sum"] if c[1]["adds"] else None)]
        own = [(1, 0, lambda: c[1]["partial"]), (3, 0, lambda: c[3]["partial"]),
               (3, 1, lambda: c[3]["adds"][0]["sum"] if c[3]["adds"] else None)]
        for (row, idx, src), (_, _, mine) in zip(exp, own):
            red_n += 1
            a = c[row]["adds"][idx] if len(c[row]["adds"]) > idx else None
            red_ok += a is not None and a["received"] == src() and a["own"] == mine()
        final = c[3]["adds"][-1]["sum"] if c[3]["adds"] else None
        bc[px] = final
    # broadcast: the other rows must end holding row 3's final sum; find it in their later ops
    got_bc = 0
    for px in range(P):
        for py in (0, 1, 2):
            seq = [lanes.get(((px, py), uid), {}) for (cc, uid, nm, nd, ut) in ev[(px, py)]
                   if res[(px, py)]["end"] < cc < res[(px, py)]["next"] and nm.startswith("FMOV16")]
            vals = [[r[m][3] for m in range(T)] for r in seq if len(r) == T]
            got_bc += bc[px] in vals
    # global: y(px) = sum over py of x(py) . W(py,px)
    gmax = 0.0
    for px in range(P):
        for n in range(T):
            ref = sum(f16(res[(px, py)]["x"][k]) * f16(res[(px, py)]["W"][k][n])
                      for py in range(P) for k in range(T))
            gmax = max(gmax, abs(f16(bc[px][n]) - ref) / max(1.0, abs(ref)))
    print(f"arithmetic: {ar_ok}/{ar_n} FMACH and FADDH results reproduced bit for bit")
    print(f"reduce:     {red_ok}/{red_n} adds whose received operand is the neighbour's value AND own operand is its own, bit for bit")
    print(f"broadcast:  {got_bc}/{3*P} non-final rows end holding row 3's final y exactly")
    print(f"global:     y vs x.W rebuilt from traced tiles, max relative error {gmax:.2e}")
    out = {"P": P, "T": T, "run": "first", "checks": {"arithmetic": [ar_ok, ar_n], "reduce": [red_ok, red_n],
           "broadcast": [got_bc, 3 * P], "global_max_rel_err": gmax},
           "pes": {f"{k[0]},{k[1]}": v for k, v in res.items()}, "final": {str(k): v for k, v in bc.items()}}
    Path("results/datapath/meshgemv_values.json").write_text(json.dumps(out))
    print("-> results/datapath/meshgemv_values.json")

if __name__ == "__main__":
    main()
