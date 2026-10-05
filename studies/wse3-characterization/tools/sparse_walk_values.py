#!/usr/bin/env python3
"""The three sparse kernels' traced small runs, checked value by value, for the sparse dataflow page.

Input: microbench/sparse_walk/<case>/{instance,result,manifest}.json, events.jsonl.gz, disasm_*.json.
For every case this reconstructs, from the trace alone, what each PE computed and moved, and checks
it against the host's arrays and readback:

  arithmetic  every FMULS / FADDS lane record (src0, src1 -> dest) is matched, in order, to the
              product / running sum the source program says it computes, bit for bit (f32; the
              instance is integer-valued, so the reference is exact)
  outputs     the last sum of every row / element equals the host readback
  memcpy      the 32-bit payloads of the host->device packets that reach the kernel PEs contain
              every word the host sent (multiset), and the device->host packets carry the results
  multicast   (SpMV) colour 8: every x value is one packet, seen at the four kernel routers in
              order, and three PEs then compute with it
  cost        dispatched instructions per nonzero / per output, and the exact instruction
              sequence of one inner-loop iteration (dispatch names joined to the disassembly)
Evidence: `simulator` (trace), `compiled` (ELF symbols), exact comparisons. Output:
results/datapath/sparse_walk.json
"""
from __future__ import annotations
import collections, gzip, json, struct
from pathlib import Path

STUDY = Path(__file__).resolve().parents[1]
W = STUDY / "microbench/sparse_walk"
f32 = lambda u: struct.unpack('<f', struct.pack('<I', u & 0xFFFFFFFF))[0]
bits = lambda x: struct.unpack('<I', struct.pack('<f', x))[0]
NONE = 4294967295

