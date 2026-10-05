#!/usr/bin/env python3
"""Measure an expert variant of SpMV-RowBlock: stage the reference bundle, overlay the variant's files,
run one commands script on the training matrix (seed 7) and the three held-out matrices.
    python measure_variant.py <variant_dir> <commands_script> --out results.csv [--tag name]"""
import argparse, csv, os, re, shutil, sys, tempfile
XK = "/home/USER/xkernel"
sys.path.insert(0, f"{XK}/code_translation")
import benchmark_csl as bc
REF = f"{XK}/kernels/SpMV-RowBlock/CSL"
ap = argparse.ArgumentParser(); ap.add_argument("variant"); ap.add_argument("commands"); ap.add_argument("--out", required=True)
ap.add_argument("--tag", default=""); ap.add_argument("--seeds", default="7,101,202,303")
a = ap.parse_args()
work_root = os.environ.get("XKERNEL_VARIANT_WORK", f"{XK}/code_translation/results/phase2_stream")
new = not os.path.exists(a.out)
fh = open(a.out, "a", newline=""); w = csv.writer(fh)
if new: w.writerow(["variant", "commands", "seed", "matrix", "status", "cycles", "max_pe_window", "min_pe_window"])
for seed in a.seeds.split(","):
    work = tempfile.mkdtemp(prefix="var_", dir=work_root); b = os.path.join(work, "bundle"); shutil.copytree(REF, b)
    if a.variant != "-":
        for f in os.listdir(a.variant):
            if f.endswith((".csl", ".py", ".json", ".sh")) and not f.startswith("measure"):
                shutil.copy(os.path.join(a.variant, f), os.path.join(b, f))
    with open(os.path.join(b, ".xkernel_eval_env.json"), "w") as ef:      # the ssh relay drops the env
        ef.write('{"XKERNEL_EVAL_SEED": "%s"}' % seed)
    os.environ["XKERNEL_EVAL_SEED"] = seed
    res = bc.run_staged_bundle(b, a.commands, "/software/cerebras/cs_sdk-2.10", timeout=3600)
    out = "\n".join(str(e.get("stdout", "")) + str(e.get("stderr", "")) for e in res.get("transcript", []))
    es = re.search(r"eval_seed = (\d+)", out)
    assert es and es.group(1) == seed, f"seed {seed} did not arrive"
    mm = re.search(r"matrix = (\S+)", out); cy = re.search(r"cycles_send = (\d+)", out)
    pw = re.search(r"per-PE windows \(cycles\): \[([^\]]*)\]", out)
    wins = [int(v) for v in pw.group(1).split(",")] if pw else []
    row = [a.tag or os.path.basename(a.variant.rstrip("/")), a.commands, seed, mm.group(1) if mm else "", res.get("status"),
           cy.group(1) if cy else "", max(wins) if wins else "", min(wins) if wins else ""]
    w.writerow(row); fh.flush(); print(row, flush=True)
    if res.get("status") != "pass":
        print("\n".join([l for l in out.splitlines() if "INFO" not in l][-15:]), flush=True)
    shutil.rmtree(work, ignore_errors=True)
print("VARIANT_DONE", flush=True)
