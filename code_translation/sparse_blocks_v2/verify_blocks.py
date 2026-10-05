#!/usr/bin/env python3
"""(version 2) Compile and run the toy building-block program on SDK 2.10 (simulator) and record the result.

    python sparse_blocks/verify_blocks.py [--out results/sparse_blocks_verify.json]

Every block is checked against numpy for 1 and 10 products; the JSON records cycles per method.
The optimizer only receives a block whose toy method passed here (see sparse_blocks.py)."""
import argparse, json, os, shutil, sys, tempfile
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.dirname(HERE))
import benchmark_csl as bc

ap = argparse.ArgumentParser()
ap.add_argument("--sdk-root", default="/software/cerebras/cs_sdk-2.10")
ap.add_argument("--out", default=os.path.join(HERE, "verified.json"))
ap.add_argument("--commands", default="commands_wse3.sh")
a = ap.parse_args()
work = tempfile.mkdtemp(prefix="blocks_", dir=os.environ.get("XKERNEL_BLOCKS_WORK", os.path.dirname(HERE) + "/results"))
bundle = os.path.join(work, "bundle")
shutil.copytree(os.path.join(HERE, "toy"), bundle)
res = bc.run_staged_bundle(bundle, a.commands, a.sdk_root, timeout=1800)
out = "\n".join(str(e.get("stdout", "")) for e in res.get("transcript", []))
err = "\n".join(str(e.get("stderr", "")) for e in res.get("transcript", []))
rows = [json.loads(l) for l in out.splitlines() if l.startswith("{")]
rec = {"status": res.get("status"), "blocks_ok": "BLOCKS_OK" in out, "methods": rows,
       "sdk_root": a.sdk_root, "commands": a.commands, "stderr_tail": err.strip().splitlines()[-8:]}
json.dump(rec, open(a.out, "w"), indent=1)
print(json.dumps(rec, indent=1))
shutil.rmtree(work, ignore_errors=True)
