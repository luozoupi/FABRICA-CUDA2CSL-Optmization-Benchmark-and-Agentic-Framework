#!/usr/bin/env python3
"""Full input and output paths, edge to kernel and kernel to edge, classified by REGION
(not colour: memcpy reuses colour numbers in the support region).

Fabric is 11 x 6 with the kernel at x 4-7, y 1-4. Documented layout (sdk.cerebras.ai,
tensor streaming): a halo, plus 3 support columns west of the kernel and 2 east.
For each phase window, every packet's path shape is reduced to its PE sequence, and the
shapes are counted. Evidence: `simulator`.
"""
import collections, gzip, json
from pathlib import Path

def region(x, y):
    if 4 <= x <= 7 and 1 <= y <= 4: return "K"
    if x == 0 or x == 10 or y == 0 or y == 5: return "H"
    return "W" if x < 4 else "E"

def run(kernel, windows):
    obs = collections.defaultdict(list)
    with gzip.open(f"results/wse3-full/kernels/{kernel}/events.jsonl.gz", "rt") as f:
        for line in f:
            if '"wavelet_trace_entry"' not in line: continue
            e = json.loads(line); s = e["coordinates"]["simulator"]
            obs[int(e["ident"])].append((e["cycle"], s["x"], s["y"], int(e["fields"]) & 0x1F))
    out = {}
    for name, (lo, hi) in windows.items():
        shapes = collections.Counter(); first = {}
        for ob in obs.values():
            ob.sort()
            if not (lo <= ob[0][0] <= hi): continue
            path = []
            for _, x, y, _ in ob:
                if not path or path[-1] != (x, y): path.append((x, y))
            if all(region(*p) == "K" for p in path): continue       # kernel traffic, shown elsewhere
            key = (tuple(path), ob[0][3]); shapes[key] += 1; first.setdefault(key, ob[0][0])
        print(f"\n== {kernel} {name} (cycles {lo}-{hi}): {sum(shapes.values())} non-kernel packets, "
              f"{len(shapes)} path shapes")
        for (path, col), n in shapes.most_common(12):
            regs = "".join(region(*p) for p in path)
            print(f"   {n:5d} x colour {col:2d}  {regs:12s} {' '.join(f'{x},{y}' for x, y in path)}")
        out[name] = [{"path": [list(p) for p in path], "colour": col, "packets": n,
                      "regions": "".join(region(*p) for p in path), "first_cycle": first[(path, col)]}
                     for (path, col), n in shapes.most_common(80)]
    return out

res = {"WaferLLM-MeshGEMM": run("WaferLLM-MeshGEMM", {"input": (0, 10000), "output": (19800, 36000)}),
       "WaferLLM-MeshGEMV": run("WaferLLM-MeshGEMV", {"input": (0, 5700), "output": (8000, 14200)})}
Path("results/datapath/io_paths.json").write_text(json.dumps(res, indent=1))
print("\n-> results/datapath/io_paths.json")
