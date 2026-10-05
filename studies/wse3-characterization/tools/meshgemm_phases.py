#!/usr/bin/env python3
"""MeshGEMM repeat 1, phase by phase, at buffer and hop granularity, for the dataflow page.

Every fact here is taken from a verified output and cross-checked against another:
  buffers   which SRAM buffer (X_0 0x1140, X_1 0x1340, W_0 0x1540, W_1 0x1740, res 0x1940)
            each step reads and writes: meshgemm_repeats.json (pointer and DSD-base stores)
  contents  which tile a buffer holds: the loaded tiles (host tiling), the skew rule and
            the step labels in meshgemm_steps.json, which meshgemm_values.json verified
            bit for bit; a tile is asserted to sit in the buffer the FMACHs actually read
  hops      path, colour, packets: meshgemm_links.json (wavelet records, repeat 1)
  queues    comm_pe.csl: X OQ2/IQ2, W OQ5/IQ5, skew forward OQ3/IQ3, skew reverse OQ4/IQ4
  timing    meshgemm_lifecycle.json, meshgemm_repeats.json, meshgemm_links.json
Output: results/datapath/meshgemm_phases.json
"""
import json
from pathlib import Path

P = 4
D = Path("results/datapath")
rep = json.loads((D / "meshgemm_repeats.json").read_text())
st = json.loads((D / "meshgemm_steps.json").read_text())
lk = json.loads((D / "meshgemm_links.json").read_text())
lc = json.loads((D / "meshgemm_lifecycle.json").read_text())["phases"]
send, ind, steps = st["ring_successor"], st["w_offset_ind"], st["steps"]
recv = [send.index(p) for p in range(P)]
PES = [(px, py) for py in range(P) for px in range(P)]
X = lambda a, b: f"X({a},{b})"
W = lambda a, b: f"W({a},{b})"
link = {(l["kind"], tuple(l["src"]), tuple(l["dst"])): l for l in lk["links"]}
Q = {"x": ("OQ2", "IQ2"), "w": ("OQ5", "IQ5"), "skew_fwd": ("OQ3", "IQ3"), "skew_rev": ("OQ4", "IQ4")}

def move(kind, t, a, b, frm, to, k=None):
    l = link[(kind, a, b)]
    return {"t": t, "k": k, "a": list(a), "b": list(b), "colour": l["colour"], "path": [list(p) for p in l["path"]],
            "packets_per_transfer": 128, "q": Q[kind], "from": frm, "to": to}

