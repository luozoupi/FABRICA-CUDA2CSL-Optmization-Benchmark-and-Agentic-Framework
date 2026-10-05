#!/usr/bin/env python3
"""Compile, patch, rebuild, run and measure one or all pcsweep classes.

Per class:  capture IR (tools/cslc_ir.py) -> patch @compute: optnone, reorder descriptor loads
where the class asks, insert K[i] `nop`s after pair i's producer, strip the loads of the
prepared-DSR pair -> rebuild the ELF with the real backend and linker -> run on the simulator
and verify every value -> decode the trace -> disassemble -> measure each pair.

Measured per pair (all from the trace, joined by uid and PC):
  k_req / k_nop     fillers requested / nops actually present between producer and consumer
  n_between         all instructions between producer and consumer in PC order
  spacing           consumer dispatch - producer dispatch
  dispatch_bubble   spacing - (n_between + 1): dispatch cycles beyond one-per-instruction
  cons_dx           consumer first execute - consumer decode (3 = no extra delay)
  region            marker i dispatch -> marker i+1 dispatch
No idle records exist in this SDK's trace, so nothing here is inferred from their absence.
"""
from __future__ import annotations
import argparse, gzip, json, os, re, shutil, subprocess, sys
from pathlib import Path

HERE = Path(__file__).resolve().parent; STUDY = HERE.parent.parent
SDK = "/software/cerebras/cs_sdk-2.10"; APP_TILE = 12
CSLC = ["./layout.csl", "--arch=wse3", "--fabric-dims=8,3", "--fabric-offsets=4,1", "-o", "out", "--memcpy",
        "--channels=1", "--width-west-buf=0", "--width-east-buf=0"]
NOP = '  call void asm sideeffect "nop", ""()\n'

def sh(cmd, cwd, timeout=1200):
    env = dict(os.environ); env["PATH"] = SDK + ":" + env.get("PATH", ""); env["TMPDIR"] = str(STUDY / ".nfstmp")
    return subprocess.run(cmd, cwd=str(cwd), env=env, capture_output=True, text=True, timeout=timeout)

# ------------------------------------------------------------------ IR patching
def regions(body_lines):
    """Split @compute's body at the marker stores (store i16 0x6000+i to @mark)."""
    idx = [k for k, l in enumerate(body_lines) if re.search(r"store i16 (2457[6-9]|245[89]\d|246\d\d), i16\* getelementptr[^\n]*@mark", l)]
    out = []
    for n, k in enumerate(idx):
        end = idx[n + 1] if n + 1 < len(idx) else len(body_lines)
        out.append((k, end))
    return out

