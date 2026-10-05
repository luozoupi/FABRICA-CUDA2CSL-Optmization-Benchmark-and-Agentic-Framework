#!/usr/bin/env python3
"""A Cerebras PE, MIPS-style: functional datapath, dependency graph and cycle timeline per walkthrough.

SCOPE.  This is a FUNCTIONAL model: which resources an instruction reads and writes (PC, GPR file,
DSR file, descriptor memory, data SRAM, address generators, scalar unit, SIMD lanes, condition
flags, fabric queues, task activation) and the dependencies that follow.  It is NOT a reconstruction
of pipeline registers, ports, multiplexers or forwarding networks -- the trace records exactly two
timing anchors per instruction, the stage-3 (decode) record and the stage-6 (execute) records,
plus dispatch, redispatch and wavelet records.  Fetch timing, what stages 4-5 do, operand-read
timing and writeback timing are left unspecified.  This SDK's trace has no execute-idle records, so
nothing here is inferred from their absence.

EVIDENCE LABELS.  Every timing statement carries one of three: `dependency identified` (a
producer-consumer relation exists), `delay observed` (the trace shows a gap; cause not isolated),
`stall cause supported` (microbench/pcsweep varied the producer-consumer distance and the delay
followed it).  The pcsweep results are read from disk and quoted, never restated from memory.

Per dynamic instruction the model retains: PE, uid, PC, task colour, microthread id, decoded
operands, every dispatch (including redispatch), the decode record and ALL execute records with
element index and lane.
"""
from __future__ import annotations
import gzip, json, re, sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))
from anatomy_common import load_pipe, load_disasm, typed_for, wavelet_fields, ladder, FABRIC_LADDER

HERE = Path(__file__).resolve().parent.parent
MB = HERE / "microbench"
MEMCPY_COLOURS = {0, 1, 2, 3, 4, 5, 21, 22, 23}

# ============================================================ trace -> dynamic instructions
def load_dyn(events: Path, tiles: set, disasm_by_tile: dict):
    """Every dynamic instruction on the given tiles, with all its records."""
    disp, wav, coord = {}, {}, {}
    with gzip.open(events, "rt") as fh:
        for line in fh:
            e = json.loads(line); t = e.get("tile_index")
            if t not in tiles: continue
            if t not in coord:
                sim = (e.get("coordinates") or {}).get("simulator") or {}
                if sim.get("x") is not None: coord[t] = (sim["x"], sim["y"])
            k = e.get("event_type")
            if k == "hwm_dispatch_trace_entry":
                disp.setdefault((t, e["uid"]), []).append({"cycle": e["cycle"], "pc": e.get("inst_ptr"), "nd": e.get("num_data"),
                                                            "task": e.get("task_color"), "ut": e.get("ut_id"), "name": e.get("name")})
            elif k == "wavelet_trace_entry":
                wav.setdefault(t, []).append({"cycle": e["cycle"], "ident": e.get("ident"), "data": e.get("data"), **wavelet_fields(e.get("fields") or 0)})
    pipe = load_pipe(events, tiles)
    out = {}
    for (t, uid), ds in disp.items():
        ds.sort(key=lambda d: d["cycle"]); d0 = ds[0]
        dis = disasm_by_tile.get(t, {}).get(d0["pc"])
        text = dis["text"] if dis else (d0["name"] or "?").lower()
        p = pipe.get((t, uid), {})
        nd = d0["nd"] if isinstance(d0["nd"], int) and d0["nd"] < 65535 else 1
        mn = text.split()[0] if text else "?"
        elems = [{"cycle": x["cycle"], "idx": x["idx"], "lane": x["lane"], "dest": typed_for(mn, x["dest"]), "src0": typed_for(mn, x["src0"], "src0"),
                  "src1": typed_for(mn, x["src1"], "src1"), "src2": typed_for(mn, x["src2"], "src2")} for x in p.get("elems", [])]
        xs = sorted({x["cycle"] for x in p.get("elems", [])}) or ([p["exe"]] if p.get("exe") is not None else [])
        out[(t, uid)] = {"tile": t, "pe": coord.get(t), "uid": uid, "pc": d0["pc"], "text": text, "mnemonic": mn,
                         "origin": dis["origin"] if dis else "no-disasm", "task": d0["task"], "ut": d0["ut"], "nd": nd,
                         "dispatches": [d["cycle"] for d in ds], "dispatch": d0["cycle"], "redispatch": ds[1]["cycle"] if len(ds) > 1 else None,
                         "decode": p.get("dec"), "x_cycles": xs, "x_first": xs[0] if xs else None, "x_last": xs[-1] if xs else None,
                         "n_x": len(p.get("elems", [])), "elems": elems}
    seq = sorted(out.values(), key=lambda i: (i["tile"], i["dispatch"]))
    for i in seq: i.update(resources(i["text"]))
    return seq, wav, coord

# ============================================================ operands -> functional resources
REG = r"\b(?:r\d+|d\d+|sp)\b"
def resources(text: str, stream_hint: dict | None = None):
    """Resources read and written, by class. Streams through DSRs are 'sram-stream' unless a hint
    says a DSR names a fabric queue (that fact comes from the CSL source, not the encoding)."""
    hint = stream_hint or {}
    t = text.strip(); pred = re.match(r"^(!?)(cflag\d+) \? ", t)
    if pred: t = t[pred.end():]
    mn = t.split()[0] if t else "?"
    reads, writes, unit = [], [], "alu"
    if pred: reads.append(("cflag", pred.group(2)))
    lhs, rhs = (t.split("=", 1) + [""])[:2] if "=" in t else ("", t.split(" ", 1)[1] if " " in t else "")
    def classify(tok, is_dest):
        tok = tok.strip()
        if not tok: return
        m = re.fullmatch(r"\[(dds\d|s0ds\d|s1ds\d)\]", tok)
        if m:
            d = m.group(1); reads.append(("dsr", d))
            kind = hint.get(d, "sram-stream")
            (writes if is_dest else reads).append((kind, f"via {d}")); return
        m = re.fullmatch(r"\[(0x[0-9a-f]+|r\d+|sp\[[^\]]*\]|sp)\]", tok) or re.fullmatch(r"(sp\[[^\]]*\])", tok)
        if m:
            addr = m.group(1)
            if addr.startswith("r"): reads.append(("gpr", addr))
            (writes if is_dest else reads).append(("sram", addr)); return
        if re.fullmatch(r"(dds|s0ds|s1ds)\d", tok): (writes if is_dest else reads).append(("dsr", tok)); return
        if re.fullmatch(REG, tok): (writes if is_dest else reads).append(("gpr", tok)); return
        if tok.startswith("cflag"): (writes if is_dest else reads).append(("cflag", tok)); return
        if re.fullmatch(r"-?0x[0-9a-f]+|-?\d+", tok): reads.append(("imm", tok)); return
        reads.append(("other", tok))
    if mn.startswith(("lddwds", "lds0wds", "lds1wds")):
        unit = "dsr-load"; classify(lhs.split()[1], True)
        m = re.search(r"\[(0x[0-9a-f]+)\]", rhs); reads.append(("dmem", m.group(1) if m else rhs.strip()))
    elif mn.startswith("jmp"): unit = "sequencer"; writes.append(("pc", rhs.strip()))
    elif mn.startswith("actvt"): unit = "task"; writes.append(("task", rhs.strip()))
    elif mn.startswith(("ublk", "blk")): unit = "task"; writes.append(("task", rhs.strip()))
    elif mn.startswith("nop"): unit = "none"
    else:
        if lhs:
            for tok in " ".join(lhs.split()[1:]).split(","): classify(tok, True)
        for tok in rhs.split(","): classify(tok, False)
        if any(k in ("dsr",) for k, _ in reads) and any(k.endswith("stream") or k.startswith("fab") for k, _ in reads + writes):
            unit = "lanes"                       # a DSD op: address generators + SIMD lanes
        elif mn.startswith(("ld16", "ld32", "ld16rp")) or (mn.startswith("imov16") and any(k == "sram" for k, _ in reads)): unit = "load"
        elif mn.startswith(("st16", "st32")) or (mn.startswith("imov16") and any(k == "sram" for k, _ in writes)): unit = "store"
        elif mn.startswith(("lt16", "ltu16", "eq16", "eq32", "lt32", "ne16")): unit = "compare"
        elif mn.startswith(("faddh", "fsubh", "fmulh", "fmach", "fadds", "fmuls", "fmacs", "fh2s", "fs2h", "fmov")): unit = "fp"
        elif mn.startswith("movri"): unit = "imm"
    return {"reads": reads, "writes": writes, "unit": unit, "predicated": bool(pred)}

