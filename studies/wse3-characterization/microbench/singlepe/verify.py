"""Numerical verification of the single-PE suites.

Every variant is replayed in numpy in the EXACT order the generated compute()
runs them, on the same inputs the runner sends, with f16 rounding applied where
the hardware rounds: once per FMA (fused), once per add or multiply, sequentially
for scalar-destination reductions.  Variants share arrays, so only the final
state is observable -- the model reproduces the whole sequence and compares the
final arrays and the register accumulators (exported through `sink`).

Comparison is in f16 ulps at the expected value; a variant family passes when the
max deviation is <= ULP_TOL.  Integer paths and copies must be bit-exact.
"""
import numpy as np

A_SCALAR = np.float64(np.float16(1.0009765625))   # the @as(f16, ...) immediate in gen.py
ULP_TOL = 2


def r16(x):
    return np.asarray(x, dtype=np.float64).astype(np.float16).astype(np.float64)


def inputs(suite, meta):
    ex = {e["name"]: e for e in meta["exports"]}
    i = lambda n: np.arange(n, dtype=np.int64)
    if suite == "A":
        return {"A": r16((i(12288) % 251) * 0.25 - 31.0), "Bb": np.zeros(4096)}
    if suite == "B":
        # x is antisymmetric per adjacent pair (+v, -v) except x[0], which carries an
        # extra +0.125 so every full-window sum is a small exact multiple of 0.125
        # rather than zero; y (axpy/dot operand) and z (vdot operand) are constant
        # per pair so products cancel pairwise too.  Reductions stay finite and
        # non-trivial; axpy's y saturates in f16 exactly as the hardware does.
        k = i(2048) // 2
        v = ((k * 7) % 4 + 1) * 0.125
        x = np.where(i(2048) % 2 == 0, v, -v); x[0] += 0.125
        y = np.array([0.5, 1.0, 2.0])[(k * 5) % 3]
        z = np.array([0.5, 1.0, 2.0])[(k * 3) % 3]
        return {"x_arr": r16(x), "y_arr": r16(y), "t_arr": np.zeros(2048), "z_arr": r16(z)}
    if suite == "C1":
        return {"Amat": r16(((i(4096) * 5) % 31) * 0.0625 - 0.9375),
                "X": r16((i(64) % 9) * 0.125 - 0.5), "Y": np.zeros(64), "Bout": np.zeros(4096)}
    if suite == "C2":
        return {"a3": r16((i(6144) % 97) * 0.03125 - 1.5),
                "b3": r16(((i(6144) * 11) % 89) * 0.0625 - 2.75), "c3": np.zeros(6144)}
    if suite == "D":
        return {"ia": ((i(2048) % 101) - 50).astype(np.int16),
                "ib": (((i(2048) * 13) % 97) - 48).astype(np.int16),
                "ic": np.zeros(2048, np.int16), "q8": ((i(512) % 23) - 11).astype(np.int8)}
    raise ValueError(suite)


