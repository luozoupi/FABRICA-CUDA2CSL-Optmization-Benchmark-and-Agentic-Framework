#!/usr/bin/env python3
"""Fold the per-suite results into knee fits and roofline points.

For every family the cycles-vs-N points are fitted to cycles = a + b*N per rep
(least squares), giving the setup cost `a` and asymptotic per-element cost `b`
directly -- the same form the study's silicon cost model uses, so the simulator
columns here are directly comparable against FINDINGS section 3.

Roofline coordinates per family: intensity = flop/bytes (from meta), and
performance = flop * (1/b) FLOP/cycle at the asymptote.  Units are FLOP/cycle
and B/cycle; multiply by the clock only if you must quote absolute numbers --
this study does not assume 850 MHz.
"""

from __future__ import annotations

import json
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).parent
SUITES = ("A", "B", "C1", "C2", "D")


def fit(points):
    """Least-squares cycles = a + b*N over (N, cycles-per-rep) points."""
    if len(points) < 2:
        return None, None
    n = len(points)
    sx = sum(x for x, _ in points); sy = sum(y for _, y in points)
    sxx = sum(x * x for x, _ in points); sxy = sum(x * y for x, y in points)
    d = n * sxx - sx * sx
    if not d:
        return None, None
    b = (n * sxy - sx * sy) / d
    a = (sy - b * sx) / n
    return a, b


def main() -> int:
    rows = []
    for s in SUITES:
        f = ROOT / s / "results.json"
        if f.exists():
            rows += [dict(r, suite=s) for r in json.loads(f.read_text())["rows"]]
    bf = ROOT / "C2bf" / "results.json"
    if bf.exists():
        rows += [dict(r, suite="C2", family=r["family"] + "_bf16")
                 for r in json.loads(bf.read_text())["rows"]]

    fams = defaultdict(list)
    for r in rows:
        fams[(r["suite"], r["family"])].append(r)

    print(f"{'suite':<6}{'family':<14}{'points':>7}{'setup a':>10}{'cyc/elem b':>12}"
          f"{'elem/cyc':>10}{'FLOP/cyc':>10}{'B/cyc':>8}{'FLOP/B':>8}")
    out = []
    for (suite, fam), rs in sorted(fams.items()):
        pts = [(r["elems"], r["cycles"] / r["reps"]) for r in rs]
        a, b = fit(pts)
        big = min(rs, key=lambda r: r["cyc_per_elem"])
        bpe = big["cyc_per_elem"]
        flop, byts = big["flop"], big["bytes"]
        perf = flop / bpe if flop else 0.0
        bw = byts / bpe
        inten = flop / byts if byts else None
        arow = f"{a:>10.1f}" if a is not None else f"{'--':>10}"
        brow = f"{b:>12.4f}" if b is not None else f"{'--':>12}"
        print(f"{suite:<6}{fam:<14}{len(rs):>7}{arow}{brow}"
              f"{1/bpe:>10.3f}{perf:>10.3f}{bw:>8.2f}"
              f"{inten if inten is not None else 0:>8.3f}")
        out.append({"suite": suite, "family": fam, "n_points": len(rs),
                    "setup_cycles": round(a, 2) if a is not None else None,
                    "asymptote_cyc_per_elem": round(b, 5) if b is not None else None,
                    "best_elem_per_cyc": round(1 / bpe, 4),
                    "flop_per_cyc": round(perf, 4), "bytes_per_cyc": round(bw, 3),
                    "intensity_flop_per_byte": inten})

    ref = {"copy_f16_sim": 8.00, "fma_f16_sim": 4.00, "setup_range": (15, 17)}
    print(f"\ncross-check vs FINDINGS section 3 (fitted silicon-campaign sim model):")
    print(f"  copy f16 expected {ref['copy_f16_sim']:.2f} elem/cyc; "
          f"fma f16 expected {ref['fma_f16_sim']:.2f}; setup 15-17 cyc")
    dst = ROOT.parent.parent / "results" / "singlepe_roofline.json"
    dst.write_text(json.dumps({"families": out, "reference": ref}, indent=1))
    print(f"wrote {dst}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
