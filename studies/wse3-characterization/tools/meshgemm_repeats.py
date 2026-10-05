#!/usr/bin/env python3
"""MeshGEMM over all 7 repeats: where the skew sits, which SRAM buffer each step reads and
writes, and which tiles each repeat actually multiplies.

Evidence comes from the simulator trace alone, joined to the compiled symbol table:
  * `ST16` pipe records carry the value stored and, in `imm`, the low byte of the word
    address written. The ELF symbol table (tools: parse of bin/out_*_0.elf) places
        X_dsd.1  116   W_dsd.1  118   swap_ptr 120   ptr_X_send 122   ptr_X_recv 124
        ptr_W_send 126 ptr_W_recv 128  right_matrix_send_dsd.1 146
        left_matrix_recv_dsd.1 148     right_matrix_recv_dsd.1 150
    and the buffers at byte 0x1140 X_0_tile, 0x1340 X_1_tile, 0x1540 W_0_tile,
    0x1740 W_1_tile, 0x1940 res_tile (word addresses are half: 0x8a0 ... 0xca0).
    A store is accepted only if its value lies in the domain of that variable (byte
    buffer bases for the pointers, word addresses inside a buffer for DSD bases).
  * FMACH lane records carry the operands: src1 lane m = X[m,k], src2 = W[k,n].
  * Wavelet records give the skew packets (colours 7,8,9,12,13,16) each PE sends.
Per PE, repeat r and step s this reports: the buffer the FMACHs read (X_dsd / W_dsd base),
the buffer the receive writes (left/right_matrix_recv_dsd base), the micro-thread moves that
run inside the FMACH window, and which X and W tiles were multiplied, identified by content
against the verified repeat-1 tiles (results/datapath/meshgemm_values.json).
Evidence: `simulator` values and addresses, `compiled` symbol addresses; exact comparisons.
"""
from __future__ import annotations
import collections, gzip, json, re
from pathlib import Path

P, T = 4, 16
PATH = "results/wse3-full/kernels/WaferLLM-MeshGEMM/events.jsonl.gz"
BYTE = {0x1140: "X_0", 0x1340: "X_1", 0x1540: "W_0", 0x1740: "W_1", 0x1940: "res"}
def word_buf(w):
    for base, name in ((0x8a0, "X_0"), (0x9a0, "X_1"), (0xaa0, "W_0"), (0xba0, "W_1"), (0xca0, "res")):
        if base <= w < base + 0x100: return name
    return None
PTR = {122: "ptr_X_send", 124: "ptr_X_recv", 126: "ptr_W_send", 128: "ptr_W_recv", 120: "swap_ptr"}
DSD = {116: "X_dsd", 118: "W_dsd", 146: "W_send_dsd", 148: "X_recv_dsd", 150: "W_recv_dsd", 153: "X_send_dsd?"}
SKEW = {7, 8, 9, 12, 13, 16}; STEPC = {1, 2, 3, 4, 5, 6}
RX = re.compile(r'"tile_index": (\d+), "uid": (\d+).*?"stage": (\d+)')

def kpe(s):
    x, y = s["x"], s["y"]
    return (x - 4, y - 1) if 4 <= x <= 7 and 1 <= y <= 4 else None