def patch_ir(ll, meta):
    m = re.search(r"(define internal void @compute\(\)[^\n]*\{\n)(.*?)(\n\}\n)", ll, re.S)
    head, body, tail = m.group(1), m.group(2), m.group(3)
    lines = body.split("\n"); regs = regions(lines)
    assert len(regs) >= meta["pairs"] + 1, f"found {len(regs)} marker regions, need {meta['pairs']+1}"
    out = []; report = []
    last_end = 0
    for i in range(meta["pairs"]):
        s, e = regs[i]; seg = lines[s:e]; k = meta["k"][i]
        prod = meta["producer"]
        if prod in ("asm_f16", "asm_i16"):
            op = "faddh" if prod == "asm_f16" else "add16.nf"
            asm = lambda a: f'  call void asm sideeffect "{a}", ""()'
            j = next(jj for jj, l in enumerate(seg) if "store i16" in l and "@mark" in l)      # the marker store
            ins = [asm("movri r5 = 0x3e00"), asm("movri r8 = 0x3c00"), asm(f"{op} r5 = r5, r8")] + [NOP.rstrip("\n")] * k + [asm(f"{op} r5 = r5, r8")]
            seg = seg[:j + 1] + ins + seg[j + 1:]
        elif prod == "dsr":
            loads = [l for l in seg if "@llvm.sdr.ld" in l]; other = [l for l in seg if "@llvm.sdr.ld" not in l]
            want = {"s1": "lds1wds", "d": "lddwds", "s0": "lds0wds"}[meta["dsr_last"]]
            loads.sort(key=lambda l: (want in l))                       # the chosen one goes last
            op_at = next(j for j, l in enumerate(other) if "@llvm.sdr.add16" in l)
            if meta.get("prepared_pair") == i: loads = []               # control: DSRs already prepared by pair i-1
            seg = other[:op_at] + loads + [NOP.rstrip("\n")] * k + other[op_at:]
        else:
            pred = {"gpr": lambda ls: [j for j, l in enumerate(ls) if re.search(r"= load i16", l)][1],
                    "f16dep": lambda ls: next(j for j, l in enumerate(ls) if "fmul half" in l),
                    "i16dep": lambda ls: next(j for j, l in enumerate(ls) if re.search(r"= add i16", l)),
                    "cflag": lambda ls: next(j for j, l in enumerate(ls) if "icmp" in l),
                    "mem": lambda ls: next(j for j, l in enumerate(ls) if re.search(r"store i16 %\d+, i16\* getelementptr[^\n]*@c,", l)),
                    "reduce": lambda ls: next(j for j, l in enumerate(ls) if "faddh.rrs1" in l)}[prod]
            j = pred(seg); seg = seg[:j + 1] + [NOP.rstrip("\n")] * k + seg[j + 1:]
        out.extend(seg); report.append({"pair": i, "k": k})
        last_end = e
    out.extend(lines[last_end:])
    new = head + "\n".join(out) + tail
    return ll.replace(m.group(0), new), report

# ------------------------------------------------------------------ measurement
def load_disasm(p):
    rows = json.loads(Path(p).read_text()); rows = rows["records"] if isinstance(rows, dict) else rows
    return {r["pc"]: r["instruction"] for r in rows}, sorted(rows, key=lambda r: r["pc"])

def load_trace(p):
    disp, s3, s6 = {}, {}, {}
    with gzip.open(p, "rt") as fh:
        for line in fh:
            e = json.loads(line)
            if e.get("tile_index") != APP_TILE: continue
            t = e.get("event_type")
            if t == "hwm_dispatch_trace_entry": disp.setdefault(e.get("inst_ptr"), []).append((e["cycle"], e["uid"]))
            elif t == "hwm_pipe_trace_entry":
                if e.get("stage") == 3: s3.setdefault(e["uid"], []).append(e["cycle"])
                elif e.get("stage") == 6: s6.setdefault(e["uid"], []).append(e["cycle"])
    return disp, s3, s6

PROD = {"asm_f16": lambda t: t.startswith("faddh r"), "asm_i16": lambda t: t.startswith("add16.nf r"),
        "dsr": lambda t: t.startswith(("lddwds", "lds0wds", "lds1wds")), "gpr": lambda t: t.startswith("ld16"),
        "f16dep": lambda t: t.startswith("fmulh"), "i16dep": lambda t: t.startswith("add16"),
        "cflag": lambda t: re.match(r"(lt|lte|ltu|gt|gte|eq|ne)16\.and cflag", t) is not None, "mem": lambda t: t.startswith("st16"),
        "reduce": lambda t: t.startswith("faddh r")}
CONS = {"asm_f16": lambda t: t.startswith("faddh r"), "asm_i16": lambda t: t.startswith("add16.nf r"),
        "dsr": lambda t: t.startswith("add16.nf [dds"), "gpr": lambda t: t.startswith("add16"), "f16dep": lambda t: t.startswith("faddh"),
        "i16dep": lambda t: t.startswith("add16"), "cflag": lambda t: "? jmp" in t, "mem": lambda t: t.startswith("ld16"),
        "reduce": lambda t: t.startswith("st16")}

