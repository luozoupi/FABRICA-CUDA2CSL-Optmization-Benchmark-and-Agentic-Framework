#!/usr/bin/env python3
"""MeshGEMM's checked run, host port to host port, verified packet by packet with payloads.

Wavelets are 32 bits. memcpy's 16-bit streams carry one value per packet (upper half
zero); the kernel's @mov16 transfers carry two (low half in `data`, high half in `index`).
Phases, in time order, and what is checked in each:
  input    host -> west halo (0,1) -> support column x=2 -> each row at x=3 -> row stream
           to x=7; PE px keeps packets px, px+4, ... : equals its X and W tiles
  skew     two transfers per PE in its row's direction: 1st = own loaded tile; 2nd = own
           again (row 0) or the tile just received (rows 1-3)
  steps    four transfers per PE per tensor, 128 packets each: the tile computed on that step
  compute  every FMA recomputed (from meshgemm_values.json)
  output   each PE's C tile east to x=8 (one value + one control packet per element),
           down x=8, out through the east halo (10,4)
Evidence: `simulator`, exact comparisons.
"""
import collections, gzip, json
from pathlib import Path

P, T = 4, 16
VAL = json.loads(Path("results/datapath/meshgemm_values.json").read_text())
V = VAL["tiles"]
send = json.loads(Path("results/datapath/meshgemm_steps.json").read_text())["ring_successor"]
recv = [send.index(p) for p in range(P)]
memX = lambda X: [X[m][k] for k in range(T) for m in range(T)]
memW = lambda W: [W[k][n] for k in range(T) for n in range(T)]
K = lambda x, y: 4 <= x <= 7 and 1 <= y <= 4

obs = collections.defaultdict(list); fm_first = None
with gzip.open("results/wse3-full/kernels/WaferLLM-MeshGEMM/events.jsonl.gz", "rt") as f:
    for line in f:
        if fm_first is None and '"FMACH"' in line and '"hwm_dispatch_trace_entry"' in line:
            fm_first = json.loads(line)["cycle"]
        if '"wavelet_trace_entry"' not in line: continue
        e = json.loads(line)
        if e["cycle"] > 62000: break
        s = e["coordinates"]["simulator"]
        obs[e["ident"]].append((e["cycle"], s["x"], s["y"], e["data"], e["index"], int(e["fields"]) & 31))
pk = []
for ob in obs.values():
    ob.sort(); path = []
    for _, x, y, *_ in ob:
        if not path or path[-1] != (x, y): path.append((x, y))
    pk.append({"t": ob[0][0], "t1": ob[-1][0], "path": path, "d": ob[0][3], "i": ob[0][4], "col": ob[0][5]})

out = {"phases": {}}
def span(sel): return [min(p["t"] for p in sel), max(p["t1"] for p in sel)] if sel else None

# ---------------- input
inp = [p for p in pk if p["col"] == 23 and p["t"] < fm_first and p["path"][0][0] == 3 and p["i"] == 0]
rowstream = collections.defaultdict(list)
for p in inp: rowstream[p["path"][0][1] - 1].append((p["t"], p["d"]))
loaded = {}
okx = okw = 0
steps = json.loads(Path("results/datapath/meshgemm_steps.json").read_text())["steps"]
Xblk = {tuple(steps[s][f"{px},{py}"]["x"]): V[f"{px},{py},{s}"]["X"] for s in range(P) for px in range(P) for py in range(P)}
for py in range(P):
    st = [d for _, d in sorted(rowstream[py])]
    for px in range(P):
        loaded[(px, py)] = st[:P*T*T][px::P]
        okx += loaded[(px, py)] == memX(Xblk[(py, px)])
        okw += st[P*T*T:2*P*T*T][px::P] == memW(V[f"{px},{py},0"]["W"])
entry = [p for p in pk if p["path"][0] == (0, 1) and p["t"] < fm_first]
fan = [p for p in pk if p["path"][0] == (1, 1) and len(p["path"]) >= 2 and p["path"][1] == (2, 1) and p["t"] < fm_first]
out["phases"]["input"] = {"cycles": span(entry + inp), "entry_packets_at_west_halo_0_1": len(entry),
    "support_column_packets": len(fan), "row_stream_values_per_row": len(inp) // P,
    "x_tiles_match": [okx, P*P], "w_tiles_match": [okw, P*P], "values_per_packet": 1}
