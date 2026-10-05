import gzip, json
rows = json.load(open("disasm.json")); rows = rows["records"] if isinstance(rows, dict) else rows
pe = sorted((r for r in rows if "atomic_ops" in (r.get("source_file") or "")), key=lambda r: r["pc"])
disp, s3, s6 = {}, {}, {}
for line in gzip.open("events.jsonl.gz", "rt"):
    e = json.loads(line)
    if e.get("tile_index") != 12: continue
    t = e.get("event_type")
    if t == "hwm_dispatch_trace_entry":
        disp.setdefault(e.get("inst_ptr"), []).append((e["cycle"], e["uid"], e.get("num_data")))
    elif t == "hwm_pipe_trace_entry":
        d = s3 if e.get("stage") == 3 else s6 if e.get("stage") == 6 else None
        if d is not None: d[e["uid"]] = min(d.get(e["uid"], e["cycle"]), e["cycle"])
meta = json.load(open("meta.json"))
print(f"{'pc':>6} {'disp':>6} {'dec':>6} {'exe':>6} {'nd':>3}  instruction")
cur = None
for r in pe:
    ds = disp.get(r["pc"], [])
    if not ds: continue
    t = r["instruction"]
    if "0x5a" in t:
        idx = int(t.split("0x5a")[1][:2], 16)
        print(f"\n=== marker {idx}: {meta[idx]['name'] if idx < len(meta) else 'END'}   ({meta[idx]['csl'] if idx < len(meta) else ''})")
    for c, uid, nd in sorted(ds):
        if c < 5000: continue
        nd = nd if isinstance(nd, int) and nd < 65535 else 1
        print(f"{hex(r['pc']):>6} {c:>6} {s3.get(uid,'-'):>6} {s6.get(uid,'-'):>6} {nd:>3}  {t[:60]}")