def measure(case, meta):
    dis, rows = load_disasm(case / "disasm.json"); disp, s3, s6 = load_trace(case / "events.jsonl.gz")
    seq = []
    for r in rows:
        for c, uid in sorted(disp.get(r["pc"], [])):
            if c < 3000: continue
            seq.append({"pc": r["pc"], "text": r["instruction"], "disp": c, "uid": uid,
                        "dec": min(s3.get(uid, [c])), "xs": sorted(s6.get(uid, []))})
    seq.sort(key=lambda x: x["disp"])
    marks = [k for k, x in enumerate(seq) if re.match(r"movri \S+ = 0x60[0-9a-f]{2}$", x["text"])]
    pairs = []
    for i in range(meta["pairs"]):
        a, b = marks[i], marks[i + 1]; seg = seq[a + 2:b]        # skip the marker's movri + st16
        prod_pred, cons_pred = PROD[meta["producer"]], CONS[meta["producer"]]
        if meta["producer"] == "dsr":
            loads = [j for j, x in enumerate(seg) if prod_pred(x["text"])]
            pj = loads[-1] if loads else None
            cj = next((j for j, x in enumerate(seg) if cons_pred(x["text"])), None)
        elif meta["producer"] == "gpr":
            loads = [j for j, x in enumerate(seg) if x["text"].startswith("ld16")]; pj = loads[1] if len(loads) > 1 else None
            cj = next((j for j, x in enumerate(seg) if j > (pj or -1) and cons_pred(x["text"])), None)
        elif meta["producer"] in ("i16dep", "asm_i16", "asm_f16"):
            mn = "add16" if meta["producer"] != "asm_f16" else "faddh r"
            adds = [j for j, x in enumerate(seg) if x["text"].startswith(mn)]; pj, cj = (adds[0], adds[1]) if len(adds) > 1 else (None, None)
        elif meta["producer"] == "mem":
            sts = [j for j, x in enumerate(seg) if x["text"].startswith("st16")]; pj = sts[0] if sts else None
            cj = next((j for j, x in enumerate(seg) if j > (pj or -1) and x["text"].startswith("ld16") and x["text"].split("[")[1].split("]")[0] == seg[pj]["text"].split("[")[1].split("]")[0]), None) if pj is not None else None
        else:
            pj = next((j for j, x in enumerate(seg) if prod_pred(x["text"])), None)
            cj = next((j for j, x in enumerate(seg) if j > (pj or -1) and cons_pred(x["text"])), None)
        if meta.get("prepared_pair") == i and cj is not None:
            # control: the op with no descriptor loads of its own; the 'producer' is whatever preceded it (the marker store)
            pj, seg = 0, [seq[a + 1]] + seg; cj += 1
        if pj is None or cj is None:
            pairs.append({"pair": i, "k_req": meta["k"][i], "error": "producer/consumer not found", "seg": [x["text"] for x in seg][:12]}); continue
        P, C = seg[pj], seg[cj]; between = seg[pj + 1:cj]
        k_nop = sum(1 for x in between if x["text"].startswith("nop"))
        cons_x = C["xs"]; prod_x = P["xs"]
        # The stage-6 record carrying the result is the LAST one; earlier records for the same uid are
        # placeholders (sentinel operands) emitted while the instruction sits in the execute stage.
        # Decode -> first record is 3 for every instruction; decode -> value record is where a stall shows.
        nxt = seg[cj + 1] if cj + 1 < len(seg) else (seq[b] if b < len(seq) else None)
        pairs.append({"pair": i, "k_req": meta["k"][i], "k_nop": k_nop, "n_between": len(between),
                      "between_non_nop": [x["text"] for x in between if not x["text"].startswith("nop")],
                      "producer": P["text"], "consumer": C["text"],
                      "prod_disp": P["disp"], "prod_dec": P["dec"], "prod_x_first": prod_x[0] if prod_x else None, "prod_x_last": prod_x[-1] if prod_x else None,
                      "cons_disp": C["disp"], "cons_dec": C["dec"], "cons_x_first": cons_x[0] if cons_x else None, "cons_x_last": cons_x[-1] if cons_x else None, "cons_n_x": len(cons_x),
                      "cons_redispatched": len(disp.get(C["pc"], [])) > 1,
                      "spacing": C["disp"] - P["disp"], "dispatch_bubble": C["disp"] - P["disp"] - (len(between) + 1),
                      "cons_dx": (cons_x[0] - C["dec"]) if cons_x else None,
                      "cons_dx_value": (cons_x[-1] - C["dec"]) if cons_x else None,
                      "exec_delay": (cons_x[-1] - C["dec"] - 3) if cons_x else None,
                      "taken": bool(cons_x) if meta["producer"] == "cflag" else None,
                      "next_disp_gap": (nxt["disp"] - C["disp"]) if nxt else None,
                      "next_text": nxt["text"] if nxt else None,
                      "region": seq[b]["disp"] - seq[a]["disp"], "prepared": meta.get("prepared_pair") == i})
    return pairs

