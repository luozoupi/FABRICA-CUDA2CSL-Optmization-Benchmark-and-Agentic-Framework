#!/usr/bin/env cs_python
"""Seed a banded matrix in CSR and diagonal form, run all five entry points, verify against numpy."""
import argparse, json
import numpy as np
from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType, MemcpyOrder
ap = argparse.ArgumentParser(); ap.add_argument("--name", default="out"); ap.add_argument("--cmaddr"); a = ap.parse_args()
m = json.load(open("meta.json")); NR, NC, MX, RP, ND = m["NROWS"], m["NCOLS"], m["MAXNNZ"], m["RPLEN"], m["NDIA"]
F32, RM = MemcpyDataType.MEMCPY_32BIT, MemcpyOrder.ROW_MAJOR

# banded: row r holds columns [max(0,r-1) .. min(NC-1,r+2)] -> contiguous runs AND four diagonals
A = np.zeros((NR, NC), np.float32)
row_ptr = np.zeros(RP, np.uint16); col_idx = np.zeros(MX, np.uint16)
col_start = np.zeros(NR, np.uint16); run_len = np.zeros(NR, np.uint16); val = np.zeros(MX, np.float32)
nnz = 0
for r in range(NR):
    c0, c1 = max(0, r - 1), min(NC - 1, r + 2)
    row_ptr[r] = nnz; col_start[r] = c0; run_len[r] = c1 - c0 + 1
    for c in range(c0, c1 + 1):
        v = np.float32((r * 4 + (c - c0) + 1) * 0.25)
        col_idx[nnz] = c; val[nnz] = v; A[r, c] = v; nnz += 1
row_ptr[NR] = nnz
x = np.array([(c + 1) * 0.5 for c in range(NC)], np.float32)
y_ref = (A @ x).astype(np.float32)

# diagonal form: offsets -1,0,+1,+2; diagonal d covers rows [row0 .. row0+len) at x index row+off
dia_val = np.zeros(MX, np.float32); dia_off = np.zeros(ND, np.uint16)
dia_len = np.zeros(ND, np.uint16); dia_row0 = np.zeros(ND, np.uint16); dia_xoff = np.zeros(ND, np.uint16)
p = 0
for d, off in enumerate((-1, 0, 1, 2)):
    rows = [r for r in range(NR) if 0 <= r + off < NC and A[r, r + off] != 0]
    assert rows == list(range(rows[0], rows[-1] + 1)), "diagonal is not contiguous in rows"
    dia_off[d] = p; dia_len[d] = len(rows); dia_row0[d] = rows[0]; dia_xoff[d] = rows[0] + off
    for r in rows: dia_val[p] = A[r, r + off]; p += 1
assert p == nnz, f"diagonal form holds {p} of {nnz} nonzeros"
probe_seed = np.array([0.0, 0.0], np.float32)

pk16 = lambda v: np.frombuffer(np.asarray(v, np.uint16).tobytes(), np.uint32).copy()
pk32 = lambda v: np.frombuffer(np.asarray(v, np.float32).tobytes(), np.uint32).copy()
r = SdkRuntime(a.name, cmaddr=a.cmaddr); r.load(); r.run()
for nm, w in (("row_ptr", pk16(row_ptr)), ("col_idx", pk16(col_idx)), ("col_start", pk16(col_start)),
              ("run_len", pk16(run_len)), ("val", pk32(val)), ("x", pk32(x)),
              ("dia_val", pk32(dia_val)), ("dia_off", pk16(dia_off)), ("dia_len", pk16(dia_len)),
              ("dia_row0", pk16(dia_row0)), ("dia_xoff", pk16(dia_xoff)), ("probe_seed", pk32(probe_seed))):
    r.memcpy_h2d(r.get_id(nm), w, 0, 0, 1, 1, len(w), streaming=False, data_type=F32, order=RM, nonblock=False)
for fn in ("spmv_scalar", "spmv_ir", "spmv_blk", "spmv_dia", "probe_reduce", "probe_reduce_const", "spmv_blk_dsdred"):
    r.call(fn, [], nonblock=False)
out = {}
for nm, n in (("y_sc", NR), ("y_ir", NR), ("y_bk", NR), ("y_di", NR), ("y_bd", NR), ("probe_out", 2)):
    w = np.zeros(n, np.uint32); r.memcpy_d2h(w, r.get_id(nm), 0, 0, 1, 1, n, streaming=False, data_type=F32, order=RM, nonblock=False)
    out[nm] = np.frombuffer(w.tobytes(), np.float32).copy()
w = np.zeros(8, np.uint32); r.memcpy_d2h(w, r.get_id("mark"), 0, 0, 1, 1, 8, streaming=False, data_type=F32, order=RM, nonblock=False)
marks = [int(v) for v in np.frombuffer(w.tobytes(), np.uint16)[:14]]
r.stop()
res = {"nnz": int(nnz), "nrows": NR, "ncols": NC, "dense_elems": NR * NC, "marks": marks, "strategies": {}}
allok = True
for nm, label in (("y_sc", "scalar"), ("y_ir", "ir"), ("y_bk", "blk"), ("y_di", "dia"), ("y_bd", "blk_dsdred")):
    ok = bool(np.array_equal(out[nm], y_ref))
    if label != "blk_dsdred": allok &= ok          # the regression case is EXPECTED to be wrong
    else:
        lastterm = np.array([val[int(row_ptr[q]) + int(run_len[q]) - 1] * x[int(col_start[q]) + int(run_len[q]) - 1] for q in range(NR)], np.float32)
        res["regression_last_element_only"] = bool(np.allclose(out[nm], lastterm))
    res["strategies"][label] = {"ok": ok, "max_abs_err": float(np.max(np.abs(out[nm] - y_ref))), "y": out[nm].tolist()}
    print(f"  {label:<11} {'ok  ' if ok else 'FAIL'} max|err|={res['strategies'][label]['max_abs_err']:.3e}  y[:4]={out[nm][:4]}")
# the probe: does an f32 DSD reduction accumulate when its accumulator is not a constant?
got, want, last = float(out["probe_out"][0]), float(val.sum()), float(val[MX - 1])
gotc = float(out["probe_out"][1])
for key, g, seed in (("probe", got, "seeded from memory"), ("probe_const", gotc, "literal 0.0")):
    res[key] = {"got": g, "sum": want, "last_element": last, "accumulator_init": seed,
                "accumulated": bool(abs(g - want) < 1e-3), "last_only": bool(abs(g - last) < 1e-6)}
    verdict = "ACCUMULATES" if res[key]["accumulated"] else ("LAST ELEMENT ONLY" if res[key]["last_only"] else "neither")
    print(f"  {key:<11} accumulator {seed:<18} got {g}, true sum {want}, last element {last}  -> {verdict}")
res["ok"] = bool(allok)
print(f"nnz={nnz} markers={[hex(v) for v in marks]}  SpMV strategies {'ALL ok' if allok else 'SOME FAIL'}")
json.dump(res, open("result.json", "w"), indent=1)
