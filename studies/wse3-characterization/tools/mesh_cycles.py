#!/usr/bin/env python3
"""MeshGEMM as a per-cycle, per-PE timeline for the merged single-panel animation: which X and W tile sits on
each PE at every cycle, how long it has been there, what it is doing, and what C looks like at that cycle.

Generic in the tile size T (= Mt = Kt = Nt) and P = 4. Inputs: a traced run directory with events.jsonl.gz,
result.json (the host's X, W, ind, C) and disasm_out_*.json, e.g. microbench/mesh_small/run (T = 2, one repeat)
or the WaferLLM 16 x 16 run (T = 16, repeat 1 of 7).

From the trace alone:
  tiles      per PE per step, the X and W tiles the FMACHs read (lane operands) and C before/after; each is
             identified against the host's blocks (X(py,k), W(k,px)) and must match bit for bit
  residency  per PE, for every tile that was ever on it: arrived (last wavelet of the transfer, or the host's
             last word), computed [first, last FMACH], sent [first, last wavelet out], overwritten (first wavelet
             of the transfer that lands in the same buffer), so a counter "cycles here" can be drawn
  links      per tile and physical hop: envelope [first upstream, last downstream arrival), packets, hop index,
             plus the host-in / host-out streams per PE as envelopes from/to the edge
  compute    FMACH span per step per PE, the C clear
  cvals      (small runs only) every C element update: cycle, PE, m, n, value, from the FMACH dest lanes
  ops        same-tag dispatch runs per PE, function from the ELF symbols
Evidence: `simulator` (trace), `compiled` (symbols); exact comparisons. Output: results/datapath/<name>_cycles.json
"""
from __future__ import annotations
import collections, gzip, json, struct, sys
from pathlib import Path

STUDY = Path(__file__).resolve().parents[1]
P = 4
KIND = {1: "x", 2: "x", 3: "x", 4: "w", 5: "w", 6: "w", 7: "sr", 8: "sr", 9: "sr", 12: "sf", 13: "sf", 16: "sf"}
f16 = lambda u: struct.unpack('<e', struct.pack('<H', u & 0xFFFF))[0]
TX_DSR = {"dds2", "dds3", "dds4", "dds5"}; RX_DSR = {"s1ds2", "s1ds3", "s1ds4", "s1ds5"}
K = lambda x, y: 4 <= x <= 7 and 1 <= y <= 4