# ============================================================ dependency graph
DEP_CLASS = {"gpr": "gpr", "dsr": "dsr", "cflag": "cflag", "sram": "mem", "task": "task", "fabin": "fabric", "fabout": "fabric", "sram-stream": "stream"}
def dependencies(win):
    """Dynamic RAW / WAR / WAW edges over the window's resources. Streams and fabric are matched
    by name only where the same DSR or address recurs; a stream's memory footprint is not enumerated."""
    edges = []; last_write = {}; last_reads = {}
    for j, ins in enumerate(win):
        for kind, name in ins["reads"]:
            if kind in ("imm", "other", "dmem"): continue
            key = (kind, name)
            if key in last_write and last_write[key] != j:
                i = last_write[key]; edges.append(("RAW", DEP_CLASS.get(kind, kind), name, i, j))
            last_reads.setdefault(key, []).append(j)
        for kind, name in ins["writes"]:
            key = (kind, name)
            if key in last_write and last_write[key] != j: edges.append(("WAW", DEP_CLASS.get(kind, kind), name, last_write[key], j))
            for r in last_reads.get(key, []):
                if r != j and (key not in last_write or last_write[key] < r): edges.append(("WAR", DEP_CLASS.get(kind, kind), name, r, j))
            last_write[key] = j; last_reads[key] = []
    out = []
    for kind, cls, name, i, j in edges:
        P, C = win[i], win[j]
        out.append({"kind": kind, "cls": cls, "resource": name, "producer": i, "consumer": j,
                    "spacing": C["dispatch"] - P["dispatch"],
                    "x_gap": (C["x_first"] - P["x_last"]) if C["x_first"] is not None and P["x_last"] is not None else None})
    return out

# ============================================================ controlled-experiment support
def sweep_support():
    """Per sweep class: the dispatch bubble and the execute-stage delay as functions of filler count.

    Two different stall signatures exist and the sweep separates them.  A DISPATCH bubble means the
    consumer could not enter the pipeline until some cycles after the producer (spacing beyond one
    per instruction).  An EXECUTE-STAGE delay means the consumer dispatched on time and then sat in
    the execute stage, emitting placeholder records, until its value record landed (decode -> value
    record beyond the usual 3).  Both are read from the trace; `verdict` says which was found and at
    what filler count it vanished."""
    p = MB / "pcsweep" / "results.json"
    if not p.exists(): return {}
    R = json.loads(p.read_text()); out = {}
    for name, r in R.items():
        rows = [x for x in r["pairs"] if "error" not in x]
        if not rows: continue
        sw = sorted((x for x in rows if not x.get("prepared")), key=lambda x: x["k_nop"])
        by_k = [(x["k_nop"], x["dispatch_bubble"], x.get("exec_delay"), x.get("cons_dx_value"), x.get("next_disp_gap"), x.get("taken")) for x in sw]
        prep = next((x for x in rows if x.get("prepared")), None)
        b0, bfar = sw[0]["dispatch_bubble"], sw[-1]["dispatch_bubble"]
        e0, efar = sw[0].get("exec_delay"), sw[-1].get("exec_delay")
        bvan = next((x["k_nop"] for x in sw if x["dispatch_bubble"] == 0), None)
        evan = next((x["k_nop"] for x in sw if (x.get("exec_delay") or 0) == 0), None)
        if b0 and bfar and bfar > 0:
            verdict = f"the consumer's dispatch is held {bfar} cycles at every spacing — the producer occupies the issue slot for its own duration and fillers do not change it (they dispatch in the gaps between its element records); on top of that the consumer's value record lands {e0} cycle(s) late at k=0, gone at k={evan}"; kind = "occupancy"
        elif b0 and bfar == 0:
            verdict = f"stall cause supported, at dispatch: the consumer cannot dispatch until {sw[0]['spacing']} cycles after the producer; the bubble shrinks one-for-one with fillers and is gone at k={bvan}"; kind = "dispatch"
        elif e0 and efar == 0:
            verdict = f"stall cause supported, at the execute stage: the consumer dispatches on time but its value record lands {e0} cycle(s) late; gone at k={evan}"; kind = "execute"
        elif (b0 or 0) == 0 and (e0 or 0) == 0:
            verdict = "no stall: no dispatch bubble and no execute-stage delay at any spacing"; kind = "none"
        else:
            verdict = "delay observed but not filler-dependent"; kind = "observed"
        out[name] = {"producer": rows[0]["producer"], "consumer": rows[0]["consumer"], "by_k": by_k, "kind": kind,
                     "bubble_at_0": b0, "bubble_far": bfar, "exec_at_0": e0, "exec_far": efar, "vanishes_at_k": bvan if kind == "dispatch" else evan,
                     "verified": r["verify"]["ok"], "timing_only": r["meta"].get("expect") == "none",
                     "prepared": None if not prep else {"spacing": prep["spacing"], "cons_dx": prep.get("cons_dx_value") or prep.get("cons_dx")},
                     "verdict": verdict}
    return out
# dependency class of an edge -> the sweep class that tested it (first one present wins)
CLASS_TO_SWEEP = {"dsr": ["dsr_s1last", "dsr_s0last", "dsr_dlast"], "gpr": ["gpr"], "cflag": ["cflag_jmp"], "mem": ["mem"]}
# a RAW gpr edge whose producer and consumer are both FP ops is the f16 chain; both integer ALU ops, the i16 chain
def sweep_for(edge, win):
    P, C = win[edge["producer"]], win[edge["consumer"]]
    if edge["cls"] == "gpr":
        if P["unit"] == "fp" and C["unit"] == "fp": return ["f16chain_asm", "f16dep"]
        if P["unit"] == "alu" and C["unit"] == "alu": return ["i16chain_asm", "i16dep"]
        if P["unit"] == "load": return ["gpr"]
        if P["unit"] == "lanes" and C["unit"] == "store": return ["reduce"]
        return []
    return CLASS_TO_SWEEP.get(edge["cls"], [])

