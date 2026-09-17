#!/usr/bin/env python3
"""Lever 1 — pre-flight library-param extractor.

W1 failure analysis (2026-06-18, results/w1_failure_analysis_20260618.md) found
that ~50% of W1 translation failures are the implementer THRASHING on the hidden
signatures of the SDK-style library modules a kernel must instantiate
(``benchmark-libs/stencil_3d_7pts/pe.csl``, ``allreduce/pe.csl``, and the SDK
``<collectives_2d/*>``). The implementer is firewalled from the reference
``pe.csl`` AND from these library files, so it reverse-engineers param arities
(``dest_dsr_ids:[2]u16`` vs ``[1]u16`` …) from compiler errors and never
converges — the reviewer even tells it to "open pe.csl and list its params" but
the agent has no Read tool.

This module extracts the ``param`` + top-level ``fn`` *signatures* (NOT bodies)
of the library modules a kernel's ``layout.csl`` imports, so they can be injected
into the implementer context.

FIREWALL: this is firewall-safe. The library files are shared interfaces (like
SDK headers), not the bench's reference compute. The compute-leak canary guards
a distinctive line of the bench's OWN reference compute file (a different file);
library signatures never trip it. Only ``param`` declarations and one-line ``fn``
signatures are emitted — never a function body, never the reference compute.
"""

from __future__ import annotations

import os
from workflow_common import default_sdk_root, sdk_sif_path  # noqa: E402
import re
from pathlib import Path
from typing import List, Optional

# Match  @import_module("../../benchmark-libs/<mod>/layout.csl", ...)
#   and  @import_module("<collectives_2d/pe>" / "<collectives_2d/params>", ...)
_IMPORT_RE = re.compile(r'@import_module\(\s*"([^"]+)"')

# A param line we want to surface (declaration the import struct must satisfy).
_PARAM_RE = re.compile(r'^\s*param\s+[A-Za-z_]\w*\s*[:=]')
# A top-level callable: `fn name(args) ret {`  — capture up to the opening brace.
_FN_RE = re.compile(r'^\s*(?:pub\s+)?fn\s+([A-Za-z_]\w*)\s*\(')


def discover_imported_libs(layout_text: str) -> List[str]:
    """Return the raw @import_module targets in layout_text that point at a
    library module whose pe.csl-side signature the COMPUTE file must satisfy.

    Keeps benchmark-libs/*, <collectives_2d/*>, and <kernels/.../layout> SDK
    modules. Drops <memcpy/*>, <time>, <math> etc. (the agent already knows those /
    they need no struct wiring).
    """
    # R4 (failure-analysis 2026-06-25): surface SDK <kernels/...> library interfaces
    # (e.g. <kernels/tally/pe> for Histogram). Default-on; XKERNEL_FIXES_20260625=0
    # drops it for the attributable A/B over the 2026-06-25 patch set.
    _r4_kernels_libs = os.getenv("XKERNEL_FIXES_20260625", "1") != "0"
    out: List[str] = []
    for m in _IMPORT_RE.finditer(layout_text or ""):
        target = m.group(1)
        is_kernels = target.startswith("<kernels/")
        if ("benchmark-libs/" in target or target.startswith("<collectives_2d")
                or (is_kernels and _r4_kernels_libs)):
            if target not in out:
                out.append(target)
            # The layout imports <collectives_2d/params> (layout side), but the
            # COMPUTE file must instantiate <collectives_2d/pe> (the side with
            # broadcast/scatter/gather/reduce_fadds). Surface the pe interface
            # too so the agent gets the methods it actually calls.
            if target.startswith("<collectives_2d") and "<collectives_2d/pe>" not in out:
                out.append("<collectives_2d/pe>")
            # Same idea for SDK <kernels/...> modules whose layout side is imported
            # but whose COMPUTE-side pe interface the agent must instantiate (e.g.
            # Histogram imports <kernels/tally/layout> but the compute file calls
            # <kernels/tally/pe>'s bump_tally/signal_completion). Map the layout
            # path -> the sibling pe module so its signature is surfaced. (Modules
            # without a /layout suffix + /pe sibling, e.g. <kernels/fft/fft3d_layout>,
            # just pass through harmlessly — no sibling is added.)
            if is_kernels and _r4_kernels_libs and target.endswith("/layout>"):
                pe = target[: -len("/layout>")] + "/pe>"
                if pe not in out:
                    out.append(pe)
    return out


