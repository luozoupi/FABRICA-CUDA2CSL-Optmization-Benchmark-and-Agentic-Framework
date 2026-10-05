#!/usr/bin/env python3
"""Branch cost from the dispatch trace.

For every `jmp` dispatched on the compute PE inside a variant's TSC window, the
next dispatch tells the outcome: a PC that is not the fall-through (jmp PC + 2
words) means the branch was taken.  The cycle gap from the jmp to that next
dispatch is the branch cost as the pipeline actually paid it.  Predicated jumps
carry a `cflag ? jmp` form; the compare that produced the predicate is found by
walking back within the window, giving the compare->branch distance too.
"""
import collections, gzip, json, statistics as st

res = json.load(open("results.json"))
disp = []
for line in gzip.open("events.jsonl.gz", "rt"):
    e = json.loads(line)
    if e.get("event_type") == "hwm_dispatch_trace_entry":
        disp.append((e["cycle"], e["tile_index"], e.get("inst_ptr"), e.get("name") or ""))
tiles = collections.Counter(t for _, t, _, _ in disp)
app = tiles.most_common(1)[0][0]
mine = sorted(d for d in disp if d[1] == app)
print(f"app PE tile {app}: {len(mine)} dispatches")

print(f"\n{'variant':<10}{'cyc/iter':>9}{'jmps':>7}{'taken':>7}{'gap taken':>11}{'gap fallthru':>13}{'cmp->jmp':>10}  jmp share of dispatches")
for v in res:
    lo, hi = v["t_start"], v["t_end"]
    win = [d for d in mine if lo <= d[0] <= hi]
    taken, fall, dist = [], [], []
    for i, (cyc, _t, pc, name) in enumerate(win[:-1]):
        if not name.upper().startswith("JMP"):
            continue
        ncyc, _nt, npc, _nn = win[i + 1]
        gap = ncyc - cyc
        (taken if npc != pc + 2 else fall).append(gap)
        # distance back to the compare that set the predicate
        for k in range(i - 1, max(-1, i - 8), -1):
            if any(win[k][3].upper().startswith(p) for p in ("LT", "EQ", "GT", "NE", "GE", "LE")):
                dist.append(i - k); break
    nj = len(taken) + len(fall)
    f = lambda xs: (f"{st.median(xs):.1f} (n={len(xs)})" if xs else "—")
    print(f"{v['variant']:<10}{v['cyc_per_iter']:>9.3f}{nj:>7}{len(taken):>7}{f(taken):>11}{f(fall):>13}"
          f"{(f'{st.median(dist):.0f}' if dist else '—'):>10}  {100*nj/max(len(win),1):.0f}%")
    if v["variant"] in ("loop", "true", "false", "alt"):
        seq = collections.Counter(n for _, _, _, n in win)
        print(f"           instruction mix: " + ", ".join(f"{k}:{c}" for k, c in seq.most_common(7)))
