#!/usr/bin/env python3
"""Add the canonical tic/toc + cycles_send instrumentation to a kernel.

Many `kernels/` benches don't print ``cycles_send = N cycles`` from
``run.py`` and so are unusable as optimize_explore targets (the audit
classifies them ``NO_CYCLES``). This script asks the LLM to splice the
4-function recipe into both pe.csl (or whichever compute file the kernel
uses) and run.py, then smoke-tests the result by building + running the
modified bundle. The bundle is only written back to disk if the smoke
test confirms a fresh ``cycles_send`` line appears in stdout.

Idempotent — already-instrumented kernels are detected (grep for
``cycles_send`` in run.py) and skipped with no LLM call.

Usage:
    python3 code_translation/instrument_kernel.py --target kernels/Mandelbrot
    python3 code_translation/instrument_kernel.py --target kernels/Game\\ of\\ Life --dry-run
    python3 code_translation/instrument_kernel.py --batch \\
        kernels/Mandelbrot kernels/Game\\ of\\ Life kernels/GEMM\\ Collectives\\ 2D

Design notes:
  * Mirrors optimize_explore's bundle-staging pattern. Never edits the
    bench in-place until smoke test passes; writes go through .tmp +
    os.replace so an interrupted run can't half-corrupt a kernel.
  * Uses the same ProviderHandle resolver as optimize_explore so the
    --provider/--model/--api-key-file flags compose.
  * The reference template is the GEMV bundle. The LLM is shown that
    bundle's relevant 4-function block + run.py timing block and asked
    to adapt the shapes (rectangle dims, symbol names) to the target
    kernel.
"""

from __future__ import annotations

import argparse
import logging
import os
import re
import shutil
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path
from typing import List, Optional, Tuple

THIS_DIR = Path(__file__).resolve().parent
if str(THIS_DIR) not in sys.path:
    sys.path.insert(0, str(THIS_DIR))

from benchmark_csl import benchmark_translated_compute_file  # type: ignore
from optimize_explore import (  # type: ignore
    _detect_arch_and_script,
    _find_compute_file,
    _kernel_id_from_path,
)
from workflow_common import (  # type: ignore
    DEFAULT_API_KEY_FILE,
    ProviderHandle,
    expand_path,
    extract_code_block,
    llm_complete,
    resolve_provider,
)
from workflow_common import default_sdk_root, sdk_sif_path  # noqa: E402

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(filename)s:%(lineno)d - %(levelname)s - %(message)s",
)
logger = logging.getLogger("instrument_kernel")

REPO_ROOT = Path(__file__).resolve().parents[1]
GEMV_REFERENCE = REPO_ROOT / "kernels" / "GEMV" / "CSL"


# ---------------------------------------------------------------------------
# Idempotency check
# ---------------------------------------------------------------------------

_CYCLES_PRINT_RE = re.compile(r"cycles_send\s*=")


def is_already_instrumented(run_py_text: str) -> bool:
    """Cheap textual check: does run.py print 'cycles_send = ...' AND call
    f_tic / f_toc?
    """
    if not run_py_text:
        return False
    has_print = bool(_CYCLES_PRINT_RE.search(run_py_text))
    has_tic = "f_tic" in run_py_text or '"f_tic"' in run_py_text
    return has_print and has_tic


def has_pe_instrumentation(pe_text: str) -> bool:
    """Does pe.csl already declare the timestamp + tsc buffers?"""
    if not pe_text:
        return False
    return (
        "tscStartBuffer" in pe_text
        and "tscEndBuffer" in pe_text
        and "time_buf_u16" in pe_text
    )


# ---------------------------------------------------------------------------
# LLM prompt
# ---------------------------------------------------------------------------

SYSTEM_PROMPT = (
    "You are adding timing instrumentation to a Cerebras CSL kernel. The kernel "
    "currently runs correctly but does NOT print `cycles_send = N cycles` to "
    "stdout, so it cannot be used as an optimize_explore target. Your job is to "
    "splice in the canonical 4-function tic/toc recipe (already used by GEMV / "
    "Cholesky / 7-Point Stencil / etc) without changing any compute or "
    "correctness behaviour. Output two fenced blocks: the modified pe.csl and "
    "the modified run.py."
)


