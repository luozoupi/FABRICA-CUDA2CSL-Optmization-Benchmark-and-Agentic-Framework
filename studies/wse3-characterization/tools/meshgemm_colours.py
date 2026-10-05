#!/usr/bin/env python3
"""MeshGEMM: how X and W become tiles, wavelets and colours, and a hand-checkable toy.

1. Colour plan. comm_layout.csl `get_params(px, py)` gives every PE a send, receive and
   transit colour from three-colour interleaves (px % 3 / py % 3); layout.csl binds
   X = colours 1,2,3  W = 4,5,6  X skew reverse = 7,8,9  X skew forward = 12,13,16.
   Ported here line for line, then checked against every traced transfer: the packet's
   colour must equal the sender's send colour, each transit router's transit colour and
   the receiver's receive colour.
2. Colour census over the whole trace: packets per colour and routers seen per packet.
3. Toy: 4 x 4 integer matrices on the same 4 x 4 mesh (1 x 1 tiles). The block schedule
   (which k each PE multiplies at each step) is the one verified from the trace in
   meshgemm_steps.json, so the toy runs the real schedule with numbers small enough to
   check by hand. Asserted: the toy's C equals X.W exactly.
Evidence: `source` (plan), `simulator` (census, check), exact integer arithmetic (toy).
"""
import collections, gzip, json
from pathlib import Path

P = 4
X_I, W_I, SR_I, SF_I = [1, 2, 3], [4, 5, 6], [7, 8, 9], [12, 13, 16]

def get_params(px, py):                      # comm_layout.csl, P even
    px3, py3 = px % 3, py % 3
    xr, xs, xt = X_I[0], X_I[1], X_I[2]
    fr, fs, ft = SF_I[0], SF_I[1], SF_I[2]
    rs, rr, rt = SR_I[0], SR_I[1], SR_I[2]
    if px == 0: xr, xs, fr, fs, rs, rr = X_I[0], X_I[1], SF_I[0], SF_I[1], SR_I[0], SR_I[1]
    elif px == P - 1:
        xt, ft, rt = X_I[(px + 1) % 3], SF_I[(px + 1) % 3], SR_I[(px + 1) % 3]
        xr, xs = X_I[px3], X_I[(px - 1) % 3]; fr, fs = SF_I[px3], SF_I[(px - 1) % 3]; rs, rr = SR_I[px3], SR_I[(px - 1) % 3]
    else:
        xt, ft, rt = X_I[px3], SF_I[px3], SR_I[px3]
        if px % 2 == 0:
            xs, xr = X_I[(px + 1) % 3], X_I[(px - 1) % 3]; fs, fr = SF_I[(px + 1) % 3], SF_I[(px - 1) % 3]; rr, rs = SR_I[(px + 1) % 3], SR_I[(px - 1) % 3]
        else:
            xs, xr = X_I[(px - 1) % 3], X_I[(px + 1) % 3]; fs, fr = SF_I[(px - 1) % 3], SF_I[(px + 1) % 3]; rr, rs = SR_I[(px - 1) % 3], SR_I[(px + 1) % 3]
    yr, ys, yt = W_I[0], W_I[1], W_I[2]
    if py == 0: yr, ys = W_I[0], W_I[1]
    elif py == P - 1: yr, ys = W_I[py3], W_I[(py - 1) % 3]
    else:
        yt = W_I[py3]
        if py % 2 == 0: ys, yr = W_I[(py + 1) % 3], W_I[(py - 1) % 3]
        else: ys, yr = W_I[(py - 1) % 3], W_I[(py + 1) % 3]
    return {"x": {"send": xs, "recv": xr, "tran": xt}, "w": {"send": ys, "recv": yr, "tran": yt},
            "skew_fwd": {"send": fs, "recv": fr, "tran": ft}, "skew_rev": {"send": rs, "recv": rr, "tran": rt}}

