#!/usr/bin/env python3
"""Stage the formats toy and run one commands script; print the JSON lines and errors.
    python run_toy.py commands_banded.sh [out.json]"""
import json, os, shutil, sys, tempfile
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.dirname(os.path.dirname(HERE)))
import benchmark_csl as bc
cmd = sys.argv[1]
work = tempfile.mkdtemp(prefix="fmt_", dir=os.environ.get("XKERNEL_FMT_WORK", "/home/USER/xkernel/code_translation/results/phase1_blocks"))
b = os.path.join(work, "bundle"); shutil.copytree(HERE, b, ignore=shutil.ignore_patterns("*.json", "__pycache__"))
res = bc.run_staged_bundle(b, cmd, "/software/cerebras/cs_sdk-2.10", timeout=1800)
out = "\n".join(str(e.get("stdout", "")) for e in res.get("transcript", []))
rows = [json.loads(l) for l in out.splitlines() if l.startswith("{")]
print(res.get("status"))
for r in rows: print(json.dumps(r))
if res.get("status") != "pass":
    err = "\n".join(str(e.get("stderr", "")) for e in res.get("transcript", []))
    print("\n".join([l for l in err.splitlines() if "INFO" not in l][-20:]))
if len(sys.argv) > 2:
    json.dump({"commands": cmd, "status": res.get("status"), "rows": rows}, open(sys.argv[2], "w"), indent=1)
shutil.rmtree(work, ignore_errors=True)