# ============================================================ walkthrough windows
def window(seq, tile, start_re, before=0, after=0, start_after_cycle=0, occurrence=0):
    """A window of consecutive APPLICATION instructions (origin 'app') around the occurrence-th match.
    Runtime (<memcpy>) instructions are excluded from the search so a walkthrough never lands on
    harness code; they are still counted in the timeline if they fall inside the window's cycles."""
    s = [i for i in seq if i["tile"] == tile and i["dispatch"] >= start_after_cycle and i["origin"] == "application"]
    hits = [k for k, i in enumerate(s) if re.search(start_re, i["text"])]
    if len(hits) <= occurrence: return []
    k = hits[occurrence]; return s[max(0, k - before): k + after + 1]

def wt(title, role, win, ladder_key=None, csl=None, notes=None, unknowns=None, support=None, stream_hints=None, wavelets=None, extra_ladder=None):
    if stream_hints:
        for ins in win:
            if ins["uid"] in stream_hints: ins.update(resources(ins["text"], stream_hints[ins["uid"]]))
    c0 = min(i["dispatch"] for i in win) if win else 0
    for k, ins in enumerate(win): ins["idx"] = k; ins["d_rel"] = ins["dispatch"] - c0; ins["x_rel"] = [x - c0 for x in ins["x_cycles"]]; ins["red_rel"] = (ins["redispatch"] - c0) if ins["redispatch"] else None
    deps = dependencies(win); sup = sweep_support()
    for e in deps:
        cands = [c for c in sweep_for(e, win) if c in sup]
        sw = cands[0] if cands else None
        e["support"] = sup.get(sw) if sw else None; e["support_name"] = sw
    return {"title": title, "role": role, "c0": c0, "instrs": win, "deps": deps, "ladder": ladder(ladder_key) if ladder_key else extra_ladder, "csl": csl,
            "notes": notes or [], "unknowns": unknowns or [], "wavelets": [{**w, "rel": w["cycle"] - c0} for w in (wavelets or [])]}

COMMON_UNKNOWNS = ["fetch timing (no trace record)", "what stages 4 and 5 do, and where an extra decode→execute delay sits",
                   "when operands are read from the GPR/DSR file relative to the decode record", "writeback timing (no trace record)"]

