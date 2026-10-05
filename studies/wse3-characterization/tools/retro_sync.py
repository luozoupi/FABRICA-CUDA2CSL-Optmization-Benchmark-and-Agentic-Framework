#!/usr/bin/env python3
"""Re-correct the silicon fabric-latency samples under a 2 cyc/hop sync assumption.

The SDK bandwidth-test synchronisation subtracts (x + y) from each PE's reference
timestamp, i.e. it assumes the sync wavelet reaches PE (x, y) after x + y cycles --
one cycle per hop (calibration_codegen.corrected_timestamp).  This study measured
the WSE-3 fabric at 2 cyc/hop in simulation, where no synchronisation is needed.
If the hardware also runs 2 cyc/hop, the 1-cyc assumption biases every corrected
elapsed time by exactly (tau - 1) * hops.

The ledger kept the raw 48-bit start/end and reference words plus PE coordinates
for every silicon event, so the correction can be redone for tau = 1 and tau = 2
and the hop coefficient refitted from the same data.  Evidence: `silicon` samples,
`inferred` re-analysis.
"""
from __future__ import annotations
import argparse, collections, json, statistics as st
from pathlib import Path

MOD48 = 1 << 48

def u48(w):
    return (int(w[0]) | (int(w[1]) << 16) | (int(w[2]) << 32)) % MOD48

def corrected(words, ref_words, xy, tau):
    ref = (u48(ref_words) - tau * (int(xy[0]) + int(xy[1]))) % MOD48
    return (u48(words) - ref) % MOD48

def elapsed(res, tau):
    s = corrected(res["start_words_u16"], res["source_reference_words_u16"], res["source_pe"], tau)
    e = corrected(res["end_words_u16"], res["destination_reference_words_u16"], res["destination_pe"], tau)
    d = (e - s) % MOD48
    return d if d < (1 << 40) else d - MOD48

def fit_hops_payload(rows):
    """elapsed = a + b*hops + p*payload, least squares."""
    X = [[1.0, r["hops"], r["payload"]] for r in rows]; y = [r["t"] for r in rows]
    n = 3
    XtX = [[sum(x[i] * x[j] for x in X) for j in range(n)] for i in range(n)]
    Xty = [sum(x[i] * yy for x, yy in zip(X, y)) for i in range(n)]
    A = [row[:] + [Xty[i]] for i, row in enumerate(XtX)]
    for c in range(n):
        piv = max(range(c, n), key=lambda r: abs(A[r][c])); A[c], A[piv] = A[piv], A[c]
        A[c] = [v / A[c][c] for v in A[c]]
        for r in range(n):
            if r != c:
                A[r] = [rv - A[r][c] * cv for rv, cv in zip(A[r], A[c])]
    return [A[i][n] for i in range(n)]

def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--ledger", default="results/wse3-full/ledger.jsonl")
    ap.add_argument("--json", default="results/retro_sync.json")
    a = ap.parse_args()
    samples = []
    with open(a.ledger) as fh:
        for line in fh:
            r = json.loads(line)
            if r.get("arm") != "hardware" or not r.get("accepted"):
                continue
            res = r.get("result") or {}
            if not isinstance(res, dict) or res.get("warmup"):
                continue
            if res.get("runner_screening_status") == "rejected_dead_timer" or not res.get("hw_comparable"):
                continue
            if res.get("family") != "straight":
                continue
            need = ("start_words_u16", "end_words_u16", "source_reference_words_u16",
                    "destination_reference_words_u16", "source_pe", "destination_pe", "hops", "payload_wavelets")
            if not all(k in res for k in need):
                continue
            samples.append(res)
    print(f"straight-family silicon samples with raw words: {len(samples)}")
    if len(samples) < 6:
        print("not enough samples to refit"); return 1

    out = {}
    for tau in (1, 2):
        rows = [{"t": elapsed(s, tau), "hops": int(s["hops"]), "payload": int(s["payload_wavelets"])} for s in samples]
        a0, b, pcoef = fit_hops_payload(rows)
        resid = [r["t"] - (a0 + b * r["hops"] + pcoef * r["payload"]) for r in rows]
        mae = st.mean(abs(x) for x in resid)
        # sanity: ledger's own elapsed should match our tau=1 recomputation
        agree = None
        if tau == 1:
            agree = st.mean(abs(elapsed(s, 1) - int(s["elapsed_cycles"])) for s in samples)
        by_h = collections.defaultdict(list)
        for r in rows:
            if r["payload"] == 1:
                by_h[r["hops"]].append(r["t"])
        print(f"\nsync assumption tau = {tau} cyc/hop")
        print(f"  fit  elapsed = {a0:.1f} + {b:.3f}*hops + {pcoef:.3f}*payload     MAE {mae:.1f} cyc")
        if agree is not None:
            print(f"  recomputed tau=1 elapsed vs ledger elapsed_cycles: mean |diff| = {agree:.2f} cyc")
        print("  payload=1 medians by hops: " + ", ".join(f"h{h}:{st.median(v):.0f}" for h, v in sorted(by_h.items())[:10]))
        out[f"tau_{tau}"] = {"intercept": a0, "cyc_per_hop": b, "cyc_per_wavelet": pcoef, "mae": mae,
                            "recompute_check": agree}
    print("\nreading: the fitted per-hop coefficient under tau=2 minus under tau=1 should be exactly +1.0,")
    print("because the correction moves every sample by (tau-1)*hops. The question this answers is not")
    print("'which tau is right' -- the sync cannot tell you that -- but what the silicon hop coefficient")
    print("becomes once the sync stops assuming the answer.")
    Path(a.json).write_text(json.dumps({"n_samples": len(samples), **out}, indent=1))
    print(f"wrote {a.json}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
