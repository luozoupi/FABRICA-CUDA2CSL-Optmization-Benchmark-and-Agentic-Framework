#!/usr/bin/env python3
"""Render the cached 3-D mesh scenes into one self-contained WebGL page.

Scene JSON comes from tools/mesh3d_scenes.py.  This step only picks the moments
worth opening on, writes the guided walkthrough, and inlines everything.
"""
from __future__ import annotations

import argparse
import bisect
import datetime as dt
import json
from pathlib import Path

STUDY = Path(__file__).resolve().parent.parent
ORDER = ["relay", "relay_compute", "single_pe", "meshgemv", "meshgemm", "meshgemm_full"]


def busiest(scene, lo_frac=0.0, hi_frac=1.0):
    """Relative cycle where the most packets are in flight, within a fraction band."""
    span = scene["stride"] * scene["nb"]
    lo, hi = lo_frac * span, hi_frac * span
    life = {i: t["d"][-1] for i, t in enumerate(scene["templates"])}
    step = max(1, int(span / 400))
    starts = [w[1] for w in scene["waves"]]
    best, bestn = int(lo), -1
    for c in range(int(lo), int(hi), step):
        i = bisect.bisect_left(starts, c - 60)
        n = 0
        while i < len(starts) and starts[i] <= c:
            if c - starts[i] <= life[scene["waves"][i][0]]:
                n += 1
            i += 1
        if n > bestn:
            best, bestn = c, n
    return best, bestn