def _resolve_pe_csl(reference_dir: str, import_target: str,
                    arch: Optional[str] = None) -> Optional[Path]:
    """Resolve a layout @import_module target to the library's pe.csl on disk.

    layout.csl imports the module's layout.csl by a path relative to where
    layout.csl lives (reference_dir, typically .../CSL or .../CSL/src). The
    COMPUTE file imports the sibling pe.csl. We map ``<mod>/layout.csl`` ->
    ``<mod>/pe.csl`` and try the import path relative to both reference_dir and
    reference_dir/src (covers the two bundle layouts: flat and src/).

    C5 fix (failure-analysis 2026-06-23): when `arch` is given, PREFER the
    arch-specific sibling ``<mod>/<arch>/pe.csl`` over the arch-neutral
    ``<mod>/pe.csl``. The neutral stencil_3d_7pts/pe.csl declares
    ``param output_queues = {}`` / ``param output_ut_id = {}`` (no type -> the
    agent guesses arity), while wse3/pe.csl declares ``param output_queues:[4]u16``
    and a bare-scalar ``param output_ut_id`` — exactly the two shapes behind the
    documented 'output_ut_id as [1]u16 instead of scalar' / 'omitted output_queues'
    failures. Falls back to the neutral file when no arch-specific sibling exists.
    """
    if import_target.startswith("<"):
        return None  # SDK <...> module: resolved from the container, not on disk.

    # Normalise layout.csl -> pe.csl.
    rel = import_target
    if rel.endswith("/layout.csl"):
        rel = rel[: -len("/layout.csl")] + "/pe.csl"
    elif not rel.endswith(".csl"):
        rel = rel + "/pe.csl"

    # Build arch-specific candidates first (prefer them), then the neutral ones.
    rels = []
    if arch and rel.endswith("/pe.csl"):
        rels.append(rel[: -len("/pe.csl")] + f"/{arch}/pe.csl")
    rels.append(rel)

    ref = Path(reference_dir)
    for r in rels:
        for c in (ref / r, ref / "src" / r, ref.parent / r):
            try:
                rc = c.resolve()
            except OSError:
                continue
            if rc.is_file():
                return rc
    return None


# --- SDK <...> module extraction from inside the cslc container ---------------
# The SDK collectives/csl-libs modules (e.g. <collectives_2d/pe>) live inside the
# SIF, not on the host. We read their REAL source via `singularity exec cat` so
# the signatures are extracted from ground truth — NOT hand-authored prose (which
# would be benchmark-overfitting / not paper-defensible). Cached per-process.
_SDK_SIF = sdk_sif_path() or ""
_SDK_CSL_LIBS = os.getenv(
    "XKERNEL_SDK_CSL_LIBS",
    "/cb/toolchains/cslang/rel-sdk-1.4.0/202504282304-1429-c9d41c22/csl-libs")
_sdk_cache: dict = {}


def _read_sdk_module_text(import_target: str) -> Optional[str]:
    """Read an SDK <mod/sub> module's pe-side source from the container.
    import_target like '<collectives_2d/pe>' -> csl-libs/collectives_2d/pe.csl.
    Returns the file text, or None if unavailable (no SIF / not found)."""
    inner = import_target.strip("<>")
    if "/" not in inner:
        inner = inner + "/pe"
    rel = inner + ".csl"
    if rel in _sdk_cache:
        return _sdk_cache[rel]
    text = None
    try:
        import subprocess, shutil
        if shutil.which("singularity") and os.path.isfile(_SDK_SIF):
            path = f"{_SDK_CSL_LIBS}/{rel}"
            r = subprocess.run(["singularity", "exec", _SDK_SIF, "cat", path],
                               capture_output=True, text=True, timeout=60)
            if r.returncode == 0 and r.stdout.strip():
                text = r.stdout
    except Exception:
        text = None
    _sdk_cache[rel] = text
    return text


