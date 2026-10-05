#!/usr/bin/env python3
"""Anatomy of the basic ISA, one operation at a time, from real traces.

Companion to add_anatomy.py.  Reads microbench/atomic_ops (22 MIPS-style basic
operations -- arithmetic, logic, control, convert, memory, vector -- each written
once in CSL) and microbench/relay at N=1,B=8 (one 8-wavelet message between two
PEs, the fabric primitive MIPS has no counterpart for).  Joins the dispatch trace
(cycle, PC), the pipe trace (decode = stage 3, execute = stage 6, by uid) and the
elf2am disassembly (PC -> text), then renders:

  * a summary table: CSL line -> the core instruction(s) it became, D->X cycles,
    and the cycle the result was first consumed
  * the body exactly as the compiler SCHEDULED it, region by marker, as MIPS-style
    pipeline charts -- because the optimiser (the LLVM mid-end, downstream of the captured IR) moved independent scalar ops across
    the markers and shared their loads, the charts show that instead of hiding it
  * the send/receive anatomy: two PEs on one absolute cycle axis, the wavelets on
    the link between them

Evidence: `simulator`, joined by uid and PC exactly.  Fetch and writeback are not
traced.  Marker stores (0x5A00+i into an exported array) survive dead-store
elimination but do not pin instruction order; attribution is by mnemonic.
"""
from __future__ import annotations
import gzip, json, re, sys
from pathlib import Path

HERE = Path(__file__).resolve().parent.parent
OPS = HERE / "microbench" / "atomic_ops"
RELAY = HERE / "microbench" / "relay"
OPS_TILE = 12
MEMCPY_COLOURS = {0, 1, 2, 3, 4, 5, 21, 22, 23}
sys.path.insert(0, str(Path(__file__).resolve().parent))
from anatomy_common import load_pipe, typed_for, wavelet_fields, load_disasm, ladder, FABRIC_LADDER  # values, link bits, disasm, C ladder

def load_trace(events, tiles):
    disp, s3, s6, s6max, wav = {}, {}, {}, {}, {}
    with gzip.open(events, "rt") as fh:
        for line in fh:
            e = json.loads(line); tile = e.get("tile_index")
            if tile not in tiles: continue
            t = e.get("event_type")
            if t == "hwm_dispatch_trace_entry":
                disp.setdefault(tile, []).append((e["cycle"], e.get("inst_ptr"), e["uid"], e.get("num_data"), e.get("task_color"), e.get("name")))
            elif t == "hwm_pipe_trace_entry":
                k = (tile, e["uid"])
                if e.get("stage") == 3: s3[k] = min(s3.get(k, e["cycle"]), e["cycle"])
                elif e.get("stage") == 6:
                    s6[k] = min(s6.get(k, e["cycle"]), e["cycle"]); s6max[k] = max(s6max.get(k, e["cycle"]), e["cycle"])
            elif t == "wavelet_trace_entry":
                wav.setdefault(tile, []).append((e["cycle"], (e.get("fields") or 0) & 0x1F, e.get("fields") or 0, e.get("data")))
    return disp, s3, s6, s6max, wav

def disasm(fn, tag=None):
    """Every instruction in the ELF, labelled application / runtime / unclassified.

    `tag` is accepted for call compatibility and ignored: filtering the disassembly by
    source dropped the <memcpy> runtime instructions that execute ON the application PE,
    which both hid real work and invented gaps in any interval measured from what was left.
    """
    return load_disasm(fn)

def attach_values(seq, events, tile):
    """Stage-6 operand values per uid, typed by mnemonic (one entry per element for DSD ops)."""
    pv = load_pipe(events, {tile})
    for ins in seq:
        mn = ins["text"].split(" ")[0]; raw = pv.get((tile, ins["uid"]), {}).get("elems", [])
        ins["vals"] = [{"cycle": x["cycle"], "idx": x["idx"], "lane": x["lane"], "dest": typed_for(mn, x["dest"]), "src0": typed_for(mn, x["src0"], "src0"),
                        "src1": typed_for(mn, x["src1"], "src1"), "src2": typed_for(mn, x["src2"], "src2")} for x in raw][:64]
    return seq

def seq_for(tile, disp, s3, s6, dis, lo=0, hi=10**9, s6max=None):
    out = []
    for c, pc, uid, nd, col, nm in sorted(disp.get(tile, [])):
        if not (lo <= c <= hi): continue
        nd = nd if isinstance(nd, int) and nd < 65535 else 1
        rec = dis.get(pc); xl = (s6max or {}).get((tile, uid))
        out.append({"pc": pc, "text": (rec or {}).get("text", (nm or "?").lower()), "dispatch": c,
                    "decode": s3.get((tile, uid)), "execute": s6.get((tile, uid)), "x_last": xl,
                    "completion": (xl - c) if xl is not None else None,
                    "nd": nd, "task": col, "uid": uid, "known": rec is not None,
                    "origin": (rec or {}).get("origin", "unknown"),
                    "source_file": (rec or {}).get("source_file", "")})
    return out

# ---- attribution of core instructions to forms --------------------------------
CORE = [  # (form, predicate on (text, region-index))
    ("sub_i16",    lambda t, r: t.startswith("sub16")),
    ("mul_i16",    lambda t, r: t.startswith("imul16")),
    ("mul_f16",    lambda t, r: t.startswith("fmulh r")),
    ("fma_f16",    lambda t, r: t.startswith("faddh r") and "[" not in t),
    ("and_i16",    lambda t, r: t.startswith("and16")),
    ("or_i16",     lambda t, r: t.startswith("or16")),
    ("xor_i16",    lambda t, r: t.startswith("xor16")),
    ("shl_i16",    lambda t, r: t.startswith("sll16")),
    ("shr_i16",    lambda t, r: t.startswith("sar16")),
    ("br_taken",   lambda t, r: r == 9 and (t.startswith("lt16") or "?" in t or t.startswith("fmov16.nf r") or t.startswith("movri r9 = 0xb"))),
    ("br_not",     lambda t, r: r == 10 and (t.startswith("lt16") or "?" in t)),
    ("loop2",      lambda t, r: r == 11 and not t.startswith(("movri r9 = 0x5a", "st16 [0x7ff]", "fh2s", "st32"))),
    ("f16_to_f32", lambda t, r: t.startswith("fh2s")),
    ("f32_to_f16", lambda t, r: t.startswith("fs2h")),
    ("dsd_fill8",  lambda t, r: t.startswith("fmov16.nf [dds") and "[s" not in t),
    ("dsd_copy8",  lambda t, r: r == 15 and t.startswith("fmov16.nf [dds")),
    ("dsd_stride2",lambda t, r: r == 16 and t.startswith("fmov16.nf [dds")),
    ("dsd_reduce8",lambda t, r: t.startswith("faddh r") and "[s" in t),
    ("dsd_mulh8",  lambda t, r: t.startswith("fmulh [dds")),
    ("dsd_fmach8", lambda t, r: t.startswith("fmach [dds")),
    ("dsd_add16x8",lambda t, r: t.startswith("add16.nf [dds")),
    ("dsd_fadds8", lambda t, r: t.startswith("fadds [dds")),
]
ROLE = [
    ("ld16",   "load",  "SRAM word -> GPR"),
    ("ld16rp", "load",  "SRAM word pair -> GPR pair"),
    ("st16",   "store", "GPR -> SRAM word"),
    ("st32",   "store", "GPR pair -> SRAM"),
    ("lddwds", "dsr",   "descriptor -> DDS"),
    ("lds0wds","dsr",   "descriptor -> S0DS"),
    ("lds1wds","dsr",   "descriptor -> S1DS"),
    ("movri",  "alu",   "immediate -> GPR"),
    ("jmp",    "ctrl",  "PC <- target"),
    ("actvt",  "ctrl",  "activate task"),
]
def role(t):
    if "?" in t and "jmp" in t: return ("ctrl", "predicated jump")
    if "?" in t: return ("pred", "predicated move")
    if "[dds" in t or "[s1ds" in t or "[s0ds" in t: return ("simd", "DSR streams -> lanes -> DSR stream")
    for k, r, f in ROLE:
        if t.startswith(k): return (r, f)
    if t.startswith(("lt16", "ltu16", "eq16")): return ("cmp", "GPR cmp GPR -> cflag")
    if t.startswith(("fh2s", "fs2h")): return ("cvt", "GPR -> GPR (format)")
    return ("alu", "GPR op GPR -> GPR")

