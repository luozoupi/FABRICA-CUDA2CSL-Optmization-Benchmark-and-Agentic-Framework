#!/usr/bin/env python3
"""Score the synthesized runtime model against measured spans.

Two evaluations over the per-kernel components from runtime_model.py:

  HPDC form   T = roof + 5*D          (their 2*T_R+1 = 5, no offset)
  fitted      T = roof + k*D + c      (k, c least-squares over the corpus,
                                       plus leave-one-out cross-validation)

where roof = max(C, E/N + 2*L, W).  Their model was built for one collective
with synchronized starts; ours is scored on WHOLE PROGRAMS (H2D + compute + D2H),
so D here counts every inferred relay stage including the host stream -- the fit
tells us whether the same structural form carries over, and what a WSE-3 relay
stage costs.
"""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent / "results" / "runtime_model"


def fit(rows):
    """Least squares for measured - roof = k*D + c."""
    xs = [r["D"] for r in rows]
    ys = [r["measured"] - r["roof"] for r in rows]
    n = len(rows)
    sx, sy = sum(xs), sum(ys)
    sxx = sum(x * x for x in xs)
    sxy = sum(x * y for x, y in zip(xs, ys))
    den = n * sxx - sx * sx
    if not den:
        return 0.0, sy / n
    k = (n * sxy - sx * sy) / den
    c = (sy - k * sx) / n
    return k, c


def phase_roof(r):
    """Phases serialize in these programs (load -> compute -> drain, observed), so
    the whole-program estimate sums a roof per phase instead of taking one max."""
    return (max(r["C_in"], r["fab_in"]) + max(r["C_comp"], r["fab_comp"], r["W"])
            + max(r["C_out"], r["fab_out"]))


def fit_generic(rows, roof_fn, dkey, with_c=True):
    xs = [r[dkey] for r in rows]
    ys = [r["measured"] - roof_fn(r) for r in rows]
    n = len(rows)
    if not with_c:
        sxx = sum(x * x for x in xs); sxy = sum(x * y for x, y in zip(xs, ys))
        return (sxy / sxx if sxx else 0.0), 0.0
    sx, sy = sum(xs), sum(ys)
    sxx = sum(x * x for x in xs); sxy = sum(x * y for x, y in zip(xs, ys))
    den = n * sxx - sx * sx
    if not den:
        return 0.0, sy / n
    k = (n * sxy - sx * sy) / den
    return k, (sy - k * sx) / n