def _extract_signatures_from_text(text: str) -> str:
    """Pull param decls + one-line fn signatures from CSL module source text."""
    params: List[str] = []
    fns: List[str] = []
    for raw in text.splitlines():
        line = raw.rstrip()
        if _PARAM_RE.match(line):
            decl = line.strip()
            if ";" in decl:
                decl = decl[: decl.index(";") + 1]
            params.append(decl)
            continue
        fm = _FN_RE.match(line)
        if fm:
            sig = line.strip()
            if "{" in sig:
                sig = sig[: sig.index("{")].strip()
            fns.append(sig)
    if not params and not fns:
        return ""
    chunk = []
    if params:
        chunk.append("// params your @import_module struct MUST supply "
                     "(exact names + arities):")
        chunk.extend(params)
    if fns:
        chunk.append("// callable helpers exposed by this module "
                     "(call via the module handle):")
        chunk.extend(fns)
    return "\n".join(chunk)


def _extract_signatures_from_pe(pe_path: Path) -> str:
    """Pull the param decls + one-line fn signatures from a library pe.csl."""
    try:
        text = pe_path.read_text(encoding="utf-8", errors="ignore")
    except OSError:
        return ""
    return _extract_signatures_from_text(text)


def library_signatures_block(reference_dir: str,
                             layout_text: str,
                             enabled: Optional[bool] = None,
                             arch: str = "wse3") -> str:
    """Build the injectable signature block for a kernel.

    Returns "" when disabled, when the layout imports no relevant libraries
    (single-PE kernels), or when nothing could be extracted — so the caller can
    inject unconditionally without special-casing.

    `arch` (default "wse3") selects the arch-specific library pe.csl so the
    emitted param types/arities match what the build actually compiles (C5 fix).

    Gate: XKERNEL_LIB_SIGNATURES (default "1"); pass enabled=False to force off
    for an A/B arm.
    """
    if enabled is None:
        enabled = os.getenv("XKERNEL_LIB_SIGNATURES", "1") != "0"
    if not enabled:
        return ""

    # Attributable A/B gate (2026-06-24): XKERNEL_FIXES_C4_C5_C10=0 reverts the C5
    # behavior — fall back to arch-NEUTRAL pe.csl resolution (the pre-fix path) and
    # suppress the @concat_structs overlay note — so a sweep can isolate C5's lift.
    _c5_on = os.getenv("XKERNEL_FIXES_C4_C5_C10", "1") != "0"
    if not _c5_on:
        arch = None  # neutral resolution (the old "prefer arch-neutral pe.csl" path)

    targets = discover_imported_libs(layout_text)
    if not targets:
        return ""

    sections: List[str] = []
    for t in targets:
        if t.startswith("<"):
            # SDK <...> module (e.g. <collectives_2d/pe>): read its REAL source
            # from inside the cslc container (NOT hand-authored prose — that
            # would be benchmark-overfitting). Honestly skipped if the SIF isn't
            # available. Gate XKERNEL_SDK_SIG=0 to disable container extraction.
            if os.getenv("XKERNEL_SDK_SIG", "1") == "0":
                continue
            text = _read_sdk_module_text(t)
            if not text:
                continue
            sig = _extract_signatures_from_text(text)
            if sig:
                sections.append(f"// ===== SDK module: {t} (real source) =====\n{sig}")
            continue
        pe = _resolve_pe_csl(reference_dir, t, arch=arch)
        if pe is None:
            continue
        sig = _extract_signatures_from_pe(pe)
        if sig:
            mod = t[: -len("/layout.csl")] if t.endswith("/layout.csl") else t
            # Note whether we resolved the arch-specific file (the typed shapes).
            arch_tag = f"/{arch}/" if f"/{arch}/" in str(pe).replace("\\", "/") else "/"
            sections.append(
                f"// ===== module: {mod} (from {pe.name}, arch path {arch_tag}) =====\n{sig}")

    if not sections:
        return ""

    header = (
        "## Library module signatures (the modules layout.csl imports that your "
        "COMPUTE file must instantiate)\n"
        "You do NOT see these library files, but your @import_module(...) struct "
        "MUST match these param names and arities EXACTLY (a mismatch is the #1 "
        "cause of W1 failure — e.g. dest_dsr_ids:[2]u16 is a 2-element array, "
        "src0_dsr_ids:[1]u16 is 1-element). Bind every listed param; call the "
        "listed helpers rather than rolling your own.\n"
    )
    body = header + "\n\n".join(sections)

    # C5 overlay note (failure-analysis 2026-06-23) — DEFAULT ON, gate
    # XKERNEL_LIB_OVERLAY_NOTE. The layout-supplied struct (e.g. stencilParams /
    # reduceParams passed to the compute file via @set_tile_code) ALREADY binds a
    # subset of these params; re-declaring them causes duplicated-COMM/BLOCK_SIZE
    # errors. Teach the @concat_structs overlay idiom so the agent supplies ONLY
    # the leaf params. Generic (no reference id values) -> firewall-safe.
    if _c5_on and os.getenv("XKERNEL_LIB_OVERLAY_NOTE", "1") != "0":
        if any(tok in body for tok in ("output_queues", "dsr_ids", "stencil", "reduce")):
            body += "\n\n" + _LIB_OVERLAY_NOTE
            # R1 in-place DSR rule — default-on; XKERNEL_FIXES_20260625=0 drops it for
            # the attributable A/B over the 2026-06-25 patch set.
            if os.getenv("XKERNEL_FIXES_20260625", "1") != "0" and "dsr_ids" in body:
                body += "\n" + _INPLACE_DSR_RULE

    # Layer 2 (queue/ut_id discipline note) — DEFAULT OFF as of 2026-06-20.
    # Rationale: the multi-seed cap-20 A/B (lever1_cap20_multiseed_report_20260620)
    # showed this note BACKFIRED — queue_or_ut_id errors +84% per-attempt and
    # solver pass-rate fell (Arm B 5/15 vs control 7/15). It bundles/confounds
    # with lib-sigs and appears to pull the agent into queue setup it would leave
    # to library defaults. Kept behind its OWN gate (default off) so the clean
    # lib-signature lever (validated −67% dsr-arity at cap-8) is the default and
    # the queue note can be re-tested in isolation (3-arm: off / sigs / sigs+queue).
    if os.getenv("XKERNEL_QUEUE_DISCIPLINE_NOTE", "0") == "1":
        if any(tok in body for tok in ("queues", "dsr_ids", "ut_id")):
            body += "\n\n" + _QUEUE_DISCIPLINE_NOTE

    behavioral = _behavioral_block(targets)
    if behavioral:
        body += "\n\n" + behavioral

    return body


