import gzip, json, collections
MEMCPY = {0,1,2,3,4,5,21,22,23}
def pe_rows(fn, tag):
    rows = json.load(open(fn)); rows = rows["records"] if isinstance(rows, dict) else rows
    return {r["pc"]: r["instruction"] for r in rows if tag in (r.get("source_file") or "")}
d0 = pe_rows("disasm_pe0.json", "relay"); d1 = pe_rows("disasm_pe1.json", "relay")
disp = collections.defaultdict(list); s3 = {}; s6 = {}; wav = collections.defaultdict(list)
for line in gzip.open("events_n1b8.jsonl.gz", "rt"):
    e = json.loads(line); t = e.get("event_type"); tile = e.get("tile_index")
    if t == "hwm_dispatch_trace_entry": disp[tile].append((e["cycle"], e.get("inst_ptr"), e["uid"], e.get("num_data"), e.get("task_color"), e.get("name")))
    elif t == "hwm_pipe_trace_entry":
        d = s3 if e.get("stage") == 3 else s6 if e.get("stage") == 6 else None
        if d is not None: d[(tile, e["uid"])] = min(d.get((tile, e["uid"]), e["cycle"]), e["cycle"])
    elif t == "wavelet_trace_entry": wav[tile].append((e["cycle"], e.get("ident"), e.get("index"), (e.get("fields") or 0) & 0x1F, e.get("data")))
app = {t: [w for w in ws if w[3] not in MEMCPY] for t, ws in wav.items()}
print("app wavelets per tile:", {t: len(v) for t, v in app.items() if v})
allw = sorted(w for t in (20, 21) for w in app.get(t, []))
lo = min(w[0] for w in allw) - 45; hi = max(w[0] for w in allw) + 40
print(f"window {lo}..{hi}")
for tile, dis, tag in ((20, d0, "PE0 sender"), (21, d1, "PE1 receiver")):
    print(f"\n=== tile {tile} {tag}")
    for c, pc, uid, nd, col, nm in sorted(disp[tile]):
        if lo <= c <= hi:
            nd = nd if isinstance(nd, int) and nd < 65535 else 1
            print(f"  {c:>5} dec {s3.get((tile,uid),'-'):>5} exe {s6.get((tile,uid),'-'):>5} nd={nd:<3} task={col!s:>3} {hex(pc) if pc else '?':>6} {dis.get(pc, nm or '?')[:56]}")
    for c, ident, idx, col, data in sorted(app.get(tile, [])):
        print(f"  wavelet @ {c}  colour={col} data={data!s:.20}")