# Multi-PE timing recipe. Gated by XKERNEL_MULTIPE_PROMPT (default on) so the
# experience-mining A/B can measure its marginal pass-rate lift on multi-PE
# kernels. Set XKERNEL_MULTIPE_PROMPT=0 to reproduce the old single-PE-only
# prompt (the arm that stalled on multi-PE kernels).
_MULTIPE_PROMPT_BLOCK = """
## MULTI-PE kernels (rectangle bigger than 1x1) — extra rules, READ CAREFULLY

If the mesh hint shows a rectangle larger than 1x1 (e.g. set_rectangle(width,
height) with width*height > 1), the single-PE GEMV recipe is NOT enough. Two
runtime stalls bite (clean compile, then host aborts with
`the received length (N bytes) is not expected (M bytes), could be a kernel
stall`):

1. EVERY PE must own its own `time_buf_u16 = @zeros([6]u16)` and reach
   `@export_symbol(ptr_time_buf_u16, "time_buf_u16")` — this already happens
   if the buffer is a module-level var in the per-PE compute file (it is
   compiled onto every tile). Good.

2. The timestamp D2H in run.py MUST read 6 u16 words from the FULL rectangle,
   not from a single PE. Use the kernel's real width/height:
       time_memcpy_hwl = np.zeros((height, width, 6), dtype=np.uint32)
       runner.memcpy_d2h(time_memcpy_hwl, sym_time, 0, 0, width, height, 6,
                         streaming=False, data_type=MemcpyDataType.MEMCPY_16BIT,
                         nonblock=False, order=MemcpyOrder.ROW_MAJOR)
   Then cycles_send = max(time_end over all PEs) - min(time_start over all PEs)
   after the per-PE reference-clock shift (or, if the kernel has no reference
   clock, just max_end - min_start over the rectangle).

3. EVERY PE — including PEs whose compute already returned and edge/corner PEs
   that took a different branch — must call `sys_mod.unblock_cmd_stream()` at
   the END of f_tic, f_toc, f_memcpy_timestamps AND f_enable_timer. If any PE
   skips the unblock, the host launch of the next timer fn (or the timestamp
   D2H) hangs on that PE. The canonical timer fns each end with
   `sys_mod.unblock_cmd_stream();` for exactly this reason — copy that
   discipline. (If the compute file imports the memcpy module under a different
   name than `sys_mod`, use that name.)

4. f_tic / f_toc / f_memcpy_timestamps / f_enable_timer take NO arguments and
   are launched on ALL PEs by the broadcast launch. Do not gate their bodies
   behind a per-PE role check that would let some PE skip unblock_cmd_stream.

The canonical MULTI-PE reference is csl-examples/benchmarks/power-method
(kernel_power.csl + layout_power.csl + the run.py timing block) and the
residual benchmark. Follow it for any rectangle > 1x1.
"""