def dest_reg(t):
    m = re.match(r"(?:!?cflag\d \? )?\S+ (\S+) =", t)
    return m.group(1) if m else None

def first_consumer(seq, i):
    """Dispatch cycle of the first later instruction that reads this one's destination register."""
    d = dest_reg(seq[i]["text"])
    if not d or d.startswith(("dds", "s0ds", "s1ds", "cflag")): return None
    for j in range(i + 1, min(i + 40, len(seq))):
        t = seq[j]["text"]; rhs = t.split("=", 1)[1] if "=" in t else t
        if re.search(rf"\b{re.escape(d)}\b", rhs): return seq[j]
        if dest_reg(t) == d: return None
    return None

def analyse_ops():
    meta = json.loads((OPS / "meta.json").read_text())
    res = json.loads((OPS / "results.json").read_text()) if (OPS / "results.json").exists() else {}
    dis = disasm(OPS / "disasm.json")
    disp, s3, s6, s6max, _ = load_trace(OPS / "events.jsonl.gz", {OPS_TILE})
    full = seq_for(OPS_TILE, disp, s3, s6, dis, lo=5000, s6max=s6max)
    # the COMPLETE stream inside the marker window: <memcpy> runtime instructions do execute
    # on this PE between the markers, and dropping them would invent gaps in the intervals below
    mk = [i for i, x in enumerate(full) if x["origin"] == "application"
          and re.match(r"movri \S+ = 0x5a[0-9a-f]{2}$", x["text"])]
    seq = full[mk[0]: mk[-1] + 6] if mk else full
    attach_values(seq, OPS / "events.jsonl.gz", OPS_TILE)
    # regions by marker movri
    region = None; regions = []
    for i, ins in enumerate(seq):
        m = re.match(r"movri \S+ = 0x5a([0-9a-f]{2})$", ins["text"]) if ins["origin"] == "application" else None
        if m:
            region = int(m.group(1), 16); regions.append({"idx": region, "start": i, "rows": []})
        ins["region"] = region
        if regions: regions[-1]["rows"].append(i)
    # stop at END marker's region
    end_idx = len(meta)
    regions = [r for r in regions if r["idx"] <= end_idx]
    # attribute cores
    verify = {r["name"]: {"ok": r["ok"], "got": r["got"], "expected": r["expected"]} for r in res.get("rows", [])}
    forms = {m["name"]: {"cls": m["cls"], "name": m["name"], "csl": m["csl"], "ladder": ladder(m["name"]), "core": []} for m in meta}
    for i, ins in enumerate(seq):
        ins["role"], ins["flow"] = role(ins["text"]) if ins["known"] else ("unknown", "")
        ins["form"] = None
        if ins["origin"] != "application": continue   # a form's core instruction is application code
        for name, pred in CORE:
            if pred(ins["text"], ins.get("region")):
                ins["form"] = name; forms[name]["core"].append(i); break
    for f in forms.values():
        rows = []
        for i in f["core"]:
            ins = seq[i]; cons = first_consumer(seq, i)
            rows.append({**{k: ins[k] for k in ("pc", "text", "dispatch", "decode", "execute", "nd", "role", "vals", "origin", "completion")},
                         "dx": (ins["execute"] - ins["decode"]) if ins["execute"] is not None and ins["decode"] is not None else None,
                         "consumer": cons["text"] if cons else None,
                         "consumer_dispatch_interval": (cons["dispatch"] - ins["dispatch"]) if cons else None,
                         "consumer_execute": cons["x_last"] if cons else None,
                         "next_issue": (seq[i + 1]["dispatch"] - ins["dispatch"]) if i + 1 < len(seq) else None})
        f["rows"] = rows
        f["verified"] = verify.get(f["name"])
    # region charts
    charts = []
    for r in regions:
        rows = [seq[i] for i in r["rows"]]
        if not rows: continue
        c0 = rows[0]["dispatch"]; span = max((x["execute"] or x["dispatch"]) for x in rows) - c0 + 1
        charts.append({"ladder": ladder(meta[r["idx"]]["name"]) if r["idx"] < len(meta) else None,
                       "idx": r["idx"], "label": meta[r["idx"]]["name"] if r["idx"] < len(meta) else "END",
                       "csl": meta[r["idx"]]["csl"] if r["idx"] < len(meta) else "", "c0": c0, "span": span,
                       "rows": [{"pc": x["pc"], "text": x["text"], "d": x["dispatch"] - c0,
                                 "x": (x["execute"] - c0) if x["execute"] is not None else None,
                                 "xl": (x["x_last"] - c0) if x["x_last"] is not None else None,
                                 "nd": x["nd"], "form": x["form"], "role": x["role"], "origin": x["origin"],
                                 "cls": forms[x["form"]]["cls"] if x["form"] else None} for x in rows]})
    res["verify"] = verify; res["outputs"] = {r["name"]: r["got"] for r in res.get("rows", [])}
    return meta, forms, charts, res