def expect(suite, meta, inp):
    """Replay the suite; return expected arrays and per-variant expected sink values."""
    S = {k: v.copy() for k, v in inp.items()}
    sinks = {}
    V = meta["variants"]
    if suite == "A":
        A, Bb = S["A"], S["Bb"]; rsink = 0.0; chk = 0.0
        for v in V:
            n, r = v["elems"], v["reps"]
            if v["family"] == "read":
                rsink = A[n - 1]
            elif v["family"] == "copy":
                Bb[:n] = A[:n]
            elif v["family"] == "rstride":
                st = int(v["name"].split("_")[1]); Bb[:n] = A[st * np.arange(n)]
            elif v["family"] == "write":
                A[:n] = 1.5
            # checksum consume: sequential f16 accumulation over the destination prefix
            if v["family"] in ("copy", "rstride", "write"):
                dst = A if v["family"] == "write" else Bb
                for e in dst[:n]:
                    chk = float(r16(chk + e))
            sinks[v["name"]] = {"read": rsink, "copy": chk, "rstride": chk, "write": chk}[v["family"]]
    elif suite == "B":
        x, y, t, z = S["x_arr"], S["y_arr"], S["t_arr"], S["z_arr"]; acc = 0.0
        for v in V:
            n, r = v["elems"], v["reps"]; fam = v["family"]
            if fam == "axpy":
                for _ in range(r):
                    y[:n] = r16(y[:n] + A_SCALAR * x[:n])          # FMACH: one rounding
            elif fam == "dotloop":
                for rr in range(r):
                    for i in range(n):                                # scalar FMULH then FADDH
                        acc = float(r16(acc + float(r16(x[(i + rr) & 2047] * y[i]))))
            elif fam == "vdot":
                for _ in range(r):
                    t[:n] = r16(x[:n] * z[:n])
                    for i in range(n):
                        acc = float(r16(acc + t[i]))
            elif fam == "reduce":
                for _ in range(r):
                    for i in range(n):
                        acc = float(r16(acc + x[i]))
            sinks[v["name"]] = (y[1] if v["name"] == "axpy_2047" else y[0]) if fam == "axpy" else acc
    elif suite == "C1":
        Am, X, Y, Bo = S["Amat"], S["X"], S["Y"], S["Bout"]
        for v in V:
            if v["family"] == "gemv":
                M, K = (int(z) for z in v["name"].split("_")[1].split("x"))
                for _ in range(v["reps"]):
                    Y[:M] = 0.0
                    for k in range(K):
                        Y[:M] = r16(Y[:M] + Am[k * M:(k + 1) * M] * X[k])
            else:
                n = v["elems"]; ii = np.arange(n)
                o = r16(Am[ii + 64] + Am[ii + 63]); o = r16(o + Am[ii + 65])
                o = r16(o + Am[ii]); o = r16(o + Am[ii + 128]); Bo[64:64 + n] = o
            sinks[v["name"]] = Y[0] if v["family"] == "gemv" else Bo[64]
    elif suite == "C2":
        a, b, c = S["a3"], S["b3"], S["c3"]
        for v in V:
            n = v["elems"]
            c[:n] = r16(a[:n] * b[:n]) if v["family"] == "ewmul" else r16(a[:n] + b[:n])
            sinks[v["name"]] = c[0]
    elif suite == "D":
        ia, ib, ic, q8 = S["ia"], S["ib"], S["ic"], S["q8"]; iacc = np.int16(0); qacc = np.int8(0)
        for v in V:
            n, r = v["elems"], v["reps"]; fam = v["family"]
            if fam == "iadd16":
                ic[:n] = (ia[:n].astype(np.int32) + ib[:n]).astype(np.int16)
            elif fam == "idot16":
                for rr in range(r):
                    for i in range(n):
                        iacc = np.int16((int(iacc) + int(ia[(i + rr) & 2047]) * int(ib[i])) & 0xFFFF)
            elif fam == "i8":
                for rr in range(r):
                    for i in range(512):
                        qacc = np.int8((int(qacc) + int(q8[(i + rr) & 511])) & 0xFF)
            sinks[v["name"]] = {"iadd16": float(ic[0]), "idot16": float(iacc), "i8": float(qacc)}[fam]
    return S, sinks


def ulps(got, exp):
    """|got - exp| in units of f16 spacing at exp (float arrays)."""
    exp = np.asarray(exp, dtype=np.float64); got = np.asarray(got, dtype=np.float64)
    both_inf = np.isinf(exp) & np.isinf(got) & (np.sign(exp) == np.sign(got))
    exp = np.where(both_inf, 0.0, exp); got = np.where(both_inf, 0.0, got)
    spacing = np.spacing(np.abs(exp).astype(np.float16)).astype(np.float64)
    spacing = np.where(spacing == 0, np.spacing(np.float16(0)).astype(np.float64), spacing)
    return np.abs(got - exp) / spacing


def check(suite, meta, inp, got_arrays, got_sinks):
    S, exp_sinks = expect(suite, meta, inp)
    report = []
    ok_all = True
    for e in meta["exports"]:
        n = e["name"]; exp = S[n]; got = got_arrays[n]
        if e["dtype"] in ("i16", "i8"):
            bad = int(np.sum(got.astype(np.int64) != exp.astype(np.int64)))
            ok = bad == 0; report.append((n, "bit-exact" if ok else f"{bad} mismatches", ok))
        else:
            u = ulps(got, exp); mx = float(np.max(u)) if u.size else 0.0
            ok = mx <= ULP_TOL
            report.append((n, f"max {mx:.1f} ulp, exact {100*np.mean(u == 0):.1f}%", ok))
        ok_all &= ok
    worst = {}
    for v in meta["variants"]:
        fam = v["family"]; exp = exp_sinks[v["name"]]; got = got_sinks[v["name"]]
        u = float(ulps([got], [exp])[0]) if fam not in ("iadd16", "idot16", "i8") else (0.0 if got == exp else 1e9)
        if fam not in worst or u > worst[fam][0]:
            worst[fam] = (u, got, exp, v["name"])
    for fam, (u, got, exp, name) in worst.items():
        ok = u <= ULP_TOL
        report.append((f"sink:{fam}", f"worst {name}: got {got:.6g} expected {exp:.6g} ({u:.1f} ulp)", ok)); ok_all &= ok
    return ok_all, report
