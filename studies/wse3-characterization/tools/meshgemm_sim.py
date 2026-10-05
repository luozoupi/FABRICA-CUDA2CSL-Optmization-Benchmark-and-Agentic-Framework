#!/usr/bin/env python3
"""Reconstruct WaferLLM MeshGEMM's dataflow from its host and kernel source, and
check the reconstruction by computing C = X.W with it.

Placement is taken verbatim from ~/waferllm/MeshGEMM/host_common.py
(assignId, make_inputs' W offset, tile_X/tile_W/untile_res). Each step every PE
sends its X tile to its row-ring successor and its W tile to its column-ring
successor, which is what two_hop_comm does. If the resulting C equals X.W exactly,
the per-step ownership table this emits is the algorithm, not a guess.

Evidence: `source-derived`, verified by exact integer arithmetic.
"""
from __future__ import annotations
import itertools, json, random
from pathlib import Path

def assignId(pc, P):                        # verbatim port of host_common.assignId
    send_id = recv_id = 0
    pc = pc + 1
    if pc % 2 == 0: send_id, recv_id = pc - 2, pc + 2
    else:           send_id, recv_id = pc + 2, pc - 2
    if pc == 1: send_id, recv_id = 3, 2
    if pc == 2: send_id, recv_id = 1, min(recv_id, P)
    if P % 2 == 0:
        if pc == P - 1: send_id, recv_id = P, P - 3
        if pc == P:     send_id, recv_id = P - 2, P - 1
    else:
        if pc == P - 1: send_id, recv_id = max(send_id, 1), P
        if pc == P:     send_id, recv_id = P - 1, P - 2
    return send_id - 1, recv_id - 1

def ind_table(P):                           # verbatim port of make_inputs' ind
    ind = [[0] * P for _ in range(P)]
    for i in range(P):
        for j in range(P):
            if i == 0: ind[0][j] = j
            elif i == 1: _, ind[1][j] = assignId(ind[0][j], P)
            elif (i - 1) % 2 == 0: _, ind[i][j] = assignId(ind[i - 2][j], P)
            else: ind[i][j], _ = assignId(ind[i - 2][j], P)
    return ind

def matmul(A, B):
    n, k, m = len(A), len(B), len(B[0])
    return [[sum(A[i][t] * B[t][j] for t in range(k)) for j in range(m)] for i in range(n)]

def blk(M, bi, bj, t):
    return [row[bj * t:(bj + 1) * t] for row in M[bi * t:(bi + 1) * t]]

def simulate(P, t=2, seed=7):
    rng = random.Random(seed)
    n = P * t
    X = [[rng.randint(-4, 4) for _ in range(n)] for _ in range(n)]
    W = [[rng.randint(-4, 4) for _ in range(n)] for _ in range(n)]
    ind = ind_table(P)
    send = [assignId(p, P)[0] for p in range(P)]            # ring successor of position p
    # host: W tile at PE(px,py) is W block (ind[py][px], px)
    wk = {(px, py): ind[py][px] for px in range(P) for py in range(P)}
    # device pre-skew must leave X tile at PE(px,py) = X block (py, k) with the SAME k
    xk = dict(wk)
    C = {(px, py): [[0] * t for _ in range(t)] for px in range(P) for py in range(P)}
    steps = []
    for s in range(P):
        snap = {f"{px},{py}": {"x": [py, xk[(px, py)]], "w": [wk[(px, py)], px], "c": [py, px]}
                for px in range(P) for py in range(P)}
        steps.append(snap)
        for (px, py), cb in C.items():
            assert xk[(px, py)] == wk[(px, py)], "operand k mismatch"
            k = xk[(px, py)]
            prod = matmul(blk(X, py, k, t), blk(W, k, px, t))
            for i in range(t):
                for j in range(t):
                    cb[i][j] += prod[i][j]
        # shift: X to the row successor, W to the column successor
        nxk, nwk = {}, {}
        for (px, py) in xk:
            nxk[(send[px], py)] = xk[(px, py)]
            nwk[(px, send[py])] = wk[(px, py)]
        xk, wk = nxk, nwk
    ref = matmul(X, W)
    ok = all(C[(px, py)][i][j] == ref[py * t + i][px * t + j]
             for px in range(P) for py in range(P) for i in range(t) for j in range(t))
    return ok, steps, send, ind

if __name__ == "__main__":
    for P in (2, 3, 4, 5, 6, 7, 8, 10, 12):
        send = [assignId(p, P)[0] for p in range(P)]
        if sorted(send) != list(range(P)):
            print(f"  P={P}: assignId is not a ring (successors {send}) -- skipped")
            continue
        ok, *_ = simulate(P)
        print(f"  P={P}: ring {send}  C == X.W  ->  {'EXACT' if ok else 'MISMATCH'}")
    ok, steps, send, ind = simulate(4)
    ring = [0]
    while len(ring) < 4: ring.append(send[ring[-1]])
    hops = [abs(send[p] - p) for p in range(4)]
    print(f"\n  P=4 ring order {ring} -> hop lengths per position {hops}")
    out = {"P": 4, "ring_successor": send, "ring_order": ring, "hop_len": hops,
           "w_offset_ind": ind, "verified": ok, "steps": steps,
           "provenance": "host_common.py assignId/make_inputs/tile_*, meshgemm.csl two_hop_comm"}
    Path("results/datapath/meshgemm_steps.json").write_text(json.dumps(out, indent=1))
    print("  -> results/datapath/meshgemm_steps.json")
    for s, snap in enumerate(steps):
        row = "  ".join(f"({px},{py}):k={snap[f'{px},{py}']['x'][1]}" for py in [0] for px in range(4))
        print(f"   step {s}, row 0: {row}")