def main():
    plan = {f"{px},{py}": get_params(px, py) for py in range(P) for px in range(P)}
    links = json.loads(Path("results/datapath/meshgemm_links.json").read_text())["links"]
    ok = n = 0; bad = []
    for l in links:
        path = [tuple(p) for p in l["path"]]; k = l["kind"]
        want = [plan[f"{path[0][0]},{path[0][1]}"][k]["send"], plan[f"{path[-1][0]},{path[-1][1]}"][k]["recv"]] + \
               [plan[f"{p[0]},{p[1]}"][k]["tran"] for p in path[1:-1]]
        n += 1; good = all(c == l["colour"] for c in want); ok += good
        if not good: bad.append((k, path, l["colour"], want))
    print(f"colour plan (ported get_params) matches traced colours: {ok}/{n}", bad[:3])
    # census over the whole run
    obs = collections.defaultdict(set); col = {}
    with gzip.open("results/wse3-full/kernels/WaferLLM-MeshGEMM/events.jsonl.gz", "rt") as f:
        for line in f:
            if '"wavelet_trace_entry"' not in line: continue
            e = json.loads(line); s = e["coordinates"]["simulator"]
            obs[e["ident"]].add((s["x"], s["y"])); col[e["ident"]] = int(e["fields"]) & 31
    census = collections.defaultdict(lambda: {"packets": 0, "routers_per_packet": collections.Counter(), "kernel_only": True})
    for ident, pes in obs.items():
        c = census[col[ident]]; c["packets"] += 1; c["routers_per_packet"][len(pes)] += 1
        if not all(4 <= x <= 7 and 1 <= y <= 4 for x, y in pes): c["kernel_only"] = False
    census = {c: {"packets": v["packets"], "routers_per_packet": dict(sorted(v["routers_per_packet"].items())), "kernel_only": v["kernel_only"]}
              for c, v in sorted(census.items())}
    print("colours seen:", {c: v["packets"] for c, v in census.items()})
    # toy: 4 x 4 integers, real block schedule
    steps = json.loads(Path("results/datapath/meshgemm_steps.json").read_text())
    send, ind, st = steps["ring_successor"], steps["w_offset_ind"], steps["steps"]
    X = [[1, 2, 0, 1], [0, 1, 2, 1], [2, 0, 1, 0], [1, 1, 0, 2]]
    W = [[1, 0, 2, 1], [0, 1, 1, 0], [1, 2, 0, 1], [2, 1, 0, 1]]
    ref = [[sum(X[i][k] * W[k][j] for k in range(P)) for j in range(P)] for i in range(P)]
    C = [[0] * P for _ in range(P)]
    frames = [{"id": "load", "pes": {f"{px},{py}": {"x": [py, px], "w": [ind[py][px], px], "c": 0} for py in range(P) for px in range(P)}}]
    for s in range(P):
        pes = {}
        for py in range(P):
            for px in range(P):
                i, k = st[s][f"{px},{py}"]["x"]; k2, j = st[s][f"{px},{py}"]["w"]
                assert i == py and j == px and k == k2, "a PE multiplies matched blocks of its own row and column"
                C[py][px] += X[py][k] * W[k][px]
                pes[f"{px},{py}"] = {"x": [py, k], "w": [k, px], "term": X[py][k] * W[k][px], "c": C[py][px]}
        frames.append({"id": f"step{s + 1}", "pes": pes})
    assert C == ref, (C, ref)
    # every X block visits every PE of its row once, every W block every PE of its column once
    for py in range(P):
        for k in range(P):
            assert sorted(px for s in range(P) for px in range(P) if st[s][f"{px},{py}"]["x"][1] == k) == list(range(P))
    print("toy: C == X.W exactly;", ref)
    out = {"plan": plan, "plan_check": [ok, n], "census": census,
           "toy": {"X": X, "W": W, "C": ref, "send": send, "ind": ind, "frames": frames}}
    Path("results/datapath/meshgemm_colours.json").write_text(json.dumps(out))
    print("-> results/datapath/meshgemm_colours.json")

if __name__ == "__main__":
    main()
