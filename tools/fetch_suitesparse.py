#!/usr/bin/env python3
"""Fetch small SuiteSparse Matrix Collection matrices for the S task suite and
report the statistics that fix the device capacity parameters.

    fetch_suitesparse.py --fetch                 # download every matrix in the candidate list
    fetch_suitesparse.py --stats [--pes 4 16]    # n, nnz, row-length stats, per-PE nnz after partition
    fetch_suitesparse.py --pin                   # write kernels/_sparse_data/MANIFEST.json with sha256
    fetch_suitesparse.py --install               # copy each class into kernels/<Task>/CSL/data/ (per MANIFEST installs)
    fetch_suitesparse.py --manual                # print URLs + destinations for an scp fallback

Sources, in order: https://sparse.tamu.edu/MM/<group>/<name>.tar.gz (301 -> sparse-files.engr.tamu.edu,
honours the proxy environment) and the herokuapp mirror.  Files land in kernels/_sparse_data/<name>.mtx.
The collection is CC-BY 4.0 (Davis & Hu, ACM TOMS 2011); README.md there records provenance.
"""
from __future__ import annotations

import argparse, hashlib, io, json, shutil, sys, tarfile, urllib.request
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
DATA = REPO / "kernels" / "_sparse_data"
sys.path.insert(0, str(REPO / "code_translation"))
import sparse_inputs as si  # noqa: E402

SOURCES = ("https://sparse.tamu.edu/MM/{group}/{name}.tar.gz",
           "https://suitesparse-collection-website.herokuapp.com/MM/{group}/{name}.tar.gz")

# Candidate classes (rows/nnz figures from memory; --stats is the authority).  Train matrix first.
CANDIDATES = {
    "hb_n144":        ["HB/bcspwr03", "HB/ash85", "HB/arc130", "HB/can_144", "HB/bcsstk01", "HB/nos4"],
    "hb_n256":        ["HB/dwt_234", "HB/can_229", "HB/gre_216a", "HB/can_256", "HB/fs_183_1", "HB/west0167", "HB/dwt_245"],
    "hb_n512":        ["HB/494_bus", "HB/bcspwr05", "HB/gre_512", "HB/west0479", "HB/dwt_361", "HB/nos6", "HB/bcspwr04"],
    "hb_n1024":       ["HB/sherman1", "HB/jagmesh1", "HB/gr_30_30", "HB/dwt_1005", "HB/bcsstk08", "HB/orsirr_2", "HB/662_bus"],
    "hb_power_n2048": ["HB/bcspwr07", "HB/bcspwr06", "HB/bcspwr08", "HB/bcspwr09", "HB/1138_bus", "HB/jagmesh2"],
    "hb_tiny":        ["HB/bcspwr01", "HB/bcspwr02", "HB/ibm32", "HB/pores_1"],
}