def run_class(name, skip_run=False):
    case = HERE / "cases" / name; meta = json.loads((case / "meta.json").read_text())
    log = []
    if not skip_run:
        r = sh([sys.executable, str(STUDY / "tools" / "cslc_ir.py"), "capture", "-o", "ir", "--"] + CSLC, case)
        if r.returncode: return {"cls": name, "error": "capture", "diag": (r.stdout + r.stderr)[-800:]}
        prog = next(p for p in (case / "ir").iterdir() if p.is_dir() and (p / "program.ll").exists() and "east" not in p.name and "west" not in p.name)
        ll = (prog / "program.ll").read_text(); patched, rep = patch_ir(ll, meta); (case / "patched.ll").write_text(patched)
        elf = case / "out" / "bin" / "out_0_0.elf"; shutil.copy(elf, case / "out_0_0.orig.elf")
        r = sh([sys.executable, str(STUDY / "tools" / "cslc_ir.py"), "rebuild", str(prog), "-o", str(elf), "--ll", str(case / "patched.ll"), "--optnone", "compute"], case)
        if r.returncode: return {"cls": name, "error": "rebuild", "diag": (r.stdout + r.stderr)[-800:]}
        log.append(r.stdout.strip().splitlines()[-1] if r.stdout.strip() else "")
        shutil.rmtree(case / "simfab_traces", ignore_errors=True)
        r = sh(["cs_python", "run.py", "--name", "out", "--cls", name], case)
        # run.py lives in HERE; copy it in first
    return {"cls": name, "log": log}