def score(rows, roof_fn, dkey, k, c):
    errs = []
    for r in rows:
        pred = roof_fn(r) + k * r[dkey] + c
        errs.append(abs(pred - r["measured"]) / r["measured"])
    s = sorted(errs)
    return s[len(s) // 2], sum(errs) / len(errs)


def main() -> int:
    rows = [json.loads(f.read_text()) for f in sorted(ROOT.glob("*.json"))
            if f.name != "summary.json"]
    rows = [r for r in rows if r["measured"] > 0]

    # ---- model family comparison -------------------------------------------
    print("model family comparison (22 kernels, whole-program spans)")
    print(f"  {'model':<46}{'k':>7}{'c':>9}{'median|err|':>13}{'mean|err|':>11}")
    fams = [
        ("HPDC form, their constants (k=5, c=0)", lambda r: r["roof"], "D", 5.0, 0.0, False),
        ("HPDC form, fitted k,c", lambda r: r["roof"], "D", None, None, True),
        ("phase model, fitted k on D_app, c=0", phase_roof, "D_app", None, None, False),
        ("phase model, fitted k on D_app + c", phase_roof, "D_app", None, None, True),
    ]
    for name, rf, dk, k0, c0, with_c in fams:
        if k0 is None:
            k0, c0 = fit_generic(rows, rf, dk, with_c)
        med, mean = score(rows, rf, dk, k0, c0)
        print(f"  {name:<46}{k0:>7.2f}{c0:>9.0f}{med:>12.1%}{mean:>11.1%}")
    kp, cp = fit_generic(rows, phase_roof, "D_app", True)

    # ---- optimality gaps ----------------------------------------------------
    print(f"\noptimality gap: lower bound = max(busiest link, E/N + 2L, FP floor)")
    print(f"  {'kernel':<24}{'measured':>9}{'bound':>9}{'%bound':>8}  binding")
    for r in sorted(rows, key=lambda r: -(r["pct_of_bound"] or 0)):
        binding = max((("link C", r["C"]), ("fabric", r["fabric_term"]),
                       ("compute", r["lb_compute"])), key=lambda kv: kv[1])[0]
        print(f"  {r['kernel']:<24}{r['measured']:>9}{r['lower_bound']:>9.0f}"
              f"{r['pct_of_bound']:>7.1f}%  {binding}")

    k, c = fit(rows)
    print(f"fitted stage cost k = {k:.2f} cyc/relay   offset c = {c:.0f} cyc   "
          f"(HPDC'24 WSE-2: k = 5, c = 0)\n")

    hdr = (f"{'kernel':<24}{'measured':>9}{'roof':>9}{'C':>7}{'fab':>8}{'W':>9}"
           f"{'D':>7}{'HPDC err':>10}{'fit err':>9}{'LOO err':>9}")
    print(hdr)
    errs_h, errs_f, errs_l = [], [], []
    out = []
    for i, r in enumerate(rows):
        pred_h = r["roof"] + 5 * r["D"]
        pred_f = r["roof"] + k * r["D"] + c
        others = rows[:i] + rows[i + 1:]
        kl, cl = fit(others)
        pred_l = r["roof"] + kl * r["D"] + cl
        eh = (pred_h - r["measured"]) / r["measured"]
        ef = (pred_f - r["measured"]) / r["measured"]
        el = (pred_l - r["measured"]) / r["measured"]
        errs_h.append(abs(eh)); errs_f.append(abs(ef)); errs_l.append(abs(el))
        dom = max((("C", r["C"]), ("fab", r["fabric_term"]), ("W", r["W"])),
                  key=lambda kv: kv[1])[0]
        print(f"{r['kernel']:<24}{r['measured']:>9}{r['roof']:>9.0f}{r['C']:>7}"
              f"{r['fabric_term']:>8.0f}{r['W']:>9.0f}{r['D']:>7}"
              f"{eh:>+10.1%}{ef:>+9.1%}{el:>+9.1%}")
        out.append({**r, "dominant_term": dom,
                    "pred_hpdc": round(pred_h), "err_hpdc": round(eh, 4),
                    "pred_fit": round(pred_f), "err_fit": round(ef, 4),
                    "err_loo": round(el, 4)})

    def med(v):
        s = sorted(v); return s[len(s) // 2]
    print(f"\n{'':<24}{'median |err|':>20}{'mean |err|':>14}")
    for name, e in (("HPDC constants (k=5)", errs_h), ("fitted", errs_f),
                    ("leave-one-out", errs_l)):
        print(f"{name:<24}{med(e):>19.1%}{sum(e)/len(e):>13.1%}")

    (ROOT / "summary.json").write_text(json.dumps(
        {"k_fitted": round(k, 3), "c_fitted": round(c, 1), "n_kernels": len(rows),
         "phase_model": {"k_on_D_app": round(kp, 3), "c": round(cp, 1)},
         "optimality": [{"kernel": r["kernel"], "measured": r["measured"],
                         "lower_bound": r["lower_bound"], "pct_of_bound": r["pct_of_bound"]}
                        for r in rows],
         "median_abs_err": {"hpdc": round(med(errs_h), 4),
                            "fitted": round(med(errs_f), 4),
                            "loo": round(med(errs_l), 4)},
         "rows": out}, indent=1))
    print(f"\nwrote {ROOT / 'summary.json'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
