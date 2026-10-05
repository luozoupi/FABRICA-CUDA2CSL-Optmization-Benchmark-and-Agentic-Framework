#!/usr/bin/env python3
"""MeshGEMM repeat 1 as a per-cycle timeline, in the manner of qin00162/Cerebras (profiling/animate_native.py).

That tool draws one frame per simulator cycle on the 4 x 4 physical grid: PEs are green inside a compute
window, each PE carries the tags of the instructions it executed in that cycle, and every data group's
transfer is drawn per physical hop as a batch envelope [first upstream observation, last downstream
arrival). This produces the same three ingredients from this study's trace of WaferLLM MeshGEMM:

  compute   per PE, the FMACH span of each step (measured: first to last FMACH dispatch), plus the C clear
  links     per tile (the data group) and per physical hop: envelope, packet count, colour, hop index.
            Packets are followed by their trace identity (`ident`), so no payload matching is needed.
  ops       per PE, runs of consecutive dispatches with the same tag (gap <= 3 cycles), with the function
            the pc lies in (ELF symbol table) and, where the disassembly has it, the CSL source line.
Tags follow the reference tool's taxonomy: FMAC, ASYNC TX, ASYNC RX, COMM DSD, CLEAR C, CTRL, ADDR,
MEMCPY, OTHER. The window is repeat 1 from just before the skew to the last FMACH of step 4.
Evidence: `simulator` (trace), `compiled` (symbols, disassembly). Output: results/datapath/meshgemm_cycles.json
"""
from __future__ import annotations
import collections, gzip, json, struct, subprocess, sys
from pathlib import Path

STUDY = Path(__file__).resolve().parents[1]
TRACE = STUDY / "results/wse3-full/kernels/WaferLLM-MeshGEMM/events.jsonl.gz"
BIN = Path.home() / "waferllm/MeshGEMM/out_4_16_16_16/bin"
P = 4
KIND = {1: "x", 2: "x", 3: "x", 4: "w", 5: "w", 6: "w", 7: "sr", 8: "sr", 9: "sr", 12: "sf", 13: "sf", 16: "sf"}
TX_DSR = {"dds2", "dds3", "dds4", "dds5"}; RX_DSR = {"s1ds2", "s1ds3", "s1ds4", "s1ds5"}

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
                if (info & 0xF) == 2 and sz > 0:
                    name = b[st[4] + n:b.index(b"\0", st[4] + n)].decode()
                    out.append((val, val + sz, name.replace("sys_mod.sys_mod.", "memcpy.")))
    return sorted(out)

def disasm(elf, out):
    if not out.exists():
        subprocess.run([sys.executable, str(STUDY / "tools/csdisasm.py"), str(elf), "--json", str(out)], check=True, capture_output=True,
                       env=dict(__import__("os").environ, TMPDIR=str(STUDY / ".nfstmp")))
    return {r["pc"]: r for r in json.loads(out.read_text())["records"]}

def tag_of(name, ut, nd, asm, fn, src):
    if name == "FMACH": return "FMAC"
    if fn.startswith("memcpy."): return "MEMCPY"
    if ut != 255 and name.startswith(("IMOV", "FMOV")):
        a = asm.replace(" ", "")
        if any(f"[{d}]=" in a for d in TX_DSR): return "ASYNC TX"
        if any(f"=[{s}]" in a for s in RX_DSR): return "ASYNC RX"
        return "ASYNC"
    if name == "FMOV16.NF" and nd >= 256: return "CLEAR C"
    if "ds" in asm.split("=")[0] and name.startswith(("LD", "ST", "MOV")): return "COMM DSD"
    if "@load_to_dsr" in src or "@set_dsd" in src or "@increment_dsd" in src: return "COMM DSD"
    if name in ("JMP", "SETJT", "BLK", "UBLK", "NOP") or name.startswith(("LT", "EQ", "GT")) or "activate" in src: return "CTRL"
    if name.startswith(("ADD", "SLL", "SLR", "MOVRI", "LD16", "ST16", "AND", "OR", "SUB")): return "ADDR"
    return "OTHER"

