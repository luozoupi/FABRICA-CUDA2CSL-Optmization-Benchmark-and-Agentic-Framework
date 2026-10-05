#!/usr/bin/env python3
"""Compile and run the version-3 toy on SDK 2.10 for its three matrices and write verified.json.
    python sparse_blocks_v3/verify_blocks.py [banded,random,block]
Each configuration records the status, the matrix line and one row per (method, products)."""
import json, os, shutil, sys, tempfile
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.dirname(HERE))
import benchmark_csl as bc

OUT = os.path.join(HERE, "verified.json")
configs = sys.argv[1].split(",") if len(sys.argv) > 1 else ["banded", "random", "block"]
doc = json.load(open(OUT)) if os.path.exists(OUT) else {}
doc["_note"] = ("sparse_blocks_v3/verify_blocks.py on SDK 2.10 (simulator); rows: cycles for 1 and 10 products "
                "of each method, checked against numpy")
doc.setdefault("configs", {})
for name in configs:
    work = tempfile.mkdtemp(prefix="v3_", dir=os.path.join(os.path.dirname(HERE), "results"))
    b = os.path.join(work, "bundle")
    shutil.copytree(os.path.join(HERE, "toy"), b)
    res = bc.run_staged_bundle(b, f"commands_{name}.sh", "/software/cerebras/cs_sdk-2.10", timeout=3600)
    out = "\n".join(str(e.get("stdout", "")) for e in res.get("transcript", []))
    lines = [json.loads(l) for l in out.splitlines() if l.startswith("{")]
    matrix = next((l for l in lines if "kind" in l), {})
    rows = [l for l in lines if "method" in l]
    doc["configs"][name] = {"status": res.get("status"), "blocks_ok": "BLOCKS_OK" in out, "matrix": matrix,
                            "rows": rows}
    print(name, res.get("status"), json.dumps(matrix), flush=True)
    for r in rows:
        print("  ", json.dumps(r), flush=True)
    if res.get("status") != "pass":
        err = "\n".join(str(e.get("stderr", "")) + str(e.get("stdout", "")) for e in res.get("transcript", []))
        print("\n".join([l for l in err.splitlines() if "INFO" not in l][-20:]), flush=True)
    json.dump(doc, open(OUT, "w"), indent=1)
    shutil.rmtree(work, ignore_errors=True)
print("VERIFY_DONE", flush=True)
