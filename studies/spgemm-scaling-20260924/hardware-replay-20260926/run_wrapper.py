#!/usr/bin/env python3
"""run.py wrapper for the appliance driver: runs the frozen host.py unchanged (it validates every
launch and writes observations.json), prints every session's median root interval, and reports
the UNIFORM unchanged-input broadcast session as `cycles_send` -- the session the companion
study's strong-scaling table quotes. The raw records stay in observations.json next to this file."""
import json, statistics, sys
from pathlib import Path
sys.argv = [sys.argv[0]]                      # host.py takes no arguments
import host
host.main()
obs = json.loads(Path("observations.json").read_text())
chosen = None
for r in obs["records"]:
    spans = [s["root_span_cycles"] for s in r["samples"] if not s["warmup"]]
    print(f"session {r['pattern']} {r['mode']} changed={r['changed']} root spans {spans} median {int(statistics.median(spans))}")
    if r["pattern"] == "uniform" and r["mode"] == "broadcast" and not r["changed"] and chosen is None:
        chosen = int(statistics.median(spans))
assert all(s["correct"] for r in obs["records"] for s in r["samples"])
print(f"cycles_send = {chosen} cycles")
print("SUCCESS")