def main():
    W = []
    # ---- 1. scalar load-add-store (atomic_add, -O2)
    A = MB / "atomic_add"; disA = {12: load_disasm(A / "disasm.json")}
    seqA, _, _ = load_dyn(A / "events.jsonl.gz", {12}, disA)
    win = window(seqA, 12, r"^add16\.nf r", before=2, after=1, start_after_cycle=5000)
    W.append(wt("Scalar load, add, store", "the four-instruction form every scalar operation reduces to", win, "scalar_i16", "ci[0] = ai[0] + bi[0];",
        notes=["Each instruction has one decode record and one execute record, three cycles apart, and dispatches one per cycle: the add reads registers written by loads that executed one and two cycles before it.",
               "The trace's execute records carry the operand values: the values in the table are what the datapath used, not a recomputation."],
        unknowns=COMMON_UNKNOWNS + ["whether the load→add distance of 1 dispatch involves forwarding or a register-file read: both fit the records (see pcsweep `gpr` for the controlled test)"]))
    # ---- 2. descriptor load -> vector op (atomic_add dsd8)
    win = window(seqA, 12, r"^faddh \[dds", before=3, after=1, start_after_cycle=5000)
    W.append(wt("Descriptor load, then a vector operation", "descriptor control state is loaded into DSRs; the vector op reads its data through them", win, "dsd8", "@faddh(c8, a8, b8);",
        notes=["The three `ld*wds` move descriptor words from descriptor memory into the DSR file. They load control state — base, length, stride — not operands: no data element moves until the vector op.",
               "The vector op reads the three DSRs, drives the address generators over SRAM, and produces one execute record per element with its SIMD lane. For 8 elements all records land in one cycle.",
               "The instruction after the op dispatches 4 cycles after the op's last execute record; nothing in the trace says what fills those 4 cycles."],
        unknowns=COMMON_UNKNOWNS + ["what the 4-cycle interval between the op's last execute record and the next dispatch is (drain, issue policy, or something else)",
                                    "whether cycles inside a longer op's execute window with no record for it are lanes running or idle"]))
    # ---- 3a. dependent f16 pair (atomic_ops optnone) and 3b. the 8-element reduction
    O = MB / "atomic_ops"; opt = O / "ir_cap" / "optnone_sim"
    disO = {12: load_disasm(opt / "disasm_optnone.json")}; seqO, _, _ = load_dyn(opt / "events_optnone.jsonl.gz", {12}, disO)
    win = window(seqO, 12, r"^fmulh r", before=2, after=3, start_after_cycle=5000, occurrence=1)
    W.append(wt("Dependent floating-point pair", "a multiply whose result feeds an add: the dependency is in a register", win, "fma_f16", "cf[1] = af[0] * bf[0] + af[1];",
        notes=["`fmulh` writes r5; `faddh` reads r5 one load later. The decode→execute of the consumer is what the dependency can lengthen; the load between them is an operand fetch, not a filler."],
        unknowns=COMMON_UNKNOWNS + ["the f16 dependent latency in isolation: pcsweep `f16dep` varies the distance (see its table)"]))
    win = window(seqO, 12, r"^faddh r\d+ = r\d+, \[s1ds", before=2, after=1, start_after_cycle=5000)
    W.append(wt("An eight-element reduction: a dependent chain inside one instruction", "each element depends on the accumulator the previous element produced", win, "dsd_reduce8", "@faddh(&acc, acc, a8);\ncf[3] = acc;",
        notes=["One instruction, eight execute records, two cycles apart: the accumulator dependency serialises the elements. The consuming store dispatches long before the last element executes — the clearest case of dispatch not being availability."],
        unknowns=COMMON_UNKNOWNS + ["whether the 2-cycle element spacing is the same mechanism as the scalar dependent-f16 latency (not tested separately)"]))
    # ---- 4a. conditional control as a jump (optnone) and 4b. as predication (-O2)
    win = window(seqO, 12, r"cflag0 \? jmp", before=4, after=1, start_after_cycle=5000)
    W.append(wt("Conditional control as a jump", "a compare writes a flag; a predicated jump reads it", win, "br_taken", "if (ai[2] < bi[2]) { ci[7] = 11; } else { ci[7] = 22; }",
        notes=["The compare writes `cflag0`; the jump reads it. The jump has no execute record, so where it resolves is not observed. The instruction after it dispatches 3 cycles later."],
        unknowns=COMMON_UNKNOWNS + ["where a jump resolves (no execute record exists for it)", "whether the 3-cycle gap after a jump is a fetch redirect, a flag-dependency wait, or issue policy: pcsweep `cflag_jmp` varies the compare→jump distance"]))
    disO2 = {12: load_disasm(O / "disasm.json")}; seqO2, _, _ = load_dyn(O / "events.jsonl.gz", {12}, disO2)
    win = window(seqO2, 12, r"^lt16\.and cflag0", before=2, after=4, start_after_cycle=5000)
    W.append(wt("Conditional control as predication", "the optimiser replaced the branch with a flag-guarded move", win, "br_taken", "if (ai[2] < bi[2]) { ci[7] = 11; } else { ci[7] = 22; }",
        notes=["Same source, optimised build: no jump. The predicated move reads the flag one dispatch after the compare and, when the predicate is false, leaves no execute record — it is squashed, not executed as a no-op."],
        unknowns=COMMON_UNKNOWNS + ["whether a squashed predicated instruction occupies an execute-unit cycle (no record either way)"]))
    # ---- 5. fabric receive followed by computation (relay_compute)
    RC = MB / "relay_compute"
    if (RC / "events.jsonl.gz").exists() and (RC / "disasm_pe1.json").exists():
        disR = {20: load_disasm(RC / "disasm_pe0.json"), 21: load_disasm(RC / "disasm_pe1.json")}
        seqR, wavR, coordR = load_dyn(RC / "events.jsonl.gz", {20, 21}, disR)
        app_w = {t: [w for w in wavR.get(t, []) if w["colour"] not in MEMCPY_COLOURS] for t in (20, 21)}
        send = next(i for i in seqR if i["tile"] == 20 and i["nd"] > 1 and i["mnemonic"].startswith("fmov32"))
        recv = next(i for i in seqR if i["tile"] == 21 and i["nd"] > 1 and i["mnemonic"].startswith("fmov32"))
        add = next(i for i in seqR if i["tile"] == 21 and i["mnemonic"].startswith("fadds") and i["dispatch"] > recv["dispatch"])
        lo = min(send["dispatch"], recv["dispatch"]) - 3; hi = add["x_last"] + 6
        win = [i for i in seqR if lo <= i["dispatch"] <= hi and (i["tile"] == 21 or i["tile"] == 20 and i["dispatch"] <= send["dispatch"] + 4) and i["origin"] != "runtime"]
        hints = {send["uid"]: {"dds1": "fabout", "dds0": "fabout"}, recv["uid"]: {"s1ds1": "fabin", "s1ds0": "fabin"}}
        for ins in win:
            if ins["uid"] in hints and ins["tile"] in (20, 21):
                h = hints[ins["uid"]]; ins.update(resources(ins["text"], h))
        res = json.loads((RC / "result.json").read_text()) if (RC / "result.json").exists() else {}
        w5 = wt("Fabric receive, then compute", "wavelets → input queue → a microthreaded receive → task activation → a vector add on the received data", win, None,
            "// PE0\n@fmovs(fout, buf_dsd, .{ .async = true, .activate = SEND_DONE });\n// PE1\n@fmovs(buf_dsd, fin, .{ .async = true, .activate = RECV_DONE });\ntask recv_done() void { @fadds(res_dsd, buf_dsd, loc_dsd); ... }",
            notes=["PE0's send and PE1's receive are both ordinary DSD copies (`fmov32.nf`); the fabric role comes from the descriptor, fabout or fabin, and both run as microthread 6 (µt6 in the table). The send's eight elements produced execute records in two cycles, four lanes each; its wavelets left PE0's ramp one per cycle from +7 and reached PE1's link two cycles later.",
                   f"Ordering here is the reverse of the relay run: the host's RPC reached PE1 later, so its receive was dispatched at +{recv['dispatch']-lo-3} — some forty cycles after the last wavelet had arrived. The data waited in the input queue. The receive was still redispatched, 2 cycles after its first dispatch, where the relay's receive (dispatched before any data existed) was redispatched 19 cycles later when the first wavelet arrived: the redispatch marks the source queue becoming non-empty, whichever side was late <span class='ev ev-delay'>delay observed</span>.",
                   "The receive drained the queue as 4, 2 and 2 elements in three record cycles two cycles apart. The completion task's first instruction dispatched in the same cycle as the receive's last element record — task activation from microthread completion showed no visible gap in this one instance <span class='ev ev-delay'>delay observed</span>.",
                   "Inside the task, the add's three descriptor loads precede it by 4 cycles from the last load to the op — the same DSR load-use spacing pcsweep measured — and its eight f32 elements executed in two cycles, four lanes each. Their execute records carry the verified sums (7.75 = −2.25 + 10.0, …). The fabric copies' own execute records carry no payload values (they read as 0), so the values of a message are visible only where it is consumed.",
                   f"Values verified end to end: received buffer {'matches' if res.get('received_ok') else 'DOES NOT MATCH'} what PE0 sent, res = buf + loc {'exact' if res.get('res_ok') else 'WRONG'}." if res else "No result.json yet."],
            unknowns=COMMON_UNKNOWNS + ["how the router→queue→microthread hand-off is timed at finer than the redispatch record", "microthread scheduling policy when more than one is live",
                                        "the cost of task activation itself, from the completion record to the task's first dispatch (observed here for one instance; not swept)"],
            extra_ladder=FABRIC_LADDER, wavelets=sorted(app_w[20] + app_w[21], key=lambda w: w["cycle"]), stream_hints=hints)
        w5["two_pe"] = True; w5["coord"] = {str(t): list(c) for t, c in coordR.items()}
        W.append(w5)
    else:
        W.append({"title": "Fabric receive, then compute", "role": "pending: microbench/relay_compute has not produced a trace yet", "instrs": [], "deps": [], "notes": [], "unknowns": [], "wavelets": [], "c0": 0, "ladder": FABRIC_LADDER, "csl": ""})
    data = {"walkthroughs": W, "sweep": sweep_support()}
    out = HERE / "results" / "anatomy" / "pe_model.html"
    out.write_text(HTML.replace("__DATA__", json.dumps(data)))
    for w in W: print(f"{w['title']:<60} {len(w['instrs']):>3} instr  {len(w['deps']):>3} deps  wavelets {len(w['wavelets'])}")
    print(f"sweep classes available for support: {sorted(data['sweep'])}")
    print("wrote", out, f"({out.stat().st_size // 1024} KB)")