def main():
    ap = argparse.ArgumentParser(); ap.add_argument("--only", nargs="*"); ap.add_argument("--reuse-ir", action="store_true", help="skip capture; patch and rebuild the IR captured earlier"); ap.add_argument("--measure-only", action="store_true"); a = ap.parse_args()
    names = a.only or sorted(p.name for p in (HERE / "cases").iterdir() if p.is_dir())
    results = {}
    for name in names:
        case = HERE / "cases" / name; meta = json.loads((case / "meta.json").read_text())
        shutil.copy(HERE / "run.py", case / "run.py")
        if not a.measure_only:
            import time
            elf = case / "out" / "bin" / "out_0_0.elf"
            if a.reuse_ir and (case / "ir").exists() and (case / "out_0_0.orig.elf").exists():
                shutil.copy(case / "out_0_0.orig.elf", elf)                    # start from cslc's own ELF again
            else:
                r = sh([sys.executable, str(STUDY / "tools" / "cslc_ir.py"), "capture", "-o", "ir", "--"] + CSLC, case)
                if r.returncode: print(f"{name}: CAPTURE FAILED\n{(r.stdout + r.stderr)[-600:]}"); continue
                shutil.copy(elf, case / "out_0_0.orig.elf")
            prog = next(p for p in (case / "ir").iterdir() if p.is_dir() and (p / "program.ll").exists() and "east" not in p.name and "west" not in p.name)
            patched, rep = patch_ir((prog / "program.ll").read_text(), meta); (case / "patched.ll").write_text(patched)
            ok = False
            for attempt in range(4):                                             # the relay drops sessions that follow a burst; space them out
                time.sleep(6 if attempt == 0 else 20)
                r = sh([sys.executable, str(STUDY / "tools" / "cslc_ir.py"), "rebuild", str(prog), "-o", str(elf), "--ll", str(case / "patched.ll"), "--optnone", "compute"], case)
                if r.returncode == 0 and elf.stat().st_size and (case / "out_0_0.orig.elf").read_bytes() != elf.read_bytes(): ok = True; break
                print(f"{name}: rebuild attempt {attempt + 1} failed ({(r.stdout + r.stderr).strip()[-160:] or 'no output'})")
            if not ok: print(f"{name}: REBUILD FAILED after retries"); continue
            time.sleep(6)
            shutil.rmtree(case / "simfab_traces", ignore_errors=True)
            r = sh(["cs_python", "run.py", "--name", "out", "--cls", name], case)
            vline = [l for l in r.stdout.splitlines() if l.startswith(name)]
            print(vline[-1] if vline else f"{name}: RUN produced no verdict\n{(r.stdout + r.stderr)[-600:]}")
            if not (case / "verify.json").exists(): continue
            import time
            for _ in range(24):                       # the container writes on another host; NFS can lag by tens of seconds
                if (case / "simfab_traces" / "stream0").exists(): break
                time.sleep(5)
            r = sh([sys.executable, str(STUDY / "tools" / "decode_trace.py"), ".", "-o", "events.jsonl.gz"], case)
            if r.returncode: print(f"{name}: decode failed: {(r.stdout + r.stderr)[-300:]}")
            r = sh([sys.executable, str(STUDY / "tools" / "csdisasm.py"), "out/bin/out_0_0.elf", "--json", "disasm.json"], case)
        if not (case / "events.jsonl.gz").exists() or not (case / "disasm.json").exists(): print(f"{name}: no trace/disasm"); continue
        pairs = measure(case, meta); v = json.loads((case / "verify.json").read_text())
        results[name] = {"meta": meta, "verify": v, "pairs": pairs}
        print(f"  {'pair':>4} {'k_nop':>5} {'betw':>4} {'spacing':>7} {'bubble':>6} {'DXfirst':>7} {'DXvalue':>7} {'exDelay':>7} {'cons#X':>6} {'nextGap':>7} {'region':>6}  producer -> consumer")
        for p in pairs:
            if "error" in p: print(f"  {p['pair']:>4} {p['k_req']:>5}  {p['error']}: {p['seg']}"); continue
            tag = " (prepared DSR)" if p.get("prepared") else ""
            tag += (" taken" if p.get("taken") else " not taken") if p.get("taken") is not None else ""
            print(f"  {p['pair']:>4} {p['k_nop']:>5} {p['n_between']:>4} {p['spacing']:>7} {p['dispatch_bubble']:>6} {str(p['cons_dx']):>7} {str(p['cons_dx_value']):>7} {str(p['exec_delay']):>7} {p['cons_n_x']:>6} {str(p['next_disp_gap']):>7} {p['region']:>6}  {p['producer'][:26]} -> {p['consumer'][:30]}{tag}"
                  + (f"   non-nop between: {p['between_non_nop']}" if p["between_non_nop"] else ""))
    prev = json.loads((HERE / "results.json").read_text()) if (HERE / "results.json").exists() else {}
    prev.update(results); results = prev                       # merge: a partial rerun must not drop finished classes
    (HERE / "results.json").write_text(json.dumps(results, indent=1))
    print("wrote", HERE / "results.json")

if __name__ == "__main__":
    main()