def elf_symbols(path):
    b = Path(path).read_bytes(); E = '<'
    shoff = struct.unpack_from(E + 'Q', b, 0x28)[0]; shentsize, shnum, shstrndx = struct.unpack_from(E + 'HHH', b, 0x3A)
    secs = [struct.unpack_from(E + 'IIQQQQIIQQ', b, shoff + i * shentsize) for i in range(shnum)]
    out = {}
    for s in secs:
        if s[1] == 2:
            st = secs[s[6]]
            for j in range(s[5] // 24):
                n, info, oth, shn, val, sz = struct.unpack_from(E + 'IBBHQQ', b, s[4] + j * 24)
                name = b[st[4] + n:b.index(b'\0', st[4] + n)].decode()
                out[name.split("$$")[-1]] = (val, sz)
    return out

def load_trace(case, rect):
    """Dispatches and lane records of the kernel PEs, plus every wavelet observation."""
    x0, y0, w, h = rect
    K = lambda x, y: x0 <= x < x0 + w and y0 <= y < y0 + h
    disp = collections.defaultdict(list); lanes = {}; waves = collections.defaultdict(list); want = {}
    with gzip.open(W / case / "events.jsonl.gz", "rt") as f:
        for line in f:
            e = json.loads(line); s = e["coordinates"]["simulator"]; xy = (s["x"], s["y"]); k = e["_type"]
            if k == "wavelet_trace_entry":
                waves[e["ident"]].append((e["cycle"], xy, (e["index"] << 16) | e["data"], int(e["fields"]) & 31)); continue
            if not K(*xy): continue
            pe = (xy[0] - x0, xy[1] - y0)
            if k == "hwm_dispatch_trace_entry":
                disp[pe].append(dict(c=e["cycle"], n=e["name"], ut=e["ut_id"], uid=e["uid"], pc=e["inst_ptr"], nd=e["num_data"]))
                want[(e["tile_index"], e["uid"])] = (pe, e["cycle"])
            elif k == "hwm_pipe_trace_entry" and e.get("stage") == 6 and e.get("simdi") not in (None, 255):
                key = (e["tile_index"], e["uid"])
                if key in want:
                    pe, c = want[key]
                    lanes.setdefault((pe, e["uid"]), {})[e["data"]] = dict(s0=e["src0"], s1=e["src1"], s2=e["src2"], d=e["dest"], imm=e["imm"], c=e["cycle"])
    for pe in disp: disp[pe].sort(key=lambda d: d["c"])
    for v in waves.values(): v.sort()
    return disp, lanes, waves

def fops(disp, lanes, pe):
    """Ordered (cycle, name, lane0) of the scalar FMULS/FADDS on one PE."""
    out = []
    for d in disp[pe]:
        if d["n"] in ("FMULS", "FADDS"):
            L = lanes.get((pe, d["uid"]), {})
            out.append((d["c"], d["n"], L.get(0)))
    return out

def check_chain(ops, expect):
    """expect: list of (a, b, old) f32 triples in program order. Returns (ok, n, records)."""
    ok = 0; recs = []
    assert len(ops) == 2 * len(expect), (len(ops), len(expect))
    for i, (a, b, old) in enumerate(expect):
        cm, nm, lm = ops[2 * i]; ca, na, la = ops[2 * i + 1]
        prod = f32(bits(a * b)) ; acc = f32(bits(old + prod))
        good = nm == "FMULS" and na == "FADDS" and lm and la and sorted([lm["s0"], lm["s1"]]) == sorted([bits(a), bits(b)]) and lm["d"] == bits(prod) \
               and sorted([la["s0"], la["s1"]]) == sorted([bits(old), bits(prod)]) and la["d"] == bits(acc)
        ok += good
        recs.append(dict(a=a, b=b, old=old, product=prod, acc=acc, cyc_mul=cm, cyc_add=ca, ok=good))
    return ok, len(expect), recs

def io_check(waves, rect, h2d_words, d2h_words):
    """Host->device payloads that reach the kernel region vs the words the host sent (multiset)."""
    x0, y0, w, h = rect
    K = lambda xy: x0 <= xy[0] < x0 + w and y0 <= xy[1] < y0 + h
    seen_in, seen_out, entry, exit_ = collections.Counter(), collections.Counter(), collections.Counter(), collections.Counter()
    n_in = n_out = 0
    for v in waves.values():
        col = v[0][3]; path = [o[1] for o in v]
        if col == 23 and any(K(p) for p in path): seen_in[v[0][2]] += 1; n_in += 1; entry[path[0]] += 1
        if col == 21 and any(K(p) for p in path): seen_out[v[0][2]] += 1; n_out += 1; exit_[path[-1]] += 1
    want_in = collections.Counter(h2d_words); want_out = collections.Counter(d2h_words)
    return dict(h2d_packets=n_in, h2d_words_expected=len(h2d_words), h2d_words_found=sum(min(seen_in[k], c) for k, c in want_in.items()),
                h2d_first_router=[list(k) for k, _ in entry.most_common(2)],
                d2h_packets=n_out, d2h_words_expected=len(d2h_words), d2h_words_found=sum(min(seen_out[k], c) for k, c in want_out.items()),
                d2h_last_router=[list(k) for k, _ in exit_.most_common(2)], values_per_packet=1)

def mix(disp, pe, c0, c1):
    names = collections.Counter(d["n"] for d in disp[pe] if c0 <= d["c"] <= c1 and d["ut"] == 255)
    cls = collections.Counter()
    for n, k in names.items():
        g = "float" if n.startswith("F") and n not in ("FMOV32.NF", "FMOV16.NF") else "load" if n.startswith("LD") else "store" if n.startswith("ST") else \
            "branch" if n in ("JMP", "SETJT", "BLK", "UBLK") or n.startswith(("LT", "EQ", "LTE", "LTU", "GT")) else "move" if "MOV" in n else "address"
        cls[g] += k
    return dict(total=sum(names.values()), by_class=dict(cls), top=names.most_common(12))

def inner_iteration(disp, pe, disasm, a, b):
    """Dispatch names (with disassembly) strictly between two cycles, one inner-loop iteration."""
    return [dict(c=d["c"], n=d["n"], asm=disasm.get(d["pc"], "")) for d in disp[pe] if a < d["c"] <= b and d["ut"] == 255]

def read_disasm(case, elf_stem):
    p = W / case / f"disasm_{elf_stem}.json"
    if not p.exists(): return {}
    return {r["pc"]: r["instruction"] for r in json.loads(p.read_text())["records"]}

# ------------------------------------------------------------------ SpMV-RowBlock
def spmv():
    case = "spmv"; R = json.loads((W / case / "result.json").read_text()); I = json.loads((W / case / "instance.json").read_text())
    P, nr, nc, cap = R["P"], R["nrows_pe"], R["ncols"], R["max_nnz_pe"]; rect = (4, 1, P, 1)
    disp, lanes, waves = load_trace(case, rect)
    x = [f32(bits(v)) for v in R["x"]]
    pes = {}; ok_all = n_all = 0
    for px in range(P):
        pe = (px, 0); rp, ci, va = R["row_ptr"][px], R["col_idx"][px], R["val"][px]
        expect = []; rows = []
        for r in range(nr):
            old = 0.0; terms = []
            for j in range(rp[r], rp[r + 1]):
                a, b = f32(bits(va[j])), x[ci[j]]; expect.append((a, b, old)); terms.append(dict(j=j, col=ci[j], val=a, x=b)); old = f32(bits(old + f32(bits(a * b))))
            rows.append(dict(r=r, grow=px * nr + r, terms=terms, y=old, y_dev=R["y_dev"][px][r]))
        ok, n, recs = check_chain(fops(disp, lanes, pe), expect); ok_all += ok; n_all += n
        k = 0
        for row in rows:
            for t in row["terms"]: t.update(recs[k]); k += 1
        # y stores: ST32 whose value is the row's y, in order
        # y[r] is written by a memory-destination move: find the pc whose stored values are exactly y, in row order
        by_pc = collections.defaultdict(list)
        for d in disp[pe]:
            if d["ut"] == 255 and (d["n"].startswith("ST") or d["n"] in ("FMOV32.NF", "IMOV32.NF")):
                L = lanes.get((pe, d["uid"]), {}).get(0)
                if L and L["d"] != NONE: by_pc[d["pc"]].append((d["c"], L["d"]))
        # the row loop is unrolled (one store site per row), so match each y[r] by value after its last FADDS
        stores = sorted((c, v) for lst in by_pc.values() for c, v in lst)
        ystores = []
        for row in rows:
            after = max([t["cyc_add"] for t in row["terms"]], default=0)
            hit = next((c for c, v in stores if c > after and v == bits(row["y"])), None)
            ystores.append(hit)
        F = fops(disp, lanes, pe); c0, c1 = F[0][0], F[-1][0]
        # the kernel's own x move (micro-thread 0 belongs to memcpy): PE 0 sends with @fmovs, the others receive
        ut = [d for d in disp[pe] if d["ut"] not in (255, 0) and d["n"] in ("FMOV32.NF", "IMOV32.NF")]
        pes[f"{px},0"] = dict(rows=rows, row_ptr=rp, col_idx=ci, val=[f32(bits(v)) for v in va], nnz=R["nnz_per_pe"][px], first_fmuls=c0, last_fadds=c1,
                              y_store_cycles=ystores, x_move=(dict(c=ut[0]["c"], n=ut[0]["n"], ut=ut[0]["ut"], elems=ut[0]["nd"]) if ut else None),
                              mix=mix(disp, pe, c0 - 40, c1 + 40), window_tsc=R["windows"][px])
    # colour-8 multicast
    c8 = [v for v in waves.values() if v[0][3] == 8]; c8.sort(key=lambda v: v[0][0])
    mc = dict(packets=len(c8), routers_per_packet=sorted({len({o[1] for o in v}) for v in c8}), path=[list(p) for p in [o[1] for o in c8[0]]] if c8 else [],
              first_send=c8[0][0][0] if c8 else None, last_arrival=max(v[-1][0] for v in c8) if c8 else None,
              payload_is_x_in_order=all(f32(v[0][2]) == x[i] for i, v in enumerate(c8)) and len(c8) == nc,
              per_hop_cycles=sorted({v[i + 1][0] - v[i][0] for v in c8 for i in range(len(v) - 1)}),
              arrivals=[[o[0] for o in v] for v in c8[:3]])
    for px in range(1, P):
        pes[f"{px},0"]["x_last_arrival"] = max(o[0] for v in c8 for o in v if o[1] == (4 + px, 1))
    words_in = [w for px in range(P) for arr in (R["row_ptr"][px], R["col_idx"][px]) for w in arr] + [bits(f32(bits(v))) for px in range(P) for v in R["val"][px]] + [bits(v) for v in x]
    words_out = [bits(f32(bits(v))) for px in range(P) for v in R["y_dev"][px]]
    disasm = read_disasm(case, "out_1_0")
    F1 = fops(disp, lanes, (1, 0)); it = inner_iteration(disp, (1, 0), disasm, F1[2][0], F1[4][0])   # second nnz of PE 1: from its FMULS to the next FMULS
    return dict(task="SpMV-RowBlock", params=dict(P=P, nrows_pe=nr, ncols=nc, max_nnz_pe=cap), fabric=[11, 3], rect=list(rect), instance=I,
                x=x, y_dev=R["y_dev"], y_ref=R["y_ref"], exact=R["exact"], cycles_send=R["cycles_send"], pes=pes, mcast=mc,
                io=io_check(waves, rect, words_in, words_out), checks=dict(arithmetic=[ok_all, n_all], outputs=[sum(int(row["y"] == row["y_dev"]) for p in pes.values() for row in p["rows"]), P * nr]),
                inner_iteration=it, nnz=sum(R["nnz_per_pe"]))

# ------------------------------------------------------------------ SpMM-CSR-Dense
def spmm():
    case = "spmm"; R = json.loads((W / case / "result.json").read_text()); I = json.loads((W / case / "instance.json").read_text())
    P, Mt, K, Nt, cap = R["P"], R["Mt"], R["K"], R["Nt"], R["max_nnz_pe"]; rect = (4, 1, P, P)
    disp, lanes, waves = load_trace(case, rect)
    pes = {}; ok_all = n_all = 0; outs_ok = outs_n = 0
    for py in range(P):
        for px in range(P):
            pe = (px, py); rp, ci, va = R["row_ptr"][py][px], R["col_idx"][py][px], R["val"][py][px]
            Bt = [f32(bits(v)) for v in R["B_tiles"][py][px]]          # K x Nt row-major
            expect = []; rows = []
            for r in range(Mt):
                acc = [0.0] * Nt; cells = [[] for _ in range(Nt)]
                for j in range(rp[r], rp[r + 1]):
                    k = ci[j]; v = f32(bits(va[j]))
                    for cc in reversed(range(Nt)):                     # the compiled loop counts cc down (observed order)
                        b = Bt[k * Nt + cc]; expect.append((v, b, acc[cc])); cells[cc].append(dict(j=j, k=k, val=v, b=b))
                        acc[cc] = f32(bits(acc[cc] + f32(bits(v * b))))
                dev = [R["C_dev"][py * Mt + r][px * Nt + cc] for cc in range(Nt)]
                rows.append(dict(r=r, grow=py * Mt + r, cells=[dict(c=cc, gcol=px * Nt + cc, terms=cells[cc], C=acc[cc], C_dev=dev[cc]) for cc in range(Nt)]))
                outs_ok += sum(int(acc[cc] == dev[cc]) for cc in range(Nt)); outs_n += Nt
            ok, n, recs = check_chain(fops(disp, lanes, pe), expect); ok_all += ok; n_all += n
            k = 0
            for row in rows:                                            # trace order is j-major, then cc
                order = []
                for j in range(rp[row["r"]], rp[row["r"] + 1]):
                    for cc in reversed(range(Nt)): order.append((cc, j))
                for cc, j in order:
                    t = next(t for t in row["cells"][cc]["terms"] if t["j"] == j); t.update(recs[k]); k += 1
            F = fops(disp, lanes, pe); c0, c1 = F[0][0], F[-1][0]
            pes[f"{px},{py}"] = dict(rows=rows, row_ptr=rp, col_idx=ci, val=[f32(bits(v)) for v in va], B_tile=Bt, nnz=R["nnz_per_tile"][py],
                                     first_fmuls=c0, last_fadds=c1, mix=mix(disp, pe, c0 - 60, c1 + 40), window_tsc=R["windows"][f"{px},{py}"])
    words_in = [w for py in range(P) for px in range(P) for arr in (R["row_ptr"][py][px], R["col_idx"][py][px]) for w in arr] + \
               [bits(f32(bits(v))) for py in range(P) for px in range(P) for v in R["val"][py][px]] + [bits(f32(bits(v))) for py in range(P) for px in range(P) for v in R["B_tiles"][py][px]]
    words_out = [bits(f32(bits(v))) for row in R["C_dev"] for v in row]
    disasm = read_disasm(case, "out_0_0"); F0 = fops(disp, lanes, (0, 0)); it = inner_iteration(disp, (0, 0), disasm, F0[2][0], F0[4][0])
    return dict(task="SpMM-CSR-Dense", params=dict(P=P, Mt=Mt, K=K, Nt=Nt, max_nnz_pe=cap), fabric=[9, 4], rect=list(rect), instance=I,
                B=R["B"], C_dev=R["C_dev"], C_ref=R["C_ref"], exact=R["exact"], cycles_send=R["cycles_send"], pes=pes,
                io=io_check(waves, rect, words_in, words_out), checks=dict(arithmetic=[ok_all, n_all], outputs=[outs_ok, outs_n]),
                kernel_colours=sorted({v[0][3] for v in waves.values() if any(4 <= o[1][0] < 4 + P and 1 <= o[1][1] < 1 + P for o in v)}),
                inner_iteration=it, nnz=sum(R["nnz_per_tile"]))

# ------------------------------------------------------------------ SpGEMM-Masked-Dot (merge, and the accumulator variant)
def merge_model(ptr, idx, val, i, j):
    pa, pb = ptr[i], ptr[j]; ea, eb = ptr[i + 1], ptr[j + 1]; old = 0.0; steps = []
    while pa < ea and pb < eb:
        ia, ib = idx[pa], idx[pb]; m = ia == ib
        if m: prod = f32(bits(val[pa] * val[pb])); acc = f32(bits(old + prod))
        steps.append(dict(pa=pa, pb=pb, ia=ia, ib=ib, match=m, a=val[pa] if m else None, b=val[pb] if m else None, old=old, product=prod if m else None, acc=acc if m else old,
                          action="match" if m else ("advance A(:,i)" if ia < ib else "advance A(:,j)")))
        if m: old = acc
        if ia <= ib: pa += 1
        if ib <= ia: pb += 1
    return steps, old

def acc_model(ptr, idx, val, i, j):
    """The expert variant: A(:,j) scattered into a dense accumulator; C(i,j) is a gather over A(:,i),
    one multiply per stored row of column i (by 0.0 where column j has no entry)."""
    inj = {idx[q]: val[q] for q in range(ptr[j], ptr[j + 1])}; old = 0.0; steps = []
    for q in range(ptr[i], ptr[i + 1]):
        k = idx[q]; a = val[q]; b = inj.get(k, 0.0); prod = f32(bits(a * b)); acc = f32(bits(old + prod))
        steps.append(dict(pa=q, pb=None, ia=k, ib=k if k in inj else None, match=k in inj, a=a, b=b, old=old, product=prod, acc=acc,
                          action="gather: hit" if k in inj else "gather: miss (x 0.0)")); old = acc
    return steps, old

def spgemm(case="spgemm"):
    if not all((W / case / f).exists() for f in ("result.json", "events.jsonl.gz", "manifest.json")): return None
    R = json.loads((W / case / "result.json").read_text()); I = json.loads((W / case / "instance.json").read_text())
    n, cap, nnz = R["n"], R["max_nnz"], R["nnz"]; rect = (4, 1, 1, 1); pe = (0, 0)
    disp, lanes, waves = load_trace(case, rect)
    ptr, idx = R["col_ptr"], R["row_idx"]; val = [f32(bits(v)) for v in R["val"]]
    entries = []; expect = []
    for j in range(n):
        for p in range(ptr[j], ptr[j + 1]):
            i = idx[p]; steps, c = (merge_model if case == "spgemm" else acc_model)(ptr, idx, val, i, j)
            matches = [s for s in steps if s["match"]]
            for s in (matches if case == "spgemm" else steps): expect.append((s["a"], s["b"], s["old"]))
            entries.append(dict(p=p, i=i, j=j, steps=steps, matches=len(matches), c=c, exists=bool(matches), c_dev=R["c_dev"][p], c_row_dev=R["c_row_dev"][p],
                                zombie=not matches, colA=[[idx[q], val[q]] for q in range(ptr[i], ptr[i + 1])], colB=[[idx[q], val[q]] for q in range(ptr[j], ptr[j + 1])]))
    F = fops(disp, lanes, pe); ok, nchk, recs = check_chain(F, expect) if F else (0, len(expect), [])
    k = 0
    for e in entries:
        for s in e["steps"]:
            if (s["match"] or case != "spgemm") and k < len(recs): s.update(recs[k]); k += 1
    # per-entry cost: cycles between consecutive c_val stores (ST32 into c_val_array), from the ELF symbol
    # Indexed stores carry no address immediate, so the c_val / c_row store instructions are found by
    # their value sequences: the ST32 pc whose stored values, in order, are exactly the readback.
    by_pc = collections.defaultdict(list)                      # any instruction that writes memory: ST32, FMOV32, IMOV32, ...
    for d in disp[pe]:
        if d["ut"] == 255 and (d["n"].startswith("ST") or d["n"] in ("FMOV32.NF", "IMOV32.NF")):
            L = lanes.get((pe, d["uid"]), {}).get(0)
            if L and L["d"] != NONE: by_pc[d["pc"]].append((d["c"], L["d"]))
    def pc_matching(seq):
        for pc, lst in by_pc.items():
            if [v for _, v in lst] == seq: return pc, [c for c, _ in lst]
        return None, [None] * len(seq)
    pc_cval, cval_cycles = pc_matching([bits(e["c"]) for e in entries])
    pc_crow, crow_cycles = pc_matching([(e["i"] if e["exists"] else (~e["i"]) & 0xFFFFFFFF) for e in entries])   # two pcs (i / ~i): may not match as one sequence
    cstores = cval_cycles if pc_cval is not None else crow_cycles
    st_total = sum(len(v) for v in by_pc.values())
    prev = None
    for p, e in enumerate(entries):
        c = cstores[p]; e["store_cycle"] = c; e["c_val_store_cycle"] = cval_cycles[p]
        if c is not None:
            lo = prev if prev is not None else (F[0][0] - 60 if F else c - 400)
            win = [d for d in disp[pe] if lo < d["c"] <= c and d["ut"] == 255]
            e["instructions"] = len(win); e["cycles"] = c - lo if prev is not None else None
            e["stores"] = sum(1 for d in win if d["n"].startswith("ST"))                 # register spills of the merge state (ST16/ST32)
            e["compares"] = sum(1 for d in win if d["n"] in ("LTU32", "LTEU32", "EQ32", "LT16", "LTU16", "EQ16", "LTE16"))
            e["branches"] = sum(1 for d in win if d["n"] in ("JMP", "SETJT"))
            prev = c
    first_c = min(c for c in cstores if c) if any(cstores) else None
    span = [min(d["c"] for d in disp[pe] if d["n"] == "LTU32") if any(d["n"] == "LTU32" for d in disp[pe]) else None, max(cstores) if any(cstores) else None]
    zomb = [e for e in entries if e["zombie"]]
    return dict(task="SpGEMM-Masked-Dot" + (" · dense accumulator (expert variant)" if case != "spgemm" else " · two-pointer merge (reference)"), case=case,
                params=dict(n=n, max_nnz=cap), fabric=[8, 3], rect=list(rect), instance=I, col_ptr=ptr, row_idx=idx, val=val, nnz=nnz,
                entries=entries, exact=R["exact"], cycles_send=R["cycles_send"], nzombies=R["nzombies_dev"],
                checks=dict(arithmetic=[ok, nchk], c_values=[sum(int(e["c"] == e["c_dev"]) for e in entries), len(entries)],
                            row_codes=[sum(int((e["i"] if e["exists"] else (~e["i"]) & 0xFFFFFFFF) == e["c_row_dev"]) for e in entries), len(entries)],
                            zombies=[R["nzombies_dev"], len(zomb)], entry_boundaries_found=[sum(1 for c in cstores if c), len(entries)]),
                store_pcs=dict(c_val=pc_cval, c_row=pc_crow),
                mix=mix(disp, pe, F[0][0] - 400 if F else 0, max(c for c in cstores if c) if any(cstores) else 0), compute_span=span,
                io=io_check(waves, rect, [w for w in ptr] + [w for w in idx] + [bits(v) for v in val], [bits(f32(bits(v))) for v in R["c_dev"]] + R["c_row_dev"]),
                kernel_colours=sorted({v[0][3] for v in waves.values() if any(o[1] == (4, 1) for o in v)}), matches_total=len(expect))

def main():
    out = dict(spmv=spmv(), spmm=spmm(), spgemm=spgemm("spgemm"), spgemm_acc=spgemm("spgemm_acc"))
    for k, v in out.items():
        if not v: print(k, "missing"); continue
        print(k, "checks", json.dumps(v["checks"]), "| io", {a: v["io"][a] for a in ("h2d_packets", "h2d_words_expected", "h2d_words_found", "d2h_packets", "d2h_words_expected", "d2h_words_found")},
              "| cycles_send", v["cycles_send"])
        if k == "spmv": print("   mcast", {a: v["mcast"][a] for a in ("packets", "routers_per_packet", "payload_is_x_in_order", "per_hop_cycles", "first_send", "last_arrival")})
    (STUDY / "results/datapath/sparse_walk.json").write_text(json.dumps(out))
    print("-> results/datapath/sparse_walk.json", round((STUDY / "results/datapath/sparse_walk.json").stat().st_size / 1e6, 2), "MB")

if __name__ == "__main__":
    main()