def sha256(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def fetch_one(mid, force=False):
    group, name = mid.split("/")
    dst = DATA / f"{name}.mtx"
    if dst.exists() and not force:
        return dst, "cached"
    last = None
    for src in SOURCES:
        url = src.format(group=group, name=name)
        try:
            with urllib.request.urlopen(url, timeout=60) as r:
                blob = r.read()
            with tarfile.open(fileobj=io.BytesIO(blob), mode="r:gz") as tf:
                member = next(m for m in tf.getmembers() if m.name.endswith(f"/{name}.mtx") or m.name == f"{name}.mtx")
                dst.write_bytes(tf.extractfile(member).read())
            return dst, url
        except Exception as e:  # try the next mirror
            last = f"{url}: {type(e).__name__}: {e}"
    raise RuntimeError(f"could not fetch {mid}: {last}")


def stats_row(mid, pes):
    name = mid.split("/")[1]
    c = si.read_mtx(DATA / f"{name}.mtx")
    f = si.features(c)
    row = {"id": mid, "n": c.n, "m": c.m, "nnz": c.nnz, "sym": f["symmetric_pattern"],
           "rl_mean": f["row_len_mean"], "rl_max": f["row_len_max"], "rl_cv": f["row_len_cv"],
           "bw": f["bandwidth"], "band95": f["band95"], "diag90": f["n_diagonals_for_90pct"],
           "contig": f["contiguous_run_rows_frac"], "keys": ",".join(k[7:] for k in f["keys"])}
    for P in pes:
        parts = si.partition_row_block(c, P)
        row[f"pe{P}_max_nnz"] = max(p.nnz for p in parts)
        row[f"pe{P}_imb"] = max(p.nnz for p in parts) / (c.nnz / P) if c.nnz else 0
    row["bytes_1pe"] = 4 * (c.n + 1) + 8 * c.nnz + 4 * (c.n + c.m)   # u32 row_ptr + (u32 col, f32 val) + x + y
    return row


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--fetch", action="store_true"); ap.add_argument("--force", action="store_true")
    ap.add_argument("--stats", action="store_true"); ap.add_argument("--pes", type=int, nargs="*", default=[4, 16])
    ap.add_argument("--pin", action="store_true"); ap.add_argument("--install", action="store_true")
    ap.add_argument("--manual", action="store_true"); ap.add_argument("--classes", nargs="*", default=None)
    a = ap.parse_args()
    DATA.mkdir(parents=True, exist_ok=True)
    classes = {k: v for k, v in CANDIDATES.items() if not a.classes or k in a.classes}
    ids = [m for v in classes.values() for m in v]
    if a.manual:
        for mid in ids:
            g, n = mid.split("/"); print(SOURCES[0].format(group=g, name=n), "->", DATA / f"{n}.mtx")
        return
    if a.fetch:
        for mid in ids:
            try:
                dst, how = fetch_one(mid, a.force); print(f"  {mid:<18} {dst.stat().st_size:>9} B  {how}")
            except Exception as e:
                print(f"  {mid:<18} FAILED: {e}")
    if a.stats:
        cols = ["id", "n", "m", "nnz", "sym", "rl_mean", "rl_max", "rl_cv", "bw", "band95", "diag90", "contig"] + \
               [f"pe{P}_max_nnz" for P in a.pes] + [f"pe{P}_imb" for P in a.pes] + ["bytes_1pe", "keys"]
        print(" ".join(f"{c:>10}" if c != "keys" else c for c in cols))
        for cls, mids in classes.items():
            print(f"-- {cls}")
            for mid in mids:
                if not (DATA / f"{mid.split('/')[1]}.mtx").exists():
                    print(f"  {mid:<18} (not fetched)"); continue
                r = stats_row(mid, a.pes)
                print(" ".join((f"{r[c]:>10.2f}" if isinstance(r[c], float) else f"{str(r[c]):>10}") if c != "keys" else r[c] for c in cols))
    if a.pin:
        manifest_path = DATA / "MANIFEST.json"
        # Refresh checksums without deleting task installs or unselected classes.
        man = json.loads(manifest_path.read_text()) if manifest_path.exists() else {
            "schema": 1,
            "license": "CC-BY 4.0, SuiteSparse Matrix Collection (Davis & Hu, ACM TOMS 38(1), 2011)",
            "classes": {},
        }
        man.setdefault("classes", {})
        for cls, mids in classes.items():
            man["classes"][cls] = []
            for mid in mids:
                p = DATA / f"{mid.split('/')[1]}.mtx"
                if not p.exists():
                    continue
                c = si.read_mtx(p)
                man["classes"][cls].append({"id": mid, "file": p.name, "sha256": sha256(p), "n": c.n, "m": c.m, "nnz": c.nnz})
        (DATA / "MANIFEST.json").write_text(json.dumps(man, indent=1) + "\n")
        print("wrote", DATA / "MANIFEST.json")
    if a.install:
        man = json.loads((DATA / "MANIFEST.json").read_text())
        for kernel, specs in (man.get("installs") or {}).items():
            dst = REPO / "kernels" / kernel / "CSL" / "data"; dst.mkdir(parents=True, exist_ok=True)
            for spec in ([specs] if isinstance(specs, dict) else specs):
                entries = [e for e in man["classes"][spec["class"]] if e["id"] in spec["matrices"]]
                entries.sort(key=lambda e: spec["matrices"].index(e["id"]))
                for e in entries:
                    shutil.copy(DATA / e["file"], dst / e["file"])
                name = spec.get("manifest", "manifest.json")
                (dst / name).write_text(json.dumps({"schema": 1, "class": spec["class"], "train_seed": spec.get("train_seed", 7),
                                                    "values": spec.get("values", "seeded_uniform"), "matrices": entries}, indent=1) + "\n")
                print(f"  {kernel}/{name}: {len(entries)} matrices ({spec['class']}) -> {dst}")


if __name__ == "__main__":
    main()
