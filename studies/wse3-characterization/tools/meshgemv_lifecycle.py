#!/usr/bin/env python3
"""MeshGEMV's first run, host port to host port, verified with payloads (see
meshgemm_lifecycle.py for the conventions). Input: each row stream carries the row's x
slice and W tiles; output: each PE sends its column's final y east, out through (10,4)."""
import collections, gzip, json
from pathlib import Path

P, T = 4, 16
R = json.loads(Path("results/datapath/meshgemv_values.json").read_text())
pes, fin = R["pes"], {int(k): v for k, v in R["final"].items()}
K = lambda x, y: 4 <= x <= 7 and 1 <= y <= 4
obs = collections.defaultdict(list); fm_first = None
with gzip.open("results/wse3-full/kernels/WaferLLM-MeshGEMV/events.jsonl.gz", "rt") as f:
    for line in f:
        if fm_first is None and '"FMACH"' in line and '"hwm_dispatch_trace_entry"' in line:
            fm_first = json.loads(line)["cycle"]
        if '"wavelet_trace_entry"' not in line: continue
        e = json.loads(line); s = e["coordinates"]["simulator"]
        obs[e["ident"]].append((e["cycle"], s["x"], s["y"], e["data"], e["index"], int(e["fields"]) & 31))
pk = []
for ob in obs.values():
    ob.sort(); path = []
    for _, x, y, *_ in ob:
        if not path or path[-1] != (x, y): path.append((x, y))
    pk.append({"t": ob[0][0], "t1": ob[-1][0], "path": path, "d": ob[0][3], "i": ob[0][4], "col": ob[0][5]})
span = lambda sel: [min(p["t"] for p in sel), max(p["t1"] for p in sel)] if sel else None
out = {"first_fmach": fm_first, "phases": {}}
inp = [p for p in pk if p["col"] == 23 and p["t"] < fm_first and p["path"][0][0] == 3 and p["i"] == 0]
rs = collections.defaultdict(list)
for p in inp: rs[p["path"][0][1] - 1].append((p["t"], p["d"]))
okx = okw = 0
for py in range(P):
    st = [d for _, d in sorted(rs[py])]
    for px in range(P):
        me = pes[f"{px},{py}"]
        okx += st[:P*T][px::P] == me["x"]
        okw += st[P*T:P*T + P*T*T][px::P] == [me["W"][k][n] for k in range(T) for n in range(T)]
entry = [p for p in pk if p["path"][0] == (0, 1) and p["t"] < fm_first]
out["phases"]["input"] = {"cycles": span(entry + inp), "entry_packets_at_west_halo_0_1": len(entry),
    "row_stream_values_per_row": len(inp) // P, "x_slices_match": [okx, P*P], "w_tiles_match": [okw, P*P],
    "values_per_packet": 1}
o = [p for p in pk if p["col"] == 21 and p["t"] > fm_first and K(*p["path"][0])]
src = collections.defaultdict(list)
for p in o: src[(p["path"][0][0] - 4, p["path"][0][1] - 1)].append(p)
oky = 0
for (px, py), L in src.items():
    L.sort(key=lambda p: p["t"]); oky += [p["d"] for p in L if p["i"] == 0][:T] == fin[px]
first_out = min(p["t"] for p in o)
ex = [p for p in pk if p["path"][-1] == (10, 4) and p["col"] == 5 and p["t"] >= first_out - 50]
yv = collections.Counter(v for px in range(P) for py in range(P) for v in fin[px])
exv = collections.Counter(p["d"] for p in ex)
out["phases"]["output"] = {"cycles": span(o + ex), "kernel_packets": len(o), "y_match": [oky, P*P],
    "exit_packets_at_east_halo_10_4": len(ex), "exit_values_all_from_y": not (exv - yv),
    "exit_covers_every_y_value": not (yv - exv)}
out["checks"] = R["checks"]
Path("results/datapath/meshgemv_lifecycle.json").write_text(json.dumps(out, indent=1))
print(json.dumps(out["phases"], indent=1))
