import gzip, json
rows = json.load(open("disasm.json")); rows = rows["records"] if isinstance(rows, dict) else rows
pe = sorted((r for r in rows if "atomic_add" in (r.get("source_file") or "")), key=lambda r: r["pc"])
print("pe.csl instructions:", len(pe), " source files seen:", len({r.get("source_file") for r in rows}))
disp = {}; s3 = {}; s6 = {}
for line in gzip.open("events.jsonl.gz", "rt"):
    e = json.loads(line)
    if e.get("tile_index") != 12: continue
    t = e.get("event_type")
    if t == "hwm_dispatch_trace_entry":
        disp.setdefault(e.get("inst_ptr"), []).append((e["cycle"], e["uid"], e.get("num_data")))
    elif t == "hwm_pipe_trace_entry":
        d = s3 if e.get("stage") == 3 else s6 if e.get("stage") == 6 else None
        if d is not None: d[e["uid"]] = min(d.get(e["uid"], e["cycle"]), e["cycle"])
# print only instructions that were dispatched exactly once in the compute region (the straight-line body)
print(f"{'pc':>6} {'disp':>7} {'dec':>7} {'exe':>7} {'nd':>5}  instruction")
for r in pe:
    ds = disp.get(r["pc"], [])
    if len(ds) != 1: continue
    c, uid, nd = ds[0]
    if c < 5000: continue     # skip early memcpy/setup code
    print(f"{hex(r['pc']):>6} {c:>7} {s3.get(uid,'-'):>7} {s6.get(uid,'-'):>7} {str(nd if isinstance(nd,int) and nd<65535 else 1):>5}  {r['instruction'][:66]}")
