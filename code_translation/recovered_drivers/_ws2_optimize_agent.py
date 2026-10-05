#!/usr/bin/env python3
"""Closer: W2-optimize the agent's correct-but-slow GEMV-large decomposition.

The agent's from-CUDA decomposition runs at 58,610 cycles vs the expert's 10,309
(5.7x slower) because its inner product is a SCALAR double loop. This runs the
cycle-reduction optimizer on the agent's OWN pe.csl (keeping its distribution +
layout fixed) to measure how much of the gap the translate->optimize pipeline
recovers at scale — the paper's large-size key number.

Optimizer loop: show current pe.csl + cycles + the optimization angles; ask for a
faster rewrite (same contract); benchmark; accept iff strictly fewer cycles +
still SUCCESS. Up to N attempts. This mirrors cuda2csl.optimize() but on the
agent's non-registry bundle.
"""
import os, re, sys, subprocess, shutil
from pathlib import Path

sys.path.insert(0, "/home/USER/xkernel/code_translation")
from workflow_common import resolve_provider, llm_complete  # type: ignore

REPO = Path("/home/USER/xkernel")
ART = Path("/tmp/ws2b_repair_artifacts")       # agent's winning bundle
GEMV = REPO / "kernels" / "GEMV" / "CSL"
WORK = Path("/tmp/ws2opt/K")
REF = 10309
MAX = int(os.getenv("WS2OPT_MAX", "6"))

ANGLES = """Optimization angles (pick what applies; the inner product is the hot spot):
- fmac_bulk: replace the scalar `while j { s += A[i*Nt+j]*xv[j] }` inner loop with
  a strided mem1d_dsd over A's row + @fmacs accumulating into a result DSD —
  streams Nt elements per issue instead of per-element scalar ops.
- dsd_offset_chaining: build the row DSD once, @increment_dsd_offset by i*Nt.
- comptime_hoist: hoist comptime-derived bounds out of the loops.
Keep the EXACT contract: same @import_module imports, same collective calls
(c2d_x/c2d_y broadcast/reduce_fadds with the same args), same entrypoints,
same exported symbols. Only the local compute may change."""


def run(pe_text):
    if WORK.exists():
        shutil.rmtree(WORK.parent)
    WORK.mkdir(parents=True)
    shutil.copytree(GEMV, WORK / "CSL")
    shutil.copytree(REPO / "kernels" / "benchmark-libs", WORK / "benchmark-libs")
    (WORK / "CSL" / "distribution.py").write_text((ART / "distribution.py").read_text())
    (WORK / "CSL" / "layout.csl").write_text((ART / "layout.csl").read_text())
    (WORK / "CSL" / "pe.csl").write_text(pe_text)
    cmds = (WORK / "CSL" / "commands_wse3_large.sh").read_text()
    (WORK / "CSL" / "r.sh").write_text(cmds)
    env = dict(os.environ, PATH=f"/home/USER/cs_sdk-1.4.0:{os.environ['PATH']}",
               CSL_IMPORT_PATH=str(WORK))
    try:
        r = subprocess.run(["bash", "r.sh"], cwd=WORK / "CSL", env=env,
                           capture_output=True, text=True, timeout=900)
        out = r.stdout + r.stderr
    except subprocess.TimeoutExpired:
        out = "TIMEOUT"
    cyc = re.search(r"cycles_send = (\d+)", out)
    return ("SUCCESS" in out and cyc is not None), (int(cyc.group(1)) if cyc else None), out


def extract(reply):
    m = re.search(r"```(?:csl)?\s*\n(.*?)```", reply, re.DOTALL)
    return m.group(1) if m else None


def main():
    h = resolve_provider(provider="auto")
    best_pe = (ART / "pe.csl").read_text()
    ok, best_cyc, _ = run(best_pe)
    print(f"[w2opt] baseline (agent decomposition): SUCCESS={ok} cycles={best_cyc} (ref={REF})")
    if not ok:
        print("[w2opt] baseline doesn't reproduce; abort"); return 1
    accepts = 0
    for attempt in range(1, MAX + 1):
        prompt = (f"Optimize this CSL compute file to REDUCE cycles (currently "
                  f"{best_cyc}). It is one PE of an 8x8 GEMV decomposition.\n{ANGLES}\n\n"
                  f"```csl\n{best_pe}\n```\n\nReturn ONLY the full optimized pe.csl "
                  f"in one ```csl fence.")
        reply = llm_complete(h.client, h.model, [{"role": "user", "content": prompt}], 8192)
        cand = extract(reply)
        if not cand:
            print(f"[attempt {attempt}] no csl block"); continue
        ok, cyc, out = run(cand)
        if ok and cyc < best_cyc:
            accepts += 1
            print(f"[attempt {attempt}] ACCEPT {best_cyc} -> {cyc} (Δ {cyc-best_cyc})")
            best_pe, best_cyc = cand, cyc
        elif ok:
            print(f"[attempt {attempt}] reject (cyc {cyc} >= best {best_cyc})")
        else:
            err = [l for l in out.splitlines() if re.search(r"error:|Mismatch|stall|ran out", l)]
            print(f"[attempt {attempt}] FAIL ({(err[:1] or ['?'])[0][:80]})")
    print("=" * 60)
    print(f"[w2opt] best after {MAX} attempts ({accepts} accepts): {best_cyc} cycles")
    print(f"[w2opt] vs expert ref {REF}: {(best_cyc-REF)/REF*100:+.1f}%  "
          f"(baseline was +468.5%); translate->optimize recovered "
          f"{(58610-best_cyc)/(58610-REF)*100:.0f}% of the gap" if best_cyc>REF else "BEATS expert")
    if best_cyc < 58610:
        Path("/tmp/ws2opt_best_pe.csl").write_text(best_pe)
        print("[w2opt] best pe -> /tmp/ws2opt_best_pe.csl")
    return 0


if __name__ == "__main__":
    sys.exit(main())
