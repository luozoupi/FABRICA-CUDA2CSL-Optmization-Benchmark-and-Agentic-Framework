import re, glob, os
hits = {}
for f in glob.glob("/cbcore/py_root/cerebras/**/*.py", recursive=True):
    try: t = open(f).read()
    except Exception: continue
    for m in re.findall(r"[A-Z_]*SIMFAB[A-Z_]*|CSL_[A-Z_]*TRACE[A-Z_]*|CS_[A-Z_]*TRACE[A-Z_]*|debug_mode|artifact|collect_int|instr_trace|WSE_?SIM", t):
        hits.setdefault(m, set()).add(os.path.basename(f))
for k in sorted(hits):
    if "TRACE" in k or "SIMFAB" in k or "debug" in k: print(k, "->", sorted(hits[k])[:5])
print("=== env vars referenced in sdkruntime")
for f in glob.glob("/cbcore/py_root/cerebras/sdk/runtime/*.py"):
    t = open(f).read()
    for m in sorted(set(re.findall(r"os\.environ(?:\.get)?\(?\[?['\"]([A-Z_]+)['\"]", t))): print(" ", os.path.basename(f), m)
