#!/usr/bin/env python3
"""Traced simulator runs of the three sparse reference kernels on small, hand-checkable instances.

The kernels are the unmodified references (layout.csl + pe.csl copied from kernels/<Task>/CSL and
hash-recorded); only the host program and the matrices are ours. Every value is a small integer,
so f32 arithmetic is exact and every product, sum, gathered x and output can be checked by hand
and bit for bit against the trace.

  spmv    SpMV-RowBlock      1 x 4 strip, 16 x 16 A (2-3 nnz per row), x multicast on colour 8
  spmm    SpMM-CSR-Dense     2 x 2 mesh, 8 x 8 A times 8 x 4 dense B, no fabric traffic
  spgemm  SpGEMM-Masked-Dot  1 PE, 8 x 8 A by column, C<M> = A'A at the mask positions

Per kernel this leaves in microbench/sparse_walk/<kernel>/: the sources, instance.json (the
matrices), out/ (cslc), result.json (host readback + reference), events.jsonl.gz (decoded trace),
disasm_*.json, capture.log and manifest.json (commands, hashes, SIF).

Jobs are serialised and each waits until no cslc / cs_python / singularity of ours runs on the
relay node (user-node-1), because concurrent container launches over the relay fail.
Evidence: `simulator`, exact comparisons.
"""
from __future__ import annotations
import argparse, hashlib, json, os, shutil, subprocess, sys, time
from pathlib import Path
import numpy as np

HERE = Path(__file__).resolve().parent
STUDY = HERE.parents[1]
KERNELS = STUDY.parents[1] / "kernels"
SDK = Path("/software/cerebras/cs_sdk-2.10")
RELAY_HOST = "user-node-1"

CASES = {
    "spmv":   dict(task="SpMV-RowBlock",     fabric="11,3", params="P:4,nrows_pe:4,ncols:16,max_nnz_pe:12,iters:1,structure_id:0"),
    "spmm":   dict(task="SpMM-CSR-Dense",    fabric="9,4",  params="P:2,Mt:4,K:8,Nt:2,max_nnz_pe:12,iters:1,structure_id:0"),
    "spgemm": dict(task="SpGEMM-Masked-Dot", fabric="8,3",  params="n:8,max_nnz:24,iters:1,structure_id:0"),
    # the hand-written expert variant (Gustavson dense accumulator instead of the merge), same layout and instance
    "spgemm_acc": dict(task="SpGEMM-Masked-Dot", fabric="8,3",  params="n:8,max_nnz:24,iters:1,structure_id:0",
                       pe_src=KERNELS / "_sparse_expert/SpGEMM-Masked-Dot/pe_dense_accumulator.csl"),
}

def sparse_int_matrix(n, m, per_row, vmax, seed):
    """n x m CSR with `per_row[r]` distinct columns per row and integer values in 1..vmax."""
    rng = np.random.default_rng(seed)
    rows, cols, vals = [], [], []
    for r in range(n):
        cs = sorted(rng.choice(m, size=per_row[r], replace=False).tolist())
        rows += [r] * len(cs); cols += cs; vals += rng.integers(1, vmax + 1, size=len(cs)).tolist()
    return rows, cols, vals

def instance(case):
    rng = np.random.default_rng({"spmv": 11, "spmm": 12, "spgemm": 13, "spgemm_acc": 13}[case])
    if case == "spmv":
        n = m = 16; per = rng.integers(2, 4, size=n).tolist()               # 2 or 3 nonzeros per row
        rows, cols, vals = sparse_int_matrix(n, m, per, 5, 101)
        x = rng.integers(1, 5, size=m).tolist()
        return dict(kind="spmv", n=n, m=m, rows=rows, cols=cols, vals=vals, x=x)
    if case == "spmm":
        n = m = 8; per = rng.integers(2, 4, size=n).tolist()
        rows, cols, vals = sparse_int_matrix(n, m, per, 5, 102)
        B = rng.integers(0, 4, size=(8, 4)).tolist()                          # 8 x 4 dense, some zeros
        return dict(kind="spmm", n=n, m=m, rows=rows, cols=cols, vals=vals, B=B)
    n = m = 8; per = rng.integers(2, 4, size=n).tolist()
    rows, cols, vals = sparse_int_matrix(n, m, per, 3, 103)
    return dict(kind="spgemm", n=n, m=m, rows=rows, cols=cols, vals=vals)