def build_prompt(target_kernel: str,
                 current_pe: str,
                 current_run_py: str,
                 current_layout: str,
                 reference_pe_excerpt: str,
                 reference_run_py_excerpt: str,
                 reference_layout_excerpt: str,
                 rectangle_hint: str) -> str:
    # Gated for A/B (XKERNEL_MULTIPE_PROMPT=0 reproduces the single-PE-only
    # prompt). Default on.
    multipe_block = ("" if os.getenv("XKERNEL_MULTIPE_PROMPT", "1") == "0"
                     else _MULTIPE_PROMPT_BLOCK)
    return f"""You are adding timing instrumentation to a Cerebras CSL kernel.

## Target kernel
{target_kernel}

## Goal
Make the kernel print these two specific stdout lines on a successful run:
    cycles_send = <int> cycles
    time_send = <float> us

The instrumentation must NOT change any compute behaviour, exported
symbol shapes that the kernel itself uses, fabric routing, or numerical
output. The only NEW exported symbols are the four timer functions and
the time_buf_u16 array.

## Canonical recipe (verbatim from the GEMV kernel — pe.csl + layout.csl + run.py)

### From GEMV pe.csl
```csl
{reference_pe_excerpt}
```

### From GEMV layout.csl — REQUIRED `@export_name` declarations
```csl
{reference_layout_excerpt}
```
Without these `@export_name` lines in layout.csl, cslc fails with:
  `name 'time_buf_u16' was not declared during layout evaluation`
This is the most common failure when instrumenting a kernel.

### From GEMV run.py — launch order + timestamp decode
```python
{reference_run_py_excerpt}
```

## CURRENT pe.csl (your input — modify this)
```csl
{current_pe}
```

## CURRENT layout.csl (your input — modify this too if not yet declaring the timer symbols)
```csl
{current_layout}
```

## CURRENT run.py (your input — modify this)
```python
{current_run_py}
```

## Mesh hint
{rectangle_hint}

## What to do

1. **pe.csl**: add at file top after the existing imports — the `<time>` import,
   `tscStartBuffer`, `tscEndBuffer`, `time_buf_u16`, `ptr_time_buf_u16`. Add the
   four functions (f_enable_timer, f_tic, f_toc, f_memcpy_timestamps) somewhere
   sensible. Add `@export_symbol(...)` for ptr_time_buf_u16 (name "time_buf_u16")
   and each of the four functions in the existing `comptime {{ ... }}` block.

2. **layout.csl**: add these 5 lines inside the existing layout's export block
   (where `@export_name(...)` calls already live). REQUIRED — without them,
   compile fails with `name 'time_buf_u16' was not declared during layout
   evaluation`:
       @export_name("time_buf_u16", [*]u16, true);
       @export_name("f_tic", fn()void);
       @export_name("f_toc", fn()void);
       @export_name("f_memcpy_timestamps", fn()void);
       @export_name("f_enable_timer", fn()void);
   If the kernel's existing layout.csl uses a different `comptime { ... }` /
   `layout { ... }` shape, slot them next to the other `@export_name` calls.

3. **run.py**: in the order shown by the GEMV reference, insert:
       runner.launch("f_enable_timer", nonblock=False)
       runner.launch("f_tic",          nonblock=False)
       <the existing kernel-launch call(s) — leave them unchanged>
       runner.launch("f_toc",          nonblock=False)
       runner.launch("f_memcpy_timestamps", nonblock=False)
   AFTER existing memcpy_d2h of outputs, insert the timestamp d2h block +
   the cycles_send / time_send compute + the two print statements. Use the
   ACTUAL rectangle dimensions of this kernel (the mesh hint above).

## Hard rules

- Do NOT change which symbols the kernel itself exports (e.g. keep `A`, `x`,
  `y`, `compute`, etc as they were). Only ADD the four timer functions and
  the time_buf_u16 pointer.
- Do NOT move or reorder any existing computation. Tic comes BEFORE the
  kernel's compute launch, toc comes AFTER it, memcpy_timestamps comes
  AFTER toc but BEFORE the device output d2h reads.
- ALWAYS modify layout.csl too — `@export_symbol` in pe.csl is necessary
  but not sufficient. Without matching `@export_name` in layout.csl, compile
  fails. (Exception: kernels with no layout.csl at all — single-file
  kernels — can skip the `layout` fence; return an empty one.)
- If the kernel uses MEMCPY_16BIT elsewhere for its data, KEEP that.
  Read the timestamps with `MemcpyDataType.MEMCPY_16BIT` matching the
  device-side u16 storage.
{multipe_block}
## Output format — strict

```pe
<the FULL modified pe.csl, top to bottom>
```

```layout
<the FULL modified layout.csl, top to bottom — or LEAVE EMPTY if the kernel
has no layout.csl>
```

```run
<the FULL modified run.py, top to bottom>
```

Nothing else. No prose outside the fences.
"""