def analyse_optnone():
    """The same program rebuilt with `noinline optnone` on compute() (tools/cslc_ir.py) and run on the
    simulator: every form sits between its own markers, so attribution is by region, not mnemonic."""
    opt = OPS / "ir_cap" / "optnone_sim"
    if not (opt / "events_optnone.jsonl.gz").exists(): return None
    meta = json.loads((OPS / "meta.json").read_text())
    dis = disasm(opt / "disasm_optnone.json")
    disp, s3, s6, s6max, _ = load_trace(opt / "events_optnone.jsonl.gz", {OPS_TILE})
    full = seq_for(OPS_TILE, disp, s3, s6, dis, lo=5000, s6max=s6max)
    mk0 = [i for i, x in enumerate(full) if x["origin"] == "application"
           and re.match(r"movri \S+ = 0x5a[0-9a-f]{2}$", x["text"])]
    seq = full[mk0[0]: mk0[-1] + 6] if mk0 else full
    attach_values(seq, opt / "events_optnone.jsonl.gz", OPS_TILE)
    for ins in seq: ins["role"], ins["flow"] = role(ins["text"]) if ins["known"] else ("unknown", "")
    marks = [i for i, ins in enumerate(seq) if ins["origin"] == "application"
             and re.match(r"movri \S+ = 0x5a[0-9a-f]{2}$", ins["text"])]
    verify = {}
    for line in (opt / "run_optnone.log").read_text().splitlines():
        m = re.match(r"\s*(\w+)\s+(ok|FAIL)\s+got=(.*?)\s+expected=(.*)$", line)
        if m: verify[m.group(1)] = {"ok": m.group(2) == "ok", "got": m.group(3), "expected": m.group(4)}
    forms, charts = [], []
    for k in range(min(len(meta), len(marks) - 1)):
        i = marks[k]; seg = seq[i:marks[k + 1]]; body = seg[2:]          # the marker pair (movri, st16) is not the form
        m = meta[k]; rows = []
        for j, ins in enumerate(body):
            gi = i + 2 + j; cons = first_consumer(seq, gi)
            rows.append({**{kk: ins[kk] for kk in ("pc", "text", "dispatch", "decode", "execute", "nd", "role", "vals")},
                         "dx": (ins["execute"] - ins["decode"]) if ins["execute"] is not None and ins["decode"] is not None else None,
                         "consumer": cons["text"] if cons else None,
                         "consumer_dispatch_interval": (cons["dispatch"] - ins["dispatch"]) if cons else None,
                         "consumer_execute": cons["x_last"] if cons else None,
                         "next_issue": (seq[gi + 1]["dispatch"] - ins["dispatch"]) if gi + 1 < len(seq) else None})
        c0 = body[0]["dispatch"] if body else seg[0]["dispatch"]
        span = (max((x["execute"] or x["dispatch"]) for x in body) - c0 + 1) if body else 0
        forms.append({"cls": m["cls"], "name": m["name"], "csl": m["csl"], "ladder": ladder(m["name"]), "rows": rows, "verified": verify.get(m["name"]),
                      "n_instr": len(body), "span": span, "cost": seq[marks[k + 1]]["dispatch"] - c0})
        c0r = seg[0]["dispatch"]; spanr = max((x["execute"] or x["dispatch"]) for x in seg) - c0r + 1
        charts.append({"ladder": ladder(m["name"]), "idx": k, "label": m["name"], "csl": m["csl"], "c0": c0r, "span": spanr,
                       "rows": [{"pc": x["pc"], "text": x["text"], "d": x["dispatch"] - c0r, "x": (x["execute"] - c0r) if x["execute"] is not None else None,
                                 "nd": x["nd"], "form": m["name"] if n >= 2 else None, "role": x["role"], "cls": m["cls"] if n >= 2 else None} for n, x in enumerate(seg)]})
    body_cycles = seq[marks[len(meta)]]["dispatch"] - seq[marks[0]]["dispatch"] if len(marks) > len(meta) else None
    return {"forms": forms, "charts": charts, "verify": verify, "body_cycles": body_cycles, "n_instr": sum(f["n_instr"] for f in forms),
            "n_dispatch": len(seq)}

def analyse_fabric():
    d0 = disasm(RELAY / "disasm_pe0.json"); d1 = disasm(RELAY / "disasm_pe1.json")
    disp, s3, s6, s6max, wav = load_trace(RELAY / "events_n1b8.jsonl.gz", {20, 21})
    app = {t: sorted(c for c, col, *_ in wav.get(t, []) if col not in MEMCPY_COLOURS) for t in (20, 21)}
    wl = {str(t): [[c, wavelet_fields(f)["link"], d] for c, col, f, d in sorted(wav.get(t, [])) if col not in MEMCPY_COLOURS] for t in (20, 21)}
    lo = min(app[20]) - 24; hi = max(app[21]) + 26
    s0 = seq_for(20, disp, s3, s6, d0, lo, hi, s6max=s6max); s1 = seq_for(21, disp, s3, s6, d1, lo, hi, s6max=s6max)
    attach_values(s0, RELAY / "events_n1b8.jsonl.gz", 20); attach_values(s1, RELAY / "events_n1b8.jsonl.gz", 21)
    # collapse the receiver's re-dispatch of the same uid into one row with a wait window
    merged = {}
    for ins in s1:
        k = ins["uid"]
        if k in merged: merged[k]["redispatch"] = ins["dispatch"]
        else: merged[k] = dict(ins)
    s1 = sorted(merged.values(), key=lambda x: x["dispatch"])
    for s in (s0, s1):
        for ins in s: ins["role"], ins["flow"] = role(ins["text"]) if ins["known"] else ("unknown", "")
    send = next(x for x in s0 if x["nd"] == 8); recv = next(x for x in s1 if x["nd"] == 8)
    res = json.loads((RELAY / "result_N1_B8.json").read_text())
    done_task = next((x for x in s1 if x["task"] not in (None, 1) and x["dispatch"] > recv["execute"]), None)
    return {"lo": lo, "hi": hi, "pe0": s0, "pe1": s1, "leave": app[20], "arrive": app[21], "tsc_cycles": res["cycles"], "wl": wl,
            "send_dispatch": send["dispatch"], "first_leave": app[20][0], "recv_dispatch": recv["dispatch"],
            "recv_redispatch": recv.get("redispatch"), "recv_execute": recv["execute"], "first_arrive": app[21][0],
            "done_task_dispatch": done_task["dispatch"] if done_task else None, "hop": app[21][0] - app[20][0]}

def main():
    meta, forms, charts, res = analyse_ops()
    fab = analyse_fabric()
    _ov = HERE / "microbench" / "overlap" / "overlap.json"
    ovl = json.loads(_ov.read_text()) if _ov.exists() else None
    opt = analyse_optnone()
    o2_body = (charts[-1]["c0"] - charts[0]["c0"]) if charts and charts[-1]["label"] == "END" else None
    data = {"forms": [forms[m["name"]] for m in meta], "charts": charts, "fabric": fab, "optnone": opt, "o2_body_cycles": o2_body,
            "fabric_ladder": FABRIC_LADDER,
            "overlap": ovl,
            "verify": res.get("verify"), "inputs": res.get("inputs"), "outputs": res.get("outputs")}
    out = HERE / "results" / "anatomy" / "ops_anatomy.html"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(HTML.replace("__DATA__", json.dumps(data)))
    print(f"{'form':<12} {'cls':<8} core  D->X  compl  cons-disp  next-disp  core instruction")
    for m in meta:
        f = forms[m["name"]]
        for r in f["rows"]:
            print(f"{f['name']:<12} {f['cls']:<8} {len(f['rows']):>4}  {str(r['dx']):>4}  {str(r['completion']):>6}  {str(r['consumer_dispatch_interval']):>9}  {str(r['next_issue']):>10}  {r['text'][:52]}")
    fb = fab
    print(f"\nfabric: send dispatch {fb['send_dispatch']} -> first wavelet leaves {fb['first_leave']} (+{fb['first_leave']-fb['send_dispatch']}), "
          f"hop {fb['hop']} cyc, recv dispatched {fb['recv_dispatch']} re-dispatched {fb['recv_redispatch']} executes {fb['recv_execute']}, "
          f"done task {fb['done_task_dispatch']}, TSC-timed {fb['tsc_cycles']}")
    if opt:
        print(f"\noptnone build: body {opt['body_cycles']} cycles (-O2 {o2_body}), {opt['n_instr']} form instructions; per form:")
        print(f"  {'form':<12} {'instr':>5} {'first D->last X':>15} {'to next marker':>14}  verified")
        for f in opt["forms"]: print(f"  {f['name']:<12} {f['n_instr']:>5} {f['span']:>15} {f['cost']:>14}  {f['verified']['ok'] if f['verified'] else '?'}")
    bad = [n for n, v in res["verify"].items() if not v["ok"]]
    print("verified", len(res["verify"]) - len(bad), "of", len(res["verify"]), "forms", ("FAILED: " + ", ".join(bad)) if bad else "")
    print("wrote", out)

