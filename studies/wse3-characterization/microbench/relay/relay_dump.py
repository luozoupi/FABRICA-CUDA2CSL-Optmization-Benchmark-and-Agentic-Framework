import gzip, json, collections
X = 16
def pe_rows(fn, tag):
    rows = json.load(open(fn)); rows = rows["records"] if isinstance(rows, dict) else rows
    return {r["pc"]: r["instruction"] for r in rows if tag in (r.get("source_file") or "")}
d0 = pe_rows("disasm_pe0.json", "relay"); d1 = pe_rows("disasm_pe1.json", "relay")
disp = collections.defaultdict(list); s3 = {}; s6 = {}; wav = collections.defaultdict(list)
for line in gzip.open("events_n1b8.jsonl.gz", "rt"):
    e = json.loads(line); t = e.get("event_type"); tile = e.get("tile_index")
    if t == "hwm_dispatch_trace_entry": disp[tile].append((e["cycle"], e.get("inst_ptr"), e["uid"], e.get("num_data")))
    elif t == "hwm_pipe_trace_entry":
        d = s3 if e.get("stage") == 3 else s6 if e.get("stage") == 6 else None
        if d is not None: d[(tile, e["uid"])] = min(d.get((tile, e["uid"]), e["cycle"]), e["cycle"])
    elif t == "wavelet_trace_entry": wav[tile].append((e["cycle"], e.get("ident"), e.get("index"), (e.get("fields") or 0) & 0x1F))
print("tiles dispatching:", {t: len(v) for t, v in disp.items()})
res = json.load(open("result_N1_B8.json")); print("relay result:", res)
# the two application PEs are at x=4,5 (y=1) on a 16-wide fabric -> tiles 20, 21
for tile, dis, tag in ((20, d0, "PE0 (sender)"), (21, d1, "PE1 (receiver)")):
    rows = sorted(disp[tile]); late = [r for r in rows if r[0] >= min(w[0] for w in wav[tile]) - 40] if wav.get(tile) else rows[-25:]
    print(f"\n=== {tile} {tag}: {len(rows)} dispatches; wavelets seen {len(wav.get(tile, []))}")
    for c, pc, uid, nd in late[:40]:
        txt = dis.get(pc, "?")
        if "fab" in txt or "dsd" in txt.lower() or "fmovs" in txt or "actvt" in txt or "ublk" in txt or "wds" in txt or nd not in (None, 1, 65535):
            print(f"  {c:>6} dec {s3.get((tile,uid),'-'):>6} exe {s6.get((tile,uid),'-'):>6} nd={nd!s:>5}  {txt[:58]}")
    for c, ident, idx, col in sorted(wav.get(tile, []))[:10]:
        print(f"  wavelet @ {c}  ident={ident} index={idx} colour={col}")
