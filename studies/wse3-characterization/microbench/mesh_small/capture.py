#!/usr/bin/env python3
"""MeshGEMM at the smallest faithful size, traced: P = 4, X and W 8 x 8 (2 x 2 tiles), small integers, one checked repeat.

The kernel is WaferLLM's MeshGEMM unmodified (src/ copied from ~/waferllm/MeshGEMM/src, hashes recorded); only the host
program is ours: integer X and W (exact in f16), the same host-side tiling and W pre-skew (host_common.py), one repeat
(meshgemm_host(0, 1)) so the whole run is the run the host checks. P = 2 is not possible: the folded two-hop ring
(assignId / comm_layout.get_params) is defined for P >= 3 only.
Leaves: out/ (cslc), result.json (inputs, ind, C read back, exact flag), events.jsonl.gz, disasm_out_*.json, manifest.json.
Evidence: `simulator`, exact comparison.
"""
import hashlib, json, os, shutil, subprocess, sys, time
from pathlib import Path

HERE = Path(__file__).resolve().parent; STUDY = HERE.parents[1]
SRC = Path.home() / "waferllm/MeshGEMM"; SDK = Path("/software/cerebras/cs_sdk-2.10"); RELAY = "user-node-1"
P, Mt = 4, 2; M = P * Mt

RUN = r'''#!/usr/bin/env cs_python
# MeshGEMM P=4, 8x8 integer instance: same host contract as launch_sim.py, one checked repeat.
import json, numpy as np
from cerebras.sdk.sdk_utils import input_array_to_u32, memcpy_view
from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType, MemcpyOrder
import host_common as hc
P, Mt, Kt, Nt = 4, 2, 2, 2; M = K = N = P * Mt
inst = json.load(open("instance.json"))
X = np.array(inst["X"], dtype=np.float16); W = np.array(inst["W"], dtype=np.float16)
ind = np.zeros((P, P), dtype=int)                       # the host's W pre-skew, exactly as make_inputs builds it
for i in range(P):
    for j in range(P):
        if i == 0: ind[0, j] = j
        elif i == 1: _, ind[1, j] = hc.assignId(ind[0, j], P)
        elif (i - 1) % 2 == 0: _, ind[i, j] = hc.assignId(ind[i - 2, j], P)
        else: ind[i, j], _ = hc.assignId(ind[i - 2, j], P)
Woff = np.zeros((K, N), dtype=np.float16)
for i in range(P):
    for j in range(P):
        t = ind[i, j]; Woff[i * Kt:(i + 1) * Kt, j * Nt:(j + 1) * Nt] = W[t * Kt:(t + 1) * Kt, j * Nt:(j + 1) * Nt]
runner = SdkRuntime("out"); runner.load(); runner.run()
sym_X, sym_W, sym_res = runner.get_id("X"), runner.get_id("W"), runner.get_id("res")
io, order = MemcpyDataType.MEMCPY_16BIT, MemcpyOrder.ROW_MAJOR
runner.memcpy_h2d(sym_X, input_array_to_u32(hc.tile_X(X, P, Mt, Kt), 1, 1), 0, 0, P, P, Mt * Kt, streaming=False, data_type=io, order=order, nonblock=False)
runner.memcpy_h2d(sym_W, input_array_to_u32(hc.tile_W(Woff, P, Kt, Nt), 1, 1), 0, 0, P, P, Kt * Nt, streaming=False, data_type=io, order=order, nonblock=False)
runner.launch("init_task", nonblock=False)
runner.launch("meshgemm_host", np.int16(0), np.int16(1), nonblock=False)
res = np.zeros(M * N, dtype=np.uint32)
runner.memcpy_d2h(res, sym_res, 0, 0, P, P, Mt * Nt, streaming=False, data_type=io, order=order, nonblock=False)
runner.stop()
C = hc.untile_res(memcpy_view(res, np.dtype(np.float16)), P, Mt, Nt).astype(np.float64)
ref = X.astype(np.float64) @ W.astype(np.float64); ok = bool(np.array_equal(C, ref))
json.dump(dict(P=P, Mt=Mt, X=X.astype(int).tolist(), W=W.astype(int).tolist(), W_offset=Woff.astype(int).tolist(), ind=ind.tolist(),
               C_dev=C.astype(int).tolist(), C_ref=ref.astype(int).tolist(), exact=ok), open("result.json", "w"), indent=1)
print("C_dev", C.astype(int).tolist()); assert ok, "C != X W"; print("SUCCESS")
'''

