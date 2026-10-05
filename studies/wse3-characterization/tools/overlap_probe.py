#!/usr/bin/env python3
"""Does independent scalar work execute concurrently with a DSD hardware loop?

Reads `microbench/overlap`, which calls three functions on one PE so that region
boundaries need no markers and cannot be confused by scheduling:

  region_a()   a long i16 DSD add alone                                   (L elements)
  region_b()   an independent register-only scalar dependency chain alone (S steps)
  region_c()   the same DSD plus the same chain, mutually independent

METHOD.  Every latency here is a COMPLETION boundary: an instruction's last stage-6
(execute) record minus its dispatch cycle.  Dispatch-to-dispatch intervals are never
used as latencies -- a consumer's dispatch only says when it entered the pipeline, not
when the producer's result existed.  A DSD instruction emits one stage-6 record per
element, so its completion is the last of those, not the first.

The verdict rests on three independent readings:
  1. the combined span T_C against the serial prediction (T_A + T_B) and the
     full-overlap prediction (max(T_A, T_B));
  2. how many of the chain's execute records fall inside the DSD's execute window;
  3. how long the machine issues nothing at all after the DSD dispatches.

Instructions are attributed by the disassembler's `source_file`, so application code is
separated from the `<memcpy>` runtime by where it came from, not by whether a mnemonic
was recognised.

Evidence: `simulator`.
"""
from __future__ import annotations
import gzip, json, sys
from pathlib import Path

HERE = Path(__file__).resolve().parent.parent
ROOT = HERE / "microbench" / "overlap"
TILE = 12
APP_SRC = "pe.csl"

def load(events, tile):
    disp, ex = [], {}
    with gzip.open(events, "rt") as fh:
        for line in fh:
            if '"hwm_' not in line: continue
            e = json.loads(line)
            if e.get("tile_index") != tile: continue
            t = e.get("event_type")
            if t == "hwm_dispatch_trace_entry":
                nd = e.get("num_data"); nd = nd if isinstance(nd, int) and nd < 65535 else 1
                disp.append({"cycle": e["cycle"], "pc": e.get("inst_ptr"), "nd": nd, "uid": e["uid"]})
            elif t == "hwm_pipe_trace_entry" and e.get("stage") == 6:
                r = ex.setdefault(e["uid"], {"first": e["cycle"], "last": e["cycle"], "n": 0})
                r["first"] = min(r["first"], e["cycle"]); r["last"] = max(r["last"], e["cycle"]); r["n"] += 1
    disp.sort(key=lambda d: d["cycle"])
    return disp, ex

def main():
    meta = json.loads((ROOT / "meta.json").read_text()); L, S = meta["L"], meta["S"]
    rows = json.loads((ROOT / "disasm.json").read_text()); rows = rows["records"] if isinstance(rows, dict) else rows
    dis = {r["pc"]: r["instruction"] for r in rows}
    sfile = {r["pc"]: (r.get("source_file") or "").split("/")[-1] for r in rows}
    disp, ex = load(ROOT / "events.jsonl.gz", TILE)
    app = [d for d in disp if sfile.get(d["pc"]) == APP_SRC]
    dsds = [d for d in app if d["nd"] == L]
    if len(dsds) != 2: sys.exit(f"expected 2 DSD ops of {L} elements, found {len(dsds)}")
    A, C = dsds; xA, xC = ex[A["uid"]], ex[C["uid"]]
    chain = [d for d in app if dis.get(d["pc"], "").startswith("imul16")]
    b = [d for d in chain if d["cycle"] < C["cycle"]]
    c = [d for d in chain if d["cycle"] > C["cycle"]]
    span = lambda l: (l[0]["cycle"], max(ex[d["uid"]]["last"] for d in l if d["uid"] in ex))
    b0, b1 = span(b); c0, c1 = span(c)
    T_A = xA["last"] - A["cycle"]
    T_B = b1 - b0
    T_C = max(xC["last"], c1) - C["cycle"]
    serial, over = T_A + T_B, max(T_A, T_B)
    inside = [d for d in c if d["uid"] in ex and xC["first"] <= ex[d["uid"]]["first"] <= xC["last"]]
    first_after = next((d for d in disp if d["cycle"] > C["cycle"] and sfile.get(d["pc"]) == APP_SRC), None)
    held = (first_after["cycle"] - C["cycle"]) if first_after else None
    if T_C >= 0.95 * serial: verdict = "SERIALIZED — no execution overlap"
    elif T_C <= 1.10 * over: verdict = "OVERLAPPED"
    else: verdict = "PARTIAL"
    out = {"L": L, "S": S, "run_verified": json.loads((ROOT / "results.json").read_text())["ok"],
           "T_A_dsd_alone": T_A, "T_B_chain_alone": T_B, "T_C_combined": T_C,
           "serial_prediction": serial, "overlap_prediction": over,
           "pct_of_serial": round(100 * T_C / serial, 1), "pct_of_full_overlap": round(100 * T_C / over, 1),
           "chain_steps": len(b), "chain_cyc_per_step_alone": round(T_B / len(b), 2),
           "chain_cyc_per_step_after_dsd": round((c1 - c0) / len(c), 2),
           "dsd_a": {"dispatch": A["cycle"], "x_first": xA["first"], "x_last": xA["last"], "records": xA["n"]},
           "dsd_c": {"dispatch": C["cycle"], "x_first": xC["first"], "x_last": xC["last"], "records": xC["n"]},
           "chain_execs_inside_dsd_window": len(inside), "chain_execs_total": len(c),
           "earliest_chain_dispatch_after_dsd": (c0 - C["cycle"]),
           "issue_held_cycles": held, "verdict": verdict}
    (ROOT / "overlap.json").write_text(json.dumps(out, indent=1))
    print(f"L={L} DSD elements, S={S} chain steps; run verified: {out['run_verified']}")
    print(f"\n  DSD alone            T_A = {T_A:>5}  (dispatch {A['cycle']}, execute {xA['first']}..{xA['last']}, {xA['n']} records)")
    print(f"  chain alone          T_B = {T_B:>5}  ({len(b)} steps, {out['chain_cyc_per_step_alone']} cyc/step)")
    print(f"  both, independent    T_C = {T_C:>5}")
    print(f"  serial prediction  A + B = {serial:>5}   -> T_C is {out['pct_of_serial']}% of it")
    print(f"  overlap prediction max(A,B) = {over}   -> T_C is {out['pct_of_full_overlap']}% of it")
    print(f"\n  chain execute records inside the DSD execute window: {len(inside)} of {len(c)}")
    print(f"  earliest chain dispatch after the DSD dispatched: +{c0 - C['cycle']} cyc (the DSD completes at +{T_A})")
    print(f"  the PE issues no application instruction for {held} cycles after the DSD dispatches")
    print(f"\nVERDICT: {verdict}")
    print("wrote", ROOT / "overlap.json")

if __name__ == "__main__":
    main()