# C5 overlay-discipline note (general SDK idiom, not bench-specific): how to
# instantiate a library module whose layout-supplied struct already binds some of
# the params listed above. Injects only the @concat_structs pattern + which params
# are layout-provided vs caller-supplied — never the reference's id VALUES.
_LIB_OVERLAY_NOTE = """// HOW TO INSTANTIATE these modules (avoid duplicated-param compile errors):
// The GIVEN layout.csl passes each module a params struct via @set_tile_code (e.g.
// stencilParams / reduceParams). That struct ALREADY binds: the colors, the
// COMM/SEND/RECV (or C_ROUTE/C_SEND_*) entrypoints, first_px/last_px/first_py/
// last_py, width, height. Do NOT re-declare those in your @import_module struct —
// wrap the layout struct and add ONLY the remaining leaf params with @concat_structs:
//
//   const stencil_mod = @import_module(
//       "../../benchmark-libs/stencil_3d_7pts/pe.csl",
//       @concat_structs(stencilParams, .{
//           .f_callback   = <your callback>,
//           .input_queues = [4]u16{ ... },   // arity from the signature above
//           .output_queues= [4]u16{ ... },   // [4]u16 on wse3, NOT [1]u16
//           .output_ut_id = <scalar u16>,    // SCALAR, not an array
//           .BLOCK_SIZE   = BLOCK_SIZE,
//           .dest_dsr_ids = [2]u16{ A, B },
//           .src0_dsr_ids = [1]u16{ A },     // (R1) src0_dsr_ids[0] == dest_dsr_ids[0]
//           .src1_dsr_ids = [2]u16{ C, D },  // src1 ids are independent
//       }));
//
// Pick your own distinct queue/DSR ids under the reserved-range rules; A/B/C/D above
// are generic placeholders. output_ut_id is a SCALAR u16 (a frequent arity mistake)."""


