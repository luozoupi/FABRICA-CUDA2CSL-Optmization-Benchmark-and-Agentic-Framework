#!/usr/bin/env python3
"""Model-driven 1-D Reduce planner: the HPDC'24 Auto-Gen idea on OUR constants.

Luczynski et al. pick a reduction tree by minimising a cost model with hop latency
1 cyc, no turn cost, and (2*T_R+1) = 5 cyc per store-and-forward stage (WSE-2).
This re-runs the same decision with the WSE-3 constants this study measured:

    hop latency        2 cyc      (silicon fit; 72% of simulated hops exactly 2)
    link bandwidth     1 wavelet / cyc / link   (agrees with theirs)
    relay stage        k          (2.07 from the corpus fit, or measured by microbench/relay)
    per-element store  1 cyc      (their assumption; our DSD copy sustains 8/cyc,
                                   so this is conservative and kept for comparability)

Patterns evaluated with the model T = max(C, E/N + hop*L) + k*D for a row of P PEs
reducing vectors of B wavelets to PE 0:

    star       every PE sends straight to the root            D=1
    chain      each PE forwards to its left neighbour          D=P-1
    tree       binary, log2 P rounds                            D=log2 P
    two-phase  chains of size sqrt(P), then a chain of roots    D=2*sqrt(P)-2
    auto-gen   DP over pre-order reduction trees (reconstructed from the paper's
               recursion; energy min over the split point of the last subtree)

The output is the decision table -- which pattern the model picks per (P, B) -- under
their constants and under ours, and where the two disagree.  It is an ANALYTICAL
prototype: no CSL is generated and nothing here is validated on a run.  Evidence:
`inferred`.
"""
from __future__ import annotations
import argparse, functools, json, math
from pathlib import Path

def cost(C, E, N, L, D, hop, k):
    return max(C, E / N + hop * L) + k * D

def star(P, B, hop, k):
    return cost(B * (P - 1), B * P * (P - 1) / 2, P - 1, P - 1, 1, hop, k)

def chain(P, B, hop, k):
    return cost(B, B * (P - 1), P - 1, P - 1, P - 1, hop, k)

def tree(P, B, hop, k):
    rounds = max(1, int(round(math.log2(P))))
    # each round: messages of B over 2^(r-1) hops, all rounds serial
    return sum(B + hop * (2 ** r) + k for r in range(rounds))

def two_phase(P, B, hop, k):
    S = max(2, int(round(math.sqrt(P))))
    groups = math.ceil(P / S)
    E = (S - 1) * B * groups + S * B * (groups - 1)
    D = (S - 1) + (groups - 1)
    return cost(2 * B, E, P - 1, P - 1, D, hop, k)

def auto_gen(P, B, hop, k):
    """Reconstruction of the Auto-Gen recursion: a pre-order tree on P PEs where the
    root's last child heads a subtree of i PEs (its message travels i hops) and the
    remaining P-i PEs form the rest.  Energy is minimised subject to depth/contention
    budgets; the outer loop scans budgets and takes the best synthesised time."""
    @functools.lru_cache(maxsize=None)
    def energy(n, D, Cc):
        if n <= 1:
            return 0.0
        if D < 1 or Cc < 1:
            return math.inf
        best = math.inf
        for i in range(1, n):
            e = energy(i, D - 1, Cc) + energy(n - i, D, Cc - 1) + i
            best = min(best, e)
        return best
    best = math.inf
    for D in range(1, P):
        for Cc in range(1, P):
            e = energy(P, D, Cc)
            if e == math.inf:
                continue
            best = min(best, cost(Cc * B, e * B, P - 1, P - 1, D, hop, k))
    return best

PATTERNS = {"star": star, "chain": chain, "tree": tree, "two-phase": two_phase, "auto-gen": auto_gen}

def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--k", type=float, default=2.07, help="WSE-3 relay stage cost (default: corpus fit)")
    ap.add_argument("--json", default=None)
    a = ap.parse_args()
    consts = {"theirs (WSE-2: hop 1, k 5)": (1.0, 5.0), f"ours (WSE-3: hop 2, k {a.k})": (2.0, a.k)}
    Ps, Bs = (8, 16, 32, 64), (1, 16, 256, 4096)
    out = {}
    for label, (hop, k) in consts.items():
        print(f"\n=== {label} ===")
        print(f"  {'P':>4}{'B':>6}   " + "".join(f"{n:>11}" for n in PATTERNS) + "   winner")
        for P in Ps:
            for B in Bs:
                row = {n: f(P, B, hop, k) for n, f in PATTERNS.items()}
                win = min(row, key=row.get)
                out.setdefault(label, []).append({"P": P, "B": B, **{n: round(v, 1) for n, v in row.items()}, "winner": win})
                print(f"  {P:>4}{B:>6}   " + "".join(f"{row[n]:>11.0f}" for n in PATTERNS) + f"   {win}")
    a_, b_ = list(out.values())
    flips = [(x["P"], x["B"], x["winner"], y["winner"]) for x, y in zip(a_, b_) if x["winner"] != y["winner"]]
    print(f"\ndecisions that change under our constants: {len(flips)} of {len(a_)}")
    for P, B, w1, w2 in flips:
        print(f"  P={P:<3} B={B:<5}  theirs -> {w1:<10} ours -> {w2}")
    if a.json:
        Path(a.json).write_text(json.dumps({"tables": out, "flips": flips}, indent=1))
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