HTML = r"""<title>Anatomy of the Basic ISA</title>
<style>
:root{--ground:#F4F6F8;--surface:#FFFFFF;--surface-2:#EDF0F3;--ink:#12171C;--ink-2:#3D4750;--muted:#68747F;--line:#D9DFE5;
  --oxide:#0C6E77;--amber:#A8660F;--violet:#5A4B94;--rose:#A33A5B;--moss:#3F7A3A;--slate:#4A6070;--idle:#DDE3E9;--wait:#F1D7A8;--wave:#C9E6E9}
@media (prefers-color-scheme:dark){:root:not([data-theme="light"]){--ground:#0C1014;--surface:#141A20;--surface-2:#1B232B;--ink:#E7ECF1;--ink-2:#B6C1CB;--muted:#8797A3;--line:#26313A;
  --oxide:#4FC3CC;--amber:#E8A33F;--violet:#A99BE0;--rose:#E48AA6;--moss:#8CC985;--slate:#93AABB;--idle:#222C35;--wait:#4A3A1C;--wave:#1D3F44}}
:root[data-theme="dark"]{--ground:#0C1014;--surface:#141A20;--surface-2:#1B232B;--ink:#E7ECF1;--ink-2:#B6C1CB;--muted:#8797A3;--line:#26313A;
  --oxide:#4FC3CC;--amber:#E8A33F;--violet:#A99BE0;--rose:#E48AA6;--moss:#8CC985;--slate:#93AABB;--idle:#222C35;--wait:#4A3A1C;--wave:#1D3F44}
*{box-sizing:border-box}body{margin:0;background:var(--ground);color:var(--ink);font-family:ui-sans-serif,system-ui,-apple-system,"Segoe UI",Roboto,sans-serif;font-size:15px;line-height:1.55}
.wrap{max-width:1160px;margin:0 auto;padding:26px 20px 60px}
header{border-bottom:1px solid var(--line);padding-bottom:13px;margin-bottom:20px;display:flex;gap:14px;flex-wrap:wrap;align-items:baseline}
h1{font-size:22px;margin:0;letter-spacing:-.02em}h2{font-size:17px;margin:34px 0 8px;letter-spacing:-.01em}h3{font-size:14px;margin:18px 0 6px}
.eyebrow{font-size:11px;letter-spacing:.14em;text-transform:uppercase;color:var(--muted)}
.chip{font-size:10.5px;letter-spacing:.08em;text-transform:uppercase;padding:2px 7px;border-radius:3px;border:1px solid var(--line);color:var(--muted)}
.card{background:var(--surface);border:1px solid var(--line);border-radius:8px;padding:14px 16px;margin-top:10px}
code,.mono{font-family:ui-monospace,SFMono-Regular,Menlo,Consolas,monospace;font-size:.92em}
table{border-collapse:collapse;width:100%;font-size:13px}th{font-size:10.5px;letter-spacing:.09em;text-transform:uppercase;color:var(--muted);text-align:left;padding:6px 8px;border-bottom:1px solid var(--line)}
td{padding:5px 8px;border-bottom:1px solid var(--line);vertical-align:top}
.scroll{overflow-x:auto}
.pipe{border-collapse:separate;border-spacing:2px;font-family:ui-monospace,Menlo,monospace;font-size:11px}
.pipe td{padding:0;border:0;width:20px;min-width:20px;height:20px;text-align:center;border-radius:3px;background:var(--idle);color:var(--ink)}
.pipe td.lbl{width:auto;min-width:0;text-align:left;padding:0 10px 0 2px;background:transparent;white-space:nowrap}
.pipe td.tag{width:auto;min-width:0;text-align:left;padding:0 8px 0 0;background:transparent;white-space:nowrap;font-size:10px;letter-spacing:.06em;text-transform:uppercase}
.pipe td.D{background:var(--violet);color:#fff}.pipe td.X{background:var(--oxide);color:#fff}.pipe td.s{background:var(--surface-2)}
.pipe td.run{background:var(--oxide);opacity:.4}
.pipe tr.nonapp td.lbl,.pipe tr.nonapp td.tag{opacity:.72}
.orig{font-size:9.5px;letter-spacing:.06em;text-transform:uppercase;color:var(--muted);border:1px solid var(--line);border-radius:3px;padding:0 4px;margin-right:5px}
.pipe td.w{background:var(--wait);color:var(--ink)}.pipe td.v{background:var(--oxide);color:#fff;opacity:.8}.pipe td.R{background:var(--violet);color:#fff;opacity:.7}
.pipe th{padding:0;text-align:center;font-size:9.5px;border:0;color:var(--muted)}
.lede{color:var(--ink-2)}.note{margin-top:12px;padding:11px 14px;border-left:3px solid var(--violet);background:var(--surface);border-radius:0 6px 6px 0;font-size:13.5px;color:var(--ink-2)}
.c-arith{color:var(--oxide)}.c-logic{color:var(--violet)}.c-control{color:var(--amber)}.c-convert{color:var(--rose)}.c-memory{color:var(--slate)}.c-vector{color:var(--moss)}
.legend{display:flex;gap:14px;flex-wrap:wrap;font-size:12px;color:var(--ink-2);margin-top:8px}.legend span::before{content:"";display:inline-block;width:11px;height:11px;border-radius:2px;margin-right:5px;vertical-align:-1px}
.legend .lD::before{background:var(--violet)}.legend .lX::before{background:var(--oxide)}.legend .ls::before{background:var(--surface-2);border:1px solid var(--line)}.legend .lw::before{background:var(--wait)}.legend .lv::before{background:var(--oxide);opacity:.8}
.obs li{margin:6px 0}
.lad{display:grid;grid-template-columns:1fr 1.15fr 1fr;gap:0;border:1px solid var(--line);border-radius:8px;overflow:hidden;background:var(--surface);margin-top:8px}
@media(max-width:820px){.lad{grid-template-columns:1fr}}
.lad>div{padding:10px 13px;border-right:1px solid var(--line)}
.lad>div:last-child{border-right:0}
@media(max-width:820px){.lad>div{border-right:0;border-bottom:1px solid var(--line)}}
.lad pre{margin:4px 0 0;font-family:ui-monospace,Menlo,monospace;font-size:11px;line-height:1.5;white-space:pre-wrap;color:var(--ink)}
.lad p{margin:4px 0 0;font-size:12px;color:var(--ink-2)}
.diverge{margin-top:7px;padding:8px 12px;border-left:3px solid var(--amber);background:var(--surface);border-radius:0 6px 6px 0;font-size:12px;color:var(--ink-2)}
.ev{display:inline-block;font-size:9.5px;letter-spacing:.08em;text-transform:uppercase;padding:1px 6px;border-radius:2px;border:1px solid;margin-left:4px;vertical-align:1px;white-space:nowrap}.ev-dep{color:var(--violet);border-color:var(--violet)}.ev-delay{color:var(--amber);border-color:var(--amber)}.ev-stall{color:var(--oxide);border-color:var(--oxide)}
.grid2{display:grid;grid-template-columns:1fr 1fr;gap:12px}@media(max-width:800px){.grid2{grid-template-columns:1fr}}
.tabs{display:flex;gap:6px;margin:26px 0 0;flex-wrap:wrap}.tab{padding:6px 12px;border:1px solid var(--line);border-radius:6px;background:var(--surface);cursor:pointer;font-size:13px;color:var(--ink-2)}.tab[aria-selected="true"]{border-color:var(--oxide);color:var(--oxide);font-weight:600}.tab:focus-visible{outline:2px solid var(--oxide);outline-offset:2px}
.cost td,.cost th{padding:4px 8px}
</style>
<div class="wrap">
<header><div><div class="eyebrow">Cerebras WSE-3 · one PE · one instruction at a time</div><h1>Anatomy of the Basic ISA</h1></div><span class="chip">cycles · simulator</span><span class="chip">joined by uid + PC</span><span class="chip">22 forms + 1 message</span></header>
<p class="lede">The <a href="#" onclick="return false" style="color:inherit">Anatomy of an Add</a> treatment, extended to the rest of a MIPS-style basic set: integer and floating arithmetic, logic and shifts, compare-and-branch, a data-bounded loop, format conversion, fill/copy/strided copy/reduction through the DSD engine, the vector forms, and — the primitive MIPS never had — one message from one PE to its neighbour. Every form was written once in CSL and executed once; the cycles are the ones the simulator recorded; every result was checked against a host model.</p>
<div class="card"><div class="eyebrow" style="margin-bottom:6px">The pipeline these charts are drawn on</div>
<div class="scroll"><table class="pipe" style="width:auto"><tr><td class="lbl">stage</td><td class="s" style="width:70px">fetch</td><td class="D" style="width:110px">dispatch / decode</td><td class="s" style="width:60px">stage 4</td><td class="s" style="width:60px">stage 5</td><td class="X" style="width:70px">execute</td><td class="s" style="width:90px">writeback</td></tr>
<tr><td class="lbl">observed?</td><td class="lbl">no</td><td class="lbl">yes — trace stage 3</td><td class="lbl">—</td><td class="lbl">—</td><td class="lbl">yes — trace stage 6</td><td class="lbl">no</td></tr></table></div>
<div class="legend"><span class="lD">D — dispatched and decoded this cycle</span><span class="lX">X — executed this cycle</span><span class="ls">· — the two cycles between the decode record and the execute record: stages 4–5, which the trace does not record (inferred from the stage numbering; NOT decode)</span><span class="lw">… — dispatched but waiting for data</span><span class="lv">w — a wavelet on the link</span></div></div>

<div class="card" style="font-size:12.5px;color:var(--ink-2)"><div class="eyebrow" style="margin-bottom:6px">how timing statements are labelled</div><span class="ev ev-dep">dependency identified</span> a producer–consumer relation exists in the code (register, DSR, flag or memory); it may or may not cost anything. &nbsp; <span class="ev ev-delay">delay observed</span> the trace shows a gap; its cause has not been isolated. &nbsp; <span class="ev ev-stall">stall cause supported</span> a controlled experiment varied the suspected cause and the delay followed it.</div>
<div class="tabs" role="tablist" id="build"><button class="tab" role="tab" aria-selected="true" data-v="o2">−O2 · as cslc scheduled it</button><button class="tab" role="tab" aria-selected="false" data-v="optnone">optnone · every form isolated</button></div>
<p id="buildnote" style="color:var(--ink-2);font-size:13.5px;margin:8px 0 0"></p>
<div id="costcard"></div>
<h2>1 · What each CSL line became</h2>
<p class="lede" style="font-size:14px">One row per basic operation. <em>D→X</em> is decode-to-execute for the core instruction (3 = no stall). <em>Completion latency</em> is dispatch to the instruction's <strong>last</strong> execute record — the only boundary at which the result is known to exist, and for a DSD op the end of its whole hardware loop. <em>Consumer dispatch interval</em> is the dispatch-to-dispatch distance to the first instruction that reads the result: a scheduling fact about an in-order machine, <strong>not</strong> the time at which the value became available. The two differ, and the reduction below is the clearest case. <em>Next dispatch</em> is when the very next instruction of any kind dispatched.</p>
<div class="card"><div class="scroll"><table id="summary"><tr><th>class</th><th>form</th><th>in C</th><th>CSL</th><th>core instruction(s)</th><th>elems</th><th>D→X</th><th title="dispatch to the instruction's last execute record">completion latency</th><th title="dispatch-to-dispatch distance to the first instruction that reads the result: a scheduling fact, not an availability time">consumer dispatch interval</th><th>next dispatch</th><th>values at X (dest ← src0, src1[, src2])</th><th>check</th></tr></table></div></div>

<h2 id="h2sched">2 · The body as the compiler scheduled it</h2>
<p class="lede" style="font-size:14px" id="p2sched"></p>
<div id="charts"></div>

<h2>3 · What the traces say about the basic set</h2>
<div class="card"><ul class="obs" id="obs"></ul></div>

<h2>4 · One message: send and receive</h2>
<p class="lede" style="font-size:14px">The relay microbench at N=1, B=8: PE0 pushes eight 32-bit words to PE1 through the fabric. Both PEs are drawn on one absolute cycle axis (simulator cycles), with the link between them. The sender's <code>fmov32.nf [fabout] = [sram]</code> is a normal DSD copy whose destination DSR names an output queue; the receiver's <code>fmov32.nf [sram] = [fabin]</code> is a DSD copy whose source is an input queue — and it was dispatched <em>before</em> any data existed, so it sat in the pipe until the first wavelet reached the router.</p>
<div class="card" id="fabric"></div>
<div class="note" id="fabnote"></div>

<div class="card" id="values" style="margin-top:22px"></div>
</div>
<script>
const D = __DATA__;
const esc = s => String(s).replace(/</g,'&lt;');
const clsOf = c => c ? `c-${c}` : '';
const ladHTML = (L, csl) => !L ? '' : `<div class="lad">
    <div><span class="eyebrow">what it does</span><p>${esc(L.intent)}</p></div>
    <div><span class="eyebrow">the same thing in C</span><pre>${esc(L.c)}</pre></div>
    <div><span class="eyebrow">as written in CSL</span><pre>${esc(csl)}</pre></div>
  </div>${L.differs ? `<div class="diverge"><strong>Where C and the WSE part company.</strong> ${esc(L.differs)}</div>` : ''}`;
const valsCell = r => { const e = r.vals || []; if (!e.length) return '<span style="color:var(--muted)">—</span>';
  const one = x => `${x.dest || '<span style="color:var(--muted)">(flag)</span>'}${[x.src0, x.src1, x.src2].filter(Boolean).length ? ' ← ' + [x.src0, x.src1, x.src2].filter(Boolean).join(', ') : ''}`;
  if (e.length === 1) return one(e[0]);
  const lanes = e.map(x => x.lane).filter(l => l !== null && l !== undefined), cyc = [...new Set(e.map(x => x.cycle))];
  return `<details><summary style="cursor:pointer">${e.length} elements · lanes ${Math.min(...lanes)}–${Math.max(...lanes)} · ${cyc.length} cycle${cyc.length>1?'s':''} (${cyc.map(c => c - r.dispatch).join(',')} after dispatch)</summary><table style="margin-top:4px"><tr><th>el</th><th>lane</th><th>+cyc</th><th>src0</th><th>src1</th><th>src2</th><th>dest</th></tr>${e.map(x => `<tr><td class="mono">${x.idx}</td><td class="mono">${x.lane}</td><td class="mono">${x.cycle - r.dispatch}</td><td class="mono">${x.src0}</td><td class="mono">${x.src1}</td><td class="mono">${x.src2}</td><td class="mono">${x.dest}</td></tr>`).join('')}</table></details>`; };
// ---- 1 + 2. summary table and region charts, per build
const S = document.getElementById('summary'), C = document.getElementById('charts');
const P2_O2 = `The 22 forms were written in order, each behind a marker store. The optimiser (the LLVM mid-end, downstream of the captured IR — see the Add-Family Lowering page) kept the marker stores in order but was free to move the arithmetic: it hoisted the two operand loads once and fed <strong>seven</strong> integer ops from them, shared the f16 product between <code>mul_f16</code> and <code>fma_f16</code>, and pushed the two conversions past their markers. The charts below are cut at the markers and coloured by which CSL form each instruction implements, so the reordering is visible rather than hidden. Row order is dispatch order; the axis is cycles from the region's first dispatch. <strong>Read the windows below as PC ranges, not as per-line code:</strong> the marker stores keep their order, but the work does not stay between its own markers, and five of the windows hold arithmetic belonging to other forms. Every instruction the PE dispatched in the window is shown, including the <code>&lt;memcpy&gt;</code> runtime instructions that execute on this same PE between the markers (badged) and any whose PC the disassembler could not place (<em>unknown</em>) — they are not application work, but they do consume cycles, and hiding them would turn their cycles into apparent bubbles.`;
const P2_OPT = `The same program rebuilt from cslc's own LLVM IR with <code>noinline optnone</code> on <code>compute()</code> (<code>tools/cslc_ir.py rebuild --optnone compute</code>), then run on the simulator. Nothing moves across a marker any more: each chart is exactly one CSL line — its loads, its op, its store — and every value was re-verified against the host. The first two rows of each chart are the marker itself (<code>movri</code>, <code>st16</code>).`;
const NOTE_O2 = () => `Build shown: the normal <code>cslc</code> −O2 output — the code a CSL programmer actually gets. Body: ${D.o2_body_cycles ?? '?'} cycles from the first marker to the END marker.`;
const NOTE_OPT = () => `Build shown: <code>optnone</code> on <code>compute()</code>, patched at the LLVM-IR level and rebuilt with the real backend and linker. All ${Object.keys(D.optnone.verify).length} forms verified on the simulator; ${D.optnone.n_instr} form instructions in ${D.optnone.body_cycles} cycles (−O2: ${D.o2_body_cycles}). Loads are no longer shared, the if/else forms become real jumps and the loop keeps its counter on the stack — the price of isolating each operation.`;
function renderBuild(v){
  document.querySelectorAll('#build .tab').forEach(b => b.setAttribute('aria-selected', b.dataset.v === v));
  const opt = v === 'optnone' && D.optnone;
  const forms = opt ? D.optnone.forms : D.forms, charts = opt ? D.optnone.charts : D.charts, verify = opt ? D.optnone.verify : D.verify;
  document.getElementById('buildnote').innerHTML = opt ? NOTE_OPT() : NOTE_O2();
  document.getElementById('h2sched').textContent = opt ? '2 · Each form between its own markers' : '2 · The body as the compiler scheduled it';
  document.getElementById('p2sched').innerHTML = opt ? P2_OPT : P2_O2;
  // per-form cost table (only meaningful when forms are isolated)
  document.getElementById('costcard').innerHTML = opt ? `<div class="card"><div class="eyebrow" style="margin-bottom:6px">cost of each operation in isolation (optnone build, simulator cycles)</div><div class="scroll"><table class="cost"><tr><th>class</th><th>form</th><th>instructions</th><th>first dispatch → last execute</th><th>cycles to next marker</th><th>check</th></tr>${forms.map(f => `<tr><td class="${clsOf(f.cls)}">${f.cls}</td><td class="mono">${f.name}</td><td class="mono">${f.n_instr}</td><td class="mono">${f.span}</td><td class="mono">${f.cost}</td><td style="font-size:12px">${f.verified ? (f.verified.ok ? 'ok' : '<strong>FAIL</strong>') : '—'}</td></tr>`).join('')}</table></div></div>` : '';
  // summary table
  S.querySelectorAll('tr:not(:first-child)').forEach(r => r.remove());
  for (const f of forms){
    const vv = verify && verify[f.name];
    const chk = vv == null ? '—' : (vv.ok ? `ok · ${esc(typeof vv.got === 'string' ? vv.got : JSON.stringify(vv.got))}` : `<strong>FAIL</strong> got ${esc(JSON.stringify(vv.got))} expected ${esc(JSON.stringify(vv.expected))}`);
    const rows = f.rows.length ? f.rows : [{text:'(no core instruction found)', nd:'', dx:'', completion:'', consumer_dispatch_interval:'', next_issue:'', vals:[]}];
    rows.forEach((r, i) => S.insertAdjacentHTML('beforeend', `<tr>${i===0?`<td class="${clsOf(f.cls)}" rowspan="${rows.length}">${f.cls}</td><td class="mono" rowspan="${rows.length}">${f.name}</td><td class="mono" rowspan="${rows.length}" style="white-space:pre-wrap;max-width:26ch;color:var(--ink-2)">${esc((f.ladder||{}).c || "")}</td><td class="mono" rowspan="${rows.length}" style="white-space:pre">${esc(f.csl)}</td>`:''}<td class="mono ${r.role ? '' : ''}">${esc(r.text)}</td><td class="mono">${r.nd}</td><td class="mono">${r.dx ?? ''}</td><td class="mono">${r.completion ?? '—'}</td><td class="mono">${r.consumer_dispatch_interval ?? '—'}${r.consumer ? ` <span style="color:var(--muted)">by ${esc(r.consumer.split(' ')[0])}</span>` : ''}</td><td class="mono">${r.next_issue ?? ''}</td><td class="mono" style="font-size:11.5px">${valsCell(r)}</td>${i===0?`<td rowspan="${rows.length}" style="font-size:12px">${chk}</td>`:''}</tr>`));
  }
  // region charts
  C.innerHTML = '';
  for (const ch of charts){
    if (!ch.rows.length) continue;
    let t = `<div class="scroll"><table class="pipe"><tr><th></th><th></th>${Array.from({length: ch.span}, (_, i) => `<th>${i}</th>`).join('')}</tr>`;
    for (const r of ch.rows){
      let cells = '';
      for (let c = 0; c < ch.span; c++){
        let cls = '', txt = '';
        if (c === r.d){ cls = 'D'; txt = 'D'; }
        else if (r.x !== null && c === r.x){ cls = 'X'; txt = 'X'; }
        else if (r.x !== null && c > r.d && c < r.x){ cls = 's'; txt = '·'; }
        else if (r.xl != null && r.x !== null && c > r.x && c <= r.xl){ cls = (c === r.xl ? 'X' : 'run'); txt = (c === r.xl ? '\u25a0' : '\u2248'); }
        cells += `<td class="${cls}">${txt}</td>`;
      }
      const nd = r.nd > 1 ? ` <span style="color:var(--muted)">×${r.nd}</span>` : '';
      const badge = r.origin && r.origin !== 'application' ? `<span class="orig">${r.origin === 'runtime' ? 'memcpy runtime' : esc(r.origin)}</span>` : '';
      t += `<tr class="${r.origin === 'application' ? '' : 'nonapp'}"><td class="tag ${clsOf(r.cls)}">${r.form ? r.form.replace('_',' ') : ''}</td><td class="lbl">${badge}${esc(r.text)}${nd}</td>${cells}</tr>`;
    }
    t += '</table></div>';
    const present = [...new Set(ch.rows.map(r => r.form).filter(Boolean))];
    const own = present.length === 1 && present[0] === ch.label;
    const caution = (present.length > 1 || (present.length === 1 && !own))
      ? `<div class="diverge"><strong>This window is not this line's code.</strong> The ${ch.rows.length} instructions between marker ${ch.idx} and the next one carry the arithmetic of ${present.length} form${present.length>1?'s':''} — ${present.map(x => `<span class="mono">${esc(x)}</span>`).join(', ')} — because <code>mark</code>, <code>ci</code> and <code>cf</code> are distinct exported arrays that cannot alias, so a result store is free to move across a marker store. Marker order is preserved among markers; that constrains nothing about where the work sits. Colours below say which form each instruction belongs to, and the optnone build isolates them.</div>`
      : present.length === 0 ? `<div class="diverge" style="border-left-color:var(--line)">No form arithmetic in this window: marker stores and control only.</div>`
      : `<div class="diverge" style="border-left-color:var(--moss)">This window is exactly this line's code.</div>`;
    C.insertAdjacentHTML('beforeend', `<h3>marker ${ch.idx} · PC window <span class="chip">first dispatch @ ${ch.c0}</span> <span class="chip">${ch.rows.length} instructions</span></h3>${ladHTML(ch.ladder, ch.csl)}${caution}<div class="card">${t}</div>`);
  }
}
document.querySelectorAll('#build .tab').forEach(b => b.onclick = () => renderBuild(b.dataset.v));
if (!D.optnone) document.querySelector('#build .tab[data-v="optnone"]').disabled = true;
renderBuild('o2');
// ---- 3. observations
const F = Object.fromEntries(D.forms.map(f => [f.name, f]));
const cdi = (n, i=0) => (F[n] && F[n].rows[i]) ? F[n].rows[i].consumer_dispatch_interval : '?';
const comp = (n, i=0) => (F[n] && F[n].rows[i]) ? F[n].rows[i].completion : '?';
const nxt = (n, i=0) => (F[n] && F[n].rows[i]) ? F[n].rows[i].next_issue : '?';
const obs = [
 `<strong>The trace records the values, not just the timing.</strong> Every execute-stage record carries <code>dest</code>, <code>src0</code>, <code>src1</code> (and <code>src2</code> for the FMA) as the datapath used them: <code>${esc((F.sub_i16.rows[0].vals[0]||{}).dest||'')} ← ${esc([(F.sub_i16.rows[0].vals[0]||{}).src0, (F.sub_i16.rows[0].vals[0]||{}).src1].join(', '))}</code> for the subtraction. A DSD op emits one record per element with its SIMD lane, so the 8-element forms expand into eight numbered lane results — open a "values" cell in the table to see them. Cerebras's own decoder (<code>SimfabInstructionTraceCtf</code>) reports the same values.`,
 `<strong>Every scalar op is one instruction, 3 cycles decode→execute, and its result is stored on the very next cycle.</strong> <span class="ev ev-delay">delay observed</span> sub, and, or, xor, shifts and the integer multiply <code>imul16</code> all issue back-to-back with their consuming <code>st16</code> (their consuming <code>st16</code> dispatches ${cdi('sub_i16')}, ${cdi('and_i16')}, ${cdi('mul_i16')} cycles later, and each op's own completion latency is ${comp('sub_i16')}, ${comp('and_i16')}, ${comp('mul_i16')} cycles). There is no visible multiply latency at this level: <code>imul16</code> behaves like an add.`,
 `<strong>A consumer's dispatch is not the moment a result exists.</strong> This machine is in-order and single-issue, so it dispatches the next instruction as soon as it reaches the head of the stream — which can be well before the producer has finished. The reduction is the clean example: <code>faddh r5 = r5, [s1ds1]</code> dispatches, its consuming store dispatches ${cdi('dsd_reduce8')} cycles later, but the op's <em>last</em> element executes at +${comp('dsd_reduce8')} and the store's own value record appears after that. Every latency on this page is therefore a completion boundary (dispatch to last execute); dispatch-to-dispatch distances are labelled as such and never called latencies.`,
 `<strong>The compiler, not the ISA, decides how many loads an add needs.</strong> Seven independent ops shared two <code>ld16</code>: the "4 instructions per add" of the add page is the cost of an <em>isolated</em> add; in straight-line code the loads amortise and each further op costs 1 ALU instruction + 1 store.`,
 `<strong>Scalar f16 multiply-add is not fused.</strong> <code>cf[1] = af[0]*bf[0] + af[1]</code> became <code>fmulh</code> then <code>faddh</code>; the product was even shared with the preceding <code>mul_f16</code> form. The fused <code>fmach</code> exists only as a DSD (vector) instruction. The dependent <code>faddh</code> dispatched 3 cycles after the <code>fmulh</code> and still stalled one cycle (decode→execute ${F.fma_f16.rows[0].dx} instead of 3) — the 2-cycle dependent f16 latency seen in the hazard probe, visible here as one bubble.`,
 `<strong>Both if/else forms compiled to predication, not branches.</strong> <code>lt16.and cflag0 = …</code> sets a condition flag; <code>!cflag0 ? imov16.nf r = 0x16</code> executes only if the flag is clear. No jump, no bubble, no misprediction possible — the "taken" and "not taken" cases cost the same. This is the compiler's answer to a machine without a branch predictor.`,
 `<strong>Real jumps appear only when control depends on data the compiler cannot resolve</strong> — the data-bounded loop. Each <code>cflag0 ? jmp</code> has no execute record in the trace; where the jump resolves is not observed. The next instruction dispatches 3 cycles later whether taken or not <span class="ev ev-delay">delay observed</span>; the branch microbench measured 6 for a taken jump to a cold target, and no controlled experiment has isolated the cause of the 3.`,
 `<strong>Conversion is one instruction each way:</strong> <code>fh2s</code> (half→single) and <code>fs2h</code> (single→half), 3 cycles, into a 32-bit register pair that <code>st32</code> then writes.`,
 `<strong>Fill, copy and strided copy are the same instruction with different DSRs.</strong> A fill is <code>fmov16.nf [dds1] = r5</code> — a register broadcast into a destination stream. A copy loads two DSRs; a stride-2 copy is identical, the stride lives in the descriptor. All three moved 8 elements, completing ${comp('dsd_copy8')} cycles after dispatch, with the next instruction dispatching ${nxt('dsd_copy8')} cycle later.`,
 `<strong>A reduction is a DSD op whose destination is a register:</strong> <code>faddh r5 = r5, [s1ds1]</code>. Its 8 elements execute two cycles apart <span class="ev ev-dep">dependency identified</span> <span class="ev ev-delay">delay observed</span> — each element depends on the previous accumulator value, and the spacing matches the dependent-f16 figure the ILP microbench obtained by varying chain depth at constant work for <em>scalar</em> chains; that the same mechanism governs the elements of one DSD op has not been tested separately — so its completion latency is ${comp('dsd_reduce8')} cycles, while its consuming store merely <em>dispatched</em> ${cdi('dsd_reduce8')} cycles in. It is the one form where the difference between the two numbers is impossible to miss.`,
 `<strong>A DSD op holds the issue slot for its whole duration, in the configuration tested — measured, not inferred.</strong> An earlier version of this page claimed the opposite, on the grounds that a scalar instruction dispatches 1 cycle after an 8-element DSD op. That does not follow: with 8 elements the entire loop executes in a single cycle, so "1 cycle later" is simply <em>after</em> completion, and consecutive dispatch is not concurrent execution. ${D.overlap ? `<code>microbench/overlap</code> settles it with a case where the windows are long enough to tell apart: a ${D.overlap.L}-element DSD add (completion ${D.overlap.T_A_dsd_alone} cycles) and an independent ${D.overlap.S}-step register-only scalar chain (${D.overlap.T_B_chain_alone} cycles) were run alone and then together. Together they took <strong>${D.overlap.T_C_combined}</strong> cycles — ${D.overlap.pct_of_serial}% of the serial sum (${D.overlap.serial_prediction}) and ${D.overlap.pct_of_full_overlap}% of what full overlap would predict (${D.overlap.overlap_prediction}). Not one of the chain's ${D.overlap.chain_execs_total} execute records falls inside the DSD's execute window, and the PE issues no application instruction at all for ${D.overlap.issue_held_cycles} of those ${D.overlap.T_A_dsd_alone} cycles. Verdict: ${D.overlap.verdict}.` : `The overlap microbench has not been run in this tree.`} So the 6 + 2·groups next-dispatch figure is issue-slot occupancy for this case <span class="ev ev-stall">stall cause supported</span>, and the "next dispatch" column below is a scheduling observation, not evidence of overlap. <strong>Scope:</strong> a memory-to-memory i16 <code>@add16</code> on one PE with no microthread (<code>ut_id</code> 255). Fabric-bound DSD copies run as microthreads — the relay's send and receive carry <code>ut_id</code> 6 — and asynchronous modes were not tested; serialization is not established for them.`,
 `<strong>The vector set at this granularity:</strong> <code>fmulh</code>, <code>fmach</code> (with a register scalar), <code>add16.nf</code> and <code>fadds</code> (f32) each cost 3 DSR loads + 1 op for 8 elements; each completing ${comp('dsd_mulh8')} cycles after dispatch; the f32 <code>fadds</code> was the only one after which the next instruction's dispatch waited ${nxt('dsd_fadds8')} cycles <span class="ev ev-delay">delay observed</span>.`,
];
if (D.optnone){
  const O = D.optnone, byName = Object.fromEntries(O.forms.map(f => [f.name, f]));
  const c = n => byName[n] ? `${byName[n].n_instr} instr / ${byName[n].span} cyc` : '?';
  obs.push(`<strong>Isolated, every operation has the same shape (optnone build, second tab).</strong> With function-local <code>optnone</code> applied at the IR level — which disables most LLVM optimisations, not only instruction scheduling — each integer or f16 op is <code>ld16, ld16, op, st16</code> — ${c('sub_i16')}, ${c('mul_i16')}, ${c('and_i16')} — and the multiply-add is the same plus one load and one <code>faddh</code> (${c('fma_f16')}). The DSD forms keep their shape exactly: DSR loads plus one op (${c('dsd_mulh8')}); the reduction still needs its 13-cycle result wait (${c('dsd_reduce8')}). The if/else forms now compile to a compare and a real <code>cflag0 ? jmp</code> (${c('br_taken')}, ${c('br_not')}): if-conversion is an optimisation, not codegen. The loop is ${c('loop2')} with its counter on the stack. Whole body: ${O.body_cycles} cycles against ${D.o2_body_cycles} at −O2 — what the optimiser was worth here.`);
}
document.getElementById('obs').innerHTML = obs.map(o => `<li>${o}</li>`).join('');
// ---- 4. fabric
const fb = D.fabric; const lo = fb.lo, hi = fb.hi, span = hi - lo + 1;
const leave = new Set(fb.leave), arrive = new Set(fb.arrive);
let t = `<div class="scroll"><table class="pipe"><tr><th></th><th></th>${Array.from({length: span}, (_, i) => `<th>${(lo + i) % 5 === 0 ? lo + i : ''}</th>`).join('')}</tr>`;
const rowFor = (tag, ins, opts={}) => {
  let cells = '';
  for (let c = lo; c <= hi; c++){
    let cls = '', txt = '';
    if (c === ins.dispatch){ cls = 'D'; txt = 'D'; }
    else if (ins.redispatch && c === ins.redispatch){ cls = 'R'; txt = 'D'; }
    else if (ins.execute !== null && c === ins.execute){ cls = 'X'; txt = 'X'; }
    else if (ins.redispatch && c > ins.dispatch && c < ins.redispatch){ cls = 'w'; txt = '…'; }
    else if (ins.execute !== null && c > (ins.redispatch || ins.dispatch) && c < ins.execute){ cls = 's'; txt = '·'; }
    cells += `<td class="${cls}">${txt}</td>`;
  }
  const nd = ins.nd > 1 ? ` <span style="color:var(--muted)">×${ins.nd}</span>` : '';
  const task = ins.task !== 1 ? ` <span style="color:var(--muted)">task ${ins.task}</span>` : '';
  return `<tr><td class="tag ${opts.cls||''}">${tag}</td><td class="lbl">${esc(ins.text)}${nd}${task}</td>${cells}</tr>`;
};
const interesting = ins => ins.nd > 1 || /wds|fab|actvt|ublk|st32|ld16|st16|fmov|or32|movri r5/.test(ins.text) || (ins.task !== 1);
for (const ins of fb.pe0.filter(interesting)) t += rowFor('PE0', ins, {cls:'c-arith'});
let wl = '', wa = '';
for (let c = lo; c <= hi; c++){ wl += `<td class="${leave.has(c)?'v':''}">${leave.has(c)?'w':''}</td>`; wa += `<td class="${arrive.has(c)?'v':''}">${arrive.has(c)?'w':''}</td>`; }
t += `<tr><td class="tag c-control">link</td><td class="lbl">wavelet leaves PE0 router (colour 6)</td>${wl}</tr>`;
t += `<tr><td class="tag c-control">link</td><td class="lbl">wavelet arrives at PE1 router</td>${wa}</tr>`;
for (const ins of fb.pe1.filter(interesting)) t += rowFor('PE1', ins, {cls:'c-vector'});
t += '</table></div>';
document.getElementById('fabric').innerHTML = ladHTML(D.fabric_ladder, "@fmovs(fabout_dsd, sram_dsd);   // sender\\n@fmovs(sram_dsd, fabin_dsd);    // receiver") + t;
document.getElementById('fabnote').innerHTML = `<strong>Reading it.</strong> PE0 loads two DSRs (destination = the fabric output queue, source = its SRAM buffer) and dispatches one <code>fmov32.nf</code> for 8 words at cycle ${fb.send_dispatch}. The first wavelet leaves its router ${fb.first_leave - fb.send_dispatch} cycles later, then one per cycle; each reaches PE1's router after ${fb.hop} cycles — the per-hop latency measured on silicon. PE1 had dispatched its receiving <code>fmov32.nf</code> at cycle ${fb.recv_dispatch}, ${fb.first_arrive - fb.recv_dispatch} cycles before any data existed: the trace shows it re-dispatched at ${fb.recv_redispatch}, the cycle the first wavelet arrived, and executed at ${fb.recv_execute}. A receive is a load whose operand is on the wire; the pipeline simply waits. ${fb.done_task_dispatch ? `The last wavelet arrived at ${fb.arrive[fb.arrive.length-1]} and PE1's completion task began ${fb.done_task_dispatch - fb.arrive[fb.arrive.length-1]} cycles after it, at ${fb.done_task_dispatch}.` : ''} The wavelet records themselves say where they were taken: ${(() => { const L = t => [...new Set((fb.wl[t]||[]).map(w => w[1]))].join('/'); return `at PE0 on <strong>${L('20')}</strong> (the PE's own ramp), at PE1 on the <strong>${L('21')}</strong> link` })()} — the link field of the trace decoded exactly as csdb renders it. ${(() => { const s = fb.pe0.find(i => i.nd === 8); const v = s && s.vals && s.vals.length ? s.vals.map(x => x.src1 || x.dest).slice(0, 8) : []; return v.length ? `The sender's execute-stage records give the eight payload words in order: <span class="mono">${esc(v.join(' '))}</span>.` : ''; })()} Send dispatch to receive-complete: <strong>${fb.done_task_dispatch ? fb.done_task_dispatch - fb.send_dispatch : '?'} cycles</strong> for 8 words over one hop; the TSC-timed figure, which includes the timer reads and the completion handshake, was ${fb.tsc_cycles}.`;
// values
const I = D.inputs || {}, O = D.outputs || {};
document.getElementById('values').innerHTML = `<div class="eyebrow" style="margin-bottom:6px">verified values</div><div class="mono" style="font-size:12.5px;white-space:pre-wrap">${esc(JSON.stringify({inputs: I, outputs: O}, null, 1)).slice(0, 4000)}</div>`;
</script>
"""
if __name__ == "__main__":
    main()