# R1 (failure-analysis 2026-06-25): the in-place-accumulate DSR rule. Kept as a separate
# constant so the 2026-06-25 attributable A/B gate (XKERNEL_FIXES_20260625) can drop it.
_INPLACE_DSR_RULE = """
// IN-PLACE-ACCUMULATE DSR RULE (stencil_3d_7pts / allreduce / collectives_2d only):
// these reduction libraries compute dest = src0 (+ coeff)*src1 IN PLACE, so the
// dest and src0 DSRs MUST alias on element 0 -> src0_dsr_ids[0] == dest_dsr_ids[0].
// Giving src0 a DISTINCT id from dest reads stale/zero accumulator state and yields a
// wrong-but-compiling result (or DSR-alias churn through the repair loop). src1 ids
// are genuinely separate (the operand being multiplied/added in). This is a property
// of the in-place reduction APIs above, NOT a universal rule for every library."""


# Curated, general WSE-3 queue/ut_id discipline (NOT bench-specific). Mirrors the
# canonical gotcha in csl_knowledge_base; emitted only when a kernel actually
# imports a fabric library that needs it.
_QUEUE_DISCIPLINE_NOTE = """// WSE-3 queue / microthread (ut_id) discipline for the queue/DSR params above:
//  - input_queue / output_queue / ut_id IDs are all 0..7 (8 is a compile error).
//  - memcpy reserves the queues bound to sys_mod.MEMCPYH2D_* / MEMCPYD2H_*
//    (conventionally ids 2 and 3); allocate YOUR color queues starting at 4.
//  - On WSE-3 every user queue MUST be initialized at comptime before data flows:
//      comptime { if (@is_arch(\"wse3\")) {
//        @initialize_queue(my_iq, .{ .color = MY_COLOR }); } }
//  - ut_id defaults to the queue id; give each concurrent async fabric op its
//    OWN ut_id (don't share, or you get \"trying to term ut_instr, not ours\").
//  - The dest/src*_dsr_ids you pass to a library module must be DISTINCT small
//    ids the module owns; reuse across modules causes runtime hcf."""


# ---------------------------------------------------------------------------
# Behavioral contracts — HOW to use these modules, not just WHAT they export.
# Generic SDK usage patterns (firewall-safe, not benchmark-specific).
# Gate: XKERNEL_LIB_BEHAVIORAL (default "1").
# ---------------------------------------------------------------------------