def main():
    rep = json.loads((STUDY / "results/datapath/meshgemm_repeats.json").read_text())
    ph = json.loads((STUDY / "results/datapath/meshgemm_phases.json").read_text())["phases"]
    r1 = {tuple(map(int, k.split(","))): v[0] for k, v in rep["pes"].items()}
    t0 = min(v["skew"][0] for v in r1.values()) - 150
    t1 = max(s["fmach"][1] for v in r1.values() for s in v["steps"]) + 80
    # ---- per-PE symbols and disassembly
    fns, dis = {}, {}
    for n in range(16):
        pe = (n // 4, n % 4); elf = BIN / f"out_{n}_0.elf"
        fns[pe] = functions(elf); dis[pe] = disasm(elf, STUDY / "results/disasm" / f"WaferLLM-MeshGEMM_out_{n}_0.json")
    def fn_of(pe, pc):
        for a, b, name in fns[pe]:
            if a <= pc < b: return name
        return "?"
    # ---- one pass over the trace window
    disp = collections.defaultdict(list); obs = collections.defaultdict(list)
    with gzip.open(TRACE, "rt") as f:
        for line in f:
            if '"hwm_pipe_trace_entry"' in line: continue
            e = json.loads(line); c = e["cycle"]
            if c < t0: continue
            if c > t1: break
            s = e["coordinates"]["simulator"]; x, y = s["x"], s["y"]
            if e["_type"] == "wavelet_trace_entry":
                col = int(e["fields"]) & 31
                if col in KIND and 4 <= x <= 7 and 1 <= y <= 4: obs[e["ident"]].append((c, (x - 4, y - 1), col))
                continue
            if not (4 <= x <= 7 and 1 <= y <= 4): continue
            disp[(x - 4, y - 1)].append((c, e["name"], e["ut_id"], e["num_data"], e["inst_ptr"]))
    # ---- compute windows (measured FMACH spans) and the C clear
    compute = {}
    for pe, v in r1.items():
        iv = [[s["fmach"][0], s["fmach"][1] + 1, f"FMACH step {i + 1}"] for i, s in enumerate(v["steps"])]
        if v["c_clear"]: iv.insert(0, [v["c_clear"], v["c_clear"] + 1, "C cleared"])
        compute[f"{pe[0]},{pe[1]}"] = iv
    # ---- tile labels for every transfer: from the verified phase model
    label = {}                                   # (kind, src, dst, ordinal) -> tile label
    for p in ph:
        if p["id"].startswith("skew"):
            t = int(p["id"][-1]) - 1
            for m in p["moves"]:
                a = tuple(m["a"]); kind = "sf" if a[1] % 2 else "sr"
                label[(kind, a, tuple(m["b"]), t)] = p["bufs"][f"{a[0]},{a[1]}"][m["from"]]["label"]
        elif p["id"].startswith("step"):
            s = int(p["id"][4:]) - 1
            for m in p["moves"]:
                a = tuple(m["a"]); label[(m["t"], a, tuple(m["b"]), s)] = p["bufs"][f"{a[0]},{a[1]}"][m["from"]]["label"]
    # ---- packets -> transfers -> per-hop envelopes
    paths = collections.defaultdict(list)        # (kind, src, dst) -> [(t_send, [(cycle, pe)...], colour)]
    for ident, L in obs.items():
        L.sort(); route = []
        for c, pe, col in L:
            if not route or route[-1][1] != pe: route.append((c, pe))
        if len(route) < 2: continue
        kind = KIND[L[0][2]]; paths[(kind, route[0][1], route[-1][1])].append((L[0][0], route, L[0][2]))
    links = []
    for (kind, src, dst), pk in paths.items():
        pk.sort(key=lambda q: q[0])
        chunks = [pk[i:i + 128] for i in range(0, len(pk), 128)]        # one transfer = 128 packets; skew sends twice
        for ordinal, ch in enumerate(chunks):
            lab = label.get((kind, src, dst, ordinal), "?")
            hops = len(ch[0][1]) - 1
            for h in range(hops):
                up = [q[1][h][0] for q in ch]; dn = [q[1][h + 1][0] for q in ch]
                a, b = ch[0][1][h][1], ch[0][1][h + 1][1]
                links.append(dict(g=lab, t="x" if kind != "w" else "w", kind=kind, col=ch[0][2], hop=h + 1, hops=hops, sx=a[0], sy=a[1], tx=b[0], ty=b[1],
                                  start=min(up), end=max(dn) + 1, n=len(ch), per_hop=sorted({d - u for u, d in zip(up, dn)})))
    links.sort(key=lambda l: (l["start"], l["g"], l["hop"]))
    # ---- ops: runs of same-tag dispatches per PE
    tags, fns_i, instr_i = [], [], []
    def idx(lst, v):
        if v not in lst: lst.append(v)
        return lst.index(v)
    ops = {}
    for pe, L in disp.items():
        L.sort(); runs = []
        for c, name, ut, nd, pc in L:
            d = dis[pe].get(pc, {}); asm = d.get("instruction", name.lower()); src = (d.get("source") or "").strip(); fn = fn_of(pe, pc)
            tg = tag_of(name, ut, nd, asm, fn, src)
            if runs and runs[-1][2] == tg and runs[-1][3] == idx(fns_i, fn) and c - runs[-1][1] <= 3:
                runs[-1][1] = c; runs[-1][5] += 1
                if src and not runs[-1][6]: runs[-1][6] = src[:90]
            else:
                runs.append([c, c, tg, idx(fns_i, fn), idx(instr_i, asm[:60]), 1, src[:90]])
        ops[f"{pe[0]},{pe[1]}"] = [[a, b, idx(tags, tg), fi, ii, n, s] for a, b, tg, fi, ii, n, s in runs]
    events = sorted({c for l in links for c in (l["start"], l["end"])} | {c for iv in compute.values() for a, b, _ in iv for c in (a, b)})
    tiles = sorted({l["g"] for l in links})
    out = dict(start=t0, end=t1, compute=compute, links=links, ops=ops, tags=tags, fns=fns_i, instrs=instr_i, events=events, tiles=tiles,
               window_note=f"repeat 1: skew start - 150 to last FMACH of step 4 + 80 ({t1 - t0 + 1:,} cycles)",
               checks=dict(transfers_labelled=[sum(1 for l in links if l["g"] != "?" and l["hop"] == 1), sum(1 for l in links if l["hop"] == 1)],
                           packets_per_transfer=sorted({l["n"] for l in links}), dispatch_runs=sum(len(v) for v in ops.values()),
                           dispatches=sum(len(v) for v in disp.values())))
    (STUDY / "results/datapath/meshgemm_cycles.json").write_text(json.dumps(out, separators=(",", ":")))
    print("window", t0, t1, "links", len(links), "checks", out["checks"], "tags", tags)
    print("-> results/datapath/meshgemm_cycles.json", round((STUDY / "results/datapath/meshgemm_cycles.json").stat().st_size / 1e6, 2), "MB")

if __name__ == "__main__":
    main()
