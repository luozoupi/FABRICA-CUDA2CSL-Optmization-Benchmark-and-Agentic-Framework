import gzip, json, collections
res = json.load(open("C2/results.json"))["rows"]
win = {r["name"]: (r["t_start"], r["t_end"]) for r in res}
hist = {k: collections.Counter() for k in ("ewmul_8", "ewmul_6144", "ewadd_6144")}
fab = collections.Counter()
for line in gzip.open("C2/events.jsonl.gz", "rt"):
    e = json.loads(line)
    if e.get("tile_index") != 12: continue
    c = e["cycle"]; t = e.get("event_type")
    for k, (lo, hi) in win.items():
        if lo <= c <= hi:
            if t == "hwm_dispatch_trace_entry" and k in hist:
                nd = e.get("num_data"); nd = nd if isinstance(nd, int) and nd < 65535 else 1
                hist[k][(e.get("name"), nd)] += 1
            elif t == "wavelet_trace_entry":
                fab[k] += 1
for k, h in hist.items():
    print(k, "top (name, num_data):", h.most_common(6))
print("fabric wavelets at PE per variant window:", dict(fab))