# ---------------------------------------------------------------------------
# Reference excerpts (loaded once at startup)
# ---------------------------------------------------------------------------

def _load_reference_excerpts() -> Tuple[str, str, str]:
    pe_path = GEMV_REFERENCE / "pe.csl"
    rp_path = GEMV_REFERENCE / "run.py"
    layout_path = GEMV_REFERENCE / "layout.csl"
    pe_text = pe_path.read_text(encoding="utf-8")
    rp_text = rp_path.read_text(encoding="utf-8")
    layout_text = layout_path.read_text(encoding="utf-8") if layout_path.is_file() else ""
    # Extract the timing-relevant pieces from pe.csl:
    #   - the import + tsc buffer lines (block 1)
    #   - the four functions
    #   - the export block lines
    pe_lines = pe_text.splitlines()
    pe_excerpt_lines = []
    in_funcs = False
    for i, ln in enumerate(pe_lines):
        if any(tok in ln for tok in (
            "const timestamp = @import_module(\"<time>\")",
            "tscStartBuffer", "tscEndBuffer", "time_buf_u16",
            "ptr_time_buf_u16",
        )):
            pe_excerpt_lines.append(ln)
        elif ln.strip().startswith("fn f_tic(") or ln.strip().startswith("fn f_toc(") \
                or ln.strip().startswith("fn f_memcpy_timestamps(") \
                or ln.strip().startswith("fn f_enable_timer("):
            in_funcs = True
            pe_excerpt_lines.append(ln)
        elif in_funcs:
            pe_excerpt_lines.append(ln)
            if ln.strip() == "}" and i + 1 < len(pe_lines) and not pe_lines[i+1].strip():
                in_funcs = False
        elif "@export_symbol(ptr_time_buf_u16" in ln or "@export_symbol(f_tic" in ln \
                or "@export_symbol(f_toc" in ln \
                or "@export_symbol(f_memcpy_timestamps" in ln \
                or "@export_symbol(f_enable_timer" in ln:
            pe_excerpt_lines.append(ln)
    pe_excerpt = "\n".join(pe_excerpt_lines)
    # Excerpt run.py: lines around the launch sequence + timestamp decode.
    rp_lines = rp_text.splitlines()
    rp_keep_idx = set()
    for i, ln in enumerate(rp_lines):
        if any(tok in ln for tok in (
            "symbol_time", "f_enable_timer", "f_tic", "f_toc",
            "f_memcpy_timestamps", "cycles_send", "time_send",
            "time_memcpy_hwl", "MEMCPY_16BIT",
            "MemcpyDataType", "MemcpyOrder",
        )):
            # Keep this line plus 1 line of context either side.
            for j in (i - 1, i, i + 1):
                if 0 <= j < len(rp_lines):
                    rp_keep_idx.add(j)
    rp_excerpt = "\n".join(rp_lines[i] for i in sorted(rp_keep_idx))
    # Layout excerpt: the 5 @export_name lines for timer symbols (+ a few
    # lines of surrounding context so the LLM knows where they go).
    layout_excerpt = ""
    if layout_text:
        layout_lines = layout_text.splitlines()
        keep = set()
        for i, ln in enumerate(layout_lines):
            if any(tok in ln for tok in (
                "time_buf_u16", "f_tic", "f_toc", "f_memcpy_timestamps",
                "f_enable_timer", "// export symbol names",
            )):
                for j in (i - 1, i, i + 1):
                    if 0 <= j < len(layout_lines):
                        keep.add(j)
        layout_excerpt = "\n".join(layout_lines[i] for i in sorted(keep))
    return pe_excerpt, rp_excerpt, layout_excerpt


# ---------------------------------------------------------------------------
# Layout-file discovery
# ---------------------------------------------------------------------------