def functions(elf):
    b = elf.read_bytes(); E = "<"
    shoff = struct.unpack_from(E + "Q", b, 0x28)[0]; shentsize, shnum, _ = struct.unpack_from(E + "HHH", b, 0x3A)
    secs = [struct.unpack_from(E + "IIQQQQIIQQ", b, shoff + i * shentsize) for i in range(shnum)]
    out = []
    for s in secs:
        if s[1] == 2:
            st = secs[s[6]]
            for j in range(s[5] // 24):
                n, info, oth, shn, val, sz = struct.unpack_from(E + "IBBHQQ", b, s[4] + j * 24)
                if (info & 0xF) == 2 and sz > 0: out.append((val, val + sz, b[st[4] + n:b.index(b"\0", st[4] + n)].decode().replace("sys_mod.sys_mod.", "memcpy.")))
    return sorted(out)

def tag_of(name, ut, nd, asm, fn, T):
    if name == "FMACH": return "FMAC"
    if fn.startswith("memcpy."): return "MEMCPY"
    if ut != 255 and name.startswith(("IMOV", "FMOV")):
        a = asm.replace(" ", "")
        if any(f"[{d}]=" in a for d in TX_DSR): return "ASYNC TX"
        if any(f"=[{s}]" in a for s in RX_DSR): return "ASYNC RX"
        return "ASYNC"
    if name == "FMOV16.NF" and nd >= T * T: return "CLEAR C"
    if "ds" in asm.split("=")[0] and name.startswith(("LD", "ST", "MOV")): return "COMM DSD"
    if name in ("JMP", "SETJT", "BLK", "UBLK", "NOP") or name.startswith(("LT", "EQ", "GT")): return "CTRL"
    if name.startswith(("ADD", "SLL", "SLR", "MOVRI", "LD16", "ST16", "AND", "OR", "SUB")): return "ADDR"
    return "OTHER"

def main(run, name, T, repeat_1_only, keep_cvals):
    run = Path(run); R = json.loads((run / "result.json").read_text())
    X, W, ind = R["X"], R["W"], R["ind"]
    steps = json.loads((STUDY / "results/datapath/meshgemm_steps.json").read_text())
    send = steps["ring_successor"]; recv = [send.index(p) for p in range(P)]
    blk = lambda M, i, j: [[M[i * T + a][j * T + b] for b in range(T)] for a in range(T)]
    PES = [(px, py) for py in range(P) for px in range(P)]
    fns = {pe: functions(run / "out/bin" / f"out_{pe[0] * 4 + pe[1]}_0.elf") for pe in PES}
    dis = {pe: {r["pc"]: r["instruction"] for r in json.loads((run / f"disasm_out_{pe[0] * 4 + pe[1]}_0.json").read_text())["records"]} for pe in PES}
    fn_of = lambda pe, pc: next((n for a, b, n in fns[pe] if a <= pc < b), "?")
    # ---- read the trace
    disp = collections.defaultdict(list); lanes = {}; want = {}; obs = collections.defaultdict(list)
    with gzip.open(run / "events.jsonl.gz", "rt") as f:
        for line in f:
            if '"hwm_pipe_trace_entry"' in line:
                e = json.loads(line)
                if e.get("stage") != 6 or e.get("simdi") in (None, 255): continue
                w = want.get((e["tile_index"], e["uid"]))
                if w: lanes.setdefault(w, {})[e["data"]] = (e["src0"] & 0xFFFF, e["src1"] & 0xFFFF, e["src2"] & 0xFFFF, e["dest"] & 0xFFFF, e["cycle"])
                continue
            e = json.loads(line); s = e["coordinates"]["simulator"]; x, y = s["x"], s["y"]; c = e["cycle"]
            if e["_type"] == "wavelet_trace_entry":
                obs[e["ident"]].append((c, (x, y), int(e["fields"]) & 31, (e["index"] << 16) | e["data"])); continue
            if not K(x, y): continue
            pe = (x - 4, y - 1)
            d = dict(c=c, n=e["name"], ut=e["ut_id"], nd=e["num_data"], pc=e["inst_ptr"], uid=e["uid"]); disp[pe].append(d)
            if e["name"] == "FMACH" and e["ut_id"] == 255: want[(e["tile_index"], e["uid"])] = (pe, c, e["uid"])
    for pe in disp: disp[pe].sort(key=lambda d: d["c"])
    # ---- FMACH -> tiles per step (repeat 1 only when the run has several)
    per_step = T * T                                     # FMACHs per step: Kt k-values x Nt columns
    tiles = {}; compute = {}; cvals = []; checks = collections.Counter()
    for pe in PES:
        F = sorted(k for k in lanes if k[0] == pe); F = F[:P * per_step] if repeat_1_only else F
        assert len(F) >= P * per_step, (pe, len(F))
        iv = []
        for s in range(P):
            blkF = F[s * per_step:(s + 1) * per_step]
            Xt = [[0] * T for _ in range(T)]; Wt = [[0] * T for _ in range(T)]; C0 = [[0] * T for _ in range(T)]; C1 = [[0] * T for _ in range(T)]
            for kk in range(T):
                for n in range(T):
                    L = lanes[blkF[kk * T + n]]; Wt[kk][n] = L[0][2]
                    for m in range(T):
                        s0, s1, s2, d, cyc = L[m]; Xt[m][kk] = s1
                        if kk == 0: C0[m][n] = s0
                        if kk == T - 1: C1[m][n] = d
                        if keep_cvals: cvals.append([cyc, pe[0], pe[1], m, n, int(f16(d))])
            k = steps["steps"][s][f"{pe[0]},{pe[1]}"]["x"][1]
            xi = [[int(f16(v)) for v in r] for r in Xt]; wi = [[int(f16(v)) for v in r] for r in Wt]
            checks["x_tile_matches_block"] += xi == blk(X, pe[1], k); checks["w_tile_matches_block"] += wi == blk(W, k, pe[0]); checks["tiles"] += 1
            f0, f1 = blkF[0][1], blkF[-1][1]
            tiles[f"{pe[0]},{pe[1]},{s}"] = dict(k=k, X=xi, W=wi, C0=[[int(f16(v)) for v in r] for r in C0], C1=[[int(f16(v)) for v in r] for r in C1], fmach=[f0, f1])
            iv.append([f0, f1 + 1, f"FMACH step {s + 1}", s])
        clears = [d["c"] for d in disp[pe] if d["n"] == "FMOV16.NF" and d["nd"] >= T * T and d["ut"] == 255 and d["c"] < iv[0][0]]
        if clears: iv.insert(0, [clears[-1], clears[-1] + 1, "C cleared", -1])
        compute[f"{pe[0]},{pe[1]}"] = iv
        checks["c_final_matches_host"] += tiles[f"{pe[0]},{pe[1]},{P - 1}"]["C1"] == blk(R["C_dev"], pe[1], pe[0])
    # ---- kernel transfers (identity-followed), labelled by the schedule
    t_first = min(v[0][0] for v in compute.values()) - 2000 if repeat_1_only else 0
    t_last = max(v[-1][1] for v in compute.values())
    paths = collections.defaultdict(list)
    for ident, L in obs.items():
        L.sort(); col = L[0][2]
        if col not in KIND: continue
        route = []
        for c, xy, _, pay in L:
            if not route or route[-1][1] != xy: route.append((c, xy))
        if len(route) < 2 or not all(K(*xy) for _, xy in route): continue
        if repeat_1_only and not (t_first <= L[0][0] <= t_last): continue
        paths[(KIND[col], route[0][1], route[-1][1])].append((L[0][0], route, col))
    def label(kind, src, dst, ordinal):
        px, py = src[0] - 4, src[1] - 1
        if kind in ("sr", "sf"):
            if ordinal == 0 or py == 0: return f"X({py},{px})"
            prev = recv[px] if py % 2 else send[px]                     # who sent to me in transfer 1
            return f"X({py},{prev})"
        s = ordinal; q = steps["steps"][s][f"{px},{py}"]
        return f"X({py},{q['x'][1]})" if kind == "x" else f"W({q['w'][0]},{px})"
    PK = T * T // 2                                      # @mov16 packs two f16 per wavelet
    links = []; arrivals = collections.defaultdict(list); departures = collections.defaultdict(list)
    for (kind, src, dst), pk in paths.items():
        pk.sort(key=lambda q: q[0]); chunks = [pk[i:i + PK] for i in range(0, len(pk), PK)]
        for ordinal, ch in enumerate(chunks):
            lab = label(kind, src, dst, ordinal); hops = len(ch[0][1]) - 1
            for h in range(hops):
                up = [q[1][h][0] for q in ch]; dn = [q[1][h + 1][0] for q in ch]; a, b = ch[0][1][h][1], ch[0][1][h + 1][1]
                links.append(dict(g=lab, t="w" if kind == "w" else "x", kind=kind, hop=h + 1, hops=hops, sx=a[0] - 4, sy=a[1] - 1, tx=b[0] - 4, ty=b[1] - 1,
                                  start=min(up), end=max(dn) + 1, n=len(ch)))
            s_pe = (src[0] - 4, src[1] - 1); d_pe = (dst[0] - 4, dst[1] - 1)
            departures[(s_pe, lab)].append([min(q[1][0][0] for q in ch), max(q[1][0][0] for q in ch) + 1])
            arrivals[(d_pe, lab)].append(max(q[1][-1][0] for q in ch) + 1)
    # ---- host streams: words for each PE arrive in its row stream (every P-th packet is its slot)
    host_in = {}; host_out = {}
    for pe in PES:
        px, py = pe
        row = sorted((L[0][0], ident) for ident, L in obs.items() if L[0][2] == 23 and any(xy == (3, py + 1) for _, xy, _, _ in L) and L[0][0] < t_first + 2000)
        mine = [L for i, (_, ident) in enumerate(row) if i % P == px for L in [obs[ident]]]
        at_pe = [max(c for c, xy, _, _ in L if xy == (px + 4, py + 1)) for L in mine if any(xy == (px + 4, py + 1) for _, xy, _, _ in L)]
        if at_pe: host_in[f"{px},{py}"] = dict(start=min(at_pe), end=max(at_pe) + 1, n=len(at_pe))
        out = [L for L in obs.values() if L[0][2] == 21 and L[0][1] == (px + 4, py + 1) and L[0][0] > t_last]
        if out: host_out[f"{px},{py}"] = dict(start=min(L[0][0] for L in out), end=max(L[-1][0] for L in out) + 1, n=len(out))
    # ---- residency per PE: one record per STAY, with the buffer each arrival lands in from the kernel's own pointer logic
    # (meshgemm.csl: init x_shift_step by row; left_matrix_shift_callback swaps while x_shift_step >= 0, swaps once more after the
    # loop if x_shift_step != 0; mm_compute swaps both pairs at every step). Asserted below against the FMACH-identified tiles.
    first_arrival = collections.defaultdict(list)                  # (pe, label) -> first downstream wavelet cycles (one per transfer)
    for (kind, src, dst), pk in paths.items():
        pk.sort(key=lambda q: q[0]); chunks = [pk[i:i + PK] for i in range(0, len(pk), PK)]
        for ordinal, ch in enumerate(chunks):
            first_arrival[((dst[0] - 4, dst[1] - 1), label(kind, src, dst, ordinal))].append(min(q[1][-1][0] for q in ch))
    residency = {}
    for pe in PES:
        px, py = pe; hi = host_in.get(f"{px},{py}"); stays = []
        buf = {"X_0": None, "X_1": None, "W_0": None, "W_1": None}
        def land(b, lab, t_first, t_last_, from_host=False):
            if buf[b] is not None: buf[b]["overwritten"] = t_first
            st = dict(t=b[0].lower(), g=lab, buf=b, arrived=t_last_, from_host=from_host, overwritten=None, sent=[], computed=[]); buf[b] = st; stays.append(st)
        if hi:
            land("X_0", f"X({py},{px})", hi["start"], hi["end"] - 1, True); land("W_0", f"W({ind[py][px]},{px})", hi["start"], hi["end"] - 1, True)
        xa = sorted((c, lab) for (q, lab), L in arrivals.items() if q == pe and lab[0] == "X" for c in L)      # (last wavelet, label), time order
        wa = sorted((c, lab) for (q, lab), L in arrivals.items() if q == pe and lab[0] == "W" for c in L)
        fa = {}
        for (q, lab), L in first_arrival.items():
            if q == pe: fa[lab] = sorted(L)
        def first_of(lab, c_last): return max([c for c in fa.get(lab, []) if c <= c_last], default=c_last)
        xs, xr, ws, wr = "X_1", "X_0", "W_1", "W_0"                # meshgemm_entry: ptr_X_send = X_1, ptr_X_recv = X_0
        shift = py // 2 if py % 2 == 0 else (py + 1) // 2
        ai = 0
        for t in range(P // 2):                                    # the skew: two transfers
            if shift >= 0: shift -= 1; xs, xr = xr, xs
            c, lab = xa[ai]; ai += 1; land(xr, lab, first_of(lab, c), c)
        if shift != 0: xs, xr = xr, xs
        for s_ in range(P):                                        # mm_compute: swap, send xs/ws, receive into xr/wr, multiply xs/ws
            xs, xr = xr, xs; ws, wr = wr, ws
            tl = tiles[f"{px},{py},{s_}"]
            assert buf[xs] and buf[xs]["g"] == f"X({py},{tl['k']})", (pe, s_, xs, buf[xs] and buf[xs]["g"], tl["k"])
            assert buf[ws] and buf[ws]["g"] == f"W({tl['k']},{px})", (pe, s_, ws, buf[ws] and buf[ws]["g"])
            buf[xs]["computed"].append(tl["fmach"]); buf[ws]["computed"].append(tl["fmach"])
            if ai < len(xa): c, lab = xa[ai]; ai += 1; land(xr, lab, first_of(lab, c), c)
            if s_ < len(wa): c, lab = wa[s_]; land(wr, lab, first_of(lab, c), c)
        checks["buffer_model_consistent_pes"] += 1
        for st in stays:                                           # sends: the transfers of this label issued while this stay was alive
            end = st["overwritten"] or (host_out.get(f"{px},{py}", {}).get("end") or t_last)
            st["sent"] = [iv for iv in sorted(departures.get((pe, st["g"]), [])) if st["arrived"] - 2 <= iv[0] < end]
        residency[f"{px},{py}"] = stays
    # ---- ops runs
    tags, fns_i, instr_i = [], [], []
    def idx(lst, v):
        if v not in lst: lst.append(v)
        return lst.index(v)
    ops = {}; t0 = min(min(h["start"] for h in host_in.values()), t_first) if host_in else t_first
    t1 = max([h["end"] for h in host_out.values()] + [t_last]) + 20
    for pe, L in disp.items():
        runs = []
        for d in L:
            if not t0 <= d["c"] <= t1: continue
            asm = dis[pe].get(d["pc"], d["n"].lower()); fn = fn_of(pe, d["pc"]); tg = tag_of(d["n"], d["ut"], d["nd"], asm, fn, T)
            if runs and runs[-1][2] == tg and runs[-1][3] == idx(fns_i, fn) and d["c"] - runs[-1][1] <= 3: runs[-1][1] = d["c"]; runs[-1][5] += 1
            else: runs.append([d["c"], d["c"], tg, idx(fns_i, fn), idx(instr_i, asm[:60]), 1])
        ops[f"{pe[0]},{pe[1]}"] = [[a, b, idx(tags, tg), fi, ii, n] for a, b, tg, fi, ii, n in runs]
    events = sorted({c for l in links for c in (l["start"], l["end"])} | {c for iv in compute.values() for a, b, _, _ in iv for c in (a, b)} |
                    {c for h in list(host_in.values()) + list(host_out.values()) for c in (h["start"], h["end"])})
    out = dict(name=name, T=T, P=P, start=t0, end=t1, X=X, W=W, W_offset=R.get("W_offset"), ind=ind, C=R["C_dev"], exact=R["exact"], send=send,
               tiles=tiles, compute=compute, links=links, host_in=host_in, host_out=host_out, residency=residency, cvals=cvals if keep_cvals else None,
               ops=ops, tags=tags, fns=fns_i, instrs=instr_i, events=events, checks=dict(checks),
               notes=["tile identity from the verified schedule (meshgemm_steps.json) and checked against the FMACH operands, bit for bit",
                      "arrivals = last wavelet of a transfer at the PE's router; host words = the PE's own slots of its row stream",
                      "overwritten = the second later arrival of the same tensor (double buffering: the next arrival goes to the other buffer)"])
    (STUDY / "results/datapath" / f"{name}_cycles.json").write_text(json.dumps(out, separators=(",", ":")))
    print(name, "window", t0, t1, "checks", dict(checks), "links", len(links), "host_in", len(host_in), "host_out", len(host_out), "cvals", len(cvals))
    print("->", f"results/datapath/{name}_cycles.json", round((STUDY / "results/datapath" / f"{name}_cycles.json").stat().st_size / 1e6, 2), "MB")

if __name__ == "__main__":
    which = sys.argv[1] if len(sys.argv) > 1 else "small"
    if which == "small": main(STUDY / "microbench/mesh_small/run", "mesh_small", 2, False, True)
    else: main(STUDY / "microbench/mesh_big", "mesh_big", 16, True, False)