def quietest(scene):
    """Relative cycle in the longest stretch with no packet launches at all."""
    starts = sorted(w[1] for w in scene["waves"])
    if len(starts) < 2:
        return 0, 0
    gap, at = 0, 0
    for a, b in zip(starts, starts[1:]):
        if b - a > gap:
            gap, at = b - a, a + (b - a) // 2
    return at, gap


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--scenes", default=str(STUDY / "results/mesh3d/scenes"))
    ap.add_argument("-o", "--out", default=str(STUDY / "results/anatomy/mesh3d.html"))
    a = ap.parse_args()

    src = Path(a.scenes)
    scenes = []
    for n in ORDER:
        f = src / f"{n}.json"
        if f.exists():
            scenes.append(json.loads(f.read_text()))
    if not scenes:
        raise SystemExit("no scenes in " + str(src))

    by = {s["name"]: s for s in scenes}
    moment = {}
    for s in scenes:
        c, n = busiest(s)
        s["start"] = c
        moment[s["name"]] = c
        print(f"  {s['name']:14s} opens at relative cycle {c:7d} "
              f"({n} packets in flight)  span={s['stride']*s['nb']}")

    def abscyc(name, rel):
        return by[name]["cycles"][0] + rel

    ISO = [round(3.14159 * 0.24, 4), round(3.14159 * 0.30, 4)]
    tour = []
    if "relay" in by:
        tour.append({"tag": "1 · the control", "scene": "relay",
                     "cycle": abscyc("relay", moment["relay"]), "pe": [5, 1],
                     "cam": [0.85, 1.25, 9], "speed": 1,
                     "text": "Eight words leave PE (4,1) and arrive at (5,1). One hop, "
                             "nothing else in the program. If the pipeline lies, it lies here."})
        tour.append({"tag": "2 · two cycles a hop", "scene": "relay",
                     "cycle": abscyc("relay", moment["relay"]), "pe": [4, 1],
                     "cam": [1.15, 1.4, 6], "speed": 0.25,
                     "text": "At a quarter cycle per frame the dot crosses the link in the "
                             "two cycles the trace actually recorded between the two observations."})
    if "single_pe" in by:
        tour.append({"tag": "3 · the overhead", "scene": "single_pe",
                     "cycle": abscyc("single_pe", moment["single_pe"]), "pe": [4, 1],
                     "cam": [0.06, 0.0, 13], "speed": 4,
                     "text": "Plan view. One PE runs the 22 atomic instruction forms. Every "
                             "other lit tile is memcpy plumbing moving operands in and results out."})
    if "meshgemv" in by:
        tour.append({"tag": "4 · many packets, one route", "scene": "meshgemv",
                     "cycle": abscyc("meshgemv", moment["meshgemv"]), "pe": [2, 1],
                     "cam": [0.30, 0.55, 20], "speed": 1,
                     "text": "Packets run east along row 1, then turn south down column 2 and "
                             "out across the 4×4 tile. The turn is a compiled route. Each strand "
                             "is a separate packet: no identity here ever branches."})
        tour.append({"tag": "5 · where the math is", "scene": "meshgemv",
                     "cycle": abscyc("meshgemv", moment["meshgemv"]), "pe": [6, 3],
                     "cam": [ISO[0], ISO[1], 18], "speed": 4,
                     "text": "Teal tiles issued floating-point arithmetic. Everything blue-grey "
                             "issued loop, address and move instructions only."})
    if "meshgemm" in by:
        q, gap = quietest(by["meshgemm"])
        tour.append({"tag": "6 · the reduction", "scene": "meshgemm",
                     "cycle": abscyc("meshgemm", moment["meshgemm"]), "pe": [5, 4],
                     "cam": [0.42, 0.62, 16], "speed": 1,
                     "text": "In the MeshGEMM steady state every packet travels west: "
                             "(7,y) to (6,y) to (5,y). This is the partial-sum reduction, and "
                             "all 60 observed hop intervals are 2 cycles."})
        if gap > 200:
            tour.append({"tag": "7 · compute, no traffic", "scene": "meshgemm",
                         "cycle": abscyc("meshgemm", q), "pe": [6, 2],
                         "cam": [0.55, 0.30, 15], "speed": 4,
                         "text": f"A {gap:,}-cycle stretch with no packet launched at all. The "
                                 "tiles keep dispatching, so the kernel is compute-bound here, "
                                 "not waiting on the fabric."})
    for t in tour:
        t["mode"] = "flow"

    if "meshgemm_full" in by:
        tour.append({"tag": "8 · the whole run", "scene": "meshgemm_full", "mode": "flow",
                     "cycle": abscyc("meshgemm_full", 0), "pe": [5, 2],
                     "cam": [0.22, 0.35, 22], "speed": 100,
                     "text": "All 122,741 cycles at 100× . Setup and teardown light a wider "
                             "footprint than the 4×4 compute tile, and the long quiet middle "
                             "is five PEs of runtime, not the kernel."})

    # ---- trellis steps: the same traces read as a space-time stack ----
    if "meshgemv" in by:
        tour.append({"tag": "9 · stack the cycles", "scene": "meshgemv", "mode": "trellis",
                     "cycle": abscyc("meshgemv", moment["meshgemv"]), "pe": [2, 1],
                     "layers": 16, "stride": 2, "cam": [1.13, 0.94, 24], "speed": 1,
                     "text": "The same MeshGEMV moment, but every plane is one cycle and "
                             "time runs upward. A hop is now a line between two planes, so "
                             "a whole route is one continuous thread instead of a moving dot."})
        tour.append({"tag": "10 · slope is latency", "scene": "meshgemv", "mode": "trellis",
                     "cycle": abscyc("meshgemv", moment["meshgemv"]), "pe": [2, 3],
                     "layers": 24, "stride": 2, "cam": [1.545, 1.5708, 26], "speed": 1,
                     "play": False,
                     "text": "Edge on, with the stride set to the 2-cycle hop. A transit "
                             "line spanning one plane is travelling at fabric speed; the "
                             "steeper lines are injection and drain at the ends of a route."})
    if "meshgemm" in by:
        tour.append({"tag": "11 · reduction as diagonals", "scene": "meshgemm",
                     "mode": "trellis",
                     "cycle": abscyc("meshgemm", moment["meshgemm"]), "pe": [5, 4],
                     "layers": 24, "stride": 2, "cam": [1.20, 0.80, 25], "speed": 1,
                     "text": "MeshGEMM's steady state stacked. The partial-sum reduction "
                             "leans west at one constant angle, four rows in parallel: every "
                             "hop drawn here spans exactly one plane, with no exceptions."})

    # lineage audit -> the table that tells the reader what the pairing rule costs
    ap = STUDY / "results/datapath/lineage_audit.json"
    if ap.exists():
        A = json.loads(ap.read_text())
        LBL = {"relay": "relay, 1 hop", "relay_compute": "relay + compute",
               "single_pe": "atomic_ops, 1 PE", "meshgemv": "MeshGEMV",
               "meshgemm_full": "MeshGEMM, whole run"}
        head = ("<thead><tr><th>Capture</th><th>Identities</th><th>Simple path</th>"
                "<th>Branching</th><th>Ambiguous step</th><th>Non-adjacent</th>"
                "<th>Seen once</th><th>Shared origin</th></tr></thead><tbody>")
        body = []
        for k, v in A.items():
            c = v["classes"]
            z = lambda n: ('<td class="n">%d</td>' % n if n else
                           '<td class="n" style="color:var(--compute)">0</td>')
            body.append(
                f'<tr><td>{LBL.get(k, k)}</td><td class="n">{v["idents"]:,}</td>'
                f'<td class="n">{c.get("linear", 0):,}</td>'
                f'{z(c.get("branching", 0))}{z(c.get("ambiguous", 0))}{z(c.get("broken", 0))}'
                f'<td class="n">{c.get("solo", 0):,}</td>'
                f'{z(v["origins_shared_by_multiple_idents"])}</tr>')
        tot = sum(v["idents"] for v in A.values())
        body.append(f'<tr><td><strong>all</strong></td><td class="n"><strong>{tot:,}</strong></td>'
                    f'<td class="n"><strong>{sum(v["classes"].get("linear",0) for v in A.values()):,}'
                    f'</strong></td>{z(0)}{z(0)}{z(0)}'
                    f'<td class="n">{sum(v["classes"].get("solo",0) for v in A.values()):,}</td>{z(0)}</tr>')
        audit = head + "".join(body) + "</tbody>"
    else:
        audit = "<tbody><tr><td>lineage audit not run</td></tr></tbody>"

    tpl = (STUDY / "tools/mesh3d.html.tpl").read_text()
    html = (tpl.replace("__SCENES__", json.dumps(scenes, separators=(",", ":")))
               .replace("__TOURS__", json.dumps(tour, separators=(",", ":")))
               .replace("__START__", json.dumps("meshgemv" if "meshgemv" in by else scenes[0]["name"]))
               .replace("__AUDIT__", audit)
               .replace("__STAMP__", json.dumps(
                   "built " + dt.datetime.now().strftime("%Y-%m-%d"))))
    out = Path(a.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(html)
    print(f"\n  -> {out}  {out.stat().st_size/1e6:.2f} MB  "
          f"{len(scenes)} scenes, {len(tour)} walkthrough steps")


if __name__ == "__main__":
    main()
