#!/usr/bin/env python3
"""Headline experiment: GEMV-large agent-decomposition through a REPAIR LOOP.

WS2b proved one-shot generation gets the decomposition structurally right but
dies on deep idiom errors (e.g. c2d_params.x_dim_params -> should be .x, which
the compiler itself points to). The framework's real W1 path has a repair loop;
this driver adds one to the agent-distribution path so we can answer the headline
question: can the agent, firewalled from the reference, produce a PASSING
decomposition at the large size (512x256) and beat the human reference (10309)?

Firewall: sees CUDA + task + holed layout template + logical run.py + real
library signatures (incl. SDK <collectives_2d/*> from the container). NEVER the
reference pe.csl / layout.csl / distribution.py.

Loop: generate 3 artifacts -> stage -> compile+run at large size -> if fail,
feed back the cslc/runtime error + the current artifacts, regenerate. Up to N
attempts (matches the framework's --reviewer-max-attempts).
"""
import os, re, sys, subprocess, shutil
from pathlib import Path

sys.path.insert(0, "/home/USER/xkernel/code_translation")
from workflow_common import resolve_provider, llm_complete  # type: ignore
from library_signatures import library_signatures_block  # type: ignore

REPO = Path("/home/USER/xkernel")
GEMV = REPO / "kernels" / "GEMV" / "CSL"
WORK = Path("/tmp/ws2b_repair/K")
REF_CYCLES = 10309
MAX_ATTEMPTS = int(os.getenv("WS2B_MAX_ATTEMPTS", "8"))

cuda = (REPO / "kernels" / "GEMV" / "CUDA" / "kernel.cu").read_text()
template = (GEMV / "layout.template.csl").read_text()
runpy = (GEMV / "run.py").read_text()
libsig = library_signatures_block(str(GEMV), template)

SYS = ("You are an expert Cerebras WSE CSL engineer translating CUDA to a "
       "wafer-scale decomposition. You design from first principles; you never "
       "see reference CSL. You fix compile/runtime errors precisely from the "
       "diagnostics given.")

BASE = f"""Translate this CUDA GEMV to a CSL kernel at a LARGE size (512x256) that does
NOT fit a small PE mesh — choose a decomposition onto an 8x8 PE rectangle.

Emit THREE fenced blocks, nothing else:
1) ```distribution  (Python distribution.py)
   grid(params)->(w,h); distribute(name,arr,params)->(flat,w,h,elems,x0,y0) for
   name in 'A','x','b'; collect(name,params)->(x,y,w,h,elems) for 'y';
   DTYPE=MemcpyDataType.MEMCPY_32BIT; ORDER=MemcpyOrder.ROW_MAJOR (import from
   cerebras.sdk.runtime.sdkruntimepybind).
2) ```layout  (CSL) — fill the HOLES in the template; keep the @export_name
   contract + param names verbatim; set_rectangle must match grid().
3) ```pe  (CSL) — the per-PE compute bound by the layout.

## logical run.py (drives your bundle; do not change):
```python
{runpy[:2400]}
```
## layout template (fill <<HOLE>>s):
```csl
{template}
```
## Library module signatures (instantiate EXACTLY — names + arities):
{libsig}
## CUDA:
```cuda
{cuda}
```"""


def extract(reply, tag):
    m = re.search(rf"```{tag}\s*\n(.*?)```", reply, re.DOTALL)
    return m.group(1) if m else None


def stage_and_run(dist, layout, pe):
    if WORK.exists():
        shutil.rmtree(WORK.parent)
    WORK.mkdir(parents=True)
    shutil.copytree(GEMV, WORK / "CSL")
    shutil.copytree(REPO / "kernels" / "benchmark-libs", WORK / "benchmark-libs")
    (WORK / "CSL" / "distribution.py").write_text(dist)
    (WORK / "CSL" / "layout.csl").write_text(layout)
    (WORK / "CSL" / "pe.csl").write_text(pe)
    cmds = (WORK / "CSL" / "commands_wse3_large.sh").read_text()
    (WORK / "CSL" / "ws_run.sh").write_text(cmds)
    env = dict(os.environ, PATH=f"/home/USER/cs_sdk-1.4.0:{os.environ['PATH']}",
               CSL_IMPORT_PATH=str(WORK))
    try:
        r = subprocess.run(["bash", "ws_run.sh"], cwd=WORK / "CSL", env=env,
                           capture_output=True, text=True, timeout=900)
        out = r.stdout + r.stderr
    except subprocess.TimeoutExpired:
        out = "TIMEOUT after 900s"
    cyc = re.search(r"cycles_send = (\d+)", out)
    ok = "SUCCESS" in out and cyc is not None
    return ok, (int(cyc.group(1)) if cyc else None), out


def main():
    h = resolve_provider(provider="auto")
    print(f"[repair] provider={h.model}  max_attempts={MAX_ATTEMPTS}  ref={REF_CYCLES}")
    msgs = [{"role": "system", "content": SYS},
            {"role": "user", "content": BASE}]
    for attempt in range(1, MAX_ATTEMPTS + 1):
        reply = llm_complete(h.client, h.model, msgs, 8192)
        dist, layout, pe = extract(reply, "distribution"), extract(reply, "layout"), extract(reply, "pe")
        if not (dist and layout and pe):
            print(f"[attempt {attempt}] missing artifact (d={bool(dist)} l={bool(layout)} p={bool(pe)})")
            msgs += [{"role": "assistant", "content": reply},
                     {"role": "user", "content": "You did not emit all three fenced blocks "
                      "(```distribution, ```layout, ```pe). Emit all three, complete."}]
            continue
        ok, cyc, out = stage_and_run(dist, layout, pe)
        # error tail for feedback
        errs = [ln for ln in out.splitlines()
                if re.search(r"error:|not expected|stall|Mismatch|assert|ran out|no such|Possible fields", ln)]
        tail = "\n".join(errs[:12]) or "\n".join(out.splitlines()[-12:])
        status = f"SUCCESS cycles={cyc}" if ok else "FAIL"
        print(f"[attempt {attempt}] {status}")
        if ok:
            verdict = "BEATS" if cyc < REF_CYCLES else "slower than"
            print("=" * 60)
            print(f"[repair] PASSING decomposition in {attempt} attempts: {cyc} cycles, "
                  f"{(cyc-REF_CYCLES)/REF_CYCLES*100:+.1f}% ({verdict} human ref {REF_CYCLES})")
            art = Path("/tmp/ws2b_repair_artifacts"); art.mkdir(exist_ok=True)
            (art / "distribution.py").write_text(dist)
            (art / "layout.csl").write_text(layout)
            (art / "pe.csl").write_text(pe)
            print(f"[repair] winning artifacts -> {art}")
            return 0
        # feed the error back
        msgs += [{"role": "assistant", "content": reply},
                 {"role": "user", "content":
                  f"The bundle FAILED to compile/run. Fix it precisely from these "
                  f"diagnostics (the compiler often names the correct field/arity):\n"
                  f"```\n{tail[:1500]}\n```\n"
                  f"Re-emit all THREE corrected fenced blocks "
                  f"(```distribution, ```layout, ```pe)."}]
    print("=" * 60)
    print(f"[repair] NO passing decomposition in {MAX_ATTEMPTS} attempts.")
    print(f"[repair] last error tail:\n{tail}")
    return 1


if __name__ == "__main__":
    sys.exit(main())