_BEHAVIORAL_CONTRACTS = {
    "<kernels/tally/pe>": """\
// BEHAVIORAL CONTRACT for <kernels/tally/pe>:
// The tally module accumulates a distributed count across a PE mesh in two phases.
//
// Phase 1 (your compute): call bump_tally(count) every time you produce a
//   result to tally (e.g. per-element histogram increment). You may call
//   bump_tally as many times as you like from any PE.
//
// Phase transition: when your PE's local compute is DONE, call
//   signal_completion() EXACTLY ONCE. This unblocks the tally's internal
//   receive task and starts the reduction chain. Every PE MUST call
//   signal_completion — if any PE skips it, the chain stalls (D2H 0 bytes).
//
// Phase 2 (automatic): the module internally forwards accumulated tallies
//   along the fabric ring. Do NOT call send_and_reset_tally() yourself —
//   it is a private function driven by the module's receive callbacks.
//
// Callback: when the final tally arrives at the output PE (is_output_tally=true),
//   the module activates your `callback` local_task_id. Your callback task
//   should read `local_tally` and initiate D2H (streaming send to host).
//
// Common mistakes:
//   - Forgetting signal_completion → infinite stall (D2H 0 bytes)
//   - Calling send_and_reset_tally manually → fights the module's FSM
//   - Re-initializing the module's input_queues → "queue already set"
//   - Using is_output_tally on more than one PE → double-send""",

    "<collectives_2d/pe>": """\
// BEHAVIORAL CONTRACT for <collectives_2d/pe>:
// Import SEPARATELY for x and y dimensions (two module instances, each with
// its own dim_params from the layout). Call init() on BOTH before any collective.
//
// Usage pattern:
//   const mpi_x = @import_module("<collectives_2d/pe>", @concat_structs(c2d_x_params, .{ ... }));
//   const mpi_y = @import_module("<collectives_2d/pe>", @concat_structs(c2d_y_params, .{ ... }));
//   // In a task:
//   mpi_x.init();
//   mpi_y.init();
//   mpi_x.broadcast(root_x, buf_ptr, count, callback_after_x);
//   // Inside callback_after_x:
//   mpi_y.reduce_fadds(root_y, send_ptr, recv_ptr, count, callback_after_y);
//
// Key functions (all take callback: local_task_id, activated on completion):
//   init()                              — MUST call before any collective
//   broadcast(root, buf, count, cb)     — root sends buf to all PEs in this dim
//   scatter(root, send, recv, cnt, cb)  — root distributes chunks
//   gather(root, send, recv, cnt, cb)   — all PEs send chunks to root
//   reduce_fadds(root, send, recv, cnt, cb) — sum-reduce f32 to root PE
//
// After reduce_fadds: the result is on the ROOT PE of that dimension ONLY.
//   If you reduce along x (mpi_x.reduce_fadds with root_x=0), the result
//   is on PE(0, py) — a COLUMN of PEs, not a single PE. To get a single
//   scalar, reduce along y next (mpi_y.reduce_fadds with root_y=0).
//
// Host-side D2H after reduction: read from the ROOT PE only.
//   collect("y", params) returns (cx, cy, cw=1, ch=1, elems=N) pointing at
//   the single root PE. Do NOT read from the full column — you'd get zeros
//   from non-root PEs.
//
// Buffers: send_buf and recv_buf are [*]u32 (not [*]f32). For f32 data,
//   declare var ptrs as [*]u32 and cast: @ptrcast([*]u32, &my_f32_array).
//
// Common mistakes:
//   - Forgetting init() → silent hang or hcf
//   - Using queues[0]=0 or [1]=1 → collides with memcpy reserved queues
//   - Sharing dest_dsr_ids across x and y modules → DSR conflict / hcf
//   - Reading reduced result from all PEs instead of root only""",
}


def _behavioral_block(module_targets: List[str]) -> str:
    """Return the behavioral contract text for any recognized module targets."""
    if os.getenv("XKERNEL_LIB_BEHAVIORAL", "1") == "0":
        return ""
    parts = []
    for t in module_targets:
        if t in _BEHAVIORAL_CONTRACTS:
            parts.append(_BEHAVIORAL_CONTRACTS[t])
    return "\n\n".join(parts)


if __name__ == "__main__":  # quick manual check
    import sys
    ref = sys.argv[1] if len(sys.argv) > 1 else "kernels/Power Method/CSL"
    lt = Path(ref, "src", "layout.csl")
    lt = lt if lt.is_file() else Path(ref, "layout.csl")
    print(library_signatures_block(ref, lt.read_text(encoding="utf-8")))