def _find_layout_file(csl_dir: Path) -> Optional[str]:
    """Return the relpath (relative to csl_dir) of the LAYOUT file — the one
    containing the `layout { ... }` block with `@set_tile_code` /
    `@export_name`. NOT always named layout.csl: e.g. Wide Multiplication
    names it `code.csl`. Multi-file solver bundles use `src/layout.csl`.

    Without this, an instrumenter that hardcodes `layout.csl` writes the
    @export_name additions to a file that isn't in the build, and cslc fails
    with `name '<sym>' was not declared during layout evaluation`.

    Search order: src/layout.csl, layout.csl, then any *.csl at root (or under
    src/) whose text contains `@set_tile_code` (the unambiguous layout marker).
    """
    candidates = [Path("src") / "layout.csl", Path("layout.csl")]
    for rel in candidates:
        if (csl_dir / rel).is_file():
            return str(rel)
    search_roots = [csl_dir]
    if (csl_dir / "src").is_dir():
        search_roots.append(csl_dir / "src")
    for root in search_roots:
        for p in sorted(root.glob("*.csl")):
            try:
                txt = p.read_text(encoding="utf-8")
            except OSError:
                continue
            if "@set_tile_code" in txt or re.search(r"\blayout\s*\{", txt):
                return str(p.relative_to(csl_dir))
    return None


# ---------------------------------------------------------------------------
# Smoke test
# ---------------------------------------------------------------------------

@dataclass
class SmokeResult:
    ok: bool
    cycles_send: Optional[int]
    reason: str
    stderr_tail: str


def smoke_test(target_dir: Path,
               modified_pe: str,
               modified_run_py: str,
               compute_relpath: str,
               commands_script: str,
               arch: str,
               sdk_root: str,
               modified_layout: Optional[str] = None,
               layout_relpath: Optional[str] = None) -> SmokeResult:
    """Stage the modified bundle into a sandbox and benchmark. Return
    whether cycles_send was emitted + correctness still holds.

    Important: benchmark_translated_compute_file copies the bundle into
    work_dir/bundle internally and then overlays translated_path onto
    target_relpath. To avoid SameFileError, translated_path MUST live
    OUTSIDE work_dir/bundle. We write the modified pe.csl + run.py to
    a sibling staging area instead.
    """
    work_dir = tempfile.mkdtemp(prefix="instrument_smoke_", dir="/tmp")
    try:
        # Write modified files to a sibling dir, NOT inside the bundle
        # benchmark_translated_compute_file will create. The benchmark
        # routine itself copies target_dir → work_dir/bundle and then
        # overlays translated_path on top.
        overlay = Path(work_dir) / "overlay"
        overlay.mkdir(parents=True, exist_ok=True)
        # Mirror the compute_relpath structure (e.g. src/kernel.csl needs src/).
        modified_pe_path = overlay / compute_relpath
        modified_pe_path.parent.mkdir(parents=True, exist_ok=True)
        modified_pe_path.write_text(modified_pe, encoding="utf-8")
        # run.py is overlayed onto the bundle separately — but
        # benchmark_translated_compute_file only honours translated_path
        # for the compute file. We have to overlay run.py by either
        # (a) staging a complete modified target_dir, or
        # (b) running benchmark with a copy of target_dir that already
        # has the modified run.py.
        # Use (b) — make a target_dir copy with the modified run.py.
        modified_target = Path(work_dir) / "modified_target"
        shutil.copytree(target_dir, modified_target)
        (modified_target / "run.py").write_text(modified_run_py,
                                                 encoding="utf-8")
        # Layout overlay: required for kernels where @export_name needs
        # to be added so the host can find time_buf_u16 et al. The layout
        # file is NOT always named layout.csl (e.g. code.csl, src/layout.csl)
        # — write to the discovered relpath, falling back to layout.csl.
        if modified_layout is not None and modified_layout.strip():
            layout_path = modified_target / (layout_relpath or "layout.csl")
            if layout_path.is_file():
                layout_path.write_text(modified_layout, encoding="utf-8")
            else:
                logger.warning("[smoke] layout overlay target %s not found; "
                               "@export_name additions will not be applied",
                               layout_path)
        result = benchmark_translated_compute_file(
            translated_path=str(modified_pe_path),
            reference_dir=str(modified_target),
            target_relpath=compute_relpath,
            work_dir=work_dir,
            sdk_root=sdk_root,
            shell_setup=None,
            commands_script=commands_script,
            arch=arch,
            keep_staged_bundle=False,
            num_runs=1,
        )
    finally:
        shutil.rmtree(work_dir, ignore_errors=True)

    status = result.get("status")
    cycles = result.get("cycles_send")
    stderr_tail = ""
    for entry in (result.get("transcript") or []):
        if entry.get("status") != "pass":
            stderr_tail = (entry.get("stderr") or "")[-1200:]
            break

    if status != "pass":
        return SmokeResult(False, None,
                           f"bench fail: {result.get('failure_reason')}",
                           stderr_tail)
    if cycles is None:
        return SmokeResult(False, None,
                           "ran but did not emit `cycles_send = N cycles` "
                           "(LLM may have inserted the print but it didn't "
                           "reach stdout; check that f_memcpy_timestamps "
                           "is actually launched before the timestamp d2h)",
                           "")
    return SmokeResult(True, int(cycles), "OK", "")