def main():
    tile_pe = {}
    fm = collections.defaultdict(list)          # pe -> [(cycle, uid)]
    st = collections.defaultdict(list)          # pe -> [(cycle, uid)]
    ut = collections.defaultdict(list)          # pe -> [(cycle, name, ut, num_data)]
    big = collections.defaultdict(list)         # pe -> [(cycle, name)] main-thread ops over 256 elements
    want = {}                                   # (tile, uid) -> ("F"|"S", pe, cycle)
    lanes = {}                                  # (pe, cycle) -> {m: (src1, src2)}
    stores = collections.defaultdict(list)      # pe -> [(cycle, imm, value)]
    pk = {}                                     # ident -> [t0, t1, first xy, last xy, colour]
    n = 0
    with gzip.open(PATH, "rt") as f:
        for line in f:
            n += 1
            if '"hwm_pipe_trace_entry"' in line:
                m = RX.search(line)
                if not m or m.group(3) != "6": continue
                key = (int(m.group(1)), int(m.group(2)))
                w = want.get(key)
                if not w: continue
                e = json.loads(line)
                if e.get("simdi") in (None, 255): continue
                kind, pe, c = w
                if kind == "F":
                    lanes.setdefault((pe, c), {})[e["data"]] = (e["src1"] & 0xFFFF, e["src2"] & 0xFFFF)
                else:
                    stores[pe].append((c, e["imm"], e["dest"] & 0xFFFF)); del want[key]
                continue
            e = json.loads(line)
            if e["_type"] == "hwm_dispatch_trace_entry":
                pe = kpe(e["coordinates"]["simulator"])
                if pe is None: continue
                tile_pe[e["tile_index"]] = pe
                c, nm, u = e["cycle"], e["name"], e["ut_id"]
                want.pop((e["tile_index"], e["uid"]), None)      # uids can wrap: never inherit a stale entry
                if nm == "FMACH" and u == 255:
                    fm[pe].append((c, e["uid"])); want[(e["tile_index"], e["uid"])] = ("F", pe, c)
                elif nm == "ST16" and u == 255:
                    want[(e["tile_index"], e["uid"])] = ("S", pe, c)
                elif u != 255:
                    ut[pe].append((c, nm, u, e["num_data"]))
                if u == 255 and e["num_data"] >= 256 and nm != "FMACH":
                    big[pe].append((c, nm))
            elif e["_type"] == "wavelet_trace_entry":
                col = int(e["fields"]) & 31
                if col not in SKEW and col not in STEPC: continue
                s = e["coordinates"]["simulator"]; xy = (s["x"], s["y"])
                q = pk.get(e["ident"])
                if q is None: pk[e["ident"]] = [e["cycle"], e["cycle"], xy, xy, col]
                else: q[1] = e["cycle"]; q[3] = xy
    print(f"read {n:,} records; FMACH per PE {sorted({len(v) for v in fm.values()})}")

    # ---- accept stores only inside each variable's value domain
    ptrs = collections.defaultdict(lambda: collections.defaultdict(list)); rejected = collections.Counter()
    for pe, L in stores.items():
        for c, imm, v in sorted(L):
            if imm in PTR and v in BYTE: ptrs[pe][PTR[imm]].append((c, BYTE[v]))
            elif imm in DSD and word_buf(v): ptrs[pe][DSD[imm]].append((c, word_buf(v), v))
            elif imm in PTR or imm in DSD: rejected[imm] += 1
    def at(pe, var, c):                          # last value stored to var at or before cycle c
        best = None
        for rec in ptrs[pe][var]:
            if rec[0] <= c: best = rec
            else: break
        return best

    # ---- reference tiles (repeat 1, verified) for identification by content
    V = json.loads(Path("results/datapath/meshgemm_values.json").read_text())["tiles"]
    steps = json.loads(Path("results/datapath/meshgemm_steps.json").read_text())["steps"]
    Xid, Wid = {}, {}
    for key, tl in V.items():
        px, py, s = map(int, key.split(","))
        q = steps[s][f"{px},{py}"]
        Xid[json.dumps(tl["X"])] = tuple(q["x"]); Wid[json.dumps(tl["W"])] = tuple(q["w"])

    per_rep = P * T * T
    R = len(next(iter(fm.values()))) // per_rep
    out = {"repeats": R, "rejected_stores": dict(rejected), "pes": {}, "summary": {}}
    S = collections.Counter()
    skew_rows = collections.defaultdict(list)
    for pe in sorted(fm):
        seq = sorted(fm[pe]); rec = []
        prev_end = 0
        for r in range(R):
            blk = seq[r * per_rep:(r + 1) * per_rep]
            f0 = blk[0][0]
            # skew packets this PE sent after the previous repeat's last FMACH, before this repeat's first
            mine = sorted(q[0] for q in pk.values() if q[4] in SKEW and (q[2][0] - 4, q[2][1] - 1) == pe and prev_end < q[0] < f0)
            clears = [c for c, nm in big[pe] if prev_end < c < f0 and nm.startswith("FMOV")]
            rrec = {"first_fmach": f0, "skew_packets": len(mine), "skew": [mine[0], mine[-1]] if mine else None,
                    "c_clear": clears[-1] if clears else None, "steps": []}
            # which buffers the skew transfers wrote (recv DSD stores inside the skew window)
            if mine:
                rrec["skew_recv_bufs"] = [b for c, b, _ in ptrs[pe]["X_recv_dsd"] if prev_end < c <= f0]
                rrec["skew_send_bufs"] = [b for c, b, _ in ptrs[pe]["X_send_dsd?"] if prev_end < c <= f0]
            for s in range(P):
                sb = blk[s * T * T:(s + 1) * T * T]
                c0, c1 = sb[0][0], sb[-1][0]
                X = [[0] * T for _ in range(T)]; W = [[0] * T for _ in range(T)]
                for kk in range(T):
                    for nn in range(T):
                        L = lanes[(pe, sb[kk * T + nn][0])]
                        W[kk][nn] = L[0][1]
                        for mm in range(T): X[mm][kk] = L[mm][0]
                xr, wr = at(pe, "X_dsd", c0), at(pe, "W_dsd", c0)
                xv, wv = at(pe, "X_recv_dsd", c0), at(pe, "W_recv_dsd", c0)
                xreads = {b for c, b, _ in ptrs[pe]["X_dsd"] if c0 - 40 <= c <= c1}
                moves = [u for u in ut[pe] if c0 <= u[0] <= c1]
                xl, wl = Xid.get(json.dumps(X)), Wid.get(json.dumps(W))
                st_ = {"fmach": [c0, c1], "x_read": xr and xr[1], "x_recv": xv and xv[1], "w_read": wr and wr[1], "w_recv": wv and wv[1],
                       "x_read_bufs_in_step": sorted(xreads), "ut_moves_during_fmach": len(moves),
                       "ut_elems_during_fmach": sum(u[3] for u in moves), "x_tile": xl, "w_tile": wl,
                       "aligned": bool(xl and wl and xl[1] == wl[0])}
                rrec["steps"].append(st_)
                S["steps"] += 1
                S["x_read!=x_recv"] += st_["x_read"] != st_["x_recv"]
                S["w_read!=w_recv"] += st_["w_read"] != st_["w_recv"]
                S["single_x_buffer_per_step"] += len(xreads) == 1
                S["recv_overlaps_fmach"] += st_["ut_moves_during_fmach"] > 0
                S[f"rep{r+1}_aligned"] += st_["aligned"]
                S[f"rep{r+1}_identified"] += bool(xl and wl)
            for s in range(P - 1):                    # the buffer just filled is the one computed on next
                a, b = rrec["steps"][s], rrec["steps"][s + 1]
                S["x_alternates"] += b["x_read"] == a["x_recv"]; S["w_alternates"] += b["w_read"] == a["w_recv"]
                S["alternation_pairs"] += 1
            rec.append(rrec); prev_end = blk[-1][0]
            skew_rows[(r, pe[1])].append(len(mine))
        out["pes"][f"{pe[0]},{pe[1]}"] = rec
    out["summary"] = dict(S)
    out["skew_packets_by_repeat_row"] = {f"{r+1}:{row}": v for (r, row), v in sorted(skew_rows.items())}
    # timing of each repeat's phases, across PEs
    tl = []
    for r in range(R):
        rr = [out["pes"][k][r] for k in out["pes"]]
        sk = [x["skew"] for x in rr if x["skew"]]
        tl.append({"repeat": r + 1, "skew": [min(a for a, _ in sk), max(b for _, b in sk)] if sk else None,
                   "c_clear": [min(x["c_clear"] for x in rr if x["c_clear"]), max(x["c_clear"] for x in rr if x["c_clear"])] if any(x["c_clear"] for x in rr) else None,
                   "first_fmach": [min(x["first_fmach"] for x in rr), max(x["first_fmach"] for x in rr)],
                   "skew_before_clear_before_fmach": all(x["skew"] and x["c_clear"] and x["skew"][1] < x["c_clear"] < x["first_fmach"] for x in rr)})
    out["timeline"] = tl
    Path("results/datapath/meshgemm_repeats.json").write_text(json.dumps(out, indent=1))
    print(json.dumps(out["summary"], indent=1)); print("rejected stores", dict(rejected))
    for t in tl: print(t)
    print("skew packets per PE by repeat:row", {k: sorted(set(v)) for k, v in out["skew_packets_by_repeat_row"].items()})
    print("-> results/datapath/meshgemm_repeats.json")

if __name__ == "__main__":
    main()