RUNNERS = {
"spmv": r'''#!/usr/bin/env cs_python
# SpMV-RowBlock on a small integer instance (microbench/sparse_walk). Same host contract as the
# reference run.py: per-PE padded CSR slices, x written to PE 0 only, y read back per PE.
import json, os, sys, argparse, numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sparse_inputs as si
from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType, MemcpyOrder
ap = argparse.ArgumentParser(); ap.add_argument("--name"); ap.add_argument("--cmaddr"); a = ap.parse_args()
params = json.load(open(f"{a.name}/out.json"))["params"]
P, nrows_pe, ncols, max_nnz_pe, iters = (int(params[k]) for k in ("P", "nrows_pe", "ncols", "max_nnz_pe", "iters"))
inst = json.load(open("instance.json"))
csr = si.from_coo(inst["n"], inst["m"], inst["rows"], inst["cols"], inst["vals"])
parts = si.partition_row_block(csr, P, nrows_pe)
pads = [si.csr_pad(p, nrows_pe, max_nnz_pe) for p in parts]
row_ptr = np.stack([q["row_ptr"] for q in pads]); col_idx = np.stack([q["col"] for q in pads]); val = np.stack([q["val"] for q in pads])
x = np.zeros(ncols, dtype=np.float32); x[: csr.m] = np.array(inst["x"], dtype=np.float32)
y_ref = csr.matvec(x[: csr.m].astype(np.float64)).astype(np.float32)
runner = SdkRuntime(a.name, cmaddr=a.cmaddr)
sym = {k: runner.get_id(k) for k in ("row_ptr", "col_idx", "val", "x", "y", "time_buf_u16")}
runner.load(); runner.run()
U32, U16, RM = MemcpyDataType.MEMCPY_32BIT, MemcpyDataType.MEMCPY_16BIT, MemcpyOrder.ROW_MAJOR
def h2d_strip(name, arr2d, count):
    runner.memcpy_h2d(sym[name], np.ascontiguousarray(arr2d, dtype=np.uint32).ravel(), 0, 0, P, 1, count,
                      streaming=False, data_type=U32, order=RM, nonblock=False)
h2d_strip("row_ptr", row_ptr, nrows_pe + 1); h2d_strip("col_idx", col_idx, max_nnz_pe); h2d_strip("val", val.view(np.uint32), max_nnz_pe)
runner.memcpy_h2d(sym["x"], x.view(np.uint32), 0, 0, 1, 1, ncols, streaming=False, data_type=U32, order=RM, nonblock=False)
runner.launch("f_enable_timer", nonblock=False)
runner.launch("main", nonblock=False)
runner.launch("f_memcpy_timestamps", nonblock=False)
y_dev = np.zeros((1, P, nrows_pe), dtype=np.uint32)
runner.memcpy_d2h(y_dev, sym["y"], 0, 0, P, 1, nrows_pe, streaming=False, data_type=U32, order=RM, nonblock=False)
t = np.zeros((1, P, 6), dtype=np.uint32)
runner.memcpy_d2h(t, sym["time_buf_u16"], 0, 0, P, 1, 6, streaming=False, data_type=U16, order=RM, nonblock=False)
runner.stop()
t = t.reshape(P, 6).astype(np.uint16)
tc = lambda w: int(w[0]) | (int(w[1]) << 16) | (int(w[2]) << 32)
win = [[tc(t[c, 0:3]), tc(t[c, 3:6])] for c in range(P)]
y_out = y_dev.reshape(P, nrows_pe).view(np.float32).reshape(-1)[: csr.n]
ok = bool(np.array_equal(y_out, y_ref))
json.dump(dict(kind="spmv", P=P, nrows_pe=nrows_pe, ncols=ncols, max_nnz_pe=max_nnz_pe,
               row_ptr=row_ptr.tolist(), col_idx=col_idx.tolist(), val=val.tolist(), x=x.tolist(),
               y_dev=y_dev.reshape(P, nrows_pe).view(np.float32).tolist(), y_ref=y_ref.tolist(), exact=ok,
               nnz_per_pe=[p.nnz for p in parts], windows=win, cycles_send=int(max(e for _, e in win) - min(s for s, _ in win))),
          open("result.json", "w"), indent=1)
print("y_dev", y_out.tolist()); print("y_ref", y_ref.tolist()); print("cycles_send", max(e for _, e in win) - min(s for s, _ in win))
assert ok, "y != A x"; print("SUCCESS")
''',
"spmm": r'''#!/usr/bin/env cs_python
# SpMM-CSR-Dense on a small integer instance (microbench/sparse_walk). Same host contract as the
# reference run.py: row tiles replicated along mesh rows, B slices replicated down mesh columns.
import json, os, sys, argparse, numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sparse_inputs as si
from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType, MemcpyOrder
ap = argparse.ArgumentParser(); ap.add_argument("--name"); ap.add_argument("--cmaddr"); a = ap.parse_args()
params = json.load(open(f"{a.name}/out.json"))["params"]
P, Mt, K, Nt, max_nnz_pe, iters = (int(params[k]) for k in ("P", "Mt", "K", "Nt", "max_nnz_pe", "iters")); N = P * Nt
inst = json.load(open("instance.json"))
csr = si.from_coo(inst["n"], inst["m"], inst["rows"], inst["cols"], inst["vals"])
tiles = si.partition_row_block(csr, P, Mt); pads = [si.csr_pad(t_, Mt, max_nnz_pe) for t_ in tiles]
B = np.zeros((K, N), dtype=np.float32); B[: csr.m, :] = np.array(inst["B"], dtype=np.float32)
C_ref = csr.matmat(B[: csr.m, :]).astype(np.float32)
row_ptr = np.zeros((P, P, Mt + 1), dtype=np.uint32); col_idx = np.zeros((P, P, max_nnz_pe), dtype=np.uint32)
val = np.zeros((P, P, max_nnz_pe), dtype=np.float32); B_tiles = np.zeros((P, P, K * Nt), dtype=np.float32)
for py in range(P):
    for px in range(P):
        row_ptr[py, px] = pads[py]["row_ptr"]; col_idx[py, px] = pads[py]["col"]; val[py, px] = pads[py]["val"]
        B_tiles[py, px] = np.ascontiguousarray(B[:, px * Nt:(px + 1) * Nt]).reshape(-1)
runner = SdkRuntime(a.name, cmaddr=a.cmaddr)
sym = {k: runner.get_id(k) for k in ("row_ptr", "col_idx", "val", "B_tile", "C_tile", "time_buf_u16")}
runner.load(); runner.run()
U32, U16, RM = MemcpyDataType.MEMCPY_32BIT, MemcpyDataType.MEMCPY_16BIT, MemcpyOrder.ROW_MAJOR
def h2d_mesh(name, arr3d, count):
    runner.memcpy_h2d(sym[name], np.ascontiguousarray(arr3d, dtype=np.uint32).ravel(), 0, 0, P, P, count,
                      streaming=False, data_type=U32, order=RM, nonblock=False)
h2d_mesh("row_ptr", row_ptr, Mt + 1); h2d_mesh("col_idx", col_idx, max_nnz_pe)
h2d_mesh("val", val.view(np.uint32), max_nnz_pe); h2d_mesh("B_tile", B_tiles.view(np.uint32), K * Nt)
runner.launch("f_enable_timer", nonblock=False); runner.launch("main", nonblock=False); runner.launch("f_memcpy_timestamps", nonblock=False)
C_dev = np.zeros((P, P, Mt * Nt), dtype=np.uint32)
runner.memcpy_d2h(C_dev, sym["C_tile"], 0, 0, P, P, Mt * Nt, streaming=False, data_type=U32, order=RM, nonblock=False)
t = np.zeros((P, P, 6), dtype=np.uint32)
runner.memcpy_d2h(t, sym["time_buf_u16"], 0, 0, P, P, 6, streaming=False, data_type=U16, order=RM, nonblock=False)
runner.stop()
t = t.reshape(P, P, 6).astype(np.uint16)
tc = lambda w: int(w[0]) | (int(w[1]) << 16) | (int(w[2]) << 32)
win = {f"{px},{py}": [tc(t[py, px, 0:3]), tc(t[py, px, 3:6])] for py in range(P) for px in range(P)}
C_out = np.zeros((P * Mt, N), dtype=np.float32)
for py in range(P):
    for px in range(P):
        C_out[py * Mt:(py + 1) * Mt, px * Nt:(px + 1) * Nt] = C_dev[py, px].view(np.float32).reshape(Mt, Nt)
ok = bool(np.array_equal(C_out[: csr.n], C_ref))
json.dump(dict(kind="spmm", P=P, Mt=Mt, K=K, Nt=Nt, max_nnz_pe=max_nnz_pe, row_ptr=row_ptr.tolist(), col_idx=col_idx.tolist(),
               val=val.tolist(), B=B.tolist(), B_tiles=B_tiles.tolist(), C_dev=C_out.tolist(), C_ref=C_ref.tolist(), exact=ok,
               nnz_per_tile=[t_.nnz for t_ in tiles], windows=win,
               cycles_send=int(max(e for _, e in win.values()) - min(s for s, _ in win.values()))), open("result.json", "w"), indent=1)
print("C_dev", C_out[: csr.n].tolist()); print("exact", ok); assert ok, "C != A B"; print("SUCCESS")
''',
"spgemm": r'''#!/usr/bin/env cs_python
# SpGEMM-Masked-Dot on a small integer instance (microbench/sparse_walk). Same host contract as the
# reference run.py: A by column (CSC, padded), C<M> = A'A at the stored positions, zombies counted.
import json, os, sys, struct, argparse, numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sparse_inputs as si
from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType, MemcpyOrder
ap = argparse.ArgumentParser(); ap.add_argument("--name"); ap.add_argument("--cmaddr"); a = ap.parse_args()
params = json.load(open(f"{a.name}/out.json"))["params"]
n, max_nnz, iters = (int(params[k]) for k in ("n", "max_nnz", "iters"))
inst = json.load(open("instance.json"))
csr = si.from_coo(inst["n"], inst["m"], inst["rows"], inst["cols"], inst["vals"]); nnz = csr.nnz
csc = si.csc_pad(csr, n, max_nnz); col_ptr, row_idx, val = csc["col_ptr"], csc["row"], csc["val"]
cols = np.repeat(np.arange(csr.n), np.diff(col_ptr[: csr.n + 1].astype(np.int64))); rows = row_idx[:nnz].astype(np.int64)
c_ref, exists = csr.masked_gram(rows, cols); c_ref = c_ref.astype(np.float32); c_ref[~exists] = 0.0
c_row_ref = np.where(exists, rows, (~rows) & 0xFFFFFFFF).astype(np.uint32); nz_ref = int((~exists).sum())
runner = SdkRuntime(a.name, cmaddr=a.cmaddr)
names = ["col_ptr", "row_idx", "val", "c_val", "c_row", "nzombies"]; sym = {k: runner.get_id(k) for k in names}; sym_t = runner.get_id("maxmin_time")
runner.load(); runner.run()
U32, RM = MemcpyDataType.MEMCPY_32BIT, MemcpyOrder.ROW_MAJOR
def h2d(name, arr, count):
    runner.memcpy_h2d(sym[name], np.ascontiguousarray(arr, dtype=np.uint32), 0, 0, 1, 1, count, streaming=False, data_type=U32, order=RM, nonblock=False)
def d2h(name, count):
    out = np.zeros((count,), dtype=np.uint32)
    runner.memcpy_d2h(out, sym[name], 0, 0, 1, 1, count, streaming=False, data_type=U32, order=RM, nonblock=False); return out
h2d("col_ptr", col_ptr, n + 1); h2d("row_idx", row_idx, max_nnz); h2d("val", val.view(np.uint32), max_nnz)
runner.call("compute", [], nonblock=False)
tdata = np.zeros((3,), dtype=np.uint32)
runner.memcpy_d2h(tdata, sym_t, 0, 0, 1, 1, 3, streaming=False, data_type=U32, order=RM, nonblock=False)
dev = {"c_val": d2h("c_val", max_nnz), "c_row": d2h("c_row", max_nnz), "nzombies": d2h("nzombies", 1)}
runner.stop()
w = [int(v) for v in tdata]; tsc = [w[0] & 0xFFFF, w[0] >> 16, w[1] & 0xFFFF, w[1] >> 16, w[2] & 0xFFFF, w[2] >> 16]
mk = lambda ws: ws[0] | (ws[1] << 16) | (ws[2] << 32); cycles = mk(tsc[3:]) - mk(tsc[0:3])
c_out = dev["c_val"].view(np.float32)[:nnz]; c_row_out = dev["c_row"][:nnz]; nz_out = int(dev["nzombies"][0])
ok = bool(np.array_equal(c_out, c_ref) and np.array_equal(c_row_out, c_row_ref) and nz_out == nz_ref)
json.dump(dict(kind="spgemm", n=n, max_nnz=max_nnz, nnz=nnz, col_ptr=col_ptr.tolist(), row_idx=row_idx.tolist(), val=val.tolist(),
               mask_rows=rows.tolist(), mask_cols=cols.tolist(), c_dev=c_out.tolist(), c_row_dev=[int(v) for v in c_row_out], nzombies_dev=nz_out,
               c_ref=c_ref.tolist(), c_row_ref=[int(v) for v in c_row_ref], nzombies_ref=nz_ref, exact=ok, cycles_send=int(cycles)),
          open("result.json", "w"), indent=1)
print("c_dev", c_out.tolist()); print("zombies", nz_out, nz_ref); print("cycles_send", cycles); assert ok, "C<M> mismatch"; print("SUCCESS")
''',
}