# ---------------------------------------------------------------------------
# Driver — one kernel
# ---------------------------------------------------------------------------

def instrument_one(target: Path,
                   provider: ProviderHandle,
                   sdk_root: str,
                   dry_run: bool = False,
                   force: bool = False,
                   max_tokens: int = 8192) -> bool:
    """Returns True on success (or already-instrumented), False on failure."""
    if not target.is_dir():
        logger.error("[%s] not a directory", target)
        return False
    csl_dir = target / "CSL" if (target / "CSL").is_dir() else target
    run_py_path = csl_dir / "run.py"
    if not run_py_path.is_file():
        logger.error("[%s] no run.py at %s", target.name, run_py_path)
        return False

    run_py_text = run_py_path.read_text(encoding="utf-8")
    if not force and is_already_instrumented(run_py_text):
        logger.info("[%s] already instrumented (cycles_send + f_tic present in run.py); skip",
                    target.name)
        return True

    # Locate compute file + commands script + arch.
    compute_relpath = _find_compute_file(csl_dir)
    if not compute_relpath:
        logger.error("[%s] no compute file found (pe*.csl / src/kernel*.csl / *.csl)",
                     target.name)
        return False
    try:
        arch, commands_script = _detect_arch_and_script(csl_dir)
    except FileNotFoundError as exc:
        logger.error("[%s] %s", target.name, exc)
        return False
    pe_path = csl_dir / compute_relpath
    pe_text = pe_path.read_text(encoding="utf-8")

    # Rectangle hint + current layout text. The layout file is not always
    # named layout.csl (e.g. Wide Multiplication uses code.csl; solvers use
    # src/layout.csl) — discover it so the LLM sees the real layout and the
    # @export_name additions land in the file that's actually compiled.
    rect_hint = "(unknown — read the layout file in the kernel to determine width × height)"
    layout_relpath = _find_layout_file(csl_dir)
    current_layout_text = ""
    if layout_relpath is not None:
        layout_path = csl_dir / layout_relpath
        current_layout_text = layout_path.read_text(encoding="utf-8")
        m = re.search(r"@set_rectangle\s*\(\s*([^)]+)\)", current_layout_text)
        if m:
            rect_hint = f"{layout_relpath} declares: @set_rectangle({m.group(1)})"
        if layout_relpath != "layout.csl":
            current_layout_text = (
                f"// NOTE: this kernel's layout file is named '{layout_relpath}', "
                f"not layout.csl. Emit the FULL modified contents of THIS file in "
                f"the ```layout fence.\n" + current_layout_text)
    else:
        current_layout_text = "(no layout file found — single-file bundle; emit an empty layout fence)"

    pe_excerpt, rp_excerpt, layout_excerpt = _load_reference_excerpts()
    prompt = build_prompt(
        target_kernel=target.name,
        current_pe=pe_text,
        current_run_py=run_py_text,
        current_layout=current_layout_text,
        reference_pe_excerpt=pe_excerpt,
        reference_run_py_excerpt=rp_excerpt,
        reference_layout_excerpt=layout_excerpt,
        rectangle_hint=rect_hint,
    )
    if dry_run:
        logger.info("[%s] dry-run: would call LLM with %d-char prompt; compute=%s "
                    "arch=%s script=%s rect=%r",
                    target.name, len(prompt), compute_relpath, arch,
                    commands_script, rect_hint)
        return True

    logger.info("[%s] requesting instrumentation (compute=%s, arch=%s)",
                target.name, compute_relpath, arch)
    try:
        reply = llm_complete(
            provider.client, provider.model,
            [{"role": "system", "content": SYSTEM_PROMPT},
             {"role": "user", "content": prompt}],
            max_tokens,
        )
    except Exception as exc:
        logger.error("[%s] LLM call failed: %s", target.name, str(exc)[:200])
        return False

    # Parse three fenced blocks: ```pe ... ```, ```layout ... ```, ```run ... ```.
    # layout is OPTIONAL (kernels without a layout.csl emit an empty fence).
    pe_match = re.search(r"```pe\s*\n(.*?)```", reply, re.DOTALL)
    layout_match = re.search(r"```layout\s*\n(.*?)```", reply, re.DOTALL)
    run_match = re.search(r"```run\s*\n(.*?)```", reply, re.DOTALL)
    if not pe_match or not run_match:
        # Fall back to language-tagged fences (no separate layout fallback).
        pe_match = re.search(r"```csl\s*\n(.*?)```", reply, re.DOTALL)
        run_match = re.search(r"```python\s*\n(.*?)```", reply, re.DOTALL)
    if not pe_match or not run_match:
        # Likely truncated by max_tokens. Surface the reply size + the
        # presence of opening fences so the operator knows whether to
        # raise --max-tokens or check the prompt itself.
        opens = sum(reply.count(f"```{tag}") for tag in
                    ("pe", "run", "csl", "python"))
        closes = reply.count("```") - opens
        logger.error("[%s] reply missing ```pe / ```run fence(s). "
                     "reply_chars=%d, open_fences=%d, close_fences=%d. "
                     "If close < open, the reply was truncated mid-block — "
                     "re-run with a larger --max-tokens. "
                     "raw[:400]=%r ... raw[-200:]=%r",
                     target.name, len(reply), opens, closes,
                     reply[:400], reply[-200:])
        return False

    new_pe = pe_match.group(1).strip() + "\n"
    new_run_py = run_match.group(1).strip() + "\n"
    new_layout = (layout_match.group(1).strip() + "\n") if layout_match else ""

    # Verify the LLM didn't strip something important.
    if "@export_symbol" not in new_pe:
        logger.error("[%s] modified pe.csl has no @export_symbol — aborting "
                     "(LLM probably truncated)", target.name)
        return False
    if "runner.launch" not in new_run_py:
        logger.error("[%s] modified run.py has no runner.launch — aborting",
                     target.name)
        return False

    # Smoke-test.
    logger.info("[%s] running smoke test (compile + 1 run)", target.name)
    smoke = smoke_test(
        target_dir=csl_dir,
        modified_pe=new_pe,
        modified_run_py=new_run_py,
        compute_relpath=compute_relpath,
        commands_script=commands_script,
        arch=arch,
        sdk_root=sdk_root,
        modified_layout=new_layout if new_layout.strip() else None,
        layout_relpath=layout_relpath,
    )
    if not smoke.ok:
        logger.error("[%s] smoke test FAILED: %s\n--- stderr tail ---\n%s",
                     target.name, smoke.reason, smoke.stderr_tail)
        return False
    logger.info("[%s] smoke OK: cycles_send=%d", target.name, smoke.cycles_send)

    # Write back atomically.
    _atomic_write(pe_path, new_pe)
    _atomic_write(run_py_path, new_run_py)
    files_written = [str(pe_path), str(run_py_path)]
    if new_layout.strip() and layout_relpath is not None:
        layout_path = csl_dir / layout_relpath
        if layout_path.is_file():
            _atomic_write(layout_path, new_layout)
            files_written.append(str(layout_path))
    logger.info("[%s] INSTRUMENTED. Files written:\n  %s\n  baseline cycles_send=%d",
                target.name, "\n  ".join(files_written), smoke.cycles_send)
    return True