HTML = r"""<title>A Cerebras PE, MIPS-Style</title>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Spectral:wght@400;600&family=IBM+Plex+Sans:wght@400;500;600&family=IBM+Plex+Mono:wght@400;500&display=swap">
<style>
:root{--ground:#F5F6F4;--surface:#FFFFFF;--sunk:#ECEEEA;--ink:#14181A;--ink-2:#41494B;--muted:#6B7472;--line:#D8DDD8;
  --oxide:#0C6E77;--violet:#5A4B94;--amber:#A8660F;--rose:#A33A5B;--moss:#3F7A3A;--slate:#4A6070;--idle:#E3E8ED;--wait:#F1D7A8}
@media (prefers-color-scheme:dark){:root:not([data-theme="light"]){--ground:#0E1112;--surface:#171B1C;--sunk:#1F2425;--ink:#E8ECE9;--ink-2:#B4BDB9;--muted:#889490;--line:#2A3132;
  --oxide:#54C7CF;--violet:#AC9EE4;--amber:#E8A33F;--rose:#E48AA6;--moss:#8ECC86;--slate:#95ACBC;--idle:#222C35;--wait:#4A3A1C}}
:root[data-theme="dark"]{--ground:#0E1112;--surface:#171B1C;--sunk:#1F2425;--ink:#E8ECE9;--ink-2:#B4BDB9;--muted:#889490;--line:#2A3132;
  --oxide:#54C7CF;--violet:#AC9EE4;--amber:#E8A33F;--rose:#E48AA6;--moss:#8ECC86;--slate:#95ACBC;--idle:#222C35;--wait:#4A3A1C}
*{box-sizing:border-box}body{margin:0;background:var(--ground);color:var(--ink);font-family:"IBM Plex Sans",ui-sans-serif,system-ui,sans-serif;font-size:14.5px;line-height:1.55;font-variant-numeric:tabular-nums}
.wrap{max-width:1180px;margin:0 auto;padding:32px 22px 72px;display:flex;flex-direction:column;gap:30px}
h1{font-family:Spectral,Georgia,serif;font-weight:600;font-size:32px;margin:0;letter-spacing:-.015em;text-wrap:balance}
h2{font-family:Spectral,Georgia,serif;font-weight:600;font-size:21px;margin:0 0 2px;letter-spacing:-.01em;text-wrap:balance}
h3{font-family:Spectral,Georgia,serif;font-weight:600;font-size:15.5px;margin:14px 0 6px}
.eyebrow{font-size:10.5px;letter-spacing:.15em;text-transform:uppercase;color:var(--muted);font-weight:500}
.lede{color:var(--ink-2);max-width:70ch;margin:0}
code,.mono{font-family:"IBM Plex Mono",ui-monospace,Menlo,monospace;font-size:.9em}
header{border-bottom:2px solid var(--ink);padding-bottom:16px;display:flex;flex-direction:column;gap:9px}
section{display:flex;flex-direction:column;gap:10px}
.scroll{overflow-x:auto}
table{border-collapse:collapse;width:100%;font-size:12.5px}
th{font-size:10px;letter-spacing:.1em;text-transform:uppercase;color:var(--muted);text-align:left;padding:5px 8px;border-bottom:1px solid var(--line);font-weight:600;white-space:nowrap}
td{padding:5px 8px;border-bottom:1px solid var(--line);vertical-align:top}
.card{background:var(--surface);border:1px solid var(--line);border-radius:3px;padding:13px 15px}
.ev{display:inline-block;font-size:9.5px;letter-spacing:.08em;text-transform:uppercase;padding:1px 6px;border-radius:2px;border:1px solid;margin-left:4px;vertical-align:1px;white-space:nowrap}
.ev-dep{color:var(--violet);border-color:var(--violet)}.ev-delay{color:var(--amber);border-color:var(--amber)}.ev-stall{color:var(--oxide);border-color:var(--oxide)}.ev-none{color:var(--muted);border-color:var(--line)}
.lad{display:grid;grid-template-columns:1fr 1.2fr 1fr;border:1px solid var(--line);border-radius:3px;overflow:hidden;background:var(--surface)}
@media(max-width:820px){.lad{grid-template-columns:1fr}}
.lad>div{padding:10px 13px;border-right:1px solid var(--line)}.lad>div:last-child{border-right:0}
.lad pre{margin:4px 0 0;font-family:"IBM Plex Mono",monospace;font-size:11px;line-height:1.5;white-space:pre-wrap;color:var(--ink)}
.lad p{margin:4px 0 0;font-size:12px;color:var(--ink-2)}
.diverge{padding:8px 12px;border-left:3px solid var(--amber);background:var(--surface);font-size:12px;color:var(--ink-2)}
.views{display:grid;grid-template-columns:1fr;gap:12px}
.pipe{border-collapse:separate;border-spacing:2px;font-family:"IBM Plex Mono",monospace;font-size:10.5px}
.pipe td{padding:0;border:0;width:18px;min-width:18px;height:18px;text-align:center;border-radius:2px;background:var(--idle);color:var(--ink)}
.pipe td.lbl{width:auto;min-width:0;text-align:left;padding:0 8px 0 2px;background:transparent;white-space:nowrap}
.pipe td.tag{width:auto;min-width:0;text-align:left;padding:0 8px 0 0;background:transparent;font-size:9.5px;color:var(--muted);white-space:nowrap}
.pipe td.D{background:var(--violet);color:#fff}.pipe td.X{background:var(--oxide);color:#fff}.pipe td.Xm{background:var(--oxide);color:#fff;opacity:.72}.pipe td.Xl{background:var(--oxide);color:#fff;outline:2px solid var(--ink);outline-offset:-2px}
.pipe td.R{background:var(--violet);color:#fff;opacity:.6}.pipe td.w{background:var(--wait)}.pipe td.wv{background:var(--moss);color:#fff;border-radius:50%}
.pipe th{padding:0;text-align:center;font-size:9px;border:0;color:var(--muted)}
svg text{font-family:"IBM Plex Mono",monospace}
.unk{font-size:12.5px;color:var(--ink-2);margin:0;padding-left:18px}.unk li{margin:2px 0}
.small{font-size:12px;color:var(--ink-2)}
.r-gpr{color:var(--oxide)}.r-dsr{color:var(--violet)}.r-sram{color:var(--amber)}.r-cflag{color:var(--rose)}.r-fab{color:var(--moss)}.r-task{color:var(--slate)}.r-pc{color:var(--rose)}
</style>
<div class="wrap">
<header>
  <div class="eyebrow">Cerebras WSE-3 · one processing element · SDK 2.10 · simulator traces</div>
  <h1>A Cerebras PE, MIPS-Style</h1>
  <p class="lede">Follow an instruction: where its operands come from, what depends on it, and when the trace says things happened. Five walkthroughs, each with a functional datapath view, a dependency graph and a cycle timeline. This is a model of <em>resources and functions</em>, not of pipeline wiring: the trace anchors exactly two moments per instruction — its decode record and its execute records — and everything between them is left unspecified.</p>
</header>

<section>
  <div class="eyebrow">what is and is not claimed</div>
  <div class="card small">
    <p style="margin:0 0 8px"><strong>Resources</strong> (what an instruction reads and writes) and <strong>stages</strong> (when work happens) are kept separate below. The resources are read from the disassembly and from the operand values the execute records carry. The stages are the two the trace records: <span class="mono">D</span> is the stage-3 decode record, <span class="mono">X</span> is a stage-6 execute record, of which a vector instruction has one per element. Fetch, the responsibilities of stages 4–5, operand-read timing and writeback timing are <em>not</em> observed and are not drawn. The trace also has no execute-idle records, so no bubble is inferred from a missing row.</p>
    <p style="margin:0">Every timing statement carries a label: <span class="ev ev-dep">dependency identified</span> a producer–consumer relation exists in the code; <span class="ev ev-delay">delay observed</span> the trace shows a gap whose cause is not isolated; <span class="ev ev-stall">stall cause supported</span> <code>microbench/pcsweep</code> varied the distance between that producer and consumer and the delay followed it. The sweep's own numbers are quoted from its results file, per dependency class, wherever they apply.</p>
  </div>
</section>

<section>
  <div class="eyebrow">the functional datapath</div>
  <h2>Resources an instruction can touch</h2>
  <div class="card scroll" id="datapath"></div>
  <p class="small" style="margin:0">The descriptor path is drawn apart from the operand path on purpose: <code>ld*wds</code> moves descriptor words into the DSR file and moves no operand anywhere. A vector instruction then reads those DSRs and drives the address generators, and only then does data move. In each walkthrough the steps the instructions take are numbered on this figure and listed beside it.</p>
</section>

<div id="walkthroughs"></div>

<section>
  <div class="eyebrow">controlled experiments</div>
  <h2>What the producer–consumer sweep established</h2>
  <p class="lede">For each dependency class, a producer and its consumer were separated by 0 to 24 independent <code>nop</code> instructions in an <code>optnone</code> rebuild, so the sequence survived compilation exactly (verified from the disassembly). Two stall signatures are read separately. The <em>dispatch bubble</em> is the spacing beyond one cycle per instruction: the consumer could not enter the pipeline. The <em>execute-stage delay</em> is decode-to-value-record beyond the usual 3: the consumer entered on time and then waited in the execute stage, emitting placeholder records (the first execute record of a delayed instruction carries sentinel operands; the value lands in the last). A dependency whose signature shrinks one-for-one with fillers and vanishes is a stall with that latency; one showing neither at zero fillers is not a stall at all. Not-taken jumps leave no execute record, so their execute-stage delay is undefined.</p>
  <div id="sweep"></div>
</section>
</div>
<script>
const D = __DATA__;
const esc = s => String(s ?? "").replace(/&/g,"&amp;").replace(/</g,"&lt;");
const RES = [
  ["pc","PC / sequencer",30,30],["imem","instruction memory\n(unobserved)",30,110],["gpr","GPR file\nr0–r15, d0–d7",260,30],["cflag","condition flags\ncflag0…",260,110],
  ["dmem","descriptor memory\n(low SRAM words)",490,190],["dsr","DSR file\ndds · s0ds · s1ds",490,110],["agen","address\ngenerators",700,110],
  ["sram","data SRAM\n48 KB, 8 banks",700,190],["alu","scalar unit\nint · f16 · f32",260,190],["lanes","SIMD lanes ×8",700,30],
  ["fabin","fabric in queue",920,110],["fabout","fabric out queue",920,190],["task","task activation\nlocal · data · control",920,30]];
const POS = Object.fromEntries(RES.map(r => [r[0], {x: r[2], y: r[3], w: 190, h: 52}]));
const KIND2RES = {gpr:"gpr", dsr:"dsr", dmem:"dmem", sram:"sram", "sram-stream":"sram", fabin:"fabin", fabout:"fabout", cflag:"cflag", pc:"pc", task:"task", imm:null, other:null};
const UNIT2RES = {load:"sram", store:"sram", alu:"alu", fp:"alu", compare:"alu", imm:"alu", "dsr-load":"dsr", lanes:"lanes", sequencer:"pc", task:"task", none:null};
function datapathSVG(steps){
  const W = 1140, H = 265;
  let g = `<svg viewBox="0 0 ${W} ${H}" width="${W}" height="${H}" style="display:block;max-width:none">`;
  for (const [id, label, x, y] of RES){
    const used = steps.some(s => s.res.includes(id));
    g += `<rect x="${x}" y="${y}" width="190" height="52" rx="3" fill="var(--surface)" stroke="${used ? 'var(--oxide)' : 'var(--line)'}" stroke-width="${used ? 2 : 1}"/>`;
    label.split("\n").forEach((l, i) => g += `<text x="${x+95}" y="${y+21+i*15}" font-size="${i?10:11.5}" text-anchor="middle" fill="${i?'var(--muted)':'var(--ink)'}" font-weight="${i?400:600}">${esc(l)}</text>`);
  }
  // control path emphasised: dmem -> dsr -> agen -> sram
  const arrow = (a, b, color, dash, n) => { const A = POS[a], B = POS[b]; if (!A || !B) return "";
    const x1 = A.x + A.w/2, y1 = A.y + A.h/2, x2 = B.x + B.w/2, y2 = B.y + B.h/2;
    const dx = x2 - x1, dy = y2 - y1, L = Math.hypot(dx, dy) || 1, ux = dx/L, uy = dy/L;
    const sx = x1 + ux*98, sy = y1 + uy*28, ex = x2 - ux*98, ey = y2 - uy*28;
    const mx = (sx+ex)/2, my = (sy+ey)/2;
    return `<line x1="${sx}" y1="${sy}" x2="${ex}" y2="${ey}" stroke="${color}" stroke-width="1.6" ${dash?'stroke-dasharray="5 4"':''} marker-end="url(#ah)"/>` +
           (n !== undefined ? `<circle cx="${mx}" cy="${my}" r="8" fill="${color}"/><text x="${mx}" y="${my+3.5}" font-size="9" text-anchor="middle" fill="#fff" font-weight="600">${n}</text>` : ""); };
  g += `<defs><marker id="ah" markerWidth="8" markerHeight="8" refX="7" refY="4" orient="auto"><path d="M0,0 L8,4 L0,8 z" fill="var(--muted)"/></marker></defs>`;
  for (const s of steps) for (const [a, b] of s.arrows) g += arrow(a, b, s.color, s.dash, s.n);
  return g + `</svg>`;
}
function stepsOf(ins){
  const unit = UNIT2RES[ins.unit]; const steps = [];
  const reads = ins.reads.map(([k]) => KIND2RES[k]).filter(Boolean), writes = ins.writes.map(([k]) => KIND2RES[k]).filter(Boolean);
  const arrows = [];
  if (ins.unit === "dsr-load"){ arrows.push(["dmem","dsr"]); }
  else if (ins.unit === "lanes"){ arrows.push(["dsr","agen"]); if (reads.includes("sram")) arrows.push(["agen","sram"],["sram","lanes"]); if (reads.includes("fabin")) arrows.push(["fabin","lanes"]); if (writes.includes("sram")) arrows.push(["lanes","sram"]); if (writes.includes("fabout")) arrows.push(["lanes","fabout"]); if (writes.includes("gpr")) arrows.push(["lanes","gpr"]); if (reads.includes("gpr")) arrows.push(["gpr","lanes"]); }
  else if (ins.unit === "load"){ arrows.push(["sram","gpr"]); if (reads.includes("gpr")) arrows.push(["gpr","sram"]); }
  else if (ins.unit === "store"){ arrows.push(["gpr","sram"]); }
  else if (ins.unit === "sequencer"){ if (reads.includes("cflag")) arrows.push(["cflag","pc"]); else arrows.push(["pc","pc"]); }
  else if (ins.unit === "task"){ arrows.push(["pc","task"]); }
  else { for (const r of new Set(reads)) if (r !== "alu") arrows.push([r,"alu"]); for (const w of new Set(writes)) arrows.push(["alu", w]); if (!arrows.length) arrows.push(["alu","gpr"]); }
  const res = [...new Set(arrows.flat())];
  return {arrows, res, dash: ins.unit === "dsr-load" || ins.unit === "task", color: ins.unit === "dsr-load" ? "var(--violet)" : ins.unit === "lanes" ? "var(--oxide)" : ins.unit === "task" || ins.unit === "sequencer" ? "var(--rose)" : "var(--amber)"};
}
document.getElementById("datapath").innerHTML = datapathSVG([]);

const rcls = k => ({gpr:"r-gpr", dsr:"r-dsr", sram:"r-sram", "sram-stream":"r-sram", dmem:"r-sram", cflag:"r-cflag", fabin:"r-fab", fabout:"r-fab", task:"r-task", pc:"r-pc"}[k] || "");
const resList = xs => xs.filter(([k]) => k !== "imm").map(([k, n]) => `<span class="${rcls(k)}">${esc(k)}${n ? " " + esc(n) : ""}</span>`).join(", ") || "<span style='color:var(--muted)'>—</span>";
const evTag = e => { const s = e.support; if (!s) return '<span class="ev ev-dep">dependency identified</span> <span class="ev ev-delay">delay observed</span>';
  if (s.kind === "dispatch") return `<span class="ev ev-stall">stall cause supported</span> <span class="small">pcsweep ${esc(e.support_name)}: dispatch bubble ${s.bubble_at_0} at k=0, gone at k=${s.vanishes_at_k}</span>`;
  if (s.kind === "execute") return `<span class="ev ev-stall">stall cause supported</span> <span class="small">pcsweep ${esc(e.support_name)}: value record ${s.exec_at_0} cycle(s) late at k=0, gone at k=${s.vanishes_at_k}; no dispatch bubble</span>`;
  if (s.kind === "occupancy") return `<span class="ev ev-stall">stall cause supported</span> <span class="small">pcsweep ${esc(e.support_name)}: ${esc(s.verdict)}</span>`;
  if (s.kind === "none") return `<span class="ev ev-dep">dependency identified</span> <span class="ev ev-none">no stall in sweep</span> <span class="small">pcsweep ${esc(e.support_name)}: no dispatch bubble and no execute-stage delay at any spacing</span>`;
  return `<span class="ev ev-dep">dependency identified</span> <span class="ev ev-delay">delay observed</span> <span class="small">pcsweep ${esc(e.support_name)}: ${esc(s.verdict)}</span>`; };

function timeline(w){
  const ins = w.instrs; if (!ins.length) return "";
  const span = Math.max(...ins.map(i => Math.max(i.d_rel, ...(i.x_rel.length ? i.x_rel : [i.d_rel]), i.red_rel ?? 0)), ...w.wavelets.map(x => x.rel)) + 1;
  let t = `<div class="scroll"><table class="pipe"><tr><th></th><th></th>${Array.from({length: span}, (_, i) => `<th>${i % 5 === 0 ? i : ""}</th>`).join("")}</tr>`;
  const wl = w.wavelets.filter(x => x.link === "R"), wa = w.wavelets.filter(x => x.link !== "R");
  const rowW = (label, xs) => `<tr><td class="tag">link</td><td class="lbl">${label}</td>${Array.from({length: span}, (_, c) => { const h = xs.find(x => x.rel === c); return `<td class="${h ? 'wv' : ''}">${h ? 'w' : ''}</td>`; }).join("")}</tr>`;
  for (const i of ins){
    if (w.two_pe && i.tile === 21 && wl.length && !t.includes("leaves")) { t += rowW("wavelets leave PE0's router (ramp)", wl) + rowW("wavelets arrive at PE1's router (link)", wa); }
    let cells = "";
    for (let c = 0; c < span; c++){
      let cls = "", txt = "";
      if (c === i.d_rel){ cls = "D"; txt = "D"; }
      else if (i.red_rel !== null && c === i.red_rel){ cls = "R"; txt = "D"; }
      else if (i.red_rel !== null && c > i.d_rel && c < i.red_rel){ cls = "w"; txt = "…"; }
      else if (i.x_rel.includes(c)){ const k = i.x_rel.indexOf(c); cls = k === 0 ? "X" : (c === i.x_rel[i.x_rel.length-1] ? "Xl" : "Xm"); txt = i.x_rel.length > 1 ? String(i.n_x > 9 ? "" : "") + "X" : "X"; }
      cells += `<td class="${cls}">${txt}</td>`;
    }
    const meta = `${w.two_pe ? `PE(${(w.coord[String(i.tile)]||[]).join(",")}) ` : ""}${i.ut !== 255 && i.ut !== undefined ? `µt${i.ut} ` : ""}${i.task !== undefined && i.task !== null ? `task${i.task}` : ""}`;
    t += `<tr><td class="tag">${esc(meta)}</td><td class="lbl">${esc(i.text)}${i.n_x > 1 ? ` <span style="color:var(--muted)">${i.n_x} exec records</span>` : ""}</td>${cells}</tr>`;
  }
  return t + "</table></div>";
}
function depGraph(w){
  const ins = w.instrs, n = ins.length; if (!n) return "";
  const step = Math.max(96, Math.min(150, 1100 / Math.max(n, 1))), W = 40 + step * n, H = 210, y0 = 118;
  let g = `<svg viewBox="0 0 ${W} ${H}" width="${W}" height="${H}" style="display:block;max-width:none">`;
  ins.forEach((i, k) => { const x = 20 + step * k + step/2;
    g += `<circle cx="${x}" cy="${y0}" r="6" fill="var(--ink)"/><text x="${x}" y="${y0+22}" font-size="10" text-anchor="middle" fill="var(--ink)">${esc(i.mnemonic)}</text><text x="${x}" y="${y0+35}" font-size="9" text-anchor="middle" fill="var(--muted)">D+${i.d_rel}${i.x_rel.length ? ` · X+${i.x_rel[0]}${i.x_rel.length>1?`…${i.x_rel[i.x_rel.length-1]}`:""}` : " · no X"}</text>`; });
  const color = {gpr:"var(--oxide)", dsr:"var(--violet)", mem:"var(--amber)", cflag:"var(--rose)", fabric:"var(--moss)", task:"var(--slate)", stream:"var(--amber)"};
  w.deps.forEach((e, idx) => { const x1 = 20 + step * e.producer + step/2, x2 = 20 + step * e.consumer + step/2, up = e.kind === "RAW";
    const h = 18 + 14 * Math.min(4, e.consumer - e.producer), cy = up ? y0 - h : y0 + 42 + h * 0.6, col = color[e.cls] || "var(--muted)";
    g += `<path d="M${x1},${up?y0-6:y0+6} C${x1},${cy} ${x2},${cy} ${x2},${up?y0-6:y0+6}" fill="none" stroke="${col}" stroke-width="1.5" ${e.kind !== "RAW" ? 'stroke-dasharray="4 3"' : ""}/>`;
    g += `<text x="${(x1+x2)/2}" y="${up ? cy + 4 : cy + 12}" font-size="9" text-anchor="middle" fill="${col}">${esc(e.kind)} ${esc(e.cls)} ${esc(e.resource)} · Δdispatch ${e.spacing}${e.x_gap !== null ? ` · X→X ${e.x_gap}` : ""}</text>`; });
  return g + "</svg>";
}
const wrap = document.getElementById("walkthroughs");
D.walkthroughs.forEach((w, n) => {
  const steps = w.instrs.map((i, k) => ({...stepsOf(i), n: k + 1}));
  const L = w.ladder;
  const lad = L ? `<div class="lad"><div><span class="eyebrow">what it does</span><p>${esc(L.intent)}</p></div><div><span class="eyebrow">the same thing in C</span><pre>${esc(L.c)}</pre></div><div><span class="eyebrow">as written in CSL</span><pre>${esc(w.csl || "")}</pre></div></div>${L.differs ? `<div class="diverge"><strong>Where C and the WSE part company.</strong> ${esc(L.differs)}</div>` : ""}` : "";
  const dpRows = w.instrs.map((i, k) => `<tr><td class="mono">${k+1}</td><td class="mono">${esc(i.text)}</td><td>${resList(i.reads)}</td><td class="mono">${esc(i.unit)}</td><td>${resList(i.writes)}</td><td class="mono" style="color:var(--muted)">${i.origin}${i.ut !== 255 ? ` · µt${i.ut}` : ""}${i.task !== null && i.task !== undefined ? ` · task ${i.task}` : ""}</td></tr>`).join("");
  const depRows = w.deps.map(e => `<tr><td class="mono">${esc(e.kind)}</td><td class="${rcls(e.cls === 'mem' ? 'sram' : e.cls)}">${esc(e.cls)} ${esc(e.resource)}</td><td class="mono">${esc(w.instrs[e.producer].mnemonic)} → ${esc(w.instrs[e.consumer].mnemonic)}</td><td class="mono">${e.spacing}</td><td class="mono">${e.x_gap ?? "—"}</td><td>${evTag(e)}</td></tr>`).join("");
  const vals = w.instrs.filter(i => i.elems.length).map(i => `<tr><td class="mono">${esc(i.mnemonic)}</td><td class="mono">${i.elems.length === 1 ? `${esc(i.elems[0].dest)}${[i.elems[0].src0,i.elems[0].src1,i.elems[0].src2].filter(Boolean).length ? " ← " + esc([i.elems[0].src0,i.elems[0].src1,i.elems[0].src2].filter(Boolean).join(", ")) : ""}` : `${i.elems.length} element records: ` + i.elems.slice(0,4).map(e => `e${e.idx}/lane${e.lane}@+${e.cycle - w.c0}: ${esc((e.dest||"").split(" ")[0])}`).join(", ") + (i.elems.length > 4 ? " …" : "")}</td></tr>`).join("");
  wrap.insertAdjacentHTML("beforeend", `<section>
    <div class="eyebrow">walkthrough ${n+1}</div><h2>${esc(w.title)}</h2><p class="lede">${esc(w.role)}</p>
    ${lad}
    ${w.instrs.length ? `<div class="views">
      <div class="card"><div class="eyebrow" style="margin-bottom:6px">functional datapath — numbered steps in dispatch order</div><div class="scroll">${datapathSVG(steps)}</div>
        <div class="scroll" style="margin-top:8px"><table><tr><th>#</th><th>instruction</th><th>reads</th><th>unit</th><th>writes</th><th>origin</th></tr>${dpRows}</table></div>
        ${vals ? `<div class="eyebrow" style="margin:10px 0 4px">values the execute records carry</div><div class="scroll"><table>${vals}</table></div>` : ""}</div>
      <div class="card"><div class="eyebrow" style="margin-bottom:6px">dependency graph — dynamic producers to consumers</div><div class="scroll">${depGraph(w)}</div>
        <div class="scroll" style="margin-top:8px"><table><tr><th>kind</th><th>resource</th><th>producer → consumer</th><th>Δ dispatch</th><th>X→X</th><th>evidence</th></tr>${depRows || '<tr><td colspan="6" style="color:var(--muted)">no register, DSR, flag or memory dependency inside this window</td></tr>'}</table></div></div>
      <div class="card"><div class="eyebrow" style="margin-bottom:6px">cycle timeline — D = decode record, X = execute records (■ the last), … = dispatched and waiting, second D = redispatch, w = wavelet</div>${timeline(w)}</div>
    </div>` : `<div class="card small">${esc(w.role)}</div>`}
    ${w.notes.length ? `<div class="card small"><div class="eyebrow" style="margin-bottom:4px">reading it</div><ul class="unk">${w.notes.map(x => `<li>${x}</li>`).join("")}</ul></div>` : ""}
    ${w.unknowns.length ? `<div class="card small"><div class="eyebrow" style="margin-bottom:4px">remaining unknowns</div><ul class="unk">${w.unknowns.map(x => `<li>${esc(x)}</li>`).join("")}</ul></div>` : ""}
  </section>`);
});
const S = D.sweep, sw = document.getElementById("sweep");
sw.innerHTML = Object.keys(S).length ? Object.entries(S).map(([name, s]) => `<div class="card" style="margin-bottom:10px"><h3 style="margin-top:0">${esc(name)} <span class="small">${esc(s.producer)} → ${esc(s.consumer)}</span> ${s.timing_only ? '<span class="ev ev-none">timing only</span>' : (s.verified ? '<span class="ev ev-none">values verified</span>' : '<span class="ev ev-delay">values NOT verified</span>')}</h3>
  <div class="scroll"><table><tr><th>fillers (nop)</th>${s.by_k.map(([k,,,,,t]) => `<th>${k}${t === true ? " ·taken" : t === false ? " ·not taken" : ""}</th>`).join("")}${s.prepared ? "<th>prepared DSR</th>" : ""}</tr>
  <tr><td>dispatch bubble</td>${s.by_k.map(([,b]) => `<td class="mono" style="color:${b ? 'var(--amber)' : 'var(--moss)'}">${b}</td>`).join("")}${s.prepared ? `<td class="mono">${s.prepared.spacing - 1}</td>` : ""}</tr>
  <tr><td>execute-stage delay (decode → value record, minus 3)</td>${s.by_k.map(([,,e]) => `<td class="mono" style="color:${e ? 'var(--amber)' : (e === null || e === undefined ? 'var(--muted)' : 'var(--moss)')}">${e ?? "—"}</td>`).join("")}${s.prepared ? `<td class="mono">${s.prepared.cons_dx - 3}</td>` : ""}</tr>
  <tr><td>next dispatch after the consumer</td>${s.by_k.map(([,,,,g]) => `<td class="mono">${g ?? "—"}</td>`).join("")}${s.prepared ? "<td></td>" : ""}</tr></table></div>
  <p class="small" style="margin:8px 0 0"><strong>Verdict:</strong> ${esc(s.verdict)}.</p></div>`).join("")
  : `<div class="card small">microbench/pcsweep has not produced results yet.</div>`;
</script>
"""
if __name__ == "__main__":
    main()