def sha(p): return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def relay_busy():
    r = subprocess.run(["ssh", "-o", "BatchMode=yes", "-o", "ConnectTimeout=10", RELAY,
                        'ps -u USER -o args | grep -E "[c]slc|[c]s_python|/usr/bin/[s]ingularity exec" | grep -v grep | head -3'], capture_output=True, text=True, timeout=40)
    return [l for l in r.stdout.splitlines() if l.strip()]
def wait_idle(log, limit=3600):
    t0 = time.time()
    while relay_busy():
        log.write(f"{time.strftime('%H:%M:%S')} relay busy\n"); log.flush()
        if time.time() - t0 > limit: raise SystemExit("relay never idle")
        time.sleep(30)

def main():
    work = HERE / "run"
    if work.exists(): shutil.rmtree(work)
    shutil.copytree(SRC / "src", work / "src"); shutil.copy2(SRC / "host_common.py", work / "host_common.py")
    rng = __import__("numpy").random.default_rng(21)
    X = rng.integers(0, 4, size=(M, M)).tolist(); W = rng.integers(0, 4, size=(M, M)).tolist()
    (work / "instance.json").write_text(json.dumps(dict(X=X, W=W), indent=1)); (work / "run.py").write_text(RUN)
    env = dict(os.environ); env["PATH"] = f"{SDK}:{Path.home() / 'bin'}:{env['PATH']}"; env["TMPDIR"] = str(STUDY / ".nfstmp")
    log = (work / "capture.log").open("a"); cmds = []
    def run(argv, timeout=1800):
        cmds.append(argv); log.write(f"\n$ {' '.join(argv)}\n"); log.flush()
        r = subprocess.run(argv, cwd=work, env=env, stdout=log, stderr=subprocess.STDOUT, timeout=timeout); log.write(f"[exit {r.returncode}]\n"); log.flush()
        if r.returncode: raise SystemExit(f"{argv[0]} failed, see {work / 'capture.log'}")
    wait_idle(log)
    run(["cslc", "./src/layout.csl", "--arch=wse3", f"--fabric-dims={P + 7},{P + 2}", "--fabric-offsets=4,1", f"--params=P:{P},Mt:{Mt},Kt:{Mt},Nt:{Mt}",
         "-o", "out", "--memcpy", "--channels", "1"])
    wait_idle(log); shutil.rmtree(work / "simfab_traces", ignore_errors=True)
    run(["cs_python", "run.py"])
    for _ in range(60):
        if (work / "simfab_traces/stream0").exists(): break
        time.sleep(5)
    run([sys.executable, str(STUDY / "tools/decode_trace.py"), ".", "-o", "events.jsonl.gz"])
    for elf in sorted((work / "out/bin").glob("out_*.elf")): run([sys.executable, str(STUDY / "tools/csdisasm.py"), str(elf.relative_to(work)), "--json", f"disasm_{elf.stem}.json"])
    srcs = {str(p.relative_to(SRC)): sha(p) for p in (SRC / "src").rglob("*.csl")}
    (work / "manifest.json").write_text(json.dumps(dict(schema="mesh-small/1", P=P, Mt=Mt, sdk=str(SDK), sif=[str(s) for s in SDK.glob("*.sif")], commands=cmds,
        kernel_sources=srcs, host_common=sha(SRC / "host_common.py"), copied_identical=all(sha(work / k) == v for k, v in srcs.items()),
        result_exact=json.loads((work / "result.json").read_text())["exact"]), indent=1))
    print("COMPLETE", json.loads((work / "result.json").read_text())["exact"], flush=True)

if __name__ == "__main__":
    main()