def _atomic_write(path: Path, content: str) -> None:
    tmp = path.with_suffix(path.suffix + ".tmp_instrument")
    tmp.write_text(content, encoding="utf-8")
    os.replace(tmp, path)


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main() -> int:
    p = argparse.ArgumentParser(
        description="Add canonical tic/toc + cycles_send instrumentation to "
                    "an uninstrumented Cerebras CSL kernel.")
    g = p.add_mutually_exclusive_group(required=True)
    g.add_argument("--target", type=str, default=None,
                   help="Path to ONE kernels/<Name>/ directory to instrument.")
    g.add_argument("--batch", type=str, nargs="+",
                   help="Multiple kernels to instrument in sequence.")
    p.add_argument("--provider", choices=["auto", "alcf", "argo", "openai"],
                   default="auto")
    p.add_argument("--alcf-endpoint", choices=["metis", "sophia"], default="metis")
    p.add_argument("--model", type=str, default=None)
    p.add_argument("--api-key-file", type=str, default=DEFAULT_API_KEY_FILE)
    p.add_argument("--api-key-command", type=str, default=None)
    p.add_argument("--require-provider", action="store_true")
    p.add_argument("--sdk-root", type=str, default=default_sdk_root())
    p.add_argument("--max-tokens", type=int, default=16384,
                   help="LLM max output tokens. Default 16384 — kernels with "
                        "300+ line pe.csl + 200+ line run.py easily exceed "
                        "8k token output. Game of Life (532 lines combined) "
                        "is the canonical case that needed this bump.")
    p.add_argument("--enable-singularity-gate", action="store_true",
                   help="Serialize singularity invocations (use with --batch).")
    p.add_argument("--dry-run", action="store_true",
                   help="Skip the LLM + cslc; just confirm we can read the "
                        "bundle and would build a prompt.")
    p.add_argument("--force", action="store_true",
                   help="Re-instrument even if cycles_send is already in run.py.")
    args = p.parse_args()

    if args.enable_singularity_gate:
        os.environ["XKERNEL_SINGULARITY_GATE"] = "1"

    # Resolve provider once.
    provider = None
    if not args.dry_run:
        try:
            provider = resolve_provider(
                provider=args.provider,
                alcf_endpoint=args.alcf_endpoint,
                model=args.model,
                api_key_file=args.api_key_file,
                api_key_command=args.api_key_command,
                require=args.require_provider,
            )
        except RuntimeError as exc:
            logger.error("provider resolution failed: %s", exc)
            return 2

    targets = [args.target] if args.target else args.batch
    sdk_root = expand_path(args.sdk_root)
    successes = 0
    failures: List[str] = []
    for tpath in targets:
        target = Path(os.path.expanduser(tpath)).resolve()
        try:
            ok = instrument_one(
                target=target,
                provider=provider,
                sdk_root=sdk_root,
                dry_run=args.dry_run,
                force=args.force,
                max_tokens=args.max_tokens,
            )
        except Exception as exc:
            logger.error("[%s] unhandled exception: %s",
                         target.name, str(exc)[:300])
            ok = False
        if ok:
            successes += 1
        else:
            failures.append(target.name)

    print()
    print("=" * 60)
    print(f"  attempted          {len(targets)}")
    print(f"  succeeded          {successes}")
    print(f"  failed             {len(failures)}")
    if failures:
        for f in failures:
            print(f"    - {f}")
    print("=" * 60)
    return 0 if not failures else 1


if __name__ == "__main__":
    sys.exit(main())