# ---------------- skew
sk = [p for p in pk if p["col"] in (7, 8, 9, 12, 13, 16) and p["t"] < fm_first + 50 and K(*p["path"][0])]
src = collections.defaultdict(list)
for p in sk: src[(p["path"][0][0] - 4, p["path"][0][1] - 1)].append(p)
ok1 = ok2 = 0; dirs = {}
for (px, py), L in src.items():
    L.sort(key=lambda p: p["t"]); vals = [v for p in L for v in (p["d"], p["i"])]
    rev = py % 2 == 0
    ok1 += vals[:256] == loaded[(px, py)]
    want2 = loaded[(px, py)] if py == 0 else loaded[((send[px] if rev else recv[px]), py)]
    ok2 += vals[256:512] == want2
    dirs[py] = "backward (ring predecessor)" if rev else "forward (ring successor)"
out["phases"]["skew"] = {"cycles": span(sk), "packets": len(sk), "packets_per_pe": len(sk) // (P*P),
    "values_per_packet": 2, "transfers_per_pe": 2, "first_transfer_own_tile": [ok1, P*P],
    "second_transfer_predicted_tile": [ok2, P*P], "direction_by_row": dirs,
    "rotations_kept_by_row": {0: 0, 1: 1, 2: 1, 3: 2}}
# ---------------- steps
st_pk = [p for p in pk if p["col"] in (1, 2, 3, 4, 5, 6) and out["phases"]["skew"]["cycles"][0] <= p["t"] < 21000 and K(*p["path"][0])]
per = collections.defaultdict(list)
for p in st_pk: per[(p["path"][0][0] - 4, p["path"][0][1] - 1, "X" if p["col"] <= 3 else "W")].append(p)
okS = collections.Counter(); nS = collections.Counter(); hops = collections.Counter()
for (px, py, t), L in per.items():
    L.sort(key=lambda p: p["t"])
    for p in L: hops[(t, len(p["path"]) - 1)] += 1
    for s in range(P):
        ch = L[s*128:(s+1)*128]
        vals = [v for p in ch for v in (p["d"], p["i"])]
        want = memX(V[f"{px},{py},{s}"]["X"]) if t == "X" else memW(V[f"{px},{py},{s}"]["W"])
        nS[t] += 1; okS[t] += vals == want
out["phases"]["steps"] = {"cycles": span(st_pk), "packets": len(st_pk), "packets_per_transfer": 128,
    "values_per_packet": 2, "x_transfers_match": [okS["X"], nS["X"]], "w_transfers_match": [okS["W"], nS["W"]],
    "hops": {f"{t}{h}": n for (t, h), n in hops.items()}}
out["phases"]["compute"] = {"fma_bit_exact": VAL["checks"]["arithmetic"], "c_vs_xw_max_rel_err": VAL["checks"]["global_max_rel_err"]}
# ---------------- output
o = [p for p in pk if p["col"] == 21 and 19800 < p["t"] and K(*p["path"][0])]
okc = 0; osrc = collections.defaultdict(list)
for p in o: osrc[(p["path"][0][0] - 4, p["path"][0][1] - 1)].append(p)
for (px, py), L in osrc.items():
    L.sort(key=lambda p: p["t"]); d = [p["d"] for p in L if p["i"] == 0]
    C = V[f"{px},{py},{P-1}"]["C1"]
    okc += d[:T*T] == [C[m][n] for n in range(T) for m in range(T)]
ex = [p for p in pk if p["path"][-1] == (10, 4) and p["t"] > 19800 and p["col"] == 5]
Cvals = collections.Counter(V[f"{px},{py},{P-1}"]["C1"][m][n] for px in range(P) for py in range(P) for m in range(T) for n in range(T))
exv = collections.Counter(p["d"] for p in ex)
out["phases"]["output"] = {"cycles": span(o + ex), "kernel_packets": len(o),
    "data_packets_per_pe": T*T, "control_packets_per_pe": (len(o) - T*T*P*P) // (P*P),
    "c_tiles_match": [okc, P*P], "exit_packets_at_east_halo_10_4": len(ex),
    "exit_values_all_from_c": not (exv - Cvals), "exit_covers_every_c_value": not (Cvals - exv)}
Path("results/datapath/meshgemm_lifecycle.json").write_text(json.dumps(out, indent=1))
print(json.dumps(out, indent=1))