def sha(p): return hashlib.sha256(Path(p).read_bytes()).hexdigest()

def relay_busy():
    """Our own container jobs on the relay node (bracket trick: never match this ssh's own command)."""
    r = subprocess.run(["ssh", "-o", "BatchMode=yes", "-o", "ConnectTimeout=10", RELAY_HOST,
                        'ps -u USER -o args | grep -E "[c]slc|[c]s_python|/usr/bin/[s]ingularity exec" | grep -v "grep" | head -3'],
                       capture_output=True, text=True, timeout=40)
    return [l for l in r.stdout.splitlines() if l.strip()]

def wait_idle(log, limit=3600):
    t0 = time.time()
    while True:
        busy = relay_busy()
        if not busy: return
        log.write(f"{time.strftime('%H:%M:%S')} relay busy ({len(busy)}): {busy[0][:100]}\n"); log.flush()
        if time.time() - t0 > limit: raise SystemExit("relay never became idle")
        time.sleep(30)

def run_case(case, root):
    c = CASES[case]; src = KERNELS / c["task"] / "CSL"; work = root / case
    if work.exists(): shutil.rmtree(work)
    work.mkdir(parents=True)
    for f in ("layout.csl", "pe.csl", "sparse_inputs.py"): shutil.copy2(src / f, work / f)
    if c.get("pe_src"): shutil.copy2(c["pe_src"], work / "pe.csl")
    (work / "run.py").write_text(RUNNERS["spgemm" if case == "spgemm_acc" else case]); (work / "instance.json").write_text(json.dumps(instance(case), indent=1))
    env = dict(os.environ); env["PATH"] = f"{SDK}:{Path.home() / 'bin'}:{env['PATH']}"; env["TMPDIR"] = str(STUDY / ".nfstmp")
    log = (work / "capture.log").open("a"); commands = []
    def run(argv, timeout=1800):
        commands.append(argv); log.write(f"\n$ {' '.join(argv)}\n"); log.flush()
        r = subprocess.run(argv, cwd=work, env=env, stdout=log, stderr=subprocess.STDOUT, timeout=timeout)
        log.write(f"[exit {r.returncode}]\n"); log.flush()
        if r.returncode: raise SystemExit(f"{case}: {' '.join(argv[:2])} failed (exit {r.returncode}); see {work / 'capture.log'}")
    wait_idle(log)
    run(["cslc", "./layout.csl", "--arch=wse3", f"--fabric-dims={c['fabric']}", "--fabric-offsets=4,1", f"--params={c['params']}",
         "-o", "out", "--memcpy", "--channels=1", "--width-west-buf=0", "--width-east-buf=0"])
    wait_idle(log)
    shutil.rmtree(work / "simfab_traces", ignore_errors=True)
    run(["cs_python", "run.py", "--name", "out"])
    for _ in range(60):                                   # NFS lag: stream0 can appear well after cs_python returns
        if (work / "simfab_traces" / "stream0").exists(): break
        time.sleep(5)
    run([sys.executable, str(STUDY / "tools/decode_trace.py"), ".", "-o", "events.jsonl.gz"])
    for elf in sorted((work / "out/bin").glob("out_*.elf")):
        run([sys.executable, str(STUDY / "tools/csdisasm.py"), str(elf.relative_to(work)), "--json", f"disasm_{elf.stem}.json"])
    manifest = dict(schema="sparse-walk/1", case=case, task=c["task"], fabric=c["fabric"], params=c["params"], sdk=str(SDK),
                    sif=[str(s) for s in SDK.glob("*.sif")], commands=commands,
                    kernel_sources={"layout.csl": sha(src / "layout.csl"), "pe.csl": sha(c.get("pe_src") or src / "pe.csl")},
                    pe_source=str(c.get("pe_src") or src / "pe.csl"),
                    copied_sources_identical=sha(src / "layout.csl") == sha(work / "layout.csl") and sha(c.get("pe_src") or src / "pe.csl") == sha(work / "pe.csl"),
                    result_exact=json.loads((work / "result.json").read_text())["exact"])
    (work / "manifest.json").write_text(json.dumps(manifest, indent=1))
    print(f"COMPLETE {case} exact={manifest['result_exact']}", flush=True)

def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--cases", nargs="+", choices=list(CASES), default=list(CASES))
    ap.add_argument("--execute", action="store_true")
    a = ap.parse_args()
    if not a.execute:
        for case in a.cases: print(case, json.dumps(instance(case))[:300])
        return
    for case in a.cases: run_case(case, HERE)
    print("ALL DONE", flush=True)

if __name__ == "__main__":
    main()
