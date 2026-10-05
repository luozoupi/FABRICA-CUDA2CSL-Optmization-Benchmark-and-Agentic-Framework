#!/usr/bin/env python3
"""Measure the stream variant: stage the reference bundle, overlay the variant, run every
(size, rcm) configuration on the training matrix (seed 7) and the three held-out matrices.
    python measure_stream.py --sizes 64,256 --out stream_results.csv"""
import argparse, csv, os, re, shutil, sys, tempfile
XK = "/home/USER/xkernel"
sys.path.insert(0, f"{XK}/code_translation")
import benchmark_csl as bc
HERE = os.path.dirname(os.path.abspath(__file__))
REF = f"{XK}/kernels/SpMV-RowBlock/CSL"
ap = argparse.ArgumentParser(); ap.add_argument("--sizes", default="64,256"); ap.add_argument("--rcm", default="0,1")
ap.add_argument("--seeds", default="7,101,202,303"); ap.add_argument("--out", default=os.path.join(HERE, "stream_results.csv"))
a = ap.parse_args()
work_root = os.environ.get("XKERNEL_STREAM_WORK", f"{XK}/code_translation/results/phase2_stream")
os.makedirs(work_root, exist_ok=True)
new = not os.path.exists(a.out)
fh = open(a.out, "a", newline=""); w = csv.writer(fh)
if new: w.writerow(["pes", "rcm", "seed", "matrix", "status", "cycles", "max_pe_window", "min_pe_window"])
for size in a.sizes.split(","):
    for rcm in a.rcm.split(","):
        for seed in a.seeds.split(","):
            work = tempfile.mkdtemp(prefix=f"stream_p{size}_r{rcm}_s{seed}_", dir=work_root)
            b = os.path.join(work, "bundle"); shutil.copytree(REF, b)
            for f in ("layout.csl", "pe.csl", "run.py", "rcm_perm.json", f"commands_wse3_stream_p{size}_rcm{rcm}.sh"):
                shutil.copy(os.path.join(HERE, f), os.path.join(b, f))
            os.environ["XKERNEL_EVAL_SEED"] = seed
            with open(os.path.join(b, ".xkernel_eval_env.json"), "w") as ef:   # the ssh relay drops the env
                ef.write('{"XKERNEL_EVAL_SEED": "%s"}' % seed)
            res = bc.run_staged_bundle(b, f"commands_wse3_stream_p{size}_rcm{rcm}.sh", "/software/cerebras/cs_sdk-2.10", timeout=3600)
            out = "\n".join(str(e.get("stdout", "")) + str(e.get("stderr", "")) for e in res.get("transcript", []))
            mm = re.search(r"matrix = (\S+)", out); es = re.search(r"eval_seed = (\d+)", out); cy = re.search(r"cycles_send = (\d+)", out)
            pw = re.search(r"per-PE windows \(cycles\): \[([^\]]*)\]", out)
            wins = [int(v) for v in pw.group(1).split(",")] if pw else []
            assert es and es.group(1) == seed, f"seed {seed} did not arrive (echo {es.group(1) if es else None})"
            row = [size, rcm, seed, mm.group(1) if mm else "", res.get("status"), cy.group(1) if cy else "",
                   max(wins) if wins else "", min(wins) if wins else ""]
            w.writerow(row); fh.flush(); print(row, flush=True)
            if res.get("status") != "pass":
                print("\n".join(out.strip().splitlines()[-15:]), flush=True)
            shutil.rmtree(work, ignore_errors=True)
print("STREAM_DONE", flush=True)