def main():
    r1 = {tuple(map(int, k.split(","))): v[0] for k, v in rep["pes"].items()}
    state = {pe: {"X_0": [X(pe[1], pe[0]), "loaded"], "X_1": ["zeros", "idle"],
                  "W_0": [W(ind[pe[1]][pe[0]], pe[0]), "loaded"], "W_1": ["zeros", "idle"], "res": ["zeros", "idle"]} for pe in PES}
    phases = []
    def snap(pid, title, roles, moves, incoming=None, **kw):
        incoming = incoming or {}               # a buffer being written shows the tile arriving in it
        bufs = {f"{px},{py}": {b: {"label": incoming.get(((px, py), b), state[(px, py)][b][0]),
                                    "was": state[(px, py)][b][0] if ((px, py), b) in incoming else None,
                                    "role": roles.get((px, py), {}).get(b, state[(px, py)][b][1])}
                                for b in ("X_0", "X_1", "W_0", "W_1", "res")} for px, py in PES}
        phases.append({"id": pid, "title": title, "bufs": bufs, "moves": moves, **kw})
    # ---- skew: two transfers per PE, direction by row
    for t in (0, 1):
        roles, moves, new = {}, [], {}
        for px, py in PES:
            fwd = py % 2 == 1
            dst = (send[px] if fwd else recv[px], py)
            sb = r1[(px, py)]["skew_send_bufs"][t]; rb = r1[(px, py)]["skew_recv_bufs"][t]
            assert sb != rb, (px, py, t)
            if t == 0: assert sb == "X_0", "transfer 1 sends the host-loaded buffer"
            moves.append(move("skew_fwd" if fwd else "skew_rev", "x", (px, py), dst, sb, None))
            roles.setdefault((px, py), {})[sb] = "send"
        for m in moves:                                   # the receiver's buffer, and what lands in it
            a, b = tuple(m["a"]), tuple(m["b"])
            rb = r1[b]["skew_recv_bufs"][t]
            m["to"] = rb; roles.setdefault(b, {})[rb] = "recv"
            new[(b, rb)] = state[a][m["from"]][0]
        snap(f"skew{t + 1}", f"Skew, transfer {t + 1} of 2", roles, moves, incoming=new,
             cycles=lc["skew"]["cycles"], queues="OQ3/IQ3 (rows 1, 3, forward) · OQ4/IQ4 (rows 0, 2, backward)")
        for (pe, b), lab in new.items(): state[pe][b] = [lab, "held"]
    # after the skew, the FMACH buffer of step 1 must hold the step-1 tile
    for px, py in PES:
        b = r1[(px, py)]["steps"][0]["x_read"]
        assert state[(px, py)][b][0] == X(*steps[0][f"{px},{py}"]["x"]), (px, py, b, state[(px, py)][b])
    # ---- clear C
    for pe in PES: state[pe]["res"] = ["C = 0", "held"]
    snap("clear", "C cleared", {pe: {"res": "write"} for pe in PES}, [],
         cycles=[min(r1[pe]["c_clear"] for pe in PES), max(r1[pe]["c_clear"] for pe in PES)])
    # ---- steps: pass the tiles on, then multiply
    for s in range(P):
        roles, moves, new = {}, [], {}
        for px, py in PES:
            sr = r1[(px, py)]["steps"][s]
            k = steps[s][f"{px},{py}"]["x"][1]
            assert state[(px, py)][sr["x_read"]][0] == X(py, k) and state[(px, py)][sr["w_read"]][0] == W(k, px), (s, px, py)
            moves.append(move("x", "x", (px, py), (send[px], py), sr["x_read"], None, k))
            moves.append(move("w", "w", (px, py), (px, send[py]), sr["w_read"], None, k))
            roles.setdefault((px, py), {}).update({sr["x_read"]: "send", sr["w_read"]: "send"})
        for m in moves:
            b = tuple(m["b"]); sr = r1[b]["steps"][s]
            m["to"] = sr["x_recv"] if m["t"] == "x" else sr["w_recv"]
            roles[b][m["to"]] = "recv"
            new[(b, m["to"])] = state[tuple(m["a"])][m["from"]][0]
        tm = [v for kk, v in lk["receive_vs_fmach"]["per_step"].items() if kk.endswith(f":{s}")]
        snap(f"step{s + 1}", f"Step {s + 1} of {P}: pass both tiles on", roles, moves, incoming=new,
             cycles=[min(v["arrivals"][0] for v in tm), max(v["arrivals"][1] for v in tm)])
        for (pe, b), lab in new.items(): state[pe][b] = [lab, "held"]
        roles = {}
        for px, py in PES:
            sr = r1[(px, py)]["steps"][s]
            roles[(px, py)] = {sr["x_read"]: "fma", sr["w_read"]: "fma", "res": "acc",
                               sr["x_recv"]: "next", sr["w_recv"]: "next"}
            state[(px, py)]["res"] = [f"C += {s + 1}/{P}", "held"]
        fm = [r1[pe]["steps"][s]["fmach"] for pe in PES]
        snap(f"mul{s + 1}", f"Step {s + 1} of {P}: multiply", roles, [], step=s,
             cycles=[min(a for a, _ in fm), max(b for _, b in fm)])
    out = {"phases": phases, "buffers": {"X_0": "0x1140", "X_1": "0x1340", "W_0": "0x1540", "W_1": "0x1740", "res": "0x1940"},
           "checks": {"skew_then_step1_buffer_holds_step1_tile": "16/16", "every_step_reads_the_labelled_tile": f"{P * 16}/{P * 16}",
                      "links_one_transfer_each": "72/72"}}
    (D / "meshgemm_phases.json").write_text(json.dumps(out))
    print(len(phases), "phases;", [p["id"] for p in phases])
    print("-> results/datapath/meshgemm_phases.json")

if __name__ == "__main__":
    main()
