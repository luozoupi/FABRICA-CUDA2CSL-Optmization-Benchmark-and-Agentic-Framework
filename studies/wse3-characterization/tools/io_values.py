#!/usr/bin/env python3
"""Verify the end-to-end lifecycle of MeshGEMM's checked run with real payloads.

The wavelet `data` field is the 16-bit payload. So:
  input   the colour-23 stream entering each kernel row interleaves the row's four PEs
          element by element; each PE's share must equal, bit for bit, the X and W tiles
          it later computes with (X as loaded, before the skew; W as used in step 1)
  output  each PE's colour-21 data packets must equal its final C tile, in memory order
  exit    what leaves through the east-edge port, compared to the C values
Evidence: `simulator`, exact comparisons.
"""
import collections, gzip, json, struct
from pathlib import Path

P, T = 4, 16
V = json.loads(Path("results/datapath/meshgemm_values.json").read_text())["tiles"]
steps = json.loads(Path("results/datapath/meshgemm_steps.json").read_text())["steps"]
# X block (py,k) content, from the validated labels
Xblk = {}
for py in range(P):
    for px in range(P):
        for s in range(P):
            q = steps[s][f"{px},{py}"]; Xblk[tuple(q["x"])] = V[f"{px},{py},{s}"]["X"]

row_in = collections.defaultdict(list)      # kernel row -> stream as seen at its first kernel PE
pe_out = collections.defaultdict(list)      # kernel PE -> packets it injected on colour 21
exit_pk = []; first_obs = {}
with gzip.open("results/wse3-full/kernels/WaferLLM-MeshGEMM/events.jsonl.gz", "rt") as f:
    for line in f:
        if '"wavelet_trace_entry"' not in line: continue
        e = json.loads(line); s = e["coordinates"]["simulator"]; x, y = s["x"], s["y"]
        col = int(e["fields"]) & 0x1F; c = e["cycle"]; ident = int(e["ident"])
        if col == 23 and x == 4 and 1 <= y <= 4 and c < 10000:
            row_in[y - 1].append((c, e["index"], e["data"]))
        if col == 21 and 19800 < c < 36000 and 4 <= x <= 7 and 1 <= y <= 4:
            if ident not in first_obs:
                first_obs[ident] = (x, y)
                pe_out[(x - 4, y - 1)].append((c, e["index"], e["data"]))
        if x == 10 and y == 4 and 19800 < c < 60000:
            exit_pk.append((c, e["index"], e["data"], col))
# ---- input
ok_x = ok_w = 0; idx_in = collections.Counter()
for py in range(P):
    st = sorted(row_in[py]); idx_in.update(i for _, i, _ in st)
    data = [d for _, i, d in st if i == 0]
    xs, ws = data[:P * T * T], data[P * T * T:2 * P * T * T]
    for px in range(P):
        mine_x = xs[px::P]; mine_w = ws[px::P]
        # X_0_tile is k-major: element k*T + m is X[m,k]; W tile is k-major rows: k*T + n
        want_x = [Xblk[(py, px)][m][k] for k in range(T) for m in range(T)]
        want_w = [V[f"{px},{py},0"]["W"][k][n] for k in range(T) for n in range(T)]
        ok_x += mine_x == want_x; ok_w += mine_w == want_w
print(f"input:  index values in the row streams {dict(idx_in)}")
print(f"        X tile as loaded matches the PE's share of its row stream: {ok_x}/{P*P}")
print(f"        W tile as loaded matches the PE's share of its row stream: {ok_w}/{P*P}")
# ---- output
ok_c = 0; idx_out = collections.Counter(); ctrl = collections.Counter()
for (px, py), pk in pe_out.items():
    pk.sort(); idx_out.update(i for _, i, _ in pk)
    data = [d for _, i, d in pk if i == 0]
    C = V[f"{px},{py},{P-1}"]["C1"]
    want = [C[m][n] for n in range(T) for m in range(T)]        # res_tile[n*Mt + m]
    ok_c += data[:T * T] == want
    ctrl.update((i, d) for _, i, d in pk if i != 0)
print(f"output: index values {dict(idx_out)}; non-data packets {dict(ctrl.most_common(3))}")
print(f"        C tile leaves each PE in memory order, bit for bit: {ok_c}/{P*P}")
# ---- exit
Cvals = {V[f"{px},{py},{P-1}"]["C1"][m][n] for px in range(P) for py in range(P) for m in range(T) for n in range(T)}
ex = collections.Counter(); hits_d = hits_i = 0
for c, i, d, col in exit_pk:
    ex[col] += 1; hits_d += d in Cvals; hits_i += i in Cvals
print(f"exit:   {len(exit_pk)} packets at the east halo (10,4) by colour {dict(ex)}; "
      f"data field is a C value in {hits_d}, index field is a C value in {hits_i}")
out = {"input": {"x_match": [ok_x, P*P], "w_match": [ok_w, P*P], "index_values": dict(idx_in),
                 "interleave": "element-major, PE-minor: PE px keeps packets px, px+4, px+8, ..."},
       "output": {"c_match": [ok_c, P*P], "index_values": dict(idx_out),
                  "control_packets": [[list(k), n] for k, n in ctrl.most_common(3)]},
       "exit": {"packets": len(exit_pk), "by_colour": dict(ex), "data_is_c": hits_d, "index_is_c": hits_i}}
Path("results/datapath/io_values.json").write_text(json.dumps(out, indent=1))
print("-> results/datapath/io_values.json")
